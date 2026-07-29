-- ============================================================================
-- programmecourses_cleanup_01.sql
-- Zero-loss cleanup of junk rows in campus_dynamics.acad_programmecourses
-- Ref: PROGRAMMECOURSES_PHANTOM_DUP_ANALYSIS.md   Date: 2026-07-18
--
-- Removes ONLY genuinely inert rows (109 expected):
--   * blank course_code           (mapping points at no course)          16
--   * blank / '-' progcode         (mapping under an invalid programme)   93
-- HARD GUARDS (a row is skipped if ANY is true):
--   * is_lecturere_assigned = YES  (would drop a real lecturer assignment)
--   * a matching acad_course_registration exists (real students)
--   * a matching acad_results row exists          (real marks)
--
-- NOTHING is hard-deleted: every removed row is copied verbatim into
-- acad_programmecourses_quarantine first, and the whole table is backed up.
-- Fully reversible — see RESTORE section at the bottom.
-- ============================================================================

USE campus_dynamics;

-- ---- STEP 1: DDL (implicit commit in MySQL 5.6 — kept out of the txn) ------
-- Full table backup (one-time; safe to keep).
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_programmecourses_bak_20260718
  LIKE campus_dynamics.acad_programmecourses;
INSERT INTO campus_dynamics.acad_programmecourses_bak_20260718
  SELECT * FROM campus_dynamics.acad_programmecourses
  WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_programmecourses_bak_20260718 b
                    WHERE b.ID = acad_programmecourses.ID);

-- Quarantine table = full row + provenance columns.
-- (MySQL 5.6 has no ADD COLUMN IF NOT EXISTS; guard each add via information_schema.)
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_programmecourses_quarantine
  LIKE campus_dynamics.acad_programmecourses;

SET @c := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='campus_dynamics'
           AND table_name='acad_programmecourses_quarantine' AND column_name='q_reason');
SET @s := IF(@c=0,'ALTER TABLE campus_dynamics.acad_programmecourses_quarantine ADD COLUMN q_reason VARCHAR(40) NULL','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='campus_dynamics'
           AND table_name='acad_programmecourses_quarantine' AND column_name='q_batch');
SET @s := IF(@c=0,'ALTER TABLE campus_dynamics.acad_programmecourses_quarantine ADD COLUMN q_batch VARCHAR(40) NULL','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='campus_dynamics'
           AND table_name='acad_programmecourses_quarantine' AND column_name='q_at');
SET @s := IF(@c=0,'ALTER TABLE campus_dynamics.acad_programmecourses_quarantine ADD COLUMN q_at DATETIME NULL','DO 0');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

-- ---- STEP 2: DML (transactional: quarantine THEN delete, atomically) ------
START TRANSACTION;

INSERT INTO campus_dynamics.acad_programmecourses_quarantine
SELECT pc.*,
       CASE WHEN TRIM(IFNULL(pc.course_code,''))='' THEN 'BLANK_COURSE_CODE'
            ELSE 'BLANK_OR_DASH_PROGCODE' END,
       'cleanup_01_20260718',
       '2026-07-18 00:00:00'
FROM campus_dynamics.acad_programmecourses pc
WHERE ( TRIM(IFNULL(pc.course_code,''))='' OR TRIM(IFNULL(pc.progcode,'')) IN ('','-') )
  AND UPPER(IFNULL(pc.is_lecturere_assigned,'No')) <> 'YES'
  AND NOT EXISTS (SELECT 1 FROM campus_dynamics_portal.acad_course_registration r
        WHERE TRIM(r.prog_id)=TRIM(pc.progcode) AND TRIM(r.courseID)=TRIM(pc.course_code))
  AND NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_results x
        WHERE TRIM(x.progid)=TRIM(pc.progcode) AND TRIM(x.courseid)=TRIM(pc.course_code));

DELETE pc FROM campus_dynamics.acad_programmecourses pc
WHERE ( TRIM(IFNULL(pc.course_code,''))='' OR TRIM(IFNULL(pc.progcode,'')) IN ('','-') )
  AND UPPER(IFNULL(pc.is_lecturere_assigned,'No')) <> 'YES'
  AND NOT EXISTS (SELECT 1 FROM campus_dynamics_portal.acad_course_registration r
        WHERE TRIM(r.prog_id)=TRIM(pc.progcode) AND TRIM(r.courseID)=TRIM(pc.course_code))
  AND NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_results x
        WHERE TRIM(x.progid)=TRIM(pc.progcode) AND TRIM(x.courseid)=TRIM(pc.course_code));

COMMIT;

-- ---- STEP 3: verification (run after commit) ------------------------------
-- Expect: quarantined = 109, remaining junk = 0.
-- SELECT COUNT(*) quarantined FROM campus_dynamics.acad_programmecourses_quarantine
--   WHERE q_batch='cleanup_01_20260718';
-- SELECT COUNT(*) remaining_junk FROM campus_dynamics.acad_programmecourses
--   WHERE TRIM(IFNULL(course_code,''))='' OR TRIM(IFNULL(progcode,'')) IN ('','-');

-- ============================================================================
-- RESTORE (undo this batch completely):
--   START TRANSACTION;
--   INSERT INTO campus_dynamics.acad_programmecourses
--     SELECT progcode,course_code,study_year,semester,ID,CurriculumID,specialisation_id,
--            course_type,is_lecturere_assigned,lecturer_id,supervisor_id,status,
--            allocation_request_status,allocation_request_lecturer_id,allocation_request_date,
--            allocation_request_message,allocation_request_admin_status,allocation_request_admin_message
--     FROM campus_dynamics.acad_programmecourses_quarantine
--     WHERE q_batch='cleanup_01_20260718';
--   DELETE FROM campus_dynamics.acad_programmecourses_quarantine WHERE q_batch='cleanup_01_20260718';
--   COMMIT;
-- (Full table also recoverable from acad_programmecourses_bak_20260718.)
-- ============================================================================
