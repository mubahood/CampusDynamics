-- Rollback: restore previous fin_ApproveJournal_Safe (with INT vs VARCHAR comparison bug)
-- See the .up.sql of the previous migration for the original body.
-- Note: rolling back restores the bug — only do this if needed for debugging.
DROP PROCEDURE IF EXISTS fin_ApproveJournal_Safe;
-- Re-apply the previous version from:
--   20260317_003239__accounts__fix_approve_journal_safe_add_posting_logic.up.sql
