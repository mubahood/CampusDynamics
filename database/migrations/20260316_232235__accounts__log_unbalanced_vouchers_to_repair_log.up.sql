-- Migration: log_unbalanced_vouchers_to_repair_log
-- Logical database: accounts
-- Generated: 2026-03-16T23:22:35
-- E1: Log all unbalanced vouchers to fin_repair_log
--
-- Inserts one row per unbalanced voucher (DR != CR) into fin_repair_log
-- with status PENDING_REVIEW. This creates a complete audit register of
-- all 2,906 problematic vouchers before any repair is attempted.
--
-- Idempotent: does not insert vouchers already logged with repair_type
-- 'UNBALANCED_VOUCHER', so safe to re-run.
--
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- E1: Insert unbalanced vouchers into fin_repair_log
-- Join with fin_journalnumbers to capture journal_no where available
INSERT INTO fin_repair_log
    (repair_type, voucherNo, journal_no, original_dr, original_cr, difference, action_taken, repaired_by, repair_notes, repair_date)
SELECT
    'UNBALANCED_VOUCHER' AS repair_type,
    l.voucherNo,
    j.JournalNo AS journal_no,
    SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END) AS original_dr,
    SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END) AS original_cr,
    ABS(
        SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END) -
        SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END)
    ) AS difference,
    'PENDING_REVIEW' AS action_taken,
    'system_audit_2026' AS repaired_by,
    CONCAT(
        'Detected during 2026 audit. ',
        'JournalType: ', IFNULL(j.journalType, 'N/A'), '. ',
        'VoucherType: ', IFNULL(j.voucherType, 'N/A'), '. ',
        'PostStatus: ', IFNULL(j.PostStatus, 'N/A')
    ) AS repair_notes,
    NOW() AS repair_date
FROM fin_ledger l
LEFT JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
GROUP BY l.voucherNo, j.JournalNo, j.journalType, j.voucherType, j.PostStatus
HAVING ABS(
    SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END) -
    SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END)
) > 0
AND l.voucherNo NOT IN (
    SELECT voucherNo FROM fin_repair_log
    WHERE repair_type = 'UNBALANCED_VOUCHER'
    AND voucherNo IS NOT NULL
);
