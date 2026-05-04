from datetime import timedelta
from typing import Dict
from helpers import *
from response_utils import secure_json


def fetch_one(cursor, query: str, params: tuple = ()) -> Optional[Dict]:
    cursor.execute(query, params)
    return cursor.fetchone()


def auth_user(cursor, raw_token: Optional[str]) -> Optional[Dict]:
    if not raw_token:
        return None

    cursor.execute(
        '''
        SELECT u.*
        FROM user_tokens t
        JOIN users u ON u.id = t.user_id
        WHERE t.token_hash = %s
          AND t.revoked_at IS NULL
          AND (t.expires_at IS NULL OR t.expires_at > NOW())
        LIMIT 1
        ''',
        (token_hash(raw_token),),
    )
    user = cursor.fetchone()
    if user:
        cursor.execute(
            'UPDATE user_tokens SET last_used_at = NOW() WHERE token_hash = %s LIMIT 1',
            (token_hash(raw_token),),
        )
    return user


def serialize_user(user: Dict) -> Dict:
    return {'id': user['id'], 'name': user['name'], 'email': user['email'], 'role': user['role']}


def require_admin(cursor, token: Optional[str]) -> Optional[Dict]:
    user = auth_user(cursor, token)
    if user and user.get('role') == 'admin':
        return user
    return None


def require_roles(cursor, token: Optional[str], roles) -> Optional[Dict]:
    user = auth_user(cursor, token)
    if user and user.get('role') in set(roles):
        return user
    return None



def unauthorized_or_forbidden(token: Optional[str]):
    if token:
        return secure_json({'ok': False, 'error': 'Forbidden.'}, 403)
    return secure_json({'ok': False, 'error': 'Not logged in.'}, 401)


def not_logged_in():
    return secure_json({'ok': False, 'error': 'Not logged in.'}, 401)


def require_user_or_error(cursor, token: Optional[str]):
    user = auth_user(cursor, token)
    if user:
        return user, None
    return None, not_logged_in()


def require_roles_or_error(cursor, token: Optional[str], roles):
    user = require_roles(cursor, token, roles)
    if user:
        return user, None
    return None, unauthorized_or_forbidden(token)


def require_user_role_or_error(cursor, token: Optional[str], role: str):
    return require_roles_or_error(cursor, token, {role})


def is_locked(cursor, email: str) -> bool:
    row = fetch_one(cursor, 'SELECT locked_until FROM users WHERE email=%s LIMIT 1', (email,))
    return bool(row and row.get('locked_until') and row['locked_until'] > datetime.now())


def register_failed_login(cursor, email: str) -> None:
    cursor.execute(
        '''
        UPDATE users
        SET failed_login_attempts = failed_login_attempts + 1,
            last_failed_login = NOW()
        WHERE email=%s LIMIT 1
        ''',
        (email,),
    )
    row = fetch_one(cursor, 'SELECT failed_login_attempts FROM users WHERE email=%s LIMIT 1', (email,))
    if row and int(row['failed_login_attempts']) >= settings.login_max_attempts:
        lock_until = datetime.now() + timedelta(minutes=settings.login_lock_minutes)
        cursor.execute(
            '''
            UPDATE users
            SET locked_until = %s
            WHERE email=%s LIMIT 1
            ''',
            (lock_until, email),
        )


def clear_failed_login(cursor, user_id: int) -> None:
    cursor.execute(
        '''
        UPDATE users
        SET failed_login_attempts = 0, locked_until = NULL
        WHERE id=%s LIMIT 1
        ''',
        (user_id,),
    )


def create_otp(cursor, email: str, purpose: str) -> None:
    cursor.execute('DELETE FROM user_otps WHERE email=%s AND purpose=%s', (email, purpose))
    otp = generate_otp()
    cursor.execute(
        '''
        INSERT INTO user_otps (email, purpose, otp_hash, expires_at)
        VALUES (%s, %s, %s, DATE_ADD(NOW(), INTERVAL 25 MINUTE))
        ''',
        (email, purpose, otp_hash(otp)),
    )
    send_otp_email(email, otp, purpose)


def ensure_auth_schema(cursor) -> None:
    row = fetch_one(
        cursor,
        '''
        SELECT COLUMN_TYPE AS column_type
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA=%s
          AND TABLE_NAME='user_otps'
          AND COLUMN_NAME='purpose'
        LIMIT 1
        ''',
        (settings.db_name,),
    )
    if not row:
        return

    column_type = str(row.get('column_type', ''))
    if 'password_reset' in column_type:
        return

    cursor.execute(
        '''
        ALTER TABLE user_otps
        MODIFY purpose ENUM('register','login','password_reset') NOT NULL
        '''
    )


def issue_user_token(cursor, user_id: int, request: Request):
    raw = make_token(32)
    cursor.execute(
        '''
        INSERT INTO user_tokens(user_id, token_hash, expires_at, ip, user_agent)
        VALUES(%s, %s, DATE_ADD(NOW(), INTERVAL %s HOUR), %s, %s)
        ''',
        (user_id, token_hash(raw), settings.token_ttl_hours, client_ip(request), client_ua(request)),
    )
    user = fetch_one(cursor, 'SELECT id, name, email, role FROM users WHERE id=%s LIMIT 1', (user_id,))
    return secure_json({'ok': True, 'data': {'token': raw, 'user': serialize_user(user)}})


