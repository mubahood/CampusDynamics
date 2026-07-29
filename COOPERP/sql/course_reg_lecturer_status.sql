-- ============================================================================
-- course_reg_lecturer_status.sql
-- Adds the lecturer-controlled approval status to course registrations.
--   lecturer_status: PENDING (default, new regs) | APPROVED | REMOVED
-- Backfill (one-time): acad_year >= '2026/2027' -> APPROVED ; older -> REMOVED.
-- Idempotent: safe to run more than once. Target DB: campus_dynamics_portal.
-- Gate scope: ODEL online-course participation only (see COURSE_REG_LECTURER_STATUS_PLAN.md).
-- ============================================================================
USE campus_dynamics_portal;

-- ---- columns (MySQL 5.6 has no ADD COLUMN IF NOT EXISTS; guard via information_schema) ----
SET @c := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE()
           AND table_name='acad_course_registration' AND column_name='lecturer_status');
SET @s := IF(@c=0,'ALTER TABLE acad_course_registration ADD COLUMN lecturer_status VARCHAR(10) NOT NULL DEFAULT ''PENDING''','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE()
           AND table_name='acad_course_registration' AND column_name='lecturer_status_by');
SET @s := IF(@c=0,'ALTER TABLE acad_course_registration ADD COLUMN lecturer_status_by VARCHAR(150) NULL','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE()
           AND table_name='acad_course_registration' AND column_name='lecturer_status_at');
SET @s := IF(@c=0,'ALTER TABLE acad_course_registration ADD COLUMN lecturer_status_at DATETIME NULL','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

-- index for the lecturer console section counts
SET @c := (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE()
           AND table_name='acad_course_registration' AND index_name='idx_lecturer_status');
SET @s := IF(@c=0,'ALTER TABLE acad_course_registration ADD INDEX idx_lecturer_status (lecturer_status)','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

-- ---- one-time backfill, gated so it can NEVER re-approve new PENDING rows ----
-- Runs only when the table has never been stamped (first initialization). Current/future
-- academic year -> active (APPROVED); older years -> completed (REMOVED). After the first
-- run, @already>0 forever, so later new registrations keep their PENDING default.
SET @already := (SELECT COUNT(*) FROM acad_course_registration WHERE lecturer_status_at IS NOT NULL);
UPDATE acad_course_registration
SET lecturer_status = CASE WHEN TRIM(acad_year) >= '2026/2027' THEN 'APPROVED' ELSE 'REMOVED' END,
    lecturer_status_by = 'system_backfill',
    lecturer_status_at = NOW()
WHERE lecturer_status_at IS NULL AND @already = 0;

-- ---- verify (run manually) ----
-- SELECT lecturer_status, COUNT(*) FROM acad_course_registration GROUP BY lecturer_status;
-- Expect: APPROVED ~4976, REMOVED ~125445, PENDING = new regs created after this ran.
