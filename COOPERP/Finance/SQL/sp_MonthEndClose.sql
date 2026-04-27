-- =============================================================================
-- sp_MonthEndClose.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   MySQL stored procedure that executes a month-end close for a specific
--   accounting period.  It validates pre-conditions and then:
--     1. Verifies the period exists and is still open
--     2. Checks that no incomplete transaction batches exist in the period
--     3. Verifies the trial balance is in balance (SUM DR = SUM CR in fin_ledger)
--     4. Freezes the period (is_frozen_for_month_end = 1, is_open = 0)
--     5. Records the action in fin_transaction_log
--
-- PARAMETERS:
--   p_fiscal_year    VARCHAR(10)  — e.g. '2024/2025'
--   p_period_number  INT          — 1..12
--   p_closed_by      VARCHAR(50)  — username of the person closing the period
--
-- OUTPUT CODES (via p_result_code OUT):
--   'OK'               — Period closed successfully
--   'PERIOD_NOT_FOUND' — No matching period in fin_accounting_periods
--   'ALREADY_CLOSED'   — Period is already frozen/closed
--   'OPEN_BATCHES'     — Incomplete transaction batches exist in this period
--   'IMBALANCED'       — Trial balance is not in balance; close blocked
--   'ERROR'            — Unexpected error (see p_result_message)
--
-- PREREQUISITES:
--   Phase1_1_Create_Batch_Tables.sql  (fin_transaction_batch, fin_transaction_log)
--   Phase1_2_Create_Period_Tables.sql (fin_accounting_periods)
--   Phase1_4_Alter_fin_ledger.sql     (fin_ledger.period_id / batch_id columns)
--
-- INSTRUCTIONS:
--   Execute as a DBA with CREATE ROUTINE privilege.
--   Call from Finance Admin UI via ado.net CommandType.StoredProcedure.
-- =============================================================================

DROP PROCEDURE IF EXISTS sp_MonthEndClose;

DELIMITER $$

