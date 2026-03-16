SELECT '--- Q1: transactionType distribution ---' AS '';
SELECT transactionType, COUNT(*) AS cnt FROM fin_ledger GROUP BY transactionType;

SELECT '--- Q2: BAD_ACCTCODE ---' AS '';
SELECT 'BAD_ACCTCODE' AS i, COUNT(*) AS c FROM fin_ledger WHERE accountcode IS NULL OR accountcode = '' OR accountcode = '-';

SELECT '--- Q3: ZERO_AMT ---' AS '';
SELECT 'ZERO_AMT' AS i, COUNT(*) AS c FROM fin_ledger WHERE transaction_amount = 0;

SELECT '--- Q4: BAD_CURR_BAL ---' AS '';
SELECT 'BAD_CURR_BAL' AS i, COUNT(*) AS c FROM fin_ledger WHERE curr_balance = '0' OR curr_balance = '-' OR curr_balance = '' OR curr_balance IS NULL;

SELECT '--- Q5: fin_financial_years ---' AS '';
SELECT * FROM fin_financial_years;

SELECT '--- Q6: fin_mainaccounts ---' AS '';
SELECT * FROM fin_mainaccounts;

SELECT '--- Q7: Ledger entries by year ---' AS '';
SELECT YEAR(transactionDate) AS yr, COUNT(*) AS cnt FROM fin_ledger GROUP BY YEAR(transactionDate) ORDER BY yr;

SELECT '--- Q8: DELETED ledger count ---' AS '';
SELECT 'DELETED' AS tbl, COUNT(*) FROM fin_deleted_ledger;

SELECT '--- Q9: fin_ledger indexes ---' AS '';
SELECT INDEX_NAME, COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_ledger';

SELECT '--- Q10: DESCRIBE fin_subaccounts ---' AS '';
DESCRIBE fin_subaccounts;

SELECT '--- Q11: JOURNALS_NO_LEDGER ---' AS '';
SELECT 'JOURNALS_NO_LEDGER' AS i, COUNT(*) AS c FROM fin_journalnumbers j LEFT JOIN fin_ledger l ON l.voucherNo = j.JournalNo WHERE l.TID IS NULL;

SELECT '--- Q12: PostStatus distribution ---' AS '';
SELECT PostStatus, COUNT(*) AS cnt FROM fin_journalnumbers GROUP BY PostStatus;

SELECT '--- Q13: account_type distribution ---' AS '';
SELECT account_type, COUNT(*) AS cnt FROM fin_ledger GROUP BY account_type;

SELECT '--- Q14: DUP_VOUCHER_JNO ---' AS '';
SELECT 'DUP_VOUCHER_JNO' AS i, COUNT(*) AS c FROM (SELECT voucherNo, COUNT(DISTINCT journal_no) AS jcnt FROM fin_ledger GROUP BY voucherNo HAVING jcnt > 1) t;

SELECT '--- Q15: MISSING_FK_SUBACCT ---' AS '';
SELECT 'MISSING_FK_SUBACCT' AS i, COUNT(DISTINCT l.accountcode) AS c FROM fin_ledger l LEFT JOIN fin_subaccounts s ON s.AccountCode = l.accountcode WHERE s.AccountCode IS NULL;

SELECT '--- Q16: trans_currency distribution ---' AS '';
SELECT trans_currency, COUNT(*) AS cnt FROM fin_ledger GROUP BY trans_currency;

SELECT '--- Q17: NEG_AMOUNT ---' AS '';
SELECT 'NEG_AMOUNT' AS i, COUNT(*) AS c FROM fin_ledger WHERE CAST(transaction_amount AS SIGNED) < 0;
