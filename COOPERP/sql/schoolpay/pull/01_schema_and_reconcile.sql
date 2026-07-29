-- ============================================================================
-- SchoolPay PULL / reconciliation — schema + reconcile SP   (campus_dynamics_accounts)
-- Landing zone for pulled transactions + the reconcile procedure that funnels any
-- payment SchoolPay has but we don't through the ONE hardened capture engine
-- (fin_AutoPayCapture, §14) — fully de-duplicated. Created 2026-07-02.
-- ============================================================================

-- 1. Staging: raw pulled rows (idempotent landing zone; receipt_no unique)
CREATE TABLE IF NOT EXISTS fin_schoolpay_pull_staging (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_id              VARCHAR(40)  NOT NULL,
    receipt_no          VARCHAR(45)  NOT NULL,
    regno               VARCHAR(45)  NULL,
    student_payment_code VARCHAR(45) NULL,
    amount              DOUBLE       NOT NULL DEFAULT 0,
    channel             VARCHAR(45)  NULL,
    settlement_bank     VARCHAR(45)  NULL,
    source_txn_id       VARCHAR(60)  NULL,
    pay_datetime        DATETIME     NULL,
    student_name        VARCHAR(100) NULL,
    txn_status          VARCHAR(30)  NULL,
    fee_type            VARCHAR(20)  NULL DEFAULT 'SCHOOL',
    supp_fee_desc       VARCHAR(100) NULL,
    reconcile_status    VARCHAR(20)  NOT NULL DEFAULT 'New',   -- New/Existed/Captured/Failed/NoStudent
    pulled_at           DATETIME     NOT NULL,
    UNIQUE KEY uq_run_receipt (run_id, receipt_no),
    KEY idx_receipt (receipt_no),
    KEY idx_run (run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2. Sync log: one row per pull run
CREATE TABLE IF NOT EXISTS fin_schoolpay_synclog (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_id          VARCHAR(40)  NOT NULL,
    txn_date_from   DATE         NULL,
    txn_date_to     DATE         NULL,
    trigger_type    VARCHAR(20)  NULL,       -- MANUAL / SCHEDULED / CATCHUP
    triggered_by    VARCHAR(100) NULL,
    run_started     DATETIME     NULL,
    run_finished    DATETIME     NULL,
    return_code     INT          NULL,
    return_message  VARCHAR(500) NULL,
    fetched_count   INT          NULL DEFAULT 0,
    new_count       INT          NULL DEFAULT 0,
    existed_count   INT          NULL DEFAULT 0,
    captured_count  INT          NULL DEFAULT 0,
    failed_count    INT          NULL DEFAULT 0,
    sp_total_amount DOUBLE       NULL DEFAULT 0,
    local_total_amount DOUBLE    NULL DEFAULT 0,
    status          VARCHAR(20)  NULL,
    KEY idx_run (run_id), KEY idx_started (run_started)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 3. Reconcile: post every 'New' staged row of a run through the hardened engine.
DROP PROCEDURE IF EXISTS fin_SchoolPayReconcilePulled;
DELIMITER $$
CREATE PROCEDURE fin_SchoolPayReconcilePulled(IN p_run_id VARCHAR(40), IN p_actor VARCHAR(100))
BEGIN
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_max INT DEFAULT 0;
    DECLARE v_sid BIGINT;
    DECLARE v_receipt VARCHAR(45);
    DECLARE v_regno VARCHAR(45);
    DECLARE v_amount DOUBLE;
    DECLARE v_channel VARCHAR(45);
    DECLARE v_paydate DATETIME;
    DECLARE v_name VARCHAR(100);
    DECLARE v_bankCode VARCHAR(25);
    DECLARE v_exists INT;
    DECLARE v_hasstudent INT;
    DECLARE n_new INT DEFAULT 0;
    DECLARE n_existed INT DEFAULT 0;
    DECLARE n_captured INT DEFAULT 0;
    DECLARE n_failed INT DEFAULT 0;

    DROP TEMPORARY TABLE IF EXISTS tmp_recon;
    CREATE TEMPORARY TABLE tmp_recon (
        rid INT AUTO_INCREMENT PRIMARY KEY, sid BIGINT, receipt VARCHAR(45),
        regno VARCHAR(45), amount DOUBLE, channel VARCHAR(45), paydate DATETIME, name VARCHAR(100));
    INSERT INTO tmp_recon(sid, receipt, regno, amount, channel, paydate, name)
        SELECT id, receipt_no, regno, amount, channel, pay_datetime, student_name
        FROM fin_schoolpay_pull_staging WHERE run_id = p_run_id AND reconcile_status = 'New';
    SELECT IFNULL(MAX(rid),0) INTO v_max FROM tmp_recon;

    WHILE v_i <= v_max DO
        SELECT sid, receipt, regno, amount, channel, paydate, name
          INTO v_sid, v_receipt, v_regno, v_amount, v_channel, v_paydate, v_name
          FROM tmp_recon WHERE rid = v_i;
        SET v_regno = TRIM(IFNULL(v_regno,''));
        SET v_bankCode = CASE
            WHEN LOWER(v_channel) LIKE '%dfcu%'      THEN 'AC1303'
            WHEN LOWER(v_channel) LIKE '%centenary%' THEN 'AC1303'
            WHEN LOWER(v_channel) LIKE '%eco%'       THEN 'AC1308'
            ELSE 'AC1302' END;

        SELECT COUNT(*) INTO v_exists FROM fin_schoolpaydata WHERE ReceiptNo = v_receipt;

        IF v_exists > 0 THEN
            UPDATE fin_schoolpay_pull_staging SET reconcile_status = 'Existed' WHERE id = v_sid;
            SET n_existed = n_existed + 1;
        ELSE
            SELECT COUNT(*) INTO v_hasstudent FROM campus_dynamics.acad_student WHERE TRIM(regno) = v_regno;
            IF v_regno = '' OR v_hasstudent = 0 THEN
                -- record the payment but it can't be posted (student unresolved) -> Pending for manual mapping
                INSERT IGNORE INTO fin_schoolpaydata(ReceiptNo, regno, datePaid, channelPaid, amount_paid, stud_name, captureStatus)
                    VALUES (v_receipt, IF(v_regno='','-',v_regno), v_paydate, v_channel, v_amount, v_name, 'Pending');
                UPDATE fin_schoolpay_pull_staging SET reconcile_status = 'NoStudent' WHERE id = v_sid;
                SET n_new = n_new + 1; SET n_failed = n_failed + 1;
            ELSE
                INSERT IGNORE INTO fin_schoolpaydata(ReceiptNo, regno, datePaid, channelPaid, amount_paid, stud_name, captureStatus)
                    VALUES (v_receipt, v_regno, v_paydate, v_channel, v_amount, v_name, 'Pending');
                SET n_new = n_new + 1;
                BEGIN
                    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;
                    CALL fin_AutoPayCapture(v_regno, CONCAT(v_name, ' [', v_regno, '] - SCHOOLPAY'),
                         v_bankCode, v_amount, DATE(v_paydate), 'pullsync', v_channel, v_receipt);
                END;
                IF (SELECT captureStatus FROM fin_schoolpaydata WHERE ReceiptNo = v_receipt) = 'Captured' THEN
                    UPDATE fin_schoolpay_pull_staging SET reconcile_status = 'Captured' WHERE id = v_sid;
                    SET n_captured = n_captured + 1;
                ELSE
                    UPDATE fin_schoolpay_pull_staging SET reconcile_status = 'Failed' WHERE id = v_sid;
                    SET n_failed = n_failed + 1;
                END IF;
            END IF;
        END IF;
        SET v_i = v_i + 1;
    END WHILE;

    UPDATE fin_schoolpay_synclog
       SET new_count = n_new, existed_count = n_existed, captured_count = n_captured,
           failed_count = n_failed, run_finished = NOW(), status = 'OK'
     WHERE run_id = p_run_id;

    DROP TEMPORARY TABLE IF EXISTS tmp_recon;
    SELECT n_new AS newly_inserted, n_existed AS already_had, n_captured AS captured, n_failed AS failed;
END$$
DELIMITER ;
