# Darmon Service UZ (static site + simple PHP backend)

## What’s inside
- Multi-page site: Home, About, Specialists (filters), Lab Results (Quick Check + login/register + booking), Contact (callback request + map), Vacancies.
- CSS split per page in `assets/css/`
- Vanilla JS: language switcher (UZ/RU/EN), counters, YouTube lazy-load, filters, forms.
- Backend (PHP + MySQL): auth, booking, quick check, results download, callback requests.

## Quick start (local)
1) Create DB (MySQL):
- Create database: `darmon_service`
- Run SQL:
  - `backend/sql/schema.sql`
  - `backend/sql/seed.sql`

2) Start PHP server (any of these):
- XAMPP/WAMP/MAMP (place the project in web root)
- or `php -S localhost:8000` from project root (if you know how)

3) Open:
- `http://localhost:8000/index.html`

## Demo accounts
- Patient: `patient@darmon.uz` / `Demo123!`
- Admin: `admin@darmon.uz` / `Demo123!`

## Notes
- `results.html` works in “demo mode” if backend is not running (it will show a sample quick-check response).
- For real PDFs: `backend/php/files/sample_result.pdf` is included as an example.
