-- ============================================================================
--  Marks displayed in the wrong semester — duplicate-registration repair
--  Muteesa I Royal University
--
--  THE FAULT
--  ---------
--  A student's course set was registered TWICE: once under the correct term,
--  and once under an earlier term at the wrong study year. Example that raised
--  this — MRU2025002725 (DPE, in-service): all seven Year-2 Semester-2 courses
--  appear both under 2025/2026 sem 2 (where she was a YEAR 1 student) and under
--  2026/2027 sem 2 (where she is a YEAR 2 student, which is correct).
--
--  A Dean bulk-approval scoped to "year of study 1, semester 2"
--  (mark_approve_records id 21, 2,658 rows) then swept in those duplicates,
--  because as far as the term columns were concerned they WERE year 1 sem 2.
--  Publishing copied each mark into acad_results stamped with the registration's
--  term, so the transcript prints Year-2 marks under Year 1 Semester 2.
--
--  Note the four affected registrations already carry lecturer_status='REMOVED'
--  — the duplicates had been recognised as wrong, but the marks stayed on them.
--
--  THE REPAIR
--  ----------
--  Marks are MOVED onto the curriculum-correct registration, never re-keyed or
--  re-graded. Scores are untouched. Then the phantom duplicate registrations are
--  removed, and acad_results is re-stamped with the correct term.
--
--  Safe to re-run: every statement is keyed on explicit row IDs and is a no-op
--  once applied. Backups are taken first; the rollback script restores them.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 0. Backups. Nothing below runs until these exist.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics.bk_wrongsem_results_20260827 AS
SELECT * FROM campus_dynamics.acad_results WHERE 1 = 0;

CREATE TABLE IF NOT EXISTS campus_dynamics.bk_wrongsem_coursereg_20260827 AS
SELECT * FROM campus_dynamics_portal.acad_course_registration WHERE 1 = 0;

INSERT INTO campus_dynamics.bk_wrongsem_results_20260827
SELECT r.* FROM campus_dynamics.acad_results r
 WHERE r.ID IN (671508, 671509, 671510, 671511)
   AND NOT EXISTS (SELECT 1 FROM campus_dynamics.bk_wrongsem_results_20260827 b WHERE b.ID = r.ID);

INSERT INTO campus_dynamics.bk_wrongsem_coursereg_20260827
SELECT c.* FROM campus_dynamics_portal.acad_course_registration c
 WHERE c.ID IN (149952, 149953, 149954, 149955, 149956, 149957, 149958,
                150614, 150615, 150616, 150617, 150618, 150619, 150620)
   AND NOT EXISTS (SELECT 1 FROM campus_dynamics.bk_wrongsem_coursereg_20260827 b WHERE b.ID = c.ID);

-- ---------------------------------------------------------------------------
-- 1. Move each published mark onto the curriculum-correct registration.
--
--    from (2025/2026 sem 2, study year 1)  ->  to (2026/2027 sem 2, study year 2)
--      DEC2201D  149957 -> 150619        DEC2202D  149952 -> 150614
--      DEL2201D  149954 -> 150616        DEL2202D  149958 -> 150620
--
--    The mapping is expressed as a CASE on the primary key so BOTH sides are
--    single-row primary-key lookups. (Writing it as a row-constructor IN list
--    instead — (src.ID, dst.ID) IN ((..),(..)) — is NOT optimisable: MySQL
--    cannot drive an index from it and joins the 693k-row table against itself.
--    That form was tried and had to be killed.)
--
--    Same-student and same-course equality is asserted in the WHERE clause, so
--    a row can only ever receive the mark belonging to its own course while the
--    assertions stay out of the query plan. The final two conditions make this
--    idempotent: once the destination holds a mark, the statement stops
--    matching, so a re-run changes nothing.
-- ---------------------------------------------------------------------------
UPDATE campus_dynamics_portal.acad_course_registration src
  JOIN campus_dynamics_portal.acad_course_registration dst
    ON dst.ID = CASE src.ID WHEN 149957 THEN 150619
                            WHEN 149952 THEN 150614
                            WHEN 149954 THEN 150616
                            WHEN 149958 THEN 150620 END
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
            ' — course belongs to year 2 semester 2.'))
 WHERE src.ID IN (149957, 149952, 149954, 149958)
   AND TRIM(dst.regno)    = TRIM(src.regno)      -- assertion: same student
   AND TRIM(dst.courseID) = TRIM(src.courseID)   -- assertion: same course
   AND src.provisional_total_marks IS NOT NULL
   AND dst.provisional_total_marks IS NULL;

