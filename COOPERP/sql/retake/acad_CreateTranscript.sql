DROP PROCEDURE IF EXISTS `acad_CreateTranscript`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_CreateTranscript`(reg CHAR(45), typ CHAR(25), fid INT)
BEGIN
  DECLARE prog, sys CHAR(45);
  SET prog = acad_GetProgCodeByRegNo(reg);
  SELECT study_system INTO sys FROM acad_programme WHERE progcode = prog LIMIT 1;

  IF (typ = 'Custom') THEN

    DELETE FROM acad_transcript_results WHERE regno = reg;
    INSERT INTO acad_transcript_results
      (regno, courseid, semester, acad, studyyear, score, grade, gradept, gpa,
       result_comment, CreditUnits, progid, study_system, is_retake)
    SELECT
      regno, courseid, tfd.semester, acad, study_year, score, grade, gradept, gpa,
      result_comment, CreditUnits, progid, study_system, COALESCE(r.is_retake,0)
    FROM acad_results r, acad_transcript_format tf, acad_transcript_format_detail tfd
    WHERE tfd.format_id = tf.ID
      AND tfd.course_id = r.courseid
      AND regno = reg
      AND tf.ID = fid;

    UPDATE acad_transcript_results
    SET gpa = acad_TranscriptGPAFinder(regno, studyyear, semester)
    WHERE regno = reg;

  ELSE

    DELETE FROM acad_transcript_results WHERE regno = reg;
    INSERT INTO acad_transcript_results
      (regno, courseid, semester, acad, studyyear, score, grade, gradept, gpa,
       result_comment, CreditUnits, progid, study_system, is_retake)
    SELECT
      regno, r.courseid, semester, acad, studyyear, score, grade, gradept, gpa,
      result_comment,
      COALESCE(c.CreditUnit, r.CreditUnits, 3),
      progid, sys, COALESCE(r.is_retake,0)
    FROM acad_results r
    LEFT JOIN acad_course c ON c.courseID = r.courseid
    WHERE regno = reg;

  END IF;

  UPDATE acad_transcript_results a
  JOIN (
    SELECT progcode, course_code, study_year, semester
    FROM acad_programmecourses p
    WHERE p.curriculumID = acad_GetStudentStudyCurriculum(reg)
  ) p ON p.progcode = a.progid AND p.course_code = a.courseid
  SET a.studyyear = p.study_year, a.semester = p.semester
  WHERE regno = reg;

  UPDATE acad_transcript_results
  SET gpa = acad_TranscriptGPAFinder(regno, studyyear, semester)
  WHERE regno = reg;

END
$$
DELIMITER ;
