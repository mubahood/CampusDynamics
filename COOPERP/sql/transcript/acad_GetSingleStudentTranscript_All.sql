-- ─────────────────────────────────────────────────────────────────────────────
-- acad_GetSingleStudentTranscript_All
--
-- Combined "list format" transcript body feed for Template 2 (FinalTranscriptList).
-- Returns EVERY semester's results for a student in a single result set, ordered
-- chronologically (studyyear, semester), so the transcript body can render one
-- vertical list of semester blocks — as opposed to acad_GetSingleStudentTranscript_Col1
-- / _Col2 which hard-split the same rows into a left/right two-column grid.
--
-- Column set is IDENTICAL to _Col1 (so the same report bindings resolve unchanged);
-- only the row partitioning differs (all semesters here vs. a fixed subset there).
--
-- NOTE: no DEFINER clause — the routine is owned by whichever user creates it, so it
-- deploys cleanly on any environment. The application also self-heals this routine at
-- runtime (AcademicDocumentPdfService.EnsureListTranscriptProc), but running this file
-- once on the campus_dynamics database is the authoritative deployment.
-- ─────────────────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS `acad_GetSingleStudentTranscript_All`;
DELIMITER $$
CREATE PROCEDURE `acad_GetSingleStudentTranscript_All`(reg CHAR(30))
BEGIN

DECLARE prog,sys CHAR(45);

SET prog=acad_GetProgCodeByRegNo(reg);
SELECT acad_proper_case(study_system) INTO sys FROM acad_programme WHERE progcode=prog LIMIT 1;

SELECT CONCAT(UPPER(acad_GetCourseNameByCode(courseid)),IF(COALESCE(r.is_retake,0)=1,' (RT)','')) AS coursename, sys,
r.ID, r.regno, courseid, r.semester, acad_GetResultsAcademicYear(reg,studyyear, r.semester) acad, studyyear, score, grade, gradept,
gpa, result_comment, CreditUnits, r.progid, r.study_system,
CONCAT_WS('  ',CONCAT('GPA: ',gpa),CONCAT('      CGPA: ',acad_CGPAFinder_ByPeriod(r.regno,r.studyyear, r.semester))) AS SemesterScores
FROM acad_transcript_results r JOIN acad_graduands g ON g.regno=r.regno
WHERE g.regno=reg AND trans_status='Ready'
ORDER BY r.studyyear, r.semester, r.ID;

END
$$
DELIMITER ;
