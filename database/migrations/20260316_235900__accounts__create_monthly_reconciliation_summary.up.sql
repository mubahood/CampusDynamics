-- H2: Monthly reconciliation summary stored procedure
-- Generates DR/CR totals per main account category for a given month.
-- Usage: CALL fin_MonthlyReconciliation('2026', '03');

DELIMITER $

DROP PROCEDURE IF EXISTS `fin_MonthlyReconciliation` $

CREATE PROCEDURE `fin_MonthlyReconciliation`(
    IN p_year  CHAR(4),
    IN p_month CHAR(2)
)
BEGIN
    -- Summary by main account category
    SELECT
        COALESCE(m.AccountName, 'Unknown')       AS account_category,
        s.AccountCode                             AS sub_account,
        s.AccountName                             AS sub_account_name,
        SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END) AS total_dr,
        SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END) AS total_cr,
        SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END)
        - SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END) AS net_balance,
        COUNT(DISTINCT l.voucherNo)               AS voucher_count,
        COUNT(*)                                   AS line_count
    FROM fin_ledger l
    JOIN fin_journalnumbers j  ON j.JournalNo = l.voucherNo
    LEFT JOIN fin_subaccounts s ON s.AccountCode = l.accountcode
    LEFT JOIN fin_mainaccounts m ON m.AccountCode = s.MainAccountCode
    WHERE j.PostStatus = 'Posted'
      AND YEAR(l.transactionDate)  = p_year
      AND MONTH(l.transactionDate) = p_month
    GROUP BY m.AccountName, s.AccountCode, s.AccountName
    ORDER BY m.AccountName, s.AccountCode;
END $

DELIMITER ;
