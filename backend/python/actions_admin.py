from services import *
def build_environment_context(ambulance_request=None):
    context = {}
    if ambulance_request:
        context["ambulance_eta"] = f"{ambulance_request.get('eta_minutes', '?')} min"
        context["ambulance_route"] = f"{ambulance_request.get('distance_km', '?')} km"
    return context


def serialize_note_history(notes):
    return [
        {
            "created_at": row["created_at"],
            "diagnosis": row.get("diagnosis") or "-",
            "medications": row.get("medications") or "-",
            "patient_status": row.get("patient_status") or "under_observation",
            "blood_test_required": bool(row.get("blood_test_required")),
            "blood_test_note": row.get("blood_test_note") or "",
            "doctor_note": row.get("doctor_note") or "",
        }
        for row in notes
    ]


def build_patient_alerts(lab_results, latest_note, appointments, ambulance_request=None):
    alerts = []

    if latest_note and latest_note.get("patient_status") == "critical":
        alerts.append(
            {
                "level": "critical",
                "title": "Critical follow-up required",
                "detail": "Latest doctor update marked this patient as critical.",
            }
        )

    pending_results = [row for row in lab_results if row.get("status") == "Pending"]
    if pending_results:
        alerts.append(
            {
                "level": "warning",
                "title": "Pending blood work",
                "detail": f"{len(pending_results)} lab request(s) still pending review.",
            }
        )

    if latest_note and latest_note.get("blood_test_required"):
        alerts.append(
            {
                "level": "warning",
                "title": "Blood test requested",
                "detail": latest_note.get("blood_test_note") or "Doctor requested blood test follow-up.",
            }
        )

    if appointments:
        latest_visit = appointments[0]
        alerts.append(
            {
                "level": "normal",
                "title": "Latest scheduled interaction",
                "detail": f"{latest_visit['appointment_date']} at {latest_visit['time_slot']} with {latest_visit['doctor_name']}.",
            }
        )

    if ambulance_request:
        alerts.append(
            {
                "level": "warning",
                "title": "Ambulance request active",
                "detail": (
                    f"Requested at {ambulance_request.get('created_at')} "
                    f"for {ambulance_request.get('full_name', 'patient')}. "
                    f"ETA {ambulance_request.get('eta_minutes', '?')} min from {ambulance_request.get('address', 'reported address')}."
                ),
            }
        )

    return alerts or [
        {
            "level": "normal",
            "title": "No active alerts",
            "detail": "No urgent flags are currently registered for this patient.",
        }
    ]


def build_prediction_block(patient_id, appointments, latest_note, lab_results, ambulance_request=None):
    status_weight = {
        "stable": 12,
        "under_observation": 22,
        "needs_tests": 35,
        "critical": 52,
        "discharged": 5,
    }
    status = (latest_note or {}).get("patient_status", "under_observation")
    pending_results = sum(1 for row in lab_results if row.get("status") == "Pending")
    history_weight = min(len(appointments) * 5, 20)
    score = min(97, 18 + status_weight.get(status, 22) + pending_results * 8 + history_weight + (patient_id % 9))

    if score >= 75:
        label = "High"
    elif score >= 45:
        label = "Medium"
    else:
        label = "Low"

    eta_minutes = max(8, 42 - min(score, 30) + pending_results * 3)
    if ambulance_request:
        eta_minutes = float(ambulance_request.get("eta_minutes") or eta_minutes)

    drivers = [
        f"Status: {status.replace('_', ' ')}",
        f"Pending labs: {pending_results}",
        f"Recorded visits: {len(appointments)}",
    ]
    if ambulance_request:
        drivers.insert(0, "Ambulance requested")

    return {
        "risk_score": score,
        "risk_label": label,
        "eta_minutes": eta_minutes,
        "drivers": drivers,
    }


