-- ============================================================================
-- acad_GetResultsAcademicYear  (campus_dynamics)   fix 2026-07-01
-- ----------------------------------------------------------------------------
-- This function returns the academic year shown on the transcript for a given
-- (student, study-year, semester) block. It is called by the single-student
-- transcript SPs acad_GetSingleStudentTranscript_Col1/Col2 (the FinalTranscript PDF).
--
-- ORIGINAL: `SELECT MIN(acad) FROM acad_transcript_results WHERE studyyear=yr AND
-- semester=sem` — i.e. the earliest course-level academic year in the block. After the
-- curriculum re-map in acad_CreateTranscript, a block can hold courses taken in different
-- years, so MIN(acad) returned the wrong year (e.g. Year 3 Sem 2 showed 2019/2020 instead
-- of 2018/2019, or vice-versa).
--
-- FIX: make it AUTHORITATIVE from acad_registration — the year the student was actually
-- registered for that study-year+semester. This is correct regardless of how the course
-- rows were re-mapped. Falls back to the previous behaviour only when the student has no
-- registration row for the block.
-- Rollback: restore from acad_GetResultsAcademicYear_ORIGINAL.txt.
-- ============================================================================
DROP FUNCTION IF EXISTS acad_GetResultsAcademicYear;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `acad_GetResultsAcademicYear`(regn VARCHAR(45), yr INT, sem INT)
RETURNS CHAR(15) CHARSET latin1
BEGIN
    DECLARE acadyr CHAR(15);

    -- Authoritative: the academic year the student was REGISTERED for this study-year+semester.
    SELECT MIN(acad_year) INTO acadyr
    FROM acad_registration
    WHERE regno = regn AND studyyear = yr AND semester = sem
      AND IFNULL(acad_year,'') NOT IN ('', '-');

    -- Fallback (no registration for the block): previous behaviour — earliest recorded year.
    IF acadyr IS NULL OR acadyr = '' THEN
        SELECT MIN(acad) INTO acadyr
        FROM acad_transcript_results
        WHERE regno = regn AND studyyear = yr AND semester = sem;
    END IF;

    RETURN acadyr;
END$$
DELIMITER ;
