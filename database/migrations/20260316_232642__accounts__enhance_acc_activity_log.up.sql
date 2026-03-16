-- Migration: enhance_acc_activity_log
-- Logical database: accounts
-- Generated: 2026-03-16T23:26:42
-- F1: Enhance acc_activity_log with richer audit columns
--
-- Current columns: logid, user_id, page_function, par, comments, access_date
-- Added columns:
--   ip_address        — client IP address of the request
--   session_id        — ASP.NET session identifier
--   affected_voucherNo — voucher number affected by the action
--   affected_amount   — financial amount involved
--   before_value      — serialized value before the change (for corrections)
--   after_value       — serialized value after the change (for corrections)
--
-- Indexes added:
--   idx_log_access_date  — for date-range queries
--   idx_log_user_id      — for per-user audit trail
--   idx_log_page_func    — for per-operation queries
--
-- All column additions are conditional (idempotent).
--
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

DELIMITER $$

DROP PROCEDURE IF EXISTS tmp_enhance_activity_log$$
CREATE PROCEDURE tmp_enhance_activity_log()
BEGIN
    -- Add ip_address column
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND COLUMN_NAME = 'ip_address'
    ) THEN
        ALTER TABLE acc_activity_log
            ADD COLUMN ip_address VARCHAR(45) DEFAULT NULL COMMENT 'Client IP address';
    END IF;

    -- Add session_id column
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND COLUMN_NAME = 'session_id'
    ) THEN
        ALTER TABLE acc_activity_log
            ADD COLUMN session_id VARCHAR(100) DEFAULT NULL COMMENT 'ASP.NET Session ID';
    END IF;

    -- Add affected_voucherNo column
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND COLUMN_NAME = 'affected_voucherNo'
    ) THEN
        ALTER TABLE acc_activity_log
            ADD COLUMN affected_voucherNo INT DEFAULT NULL COMMENT 'Voucher number affected by this action';
    END IF;

    -- Add affected_amount column
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND COLUMN_NAME = 'affected_amount'
    ) THEN
        ALTER TABLE acc_activity_log
            ADD COLUMN affected_amount DECIMAL(18,2) DEFAULT NULL COMMENT 'Financial amount involved';
    END IF;

    -- Add before_value column
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND COLUMN_NAME = 'before_value'
    ) THEN
        ALTER TABLE acc_activity_log
            ADD COLUMN before_value TEXT DEFAULT NULL COMMENT 'Value before the change (for corrections/reversals)';
    END IF;

    -- Add after_value column
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND COLUMN_NAME = 'after_value'
    ) THEN
        ALTER TABLE acc_activity_log
            ADD COLUMN after_value TEXT DEFAULT NULL COMMENT 'Value after the change (for corrections/reversals)';
    END IF;
END$$
CALL tmp_enhance_activity_log()$$
DROP PROCEDURE IF EXISTS tmp_enhance_activity_log$$

DELIMITER ;

-- Add performance indexes (conditional using procedure approach)
DELIMITER $$
DROP PROCEDURE IF EXISTS tmp_add_activity_log_indexes$$
CREATE PROCEDURE tmp_add_activity_log_indexes()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND INDEX_NAME = 'idx_log_access_date'
    ) THEN
        ALTER TABLE acc_activity_log ADD INDEX idx_log_access_date (access_date);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND INDEX_NAME = 'idx_log_user_id'
    ) THEN
        ALTER TABLE acc_activity_log ADD INDEX idx_log_user_id (user_id);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acc_activity_log' AND INDEX_NAME = 'idx_log_page_func'
    ) THEN
        ALTER TABLE acc_activity_log ADD INDEX idx_log_page_func (page_function);
    END IF;
END$$
CALL tmp_add_activity_log_indexes()$$
DROP PROCEDURE IF EXISTS tmp_add_activity_log_indexes$$
DELIMITER ;
