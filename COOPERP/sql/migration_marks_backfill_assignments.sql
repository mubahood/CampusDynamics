-- ═══════════════════════════════════════════════════════════════════════
-- Migration: Backfill Teaching Assignments from Legacy Data
-- Version:   marks_006
-- Task:      B-07
-- ═══════════════════════════════════════════════════════════════════════
--
-- Purpose:
--   Populates acad_teaching_assignments from the existing acad_examsettings
--   table where empCode is set (teacher already associated with a course).
--   This is the primary backfill source for the new assignment-based
--   authorization model.
--
-- Approach:
--   1. INSERT IGNORE — idempotent, safe to run multiple times.
--   2. Sources from acad_examsettings which has empCode, CourseCode, progid, etc.
--   3. Defaults study_year to 1, campus_id to 1, stud_session to 'Day'
--      where the legacy data doesn't distinguish these.
--   4. Marks backfilled rows with assigned_by = 'SYSTEM_BACKFILL'.
--   5. Also registers itself in sys_schema_migrations.
--
-- Prerequisites:
--   - migration_marks_teaching_assignments.sql (B-02) must be applied first
--   - migration_marks_schema_registry.sql (B-01) must be applied first
--
-- Rollback: rollback_marks_backfill_assignments.sql
-- ═══════════════════════════════════════════════════════════════════════

-- Step 1: Verify prerequisite table exists
SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_teaching_assignments') > 0,
    'OK: acad_teaching_assignments exists',
    'ERROR: acad_teaching_assignments missing — run migration_marks_teaching_assignments.sql first'
) AS prerequisite_check;

-- Step 2: Count existing assignments before backfill
SELECT COUNT(*) AS assignments_before FROM acad_teaching_assignments;

-- Step 3: Backfill from acad_examsettings
-- Uses INSERT IGNORE to skip duplicates (unique key on the combination)
INSERT IGNORE INTO acad_teaching_assignments
    (teacher_username, course_id, progid, acadyear, semester, study_year, campus_id, stud_session,
     assigned_by, assigned_at, is_active, notes)
SELECT DISTINCT
    es.empCode           AS teacher_username,
    es.CourseCode        AS course_id,
    es.progid            AS progid,
    es.acadyear          AS acadyear,
    es.semester          AS semester,
    COALESCE(es.StudyYear, 1) AS study_year,
    COALESCE(es.campusid, 1)  AS campus_id,
    COALESCE(es.studsession, 'Day') AS stud_session,
    'SYSTEM_BACKFILL'    AS assigned_by,
    NOW()                AS assigned_at,
    1                    AS is_active,
    'Backfilled from acad_examsettings'
FROM acad_examsettings es
WHERE es.empCode IS NOT NULL
  AND es.empCode != ''
  AND es.CourseCode IS NOT NULL
  AND es.CourseCode != ''
  AND es.progid IS NOT NULL
  AND es.progid != ''
  AND es.acadyear IS NOT NULL
  AND es.acadyear != '';

-- Step 4: Count assignments after backfill
SELECT COUNT(*) AS assignments_after FROM acad_teaching_assignments;

-- Step 5: Show newly backfilled rows
SELECT COUNT(*) AS backfilled_count
FROM acad_teaching_assignments
WHERE assigned_by = 'SYSTEM_BACKFILL';

-- Step 6: Summary by programme
SELECT ta.progid,
       COALESCE(p.progname, ta.progid) AS programme,
       COUNT(DISTINCT ta.teacher_username) AS teachers,
       COUNT(DISTINCT ta.course_id) AS courses,
       COUNT(*) AS total_assignments
FROM acad_teaching_assignments ta
LEFT JOIN acad_programme p ON p.progcode = ta.progid
WHERE ta.assigned_by = 'SYSTEM_BACKFILL'
GROUP BY ta.progid, p.progname
ORDER BY total_assignments DESC;

-- Step 7: Register migration
INSERT IGNORE INTO sys_schema_migrations (version, description, applied_by, checksum, rollback_ref)
VALUES (
    'marks_006',
    'Backfill teaching assignments from acad_examsettings',
    CURRENT_USER(),
    MD5('backfill_assignments_from_examsettings_v1'),
    'rollback_marks_backfill_assignments.sql'
);

SELECT 'Migration marks_006 (assignment backfill) complete.' AS result;
