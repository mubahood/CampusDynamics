-- Migration: add_missing_financial_periods
-- Logical database: accounts
-- Generated: 2026-03-16T21:47:18
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.

-- Task A4: Add missing financial periods
-- Currently only 2025/2026 (Open) exists. Data spans 2023-2026.
-- Historical periods are Closed.

INSERT INTO fin_financial_years (finacial_Year, start_date, end_date, status)
SELECT '2023/2024', '2023-08-01', '2024-07-31', 'Closed'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fin_financial_years WHERE finacial_Year = '2023/2024');

INSERT INTO fin_financial_years (finacial_Year, start_date, end_date, status)
SELECT '2024/2025', '2024-08-01', '2025-07-31', 'Closed'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fin_financial_years WHERE finacial_Year = '2024/2025');
