-- Rollback: add_ledger_validation_triggers
-- Logical database: accounts
-- Generated: 2026-03-16T21:48:25
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DROP TRIGGER IF EXISTS trg_fin_ledger_before_insert;
DROP TRIGGER IF EXISTS trg_fin_ledger_before_update;
