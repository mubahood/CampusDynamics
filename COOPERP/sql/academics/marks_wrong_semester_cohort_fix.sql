-- ============================================================================
--  Marks displayed in the wrong semester — batch-21 cohort repair
--  Muteesa I Royal University                                     2026-08-27
--
--  This is the cohort form of marks_wrong_semester_fix.sql, which repaired the
--  student who raised the problem (MRU2025002725). 18 further students carry the
--  identical defect, 45 marks in total.
--
--  THE DEFECT
--  ----------
--  These students' Year-2 Semester-2 courses were registered TWICE — once
--  correctly under 2026/2027 (when they are Year 2), and once under 2025/2026
--  sem 2 (when they were Year 1). A Dean bulk approval scoped to
--  "year of study 1, semester 2" (mark_approve_records id 21, 2,658 rows,
--  Lutamaguzi John Bosco, 2026-07-26) then swept in the Year-1-dated duplicates,
--  because by their term columns they WERE year 1 semester 2. Publishing copied
--  each mark into acad_results stamped with the registration's term, so Year-2
--  marks print under Year 1 Semester 2.
--
--  WHY ONLY THIS COHORT
--  --------------------
--  466 marks across 231 students superficially match "mark filed at a term the
--  curriculum disagrees with, while the curriculum-correct registration also
--  exists". Most must NOT be moved, and the distinctions matter:
--
--    * Direction. 74 marks sit at a study year ABOVE the curriculum year —
--      a Year-1 course marked in Year 2. That is ordinary catch-up or
--      carry-over study. Moving those marks backwards would fabricate a record
--      of the student passing in a year they did not.
--    * Provenance. 207 marks were loaded by the LEGACY_MIGRATION bulk run
--      (2026-07-27 02:41-02:42), which stamped every row with one timestamp.
--      For those, acad_results carries the historical term from the old system
--      and there is no independent evidence the term is wrong.
--    * Ambiguity. 52 marks have a destination that already holds a DIFFERENT
--      mark, and 2 have more than one candidate destination. Those need a human.
--
--  The 45 rows below are the residue where all of that is settled: the mark sits
--  at a study year BELOW the curriculum year (the student could not yet have
--  reached the course), the curriculum-correct registration exists and is EMPTY,
--  no retake is involved, and the mark came through the live staged workflow via
--  the one scoped approval that is known to have swept duplicates. All 18 are
--  2025-entry students moving 2025/2026 year 1 -> 2026/2027 year 2.
--
--  The frozen row list is campus_dynamics.fix_wrongsem_pairs_20260827, so the
--  exact rows touched can be reviewed before and after. Scores, grades and grade
--  points are never altered — only the term a mark is filed under.
--
--  Safe to re-run: every statement is idempotent.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 0. Backups.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics.bk_wrongsem_results_cohort_20260827 AS
SELECT * FROM campus_dynamics.acad_results WHERE 1 = 0;

CREATE TABLE IF NOT EXISTS campus_dynamics.bk_wrongsem_coursereg_cohort_20260827 AS
SELECT * FROM campus_dynamics_portal.acad_course_registration WHERE 1 = 0;

INSERT INTO campus_dynamics.bk_wrongsem_results_cohort_20260827
SELECT r.* FROM campus_dynamics.acad_results r
  JOIN campus_dynamics.fix_wrongsem_pairs_20260827 p ON p.result_id = r.ID
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics.bk_wrongsem_results_cohort_20260827 b
                    WHERE b.ID = r.ID);

INSERT INTO campus_dynamics.bk_wrongsem_coursereg_cohort_20260827
SELECT c.* FROM campus_dynamics_portal.acad_course_registration c
  JOIN campus_dynamics.fix_wrongsem_pairs_20260827 p ON p.src_id = c.ID OR p.dst_id = c.ID
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics.bk_wrongsem_coursereg_cohort_20260827 b
                    WHERE b.ID = c.ID);

SELECT '--- backup sizes (expect 45 results, 90 registrations) ---' AS backup_check;
SELECT (SELECT COUNT(*) FROM campus_dynamics.bk_wrongsem_results_cohort_20260827)   AS results_backed_up,
       (SELECT COUNT(*) FROM campus_dynamics.bk_wrongsem_coursereg_cohort_20260827) AS registrations_backed_up;

-- ---------------------------------------------------------------------------
-- 1. Move each mark onto the curriculum-correct registration.
--    Both sides are primary-key lookups driven by the frozen pair list.
--    The last condition makes it idempotent — a destination that already holds
--    a mark is skipped, so re-running changes nothing.
-- ---------------------------------------------------------------------------
UPDATE campus_dynamics.fix_wrongsem_pairs_20260827 p
  JOIN campus_dynamics_portal.acad_course_registration src ON src.ID = p.src_id
  JOIN campus_dynamics_portal.acad_course_registration dst ON dst.ID = p.dst_id
   SET dst.provisional_course_work_marks    = src.provisional_course_work_marks,
       dst.provisional_exam_marks           = src.provisional_exam_marks,
       dst.provisional_total_marks          = src.provisional_total_marks,
       dst.provisional_marks_status         = src.provisional_marks_status,
       dst.provisional_marks_review_comments= src.provisional_marks_review_comments,
       dst.provisional_marks_reviewed_by    = src.provisional_marks_reviewed_by,
       dst.provisional_marks_review_date    = src.provisional_marks_review_date,
       dst.provisional_submitted_by         = src.provisional_submitted_by,
       dst.provisional_published_by         = src.provisional_published_by,
       dst.provisional_published_date       = src.provisional_published_date,
       dst.mark_stage                       = src.mark_stage,
       dst.capture_record_id                = src.capture_record_id,
       dst.approve_record_id                = src.approve_record_id,
       dst.publish_record_id                = src.publish_record_id,
       dst.mark_stage_changed_at            = src.mark_stage_changed_at,
       dst.mark_stage_changed_by            = src.mark_stage_changed_by,
       dst.edit_audit_trail = TRIM(CONCAT(IFNULL(dst.edit_audit_trail, ''),
            IF(IFNULL(dst.edit_audit_trail, '') = '', '', ' | '),
            'Mark moved from duplicate registration #', src.ID,
            ' (', src.acad_year, ' sem ', src.semester, ') on 2026-08-27',
            ' — course belongs to year ', p.cur_sy, ' semester ', p.cur_sem, '.'))
 WHERE TRIM(dst.regno)    = TRIM(src.regno)      -- assertion: same student
   AND TRIM(dst.courseID) = TRIM(src.courseID)   -- assertion: same course
   AND src.provisional_total_marks IS NOT NULL
   AND dst.provisional_total_marks IS NULL;

