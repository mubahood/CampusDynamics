-- E5: Analyze and categorize remaining unbalanced vouchers
-- Adds repair_strategy column to fin_repair_log and classifies each pending entry.

DELIMITER $

DROP PROCEDURE IF EXISTS `_e5_categorize_unbalanced` $

CREATE PROCEDURE `_e5_categorize_unbalanced`()
BEGIN

    -- Add repair_strategy column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name   = 'fin_repair_log'
          AND column_name  = 'repair_strategy'
    ) THEN
        ALTER TABLE fin_repair_log ADD COLUMN repair_strategy VARCHAR(60) DEFAULT NULL;
    END IF;

    -- Classify each unbalanced voucher still PENDING_REVIEW
    UPDATE fin_repair_log rl
    JOIN (
        SELECT
            l.voucherNo,
            j.journalType,
            j.voucherType,
            COUNT(*)                                                                       AS line_count,
            SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END)  AS dr_total,
            SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END)  AS cr_total,
            SUM(CASE WHEN l.transactionType = 'DR' THEN 1 ELSE 0 END)                    AS dr_lines,
            SUM(CASE WHEN l.transactionType = 'CR' THEN 1 ELSE 0 END)                    AS cr_lines
        FROM fin_ledger l
        JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
        WHERE j.PostStatus IN ('Pending', 'Posted')
        GROUP BY l.voucherNo, j.journalType, j.voucherType
        HAVING ABS(dr_total - cr_total) > 0.005
    ) sub ON sub.voucherNo = rl.voucherNo
    SET
        rl.repair_strategy = CASE
            WHEN sub.line_count = 1
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
            ', type=', COALESCE(sub.journalType,'?'),
            ', subtype=', COALESCE(sub.voucherType,'?')
        )
    WHERE rl.action_taken = 'PENDING_REVIEW';

    -- Summary
    SELECT repair_strategy,
           COUNT(*)                             AS voucher_count,
           SUM(original_dr - original_cr)       AS total_imbalance_ugx
    FROM fin_repair_log
    WHERE action_taken = 'PENDING_REVIEW'
    GROUP BY repair_strategy
    ORDER BY voucher_count DESC;

END $

DELIMITER ;

CALL `_e5_categorize_unbalanced`();
DROP PROCEDURE IF EXISTS `_e5_categorize_unbalanced`;
