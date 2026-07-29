-- ============================================================================
-- acad_GetResultsAcademicYear — ORIGINAL (pre-2026-07-01), kept for ROLLBACK only.
-- Returned MIN(acad) from acad_transcript_results for the block, which is wrong after
-- the curriculum re-map (a block can hold courses from different years). Do not deploy
-- except to revert.
-- ============================================================================
DROP FUNCTION IF EXISTS acad_GetResultsAcademicYear;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `acad_GetResultsAcademicYear`(regn VARCHAR(45), yr INT, sem INT)
RETURNS CHAR(15) CHARSET latin1
BEGIN
    DECLARE acadyr CHAR(15);
    SELECT MIN(acad) INTO acadyr FROM acad_transcript_results WHERE regno=regn AND studyyear=yr AND semester=sem;
    RETURN acadyr;
END$$
DELIMITER ;