CREATE PROCEDURE sp_MonthEndClose(
    IN  p_fiscal_year    VARCHAR(10),
    IN  p_period_number  INT,
    IN  p_closed_by      VARCHAR(50),
    OUT p_result_code    VARCHAR(30),
    OUT p_result_message VARCHAR(500)
)
proc_body: BEGIN
    -- ── Local variables ───────────────────────────────────────────────────────
    DECLARE v_period_id          BIGINT DEFAULT NULL;
    DECLARE v_is_open            TINYINT DEFAULT 1;
    DECLARE v_is_frozen          TINYINT DEFAULT 0;
    DECLARE v_period_start       DATE DEFAULT NULL;
    DECLARE v_period_end         DATE DEFAULT NULL;
    DECLARE v_open_batches       INT DEFAULT 0;
    DECLARE v_total_dr           DECIMAL(18,4) DEFAULT 0;
    DECLARE v_total_cr           DECIMAL(18,4) DEFAULT 0;
    DECLARE v_balance_diff       DECIMAL(18,4) DEFAULT 0;
    DECLARE v_has_period_id_col  TINYINT DEFAULT 0;
    DECLARE v_has_frozen_col     TINYINT DEFAULT 0;
    DECLARE v_has_tb_checked_col TINYINT DEFAULT 0;
    DECLARE v_exit_handler_fired TINYINT DEFAULT 0;
    DECLARE v_sqlstate           VARCHAR(5) DEFAULT '00000';
    DECLARE v_sqlerrm            TEXT DEFAULT '';

    -- ── Exit handler for unexpected errors ────────────────────────────────────
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_sqlerrm  = MESSAGE_TEXT;
        ROLLBACK;
        SET p_result_code    = 'ERROR';
        SET p_result_message = CONCAT('SQLSTATE=', v_sqlstate, ': ', v_sqlerrm);
    END;

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 0: Schema guard — check optional column availability
    -- ─────────────────────────────────────────────────────────────────────────
    SET v_has_period_id_col = (
        SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'fin_accounting_periods'
          AND COLUMN_NAME  = 'is_frozen_for_month_end'
    );

    SET v_has_frozen_col = v_has_period_id_col;   -- same column check

    SET v_has_tb_checked_col = (
        SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'fin_accounting_periods'
          AND COLUMN_NAME  = 'trial_balance_balanced'
    );

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 1: Locate the period
    -- ─────────────────────────────────────────────────────────────────────────
    SELECT period_id, is_open,
           COALESCE(is_frozen_for_month_end, 0),
           start_date, end_date
      INTO v_period_id, v_is_open, v_is_frozen, v_period_start, v_period_end
      FROM fin_accounting_periods
     WHERE fiscal_year   = p_fiscal_year
       AND period_number = p_period_number
     LIMIT 1;

    IF v_period_id IS NULL THEN
        SET p_result_code    = 'PERIOD_NOT_FOUND';
        SET p_result_message = CONCAT(
            'No period found for fiscal_year=', p_fiscal_year,
            ', period_number=', p_period_number, '.');
        LEAVE proc_body;
    END IF;

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 2: Check period is still open and not already frozen
    -- ─────────────────────────────────────────────────────────────────────────
    IF v_is_frozen = 1 OR v_is_open = 0 THEN
        SET p_result_code    = 'ALREADY_CLOSED';
        SET p_result_message = CONCAT(
            'Period ', p_fiscal_year, '/', p_period_number,
            ' is already closed or frozen. No action taken.');
        LEAVE proc_body;
    END IF;

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 3: Check for open/pending transaction batches in this period
    --         Uses fin_transaction_batch.period_id if the column exists,
    --         otherwise falls back to date-range check on created_at.
    -- ─────────────────────────────────────────────────────────────────────────
    SET v_has_period_id_col = (
        SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'fin_transaction_batch'
          AND COLUMN_NAME  = 'period_id'
    );

    IF v_has_period_id_col > 0 THEN
        SELECT COUNT(*) INTO v_open_batches
          FROM fin_transaction_batch
         WHERE period_id = v_period_id
           AND batch_status IN ('Created', 'Processing');
    ELSE
        SELECT COUNT(*) INTO v_open_batches
          FROM fin_transaction_batch
         WHERE batch_status IN ('Created', 'Processing')
           AND DATE(created_at) BETWEEN v_period_start AND v_period_end;
    END IF;

    IF v_open_batches > 0 THEN
        SET p_result_code    = 'OPEN_BATCHES';
        SET p_result_message = CONCAT(
            v_open_batches, ' incomplete transaction batch(es) exist for this period. ',
            'Resolve or cancel them before closing the period.');
        LEAVE proc_body;
    END IF;

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 4: Trial balance check — SUM(DR) must equal SUM(CR) from fin_ledger
    --         Falls back to date range when period_id column on fin_ledger absent.
    -- ─────────────────────────────────────────────────────────────────────────
    SET v_has_period_id_col = (
        SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'fin_ledger'
          AND COLUMN_NAME  = 'period_id'
    );

    IF v_has_period_id_col > 0 THEN
        -- Prefer explicit period_id linkage (most accurate)
        SELECT
            COALESCE(SUM(CASE WHEN UPPER(COALESCE(dr_cr, entry_type, drcr, '')) IN ('DR','DEBIT','D') THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN UPPER(COALESCE(dr_cr, entry_type, drcr, '')) IN ('CR','CREDIT','C') THEN amount ELSE 0 END), 0)
          INTO v_total_dr, v_total_cr
          FROM fin_ledger
         WHERE period_id = v_period_id;
    ELSE
        -- Fallback: date-range approximation
        SELECT
            COALESCE(SUM(CASE WHEN UPPER(COALESCE(dr_cr, entry_type, drcr, '')) IN ('DR','DEBIT','D') THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN UPPER(COALESCE(dr_cr, entry_type, drcr, '')) IN ('CR','CREDIT','C') THEN amount ELSE 0 END), 0)
          INTO v_total_dr, v_total_cr
          FROM fin_ledger
         WHERE COALESCE(entry_date, trans_date, `date`, posting_date)
               BETWEEN v_period_start AND v_period_end;
    END IF;

    SET v_balance_diff = ABS(v_total_dr - v_total_cr);

    -- Allow tolerance of 0.005 to accommodate rounding in legacy data
    IF v_balance_diff > 0.005 THEN
        SET p_result_code    = 'IMBALANCED';
        SET p_result_message = CONCAT(
            'Trial balance is out of balance by ', v_balance_diff, '. ',
            'Total DR=', v_total_dr, ', Total CR=', v_total_cr, '. ',
            'Correct the imbalance before closing the period.');
        LEAVE proc_body;
    END IF;

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 5: Freeze the period — all within a transaction
    -- ─────────────────────────────────────────────────────────────────────────
    START TRANSACTION;

    -- Core freeze: always available columns
    UPDATE fin_accounting_periods
       SET is_open  = 0,
           closed_by = p_closed_by,
           closed_at = NOW()
     WHERE period_id = v_period_id;

    -- Optional columns — update only if they exist
    IF v_has_frozen_col > 0 THEN
        UPDATE fin_accounting_periods
           SET is_frozen_for_month_end = 1
         WHERE period_id = v_period_id;
    END IF;

    IF v_has_tb_checked_col > 0 THEN
        UPDATE fin_accounting_periods
           SET trial_balance_balanced    = 1,
               trial_balance_checked_by  = p_closed_by,
               trial_balance_checked_at  = NOW()
         WHERE period_id = v_period_id;
    END IF;

    -- Audit log — columns match Phase1_1_Create_Batch_Tables.sql schema exactly
    INSERT INTO fin_transaction_log
        (action, table_name, record_id, batch_id, changed_by, reason_code, reason_text)
    VALUES (
        'MonthEndClose',
        'fin_accounting_periods',
        v_period_id,
        NULL,
        p_closed_by,
        CONCAT(p_fiscal_year, '/', LPAD(p_period_number, 2, '0')),
        CONCAT('Period closed. DR=', v_total_dr, ', CR=', v_total_cr, ', Diff=', v_balance_diff, '.')
    );

    COMMIT;

    -- ─────────────────────────────────────────────────────────────────────────
    -- STEP 6: Return success
    -- ─────────────────────────────────────────────────────────────────────────
    SET p_result_code    = 'OK';
    SET p_result_message = CONCAT(
        'Period ', p_fiscal_year, '/', p_period_number,
        ' successfully closed by ', p_closed_by,
        '. Trial balance: DR=', v_total_dr, ' CR=', v_total_cr, '.');

END proc_body$$

DELIMITER ;

-- =============================================================================
-- USAGE EXAMPLE
-- =============================================================================
-- CALL sp_MonthEndClose('2024/2025', 6, 'admin', @code, @msg);
-- SELECT @code AS result_code, @msg AS result_message;
-- =============================================================================
