-- Migration: add_void_reason_to_journalnumbers
-- Logical database: accounts
-- Generated: 2026-03-16T21:50:03
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.

-- Task A6: Add void_reason column to fin_journalnumbers
-- Needed for voiding empty/abandoned journals with a documented reason
-- Also update PostStatus enum to include 'Void' as valid value

ALTER TABLE fin_journalnumbers
    ADD COLUMN void_reason VARCHAR(100) DEFAULT NULL;

-- Update the status enum to include 'Void' if it doesn't already
-- Current PostStatus values found in data: 'Posted', 'Pending', 'Not Posted', 'l'
ALTER TABLE fin_journalnumbers
    MODIFY COLUMN PostStatus VARCHAR(15) DEFAULT 'Not Posted';
