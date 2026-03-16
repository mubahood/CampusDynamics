-- Rollback: Restore validation-only fin_ApproveJournal_Safe (before posting logic was added)
-- Note: The original fin_ApproveJournal SP still exists as a fallback.

DROP PROCEDURE IF EXISTS fin_ApproveJournal_Safe;
