-- ============================================================================
--  ROLLBACK for restore_MRU2026004388_registration.sql
--  Muteesa I Royal University                                     2026-08-27
--
--  Removes the restored 2026/2027 Semester 2 registration and its ten course
--  rows, and puts the two bills back on 2025/2026 semester 2.
--
--  The course delete is guarded on mark_stage='NOT_ENTERED': if marks have since
--  been captured against these rows, this refuses to remove them rather than
--  destroy a mark. Check the row count in check_2 before assuming it ran.
--
--  Safe to re-run.
-- ============================================================================

SET @reg  := 'MRU2026004388';
SET @year := '2026/2027';
SET @sem  := 2;

-- 1. Course registrations — only while still unmarked.
DELETE FROM campus_dynamics_portal.acad_course_registration
 WHERE TRIM(regno) = @reg AND acad_year = @year AND semester = @sem
   AND mark_stage = 'NOT_ENTERED'
   AND provisional_total_marks IS NULL;

-- 2. The semester registration, only if it is the one this restore created.
DELETE FROM campus_dynamics.acad_registration
 WHERE TRIM(regno) = @reg AND acad_year = @year AND semester = @sem
   AND registeredBy = 'restore-registration-20260827';

-- 3. Put the bills back exactly as the backup holds them.
UPDATE campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics.bk_restore4388_fees_20260827 b ON b.TID = f.TID
   SET f.acadyear = b.acadyear, f.semester = b.semester, f.detail = b.detail;

-- 4. Verification.
SELECT '--- 1. registration removed (expect 0) ---' AS check_1;
SELECT COUNT(*) AS registrations_remaining
  FROM campus_dynamics.acad_registration
 WHERE TRIM(regno) = @reg AND acad_year = @year AND semester = @sem;

SELECT '--- 2. course rows removed (expect 0; non-zero means marks were captured) ---' AS check_2;
SELECT COUNT(*) AS course_rows_remaining,
       SUM(provisional_total_marks IS NOT NULL) AS of_which_marked
  FROM campus_dynamics_portal.acad_course_registration
 WHERE TRIM(regno) = @reg AND acad_year = @year AND semester = @sem;

SELECT '--- 3. finance restored to backup (expect 0 differing) ---' AS check_3;
SELECT COUNT(*) AS rows_checked,
       SUM(NOT (f.acadyear <=> b.acadyear AND f.semester <=> b.semester
            AND f.amount <=> b.amount AND f.detail <=> b.detail)) AS differing
  FROM campus_dynamics.bk_restore4388_fees_20260827 b
  LEFT JOIN campus_dynamics_accounts.fin_studentfeestracking f ON f.TID = b.TID;
