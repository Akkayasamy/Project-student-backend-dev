-- =========================================================
-- Student Management System — Seed Data
-- Creates the schema (if not already created) AND fills it
-- with sample users + students so you can log in and see
-- data immediately.
--
-- Run with:
--   mysql -u root -p < sql/seed.sql
--   (or, on RDS)  mysql -h <rds-endpoint> -u admin -p < sql/seed.sql
-- =========================================================

CREATE DATABASE IF NOT EXISTS student;
USE student;

-- ---------- Schema (safe to re-run) ----------
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  phone VARCHAR(20),
  course VARCHAR(150),
  enrollment_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- (index on students.user_id is created by sql/schema.sql; skipped here
--  since MySQL's CREATE INDEX doesn't support IF NOT EXISTS)

-- ---------- Clear old sample data (safe re-run) ----------
DELETE FROM students WHERE user_id IN (
  SELECT id FROM (SELECT id FROM users WHERE email IN
    ('admin@ledger.edu', 'priya.sharma@ledger.edu', 'demo@ledger.edu')) AS tmp
);
DELETE FROM users WHERE email IN
  ('admin@ledger.edu', 'priya.sharma@ledger.edu', 'demo@ledger.edu');

-- ---------- Sample users ----------
-- Password for admin@ledger.edu and priya.sharma@ledger.edu is:  password123
-- Password for demo@ledger.edu is:                               demo1234
-- (These are real bcrypt hashes — you can log in with these right away.)
INSERT INTO users (name, email, password) VALUES
('Admin User',      'admin@ledger.edu',        '$2b$10$Y6DauNcNmV10n04ZVBO2AOfzUrLRf./8w79e3TGex.TGyRnF0MrsO'),
('Priya Sharma',    'priya.sharma@ledger.edu', '$2b$10$Y6DauNcNmV10n04ZVBO2AOfzUrLRf./8w79e3TGex.TGyRnF0MrsO'),
('Demo Account',    'demo@ledger.edu',         '$2b$10$QAGdj77xdNxcUp7CzQC5L.YQD4Y0HuWnlBSmC8BCM3biaI.VA7l5e');

-- ---------- Sample students for Admin User ----------
INSERT INTO students (user_id, first_name, last_name, email, phone, course, enrollment_date)
SELECT id, 'Aarav', 'Mehta', 'aarav.mehta@example.com', '9876500001', 'Computer Science', '2024-06-15' FROM users WHERE email = 'admin@ledger.edu'
UNION ALL
SELECT id, 'Diya', 'Kapoor', 'diya.kapoor@example.com', '9876500002', 'Electronics Engineering', '2024-07-01' FROM users WHERE email = 'admin@ledger.edu'
UNION ALL
SELECT id, 'Rohan', 'Verma', 'rohan.verma@example.com', '9876500003', 'Computer Science', '2024-06-20' FROM users WHERE email = 'admin@ledger.edu'
UNION ALL
SELECT id, 'Ananya', 'Iyer', 'ananya.iyer@example.com', '9876500004', 'Mechanical Engineering', '2023-08-10' FROM users WHERE email = 'admin@ledger.edu'
UNION ALL
SELECT id, 'Kabir', 'Malhotra', 'kabir.malhotra@example.com', '9876500005', 'Business Administration', '2024-01-12' FROM users WHERE email = 'admin@ledger.edu'
UNION ALL
SELECT id, 'Ishita', 'Nair', 'ishita.nair@example.com', '9876500006', 'Computer Science', NOW() FROM users WHERE email = 'admin@ledger.edu';

-- ---------- Sample students for Priya Sharma ----------
INSERT INTO students (user_id, first_name, last_name, email, phone, course, enrollment_date)
SELECT id, 'Vivaan', 'Joshi', 'vivaan.joshi@example.com', '9876500007', 'Civil Engineering', '2024-03-05' FROM users WHERE email = 'priya.sharma@ledger.edu'
UNION ALL
SELECT id, 'Saanvi', 'Reddy', 'saanvi.reddy@example.com', '9876500008', 'Data Science', '2024-05-22' FROM users WHERE email = 'priya.sharma@ledger.edu'
UNION ALL
SELECT id, 'Arjun', 'Rao', 'arjun.rao@example.com', '9876500009', 'Business Administration', '2023-11-30' FROM users WHERE email = 'priya.sharma@ledger.edu'
UNION ALL
SELECT id, 'Meera', 'Pillai', 'meera.pillai@example.com', '9876500010', 'Data Science', NOW() FROM users WHERE email = 'priya.sharma@ledger.edu';

-- ---------- Sample students for Demo Account ----------
INSERT INTO students (user_id, first_name, last_name, email, phone, course, enrollment_date)
SELECT id, 'Neha', 'Bhatt', 'neha.bhatt@example.com', '9876500011', 'Computer Science', '2024-02-14' FROM users WHERE email = 'demo@ledger.edu'
UNION ALL
SELECT id, 'Karan', 'Chopra', 'karan.chopra@example.com', '9876500012', 'Electronics Engineering', '2024-04-18' FROM users WHERE email = 'demo@ledger.edu';

-- ---------- Quick check ----------
SELECT u.email AS logged_in_as, COUNT(s.id) AS student_count
FROM users u LEFT JOIN students s ON s.user_id = u.id
WHERE u.email IN ('admin@ledger.edu', 'priya.sharma@ledger.edu', 'demo@ledger.edu')
GROUP BY u.email;
