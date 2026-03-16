-- Rollback E5: Clear the repair_strategy and notes fields set during categorization.
UPDATE fin_repair_log
SET repair_strategy = NULL,
    notes          = NULL
WHERE repair_strategy IS NOT NULL
  AND action_taken = 'PENDING_REVIEW';
