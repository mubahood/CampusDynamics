-- ============================================================
-- HR Payroll Extra Records — Ad-hoc Deductions & Allowances
-- Campus Dynamics MRU
-- Created : 2026-03-23
-- Run once against campus_dynamics database
-- ============================================================

-- ── Table: hrm_deduction_records ──────────────────────────────
CREATE TABLE IF NOT EXISTS hrm_deduction_records (
    id               INT            NOT NULL AUTO_INCREMENT,
    empID            INT            NOT NULL                          COMMENT 'FK → hrm_employee.empID',
    deduction_type   VARCHAR(100)   NOT NULL,
    amount           DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    description      TEXT           NULL,
    date_recorded    DATE           NOT NULL,
    status           ENUM('PENDING','SETTLED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    to_deduct_month  ENUM('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
                         'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER') NOT NULL,
    to_deduct_year   INT            NOT NULL,
    payment_date     DATE           NULL                              COMMENT 'Set when payroll is generated',
    payroll_id       INT            NULL                              COMMENT 'FK → hrm_payroll.ID, set on settlement',
    recorded_by      VARCHAR(100)   NULL,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_ded_emp_period (empID, to_deduct_month, to_deduct_year),
    INDEX idx_ded_status (status),
    INDEX idx_ded_payroll (payroll_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Ad-hoc deductions scheduled for specific payroll periods (advances, loans, etc.)';

-- ── Table: hrm_allowance_records ──────────────────────────────
CREATE TABLE IF NOT EXISTS hrm_allowance_records (
    id               INT            NOT NULL AUTO_INCREMENT,
    empID            INT            NOT NULL                          COMMENT 'FK → hrm_employee.empID',
    allowance_type   VARCHAR(100)   NOT NULL,
    amount           DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    description      TEXT           NULL,
    date_recorded    DATE           NOT NULL,
    status           ENUM('PENDING','SETTLED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    to_add_month     ENUM('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
                         'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER') NOT NULL,
    to_add_year      INT            NOT NULL,
    payment_date     DATE           NULL                              COMMENT 'Set when payroll is generated',
    payroll_id       INT            NULL                              COMMENT 'FK → hrm_payroll.ID, set on settlement',
    recorded_by      VARCHAR(100)   NULL,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_alw_emp_period (empID, to_add_month, to_add_year),
    INDEX idx_alw_status (status),
    INDEX idx_alw_payroll (payroll_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Ad-hoc allowances scheduled for specific payroll periods (transport, housing, bonuses, etc.)';

-- ── Dummy Data (uses first few real employees — safe to re-run) ─

-- Deductions sample
INSERT INTO hrm_deduction_records (empID, deduction_type, amount, description, date_recorded, status, to_deduct_month, to_deduct_year, recorded_by)
SELECT empID, 'Salary Advance', 500000.00,
       'Advance of UGX 500,000 issued March 2026 — single repayment April 2026',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1;

INSERT INTO hrm_deduction_records (empID, deduction_type, amount, description, date_recorded, status, to_deduct_month, to_deduct_year, recorded_by)
SELECT empID, 'Loan Repayment (Staff SACCO)', 200000.00,
       'SACCO Loan UGX 2,400,000 — instalment 1 of 12',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 1;

INSERT INTO hrm_deduction_records (empID, deduction_type, amount, description, date_recorded, status, to_deduct_month, to_deduct_year, recorded_by)
SELECT empID, 'Loan Repayment (Staff SACCO)', 200000.00,
       'SACCO Loan UGX 2,400,000 — instalment 2 of 12',
       CURDATE(), 'PENDING', 'MAY', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 1;

INSERT INTO hrm_deduction_records (empID, deduction_type, amount, description, date_recorded, status, to_deduct_month, to_deduct_year, recorded_by)
SELECT empID, 'Loan Repayment (Staff SACCO)', 200000.00,
       'SACCO Loan UGX 2,400,000 — instalment 3 of 12',
       CURDATE(), 'PENDING', 'JUNE', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 1;

INSERT INTO hrm_deduction_records (empID, deduction_type, amount, description, date_recorded, status, to_deduct_month, to_deduct_year, recorded_by)
SELECT empID, 'Welfare Contribution', 50000.00,
       'Annual staff welfare Q2 2026',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 2;

-- Allowances sample
INSERT INTO hrm_allowance_records (empID, allowance_type, amount, description, date_recorded, status, to_add_month, to_add_year, recorded_by)
SELECT empID, 'Transport Allowance', 150000.00,
       'Monthly transport — April 2026',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1;

INSERT INTO hrm_allowance_records (empID, allowance_type, amount, description, date_recorded, status, to_add_month, to_add_year, recorded_by)
SELECT empID, 'Housing Allowance', 350000.00,
       'Temporary housing supplement — April 2026',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 1;

INSERT INTO hrm_allowance_records (empID, allowance_type, amount, description, date_recorded, status, to_add_month, to_add_year, recorded_by)
SELECT empID, 'Acting Allowance', 300000.00,
       'Acting as HOD — April 2026',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 2;

INSERT INTO hrm_allowance_records (empID, allowance_type, amount, description, date_recorded, status, to_add_month, to_add_year, recorded_by)
SELECT empID, 'Transport Allowance', 150000.00,
       'Monthly transport — May 2026',
       CURDATE(), 'PENDING', 'MAY', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1;

INSERT INTO hrm_allowance_records (empID, allowance_type, amount, description, date_recorded, status, to_add_month, to_add_year, recorded_by)
SELECT empID, 'Annual Bonus', 500000.00,
       'Performance bonus Q1 2026',
       CURDATE(), 'PENDING', 'APRIL', 2026, 'Administrator'
FROM hrm_employee ORDER BY empID LIMIT 1 OFFSET 3;
