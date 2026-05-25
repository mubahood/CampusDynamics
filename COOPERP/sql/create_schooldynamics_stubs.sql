-- ============================================================================
-- Create schooldynamics stub database and missing functions
-- Required by: fin_TermlyItemBillingFN in campus_dynamics_accounts
-- The function is used only for human-readable ledger description text.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS schooldynamics CHARACTER SET latin1 COLLATE latin1_swedish_ci;

DROP FUNCTION IF EXISTS schooldynamics.adm_GetStudNameByAdmNo;

DELIMITER $$

CREATE FUNCTION schooldynamics.adm_GetStudNameByAdmNo(p_regno CHAR(50))
RETURNS CHAR(150) CHARSET latin1
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_name CHAR(150) DEFAULT '';
    SELECT TRIM(CONCAT(IFNULL(firstname,''), ' ', IFNULL(othername,'')))
    INTO v_name
    FROM campus_dynamics.acad_student
    WHERE TRIM(regno) = TRIM(p_regno)
    LIMIT 1;
    RETURN IFNULL(NULLIF(TRIM(v_name),''), p_regno);
END$$

DELIMITER ;

SELECT 'schooldynamics.adm_GetStudNameByAdmNo created successfully' AS status;