def fetch_admin_doctors(cursor):
    cursor.execute(
        """
        SELECT
          d.id,
          d.full_name,
          d.specialty,
          d.experience_years,
          d.bio,
          d.image_url,
          d.is_active,
          dept.name AS department_name,
          u.email AS account_email,
          u.phone AS account_phone
        FROM doctors d
        LEFT JOIN departments dept ON dept.id = d.department_id
        LEFT JOIN users u
          ON u.role='doctor'
         AND (
              LOWER(u.name) = LOWER(d.full_name)
              OR LOWER(u.name) = LOWER(CONCAT('Dr. ', d.full_name))
         )
        WHERE d.is_active = 1
        ORDER BY d.full_name
        """
    )
    return cursor.fetchall()


def handle_admin_update_appointment_status(request, cursor, payload, token):
    del request
    if not require_roles(cursor, token, {'admin', 'reception'}):
        return unauthorized_or_forbidden(token)
    appointment_id = int(payload.get('appointment_id', 0) or 0)
    status = str(payload.get('status', '')).strip()
    if status not in {'booked', 'completed', 'canceled'}:
        return secure_json({'ok': False, 'error': 'Invalid status.'}, 400)

    cursor.execute(
        '''
        UPDATE appointments
        SET status=%s
        WHERE id=%s
        LIMIT 1
        ''',
        (status, appointment_id),
    )
    return secure_json({'ok': True})


def handle_admin_save_doctor(request, cursor, payload, token):
    del request
    if not require_admin(cursor, token):
        return unauthorized_or_forbidden(token)

    doctor_id = int(payload.get('id', 0) or 0)
    full_name = str(payload.get('full_name', '')).strip()
    specialty = str(payload.get('specialty', '')).strip()
    department_name = str(payload.get('department_name', '')).strip()
    experience_years = int(payload.get('experience_years', 0) or 0)
    bio = str(payload.get('bio', '')).strip()
    image_url = str(payload.get('image_url', '')).strip()
    phone = str(payload.get('phone', '')).strip()
    email = normalize_email(str(payload.get('email', '')))
    password = str(payload.get('password', ''))
    is_active = 1 if bool(payload.get('is_active', True)) else 0

    if not full_name or not specialty or not phone or not email:
        return secure_json({'ok': False, 'error': 'Missing fields.'}, 400)
    if experience_years < 0:
        return secure_json({'ok': False, 'error': 'Experience must be 0 or higher.'}, 400)
    if not is_valid_phone(phone):
        return secure_json({'ok': False, 'error': 'Invalid phone.'}, 400)
    if not doctor_id and len(password) < 8:
        return secure_json({'ok': False, 'error': 'Password must be at least 8 characters.'}, 400)
    if doctor_id and password and len(password) < 8:
        return secure_json({'ok': False, 'error': 'Password must be at least 8 characters.'}, 400)

    existing_doctor = None
    if doctor_id:
        existing_doctor = fetch_one(
            cursor,
            '''
            SELECT id, full_name
            FROM doctors
            WHERE id=%s
            LIMIT 1
            ''',
            (doctor_id,),
        )
        if not existing_doctor:
            return secure_json({'ok': False, 'error': 'Doctor not found.'}, 404)

    duplicate_name = fetch_one(
        cursor,
        '''
        SELECT id
        FROM doctors
        WHERE LOWER(full_name)=LOWER(%s)
          AND (%s = 0 OR id <> %s)
        LIMIT 1
        ''',
        (full_name, doctor_id, doctor_id),
    )
    if duplicate_name:
        return secure_json({'ok': False, 'error': 'Doctor name already exists.'}, 409)

    linked_user = None
    if doctor_id and existing_doctor:
        linked_user = fetch_one(
            cursor,
            '''
            SELECT id, email
            FROM users
            WHERE role='doctor'
              AND (
                   LOWER(name)=LOWER(%s)
                   OR LOWER(name)=LOWER(CONCAT('Dr. ', %s))
              )
            LIMIT 1
            ''',
            (existing_doctor['full_name'], existing_doctor['full_name']),
        )

    email_conflict = fetch_one(
        cursor,
        '''
        SELECT id
        FROM users
        WHERE email=%s
          AND (%s IS NULL OR id <> %s)
        LIMIT 1
        ''',
        (email, linked_user['id'] if linked_user else None, linked_user['id'] if linked_user else None),
    )
    if email_conflict:
        return secure_json({'ok': False, 'error': 'Email already registered.'}, 409)

    department_id = None
    if department_name:
        department = fetch_one(
            cursor,
            'SELECT id FROM departments WHERE LOWER(name)=LOWER(%s) LIMIT 1',
            (department_name,),
        )
        if department:
            department_id = department['id']
        else:
            cursor.execute('INSERT INTO departments(name) VALUES(%s)', (department_name,))
            department_id = cursor.lastrowid

    if doctor_id:
        cursor.execute(
            '''
            UPDATE doctors
            SET full_name=%s,
                specialty=%s,
                department_id=%s,
                experience_years=%s,
                bio=%s,
                image_url=%s,
                is_active=%s
            WHERE id=%s
            LIMIT 1
            ''',
            (full_name, specialty, department_id, experience_years, bio or None, image_url or None, is_active, doctor_id),
        )
    else:
        cursor.execute(
            '''
            INSERT INTO doctors(full_name, specialty, department_id, experience_years, bio, image_url, is_active)
            VALUES(%s, %s, %s, %s, %s, %s, %s)
            ''',
            (full_name, specialty, department_id, experience_years, bio or None, image_url or None, is_active),
        )
        doctor_id = cursor.lastrowid

    doctor_account_name = f'Dr. {full_name}'
    if linked_user:
        if password:
            cursor.execute(
                '''
                UPDATE users
                SET name=%s, phone=%s, email=%s, password_hash=%s
                WHERE id=%s
                LIMIT 1
                ''',
                (doctor_account_name, phone, email, password_hash_secure(password), linked_user['id']),
            )
        else:
            cursor.execute(
                '''
                UPDATE users
                SET name=%s, phone=%s, email=%s
                WHERE id=%s
                LIMIT 1
                ''',
                (doctor_account_name, phone, email, linked_user['id']),
            )
    else:
        cursor.execute(
            '''
            INSERT INTO users(name, phone, email, password_hash, role)
            VALUES(%s, %s, %s, %s, 'doctor')
            ''',
            (doctor_account_name, phone, email, password_hash_secure(password)),
        )

    return secure_json({'ok': True, 'data': {'id': doctor_id}})


