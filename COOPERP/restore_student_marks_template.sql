-- Student Marks Restoration (idempotent template)
-- Target DBs: campus_dynamics, campus_dynamics_portal
-- Usage:
--   1) Set @regno
--   2) Fill tmp_restore_marks rows from your source transcript
--   3) Run entire script in one session

SET @regno := '12/U/DPE/0019/KB/INS';
SET @actor := 'marks-restoration-admin';

-- ==========================================
-- 0) Safety checks
-- ==========================================
SELECT @regno AS regno, COUNT(*) AS student_rows
FROM campus_dynamics.acad_student s
WHERE s.regno = @regno;

-- ==========================================
-- 1) Input payload (PASTE THE FULL RECORD)
-- ==========================================
DROP TEMPORARY TABLE IF EXISTS tmp_restore_marks;
CREATE TEMPORARY TABLE tmp_restore_marks (
    acad_year      VARCHAR(20)  NOT NULL,
    semester       INT          NOT NULL,
    study_year     INT          NULL,
    course_id      VARCHAR(30)  NOT NULL,
    coursework     INT          NULL,
    exam           INT          NULL,
    total          INT          NULL,
    result_comment VARCHAR(255) NULL
);

-- Example rows (replace with full student record)
-- INSERT INTO tmp_restore_marks (acad_year, semester, study_year, course_id, coursework, exam, total, result_comment) VALUES
-- ('2012/2013', 1, 1, 'ABC1101', 18, 55, 73, 'Historical restoration'),
-- ('2012/2013', 1, 1, 'ABC1102', 21, 44, 65, 'Historical restoration');

-- ==========================================
-- 2) Resolve schema variations
-- ==========================================
SET @prog_id := (
    SELECT COALESCE(NULLIF(TRIM(s.progid),''), '')
    FROM campus_dynamics.acad_student s
    WHERE s.regno = @regno
    LIMIT 1
);

SET @acr_has_courseid := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal' AND TABLE_NAME='acad_course_registration' AND LOWER(COLUMN_NAME)='courseid'
);
SET @acr_has_course_code := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal' AND TABLE_NAME='acad_course_registration' AND LOWER(COLUMN_NAME)='course_code'
);
SET @acr_has_stud_session := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal' AND TABLE_NAME='acad_course_registration' AND LOWER(COLUMN_NAME)='stud_session'
);
SET @acr_has_created_date := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics_portal' AND TABLE_NAME='acad_course_registration' AND LOWER(COLUMN_NAME)='created_date'
);

SET @res_credit_col := (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics' AND TABLE_NAME='acad_results'
      AND LOWER(COLUMN_NAME) IN ('creditunits','credit_units','creditunit','credit_unit','cu')
    ORDER BY CASE LOWER(COLUMN_NAME)
        WHEN 'creditunits' THEN 1
        WHEN 'credit_units' THEN 2
        WHEN 'creditunit' THEN 3
        WHEN 'credit_unit' THEN 4
        WHEN 'cu' THEN 5
        ELSE 99 END
    LIMIT 1
);

SET @course_credit_col := (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='campus_dynamics' AND TABLE_NAME='acad_course'
      AND LOWER(COLUMN_NAME) IN ('creditunits','credit_units','creditunit','credit_unit','cu')
    ORDER BY CASE LOWER(COLUMN_NAME)
        WHEN 'creditunits' THEN 1
        WHEN 'credit_units' THEN 2
        WHEN 'creditunit' THEN 3
        WHEN 'credit_unit' THEN 4
        WHEN 'cu' THEN 5
        ELSE 99 END
    LIMIT 1
);

-- Ensure expected columns exist in acad_course_registration for marks restoration
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

-- Ensure result_comment supports long text payloads
ALTER TABLE campus_dynamics.acad_results
    MODIFY COLUMN result_comment TEXT NULL;

-- If credit-units column missing on results, create CreditUnits
SET @add_res_cu_sql := IF(@res_credit_col IS NULL,
    'ALTER TABLE campus_dynamics.acad_results ADD COLUMN CreditUnits INT NULL',
    'SELECT 1');
PREPARE stmt_add_res_cu FROM @add_res_cu_sql;
EXECUTE stmt_add_res_cu;
DEALLOCATE PREPARE stmt_add_res_cu;

SET @res_credit_col := COALESCE(@res_credit_col, 'CreditUnits');

