from services import *


def handle_register(request, cursor, payload, token):
    del token
    name = str(payload.get('name', '')).strip()
    phone = str(payload.get('phone', '')).strip()
    email = normalize_email(str(payload.get('email', '')))
    password = str(payload.get('password', ''))

    if not name or not phone or not email or len(password) < 8:
        return secure_json({'ok': False, 'error': 'Invalid data'}, 400)
    if fetch_one(cursor, 'SELECT id FROM users WHERE email=%s LIMIT 1', (email,)):
        return secure_json({'ok': False, 'error': 'Email already registered'}, 409)

    request.session['reg'] = {
        'name': name,
        'phone': phone,
        'email': email,
        'password_hash': password_hash_secure(password),
    }
    create_otp(cursor, email, 'register')
    return secure_json({'ok': True, 'step': 'otp_sent'})


def handle_verify_register_otp(request, cursor, payload, token):
    del token
    email = normalize_email(str(payload.get('email', '')))
    otp = str(payload.get('otp', '')).strip()
    remember = bool(payload.get('remember_device'))
    reg = request.session.get('reg')
    row = fetch_one(
        cursor,
        '''
        SELECT otp_hash
        FROM user_otps
        WHERE email=%s AND purpose='register' AND expires_at > NOW()
        LIMIT 1
        ''',
        (email,),
    )
    if not row or row['otp_hash'] != otp_hash(otp):
        return secure_json({'ok': False, 'error': 'Invalid OTP'}, 401)
    if not reg or reg.get('email') != email:
        return secure_json({'ok': False, 'error': 'Session expired'}, 400)

    cursor.execute(
        '''
        INSERT INTO users(name, phone, email, password_hash, role)
        VALUES(%s, %s, %s, %s, 'patient')
        ''',
        (reg['name'], reg['phone'], reg['email'], reg['password_hash']),
    )
    user_id = cursor.lastrowid
    request.session.pop('reg', None)
    cursor.execute('DELETE FROM user_otps WHERE email=%s AND purpose=%s', (email, 'register'))

    if remember:
        cursor.execute(
            '''
            INSERT INTO trusted_devices(user_id, device_hash, expires_at)
            VALUES(%s, %s, DATE_ADD(NOW(), INTERVAL 10 DAY))
            ''',
            (user_id, device_hash(request)),
        )

    return issue_user_token(cursor, user_id, request)


def handle_login(request, cursor, payload, token):
    del token
    email = normalize_email(str(payload.get('email', '')))
    password = str(payload.get('password', ''))

    if is_locked(cursor, email):
        return secure_json({'ok': False, 'error': 'Too many attempts'}, 429)

    user = fetch_one(cursor, 'SELECT * FROM users WHERE email=%s LIMIT 1', (email,))
    if not user or not password_verify(password, user['password_hash']):
        if user:
            register_failed_login(cursor, email)
        return secure_json({'ok': False, 'error': 'Wrong credentials'}, 401)

    clear_failed_login(cursor, int(user['id']))
    if user.get('role') != 'admin':
        trusted = fetch_one(
            cursor,
            '''
            SELECT 1 FROM trusted_devices
            WHERE user_id=%s AND device_hash=%s AND expires_at > NOW()
            LIMIT 1
            ''',
            (user['id'], device_hash(request)),
        )
        if trusted:
            cursor.execute(
                '''
                UPDATE trusted_devices
                SET expires_at = DATE_ADD(NOW(), INTERVAL 10 DAY)
                WHERE user_id=%s AND device_hash=%s
                ''',
                (user['id'], device_hash(request)),
            )
            return issue_user_token(cursor, int(user['id']), request)

    create_otp(cursor, email, 'login')
    request.session['login_uid'] = int(user['id'])
    return secure_json({'ok': True, 'step': 'otp_required'})


def handle_verify_login_otp(request, cursor, payload, token):
    del token
    email = normalize_email(str(payload.get('email', '')))
    otp = str(payload.get('otp', '')).strip()
    remember = bool(payload.get('remember_device'))
    uid = request.session.get('login_uid')
    row = fetch_one(
        cursor,
        '''
        SELECT otp_hash
        FROM user_otps
        WHERE email=%s AND purpose='login' AND expires_at > NOW()
        LIMIT 1
        ''',
        (email,),
    )
    if not row or row['otp_hash'] != otp_hash(otp):
        return secure_json({'ok': False, 'error': 'Invalid OTP'}, 401)
    if not uid:
        return secure_json({'ok': False, 'error': 'Session expired'}, 400)

    login_user = fetch_one(cursor, 'SELECT id, role FROM users WHERE id=%s LIMIT 1', (uid,))
    if remember and login_user and login_user.get('role') != 'admin':
        cursor.execute(
            '''
            INSERT INTO trusted_devices(user_id, device_hash, expires_at)
            VALUES(%s, %s, DATE_ADD(NOW(), INTERVAL 10 DAY))
            ON DUPLICATE KEY UPDATE expires_at = DATE_ADD(NOW(), INTERVAL 10 DAY)
            ''',
            (uid, device_hash(request)),
        )

    cursor.execute('DELETE FROM user_otps WHERE email=%s AND purpose=%s', (email, 'login'))
    request.session.pop('login_uid', None)
    return issue_user_token(cursor, int(uid), request)


