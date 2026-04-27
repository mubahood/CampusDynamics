-- =============================================================================
-- Phase3_4_Populate_Reversals.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Backfill fin_transaction_reversal from historical ledger entries marked as
--   reversals/corrections (or carrying original_voucherno linkage).
--
-- SAFETY:
--   * Idempotent (NOT EXISTS duplicate guard)
--   * Schema-aware detection of source columns
--   * Inserts only into fin_transaction_reversal
-- =============================================================================

USE campus_dynamics_portal;

SELECT 'Phase3_4: checking prerequisites...' AS step;

SELECT
    (SELECT COUNT(*) FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_transaction_reversal') AS reversal_table_exists,
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

SET @amount_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME IN ('amount','entry_amount','value')
    ORDER BY FIELD(COLUMN_NAME, 'amount','entry_amount','value')
    LIMIT 1
);

SET @adj_type_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'adjustment_type'
    LIMIT 1
);

SET @orig_voucher_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'original_voucherno'
    LIMIT 1
);

SET @adj_reason_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'adjustment_reason'
    LIMIT 1
);

SET @adjusted_by_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'adjusted_by'
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
    CONCAT('date_col=', COALESCE(@date_col, 'NOT FOUND')) AS date_col,
    CONCAT('amount_col=', COALESCE(@amount_col, 'NOT FOUND')) AS amount_col,
    CONCAT('adjustment_type_col=', COALESCE(@adj_type_col, 'NOT FOUND')) AS adj_type_col,
    CONCAT('original_voucher_col=', COALESCE(@orig_voucher_col, 'NOT FOUND')) AS original_voucher_col;

DROP TEMPORARY TABLE IF EXISTS _mig_reversal_stage;

SET @sql_stage = CONCAT(
    'CREATE TEMPORARY TABLE _mig_reversal_stage AS ',
    'SELECT ',
    '  COALESCE(NULLIF(l.', IFNULL(@orig_voucher_col, @voucher_col), ', ''''), l.', @voucher_col, ') AS original_voucherno, ',
    '  DATE(COALESCE(', IFNULL(CONCAT('l.`', @date_col, '`'), 'NOW()'), ', NOW())) AS original_posted_date, ',
    '  ABS(SUM(COALESCE(', IFNULL(CONCAT('l.`', @amount_col, '`'), '0'), ',0))) AS original_amount, ',
    '  l.', @voucher_col, ' AS reversal_voucherno, ',
    '  DATE(COALESCE(', IFNULL(CONCAT('l.`', @date_col, '`'), 'NOW()'), ', NOW())) AS reversal_posted_date, ',
    '  CASE ',
    '    WHEN UPPER(COALESCE(', IFNULL(CONCAT('l.`', @adj_type_col, '`'), '''REVERSAL'''), ', '''')) = ''CORRECTION'' THEN ''Correction'' ',
    '    WHEN UPPER(COALESCE(', IFNULL(CONCAT('l.`', @adj_type_col, '`'), '''REVERSAL'''), ', '''')) = ''PERIODADJUSTMENT'' THEN ''PeriodAdjustment'' ',
    '    WHEN UPPER(COALESCE(', IFNULL(CONCAT('l.`', @adj_type_col, '`'), '''REVERSAL'''), ', '''')) = ''CANCELLEDTRANSACTION'' THEN ''Cancellation'' ',
    '    ELSE ''FullReversal'' END AS reversal_type, ',
    '  NULL AS percentage_amount, ',
    '  LEFT(COALESCE(', IFNULL(CONCAT('l.`', @adj_reason_col, '`'), '''Legacy Migration'''), ', ''Legacy Migration''), 100) AS reversal_reason, ',
    '  CONCAT(''Auto-backfilled in Phase3_4 from ledger voucher '', l.', @voucher_col, ') AS reversal_notes, ',
    '  COALESCE(', IFNULL(CONCAT('l.`', @adjusted_by_col, '`'), '''migration_script'''), ', ''migration_script'') AS requested_by, ',
    '  NOW() AS requested_at, ',
    '  ''migration_script'' AS approved_by, ',
    '  NOW() AS approved_at, ',
    '  ''APPROVED: Legacy reversal history backfill'' AS approval_comments, ',
    '  ''migration_script'' AS reversed_by, ',
    '  NOW() AS reversed_at ',
    'FROM fin_ledger l ',
    'WHERE l.', @voucher_col, ' IS NOT NULL AND l.', @voucher_col, ' <> '''' ',
    IF(@is_deleted_col IS NOT NULL, CONCAT(' AND COALESCE(l.`', @is_deleted_col, '`, 0) = 0 '), ''),
    ' AND (',
    IF(@orig_voucher_col IS NOT NULL, CONCAT(' (l.`', @orig_voucher_col, '` IS NOT NULL AND l.`', @orig_voucher_col, '` <> '''') '), ' 1=0 '),
    IF(@adj_type_col IS NOT NULL, CONCAT(' OR UPPER(COALESCE(l.`', @adj_type_col, '`, '''')) IN (''REVERSAL'',''CORRECTION'',''PERIODADJUSTMENT'',''CANCELLEDTRANSACTION'') '), ''),
    ') ',
    'GROUP BY original_voucherno, reversal_voucherno, reversal_type'
);

PREPARE stmt_stage FROM @sql_stage;
EXECUTE stmt_stage;
DEALLOCATE PREPARE stmt_stage;

SELECT CONCAT('Reversal history staged: ', COUNT(*)) AS staged_count
FROM _mig_reversal_stage;

INSERT INTO fin_transaction_reversal
    (original_voucherno, original_posted_date, original_amount,
     reversal_voucherno, reversal_posted_date, reversal_type,
     percentage_amount, reversal_reason, reversal_notes,
     requested_by, requested_at,
     approved_by, approved_at, approval_comments,
     reversed_by, reversed_at)
SELECT
    s.original_voucherno,
    s.original_posted_date,
    s.original_amount,
    s.reversal_voucherno,
    s.reversal_posted_date,
    s.reversal_type,
    s.percentage_amount,
    s.reversal_reason,
    s.reversal_notes,
    s.requested_by,
    s.requested_at,
    s.approved_by,
    s.approved_at,
    s.approval_comments,
    s.reversed_by,
    s.reversed_at
FROM _mig_reversal_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM fin_transaction_reversal r
    WHERE r.original_voucherno = s.original_voucherno
      AND r.reversal_voucherno = s.reversal_voucherno
      AND r.reversal_type = s.reversal_type
);

SELECT CONCAT('Reversal rows inserted: ', ROW_COUNT()) AS inserted_rows;

DROP TEMPORARY TABLE IF EXISTS _mig_reversal_stage;

SELECT reversal_type, COUNT(*) AS row_count
FROM fin_transaction_reversal
GROUP BY reversal_type
ORDER BY reversal_type;

SELECT 'Phase3_4 complete.' AS status;
