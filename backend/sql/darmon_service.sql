-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 04, 2026 at 03:21 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `darmon_service`
--

-- --------------------------------------------------------

--
-- Table structure for table `ambulance_requests`
--

CREATE TABLE `ambulance_requests` (
  `id` int(11) NOT NULL,
  `full_name` varchar(160) DEFAULT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `address` varchar(255) NOT NULL,
  `eta_minutes` decimal(6,1) DEFAULT NULL,
  `distance_km` decimal(6,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ambulance_requests`
--

INSERT INTO `ambulance_requests` (`id`, `full_name`, `phone`, `address`, `eta_minutes`, `distance_km`, `created_at`) VALUES
(1, NULL, NULL, 'chilinzor', 11.8, 2.27, '2026-03-31 16:30:35'),
(2, NULL, NULL, 'chilanzar 4-2-45', 9.3, 2.90, '2026-04-02 09:24:08'),
(3, 'Malika abduganiyeva', '+998909964778', 'Chilanzar 3-24-5', 9.1, 3.56, '2026-04-02 09:38:53'),
(4, 'test', '+1111111111111', 'Chilanzar 3-24-5', 9.1, 3.56, '2026-04-02 09:55:18');

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `appointment_date` date NOT NULL,
  `time_slot` varchar(10) NOT NULL,
  `status` enum('booked','completed','canceled') NOT NULL DEFAULT 'booked',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`id`, `user_id`, `doctor_id`, `appointment_date`, `time_slot`, `status`, `created_at`) VALUES
(1, 3, 5, '2026-02-21', '09:00', 'booked', '2026-02-20 17:32:42'),
(2, 3, 5, '2026-02-22', '09:00', 'booked', '2026-02-20 17:32:48'),
(4, 4, 5, '2026-02-24', '09:00', 'booked', '2026-02-21 11:58:22'),
(5, 4, 1, '2026-02-25', '09:00', 'booked', '2026-02-21 13:07:32'),
(6, 10, 6, '2026-03-03', '09:00', 'canceled', '2026-02-26 12:27:07'),
(7, 17, 5, '2026-03-23', '09:00', 'completed', '2026-03-18 12:14:30'),
(8, 4, 5, '2026-03-27', '09:00', 'completed', '2026-03-25 11:15:17'),
(10, 2, 1, '2026-03-27', '09:00', 'canceled', '2026-03-25 11:17:17'),
(11, 7, 5, '2026-03-31', '14:00', 'booked', '2026-03-29 10:05:32'),
(12, 7, 32, '2026-04-03', '09:00', 'booked', '2026-03-30 10:27:13'),
(13, 7, 32, '2026-03-30', '16:00', 'booked', '2026-03-30 10:28:35'),
(14, 7, 5, '2026-04-03', '09:00', 'booked', '2026-04-02 09:14:58'),
(16, 40, 5, '2026-04-09', '09:00', 'booked', '2026-04-02 09:16:48'),
(18, 2, 5, '2026-05-05', '09:00', 'booked', '2026-05-04 08:20:07');

-- --------------------------------------------------------

--
-- Table structure for table `callback_requests`
--

CREATE TABLE `callback_requests` (
  `id` int(11) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `phone` varchar(40) NOT NULL,
  `preferred_time` time NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `callback_requests`
--

INSERT INTO `callback_requests` (`id`, `first_name`, `last_name`, `phone`, `preferred_time`, `created_at`) VALUES
(1, 'Gulsevar', 'Bahodirova', '+998909964778', '12:44:00', '2026-02-21 09:42:27'),
(2, 'madina', 'abduganiyeva', '+998908457934', '14:03:00', '2026-03-18 11:59:31'),
(3, 'Masa', 'hajjar', '+393513921977', '04:22:00', '2026-03-25 11:19:24'),
(4, 'test', 'test2', '+393513921977', '03:02:00', '2026-03-29 09:58:54');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`) VALUES
(1, 'Cardiology'),
(5, 'Gynecology'),
(2, 'Laboratory'),
(4, 'Neurology'),
(3, 'Pediatrics'),
(6, 'Therapy');

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `id` int(11) NOT NULL,
  `full_name` varchar(140) NOT NULL,
  `specialty` varchar(120) NOT NULL,
  `department_id` int(11) DEFAULT NULL,
  `experience_years` int(11) NOT NULL DEFAULT 0,
  `bio` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`id`, `full_name`, `specialty`, `department_id`, `experience_years`, `bio`, `image_url`, `is_active`) VALUES
(1, 'Dilshod Akhmedov', 'Cardiology', 1, 9, 'Heart health, ECG, prevention plans.', 'assets/images/doctor1.svg', 1),
(2, 'Malika Karimova', 'Laboratory', 2, 7, 'Diagnostics, QC, home sampling supervision.', 'assets/images/doctor2.svg', 1),
(3, 'Sardor Rakhimov', 'Pediatrics', 3, 6, 'Kids care, vaccines, parent guidance.', 'assets/images/doctor3.svg', 1),
(4, 'Nodira Usmonova', 'Neurology', 4, 8, 'Headache, sleep, rehab and consults.', 'assets/images/doctor4.svg', 1),
(5, 'Aziza Tursunova', 'Gynecology', 5, 10, 'Women’s health, ultrasound, counseling.', 'assets/images/doctor5.svg', 1),
(6, 'Javlon Ismoilov', 'Therapy', 6, 11, 'General adult care and follow-up.', 'assets/images/doctor6.svg', 1),
(7, 'Madina Ganiyeva', 'Ortoped', NULL, 10, NULL, NULL, 0),
(32, 'John Doe', 'Therapy', 6, 5, 'General adult care and follow-up.', 'assets/images/doctor1.avif', 1);

-- --------------------------------------------------------

--
-- Table structure for table `doctor_patient_notes`
--

CREATE TABLE `doctor_patient_notes` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `doctor_user_id` int(11) NOT NULL,
  `diagnosis` text DEFAULT NULL,
  `medications` text DEFAULT NULL,
  `patient_status` varchar(60) NOT NULL DEFAULT 'under_observation',
  `blood_test_required` tinyint(1) NOT NULL DEFAULT 0,
  `blood_test_note` text DEFAULT NULL,
  `doctor_note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lab_results`
--

