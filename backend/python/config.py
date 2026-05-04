import os
from dataclasses import dataclass
from pathlib import Path
from typing import List


BASE_DIR = Path(__file__).resolve().parents[2]


def load_env_file(path: Path) -> None:
    if not path.is_file():
        return

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip())


load_env_file(BASE_DIR / ".env")


def env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def env_int(name: str, default: int) -> int:
    raw = os.getenv(name)
    if raw is None:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def env_csv(name: str) -> List[str]:
    raw = os.getenv(name, "")
    return [item.strip() for item in raw.split(",") if item.strip()]


@dataclass(frozen=True)
class Settings:
    app_env: str = os.getenv("APP_ENV", "development")
    api_host: str = os.getenv("API_HOST", "127.0.0.1")
    api_port: int = env_int("API_PORT", 8000)
    db_host: str = os.getenv("DB_HOST", "127.0.0.1")
    db_name: str = os.getenv("DB_NAME", "darmon_service")
    db_user: str = os.getenv("DB_USER", "root")
    db_pass: str = os.getenv("DB_PASS", "")
    token_ttl_hours: int = env_int("TOKEN_TTL_HOURS", 1)
    login_max_attempts: int = env_int("LOGIN_MAX_ATTEMPTS", 5)
    login_lock_minutes: int = env_int("LOGIN_LOCK_MINUTES", 10)
    cors_allow_origins: List[str] = tuple(env_csv("CORS_ALLOW_ORIGINS") or env_csv("CORS_ALLOW_ORIGIN"))
    smtp_host: str = os.getenv("SMTP_HOST", "")
    smtp_port: int = env_int("SMTP_PORT", 587)
    smtp_user: str = os.getenv("SMTP_USER", "")
    smtp_pass: str = os.getenv("SMTP_PASS", "")
    smtp_secure: str = os.getenv("SMTP_SECURE", "tls")
    smtp_from: str = os.getenv("SMTP_FROM", "gulsevar04@gmail.com")
    session_secret: str = os.getenv("FASTAPI_SESSION_SECRET", "change-me")
    session_cookie_name: str = os.getenv("SESSION_COOKIE_NAME", "darmon_session")
    session_cookie_secure: bool = env_bool("SESSION_COOKIE_SECURE", False)
    session_cookie_same_site: str = os.getenv("SESSION_COOKIE_SAMESITE", "lax")
    session_max_age_seconds: int = env_int("SESSION_MAX_AGE_SECONDS", 3600)


settings = Settings()
