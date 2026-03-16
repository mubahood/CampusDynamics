-- Rollback E2: Remove the offsetting repair entries inserted by the up migration.
-- This removes ONLY the entries flagged as E2 repairs (teller = 'SYSTEM_REPAIR_E2').

DELETE FROM fin_ledger
WHERE teller = 'SYSTEM_REPAIR_E2'
  AND particulars LIKE 'E2 repair:%'
  AND voucherNo IN (60407, 60408, 60411);

-- Reset repair_log status
UPDATE fin_repair_log
SET action_taken = 'PENDING_REVIEW',
    repaired_by  = NULL,
    repair_date  = NULL,
    notes        = NULL
WHERE voucherNo IN (60407, 60408, 60411)
  AND repair_type = 'UNBALANCED_VOUCHER'
  AND repaired_by = 'SYSTEM_REPAIR_E2';