CREATE TABLE `lab_results` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `receipt_id` varchar(40) NOT NULL,
  `test_name` varchar(160) NOT NULL,
  `status` enum('Pending','Ready') NOT NULL DEFAULT 'Pending',
  `sample_date` date NOT NULL,
  `upload_date` date DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lab_results`
--

INSERT INTO `lab_results` (`id`, `user_id`, `receipt_id`, `test_name`, `status`, `sample_date`, `upload_date`, `file_path`) VALUES
(1, 8, 'DS-2026-00021', 'Blood panel', 'Pending', '2026-01-10', NULL, NULL),
(2, 7, 'DS-2026-00022', 'Biochemistry', 'Ready', '2026-01-08', '2026-01-09', 'backend/files/sample_result.pdf');

-- --------------------------------------------------------

--
-- Table structure for table `trusted_devices`
--

CREATE TABLE `trusted_devices` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `device_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trusted_devices`
--

INSERT INTO `trusted_devices` (`id`, `user_id`, `device_hash`, `expires_at`, `created_at`) VALUES
(1, 3, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-05 14:40:25', '2026-02-23 13:40:25'),
(2, 6, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-05 16:25:21', '2026-02-23 15:25:21'),
(4, 8, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-09 09:40:59', '2026-02-26 10:45:29'),
(5, 10, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-08 13:26:46', '2026-02-26 12:26:46'),
(6, 11, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-08 14:40:43', '2026-02-26 13:40:33'),
(7, 12, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-08 14:47:33', '2026-02-26 13:47:19'),
(8, 13, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-08 14:54:46', '2026-02-26 13:48:21'),
(10, 14, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-08 15:02:55', '2026-02-26 14:02:32'),
(13, 1, '02048353465e8245a9d5caf61edfa7a2e548e829c4491572729d70a6b5e58d85', '2026-03-28 14:22:58', '2026-03-18 13:06:44'),
(16, 40, '9319cb88ccf0deaeba195f92fd87703a69a8f6f5c293d6c2d56aeaf87daf6433', '2026-04-12 11:20:17', '2026-04-02 09:16:36'),
(17, 7, '9319cb88ccf0deaeba195f92fd87703a69a8f6f5c293d6c2d56aeaf87daf6433', '2026-04-19 12:45:05', '2026-04-08 07:05:14'),
(18, 17, '9319cb88ccf0deaeba195f92fd87703a69a8f6f5c293d6c2d56aeaf87daf6433', '2026-04-23 15:49:28', '2026-04-13 10:19:00'),
(19, 17, '4cbc8039bc8d8badefe54056014551dfd22b5e4a800a9e6305203a5a073e6b48', '2026-05-14 12:41:43', '2026-05-04 07:57:16'),
(20, 44, '4cbc8039bc8d8badefe54056014551dfd22b5e4a800a9e6305203a5a073e6b48', '2026-05-14 10:01:47', '2026-05-04 08:01:20'),
(21, 8, '4cbc8039bc8d8badefe54056014551dfd22b5e4a800a9e6305203a5a073e6b48', '2026-05-14 11:13:07', '2026-05-04 09:13:07'),
(22, 7, '4cbc8039bc8d8badefe54056014551dfd22b5e4a800a9e6305203a5a073e6b48', '2026-05-14 12:02:05', '2026-05-04 09:14:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `phone` varchar(40) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('patient','admin','doctor','reception') NOT NULL DEFAULT 'patient',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `failed_login_attempts` int(11) NOT NULL DEFAULT 0,
  `last_failed_login` datetime DEFAULT NULL,
  `locked_until` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `email`, `password_hash`, `role`, `created_at`, `failed_login_attempts`, `last_failed_login`, `locked_until`) VALUES
(1, 'Admin', '+998901111111', 'gulsevar.bahodirova1105@gmail.com', '$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG', 'admin', '2026-02-17 14:18:52', 0, NULL, NULL),
(2, 'Aziza Patient', '+998902222222', 'patient@darmon.uz', '$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG', 'patient', '2026-02-17 14:18:52', 1, '2026-02-26 11:55:52', NULL),
(3, 'Gulsevar', '+998909964778', 'gulsevar04@gmail.com', '$2y$12$5V0yAs4wMW/l7vxbfTs29O1Uabygymc5eik4Fj2dlMoEJ5nbUm62W', 'reception', '2026-02-20 17:31:29', 0, '2026-02-21 12:50:37', NULL),
(4, 'malika', '+998909964778', 'malika@darmon.uz', '$2y$12$uGQ009Cqmbvr3.tzXThhHOHRwWA.TIlMaoFpx9RT0g6jjdwXLhr3y', 'patient', '2026-02-21 11:57:35', 0, NULL, NULL),
(5, 'Maamoun', '+393523433274', 'maamounhajjartun@gmail.com', '$2y$12$B1sjxc6tW0aqr8At47I/MeRYaYNxsoxb7YaHYLN3Ogw2uKwe.tsuO', 'patient', '2026-02-23 13:38:53', 2, '2026-02-23 14:39:37', NULL),
(6, 'Farangiz', '+393513921977', 'bekmurodovafarangiz0304@gmail.com', '$2y$12$EGgdpYoscwtmyQ/7954C1e49I4rP2Cc.hhb6DCm9tvEqEVVjF9muG', 'patient', '2026-02-23 15:23:51', 0, NULL, NULL),
(7, 'Madina', '+393523433274', 'madinaabduganiyeva15@gmail.com', '$2b$12$tUJgGjFgSYrghL.0Kh5aSec33casDCnzMgoXTvWM0qRxhnB90N1AK', 'patient', '2026-02-26 10:18:11', 0, '2026-04-08 11:36:33', NULL),
(8, 'saidnosir', '+998909964778', 'saidnosirkhonkosimov@gmail.com', '$2y$12$BohyY4PtMEHfE8taZ5z9YeNjtktIhL..eorAO38zHVoL47Lab2oE.', 'patient', '2026-02-26 10:40:18', 0, '2026-05-04 11:09:24', NULL),
(9, 'Hajjar', '+393523433274', 'e1b317a856@webxio.pro', '$2y$12$sQmFx2KmRBQbQWhEJo3rMeTXoW9Cb4/50.Pijo.p0/I2hGwQujz0.', 'patient', '2026-02-26 12:23:49', 0, NULL, NULL),
(10, 'Hajjar', '+393523433274', 'a7d07875b7@webxio.pro', '$2y$12$NYwnCTcONN/6jtdS5kOOw.nsb4pMxV88ao4Dw3NZ7SMd0bemw8y4q', 'patient', '2026-02-26 12:25:52', 0, NULL, NULL),
(11, 'check', '+393523433274', 'c1dc166663@webxio.pro', '$2y$12$lRtibpMOQuSCBBuVqPvfjePRP5t9UHRWE7QGT2HTDbMjy3XBAF1tu', 'patient', '2026-02-26 13:40:00', 0, NULL, NULL),
(12, 'test2', '+998909964778', '439a35274d@webxio.pro', '$2y$12$NE.lD6oLOye/iVWbc0uzs.Y9uPKVxr.1dYrahxqf3Gs2.pBKYoete', 'patient', '2026-02-26 13:47:19', 0, NULL, NULL),
(13, 'test3', '+998909964778', '7966c669c6@webxio.pro', '$2y$12$Nv1mrldIvloNAX7MVG13U.3T.ORillz4dSlTjJA9bjQw7fY/Pg6ym', 'patient', '2026-02-26 13:48:21', 0, NULL, NULL),
(14, 'test4', '+393523433274', '6c752e4b92@webxio.pro', '$2y$12$nAqbINj0tcUZM8obaOehAuoHFCFnpXzOEblXnky5wkVKPgYieVsaK', 'patient', '2026-02-26 14:02:32', 0, NULL, NULL),
(17, 'Nodira Usmonova', '+393513921977', 'nodira.uralova@proton.me', '$2b$12$cDMaVjwzplQSPfyzfuGCIeLgkaN80CzAT4uPjBvl87/kPy8FMylF2', 'doctor', '2026-03-18 12:14:22', 0, '2026-04-13 12:13:06', NULL),
(35, 'Admin', '+998901111111', 'admin@darmon.uz', '$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG', 'admin', '2026-03-30 09:57:45', 0, NULL, NULL),
(36, 'Reception Desk', '+998903333333', 'reception@darmon.uz', '$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG', 'reception', '2026-03-30 09:57:45', 0, NULL, NULL),
(37, 'Dr. Dilshod Akhmedov', '+998904444444', 'e369066f03@emailax.pro', '$2y$10$H0LA6.j.vdFvoyzsfEg/vusRRuZPlrR0q0K5CTOM28ljN1Y1dWdwG', 'doctor', '2026-03-30 09:57:45', 0, '2026-05-04 12:42:25', NULL),
(39, 'Dr. John Doe', '+393513921977', '376e3fd6b5@emailax.pro', '$2b$12$.vGNF6FGZ496qVObupvWK.r2gB9as1lxIn2EKmDY82Y/3p2W8lUaa', 'doctor', '2026-03-30 10:25:30', 0, NULL, NULL),
(40, 'test5', '+998908457934', '7e85a885f7@emailax.pro', '$2b$12$rzkSJdnpVsC8qVXGx.bmNehHTdTngN9EeMNbOKs8o7iY40Loww/8y', 'patient', '2026-04-02 09:16:36', 0, NULL, NULL),
(41, 'Dr. Test 9', '+393513921977', 'test9@gmail.com', '$2b$12$iMS1T94pvQo5iiFHYxKST.hVb0uBxyyTu9T.anhvMicWhPgCuNhfy', 'doctor', '2026-04-03 10:00:40', 0, NULL, NULL),
(42, 'Dr. test1', '+998908457934', 'test1@gmail.ocm', '$2b$12$Aderqwsg4wSQADV3H9yTv.tQZTwiLCFdmWzXxAhph6Qiv.r3s7SPq', 'doctor', '2026-04-03 10:01:31', 0, NULL, NULL),
(43, 'Dr. t2', '+998909964778', 't2@gmail.com', '$2b$12$nUL6OUOpph2mrip2utI9gO8s88m4awWev2Nxp7ngNthbXiWz4za6G', 'doctor', '2026-04-03 10:18:36', 0, NULL, NULL),
(44, 'test 10', '+393523433274', 'e31938196e@emailax.pro', '$2b$12$WTAstAVLxVBkpEeDHaW7KOMN7OkYQ3WbRJE2JWuQfPv7cAy1NeMqa', 'patient', '2026-05-04 08:01:20', 0, NULL, NULL),
(45, 'Dr. Aziza Tursunova', '+393523433274', 'a7ee15ad5b@emailax.pro', '$2b$12$z1Jo0jg/wjCewBm6i5yMvuDKfp7es.gxFAjCAwQeAeczgQ0cPefPa', 'doctor', '2026-05-04 08:51:02', 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_otps`
--

