import hashlib
import json
import secrets
import smtplib
import re
from datetime import datetime, timezone
from email.message import EmailMessage
from typing import Any, Optional

import bcrypt
from fastapi import Request

from config import BASE_DIR, settings


ERROR_LOG = BASE_DIR / "backend" / "python" / "error.log"


def normalize_email(email: str) -> str:
    return email.strip().lower()


def is_valid_phone(phone: str) -> bool:
    return bool(re.match(r"^\+?[0-9 \-]{7,20}$", phone))


def password_hash_secure(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt(rounds=12)).decode("utf-8")


def password_verify(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))


def make_token(byte_count: int = 32) -> str:
    return secrets.token_hex(byte_count)


def token_hash(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def otp_hash(otp: str) -> str:
    return hashlib.sha256(otp.encode("utf-8")).hexdigest()


def generate_otp() -> str:
    return f"{secrets.randbelow(1_000_000):06d}"


def get_bearer_token(request: Request) -> Optional[str]:
    header = request.headers.get("Authorization", "")
    if header.lower().startswith("bearer "):
        return header[7:].strip()
    return None


def client_ip(request: Request) -> str:
    if request.client and request.client.host:
      return request.client.host
    return "0.0.0.0"


def client_ua(request: Request) -> str:
    return request.headers.get("user-agent", "unknown")[:255]


def device_hash(request: Request) -> str:
    return hashlib.sha256(request.headers.get("user-agent", "").encode("utf-8")).hexdigest()


def write_error_log(message: str) -> None:
    timestamp = datetime.now(timezone.utc).isoformat()
    ERROR_LOG.parent.mkdir(parents=True, exist_ok=True)
    with ERROR_LOG.open("a", encoding="utf-8") as handle:
        handle.write(f"[{timestamp}] {message}\n")


def send_otp_email(email: str, otp: str, purpose: str) -> None:
    if purpose == "register":
        subject = "Verify your email"
        intro = "Use this code to finish creating your account."
    elif purpose == "password_reset":
        subject = "Your password reset code"
        intro = "Use this code to reset your password."
    else:
        subject = "Your login verification code"
        intro = "Use this code to finish signing in."

    message_body = f"{intro}\n\nYour verification code is: {otp}\n\nThis code expires in 25 minutes."

    if settings.smtp_host:
        try:
            msg = EmailMessage()
            msg["Subject"] = subject
            msg["From"] = settings.smtp_from
            msg["To"] = email
            msg.set_content(message_body)

            if settings.smtp_secure == "ssl":
                with smtplib.SMTP_SSL(settings.smtp_host, settings.smtp_port) as smtp:
                    if settings.smtp_user:
                        smtp.login(settings.smtp_user, settings.smtp_pass)
                    smtp.send_message(msg)
            else:
                with smtplib.SMTP(settings.smtp_host, settings.smtp_port) as smtp:
                    smtp.starttls()
                    if settings.smtp_user:
                        smtp.login(settings.smtp_user, settings.smtp_pass)
                    smtp.send_message(msg)
        except Exception as exc:
            pass
            #write_error_log(f"SMTP error: {exc}")

    #write_error_log(f"OTP {purpose} to {email} = {otp}")


def json_log_payload(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False)
