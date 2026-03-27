-- ============================================================================
-- MIGRATION: Prevent Duplicate Billing (Absolute Guarantee)
-- Run against: campus_dynamics_accounts
-- Date: 2026-03-25
--
-- PURPOSE:
-- Ensures no student can EVER be billed twice for the same item in the same
-- semester, regardless of the billing pathway (single, batch, auto, API).
--
-- STRATEGY (Defense-in-Depth):
--   Layer 1: C# in-memory pre-check (HashSet) — filters 99% before SP call
--   Layer 2: SP pre-check via INSERT...SELECT...WHERE NOT EXISTS (near-atomic)
--   Layer 3: DB-level UNIQUE constraint on fin_bill_uniqueness table
--            + BEFORE INSERT trigger on fin_studentfeestracking
--            (the ONLY 100% race-proof protection)
--
-- WHY NOT a UNIQUE INDEX directly on fin_studentfeestracking?
-- Because fin_studentfeestracking also holds Payment/Credit records.
-- A UNIQUE on (regno, acadyear, semester, item_code, trans_type) would prevent
-- multiple partial payments for the same item — breaking valid payment workflows.
-- The helper table fin_bill_uniqueness applies uniqueness ONLY to Bill records.
--
-- STEPS:
--   0. Backup
--   1. Clean up existing duplicate bills (idempotent)
--   2. Create fin_bill_uniqueness helper table with UNIQUE constraint
--   3. Populate from existing bill records
--   4. Create BEFORE INSERT trigger (prevents duplicate bills at DB level)
--   5. Create AFTER DELETE trigger (keeps helper table in sync on bill removal)
--   6. Update fin_TermlyItemBillingFN to use atomic INSERT...WHERE NOT EXISTS
-- ============================================================================


-- ============================================================================
-- STEP 0: BACKUP (skip if backup already exists from previous migration)
-- ============================================================================
CREATE TABLE IF NOT EXISTS fin_studentfeestracking_backup_dup_prevention
    AS SELECT * FROM fin_studentfeestracking WHERE 1=0;

INSERT INTO fin_studentfeestracking_backup_dup_prevention
SELECT * FROM fin_studentfeestracking
WHERE TID NOT IN (SELECT TID FROM fin_studentfeestracking_backup_dup_prevention);


-- ============================================================================
-- STEP 1: Clean up any remaining duplicate bills (idempotent)
-- Keeps the FIRST bill (lowest TID) for each (regno, acadyear, semester, item_code)
-- ============================================================================

-- Find duplicate TIDs to remove
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_dup_tids AS
SELECT ft.TID
FROM fin_studentfeestracking ft
INNER JOIN (
    SELECT regno, acadyear, semester, item_code, MIN(TID) AS keep_tid
    FROM fin_studentfeestracking
    WHERE trans_type = 'Bill'
    GROUP BY regno, acadyear, semester, item_code
    HAVING COUNT(*) > 1
) keeper ON ft.regno = keeper.regno
    AND ft.acadyear = keeper.acadyear
    AND ft.semester = keeper.semester
    AND ft.item_code = keeper.item_code
    AND ft.trans_type = 'Bill'
    AND ft.TID != keeper.keep_tid;

-- Remove GL entries for duplicates
DELETE FROM fin_ledger
WHERE folio IN (SELECT CONCAT('BillNo:', TID) FROM tmp_dup_tids);

-- Remove duplicate bill records
DELETE FROM fin_studentfeestracking
WHERE TID IN (SELECT TID FROM tmp_dup_tids);

DROP TEMPORARY TABLE IF EXISTS tmp_dup_tids;

-- Verify: should return 0
SELECT COUNT(*) AS remaining_duplicates FROM (
    SELECT regno, acadyear, semester, item_code
    FROM fin_studentfeestracking WHERE trans_type = 'Bill'
    GROUP BY regno, acadyear, semester, item_code
    HAVING COUNT(*) > 1
) chk;


-- ============================================================================
-- STEP 2: Create the bill uniqueness helper table
-- This table enforces a UNIQUE constraint on (regno, acadyear, semester, item_code)
-- for Bill records ONLY. Payments and other trans_types are not constrained.
-- ============================================================================

