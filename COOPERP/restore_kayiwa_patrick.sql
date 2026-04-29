-- ============================================================
-- RESTORATION SCRIPT: KAYIWA PATRICK
-- Reg No:    21/U/BMC/0508/K/DAY
-- Student No: MRU/21000537
-- Programme: BACHELOR OF MASS COMMUNICATION (BMC)
-- Faculty:   Social Sciences, Arts and Humanities
-- Academic Years: 2021/2022, 2022/2023, 2023/2024
-- (6 semesters, 47 courses)
-- Target CGPA: 3.79
-- Generated: 2026-04-28
--
-- NOTE ON GRADE LABELS:
--   The original transcript uses a different letter-grade labelling system
--   (e.g. D+ for 57, B+ for 78). This script uses the ACTIVE SYSTEM scale
--   (A/A-/B+/B/B-/C+/C/C-/D/E) for grade labels stored in the DB.
--   Grade POINTS are mathematically identical to the original transcript.
--   Example: score=57 → stored as C+(2.5), transcript shows D+(2.5); same GPA.
--
-- HOW TO RUN:
--   1) Verify @prog_id_override matches actual BMC code in acad_programme
--   2) Run entire script in one MySQL session
--   3) Review final SELECT output; expect CGPA ≈ 3.79
--   4) Rollback if counts differ from expected (47 result rows)
-- ============================================================

SET @regno  := '21/U/BMC/0508/K/DAY';
SET @actor  := 'registry-restoration-2026';
SET @prog_id_override := 'BMC';   -- ← VERIFY: change if BMC code differs in your DB

-- ============================================================
-- PHASE 0 — SAFETY CHECKS
-- ============================================================

SELECT 'SAFETY-CHECK: acad_student' AS section,
       @regno AS regno,
       COUNT(*) AS existing_rows
FROM campus_dynamics.acad_student
WHERE regno = @regno;

SELECT 'SAFETY-CHECK: acad_results' AS section,
       COUNT(*) AS existing_result_rows
FROM campus_dynamics.acad_results
WHERE regno = @regno;

SELECT 'SAFETY-CHECK: acad_registration' AS section,
       COUNT(*) AS existing_reg_rows
FROM campus_dynamics.acad_registration
WHERE regno = @regno;

-- ============================================================
-- PHASE 1 — STUDENT MASTER RECORD
-- ============================================================

INSERT INTO campus_dynamics.acad_student
    (regno, entryno, firstname, othername, gender,
     nationality, progid, studsesion, studCampus,
     entryyear, stud_status, new_status)
SELECT
    '21/U/BMC/0508/K/DAY',
    'MRU/21000537',           -- Official student number
    'KAYIWA',
    'PATRICK',
    'Male',
    'Ugandan',
    @prog_id_override,
    'DAY',
    'MAIN',
    2021,
    'Active',
    'Active'
WHERE NOT EXISTS (
    SELECT 1 FROM campus_dynamics.acad_student
    WHERE regno = '21/U/BMC/0508/K/DAY'
);

-- If student exists but student number (entryno) is blank, update it
UPDATE campus_dynamics.acad_student
SET entryno = 'MRU/21000537'
WHERE regno = '21/U/BMC/0508/K/DAY'
  AND (entryno IS NULL OR TRIM(entryno) = '');

SELECT 'PHASE-1: student row after insert' AS section,
       regno, entryno, firstname, othername, gender, progid, stud_status
FROM campus_dynamics.acad_student
WHERE regno = @regno;

-- ============================================================
-- PHASE 2 — RESOLVE SCHEMA VARIATIONS
-- ============================================================

SET @prog_id := COALESCE(
    (SELECT NULLIF(TRIM(s.progid),'')
     FROM campus_dynamics.acad_student s
     WHERE s.regno = @regno LIMIT 1),
    @prog_id_override
);

