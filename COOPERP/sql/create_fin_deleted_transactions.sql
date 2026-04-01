-- =============================================================================
-- Migration: Create fin_deleted_transactions table
-- Database:  campus_dynamics_accounts
--
-- Purpose:
--   A clean, dedicated archive table for every fee transaction that is
--   deleted from fin_studentfeestracking.  Unlike the general-purpose
--   fin_changed_deleted_transactions audit log (which also captures EDITs
--   and stores new/old pairs), this table stores one complete copy of the
--   original row in a queryable format, making it easy to:
--     - Review historically-deleted transactions per student
--     - Restore an accidentally-deleted transaction
--     - Run reports on what was deleted, when, and by whom
--
-- Run on: campus_dynamics_accounts database
-- Safe to run multiple times — uses CREATE TABLE IF NOT EXISTS.
-- =============================================================================

USE campus_dynamics_accounts;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1 — Create the table
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fin_deleted_transactions (
    id               INT            NOT NULL AUTO_INCREMENT PRIMARY KEY,
    original_tid     INT            NOT NULL        COMMENT 'TID from fin_studentfeestracking at time of delete',
    regno            VARCHAR(20)    NOT NULL        COMMENT 'Student registration number',
    trans_type       VARCHAR(20)    NOT NULL        COMMENT 'Payment | Bill | Waiver | etc.',
    item_code        INT            DEFAULT NULL    COMMENT 'FK to fee item (fin_feeitems or similar)',
    amount           DOUBLE         NOT NULL,
    detail           VARCHAR(500)   DEFAULT NULL    COMMENT 'Transaction description / narration',
    trans_date       DATE           DEFAULT NULL,
    acadyear         VARCHAR(20)    DEFAULT NULL    COMMENT 'e.g. 2025/2026',
    semester         INT            DEFAULT NULL    COMMENT '1 | 2',
    post_status      VARCHAR(20)    DEFAULT NULL    COMMENT 'Posted | Unposted',

    -- Who deleted it and why
    deleted_by       VARCHAR(100)   NOT NULL        COMMENT 'Username / screen name of deleting user',
    deleted_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delete_category  VARCHAR(100)   DEFAULT NULL    COMMENT 'Category: Data Entry Error | Duplicate Transaction | Reversal / Adjustment | Student Request | Transfer / Campus Change | System Error | Other',
    delete_reason    VARCHAR(500)   DEFAULT NULL    COMMENT 'Free-text explanation entered at delete time',
    ip_address       VARCHAR(50)    DEFAULT NULL,

    -- Indexes for common lookups
    INDEX idx_dt_regno        (regno),
    INDEX idx_dt_original_tid (original_tid),
    INDEX idx_dt_deleted_at   (deleted_at)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Archive of every manually-deleted student fee transaction';


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 2 — Back-fill from the existing audit log
--
-- fin_changed_deleted_transactions already contains all past DELETEs.
-- We copy their original-value columns into the new clean table so the
-- history is not lost.  The INSERT IGNORE prevents duplicates if this
-- script is re-run.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO fin_deleted_transactions
    (original_tid, regno, trans_type, item_code, amount, detail,
     trans_date, acadyear, semester, post_status,
     deleted_by, deleted_at, delete_category, delete_reason, ip_address)
SELECT
    fcd.original_tid,
    fcd.orig_regno,
    fcd.orig_trans_type,
    fcd.orig_item_code,
    fcd.orig_amount,
    fcd.orig_detail,
    fcd.orig_trans_date,
    fcd.orig_acadyear,
    fcd.orig_semester,
    fcd.orig_post_status,
    IFNULL(fcd.changed_by, 'System (migration)'),
    NOW(),                                   -- deleted_at: use NOW() as approximation for historical records
    NULL,                                    -- delete_category: not captured in old audit records
    NULL,                                    -- delete_reason: not captured in old audit records
    fcd.ip_address
FROM fin_changed_deleted_transactions fcd
WHERE fcd.action_type = 'DELETE'
  AND NOT EXISTS (
      -- Avoid re-inserting if the original_tid already landed in this table
      SELECT 1 FROM fin_deleted_transactions dt WHERE dt.original_tid = fcd.original_tid
  );

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 3 — Verify
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    COUNT(*) AS total_deleted_transactions_archived
FROM fin_deleted_transactions;

SELECT
    original_tid,
    regno,
    trans_type,
    amount,
    detail,
    trans_date,
    deleted_by,
    deleted_at
FROM fin_deleted_transactions
ORDER BY deleted_at DESC
LIMIT 50;