def handle_admin_delete_doctor(request, cursor, payload, token):
    del request
    if not require_admin(cursor, token):
        return unauthorized_or_forbidden(token)

    doctor_id = int(payload.get('id', 0) or 0)
    if not doctor_id:
        return secure_json({'ok': False, 'error': 'Doctor not found.'}, 404)

    doctor = fetch_one(
        cursor,
        '''
        SELECT id, full_name
        FROM doctors
        WHERE id=%s
        LIMIT 1
        ''',
        (doctor_id,),
    )
    if not doctor:
        return secure_json({'ok': False, 'error': 'Doctor not found.'}, 404)

    cursor.execute(
        '''
        DELETE FROM doctors
        WHERE id=%s
        ''',
        (doctor_id,),
    )
    return secure_json({'ok': True})


def handle_admin_save_vacancy(request, cursor, payload, token):
    del request
    if not require_admin(cursor, token):
        return unauthorized_or_forbidden(token)
    vacancy_id = int(payload.get('id', 0) or 0)
    title = str(payload.get('title', '')).strip()
    description = str(payload.get('description', '')).strip()
    requirements = str(payload.get('requirements', '')).strip()
    is_active = 1 if bool(payload.get('is_active', True)) else 0
    if not title or not description or not requirements:
        return secure_json({'ok': False, 'error': 'Missing fields.'}, 400)

    try:
        if vacancy_id:
            cursor.execute(
                '''
                UPDATE vacancies
                SET title=%s, description=%s, requirements=%s, is_active=%s
                WHERE id=%s
                LIMIT 1
                ''',
                (title, description, requirements, is_active, vacancy_id),
            )
            return secure_json({'ok': True, 'data': {'id': vacancy_id}})

        cursor.execute(
            '''
            INSERT INTO vacancies(title, description, requirements, is_active)
            VALUES(%s, %s, %s, %s)
            ''',
            (title, description, requirements, is_active),
        )
        return secure_json({'ok': True, 'data': {'id': cursor.lastrowid}})
    except Exception:
        return secure_json({'ok': False, 'error': 'Vacancy title must be unique.'}, 409)


