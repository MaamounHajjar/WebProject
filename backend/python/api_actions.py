from actions_admin import *
from actions_auth import *
from actions_booking import *
from actions_public import *
from db import get_db
from helpers import write_error_log
from response_utils import secure_json

ACTION_HANDLERS = {
    "register": handle_register,
    "verify_register_otp": handle_verify_register_otp,
    "login": handle_login,
    "verify_login_otp": handle_verify_login_otp,
    "request_password_reset": handle_request_password_reset,
    "verify_password_reset_otp": handle_verify_password_reset_otp,
    "reset_password": handle_reset_password,
    "logout": handle_logout,
    "list_doctors": handle_list_doctors,
    "book_appointment": handle_book_appointment,
    "admin_book_appointment": handle_book_appointment,
    "quick_check": handle_quick_check,
    "my_results": handle_my_results,
    "account_overview": handle_account_overview,
    "me": handle_me,
    "callback_request": handle_callback_request,
    "request_ambulance": handle_request_ambulance,
    "vacancies": handle_vacancies,
    "admin_update_appointment_status": handle_admin_update_appointment_status,
    "admin_save_doctor": handle_admin_save_doctor,
    "admin_delete_doctor": handle_admin_delete_doctor,
    "admin_save_vacancy": handle_admin_save_vacancy,
    "admin_delete_vacancy": handle_admin_delete_vacancy,
    "admin_dashboard": handle_admin_dashboard,
    "staff_dashboard": handle_staff_dashboard,
    "doctor_dashboard": handle_doctor_dashboard,
    "doctor_patients": handle_doctor_patients,
    "doctor_patient_detail": handle_doctor_patient_detail,
    "doctor_save_patient_plan": handle_doctor_save_patient_plan,
}

def handle_api_action(request: Request, payload, token):
    action = payload.get("action", "")
    handler = ACTION_HANDLERS.get(action)
    if not handler:
        return secure_json({"ok": False, "error": "Unknown action."}, 400)

    try:
        with get_db() as connection:
            with connection.cursor() as cursor:
                if action in {"book_appointment", "admin_book_appointment"}:
                    return handle_book_appointment(request, cursor, payload, token, action)
                return handler(request, cursor, payload, token)
    except Exception as exc:
        write_error_log(str(exc))
        return secure_json({"ok": False, "error": "Internal server error"}, 500)
