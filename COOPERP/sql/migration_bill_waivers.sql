-- ============================================================================
-- MIGRATION: Bill Waivers Module
-- Database: campus_dynamics_accounts
-- Date:     2026-04-03
-- Author:   System
--
-- Creates the fin_bill_waivers table which tracks every bill waiver applied.
-- Each waiver links:
--   - The original bill(s) being waived (via waiver_items)
--   - The credit transaction created on the student account (credit_tid)
--   - The GL entry created (credit_gl_tid)
--
-- A waiver is always a CREDIT (reduces student balance). The credit TID
-- is stored so the waiver and its financial effect are permanently linked.
-- ============================================================================

-- ── 1. Main Waivers Table ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS fin_bill_waivers (
    waiver_id       INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    regno           VARCHAR(25)     NOT NULL        COMMENT 'Student registration number',
    waiver_category VARCHAR(50)     NOT NULL        COMMENT 'Bursary Waiver | Double Billing | Wrong Billing | Other',
    waiver_reason   VARCHAR(500)    NOT NULL        COMMENT 'Free-text explanation by the user',
    total_amount    DOUBLE          NOT NULL        COMMENT 'Total amount waived (sum of selected bills)',
    credit_tid      INT UNSIGNED    DEFAULT NULL    COMMENT 'TID in fin_studentfeestracking for the credit entry created',
    credit_gl_tid   INT UNSIGNED    DEFAULT NULL    COMMENT 'TID in fin_ledger for the GL credit entry created',
    acadyear        CHAR(25)        NOT NULL        COMMENT 'Academic year context (e.g. 2025/2026)',
    semester        INT UNSIGNED    NOT NULL        COMMENT 'Semester context',
    status          VARCHAR(20)     NOT NULL DEFAULT 'Active' COMMENT 'Active | Reversed',
    created_by      VARCHAR(45)     NOT NULL        COMMENT 'Username who created the waiver',
    created_at      DATETIME        NOT NULL        COMMENT 'When the waiver was created',
    reversed_by     VARCHAR(45)     DEFAULT NULL    COMMENT 'Username who reversed (if reversed)',
    reversed_at     DATETIME        DEFAULT NULL    COMMENT 'When it was reversed',
    INDEX idx_bw_regno (regno),
    INDEX idx_bw_category (waiver_category),
    INDEX idx_bw_status (status),
    INDEX idx_bw_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Bill waivers — tracks fee reduction credits applied to student accounts';


-- ── 2. Waiver Line Items ───────────────────────────────────────────────────
-- Each waiver can include one or more original bill TIDs.

CREATE TABLE IF NOT EXISTS fin_bill_waiver_items (
    item_id         INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    waiver_id       INT UNSIGNED    NOT NULL        COMMENT 'FK → fin_bill_waivers.waiver_id',
    original_tid    INT UNSIGNED    NOT NULL        COMMENT 'TID of the original bill in fin_studentfeestracking',
    bill_amount     DOUBLE          NOT NULL        COMMENT 'Original bill amount',
    waived_amount   DOUBLE          NOT NULL        COMMENT 'Amount being waived for this bill',
    bill_detail     VARCHAR(250)    DEFAULT NULL    COMMENT 'Description copied from original bill',
    INDEX idx_bwi_waiver (waiver_id),
    INDEX idx_bwi_tid (original_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Individual bill line items included in a waiver';


-- ── 3. Verification ────────────────────────────────────────────────────────
-- Quick check after running:
SELECT 'fin_bill_waivers' AS tbl, COUNT(*) AS rows FROM fin_bill_waivers
UNION ALL
SELECT 'fin_bill_waiver_items', COUNT(*) FROM fin_bill_waiver_items;