def create_appointment(cursor, user_id: int, doctor_id: int, appointment_date: str, time_slot: str):
    cursor.execute(
        '''
        INSERT INTO appointments(user_id, doctor_id, appointment_date, time_slot, status)
        VALUES(%s, %s, %s, %s, 'booked')
        ''',
        (user_id, doctor_id, appointment_date, time_slot),
    )
    return cursor.lastrowid


def create_patient_by_admin(cursor, payload) -> Optional[int]:
    name = str(payload.get('new_patient_name', '')).strip()
    phone = str(payload.get('new_patient_phone', '')).strip()
    email = normalize_email(str(payload.get('new_patient_email', '')))
    password = str(payload.get('new_patient_password', ''))

    if not name or not phone or not email or len(password) < 8:
        return None
    if not is_valid_phone(phone):
        return None
    if fetch_one(cursor, 'SELECT id FROM users WHERE email=%s LIMIT 1', (email,)):
        return -1

    cursor.execute(
        '''
        INSERT INTO users(name, phone, email, password_hash, role)
        VALUES(%s, %s, %s, %s, 'patient')
        ''',
        (name, phone, email, password_hash_secure(password)),
    )
    return cursor.lastrowid


def validate_appointment_fields(cursor, doctor_id: int, appointment_date: str, time_slot: str):
    if not doctor_id or not appointment_date or not time_slot:
        return secure_json({'ok': False, 'error': 'Missing fields.'}, 400)

    try:
        slot = datetime.strptime(f'{appointment_date} {time_slot}', '%Y-%m-%d %H:%M')
    except ValueError:
        return secure_json({'ok': False, 'error': 'Invalid date/time.'}, 400)

    if slot <= datetime.now():
        return secure_json({'ok': False, 'error': 'Invalid time, choose a future slot.'}, 400)

    doctor = fetch_one(cursor, 'SELECT id FROM doctors WHERE id=%s AND is_active=1 LIMIT 1', (doctor_id,))
    if not doctor:
        return secure_json({'ok': False, 'error': 'Doctor not found.'}, 404)
    return None


def get_active_doctors(cursor):
    cursor.execute(
        '''
        SELECT id, full_name, specialty, experience_years
        FROM doctors
        WHERE is_active = 1
        ORDER BY full_name
        '''
    )
    return cursor.fetchall()


def get_ready_results(cursor, user_id: int):
    cursor.execute(
        '''
        SELECT receipt_id, test_name, upload_date, file_path
        FROM lab_results
        WHERE user_id=%s AND status='Ready'
        ORDER BY upload_date DESC
        ''',
        (user_id,),
    )
    return [
        {
            'receipt_id': row['receipt_id'],
            'test_name': row['test_name'],
            'upload_date': row['upload_date'],
            'download_url': f"/download?receipt_id={row['receipt_id']}",
        }
        for row in cursor.fetchall()
    ]


def get_doctor_record_for_user(cursor, user_name: str):
    return fetch_one(
        cursor,
        '''
        SELECT id, full_name, specialty
        FROM doctors
        WHERE is_active = 1
          AND (
              LOWER(full_name) = LOWER(%s)
              OR LOWER(CONCAT('Dr. ', full_name)) = LOWER(%s)
          )
        LIMIT 1
        ''',
        (user_name, user_name),
    )


def require_active_doctor_or_error(cursor, token: Optional[str]):
    user, error_response = require_user_role_or_error(cursor, token, 'doctor')
    if error_response:
        return None, None, error_response

    doctor = get_doctor_record_for_user(cursor, user['name'])
    if doctor:
        return user, doctor, None

    return None, None, secure_json({'ok': False, 'error': 'Doctor account is inactive.'}, 403)


def doctor_has_patient_access(cursor, doctor_id: int, patient_id: int) -> bool:
    if not doctor_id or not patient_id:
        return False

    row = fetch_one(
        cursor,
        '''
        SELECT 1
        FROM appointments
        WHERE doctor_id=%s
          AND user_id=%s
          AND status <> 'canceled'
        LIMIT 1
        ''',
        (doctor_id, patient_id),
    )
    return bool(row)



def serialize_ambulance_request(row):
    if not row:
        return None

    request = dict(row)
    eta_minutes = float(request.get('eta_minutes') or 0)
    created_at = request.get('created_at')
    remaining_seconds = 0
    expires_at = None

    if created_at:
        expires_at = created_at + timedelta(seconds=max(0, int(round(eta_minutes * 60))))
        remaining_seconds = max(0, int((expires_at - datetime.now()).total_seconds()))

    request['eta_minutes'] = eta_minutes
    request['expires_at'] = expires_at
    request['remaining_seconds'] = remaining_seconds
    request['is_active'] = remaining_seconds > 0
    return request


def get_recent_ambulance_requests(cursor, limit: int = 10):
    cursor.execute(
        '''
        SELECT id, full_name, phone, address, eta_minutes, distance_km, created_at
        FROM ambulance_requests
        ORDER BY created_at DESC
        LIMIT %s
        ''',
        (limit,),
    )
    return [serialize_ambulance_request(row) for row in cursor.fetchall()]


def get_active_ambulance_request(cursor):
    for request in get_recent_ambulance_requests(cursor, limit=25):
        if request and request.get('is_active'):
            return request
    return None
