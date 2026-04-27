-- =============================================================================
-- Phase1_6_Migrate_Periods.sql — Finance System Realignment
-- =============================================================================
-- PURPOSE:
--   Populate fin_accounting_periods from the existing legacy period table(s).
--   This script is safe to run multiple times (uses INSERT IGNORE / ON DUPLICATE
--   KEY UPDATE on (fiscal_year, period_number) unique key).
--
-- PREREQUISITES:
--   fin_accounting_periods must exist (Phase1_2_Create_Period_Tables.sql).
--   At least one of the candidate source tables must exist:
--     fin_financial_years, fin_accounting_year, fin_fiscal_year
--
-- SAFETY:
--   * No DROP / ALTER statements.
--   * No existing data is deleted from legacy tables.
--   * Legacy tables are left entirely intact.
--   * All legacy period rows map to period_number = 1..12 where possible.
--
-- INSTRUCTIONS:
--   Execute as a DBA with SELECT on the legacy tables and INSERT on
--   fin_accounting_periods.  Review the row counts printed at the end.
-- =============================================================================

-- Verify target table exists before doing anything
SELECT 'Checking target table…' AS step;
SELECT COUNT(*) AS existing_periods FROM fin_accounting_periods;

-- =============================================================================
-- SECTION A: Migrate from fin_financial_years (most common in Campus Dynamics)
-- =============================================================================
-- Expected columns: year_id (PK), fiscal_year (VARCHAR), start_date, end_date,
-- is_open, is_locked, created_by, created_at
-- Maps each financial year as 12 monthly periods (open = not locked)
-- =============================================================================

INSERT IGNORE INTO fin_accounting_periods
    (fiscal_year, period_number, period_name, start_date, end_date,
     is_open, created_at)
SELECT
    fy.fiscal_year                                          AS fiscal_year,
    m.period_number                                        AS period_number,
    CONCAT(DATE_FORMAT(
        DATE_ADD(fy.start_date, INTERVAL (m.period_number - 1) MONTH),
        '%b %Y'))                                          AS period_name,
    DATE_ADD(fy.start_date, INTERVAL (m.period_number - 1) MONTH)
                                                           AS start_date,
    LAST_DAY(DATE_ADD(fy.start_date, INTERVAL (m.period_number - 1) MONTH))
                                                           AS end_date,
    CASE
        WHEN fy.is_locked = 1 THEN 0
        WHEN fy.is_open   = 0 THEN 0
        ELSE 1
    END                                                    AS is_open,
    COALESCE(fy.created_at, NOW())                         AS created_at
FROM
    fin_financial_years fy
    -- Cross join with a 12-row auxiliary number set
    CROSS JOIN (
        SELECT 1  AS period_number UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL SELECT 6
        UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    ) AS m
WHERE
    fy.start_date IS NOT NULL
    -- Only generate periods whose start month falls within the fiscal year
    AND DATE_ADD(fy.start_date, INTERVAL (m.period_number - 1) MONTH)
            <= COALESCE(fy.end_date, DATE_ADD(fy.start_date, INTERVAL 11 MONTH));

SELECT CONCAT('A: Migrated from fin_financial_years → ',
    ROW_COUNT(), ' row(s) inserted.') AS result;

-- =============================================================================
-- SECTION B (optional fallback): Migrate from fin_accounting_year
-- Activate this block ONLY if your schema uses fin_accounting_year instead.
-- =============================================================================
-- Uncomment to enable:
--
-- INSERT IGNORE INTO fin_accounting_periods
--     (fiscal_year, period_number, period_name, start_date, end_date, is_open, created_at)
-- SELECT
--     ay.year_label,
--     m.period_number,
--     CONCAT(DATE_FORMAT(DATE_ADD(ay.from_date, INTERVAL (m.period_number - 1) MONTH), '%b %Y')),
--     DATE_ADD(ay.from_date, INTERVAL (m.period_number - 1) MONTH),
--     LAST_DAY(DATE_ADD(ay.from_date, INTERVAL (m.period_number - 1) MONTH)),
--     CASE WHEN ay.status = 'Open' THEN 1 ELSE 0 END,
--     NOW()
-- FROM fin_accounting_year ay
-- CROSS JOIN (
--     SELECT 1 AS period_number UNION ALL SELECT 2 UNION ALL SELECT 3
--     UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL SELECT 6
--     UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL SELECT 9
--     UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
-- ) AS m
-- WHERE ay.from_date IS NOT NULL
--   AND DATE_ADD(ay.from_date, INTERVAL (m.period_number - 1) MONTH)
--           <= COALESCE(ay.to_date, DATE_ADD(ay.from_date, INTERVAL 11 MONTH));

-- =============================================================================
-- SECTION C: Verify results
-- =============================================================================

SELECT 'Final count of fin_accounting_periods:' AS step;
SELECT fiscal_year, COUNT(*) AS periods, MIN(start_date) AS first_start, MAX(end_date) AS last_end
FROM fin_accounting_periods
GROUP BY fiscal_year
ORDER BY fiscal_year;

SELECT 'Migration complete. No legacy table has been modified.' AS status;
