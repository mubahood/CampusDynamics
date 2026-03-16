-- Rollback: create_fin_approve_journal_safe
-- Logical database: accounts
-- Generated: 2026-03-16T22:51:44
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

DROP PROCEDURE IF EXISTS `fin_ApproveJournal_Safe`;
