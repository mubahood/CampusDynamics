USE campus_dynamics_accounts;

DROP PROCEDURE IF EXISTS fin_BillFix_Apply;

DELIMITER $$

CREATE PROCEDURE fin_BillFix_Apply(IN p_batch VARCHAR(40), IN p_max INT)
BEGIN
  DECLARE v_done INT DEFAULT 0;
  DECLARE v_err  INT DEFAULT 0;
  DECLARE v_reg  VARCHAR(35);
  DECLARE v_acad VARCHAR(15);
  DECLARE v_sem  INT;
  DECLARE v_yr   INT;
  DECLARE v_prog VARCHAR(25);
  DECLARE v_sess VARCHAR(25);
  DECLARE v_n    INT DEFAULT 0;

  DECLARE cur CURSOR FOR
    SELECT DISTINCT regno, acadyear, semester, studyyear, progid, session
    FROM fin_billfix_worklist
    WHERE batch_id = p_batch AND status = 'PLANNED'
    ORDER BY regno, acadyear, semester;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_err = 1;

  OPEN cur;
  loop1: LOOP
    IF p_max > 0 AND v_n >= p_max THEN LEAVE loop1; END IF;
    SET v_done = 0;
    FETCH cur INTO v_reg, v_acad, v_sem, v_yr, v_prog, v_sess;
    IF v_done = 1 THEN LEAVE loop1; END IF;

    SET v_err = 0;
    CALL fin_BillProgrammeFees(v_reg, v_prog, COALESCE(NULLIF(TRIM(v_sess),''),'Day'),
                               v_yr, v_sem, v_acad, 'system', 'AUTO');

    IF v_err = 1 THEN
      UPDATE fin_billfix_worklist
        SET status = 'FAILED', reason = 'billing error', applied_at = NOW()
        WHERE batch_id = p_batch AND regno = v_reg AND acadyear = v_acad
          AND semester = v_sem AND status = 'PLANNED';
    ELSE
      /* 1. hidden tag on the tracking bills just created (worklist-matched, untagged) */
      UPDATE fin_studentfeestracking t
        JOIN fin_billfix_worklist w
          ON w.batch_id = p_batch AND w.regno = t.regno AND w.acadyear = t.acadyear
         AND w.semester = t.semester AND w.item_code = t.item_code
        SET t.fix_batch_id = p_batch
        WHERE t.trans_type = 'Bill' AND t.fix_batch_id IS NULL
          AND t.regno = v_reg AND t.acadyear = v_acad AND t.semester = v_sem;

      /* 2. hidden tag on the GL rows of those bills */
      UPDATE fin_ledger l
        JOIN fin_studentfeestracking t ON l.folio = CONCAT('BillNo:', t.TID)
        SET l.source_system = 'BILLFIX', l.RefNo = p_batch
        WHERE t.fix_batch_id = p_batch AND t.regno = v_reg AND t.acadyear = v_acad
          AND t.semester = v_sem
          AND (l.source_system IS NULL OR l.source_system <> 'BILLFIX');

      /* 3. registry: link TIDs, mark APPLIED */
      UPDATE fin_billfix_worklist w
        JOIN fin_studentfeestracking t
          ON t.regno = w.regno AND t.acadyear = w.acadyear AND t.semester = w.semester
         AND t.item_code = w.item_code AND t.trans_type = 'Bill' AND t.fix_batch_id = p_batch
        SET w.status = 'APPLIED', w.tracking_tid = t.TID,
            w.ledger_dr_tid = (SELECT TID FROM fin_ledger WHERE folio = CONCAT('BillNo:', t.TID) AND transactionType = 'DR' LIMIT 1),
            w.ledger_cr_tid = (SELECT TID FROM fin_ledger WHERE folio = CONCAT('BillNo:', t.TID) AND transactionType = 'CR' LIMIT 1),
            w.balance_after = w.balance_before - w.amount,
            w.applied_at = NOW()
        WHERE w.batch_id = p_batch AND w.regno = v_reg AND w.acadyear = v_acad
          AND w.semester = v_sem AND w.status = 'PLANNED';

      /* 4. any remaining PLANNED rows for this group had no bill created -> SKIPPED */
      UPDATE fin_billfix_worklist
        SET status = 'SKIPPED', reason = 'no bill created (fee 0 / already billed)', applied_at = NOW()
        WHERE batch_id = p_batch AND regno = v_reg AND acadyear = v_acad
          AND semester = v_sem AND status = 'PLANNED';
    END IF;

    SET v_n = v_n + 1;
  END LOOP;
  CLOSE cur;

  SELECT v_n AS groups_processed;
END$$

DELIMITER ;
