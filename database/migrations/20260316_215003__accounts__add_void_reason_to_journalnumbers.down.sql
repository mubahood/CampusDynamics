-- Rollback: add_void_reason_to_journalnumbers
-- Logical database: accounts
-- Generated: 2026-03-16T21:50:03
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

ALTER TABLE fin_journalnumbers
    DROP COLUMN void_reason;
