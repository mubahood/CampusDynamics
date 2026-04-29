-- ============================================================
-- RESTORATION SCRIPT: NAKASULE SYLVIA
-- Reg No: 10/U/DPE/935/KB/INS
-- Programme: DIPLOMA IN PRIMARY EDUCATION (DPE)
-- Academic Years: 2010/2011, 2011/2012 (6 sessions, 31 courses)
-- Award: SECOND CLASS UPPER | Graduated: 15 Feb 2013
-- Generated: 2026-04-28
--
-- HOW TO RUN:
--   1) Verify @prog_id below matches the actual DPE code in acad_programme
--   2) Run entire script in one MySQL session (autocommit off recommended)
--   3) Review final SELECT output before committing
--   4) Rollback if any counts look wrong
-- ============================================================

SET @regno  := '10/U/DPE/935/KB/INS';
SET @actor  := 'registry-restoration-2026';
SET @prog_id_override := 'DPE';   -- ← VERIFY: change if DPE code differs in your DB

-- ============================================================
-- PHASE 0 — SAFETY CHECKS
-- ============================================================

-- Check if student already exists
SELECT 'SAFETY-CHECK: acad_student' AS section,
       @regno AS regno,
       COUNT(*) AS existing_rows
FROM campus_dynamics.acad_student
WHERE regno = @regno;

-- Check if any results already exist (prevent double-restoration)
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
-- Insert only if not already present. Adjust columns as needed.
-- ============================================================

INSERT INTO campus_dynamics.acad_student
    (regno, entryno, firstname, othername, gender, dob,
     nationality, progid, studsesion, studCampus,
     entryyear, stud_status, new_status)
SELECT
    '10/U/DPE/935/KB/INS',
    '10/U/DPE/935/KB/INS',   -- entryno = regno (no separate student number confirmed)
    'NAKASULE',
    'Sylvia',
    'Female',
    '1986-10-24',
    'Ugandan',
    @prog_id_override,
    'DAY',
    'MAIN',
    2010,
    'GRADUATED',
    'GRADUATED'
WHERE NOT EXISTS (
    SELECT 1 FROM campus_dynamics.acad_student
    WHERE regno = '10/U/DPE/935/KB/INS'
);

SELECT 'PHASE-1: student row after insert' AS section,
       regno, entryno, firstname, othername, gender, dob, progid, stud_status
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

-- Add CreditUnits column to acad_results if missing
SET @add_res_cu_sql := IF(@res_credit_col IS NULL,
    'ALTER TABLE campus_dynamics.acad_results ADD COLUMN CreditUnits INT NULL',
    'SELECT 1');
PREPARE stmt_add_res_cu FROM @add_res_cu_sql; EXECUTE stmt_add_res_cu; DEALLOCATE PREPARE stmt_add_res_cu;
SET @res_credit_col := COALESCE(@res_credit_col, 'CreditUnits');

-- ============================================================
-- PHASE 3 — TRANSCRIPT PAYLOAD
-- All 31 courses across 6 sessions, CU=2 for all
-- Grades derived from active system scale:
--   >=80:A/5.0, >=75:A-/4.5, >=70:B+/4.0, >=65:B/3.5,
--   >=60:B-/3.0, >=55:C+/2.5, >=50:C/2.0, >=45:C-/1.5, >=40:D/1.0, else E/0.0
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_restore_marks;
CREATE TEMPORARY TABLE tmp_restore_marks (
    acad_year      VARCHAR(20) NOT NULL,
    semester       INT         NOT NULL,
    study_year     INT         NOT NULL,
    course_id      VARCHAR(30) NOT NULL,
    course_name    VARCHAR(200) NULL,
    coursework     INT         NULL,
    exam           INT         NULL,
    total          INT         NOT NULL
);

INSERT INTO tmp_restore_marks
    (acad_year, semester, study_year, course_id, course_name, coursework, exam, total) VALUES
