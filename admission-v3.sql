-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: May 21, 2026 at 07:17 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `admission-v3`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `role` enum('superadmin','admin','viewer') DEFAULT 'admin',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `username`, `password`, `full_name`, `email`, `role`, `last_login`, `created_at`) VALUES
(1, 'admin', '$2y$10$TqM/2r3yLblslMJo8ebGIu15NG7ME0DHD0VqswLCgidvksiahbkL2', 'System Administrator', 'admin@example.com', 'superadmin', '2026-05-21 13:32:57', '2026-02-04 11:05:56');

-- --------------------------------------------------------

--
-- Table structure for table `admission_campaigns`
--

CREATE TABLE `admission_campaigns` (
  `id` int(11) NOT NULL,
  `campaign_name` varchar(50) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admission_campaigns`
--

INSERT INTO `admission_campaigns` (`id`, `campaign_name`, `start_date`, `end_date`, `is_active`, `created_at`) VALUES
(1, 'Fall 2025', '2025-06-01', '2025-10-31', 1, '2026-05-20 16:28:20'),
(2, 'spring 2026', '2026-04-10', '2026-06-05', 1, '2026-05-20 16:31:09');

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_faqs`
--

CREATE TABLE `chatbot_faqs` (
  `id` int(11) NOT NULL,
  `category` enum('admission','fee','application','test','general') NOT NULL,
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `keywords` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chatbot_faqs`
--

INSERT INTO `chatbot_faqs` (`id`, `category`, `question`, `answer`, `keywords`, `is_active`, `created_at`) VALUES
(1, 'admission', 'What programs are offered?', 'We offer 4 BS programs: BSCS (Computer Science), BSAI (Artificial Intelligence), BSCyS (Cyber Security), and BSSE (Software Engineering). We also offer BBA and MBA programs.', 'programs,courses,offered,study,degree', 1, '2026-04-12 02:34:02'),
(2, 'admission', 'What is the admission deadline?', 'Admissions for Fall 2025 are open until August 31, 2025. Spring admissions close January 15, 2025. Apply early for best chances!', 'deadline,last date,closing,when,apply', 1, '2026-04-12 02:34:02'),
(3, 'admission', 'What are the eligibility criteria?', 'For BS programs: Minimum FSc/A-Levels with 50% marks or equivalent. For MBA: Bachelor degree with 2.0 GPA. CNIC/B-Form required for all applicants.', 'eligibility,criteria,requirement,qualify,minimum', 1, '2026-04-12 02:34:02'),
(4, 'admission', 'What is the test date?', 'Entrance tests are conducted every month. Once you submit your application, our team will schedule your test and notify you via WhatsApp and email.', 'test date,when is test,exam date,schedule', 1, '2026-04-12 02:34:02'),
(5, 'fee', 'What is the semester fee?', 'Semester fees vary by program: BSCS/BSAI/BSCyS/BSSE: PKR 45,000/semester. BBA: PKR 38,000/semester. MBA: PKR 55,000/semester. Fee can be paid in installments.', 'fee,fees,cost,price,how much,semester fee', 1, '2026-04-12 02:34:02'),
(6, 'fee', 'Is scholarship available?', 'Yes! We offer merit-based scholarships for students with 80%+ marks. Need-based scholarships are also available. Contact the admissions office for details.', 'scholarship,financial aid,discount,help,afford', 1, '2026-04-12 02:34:02'),
(7, 'fee', 'Are there any hostel facilities?', 'Yes, separate hostels for boys and girls are available. Hostel fee is PKR 8,000-12,000/month including meals. Limited seats available.', 'hostel,boarding,accommodation,stay', 1, '2026-04-12 02:34:02'),
(8, 'application', 'How to apply?', 'Apply online through our website: 1) Fill the inquiry form, 2) Our team will contact you, 3) Submit documents, 4) Appear for entrance test, 5) Get your admission letter!', 'apply,how,application,form,submit', 1, '2026-04-12 02:34:02'),
(9, 'application', 'How to check application status?', 'You can check your status by typing your Application ID in this chat. Example: just type your ID number and I will tell you your current status!', 'status,check,application,track,id', 1, '2026-04-12 02:34:02'),
(10, 'application', 'What documents are required?', 'Required documents: 1) Original Matric/FSc certificates, 2) CNIC/B-Form copy, 3) 4 passport photos, 4) Domicile certificate, 5) Character certificate from last institution.', 'documents,required,papers,certificates,needed', 1, '2026-04-12 02:34:02'),
(11, 'test', 'How to prepare for admission test?', 'The test covers: Mathematics (30%), English (20%), Subject-specific (40%), General Knowledge (10%). Study FSc/O-Level syllabus. Practice MCQs. 50 questions in 20 minutes.', 'prepare,study,tips,test,exam,how to', 1, '2026-04-12 02:34:02'),
(12, 'test', 'What is the test pattern?', 'Online test: 50 MCQs, 20 minutes, passing score 50%. Sections: Mathematics, English, Subject Knowledge, General Knowledge. Results announced same day!', 'pattern,format,test,mcq,questions,marks', 1, '2026-04-12 02:34:02'),
(13, 'test', 'Can I retake the test?', 'Yes, you can retake the test after 30 days if you do not pass. A small re-attempt fee of PKR 500 applies. Your best score will be considered.', 'retake,again,fail,second chance,retry', 1, '2026-04-12 02:34:02'),
(14, 'general', 'What are the timings?', 'University hours: Monday-Friday 8am-5pm, Saturday 9am-1pm. Admissions office: Monday-Saturday 9am-4pm. Online portal available 24/7.', 'timing,hours,open,close,when,office', 1, '2026-04-12 02:34:02'),
(15, 'general', 'Where is the university located?', 'Our main campus is located at University Road, City. Easily accessible by public transport. Google Maps link: [Ask our team for directions]', 'location,address,where,campus,map,directions', 1, '2026-04-12 02:34:02');

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_sessions`
--

CREATE TABLE `chatbot_sessions` (
  `id` int(11) NOT NULL,
  `session_id` varchar(100) NOT NULL,
  `messages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`messages`)),
  `lead_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `communications`
--

CREATE TABLE `communications` (
  `id` int(11) NOT NULL,
  `lead_id` int(11) DEFAULT NULL,
  `type` enum('email','whatsapp','sms','call') NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` enum('sent','delivered','read','failed') DEFAULT 'sent',
  `sent_by` int(11) DEFAULT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `communications`
--

INSERT INTO `communications` (`id`, `lead_id`, `type`, `subject`, `message`, `status`, `sent_by`, `sent_at`) VALUES
(18, 92, 'whatsapp', 'Application Received', 'Admission confirmation template sent', 'sent', NULL, '2026-02-23 17:22:40'),
(21, 96, 'whatsapp', 'Application Received', 'Admission confirmation template sent', 'sent', NULL, '2026-03-04 02:28:30'),
(22, 97, 'whatsapp', 'Application Received', 'Admission confirmation template sent', 'sent', NULL, '2026-03-04 02:29:49'),
(23, 200, 'email', 'Welcome to NUT', 'Application received', 'sent', NULL, '2026-04-24 08:21:50'),
(24, 200, 'whatsapp', 'Admission Confirmation', 'Your application is received', 'sent', NULL, '2026-04-24 08:21:50'),
(25, 201, 'email', 'Welcome to NUT', 'Application received', 'sent', NULL, '2026-04-24 08:21:50'),
(26, 202, 'whatsapp', 'Test Schedule', 'Your test is scheduled', 'sent', NULL, '2026-04-24 08:21:50'),
(27, 203, 'email', 'Test Schedule', 'Your test is on...', 'sent', NULL, '2026-04-24 08:21:50'),
(28, 204, 'whatsapp', 'Test Result', 'Congratulations! You passed', 'sent', NULL, '2026-04-24 08:21:50'),
(29, 205, 'whatsapp', 'Test Result', 'Unfortunately you did not pass', 'sent', NULL, '2026-04-24 08:21:50'),
(30, 206, 'email', 'Selection Letter', 'Congratulations! You are selected', 'sent', NULL, '2026-04-24 08:21:50'),
(31, 207, 'whatsapp', 'Enrollment Confirmation', 'Welcome to NUT!', 'sent', NULL, '2026-04-24 08:21:50'),
(32, 208, 'email', 'Application Status', 'Application rejected', 'sent', NULL, '2026-04-24 08:21:50');

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `id` int(11) NOT NULL,
  `lead_id` int(11) NOT NULL,
  `program` enum('bscs','bsai','bscys','bsse') DEFAULT NULL,
  `aggregate` decimal(5,2) DEFAULT NULL,
  `merit_rank` int(11) DEFAULT NULL,
  `offer_sent_at` timestamp NULL DEFAULT NULL,
  `offer_confirmed_at` timestamp NULL DEFAULT NULL,
  `enrollment_status` enum('offer_sent','confirmed','declined','expired') DEFAULT 'offer_sent',
  `documents_submitted` tinyint(1) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leads`
--

CREATE TABLE `leads` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `cnic` varchar(15) DEFAULT NULL,
  `father_name` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `education` varchar(100) DEFAULT NULL,
  `academic_percentage` decimal(5,2) DEFAULT NULL,
  `passing_year` int(11) DEFAULT NULL,
  `board_name` varchar(50) DEFAULT NULL,
  `board_reg_no` varchar(50) DEFAULT NULL,
  `board_roll_no` varchar(50) DEFAULT NULL,
  `board_verified` tinyint(1) DEFAULT 0,
  `nts_reg_no` varchar(50) DEFAULT NULL,
  `nts_roll_no` varchar(50) DEFAULT NULL,
  `nts_verified` tinyint(1) DEFAULT 0,
  `nts_score` decimal(5,2) DEFAULT NULL,
  `aggregate` decimal(5,2) DEFAULT NULL,
  `interested_program` varchar(100) DEFAULT NULL,
  `source` varchar(50) DEFAULT 'website',
  `utm_campaign` varchar(100) DEFAULT NULL,
  `utm_medium` varchar(100) DEFAULT NULL,
  `status` enum('new','contacted','applied','test_scheduled','test_completed','selected','enrolled','rejected','absent') DEFAULT 'new',
  `test_status` enum('pending','scheduled','passed','failed','absent') DEFAULT 'pending',
  `score` int(11) DEFAULT 0,
  `test_score` int(11) DEFAULT 0,
  `test_date` date DEFAULT NULL,
  `test_type` enum('online','external') DEFAULT NULL,
  `test_roll_number` varchar(50) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `dob` date DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `test_sent` tinyint(4) DEFAULT 0,
  `test_sent_date` datetime DEFAULT NULL,
  `test_reschedule_count` int(11) DEFAULT 0,
  `test_absent_notified` tinyint(4) DEFAULT 0,
  `last_test_notification_sent` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `leads`
--

INSERT INTO `leads` (`id`, `full_name`, `email`, `phone`, `cnic`, `father_name`, `address`, `education`, `academic_percentage`, `passing_year`, `board_name`, `board_reg_no`, `board_roll_no`, `board_verified`, `nts_reg_no`, `nts_roll_no`, `nts_verified`, `nts_score`, `aggregate`, `interested_program`, `source`, `utm_campaign`, `utm_medium`, `status`, `test_status`, `score`, `test_score`, `test_date`, `test_type`, `test_roll_number`, `notes`, `created_at`, `updated_at`, `dob`, `profile_picture`, `test_sent`, `test_sent_date`, `test_reschedule_count`, `test_absent_notified`, `last_test_notification_sent`) VALUES
(92, 'ali', 'ali@gmail.com', '03318228117', '3230381070361', 'khan', 'dfdf', 'bachelor', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bsse', 'twitter', NULL, NULL, 'new', 'scheduled', 0, 0, '2026-02-25', NULL, 'T20260092', NULL, '2026-02-23 17:22:31', '2026-02-23 17:23:27', NULL, NULL, 0, NULL, 0, 0, NULL),
(96, 'Abdul Rehman', 'umerhayat.ghussain@gmail.com', '+923015066143', '3230381070421', 'Hayat', 'Css2', 'a-levels', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bsse', 'newspaper', NULL, NULL, 'test_scheduled', 'scheduled', 0, 0, NULL, 'online', 'OT20260096', NULL, '2026-03-04 02:28:24', '2026-05-21 13:42:38', NULL, NULL, 1, '2026-05-21 18:42:38', 0, 0, NULL),
(97, 'Humail', 'tanveerulhaq567@yahoo.com', '+923015066143', '3230381070361', 'Tanveer', 'css3', 'fsc', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bsee', 'instagram', NULL, NULL, 'test_scheduled', 'scheduled', 0, 0, NULL, 'online', 'OT20260097', NULL, '2026-03-04 02:29:41', '2026-05-21 13:42:43', NULL, NULL, 1, '2026-05-21 18:42:43', 0, 0, NULL),
(200, 'Ahmed Raza', 'ahmed@test.com', '03001234567', '12345-1234567-1', 'Raza Ahmed', 'Islamabad', 'Fsc', 78.50, 2024, 'FBISE', NULL, '123456', 0, NULL, NULL, 0, NULL, 76.75, 'bscs', 'facebook', NULL, NULL, 'new', 'passed', 10, 75, NULL, NULL, NULL, NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:43', NULL, NULL, 0, NULL, 0, 0, NULL),
(201, 'Sara Khan', 'sara@test.com', '03011234567', '12345-1234567-2', 'Khan Ahmed', 'Rawalpindi', 'Fsc', 82.00, 2024, 'BISE Lahore', NULL, '789012', 0, NULL, NULL, 0, NULL, 63.50, 'bsai', 'instagram', NULL, NULL, 'contacted', 'failed', 15, 45, NULL, NULL, NULL, NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:43', NULL, NULL, 0, NULL, 0, 0, NULL),
(202, 'Bilal Hussain', 'bilal@test.com', '03021234567', '12345-1234567-3', 'Hussain Ali', 'Lahore', 'ICS', 75.00, 2024, 'BISE Lahore', NULL, '345678', 0, NULL, NULL, 0, NULL, 72.50, 'bscys', 'website', NULL, NULL, 'applied', 'passed', 20, 70, NULL, NULL, NULL, NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:43', NULL, NULL, 0, NULL, 0, 0, NULL),
(203, 'Fatima Zafar', 'fatima@test.com', '03031234567', '12345-1234567-4', 'Zafar Ali', 'Karachi', 'Fsc', 88.00, 2024, 'BISE Karachi', NULL, '901234', 0, NULL, NULL, 0, NULL, NULL, 'bsse', 'facebook', NULL, NULL, 'absent', 'absent', 25, 0, '2026-05-01', 'external', 'T20260203', NULL, '2026-04-24 08:21:17', '2026-05-20 16:28:21', NULL, NULL, 0, NULL, 0, 0, NULL),
(204, 'Omar Farooq', 'omar@test.com', '03041234567', '12345-1234567-5', 'Farooq Ahmed', 'Multan', 'Fsc', 85.50, 2024, 'BISE Multan', NULL, '567890', 0, NULL, NULL, 0, NULL, 85.25, 'bscs', 'instagram', NULL, NULL, 'selected', 'passed', 30, 85, '2026-04-19', 'online', 'OT20260204', NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:30', NULL, NULL, 0, NULL, 0, 0, NULL),
(205, 'Zainab Akhtar', 'zainab@test.com', '03051234567', '12345-1234567-6', 'Akhtar Ali', 'Peshawar', 'Fsc', 68.00, 2024, 'BISE Peshawar', NULL, '123789', 0, NULL, NULL, 0, NULL, 55.00, 'bsai', 'youtube', NULL, NULL, 'applied', 'failed', 20, 42, '2026-04-21', 'online', 'OT20260205', NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:30', NULL, NULL, 0, NULL, 0, 0, NULL),
(206, 'Hamza Ali', 'hamza@test.com', '03061234567', '12345-1234567-7', 'Ali Raza', 'Quetta', 'A-Levels', 79.00, 2024, 'Cambridge', NULL, '456123', 0, NULL, NULL, 0, NULL, 78.50, 'bsse', 'twitter', NULL, NULL, 'selected', 'passed', 35, 78, '2026-04-22', 'online', 'OT20260206', NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:30', NULL, NULL, 0, NULL, 0, 0, NULL),
(207, 'Ayesha Naeem', 'ayesha@test.com', '03071234567', '12345-1234567-8', 'Naeem Ahmed', 'Islamabad', 'Fsc', 91.00, 2024, 'FBISE', NULL, '789456', 0, NULL, NULL, 0, NULL, 91.50, 'bscys', 'friend', NULL, NULL, 'enrolled', 'passed', 50, 92, '2026-04-14', 'online', 'OT20260207', NULL, '2026-04-24 08:21:17', '2026-04-24 08:25:30', NULL, NULL, 0, NULL, 0, 0, NULL),
(208, 'Usman Chaudhry', 'usman@test.com', '03081234567', '12345-1234567-9', 'Chaudhry Ahmed', 'Gujranwala', 'Fsc', 55.00, 2024, 'BISE Gujranwala', NULL, '321654', 0, NULL, NULL, 0, NULL, NULL, 'bba', 'newspaper', NULL, NULL, 'rejected', 'failed', 5, 35, '2026-04-09', 'external', 'T20260208', NULL, '2026-04-24 08:21:17', '2026-04-24 08:21:17', NULL, NULL, 0, NULL, 0, 0, NULL),
(209, 'tanveer', 'tanveer.ulhaq5@gmail.com', '+923015066143', '3230381070361', 'Riaz', 'CHowk Sarwar Shaheed', 'Ics', 76.71, 2021, 'BISE DG Khan', NULL, '12223', 0, NULL, NULL, 0, NULL, NULL, 'bsai', 'website', NULL, NULL, 'selected', 'passed', 40, 83, NULL, 'online', 'OT20260209', NULL, '2026-04-24 08:48:02', '2026-04-24 09:40:00', NULL, NULL, 0, NULL, 0, 0, NULL),
(210, 'Test Week 1', 'week1@test.com', '03001111111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bscs', 'website', NULL, NULL, 'test_scheduled', 'failed', 0, 0, NULL, 'online', 'OT20260210', NULL, '2026-05-19 16:33:01', '2026-05-21 13:52:57', NULL, NULL, 1, '2026-05-21 18:42:49', 0, 0, NULL),
(211, 'Test Week 2', 'week2@test.com', '03002222222', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bsai', 'website', NULL, NULL, 'test_scheduled', 'scheduled', 0, 0, NULL, 'online', 'OT20260211', NULL, '2026-05-17 16:33:01', '2026-05-21 13:42:55', NULL, NULL, 1, '2026-05-21 18:42:55', 0, 0, NULL),
(212, 'Test Week 3', 'week3@test.com', '03003333333', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bscys', 'website', NULL, NULL, 'test_scheduled', 'scheduled', 0, 0, NULL, 'online', 'OT20260212', NULL, '2026-05-15 16:33:01', '2026-05-21 13:43:01', NULL, NULL, 1, '2026-05-21 18:43:01', 0, 0, NULL),
(213, 'Test Week 4', 'week4@test.com', '03004444444', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, 'bsse', 'website', NULL, NULL, 'test_scheduled', 'scheduled', 0, 0, NULL, 'online', 'OT20260213', NULL, '2026-05-13 16:33:01', '2026-05-21 13:43:07', NULL, NULL, 1, '2026-05-21 18:43:07', 0, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `lead_interactions`
--

CREATE TABLE `lead_interactions` (
  `id` int(11) NOT NULL,
  `lead_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `action_type` enum('note','call','email','whatsapp','status_change','score_change','test_scheduled','result_sent') NOT NULL,
  `description` text NOT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lead_interactions`
--

INSERT INTO `lead_interactions` (`id`, `lead_id`, `admin_id`, `action_type`, `description`, `old_value`, `new_value`, `created_at`) VALUES
(65, 200, NULL, 'note', 'Lead created via Facebook', NULL, NULL, '2026-04-24 08:22:03'),
(66, 200, NULL, 'email', 'Welcome email sent', NULL, NULL, '2026-04-24 08:22:03'),
(67, 200, NULL, 'whatsapp', 'WA confirmation sent', NULL, NULL, '2026-04-24 08:22:03'),
(68, 201, NULL, 'note', 'Lead created via Instagram', NULL, NULL, '2026-04-24 08:22:03'),
(69, 201, NULL, 'status_change', 'Status changed to contacted', NULL, NULL, '2026-04-24 08:22:03'),
(70, 202, NULL, 'note', 'Documents verified', NULL, NULL, '2026-04-24 08:22:03'),
(71, 203, NULL, 'test_scheduled', 'External test scheduled', NULL, NULL, '2026-04-24 08:22:03'),
(72, 204, NULL, 'score_change', 'Test score: 85%', NULL, NULL, '2026-04-24 08:22:03'),
(73, 204, NULL, 'status_change', 'Status changed to selected', NULL, NULL, '2026-04-24 08:22:03'),
(74, 205, NULL, 'score_change', 'Test score: 42% (Failed)', NULL, NULL, '2026-04-24 08:22:03'),
(75, 206, NULL, 'status_change', 'Status changed to selected', NULL, NULL, '2026-04-24 08:22:03'),
(76, 207, NULL, 'status_change', 'Status changed to enrolled', NULL, NULL, '2026-04-24 08:22:03'),
(77, 208, NULL, 'status_change', 'Status changed to rejected', NULL, NULL, '2026-04-24 08:22:03'),
(78, 209, NULL, 'note', 'Lead created via website', NULL, NULL, '2026-04-24 08:48:02'),
(79, 209, NULL, 'note', 'Academic percentage: 76.71% (Board: BISE DG Khan, Roll: 12223)', NULL, NULL, '2026-04-24 08:48:02'),
(80, 209, NULL, 'email', 'Welcome email sent', NULL, NULL, '2026-04-24 08:48:07'),
(81, 209, NULL, 'whatsapp', 'WA confirmation sent', NULL, NULL, '2026-04-24 08:48:08'),
(82, 209, NULL, 'test_scheduled', 'Online test created. Roll: OT20260209', NULL, NULL, '2026-04-24 08:48:53'),
(83, 209, NULL, 'note', 'Online test done. Score: 83.33%. Result: passed', NULL, NULL, '2026-04-24 09:15:10'),
(84, 209, NULL, 'status_change', 'Status → selected', 'selected', 'selected', '2026-04-24 09:22:28'),
(85, 209, NULL, '', 'Merit offer sent. Deadline: 2026-05-01', NULL, NULL, '2026-04-24 09:35:53'),
(86, 209, NULL, '', 'Merit offer sent. Deadline: 2026-05-01', NULL, NULL, '2026-04-24 09:40:07'),
(87, 96, NULL, '', 'Test link sent', NULL, NULL, '2026-05-21 13:42:42'),
(88, 97, NULL, '', 'Test link sent', NULL, NULL, '2026-05-21 13:42:48'),
(89, 210, NULL, '', 'Test link sent', NULL, NULL, '2026-05-21 13:42:53'),
(90, 211, NULL, '', 'Test link sent', NULL, NULL, '2026-05-21 13:42:59'),
(91, 212, NULL, '', 'Test link sent', NULL, NULL, '2026-05-21 13:43:05'),
(92, 213, NULL, '', 'Test link sent', NULL, NULL, '2026-05-21 13:43:11'),
(93, 210, NULL, 'test_scheduled', 'Online test created. Roll: OT20260210', NULL, NULL, '2026-05-21 13:52:09');

-- --------------------------------------------------------

--
-- Table structure for table `online_tests`
--

CREATE TABLE `online_tests` (
  `id` int(11) NOT NULL,
  `lead_id` int(11) NOT NULL,
  `program` enum('bscs','bsai','bscys','bsse') NOT NULL,
  `roll_number` varchar(50) NOT NULL,
  `token` varchar(100) NOT NULL,
  `questions_json` longtext NOT NULL,
  `answers_json` text DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `total_marks` int(11) DEFAULT 50,
  `passing_marks` int(11) DEFAULT 25,
  `status` enum('pending','started','completed','expired','cheating') DEFAULT 'pending',
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `time_limit_minutes` int(11) DEFAULT 20,
  `tab_switches` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `online_tests`
--

INSERT INTO `online_tests` (`id`, `lead_id`, `program`, `roll_number`, `token`, `questions_json`, `answers_json`, `score`, `total_marks`, `passing_marks`, `status`, `started_at`, `completed_at`, `time_limit_minutes`, `tab_switches`, `created_at`) VALUES
(15, 204, 'bscs', 'OT20260204', 'test_token_204', '[]', '{}', 85.00, 50, 25, 'completed', '2026-04-19 08:21:33', '2026-04-19 08:21:33', 20, 0, '2026-04-24 08:21:33'),
(16, 205, 'bsai', 'OT20260205', 'test_token_205', '[]', '{}', 42.00, 50, 25, 'completed', '2026-04-21 08:21:33', '2026-04-21 08:21:33', 20, 0, '2026-04-24 08:21:33'),
(17, 206, 'bsse', 'OT20260206', 'test_token_206', '[]', '{}', 78.00, 50, 25, 'completed', '2026-04-22 08:21:33', '2026-04-22 08:21:33', 20, 0, '2026-04-24 08:21:33'),
(18, 207, 'bscys', 'OT20260207', 'test_token_207', '[]', '{}', 92.00, 50, 25, 'completed', '2026-04-14 08:21:33', '2026-04-14 08:21:33', 20, 0, '2026-04-24 08:21:33'),
(19, 209, 'bsai', 'OT20260209', '56bc6b3c44d584a3c7c6aaff1b5c15011da592537eb200b8832852e9cacdbd84', '[{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"14\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"Supervised learning requires?\",\"option_a\":\"Labeled data\",\"option_b\":\"Unlabeled data\",\"option_c\":\"No data\",\"option_d\":\"Random data\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"9\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"What is Machine Learning?\",\"option_a\":\"Programming computers to follow rules\",\"option_b\":\"Teaching computers to learn from data\",\"option_c\":\"A type of computer hardware\",\"option_d\":\"None of these\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"10\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"Which algorithm is used for classification?\",\"option_a\":\"Linear Regression\",\"option_b\":\"K-Means\",\"option_c\":\"Decision Tree\",\"option_d\":\"All of above\",\"correct_answer\":\"c\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"12\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"What does NLP stand for?\",\"option_a\":\"Natural Language Processing\",\"option_b\":\"Network Layer Protocol\",\"option_c\":\"Neural Learning Process\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"11\",\"program\":\"bsai\",\"subject\":\"Mathematics\",\"question_text\":\"What is a neural network inspired by?\",\"option_a\":\"Human brain\",\"option_b\":\"Computer circuits\",\"option_c\":\"Electrical networks\",\"option_d\":\"Mathematical functions\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"16\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"Deep learning uses?\",\"option_a\":\"Shallow networks\",\"option_b\":\"Deep neural networks\",\"option_c\":\"Decision trees\",\"option_d\":\"Linear models\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"15\",\"program\":\"bsai\",\"subject\":\"Statistics\",\"question_text\":\"What is standard deviation?\",\"option_a\":\"Mean of data\",\"option_b\":\"Measure of spread\",\"option_c\":\"Maximum value\",\"option_d\":\"Minimum value\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"13\",\"program\":\"bsai\",\"subject\":\"Mathematics\",\"question_text\":\"Which activation function outputs values 0 to 1?\",\"option_a\":\"ReLU\",\"option_b\":\"Sigmoid\",\"option_c\":\"Tanh\",\"option_d\":\"Linear\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', '{\"9\":\"b\",\"10\":\"d\",\"11\":\"a\",\"12\":\"a\",\"13\":\"b\",\"14\":\"a\",\"15\":\"a\",\"16\":\"b\",\"33\":\"b\",\"34\":\"c\",\"35\":\"c\",\"36\":\"c\",\"37\":\"b\",\"38\":\"c\",\"39\":\"a\",\"40\":\"b\",\"41\":\"b\",\"42\":\"b\"}', 83.33, 50, 25, 'completed', '2026-04-24 09:12:31', '2026-04-24 09:15:10', 20, 0, '2026-04-24 08:48:52'),
(20, 96, 'bsse', 'OT20260096', 'b0b6b2e3ceb2392f8b53d21971d3b3077ea86a6eb368b65ff319023f1e943c46', '[{\"id\":\"25\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What is SDLC?\",\"option_a\":\"Software Development Life Cycle\",\"option_b\":\"System Design Language Concept\",\"option_c\":\"Software Debugging Language Check\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"30\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What is refactoring?\",\"option_a\":\"Rewriting code from scratch\",\"option_b\":\"Improving code structure without changing behavior\",\"option_c\":\"Adding new features\",\"option_d\":\"Deleting old code\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"32\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"Which is NOT a design pattern?\",\"option_a\":\"Singleton\",\"option_b\":\"Factory\",\"option_c\":\"Observer\",\"option_d\":\"Compiler\",\"correct_answer\":\"d\",\"difficulty\":\"hard\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"28\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What does UML stand for?\",\"option_a\":\"Unified Modeling Language\",\"option_b\":\"Universal Machine Language\",\"option_c\":\"User Making Language\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"27\",\"program\":\"bsse\",\"subject\":\"Programming\",\"question_text\":\"What is version control?\",\"option_a\":\"A software version number\",\"option_b\":\"Managing code changes over time\",\"option_c\":\"Type of database\",\"option_d\":\"None\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"29\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What is unit testing?\",\"option_a\":\"Testing entire system\",\"option_b\":\"Testing individual components\",\"option_c\":\"Testing user interface\",\"option_d\":\"None\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"26\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"Which model is most flexible?\",\"option_a\":\"Waterfall\",\"option_b\":\"Agile\",\"option_c\":\"V-Model\",\"option_d\":\"Spiral\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"31\",\"program\":\"bsse\",\"subject\":\"Database\",\"question_text\":\"What is normalization?\",\"option_a\":\"Adding redundant data\",\"option_b\":\"Organizing database to reduce redundancy\",\"option_c\":\"Encrypting database\",\"option_d\":\"Backing up database\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', NULL, NULL, 50, 25, 'pending', NULL, NULL, 20, 0, '2026-05-21 13:42:38'),
(21, 97, '', 'OT20260097', '691bba0a11356f48c00fe69bdcc8f1625238090390ecae0ff54fccd09be27101', '[{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', NULL, NULL, 50, 25, 'pending', NULL, NULL, 20, 0, '2026-05-21 13:42:43'),
(23, 211, 'bsai', 'OT20260211', '7f8d7bd9d280a5412d2b30dd08670b1c20fd0ee9cd437c151678d6e15332cf9e', '[{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"12\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"What does NLP stand for?\",\"option_a\":\"Natural Language Processing\",\"option_b\":\"Network Layer Protocol\",\"option_c\":\"Neural Learning Process\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"13\",\"program\":\"bsai\",\"subject\":\"Mathematics\",\"question_text\":\"Which activation function outputs values 0 to 1?\",\"option_a\":\"ReLU\",\"option_b\":\"Sigmoid\",\"option_c\":\"Tanh\",\"option_d\":\"Linear\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"11\",\"program\":\"bsai\",\"subject\":\"Mathematics\",\"question_text\":\"What is a neural network inspired by?\",\"option_a\":\"Human brain\",\"option_b\":\"Computer circuits\",\"option_c\":\"Electrical networks\",\"option_d\":\"Mathematical functions\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"10\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"Which algorithm is used for classification?\",\"option_a\":\"Linear Regression\",\"option_b\":\"K-Means\",\"option_c\":\"Decision Tree\",\"option_d\":\"All of above\",\"correct_answer\":\"c\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"14\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"Supervised learning requires?\",\"option_a\":\"Labeled data\",\"option_b\":\"Unlabeled data\",\"option_c\":\"No data\",\"option_d\":\"Random data\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"9\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"What is Machine Learning?\",\"option_a\":\"Programming computers to follow rules\",\"option_b\":\"Teaching computers to learn from data\",\"option_c\":\"A type of computer hardware\",\"option_d\":\"None of these\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"15\",\"program\":\"bsai\",\"subject\":\"Statistics\",\"question_text\":\"What is standard deviation?\",\"option_a\":\"Mean of data\",\"option_b\":\"Measure of spread\",\"option_c\":\"Maximum value\",\"option_d\":\"Minimum value\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"16\",\"program\":\"bsai\",\"subject\":\"AI Basics\",\"question_text\":\"Deep learning uses?\",\"option_a\":\"Shallow networks\",\"option_b\":\"Deep neural networks\",\"option_c\":\"Decision trees\",\"option_d\":\"Linear models\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', NULL, NULL, 50, 25, 'pending', NULL, NULL, 20, 0, '2026-05-21 13:42:54'),
(24, 212, 'bscys', 'OT20260212', '2cc1dd2a905d7be402e03253425d6410a55b978c901e3b36f5a28efee5f1197d', '[{\"id\":\"23\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"What does CIA triad stand for?\",\"option_a\":\"Confidentiality, Integrity, Availability\",\"option_b\":\"Computer, Internet, Application\",\"option_c\":\"None\",\"option_d\":\"Central Intelligence Agency\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"24\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"What is two-factor authentication?\",\"option_a\":\"Password only\",\"option_b\":\"Two passwords\",\"option_c\":\"Password + another verification\",\"option_d\":\"Biometric only\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"21\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"Phishing is?\",\"option_a\":\"A fishing sport\",\"option_b\":\"Email fraud attack\",\"option_c\":\"Network protocol\",\"option_d\":\"None\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"20\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"What is a firewall?\",\"option_a\":\"A virus\",\"option_b\":\"Network security system\",\"option_c\":\"Hardware component\",\"option_d\":\"Programming language\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"18\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"What does VPN stand for?\",\"option_a\":\"Virtual Private Network\",\"option_b\":\"Very Personal Network\",\"option_c\":\"Virtual Public Network\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"17\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"What is encryption?\",\"option_a\":\"Deleting data\",\"option_b\":\"Converting data to unreadable format\",\"option_c\":\"Copying data\",\"option_d\":\"Sending data\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"19\",\"program\":\"bscys\",\"subject\":\"Security\",\"question_text\":\"SQL Injection is a type of?\",\"option_a\":\"Network attack\",\"option_b\":\"Database attack\",\"option_c\":\"Hardware failure\",\"option_d\":\"Software bug\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"22\",\"program\":\"bscys\",\"subject\":\"Networking\",\"question_text\":\"What is a port number?\",\"option_a\":\"IP address\",\"option_b\":\"Logical endpoint for communication\",\"option_c\":\"MAC address\",\"option_d\":\"Physical connector\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', NULL, NULL, 50, 25, 'pending', NULL, NULL, 20, 0, '2026-05-21 13:42:59'),
(25, 213, 'bsse', 'OT20260213', 'a652f98cf11d71a4185b7e2a59b613d913c3f58cd694a7cb5cb397cb3ddd7293', '[{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"32\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"Which is NOT a design pattern?\",\"option_a\":\"Singleton\",\"option_b\":\"Factory\",\"option_c\":\"Observer\",\"option_d\":\"Compiler\",\"correct_answer\":\"d\",\"difficulty\":\"hard\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"31\",\"program\":\"bsse\",\"subject\":\"Database\",\"question_text\":\"What is normalization?\",\"option_a\":\"Adding redundant data\",\"option_b\":\"Organizing database to reduce redundancy\",\"option_c\":\"Encrypting database\",\"option_d\":\"Backing up database\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"26\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"Which model is most flexible?\",\"option_a\":\"Waterfall\",\"option_b\":\"Agile\",\"option_c\":\"V-Model\",\"option_d\":\"Spiral\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"28\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What does UML stand for?\",\"option_a\":\"Unified Modeling Language\",\"option_b\":\"Universal Machine Language\",\"option_c\":\"User Making Language\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"27\",\"program\":\"bsse\",\"subject\":\"Programming\",\"question_text\":\"What is version control?\",\"option_a\":\"A software version number\",\"option_b\":\"Managing code changes over time\",\"option_c\":\"Type of database\",\"option_d\":\"None\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"30\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What is refactoring?\",\"option_a\":\"Rewriting code from scratch\",\"option_b\":\"Improving code structure without changing behavior\",\"option_c\":\"Adding new features\",\"option_d\":\"Deleting old code\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"29\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What is unit testing?\",\"option_a\":\"Testing entire system\",\"option_b\":\"Testing individual components\",\"option_c\":\"Testing user interface\",\"option_d\":\"None\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"25\",\"program\":\"bsse\",\"subject\":\"Engineering\",\"question_text\":\"What is SDLC?\",\"option_a\":\"Software Development Life Cycle\",\"option_b\":\"System Design Language Concept\",\"option_c\":\"Software Debugging Language Check\",\"option_d\":\"None\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', NULL, NULL, 50, 25, 'pending', NULL, NULL, 20, 0, '2026-05-21 13:43:06'),
(26, 210, 'bscs', 'OT20260210', 'a3a82801fa858d439ffb237d365aa090d7d64ebc8a38368daaff52104474d1c6', '[{\"id\":\"42\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Synonym of \\\"Eloquent\\\" is?\",\"option_a\":\"Silent\",\"option_b\":\"Fluent\",\"option_c\":\"Shy\",\"option_d\":\"Loud\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"4\",\"program\":\"bscs\",\"subject\":\"Mathematics\",\"question_text\":\"Binary of 15 in decimal is?\",\"option_a\":\"1010\",\"option_b\":\"1111\",\"option_c\":\"1001\",\"option_d\":\"1100\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"1\",\"program\":\"bscs\",\"subject\":\"Mathematics\",\"question_text\":\"What is the value of log\\u2082(64)?\",\"option_a\":\"4\",\"option_b\":\"6\",\"option_c\":\"8\",\"option_d\":\"5\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"5\",\"program\":\"bscs\",\"subject\":\"Programming\",\"question_text\":\"Which is an OOP language?\",\"option_a\":\"C\",\"option_b\":\"Python\",\"option_c\":\"Assembly\",\"option_d\":\"HTML\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"7\",\"program\":\"bscs\",\"subject\":\"Mathematics\",\"question_text\":\"What is O(n log n) complexity?\",\"option_a\":\"Constant\",\"option_b\":\"Polynomial\",\"option_c\":\"Logarithmic\",\"option_d\":\"Linearithmic\",\"correct_answer\":\"d\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"39\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"Area of circle with radius 7?\",\"option_a\":\"154\",\"option_b\":\"144\",\"option_c\":\"164\",\"option_d\":\"134\",\"correct_answer\":\"a\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"37\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Choose correct spelling:\",\"option_a\":\"Accomodate\",\"option_b\":\"Accommodate\",\"option_c\":\"Acommodate\",\"option_d\":\"Acomodate\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"40\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Number of provinces in Pakistan?\",\"option_a\":\"3\",\"option_b\":\"4\",\"option_c\":\"5\",\"option_d\":\"6\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"41\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is \\u221a144?\",\"option_a\":\"11\",\"option_b\":\"12\",\"option_c\":\"13\",\"option_d\":\"14\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"36\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"If x + 5 = 12, then x = ?\",\"option_a\":\"5\",\"option_b\":\"6\",\"option_c\":\"7\",\"option_d\":\"8\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"33\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Pakistan gained independence in?\",\"option_a\":\"1946\",\"option_b\":\"1947\",\"option_c\":\"1948\",\"option_d\":\"1945\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"38\",\"program\":\"all\",\"subject\":\"English\",\"question_text\":\"Antonym of \\\"Abundant\\\" is?\",\"option_a\":\"Plenty\",\"option_b\":\"Scarce\",\"option_c\":\"Ample\",\"option_d\":\"Rich\",\"correct_answer\":\"b\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"2\",\"program\":\"bscs\",\"subject\":\"Mathematics\",\"question_text\":\"Which data structure uses LIFO?\",\"option_a\":\"Queue\",\"option_b\":\"Stack\",\"option_c\":\"Tree\",\"option_d\":\"Graph\",\"correct_answer\":\"b\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"34\",\"program\":\"all\",\"subject\":\"General\",\"question_text\":\"Capital of Pakistan is?\",\"option_a\":\"Karachi\",\"option_b\":\"Lahore\",\"option_c\":\"Islamabad\",\"option_d\":\"Peshawar\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"35\",\"program\":\"all\",\"subject\":\"Mathematics\",\"question_text\":\"What is 15% of 200?\",\"option_a\":\"20\",\"option_b\":\"25\",\"option_c\":\"30\",\"option_d\":\"35\",\"correct_answer\":\"c\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"8\",\"program\":\"bscs\",\"subject\":\"Programming\",\"question_text\":\"Which keyword declares a variable in Python?\",\"option_a\":\"var\",\"option_b\":\"dim\",\"option_c\":\"let\",\"option_d\":\"No keyword needed\",\"correct_answer\":\"d\",\"difficulty\":\"medium\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"3\",\"program\":\"bscs\",\"subject\":\"Programming\",\"question_text\":\"What does HTML stand for?\",\"option_a\":\"Hyper Text Markup Language\",\"option_b\":\"High Text Markup Language\",\"option_c\":\"Hyper Transfer Markup Language\",\"option_d\":\"Hyper Text Making Language\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"},{\"id\":\"6\",\"program\":\"bscs\",\"subject\":\"Networking\",\"question_text\":\"What does IP stand for?\",\"option_a\":\"Internet Protocol\",\"option_b\":\"Internal Protocol\",\"option_c\":\"Intra Protocol\",\"option_d\":\"Interface Protocol\",\"correct_answer\":\"a\",\"difficulty\":\"easy\",\"marks\":\"1\",\"is_active\":\"1\",\"created_at\":\"2026-04-12 07:34:02\"}]', NULL, NULL, 50, 25, 'cheating', '2026-05-21 13:52:18', NULL, 20, 3, '2026-05-21 13:52:08');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` int(11) NOT NULL,
  `program` enum('bscs','bsai','bscys','bsse','all') NOT NULL,
  `subject` varchar(100) NOT NULL,
  `question_text` text NOT NULL,
  `option_a` varchar(500) NOT NULL,
  `option_b` varchar(500) NOT NULL,
  `option_c` varchar(500) NOT NULL,
  `option_d` varchar(500) NOT NULL,
  `correct_answer` enum('a','b','c','d') NOT NULL,
  `difficulty` enum('easy','medium','hard') DEFAULT 'medium',
  `marks` int(11) DEFAULT 1,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`id`, `program`, `subject`, `question_text`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_answer`, `difficulty`, `marks`, `is_active`, `created_at`) VALUES
(1, 'bscs', 'Mathematics', 'What is the value of log₂(64)?', '4', '6', '8', '5', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(2, 'bscs', 'Mathematics', 'Which data structure uses LIFO?', 'Queue', 'Stack', 'Tree', 'Graph', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(3, 'bscs', 'Programming', 'What does HTML stand for?', 'Hyper Text Markup Language', 'High Text Markup Language', 'Hyper Transfer Markup Language', 'Hyper Text Making Language', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(4, 'bscs', 'Mathematics', 'Binary of 15 in decimal is?', '1010', '1111', '1001', '1100', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(5, 'bscs', 'Programming', 'Which is an OOP language?', 'C', 'Python', 'Assembly', 'HTML', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(6, 'bscs', 'Networking', 'What does IP stand for?', 'Internet Protocol', 'Internal Protocol', 'Intra Protocol', 'Interface Protocol', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(7, 'bscs', 'Mathematics', 'What is O(n log n) complexity?', 'Constant', 'Polynomial', 'Logarithmic', 'Linearithmic', 'd', 'medium', 1, 1, '2026-04-12 02:34:02'),
(8, 'bscs', 'Programming', 'Which keyword declares a variable in Python?', 'var', 'dim', 'let', 'No keyword needed', 'd', 'medium', 1, 1, '2026-04-12 02:34:02'),
(9, 'bsai', 'AI Basics', 'What is Machine Learning?', 'Programming computers to follow rules', 'Teaching computers to learn from data', 'A type of computer hardware', 'None of these', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(10, 'bsai', 'AI Basics', 'Which algorithm is used for classification?', 'Linear Regression', 'K-Means', 'Decision Tree', 'All of above', 'c', 'medium', 1, 1, '2026-04-12 02:34:02'),
(11, 'bsai', 'Mathematics', 'What is a neural network inspired by?', 'Human brain', 'Computer circuits', 'Electrical networks', 'Mathematical functions', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(12, 'bsai', 'AI Basics', 'What does NLP stand for?', 'Natural Language Processing', 'Network Layer Protocol', 'Neural Learning Process', 'None', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(13, 'bsai', 'Mathematics', 'Which activation function outputs values 0 to 1?', 'ReLU', 'Sigmoid', 'Tanh', 'Linear', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(14, 'bsai', 'AI Basics', 'Supervised learning requires?', 'Labeled data', 'Unlabeled data', 'No data', 'Random data', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(15, 'bsai', 'Statistics', 'What is standard deviation?', 'Mean of data', 'Measure of spread', 'Maximum value', 'Minimum value', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(16, 'bsai', 'AI Basics', 'Deep learning uses?', 'Shallow networks', 'Deep neural networks', 'Decision trees', 'Linear models', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(17, 'bscys', 'Security', 'What is encryption?', 'Deleting data', 'Converting data to unreadable format', 'Copying data', 'Sending data', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(18, 'bscys', 'Security', 'What does VPN stand for?', 'Virtual Private Network', 'Very Personal Network', 'Virtual Public Network', 'None', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(19, 'bscys', 'Security', 'SQL Injection is a type of?', 'Network attack', 'Database attack', 'Hardware failure', 'Software bug', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(20, 'bscys', 'Security', 'What is a firewall?', 'A virus', 'Network security system', 'Hardware component', 'Programming language', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(21, 'bscys', 'Security', 'Phishing is?', 'A fishing sport', 'Email fraud attack', 'Network protocol', 'None', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(22, 'bscys', 'Networking', 'What is a port number?', 'IP address', 'Logical endpoint for communication', 'MAC address', 'Physical connector', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(23, 'bscys', 'Security', 'What does CIA triad stand for?', 'Confidentiality, Integrity, Availability', 'Computer, Internet, Application', 'None', 'Central Intelligence Agency', 'a', 'medium', 1, 1, '2026-04-12 02:34:02'),
(24, 'bscys', 'Security', 'What is two-factor authentication?', 'Password only', 'Two passwords', 'Password + another verification', 'Biometric only', 'c', 'easy', 1, 1, '2026-04-12 02:34:02'),
(25, 'bsse', 'Engineering', 'What is SDLC?', 'Software Development Life Cycle', 'System Design Language Concept', 'Software Debugging Language Check', 'None', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(26, 'bsse', 'Engineering', 'Which model is most flexible?', 'Waterfall', 'Agile', 'V-Model', 'Spiral', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(27, 'bsse', 'Programming', 'What is version control?', 'A software version number', 'Managing code changes over time', 'Type of database', 'None', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(28, 'bsse', 'Engineering', 'What does UML stand for?', 'Unified Modeling Language', 'Universal Machine Language', 'User Making Language', 'None', 'a', 'easy', 1, 1, '2026-04-12 02:34:02'),
(29, 'bsse', 'Engineering', 'What is unit testing?', 'Testing entire system', 'Testing individual components', 'Testing user interface', 'None', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(30, 'bsse', 'Engineering', 'What is refactoring?', 'Rewriting code from scratch', 'Improving code structure without changing behavior', 'Adding new features', 'Deleting old code', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(31, 'bsse', 'Database', 'What is normalization?', 'Adding redundant data', 'Organizing database to reduce redundancy', 'Encrypting database', 'Backing up database', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(32, 'bsse', 'Engineering', 'Which is NOT a design pattern?', 'Singleton', 'Factory', 'Observer', 'Compiler', 'd', 'hard', 1, 1, '2026-04-12 02:34:02'),
(33, 'all', 'General', 'Pakistan gained independence in?', '1946', '1947', '1948', '1945', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(34, 'all', 'General', 'Capital of Pakistan is?', 'Karachi', 'Lahore', 'Islamabad', 'Peshawar', 'c', 'easy', 1, 1, '2026-04-12 02:34:02'),
(35, 'all', 'Mathematics', 'What is 15% of 200?', '20', '25', '30', '35', 'c', 'easy', 1, 1, '2026-04-12 02:34:02'),
(36, 'all', 'Mathematics', 'If x + 5 = 12, then x = ?', '5', '6', '7', '8', 'c', 'easy', 1, 1, '2026-04-12 02:34:02'),
(37, 'all', 'English', 'Choose correct spelling:', 'Accomodate', 'Accommodate', 'Acommodate', 'Acomodate', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(38, 'all', 'English', 'Antonym of \"Abundant\" is?', 'Plenty', 'Scarce', 'Ample', 'Rich', 'b', 'medium', 1, 1, '2026-04-12 02:34:02'),
(39, 'all', 'Mathematics', 'Area of circle with radius 7?', '154', '144', '164', '134', 'a', 'medium', 1, 1, '2026-04-12 02:34:02'),
(40, 'all', 'General', 'Number of provinces in Pakistan?', '3', '4', '5', '6', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(41, 'all', 'Mathematics', 'What is √144?', '11', '12', '13', '14', 'b', 'easy', 1, 1, '2026-04-12 02:34:02'),
(42, 'all', 'English', 'Synonym of \"Eloquent\" is?', 'Silent', 'Fluent', 'Shy', 'Loud', 'b', 'medium', 1, 1, '2026-04-12 02:34:02');

-- --------------------------------------------------------

--
-- Table structure for table `seat_limits`
--

CREATE TABLE `seat_limits` (
  `id` int(11) NOT NULL,
  `program` varchar(20) NOT NULL,
  `campaign_name` varchar(50) NOT NULL DEFAULT 'Fall 2025',
  `total_seats` int(11) NOT NULL DEFAULT 0,
  `enrolled_count` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(4) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seat_limits`
--

INSERT INTO `seat_limits` (`id`, `program`, `campaign_name`, `total_seats`, `enrolled_count`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'bscs', 'Fall 2025', 60, 0, 1, '2026-05-20 16:28:20', '2026-05-20 16:28:20'),
(2, 'bsai', 'Fall 2025', 40, 0, 1, '2026-05-20 16:28:20', '2026-05-20 16:28:20'),
(3, 'bscys', 'Fall 2025', 40, 0, 1, '2026-05-20 16:28:20', '2026-05-20 16:28:20'),
(4, 'bsse', 'Fall 2025', 60, 0, 1, '2026-05-20 16:28:20', '2026-05-20 16:28:20');

-- --------------------------------------------------------

--
-- Table structure for table `test_reschedule_requests`
--

CREATE TABLE `test_reschedule_requests` (
  `id` int(11) NOT NULL,
  `lead_id` int(11) NOT NULL,
  `original_test_date` datetime DEFAULT NULL,
  `requested_date` datetime DEFAULT NULL,
  `status` enum('pending','approved','rejected','completed') DEFAULT 'pending',
  `new_test_link` varchar(500) DEFAULT NULL,
  `reschedule_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `admission_campaigns`
--
ALTER TABLE `admission_campaigns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `campaign_name` (`campaign_name`);

--
-- Indexes for table `chatbot_faqs`
--
ALTER TABLE `chatbot_faqs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chatbot_sessions`
--
ALTER TABLE `chatbot_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lead_id` (`lead_id`);

--
-- Indexes for table `communications`
--
ALTER TABLE `communications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lead_id` (`lead_id`),
  ADD KEY `sent_by` (`sent_by`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `leads`
--
ALTER TABLE `leads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `test_roll_number` (`test_roll_number`),
  ADD KEY `idx_test_status` (`test_status`),
  ADD KEY `idx_test_date` (`test_date`),
  ADD KEY `idx_test_sent` (`test_sent`),
  ADD KEY `idx_test_reschedule` (`test_reschedule_count`),
  ADD KEY `idx_test_absent_notified` (`test_absent_notified`);

--
-- Indexes for table `lead_interactions`
--
ALTER TABLE `lead_interactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `idx_lead_id` (`lead_id`);

--
-- Indexes for table `online_tests`
--
ALTER TABLE `online_tests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roll_number` (`roll_number`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `lead_id` (`lead_id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `seat_limits`
--
ALTER TABLE `seat_limits`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_program_campaign` (`program`,`campaign_name`);

--
-- Indexes for table `test_reschedule_requests`
--
ALTER TABLE `test_reschedule_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lead_id` (`lead_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `admission_campaigns`
--
ALTER TABLE `admission_campaigns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `chatbot_faqs`
--
ALTER TABLE `chatbot_faqs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `chatbot_sessions`
--
ALTER TABLE `chatbot_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `communications`
--
ALTER TABLE `communications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leads`
--
ALTER TABLE `leads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=214;

--
-- AUTO_INCREMENT for table `lead_interactions`
--
ALTER TABLE `lead_interactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `online_tests`
--
ALTER TABLE `online_tests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `seat_limits`
--
ALTER TABLE `seat_limits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `test_reschedule_requests`
--
ALTER TABLE `test_reschedule_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `chatbot_sessions`
--
ALTER TABLE `chatbot_sessions`
  ADD CONSTRAINT `chatbot_sessions_ibfk_1` FOREIGN KEY (`lead_id`) REFERENCES `leads` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `communications`
--
ALTER TABLE `communications`
  ADD CONSTRAINT `communications_ibfk_1` FOREIGN KEY (`lead_id`) REFERENCES `leads` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `communications_ibfk_2` FOREIGN KEY (`sent_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `lead_interactions`
--
ALTER TABLE `lead_interactions`
  ADD CONSTRAINT `lead_interactions_ibfk_1` FOREIGN KEY (`lead_id`) REFERENCES `leads` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lead_interactions_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `online_tests`
--
ALTER TABLE `online_tests`
  ADD CONSTRAINT `online_tests_ibfk_1` FOREIGN KEY (`lead_id`) REFERENCES `leads` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `test_reschedule_requests`
--
ALTER TABLE `test_reschedule_requests`
  ADD CONSTRAINT `test_reschedule_requests_ibfk_1` FOREIGN KEY (`lead_id`) REFERENCES `leads` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
