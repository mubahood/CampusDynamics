-- Rollback: add_missing_financial_periods
-- Logical database: accounts
-- Generated: 2026-03-16T21:47:18
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DELETE FROM fin_financial_years WHERE finacial_Year IN ('2023/2024', '2024/2025');
