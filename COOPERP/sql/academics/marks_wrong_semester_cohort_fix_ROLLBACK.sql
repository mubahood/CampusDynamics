-- ============================================================================
--  ROLLBACK for marks_wrong_semester_cohort_fix.sql
--  Muteesa I Royal University                                     2026-08-27
--
--  Restores the 18 students' 45 marks to the terms they were filed under before
--  the repair, and re-creates the duplicate registrations it deleted.
--  Safe to re-run.
-- ============================================================================

-- 1. Re-create the deleted duplicate registrations and restore both sides of
--    every pair to their pre-repair state.
REPLACE INTO campus_dynamics_portal.acad_course_registration
SELECT * FROM campus_dynamics.bk_wrongsem_coursereg_cohort_20260827;

-- 2. Restore the results rows to their original term.
REPLACE INTO campus_dynamics.acad_results
SELECT * FROM campus_dynamics.bk_wrongsem_results_cohort_20260827;

-- 3. Verify the restore is exact.
SELECT '--- registrations restored (expect 90 / 0 differing) ---' AS check_1;
SELECT COUNT(*) AS restored,
       SUM(NOT (c.acad_year <=> b.acad_year
            AND c.semester  <=> b.semester
            AND c.provisional_total_marks <=> b.provisional_total_marks
            AND c.provisional_course_work_marks <=> b.provisional_course_work_marks
            AND c.provisional_exam_marks <=> b.provisional_exam_marks
            AND c.mark_stage <=> b.mark_stage)) AS differing
  FROM campus_dynamics.bk_wrongsem_coursereg_cohort_20260827 b
  LEFT JOIN campus_dynamics_portal.acad_course_registration c ON c.ID = b.ID;

SELECT '--- results restored (expect 45 / 0 differing) ---' AS check_2;
SELECT COUNT(*) AS restored,
       SUM(NOT (r.acad <=> b.acad AND r.studyyear <=> b.studyyear
            AND r.semester <=> b.semester AND r.score <=> b.score
            AND r.grade <=> b.grade AND r.gradept <=> b.gradept)) AS differing
  FROM campus_dynamics.bk_wrongsem_results_cohort_20260827 b
  LEFT JOIN campus_dynamics.acad_results r ON r.ID = b.ID;
