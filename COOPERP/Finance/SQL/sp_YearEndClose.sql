-- =============================================================================
-- sp_YearEndClose.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Execute year-end close for one fiscal year:
--     1) Verify all 12 periods are month-end frozen
--     2) Verify depreciation posted for all periods
--     3) Post closing entries (P&L summary -> Retained Earnings)
--     4) Mark periods archived/closed
--     5) Write audit log
-- =============================================================================

DROP PROCEDURE IF EXISTS sp_YearEndClose;

DELIMITER $$

CREATE PROCEDURE sp_YearEndClose(
    IN  p_fiscal_year             VARCHAR(10),
    IN  p_closed_by               VARCHAR(50),
    IN  p_pl_closing_account      VARCHAR(50),
    IN  p_retained_earnings_acct  VARCHAR(50),
    OUT p_result_code             VARCHAR(30),
    OUT p_result_message          VARCHAR(500)
)
proc_body: BEGIN
    DECLARE v_total_periods INT DEFAULT 0;
    DECLARE v_frozen_periods INT DEFAULT 0;
    DECLARE v_dep_posted_periods INT DEFAULT 0;

    DECLARE v_batch_id INT DEFAULT NULL;
    DECLARE v_voucher_no VARCHAR(50) DEFAULT NULL;
    DECLARE v_next_no INT DEFAULT 0;
    DECLARE v_prefix VARCHAR(10) DEFAULT 'JNL';

    DECLARE v_total_income DECIMAL(15,2) DEFAULT 0;
    DECLARE v_total_expense DECIMAL(15,2) DEFAULT 0;
    DECLARE v_net_result DECIMAL(15,2) DEFAULT 0;

    DECLARE v_sqlstate VARCHAR(5) DEFAULT '00000';
    DECLARE v_sqlerrm TEXT DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_sqlerrm  = MESSAGE_TEXT;
        ROLLBACK;
        SET p_result_code = 'ERROR';
        SET p_result_message = CONCAT('SQLSTATE=', v_sqlstate, ': ', v_sqlerrm);
    END;

    IF p_pl_closing_account IS NULL OR p_pl_closing_account = ''
       OR p_retained_earnings_acct IS NULL OR p_retained_earnings_acct = '' THEN
        SET p_result_code = 'INVALID_ACCOUNTS';
        SET p_result_message = 'P&L closing account and retained earnings account are required.';
        LEAVE proc_body;
    END IF;

    SELECT COUNT(*) INTO v_total_periods
    FROM fin_accounting_periods
    WHERE fiscal_year = p_fiscal_year;

    IF v_total_periods < 12 THEN
        SET p_result_code = 'INCOMPLETE_YEAR';
        SET p_result_message = CONCAT('Expected 12 periods but found ', v_total_periods, ' for fiscal year ', p_fiscal_year, '.');
        LEAVE proc_body;
    END IF;

    SELECT COUNT(*) INTO v_frozen_periods
    FROM fin_accounting_periods
    WHERE fiscal_year = p_fiscal_year
      AND COALESCE(is_frozen_for_month_end, 0) = 1;

    IF v_frozen_periods < 12 THEN
        SET p_result_code = 'MONTHS_NOT_FROZEN';
        SET p_result_message = CONCAT('Only ', v_frozen_periods, ' period(s) are frozen. Freeze all 12 periods first.');
        LEAVE proc_body;
    END IF;

    SELECT COUNT(*) INTO v_dep_posted_periods
    FROM fin_accounting_periods
    WHERE fiscal_year = p_fiscal_year
      AND COALESCE(depreciation_posted, 0) = 1;

    IF v_dep_posted_periods < 12 THEN
        SET p_result_code = 'DEPRECIATION_PENDING';
        SET p_result_message = CONCAT('Depreciation is posted for ', v_dep_posted_periods, ' period(s). Post for all 12 first.');
        LEAVE proc_body;
    END IF;

    START TRANSACTION;

    SELECT
        COALESCE(SUM(CASE
            WHEN UPPER(account_code) LIKE 'INCOME%'
             AND UPPER(COALESCE(dr_cr, '')) IN ('CR','CREDIT','C') THEN amount
            WHEN UPPER(account_code) LIKE 'INCOME%'
             AND UPPER(COALESCE(dr_cr, '')) IN ('DR','DEBIT','D') THEN -amount
            ELSE 0 END), 0),
        COALESCE(SUM(CASE
            WHEN UPPER(account_code) LIKE 'EXPENSE%'
             AND UPPER(COALESCE(dr_cr, '')) IN ('DR','DEBIT','D') THEN amount
            WHEN UPPER(account_code) LIKE 'EXPENSE%'
             AND UPPER(COALESCE(dr_cr, '')) IN ('CR','CREDIT','C') THEN -amount
            ELSE 0 END), 0)
    INTO v_total_income, v_total_expense
    FROM fin_ledger l
    INNER JOIN fin_accounting_periods p ON p.period_id = l.fiscal_period_id
    WHERE p.fiscal_year = p_fiscal_year
      AND COALESCE(l.is_deleted, 0) = 0;

    SET v_net_result = ROUND(v_total_income - v_total_expense, 2);

    INSERT INTO fin_transaction_batch
        (batch_type, created_by, created_at, started_at, status, batch_reference, source_system)
    VALUES
        ('JournalEntry', p_closed_by, NOW(), NOW(), 'InProgress',
         CONCAT('YE-', p_fiscal_year), 'sp_YearEndClose');

    SET v_batch_id = LAST_INSERT_ID();

    INSERT INTO fin_voucher_sequence (voucher_type, current_number, prefix, fiscal_year)
    VALUES ('JournalEntry', 0, 'JNL', p_fiscal_year)
    ON DUPLICATE KEY UPDATE fiscal_year = VALUES(fiscal_year);

    SELECT COALESCE(prefix, 'JNL'), current_number
    INTO v_prefix, v_next_no
    FROM fin_voucher_sequence
    WHERE voucher_type = 'JournalEntry'
    FOR UPDATE;

    SET v_next_no = COALESCE(v_next_no, 0) + 1;

    UPDATE fin_voucher_sequence
       SET current_number = v_next_no,
           updated_at = NOW()
     WHERE voucher_type = 'JournalEntry';

    SET v_voucher_no = CONCAT(v_prefix, '-', REPLACE(p_fiscal_year, '/', ''), '-YE-', LPAD(v_next_no, 6, '0'));

    IF ABS(v_net_result) > 0.005 THEN
        IF v_net_result > 0 THEN
            INSERT INTO fin_ledger
                (voucherno, account_code, dr_cr, amount, narration, entry_date, fiscal_period_id, batch_id, adjustment_type)
            VALUES
                (v_voucher_no, p_pl_closing_account, 'DR', ABS(v_net_result),
                 CONCAT('Year-end close: transfer profit to retained earnings (', p_fiscal_year, ')'),
                 CURDATE(), NULL, v_batch_id, 'Original'),
                (v_voucher_no, p_retained_earnings_acct, 'CR', ABS(v_net_result),
                 CONCAT('Year-end close retained earnings (', p_fiscal_year, ')'),
                 CURDATE(), NULL, v_batch_id, 'Original');
        ELSE
            INSERT INTO fin_ledger
                (voucherno, account_code, dr_cr, amount, narration, entry_date, fiscal_period_id, batch_id, adjustment_type)
            VALUES
                (v_voucher_no, p_retained_earnings_acct, 'DR', ABS(v_net_result),
                 CONCAT('Year-end close: transfer loss to retained earnings (', p_fiscal_year, ')'),
                 CURDATE(), NULL, v_batch_id, 'Original'),
                (v_voucher_no, p_pl_closing_account, 'CR', ABS(v_net_result),
                 CONCAT('Year-end close P&L closing entry (', p_fiscal_year, ')'),
                 CURDATE(), NULL, v_batch_id, 'Original');
        END IF;
    END IF;

    UPDATE fin_transaction_batch
       SET status = 'Completed',
           completed_at = NOW(),
           transaction_count = CASE WHEN ABS(v_net_result) > 0.005 THEN 2 ELSE 0 END,
           total_debit = CASE WHEN ABS(v_net_result) > 0.005 THEN ABS(v_net_result) ELSE 0 END,
           total_credit = CASE WHEN ABS(v_net_result) > 0.005 THEN ABS(v_net_result) ELSE 0 END
     WHERE batch_id = v_batch_id;

    UPDATE fin_accounting_periods
       SET is_open_for_posting = 0,
           is_frozen_for_month_end = 0,
           is_closed_for_adjustment = 1,
           is_archived = 1,
           posted_by_user = p_closed_by,
           locked_at = NOW(),
           updated_at = NOW()
     WHERE fiscal_year = p_fiscal_year;

    INSERT INTO fin_transaction_log
        (action, table_name, record_id, batch_id, changed_by, reason_code, reason_text)
    VALUES
        ('Validate', 'fin_accounting_periods', NULL, v_batch_id, p_closed_by,
         'YEAR_END_CLOSE',
         CONCAT('FiscalYear=', p_fiscal_year,
                ', Voucher=', v_voucher_no,
                ', NetResult=', FORMAT(v_net_result, 2),
                ', Income=', FORMAT(v_total_income, 2),
                ', Expense=', FORMAT(v_total_expense, 2)));

    COMMIT;

    SET p_result_code = 'OK';
    SET p_result_message = CONCAT('Year-end close complete for ', p_fiscal_year,
                                  '. Voucher=', v_voucher_no,
                                  ', NetResult=', FORMAT(v_net_result, 2),
                                  ', Batch=', v_batch_id);
END proc_body$$

DELIMITER ;

-- Usage:
-- CALL sp_YearEndClose('2025-2026', 'finance.admin', 'P_AND_L_CLOSING', 'RETAINED_EARNINGS', @code, @msg);
-- SELECT @code, @msg;