-- ==========================================
-- 3) Upsert semester registration context
-- ==========================================
INSERT INTO campus_dynamics.acad_registration
    (regno, acad_year, semester, studyyear, regstatus,
     id_cardStatus, residence_status, examClearance,
     conducted_new_registration, registeredBy)
SELECT
    @regno,
    m.acad_year,
    m.semester,
    COALESCE(m.study_year, 1),
    'REGISTERED',
    'UNPRINTED',
    'DAY',
    'UNCLEARED',
    'Yes',
    @actor
FROM (
    SELECT DISTINCT acad_year, semester, study_year
    FROM tmp_restore_marks
) m
WHERE NOT EXISTS (
    SELECT 1
    FROM campus_dynamics.acad_registration r
    WHERE r.regno = @regno
      AND r.acad_year = m.acad_year
      AND r.semester = m.semester
);

-- ==========================================
-- 4) Upsert course registration + provisional marks
-- ==========================================
DROP TEMPORARY TABLE IF EXISTS tmp_restore_rows;
CREATE TEMPORARY TABLE tmp_restore_rows AS
SELECT
    m.acad_year,
    m.semester,
    COALESCE(NULLIF(m.study_year,0),
        (SELECT MAX(r.studyyear)
         FROM campus_dynamics.acad_registration r
         WHERE r.regno=@regno AND r.acad_year=m.acad_year AND r.semester=m.semester),
        1) AS study_year,
    m.course_id,
    m.coursework,
    m.exam,
    COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) AS total,
    COALESCE(m.result_comment, CONCAT('Historical restoration by ', @actor)) AS result_comment,
    CASE
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 80 THEN 'A'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 75 THEN 'A-'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 70 THEN 'B+'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 65 THEN 'B'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 60 THEN 'B-'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 55 THEN 'C+'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 50 THEN 'C'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 45 THEN 'C-'
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 40 THEN 'D'
      ELSE 'E'
    END AS grade,
    CASE
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 80 THEN 5.0
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 75 THEN 4.5
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 70 THEN 4.0
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 65 THEN 3.5
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 60 THEN 3.0
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 55 THEN 2.5
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 50 THEN 2.0
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 45 THEN 1.5
      WHEN COALESCE(m.total, COALESCE(m.coursework,0)+COALESCE(m.exam,0)) >= 40 THEN 1.0
      ELSE 0.0
    END AS gradept
FROM tmp_restore_marks m;

-- Insert missing course-registration rows using detected schema shape
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
'  WHERE cr.regno=@regno AND cr.acad_year=t.acad_year AND cr.semester=t.semester AND ',
'  ', IF(@acr_has_courseid>0,'IFNULL(cr.courseID,'''') = t.course_id','IFNULL(cr.course_code,'''') = t.course_id'),
');'
);
PREPARE stmt_ins_acr FROM @ins_acr_sql;
EXECUTE stmt_ins_acr;
DEALLOCATE PREPARE stmt_ins_acr;

-- Update existing course-registration rows to align marks/publish state
SET @upd_acr_sql := CONCAT(
'UPDATE campus_dynamics_portal.acad_course_registration cr ',
'JOIN tmp_restore_rows t ON t.acad_year=cr.acad_year AND t.semester=cr.semester AND ',
IF(@acr_has_courseid>0,'IFNULL(cr.courseID,'''')=t.course_id','IFNULL(cr.course_code,'''')=t.course_id'),
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

-- ==========================================
-- 5) Upsert final results in acad_results
-- ==========================================
SET @sel_course_cu_expr := IF(@course_credit_col IS NULL, '3', CONCAT('COALESCE(NULLIF(c.', @course_credit_col, ',0),3)'));

SET @ins_res_sql := CONCAT(
'INSERT INTO campus_dynamics.acad_results (regno, courseid, acad, semester, studyyear, score, grade, gradept, ', @res_credit_col, ', result_comment) ',
'SELECT @regno, t.course_id, t.acad_year, t.semester, t.study_year, t.total, t.grade, t.gradept, ',
@sel_course_cu_expr,
', t.result_comment ',
'FROM tmp_restore_rows t ',
'LEFT JOIN campus_dynamics.acad_course c ON c.courseID = t.course_id ',
'WHERE NOT EXISTS (',
'  SELECT 1 FROM campus_dynamics.acad_results r ',
'  WHERE r.regno=@regno AND r.courseid=t.course_id AND r.acad=t.acad_year AND r.semester=t.semester',
');'
);
PREPARE stmt_ins_res FROM @ins_res_sql;
EXECUTE stmt_ins_res;
DEALLOCATE PREPARE stmt_ins_res;

