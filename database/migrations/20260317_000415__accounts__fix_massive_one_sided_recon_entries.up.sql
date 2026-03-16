-- E2: Fix 3 massive one-sided reconciliation entries (60407, 60408, 60411)
-- These vouchers have DR entries but zero CR side, creating a UGX ~1.598B imbalance.
-- Fix: Insert offsetting entries to a dedicated "Bank Reconciliation Differences" account.

DELIMITER $

DROP PROCEDURE IF EXISTS `_e2_fix_recon_entries` $

CREATE PROCEDURE `_e2_fix_recon_entries`()
BEGIN
    DECLARE v_vno       INT;
    DECLARE v_dr        DECIMAL(20,4);
    DECLARE v_cr        DECIMAL(20,4);
    DECLARE v_diff      DECIMAL(20,4);
    DECLARE v_jno       INT;
    DECLARE v_done      INT DEFAULT 0;
    DECLARE v_teller    VARCHAR(45) DEFAULT 'SYSTEM_REPAIR_E2';
    DECLARE v_recon_acc CHAR(25) DEFAULT 'AC-RECONCILE-DIFF';

    -- Cursor over the 3 known problem vouchers
    DECLARE cur CURSOR FOR
        SELECT voucherNo,
               SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) AS dr_total,
               SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS cr_total
        FROM fin_ledger
        WHERE voucherNo IN (60407, 60408, 60411)
        GROUP BY voucherNo
        HAVING ABS(dr_total - cr_total) > 0.005;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Ensure the reconciliation differences account exists in fin_subaccounts
    IF NOT EXISTS (
        SELECT 1 FROM fin_subaccounts WHERE AccountCode = v_recon_acc
    ) THEN
        INSERT INTO fin_subaccounts
            (AccountCode, AccountName, MainAccountCode, accounttype, Details)
        VALUES
            (v_recon_acc, 'Bank Reconciliation Differences', 'AC7003',
             'Chart Account', 'Auto-created for E2 repair 2026-03-17');
    END IF;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_vno, v_dr, v_cr;
        IF v_done THEN LEAVE read_loop; END IF;

        SET v_diff = v_dr - v_cr;

        -- Get journal number (journal_no is CHAR(25) in fin_ledger)
        SELECT JournalNo INTO v_jno
        FROM fin_journalnumbers WHERE GL_VoucherNo = v_vno LIMIT 1;

        IF v_diff > 0.005 THEN
            -- DR exceeds CR — insert a CR entry
            INSERT INTO fin_ledger
                (accountcode, account_type, transactionType, transaction_amount,
                 particulars, voucherNo, journal_no, transactionDate, teller,
                 trans_currency, actual_amount, forex_rate, timeLog)
            VALUES
                (v_recon_acc, 'Chart Account', 'CR', CAST(ROUND(v_diff) AS UNSIGNED),
                 CONCAT('E2 repair: offsetting CR for voucher ', v_vno, ' - reconciliation difference'),
                 v_vno, CAST(v_jno AS CHAR), CURDATE(),
                 v_teller, 'UGX', v_diff, 1, NOW());

        ELSEIF v_diff < -0.005 THEN
            -- CR exceeds DR — insert a DR entry
            INSERT INTO fin_ledger
                (accountcode, account_type, transactionType, transaction_amount,
                 particulars, voucherNo, journal_no, transactionDate, teller,
                 trans_currency, actual_amount, forex_rate, timeLog)
            VALUES
                (v_recon_acc, 'Chart Account', 'DR', CAST(ROUND(ABS(v_diff)) AS UNSIGNED),
                 CONCAT('E2 repair: offsetting DR for voucher ', v_vno, ' - reconciliation difference'),
                 v_vno, CAST(v_jno AS CHAR), CURDATE(),
                 v_teller, 'UGX', ABS(v_diff), 1, NOW());
        END IF;

        -- Log repair to fin_repair_log
        UPDATE fin_repair_log
        SET action_taken  = 'REPAIRED_E2',
            repaired_by   = v_teller,
            repair_date   = NOW(),
            repair_notes  = CONCAT('Offsetting entry inserted. diff=', ROUND(v_diff, 0))
        WHERE voucherNo   = v_vno
          AND repair_type = 'UNBALANCED_VOUCHER';

        -- Audit trail
        INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
        VALUES (v_teller, 'E2_RECON_REPAIR',
                CONCAT('voucherNo=', v_vno),
                CONCAT('Inserted offsetting entry. DR=', ROUND(v_dr,0),
                       ', CR=', ROUND(v_cr,0), ', diff=', ROUND(v_diff,0)),
                NOW());

    END LOOP;
    CLOSE cur;
END $

DELIMITER ;

CALL `_e2_fix_recon_entries`();
DROP PROCEDURE IF EXISTS `_e2_fix_recon_entries`;
