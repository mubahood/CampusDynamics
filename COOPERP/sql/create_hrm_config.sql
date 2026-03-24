-- ============================================================
-- HR System Configuration Table
-- Campus Dynamics MRU
-- Created : 2026-03-23
-- Run     : once against campus_dynamics database
-- ============================================================

CREATE TABLE IF NOT EXISTS hrm_config (
    id                           INT           NOT NULL DEFAULT 1
                                               COMMENT 'Always 1 — single-row config table',

    -- ── PAYE Tax Brackets (Monthly Taxable Income, UGX) ──────
    paye_b1_min                  DECIMAL(15,2) NOT NULL DEFAULT 0,
    paye_b1_max                  DECIMAL(15,2) NOT NULL DEFAULT 235000,
    paye_b1_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 0.00   COMMENT 'Percent',

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
    paye_b5_max                  DECIMAL(15,2) NULL                    COMMENT 'NULL = no upper limit (top bracket)',
    paye_b5_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 40.00,

    -- ── Statutory Contributions ───────────────────────────────
    nssf_employee_rate           DECIMAL(5,2)  NOT NULL DEFAULT 5.00   COMMENT 'Employee NSSF deduction %',
    nssf_employer_rate           DECIMAL(5,2)  NOT NULL DEFAULT 10.00  COMMENT 'Employer NSSF % (institution cost, not deducted from salary)',

    should_charge_kabaka         ENUM('Yes','No') NOT NULL DEFAULT 'Yes',
    kabaka_rate                  DECIMAL(5,2)  NOT NULL DEFAULT 1.00   COMMENT 'Buganda Kingdom tithe % of basic pay',

    -- ── Local Service Tax ─────────────────────────────────────
    should_charge_local_tax      ENUM('Yes','No') NOT NULL DEFAULT 'No',
    local_tax_rate               DECIMAL(5,2)  NOT NULL DEFAULT 1.00   COMMENT '% of basic pay',

    -- ── Leave Entitlements (calendar days / year) ─────────────
    default_annual_leave_days    INT           NOT NULL DEFAULT 30,
    default_maternity_leave_days INT           NOT NULL DEFAULT 60,
    default_paternity_leave_days INT           NOT NULL DEFAULT 4,
    default_sick_leave_days      INT           NOT NULL DEFAULT 30,

    -- ── Financial Year & Pay Period ───────────────────────────
    financial_year_start_month   TINYINT       NOT NULL DEFAULT 7      COMMENT '7 = July (Uganda Government fiscal year)',

    -- ── Employment Policies ───────────────────────────────────
    probation_period_months      INT           NOT NULL DEFAULT 3,
    notice_period_days           INT           NOT NULL DEFAULT 30,
    overtime_rate_multiplier     DECIMAL(4,2)  NOT NULL DEFAULT 1.50   COMMENT 'E.g. 1.5 = time-and-a-half',
    gratuity_rate                DECIMAL(5,2)  NOT NULL DEFAULT 5.00   COMMENT '% of annual gross salary',

    -- ── Working Time ──────────────────────────────────────────
    working_days_per_month       INT           NOT NULL DEFAULT 22,
    working_hours_per_day        INT           NOT NULL DEFAULT 8,

    -- ── Audit ─────────────────────────────────────────────────
    last_updated                 DATETIME      NULL,
    updated_by                   VARCHAR(100)  NULL,

    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COMMENT='Single-row HR module configuration — do NOT insert more than one row.';

-- Seed default configuration (idempotent — safe to re-run)
INSERT IGNORE INTO hrm_config (id) VALUES (1);
