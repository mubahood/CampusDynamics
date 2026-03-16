-- Migration: add_ledger_validation_triggers
-- Logical database: accounts
-- Generated: 2026-03-16T21:48:25
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.

-- Task A5: Add validation triggers to fin_ledger
-- MySQL 5.6 does NOT enforce CHECK constraints (parsed but ignored).
-- Using BEFORE INSERT/UPDATE triggers instead for actual enforcement.
-- Rules: transaction_amount > 0, transactionType IN ('DR','CR'), accountcode != ''

DELIMITER ;;

CREATE TRIGGER trg_fin_ledger_before_insert
BEFORE INSERT ON fin_ledger
FOR EACH ROW
BEGIN
    IF NEW.transaction_amount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transaction_amount must be greater than 0';
    END IF;
    
    IF NEW.transactionType NOT IN ('DR', 'CR') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transactionType must be DR or CR';
    END IF;
    
    IF NEW.accountcode = '' OR NEW.accountcode IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'accountcode must not be empty';
    END IF;
END;;

CREATE TRIGGER trg_fin_ledger_before_update
BEFORE UPDATE ON fin_ledger
FOR EACH ROW
BEGIN
    IF NEW.transaction_amount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transaction_amount must be greater than 0';
    END IF;
    
    IF NEW.transactionType NOT IN ('DR', 'CR') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transactionType must be DR or CR';
    END IF;
    
    IF NEW.accountcode = '' OR NEW.accountcode IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'accountcode must not be empty';
    END IF;
END;;

DELIMITER ;
