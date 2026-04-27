-- =============================================================================
-- sp_PostDepreciation.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Post period depreciation into GL and mark period depreciation_posted = TRUE.
--
-- NOTES:
--   * Uses explicit amount input (p_depreciation_amount) to avoid relying on
--     optional fixed-asset sub-ledger tables.
--   * Posts 2 journal lines:
--       DR  p_depr_expense_account
--       CR  p_accum_depr_account
-- =============================================================================

DROP PROCEDURE IF EXISTS sp_PostDepreciation;

DELIMITER $$

CREATE PROCEDURE sp_PostDepreciation(
    IN  p_fiscal_year          VARCHAR(10),
    IN  p_period_number        INT,
    IN  p_posted_by            VARCHAR(50),
    IN  p_depreciation_amount  DECIMAL(15,2),
    IN  p_depr_expense_account VARCHAR(50),
    IN  p_accum_depr_account   VARCHAR(50),
    OUT p_result_code          VARCHAR(30),
    OUT p_result_message       VARCHAR(500)
)
proc_body: BEGIN
    DECLARE v_period_id      INT DEFAULT NULL;
    DECLARE v_start_date     DATE DEFAULT NULL;
    DECLARE v_end_date       DATE DEFAULT NULL;
    DECLARE v_is_open        TINYINT DEFAULT 0;
    DECLARE v_is_archived    TINYINT DEFAULT 0;
    DECLARE v_dep_posted     TINYINT DEFAULT 0;

    DECLARE v_batch_id       INT DEFAULT NULL;
    DECLARE v_voucher_no     VARCHAR(50) DEFAULT NULL;
    DECLARE v_next_no        INT DEFAULT 0;
    DECLARE v_prefix         VARCHAR(10) DEFAULT 'DEP';

    DECLARE v_sqlstate       VARCHAR(5) DEFAULT '00000';
    DECLARE v_sqlerrm        TEXT DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_sqlerrm  = MESSAGE_TEXT;
        ROLLBACK;
        SET p_result_code = 'ERROR';
        SET p_result_message = CONCAT('SQLSTATE=', v_sqlstate, ': ', v_sqlerrm);
    END;

    IF p_depreciation_amount IS NULL OR p_depreciation_amount <= 0 THEN
        SET p_result_code = 'INVALID_AMOUNT';
        SET p_result_message = 'Depreciation amount must be greater than zero.';
        LEAVE proc_body;
    END IF;

    IF p_depr_expense_account IS NULL OR p_depr_expense_account = ''
       OR p_accum_depr_account IS NULL OR p_accum_depr_account = '' THEN
        SET p_result_code = 'INVALID_ACCOUNTS';
        SET p_result_message = 'Both depreciation expense and accumulated depreciation accounts are required.';
        LEAVE proc_body;
    END IF;

    SELECT
        period_id,
        start_date,
        end_date,
        COALESCE(is_open_for_posting, 0),
        COALESCE(is_archived, 0),
        COALESCE(depreciation_posted, 0)
    INTO
        v_period_id,
        v_start_date,
        v_end_date,
        v_is_open,
        v_is_archived,
        v_dep_posted
    FROM fin_accounting_periods
    WHERE fiscal_year = p_fiscal_year
      AND period_number = p_period_number
    LIMIT 1;

    IF v_period_id IS NULL THEN
        SET p_result_code = 'PERIOD_NOT_FOUND';
        SET p_result_message = 'Accounting period not found.';
        LEAVE proc_body;
    END IF;

    IF v_is_archived = 1 THEN
        SET p_result_code = 'PERIOD_ARCHIVED';
        SET p_result_message = 'Cannot post depreciation to an archived period.';
        LEAVE proc_body;
    END IF;

    IF v_dep_posted = 1 THEN
        SET p_result_code = 'ALREADY_POSTED';
        SET p_result_message = 'Depreciation has already been posted for this period.';
        LEAVE proc_body;
    END IF;

    START TRANSACTION;

    INSERT INTO fin_transaction_batch
        (batch_type, created_by, created_at, started_at, status, batch_reference, source_system)
    VALUES
        ('JournalEntry', p_posted_by, NOW(), NOW(), 'InProgress',
         CONCAT('DEP-', p_fiscal_year, '-', LPAD(p_period_number, 2, '0')),
         'sp_PostDepreciation');

    SET v_batch_id = LAST_INSERT_ID();

    INSERT INTO fin_voucher_sequence (voucher_type, current_number, prefix, fiscal_year)
    VALUES ('DepositVoucher', 0, 'DEP', p_fiscal_year)
    ON DUPLICATE KEY UPDATE fiscal_year = VALUES(fiscal_year);

    SELECT COALESCE(prefix, 'DEP'), current_number
    INTO v_prefix, v_next_no
    FROM fin_voucher_sequence
    WHERE voucher_type = 'DepositVoucher'
    FOR UPDATE;

    SET v_next_no = COALESCE(v_next_no, 0) + 1;

    UPDATE fin_voucher_sequence
       SET current_number = v_next_no,
           updated_at = NOW()
     WHERE voucher_type = 'DepositVoucher';

    SET v_voucher_no = CONCAT(v_prefix, '-', REPLACE(p_fiscal_year, '/', ''), '-', LPAD(v_next_no, 6, '0'));

    INSERT INTO fin_ledger
        (voucherno, account_code, dr_cr, amount, narration, entry_date, fiscal_period_id, batch_id, adjustment_type)
    VALUES
        (v_voucher_no, p_depr_expense_account, 'DR', p_depreciation_amount,
         CONCAT('Period depreciation expense - ', p_fiscal_year, ' P', p_period_number),
         v_end_date, v_period_id, v_batch_id, 'Original'),
        (v_voucher_no, p_accum_depr_account, 'CR', p_depreciation_amount,
         CONCAT('Accumulated depreciation posting - ', p_fiscal_year, ' P', p_period_number),
         v_end_date, v_period_id, v_batch_id, 'Original');

    UPDATE fin_transaction_batch
       SET status = 'Completed',
           completed_at = NOW(),
           transaction_count = 2,
           total_debit = p_depreciation_amount,
           total_credit = p_depreciation_amount
     WHERE batch_id = v_batch_id;

    UPDATE fin_accounting_periods
       SET depreciation_posted = 1,
           updated_at = NOW()
     WHERE period_id = v_period_id;

    INSERT INTO fin_transaction_log
        (action, table_name, record_id, batch_id, changed_by, reason_code, reason_text)
    VALUES
        ('Insert', 'fin_ledger', NULL, v_batch_id, p_posted_by,
         'DEPRECIATION_POST',
         CONCAT('Voucher=', v_voucher_no,
                ', Amount=', FORMAT(p_depreciation_amount, 2),
                ', Period=', p_fiscal_year, '-', p_period_number));

    COMMIT;

    SET p_result_code = 'OK';
    SET p_result_message = CONCAT('Depreciation posted successfully. Voucher: ', v_voucher_no, ', Batch: ', v_batch_id);
END proc_body$$

DELIMITER ;

-- Usage:
-- CALL sp_PostDepreciation('2025-2026', 10, 'finance.admin', 150000.00, 'EXP_DEPRECIATION', 'ACCUM_DEPRECIATION', @code, @msg);
-- SELECT @code, @msg;
