-- fin_AutoBillOnRegistration: Auto-bill a student immediately after registration
-- Called from C# code after DoSetStatus() sets REGISTERED or LATE REGISTERED
-- Safe to call multiple times — fin_TermlyItemBillingFN has a pre-check
-- that returns 'Already Billed' if a bill already exists.

DROP PROCEDURE IF EXISTS fin_AutoBillOnRegistration;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoBillOnRegistration`(
  IN p_regno CHAR(35),
  IN p_acadyear CHAR(15),
  IN p_semester INT,
  IN p_user CHAR(45)
)
BEGIN

  DECLARE v_regstatus CHAR(25) DEFAULT '';
  DECLARE v_resstatus CHAR(25) DEFAULT '';

  -- Get the student's current registration status for this year/semester
  SELECT regstatus, residence_status
  INTO v_regstatus, v_resstatus
  FROM campus_dynamics.acad_registration
  WHERE regno = p_regno
    AND acad_year = p_acadyear
    AND semester = p_semester
  LIMIT 1;

  -- Only bill if student is actually registered
  IF v_regstatus IN ('REGISTERED', 'LATE REGISTERED') THEN

    -- Bill tuition + function fees (and late reg fee if LATE REGISTERED)
    CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'REG', p_user, 'AUTO');

    -- Bill accommodation if student is resident
    IF v_resstatus = 'RESIDENT' THEN
      CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'ACCOMO', p_user, 'AUTO');
    END IF;

  END IF;

END$$

DELIMITER ;
