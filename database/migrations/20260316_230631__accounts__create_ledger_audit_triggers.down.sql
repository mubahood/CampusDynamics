-- Rollback: create_ledger_audit_triggers
-- Logical database: accounts
-- Generated: 2026-03-16T23:06:31
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DROP TRIGGER IF EXISTS `trg_fin_ledger_after_update`;
DROP TRIGGER IF EXISTS `trg_fin_ledger_before_delete`;
