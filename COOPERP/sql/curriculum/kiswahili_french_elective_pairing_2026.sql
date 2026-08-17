-- =====================================================================
--  Foreign language: French OR Kiswahili — Tourism & Hotel Management
--
--  Mr Kabuye, 15 August 2026: "let's maintain them to be elective such that
--  the students can choose for the future, in that one can choose either
--  French or Kiswahili."
--
--  The Kiswahili units were created as ELECTIVE, but the French units they
--  sit beside were left CORE. That is not a choice: it required French and
--  merely permitted Kiswahili on top. Both sides of each slot are now
--  ELECTIVE, so the student takes one or the other.
--
--  Only the course_type label changes. Nothing is added, removed or
--  re-coded, no registration or mark is touched, and course_type is read by
--  the curriculum screens for display and filtering only — no registration
--  path enforces it, and the student portal does not reference it at all.
--
--  Re-runnable.
-- =====================================================================
USE campus_dynamics;

START TRANSACTION;

UPDATE acad_programmecourses
   SET course_type = 'ELECTIVE'
 WHERE progcode IN ('BTHM','DTHM')
   AND study_year = 2
   AND course_code IN ('THM2105B','THM2205B','THM2104D','THM2204D');

COMMIT;

-- Verification: every language slot should now offer two ELECTIVE options.
SELECT '=== each slot is now a choice ===' AS x;
SELECT pc.progcode, pc.study_year AS yr, pc.semester AS sem,
       pc.course_code, LEFT(c.courseName,46) AS course, c.CreditUnit AS cu, pc.course_type
  FROM acad_programmecourses pc
  JOIN acad_course c ON c.courseID = pc.course_code
 WHERE pc.progcode IN ('BTHM','DTHM') AND pc.study_year = 2
   AND c.courseName LIKE '%LANGUAGE%'
 ORDER BY pc.progcode, pc.semester, pc.course_code;

SELECT '=== no CORE language unit is left in these slots ===' AS x;
SELECT COUNT(*) AS still_core
  FROM acad_programmecourses pc
  JOIN acad_course c ON c.courseID = pc.course_code
 WHERE pc.progcode IN ('BTHM','DTHM') AND pc.study_year = 2
   AND c.courseName LIKE '%LANGUAGE%' AND UPPER(IFNULL(pc.course_type,'CORE')) = 'CORE';

SELECT '=== registrations and marks are untouched ===' AS x;
SELECT c.courseID, c.CreditUnit AS cu,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr WHERE cr.courseID = c.courseID) AS regs,
       (SELECT COUNT(*) FROM acad_results r WHERE r.courseid = c.courseID) AS results
  FROM acad_course c
 WHERE c.courseID IN ('THM2105B','THM2205B','THM2104D','THM2204D','THM2109B','THM2211B','THM2109D','THM2211D')
 ORDER BY c.courseID;