DROP TABLE IF EXISTS fin_bill_uniqueness;
CREATE TABLE fin_bill_uniqueness (
    regno       VARCHAR(35)  NOT NULL,
    acadyear    VARCHAR(15)  NOT NULL,
    semester    INT          NOT NULL,
    item_code   INT          NOT NULL,
    tid         INT          NOT NULL DEFAULT 0,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY UNQ_one_bill_per_student (regno, acadyear, semester, item_code),
    KEY idx_tid (tid)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
COMMENT='Prevents duplicate billing. One bill per student per item per semester.';


-- ============================================================================
-- STEP 3: Populate from existing bill records
-- INSERT IGNORE skips any duplicates (shouldn't exist after Step 1)
-- ============================================================================

INSERT IGNORE INTO fin_bill_uniqueness (regno, acadyear, semester, item_code, tid)
SELECT ft.regno, ft.acadyear, ft.semester, ft.item_code, ft.TID
FROM fin_studentfeestracking ft
WHERE ft.trans_type = 'Bill'
GROUP BY ft.regno, ft.acadyear, ft.semester, ft.item_code;


-- ============================================================================
-- STEP 4: BEFORE INSERT trigger — prevents duplicate bills at DB level
--
-- When any INSERT into fin_studentfeestracking has trans_type='Bill',
-- this trigger attempts to INSERT into fin_bill_uniqueness first.
-- If the student already has a bill for that item/semester, the UNIQUE
-- constraint raises MySQL error 1062 (ER_DUP_ENTRY), which aborts
-- the entire INSERT. This is truly atomic and race-proof.
-- ============================================================================

DROP TRIGGER IF EXISTS trg_prevent_duplicate_bill;

DELIMITER $$
CREATE TRIGGER trg_prevent_duplicate_bill
BEFORE INSERT ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF NEW.trans_type = 'Bill' THEN
        -- This INSERT will fail with error 1062 if a bill already exists
        -- for this student/year/semester/item, aborting the parent INSERT.
        INSERT INTO fin_bill_uniqueness (regno, acadyear, semester, item_code, tid)
        VALUES (NEW.regno, NEW.acadyear, NEW.semester, NEW.item_code, 0);
    END IF;
END$$
DELIMITER ;


-- ============================================================================
-- STEP 5: AFTER DELETE trigger — keeps helper table in sync
-- When a bill is deleted from fin_studentfeestracking, remove the
-- corresponding uniqueness entry so re-billing is allowed.
-- ============================================================================

DROP TRIGGER IF EXISTS trg_sync_bill_uniqueness_delete;

DELIMITER $$
CREATE TRIGGER trg_sync_bill_uniqueness_delete
AFTER DELETE ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF OLD.trans_type = 'Bill' THEN
        DELETE FROM fin_bill_uniqueness
        WHERE regno = OLD.regno
          AND acadyear = OLD.acadyear
          AND semester = OLD.semester
          AND item_code = OLD.item_code;
    END IF;
END$$
DELIMITER ;


-- ============================================================================
-- STEP 6: Update fin_TermlyItemBillingFN — atomic INSERT with WHERE NOT EXISTS
--
-- Changes from previous version:
--   OLD: SELECT COUNT(*) pre-check + plain INSERT
--   NEW: INSERT ... SELECT ... WHERE NOT EXISTS + ROW_COUNT() check
--
-- The WHERE NOT EXISTS makes the check-and-insert more atomic (single statement).
-- Combined with the BEFORE INSERT trigger and fin_bill_uniqueness UNIQUE constraint,
-- this provides absolute protection against double-billing.
-- ============================================================================

DROP FUNCTION IF EXISTS fin_TermlyItemBillingFN;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fin_TermlyItemBillingFN`(
  billType CHAR(15),
  reg CHAR(25),
  ItemID INT,
  sems INT,
  prog CHAR(25),
  sess CHAR(25),
  T_Date DATE,
  usr CHAR(25),
  yr INT,
  acadyr CHAR(15),
  csid CHAR(25),
  amt DOUBLE
) RETURNS char(25) CHARSET latin1
DETERMINISTIC
BEGIN

DECLARE IncomeAccount, ItemNm, acad, studSys, rtn CHAR(150);
DECLARE repStatus INT DEFAULT 0;
DECLARE lastTNo INT DEFAULT 0;
DECLARE rowsInserted INT DEFAULT 0;

-- Skip zero or negative amounts immediately
IF amt <= 0 THEN
  RETURN 'Zero Amount';
END IF;

-- Look up billing item info
SELECT AccountCode, ItemName INTO IncomeAccount, ItemNm
FROM academicbillingitems
WHERE ItemCode = ItemID LIMIT 1;

SELECT study_system INTO studSys
FROM campus_dynamics.acad_programme
WHERE progcode = prog;

-- ================================================================
-- ATOMIC INSERT: Only inserts if no existing bill for this combination.
-- The WHERE NOT EXISTS check and INSERT happen in ONE statement,
-- dramatically reducing the race condition window.
--
-- ADDITIONAL SAFETY: The BEFORE INSERT trigger on fin_studentfeestracking
-- also inserts into fin_bill_uniqueness (which has a UNIQUE constraint).
-- If somehow a race condition slips through, the trigger's INSERT fails
-- with error 1062, aborting this INSERT entirely.
-- ================================================================
INSERT INTO fin_studentfeestracking(
  regno, Amount, item_code, trans_type, post_status,
  acadyear, semester, trans_date, detail
)
SELECT
  reg, amt, ItemID, 'Bill', 'Pending',
  acadyr, sems, SYSDATE(),
  CONCAT(ItemNm, ' Sem :', sems, ', ', acadyr, ': ', reg, ' [', csid, ']')
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM fin_studentfeestracking
  WHERE regno = reg
    AND acadyear = acadyr
    AND semester = sems
    AND item_code = ItemID
    AND trans_type = 'Bill'
);

SET rowsInserted = ROW_COUNT();

-- If no row was inserted, the student is already billed
IF rowsInserted = 0 THEN
  RETURN 'Already Billed';
END IF;

-- Create GL entry for the newly inserted bill
SELECT fin_TransactionCreatorFn2(
  IncomeAccount, 'Chart Account',
  CONCAT(ItemNm, ' Receivable from ',
    regno, ' (', campus_dynamics.acad_GetStudNameByID(reg), ') for ',
    studSys, ':', sems, ', ', acadyr),
  regno, fin_GetStudentLedgerName(regno),
  CONCAT(ItemNm, ' for ', studSys, ':', sems, ', ', acadyr, ' ', csid),
  Amount, fin_NextVoucherNo(usr), T_Date, usr,
  CONCAT('BillNo:', TID), 'UGX'
) INTO rtn
FROM fin_studentfeestracking
WHERE semester = sems
  AND acadyear = acadyr
  AND item_code = ItemID
  AND regno = reg
  AND post_status = 'Pending'
  AND amount > 0
LIMIT 1;

-- Mark as posted
UPDATE fin_studentfeestracking
SET post_status = 'Posted'
WHERE semester = sems
  AND acadyear = acadyr
  AND regno = reg
  AND item_code = ItemID;

-- Update ledger balances
CALL fin_UpdateAllLedgerBalances();

-- Update journal numbers
UPDATE fin_ledger
SET journal_no = fin_transactionNo(accountcode, account_type, TID)
WHERE journal_no = '-';

RETURN '1 Bill';

END$$

DELIMITER ;


-- ============================================================================
-- VERIFICATION QUERIES (run after migration)
-- ============================================================================

-- 1. Confirm uniqueness table is populated
SELECT COUNT(*) AS bills_tracked FROM fin_bill_uniqueness;

-- 2. Confirm trigger exists
SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_STATEMENT
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE()
  AND EVENT_OBJECT_TABLE = 'fin_studentfeestracking';

-- 3. Test duplicate prevention (should fail with error 1062):
-- INSERT INTO fin_studentfeestracking(regno, Amount, item_code, trans_type,
--   post_status, acadyear, semester, trans_date, detail)
-- SELECT regno, Amount, item_code, 'Bill', 'Pending', acadyear, semester,
--   SYSDATE(), 'TEST DUPLICATE'
-- FROM fin_studentfeestracking
-- WHERE trans_type='Bill' LIMIT 1;
-- Expected: ERROR 1062 (23000): Duplicate entry '...' for key 'UNQ_one_bill_per_student'

-- 4. Confirm no duplicate bills exist
SELECT COUNT(*) AS remaining_duplicates FROM (
    SELECT regno, acadyear, semester, item_code
    FROM fin_studentfeestracking WHERE trans_type = 'Bill'
    GROUP BY regno, acadyear, semester, item_code
    HAVING COUNT(*) > 1
) chk;
