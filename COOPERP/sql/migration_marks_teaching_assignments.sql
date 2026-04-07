-- ============================================================================
-- MIGRATION: Marks Module — Teaching Assignments Table (B-02)
-- Database: campus_dynamics
-- Date:     2026-04-07
-- Author:   System
-- Depends:  marks_001 (sys_schema_migrations)
--
-- Creates the acad_teaching_assignments table that maps teachers to courses
-- for each academic period. This is the foundational authorization table:
--   - Teachers can only see/edit marks for assigned courses.
--   - Dean/HOD can assign/reassign teachers per academic year/semester.
--   - Backfill from existing acad_examsettings.empCode is done separately (B-07).
--
-- Addresses: P1, P2, P4, P5 (teacher-course linkage gaps)
-- ============================================================================

-- ── 1. Teaching Assignments Table ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS acad_teaching_assignments (
    id               INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    teacher_username VARCHAR(50)     NOT NULL        COMMENT 'Username from acad_staff / Session["ScreenName"]',
    course_id        VARCHAR(25)     NOT NULL        COMMENT 'Course code from acad_programmecourses.course_code',
    progid           VARCHAR(25)     NOT NULL        COMMENT 'Programme code from acad_programme.progcode',
    acadyear         VARCHAR(25)     NOT NULL        COMMENT 'Academic year, e.g. 2025/2026',
    semester         TINYINT UNSIGNED NOT NULL       COMMENT 'Semester number (1 or 2)',
    study_year       TINYINT UNSIGNED NOT NULL       COMMENT 'Year of study (1, 2, 3, etc.)',
    campus_id        INT UNSIGNED    NOT NULL        COMMENT 'Campus identifier from acad_campus.campusid',
    stud_session     VARCHAR(25)     NOT NULL DEFAULT 'Day' COMMENT 'Study session: Day, Evening, Weekend, etc.',
    assigned_by      VARCHAR(50)     NOT NULL        COMMENT 'Username who created/assigned this record',
    assigned_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When the assignment was created',
    is_active        TINYINT(1)      NOT NULL DEFAULT 1 COMMENT '1 = active, 0 = deactivated/reassigned',
    notes            VARCHAR(250)    DEFAULT NULL    COMMENT 'Optional notes about the assignment',
    UNIQUE KEY uq_assignment (teacher_username, course_id, progid, acadyear, semester, study_year, campus_id, stud_session),
    INDEX idx_teacher_year (teacher_username, acadyear, semester),
    INDEX idx_course_year (course_id, acadyear, semester),
    INDEX idx_programme (progid, acadyear, semester),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Teacher-to-course assignments per academic period — authorization backbone for marks entry';


-- ── 2. Register this migration ─────────────────────────────────────────────

INSERT INTO sys_schema_migrations (version, description, applied_by, rollback_ref)
SELECT 'marks_002', 'Create acad_teaching_assignments table', 'system', 'rollback_marks_teaching_assignments.sql'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_schema_migrations WHERE version = 'marks_002');


-- ── 3. Verification ────────────────────────────────────────────────────────

SELECT 'acad_teaching_assignments' AS tbl, COUNT(*) AS rows FROM acad_teaching_assignments;

-- Quick structure check
SHOW COLUMNS FROM acad_teaching_assignments;
