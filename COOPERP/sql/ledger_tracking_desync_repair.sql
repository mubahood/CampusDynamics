-- ============================================================================
-- Ledger <-> Tracking desync repair  (campus_dynamics_accounts)
-- ----------------------------------------------------------------------------
-- Fixes "ghost bills": a fin_ledger DR student bill (folio 'BillNo:<TID>') whose
-- tracking_ref TID is MISSING from fin_studentfeestracking. Cause: fin_ledger is
-- MyISAM (auto-commits) while fin_studentfeestracking is InnoDB — an interrupted
-- billing call commits the ledger half but rolls back the tracking half.
-- See COOPERP/LEDGER_TRACKING_DESYNC_REPORT.md.
--
-- SAFETY: preview-first. The APPLY blocks are gated behind @DO_APPLY and every
-- destructive change is backed up first. fin_ledger has NO transactions, so the
-- backups are the only undo. RUN IN BATCHES, MONITORED, off-peak — a mid-run
-- interruption creates MORE ghosts.
-- Target invariant per fee cell (regno, acadyear, semester, item_code):
--   exactly ONE tracking Bill + ONE ledger DR, linked by folio='BillNo:<trackTID>'.
-- ============================================================================
SET @DO_APPLY := 0;   -- set to 1 ONLY when you have reviewed the preview and taken backups
USE campus_dynamics_accounts;

-- ---------------------------------------------------------------------------
-- 0. Backup tables (column-only copies; append-safe)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fin_ledger_desync_bak            AS SELECT * FROM fin_ledger              WHERE 1=0;
CREATE TABLE IF NOT EXISTS fin_studentfeestracking_desync_bak AS SELECT * FROM fin_studentfeestracking WHERE 1=0;

-- ---------------------------------------------------------------------------
-- 1. Detect ghosts + parse period/item  ->  zz_ghost_bills
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS zz_ghost_bills;
CREATE TABLE zz_ghost_bills AS
SELECT l.TID AS ledger_tid, l.tracking_ref AS track_tid, TRIM(l.accountcode) AS regno,
       l.transaction_amount AS amount, l.transactionDate AS trans_date, l.particulars,
       SUBSTRING(l.particulars, LOCATE('/', l.particulars)-4, 9) AS acadyear,
       CASE WHEN l.particulars LIKE '%Semester:1%' OR l.particulars LIKE '%Sem :1%' OR l.particulars LIKE '%Session:1%' THEN 1
            WHEN l.particulars LIKE '%Semester:2%' OR l.particulars LIKE '%Sem :2%' OR l.particulars LIKE '%Session:2%' THEN 2
            WHEN l.particulars LIKE '%Semester:3%' OR l.particulars LIKE '%Sem :3%' OR l.particulars LIKE '%Session:3%' THEN 3
            ELSE 0 END AS semester,
       CAST(NULL AS SIGNED) AS item_code,
       CAST(NULL AS SIGNED) AS valid_track_tid,   -- a tracking Bill TID for the same cell (if any)
       0 AS valid_has_ledger,                     -- does that valid tracking bill already carry a ledger DR?
       0 AS reg_ok,                               -- student REGISTERED/CLEARED for the period?
       0 AS is_cell_keeper,                       -- 1 = the single ghost chosen to survive for its cell
       CAST(NULL AS CHAR(20)) AS action
FROM fin_ledger l
WHERE l.account_type='Student' AND l.transactionType='DR' AND l.folio LIKE 'BillNo:%'
  AND l.tracking_ref > 0
  AND NOT EXISTS (SELECT 1 FROM fin_studentfeestracking t WHERE t.TID = l.tracking_ref);
ALTER TABLE zz_ghost_bills ADD INDEX ix_cell (regno, acadyear, semester, item_code), ADD INDEX ix_ltid (ledger_tid);

-- item_code: tuition=1, function=52, else resolve by name prefix
UPDATE zz_ghost_bills SET item_code = CASE WHEN particulars LIKE 'Tuition%' THEN 1 WHEN particulars LIKE 'Function%' THEN 52 ELSE item_code END;
UPDATE zz_ghost_bills g JOIN academicbillingitems bi ON g.particulars LIKE CONCAT(bi.ItemName,'%')
   SET g.item_code = bi.ItemCode WHERE g.item_code IS NULL;

-- ---------------------------------------------------------------------------
-- 2. Enrich: valid tracking bill for the cell, whether it has a ledger, registration
-- ---------------------------------------------------------------------------
UPDATE zz_ghost_bills g SET valid_track_tid = (
    SELECT MIN(t.TID) FROM fin_studentfeestracking t
    WHERE TRIM(t.regno)=g.regno AND t.acadyear=g.acadyear AND t.semester=g.semester
      AND t.item_code=g.item_code AND t.trans_type='Bill');
UPDATE zz_ghost_bills g SET valid_has_ledger = (
    SELECT COUNT(*) FROM fin_ledger l WHERE l.folio = CONCAT('BillNo:', g.valid_track_tid) AND l.transactionType='DR')
  WHERE g.valid_track_tid IS NOT NULL;
