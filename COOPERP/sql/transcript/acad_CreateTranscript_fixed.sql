-- ============================================================================
-- acad_CreateTranscript  (campus_dynamics)   fix 2026-07-01
-- ----------------------------------------------------------------------------
-- Bug: the per-(studyyear, semester) block "Academic Year" on printed transcripts
-- was wrong for some blocks (e.g. "Year 3 — Semester 2 | Academic Year 2019/2020"
-- instead of 2018/2019). Cause: the SP copies each course's `acad` from acad_results
-- (the year the course was actually taken/retaken) and then RE-MAPS studyyear/semester
-- to the curriculum position (acad_programmecourses). A block can then contain courses
-- taken in different academic years, so the block's displayed academic year was
-- inconsistent / reflected the wrong course.
--
-- Fix: after the curriculum re-map, normalise `acad` per block to the academic year the
-- student was REGISTERED for that study-year+semester (acad_registration) — the
-- authoritative "when was the student in Year N, Semester S". Blocks with no matching
-- registration keep their existing result-derived year as a fallback. Only ONE statement
-- was added (marked FIX 2026-07-01); everything else is unchanged.
-- Rollback: restore from acad_CreateTranscript_ORIGINAL.txt.
-- ============================================================================
DROP PROCEDURE IF EXISTS acad_CreateTranscript;
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

  -- ==== FIX 2026-07-01: normalise the academic year per (studyyear, semester) block ====
  -- After the curriculum re-map above, a block can contain courses taken in different
  -- academic years, so its displayed "Academic Year" was wrong/inconsistent. The correct
  -- year for a block is the one the student was REGISTERED for that study-year+semester.
  UPDATE acad_transcript_results t
  JOIN (
      SELECT studyyear, semester, MIN(acad_year) AS acad_year
      FROM acad_registration
      WHERE regno = reg AND IFNULL(acad_year,'') NOT IN ('', '-')
      GROUP BY studyyear, semester
  ) rg ON rg.studyyear = t.studyyear AND rg.semester = t.semester
  SET t.acad = rg.acad_year
  WHERE t.regno = reg;

  UPDATE acad_transcript_results
  SET gpa = acad_TranscriptGPAFinder(regno, studyyear, semester)
  WHERE regno = reg;

END$$
DELIMITER ;