SET @acr_has_courseid := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal'
      AND TABLE_NAME='acad_course_registration'
      AND LOWER(COLUMN_NAME)='courseid'
);
SET @acr_has_course_code := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal'
      AND TABLE_NAME='acad_course_registration'
      AND LOWER(COLUMN_NAME)='course_code'
);
SET @acr_has_stud_session := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal'
      AND TABLE_NAME='acad_course_registration'
      AND LOWER(COLUMN_NAME)='stud_session'
);
SET @acr_has_created_date := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal'
      AND TABLE_NAME='acad_course_registration'
      AND LOWER(COLUMN_NAME)='created_date'
);

SET @res_credit_col := (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics' AND TABLE_NAME='acad_results'
      AND LOWER(COLUMN_NAME) IN ('creditunits','credit_units','creditunit','credit_unit','cu')
    ORDER BY CASE LOWER(COLUMN_NAME)
        WHEN 'creditunits' THEN 1 WHEN 'credit_units' THEN 2
        WHEN 'creditunit'  THEN 3 WHEN 'credit_unit'  THEN 4
        WHEN 'cu'          THEN 5 ELSE 99 END
    LIMIT 1
);

-- Ensure provisional marks columns exist
ALTER TABLE campus_dynamics_portal.acad_course_registration
    ADD COLUMN IF NOT EXISTS provisional_course_work_marks INT NULL,
    ADD COLUMN IF NOT EXISTS provisional_exam_marks INT NULL,
    ADD COLUMN IF NOT EXISTS provisional_total_marks INT NULL,
    ADD COLUMN IF NOT EXISTS provisional_marks_status VARCHAR(20) NULL DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS provisional_marks_review_comments TEXT NULL,
    ADD COLUMN IF NOT EXISTS provisional_marks_reviewed_by VARCHAR(150) NULL,
    ADD COLUMN IF NOT EXISTS provisional_marks_review_date DATETIME NULL,
    ADD COLUMN IF NOT EXISTS provisional_published_by VARCHAR(150) NULL,
    ADD COLUMN IF NOT EXISTS provisional_published_date DATETIME NULL;

ALTER TABLE campus_dynamics.acad_results MODIFY COLUMN result_comment TEXT NULL;

SET @add_res_cu_sql := IF(@res_credit_col IS NULL,
    'ALTER TABLE campus_dynamics.acad_results ADD COLUMN CreditUnits INT NULL',
    'SELECT 1');
PREPARE stmt_add_res_cu FROM @add_res_cu_sql; EXECUTE stmt_add_res_cu; DEALLOCATE PREPARE stmt_add_res_cu;
SET @res_credit_col := COALESCE(@res_credit_col, 'CreditUnits');

-- ============================================================
-- PHASE 3 — TRANSCRIPT PAYLOAD
-- 47 courses, 6 semesters, CU: 3 for most, 4 for ICT1108B, MSC2221B, MSC3219B
-- GPAs verified: 3.82, 3.93, 3.43, 3.84, 4.07, 3.70 → CGPA 3.79
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_restore_marks;
CREATE TEMPORARY TABLE tmp_restore_marks (
    acad_year    VARCHAR(20) NOT NULL,
    semester     INT         NOT NULL,
    study_year   INT         NOT NULL,
    course_id    VARCHAR(30) NOT NULL,
    course_name  VARCHAR(200) NULL,
    cu           INT         NOT NULL DEFAULT 3,
    coursework   INT         NULL,
    exam         INT         NULL,
    total        INT         NOT NULL
);

INSERT INTO tmp_restore_marks
    (acad_year, semester, study_year, course_id, course_name, cu, coursework, exam, total) VALUES
