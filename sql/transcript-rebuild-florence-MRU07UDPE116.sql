-- =====================================================================
-- Reconstruct the full transcript of NANNYONDO FLORENCE
-- regno MRU07/U/DPE-II/116/INS  (DPE, 2007, Kakeeka, DAY) from OCR.
-- 35 courses, 2 years x 3 sessions. Marks published; CW 40 / Exam 60 split.
-- Code rule: use the OCR code when it is free or a placeholder (also fixes
-- that placeholder for everyone); when the code already carries a real title
-- used by others, use a "<code>R" reconstruction variant so NO shared catalog
-- entry is ever corrupted. Titles come from the OCR (authoritative).
-- =====================================================================
SET @R := 'MRU07/U/DPE-II/116/INS';

-- 0) Backups
DROP TABLE IF EXISTS campus_dynamics.florence_results_bak_20260806;
CREATE TABLE campus_dynamics.florence_results_bak_20260806 AS SELECT * FROM campus_dynamics.acad_results WHERE regno=@R;
DROP TABLE IF EXISTS campus_dynamics.florence_transcript_bak_20260806;
CREATE TABLE campus_dynamics.florence_transcript_bak_20260806 AS SELECT * FROM campus_dynamics.acad_transcript_results WHERE regno=@R;
DROP TABLE IF EXISTS campus_dynamics_portal.florence_coursereg_bak_20260806;
CREATE TABLE campus_dynamics_portal.florence_coursereg_bak_20260806 AS SELECT * FROM campus_dynamics_portal.acad_course_registration WHERE regno=@R;

-- 1) OCR source data
DROP TEMPORARY TABLE IF EXISTS _rec;
CREATE TEMPORARY TABLE _rec (sy INT, sem INT, acad CHAR(15), code CHAR(25), title VARCHAR(200), total INT, fcode CHAR(25));
INSERT INTO _rec (sy,sem,acad,code,title,total) VALUES
-- YEAR I  (2007/2008)
(1,1,'2007/2008','PEO1101','Indigenous Education and Formal Education (Primary)',64),
(1,1,'2007/2008','PEO1102','General Teaching-Learning Methods',82),
(1,1,'2007/2008','PEO1103','Human Growth and Development',64),
(1,1,'2007/2008','PEO1104','Human Learning',69),
(1,1,'2007/2008','PEO1105','Early Childhood Education',65),
(1,1,'2007/2008','PEO1106','Primary School Curriculum',70),
(1,1,'2007/2008','PEO1107','Primary Education Research',74),
(1,2,'2007/2008','DEF1201','Sociological Foundations of Education',74),
(1,2,'2007/2008','DEF1202','Contemporary Primary Education Systems',71),
(1,2,'2007/2008','DEL1201','Analysis and Assessment of Primary English Language Syllabus',56),
(1,2,'2007/2008','DEL1202','Introductory Language Study, Language Structure and Acquisition Skills Improvement',73),
(1,2,'2007/2008','DRE1201','Analysis and Assessment of Primary Religious Education',69),
(1,2,'2007/2008','DRE1202','Introduction to Christian Beliefs',72),
(1,2,'2007/2008','DRE1203','Introduction to Islam',81),
(1,3,'2007/2008','DEM1301','Introductory Educational Measurement and Evaluation',78),
(1,3,'2007/2008','DSP1301','School Practice (6 Weeks)',78),
(1,3,'2007/2008','DEL1301','Literature in Language Teaching',72),
(1,3,'2007/2008','DRE1301','African Traditional Religions',68),
(1,3,'2007/2008','DRE1302','Instructional Modes and Resources in Religious Education',74),
-- YEAR II (2008/2009)
(2,1,'2008/2009','DEF2101','Philosophical Foundations of Education',66),
(2,1,'2008/2009','DCU2101','Essentials of Educational Technology in Curriculum Design, Development and Implementation',67),
(2,1,'2008/2009','DEL2101','Language Study and Teaching',77),
(2,1,'2008/2009','DRE2101','The Structure of the Bible (Old Testament and New Testament)',69),
(2,1,'2008/2009','DRE2102','The Structure of the Quran',50),
(2,2,'2008/2009','DGC2201','Introduction to Guidance and Counselling in Primary School',76),
(2,2,'2008/2009','DEE2201','Professional Ethics in Education',62),
(2,2,'2008/2009','DEL2201','Literature and Language Teaching',61),
(2,2,'2008/2009','DRE2201','Introduction to Religious Ethics',73),
(2,2,'2008/2009','DRE2202','Themes in World Religions',71),
(2,3,'2008/2009','DEL2301','Language in Society and Skills Improvement',72),
(2,3,'2008/2009','DEL2302','Language Development in Primary Methodology',64),
(2,3,'2008/2009','DEM2301','Essentials of Educational Management and Administration',86),
(2,3,'2008/2009','DRE2301','Themes in General Church History',74),
(2,3,'2008/2009','DSP2301','School Practice',64),
(2,3,'2008/2009','DRE2302','Themes in History of Islam',71);