-- ---------------------------------------------------------------------------
-- 2. Remove the seven phantom registrations filed under 2025/2026 sem 2.
--
--    Guarded three ways: explicit IDs, the wrong term, and — the important one —
--    a self-join proving the course is also registered under 2026/2027 sem 2.
--    A duplicate is never deleted unless its replacement exists and either
--    carries the marks or the duplicate had none, so this statement cannot
--    orphan a result. (Written as a join rather than a subquery: MySQL cannot
--    read the delete target in a subquery, and a derived table would
--    materialise the whole 693k-row registration table. The pairing is again a
--    CASE on the primary key so both sides are single-row lookups.)
-- ---------------------------------------------------------------------------
DELETE dup FROM campus_dynamics_portal.acad_course_registration dup
  JOIN campus_dynamics_portal.acad_course_registration keep
    ON keep.ID = CASE dup.ID WHEN 149952 THEN 150614   -- DEC2202D
                             WHEN 149953 THEN 150615   -- DGC2201D
                             WHEN 149954 THEN 150616   -- DEL2201D
                             WHEN 149955 THEN 150617   -- DEC2203D
                             WHEN 149956 THEN 150618   -- DEE2201D
                             WHEN 149957 THEN 150619   -- DEC2201D
                             WHEN 149958 THEN 150620   -- DEL2202D
                 END
 WHERE dup.ID IN (149952, 149953, 149954, 149955, 149956, 149957, 149958)
   AND dup.acad_year  = '2025/2026' AND dup.semester  = 2
   AND keep.acad_year = '2026/2027' AND keep.semester = 2
   AND TRIM(keep.regno)    = TRIM(dup.regno)      -- assertion: same student
   AND TRIM(keep.courseID) = TRIM(dup.courseID)   -- assertion: same course
   AND (keep.provisional_total_marks IS NOT NULL
        OR dup.provisional_total_marks IS NULL);

-- ---------------------------------------------------------------------------
-- 3. Re-stamp the four results rows onto the correct term.
--    Scores, grades and grade points are deliberately not touched.
-- ---------------------------------------------------------------------------
UPDATE campus_dynamics.acad_results
   SET acad = '2026/2027', studyyear = 2, semester = 2
 WHERE ID IN (671508, 671509, 671510, 671511)
   AND TRIM(regno) = 'MRU2025002725'
   AND acad = '2025/2026';

-- ---------------------------------------------------------------------------
-- 4. Verification — read the result of the repair.
-- ---------------------------------------------------------------------------
SELECT '--- results by term (all seven year-2 courses must read 2026/2027 / 2 / 2) ---' AS check_1;
SELECT acad, studyyear, semester, COUNT(*) courses,
       GROUP_CONCAT(TRIM(courseid) ORDER BY courseid SEPARATOR ' ') list
  FROM campus_dynamics.acad_results
 WHERE TRIM(regno) = 'MRU2025002725'
 GROUP BY acad, studyyear, semester
 ORDER BY acad, studyyear, semester;

SELECT '--- registrations (2025/2026 sem 2 must hold 7 year-1 courses only) ---' AS check_2;
SELECT acad_year, semester, COUNT(*) n,
       GROUP_CONCAT(TRIM(courseID) ORDER BY courseID SEPARATOR ' ') list
  FROM campus_dynamics_portal.acad_course_registration
 WHERE TRIM(regno) = 'MRU2025002725'
 GROUP BY acad_year, semester ORDER BY acad_year, semester;

SELECT '--- every year-2 mark must now sit on the 2026/2027 registration ---' AS check_3;
SELECT TRIM(courseID) course, acad_year, semester, provisional_total_marks total, mark_stage
  FROM campus_dynamics_portal.acad_course_registration
 WHERE TRIM(regno) = 'MRU2025002725'
   AND TRIM(courseID) IN ('DEC2201D','DEC2202D','DEC2203D','DEE2201D',
                          'DEL2201D','DEL2202D','DGC2201D')
 ORDER BY courseID;

SELECT '--- no mark may have been lost: expect 19 results, 7 with year-2 codes ---' AS check_4;
SELECT COUNT(*) total_results,
       SUM(TRIM(courseid) IN ('DEC2201D','DEC2202D','DEC2203D','DEE2201D',
                              'DEL2201D','DEL2202D','DGC2201D')) year2_results
  FROM campus_dynamics.acad_results WHERE TRIM(regno) = 'MRU2025002725';