-- ── Year 1, Semester 1 (2021/2022) ──
('2021/2022', 1, 1, 'DVS1101B',  'INTRODUCTORY ECONOMICS',                          3, 25, 37, 62),
('2021/2022', 1, 1, 'FND1101B',  'COMMUNICATION AND LANGUAGE SKILLS',                3, 26, 40, 66),
('2021/2022', 1, 1, 'ICT1108B',  'COMPUTER LITERACY',                                4, 30, 44, 74),
('2021/2022', 1, 1, 'MSC1111B',  'INTRODUCTION TO MASS COMMUNICATION',               3, 31, 47, 78),
('2021/2022', 1, 1, 'MSC1113B',  'INTRODUCTION TO WRITING FOR MASS MEDIA',           3, 30, 46, 76),
('2021/2022', 1, 1, 'MSC1112B',  'MEDIA HISTORY AND ISSUES',                         3, 32, 49, 81),
('2021/2022', 1, 1, 'MSC1114B',  'INTRODUCTION TO RADIO JOURNALISM',                 3, 26, 40, 66),
('2021/2022', 1, 1, 'MSC1115B',  'INTRODUCTION TO TELEVISION JOURNALISM',            3, 23, 34, 57),
-- ── Year 1, Semester 2 (2021/2022) ──
('2021/2022', 2, 1, 'FND1205B',  'HISTORY AND CULTURAL HERITAGE OF UGANDA',          3, 26, 38, 64),
('2021/2022', 2, 1, 'MSC1206B',  'ENTREPRENEURSHIP DEVELOPMENT AND MANAGEMENT',      3, 32, 49, 81),
('2021/2022', 2, 1, 'MSC1211B',  'MASS MEDIA AND SOCIETY',                           3, 20, 31, 51),
('2021/2022', 2, 1, 'MSC1212B',  'INTRODUCTION TO POLITICAL SCIENCE',                3, 31, 47, 78),
('2021/2022', 2, 1, 'MSC1213B',  'INTRODUCTION TO PHOTO JOURNALISM',                 3, 32, 48, 80),
('2021/2022', 2, 1, 'MSC1214B',  'INTRODUCTION TO PUBLIC RELATIONS',                 3, 32, 48, 80),
('2021/2022', 2, 1, 'MSC1215B',  'THEORIES OF MASS COMMUNICATION',                   3, 25, 38, 63),
-- ── Year 2, Semester 1 (2022/2023) ──
('2022/2023', 1, 2, 'DVS2115B',  'RESEARCH METHODS IN MASS COMMUNICATION',           3, 30, 45, 75),
('2022/2023', 1, 2, 'MSC2111B',  'MEDIA LAW AND ETHICS',                             3, 27, 41, 68),
('2022/2023', 1, 2, 'MSC2112B',  'NEWS WRITING AND REPORTING',                       3, 30, 45, 75),
('2022/2023', 1, 2, 'MSC2113B',  'NEWSPAPER EDITING LAYOUT AND DESIGN',              3, 22, 33, 55),
('2022/2023', 1, 2, 'MSC2114B',  'PUBLIC INFORMATION PROGRAMMES',                    3, 24, 35, 59),
('2022/2023', 1, 2, 'MSC2116B',  'ADVERTISING AND COPY LAYOUT',                      3, 28, 42, 70),
('2022/2023', 1, 2, 'MSC2117B',  'HUMAN RIGHTS, CULTURE AND THE MEDIA',              3, 24, 35, 59),
-- ── Year 2, Semester 2 (2022/2023) ──
('2022/2023', 2, 2, 'DVS1108B',  'SOCIOLOGICAL ISSUES AND CONCEPTS',                 3, 24, 36, 60),
('2022/2023', 2, 2, 'MSC2211B',  'PUBLIC AFFAIRS REPORTING',                         3, 27, 41, 68),
('2022/2023', 2, 2, 'MSC2212B',  'PUBLIC RELATIONS AND MEDIA PRACTICE',              3, 30, 46, 76),
('2022/2023', 2, 2, 'MSC2213B',  'INVESTIGATIVE JOURNALISM',                         3, 29, 44, 73),
('2022/2023', 2, 2, 'MSC2214B',  'NEWSPAPER AND MAGAZINE PRODUCTION',                3, 22, 33, 55),
('2022/2023', 2, 2, 'MSC2215B',  'DEVELOPMENT COMMUNICATION',                        3, 30, 46, 76),
('2022/2023', 2, 2, 'MSC2216B',  'POLITICS AND GOVERNMENT OF E. AFRICAN STATES',     3, 29, 43, 72),
('2022/2023', 2, 2, 'MSC2221B',  'INTERNSHIP REPORT - INTERNSHIP 1',                 4, 31, 46, 77),
-- ── Year 3, Semester 1 (2023/2024) ──
('2023/2024', 1, 3, 'MSC3111B',  'THE ART OF PUBLIC SPEAKING',                       3, 28, 41, 69),
('2023/2024', 1, 3, 'MSC3112B',  'GRAPHICS OF COMMUNICATION',                        3, 27, 41, 68),
('2023/2024', 1, 3, 'MSC3113B',  'ADVANCED RADIO JOURNALISM AND PRODUCTION',         3, 30, 46, 76),
('2023/2024', 1, 3, 'MSC3114B',  'ADVANCED TV JOURNALISM AND PRODUCTION',            3, 28, 42, 70),
('2023/2024', 1, 3, 'MSC3115B',  'PUBLIC RELATIONS STRATEGIES AND CASE STUDIES',     3, 30, 44, 74),
('2023/2024', 1, 3, 'MSC3116B',  'MEDIA MANAGEMENT',                                 3, 30, 45, 75),
('2023/2024', 1, 3, 'MSC3118B',  'GENDER ISSUES IN MASS COMMUNICATION',              3, 30, 46, 76),
-- ── Year 3, Semester 2 (2023/2024) ──
('2023/2024', 2, 3, 'MSC3201B',  'SPECIALIZED WRITING',                              3, 30, 46, 76),
('2023/2024', 2, 3, 'MSC3208B',  'ADVANCED FILMING AND NEW MEDIA',                   3, 27, 40, 67),
('2023/2024', 2, 3, 'MSC3211B',  'ENVIRONMENTAL JOURNALISM',                         3, 31, 47, 78),
('2023/2024', 2, 3, 'MSC3212B',  'INTERNATIONAL AND ONLINE JOURNALISM',              3, 20, 30, 50),
('2023/2024', 2, 3, 'MSC3213B',  'CONTEMPORARY ISSUES IN JOURNALISM AND MASS COMM.', 3, 24, 37, 61),
('2023/2024', 2, 3, 'MSC3214B',  'COMMERCIAL AND PROMOTIONAL WRITING',               3, 23, 35, 58),
('2023/2024', 2, 3, 'MSC3215B',  'ADVANCED PHOTO JOURNALISM',                        3, 31, 46, 77),
('2023/2024', 2, 3, 'MSC3218B',  'RESEARCH REPORT',                                  3, 28, 43, 71),
('2023/2024', 2, 3, 'MSC3219B',  'INTERNSHIP REPORT - INTERNSHIP 2',                 4, 32, 47, 79);