-- ── Year 1, Session 1 (2010/2011, studyyear=1, semester=1) ──
('2010/2011', 1, 1, 'DIT1101',  'COMPUTER LITERACY',                              31, 46, 77),
('2010/2011', 1, 1, 'PEOI1101', 'INDIGENOUS AND FORMAL EDUCATION (PRIMARY)',       29, 43, 72),
('2010/2011', 1, 1, 'PEOI1102', 'HUMAN GROWTH, LEARNING AND DEVELOPMENT',          25, 38, 63),
('2010/2011', 1, 1, 'PEOI1103', 'EARLY CHILDHOOD EDUCATION',                       27, 40, 67),
('2010/2011', 1, 1, 'PEOI1104', 'THE PRIMARY CURRICULUM',                          28, 43, 71),
('2010/2011', 1, 1, 'PEOI1105', 'RESEARCH METHODS',                                30, 46, 76),
-- ── Year 1, Session 2 (2010/2011, studyyear=1, semester=2) ──
('2010/2011', 2, 1, 'DEFI1201', 'SOCIOLOGICAL FOUNDATIONS OF EDUCATION',           26, 40, 66),
('2010/2011', 2, 1, 'DEFI1202', 'CONTEMPORARY PRIMARY EDUCATIONAL SYSTEMS',        28, 40, 68),
('2010/2011', 2, 1, 'DELI1201', 'INTRODUCTION TO LANGUAGE STUDY',                  29, 44, 73),
('2010/2011', 2, 1, 'DELI1202', 'LANGUAGE STUDY AND TEACHING',                     32, 46, 78),
('2010/2011', 2, 1, 'DSSI1201', 'EVOLUTION AND FOREIGN INTRUSION IN UGANDA',       25, 40, 65),
('2010/2011', 2, 1, 'DSSI1202', 'MAN AND ENVIRONMENT IN AFRICA',                   34, 51, 85),
-- ── Year 1, Session 3 (2010/2011, studyyear=1, semester=3) ──
('2010/2011', 3, 1, 'DELI1301', 'LITERATURE AND LANGUAGE STUDY',                   31, 46, 77),
('2010/2011', 3, 1, 'DELI1302', 'LANGUAGE DEVELOPMENT AND PRIMARY METHODOLOGY',    32, 47, 79),
('2010/2011', 3, 1, 'DEMI1301', 'EDUCATIONAL MEASUREMENT AND EVALUATION',           26, 41, 67),
('2010/2011', 3, 1, 'DSSI1302', 'THE ECONOMIC DEVELOPMENT IN AFRICA',              28, 41, 69),
-- ── Year 2, Session 1 (2011/2012, studyyear=2, semester=1) ──
('2011/2012', 1, 2, 'DCUI2101', 'ESSENTIALS OF EDUCATIONAL TECHNOLOGY',            28, 44, 72),
('2011/2012', 1, 2, 'DEFI2101', 'PHILOSOPHICAL FOUNDATIONS OF EDUCATION',          26, 40, 66),
('2011/2012', 1, 2, 'DELI2101', 'LANGUAGE IN SOCIETY',                             35, 53, 88),
('2011/2012', 1, 2, 'DELI2102', 'DRAMA AND POETRY',                                32, 50, 82),
('2011/2012', 1, 2, 'DSSI2101', 'POLITICAL DEVELOPMENT OF UGANDA',                 28, 43, 71),
('2011/2012', 1, 2, 'DSSI2102', 'MAN RESOURCES AND DEVELOPMENT',                   30, 46, 76),
-- ── Year 2, Session 2 (2011/2012, studyyear=2, semester=2) ──
('2011/2012', 2, 2, 'DEEI2201', 'PROFESSIONAL ETHICS',                             21, 31, 52),
('2011/2012', 2, 2, 'DELI2201', 'INSTRUCTIONAL MODES AND RESOURCES IN ENGLISH',    31, 46, 77),
('2011/2012', 2, 2, 'DGCI2201', 'INTRODUCTION TO GUIDANCE AND COUNSELING',         32, 46, 78),
('2011/2012', 2, 2, 'DSSI2201', 'INSTRUCTIONAL MODES AND RESOURCES IN SS',         29, 44, 73),
-- ── Year 2, Session 3 (2011/2012, studyyear=2, semester=3) ──
('2011/2012', 3, 2, 'DELI2301', 'ASSESSMENT OF PRIMARY ENGLISH',                   25, 37, 62),
('2011/2012', 3, 2, 'DERI2301', 'RESEARCH PROPOSAL',                               26, 38, 64),
('2011/2012', 3, 2, 'DMAI2301', 'ESSENTIALS OF EDUCATIONAL MANAGEMENT',            27, 41, 68),
('2011/2012', 3, 2, 'DSPI2301', 'SCHOOL PRACTICE (12 WKS)',                        30, 44, 74),
('2011/2012', 3, 2, 'DSSI2301', 'ASSESSMENT OF PRIMARY SOCIAL STUDIES',            28, 42, 70);

-- ============================================================
-- PHASE 4 — EXPAND ROWS WITH COMPUTED GRADES/GRADE-POINTS
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_restore_rows;
CREATE TEMPORARY TABLE tmp_restore_rows AS
SELECT
    m.acad_year,
    m.semester,
    m.study_year,
    m.course_id,
    m.course_name,
    m.coursework,
    m.exam,
    m.total,
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
    END AS gradept,
    2 AS credit_units    -- all DPE courses are 2 CU
FROM tmp_restore_marks m;

-- Verify GPA snapshot before writing (should match transcript GPAs)
SELECT
    acad_year,
    semester,
    study_year,
    COUNT(*) AS courses,
    ROUND(SUM(gradept * credit_units) / SUM(credit_units), 2) AS computed_gpa
