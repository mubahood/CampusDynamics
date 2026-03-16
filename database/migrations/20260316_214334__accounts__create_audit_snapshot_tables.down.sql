-- Rollback: create_audit_snapshot_tables
-- Logical database: accounts
-- Generated: 2026-03-16T21:43:34
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.
DROP TABLE IF EXISTS fin_ledger_audit_snapshot_20260316;
DROP TABLE IF EXISTS fin_journalnumbers_audit_snapshot_20260316;
DROP TABLE IF EXISTS fin_subaccounts_audit_snapshot_20260316;
DROP TABLE IF EXISTS fin_mainaccounts_audit_snapshot_20260316;