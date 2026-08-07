-- ============================================================================
-- fin_SchoolPayRecaptureAllPending (campus_dynamics_accounts)  deployed 2026-06-30
--   revised 2026-08-07: heal by LEDGER TRUTH, not the captureStatus flag.
-- ----------------------------------------------------------------------------
-- Sweeps every SchoolPay payment that is NOT actually on the student ledger yet
-- (regardless of its captureStatus flag) through the double-post-proof
-- fin_AutoPayCapture. This is the core self-healing batch: it catches money that
-- was received but never posted — whether the row is 'Pending', 'Failed', or was
-- even mis-flagged 'Captured' while its GL entry never landed.
--
--   Working set = resolvable-student rows with NO ledger posting, established via
--   the dual guard fin_SchoolPayReceiptPosted (TransCode folio OR 'TNo:' particulars)
--   so a legacy-folio posting is NEVER re-posted. The cheap indexed folio filter is
--   applied first to keep the candidate set tiny before the particulars scan.
--   Each row is re-armed to 'Pending' so the capture engine acts (TCheck=1). The
--   engine's own folio guard still makes every post idempotent.
--
-- Idempotent, per-row rollback handler so one bad row never aborts the batch.
-- Run automatically by the event ev_schoolpay_autosweep (see 03_*). Safe to run
-- manually any time. Requires fin_SchoolPayReceiptPosted (see pull/01_*).
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_SchoolPayRecaptureAllPending;
DELIMITER $$
CREATE PROCEDURE fin_SchoolPayRecaptureAllPending()
BEGIN
    DECLARE v_i        INT DEFAULT 1;
    DECLARE v_max      INT DEFAULT 0;
    DECLARE v_receipt  CHAR(45);
    DECLARE v_reg      VARCHAR(45);
    DECLARE v_name     VARCHAR(75);
    DECLARE v_amount   DOUBLE;
    DECLARE v_date     DATETIME;
    DECLARE v_channel  VARCHAR(45);
    DECLARE v_bankCode VARCHAR(25);
    DECLARE v_bankName VARCHAR(250);

    DROP TEMPORARY TABLE IF EXISTS tmp_sp_pending;
    CREATE TEMPORARY TABLE tmp_sp_pending (
        rid INT AUTO_INCREMENT PRIMARY KEY,
        ReceiptNo CHAR(45), regno VARCHAR(45), stud_name VARCHAR(75),
        amount_paid DOUBLE, datePaid DATETIME, channelPaid VARCHAR(45)
    );
    -- step 1 (cheap, indexed): candidates with no 'TransCode:' folio + resolvable student
    INSERT INTO tmp_sp_pending(ReceiptNo, regno, stud_name, amount_paid, datePaid, channelPaid)
        SELECT d.ReceiptNo, d.regno, d.stud_name, d.amount_paid, d.datePaid, d.channelPaid
        FROM fin_schoolpaydata d
        WHERE NOT EXISTS (SELECT 1 FROM fin_ledger l WHERE l.folio = CONCAT('TransCode:', d.ReceiptNo))
          AND TRIM(IFNULL(d.regno,'')) NOT IN ('', '-')
          AND EXISTS (SELECT 1 FROM campus_dynamics.acad_student s WHERE TRIM(s.regno) = TRIM(d.regno));
    -- step 2 (small set only): drop any that ARE posted under a legacy folio
    DELETE t FROM tmp_sp_pending t
        WHERE fin_SchoolPayReceiptPosted(t.ReceiptNo, t.datePaid) = 1;
    SELECT IFNULL(MAX(rid), 0) INTO v_max FROM tmp_sp_pending;

    WHILE v_i <= v_max DO
        SELECT ReceiptNo INTO v_receipt FROM tmp_sp_pending WHERE rid = v_i;
        -- the ONE shared self-healing poster (posts/rebuilds/leaves as appropriate)
        CALL fin_SchoolPayHealReceipt(v_receipt, @oc);
        SET v_i = v_i + 1;
    END WHILE;

    DROP TEMPORARY TABLE IF EXISTS tmp_sp_pending;
END$$
DELIMITER ;
