-- Migration: create_audit_snapshot_tables
-- Logical database: accounts
-- Generated: 2026-03-16T21:43:34
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.
-- Task A1: Create audit snapshot tables before any structural changes
-- These preserve the exact state of all financial tables as of 2026-03-16

CREATE TABLE IF NOT EXISTS fin_ledger_audit_snapshot_20260316 AS
SELECT * FROM fin_ledger;

CREATE TABLE IF NOT EXISTS fin_journalnumbers_audit_snapshot_20260316 AS
SELECT * FROM fin_journalnumbers;

CREATE TABLE IF NOT EXISTS fin_subaccounts_audit_snapshot_20260316 AS
SELECT * FROM fin_subaccounts;

CREATE TABLE IF NOT EXISTS fin_mainaccounts_audit_snapshot_20260316 AS
SELECT * FROM fin_mainaccounts;