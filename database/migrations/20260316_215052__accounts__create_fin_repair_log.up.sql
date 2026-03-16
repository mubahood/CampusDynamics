-- Migration: create_fin_repair_log
-- Logical database: accounts
-- Generated: 2026-03-16T21:50:52
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.

-- Task A7: Create fin_repair_log table
-- Tracks every data repair action with before/after values
-- Used by Group E (Data Repair) to document all corrections

CREATE TABLE IF NOT EXISTS fin_repair_log (
    repair_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    repair_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    repair_type VARCHAR(50) NOT NULL COMMENT 'UNBALANCED_VOUCHER, EMPTY_JOURNAL, ONE_SIDED_ENTRY, etc.',
    voucherNo INT UNSIGNED DEFAULT NULL,
    journal_no INT UNSIGNED DEFAULT NULL,
    original_dr DECIMAL(18,2) DEFAULT NULL,
    original_cr DECIMAL(18,2) DEFAULT NULL,
    difference DECIMAL(18,2) DEFAULT NULL,
    action_taken VARCHAR(250) NOT NULL DEFAULT 'PENDING_REVIEW',
    repaired_by VARCHAR(45) DEFAULT NULL,
    repair_notes TEXT DEFAULT NULL,
    INDEX idx_repair_type (repair_type),
    INDEX idx_voucherNo (voucherNo),
    INDEX idx_repair_date (repair_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
