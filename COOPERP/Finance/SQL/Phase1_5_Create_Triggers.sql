-- =============================================================================
-- CAMPUS DYNAMICS – Finance System Realignment
-- Phase 1.5: Create DB-Level Safety Triggers & Validation Functions
-- =============================================================================
-- Run AFTER phases 1.1 through 1.4.
-- These triggers and functions add database-level guards that operate
-- independently of the application layer — protecting data even from direct
-- SQL console access.
-- Author: Finance Realignment Project
-- Date:   2026-04-27
-- =============================================================================

USE campus_dynamics_portal;

-- ─────────────────────────────────────────────────────────────────────────────
-- Trigger 1: Prevent hard DELETE on fin_ledger — enforce soft-delete instead
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_fin_ledger_prevent_hard_delete;

DELIMITER $$

CREATE TRIGGER trg_fin_ledger_prevent_hard_delete
BEFORE DELETE ON fin_ledger
FOR EACH ROW
BEGIN
    -- If the record is still active (not already soft-deleted), block the delete
    -- and mark it as soft-deleted instead.
    IF OLD.is_deleted = FALSE OR OLD.is_deleted IS NULL THEN
        UPDATE fin_ledger
        SET
            is_deleted      = TRUE,
            deleted_at      = NOW(),
            deleted_by      = COALESCE(@app_current_user, 'system'),
            deletion_reason = 'HARD DELETE INTERCEPTED — converted to soft delete by trigger.'
        WHERE id = OLD.id;

        -- Signal the caller so they know the row was soft-deleted instead of removed
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hard DELETE is not allowed on fin_ledger. Record has been soft-deleted instead. Use WHERE is_deleted = FALSE in all SELECT queries.';
    END IF;
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- Trigger 2: Auto-stamp adjustment_type on fin_ledger UPDATE
-- When a row's original_voucherno is set, mark it as a Reversal or Correction.
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_fin_ledger_adjustment_type_stamp;

DELIMITER $$

CREATE TRIGGER trg_fin_ledger_adjustment_type_stamp
BEFORE UPDATE ON fin_ledger
FOR EACH ROW
BEGIN
    -- If adjustment_type is still 'Original' but an original_voucherno has been set,
    -- auto-upgrade to 'Reversal' so reports correctly classify the entry.
    IF NEW.original_voucherno IS NOT NULL
       AND NEW.original_voucherno <> ''
       AND (NEW.adjustment_type = 'Original' OR NEW.adjustment_type IS NULL)
    THEN
        SET NEW.adjustment_type = 'Reversal';
    END IF;
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- Function: fn_validate_double_entry
-- Validates that debits == credits for a given batch_id.
-- Returns 1 (TRUE) if balanced, 0 (FALSE) if not.
-- Tolerance: abs(debit - credit) < 0.01 (handles floating-point rounding).
-- Usage: SELECT fn_validate_double_entry(123);
-- ─────────────────────────────────────────────────────────────────────────────
DROP FUNCTION IF EXISTS fn_validate_double_entry;

DELIMITER $$

CREATE FUNCTION fn_validate_double_entry(p_batch_id INT)
RETURNS TINYINT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_debit  DECIMAL(15,2) DEFAULT 0;
    DECLARE v_credit DECIMAL(15,2) DEFAULT 0;

    SELECT
        COALESCE(SUM(debit_amount),  0),
        COALESCE(SUM(credit_amount), 0)
    INTO v_debit, v_credit
    FROM fin_ledger
    WHERE batch_id   = p_batch_id
      AND (is_deleted = FALSE OR is_deleted IS NULL);

    RETURN ABS(v_debit - v_credit) < 0.01;
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- Function: fn_get_next_voucher_number
-- Atomically increments and returns the next voucher number for a given type.
-- Uses UPDATE + LAST_INSERT_ID trick for race-condition safety.
-- Usage: SELECT fn_get_next_voucher_number('StudentReceipt');
-- ─────────────────────────────────────────────────────────────────────────────
DROP FUNCTION IF EXISTS fn_get_next_voucher_number;

DELIMITER $$

CREATE FUNCTION fn_get_next_voucher_number(p_voucher_type VARCHAR(50))
RETURNS INT
MODIFIES SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE v_next INT DEFAULT 0;

    -- Atomic increment: guaranteed safe even under concurrent load
    UPDATE fin_voucher_sequence
    SET current_number = LAST_INSERT_ID(current_number + 1),
        updated_at     = NOW()
    WHERE voucher_type = p_voucher_type;

    SET v_next = LAST_INSERT_ID();

    -- Insert row if voucher type was missing (graceful fallback)
    IF v_next = 0 THEN
        INSERT INTO fin_voucher_sequence (voucher_type, current_number)
        VALUES (p_voucher_type, 1)
        ON DUPLICATE KEY UPDATE current_number = current_number + 1;
        SET v_next = 1;
    END IF;

    RETURN v_next;
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- Verification
-- ─────────────────────────────────────────────────────────────────────────────
-- SHOW TRIGGERS LIKE 'fin_ledger';
-- SELECT fn_validate_double_entry(0);      -- Expects 1 (no rows = balanced)
-- SELECT fn_get_next_voucher_number('TestVoucher'); -- Expects 1 (first call)
-- SELECT fn_get_next_voucher_number('TestVoucher'); -- Expects 2 (second call)

-- Cleanup test sequence
-- DELETE FROM fin_voucher_sequence WHERE voucher_type = 'TestVoucher';

-- =============================================================================
-- END Phase 1.5
-- =============================================================================
