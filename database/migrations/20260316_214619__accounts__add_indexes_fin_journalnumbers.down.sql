-- Rollback: add_indexes_fin_journalnumbers
-- Logical database: accounts
-- Generated: 2026-03-16T21:46:19
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DROP INDEX idx_GL_VoucherNo ON fin_journalnumbers;
DROP INDEX idx_PostStatus ON fin_journalnumbers;
DROP INDEX idx_journalDate ON fin_journalnumbers;
