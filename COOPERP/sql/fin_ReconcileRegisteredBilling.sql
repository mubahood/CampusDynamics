-- ============================================================================
--  fin_ReconcileRegisteredBilling  —  prevention: "a registered student can't
--  silently miss a bill."
--
--  Detects the exact recurring defect behind the phantom-overpaid students:
--  a semester fee that was BILLED then REVERSED to net-zero in the GL and never
--  re-raised, even though the student is REGISTERED for that semester. Because
--  the student has usually already paid, the missing charge shows up as a fake
--  "credit" (overpaid).
--
--  Modes:
--    CALL fin_ReconcileRegisteredBilling(0);  -- REPORT ONLY (default, safe) -> logs to fin_billing_gap_log
--    CALL fin_ReconcileRegisteredBilling(1);  -- FIX -> also posts re-instatement DRs (source_system='REBILL_RECON')
--
--  Idempotent: once a semester's fee is restored, its net is no longer 0, so it
--  is not re-detected. Runs cross-DB (accounts + campus_dynamics.acad_registration).
--  Intended to run nightly in REPORT mode; an admin reviews fin_billing_gap_log
--  and runs FIX mode when confirmed (or wire the fix behind an approval step).
-- ============================================================================

CREATE TABLE IF NOT EXISTS fin_billing_gap_log (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  regno         VARCHAR(35),
  acad_year     VARCHAR(15),
  semester      INT,
  reversed_amount DECIMAL(15,2),
  status        VARCHAR(20),          -- DETECTED | FIXED
  detected_at   DATETIME,
  note          VARCHAR(255),
  KEY ix_regno (regno),
  KEY ix_status (status)
);

DROP PROCEDURE IF EXISTS fin_ReconcileRegisteredBilling;
DELIMITER $$
CREATE PROCEDURE fin_ReconcileRegisteredBilling(IN p_apply TINYINT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS _gap;
    CREATE TEMPORARY TABLE _gap AS
    SELECT rvl.TID                                   AS reversal_tid,
           rvl.accountcode                           AS regno,
           rvl.account_type                          AS account_type,
           rvl.transaction_amount                    AS amt,
           rvl.particulars                           AS particulars,
           SUBSTRING_INDEX(SUBSTRING_INDEX(rvl.particulars,'Semester:',-1),',',1) AS sem,
           SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(rvl.particulars,'Semester:',-1),', ',-1),' ',1) AS ay
    FROM fin_ledger rvl
    WHERE rvl.particulars LIKE 'Reversal of %Fees for Semester:%'
      -- net fee for that student+semester is exactly zero (billed == reversed, no re-bill)
      AND (SELECT SUM(CASE WHEN l2.transactionType='DR' THEN l2.transaction_amount ELSE -l2.transaction_amount END)
           FROM fin_ledger l2
           WHERE l2.accountcode = rvl.accountcode
             AND l2.particulars LIKE '%Fees%'
             AND l2.particulars LIKE CONCAT('%:',
                   SUBSTRING_INDEX(SUBSTRING_INDEX(rvl.particulars,'Semester:',-1),',',1), ', ',
                   SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(rvl.particulars,'Semester:',-1),', ',-1),' ',1), '%')) = 0
      -- and the student IS registered for that acad_year + semester
      AND EXISTS (SELECT 1 FROM campus_dynamics.acad_registration reg
                  WHERE reg.regno = rvl.accountcode
                    AND reg.acad_year = SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(rvl.particulars,'Semester:',-1),', ',-1),' ',1)
                    AND reg.semester  = SUBSTRING_INDEX(SUBSTRING_INDEX(rvl.particulars,'Semester:',-1),',',1)
                    AND reg.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED'))
      -- and there is a matching original bill DR (guards against over-reversal anomalies)
      AND EXISTS (SELECT 1 FROM fin_ledger b
                  WHERE b.accountcode = rvl.accountcode AND b.transactionType='DR'
                    AND b.transaction_amount = rvl.transaction_amount
                    AND b.particulars LIKE '%Fees%' AND b.particulars NOT LIKE 'Reversal%');

    INSERT INTO fin_billing_gap_log (regno, acad_year, semester, reversed_amount, status, detected_at, note)
    SELECT regno, ay, sem, amt, IF(p_apply=1,'FIXED','DETECTED'), NOW(),
           'Reversed-to-zero fee for a registered semester (student likely already paid)'
    FROM _gap;

    IF p_apply = 1 THEN
        INSERT INTO fin_ledger (accountcode, account_type, transactionType, transaction_amount,
                                particulars, voucherNo, transactionDate, teller, timeLog, source_system, RefNo)
        SELECT regno, account_type, 'DR', amt,
               LEFT(CONCAT('Re-billing (reconciliation; registered, erroneous reversal cancelled): ',
                           REPLACE(particulars,'Reversal of ','')), 350),
               8000000 + reversal_tid, CURDATE(), 'RECON', NOW(), 'REBILL_RECON',
               CONCAT('RECON-', DATE_FORMAT(NOW(),'%Y%m%d'))
        FROM _gap;
    END IF;

    SELECT COUNT(*) AS gaps, IF(p_apply=1,'FIXED (re-instatement DRs posted)','DETECTED — report only') AS mode
    FROM _gap;
    DROP TEMPORARY TABLE IF EXISTS _gap;
END$$
DELIMITER ;
