-- Rollback: void_empty_journals
-- Logical database: accounts
-- Generated: 2026-03-16T23:23:46
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

-- Reverse: un-void the journals that were auto-voided by this migration
-- (void_reason identifies exactly which ones were changed here)
UPDATE fin_journalnumbers
SET PostStatus  = 'Pending',
    void_reason = NULL
WHERE PostStatus  = 'Void'
  AND void_reason = 'Auto-voided: No ledger entries (2026 audit)';
