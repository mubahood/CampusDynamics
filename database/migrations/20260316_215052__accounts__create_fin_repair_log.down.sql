-- Rollback: create_fin_repair_log
-- Logical database: accounts
-- Generated: 2026-03-16T21:50:52
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DROP TABLE IF EXISTS fin_repair_log;
