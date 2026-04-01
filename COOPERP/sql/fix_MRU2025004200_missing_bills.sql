-- =============================================================================
-- Fix: MRU2025004200 (ISAAC GANAZIKWA) — Missing GL entries for Sem 2 billing
--
-- Problem:  The student's portal dashboard shows Total Billed = 0 because
--           fin_studentfeestracking has billing records (items 1 & 52) but
--           fin_ledger has NO corresponding DR entries.
--           The stored procedure fin_GetStudentLedger reads fin_ledger,
--           so the portal sees zero debits.
--
-- Root cause: fin_TermlyItemBillingFN wrote to fin_studentfeestracking but the
--             fin_TransactionCreatorFn2 call (which posts to fin_ledger) either
--             failed silently or the GL rows were lost.
--
-- Strategy: Insert the missing DR entries into fin_ledger to match what is
--           already in fin_studentfeestracking. Use the existing voucher numbers
--           from fin_studentfeestracking so everything ties together.
--
-- Safe to run multiple times — WHERE NOT EXISTS guards prevent duplicates.
-- =============================================================================

-- ─── STEP 0: DIAGNOSTIC — Run this first to see current state ────────────────

-- 0a) What's in fin_studentfeestracking for this student?
SELECT 'fin_studentfeestracking' AS source,
       TID, item_code, trans_type, Amount, semester, acadyear,
       post_status, voucherNo, trans_date, detail
FROM campus_dynamics_accounts.fin_studentfeestracking
WHERE regno = 'MRU2025004200'
ORDER BY trans_date, TID;

-- 0b) What's currently in fin_ledger for this student?
SELECT 'fin_ledger' AS source,
       TID, accountcode, account_type, transactionType,
       transaction_amount, voucherNo, particulars,
       transactionDate, teller
FROM campus_dynamics_accounts.fin_ledger
WHERE accountcode = 'MRU2025004200'
ORDER BY transactionDate, TID;

-- 0c) What does the stored procedure return?
CALL campus_dynamics_accounts.fin_GetStudentLedger('MRU2025004200');


-- ─── STEP 1: Post missing BILL DR entries from tracking → ledger ─────────────
-- For each Bill row in fin_studentfeestracking that has no matching DR in
-- fin_ledger, insert the DR entry.

INSERT INTO campus_dynamics_accounts.fin_ledger
    (accountcode, account_type, transactionType, transaction_amount,
     particulars, voucherNo, transactionDate, teller, timeLog,
     folio, journal_no, trans_currency, actual_amount,
     curr_balance, forex_rate, ugx_amount)
SELECT
    'MRU2025004200',                    -- accountcode
    'Student',                          -- account_type
    'DR',                               -- transactionType (Bill = Debit)
    fst.Amount,                         -- transaction_amount
    fst.detail,                         -- particulars (from tracking detail)
    fst.voucherNo,                      -- voucherNo (same as tracking)
    fst.trans_date,                     -- transactionDate
    'System',                           -- teller
    NOW(),                              -- timeLog
    'MRU2025004200',                    -- folio
    CONCAT('BillNo:', fst.TID),         -- journal_no
    'UGX',                              -- trans_currency
    fst.Amount,                         -- actual_amount
    0,                                  -- curr_balance (will be recalculated)
    1,                                  -- forex_rate
    fst.Amount                          -- ugx_amount
FROM campus_dynamics_accounts.fin_studentfeestracking fst
WHERE fst.regno = 'MRU2025004200'
  AND fst.trans_type = 'Bill'
  AND fst.Amount > 0
  AND NOT EXISTS (
      SELECT 1
      FROM campus_dynamics_accounts.fin_ledger fl
      WHERE fl.accountcode = 'MRU2025004200'
        AND fl.account_type = 'Student'
        AND fl.transactionType = 'DR'
        AND fl.voucherNo = fst.voucherNo
  );


-- ─── STEP 2: Verify the TID 98002 CR entry also exists ──────────────────────
-- (This was inserted by the previous fix script. If it's missing, re-insert.)

INSERT INTO campus_dynamics_accounts.fin_ledger
    (accountcode, account_type, transactionType, transaction_amount,
     particulars, voucherNo, transactionDate, teller, timeLog,
     folio, journal_no, trans_currency, actual_amount,
     curr_balance, forex_rate, ugx_amount)
SELECT
    'MRU2025004200', 'Student', 'CR', 1197000,
    'Student did not study first semester but was billed.',
    98002, '2026-03-30', 'System', NOW(), 'MRU2025004200',
    '-', 'UGX', 1197000, 0, 1, 1197000
WHERE NOT EXISTS (
    SELECT 1
    FROM campus_dynamics_accounts.fin_ledger
    WHERE voucherNo = 98002
      AND accountcode = 'MRU2025004200'
      AND account_type = 'Student'
);


-- ─── STEP 3: Recalculate running balances ────────────────────────────────────
-- The fin_UpdateAllLedgerBalances SP recalculates curr_balance for all rows.
-- If it's too slow for all students, we can do it manually for just this one.

-- Option A: Call the SP (preferred if it exists and is fast)
-- CALL campus_dynamics_accounts.fin_UpdateAllLedgerBalances();

-- Option B: Manual recalc for just this student
SET @running := 0;
UPDATE campus_dynamics_accounts.fin_ledger fl
JOIN (
    SELECT TID,
           (@running := @running
               + CASE WHEN transactionType = 'DR' THEN transaction_amount
                       WHEN transactionType = 'CR' THEN -transaction_amount
                       ELSE 0 END
           ) AS new_balance
    FROM campus_dynamics_accounts.fin_ledger,
         (SELECT @running := 0) init
    WHERE accountcode = 'MRU2025004200'
      AND account_type = 'Student'
    ORDER BY transactionDate, TID
) calc ON fl.TID = calc.TID
SET fl.curr_balance = calc.new_balance
WHERE fl.accountcode = 'MRU2025004200'
  AND fl.account_type = 'Student';


-- ─── STEP 4: VERIFY — Check final state ─────────────────────────────────────

-- 4a) All fin_ledger rows for this student
SELECT TID, transactionDate, voucherNo, transactionType,
       transaction_amount, curr_balance, particulars, teller
FROM campus_dynamics_accounts.fin_ledger
WHERE accountcode = 'MRU2025004200'
  AND account_type = 'Student'
ORDER BY transactionDate, TID;

-- 4b) Summary totals (should match portal display after refresh)
SELECT
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) AS total_billed,
    SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS total_paid,
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END)
  - SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS outstanding
FROM campus_dynamics_accounts.fin_ledger
WHERE accountcode = 'MRU2025004200'
  AND account_type = 'Student';

-- 4c) Verify via stored procedure (same as portal uses)
CALL campus_dynamics_accounts.fin_GetStudentLedger('MRU2025004200');
