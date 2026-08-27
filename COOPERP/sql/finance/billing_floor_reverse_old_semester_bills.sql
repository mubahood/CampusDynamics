-- ============================================================================
--  Reverse the historic-semester bills raised by student self-service
--  Muteesa I Royal University                                     2026-08-27
--
--  Companion to billing_floor_stop_old_semester_autobilling.sql, which stopped
--  the fault. This clears what it already produced.
--
--  WHAT IS REVERSED — and what is NOT
--  ---------------------------------
--  Only bills that satisfy ALL of:
--    * trans_type = 'Bill'
--    * acadyear  < 2026/2027            (below the policy floor)
--    * trans_date >= 2026-07-01         (this month and last)
--    * the ledger `teller` is the STUDENT'S OWN regno
--
--  That last condition is what separates the fault from legitimate work. The
--  billing procedures pass the signed-in user through as the biller, so a bill
--  raised by the student's own portal action carries their regno, while a bill
--  a finance officer raised carries that officer's username. Of the 386
--  historic-semester bills since 1 July, 259 carry a student regno (the fault)
--  and 127 carry a staff name — mugweri, sharifah, teddy, autocapture. Those
--  127 are deliberate finance work and are LEFT ALONE.
--
--  Both sides of the double entry go: the fin_studentfeestracking row and the
--  fin_ledger DR/CR pair keyed 'BillNo:<TID>'. Payments, waivers and bursaries
--  are never touched — only bills.
--
--  Every reversal is recorded in fin_deleted_transactions, the same audit table
--  the finance screens write to, so the removals are visible to finance in the
--  usual place rather than being an invisible database edit.
--
--  Safe to re-run: the second run finds nothing left to reverse.
-- ============================================================================

SET @cutoff := '2026-07-01';
SET @floor  := '2026/2027';
SET @actor  := 'system:billing-floor-cleanup';

-- ---------------------------------------------------------------------------
-- 1. Freeze the exact set being reversed, so the audit, the deletes and the
--    verification all operate on one identical list.
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS campus_dynamics_accounts.tmp_floor_reverse;
CREATE TABLE campus_dynamics_accounts.tmp_floor_reverse (
    TID BIGINT PRIMARY KEY
) ENGINE=InnoDB;

INSERT INTO campus_dynamics_accounts.tmp_floor_reverse (TID)
SELECT DISTINCT f.TID
  FROM campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics_accounts.fin_ledger l ON l.folio = CONCAT('BillNo:', f.TID)
 WHERE f.trans_type = 'Bill'
   AND f.acadyear   < @floor
   AND f.trans_date >= @cutoff
   AND l.teller REGEXP '^MRU[0-9]+$';

SELECT '--- to be reversed ---' AS step_1;
SELECT COUNT(*) AS bills,
       (SELECT COUNT(DISTINCT regno) FROM campus_dynamics_accounts.fin_studentfeestracking f
         JOIN campus_dynamics_accounts.tmp_floor_reverse t ON t.TID=f.TID) AS students,
       (SELECT SUM(amount) FROM campus_dynamics_accounts.fin_studentfeestracking f
         JOIN campus_dynamics_accounts.tmp_floor_reverse t ON t.TID=f.TID) AS total_ugx
  FROM campus_dynamics_accounts.tmp_floor_reverse;

-- ---------------------------------------------------------------------------
-- 2. Full row backup, so the reversal can be undone exactly.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.bk_floor_reverse_fees_20260827
AS SELECT * FROM campus_dynamics_accounts.fin_studentfeestracking WHERE 1=0;

CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.bk_floor_reverse_ledger_20260827
AS SELECT * FROM campus_dynamics_accounts.fin_ledger WHERE 1=0;

INSERT INTO campus_dynamics_accounts.bk_floor_reverse_fees_20260827
SELECT f.* FROM campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON t.TID = f.TID
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.bk_floor_reverse_fees_20260827 b WHERE b.TID = f.TID);

INSERT INTO campus_dynamics_accounts.bk_floor_reverse_ledger_20260827
SELECT l.* FROM campus_dynamics_accounts.fin_ledger l
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON l.folio = CONCAT('BillNo:', t.TID)
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.bk_floor_reverse_ledger_20260827 b WHERE b.TID = l.TID);

-- ---------------------------------------------------------------------------
-- 3. Audit trail, in the table the finance screens already use.
-- ---------------------------------------------------------------------------
INSERT INTO campus_dynamics_accounts.fin_deleted_transactions
       (original_tid, regno, trans_type, item_code, amount, detail, trans_date,
        acadyear, semester, post_status, deleted_by, deleted_at, delete_category, delete_reason, ip_address)
SELECT f.TID, f.regno, f.trans_type, f.item_code, f.amount, f.detail, f.trans_date,
       f.acadyear, f.semester, f.post_status, @actor, NOW(),
       'System Error / AUTO Billing Mistake',
       CONCAT('Historic semester ', f.acadyear, ' sem ', f.semester,
              ' auto-billed by the student''s own portal registration on ',
              DATE_FORMAT(f.trans_date, '%d/%m/%Y'),
              '. Below the ', @floor, ' automatic-billing floor.'),
       'system'
  FROM campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON t.TID = f.TID
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_deleted_transactions d
                    WHERE d.original_tid = f.TID AND d.deleted_by = @actor);

