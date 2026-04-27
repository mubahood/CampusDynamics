-- =============================================================================
-- CAMPUS DYNAMICS – Finance System Realignment
-- Phase 1.1: Create Transaction Batch & Audit Infrastructure Tables
-- =============================================================================
-- Run this script ONCE on the campus_dynamics_portal database.
-- All tables are additive (new tables only). No existing tables are modified.
-- Safe to run in production during off-peak hours.
-- Author: Finance Realignment Project
-- Date:   2026-04-27
-- =============================================================================

USE campus_dynamics_portal;

-- ---------------------------------------------------------------------------
-- Table: fin_transaction_batch
-- Wraps every multi-step financial operation in an atomic unit.
-- Every Student Receipt, Payment Voucher, Journal Entry, and Bank Transfer
-- will create one batch record so failures can be isolated and investigated.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_transaction_batch (
    batch_id          INT AUTO_INCREMENT PRIMARY KEY,
    batch_type        ENUM(
                          'StudentReceipt',
                          'PaymentVoucher',
                          'JournalEntry',
                          'BankTransfer',
                          'NightAuditRun',
                          'BankImport',
                          'Migration'
                      ) NOT NULL,
    created_by        VARCHAR(50) NOT NULL,
    created_at        DATETIME  DEFAULT CURRENT_TIMESTAMP,
    started_at        DATETIME  NULL,
    completed_at      DATETIME  NULL,
    status            ENUM('Draft','InProgress','Completed','Failed','RolledBack')
                      DEFAULT 'Draft',
    error_message     TEXT      NULL,
    transaction_count INT       DEFAULT 0,
    total_debit       DECIMAL(15,2) DEFAULT 0.00,
    total_credit      DECIMAL(15,2) DEFAULT 0.00,
    batch_reference   VARCHAR(100) NULL,   -- e.g. voucher number, night-audit date
    source_system     VARCHAR(50)  NULL,   -- 'StudentReceipt', 'NightAudit', etc.

    INDEX idx_ftb_created_at  (created_at),
    INDEX idx_ftb_status      (status),
    INDEX idx_ftb_batch_type  (batch_type),
    INDEX idx_ftb_created_by  (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Atomic wrapper for every multi-step financial operation.';


-- ---------------------------------------------------------------------------
-- Table: fin_transaction_log
-- Complete audit trail for every insert/update/delete on ledger records.
-- Stores JSON snapshots of before/after state for forensic investigation.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_transaction_log (
    log_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    action        ENUM('Insert','Update','Delete','Reverse','Correct','Validate') NOT NULL,
    table_name    VARCHAR(50)  NOT NULL,
    record_id     INT          NULL,       -- PK of the affected row in table_name
    batch_id      INT          NULL,
    old_value     JSON         NULL,       -- Previous state before change
    new_value     JSON         NULL,       -- New state after change
    changed_by    VARCHAR(50)  NOT NULL,
    changed_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    ip_address    VARCHAR(45)  NULL,
    reason_code   VARCHAR(20)  NULL,       -- 'USER_CORRECTION', 'AUTO_REVERSAL', 'PERIOD_CLOSE'
    reason_text   TEXT         NULL,
    approver_id   VARCHAR(50)  NULL,
    approval_date DATETIME     NULL,

    FOREIGN KEY fk_ftl_batch (batch_id)
        REFERENCES fin_transaction_batch(batch_id) ON DELETE SET NULL,

    INDEX idx_ftl_changed_at  (changed_at),
    INDEX idx_ftl_changed_by  (changed_by),
    INDEX idx_ftl_batch_id    (batch_id),
    INDEX idx_ftl_table_record (table_name, record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Complete forensic audit trail for all ledger modifications.';


-- ---------------------------------------------------------------------------
-- Table: fin_voucher_sequence
-- Atomic, race-condition-free voucher number generation.
-- Uses MySQL AUTO_INCREMENT on a helper column to guarantee uniqueness.
-- Application code should INSERT to get LAST_INSERT_ID() as the next number.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_voucher_sequence (
    sequence_id    INT AUTO_INCREMENT PRIMARY KEY,
    voucher_type   VARCHAR(50) NOT NULL UNIQUE,  -- 'StudentReceipt', 'PaymentVoucher', etc.
    current_number INT         DEFAULT 0,
    prefix         VARCHAR(10) NULL,             -- e.g. 'REC', 'PAY', 'DEP', 'JNL'
    fiscal_year    VARCHAR(10) NULL,
    created_at     DATETIME    DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_fvs_voucher_type (voucher_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Atomic, collision-free voucher number generation per type.';


-- ---------------------------------------------------------------------------
-- Seed: populate known voucher types so the sequence is ready immediately
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO fin_voucher_sequence (voucher_type, prefix, fiscal_year)
VALUES
    ('StudentReceipt',  'REC',  NULL),
    ('DepositVoucher',  'DEP',  NULL),
    ('PaymentVoucher',  'PAY',  NULL),
    ('JournalEntry',    'JNL',  NULL),
    ('BankTransfer',    'TRF',  NULL),
    ('NightAudit',      'NAD',  NULL),
    ('Reversal',        'REV',  NULL),
    ('Correction',      'COR',  NULL);


-- ---------------------------------------------------------------------------
-- Verification queries (run after script to confirm success)
-- ---------------------------------------------------------------------------
-- SELECT 'fin_transaction_batch'    AS tbl, COUNT(*) AS rows FROM fin_transaction_batch;
-- SELECT 'fin_transaction_log'      AS tbl, COUNT(*) AS rows FROM fin_transaction_log;
-- SELECT 'fin_voucher_sequence'     AS tbl, COUNT(*) AS rows FROM fin_voucher_sequence;

-- =============================================================================
-- END Phase 1.1
-- =============================================================================
