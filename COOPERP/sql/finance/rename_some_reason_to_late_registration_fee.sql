-- ============================================================================
--  Rename the placeholder charge description "some reason.." to
--  "Late registration fee"
--  Muteesa I Royal University                                     2026-09-02
--
--  WHAT THIS IS
--
--  On 2026-04-14 a charge of UGX 50,000 was raised against 264 students and
--  posted as a double entry — the student account debited and income account
--  AC6016 credited — under the description "some reason..". That is a placeholder
--  somebody typed, and it is what students currently read on their fee
--  statements. It is a late registration fee, so it is renamed to say so.
--
--  Three later reversals (2026-05-14/15) carry the same placeholder inside a
--  longer sentence.
--
--  HOW IT IS RENAMED
--
--  The literal substring "some reason.." is replaced with "Late registration
--  fee" wherever it appears, rather than overwriting the whole column. That
--  matters, because the placeholder is embedded in three different sentences and
--  overwriting would destroy the rest:
--
--    some reason..
--      -> Late registration fee
--    some reason.. (MRU2025003663)
--      -> Late registration fee (MRU2025003663)
--    Reversal of some reason.. reason -WRONG BILLING
--      -> Reversal of Late registration fee reason -WRONG BILLING
--    Reversal of some reason.. (MRU2024001904) reason -Not applicable
--      -> Reversal of Late registration fee (MRU2024001904) reason -Not applicable
--    Reversal of Waiver #15 (Wrong Billing): some reason..
--      -> Reversal of Waiver #15 (Wrong Billing): Late registration fee
--
--  The "(MRU…)" tag on the AC6016 side is the only link between an income-account
--  credit and the student it came from, and the reversal wording is the only thing
--  distinguishing a reversal from a charge. Both survive.
--
--  WHAT IS CHANGED — live tables only, 823 rows
--
--    fin_ledger.particulars                 536   (264 student DR, 266 AC6016 CR, 6 reversal)
--    fin_studentfeestracking.detail         264
--    fin_bill_waiver_items.bill_detail       22   (copy of the bill's description)
--    fin_bill_waivers.waiver_reason           1   (description embedded in a composed sentence)
--
--  WHAT IS DELIBERATELY NOT CHANGED
--
--  The phrase also appears in backup and archive tables. They are records of what
--  the data WAS, and rewriting them would destroy the only evidence of the
--  original wording:
--
--    bak_20260624_fin_ledger.particulars                              543
--    bak_20260624_fin_studentfeestracking.detail                      268
--    bak_fin_changed_deleted_20260814.orig_detail                       4
--    fin_deleted_ledger.particulars                                   151
--    fin_deleted_transactions.detail                                    4
--    fin_ledger_backup_before_missing_student_restore_20260612…        543
--
--  NO AMOUNTS, ACCOUNTS OR DATES ARE TOUCHED. This is wording only; no balance
--  changes.
--
--  CASING: every live row is lowercase "some reason.." — verified with a BINARY
--  comparison, because REPLACE() is case-sensitive and a capitalised variant
--  would have been silently skipped.
-- ============================================================================

-- ── 1. backup: the exact original text of every row about to change ─────────
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_rename_somereason_bak_20260902 (
  src_table  VARCHAR(64)  NOT NULL,
  src_column VARCHAR(64)  NOT NULL,
  row_id     BIGINT       NOT NULL,
  old_value  TEXT         NOT NULL,
  KEY ix_src (src_table, row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO campus_dynamics_accounts.fin_rename_somereason_bak_20260902
SELECT 'fin_ledger','particulars',TID,particulars
FROM campus_dynamics_accounts.fin_ledger WHERE particulars LIKE BINARY '%some reason..%';

INSERT INTO campus_dynamics_accounts.fin_rename_somereason_bak_20260902
SELECT 'fin_studentfeestracking','detail',TID,detail
FROM campus_dynamics_accounts.fin_studentfeestracking WHERE detail LIKE BINARY '%some reason..%';

INSERT INTO campus_dynamics_accounts.fin_rename_somereason_bak_20260902
SELECT 'fin_bill_waiver_items','bill_detail',item_id,bill_detail
FROM campus_dynamics_accounts.fin_bill_waiver_items WHERE bill_detail LIKE BINARY '%some reason..%';

INSERT INTO campus_dynamics_accounts.fin_rename_somereason_bak_20260902
SELECT 'fin_bill_waivers','waiver_reason',waiver_id,waiver_reason
FROM campus_dynamics_accounts.fin_bill_waivers WHERE waiver_reason LIKE BINARY '%some reason..%';

SELECT src_table, COUNT(*) rows_backed_up
FROM campus_dynamics_accounts.fin_rename_somereason_bak_20260902
GROUP BY src_table WITH ROLLUP;

-- ── 2. the rename ───────────────────────────────────────────────────────────
UPDATE campus_dynamics_accounts.fin_ledger
   SET particulars = REPLACE(particulars, 'some reason..', 'Late registration fee')
 WHERE particulars LIKE BINARY '%some reason..%';
SELECT CONCAT('fin_ledger: ', ROW_COUNT(), ' rows renamed') AS step;

UPDATE campus_dynamics_accounts.fin_studentfeestracking
   SET detail = REPLACE(detail, 'some reason..', 'Late registration fee')
 WHERE detail LIKE BINARY '%some reason..%';
SELECT CONCAT('fin_studentfeestracking: ', ROW_COUNT(), ' rows renamed') AS step;

UPDATE campus_dynamics_accounts.fin_bill_waiver_items
   SET bill_detail = REPLACE(bill_detail, 'some reason..', 'Late registration fee')
 WHERE bill_detail LIKE BINARY '%some reason..%';
SELECT CONCAT('fin_bill_waiver_items: ', ROW_COUNT(), ' rows renamed') AS step;

UPDATE campus_dynamics_accounts.fin_bill_waivers
   SET waiver_reason = REPLACE(waiver_reason, 'some reason..', 'Late registration fee')
 WHERE waiver_reason LIKE BINARY '%some reason..%';
SELECT CONCAT('fin_bill_waivers: ', ROW_COUNT(), ' rows renamed') AS step;

-- ── 3. checks ───────────────────────────────────────────────────────────────
SELECT 'placeholder left in live tables' AS check_name,
       (SELECT COUNT(*) FROM campus_dynamics_accounts.fin_ledger              WHERE particulars   LIKE '%some reason%')
     + (SELECT COUNT(*) FROM campus_dynamics_accounts.fin_studentfeestracking WHERE detail        LIKE '%some reason%')
     + (SELECT COUNT(*) FROM campus_dynamics_accounts.fin_bill_waiver_items   WHERE bill_detail   LIKE '%some reason%')
     + (SELECT COUNT(*) FROM campus_dynamics_accounts.fin_bill_waivers        WHERE waiver_reason LIKE '%some reason%') AS should_be_zero;

--  Counting rows that merely LIKE '%Late registration fee%' proves nothing here:
--  LIKE is case-insensitive under this collation, and the register ALREADY held
--  ~1,000 rows reading "Late Registration Fee for Semester:X, YYYY/YYYY" long
--  before this script existed. Such a count returns thousands and looks like a
--  pass whatever happened.
--
--  The only sound check is against the backup: every row that was changed must
--  now read exactly its own old value with the substring swapped, and nothing
--  else must have moved.
SELECT b.src_table,
       COUNT(*) AS rows_changed,
       SUM(REPLACE(b.old_value,'some reason..','Late registration fee') =
           CASE b.src_table
             WHEN 'fin_ledger'              THEN (SELECT particulars   FROM campus_dynamics_accounts.fin_ledger              WHERE TID=b.row_id)
             WHEN 'fin_studentfeestracking' THEN (SELECT detail        FROM campus_dynamics_accounts.fin_studentfeestracking WHERE TID=b.row_id)
             WHEN 'fin_bill_waiver_items'   THEN (SELECT bill_detail   FROM campus_dynamics_accounts.fin_bill_waiver_items   WHERE item_id=b.row_id)
             WHEN 'fin_bill_waivers'        THEN (SELECT waiver_reason FROM campus_dynamics_accounts.fin_bill_waivers        WHERE waiver_id=b.row_id)
           END) AS exactly_as_expected     -- must equal rows_changed on every line
FROM campus_dynamics_accounts.fin_rename_somereason_bak_20260902 b
GROUP BY b.src_table WITH ROLLUP;

-- The student tag and the reversal wording must both have survived.
SELECT particulars, COUNT(*) n FROM campus_dynamics_accounts.fin_ledger
WHERE TID IN (SELECT row_id FROM campus_dynamics_accounts.fin_rename_somereason_bak_20260902 WHERE src_table='fin_ledger')
GROUP BY particulars ORDER BY n DESC LIMIT 6;

-- Money must be untouched: 267 DR / 13,350,000 and 269 CR / 13,450,000 — the 264
-- charges and 266 income credits, plus the three reversal pairs.
SELECT transactionType, COUNT(*) rows_n, SUM(transaction_amount) total
FROM campus_dynamics_accounts.fin_ledger
WHERE TID IN (SELECT row_id FROM campus_dynamics_accounts.fin_rename_somereason_bak_20260902 WHERE src_table='fin_ledger')
GROUP BY transactionType;

-- ============================================================================
--  ROLLBACK — restores the exact original wording, row by row.
--
--    UPDATE campus_dynamics_accounts.fin_ledger t
--      JOIN campus_dynamics_accounts.fin_rename_somereason_bak_20260902 b
--        ON b.src_table='fin_ledger' AND b.row_id=t.TID
--       SET t.particulars = b.old_value;
--
--    UPDATE campus_dynamics_accounts.fin_studentfeestracking t
--      JOIN campus_dynamics_accounts.fin_rename_somereason_bak_20260902 b
--        ON b.src_table='fin_studentfeestracking' AND b.row_id=t.TID
--       SET t.detail = b.old_value;
--
--    UPDATE campus_dynamics_accounts.fin_bill_waiver_items t
--      JOIN campus_dynamics_accounts.fin_rename_somereason_bak_20260902 b
--        ON b.src_table='fin_bill_waiver_items' AND b.row_id=t.item_id
--       SET t.bill_detail = b.old_value;
--
--    UPDATE campus_dynamics_accounts.fin_bill_waivers t
--      JOIN campus_dynamics_accounts.fin_rename_somereason_bak_20260902 b
--        ON b.src_table='fin_bill_waivers' AND b.row_id=t.waiver_id
--       SET t.waiver_reason = b.old_value;
-- ============================================================================
