-- Migration: add_indexes_fin_journalnumbers
-- Logical database: accounts
-- Generated: 2026-03-16T21:46:19
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.

-- Task A3: Add missing indexes to fin_journalnumbers
-- Existing: PRIMARY(JournalNo) only
-- GL_VoucherNo is used in every ledger join, PostStatus for filtering, journalDate for date queries

CREATE INDEX idx_GL_VoucherNo ON fin_journalnumbers (GL_VoucherNo);
CREATE INDEX idx_PostStatus ON fin_journalnumbers (PostStatus);
CREATE INDEX idx_journalDate ON fin_journalnumbers (journalDate);
