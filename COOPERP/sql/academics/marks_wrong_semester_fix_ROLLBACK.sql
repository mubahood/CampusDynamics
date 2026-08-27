-- ============================================================================
--  ROLLBACK for marks_wrong_semester_fix.sql
--  Muteesa I Royal University — MRU2025002725
--
--  Restores both tables from the backups that script took. Run only if the
--  repair needs to be undone; it puts the marks back on the 2025/2026 rows and
--  re-creates the seven deleted duplicate registrations exactly as they were.
--
--  Safe to re-run.
-- ============================================================================

-- 1. Put back the seven duplicate registrations, and restore the marks and
--    stage columns on every backed-up row (the four that gave up their marks in
--    step 1 of the repair, and the seven destinations that received them).
REPLACE INTO campus_dynamics_portal.acad_course_registration
SELECT * FROM campus_dynamics.bk_wrongsem_coursereg_20260827;

-- 2. Put the four results rows back on their original term.
REPLACE INTO campus_dynamics.acad_results
SELECT * FROM campus_dynamics.bk_wrongsem_results_20260827;

-- 3. Verify the restore matches the backup exactly.
SELECT '--- registrations restored (expect 14, and 0 differences) ---' AS check_1;
SELECT COUNT(*) restored FROM campus_dynamics_portal.acad_course_registration
 WHERE ID IN (SELECT ID FROM campus_dynamics.bk_wrongsem_coursereg_20260827);

SELECT COUNT(*) rows_differing_from_backup
  FROM campus_dynamics.bk_wrongsem_coursereg_20260827 b
  JOIN campus_dynamics_portal.acad_course_registration c ON c.ID = b.ID
 WHERE NOT (c.acad_year <=> b.acad_year
        AND c.semester  <=> b.semester
        AND c.provisional_total_marks <=> b.provisional_total_marks
        AND c.provisional_course_work_marks <=> b.provisional_course_work_marks
        AND c.provisional_exam_marks <=> b.provisional_exam_marks
        AND c.mark_stage <=> b.mark_stage);

SELECT '--- results restored (expect 4, and 0 differences) ---' AS check_2;
SELECT COUNT(*) rows_differing_from_backup
  FROM campus_dynamics.bk_wrongsem_results_20260827 b
  JOIN campus_dynamics.acad_results r ON r.ID = b.ID
 WHERE NOT (r.acad <=> b.acad AND r.studyyear <=> b.studyyear
        AND r.semester <=> b.semester AND r.score <=> b.score
        AND r.grade <=> b.grade AND r.gradept <=> b.gradept);