-- 2) Decide the final course code per the rule
UPDATE _rec x SET fcode = CASE
  WHEN NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_course c WHERE c.courseID=x.code) THEN x.code
  WHEN (SELECT IFNULL(TRIM(c.courseName),'') FROM campus_dynamics.acad_course c WHERE c.courseID=x.code) IN ('','-') THEN x.code
  WHEN (SELECT TRIM(c.courseName) FROM campus_dynamics.acad_course c WHERE c.courseID=x.code) = x.code THEN x.code
  ELSE CONCAT(x.code,'R') END;

-- 3) Catalog: create/fix the title for each final code (never touches a real shared title)
INSERT INTO campus_dynamics.acad_course (courseID, courseName, CreditUnit)
SELECT fcode, title, 2 FROM _rec
ON DUPLICATE KEY UPDATE courseName=VALUES(courseName);

-- 4) Rebuild acad_results
DELETE FROM campus_dynamics.acad_results WHERE regno=@R;
INSERT INTO campus_dynamics.acad_results (regno, courseid, semester, acad, studyyear, score, grade, gradept, CreditUnits, progid, is_retake)
SELECT @R, fcode, sem, acad, sy, total,
  CASE WHEN total>=80 THEN 'A' WHEN total>=75 THEN 'B+' WHEN total>=70 THEN 'B' WHEN total>=65 THEN 'C+'
       WHEN total>=60 THEN 'C' WHEN total>=55 THEN 'D+' WHEN total>=50 THEN 'D' ELSE 'F' END,
  CASE WHEN total>=80 THEN 5.0 WHEN total>=75 THEN 4.5 WHEN total>=70 THEN 4.0 WHEN total>=65 THEN 3.5
       WHEN total>=60 THEN 3.0 WHEN total>=55 THEN 2.5 WHEN total>=50 THEN 2.0 ELSE 0.0 END,
  2, 'DPE', 0
FROM _rec;

-- 5) Rebuild acad_transcript_results (what the transcript actually prints)
DELETE FROM campus_dynamics.acad_transcript_results WHERE regno=@R;
INSERT INTO campus_dynamics.acad_transcript_results (regno, courseid, semester, acad, studyyear, score, grade, gradept, CreditUnits, progid, study_system, is_retake)
SELECT regno, courseid, semester, acad, studyyear, score, grade, gradept, CreditUnits, progid, 'Semester', 0
FROM campus_dynamics.acad_results WHERE regno=@R;

-- 6) Rebuild course registrations (portal) — CW 40 / Exam 60 summing to total, PUBLISHED
DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno=@R;
INSERT INTO campus_dynamics_portal.acad_course_registration
  (regno, courseID, acad_year, semester, course_status, prog_id, stud_session, mark_stage,
   provisional_marks_status, provisional_course_work_marks, provisional_exam_marks, provisional_total_marks, registration_type)
SELECT @R, fcode, acad, sem, 'REGULAR', 'DPE', 'DAY', 'PUBLISHED', 'published',
   ROUND(total*0.4), total-ROUND(total*0.4), total, 'NORMAL'
FROM _rec;

-- 7) Per-semester GPA into both results + transcript
UPDATE campus_dynamics.acad_results r
JOIN (SELECT studyyear, semester, ROUND(SUM(gradept*CreditUnits)/SUM(CreditUnits),2) g
      FROM campus_dynamics.acad_results WHERE regno=@R GROUP BY studyyear, semester) x
  ON x.studyyear=r.studyyear AND x.semester=r.semester
SET r.gpa=x.g WHERE r.regno=@R;
UPDATE campus_dynamics.acad_transcript_results r
JOIN (SELECT studyyear, semester, ROUND(SUM(gradept*CreditUnits)/SUM(CreditUnits),2) g
      FROM campus_dynamics.acad_transcript_results WHERE regno=@R GROUP BY studyyear, semester) x
  ON x.studyyear=r.studyyear AND x.semester=r.semester
SET r.gpa=x.g WHERE r.regno=@R;

-- 8) Verify
SELECT sy 'Yr', sem 'Sem', COUNT(*) courses FROM _rec GROUP BY sy, sem;
SELECT COUNT(*) total_results, ROUND(SUM(gradept*CreditUnits)/SUM(CreditUnits),2) cgpa
FROM campus_dynamics.acad_results WHERE regno=@R;
