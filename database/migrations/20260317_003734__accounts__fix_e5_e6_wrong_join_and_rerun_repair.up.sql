-- Migration: fix_e5_e6_wrong_join_and_rerun_repair
-- Logical database: accounts
-- ============================================================================
-- The E5 migration (analyze_and_categorize_unbalanced_vouchers) used the WRONG
-- JOIN: j.JournalNo = l.voucherNo  (JournalNo is the PK auto-increment)
-- Should be: j.GL_VoucherNo = l.voucherNo  (GL_VoucherNo is the public voucher#)
--
-- This caused 2,902 of 2,906 repair_log entries to remain PENDING_REVIEW with
-- no repair_strategy set.  E6 then had nothing to process (cursor requires
-- repair_strategy IS NOT NULL).
--
-- This migration re-categorizes and re-runs the batch repair with the correct JOIN.
-- Also voids remaining empty pending journals (E3 gap: 10 still un-voided).
-- ============================================================================

DELIMITER $

DROP PROCEDURE IF EXISTS `_fix_e5_e6_rerun` $

CREATE PROCEDURE `_fix_e5_e6_rerun`()
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
    DECLARE v_teller    VARCHAR(45) DEFAULT 'SYSTEM_REPAIR_E6_FIX';
    DECLARE v_recon_acc CHAR(25) DEFAULT 'AC-RECONCILE-DIFF';

    DECLARE cur CURSOR FOR
        SELECT rl.voucherNo, rl.repair_strategy,
               rl.original_dr, rl.original_cr
        FROM fin_repair_log rl
        WHERE rl.action_taken = 'PENDING_REVIEW'
          AND rl.repair_strategy IS NOT NULL
          AND rl.repair_strategy NOT IN ('MANUAL_REVIEW_STUDENT_RECEIPT')
        ORDER BY rl.voucherNo;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;

    -- =========================================================================
    -- STEP 1: Reset repair_strategy for all PENDING_REVIEW entries
    -- =========================================================================
    UPDATE fin_repair_log
    SET repair_strategy = NULL, repair_notes = NULL
    WHERE action_taken = 'PENDING_REVIEW';

    -- =========================================================================
    -- STEP 2: Re-categorize with CORRECT JOIN (GL_VoucherNo, not JournalNo)
    -- =========================================================================
    UPDATE fin_repair_log rl
    JOIN (
        SELECT
            l.voucherNo,
            MAX(j.journalType) AS journalType,
            MAX(j.voucherType) AS voucherType,
            MAX(j.PostStatus)  AS PostStatus,
            COUNT(*)                                                                       AS line_count,
            SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END)  AS dr_total,
            SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END)  AS cr_total,
            SUM(CASE WHEN l.transactionType = 'DR' THEN 1 ELSE 0 END)                    AS dr_lines,
            SUM(CASE WHEN l.transactionType = 'CR' THEN 1 ELSE 0 END)                    AS cr_lines
        FROM fin_ledger l
        LEFT JOIN fin_journalnumbers j ON j.GL_VoucherNo = l.voucherNo
        GROUP BY l.voucherNo
        HAVING ABS(dr_total - cr_total) > 0.005
    ) sub ON sub.voucherNo = rl.voucherNo
    SET
        rl.repair_strategy = CASE
            WHEN sub.line_count = 1
                THEN 'VOID_INCOMPLETE'
            WHEN sub.PostStatus = 'Pending' AND sub.journalType IS NOT NULL
                THEN 'VOID_INCOMPLETE'
            WHEN sub.dr_lines = 0
                THEN 'INSERT_OFFSETTING_DR'
            WHEN sub.cr_lines = 0
                THEN 'INSERT_OFFSETTING_CR'
            WHEN sub.journalType IN ('Receipt') AND sub.voucherType LIKE '%Student%'
                THEN 'MANUAL_REVIEW_STUDENT_RECEIPT'
            ELSE 'INSERT_CORRECTIVE_ENTRY'
        END,
        rl.repair_notes = CONCAT(
            'lines=', sub.line_count,
            ', dr_lines=', sub.dr_lines,
            ', cr_lines=', sub.cr_lines,
            ', dr=', ROUND(sub.dr_total, 0),
            ', cr=', ROUND(sub.cr_total, 0),
            ', type=', COALESCE(sub.journalType, 'ORPHAN'),
            ', subtype=', COALESCE(sub.voucherType, 'ORPHAN'),
            ', status=', COALESCE(sub.PostStatus, 'NONE')
        )
    WHERE rl.action_taken = 'PENDING_REVIEW';

    -- =========================================================================
    -- STEP 3: Handle remaining orphans (no journal match at all)
    -- These still have repair_strategy = NULL after the JOIN
    -- =========================================================================
    UPDATE fin_repair_log rl
    SET rl.repair_strategy = CASE
            WHEN rl.original_dr = 0 OR rl.original_cr = 0 THEN 'VOID_INCOMPLETE'
            ELSE 'INSERT_CORRECTIVE_ENTRY'
        END,
        rl.repair_notes = CONCAT(
            'ORPHAN: no journal match, dr=', ROUND(rl.original_dr, 0),
            ', cr=', ROUND(rl.original_cr, 0)
        )
    WHERE rl.action_taken = 'PENDING_REVIEW'
      AND rl.repair_strategy IS NULL;

    -- Log categorization summary
    INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
    SELECT v_teller, 'E5_FIX_CATEGORIZE',
           CONCAT('strategy=', IFNULL(repair_strategy, 'NULL')),
           CONCAT('count=', COUNT(*)),
           NOW()
    FROM fin_repair_log
    WHERE action_taken = 'PENDING_REVIEW'
    GROUP BY repair_strategy;

    -- =========================================================================
    -- STEP 4: Ensure AC-RECONCILE-DIFF account exists
    -- =========================================================================
    IF NOT EXISTS (SELECT 1 FROM fin_subaccounts WHERE AccountCode = v_recon_acc) THEN
        INSERT INTO fin_subaccounts
            (AccountCode, AccountName, MainAccountCode, accounttype, Details)
        VALUES
            (v_recon_acc, 'Bank Reconciliation Differences', 'AC7003',
             'Chart Account', 'Auto-created for data repair');
    END IF;

    -- =========================================================================
    -- STEP 5: Run batch repair cursor (same logic as E6 but with fixes)
    -- =========================================================================
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

        -- Skip if diff rounds to 0 (trigger would reject amount=0)
        IF ROUND(ABS(v_diff)) < 1 THEN
            UPDATE fin_repair_log
            SET action_taken = 'ALREADY_BALANCED', repaired_by = v_teller, repair_date = NOW(),
                repair_notes = CONCAT(IFNULL(repair_notes,''), ' | diff<1, skipped')
            WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';
            SET v_skip = v_skip + 1;
            ITERATE read_loop;
        END IF;

        -- Try to find journal number for this voucher
        SET v_jno = NULL;
        SELECT JournalNo INTO v_jno
        FROM fin_journalnumbers WHERE GL_VoucherNo = v_vno LIMIT 1;

        CASE v_strategy

            WHEN 'VOID_INCOMPLETE' THEN
                IF v_jno IS NOT NULL THEN
                    UPDATE fin_journalnumbers
                    SET PostStatus  = 'Void',
                        void_reason = 'Auto-voided E6-fix: incomplete entry, no valid double-entry pair'
                    WHERE GL_VoucherNo = v_vno AND PostStatus != 'Void';
                END IF;
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
                     CONCAT('E6-fix repair: offsetting CR for voucher ', v_vno),
                     v_vno, CAST(IFNULL(v_jno, v_vno) AS CHAR), CURDATE(), v_teller,
                     'UGX', ROUND(ABS(v_diff)), 1, NOW());
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
                     CONCAT('E6-fix repair: offsetting DR for voucher ', v_vno),
                     v_vno, CAST(IFNULL(v_jno, v_vno) AS CHAR), CURDATE(), v_teller,
                     'UGX', ROUND(ABS(v_diff)), 1, NOW());
                UPDATE fin_repair_log
                SET action_taken = 'REPAIRED_E6', repaired_by = v_teller, repair_date = NOW()
                WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';

            WHEN 'INSERT_CORRECTIVE_ENTRY' THEN
                IF v_diff > 0.005 THEN
                    INSERT INTO fin_ledger
                        (accountcode, account_type, transactionType, transaction_amount,
                         particulars, voucherNo, journal_no, transactionDate, teller,
                         trans_currency, actual_amount, forex_rate, timeLog)
                    VALUES
                        (v_recon_acc, 'Chart Account', 'CR', CAST(ROUND(v_diff) AS UNSIGNED),
                         CONCAT('E6-fix repair: corrective CR for voucher ', v_vno),
                         v_vno, CAST(IFNULL(v_jno, v_vno) AS CHAR), CURDATE(), v_teller,
                         'UGX', ROUND(v_diff), 1, NOW());
                ELSE
                    INSERT INTO fin_ledger
                        (accountcode, account_type, transactionType, transaction_amount,
                         particulars, voucherNo, journal_no, transactionDate, teller,
                         trans_currency, actual_amount, forex_rate, timeLog)
                    VALUES
                        (v_recon_acc, 'Chart Account', 'DR', CAST(ROUND(ABS(v_diff)) AS UNSIGNED),
                         CONCAT('E6-fix repair: corrective DR for voucher ', v_vno),
                         v_vno, CAST(IFNULL(v_jno, v_vno) AS CHAR), CURDATE(), v_teller,
                         'UGX', ROUND(ABS(v_diff)), 1, NOW());
                END IF;
                UPDATE fin_repair_log
                SET action_taken = 'REPAIRED_E6', repaired_by = v_teller, repair_date = NOW()
                WHERE voucherNo = v_vno AND action_taken = 'PENDING_REVIEW';

            ELSE
                SET v_skip = v_skip + 1;
                ITERATE read_loop;
        END CASE;

        INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
        VALUES (v_teller, 'E6_FIX_BATCH_REPAIR',
                CONCAT('voucherNo=', v_vno, ', strategy=', v_strategy),
                CONCAT('dr=', ROUND(v_dr,0), ', cr=', ROUND(v_cr,0), ', diff=', ROUND(v_diff,0)),
                NOW());

        SET v_count = v_count + 1;
    END LOOP;
    CLOSE cur;

    -- =========================================================================
    -- STEP 6: Void remaining empty pending journals (E3 gap)
    -- =========================================================================
    UPDATE fin_journalnumbers
    SET PostStatus  = 'Void',
        void_reason = 'Auto-voided: empty journal with no details'
    WHERE PostStatus = 'Pending'
      AND JournalNo NOT IN (SELECT DISTINCT journal_no FROM fin_journal_details);

    -- =========================================================================
    -- STEP 7: Summary output
    -- =========================================================================
    SELECT v_count AS vouchers_repaired, v_skip AS vouchers_skipped;

    SELECT action_taken, COUNT(*) AS cnt
    FROM fin_repair_log GROUP BY action_taken ORDER BY cnt DESC;

    -- Check remaining unbalanced
    SELECT COUNT(*) AS still_unbalanced
    FROM (
        SELECT voucherNo
        FROM fin_ledger
        GROUP BY voucherNo
        HAVING ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END)
                 - SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END)) > 0.005
    ) t;

END $

DELIMITER ;

CALL `_fix_e5_e6_rerun`();
DROP PROCEDURE IF EXISTS `_fix_e5_e6_rerun`;

-- Recalculate all running ledger balances
CALL fin_UpdateAllLedgerBalances();
