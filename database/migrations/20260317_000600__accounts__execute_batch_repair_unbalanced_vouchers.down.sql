-- Rollback E6: Remove all repair entries inserted by the batch repair.
-- Also un-voids journals that were voided by this migration.

-- Remove corrective ledger entries
DELETE FROM fin_ledger
WHERE teller = 'SYSTEM_REPAIR_E6'
  AND particulars LIKE 'E6 repair:%';

-- Un-void journals voided by E6
UPDATE fin_journalnumbers
SET PostStatus  = 'Pending',
    void_reason = NULL
WHERE void_reason = 'Auto-voided E6: single-line entry, no valid double-entry pair';

-- Reset repair_log status for E6-repaired entries
UPDATE fin_repair_log
SET action_taken = 'PENDING_REVIEW',
    repaired_by  = NULL,
    repair_date  = NULL
WHERE repaired_by = 'SYSTEM_REPAIR_E6';
