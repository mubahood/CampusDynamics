-- Rollback: Data repair cannot be automatically rolled back.
-- The corrective entries inserted by E6-fix are marked with teller='SYSTEM_REPAIR_E6_FIX'.
-- To manually rollback: DELETE FROM fin_ledger WHERE teller = 'SYSTEM_REPAIR_E6_FIX';
-- Then reset: UPDATE fin_repair_log SET action_taken='PENDING_REVIEW', repair_strategy=NULL WHERE repaired_by='SYSTEM_REPAIR_E6_FIX';
SELECT 'WARNING: Data repair rollback requires manual intervention' AS notice;
