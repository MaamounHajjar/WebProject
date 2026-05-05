# Darmon Service UZ

Full-stack healthcare service platform built with static frontend pages, a FastAPI backend, MySQL, and MongoDB. The project covers public clinic pages, patient self-service, staff workflows, a doctor workspace, and an emergency ambulance estimate flow.

## Features

- Public clinic website with `index.html`, `about.html`, `contact.html`, `specialists.html`, `vacancies.html`, and `emergency.html`
- Patient registration, login, OTP verification, password reset, and account overview
- Appointment booking for patients and staff
- Lab result quick-check plus authenticated PDF download
- Staff portal for admin and reception users
- Doctor workspace with patient search, notes, alerts, predictions, and live vitals over WebSocket
- Emergency ambulance request flow with ETA prediction
- Multilingual frontend resources in JavaScript

## Tech Stack

- Frontend: HTML, CSS, vanilla JavaScript
- Backend: Python, FastAPI
- Databases:
  - MySQL for users, doctors, appointments, lab results, vacancies, callbacks, tokens, and notes
  - MongoDB for live patient vitals
- Other integrations:
  - Leaflet / map-based emergency flow
  - `geopy` and `requests` for address and routing utilities
  - `joblib` model loading for ambulance ETA prediction

## Project Structure

```text
darmon_service_v1/
├── assets/
│   ├── css/
│   └── images/
├── backend/
│   ├── files/
│   │   ├── ambulance_model.pkl
│   │   └── sample_result.pdf
│   ├── python/
│   │   ├── app.py
│   │   ├── actions_*.py
│   │   ├── services.py
│   │   ├── vitals_simulator.py
│   │   └── ...
│   └── sql/
│       ├── schema.sql
│       └── seed.sql
├── js/
│   ├── api.js
│   ├── config.js
│   ├── i18n.js
│   └── pages/
├── admin.html
├── doctors.html
├── emergency.html
├── index.html
├── results.html
└── ...
```

## Prerequisites

- Apache via XAMPP or another local web server for the frontend
- Python 3.10+
- MySQL
- MongoDB running locally on `mongodb://localhost:27017`

## Local Setup

### 1. Serve the frontend

This repository is already placed under XAMPP `htdocs`, so the frontend can be served from:

```text
http://localhost/darmon_service_v1/
```

Main pages:

- `/index.html`
- `/results.html`
- `/admin.html`
- `/doctors.html`
- `/emergency.html`

### 2. Configure environment variables

Copy `.env.example` to `.env` and adjust values if needed:

```env
APP_ENV=development
API_HOST=127.0.0.1
API_PORT=8000

DB_HOST=127.0.0.1
DB_NAME=darmon_service
DB_USER=root
DB_PASS=

CORS_ALLOW_ORIGINS=http://localhost,http://127.0.0.1
FASTAPI_SESSION_SECRET=change-me
```

Notes:

- `js/config.js` points the frontend to `http://<hostname>:8000`
- OTP flows depend on SMTP settings if you want real email delivery

### 3. Create the MySQL database

Create the database:

```sql
CREATE DATABASE darmon_service CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Then import:

- [backend/sql/schema.sql](/Applications/XAMPP/xamppfiles/htdocs/darmon_service_v1/backend/sql/schema.sql)
- [backend/sql/seed.sql](/Applications/XAMPP/xamppfiles/htdocs/darmon_service_v1/backend/sql/seed.sql)

Example:

```bash
mysql -u root -p darmon_service < backend/sql/schema.sql
mysql -u root -p darmon_service < backend/sql/seed.sql
```

### 4. Install Python dependencies

Install the packages used by the backend directly:

```bash
pip install fastapi uvicorn pymysql bcrypt motor pymongo requests geopy joblib scikit-learn
```

### 5. Start the backend

From [backend/python](/Applications/XAMPP/xamppfiles/htdocs/darmon_service_v1/backend/python):

```bash
uvicorn app:app --reload --host 127.0.0.1 --port 8000
```

Useful endpoints:

- `GET /health`
- `POST /api`
- `GET /download?receipt_id=...`
- `GET /predict_arrival?address=...`
- `WS /ws/vitals/{patient_id}`

### 6. Optional: run the vitals simulator

To populate MongoDB with demo patient vitals for the doctor workspace:

```bash
python vitals_simulator.py
```

## Demo Accounts

Seed data includes these users:

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@darmon.uz` | `Demo123!` |
| Reception | `reception@darmon.uz` | `Demo123!` |
| Doctor | `doctor@darmon.uz` | `Demo123!` |
| Patient | `patient@darmon.uz` | `Demo123!` |

Demo lab result receipt IDs:

- `DS-2026-00021`
- `DS-2026-00022`

## Main Application Flows

### Patient side

- Browse specialists and clinic information
- Register and verify account with OTP
- Book appointments from the results/account area
- Check lab result status
- Download ready PDF results

### Staff side

- Sign in from `admin.html`
- Admin and reception users can review callbacks, appointments, and booking operations
- Doctor users are routed to `doctors.html`

### Doctor side

- Review today’s queue
- Search patients
- Open patient detail
- Monitor live vitals over WebSocket
- Save diagnosis, medication, blood test requests, and notes

### Emergency side

- Enter an address
- Estimate ambulance arrival time
- Submit an ambulance request

## API Actions

The main `POST /api` route dispatches actions such as:

- `register`
- `verify_register_otp`
- `login`
- `verify_login_otp`
- `request_password_reset`
- `verify_password_reset_otp`
- `reset_password`
- `book_appointment`
- `quick_check`
- `my_results`
- `callback_request`
- `request_ambulance`
- `admin_dashboard`
- `doctor_dashboard`
- `doctor_patient_detail`
- `doctor_save_patient_plan`

See [backend/python/api_actions.py](/Applications/XAMPP/xamppfiles/htdocs/darmon_service_v1/backend/python/api_actions.py) for the full action map.

## Notes

- The backend loads environment variables from the project root `.env`
- Session cookies are configured through FastAPI `SessionMiddleware`
- CORS is restricted through `CORS_ALLOW_ORIGINS`
- The sample lab PDF is stored in [backend/files/sample_result.pdf](/Applications/XAMPP/xamppfiles/htdocs/darmon_service_v1/backend/files/sample_result.pdf)
- The ambulance ETA model is stored in [backend/files/ambulance_model.pkl](/Applications/XAMPP/xamppfiles/htdocs/darmon_service_v1/backend/files/ambulance_model.pkl)
