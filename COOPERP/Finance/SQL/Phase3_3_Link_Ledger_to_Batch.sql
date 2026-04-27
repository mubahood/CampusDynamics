-- =============================================================================
-- Phase3_3_Link_Ledger_to_Batch.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Link historical fin_ledger rows to fin_transaction_batch via voucher number
--   so every existing ledger row has a batch context.
--
-- SAFETY:
--   * Idempotent (updates only where batch_id is NULL)
--   * Schema-aware column detection
--   * No deletes or destructive updates
-- =============================================================================

USE campus_dynamics_portal;

SELECT 'Phase3_3: checking prerequisites...' AS step;

SELECT
    (SELECT COUNT(*) FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_transaction_batch') AS batch_table_exists,
    (SELECT COUNT(*) FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_ledger') AS ledger_table_exists,
    (SELECT COUNT(*) FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_ledger' AND COLUMN_NAME = 'batch_id') AS ledger_batch_id_col_exists;

SET @voucher_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME IN ('voucherno','voucher_no','voucher_number','ref_no')
    ORDER BY FIELD(COLUMN_NAME, 'voucherno','voucher_no','voucher_number','ref_no')
    LIMIT 1
);

SET @adj_col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME  = 'adjustment_type'
);

SET @is_deleted_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'is_deleted'
    LIMIT 1
);

SELECT CONCAT('Using voucher column: ', COALESCE(@voucher_col, 'NOT FOUND')) AS voucher_column;

SET @sql_update = CONCAT(
    'UPDATE fin_ledger l ',
    'INNER JOIN fin_transaction_batch b ON b.batch_reference = l.', @voucher_col, ' ',
    'SET l.batch_id = b.batch_id',
    IF(@adj_col_exists > 0, ', l.adjustment_type = COALESCE(l.adjustment_type, ''Original'')', ''),
    ' WHERE l.batch_id IS NULL ',
    IF(@is_deleted_col IS NOT NULL, CONCAT(' AND COALESCE(l.`', @is_deleted_col, '`, 0) = 0 '), ''),
    ' AND l.', @voucher_col, ' IS NOT NULL '
);

PREPARE stmt_update FROM @sql_update;
EXECUTE stmt_update;
SET @linked_rows = ROW_COUNT();
DEALLOCATE PREPARE stmt_update;

SELECT CONCAT('Ledger rows linked to batch_id: ', @linked_rows) AS result;

SET @sql_remaining = CONCAT(
    'SELECT COUNT(*) AS remaining_unlinked_rows ',
    'FROM fin_ledger l ',
    'WHERE l.batch_id IS NULL ',
    IF(@is_deleted_col IS NOT NULL, CONCAT(' AND COALESCE(l.`', @is_deleted_col, '`, 0) = 0 '), '')
);

PREPARE stmt_remaining FROM @sql_remaining;
EXECUTE stmt_remaining;
DEALLOCATE PREPARE stmt_remaining;

SELECT 'Phase3_3 complete. Run Phase3_4 next.' AS status;
