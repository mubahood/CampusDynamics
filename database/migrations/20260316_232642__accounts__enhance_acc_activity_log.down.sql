-- Rollback: enhance_acc_activity_log
-- Logical database: accounts
-- Generated: 2026-03-16T23:26:42
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

ALTER TABLE acc_activity_log
    DROP COLUMN IF EXISTS ip_address,
    DROP COLUMN IF EXISTS session_id,
    DROP COLUMN IF EXISTS affected_voucherNo,
    DROP COLUMN IF EXISTS affected_amount,
    DROP COLUMN IF EXISTS before_value,
    DROP COLUMN IF EXISTS after_value;

DROP INDEX IF EXISTS idx_log_access_date ON acc_activity_log;
DROP INDEX IF EXISTS idx_log_user_id     ON acc_activity_log;
DROP INDEX IF EXISTS idx_log_page_func   ON acc_activity_log;
