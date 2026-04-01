-- =============================================================================
-- Migration: Add delete_category column to fin_deleted_transactions
-- Database:  campus_dynamics_accounts
--
-- Run this if the table was already created WITHOUT the delete_category column.
-- If you are running create_fin_deleted_transactions.sql for the first time,
-- you DO NOT need this script — the CREATE TABLE already includes both columns.
--
-- Safe to run multiple times (checks column existence first).
-- =============================================================================

USE campus_dynamics_accounts;

-- Add delete_category between deleted_at and delete_reason (if not already present)
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'campus_dynamics_accounts'
      AND TABLE_NAME   = 'fin_deleted_transactions'
      AND COLUMN_NAME  = 'delete_category'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE fin_deleted_transactions
        ADD COLUMN delete_category VARCHAR(100) DEFAULT NULL
            COMMENT ''Category: Data Entry Error | Duplicate Transaction | Reversal / Adjustment | Student Request | Transfer / Campus Change | System Error | Other''
            AFTER deleted_at',
    'SELECT ''delete_category column already exists — skipping.'' AS status'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'fin_deleted_transactions schema check complete.' AS status;