UPDATE zz_ghost_bills g SET reg_ok = (
    SELECT COUNT(*) FROM campus_dynamics.acad_registration r
    WHERE TRIM(r.regno)=g.regno AND r.acad_year=g.acadyear AND r.semester=g.semester
      AND UPPER(TRIM(IFNULL(r.regstatus,''))) IN ('REGISTERED','LATE REGISTERED','CLEARED'));

-- Cell keeper = the lowest ledger_tid among the ghosts of a cell that has NO valid tracking bill
-- (that single ghost becomes the recreated tracking bill; the rest are surplus).
UPDATE zz_ghost_bills g SET is_cell_keeper = (
    g.ledger_tid = (SELECT MIN(g2.ledger_tid) FROM zz_ghost_bills g2
                    WHERE g2.regno=g.regno AND g2.acadyear=g.acadyear AND g2.semester=g.semester AND g2.item_code=g.item_code));

-- ---------------------------------------------------------------------------
-- 3. Assign one action per ghost row (fee-cell aware)
-- ---------------------------------------------------------------------------
UPDATE zz_ghost_bills g SET action =
  CASE
    WHEN item_code IS NULL THEN 'REVIEW_ITEM'
    -- cell HAS a valid tracking bill --------------------------------------------------
    WHEN valid_track_tid IS NOT NULL AND valid_has_ledger > 0 THEN 'DELETE_LEDGER'          -- pure duplicate GL debit
    WHEN valid_track_tid IS NOT NULL AND valid_has_ledger = 0 AND is_cell_keeper = 1 THEN 'RELINK_LEDGER'  -- orphan IS its ledger
    WHEN valid_track_tid IS NOT NULL AND valid_has_ledger = 0 AND is_cell_keeper = 0 THEN 'DELETE_LEDGER'  -- surplus orphan
    -- cell has NO tracking bill --------------------------------------------------------
    WHEN valid_track_tid IS NULL AND reg_ok > 0 AND is_cell_keeper = 1 THEN 'RECREATE_TRACKING'  -- restore the lost bill
    WHEN valid_track_tid IS NULL AND reg_ok > 0 AND is_cell_keeper = 0 THEN 'DELETE_LEDGER'       -- surplus duplicate ghost
    ELSE 'REVIEW_NOREG'                                                                            -- no reg -> manual
  END;

-- ===========================  PREVIEW  ======================================
SELECT action, COUNT(*) rows, COUNT(DISTINCT regno) students, SUM(amount) amount
FROM zz_ghost_bills GROUP BY action ORDER BY rows DESC;
-- Per-student preview: SELECT * FROM zz_ghost_bills ORDER BY regno, acadyear, semester, item_code;

-- ===========================  APPLY (gated)  ================================
-- Review the preview first, then: SET @DO_APPLY := 1;  and re-run from here in batches.

-- 3a. RELINK: repoint an orphan ledger row onto the existing track-only bill.
INSERT INTO fin_ledger_desync_bak SELECT l.* FROM fin_ledger l JOIN zz_ghost_bills g ON g.ledger_tid=l.TID
   WHERE @DO_APPLY=1 AND g.action='RELINK_LEDGER';
UPDATE fin_ledger l JOIN zz_ghost_bills g ON g.ledger_tid=l.TID
   SET l.folio=CONCAT('BillNo:', g.valid_track_tid), l.tracking_ref=g.valid_track_tid
   WHERE @DO_APPLY=1 AND g.action='RELINK_LEDGER';

-- 3b. RECREATE: rebuild the lost tracking row, reusing the hole TID so folio linkage holds.
--     (trg_prevent_duplicate_bill maintains fin_bill_uniqueness automatically.)
INSERT INTO fin_studentfeestracking (TID, regno, Amount, item_code, trans_type, post_status, acadyear, semester, trans_date, detail)
SELECT g.track_tid, g.regno, g.amount, g.item_code, 'Bill', 'Posted', g.acadyear, g.semester, g.trans_date,
       CONCAT(bi.ItemName, ' Semester:', g.semester, ', ', g.acadyear, ': ', g.regno)
FROM zz_ghost_bills g JOIN academicbillingitems bi ON bi.ItemCode=g.item_code
WHERE @DO_APPLY=1 AND g.action='RECREATE_TRACKING';

-- 3c. DELETE: remove surplus / pure-duplicate ghost ledger debits.
INSERT INTO fin_ledger_desync_bak SELECT l.* FROM fin_ledger l JOIN zz_ghost_bills g ON g.ledger_tid=l.TID
   WHERE @DO_APPLY=1 AND g.action='DELETE_LEDGER';
DELETE l FROM fin_ledger l JOIN zz_ghost_bills g ON g.ledger_tid=l.TID
   WHERE @DO_APPLY=1 AND g.action='DELETE_LEDGER';

-- 3d. Recompute running balances after ledger edits.
-- CALL fin_UpdateAllLedgerBalances();

-- REVIEW_NOREG / REVIEW_ITEM: left untouched for manual finance review.
-- Verify after apply: re-run Section 1 detection — ghost count for repaired years should drop to the REVIEW residue.
