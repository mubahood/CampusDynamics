-- =============================================================================
-- CAMPUS DYNAMICS – Finance System Realignment
-- Phase 1.2: Create Accounting Periods Table + Migrate from Legacy Tables
-- =============================================================================
-- Step A: Run CREATE TABLE section.
-- Step B: Run the INSERT migration block to copy data from legacy period tables.
-- Step C: Run verification queries.
-- Legacy tables (fin_financial_years, fin_financial_periods) are NOT dropped.
-- Author: Finance Realignment Project
-- Date:   2026-04-27
-- =============================================================================

USE campus_dynamics_portal;

-- ---------------------------------------------------------------------------
-- Table: fin_accounting_periods
-- Single unified source of truth for accounting period lifecycle.
-- Consolidates fin_financial_years + fin_financial_periods and adds the
-- state hierarchy (Open → Frozen → Closed → Archived).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_accounting_periods (
    period_id           INT AUTO_INCREMENT PRIMARY KEY,
    fiscal_year         VARCHAR(10) NOT NULL,      -- e.g. '2025-2026'
    period_number       INT         NOT NULL,       -- 1-12 for monthly
    period_name         VARCHAR(50) NULL,           -- 'January 2025', 'Q1 2025', etc.
    start_date          DATE        NOT NULL,
    end_date            DATE        NOT NULL,

    -- State hierarchy (only one should be active at a time)
    is_open_for_posting      BOOLEAN DEFAULT FALSE,
    is_frozen_for_month_end  BOOLEAN DEFAULT FALSE,
    is_closed_for_adjustment BOOLEAN DEFAULT FALSE,
    is_archived              BOOLEAN DEFAULT FALSE,

    posting_lock_reason  VARCHAR(100) NULL,
    posted_by_user       VARCHAR(50)  NULL,
    locked_at            DATETIME     NULL,

    -- Financial close checklist flags
    trial_balance_balanced      BOOLEAN DEFAULT FALSE,
    trial_balance_checked_by    VARCHAR(50) NULL,
    trial_balance_checked_at    DATETIME    NULL,

    accounts_recognized  BOOLEAN DEFAULT FALSE,
    depreciation_posted  BOOLEAN DEFAULT FALSE,
    revenue_finalized    BOOLEAN DEFAULT FALSE,

    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_fap_fiscal_period (fiscal_year, period_number),
    INDEX idx_fap_is_open    (is_open_for_posting),
    INDEX idx_fap_start_date (start_date),
    INDEX idx_fap_fiscal_year (fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Unified accounting period lifecycle table (replaces fin_financial_years + fin_financial_periods).';


-- ---------------------------------------------------------------------------
-- MIGRATION: Populate from legacy tables
-- Only runs if legacy tables exist. Wrapped in a conditional procedure so
-- it is safe to run even if the legacy tables are named differently.
-- Review and customise the source column names before running.
-- ---------------------------------------------------------------------------

-- Adjust these column references to match your actual legacy table schema:
--   fin_financial_years  : id, fiscal_year, is_active
--   fin_financial_periods: id, financial_year_id, period_number, period_name,
--                          start_date, end_date, is_open, is_closed

DROP PROCEDURE IF EXISTS mig_populate_accounting_periods;

DELIMITER $$

CREATE PROCEDURE mig_populate_accounting_periods()
BEGIN
    -- Only proceed if legacy tables exist
    IF (
        (SELECT COUNT(*) FROM information_schema.tables
         WHERE table_schema = DATABASE()
           AND table_name = 'fin_financial_periods') > 0
    ) THEN
        INSERT IGNORE INTO fin_accounting_periods
            (fiscal_year, period_number, period_name, start_date, end_date,
             is_open_for_posting, is_closed_for_adjustment, is_archived)
        SELECT
            COALESCE(fy.fiscal_year, YEAR(fp.start_date))   AS fiscal_year,
            fp.period_number,
            fp.period_name,
            fp.start_date,
            fp.end_date,
            COALESCE(fp.is_open,   0)                        AS is_open_for_posting,
            COALESCE(fp.is_closed, 0)                        AS is_closed_for_adjustment,
            CASE WHEN COALESCE(fp.is_closed, 0) = 1
                  AND fp.end_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
                 THEN 1 ELSE 0 END                           AS is_archived
        FROM fin_financial_periods fp
        LEFT JOIN fin_financial_years fy ON fp.financial_year_id = fy.id;

        SELECT CONCAT('Migrated ', ROW_COUNT(), ' period record(s) into fin_accounting_periods.') AS Result;
    ELSE
        SELECT 'Legacy table fin_financial_periods not found. No migration performed.' AS Result;
    END IF;
END$$

DELIMITER ;

-- Execute migration
CALL mig_populate_accounting_periods();
DROP PROCEDURE IF EXISTS mig_populate_accounting_periods;


-- ---------------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------------
-- SELECT fiscal_year, period_number, period_name, start_date, end_date,
--        is_open_for_posting, is_closed_for_adjustment, is_archived
-- FROM fin_accounting_periods
-- ORDER BY fiscal_year DESC, period_number DESC;

-- =============================================================================
-- END Phase 1.2
-- =============================================================================