-- ---------------------------------------------------------------------------
-- 4. Reverse both sides of the entry. Ledger first — deleting the tracking row
--    first would lose the TID the ledger rows are keyed by.
-- ---------------------------------------------------------------------------
DELETE l FROM campus_dynamics_accounts.fin_ledger l
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON l.folio = CONCAT('BillNo:', t.TID);

DELETE f FROM campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON t.TID = f.TID;

-- ---------------------------------------------------------------------------
-- 5. Refresh the affected students' cached balances, so the portal and every
--    fee gate immediately show the corrected figure rather than a stale debt.
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS campus_dynamics_accounts.tmp_floor_students;
CREATE TABLE campus_dynamics_accounts.tmp_floor_students (
    regno VARCHAR(35) PRIMARY KEY
) ENGINE=InnoDB;
INSERT IGNORE INTO campus_dynamics_accounts.tmp_floor_students (regno)
SELECT DISTINCT TRIM(regno) FROM campus_dynamics_accounts.bk_floor_reverse_fees_20260827;

UPDATE campus_dynamics_accounts.fin_student_balance_cache c
  JOIN campus_dynamics_accounts.tmp_floor_students s ON TRIM(c.regno) = s.regno
   SET c.total_billed  = IFNULL((SELECT SUM(amount) FROM campus_dynamics_accounts.fin_studentfeestracking f
                                  WHERE TRIM(f.regno)=s.regno AND f.trans_type='Bill'),0),
       c.total_paid    = IFNULL((SELECT SUM(amount) FROM campus_dynamics_accounts.fin_studentfeestracking f
                                  WHERE TRIM(f.regno)=s.regno AND f.trans_type='Payment'),0),
       c.total_balance = IFNULL((SELECT SUM(amount) FROM campus_dynamics_accounts.fin_studentfeestracking f
                                  WHERE TRIM(f.regno)=s.regno AND f.trans_type='Payment'),0)
                       - IFNULL((SELECT SUM(amount) FROM campus_dynamics_accounts.fin_studentfeestracking f
                                  WHERE TRIM(f.regno)=s.regno AND f.trans_type='Bill'),0),
       c.tx_count      = (SELECT COUNT(*) FROM campus_dynamics_accounts.fin_studentfeestracking f
                           WHERE TRIM(f.regno)=s.regno),
       c.updated_at    = NOW();

-- ---------------------------------------------------------------------------
-- 6. Verification.
-- ---------------------------------------------------------------------------
SELECT '--- 1. none of the reversed bills remain (expect 0) ---' AS check_1;
SELECT COUNT(*) AS still_present
  FROM campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON t.TID = f.TID;

SELECT '--- 2. their ledger entries are gone too (expect 0) ---' AS check_2;
SELECT COUNT(*) AS ledger_rows_left
  FROM campus_dynamics_accounts.fin_ledger l
  JOIN campus_dynamics_accounts.tmp_floor_reverse t ON l.folio = CONCAT('BillNo:', t.TID);

SELECT '--- 3. staff-raised historic bills were NOT touched ---' AS check_3;
SELECT COUNT(DISTINCT f.TID) AS staff_raised_bills_intact
  FROM campus_dynamics_accounts.fin_studentfeestracking f
  JOIN campus_dynamics_accounts.fin_ledger l ON l.folio = CONCAT('BillNo:', f.TID)
 WHERE f.trans_type='Bill' AND f.acadyear < @floor AND f.trans_date >= @cutoff
   AND l.teller NOT REGEXP '^MRU[0-9]+$';

SELECT '--- 4. no payment, waiver or bursary was touched (expect 0) ---' AS check_4;
SELECT COUNT(*) AS non_bill_rows_removed
  FROM campus_dynamics_accounts.bk_floor_reverse_fees_20260827 WHERE trans_type <> 'Bill';

SELECT '--- 5. audit rows written ---' AS check_5;
SELECT COUNT(*) AS audit_rows FROM campus_dynamics_accounts.fin_deleted_transactions WHERE deleted_by = @actor;

SELECT '--- 6. the student who reported it ---' AS check_6;
SELECT acadyear, semester, trans_type, item_code, amount, DATE(trans_date) d
  FROM campus_dynamics_accounts.fin_studentfeestracking
 WHERE TRIM(regno)='MRU2023000619' ORDER BY trans_date DESC LIMIT 6;

SELECT SUM(IF(trans_type='Bill',amount,0)) AS billed,
       SUM(IF(trans_type='Payment',amount,0)) AS paid,
       SUM(IF(trans_type='Payment',amount,0)) - SUM(IF(trans_type='Bill',amount,0)) AS balance
  FROM campus_dynamics_accounts.fin_studentfeestracking WHERE TRIM(regno)='MRU2023000619';