-- ============================================================
-- PHASE 4 — EXPAND ROWS WITH COMPUTED GRADES/GRADE-POINTS
-- Using active system scale: A>=80/5.0, A->=75/4.5, B+>=70/4.0,
--   B>=65/3.5, B->=60/3.0, C+>=55/2.5, C>=50/2.0, C->=45/1.5,
--   D>=40/1.0, E<40/0.0
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_restore_rows;
CREATE TEMPORARY TABLE tmp_restore_rows AS
SELECT
    m.acad_year, m.semester, m.study_year,
    m.course_id, m.course_name, m.cu AS credit_units,
    m.coursework, m.exam, m.total,
    CONCAT('Historical restoration by ', @actor) AS result_comment,
    CASE
      WHEN m.total >= 80 THEN 'A'
      WHEN m.total >= 75 THEN 'A-'
      WHEN m.total >= 70 THEN 'B+'
      WHEN m.total >= 65 THEN 'B'
      WHEN m.total >= 60 THEN 'B-'
      WHEN m.total >= 55 THEN 'C+'
      WHEN m.total >= 50 THEN 'C'
      WHEN m.total >= 45 THEN 'C-'
      WHEN m.total >= 40 THEN 'D'
      ELSE 'E'
    END AS grade,
    CASE
      WHEN m.total >= 80 THEN 5.0
      WHEN m.total >= 75 THEN 4.5
      WHEN m.total >= 70 THEN 4.0
      WHEN m.total >= 65 THEN 3.5
      WHEN m.total >= 60 THEN 3.0
      WHEN m.total >= 55 THEN 2.5
      WHEN m.total >= 50 THEN 2.0
      WHEN m.total >= 45 THEN 1.5
      WHEN m.total >= 40 THEN 1.0
      ELSE 0.0
    END AS gradept
