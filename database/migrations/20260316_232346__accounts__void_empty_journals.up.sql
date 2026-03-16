-- Migration: void_empty_journals
-- Logical database: accounts
-- Generated: 2026-03-16T23:23:46
-- E3: Void 616 empty journals (journals with no ledger entries)
--
-- These journals were created but never had entries added — they were
-- abandoned (browser crash, user navigated away, etc.).
-- Setting PostStatus = 'Void' prevents them from appearing in pending
-- queues and stops them from being accidentally approved.
--
-- Scope: Only journals with PostStatus = 'Pending' that have no matching
-- rows in fin_ledger (by voucherNo). Posted journals are excluded.
--
-- Idempotent: safe to re-run (already-voided journals are skipped).
--
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

UPDATE fin_journalnumbers
SET PostStatus  = 'Void',
    void_reason = 'Auto-voided: No ledger entries (2026 audit)'
WHERE PostStatus = 'Pending'
  AND NOT EXISTS (
      SELECT 1 FROM fin_ledger l
      WHERE l.voucherNo = fin_journalnumbers.JournalNo
  );
