-- ============================================================================
-- MIGRATION: fin_programme_fees billing SP & helper function
-- Run against: campus_dynamics_accounts
-- Date: 2026-03-24
-- ============================================================================

-- --------------------------------------------------------------------------
-- SP: fin_GetProgrammeFee
-- Returns tuition + functional fee for a given programme/study_year/semester
-- Used by billing process to look up what to bill a student
-- --------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS fin_GetProgrammeFee$$
CREATE PROCEDURE fin_GetProgrammeFee(
  IN p_progcode CHAR(25),
  IN p_study_year INT,
  IN p_semester INT,
  OUT p_tuition DOUBLE,
  OUT p_functional DOUBLE
)
BEGIN
  SET p_tuition = 0;
  SET p_functional = 0;

  IF p_study_year = 1 AND p_semester = 1 THEN
    SELECT y1_s1_tuition, y1_s1_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 1 AND p_semester = 2 THEN
    SELECT y1_s2_tuition, y1_s2_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 1 AND p_semester = 3 THEN
    SELECT y1_s3_tuition, y1_s3_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 2 AND p_semester = 1 THEN
    SELECT y2_s1_tuition, y2_s1_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 2 AND p_semester = 2 THEN
    SELECT y2_s2_tuition, y2_s2_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 2 AND p_semester = 3 THEN
    SELECT y2_s3_tuition, y2_s3_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 3 AND p_semester = 1 THEN
    SELECT y3_s1_tuition, y3_s1_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 3 AND p_semester = 2 THEN
    SELECT y3_s2_tuition, y3_s2_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 3 AND p_semester = 3 THEN
    SELECT y3_s3_tuition, y3_s3_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  END IF;

  -- Default to 0 if no match found
  SET p_tuition = COALESCE(p_tuition, 0);
  SET p_functional = COALESCE(p_functional, 0);
END$$

DELIMITER ;