CREATE TABLE `user_otps` (
  `id` int(11) NOT NULL,
  `email` varchar(190) NOT NULL,
  `purpose` enum('register','login','password_reset') NOT NULL,
  `otp_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_otps`
--

INSERT INTO `user_otps` (`id`, `email`, `purpose`, `otp_hash`, `expires_at`, `attempts`, `created_at`) VALUES
(1, 'malika@darmon.uz', 'login', '5e16871acea99b4b2ce5b67d63caa0be5f06905fd5bab727deb8fd027a7ff384', '2026-02-23 13:04:45', 0, '2026-02-23 11:39:45'),
(9, 'you@example.com', 'register', '42e09a57cb7fcfce282af54cf7bb5a27d25e0b245c67df7cfb85ffc6c45b2b2a', '2026-02-23 16:49:48', 0, '2026-02-23 15:24:48'),
(12, 'testuser123456@gmail.com', 'register', '51e27bc9c6fb6a129613286f45a728f9f431b42794248bef7a760b9f66be63f3', '2026-02-26 11:39:42', 0, '2026-02-26 10:14:42'),
(13, 'testuser654321@gmail.com', 'register', '482043859f79b8e49649d67ab6314154f2a32a956d25b3092ba5d46185363f73', '2026-02-26 11:40:49', 0, '2026-02-26 10:15:49'),
(14, 'testuser999@gmail.com', 'register', '61f663b0826e0a8a18afc3516fa57f2df358d37c67a1f06e061010ee1f1406d3', '2026-02-26 11:41:39', 0, '2026-02-26 10:16:39'),
(15, 'finaltest@gmail.com', 'register', '19e92a39fc91af5722b88dde297815cac27d5fb1070700184709ec7a11b4d7c7', '2026-02-26 11:42:10', 0, '2026-02-26 10:17:10'),
(18, 'janedoe@example.com', 'register', '02b090f699391ec0fc79f10625a4b84d82b158fa59fda68e91887e40eee98622', '2026-02-26 11:48:37', 0, '2026-02-26 10:23:37'),
(89, '82593da510@emailax.pro', 'register', 'f4d2c5581cef20ecc7719b247abfbf82cfe620fd2d6a7de018b7a1f3c2bd484c', '2026-05-04 12:36:09', 0, '2026-05-04 10:11:09');

-- --------------------------------------------------------

--
-- Table structure for table `user_tokens`
--

CREATE TABLE `user_tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_tokens`
--

INSERT INTO `user_tokens` (`id`, `user_id`, `token_hash`, `created_at`, `expires_at`, `last_used_at`, `revoked_at`, `ip`, `user_agent`) VALUES
(1, 1, 'b2ace1aad972faa12cc3084480d28018fad5b174508da2898885dc3ee76a0910', '2026-02-17 14:19:22', '2026-02-20 14:19:22', NULL, NULL, NULL, NULL),
(2, 1, '04f5d7ba962ebb131e7536363d86ef9460617a9fef7da99661f4feaf9356cb57', '2026-02-17 14:19:22', '2026-02-20 14:19:22', NULL, NULL, NULL, NULL),
(3, 1, '2ba4b34df7b840ac98e958695816349ad1bd1d711d68774da30420d64920c1df', '2026-02-17 14:19:38', '2026-02-20 14:19:38', NULL, NULL, NULL, NULL),
(4, 1, '2ef98aa8c077a1b4ab889f18207b4c71ab294070f4cbc5d1acdfdcdb55a293f1', '2026-02-17 14:19:38', '2026-02-20 14:19:38', NULL, NULL, NULL, NULL),
(5, 3, '91725a8c87ab6ed162b091081f559362ad5b379bd3ebb0a3a3fbc111836b2a85', '2026-02-20 17:31:29', '2026-02-23 17:31:29', '2026-02-20 17:31:29', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(6, 3, '3be14ce2c092d8f3303d75253d4cfa2dbf122878372e6a8e6c15a4b79e3a7e13', '2026-02-20 17:32:13', '2026-02-23 17:32:13', '2026-02-20 17:32:48', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(7, 3, '9c6426cbe8cec1112c7d1fa18ad22d9873ac7f8b61dd6098a62a0ecc71a3c8a3', '2026-02-21 11:49:45', '2026-02-24 11:49:45', '2026-02-21 11:49:45', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(8, 2, 'bc9aea3e7a2818ba5cc2749d051031654708f28b9174727c1783388f7975b03c', '2026-02-21 11:51:11', '2026-02-24 11:51:11', '2026-02-21 11:51:11', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(9, 2, 'f8c0418b7f79acd7023b14b04f781f2dcd423a4bfc30978ce10c9fe55ebe2b61', '2026-02-21 11:51:11', '2026-02-24 11:51:11', '2026-02-21 11:51:11', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(10, 4, 'f3e984a2b44dc6bff99b313194a80f5f59820919d265ef97e81969ea2d5ac4c5', '2026-02-21 11:57:35', '2026-02-24 11:57:35', '2026-02-21 13:07:14', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(11, 4, '6c31fd28e59b68eec01113d8ad889254356579c0ec5aa189e4d7eb6db51c2a95', '2026-02-21 13:07:21', '2026-02-24 13:07:21', '2026-02-21 18:10:52', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(12, 4, '9b6b70948d3e85dbcd10b2f25a5c6b077ee4b31f4953b2833ceb764af65549c4', '2026-02-22 18:50:25', '2026-02-25 18:50:25', '2026-02-22 18:50:25', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(13, 4, '94895e1f375c36546d94797d329f57daf50da344c82bfcc99f2a89756e596bfc', '2026-02-22 18:50:44', '2026-02-25 18:50:44', '2026-02-23 08:52:46', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(14, 3, '59b0848b75711f226eeb8517e773a07a29a823363f2f4298f4901cdf446bba58', '2026-02-23 13:40:25', '2026-02-23 14:40:25', '2026-02-23 13:40:25', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(15, 6, 'e8c67bdb2fa13f05fbec2218f780f80b297987685ffba8fb5ebc00b355c47000', '2026-02-23 15:25:21', '2026-02-23 16:25:21', '2026-02-23 15:25:21', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(16, 3, '182f82b23572a0bab8a414928c19fcec16ff657292aa56854115770f3d93ef7b', '2026-02-26 09:44:10', '2026-02-26 10:44:10', '2026-02-26 09:44:10', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(17, 3, '09f9b2ac032d4ca2e84c6d3ce3b9946eb3e2128f114f7fd0a1d8969334ecf913', '2026-02-26 09:45:48', '2026-02-26 10:45:48', '2026-02-26 09:45:48', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(18, 7, 'e202aa615c3baa41e6e91d5e7caea4ffdb1c0eb165a53eaa4b91d15f2f916c5a', '2026-02-26 10:18:34', '2026-02-26 11:18:34', '2026-02-26 10:18:34', '2026-04-08 07:04:51', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(19, 8, 'c8e76aa4867d8986670196ec1170a1bb6a0065f157f3c1c86663c8aff88cacdf', '2026-02-26 10:40:18', '2026-02-26 11:40:18', '2026-02-26 10:40:18', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(20, 8, 'b828e4354dce5294bd4c62f387904e9ec018cf36b7655b1538f745850364ff86', '2026-02-26 10:45:29', '2026-02-26 11:45:29', '2026-02-26 10:56:23', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(21, 8, 'ad68608fac1df6c60326b836e0ad11ec75a3963e6cfa8fdc05c4ee53ee352fc3', '2026-02-26 11:11:37', '2026-02-26 12:11:37', '2026-02-26 11:11:37', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(22, 8, '89e4f451e3a45366b998e0a69629821f77f36b03070ab84ba834b62a1b7df0fb', '2026-02-26 11:11:42', '2026-02-26 12:11:42', '2026-02-26 11:11:42', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(23, 8, 'f6dde6bd78023e3047414bc31fdde947649f10199f75a9c04ec5af87fc1ecfd0', '2026-02-26 12:20:48', '2026-02-26 13:20:48', '2026-02-26 12:20:57', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(24, 10, 'a5cadd92ab18c8152465598ccdba799abc9336b7e5e1d380fbdc322347830336', '2026-02-26 12:26:46', '2026-02-26 13:26:46', '2026-02-26 12:27:07', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(25, 10, 'ae255c8115700bc04236684032eae0677ac57ea5bfb55a0f04f8563bd46975fc', '2026-02-26 12:27:53', '2026-02-26 13:27:53', '2026-02-26 12:27:53', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(26, 3, '93613a981969fc13c9d601d3488a184263afc3c0dc73bd552f58280e51fe5a62', '2026-02-26 13:35:10', '2026-02-26 14:35:10', '2026-02-26 13:35:10', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(27, 11, '2556ea9bb5b6f14e5be38c321e8347ce1431b0be2c09e0917cfefafb76124ef4', '2026-02-26 13:40:00', '2026-02-26 14:40:00', '2026-02-26 13:40:00', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(28, 11, '831b6fe42adbc530778c2d6221f5f7305f2e92a411bda6f0436c91a03e38d68e', '2026-02-26 13:40:33', '2026-02-26 14:40:33', '2026-02-26 13:40:33', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(29, 11, '9607bb98ff296604f5809ff6aa721ea0caf7172e3752d79154f61c7cdaaba96e', '2026-02-26 13:40:39', '2026-02-26 14:40:39', '2026-02-26 13:40:39', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(30, 11, '60534501797d5cf1f82391114b1bf93c66b18eca28020e0628c846c12fc30794', '2026-02-26 13:40:43', '2026-02-26 14:40:43', '2026-02-26 13:40:43', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(31, 12, '3330d04d310fd1e7897c51b5ffb65ef6f3415ff634223ce5855f56b721e37a71', '2026-02-26 13:47:19', '2026-02-26 14:47:19', '2026-02-26 13:47:19', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(32, 12, '63fa7d8dca0364e3b419ed5e968c73811d4a6c84412eb4ffa2dc0f77daab7dab', '2026-02-26 13:47:33', '2026-02-26 14:47:33', '2026-02-26 13:47:33', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(33, 13, '358f040fcbcd84d88da7279ee34bc73a4aeae1a63cd477779496f986752aff22', '2026-02-26 13:48:21', '2026-02-26 14:48:21', '2026-02-26 13:48:21', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(34, 13, 'ae5a2a9420baedb1bafecca35ef606173467833f9d31be3a5be6ab5c777ca74d', '2026-02-26 13:48:59', '2026-02-26 14:48:59', '2026-02-26 13:48:59', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(35, 13, '229c38df01cac1ef95e7785afa734c714920e18f72d4eb5ca9e37f5ac9dae7bb', '2026-02-26 13:54:46', '2026-02-26 14:54:46', '2026-02-26 13:54:46', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(36, 14, '83f3d97a487e717e3ea6a75379c757b8b0d065da94dc5167fa7179f4d3f31d26', '2026-02-26 14:02:32', '2026-02-26 15:02:32', '2026-02-26 14:02:32', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(37, 14, '320efceb8bd67f81c9f9bc516830af71c9ceda71e044dfa0006e43a911350e80', '2026-02-26 14:02:55', '2026-02-26 15:02:55', '2026-02-26 14:02:55', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(38, 8, '108d8b17cd341415c31959dd7f58e73371b72e251e39437c52476560f95d64d5', '2026-02-27 08:40:59', '2026-02-27 09:40:59', '2026-02-27 08:41:10', NULL, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(39, 7, 'b5fade3094ff579dfb8eba909632cda4f99ff20e0c1202d1888ca975f6f5bdc3', '2026-03-02 13:41:03', '2026-03-02 14:41:03', '2026-03-02 13:41:03', '2026-04-08 07:04:51', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(40, 7, '0d76e81615a252e9aa895619e1ccc3868539861af998c5d25355b78be81e632f', '2026-03-02 13:41:13', '2026-03-02 14:41:13', '2026-03-02 13:41:21', '2026-04-08 07:04:51', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(41, 7, '7f9eef8b4af03eb9e1d04dcdc28f0afdc4360d998b3cd667d501f88d5cab4f87', '2026-03-02 14:10:20', '2026-03-02 15:10:20', '2026-03-02 14:10:20', '2026-04-08 07:04:51', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(42, 17, '482e6191be14ba4b24199f93b7200fa19194f20bccc55599020c431883ad87aa', '2026-03-18 12:14:22', '2026-03-18 13:14:22', '2026-03-18 12:14:30', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(43, 17, '6a6a73aeba9ad0b4d7a013fd42e8a385a2418a24c53844262625cc8031840115', '2026-03-18 12:14:54', '2026-03-18 13:14:54', '2026-03-18 12:14:54', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(44, 7, '8378a1804a3a06f69c0ac015e438af1388b9103fb36ffc1b04bd8b07e4f07405', '2026-03-18 12:16:10', '2026-03-18 13:16:10', '2026-03-18 12:16:10', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(45, 7, '86898e2cdb53840cf0fe773c2fb193d14e590cbd709519be1927d1b6a752a635', '2026-03-18 12:17:14', '2026-03-18 13:17:14', '2026-03-18 12:36:15', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(46, 7, 'a556cfa742a5dced4f878abfa951ab8bbeac1faa4753417a6c5b5a2bc01e9258', '2026-03-18 12:36:21', '2026-03-18 13:36:21', '2026-03-18 12:36:40', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(47, 7, '8925781e6eeeefed815b5e15e4aa67b20ec3612339b257462fbcddd537481b00', '2026-03-18 13:02:13', '2026-03-18 14:02:13', '2026-03-18 13:02:13', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(48, 1, '254967147fe1f1a5851ad8aac3e8a697c337d70d222a62bb796cd736f290e875', '2026-03-18 13:06:44', '2026-03-18 14:06:44', '2026-03-18 13:06:44', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(49, 1, 'eac6ca17637c29e67fdaf5da11fb0cdd95b898d57cd9ec07c03d442d6d89089f', '2026-03-18 13:12:49', '2026-03-18 14:12:49', '2026-03-18 13:13:12', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(50, 7, 'eb29c8ee2e3bb98c86d8e2873755a19a060ecb43d30e22a4d53ef27930d022f2', '2026-03-18 13:13:14', '2026-03-18 14:13:14', '2026-03-18 13:13:14', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(51, 7, 'a9d51d405fa708927d2aaa0ab730cda539f4f720c4d9b4486eeada7d6e4347b5', '2026-03-18 13:13:15', '2026-03-18 14:13:15', '2026-03-18 13:13:15', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(52, 7, '632379887b46f27e914d619895d0ee47026ffe6604ffd53fe1aad0d0c838395a', '2026-03-18 13:13:23', '2026-03-18 14:13:23', '2026-03-18 13:13:23', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(53, 7, '39f517a39ceb89fecf20a93091d2255ec26abd259a851273729d12f834a4e623', '2026-03-18 13:20:15', '2026-03-18 14:20:15', '2026-03-18 13:20:22', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(54, 1, '0334a3e4a3eea9857e70aef6394e284f999580d78eb3e8203dd925419179d608', '2026-03-18 13:20:42', '2026-03-18 14:20:42', '2026-03-18 13:48:25', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(55, 1, 'ea459293913ee3edda4c673ea11b9057e710ead17eb405199d10643aad181f9f', '2026-03-18 13:20:57', '2026-03-18 14:20:57', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(56, 1, '9aa8c0dac68f4356ea45f1c4557fd36516bec748148b8fef49e33547fc7b685d', '2026-03-18 13:22:58', '2026-03-18 14:22:58', '2026-03-18 13:39:53', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(57, 7, '345525ef6a60cb2c1a7ea067283233b5bc50dc798d5b837a4fef08716b59dbc3', '2026-03-18 13:49:08', '2026-03-18 14:49:08', '2026-03-18 13:49:08', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(58, 7, '1ca73e3ce5df0ffc41d15c6d4dd82b0f43524d3fbe27a079372fa4dffe28f513', '2026-03-18 13:49:12', '2026-03-18 14:49:12', '2026-03-18 13:49:12', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(59, 7, 'ec1ce312efe57ca2ea4088a3adcb8eccc63b4b520a7fcd7e13e5842b636888d2', '2026-03-18 13:53:37', '2026-03-18 14:53:37', '2026-03-18 13:53:44', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(60, 7, '1db236d7cbb778fd3ef7b39d063c09abe7a475e549ba95ae0d2853ce28fd1ab4', '2026-03-18 14:58:38', '2026-03-18 15:58:38', '2026-03-18 15:03:09', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(61, 7, '8ab4c1ee71576be50308a4eaabef512b9394897c7b5c722ee69965d56f36450f', '2026-03-18 15:03:27', '2026-03-18 16:03:27', '2026-03-18 15:09:02', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(62, 7, 'a88ba1f5ce3890f3c693bd516d1e66922b858cb1b0dc0c607181ec1991d15d4f', '2026-03-18 15:09:12', '2026-03-18 16:09:12', '2026-03-18 15:42:12', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(63, 1, '3c3b975d52b6ad73a33b62057a96dc23eb3e30bd208eb5dd101dbf009cc4b1ba', '2026-03-18 15:43:07', '2026-03-18 16:43:07', '2026-03-18 16:21:21', '2026-03-18 16:21:25', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36'),
(64, 1, 'a9fa12c6c32a82d713811dab2485115226cc831512c4587a09ea3fcf7a8b2b65', '2026-03-24 09:38:23', '2026-03-24 10:38:23', '2026-03-24 09:38:23', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(65, 1, '3b728a327d13612e99b991c1259fb5d276cbce5693e4f09c5a25c95276f661b5', '2026-03-24 09:39:18', '2026-03-24 10:39:18', '2026-03-24 09:40:42', '2026-03-24 09:41:03', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(66, 1, 'b78dbb1f85c54a328b46be4f0874a34cc613360a06497a4cbce1f80aae2d3611', '2026-03-24 09:43:21', '2026-03-24 10:43:21', '2026-03-24 09:43:21', '2026-03-24 09:43:26', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(67, 1, '347be91dea46a3c6cf2bdd89db443c1b3689afa5232b5c85970d35564dce9778', '2026-03-24 09:45:59', '2026-03-24 10:45:59', '2026-03-24 09:45:59', '2026-03-24 09:46:10', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(68, 3, 'e0495d644b7c52997f78ad510b6dff092e3202d6f31f878aa1bba0d8dc453f4e', '2026-03-24 09:47:32', '2026-03-24 10:47:32', '2026-03-24 09:47:32', '2026-03-24 09:47:56', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(69, 17, '391e0c033558ac70f3fe3e25b93e7e734b5a096b14ca07ab1153d4bc6061a100', '2026-03-24 09:51:10', '2026-03-24 10:51:10', '2026-03-24 10:07:22', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(70, 17, '47a0a3bfbc8858c4b595515dab3a14ea7a7455eea1baea6673c71e4a425eaa46', '2026-03-24 10:52:52', '2026-03-24 11:52:52', '2026-03-24 11:47:35', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(71, 3, 'de74a8c8977e5a84fc248277a8e07d19e18fd29500bd8ee71431409f91fd4a7b', '2026-03-25 11:13:36', '2026-03-25 12:13:36', '2026-03-25 11:18:23', '2026-03-25 11:18:48', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(72, 1, '40c1c4e42de97afa3d6b1ffb9821ba96e0d67f72f26cdaad1bf39e979e279b8f', '2026-03-25 11:20:15', '2026-03-25 12:20:15', '2026-03-25 12:04:18', '2026-03-25 12:04:21', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(73, 17, '431bd65a8df921f70abd376fe13cf755bb85c14dfe03e2119ed074e3c188683f', '2026-03-25 12:06:23', '2026-03-25 13:06:23', '2026-03-25 12:14:50', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(74, 17, '85e5b8533f92c298f2ec07bd5f48879cbc28e8d4e090e8df53e8fc452dae282d', '2026-03-28 15:44:44', '2026-03-28 16:44:44', '2026-03-28 16:02:42', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(75, 17, '0589a08bbb6948213de0d36956d929ccf2199eca5c7d0ad94297278df7f30f02', '2026-03-28 16:02:44', '2026-03-28 17:02:44', '2026-03-28 16:02:45', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(76, 17, 'ffc00d5493b10bd248366b5dcc7569dbcee22a02943dc9675ec1726281175fda', '2026-03-28 16:02:56', '2026-03-28 17:02:56', '2026-03-28 16:02:56', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(77, 17, 'b07d7c765b49dbcaa072e18a054623ca34aab7c9edcaab64394c7508e2c010ae', '2026-03-28 16:02:58', '2026-03-28 17:02:58', '2026-03-28 16:06:00', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(78, 17, 'dfe4335fc1167c0ef69dca671cb30eab9478261131345724152b97c6715ae1b5', '2026-03-28 16:06:11', '2026-03-28 17:06:11', '2026-03-28 16:08:04', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(79, 7, 'd9ab822eecc690b5f480543d8a9090069742ae52c6fff4afc5dc69755569b13a', '2026-03-28 16:06:44', '2026-03-28 17:06:44', '2026-03-28 16:06:44', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(80, 7, '0ba43971be473b5674ca45c6d4adaaec0ffffe271722e6c3806fec3e8ce37a48', '2026-03-28 16:07:07', '2026-03-28 17:07:07', '2026-03-28 16:07:07', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(81, 7, 'b732b9a309c36c3dc05772b9b8ce26a3ab4a26b32a526f583c5f81d61763a8c6', '2026-03-28 16:07:12', '2026-03-28 17:07:12', '2026-03-28 16:07:12', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(82, 7, 'f1caec2cf65da2b9ef232813ee98be02399d1745ce409efcb95408cfb4c3e739', '2026-03-28 16:08:07', '2026-03-28 17:08:07', '2026-03-28 16:08:07', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(83, 17, '642bad204754fedaeca20c2fe68bc10808ef1fd94036cac2226116a53a26016a', '2026-03-28 16:08:17', '2026-03-28 17:08:17', '2026-03-28 16:08:17', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(84, 7, '5cafb36a18b0d25b9ebe6c4f689317cc4753bf660f5a9ad179136aaf21e1410f', '2026-03-28 16:09:06', '2026-03-28 17:09:06', '2026-03-28 16:09:06', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(85, 17, '7b13aebc6b0892117188448b407abe50ba2d59b95a2ea9499f021e4cf68c79ef', '2026-03-28 16:09:48', '2026-03-28 17:09:48', '2026-03-28 16:29:09', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(86, 17, '22bf75600f7a751ad7be909327ec08896c43fd3782f50f09ab62f6b82efffaf5', '2026-03-28 16:29:11', '2026-03-28 17:29:11', '2026-03-28 16:31:22', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(87, 7, '198b837b1b959821231e5c6c96e29ee1f79c9fa1dc3a4686736e84e530726d22', '2026-03-29 10:02:48', '2026-03-29 11:02:48', '2026-03-29 10:02:48', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(88, 3, '70aaa5d7f39e17f4abaacffc549521145529bc95ef3892d78d0e285558678eac', '2026-03-29 10:03:14', '2026-03-29 11:03:14', '2026-03-29 10:03:14', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(89, 7, 'fa0206d5d4cd839d98f18fcfaa72ab98db727423e08719f9bd356922e4dd0fb1', '2026-03-29 10:04:13', '2026-03-29 11:04:13', '2026-03-29 10:09:01', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(90, 1, 'cc66d9ecec1b4a15ed049de1a2a6e4970ee5f9675db57c3939ac5309a265ee1c', '2026-03-29 10:32:51', '2026-03-29 11:32:51', '2026-03-29 10:38:51', '2026-03-29 10:54:53', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(91, 17, '7b30c3a18af490d4df68c8ecc5d6c58a51bc2e141d499b4ee6fb77a32e58b290', '2026-03-29 10:57:44', '2026-03-29 11:57:44', '2026-03-29 11:23:55', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(92, 17, 'cae27ff9d7cf0c25de978b12d3d3c2f416397ed5bf5315d58e920681ce1d2739', '2026-03-30 10:16:51', '2026-03-30 11:16:51', '2026-03-30 10:19:13', '2026-03-30 10:19:50', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(93, 1, '0053c857782c6ceeab9b378b4d138a9ffc7e31005bd0f486ff13eaa76909bfd5', '2026-03-30 10:22:16', '2026-03-30 11:22:16', '2026-03-30 10:25:30', '2026-03-30 10:25:50', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(94, 7, 'beef76917eadabfb2204b0d77e34baecbff7906cb1a58c59b103669e06bf363f', '2026-03-30 10:26:47', '2026-03-30 11:26:47', '2026-03-30 10:27:12', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(95, 39, '69485c8144c9f1d4c4c2c430eede5d2b5d7e0dd85931315593a90d844157ac94', '2026-03-30 10:27:49', '2026-03-30 11:27:49', '2026-03-30 10:28:03', '2026-03-30 10:28:18', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(96, 7, '8dc498c9f319a48ece7d5b408b263d2da171629526bc191fb45eba76785b2a6e', '2026-03-30 10:28:24', '2026-03-30 11:28:24', '2026-03-30 10:28:35', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(97, 39, '431c486df0c539def8f154aa201457f8feb7beb4de5dc6e0c8a2ee4cedef3573', '2026-03-30 10:29:18', '2026-03-30 11:29:18', '2026-03-30 10:29:18', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(98, 17, '39e5c1ae7eb7f1f3da5c152005e3f406a2d66f6c699a2f2eb55aeaca1fd7afe8', '2026-03-31 16:31:45', '2026-03-31 17:31:45', '2026-03-31 16:46:52', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(99, 17, '612ea1e1418d6adb1b1ff960e2e3a81d13d013652f9047adc9db733a061afd23', '2026-04-02 08:02:20', '2026-04-02 09:02:20', '2026-04-02 08:02:38', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(100, 7, '09c0f8acd59baefd85227f7c851dbd5be4457eae67cb1d59549b889aa96bc55f', '2026-04-02 09:10:40', '2026-04-02 10:10:40', '2026-04-02 09:10:40', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(101, 7, '9eed62a8ba120c57927fab391f13228103e0a302a86b05eb6395397f18df3484', '2026-04-02 09:10:41', '2026-04-02 10:10:41', '2026-04-02 09:10:41', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(102, 17, '53809888a350b88082d6bc34539a0ef13c4f694f4f83980ca00a663dac0c2e15', '2026-04-02 09:10:45', '2026-04-02 10:10:45', '2026-04-02 09:10:45', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(103, 17, '9b39f2019ff526bc8a1e720b1cc02934e8ec045a58ab83a2a3d5087a3024b474', '2026-04-02 09:10:56', '2026-04-02 10:10:56', '2026-04-02 09:10:56', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(104, 17, 'edadd18a6d61eacbd49c23a629e1074f662013fcda3f861e317915758d256dc9', '2026-04-02 09:14:09', '2026-04-02 10:14:09', '2026-04-02 09:14:09', '2026-04-02 09:14:20', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(105, 7, 'eb34d834025afb4d8952e40fecee5401235edadf0afd17bc9ceaa1f6a86909bc', '2026-04-02 09:14:47', '2026-04-02 10:14:47', '2026-04-02 09:15:30', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(106, 7, '40043dd433878f189f7c25abd2ba70fa935d786c0d01e18d81386f55f8a6b482', '2026-04-02 09:15:37', '2026-04-02 10:15:37', NULL, '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(107, 17, 'f4f1b6f014f552552681e5046713009d1ca58de81dcc6c5936d5fe48ad1a1a80', '2026-04-02 09:15:43', '2026-04-02 10:15:43', '2026-04-02 09:15:43', '2026-04-02 09:15:45', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(108, 40, 'ff70fda524f1f82a824341f04d6ebaba7194e37b11b9323c639c79bf305ee252', '2026-04-02 09:16:36', '2026-04-02 10:16:36', '2026-04-02 09:16:48', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(109, 40, 'd533af2e1dd11a30d56e14ad4346369117ede4814b8c6a98794b9bf24fc84f28', '2026-04-02 09:16:58', '2026-04-02 10:16:58', '2026-04-02 09:16:58', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(110, 40, 'dd4854beaa79523988b8201a026c8036f618489cd0527245919337083f81b530', '2026-04-02 09:20:17', '2026-04-02 10:20:17', '2026-04-02 09:20:17', '2026-04-02 09:20:19', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(111, 7, 'a818028a6b07473f8bed13cf57a45994131d267f8f72b525684b93881ede99f9', '2026-04-02 09:20:24', '2026-04-02 10:20:24', '2026-04-02 09:20:24', '2026-04-02 09:20:33', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(112, 3, 'aac670a459d4fec4682718da371dd7d9d3059eaab319e8ef6fc882f934db6434', '2026-04-02 09:20:53', '2026-04-02 10:20:53', '2026-04-02 09:21:25', '2026-04-02 09:21:31', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(113, 3, '52acf79a52a327b5132792ebd155607e39c2af55f9f9c73efdd20e4bc0fe0506', '2026-04-02 09:21:58', '2026-04-02 10:21:58', '2026-04-02 09:21:58', '2026-04-02 09:22:10', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(114, 1, '015e1fdd9e92af8adcb8f791e32b7233caf1a81f2a4fdcb7f55de60ef9050743', '2026-04-02 09:22:49', '2026-04-02 10:22:49', '2026-04-02 09:22:50', '2026-04-02 09:23:17', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(115, 17, 'aebf76bc6d52d818adc0db5dad583154a56d493ea9a69fd08a723c226bcbb5ef', '2026-04-02 09:24:53', '2026-04-02 10:24:53', '2026-04-02 09:25:23', '2026-04-02 09:26:06', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(116, 17, '00db7b086ee3c548b482b03b1cf17eee655c1ff9f5bb9eabf35ec894cf567f4d', '2026-04-02 09:56:30', '2026-04-02 10:56:30', '2026-04-02 09:57:49', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(117, 1, '2f1ae9f4a9c25b1c1781411e876e63f73200900b3dfbb2408cda9aa943dd10c2', '2026-04-03 09:55:43', '2026-04-03 10:55:43', '2026-04-03 10:20:11', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(118, 7, '6bd8dc321e559042d2e96e72edabf70022ed357907a7ef5d2e10a4624ef294f6', '2026-04-03 10:02:11', '2026-04-03 11:02:11', '2026-04-03 10:09:27', '2026-04-08 07:04:51', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(119, 7, '6b4a22d6e2fa1e4179df987566925b1886136507e1283962903a9453b53c100c', '2026-04-08 07:05:14', '2026-04-08 08:05:14', '2026-04-08 07:06:20', '2026-04-08 07:06:23', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(120, 7, 'bd9e057c255a4000484adacb8bdd275e36bcc623a7bdaed447df45b97f9a62bb', '2026-04-08 07:08:26', '2026-04-08 08:08:26', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(121, 17, '2269f9792dc9d13aa20e9418168442480db6d4f7d081674b0792ead7548b7a23', '2026-04-08 07:12:37', '2026-04-08 08:12:37', '2026-04-08 07:22:56', '2026-04-08 07:22:57', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(122, 17, '40aaf2f7b66dec6ed4c77ba1f9af36a59d7fbe3adb766061ca379e1e3e2b6db2', '2026-04-08 07:23:08', '2026-04-08 08:23:08', '2026-04-08 07:25:51', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(123, 17, '85400a3723c084c6ce6ee2feca64834754cf79e45c165f018cff4f45cb926235', '2026-04-08 07:28:00', '2026-04-08 08:28:00', '2026-04-08 07:28:25', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(124, 17, 'f29a7aca72a2a60ff941432207da2582df1816d5ee6f43c24720dcda5574f7fa', '2026-04-08 07:35:31', '2026-04-08 08:35:31', '2026-04-08 07:36:57', '2026-04-13 10:11:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(125, 7, '24b60739299a63cd1207390969ab33bb4c14420c2b4fdbf1fa5e6f2f1645ed20', '2026-04-08 09:36:12', '2026-04-08 10:36:12', '2026-04-08 09:36:12', '2026-04-08 09:36:14', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(126, 17, 'ba3cf6cb4e01df4af4d565aa3d9ac4d5681416e3e409771b265c0aef86d1acf2', '2026-04-08 11:24:11', '2026-04-08 12:24:11', '2026-04-08 11:46:48', '2026-04-08 11:52:24', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(127, 7, 'f85f9343fc9d56a1399800a8d2139407db2670c05f3ba5977f26048ce1bfb94f', '2026-04-08 12:54:19', '2026-04-08 13:54:19', '2026-04-08 12:54:19', '2026-04-08 12:54:44', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(128, 17, 'd7d2d6ac13f84c7c001a632f049d03ad01eb0ce17b83c3e026c526c711b705fa', '2026-04-08 12:54:52', '2026-04-08 13:54:52', '2026-04-08 12:54:52', '2026-04-08 12:55:14', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(129, 7, 'dbcba3901383e36d0d6c43dd196c3ddef49a2bbeb3196fdf72132e581d9874a2', '2026-04-09 10:41:43', '2026-04-09 11:41:43', '2026-04-09 10:41:43', '2026-04-09 10:44:56', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(130, 7, '199d724f3aad47b358e227d47f93fd5b8e2313815592a0d0aed88ea5efe02b0e', '2026-04-09 10:45:05', '2026-04-09 11:45:05', '2026-04-09 10:45:05', '2026-04-09 10:46:24', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(131, 17, '755740421bbddeae7e0fb1500a335a6d042f0a6099bb8d32df2268f400bac446', '2026-04-13 09:55:56', '2026-04-13 10:55:56', '2026-04-13 10:07:13', '2026-04-13 10:08:43', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(132, 17, '2dfe4da63276b1f4a23c34ca116c0038b94fa351c74696d8bff9068762cefb7b', '2026-04-13 10:14:19', '2026-04-13 11:14:19', '2026-04-13 10:14:19', '2026-04-13 10:16:04', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(133, 17, 'f0ab76b4d88fa688333a7bc3ef23910255651a9a6f3492402d8132db270eac76', '2026-04-13 10:19:00', '2026-04-13 11:19:00', '2026-04-13 10:19:00', '2026-04-13 10:19:02', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(134, 17, 'ef3277a42c0872a964a89aabee49efe1394a034ed47b545d3173360b914c4c6a', '2026-04-13 10:19:05', '2026-04-13 11:19:05', '2026-04-13 10:19:05', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(135, 17, 'eccf727b0a4bddd15ba01051dcbef9be5b3e634b5d628912f799452ff05b5cf3', '2026-04-13 11:58:24', '2026-04-13 12:58:24', '2026-04-13 12:08:00', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(136, 17, 'b0906a77864d9067c0f15ce6c5d3baf4addbc09e41a70658efeff7fd23a5fd5e', '2026-04-13 12:06:11', '2026-04-13 13:06:11', NULL, NULL, '0.0.0.0', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(137, 17, '6274afeca8ee7139398cbad6a6363f51f142469aa2059e956cbf1bf4454668cb', '2026-04-13 12:06:12', '2026-04-13 13:06:12', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(138, 17, 'f0101c5a9380fed32c0370157ea71649e9cef1e50fcea8535b32c6101f8ef7d9', '2026-04-13 12:07:16', '2026-04-13 13:07:16', '2026-04-13 12:07:53', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(139, 17, '880af958d4da41fa2f823629d88b4bc052d3e598908e955c629483844a17a650', '2026-04-13 12:08:16', '2026-04-13 13:08:16', '2026-04-13 12:08:16', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(140, 17, '1291c71ecf32d476d82e2ad4c49f924edc570f980443bfd7c0b56aff519c9a1e', '2026-04-13 12:08:27', '2026-04-13 13:08:27', '2026-04-13 12:08:27', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(141, 17, 'e9dfebd9584f79de1b3414e70250b6b8384252d70a9f11b957c8965e3cea5c4e', '2026-04-13 12:08:31', '2026-04-13 13:08:31', '2026-04-13 12:08:31', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(142, 17, 'b37735e55dff8bc99486e200615fb3d4870d2b1beabd79c4235127c1bbdf0885', '2026-04-13 12:09:03', '2026-04-13 13:09:03', '2026-04-13 12:09:03', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(143, 17, '583c0f1fd1ef447e33d6df868c778876180455ac1eced5c889f787cc643eece1', '2026-04-13 12:10:15', '2026-04-13 13:10:15', '2026-04-13 12:10:15', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(144, 17, '72060dd18351ef5ebb4986a3ee9661f21f793ba7eb86b0aafb8322e498bd1272', '2026-04-13 12:10:19', '2026-04-13 13:10:19', '2026-04-13 12:10:19', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(145, 17, 'ec18a401b6874dd7d4828456a31d045b035c87547069acb31d1f84b64f7bdd17', '2026-04-13 12:10:43', '2026-04-13 13:10:43', '2026-04-13 12:10:43', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(146, 17, '0b929add0a6e36b48b2db1ad571c3219d2234cd36a793cdddfe81c774c84565b', '2026-04-13 12:10:48', '2026-04-13 13:10:48', '2026-04-13 12:10:48', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(147, 17, '1739d2085d2bf14c208f441f49fd7972574ee288721989436e50b91fb591c724', '2026-04-13 12:11:08', '2026-04-13 13:11:08', '2026-04-13 12:16:24', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(148, 17, 'ef697380419eb00ecf0a10226d63830d31c446cabf8adf9f485dc826a4e937d0', '2026-04-13 13:31:01', '2026-04-13 14:31:01', '2026-04-13 13:42:19', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(149, 17, 'de44411066572d54f0372971b8b3e3e0cd12a91e6f247e6a299f72cc9f14864f', '2026-04-13 13:49:28', '2026-04-13 14:49:28', '2026-04-13 14:18:11', '2026-04-13 16:51:26', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'),
(150, 17, 'c038fd25722af9fd895361496619fc2c4c032dbe9b19fcefbc6c0713a2c54ed1', '2026-05-04 07:57:16', '2026-05-04 08:57:16', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(151, 17, 'dd6e6e9c3c2c9d309c414bec73bbd012d1993ba7e9be284d491fcd10d0a150f8', '2026-05-04 07:57:20', '2026-05-04 08:57:20', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(152, 17, 'a692f89ea74094c23803979c1bd41937b6a45a4d62463ab929f718739ac120c2', '2026-05-04 07:57:33', '2026-05-04 08:57:33', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(153, 17, 'e1953146255d02db4310ca21492add7c8d04619d4ba6669f95014f66502afb8a', '2026-05-04 07:57:35', '2026-05-04 08:57:35', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(154, 17, '24932f32761551aa9fafc4f44173af6aad22c7fdc003732fa2d8fe4e4c04bf1d', '2026-05-04 07:59:02', '2026-05-04 08:59:02', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(155, 17, 'd1f0841be1fb50e03d8c84c3844382c6ddc60aeb0b3dbc69cd2e3fcc0422809d', '2026-05-04 07:59:15', '2026-05-04 08:59:15', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(156, 17, 'b097584acc5628d3cf5d06acab6e8279aa7ea279da938ad301e9a00bf96fa51c', '2026-05-04 07:59:17', '2026-05-04 08:59:17', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(157, 44, '7a4e79445fc9725764b567f9157b737a61be47546a55a050ddfce91296413a4d', '2026-05-04 08:01:20', '2026-05-04 09:01:20', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(158, 44, 'edae00f532b46cc52329af75802f0a418f0320f6e851365acba9a1581c53edba', '2026-05-04 08:01:47', '2026-05-04 09:01:47', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(159, 35, 'd9cf98ab6cd0d4a5ad42178e80532d95e9f58cfbc84916ca57341aea4e3effce', '2026-05-04 08:06:27', '2026-05-04 09:06:27', NULL, NULL, '127.0.0.1', 'unknown'),
(160, 37, '41881e2c6bbef94770feea6dd38488bac852ddb57df148828cc2fa24b99fa463', '2026-05-04 08:06:45', '2026-05-04 09:06:45', '2026-05-04 08:06:45', NULL, '127.0.0.1', 'unknown'),
(161, 35, '00f1157d9e65c3ab34e5c6c900b59ec53c781619fe67b6f90851ff64cedd5a02', '2026-05-04 08:06:47', '2026-05-04 09:06:47', '2026-05-04 08:06:47', NULL, '127.0.0.1', 'unknown'),
(162, 36, '8cdf624313f7e63575a0b272da0c7d8a116771079f44b1e64b9d7bd1ee36182a', '2026-05-04 08:08:50', '2026-05-04 09:08:50', '2026-05-04 08:08:50', NULL, '127.0.0.1', 'unknown'),
(163, 1, '8bf4ef0a5698f6825b2c3e45fef38b450a4417efe43cb4cfcd2dab02a4f6333e', '2026-05-04 08:12:16', '2026-05-04 09:12:16', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(164, 1, '2bbcdfd35ee4068e165a573e21eeade6bfe0ab4a889bd9f71ea056233cd69fa5', '2026-05-04 08:12:39', '2026-05-04 09:12:39', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(165, 1, '0abdacf2c87c317f26ba51283ca575979724d5511c06cb6bc2471f7cc90fc7f7', '2026-05-04 08:13:07', '2026-05-04 09:13:07', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(166, 1, 'ec307c99fa0bc57e810f7f509d9cf11776b8124ff339af401e551ca66da5ca78', '2026-05-04 08:17:58', '2026-05-04 09:17:58', '2026-05-04 08:23:10', '2026-05-04 08:23:42', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(167, 37, 'b7677c485b74223c7807369a86b1a7d59fe9c9a41b932f6b218cd63a0597c15c', '2026-05-04 08:24:08', '2026-05-04 09:24:08', '2026-05-04 08:36:15', '2026-05-04 08:36:23', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(168, 17, '29028b7b4cd3bc4b5380a5a847d741e9fd2ed75688f7d841e9dfe148a6a8ea7c', '2026-05-04 08:36:41', '2026-05-04 09:36:41', '2026-05-04 08:37:16', '2026-05-04 08:37:20', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(169, 1, 'c1b431cfee24eb6a26a22832fcc2f58e9aba1c1185018bba996d4b7b7344a7eb', '2026-05-04 08:37:44', '2026-05-04 09:37:44', '2026-05-04 08:51:02', '2026-05-04 08:51:09', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(170, 45, 'ed350bcc6054145d274262f5f1895f08052faec6ff5a26419b6cdcd7da6ca4b8', '2026-05-04 08:55:15', '2026-05-04 09:55:15', '2026-05-04 08:56:49', '2026-05-04 08:59:32', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(171, 8, '284080b07a579e4f36e99ae043cd0f825f895c0bfb01c956d8f1db8abd97c654', '2026-05-04 09:13:07', '2026-05-04 10:13:07', '2026-05-04 09:13:07', '2026-05-04 09:13:37', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(172, 7, 'bdd6b54fa94abc74a73c17e70295ccec1a1c498b4ba703dfd3ec3ea7aeaf4e0e', '2026-05-04 09:14:00', '2026-05-04 10:14:00', '2026-05-04 09:14:02', '2026-05-04 09:14:15', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(173, 7, '2190e5b8127601b8db6d0f00d3e997ba2fecae05ede883fa46680a1e8e36649a', '2026-05-04 09:19:00', '2026-05-04 10:19:00', '2026-05-04 09:19:00', '2026-05-04 09:19:02', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(174, 7, 'c139b92c37d282d02f10cc2b22648d678a702611ce8300677d421462e2e20331', '2026-05-04 09:19:22', '2026-05-04 10:19:22', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36');
INSERT INTO `user_tokens` (`id`, `user_id`, `token_hash`, `created_at`, `expires_at`, `last_used_at`, `revoked_at`, `ip`, `user_agent`) VALUES
(175, 17, 'be20c47b57f3f4453866ab353a5fc68f6d12ad3607517800511a7b122bb9843e', '2026-05-04 09:19:32', '2026-05-04 10:19:32', '2026-05-04 09:19:32', '2026-05-04 09:20:04', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(176, 7, '67329c13cf79eaf87df40bea791536a68b23889db7df996dd6f40563d452babc', '2026-05-04 10:02:05', '2026-05-04 11:02:05', '2026-05-04 10:02:05', '2026-05-04 10:06:24', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(177, 1, 'ba9febe307f450d52cfa544dd6ab647f751f42ce99286f10336062e0461f11fd', '2026-05-04 10:40:44', '2026-05-04 11:40:44', '2026-05-04 10:40:44', '2026-05-04 10:41:26', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(178, 17, '27b9d4a8557d31166b221e938ed8ab9905b448d8ad7b307ff7413d0104eda938', '2026-05-04 10:41:43', '2026-05-04 11:41:43', '2026-05-04 10:41:43', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
(179, 37, '7a841c68d9c01600e639af9979d5a325be1549c7e23fb1aed68aeea6a1818b80', '2026-05-04 10:43:03', '2026-05-04 11:43:03', '2026-05-04 10:45:26', '2026-05-04 10:52:37', '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36');

-- --------------------------------------------------------

--
-- Table structure for table `vacancies`
--

CREATE TABLE `vacancies` (
  `id` int(11) NOT NULL,
  `title` varchar(180) NOT NULL,
  `description` text NOT NULL,
  `requirements` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vacancies`
--

INSERT INTO `vacancies` (`id`, `title`, `description`, `requirements`, `is_active`, `created_at`) VALUES
(1, 'Laboratory Nurse (Home Visits)', 'Schedule-based home sampling, patient care, strict hygiene.', '2+ years experience\nCommunication skills\nCertificate is a plus', 1, '2026-02-17 14:18:52'),
(2, 'Reception / Call Center Operator', '24/7 shifts, call routing, appointment confirmations.', 'Good Uzbek/Russian\nCalm under pressure\nBasic computer skills', 1, '2026-02-17 14:18:52'),
(3, 'Data Analyst', 'Analyze data and generate reports', 'Strong SQL, Excel, and Python skills,yes', 1, '2026-02-21 12:43:00');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ambulance_requests`
--
ALTER TABLE `ambulance_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_slot` (`doctor_id`,`appointment_date`,`time_slot`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `callback_requests`
--
ALTER TABLE `callback_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`id`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `doctor_patient_notes`
--
ALTER TABLE `doctor_patient_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `doctor_user_id` (`doctor_user_id`);

--
-- Indexes for table `lab_results`
--
ALTER TABLE `lab_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `receipt_id` (`receipt_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `trusted_devices`
--
ALTER TABLE `trusted_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_device` (`user_id`,`device_hash`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_otps`
--
ALTER TABLE `user_otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email` (`email`),
  ADD KEY `purpose` (`purpose`);

--
-- Indexes for table `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_token_hash` (`token_hash`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `vacancies`
--
ALTER TABLE `vacancies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_vacancy_title` (`title`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ambulance_requests`
--
ALTER TABLE `ambulance_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `callback_requests`
--
ALTER TABLE `callback_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `doctor_patient_notes`
--
ALTER TABLE `doctor_patient_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `lab_results`
--
ALTER TABLE `lab_results`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `trusted_devices`
--
ALTER TABLE `trusted_devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `user_otps`
--
ALTER TABLE `user_otps`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `user_tokens`
--
ALTER TABLE `user_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=180;

--
-- AUTO_INCREMENT for table `vacancies`
--
ALTER TABLE `vacancies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`);

--
-- Constraints for table `doctors`
--
ALTER TABLE `doctors`
  ADD CONSTRAINT `doctors_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`);

--
-- Constraints for table `doctor_patient_notes`
--
ALTER TABLE `doctor_patient_notes`
  ADD CONSTRAINT `doctor_patient_notes_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `doctor_patient_notes_ibfk_2` FOREIGN KEY (`doctor_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `lab_results`
--
ALTER TABLE `lab_results`
  ADD CONSTRAINT `lab_results_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `trusted_devices`
--
ALTER TABLE `trusted_devices`
  ADD CONSTRAINT `trusted_devices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD CONSTRAINT `user_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
