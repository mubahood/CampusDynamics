@echo off
set MYSQL="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"
set CONN=-h 102.34.160.47 -u dbmanager -p24thdecember1977 --default-character-set=latin1 campus_dynamics_accounts
set OUT=E:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\diag_output.txt

echo === Q1: transactionType distribution === > "%OUT%"
%MYSQL% %CONN% -e "SELECT transactionType, COUNT(*) AS cnt FROM fin_ledger GROUP BY transactionType;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q2: BAD_ACCTCODE === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'BAD_ACCTCODE' AS i, COUNT(*) AS c FROM fin_ledger WHERE accountcode IS NULL OR accountcode = '' OR accountcode = '-';" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q3: ZERO_AMT === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'ZERO_AMT' AS i, COUNT(*) AS c FROM fin_ledger WHERE transaction_amount = 0;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q4: BAD_CURR_BAL === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'BAD_CURR_BAL' AS i, COUNT(*) AS c FROM fin_ledger WHERE curr_balance = '0' OR curr_balance = '-' OR curr_balance = '' OR curr_balance IS NULL;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q5: fin_financial_years === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT * FROM fin_financial_years;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q6: fin_mainaccounts === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT * FROM fin_mainaccounts;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q7: Ledger entries by year === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT YEAR(transactionDate) AS yr, COUNT(*) AS cnt FROM fin_ledger GROUP BY YEAR(transactionDate) ORDER BY yr;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q8: DELETED ledger count === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'DELETED' AS tbl, COUNT(*) FROM fin_deleted_ledger;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q9: fin_ledger indexes === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT INDEX_NAME, COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_ledger';" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q10: DESCRIBE fin_subaccounts === >> "%OUT%"
%MYSQL% %CONN% -e "DESCRIBE fin_subaccounts;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q11: JOURNALS_NO_LEDGER === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'JOURNALS_NO_LEDGER' AS i, COUNT(*) AS c FROM fin_journalnumbers j LEFT JOIN fin_ledger l ON l.voucherNo = j.JournalNo WHERE l.TID IS NULL;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q12: PostStatus distribution === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT PostStatus, COUNT(*) AS cnt FROM fin_journalnumbers GROUP BY PostStatus;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q13: account_type distribution === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT account_type, COUNT(*) AS cnt FROM fin_ledger GROUP BY account_type;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q14: DUP_VOUCHER_JNO === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'DUP_VOUCHER_JNO' AS i, COUNT(*) AS c FROM (SELECT voucherNo, COUNT(DISTINCT journal_no) AS jcnt FROM fin_ledger GROUP BY voucherNo HAVING jcnt > 1) t;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q15: MISSING_FK_SUBACCT === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'MISSING_FK_SUBACCT' AS i, COUNT(DISTINCT l.accountcode) AS c FROM fin_ledger l LEFT JOIN fin_subaccounts s ON s.AccountCode = l.accountcode WHERE s.AccountCode IS NULL;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q16: trans_currency distribution === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT trans_currency, COUNT(*) AS cnt FROM fin_ledger GROUP BY trans_currency;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Q17: NEG_AMOUNT === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT 'NEG_AMOUNT' AS i, COUNT(*) AS c FROM fin_ledger WHERE CAST(transaction_amount AS SIGNED) < 0;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === ALL DONE === >> "%OUT%"
