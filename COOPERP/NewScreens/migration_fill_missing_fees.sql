-- ================================================================
-- MIGRATION: Insert MISSING programmes into fin_programme_fees
-- 23 programmes in acad_programme had no fee structure entry
-- Maps each to the correct tier based on programme type
-- Date: 2026-03-24
-- ================================================================
USE campus_dynamics_accounts;

-- ================================================================
-- 1-YEAR CERTIFICATE: PSM (Procurement, like HEC T=400000)
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  is_active, created_by)
VALUES ('PSM', 'Yes', 'No', 'No',
  400000, 430000, 400000, 365000,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 2-YEAR CATCH-ALL: '-' (system placeholder, 1 student)
-- Uses standard bachelor tier T=630000 as safe default
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  is_active, created_by)
VALUES ('-', 'Yes', 'Yes', 'No',
  630000, 767000, 630000, 677000,
  630000, 687000, 630000, 653000,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 2-YEAR STANDARD DIPLOMAS: T=430000 (like DBA, DBM, DAF etc.)
-- AMS, BCP, DAB, DC, DM, DMPRT, DPR, DSS
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  is_active, created_by)
VALUES
('AMS', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('BCP', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('DAB', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('DC', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('DM', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('DMPRT', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('DPR', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION'),
('DSS', 'Yes', 'Yes', 'No',
  430000, 767000, 430000, 677000,
  430000, 687000, 430000, 733000,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 2-YEAR ART/PHOTOGRAPHY DIPLOMA: DP (like DAD T=530000)
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  is_active, created_by)
VALUES ('DP', 'Yes', 'Yes', 'No',
  530000, 985250, 530000, 895250,
  530000, 905250, 530000, 1151250,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 2-YEAR TECHNICAL DIPLOMA: DRAC (like DCE/DEE T=530000 engineering)
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  is_active, created_by)
VALUES ('DRAC', 'Yes', 'Yes', 'No',
  530000, 984500, 530000, 1094500,
  530000, 904500, 530000, 1150500,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 2-YEAR MASTERS: MPAM (like MBA T=1563500)
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  is_active, created_by)
VALUES ('MPAM', 'Yes', 'Yes', 'No',
  1563500, 914500, 1563500, 834500,
  1563500, 854500, 1563500, 834500,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 3-YEAR BACHELOR: Standard tier T=630000 (like BBA)
-- BGD, BOMT, HRP 1101
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  y3_s1_tuition, y3_s1_functional, y3_s2_tuition, y3_s2_functional,
  is_active, created_by)
VALUES
('BGD', 'Yes', 'Yes', 'Yes',
  630000, 767000, 630000, 677000,
  630000, 687000, 630000, 653000,
  630000, 663000, 630000, 933000,
  'Yes', 'SYSTEM_MIGRATION'),
('BOMT', 'Yes', 'Yes', 'Yes',
  630000, 767000, 630000, 677000,
  630000, 687000, 630000, 653000,
  630000, 663000, 630000, 933000,
  'Yes', 'SYSTEM_MIGRATION'),
('HRP 1101', 'Yes', 'Yes', 'Yes',
  630000, 767000, 630000, 677000,
  630000, 687000, 630000, 653000,
  630000, 663000, 630000, 933000,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- 4-YEAR ENGINEERING (unit codes in programme table): T=1455000
-- BCE3207, BEE1101, DCS1101, ECB1101, EMB1101, SDB1101, SEB1101
-- These look like unit codes, not programmes, but they exist
-- in acad_programme so they get fee structures for safety
-- ================================================================
INSERT INTO fin_programme_fees (progcode, has_year_1, has_year_2, has_year_3,
  y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional,
  y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional,
  y3_s1_tuition, y3_s1_functional, y3_s2_tuition, y3_s2_functional,
  is_active, created_by)
VALUES
('BCE3207', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION'),
('BEE1101', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION'),
('DCS1101', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION'),
('ECB1101', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION'),
('EMB1101', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION'),
('SDB1101', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION'),
('SEB1101', 'Yes', 'Yes', 'Yes',
  1455000, 1402000, 1455000, 1312000,
  1455000, 1402000, 1455000, 1488000,
  1455000, 1298000, 1455000, 1488000,
  'Yes', 'SYSTEM_MIGRATION');

-- ================================================================
-- VERIFICATION
-- ================================================================
SELECT 'INSERTION COMPLETE' AS status;

SELECT COUNT(*) AS total_fee_structures FROM fin_programme_fees;

SELECT 'STILL MISSING' AS check_type;

SELECT p.progcode, p.progname
FROM campus_dynamics.acad_programme p
LEFT JOIN fin_programme_fees f ON f.progcode = p.progcode
WHERE f.ID IS NULL
ORDER BY p.progcode;
