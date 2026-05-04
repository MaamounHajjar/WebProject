import asyncio
from typing import Optional

from fastapi import FastAPI, HTTPException, Request, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, PlainTextResponse
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import OperationFailure, PyMongoError
from starlette.middleware.sessions import SessionMiddleware

from alerts import build_live_payload
from ambulance_utils import predict_arrival_for_address
from api_actions import handle_api_action
from config import BASE_DIR, settings
from db import get_db
from helpers import get_bearer_token, write_error_log
from response_utils import make_json_safe
from services import (
    auth_user,
    doctor_has_patient_access,
    ensure_auth_schema,
    fetch_one,
    get_active_ambulance_request,
    require_active_doctor_or_error,
)

mongo_client = AsyncIOMotorClient("mongodb://localhost:27017")
mongodb = mongo_client["darmon_health"]

app = FastAPI(title="Darmon Service API")
app.add_middleware(
    SessionMiddleware,
    secret_key=settings.session_secret,
    session_cookie=settings.session_cookie_name,
    same_site=settings.session_cookie_same_site,
    https_only=settings.session_cookie_secure,
    max_age=settings.session_max_age_seconds,
)

allowed_origins = list(settings.cors_allow_origins) or [
    "http://localhost",
    "http://127.0.0.1",
]

if allowed_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=list(dict.fromkeys(allowed_origins)),
        allow_credentials=True,
        allow_methods=["POST", "GET", "OPTIONS"],
        allow_headers=["Content-Type", "Authorization"],
    )


@app.on_event("startup")
def ensure_database_schema():
    try:
        with get_db() as connection:
            with connection.cursor() as cursor:
                ensure_auth_schema(cursor)
    except Exception as exc:
        write_error_log(f"Schema bootstrap error: {exc}")

def get_request_token(request: Request, payload: dict) -> Optional[str]:
    return get_bearer_token(request) or payload.get("token")


def resolve_result_file(file_path: str):
    base_dir = BASE_DIR.resolve()
    full_path = (base_dir / file_path).resolve()
    if base_dir not in full_path.parents and full_path != base_dir:
        return None, PlainTextResponse("Invalid path", status_code=400)
    if not full_path.is_file():
        return None, PlainTextResponse("File missing", status_code=404)
    return full_path, None


def build_patient_live_payload(snapshot):
    with get_db() as connection:
        with connection.cursor() as cursor:
            ambulance_request = get_active_ambulance_request(cursor)
    return build_live_payload(snapshot, ambulance_request)


def build_patient_id_match(patient_id: str):
    candidates = [patient_id]
    try:
        candidates.append(int(patient_id))
    except (TypeError, ValueError):
        pass
    return {"$in": candidates}


async def send_latest_patient_snapshot(websocket: WebSocket, patient_id: str):
    latest_snapshot = await mongodb.patient_vitals.find_one(
        {"patient_id": build_patient_id_match(patient_id)},
        sort=[("timestamp", -1)],
    )
    if latest_snapshot:
        payload = build_patient_live_payload(latest_snapshot)
        await websocket.send_json(make_json_safe(payload))
    return latest_snapshot


async def stream_patient_vitals_with_change_stream(websocket: WebSocket, patient_id: str):
    pipeline = [{"$match": {"fullDocument.patient_id": build_patient_id_match(patient_id)}}]
    async with mongodb.patient_vitals.watch(pipeline) as stream:
        async for change in stream:
            payload = build_patient_live_payload(change["fullDocument"])
            await websocket.send_json(make_json_safe(payload))


async def stream_patient_vitals_with_polling(websocket: WebSocket, patient_id: str, latest_snapshot=None):
    last_snapshot_id = str(latest_snapshot.get("_id")) if latest_snapshot else None
    while True:
        snapshot = await mongodb.patient_vitals.find_one(
            {"patient_id": build_patient_id_match(patient_id)},
            sort=[("timestamp", -1)],
        )
        snapshot_id = str(snapshot.get("_id")) if snapshot else None
        if snapshot and snapshot_id != last_snapshot_id:
            payload = build_patient_live_payload(snapshot)
            await websocket.send_json(make_json_safe(payload))
            last_snapshot_id = snapshot_id
        await asyncio.sleep(0.5)


@app.post("/api")
async def api(request: Request):
    try:
        payload = await request.json()
    except Exception:
        payload = {}

    token = get_request_token(request, payload)
    return handle_api_action(request, payload, token)


@app.websocket("/ws/vitals/{patient_id}")
async def vitals_websocket(websocket: WebSocket, patient_id: str):
    raw_token = websocket.query_params.get("token")
    authorization = websocket.headers.get("authorization", "")
    if not raw_token and authorization.lower().startswith("bearer "):
        raw_token = authorization.split(" ", 1)[1].strip()

    try:
        numeric_patient_id = int(patient_id)
    except (TypeError, ValueError):
        await websocket.close(code=1008)
        return

    with get_db() as connection:
        with connection.cursor() as cursor:
            _, doctor, error_response = require_active_doctor_or_error(cursor, raw_token)
            if error_response or not doctor_has_patient_access(cursor, doctor['id'], numeric_patient_id):
                await websocket.close(code=1008)
                return

    await websocket.accept()
    try:
        latest_snapshot = await mongodb.patient_vitals.find_one(
            {"patient_id": build_patient_id_match(patient_id)},
            sort=[("timestamp", -1)],
        )
        try:
            await stream_patient_vitals_with_change_stream(websocket, patient_id)
        except OperationFailure as exc:
            if getattr(exc, "code", None) != 40573:
                raise
            await stream_patient_vitals_with_polling(websocket, patient_id, latest_snapshot)
        except PyMongoError:
            await stream_patient_vitals_with_polling(websocket, patient_id, latest_snapshot)
    except WebSocketDisconnect:
        print(f"Doctor disconnected from patient {patient_id}")


@app.get("/download")
def download(receipt_id: str, request: Request, token: Optional[str] = None):
    raw_token = get_bearer_token(request) or token

    try:
        with get_db() as connection:
            with connection.cursor() as cursor:
                user = auth_user(cursor, raw_token)
                if not user:
                    return PlainTextResponse("Forbidden", status_code=403)

                row = fetch_one(
                    cursor,
                    """
                    SELECT file_path, test_name
                    FROM lab_results
                    WHERE user_id=%s AND receipt_id=%s AND status='Ready'
                    LIMIT 1
                    """,
                    (user["id"], receipt_id),
                )
                if not row or not row.get("file_path"):
                    return PlainTextResponse("Not found", status_code=404)

                full_path, error_response = resolve_result_file(row["file_path"])
                if error_response:
                    return error_response

                return FileResponse(
                    path=full_path,
                    media_type="application/pdf",
                    filename=f"result_{receipt_id}.pdf",
                    headers={"X-Content-Type-Options": "nosniff"},
                )
    except Exception as exc:
        write_error_log(str(exc))
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/predict_arrival")
def predict_arrival(address):
    result = predict_arrival_for_address(address)
    if not result["ok"]:
        return {"error": result["error"]}
    return result["data"]
