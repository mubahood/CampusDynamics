-- =============================================================================
-- CAMPUS DYNAMICS – Finance System Realignment
-- Phase 1.3: Create Reversal, Bank Reconciliation, and Posting Rules Tables
-- =============================================================================
-- All tables are new (additive). No existing data is modified.
-- fin_reco_bank_statement_import has an FK to fin_bank_accounts — if that table
-- does not exist in your schema, comment out the FOREIGN KEY line at the bottom
-- of that table's definition.
-- Author: Finance Realignment Project
-- Date:   2026-04-27
-- =============================================================================

USE campus_dynamics_portal;

-- ---------------------------------------------------------------------------
-- Table: fin_transaction_reversal
-- Complete, approved history of every transaction reversal or correction.
-- Links the original voucher to the reversal voucher for audit traceability.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_transaction_reversal (
    reversal_id             INT AUTO_INCREMENT PRIMARY KEY,
    original_voucherno      VARCHAR(50)  NOT NULL,
    original_posted_date    DATE         NOT NULL,
    original_amount         DECIMAL(15,2) NOT NULL,

    reversal_voucherno      VARCHAR(50)  NOT NULL,
    reversal_posted_date    DATE         NOT NULL,

    reversal_type           ENUM(
                                'FullReversal',
                                'PartialReversal',
                                'Correction',
                                'Cancellation',
                                'ExchangeAdjustment',
                                'PeriodAdjustment'
                            ) NOT NULL,

    percentage_amount       DECIMAL(5,2)  NULL,      -- For partial reversals (0-100 %)
    reversal_reason         VARCHAR(100)  NOT NULL,   -- e.g. 'StudentWithdrawal', 'WrongAmount'
    reversal_notes          TEXT          NULL,

    -- Request chain
    requested_by            VARCHAR(50)   NOT NULL,
    requested_at            DATETIME      DEFAULT CURRENT_TIMESTAMP,

    -- Approval chain
    approved_by             VARCHAR(50)   NULL,
    approved_at             DATETIME      NULL,
    approval_comments       TEXT          NULL,       -- 'REJECTED: ...' prefix signals rejection

    -- Execution
    reversed_by             VARCHAR(50)   NOT NULL    DEFAULT 'pending',
    reversed_at             DATETIME      NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    -- Reconciliation
    reconciliation_status   ENUM('Pending','Verified','Disputed') DEFAULT 'Pending',
    verified_by             VARCHAR(50)   NULL,
    verified_at             DATETIME      NULL,

    INDEX idx_ftr_original_voucherno  (original_voucherno),
    INDEX idx_ftr_reversal_voucherno  (reversal_voucherno),
    INDEX idx_ftr_reversed_at         (reversed_at),
    INDEX idx_ftr_approved_at         (approved_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Approved history of all transaction reversals and corrections.';


-- ---------------------------------------------------------------------------
-- Table: fin_reco_bank_statement_import
-- Audit trail for every bank statement file imported into the system.
-- File hash (SHA-256) prevents duplicate imports of the same statement.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_reco_bank_statement_import (
    import_id                   INT AUTO_INCREMENT PRIMARY KEY,
    bank_account_id             INT          NOT NULL,

    -- File metadata
    import_date                 DATETIME     DEFAULT CURRENT_TIMESTAMP,
    imported_by                 VARCHAR(50)  NOT NULL,
    original_filename           VARCHAR(255) NULL,
    file_hash                   VARCHAR(64)  NULL,     -- SHA-256 hex of uploaded file
    import_format               ENUM('MT940','CSV','OFX','Excel') NULL,

    -- Statement period
    statement_date              DATE         NOT NULL,
    statement_start_balance     DECIMAL(15,2) NULL,
    statement_end_balance       DECIMAL(15,2) NULL,

    -- Validation summary
    line_count                  INT          NULL,
    validation_errors           INT          DEFAULT 0,
    validation_status           ENUM('Pending','Passed','Warnings','Failed') DEFAULT 'Pending',
    validation_notes            TEXT         NULL,

    -- Reconciliation summary
    reconciliation_id           INT          NULL,
    reconciliation_matched_lines   INT       DEFAULT 0,
    reconciliation_unmatched_lines INT       DEFAULT 0,
    reconciliation_status       ENUM('NotReconciled','Partial','Complete') DEFAULT 'NotReconciled',

    -- Duplicate guard: unique constraint on file hash to prevent re-import
    UNIQUE KEY uq_frbsi_file_hash (file_hash),

    INDEX idx_frbsi_import_date    (import_date),
    INDEX idx_frbsi_statement_date (statement_date),
    INDEX idx_frbsi_bank_account   (bank_account_id)

    -- Uncomment the line below if fin_bank_accounts exists in your schema:
    -- ,FOREIGN KEY fk_frbsi_bank (bank_account_id) REFERENCES fin_bank_accounts(account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Audit trail of bank statement imports with duplicate detection.';


-- ---------------------------------------------------------------------------
-- Table: fin_posting_rules
-- Database-level configuration of double-entry validation rules.
-- Each rule describes what DR/CR account patterns are expected for a given
-- transaction type. The admin can set enforce_level = 'Block' to prevent
-- posting if the rule is violated, or 'Warning' to alert only.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_posting_rules (
    rule_id                 INT AUTO_INCREMENT PRIMARY KEY,
    rule_name               VARCHAR(100) NOT NULL,
    description             TEXT         NULL,

    -- Trigger condition
    transaction_type        VARCHAR(50)  NULL,   -- 'StudentReceipt', 'PaymentVoucher', etc.

    -- Debit side expectation
    debit_account_pattern   VARCHAR(100) NULL,   -- e.g. 'STUDENTS_AR_%'
    debit_required          BOOLEAN      DEFAULT TRUE,

    -- Credit side expectation
    credit_account_pattern  VARCHAR(100) NULL,   -- e.g. 'INCOME_%'
    credit_required         BOOLEAN      DEFAULT TRUE,

    -- Line count constraints
    min_debit_lines         INT          DEFAULT 1,
    max_debit_lines         INT          NULL,
    min_credit_lines        INT          DEFAULT 1,
    max_credit_lines        INT          NULL,

    -- Enforcement
    is_active               BOOLEAN      DEFAULT TRUE,
    enforce_level           ENUM('Warning','Block') DEFAULT 'Warning',
    override_allowed        BOOLEAN      DEFAULT FALSE,
    override_requires_approval BOOLEAN   DEFAULT TRUE,

    created_by              VARCHAR(50)  NULL,
    created_at              DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_fpr_transaction_type (transaction_type),
    INDEX idx_fpr_is_active        (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Configurable double-entry validation rules per transaction type.';


-- ---------------------------------------------------------------------------
-- Seed: standard industry posting rules
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO fin_posting_rules
    (rule_name, description, transaction_type, debit_account_pattern, credit_account_pattern,
     min_debit_lines, min_credit_lines, is_active, enforce_level)
VALUES
    ('Student Receipt Debit-Credit Balance',
     'Every student receipt must post equal debit (Bank/Cash) and credit (AR/Income) lines.',
     'StudentReceipt',  'BANK%',       'STUDENTS_AR%', 1, 1, TRUE, 'Block'),

    ('Payment Voucher Balance',
     'Payment vouchers must post equal debit (Expense) and credit (Bank/Cash) lines.',
     'PaymentVoucher',  'EXPENSE%',    'BANK%',        1, 1, TRUE, 'Block'),

    ('Journal Entry Balance',
     'All journal entries must have matching total debits and credits.',
     'JournalEntry',    NULL,          NULL,           1, 1, TRUE, 'Block'),

    ('Bank Transfer Balance',
     'Bank-to-bank transfers must debit destination and credit source in equal amounts.',
     'BankTransfer',    'BANK%',       'BANK%',        1, 1, TRUE, 'Block'),

    ('Night Audit Revenue Posting',
     'Night audit must post departmental revenue credits against receivables debit.',
     'NightAuditRun',   '%AR%',        'INCOME%',      1, 1, TRUE, 'Warning'),

    ('Reversal Must Mirror Original',
     'A reversal entry must exactly offset the original transaction amounts.',
     NULL,              NULL,          NULL,           1, 1, TRUE, 'Block');


-- ---------------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------------
-- SELECT rule_name, transaction_type, enforce_level, is_active FROM fin_posting_rules;
-- SELECT COUNT(*) AS reversal_rows FROM fin_transaction_reversal;
-- SELECT COUNT(*) AS import_rows   FROM fin_reco_bank_statement_import;

-- =============================================================================
-- END Phase 1.3
-- =============================================================================
