-- Rollback: add_indexes_fin_ledger
-- Logical database: accounts
-- Generated: 2026-03-16T21:45:13
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.
DROP INDEX idx_voucherNo ON fin_ledger;
DROP INDEX idx_journal_no ON fin_ledger;
DROP INDEX idx_transactionDate ON fin_ledger;