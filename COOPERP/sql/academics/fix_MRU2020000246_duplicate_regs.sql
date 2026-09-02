-- ============================================================================
--  MRU2020000246  GASTER SSENTAMU  ·  BEICT (3-year, Semester)
--  Tidy the course record: remove superseded empty duplicates
--  Muteesa I Royal University                                     2026-09-02
--
--  WHAT WAS WRONG
--
--  65 course registrations across 7 sittings, of which 21 carried no mark. Twelve
--  courses were registered TWICE, and one course code does not exist.
--
--  For ten of those twelve, one copy carries a published mark and the other is
--  empty — the student registered, was not marked, and the course was registered
--  again later when they actually sat it. The empty copy is a leftover:
--
--      BHI1201   2020/2021 S2 empty   ->  2021/2022 S1 = 60 published
--      ICT2115B  2021/2022 S2 empty   ->  2021/2022 S1 = 82 published
--      BHI2205   2021/2022 S2 empty   ->  2022/2023 S2 = 66 published
--      ICT2205B  2021/2022 S2 empty   ->  2025/2026 S2 = 50 published
--      BCU3201   2022/2023 S2 empty   ->  2025/2026 S2 = 78 published
--      BEF 3201  2022/2023 S2 empty   ->  2025/2026 S2 = 70 published
--      BGC3201   2022/2023 S2 empty   ->  2025/2026 S2 = 58 published
--      BHI3209   2022/2023 S2 empty   ->  2025/2026 S2 = 72 published
--      ICT3201B  2022/2023 S2 empty   ->  2025/2026 S2 = 57 published
--      ICT3205B  2022/2023 S2 empty   ->  2025/2026 S2 = 72 published
--
--  Two more are registered twice with NO mark on either — BHI3208 and BSP3202 are
--  genuinely still outstanding. The 2022/2023 copy is dropped and the live
--  2025/2026 attempt kept, so the student has one open registration per course
--  rather than two.
--
--  One code is a phantom: ICT2202 has no catalogue entry and no place in any
--  programme. Across the whole register it appears 33 times for 30 students and
--  has NEVER carried a mark. The real code is ICT2202B, DATABASE PROGRAMMING,
--  Year 2 Semester 2 — 952 registrations, 891 of them marked — and this student
--  now has it.
--
--  WHAT IS NOT CHANGED, AND WHY
--
--  The seventh sitting, 2025/2026 Semester 2, is REAL and stays. Seven of its nine
--  courses carry published marks for papers the student registered for in
--  2022/2023 and was never marked on. They are Year 3 courses sat after the
--  programme's nominal end — ordinary carry-over study. Moving those marks back to
--  2022/2023 would fabricate a pass in a sitting the student did not complete, so
--  the record correctly shows a 3-year programme finished with a later catch-up
--  semester.
--
--  Nothing carrying a mark is touched. Every row removed is empty, and none of
--  them has a row in acad_results — checked before writing this.
--
--  SAFETY
--
--  The DELETE is keyed on the thirteen exact IDs AND re-asserts
--  provisional_total_marks IS NULL, so if a mark has been entered since this was
--  written that row is skipped rather than destroyed. Every row is copied to a
--  backup table first, and the rollback at the foot restores them exactly.
-- ============================================================================

-- ── 1. backup ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS campus_dynamics_portal.acad_course_registration_bak_MRU2020000246_20260902
  LIKE campus_dynamics_portal.acad_course_registration;

INSERT INTO campus_dynamics_portal.acad_course_registration_bak_MRU2020000246_20260902
SELECT * FROM campus_dynamics_portal.acad_course_registration
WHERE ID IN (68436,12455,12449,68434,12451,67078,66309,66306,67076,66305,66307,67075,66308);

SELECT CONCAT('backed up: ', COUNT(*), ' rows')
FROM campus_dynamics_portal.acad_course_registration_bak_MRU2020000246_20260902;

-- ── 2. before ───────────────────────────────────────────────────────────────
SELECT 'BEFORE' AS stage, acad_year, semester,
       COUNT(*) courses, SUM(provisional_total_marks IS NOT NULL) marked
FROM campus_dynamics_portal.acad_course_registration
WHERE regno='MRU2020000246' GROUP BY acad_year, semester ORDER BY acad_year, semester;

-- ── 3. the delete ───────────────────────────────────────────────────────────
--  The mark guard is deliberate: it makes this statement safe to run twice, and
--  refuses to remove anything that has gained a mark since the analysis.
DELETE FROM campus_dynamics_portal.acad_course_registration
WHERE regno = 'MRU2020000246'
  AND provisional_total_marks IS NULL
  AND ID IN (68436,12455,12449,68434,12451,67078,66309,66306,67076,66305,66307,67075,66308);

SELECT CONCAT('removed: ', ROW_COUNT(), ' rows') AS result;

-- ── 4. after ────────────────────────────────────────────────────────────────
SELECT 'AFTER' AS stage, acad_year, semester,
       COUNT(*) courses, SUM(provisional_total_marks IS NOT NULL) marked
FROM campus_dynamics_portal.acad_course_registration
WHERE regno='MRU2020000246' GROUP BY acad_year, semester ORDER BY acad_year, semester;

-- No course should now appear twice.
SELECT courseID, COUNT(*) n
FROM campus_dynamics_portal.acad_course_registration
WHERE regno='MRU2020000246' GROUP BY courseID HAVING n > 1;

-- Every mark must still be there: 44 before, 44 after.
SELECT CONCAT('marks still present: ', COUNT(*)) AS check_marks
FROM campus_dynamics_portal.acad_course_registration
WHERE regno='MRU2020000246' AND provisional_total_marks IS NOT NULL;

-- And the transcript must be untouched: 44 results.
SELECT CONCAT('results on transcript: ', COUNT(*)) AS check_results
FROM campus_dynamics.acad_results WHERE regno='MRU2020000246';

-- ============================================================================
--  ROLLBACK — puts every removed row back exactly as it was.
--
--    INSERT INTO campus_dynamics_portal.acad_course_registration
--    SELECT * FROM campus_dynamics_portal.acad_course_registration_bak_MRU2020000246_20260902;
--
--  Then confirm 65 rows again:
--    SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration
--    WHERE regno='MRU2020000246';
-- ============================================================================
