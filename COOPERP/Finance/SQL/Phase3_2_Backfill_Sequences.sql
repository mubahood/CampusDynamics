-- =============================================================================
-- Phase3_2_Backfill_Sequences.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Populate fin_voucher_sequence.current_number using historical vouchers in
--   fin_ledger so new voucher generation continues from the correct max values.
--
-- SAFETY:
--   * Idempotent (INSERT ... ON DUPLICATE KEY UPDATE with GREATEST)
--   * Reads from fin_ledger only; updates fin_voucher_sequence only
--   * Leaves legacy data untouched
-- =============================================================================

USE campus_dynamics_portal;

SELECT 'Phase3_2: checking prerequisites...' AS step;

SELECT
    (SELECT COUNT(*) FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fin_voucher_sequence') AS sequence_table_exists,
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

SET @is_deleted_col = (
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'fin_ledger'
      AND COLUMN_NAME = 'is_deleted'
    LIMIT 1
);

SELECT CONCAT('Using voucher column: ', COALESCE(@voucher_col, 'NOT FOUND')) AS voucher_column;

DROP TEMPORARY TABLE IF EXISTS _mig_seq_stage;

SET @sql_stage = CONCAT(
    'CREATE TEMPORARY TABLE _mig_seq_stage AS ',
    'SELECT ',
    '  CASE ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(RCP|REC|STUD)'' THEN ''StudentReceipt'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(PAY|PMT|PV)''   THEN ''PaymentVoucher'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(JNL|JV|JE)''    THEN ''JournalEntry'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(TRF|BNK|BT)''   THEN ''BankTransfer'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(REV)''          THEN ''Reversal'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(COR)''          THEN ''Correction'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(DEP)''          THEN ''DepositVoucher'' ',
    '    ELSE ''JournalEntry'' ',
    '  END AS voucher_type, ',
    '  MAX(CAST(COALESCE(NULLIF(REGEXP_SUBSTR(voucher_no, ''[0-9]+$''), ''''), ''0'') AS UNSIGNED)) AS max_no, ',
    '  CASE ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(RCP|REC|STUD)'' THEN ''REC'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(PAY|PMT|PV)''   THEN ''PAY'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(JNL|JV|JE)''    THEN ''JNL'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(TRF|BNK|BT)''   THEN ''TRF'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(REV)''          THEN ''REV'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(COR)''          THEN ''COR'' ',
    '    WHEN UPPER(voucher_no) REGEXP ''^(DEP)''          THEN ''DEP'' ',
    '    ELSE ''JNL'' ',
    '  END AS prefix ',
    'FROM (',
    '  SELECT l.', @voucher_col, ' AS voucher_no ',
    '  FROM fin_ledger l ',
    '  WHERE l.', @voucher_col, ' IS NOT NULL AND l.', @voucher_col, ' <> '''' ',
    IF(@is_deleted_col IS NOT NULL, CONCAT(' AND COALESCE(l.`', @is_deleted_col, '`, 0) = 0 '), ''),
    ') x ',
    'GROUP BY voucher_type, prefix'
);

PREPARE stmt_stage FROM @sql_stage;
EXECUTE stmt_stage;
DEALLOCATE PREPARE stmt_stage;

SELECT * FROM _mig_seq_stage ORDER BY voucher_type;

INSERT INTO fin_voucher_sequence (voucher_type, current_number, prefix, fiscal_year)
SELECT
    s.voucher_type,
    COALESCE(s.max_no, 0) AS current_number,
    s.prefix,
    NULL
FROM _mig_seq_stage s
ON DUPLICATE KEY UPDATE
    current_number = GREATEST(fin_voucher_sequence.current_number, VALUES(current_number)),
    prefix = COALESCE(fin_voucher_sequence.prefix, VALUES(prefix));

SELECT CONCAT('Sequence rows inserted/updated: ', ROW_COUNT()) AS result;

DROP TEMPORARY TABLE IF EXISTS _mig_seq_stage;

SELECT voucher_type, prefix, current_number, updated_at
FROM fin_voucher_sequence
ORDER BY voucher_type;

SELECT 'Phase3_2 complete. Run Phase3_3 next.' AS status;