def handle_admin_delete_vacancy(request, cursor, payload, token):
    del request
    if not require_admin(cursor, token):
        return unauthorized_or_forbidden(token)
    vacancy_id = int(payload.get('id', 0) or 0)
    if not vacancy_id:
        return secure_json({'ok': False, 'error': 'Vacancy not found.'}, 404)
    cursor.execute('DELETE FROM vacancies WHERE id=%s LIMIT 1', (vacancy_id,))
    return secure_json({'ok': True})


def _load_shared_dashboard_data(cursor):
    cursor.execute(
        '''
        SELECT id, first_name, last_name, phone, preferred_time, created_at
        FROM callback_requests
        ORDER BY created_at DESC
        '''
    )
    callbacks = cursor.fetchall()

    cursor.execute(
        '''
        SELECT
          a.id,
          a.appointment_date,
          a.time_slot,
          a.status,
          a.created_at,
          u.name AS patient_name,
          u.phone AS patient_phone,
          u.email AS patient_email,
          d.full_name AS doctor_name,
          d.specialty AS doctor_specialty
        FROM appointments a
        JOIN users u ON u.id = a.user_id
        JOIN doctors d ON d.id = a.doctor_id
        ORDER BY a.created_at DESC
        '''
    )
    appointments = cursor.fetchall()

    cursor.execute(
        '''
        SELECT id, name, phone, email
        FROM users
        WHERE role='patient'
        ORDER BY name
        '''
    )
    patients = cursor.fetchall()

    doctors = get_active_doctors(cursor)
    return callbacks, appointments, patients, doctors


def handle_admin_dashboard(request, cursor, payload, token):
    del request, payload
    user, error_response = require_roles_or_error(cursor, token, {'admin'})
    if error_response:
        return error_response

    callbacks, appointments, patients, doctors = _load_shared_dashboard_data(cursor)
    cursor.execute(
        '''
        SELECT id, title, description, requirements, is_active, created_at
        FROM vacancies
        ORDER BY created_at DESC
        '''
    )
    vacancies = cursor.fetchall()

    admin_doctors = fetch_admin_doctors(cursor)
    cursor.execute('SELECT id, name FROM departments ORDER BY name')
    departments = cursor.fetchall()

    return secure_json({'ok': True, 'data': {'role': user['role'], 'callbacks': callbacks, 'appointments': appointments, 'vacancies': vacancies, 'patients': patients, 'doctors': doctors, 'admin_doctors': admin_doctors, 'departments': departments}})


def handle_staff_dashboard(request, cursor, payload, token):
    del request, payload
    user, error_response = require_roles_or_error(cursor, token, {'admin', 'reception'})
    if error_response:
        return error_response

    callbacks, appointments, patients, doctors = _load_shared_dashboard_data(cursor)
    data = {'role': user['role'], 'callbacks': callbacks, 'appointments': appointments, 'patients': patients, 'doctors': doctors, 'vacancies': [], 'admin_doctors': [], 'departments': []}
    if user.get('role') == 'admin':
        cursor.execute(
            '''
            SELECT id, title, description, requirements, is_active, created_at
            FROM vacancies
            ORDER BY created_at DESC
            '''
        )
        data['vacancies'] = cursor.fetchall()
        data['admin_doctors'] = fetch_admin_doctors(cursor)
        cursor.execute('SELECT id, name FROM departments ORDER BY name')
        data['departments'] = cursor.fetchall()
    return secure_json({'ok': True, 'data': data})


