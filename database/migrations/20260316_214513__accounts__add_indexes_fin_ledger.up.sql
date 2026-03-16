-- Migration: add_indexes_fin_ledger
-- Logical database: accounts
-- Generated: 2026-03-16T21:45:13
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.
-- Task A2: Add missing indexes to fin_ledger
-- Existing indexes: PRIMARY(TID), Index_2(accountcode,account_type,transactionDate), Index_3(folio)
-- Missing: voucherNo (used in every voucher join), journal_no (journal lookup), transactionDate (date filtering)

CREATE INDEX idx_voucherNo ON fin_ledger (voucherNo);
CREATE INDEX idx_journal_no ON fin_ledger (journal_no);
CREATE INDEX idx_transactionDate ON fin_ledger (transactionDate);