-- ============================================================
-- Payroll Module Redesign — Migration
-- Campus Dynamics MRU
-- Created : 2026-03-23
-- Run once against campus_dynamics database
-- NOTE: ADD COLUMN IF NOT EXISTS requires MySQL 8.0+.
--       On MySQL 5.7, remove IF NOT EXISTS clauses and run
--       each ALTER only if the column does not already exist.
-- ============================================================

-- ── Step 1: Extend hrm_payroll ─────────────────────────────
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

-- ── Step 2: Migrate existing lockStatus → payroll_status ───
UPDATE hrm_payroll
   SET payroll_status = 'PROCESSED'
 WHERE lockStatus = 'LOCKED'
   AND payroll_status = 'PENDING';

-- ── Step 3: Create hrm_payslips ────────────────────────────
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
    UNIQUE KEY uq_payslip_payroll_emp (payroll_id, empID),
    INDEX idx_ps_payroll  (payroll_id),
    INDEX idx_ps_emp      (empID),
    INDEX idx_ps_status   (status),
    INDEX idx_ps_period   (payroll_year, payroll_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Individual employee payslips generated from hrm_payroll processing';