def handle_doctor_dashboard(request, cursor, payload, token):
    del request, payload
    _, doctor, error_response = require_active_doctor_or_error(cursor, token)
    if error_response:
        return error_response

    cursor.execute(
        '''
        SELECT
          a.id,
          a.appointment_date,
          a.time_slot,
          a.status,
          u.id AS patient_id,
          u.name AS patient_name,
          u.phone AS patient_phone,
          u.email AS patient_email
        FROM appointments a
        JOIN users u ON u.id = a.user_id
        WHERE a.doctor_id=%s
          AND a.appointment_date = CURDATE()
          AND a.status <> 'canceled'
        ORDER BY a.time_slot
        ''',
        (doctor['id'],),
    )
    appointments = cursor.fetchall()
    latest_ambulance_request = get_active_ambulance_request(cursor)
    return secure_json({'ok': True, 'data': {'doctor': doctor, 'appointments': appointments, 'sections': [{'id': 'general', 'label': 'General doctors', 'enabled': True}, {'id': 'emergency', 'label': 'Emergency doctors', 'enabled': False}], 'environment_context': build_environment_context(latest_ambulance_request), 'latest_ambulance_request': latest_ambulance_request}})


def handle_doctor_patients(request, cursor, payload, token):
    del request, payload
    user, doctor, error_response = require_active_doctor_or_error(cursor, token)
    if error_response:
        return error_response
    del user

    cursor.execute(
        '''
        SELECT
          u.id,
          u.name,
          u.phone,
          u.email,
          COUNT(DISTINCT a.id) AS appointments_count,
          MAX(a.appointment_date) AS last_appointment,
          COUNT(DISTINCT CASE WHEN lr.status='Ready' THEN lr.id END) AS ready_results
        FROM users u
        JOIN appointments a
          ON a.user_id = u.id
         AND a.doctor_id = %s
         AND a.status <> 'canceled'
        LEFT JOIN lab_results lr ON lr.user_id = u.id
        WHERE u.role='patient'
        GROUP BY u.id, u.name, u.phone, u.email
        ORDER BY last_appointment DESC, u.name
        ''',
        (doctor['id'],),
    )
    return secure_json({'ok': True, 'data': cursor.fetchall()})


