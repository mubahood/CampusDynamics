-- =============================================================================
-- Fix: Post TID 98002 to fin_ledger
-- Student:     MRU2025004200 (ISAAC GANAZIKWA)
-- Transaction: "Transfer of Campus" — Credit 1,197,000 (reversal of Sem 1 AUTO billing)
-- Problem:     This manual transaction was saved via FeesTransactions.aspx which
--              only wrote to fin_studentfeestracking. It was never mirrored to
--              fin_ledger, so the Student Ledger shows a 1,197,000 overage.
--
-- Safe to run multiple times — the WHERE NOT EXISTS guard prevents duplicates.
-- =============================================================================

INSERT INTO campus_dynamics_accounts.fin_ledger
    (accountcode, account_type, transactionType, transaction_amount, particulars,
     voucherNo, transactionDate, teller, timeLog, folio,
     journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
SELECT
    'MRU2025004200',
    'Student',
    'CR',
    1197000,
    'Student did not study first semester but was billed.',
    98002,
    '2026-03-30',
    'System',
    NOW(),
    'MRU2025004200',
    '-',
    'UGX',
    1197000,
    0,
    1,
    1197000
WHERE NOT EXISTS (
    SELECT 1 FROM campus_dynamics_accounts.fin_ledger
    WHERE voucherNo = 98002
      AND accountcode = 'MRU2025004200'
      AND account_type = 'Student'
);

-- Verify the result for this student
SELECT
    transactionDate,
    voucherNo,
    particulars,
    transactionType,
    transaction_amount,
    account_type
FROM campus_dynamics_accounts.fin_ledger
WHERE accountcode = 'MRU2025004200'
ORDER BY transactionDate, TID;
