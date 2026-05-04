from ambulance_utils import predict_arrival_for_address
from response_utils import secure_json
from services import fetch_one, is_valid_phone


def handle_list_doctors(request, cursor, payload, token):
    del request, payload, token
    cursor.execute(
        '''
        SELECT id, full_name, specialty, experience_years
        FROM doctors
        WHERE is_active = 1
        ORDER BY full_name
        '''
    )
    return secure_json({'ok': True, 'data': cursor.fetchall()})


def handle_quick_check(request, cursor, payload, token):
    del request, token
    receipt_id = str(payload.get('receipt_id', '')).strip()
    sample_date = str(payload.get('date', '')).strip()
    if not receipt_id or not sample_date:
        return secure_json({'ok': False, 'error': 'Missing fields.'}, 400)

    row = fetch_one(
        cursor,
        '''
        SELECT receipt_id, test_name, status, sample_date
        FROM lab_results
        WHERE receipt_id=%s AND sample_date=%s
        LIMIT 1
        ''',
        (receipt_id, sample_date),
    )
    if not row:
        return secure_json({'ok': False, 'error': 'Not found. Check Receipt ID and Date.'}, 404)
    return secure_json({'ok': True, 'data': row})


def handle_callback_request(request, cursor, payload, token):
    del request, token
    first_name = str(payload.get('first_name', '')).strip()
    last_name = str(payload.get('last_name', '')).strip()
    phone = str(payload.get('phone', '')).strip()
    preferred_time = str(payload.get('preferred_time', '')).strip()
    if not first_name or not last_name or not phone or not preferred_time:
        return secure_json({'ok': False, 'error': 'Please fill all fields.'}, 400)
    if not is_valid_phone(phone):
        return secure_json({'ok': False, 'error': 'Invalid phone.'}, 400)

    cursor.execute(
        '''
        INSERT INTO callback_requests(first_name, last_name, phone, preferred_time)
        VALUES(%s, %s, %s, %s)
        ''',
        (first_name, last_name, phone, preferred_time),
    )
    return secure_json({'ok': True})


def handle_vacancies(request, cursor, payload, token):
    del request, payload, token
    cursor.execute(
        '''
        SELECT id, title, description, requirements
        FROM vacancies
        WHERE is_active=1
        ORDER BY created_at DESC
        '''
    )
    return secure_json({'ok': True, 'data': cursor.fetchall()})


def handle_request_ambulance(request, cursor, payload, token):
    del request, token
    full_name = str(payload.get('full_name', '')).strip()
    phone = str(payload.get('phone', '')).strip()
    address = str(payload.get('address', '')).strip()

    if not full_name:
        return secure_json({'ok': False, 'error': 'Full name is required.'}, 400)
    if not phone:
        return secure_json({'ok': False, 'error': 'Phone number is required.'}, 400)
    if not is_valid_phone(phone):
        return secure_json({'ok': False, 'error': 'Invalid phone number.'}, 400)
    if not address:
        return secure_json({'ok': False, 'error': 'Address is required.'}, 400)

    prediction = predict_arrival_for_address(address)
    if not prediction['ok']:
        return secure_json({'ok': False, 'error': prediction['error']}, 400)

    cursor.execute(
        '''
        INSERT INTO ambulance_requests(full_name, phone, address, eta_minutes, distance_km)
        VALUES(%s, %s, %s, %s, %s)
        ''',
        (
            full_name,
            phone,
            address,
            prediction['data']['arrival_time_min'],
            prediction['data']['distance_km'],
        ),
    )
    request_id = cursor.lastrowid

    return secure_json(
        {
            'ok': True,
            'data': {
                'request_id': request_id,
                'full_name': full_name,
                'phone': phone,
                **prediction['data'],
            },
        }
    )