def handle_doctor_patient_detail(request, cursor, payload, token):
    del request
    user, doctor, error_response = require_active_doctor_or_error(cursor, token)
    if error_response:
        return error_response
    del user

    patient_id = int(payload.get('patient_id', 0) or 0)
    if not patient_id:
        return secure_json({'ok': False, 'error': 'Patient not found.'}, 404)
    if not doctor_has_patient_access(cursor, doctor['id'], patient_id):
        return secure_json({'ok': False, 'error': 'Forbidden.'}, 403)

    patient = fetch_one(
        cursor,
        '''
        SELECT id, name, phone, email, created_at
        FROM users
        WHERE id=%s AND role='patient'
        LIMIT 1
        ''',
        (patient_id,),
    )
    if not patient:
        return secure_json({'ok': False, 'error': 'Patient not found.'}, 404)

    cursor.execute(
        '''
        SELECT
          a.appointment_date,
          a.time_slot,
          a.status,
          d.full_name AS doctor_name,
          d.specialty AS doctor_specialty
        FROM appointments a
        JOIN doctors d ON d.id = a.doctor_id
        WHERE a.user_id=%s
        ORDER BY a.appointment_date DESC, a.time_slot DESC
        LIMIT 10
        ''',
        (patient_id,),
    )
    appointments = cursor.fetchall()

    cursor.execute(
        '''
        SELECT receipt_id, test_name, status, sample_date, upload_date
        FROM lab_results
        WHERE user_id=%s
        ORDER BY sample_date DESC
        LIMIT 10
        ''',
        (patient_id,),
    )
    lab_results = cursor.fetchall()

    cursor.execute(
        '''
        SELECT
          diagnosis,
          medications,
          patient_status,
          blood_test_required,
          blood_test_note,
          doctor_note,
          created_at
        FROM doctor_patient_notes
        WHERE patient_id=%s
        ORDER BY created_at DESC
        LIMIT 10
        ''',
        (patient_id,),
    )
    notes = cursor.fetchall()
    latest_note = notes[0] if notes else None
    ambulance_request = get_active_ambulance_request(cursor)
    ambulance_history = get_recent_ambulance_requests(cursor, limit=8)

    alerts = build_patient_alerts(lab_results, latest_note, appointments, ambulance_request)
    predictions = build_prediction_block(patient_id, appointments, latest_note, lab_results, ambulance_request)
    environment_context = build_environment_context(ambulance_request)

    patient_summary = {
        'id': patient['id'],
        'name': patient['name'],
        'phone': patient['phone'],
        'email': patient['email'],
        'created_at': patient['created_at'],
        'status': (latest_note or {}).get('patient_status', 'under_observation'),
        'diagnosis': (latest_note or {}).get('diagnosis') or 'Awaiting doctor note',
        'medications': (latest_note or {}).get('medications') or 'No medication plan saved yet',
        'blood_test_required': bool((latest_note or {}).get('blood_test_required')),
        'blood_test_note': (latest_note or {}).get('blood_test_note') or '',
        'doctor_note': (latest_note or {}).get('doctor_note') or '',
    }

    return secure_json({
        'ok': True,
        'data': {
            'patient': patient_summary,
            'appointments': appointments,
            'lab_results': lab_results,
            'alerts': alerts,
            'predictions': predictions,
            'environment_context': environment_context,
            'notes': serialize_note_history(notes),
            'ambulance_request': ambulance_request,
            'ambulance_history': ambulance_history,
        }
    })


def handle_doctor_save_patient_plan(request, cursor, payload, token):
    del request
    user, doctor, error_response = require_active_doctor_or_error(cursor, token)
    if error_response:
        return error_response

    patient_id = int(payload.get('patient_id', 0) or 0)
    if not patient_id:
        return secure_json({'ok': False, 'error': 'Patient not found.'}, 404)
    if not doctor_has_patient_access(cursor, doctor['id'], patient_id):
        return secure_json({'ok': False, 'error': 'Forbidden.'}, 403)

    patient = fetch_one(cursor, 'SELECT id FROM users WHERE id=%s AND role=\'patient\' LIMIT 1', (patient_id,))
    if not patient:
        return secure_json({'ok': False, 'error': 'Patient not found.'}, 404)

    diagnosis = str(payload.get('diagnosis', '')).strip()
    medications = str(payload.get('medications', '')).strip()
    patient_status = str(payload.get('patient_status', 'under_observation')).strip() or 'under_observation'
    blood_test_required = 1 if bool(payload.get('blood_test_required')) else 0
    blood_test_note = str(payload.get('blood_test_note', '')).strip()
    doctor_note = str(payload.get('doctor_note', '')).strip()

    allowed_statuses = {'stable', 'under_observation', 'needs_tests', 'critical', 'discharged'}
    if patient_status not in allowed_statuses:
        return secure_json({'ok': False, 'error': 'Invalid patient status.'}, 400)

    cursor.execute(
        '''
        INSERT INTO doctor_patient_notes(
          patient_id,
          doctor_user_id,
          diagnosis,
          medications,
          patient_status,
          blood_test_required,
          blood_test_note,
          doctor_note
        )
        VALUES(%s, %s, %s, %s, %s, %s, %s, %s)
        ''',
        (patient_id, user['id'], diagnosis or None, medications or None, patient_status, blood_test_required, blood_test_note or None, doctor_note or None),
    )

    return secure_json({'ok': True, 'data': {'id': cursor.lastrowid}})
