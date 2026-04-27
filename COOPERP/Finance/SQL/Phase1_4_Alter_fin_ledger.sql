-- =============================================================================
-- CAMPUS DYNAMICS – Finance System Realignment
-- Phase 1.4: ALTER fin_ledger — Add Nullable Batch & Audit Columns
-- =============================================================================
-- ⚠ IMPORTANT: Test this script on a development copy before running on production.
-- All new columns are NULLABLE with defaults — existing rows are unaffected.
-- The ALTER is broken into multiple ADD COLUMN statements for readability and
-- easy rollback (comment out individual columns if not needed immediately).
-- Run order: Phase1_1 → 1_2 → 1_3 → 1_4 → 1_5
-- Author: Finance Realignment Project
-- Date:   2026-04-27
-- =============================================================================

USE campus_dynamics_portal;

-- ---------------------------------------------------------------------------
-- Check that fin_ledger exists before proceeding
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS ledger_exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'fin_ledger';
-- Expect: 1. If 0, do not proceed.

-- ---------------------------------------------------------------------------
-- Group 1: Transactional Batch Linkage
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS batch_id INT NULL COMMENT 'FK to fin_transaction_batch.batch_id',
    ADD COLUMN IF NOT EXISTS posting_period VARCHAR(10) NULL COMMENT 'Freeze-period label e.g. 2025-01',
    ADD COLUMN IF NOT EXISTS fiscal_period_id INT NULL COMMENT 'FK to fin_accounting_periods.period_id';

-- ---------------------------------------------------------------------------
-- Group 2: Reversal & Adjustment Tracing
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS original_voucherno VARCHAR(50) NULL
        COMMENT 'Source voucher if this is a reversal/correction',
    ADD COLUMN IF NOT EXISTS adjustment_type ENUM(
        'Original',
        'Reversal',
        'Correction',
        'CancelledTransaction',
        'PeriodAdjustment'
    ) DEFAULT 'Original'
        COMMENT 'Nature of this ledger entry',
    ADD COLUMN IF NOT EXISTS adjusted_by VARCHAR(50) NULL
        COMMENT 'Username who created the reversal/correction',
    ADD COLUMN IF NOT EXISTS adjustment_reason TEXT NULL,
    ADD COLUMN IF NOT EXISTS adjusted_at DATETIME NULL;

-- ---------------------------------------------------------------------------
-- Group 3: Transaction Date vs Posting Date
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS transaction_date_original DATE NULL
        COMMENT 'Business date of the underlying event (may differ from posting date)';

-- ---------------------------------------------------------------------------
-- Group 4: Multi-Currency Tracking
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS original_amount DECIMAL(15,2) NULL
        COMMENT 'Amount in foreign currency before conversion',
    ADD COLUMN IF NOT EXISTS original_currency CHAR(3) NULL
        COMMENT 'ISO 4217 currency code e.g. USD',
    ADD COLUMN IF NOT EXISTS exchange_rate_used DECIMAL(10,6) NULL
        COMMENT 'Rate applied at time of posting',
    ADD COLUMN IF NOT EXISTS functional_currency_amount DECIMAL(15,2) NULL
        COMMENT 'Equivalent in UGX (functional currency)';

-- ---------------------------------------------------------------------------
-- Group 5: Document Attachment Tracking
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS has_supporting_docs BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS document_count INT DEFAULT 0;

-- ---------------------------------------------------------------------------
-- Group 6: Internal Approval Control
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS requires_approval BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS approved_by VARCHAR(50) NULL,
    ADD COLUMN IF NOT EXISTS approval_date DATETIME NULL;

-- ---------------------------------------------------------------------------
-- Group 7: Bank Reconciliation
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS bank_reconciled BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS reconciled_by VARCHAR(50) NULL,
    ADD COLUMN IF NOT EXISTS reconciled_at DATETIME NULL;

-- ---------------------------------------------------------------------------
-- Group 8: Soft Delete (replaces hard DELETE)
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS deleted_at DATETIME NULL,
    ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(50) NULL,
    ADD COLUMN IF NOT EXISTS deletion_reason TEXT NULL;

-- ---------------------------------------------------------------------------
-- Indexes for new columns
-- ---------------------------------------------------------------------------
ALTER TABLE fin_ledger
    ADD INDEX IF NOT EXISTS idx_fl_batch_id          (batch_id),
    ADD INDEX IF NOT EXISTS idx_fl_adjustment_type   (adjustment_type),
    ADD INDEX IF NOT EXISTS idx_fl_fiscal_period_id  (fiscal_period_id),
    ADD INDEX IF NOT EXISTS idx_fl_original_voucherno (original_voucherno),
    ADD INDEX IF NOT EXISTS idx_fl_is_deleted        (is_deleted);

-- ---------------------------------------------------------------------------
-- Foreign Key: fin_ledger.batch_id → fin_transaction_batch.batch_id
-- (Run only AFTER Phase1_1 script has been applied successfully)
-- ---------------------------------------------------------------------------
-- ALTER TABLE fin_ledger
--     ADD CONSTRAINT fk_fl_batch
--     FOREIGN KEY (batch_id) REFERENCES fin_transaction_batch(batch_id) ON DELETE SET NULL;

-- ---------------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------------
-- DESCRIBE fin_ledger;
-- SELECT batch_id, adjustment_type, is_deleted, original_voucherno
-- FROM fin_ledger LIMIT 5;
-- Expect: all new columns present with NULL / default values for existing rows.

-- =============================================================================
-- END Phase 1.4
-- =============================================================================
