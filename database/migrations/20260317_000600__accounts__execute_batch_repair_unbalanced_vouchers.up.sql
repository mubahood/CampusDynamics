-- E6: Execute batch repair of categorized unbalanced vouchers
-- Processes all strategies set by E5 except MANUAL_REVIEW_STUDENT_RECEIPT.
-- Calls fin_UpdateAllLedgerBalances() at the end.

DELIMITER $

DROP PROCEDURE IF EXISTS `_e6_batch_repair` $

CREATE PROCEDURE `_e6_batch_repair`()
BEGIN
    DECLARE v_vno       INT;
    DECLARE v_strategy  VARCHAR(60);
    DECLARE v_dr        DECIMAL(20,4);
    DECLARE v_cr        DECIMAL(20,4);
    DECLARE v_diff      DECIMAL(20,4);
    DECLARE v_jno       INT;
    DECLARE v_done      INT DEFAULT 0;
    DECLARE v_count     INT DEFAULT 0;
    DECLARE v_skip      INT DEFAULT 0;
    DECLARE v_teller    VARCHAR(45) DEFAULT 'SYSTEM_REPAIR_E6';
    DECLARE v_recon_acc CHAR(25) DEFAULT 'AC-RECONCILE-DIFF';

    DECLARE cur CURSOR FOR
        SELECT rl.voucherNo, rl.repair_strategy,
               rl.original_dr, rl.original_cr
        FROM fin_repair_log rl
        WHERE rl.action_taken = 'PENDING_REVIEW'
          AND rl.repair_strategy IS NOT NULL
          AND rl.repair_strategy != 'MANUAL_REVIEW_STUDENT_RECEIPT'
        ORDER BY rl.voucherNo;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Ensure AC-RECONCILE-DIFF account exists (E2 may have already created it)
    IF NOT EXISTS (SELECT 1 FROM fin_subaccounts WHERE AccountCode = v_recon_acc) THEN
        INSERT INTO fin_subaccounts
            (AccountCode, AccountName, MainAccountCode, accounttype, Details)
        VALUES
            (v_recon_acc, 'Bank Reconciliation Differences', 'AC7003',
             'Chart Account', 'Auto-created for data repair 2026-03-17');
    END IF;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_vno, v_strategy, v_dr, v_cr;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Re-check live balance (another repair may have already fixed it)
        SELECT
            COALESCE(SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END), 0)
        INTO v_dr, v_cr
        FROM fin_ledger WHERE voucherNo = v_vno;

        SET v_diff = v_dr - v_cr;

        IF ABS(v_diff) <= 0.005 THEN
            UPDATE fin_repair_log
            SET action_taken = 'ALREADY_BALANCED', repaired_by = v_teller, repair_date = NOW()
            WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';
            SET v_skip = v_skip + 1;
            ITERATE read_loop;
        END IF;

        SELECT JournalNo INTO v_jno
        FROM fin_journalnumbers WHERE GL_VoucherNo = v_vno LIMIT 1;

        CASE v_strategy

            WHEN 'VOID_INCOMPLETE' THEN
                UPDATE fin_journalnumbers
                SET PostStatus  = 'Void',
                    void_reason = 'Auto-voided E6: single-line entry, no valid double-entry pair'
                WHERE GL_VoucherNo = v_vno;
                UPDATE fin_repair_log
                SET action_taken = 'VOIDED_E6', repaired_by = v_teller, repair_date = NOW()
                WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';

            WHEN 'INSERT_OFFSETTING_CR' THEN
                INSERT INTO fin_ledger
                    (accountcode, account_type, transactionType, transaction_amount,
                     particulars, voucherNo, journal_no, transactionDate, teller,
                     trans_currency, actual_amount, forex_rate, timeLog)
                VALUES
                    (v_recon_acc, 'Chart Account', 'CR', CAST(ROUND(ABS(v_diff)) AS UNSIGNED),
                     CONCAT('E6 repair: offsetting CR for voucher ', v_vno),
                     v_vno, CAST(v_jno AS CHAR), CURDATE(), v_teller, 'UGX', ABS(v_diff), 1, NOW());
                UPDATE fin_repair_log
                SET action_taken = 'REPAIRED_E6', repaired_by = v_teller, repair_date = NOW()
                WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';

            WHEN 'INSERT_OFFSETTING_DR' THEN
                INSERT INTO fin_ledger
                    (accountcode, account_type, transactionType, transaction_amount,
                     particulars, voucherNo, journal_no, transactionDate, teller,
                     trans_currency, actual_amount, forex_rate, timeLog)
                VALUES
                    (v_recon_acc, 'Chart Account', 'DR', CAST(ROUND(ABS(v_diff)) AS UNSIGNED),
                     CONCAT('E6 repair: offsetting DR for voucher ', v_vno),
                     v_vno, CAST(v_jno AS CHAR), CURDATE(), v_teller, 'UGX', ABS(v_diff), 1, NOW());
                UPDATE fin_repair_log
                SET action_taken = 'REPAIRED_E6', repaired_by = v_teller, repair_date = NOW()
                WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';

            WHEN 'INSERT_CORRECTIVE_ENTRY' THEN
                IF v_diff > 0.005 THEN
                    INSERT INTO fin_ledger
                        (accountcode, account_type, transactionType, transaction_amount,
                         particulars, voucherNo, journal_no, transactionDate, teller,
                         trans_currency, actual_amount, forex_rate)
                    VALUES
                        (v_recon_acc, 'Chart Account', 'CR', CAST(ROUND(v_diff) AS UNSIGNED),
                         CONCAT('E6 repair: corrective CR for voucher ', v_vno),
                         v_vno, CAST(v_jno AS CHAR), CURDATE(), v_teller, 'UGX', v_diff, 1, NOW());
                ELSE
                    INSERT INTO fin_ledger
                        (accountcode, account_type, transactionType, transaction_amount,
                         particulars, voucherNo, journal_no, transactionDate, teller,
                         trans_currency, actual_amount, forex_rate)
                    VALUES
                        (v_recon_acc, 'Chart Account', 'DR', CAST(ROUND(ABS(v_diff)) AS UNSIGNED),
                         CONCAT('E6 repair: corrective DR for voucher ', v_vno),
                         v_vno, CAST(v_jno AS CHAR), CURDATE(), v_teller, 'UGX', ABS(v_diff), 1, NOW());
                END IF;
                UPDATE fin_repair_log
                SET action_taken = 'REPAIRED_E6', repaired_by = v_teller, repair_date = NOW()
                WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';

            ELSE
                SET v_skip = v_skip + 1;
                ITERATE read_loop;
        END CASE;

        INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
        VALUES (v_teller, 'E6_BATCH_REPAIR',
                CONCAT('voucherNo=', v_vno, ', strategy=', v_strategy),
                CONCAT('dr=', ROUND(v_dr,0), ', cr=', ROUND(v_cr,0), ', diff=', ROUND(v_diff,0)),
                NOW());

        SET v_count = v_count + 1;
    END LOOP;
    CLOSE cur;

    SELECT v_count AS vouchers_repaired, v_skip AS vouchers_skipped;

    SELECT action_taken, COUNT(*) AS cnt
    FROM fin_repair_log GROUP BY action_taken ORDER BY cnt DESC;

END $

DELIMITER ;

CALL `_e6_batch_repair`();
DROP PROCEDURE IF EXISTS `_e6_batch_repair`;

-- Recalculate all running ledger balances
CALL fin_UpdateAllLedgerBalances();
