-- Parameterise BillUnbilledStudents: Replace hardcoded year/semester with parameters
-- Also adds a trans_type='Bill' check to more accurately find unbilled students

DROP PROCEDURE IF EXISTS BillUnbilledStudents;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `BillUnbilledStudents`(
  IN p_acadyear CHAR(15),
  IN p_semester INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_regno CHAR(35);

    DECLARE cur CURSOR FOR
        SELECT r.regno
        FROM campus_dynamics.acad_registration r
        WHERE r.acad_year = p_acadyear
          AND r.semester = p_semester
          AND r.regstatus IN ('REGISTERED', 'LATE REGISTERED')
          AND r.regno NOT IN (
              SELECT DISTINCT regno
              FROM campus_dynamics_accounts.fin_studentfeestracking
              WHERE acadyear = p_acadyear
                AND semester = p_semester
                AND trans_type = 'Bill'
          );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    loop1: LOOP
        FETCH cur INTO v_regno;
        IF done = 1 THEN LEAVE loop1; END IF;
        CALL campus_dynamics_accounts.fin_Autobilling(v_regno, p_acadyear, p_semester, 'REG', 'admin', 'BATCH');
        CALL campus_dynamics_accounts.fin_Autobilling(v_regno, p_acadyear, p_semester, 'ACCOMO', 'admin', 'BATCH');
    END LOOP;
    CLOSE cur;
END$$

DELIMITER ;
