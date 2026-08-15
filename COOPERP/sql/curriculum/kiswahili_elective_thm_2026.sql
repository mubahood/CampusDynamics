-- =====================================================================
--  FOREIGN LANGUAGE (KISWAHILI) — Tourism & Hotel Management, Year 2
--
--  Requested by Mr Joseph Kabuye, 14 August 2026, following the
--  Examinations Board: an elective Kiswahili unit alongside the existing
--  French one, for students taking the Kiswahili option.
--
--  THE REQUESTED CODES COULD NOT BE USED. All three distinct codes in the
--  request are already occupied by live units carrying student data:
--
--    THM2105B  FOREIGN LANGUAGE ( SWAHILI, FRENCH, GERMAN) 1   235 regs / 224 results
--    THM2205B  FOREIGN LANGUAGE II                             225 regs / 223 results
--    THM2204D  FOREIGN LANGUAGE (FRENCH)                        86 regs /  86 results
--
--  (The request also listed THM2204D twice for the Diploma; the Diploma's
--  two language slots are in fact THM2104D in Semester 1 and THM2204D in
--  Semester 2.)
--
--  New codes therefore continue each programme's existing series, and the
--  credit units mirror the French unit each one sits beside, so a student
--  taking Kiswahili earns exactly what a student taking French earns in
--  the same slot.
--
--    BTHM Y2 S1  THM2109B  3 CU   (beside THM2105B, 3 CU)
--    BTHM Y2 S2  THM2211B  3 CU   (beside THM2205B, 3 CU)
--    DTHM Y2 S1  THM2109D  3 CU   (beside THM2104D, 3 CU)
--    DTHM Y2 S2  THM2211D  2 CU   (beside THM2204D, 2 CU)
--
--  Re-runnable: every statement is INSERT ... ON DUPLICATE / guarded.
-- =====================================================================
USE campus_dynamics;

START TRANSACTION;

-- 1. Subject layer. One subject per level of the unit, shared by the degree
--    and the diploma, which is what is_shared/course_count exist to record.
INSERT INTO acad_subject (subject_name, norm_name, is_shared, course_count, created_at, updated_at)
VALUES ('FOREIGN LANGUAGE (KISWAHILI) I',  'FOREIGN LANGUAGE (KISWAHILI) I',  1, 2, NOW(), NOW()),
       ('FOREIGN LANGUAGE (KISWAHILI) II', 'FOREIGN LANGUAGE (KISWAHILI) II', 1, 2, NOW(), NOW())
ON DUPLICATE KEY UPDATE is_shared=VALUES(is_shared), course_count=VALUES(course_count), updated_at=NOW();

SET @sub1 = (SELECT subject_id FROM acad_subject WHERE norm_name='FOREIGN LANGUAGE (KISWAHILI) I'  LIMIT 1);
SET @sub2 = (SELECT subject_id FROM acad_subject WHERE norm_name='FOREIGN LANGUAGE (KISWAHILI) II' LIMIT 1);

-- 2. The four course units.
INSERT INTO acad_course
    (courseID, courseName, CreditUnit, ContactHr, LectureHr, PracticalHr, stat, CoreStatus,
     subject_id, course_state, specialisation_scope, dedup_category)
VALUES
    ('THM2109B', 'FOREIGN LANGUAGE (KISWAHILI) I',  3, 45, 45, 0, 'Active', 'Elective', @sub1, 'ACTIVE', 184, 'D_SPECIALISATION'),
    ('THM2211B', 'FOREIGN LANGUAGE (KISWAHILI) II', 3, 45, 45, 0, 'Active', 'Elective', @sub2, 'ACTIVE', 184, 'D_SPECIALISATION'),
    ('THM2109D', 'FOREIGN LANGUAGE (KISWAHILI) I',  3, 45, 45, 0, 'Active', 'Elective', @sub1, 'ACTIVE', 191, 'D_SPECIALISATION'),
    ('THM2211D', 'FOREIGN LANGUAGE (KISWAHILI) II', 2, 45, 45, 0, 'Active', 'Elective', @sub2, 'ACTIVE', 191, 'D_SPECIALISATION')
ON DUPLICATE KEY UPDATE
    courseName=VALUES(courseName), CreditUnit=VALUES(CreditUnit), ContactHr=VALUES(ContactHr),
    LectureHr=VALUES(LectureHr), PracticalHr=VALUES(PracticalHr), stat=VALUES(stat),
    CoreStatus=VALUES(CoreStatus), subject_id=VALUES(subject_id), course_state=VALUES(course_state);

-- 3. Curriculum placement, mirroring where the French unit sits: same year,
--    same semester, same specialisation, but ELECTIVE as requested.
INSERT INTO acad_programmecourses
    (progcode, course_code, study_year, semester, CurriculumID, specialisation_id,
     course_type, is_lecturere_assigned, status)
SELECT t.progcode, t.course_code, t.study_year, t.semester, t.curr, t.spec, 'ELECTIVE', 'No', 'Active'
  FROM (SELECT 'BTHM' progcode, 'THM2109B' course_code, 2 study_year, 1 semester, 53 curr, 184 spec
        UNION ALL SELECT 'BTHM','THM2211B',2,2, 53,184
        UNION ALL SELECT 'DTHM','THM2109D',2,1,107,191
        UNION ALL SELECT 'DTHM','THM2211D',2,2,107,191) t
 WHERE NOT EXISTS (SELECT 1 FROM acad_programmecourses pc
                    WHERE pc.progcode=t.progcode AND pc.course_code=t.course_code
                      AND pc.study_year=t.study_year AND pc.semester=t.semester);

COMMIT;

-- 4. Verification.
SELECT '=== courses created ===' AS x;
SELECT c.courseID, c.courseName, c.CreditUnit, c.CoreStatus, c.stat, c.course_state, c.subject_id
  FROM acad_course c WHERE c.courseID IN ('THM2109B','THM2211B','THM2109D','THM2211D') ORDER BY c.courseID;

SELECT '=== curriculum placement, beside the French unit it accompanies ===' AS x;
SELECT pc.progcode, pc.study_year, pc.semester, pc.course_code, c.courseName, c.CreditUnit, pc.course_type, pc.status
  FROM acad_programmecourses pc JOIN acad_course c ON c.courseID=pc.course_code
 WHERE pc.progcode IN ('BTHM','DTHM') AND pc.study_year=2
   AND (c.courseName LIKE '%LANGUAGE%')
 ORDER BY pc.progcode, pc.semester, pc.course_code;

SELECT '=== nothing existing was disturbed ===' AS x;
SELECT c.courseID, c.courseName, c.CreditUnit,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr WHERE cr.courseID=c.courseID) regs,
       (SELECT COUNT(*) FROM acad_results r WHERE r.courseid=c.courseID) results
  FROM acad_course c WHERE c.courseID IN ('THM2105B','THM2205B','THM2104D','THM2204D') ORDER BY c.courseID;
