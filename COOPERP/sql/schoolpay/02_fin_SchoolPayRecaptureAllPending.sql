-- ============================================================================
-- fin_SchoolPayRecaptureAllPending (campus_dynamics_accounts)  deployed 2026-06-30
-- ----------------------------------------------------------------------------
-- Sweeps every captureStatus='Pending' SchoolPay row through the (now double-post-
-- proof) fin_AutoPayCapture. The engine decides clean-vs-partial, so this just
-- loops. Idempotent (Captured rows leave the working set); snapshot into a temp
-- table so the loop is unaffected by its own status changes; per-row rollback
-- handler so one bad row never aborts the batch. Run automatically by the event
-- ev_schoolpay_autosweep (see 03_*). Safe to run manually any time.
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
    INSERT INTO tmp_sp_pending(ReceiptNo, regno, stud_name, amount_paid, datePaid, channelPaid)
        SELECT ReceiptNo, regno, stud_name, amount_paid, datePaid, channelPaid
        FROM fin_schoolpaydata WHERE captureStatus = 'Pending';
    SELECT IFNULL(MAX(rid), 0) INTO v_max FROM tmp_sp_pending;

    WHILE v_i <= v_max DO
        SELECT ReceiptNo, regno, stud_name, amount_paid, datePaid, channelPaid
          INTO v_receipt, v_reg, v_name, v_amount, v_date, v_channel
          FROM tmp_sp_pending WHERE rid = v_i;

        -- bank routing identical to the live webhook BankRouter()
        SET v_bankCode = CASE
            WHEN LOWER(v_channel) LIKE '%dfcu%'      THEN 'AC1303'
            WHEN LOWER(v_channel) LIKE '%centenary%' THEN 'AC1303'
            WHEN LOWER(v_channel) LIKE '%eco%'       THEN 'AC1308'
            ELSE 'AC1302'
        END;
        SET v_bankName = IF(v_channel LIKE '%Shared%', 'Bank of Africa', v_channel);

        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;
            CALL fin_AutoPayCapture(v_reg, CONCAT(v_name, ' [', v_reg, '] - SCHOOLPAY'),
                 v_bankCode, v_amount, DATE(v_date), 'autosweep', v_bankName, v_receipt);
        END;

        SET v_i = v_i + 1;
    END WHILE;

    DROP TEMPORARY TABLE IF EXISTS tmp_sp_pending;
END$$
DELIMITER ;
