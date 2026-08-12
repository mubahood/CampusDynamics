-- ============================================================================
--  Course-code harmonisation, BEICT Year 2 Semester 2 — master + curriculum
--  (run AFTER harmonise_codes.sql, which moves the marks themselves)
-- ============================================================================
--  The marks migration retired three codes by moving their rows onto the
--  canonical code. This finishes the job in the course master and the
--  curriculum, so that the codes the reports now read actually resolve.
-- ============================================================================

START TRANSACTION;

-- 1. ECO2201 had no master record at all — the canonical code existed only as
--    the spaced 'ECO 2201'. Create it from that record so the 42 moved result
--    rows resolve to a name and credit unit instead of showing blank.
INSERT INTO campus_dynamics.acad_course
       (courseID, courseName, CreditUnit, ContactHr, LectureHr, PracticalHr,
        courseDescription, stat, CoreStatus, subject_id, course_state, specialisation_scope)
SELECT 'ECO2201', courseName, CreditUnit, ContactHr, LectureHr, PracticalHr,
       courseDescription, stat, CoreStatus, subject_id, 'ACTIVE', specialisation_scope
  FROM campus_dynamics.acad_course
 WHERE courseID = 'ECO 2201'
   AND NOT EXISTS (SELECT 1 FROM (SELECT courseID FROM campus_dynamics.acad_course) x WHERE x.courseID = 'ECO2201');

-- 2. Retire the spaced codes that are now empty, using the convention already
--    established by the earlier dedup (course_state MERGED + merged_into).
--    'BCU 2203' is deliberately NOT retired: 18 rows could not move because the
--    student already holds a DIFFERENT mark under BCU2203 for the same sitting.
--    Those are conflicting marks and are an academic decision, not cleanup.
UPDATE campus_dynamics.acad_course
   SET course_state = 'MERGED', merged_into = 'ECO2201', merged_at = NOW(), dedup_category = 'A_WITHIN_PROG'
 WHERE courseID = 'ECO 2201';

UPDATE campus_dynamics.acad_course
   SET course_state = 'MERGED', merged_into = 'ECO2204', merged_at = NOW(), dedup_category = 'A_WITHIN_PROG'
 WHERE courseID = 'ECO 2204';

-- 3. Course name correction (§7): the officially approved spelling.
UPDATE campus_dynamics.acad_course
   SET courseName = 'DATABASE PROGRAMMING'
 WHERE courseID = 'BIT2204' AND courseName = 'DATA BASE PROGARAMMING';

-- 4. ICT2115B is a genuine Year 2 SEMESTER 1 course — 309 of its 333 result rows
--    sit in semester 1, across eleven academic years, and its code says so
--    (ICT-2-1-15-B). It reached this Semester 2 report through ONE curriculum row
--    mapping it to BEICT year 2 semester 2. That row is the defect; its Year 2
--    Semester 1 mappings are correct and stay.
CREATE TABLE IF NOT EXISTS campus_dynamics.bak_codeharmonise_20260812_curriculum (
    ID INT NOT NULL, progcode VARCHAR(45), course_code VARCHAR(60),
    study_year INT, semester INT, specialisation_id INT UNSIGNED, removed_at DATETIME,
    PRIMARY KEY (ID)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO campus_dynamics.bak_codeharmonise_20260812_curriculum
SELECT ID, progcode, course_code, study_year, semester, specialisation_id, NOW()
  FROM campus_dynamics.acad_programmecourses
 WHERE course_code = 'ICT2115B' AND progcode = 'BEICT' AND study_year = 2 AND semester = 2;

DELETE FROM campus_dynamics.acad_programmecourses
 WHERE course_code = 'ICT2115B' AND progcode = 'BEICT' AND study_year = 2 AND semester = 2;

INSERT INTO campus_dynamics.acad_activity_log (user_id, page_function, par, comments, access_date)
VALUES ('admin', 'Course Code Harmonisation', 'BEICT Y2 S2',
        'Merged BCU 2203/ECO 2201/ECO 2204 into unspaced codes; moved 2025/2026 Sem2 ICT2115B marks to BIT2201B; removed the ICT2115B BEICT Y2S2 curriculum row', NOW());

COMMIT;

SELECT '=== master records after ===' AS step;
SELECT CONCAT('[',courseID,']') code, courseName, CreditUnit, course_state, IFNULL(merged_into,'') merged_into
  FROM campus_dynamics.acad_course
 WHERE courseID IN ('ECO 2201','ECO2201','ECO 2204','ECO2204','BCU 2203','BCU2203','ICT2115B','BIT2201B','BIT2204')
 ORDER BY courseID;
