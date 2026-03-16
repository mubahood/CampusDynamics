-- H1: Daily balance verification scheduled event
-- Runs every day at 01:00 to check all posted vouchers for DR = CR.
-- Logs violations to acc_activity_log.
-- Requires MySQL Event Scheduler enabled: SET GLOBAL event_scheduler = ON;

DELIMITER $

DROP EVENT IF EXISTS `evt_daily_balance_check` $

CREATE EVENT `evt_daily_balance_check`
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURDATE(), '01:00:00'))
COMMENT 'Daily double-entry balance verification: logs any DR≠CR violations to acc_activity_log'
DO
BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- Count unbalanced posted vouchers (DR ≠ CR)
    SELECT COUNT(*) INTO v_count
    FROM (
        SELECT voucherNo,
               SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) AS total_dr,
               SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS total_cr
        FROM fin_ledger l
        JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
        WHERE j.PostStatus = 'Posted'
        GROUP BY voucherNo
        HAVING ABS(total_dr - total_cr) > 0.005
    ) unbalanced;

    -- Always log the run result
    INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
    VALUES (
        'SYSTEM_EVENT',
        'DAILY_BALANCE_CHECK',
        CONCAT('unbalanced_count=', v_count),
        CASE
            WHEN v_count = 0 THEN 'All posted vouchers are balanced. OK.'
            ELSE CONCAT('WARNING: ', v_count, ' posted voucher(s) have DR ≠ CR imbalance.')
        END,
        NOW()
    );

    -- If there are violations, log each one individually for easy repair
    IF v_count > 0 THEN
        INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
        SELECT
            'SYSTEM_EVENT',
            'BALANCE_VIOLATION',
            CONCAT('voucherNo=', sub.voucherNo),
            CONCAT('DR=', sub.total_dr, ', CR=', sub.total_cr,
                   ', diff=', ABS(sub.total_dr - sub.total_cr)),
            NOW()
        FROM (
            SELECT voucherNo,
                   SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) AS total_dr,
                   SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS total_cr
            FROM fin_ledger l
            JOIN fin_journalnumbers j ON j.JournalNo = l.voucherNo
            WHERE j.PostStatus = 'Posted'
            GROUP BY voucherNo
            HAVING ABS(total_dr - total_cr) > 0.005
        ) sub;
    END IF;
END $

DELIMITER ;