FROM tmp_restore_marks m;

-- GPA verification snapshot (must match: 3.82, 3.93, 3.43, 3.84, 4.07, 3.70)
SELECT
    acad_year, semester, study_year,
    COUNT(*) AS courses,
    SUM(credit_units) AS total_cu,
    ROUND(SUM(gradept * credit_units) / SUM(credit_units), 2) AS computed_gpa
FROM tmp_restore_rows
GROUP BY acad_year, semester, study_year
ORDER BY study_year, semester;

-- ============================================================
-- PHASE 5 — UPSERT SEMESTER REGISTRATIONS
-- ============================================================

INSERT INTO campus_dynamics.acad_registration
    (regno, acad_year, semester, studyyear, regstatus,
     id_cardStatus, residence_status, examClearance, registeredBy)
SELECT
    @regno, t.acad_year, t.semester, t.study_year,
    'REGISTERED', 'PRINTED', 'DAY', 'CLEARED', @actor
FROM (SELECT DISTINCT acad_year, semester, study_year FROM tmp_restore_rows) t
WHERE NOT EXISTS (
    SELECT 1 FROM campus_dynamics.acad_registration r
    WHERE r.regno=@regno AND r.acad_year=t.acad_year AND r.semester=t.semester
);

SELECT 'PHASE-5: semester registrations' AS section,
       regno, acad_year, semester, studyyear, regstatus
FROM campus_dynamics.acad_registration
WHERE regno = @regno
ORDER BY studyyear, semester;

-- ============================================================
-- PHASE 6 — UPSERT COURSE REGISTRATIONS + PROVISIONAL MARKS
-- ============================================================

