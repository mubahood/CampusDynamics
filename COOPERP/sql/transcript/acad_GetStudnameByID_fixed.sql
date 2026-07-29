-- FIX 2026-07-03: student name on transcripts/documents must match the SYSTEM order
-- (firstname + othername), e.g. "KIMBOWA ABDU", not the reversed "ABDU KIMBOWA".
-- acad_GetStudnameByID is the canonical name resolver used by 14 procedures
-- (transcripts, mark sheets, student cards, ID verification, ledger ...); fixing it here
-- aligns ALL of them with the system. The transcript SPs (acad_GetSingle/BatchStudentTranscriptData)
-- self-refresh acad_graduands.stud_name from this function, so transcripts correct on next print.
USE campus_dynamics;

DROP FUNCTION IF EXISTS acad_GetStudnameByID;
DELIMITER $$
CREATE FUNCTION acad_GetStudnameByID(reg CHAR(90)) RETURNS CHAR(65) CHARSET utf8
    READS SQL DATA
BEGIN
    DECLARE st_name CHAR(65);
    SELECT CONCAT(IFNULL(firstname,''),' ',IFNULL(othername,'')) INTO st_name
      FROM acad_student WHERE regno = reg;
    RETURN IF(st_name IS NULL, '-', TRIM(st_name));
END$$
DELIMITER ;

-- Refresh already-stored graduand names to the corrected (system) order so every consumer
-- of acad_graduands.stud_name is immediately consistent.
UPDATE acad_graduands g JOIN acad_student s ON TRIM(s.regno) = TRIM(g.regno)
SET g.stud_name = acad_GetStudnameByID(g.regno);
