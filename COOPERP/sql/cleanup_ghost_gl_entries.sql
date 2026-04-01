-- =============================================================================
-- Cleanup: Remove orphaned GL entries & fix missing manual-transaction entries
-- Database:   campus_dynamics_accounts
--
-- Background:
--   Prior to the 2026 dual-write fix, FeesTransactions.aspx only wrote to
--   fin_studentfeestracking.  The student portal reads fin_ledger via the
--   fin_GetStudentLedger stored procedure.
--
--   Two categories of inconsistency therefore exist:
--
--   A) GHOST GL ROWS — Entries that are in fin_ledger for transactions that an
--      admin deliberately deleted from fin_studentfeestracking via the admin
--      panel.  The delete code previously removed the tracking row but NOT the
--      matching GL row.  These ghost rows make deleted transactions still visible
--      to students on the portal.
--
--   B) MISSING GL ROWS — Manual transactions that were INSERTED through
--      FeesTransactions.aspx (fin_studentfeestracking) but never mirrored to
--      fin_ledger, so they don't appear on the student portal at all.
--
--   C) WRONG ACCOUNT_TYPE — AUTO billing SPs sometimes write fin_ledger rows
--      with account_type != 'Student', so fin_GetStudentLedger (which filters
--      on account_type) silently skips them.
--
-- Run order: standalone — no prerequisites.
-- Safe to run multiple times — all statements use guards.
-- =============================================================================

USE campus_dynamics_accounts;

-- ─────────────────────────────────────────────────────────────────────────────
-- DIAGNOSTIC — Run these first to see what is wrong before making changes
-- ─────────────────────────────────────────────────────────────────────────────

-- D1: All fin_ledger account_types in use (to spot what the AUTO billing SP writes)
SELECT DISTINCT account_type, COUNT(*) AS cnt
FROM fin_ledger
GROUP BY account_type
ORDER BY cnt DESC;

-- D2: All fin_ledger rows for MRU2025004200 including account_type
SELECT
    fl.TID,
    fl.voucherNo,
    fl.transactionDate,
    fl.transactionType,
    fl.transaction_amount,
    fl.particulars,
    fl.account_type
FROM fin_ledger fl
WHERE fl.accountcode = 'MRU2025004200'
ORDER BY fl.transactionDate ASC, fl.TID ASC;

-- D3: Posted manual transactions that are MISSING from fin_ledger entirely
--     (i.e. no fin_ledger row at all for this student + amount + date + direction)
SELECT
    fst.TID,
    fst.regno,
    fst.trans_type,
    fst.amount,
    fst.detail,
    fst.trans_date,
    fst.acadyear,
    fst.semester
FROM fin_studentfeestracking fst
WHERE fst.post_status = 'Posted'
  AND NOT EXISTS (
      SELECT 1 FROM fin_ledger fl
      WHERE fl.accountcode = fst.regno
        AND fl.transaction_amount = fst.amount
        AND DATE(fl.transactionDate) = DATE(fst.trans_date)
        AND fl.transactionType = CASE WHEN fst.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
  )
ORDER BY fst.regno, fst.trans_date DESC;

-- D4: fin_ledger rows for MRU2025004200 that are DR (bills) but have wrong account_type
--     (the portal SP filters account_type = 'Student' — anything else is invisible)
SELECT
    fl.TID, fl.transactionType, fl.transaction_amount, fl.particulars,
    fl.account_type AS current_account_type, fl.transactionDate
FROM fin_ledger fl
WHERE fl.accountcode = 'MRU2025004200'
  AND fl.transactionType = 'DR'
  AND fl.account_type != 'Student'
ORDER BY fl.transactionDate;


-- =============================================================================
-- ACTUAL FIXES — Run only after reviewing diagnostics above
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- FIX A: Remove ghost GL entries — fin_ledger rows for transactions that were
--         deliberately deleted from fin_studentfeestracking by an admin.
-- ─────────────────────────────────────────────────────────────────────────────
DELETE fl
FROM fin_ledger fl
WHERE fl.account_type = 'Student'
  AND EXISTS (
      SELECT 1
      FROM fin_changed_deleted_transactions fcd
      WHERE fcd.original_tid = fl.voucherNo
        AND fcd.action_type  = 'DELETE'
  )
  AND fl.voucherNo NOT IN (
      SELECT TID FROM fin_studentfeestracking
  );