def handle_request_password_reset(request, cursor, payload, token):
    del token
    email = normalize_email(str(payload.get('email', '')))
    if not email:
        return secure_json({'ok': False, 'error': 'Email is required'}, 400)

    user = fetch_one(cursor, 'SELECT id FROM users WHERE email=%s LIMIT 1', (email,))
    if not user:
        return secure_json({'ok': False, 'error': 'Email not found'}, 404)

    request.session['password_reset'] = {
        'user_id': int(user['id']),
        'email': email,
    }
    request.session.pop('password_reset_verified', None)
    create_otp(cursor, email, 'password_reset')
    return secure_json({'ok': True, 'step': 'otp_sent'})


def handle_verify_password_reset_otp(request, cursor, payload, token):
    del token
    email = normalize_email(str(payload.get('email', '')))
    otp = str(payload.get('otp', '')).strip()
    reset_session = request.session.get('password_reset')
    if not reset_session or reset_session.get('email') != email:
        return secure_json({'ok': False, 'error': 'Session expired'}, 400)

    row = fetch_one(
        cursor,
        '''
        SELECT otp_hash
        FROM user_otps
        WHERE email=%s AND purpose='password_reset' AND expires_at > NOW()
        LIMIT 1
        ''',
        (email,),
    )
    if not row or row['otp_hash'] != otp_hash(otp):
        return secure_json({'ok': False, 'error': 'Invalid OTP'}, 401)

    request.session['password_reset_verified'] = {
        'user_id': int(reset_session['user_id']),
        'email': email,
    }
    cursor.execute('DELETE FROM user_otps WHERE email=%s AND purpose=%s', (email, 'password_reset'))
    return secure_json({'ok': True, 'step': 'password_required'})


def handle_reset_password(request, cursor, payload, token):
    del token
    email = normalize_email(str(payload.get('email', '')))
    password = str(payload.get('password', ''))
    confirm_password = str(payload.get('confirm_password', ''))
    verified_session = request.session.get('password_reset_verified')

    if not verified_session or verified_session.get('email') != email:
        return secure_json({'ok': False, 'error': 'Session expired'}, 400)
    if len(password) < 8:
        return secure_json({'ok': False, 'error': 'Password must be at least 8 characters'}, 400)
    if password != confirm_password:
        return secure_json({'ok': False, 'error': 'Passwords do not match'}, 400)

    user = fetch_one(
        cursor,
        'SELECT id, password_hash FROM users WHERE id=%s AND email=%s LIMIT 1',
        (int(verified_session['user_id']), email),
    )
    if not user:
        return secure_json({'ok': False, 'error': 'User not found'}, 404)
    if password_verify(password, user['password_hash']):
        return secure_json({'ok': False, 'error': 'New password must be different from the old password'}, 400)

    cursor.execute(
        '''
        UPDATE users
        SET password_hash=%s,
            failed_login_attempts=0,
            last_failed_login=NULL,
            locked_until=NULL
        WHERE id=%s
        LIMIT 1
        ''',
        (password_hash_secure(password), int(user['id'])),
    )
    cursor.execute('DELETE FROM trusted_devices WHERE user_id=%s', (int(user['id']),))
    cursor.execute(
        '''
        UPDATE user_tokens
        SET revoked_at = NOW()
        WHERE user_id=%s AND revoked_at IS NULL
        ''',
        (int(user['id']),),
    )
    cursor.execute('DELETE FROM user_otps WHERE email=%s AND purpose=%s', (email, 'password_reset'))
    request.session.pop('password_reset', None)
    request.session.pop('password_reset_verified', None)
    return secure_json({'ok': True, 'message': 'Password updated. Sign in with your new password.'})


def handle_logout(request, cursor, payload, token):
    del request, payload
    if not token:
        return secure_json({'ok': False, 'error': 'Not logged in.'}, 401)
    cursor.execute(
        '''
        UPDATE user_tokens
        SET revoked_at = NOW()
        WHERE token_hash = %s AND revoked_at IS NULL
        LIMIT 1
        ''',
        (token_hash(token),),
    )
    return secure_json({'ok': True})


def handle_me(request, cursor, payload, token):
    del request, payload
    user = auth_user(cursor, token)
    if not user:
        return not_logged_in()
    return secure_json({'ok': True, 'data': serialize_user(user)})