-- ---------------------------------------------------------------------------
-- 2. Remove the duplicate registrations the marks came off.
--
--    Only once the destination is confirmed to be holding the mark, so a
--    half-applied run can never destroy a mark: if step 1 did not fire, this
--    does not fire either.
-- ---------------------------------------------------------------------------
DELETE dup FROM campus_dynamics_portal.acad_course_registration dup
  JOIN campus_dynamics.fix_wrongsem_pairs_20260827 p ON p.src_id = dup.ID
  JOIN campus_dynamics_portal.acad_course_registration keep ON keep.ID = p.dst_id
 WHERE keep.provisional_total_marks IS NOT NULL
   AND TRIM(keep.regno)    = TRIM(dup.regno)
   AND TRIM(keep.courseID) = TRIM(dup.courseID);

-- ---------------------------------------------------------------------------
-- 3. Re-stamp the results rows onto the correct term.
--    Scores, grades and grade points are deliberately untouched.
-- ---------------------------------------------------------------------------
UPDATE campus_dynamics.acad_results r
  JOIN campus_dynamics.fix_wrongsem_pairs_20260827 p ON p.result_id = r.ID
   SET r.acad = p.dst_year, r.studyyear = p.cur_sy, r.semester = p.cur_sem
 WHERE TRIM(r.regno) = p.regno AND TRIM(r.courseid) = p.course_code
   AND r.acad = p.src_year;

-- ---------------------------------------------------------------------------
-- 4. Verification.
-- ---------------------------------------------------------------------------
SELECT '--- 1. every result now at the corrected term (expect 45 / 0) ---' AS check_1;
SELECT SUM(r.acad = p.dst_year AND r.studyyear = p.cur_sy AND r.semester = p.cur_sem) AS moved,
       SUM(r.acad = p.src_year) AS still_at_old_term
  FROM campus_dynamics.fix_wrongsem_pairs_20260827 p
  JOIN campus_dynamics.acad_results r ON r.ID = p.result_id;

SELECT '--- 2. every mark now on the correct registration (expect 45 / 0) ---' AS check_2;
SELECT SUM(dst.provisional_total_marks IS NOT NULL) AS marks_on_destination,
       SUM(dst.provisional_total_marks IS NULL)     AS destinations_still_empty
  FROM campus_dynamics.fix_wrongsem_pairs_20260827 p
  JOIN campus_dynamics_portal.acad_course_registration dst ON dst.ID = p.dst_id;

SELECT '--- 3. duplicate registrations gone (expect 0) ---' AS check_3;
SELECT COUNT(*) AS duplicates_remaining
  FROM campus_dynamics_portal.acad_course_registration c
  JOIN campus_dynamics.fix_wrongsem_pairs_20260827 p ON p.src_id = c.ID;

SELECT '--- 4. no score changed anywhere (expect 0 rows) ---' AS check_4;
SELECT p.regno, p.course_code, b.score AS score_before, r.score AS score_after
  FROM campus_dynamics.fix_wrongsem_pairs_20260827 p
  JOIN campus_dynamics.bk_wrongsem_results_cohort_20260827 b ON b.ID = p.result_id
  JOIN campus_dynamics.acad_results r ON r.ID = p.result_id
 WHERE NOT (r.score <=> b.score AND r.grade <=> b.grade AND r.gradept <=> b.gradept);

SELECT '--- 5. no result row lost or re-keyed (expect 45 / 0) ---' AS check_5;
SELECT COUNT(*) AS results_still_present,
       SUM(TRIM(r.regno) <> TRIM(b.regno) OR TRIM(r.courseid) <> TRIM(b.courseid)) AS rekeyed
  FROM campus_dynamics.bk_wrongsem_results_cohort_20260827 b
  LEFT JOIN campus_dynamics.acad_results r ON r.ID = b.ID;

SELECT '--- 6. per-student summary of the corrected terms ---' AS check_6;
SELECT p.regno, COUNT(*) AS marks_moved,
       CONCAT(MIN(p.src_year), ' yr', MIN(p.cur_sy) - 1, ' -> ',
              MIN(p.dst_year), ' yr', MIN(p.cur_sy)) AS correction
  FROM campus_dynamics.fix_wrongsem_pairs_20260827 p
 GROUP BY p.regno ORDER BY marks_moved DESC, p.regno;
