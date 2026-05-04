-- MySQL schema for Darmon Service UZ
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('patient','admin','doctor','reception') NOT NULL DEFAULT 'patient',
  failed_login_attempts INT NOT NULL DEFAULT 0,
  last_failed_login DATETIME NULL,
  locked_until DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS departments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS doctors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(140) NOT NULL,
  specialty VARCHAR(120) NOT NULL,
  department_id INT NULL,
  experience_years INT NOT NULL DEFAULT 0,
  bio TEXT NULL,
  image_url VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  doctor_id INT NOT NULL,
  appointment_date DATE NOT NULL,
  time_slot VARCHAR(10) NOT NULL,
  status ENUM('booked','completed','canceled') NOT NULL DEFAULT 'booked',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_slot (doctor_id, appointment_date, time_slot),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE IF NOT EXISTS lab_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  receipt_id VARCHAR(40) NOT NULL UNIQUE,
  test_name VARCHAR(160) NOT NULL,
  status ENUM('Pending','Ready') NOT NULL DEFAULT 'Pending',
  sample_date DATE NOT NULL,
  upload_date DATE NULL,
  file_path VARCHAR(255) NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS vacancies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(180) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  requirements TEXT NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS callback_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  preferred_time TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ambulance_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  eta_minutes DECIMAL(6,1) NULL,
  distance_km DECIMAL(6,2) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  last_used_at DATETIME NULL,
  revoked_at DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS user_otps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL,
  purpose ENUM('register','login','password_reset') NOT NULL,
  otp_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  attempts INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX(email),
  INDEX(purpose)
);

CREATE TABLE IF NOT EXISTS trusted_devices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_device (user_id, device_hash),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS doctor_patient_notes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_user_id INT NOT NULL,
  diagnosis TEXT NULL,
  medications TEXT NULL,
  patient_status VARCHAR(60) NOT NULL DEFAULT 'under_observation',
  blood_test_required TINYINT(1) NOT NULL DEFAULT 0,
  blood_test_note TEXT NULL,
  doctor_note TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX(patient_id),
  INDEX(doctor_user_id),
  FOREIGN KEY (patient_id) REFERENCES users(id),
  FOREIGN KEY (doctor_user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS ambulance_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(160) NULL,
    phone VARCHAR(40) NULL,
    address VARCHAR(255) NOT NULL,
    eta_minutes DECIMAL(6,1) NULL,
    distance_km DECIMAL(6,2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS doctor_patient_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_user_id INT NOT NULL,
    diagnosis TEXT NULL,
    medications TEXT NULL,
    patient_status VARCHAR(60) NOT NULL DEFAULT 'under_observation',
    blood_test_required TINYINT(1) NOT NULL DEFAULT 0,
    blood_test_note TEXT NULL,
    doctor_note TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX(patient_id),
    INDEX(doctor_user_id),
    FOREIGN KEY (patient_id) REFERENCES users(id),
    FOREIGN KEY (doctor_user_id) REFERENCES users(id)
    )
