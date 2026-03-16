-- Rollback: log_unbalanced_vouchers_to_repair_log
-- Logical database: accounts
-- Generated: 2026-03-16T23:22:35
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

-- Remove only the records inserted by this migration (system_audit_2026)
DELETE FROM fin_repair_log
WHERE repair_type = 'UNBALANCED_VOUCHER'
  AND repaired_by = 'system_audit_2026';
