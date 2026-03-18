-- Step-by-step E5/E6 fix (no CONTINUE HANDLER to mask errors)
-- STEP 1: Re-categorize with CORRECT JOIN (GL_VoucherNo not JournalNo)

UPDATE fin_repair_log rl
JOIN (
    SELECT
        l.voucherNo,
        MAX(j.journalType) AS journalType,
        MAX(j.voucherType) AS voucherType,
        MAX(j.PostStatus)  AS PostStatus,
        COUNT(*)                                                                       AS line_count,
        SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END)  AS dr_total,
        SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END)  AS cr_total,
        SUM(CASE WHEN l.transactionType = 'DR' THEN 1 ELSE 0 END)                    AS dr_lines,
        SUM(CASE WHEN l.transactionType = 'CR' THEN 1 ELSE 0 END)                    AS cr_lines
    FROM fin_ledger l
    LEFT JOIN fin_journalnumbers j ON j.GL_VoucherNo = l.voucherNo
    GROUP BY l.voucherNo
    HAVING ABS(dr_total - cr_total) > 0.005
) sub ON sub.voucherNo = rl.voucherNo
SET
    rl.repair_strategy = CASE
        WHEN sub.line_count = 1
            THEN 'VOID_INCOMPLETE'
        WHEN sub.PostStatus = 'Pending' AND sub.journalType IS NOT NULL
            THEN 'VOID_INCOMPLETE'
        WHEN sub.dr_lines = 0
            THEN 'INSERT_OFFSETTING_DR'
        WHEN sub.cr_lines = 0
            THEN 'INSERT_OFFSETTING_CR'
        WHEN sub.journalType IN ('Receipt') AND sub.voucherType LIKE '%Student%'
            THEN 'MANUAL_REVIEW_STUDENT_RECEIPT'
        ELSE 'INSERT_CORRECTIVE_ENTRY'
    END,
    rl.repair_notes = CONCAT(
        'lines=', sub.line_count,
        ', dr_lines=', sub.dr_lines,
        ', cr_lines=', sub.cr_lines,
        ', dr=', ROUND(sub.dr_total, 0),
        ', cr=', ROUND(sub.cr_total, 0),
        ', type=', COALESCE(sub.journalType, 'ORPHAN'),
        ', subtype=', COALESCE(sub.voucherType, 'ORPHAN'),
        ', status=', COALESCE(sub.PostStatus, 'NONE')
    )
WHERE rl.action_taken = 'PENDING_REVIEW';

-- STEP 2: Handle orphans (no journal match)
UPDATE fin_repair_log rl
SET rl.repair_strategy = CASE
        WHEN rl.original_dr = 0 OR rl.original_cr = 0 THEN 'VOID_INCOMPLETE'
        ELSE 'INSERT_CORRECTIVE_ENTRY'
    END,
    rl.repair_notes = CONCAT(
        'ORPHAN: no journal match, dr=', ROUND(rl.original_dr, 0),
        ', cr=', ROUND(rl.original_cr, 0)
    )
WHERE rl.action_taken = 'PENDING_REVIEW'
  AND rl.repair_strategy IS NULL;

-- Show categorization results
SELECT repair_strategy, COUNT(*) cnt
FROM fin_repair_log
WHERE action_taken = 'PENDING_REVIEW'
GROUP BY repair_strategy
ORDER BY cnt DESC;
