-- Diagnostic queries for accounting module
-- Query 5: Orphan ledger entries
SELECT 'ORPHAN_LEDGER_NO_JOURNAL' AS issue, COUNT(*) AS cnt FROM fin_ledger l WHERE NOT EXISTS (SELECT 1 FROM fin_journalnumbers j WHERE j.JournalNo = l.voucherNo);
-- Query 6: Journals no ledger
SELECT 'JOURNALS_NO_LEDGER' AS issue, COUNT(*) AS cnt FROM fin_journalnumbers j WHERE NOT EXISTS (SELECT 1 FROM fin_ledger l WHERE l.voucherNo = j.JournalNo);
-- Query 7: Bad accountcodes
SELECT 'NULL_EMPTY_ACCOUNTCODE' AS issue, COUNT(*) AS cnt FROM fin_ledger WHERE accountcode IS NULL OR accountcode = '' OR accountcode = '-';
-- Query 8: Transaction types
SELECT 'TXN_TYPE' AS issue, transactionType, COUNT(*) AS cnt FROM fin_ledger GROUP BY transactionType;
-- Query 9: Zero amounts
SELECT 'ZERO_AMOUNT' AS issue, COUNT(*) AS cnt FROM fin_ledger WHERE transaction_amount = 0;
-- Query 10: Future dated
SELECT 'FUTURE_DATED' AS issue, COUNT(*) AS cnt FROM fin_ledger WHERE transactionDate > CURDATE();
-- Query 11: curr_balance problems
SELECT 'CURR_BAL_ZERO' AS issue, COUNT(*) AS cnt FROM fin_ledger WHERE curr_balance = '0' OR curr_balance = '-' OR curr_balance = '' OR curr_balance IS NULL;
-- Query 12: Accountcodes not in fin_subaccounts
SELECT 'ORPHAN_ACCOUNTCODES' AS issue, COUNT(*) AS cnt FROM fin_ledger l WHERE NOT EXISTS (SELECT 1 FROM fin_subaccounts s WHERE s.AccountCode = l.accountcode);
-- Query 13: Missing indexes
SELECT 'INDEXES_ON_LEDGER' AS issue, INDEX_NAME, COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_ledger';
-- Query 14: fin_subaccounts schema
DESCRIBE fin_subaccounts;
-- Query 15: Financial years
SELECT * FROM fin_financial_years;
-- Query 16: Financial periods
SELECT * FROM fin_financial_periods;
-- Query 17: Main accounts
SELECT * FROM fin_mainaccounts;
-- Query 18: Ledger date distribution
SELECT YEAR(transactionDate) AS yr, COUNT(*) AS cnt, SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END) AS total_dr, SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END) AS total_cr FROM fin_ledger GROUP BY YEAR(transactionDate) ORDER BY yr;
-- Query 19: Deleted ledger count
SELECT 'DELETED_LEDGER' AS tbl, COUNT(*) AS cnt FROM fin_deleted_ledger;
-- Query 20: edit_ledger count
SELECT 'EDIT_LEDGER' AS tbl, COUNT(*) AS cnt FROM edit_ledger;
