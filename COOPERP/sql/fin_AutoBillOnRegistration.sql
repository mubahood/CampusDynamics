-- ============================================================================
--  fin_AutoBillOnRegistration(regno, acadyear, semester, user)
--  The canonical "bill this student for this semester" entry point (called by the
--  eportal wizard, the eadmin reconcile sweep, and admin tools).
--
--  Hardened 2026-07-11: CLEARED is now billed IN PLACE. Previously only
--  REGISTERED / LATE REGISTERED were billed, so a student set to CLEARED without a
--  prior bill stayed unbilled, and the reconcile sweep had to downgrade CLEARED->REGISTERED
--  to bill them (losing the CLEARED status). CLEARED is an enrolled state and is now
--  billed directly via fin_BillProgrammeFees (tuition+functional), no status change.
--  Fully idempotent (fin_TermlyItemBillingFN short-circuits 'Already Billed'), so a
--  CLEARED student already billed while REGISTERED is never double-billed.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_AutoBillOnRegistration;
DELIMITER $$
CREATE PROCEDURE fin_AutoBillOnRegistration(
  IN p_regno CHAR(35),
  IN p_acadyear CHAR(15),
  IN p_semester INT,
  IN p_user CHAR(45)
)
BEGIN
  DECLARE v_regstatus CHAR(25) DEFAULT '';
  DECLARE v_resstatus CHAR(25) DEFAULT '';
  DECLARE v_studyyear INT DEFAULT 0;
  DECLARE v_prog CHAR(25) DEFAULT '';
  DECLARE v_session CHAR(25) DEFAULT '';

  SELECT regstatus, residence_status, studyyear
  INTO v_regstatus, v_resstatus, v_studyyear
  FROM campus_dynamics.acad_registration
  WHERE regno = p_regno AND acad_year = p_acadyear AND semester = p_semester
  LIMIT 1;

  SELECT progid, studsesion INTO v_prog, v_session
  FROM campus_dynamics.acad_student WHERE regno = p_regno LIMIT 1;

  IF v_regstatus IN ('REGISTERED', 'LATE REGISTERED') THEN
    CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'REG', p_user, 'AUTO');
    IF v_resstatus = 'RESIDENT' THEN
      CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'ACCOMO', p_user, 'AUTO');
    END IF;
  ELSEIF v_regstatus = 'CLEARED' THEN
    -- enrolled state: bill core programme fees in place, do NOT downgrade the status
    CALL fin_BillProgrammeFees(p_regno, v_prog, v_session, v_studyyear, p_semester, p_acadyear, p_user, 'AUTO');
    IF v_resstatus = 'RESIDENT' THEN
      CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'ACCOMO', p_user, 'AUTO');
    END IF;
  END IF;
END$$
DELIMITER ;
