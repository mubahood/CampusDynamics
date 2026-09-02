-- ============================================================================
--  Duplicate payment captures — 33 students, UGX 19,012,500 of phantom credit
--  Muteesa I Royal University                                     2026-09-02
--
--  REPORTED AS: RESTA NAMUDIRA (MRU2026005804) showing UGX 828,000 paid against
--  UGX 414,000 billed, a credit balance of -414,000, with the SAME Airtel Money
--  transaction (TNo 61615844) listed twice on her statement.
--
--  WHAT ACTUALLY HAPPENED
--
--  SchoolPay delivered the payment ONCE. fin_schoolpaydata holds exactly one row
--  for receipt 61615844, and across the whole raw capture table there is not a
--  single duplicated (regno, amount, ReceiptNo) group. The money is right.
--
--  fin_ledger is also right: one CR of 414,000, folio TransCode:61615844.
--
--  The duplication is in fin_studentfeestracking, which holds TWO rows for that
--  one payment — TID 120032 captured 02/08 05:03:59 and TID 121074 captured again
--  07/08 08:50:01. Same student, same amount, same detail, same TNo. The capture
--  step turned one raw receipt into two tracking rows, because nothing there
--  enforces uniqueness on (regno, ReceiptNo).
--
--  WHY THE SCREEN SHOWS IT TWICE
--
--  FinanceEngine.DUAL_LEDGER_SQL combines fin_ledger with fin_studentfeestracking
--  and drops a tracking row when a ledger row matches it by voucherNo, by
--  folio 'BillNo:<TID>', or by same amount AND SAME DATE and matching type.
--
--  The match is on the DATE. The surviving duplicate was captured on a different
--  day from the ledger posting, so it matches none of the three tests and is
--  counted as a second payment. That is the whole bug: the dedupe cannot see that
--  two rows are the same payment because it never compares the transaction number.
--
--  SCALE: 33 groups, 33 surplus rows, 33 students, UGX 19,012,500. Most were
--  created in one re-capture on 2026-08-07 between 08:49 and 08:50, against
--  originals from 31 July to 5 August; four more are second-apart pairs from
--  07:23 the same morning; two are older (2024 and 2026-02).
--
--  WHICH ROW IS REMOVED, AND WHY IT IS NOT SIMPLY "THE LATER ONE"
--
--  The row kept is the one whose trans_date matches the ledger posting's timeLog;
--  the other goes. That is NOT always the later capture — the ledger matches the
--  later row for 29 groups and the EARLIER row for 4. Deleting "the newer one"
--  would have removed the posted row for those four and left the orphan behind.
--
--  The 33 TIDs below were derived from that ledger match, not by hand.
--
--  NOT CHANGED: fin_ledger and fin_schoolpaydata are untouched. No money moves.
--  Only the duplicate bookkeeping row is withdrawn, so the balance stops
--  double-counting a payment that happened once.
-- ============================================================================

-- ── 1. backup ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902
  LIKE campus_dynamics_accounts.fin_studentfeestracking;

INSERT INTO campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902
SELECT * FROM campus_dynamics_accounts.fin_studentfeestracking
WHERE TID IN (6086,7237,119979,119998,120003,120018,120030,120032,120034,120067,
              120071,120077,120078,120092,120109,120130,120147,120169,120176,120179,
              120189,120237,120240,120244,120265,120269,120303,120319,120380,120833,
              120837,120840,120848);

SELECT CONCAT('backed up: ', COUNT(*), ' rows, UGX ', FORMAT(SUM(amount),0)) AS backup
FROM campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902;

-- ── 2. before ───────────────────────────────────────────────────────────────
SELECT 'BEFORE' stage,
       COUNT(*) payment_rows, FORMAT(SUM(amount),0) total
FROM campus_dynamics_accounts.fin_studentfeestracking
WHERE trans_type='Payment' AND regno IN (
  SELECT regno FROM campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902);

-- ── 3. withdraw the duplicates ──────────────────────────────────────────────
--  Keyed on the exact TIDs and re-asserting trans_type, so this cannot touch a
--  bill and is safe to run twice.
DELETE FROM campus_dynamics_accounts.fin_studentfeestracking
WHERE trans_type = 'Payment'
  AND TID IN (6086,7237,119979,119998,120003,120018,120030,120032,120034,120067,
              120071,120077,120078,120092,120109,120130,120147,120169,120176,120179,
              120189,120237,120240,120244,120265,120269,120303,120319,120380,120833,
              120837,120840,120848);

SELECT CONCAT('withdrawn: ', ROW_COUNT(), ' duplicate rows') AS result;

-- ── 4. checks ───────────────────────────────────────────────────────────────
-- No payment should now be captured twice anywhere in the table.
SELECT CONCAT('duplicate payment groups remaining: ', COUNT(*)) AS check_dups FROM (
  SELECT regno FROM campus_dynamics_accounts.fin_studentfeestracking
  WHERE trans_type='Payment' AND detail LIKE '%TNo:%'
  GROUP BY regno, amount, detail HAVING COUNT(*) > 1
) d;

-- Every kept row must still have its ledger posting.
SELECT CONCAT('kept rows still matched to the ledger: ', COUNT(*)) AS check_kept
FROM campus_dynamics_accounts.fin_studentfeestracking t
JOIN campus_dynamics_accounts.fin_ledger l
  ON l.accountcode = t.regno AND l.transactionType = 'CR'
 AND l.transaction_amount = t.amount AND l.timeLog = t.trans_date
WHERE t.trans_type = 'Payment'
  AND t.regno IN (SELECT regno FROM campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902);

-- The ledger itself must be untouched.
SELECT CONCAT('ledger CR rows for these students: ', COUNT(*)) AS check_ledger
FROM campus_dynamics_accounts.fin_ledger
WHERE transactionType='CR'
  AND accountcode IN (SELECT regno FROM campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902);

-- ── 5. the reported student ─────────────────────────────────────────────────
SELECT 'MRU2026005804' AS student,
       FORMAT(SUM(CASE WHEN trans_type='Bill'    THEN amount ELSE 0 END),0) AS billed,
       FORMAT(SUM(CASE WHEN trans_type='Payment' THEN amount ELSE 0 END),0) AS paid
FROM campus_dynamics_accounts.fin_studentfeestracking
WHERE regno='MRU2026005804' AND post_status='Posted';

-- ============================================================================
--  ROLLBACK — puts every withdrawn row back exactly as it was.
--
--    INSERT INTO campus_dynamics_accounts.fin_studentfeestracking
--    SELECT * FROM campus_dynamics_accounts.fin_studentfeestracking_bak_dupcapture_20260902;
--
--  STILL OPEN, and deliberately not changed here — both need a decision:
--
--    1. PREVENTION. The capture step has no uniqueness guard, so the same raw
--       receipt can become a tracking row twice. A unique key on
--       (regno, trans_type, detail) for payments, or a NOT EXISTS check on the
--       transaction number before insert, would stop this recurring. Adding it
--       touches the live money path, so it is proposed rather than applied.
--
--    2. THE DEDUPE. FinanceEngine matches tracking to ledger by amount and DATE.
--       Matching on the transaction number as well — fin_ledger.folio holds
--       'TransCode:<TNo>' and the tracking detail ends '...TNo: <TNo>' — would
--       collapse a duplicate whatever day it was captured. That clause can only
--       ever exclude MORE tracking rows, never include more, so balances can only
--       move toward the ledger; but it changes every student's balance
--       calculation and should be reviewed before it goes in.
-- ============================================================================
