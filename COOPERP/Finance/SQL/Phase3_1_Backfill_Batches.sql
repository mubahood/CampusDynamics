-- =============================================================================
-- Phase3_1_Backfill_Batches.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Retroactively create one fin_transaction_batch record per unique voucher
--   in fin_ledger so historical transactions participate in batch monitoring.
--
-- SAFETY:
--   * Idempotent (skips existing batch_reference rows)
--   * Read-only from fin_ledger; inserts only into fin_transaction_batch
--   * Schema-aware: detects voucher/date/type/amount/is_deleted columns
-- =============================================================================

USE campus_dynamics_portal;

SELECT 'Phase3_1: checking prerequisites...' AS step;

SELECT
    (SELECT COUNT(*) FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_transaction_batch') AS batch_table_exists,
    (SELECT COUNT(*) FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_ledger') AS ledger_table_exists;

SET @voucher_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME IN ('voucherno','voucher_no','voucher_number','ref_no')
    ORDER BY FIELD(COLUMN_NAME, 'voucherno','voucher_no','voucher_number','ref_no')
    LIMIT 1
);

SET @date_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME IN ('entry_date','trans_date','date','posting_date')
    ORDER BY FIELD(COLUMN_NAME, 'entry_date','trans_date','date','posting_date')
    LIMIT 1
);

SET @type_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME IN ('dr_cr','entry_type','drcr','type')
    ORDER BY FIELD(COLUMN_NAME, 'dr_cr','entry_type','drcr','type')
    LIMIT 1
);

SET @amount_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME IN ('amount','entry_amount','value')
    ORDER BY FIELD(COLUMN_NAME, 'amount','entry_amount','value')
    LIMIT 1
);

SET @is_deleted_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'is_deleted'
    LIMIT 1
);

SELECT
    CONCAT('voucher_col=', COALESCE(@voucher_col, 'NOT FOUND')) AS voucher_col,
    CONCAT('date_col=', COALESCE(@date_col, 'NOT FOUND'))       AS date_col,
    CONCAT('type_col=', COALESCE(@type_col, 'NOT FOUND'))       AS type_col,
    CONCAT('amount_col=', COALESCE(@amount_col, 'NOT FOUND'))   AS amount_col,
    CONCAT('is_deleted_col=', COALESCE(@is_deleted_col, 'NOT FOUND')) AS is_deleted_col;

DROP TEMPORARY TABLE IF EXISTS _mig_batch_stage;

SET @sql_stage = CONCAT(
    'CREATE TEMPORARY TABLE _mig_batch_stage AS ',
    'SELECT ',
    '  l.', @voucher_col, ' AS voucher_no, ',
    '  CASE ',
    '    WHEN UPPER(l.', @voucher_col, ') REGEXP ''^(RCP|REC|STUD)'' THEN ''StudentReceipt'' ',
    '    WHEN UPPER(l.', @voucher_col, ') REGEXP ''^(PAY|PMT|PV)'' THEN ''PaymentVoucher'' ',
    '    WHEN UPPER(l.', @voucher_col, ') REGEXP ''^(JNL|JV|JE)'' THEN ''JournalEntry'' ',
    '    WHEN UPPER(l.', @voucher_col, ') REGEXP ''^(TRF|BNK|BT)'' THEN ''BankTransfer'' ',
    '    ELSE ''JournalEntry'' END AS batch_type, ',
    '  MIN(', IFNULL(CONCAT('l.`', @date_col, '`'), 'NOW()'), ') AS created_at, ',
    '  SUM(CASE WHEN UPPER(', IFNULL(CONCAT('COALESCE(l.`', @type_col, '`, '''')'), '''DR'''), ') IN (''DR'',''DEBIT'',''D'') ',
    '           THEN COALESCE(', IFNULL(CONCAT('l.`', @amount_col, '`'), '0'), ', 0) ELSE 0 END) AS total_debit, ',
    '  SUM(CASE WHEN UPPER(', IFNULL(CONCAT('COALESCE(l.`', @type_col, '`, '''')'), '''CR'''), ') IN (''CR'',''CREDIT'',''C'') ',
    '           THEN COALESCE(', IFNULL(CONCAT('l.`', @amount_col, '`'), '0'), ', 0) ELSE 0 END) AS total_credit, ',
    '  COUNT(*) AS transaction_count ',
    'FROM fin_ledger l ',
    'WHERE l.', @voucher_col, ' IS NOT NULL AND l.', @voucher_col, ' <> '''' ',
    IF(@is_deleted_col IS NOT NULL, CONCAT(' AND COALESCE(l.`', @is_deleted_col, '`, 0) = 0 '), ''),
    'GROUP BY l.', @voucher_col
);

PREPARE stmt_stage FROM @sql_stage;
EXECUTE stmt_stage;
DEALLOCATE PREPARE stmt_stage;

SELECT CONCAT('Vouchers staged: ', COUNT(*)) AS staged_count FROM _mig_batch_stage;

INSERT INTO fin_transaction_batch
    (batch_type, created_by, created_at, started_at, completed_at,
     status, transaction_count, total_debit, total_credit, batch_reference, source_system)
SELECT
    s.batch_type,
    'migration_script',
    COALESCE(s.created_at, NOW()),
    COALESCE(s.created_at, NOW()),
    COALESCE(s.created_at, NOW()),
    'Completed',
    s.transaction_count,
    s.total_debit,
    s.total_credit,
    s.voucher_no,
    'Phase3_Migration'
FROM _mig_batch_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM fin_transaction_batch b
    WHERE b.batch_reference = s.voucher_no
);

SELECT CONCAT('Batches inserted: ', ROW_COUNT()) AS batches_inserted;

DROP TEMPORARY TABLE IF EXISTS _mig_batch_stage;

SELECT
    batch_type,
    COUNT(*) AS batch_count,
    SUM(total_debit) AS total_dr,
    SUM(total_credit) AS total_cr
FROM fin_transaction_batch
WHERE source_system = 'Phase3_Migration'
GROUP BY batch_type
ORDER BY batch_type;

SELECT 'Phase3_1 complete. Run Phase3_2 next.' AS status;
