from services import *

def handle_book_appointment(request, cursor, payload, token, action):
    if action == 'book_appointment':
        user, error_response = require_user_or_error(cursor, token)
        if error_response:
            return error_response
        user_id = int(user['id'])
    else:
        if not require_roles(cursor, token, {'admin', 'reception'}):
            return unauthorized_or_forbidden(token)
        patient_mode = str(payload.get('patient_mode', 'existing')).strip() or 'existing'
        if patient_mode == 'new':
            created_patient_id = create_patient_by_admin(cursor, payload)
            if created_patient_id is None:
                return secure_json({'ok': False, 'error': 'Invalid patient data.'}, 400)
            if created_patient_id == -1:
                return secure_json({'ok': False, 'error': 'Email already registered.'}, 409)
            user_id = int(created_patient_id)
        else:
            user_id = int(payload.get('patient_id', 0) or 0)
            patient = fetch_one(cursor, 'SELECT id, role FROM users WHERE id=%s LIMIT 1', (user_id,))
            if not patient or patient['role'] != 'patient':
                return secure_json({'ok': False, 'error': 'Patient not found.'}, 404)

    doctor_id = int(payload.get('doctor_id', 0) or 0)
    appointment_date = str(payload.get('appointment_date', '')).strip()
    time_slot = str(payload.get('time_slot', '')).strip()

    validation_error = validate_appointment_fields(cursor, doctor_id, appointment_date, time_slot)
    if validation_error:
        return validation_error

    try:
        appointment_id = create_appointment(cursor, user_id, doctor_id, appointment_date, time_slot)
        return secure_json({'ok': True, 'data': {'id': appointment_id}})
    except Exception:
        return secure_json({'ok': False, 'error': 'This slot is already booked. Choose another time.'}, 409)


def handle_my_results(request, cursor, payload, token):
    user, error_response = require_user_or_error(cursor, token)
    if error_response:
        return error_response
    return secure_json({'ok': True, 'data': get_ready_results(cursor, user['id'])})


def handle_account_overview(request, cursor, payload, token):
    user, error_response = require_user_or_error(cursor, token)
    if error_response:
        return error_response

    return secure_json(
        {
            'ok': True,
            'data': {
                'user': serialize_user(user),
                'doctors': get_active_doctors(cursor),
                'results': get_ready_results(cursor, user['id']),
            },
        }
    )
