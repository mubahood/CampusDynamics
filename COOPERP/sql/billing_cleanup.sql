-- ============================================================
-- BILLING CLEANUP & IMPROVEMENT SQL SCRIPTS
-- Run against campus_dynamics_accounts
-- Date: 2026-03-23
-- ============================================================

-- ============================================================
-- STEP 0: BACKUP the affected tables FIRST
-- ============================================================
CREATE TABLE IF NOT EXISTS fin_studentfeestracking_backup_20260323 AS SELECT * FROM fin_studentfeestracking;
CREATE TABLE IF NOT EXISTS fin_ledger_backup_20260323 AS SELECT * FROM fin_ledger;

-- ============================================================  
-- STEP 1: Identify all duplicate (extra) bill TIDs
-- For each (regno, acadyear, semester, item_code, 'Bill') group with >1 row,
-- keep the FIRST TID (MIN) and mark the rest as duplicates.
-- ============================================================

-- Create a temp table of extra TIDs to delete
CREATE TEMPORARY TABLE tmp_dup_bill_tids AS
SELECT ft.TID, ft.regno, ft.acadyear, ft.semester, ft.item_code, ft.amount  
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

-- Verify count
SELECT COUNT(*) AS duplicate_bills_to_remove FROM tmp_dup_bill_tids;

-- ============================================================
-- STEP 2: Delete GL entries for duplicate bills (those with GL)
-- ============================================================
DELETE FROM fin_ledger 
WHERE folio IN (SELECT CONCAT('BillNo:', TID) FROM tmp_dup_bill_tids);

-- ============================================================
-- STEP 3: Delete the duplicate bill records themselves
-- ============================================================  
DELETE FROM fin_studentfeestracking 
WHERE TID IN (SELECT TID FROM tmp_dup_bill_tids);

-- ============================================================
-- STEP 4: Verify no duplicates remain
-- ============================================================
SELECT COUNT(*) AS remaining_duplicates FROM (
    SELECT regno, acadyear, semester, item_code
    FROM fin_studentfeestracking WHERE trans_type = 'Bill'
    GROUP BY regno, acadyear, semester, item_code
    HAVING COUNT(*) > 1
) chk;

-- ============================================================
-- STEP 5: Fix the unique index
-- Remove the broken index that includes 'detail' column,
-- replace with proper unique on (regno, acadyear, semester, item_code, trans_type)
-- ============================================================
ALTER TABLE fin_studentfeestracking DROP INDEX Index_UNQ;

ALTER TABLE fin_studentfeestracking 
ADD UNIQUE INDEX UNQ_student_bill (regno, acadyear, semester, item_code, trans_type);

-- ============================================================
-- STEP 6: Recompute ledger balances
-- ============================================================
CALL fin_UpdateAllLedgerBalances();
