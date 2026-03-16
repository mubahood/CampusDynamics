-- Rollback: create_v_all_accounts_view
-- Logical database: accounts
-- Generated: 2026-03-16T23:23:46
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DROP VIEW IF EXISTS v_all_accounts;