SET @upd_res_sql := CONCAT(
'UPDATE campus_dynamics.acad_results r ',
'JOIN tmp_restore_rows t ON t.course_id=r.courseid AND t.acad_year=r.acad AND t.semester=r.semester AND r.regno=@regno ',
'LEFT JOIN campus_dynamics.acad_course c ON c.courseID=t.course_id ',
'SET r.studyyear=t.study_year, ',
'    r.score=t.total, ',
'    r.grade=t.grade, ',
'    r.gradept=t.gradept, ',
'    r.', @res_credit_col, ' = ', @sel_course_cu_expr, ', ',
'    r.result_comment=t.result_comment'
);
PREPARE stmt_upd_res FROM @upd_res_sql;
EXECUTE stmt_upd_res;
DEALLOCATE PREPARE stmt_upd_res;

-- ==========================================
-- 6) Recompute GPA by semester context
-- ==========================================
DROP TEMPORARY TABLE IF EXISTS tmp_semesters;
CREATE TEMPORARY TABLE tmp_semesters AS
SELECT DISTINCT acad_year, semester
FROM tmp_restore_rows;

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
PREPARE stmt_gpa_upd FROM @gpa_upd_sql;
EXECUTE stmt_gpa_upd;
DEALLOCATE PREPARE stmt_gpa_upd;

-- ==========================================
-- 7) Validation output (GPA, CGPA, class)
-- ==========================================
SET @cgpa_sql := CONCAT(
'SELECT ROUND(SUM(COALESCE(gradept,0) * COALESCE(NULLIF(', @res_credit_col, ',0),3)) / ',
'       NULLIF(SUM(COALESCE(NULLIF(', @res_credit_col, ',0),3)),0), 2) ',
'FROM campus_dynamics.acad_results WHERE regno=@regno'
);
PREPARE stmt_cgpa FROM @cgpa_sql;
EXECUTE stmt_cgpa;
DEALLOCATE PREPARE stmt_cgpa;

SET @sem_summary_sql := CONCAT(
'SELECT ',
'    r.acad, ',
'    r.semester, ',
'    MIN(r.studyyear) AS studyyear, ',
'    COUNT(*) AS courses, ',
'    ROUND(SUM(COALESCE(r.gradept,0) * COALESCE(NULLIF(r.', @res_credit_col, ',0),3)) / ',
'          NULLIF(SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),3)),0), 2) AS weighted_gpa_snapshot, ',
'    MIN(r.gpa) AS stored_gpa, ',
'    MAX(r.gpa) AS stored_gpa_max ',
'FROM campus_dynamics.acad_results r ',
'WHERE r.regno = @regno ',
'GROUP BY r.acad, r.semester ',
'ORDER BY MIN(r.studyyear), r.semester'
);
PREPARE stmt_sem_summary FROM @sem_summary_sql;
EXECUTE stmt_sem_summary;
DEALLOCATE PREPARE stmt_sem_summary;

SET @cgpa_val_sql := CONCAT(
'SELECT ROUND(SUM(COALESCE(r.gradept,0) * COALESCE(NULLIF(r.', @res_credit_col, ',0),3)) / ',
'             NULLIF(SUM(COALESCE(NULLIF(r.', @res_credit_col, ',0),3)),0), 2) ',
'INTO @cgpa_val ',
'FROM campus_dynamics.acad_results r ',
'WHERE r.regno = @regno'
);
PREPARE stmt_cgpa_val FROM @cgpa_val_sql;
EXECUTE stmt_cgpa_val;
DEALLOCATE PREPARE stmt_cgpa_val;

SELECT
    @regno AS regno,
    @cgpa_val AS cgpa,
    CASE
        WHEN @cgpa_val >= 4.40 THEN 'FIRST CLASS'
        WHEN @cgpa_val >= 3.60 THEN 'SECOND CLASS UPPER'
        WHEN @cgpa_val >= 2.80 THEN 'SECOND CLASS LOWER'
        WHEN @cgpa_val >= 2.00 THEN 'PASS'
        ELSE 'RETAKE'
    END AS award_class;

-- Optional: transcript rows after restoration
SELECT
    r.regno, r.courseid, c.CourseName, r.acad, r.semester, r.studyyear,
    r.score, r.grade, r.gradept, r.gpa, r.result_comment
FROM campus_dynamics.acad_results r
LEFT JOIN campus_dynamics.acad_course c ON c.courseID = r.courseid
WHERE r.regno = @regno
ORDER BY r.studyyear, r.semester, r.courseid;