FROM tmp_restore_rows
GROUP BY acad_year, semester, study_year
ORDER BY study_year, semester;
-- Expected: 3.92, 3.96, 3.97, 4.07, 4.02, 3.94

-- ============================================================
-- PHASE 5 — UPSERT SEMESTER REGISTRATIONS
-- ============================================================

INSERT INTO campus_dynamics.acad_registration
    (regno, acad_year, semester, studyyear, regstatus,
     id_cardStatus, residence_status, examClearance, registeredBy)
SELECT
    @regno,
    t.acad_year,
    t.semester,
    t.study_year,
    'REGISTERED',
    'PRINTED',
    'DAY',
    'CLEARED',
    @actor
FROM (SELECT DISTINCT acad_year, semester, study_year FROM tmp_restore_rows) t
WHERE NOT EXISTS (
    SELECT 1 FROM campus_dynamics.acad_registration r
    WHERE r.regno = @regno
      AND r.acad_year = t.acad_year
      AND r.semester  = t.semester
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
PREPARE stmt_ins_acr FROM @ins_acr_sql;
EXECUTE stmt_ins_acr;
DEALLOCATE PREPARE stmt_ins_acr;

-- Update any pre-existing course_registration rows to align marks
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
PREPARE stmt_upd_acr FROM @upd_acr_sql;
EXECUTE stmt_upd_acr;
DEALLOCATE PREPARE stmt_upd_acr;

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
PREPARE stmt_ins_res FROM @ins_res_sql;
EXECUTE stmt_ins_res;
DEALLOCATE PREPARE stmt_ins_res;

-- Update pre-existing result rows
SET @upd_res_sql := CONCAT(
'UPDATE campus_dynamics.acad_results r ',
'JOIN tmp_restore_rows t ',
'  ON t.course_id=r.courseid AND t.acad_year=r.acad ',
' AND t.semester=r.semester   AND r.regno=@regno ',
'SET r.studyyear=t.study_year, r.score=t.total, r.grade=t.grade, ',
'    r.gradept=t.gradept, r.', @res_credit_col, '=t.credit_units, ',
'    r.result_comment=t.result_comment'
);
PREPARE stmt_upd_res FROM @upd_res_sql;
EXECUTE stmt_upd_res;
DEALLOCATE PREPARE stmt_upd_res;

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
'         ROUND(SUM(COALESCE(x.gradept,0) * COALESCE(NULLIF(x.', @res_credit_col, ',0),2)) / ',
'               NULLIF(SUM(COALESCE(NULLIF(x.', @res_credit_col, ',0),2)),0), 2) AS sem_gpa ',
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

-- Semester-level summary (compare with transcript GPAs)
SET @sem_summary_sql := CONCAT(
'SELECT r.acad AS academic_year, r.semester, MIN(r.studyyear) AS studyyear, ',
'       COUNT(*) AS courses, ',
'       ROUND(SUM(r.gradept * COALESCE(NULLIF(r.', @res_credit_col, ',0),2)) / ',
'             NULLIF(SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),2)),0), 2) AS computed_gpa, ',
'       MIN(r.gpa) AS stored_gpa ',
'FROM campus_dynamics.acad_results r ',
'WHERE r.regno = @regno ',
'GROUP BY r.acad, r.semester ',
'ORDER BY MIN(r.studyyear), r.semester'
);
PREPARE stmt_sem_summary FROM @sem_summary_sql; EXECUTE stmt_sem_summary; DEALLOCATE PREPARE stmt_sem_summary;
-- Expected GPAs: 3.92, 3.96, 3.97, 4.07, 4.02, 3.94

-- CGPA
SET @cgpa_val_sql := CONCAT(
'SELECT ROUND(SUM(r.gradept * COALESCE(NULLIF(r.', @res_credit_col, ',0),2)) / ',
'             NULLIF(SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),2)),0), 2) ',
'INTO @cgpa_val ',
'FROM campus_dynamics.acad_results r WHERE r.regno=@regno'
);
PREPARE stmt_cgpa FROM @cgpa_val_sql; EXECUTE stmt_cgpa; DEALLOCATE PREPARE stmt_cgpa;

SELECT
    @regno      AS regno,
    'NAKASULE Sylvia' AS student_name,
    @cgpa_val   AS cgpa,
    CASE
        WHEN @cgpa_val >= 4.40 THEN 'FIRST CLASS'
        WHEN @cgpa_val >= 3.60 THEN 'SECOND CLASS UPPER'
        WHEN @cgpa_val >= 2.80 THEN 'SECOND CLASS LOWER'
        WHEN @cgpa_val >= 2.00 THEN 'PASS'
        ELSE 'RETAKE'
    END AS award_class;
-- Expected: ~3.97, SECOND CLASS UPPER

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

-- Row count sanity (expect 31)
SELECT 'FINAL: total result rows' AS msg,
       COUNT(*) AS total
FROM campus_dynamics.acad_results
WHERE regno = @regno;
