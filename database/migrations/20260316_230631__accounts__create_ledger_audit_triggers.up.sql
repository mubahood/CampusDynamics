-- Migration: create_ledger_audit_triggers
-- Logical database: accounts
-- Generated: 2026-03-16T23:06:31
-- D8: AFTER UPDATE trigger on fin_ledger — logs old/new values to edit_ledger
-- D9: BEFORE DELETE trigger on fin_ledger — archives deleted rows to fin_deleted_ledger
--
-- D8: Every UPDATE to fin_ledger is captured. The trigger records the old and new
--     values of transaction_amount and transactionType (the two fields that are
--     ever modified), along with the DB user and timestamp.
--     Required columns are added to edit_ledger if they don't already exist.
--
-- D9: Every DELETE from fin_ledger is intercepted. The row is copied to
--     fin_deleted_ledger before removal, preserving full history.
--     delete_date and deleted_by columns are added to fin_deleted_ledger if absent.
--
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

DELIMITER $$

-- Step 1: Ensure edit_ledger has trigger-tracking columns
DROP PROCEDURE IF EXISTS tmp_ensure_edit_ledger_cols$$
CREATE PROCEDURE tmp_ensure_edit_ledger_cols()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'edit_ledger'
          AND COLUMN_NAME  = 'trigger_tid'
    ) THEN
        ALTER TABLE edit_ledger
            ADD COLUMN trigger_tid              INT UNSIGNED    DEFAULT NULL COMMENT 'fin_ledger.TID that was modified',
            ADD COLUMN old_transaction_amount   DOUBLE          DEFAULT NULL COMMENT 'Amount before the UPDATE',
            ADD COLUMN new_transaction_amount   DOUBLE          DEFAULT NULL COMMENT 'Amount after the UPDATE',
            ADD COLUMN old_transactionType      CHAR(2)         DEFAULT NULL COMMENT 'DR/CR before the UPDATE',
            ADD COLUMN new_transactionType      CHAR(2)         DEFAULT NULL COMMENT 'DR/CR after the UPDATE',
            ADD COLUMN triggered_by             VARCHAR(100)    DEFAULT NULL COMMENT 'DB user() at time of change',
            ADD COLUMN trigger_date             DATETIME        DEFAULT NULL COMMENT 'Timestamp of the change';
    END IF;
END$$
CALL tmp_ensure_edit_ledger_cols()$$
DROP PROCEDURE IF EXISTS tmp_ensure_edit_ledger_cols$$

-- Step 2: Ensure fin_deleted_ledger has deletion-tracking columns
DROP PROCEDURE IF EXISTS tmp_ensure_deleted_ledger_cols$$
CREATE PROCEDURE tmp_ensure_deleted_ledger_cols()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'fin_deleted_ledger'
          AND COLUMN_NAME  = 'delete_date'
    ) THEN
        ALTER TABLE fin_deleted_ledger
            ADD COLUMN delete_date  DATETIME     DEFAULT NULL COMMENT 'When this entry was deleted',
            ADD COLUMN deleted_by   VARCHAR(100) DEFAULT NULL COMMENT 'DB user() that deleted the entry';
    END IF;
END$$
CALL tmp_ensure_deleted_ledger_cols()$$
DROP PROCEDURE IF EXISTS tmp_ensure_deleted_ledger_cols$$

-- Step 3: D8 — AFTER UPDATE trigger
-- Only fires when amount or type changes (not on balance-recalculation updates to curr_balance)
DROP TRIGGER IF EXISTS trg_fin_ledger_after_update$$
CREATE TRIGGER trg_fin_ledger_after_update
AFTER UPDATE ON fin_ledger
FOR EACH ROW
BEGIN
    IF OLD.transaction_amount <> NEW.transaction_amount
       OR OLD.transactionType <> NEW.transactionType THEN
        INSERT INTO edit_ledger
            (trigger_tid, old_transaction_amount, new_transaction_amount,
             old_transactionType, new_transactionType, triggered_by, trigger_date)
        VALUES
            (OLD.TID, OLD.transaction_amount, NEW.transaction_amount,
             OLD.transactionType, NEW.transactionType, USER(), NOW());
    END IF;
END$$

-- Step 4: D9 — BEFORE DELETE trigger
-- Archives every deleted fin_ledger row before removal
DROP TRIGGER IF EXISTS trg_fin_ledger_before_delete$$
CREATE TRIGGER trg_fin_ledger_before_delete
BEFORE DELETE ON fin_ledger
FOR EACH ROW
BEGIN
    INSERT INTO fin_deleted_ledger
        (accountcode, account_type, transactionType, transaction_amount,
         particulars, voucherNo, journal_no, transactionDate, teller,
         trans_currency, actual_amount, forex_rate, delete_date, deleted_by)
    VALUES
        (OLD.accountcode, OLD.account_type, OLD.transactionType, OLD.transaction_amount,
         OLD.particulars, OLD.voucherNo, OLD.journal_no, OLD.transactionDate, OLD.teller,
         OLD.trans_currency, OLD.actual_amount, OLD.forex_rate, NOW(), USER());
END$$

DELIMITER ;
