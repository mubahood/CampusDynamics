-- ============================================================
-- HR Payroll Module — Complete Safe Migration
-- Campus Dynamics MRU
-- Created : 2026-03-24
-- Run     : once against campus_dynamics database
--
-- SAFE TO RE-RUN: all DDL uses IF NOT EXISTS / IF EXISTS guards.
-- Covers everything in:
--   • create_hrm_config.sql
--   • alter_hrm_payroll_payslips.sql
--   • create_hrm_payroll_extra_records.sql
--
-- MySQL compatibility:
--   MySQL 8.0+ : run as-is (ADD COLUMN IF NOT EXISTS supported).
--   MySQL 5.7  : see "MySQL 5.7 fallback" procedure at the bottom.
-- ============================================================

SET NAMES utf8mb4;

-- ── STEP 1: hrm_config ──────────────────────────────────────
-- Single-row HR configuration table (PAYE brackets, NSSF, Kabaka, Local Tax).

CREATE TABLE IF NOT EXISTS hrm_config (
    id                           INT           NOT NULL DEFAULT 1
                                               COMMENT 'Always 1 — single-row config table',

    -- PAYE Tax Brackets (Monthly Taxable Income, UGX)
    paye_b1_min                  DECIMAL(15,2) NOT NULL DEFAULT 0,
    paye_b1_max                  DECIMAL(15,2) NOT NULL DEFAULT 235000,
    paye_b1_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 0.00,

    paye_b2_min                  DECIMAL(15,2) NOT NULL DEFAULT 235001,
    paye_b2_max                  DECIMAL(15,2) NOT NULL DEFAULT 335000,
    paye_b2_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 10.00,

    paye_b3_min                  DECIMAL(15,2) NOT NULL DEFAULT 335001,
    paye_b3_max                  DECIMAL(15,2) NOT NULL DEFAULT 410000,
    paye_b3_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 20.00,

    paye_b4_min                  DECIMAL(15,2) NOT NULL DEFAULT 410001,
    paye_b4_max                  DECIMAL(15,2) NOT NULL DEFAULT 10000000,
    paye_b4_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 30.00,

    paye_b5_min                  DECIMAL(15,2) NOT NULL DEFAULT 10000001,
    paye_b5_max                  DECIMAL(15,2) NULL      COMMENT 'NULL = no upper limit (top bracket)',
    paye_b5_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 40.00,

    -- Statutory Contributions
    nssf_employee_rate           DECIMAL(5,2)  NOT NULL DEFAULT 5.00
                                               COMMENT 'Employee NSSF deduction %',
    nssf_employer_rate           DECIMAL(5,2)  NOT NULL DEFAULT 10.00
                                               COMMENT 'Employer NSSF % (cost to institution)',

    should_charge_kabaka         ENUM('YES','NO') NOT NULL DEFAULT 'YES',
    kabaka_rate                  DECIMAL(5,2)  NOT NULL DEFAULT 1.00
                                               COMMENT 'Buganda Kingdom tithe % of basic pay',

    should_charge_local_tax      ENUM('YES','NO') NOT NULL DEFAULT 'NO',
    local_tax_rate               DECIMAL(5,2)  NOT NULL DEFAULT 1.00
                                               COMMENT '% of basic pay',

    -- Leave Entitlements
    default_annual_leave_days    INT           NOT NULL DEFAULT 30,
    default_maternity_leave_days INT           NOT NULL DEFAULT 60,
    default_paternity_leave_days INT           NOT NULL DEFAULT 4,
    default_sick_leave_days      INT           NOT NULL DEFAULT 30,

    -- Financial Year
    financial_year_start_month   TINYINT       NOT NULL DEFAULT 7
                                               COMMENT '7 = July (Uganda fiscal year)',

    -- Employment Policies
    probation_period_months      INT           NOT NULL DEFAULT 3,
    notice_period_days           INT           NOT NULL DEFAULT 30,
    overtime_rate_multiplier     DECIMAL(4,2)  NOT NULL DEFAULT 1.50,
    gratuity_rate                DECIMAL(5,2)  NOT NULL DEFAULT 5.00,

    -- Working Time
    working_days_per_month       INT           NOT NULL DEFAULT 22,
    working_hours_per_day        INT           NOT NULL DEFAULT 8,

    -- Audit
    last_updated                 DATETIME      NULL,
    updated_by                   VARCHAR(100)  NULL,

    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Single-row HR module configuration — do NOT insert more than one row.';

-- Seed default configuration (idempotent)
INSERT IGNORE INTO hrm_config (id) VALUES (1);

-- ── STEP 2: Extend hrm_payroll ──────────────────────────────
-- Adds payroll lifecycle and targeting columns.
-- MySQL 8.0+: ADD COLUMN IF NOT EXISTS is supported directly.

ALTER TABLE hrm_payroll
    ADD COLUMN IF NOT EXISTS payroll_status
        ENUM('PENDING','PROCESSED','CANCELLED') NOT NULL DEFAULT 'PENDING'
        COMMENT 'PENDING=editable; PROCESSED=locked; CANCELLED=void',
    ADD COLUMN IF NOT EXISTS target_type
        ENUM('ALL','DEPARTMENT','EMPLOYEE') NOT NULL DEFAULT 'ALL'
        COMMENT 'Who is included in this payroll run',
    ADD COLUMN IF NOT EXISTS target_ids
        TEXT NULL
        COMMENT 'Comma-separated dept IDs or empIDs when target_type != ALL',
    ADD COLUMN IF NOT EXISTS should_include_deductions
        ENUM('YES','NO') NOT NULL DEFAULT 'YES',
    ADD COLUMN IF NOT EXISTS should_include_allowances
        ENUM('YES','NO') NOT NULL DEFAULT 'YES',
    ADD COLUMN IF NOT EXISTS date_processed
        DATETIME NULL,
    ADD COLUMN IF NOT EXISTS processed_by
        VARCHAR(100) NULL;

-- Migrate existing lockStatus → payroll_status (idempotent: WHERE guard prevents double-update)
UPDATE hrm_payroll
   SET payroll_status = 'PROCESSED'
 WHERE lockStatus    = 'LOCKED'
   AND payroll_status = 'PENDING';

-- ── STEP 3: hrm_payslips ────────────────────────────────────
-- One row per employee per payroll run.

CREATE TABLE IF NOT EXISTS hrm_payslips (
    ID                   INT            NOT NULL AUTO_INCREMENT,
    payroll_id           INT            NOT NULL   COMMENT 'FK → hrm_payroll.ID',
    empID                INT            NOT NULL   COMMENT 'FK → hrm_employee.empID',

    payroll_year         INT            NOT NULL,
    payroll_month        INT            NOT NULL   COMMENT '1=January … 12=December',
    payroll_month_name   ENUM('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
                              'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER')
                         NOT NULL,

    basic_pay            DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    gross_salary         DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    total_allowances     DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    allowance_amount     DECIMAL(15,2)  NOT NULL DEFAULT 0.00
                         COMMENT 'Ad-hoc allowances only',
    allowance_details    TEXT           NULL
                         COMMENT 'Pipe-delimited: TypeName:Amount|TypeName:Amount',

    total_deductions     DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    deduction_amount     DECIMAL(15,2)  NOT NULL DEFAULT 0.00
                         COMMENT 'Non-statutory ad-hoc deductions only',
    deduction_details    TEXT           NULL
                         COMMENT 'Pipe-delimited: Reason:Amount|Reason:Amount',

    paye                 DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    nssf                 DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    kabaka_contribution  DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    local_tax            DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    net_salary           DECIMAL(15,2)  NOT NULL DEFAULT 0.00,

    status               ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    date_generated       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_by          VARCHAR(100)   NULL,
    date_approved        DATETIME       NULL,
    rejection_reason     TEXT           NULL,

    PRIMARY KEY (ID),
    UNIQUE  KEY uq_payslip_payroll_emp (payroll_id, empID),
    INDEX idx_ps_payroll (payroll_id),
    INDEX idx_ps_emp     (empID),
    INDEX idx_ps_status  (status),
    INDEX idx_ps_period  (payroll_year, payroll_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Individual employee payslips generated from hrm_payroll processing';

-- ── STEP 4: hrm_deduction_records ───────────────────────────
-- Ad-hoc deductions scheduled for specific payroll months.

CREATE TABLE IF NOT EXISTS hrm_deduction_records (
    id               INT            NOT NULL AUTO_INCREMENT,
    empID            INT            NOT NULL   COMMENT 'FK → hrm_employee.empID',
    deduction_type   VARCHAR(100)   NOT NULL,
    amount           DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    description      TEXT           NULL,
    date_recorded    DATE           NOT NULL,
    status           ENUM('PENDING','SETTLED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    to_deduct_month  ENUM('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
                         'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER') NOT NULL,
    to_deduct_year   INT            NOT NULL,
    payment_date     DATE           NULL       COMMENT 'Set when payroll is generated',
    payroll_id       INT            NULL       COMMENT 'FK → hrm_payroll.ID, set on settlement',
    recorded_by      VARCHAR(100)   NULL,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_ded_emp_period (empID, to_deduct_month, to_deduct_year),
    INDEX idx_ded_status     (status),
    INDEX idx_ded_payroll    (payroll_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Ad-hoc deductions scheduled for specific payroll periods (advances, loans, etc.)';

-- ── STEP 5: hrm_allowance_records ───────────────────────────
-- Ad-hoc allowances scheduled for specific payroll months.

CREATE TABLE IF NOT EXISTS hrm_allowance_records (
    id               INT            NOT NULL AUTO_INCREMENT,
    empID            INT            NOT NULL   COMMENT 'FK → hrm_employee.empID',
    allowance_type   VARCHAR(100)   NOT NULL,
    amount           DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    description      TEXT           NULL,
    date_recorded    DATE           NOT NULL,
    status           ENUM('PENDING','SETTLED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    to_add_month     ENUM('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
                         'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER') NOT NULL,
    to_add_year      INT            NOT NULL,
    payment_date     DATE           NULL       COMMENT 'Set when payroll is generated',
    payroll_id       INT            NULL       COMMENT 'FK → hrm_payroll.ID, set on settlement',
    recorded_by      VARCHAR(100)   NULL,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_alw_emp_period (empID, to_add_month, to_add_year),
    INDEX idx_alw_status     (status),
    INDEX idx_alw_payroll    (payroll_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Ad-hoc allowances scheduled for specific payroll periods (transport, housing, bonuses, etc.)';

-- ── STEP 6: Verification queries ────────────────────────────
-- Run these after migration to confirm everything is in place.

/*
SELECT 'hrm_config columns'       AS check_item, COUNT(*) AS col_count FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='hrm_config';
SELECT 'hrm_payroll new columns'  AS check_item, COUNT(*) AS col_count FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='hrm_payroll'           AND COLUMN_NAME IN ('payroll_status','target_type','target_ids','should_include_deductions','should_include_allowances','date_processed','processed_by');
SELECT 'hrm_payslips columns'     AS check_item, COUNT(*) AS col_count FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='hrm_payslips';
SELECT 'hrm_deduction_records'    AS check_item, COUNT(*) AS col_count FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='hrm_deduction_records';
SELECT 'hrm_allowance_records'    AS check_item, COUNT(*) AS col_count FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='hrm_allowance_records';
SELECT 'hrm_config seed row'      AS check_item, COUNT(*) AS row_count FROM hrm_config;
*/

-- ── MySQL 5.7 FALLBACK ───────────────────────────────────────
-- If your server is MySQL 5.7, ALTER TABLE ... ADD COLUMN IF NOT EXISTS
-- is NOT supported.  Use this stored procedure instead of Step 2 above.
--
-- DELIMITER //
-- DROP PROCEDURE IF EXISTS sp_add_col_if_missing //
-- CREATE PROCEDURE sp_add_col_if_missing(
--     p_table  VARCHAR(64),
--     p_column VARCHAR(64),
--     p_def    TEXT
-- )
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1 FROM information_schema.COLUMNS
--          WHERE TABLE_SCHEMA = DATABASE()
--            AND TABLE_NAME   = p_table
--            AND COLUMN_NAME  = p_column
--     ) THEN
--         SET @sql = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_column, '` ', p_def);
--         PREPARE stmt FROM @sql;
--         EXECUTE stmt;
--         DEALLOCATE PREPARE stmt;
--     END IF;
-- END //
-- DELIMITER ;
--
-- CALL sp_add_col_if_missing('hrm_payroll', 'payroll_status',          "ENUM('PENDING','PROCESSED','CANCELLED') NOT NULL DEFAULT 'PENDING'");
-- CALL sp_add_col_if_missing('hrm_payroll', 'target_type',             "ENUM('ALL','DEPARTMENT','EMPLOYEE') NOT NULL DEFAULT 'ALL'");
-- CALL sp_add_col_if_missing('hrm_payroll', 'target_ids',              "TEXT NULL");
-- CALL sp_add_col_if_missing('hrm_payroll', 'should_include_deductions',"ENUM('YES','NO') NOT NULL DEFAULT 'YES'");
-- CALL sp_add_col_if_missing('hrm_payroll', 'should_include_allowances',"ENUM('YES','NO') NOT NULL DEFAULT 'YES'");
-- CALL sp_add_col_if_missing('hrm_payroll', 'date_processed',          "DATETIME NULL");
-- CALL sp_add_col_if_missing('hrm_payroll', 'processed_by',            "VARCHAR(100) NULL");
-- DROP PROCEDURE IF EXISTS sp_add_col_if_missing;