SELECT ROW_COUNT() AS ghost_gl_rows_deleted;


-- ─────────────────────────────────────────────────────────────────────────────
-- FIX B: Back-fill missing GL entries for Posted manual transactions.
--
-- Uses content-based duplicate detection (regno + amount + date + direction)
-- so it is safe even when the billing SP wrote a GL row with a different
-- voucherNo than the fin_studentfeestracking TID.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO fin_ledger
    (accountcode, account_type, transactionType, transaction_amount, particulars,
     voucherNo, transactionDate, teller, timeLog, folio,
     journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
SELECT
    fst.regno,
    'Student',
    CASE WHEN fst.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END,
    fst.amount,
    IFNULL(fst.detail, CONCAT(fst.trans_type, ' — TID ', fst.TID)),
    fst.TID,
    fst.trans_date,
    'System (GL Sync)',
    NOW(),
    fst.regno,
    '-',
    'UGX',
    fst.amount,
    0,
    1,
    fst.amount
FROM fin_studentfeestracking fst
WHERE fst.post_status = 'Posted'
  AND NOT EXISTS (
      -- Content-based match: same student, amount, date, and direction
      -- This prevents duplicates even when voucherNo differs from TID
      SELECT 1 FROM fin_ledger fl
      WHERE fl.accountcode          = fst.regno
        AND fl.transaction_amount   = fst.amount
        AND DATE(fl.transactionDate)= DATE(fst.trans_date)
        AND fl.transactionType      = CASE WHEN fst.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
        AND (fl.particulars = fst.detail OR fl.voucherNo = fst.TID)
  );

SELECT ROW_COUNT() AS missing_gl_rows_inserted;


-- ─────────────────────────────────────────────────────────────────────────────
-- FIX C: Normalize account_type for student fin_ledger rows.
--
-- AUTO billing SPs sometimes write with account_type != 'Student'.
-- fin_GetStudentLedger filters on account_type so these rows are invisible
-- on the student portal even though they are in fin_ledger.
--
-- Safe: only touches rows WHERE accountcode matches a valid student regno
-- AND account_type is not already 'Student' AND not 'Chart Account'
-- (Chart Account rows belong to the income side of double-entry — never touch).
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE fin_ledger fl
INNER JOIN campus_dynamics.acad_student s ON s.regno = fl.accountcode
SET fl.account_type = 'Student'
WHERE fl.account_type NOT IN ('Student', 'Chart Account')
  AND fl.accountcode = fl.folio;  -- folio=accountcode pattern identifies the student-side GL row

SELECT ROW_COUNT() AS account_type_rows_normalised;

-- Fallback: also catch any remaining student-side rows where folio may differ
-- (Airtel/MTN API and newer billing SPs omit the folio=accountcode pattern)
UPDATE fin_ledger fl
INNER JOIN campus_dynamics.acad_student s ON s.regno = fl.accountcode
SET fl.account_type = 'Student'
WHERE fl.account_type NOT IN ('Student', 'Chart Account');

SELECT ROW_COUNT() AS account_type_rows_normalised_fallback;


-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICATION — Check MRU2025004200 full ledger after all fixes
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    fl.TID,
    fl.voucherNo,
    fl.transactionDate,
    fl.transactionType AS type,
    fl.transaction_amount AS amount,
    fl.particulars,
    fl.account_type
FROM fin_ledger fl
WHERE fl.accountcode = 'MRU2025004200'
ORDER BY fl.transactionDate ASC, fl.TID ASC;

-- Summary: what the portal SP should now compute
SELECT
    SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END) AS total_billed,
    SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END) AS total_paid,
    SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END)
  - SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END) AS balance_owed
FROM fin_ledger
WHERE accountcode  = 'MRU2025004200'
  AND account_type = 'Student';
