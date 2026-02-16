-- Seed data
INSERT INTO departments(name) VALUES
 ('Cardiology'),('Laboratory'),('Pediatrics'),('Neurology'),('Gynecology'),('Therapy')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO doctors(full_name,specialty,department_id,experience_years,bio,image_url) VALUES
 ('Dilshod Akhmedov','Cardiology',(SELECT id FROM departments WHERE name='Cardiology'),9,'Heart health, ECG, prevention plans.','assets/images/doctor1.svg'),
 ('Malika Karimova','Laboratory',(SELECT id FROM departments WHERE name='Laboratory'),7,'Diagnostics, QC, home sampling supervision.','assets/images/doctor2.svg'),
 ('Sardor Rakhimov','Pediatrics',(SELECT id FROM departments WHERE name='Pediatrics'),6,'Kids care, vaccines, parent guidance.','assets/images/doctor3.svg'),
 ('Nodira Usmonova','Neurology',(SELECT id FROM departments WHERE name='Neurology'),8,'Headache, sleep, rehab and consults.','assets/images/doctor4.svg'),
 ('Aziza Tursunova','Gynecology',(SELECT id FROM departments WHERE name='Gynecology'),10,'Women’s health, ultrasound, counseling.','assets/images/doctor5.svg'),
 ('Javlon Ismoilov','Therapy',(SELECT id FROM departments WHERE name='Therapy'),11,'General adult care and follow-up.','assets/images/doctor6.svg')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);

-- Demo admin / patient (password: Demo123!)
INSERT INTO users(name,phone,email,password_hash,role)
VALUES
 ('Admin','+998901111111','admin@darmon.uz','$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG','admin'),
 ('Aziza Patient','+998902222222','patient@darmon.uz','$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG','patient')
ON DUPLICATE KEY UPDATE email=VALUES(email);

-- Lab result demo for patient (receipt DS-2026-00021)
INSERT INTO lab_results(user_id,receipt_id,test_name,status,sample_date,upload_date,file_path)
VALUES
 ((SELECT id FROM users WHERE email='patient@darmon.uz'),'DS-2026-00021','Blood panel','Pending','2026-01-10',NULL,NULL),
 ((SELECT id FROM users WHERE email='patient@darmon.uz'),'DS-2026-00022','Biochemistry','Ready','2026-01-08','2026-01-09','backend/php/files/sample_result.pdf')
ON DUPLICATE KEY UPDATE test_name=VALUES(test_name);

INSERT INTO vacancies(title,description,requirements,is_active) VALUES
 ('Laboratory Nurse (Home Visits)','Schedule-based home sampling, patient care, strict hygiene.','2+ years experience\nCommunication skills\nCertificate is a plus',1),
 ('Reception / Call Center Operator','24/7 shifts, call routing, appointment confirmations.','Good Uzbek/Russian\nCalm under pressure\nBasic computer skills',1)
ON DUPLICATE KEY UPDATE title=VALUES(title);