SET @ins_acr_sql := CONCAT(
'INSERT INTO campus_dynamics_portal.acad_course_registration (regno,',
IF(@acr_has_courseid>0,'courseID,',''),
IF(@acr_has_course_code>0,'course_code,',''),
'prog_id,acad_year,semester,course_status,',
IF(@acr_has_stud_session>0,'stud_session,',''),
IF(@acr_has_created_date>0,'created_date,',''),
'provisional_course_work_marks,provisional_exam_marks,provisional_total_marks,',
'provisional_marks_status,provisional_marks_review_comments,provisional_marks_reviewed_by,',
'provisional_marks_review_date,provisional_published_by,provisional_published_date) ',
'SELECT @regno,',
IF(@acr_has_courseid>0,'t.course_id,',''),
IF(@acr_has_course_code>0,'t.course_id,',''),
'@prog_id,t.acad_year,t.semester,''REGULAR'',',
IF(@acr_has_stud_session>0,'''Day'',',''),
IF(@acr_has_created_date>0,'NOW(),',''),
't.coursework,t.exam,t.total,''published'',t.result_comment,@actor,NOW(),@actor,NOW() ',
'FROM tmp_restore_rows t ',
'WHERE NOT EXISTS (',
'  SELECT 1 FROM campus_dynamics_portal.acad_course_registration cr ',
'  WHERE cr.regno=@regno AND cr.acad_year=t.acad_year AND cr.semester=t.semester ',
'  AND ', IF(@acr_has_courseid>0,'IFNULL(cr.courseID,'''') = t.course_id','IFNULL(cr.course_code,'''') = t.course_id'),
');'
);
PREPARE stmt_ins_acr FROM @ins_acr_sql; EXECUTE stmt_ins_acr; DEALLOCATE PREPARE stmt_ins_acr;

SET @upd_acr_sql := CONCAT(
'UPDATE campus_dynamics_portal.acad_course_registration cr ',
'JOIN tmp_restore_rows t ON t.acad_year=cr.acad_year AND t.semester=cr.semester ',
'AND ', IF(@acr_has_courseid>0,'IFNULL(cr.courseID,'''')=t.course_id','IFNULL(cr.course_code,'''')=t.course_id'),
' AND cr.regno=@regno ',
'SET cr.provisional_course_work_marks=t.coursework, ',
'    cr.provisional_exam_marks=t.exam, ',
'    cr.provisional_total_marks=t.total, ',
'    cr.provisional_marks_status=''published'', ',
'    cr.provisional_marks_review_comments=t.result_comment, ',
'    cr.provisional_marks_reviewed_by=@actor, ',
'    cr.provisional_marks_review_date=NOW(), ',
'    cr.provisional_published_by=@actor, ',
'    cr.provisional_published_date=NOW()'
);
PREPARE stmt_upd_acr FROM @upd_acr_sql; EXECUTE stmt_upd_acr; DEALLOCATE PREPARE stmt_upd_acr;

-- ============================================================
-- PHASE 7 — UPSERT PUBLISHED RESULTS (acad_results)
-- ============================================================

SET @ins_res_sql := CONCAT(
'INSERT INTO campus_dynamics.acad_results ',
'(regno, courseid, acad, semester, studyyear, score, grade, gradept, ',
@res_credit_col, ', result_comment) ',
'SELECT @regno, t.course_id, t.acad_year, t.semester, t.study_year, ',
'       t.total, t.grade, t.gradept, t.credit_units, t.result_comment ',
'FROM tmp_restore_rows t ',
'WHERE NOT EXISTS (',
'  SELECT 1 FROM campus_dynamics.acad_results r ',
'  WHERE r.regno=@regno AND r.courseid=t.course_id ',
'    AND r.acad=t.acad_year AND r.semester=t.semester',
');'
);
PREPARE stmt_ins_res FROM @ins_res_sql; EXECUTE stmt_ins_res; DEALLOCATE PREPARE stmt_ins_res;

SET @upd_res_sql := CONCAT(
'UPDATE campus_dynamics.acad_results r ',
'JOIN tmp_restore_rows t ',
'  ON t.course_id=r.courseid AND t.acad_year=r.acad ',
' AND t.semester=r.semester   AND r.regno=@regno ',
'SET r.studyyear=t.study_year, r.score=t.total, r.grade=t.grade, ',
'    r.gradept=t.gradept, r.', @res_credit_col, '=t.credit_units, ',
'    r.result_comment=t.result_comment'
);
PREPARE stmt_upd_res FROM @upd_res_sql; EXECUTE stmt_upd_res; DEALLOCATE PREPARE stmt_upd_res;

-- ============================================================
-- PHASE 8 — RECOMPUTE GPA PER SEMESTER
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_semesters;
CREATE TEMPORARY TABLE tmp_semesters AS
SELECT DISTINCT acad_year, semester FROM tmp_restore_rows;

SET @gpa_upd_sql := CONCAT(
'UPDATE campus_dynamics.acad_results r ',
'JOIN (',
'  SELECT x.regno, x.acad, x.semester, ',
'         ROUND(SUM(COALESCE(x.gradept,0) * COALESCE(NULLIF(x.', @res_credit_col, ',0),3)) / ',
'               NULLIF(SUM(COALESCE(NULLIF(x.', @res_credit_col, ',0),3)),0), 2) AS sem_gpa ',
'  FROM campus_dynamics.acad_results x ',
'  JOIN tmp_semesters s ON s.acad_year=x.acad AND s.semester=x.semester ',
'  WHERE x.regno=@regno ',
'  GROUP BY x.regno, x.acad, x.semester',
') g ON g.regno=r.regno AND g.acad=r.acad AND g.semester=r.semester ',
'SET r.gpa=g.sem_gpa'
);
PREPARE stmt_gpa_upd FROM @gpa_upd_sql; EXECUTE stmt_gpa_upd; DEALLOCATE PREPARE stmt_gpa_upd;

-- ============================================================
-- PHASE 9 — FINAL VALIDATION OUTPUT
-- ============================================================

-- Semester-level GPA summary
SET @sem_summary_sql := CONCAT(
'SELECT r.acad AS academic_year, r.semester, MIN(r.studyyear) AS study_year, ',
'       COUNT(*) AS courses, ',
'       SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),3)) AS total_cu, ',
'       ROUND(SUM(r.gradept * COALESCE(NULLIF(r.', @res_credit_col, ',0),3)) / ',
'             NULLIF(SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),3)),0), 2) AS computed_gpa, ',
'       MIN(r.gpa) AS stored_gpa ',
'FROM campus_dynamics.acad_results r ',
'WHERE r.regno = @regno ',
'GROUP BY r.acad, r.semester ',
'ORDER BY MIN(r.studyyear), r.semester'
);
PREPARE stmt_sem_summary FROM @sem_summary_sql; EXECUTE stmt_sem_summary; DEALLOCATE PREPARE stmt_sem_summary;
-- Expected GPAs: 3.82, 3.93, 3.43, 3.84, 4.07, 3.70

-- CGPA
SET @cgpa_val_sql := CONCAT(
'SELECT ROUND(SUM(r.gradept * COALESCE(NULLIF(r.', @res_credit_col, ',0),3)) / ',
'             NULLIF(SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),3)),0), 2) ',
'INTO @cgpa_val ',
'FROM campus_dynamics.acad_results r WHERE r.regno=@regno'
);
PREPARE stmt_cgpa FROM @cgpa_val_sql; EXECUTE stmt_cgpa; DEALLOCATE PREPARE stmt_cgpa;

SELECT
    @regno           AS regno,
    'KAYIWA PATRICK' AS student_name,
    'MRU/21000537'   AS student_no,
    @cgpa_val        AS cgpa,
    CASE
        WHEN @cgpa_val >= 4.40 THEN 'FIRST CLASS'
        WHEN @cgpa_val >= 3.60 THEN 'SECOND CLASS UPPER'
        WHEN @cgpa_val >= 2.80 THEN 'SECOND CLASS LOWER'
        WHEN @cgpa_val >= 2.00 THEN 'PASS'
        ELSE 'RETAKE'
    END AS award_class;
-- Expected: CGPA ≈ 3.79, SECOND CLASS UPPER

-- Full transcript view
SET @full_tx_sql := CONCAT(
'SELECT r.acad, r.semester, r.studyyear, ',
'       r.courseid, c.CourseName, ',
'       r.score, r.grade, r.gradept, r.', @res_credit_col, ' AS credit_units, ',
'       r.gpa, r.result_comment ',
'FROM campus_dynamics.acad_results r ',
'LEFT JOIN campus_dynamics.acad_course c ON c.courseID = r.courseid ',
'WHERE r.regno = @regno ',
'ORDER BY r.studyyear, r.semester, r.courseid'
);
PREPARE stmt_full_tx FROM @full_tx_sql; EXECUTE stmt_full_tx; DEALLOCATE PREPARE stmt_full_tx;

-- Row count sanity (expect 47)
SELECT 'FINAL: total result rows' AS msg,
       COUNT(*) AS total
FROM campus_dynamics.acad_results
WHERE regno = @regno;
