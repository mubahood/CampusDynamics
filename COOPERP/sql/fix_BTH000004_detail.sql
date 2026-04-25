-- ============================================================
-- FIX: BTH000004 billing detail  "some reason..." → "Late registration fee"
-- Run against the ACCOUNTS (financials) database.
-- Created: 2026-04-17
-- Revised: 2026-04-17 (corrected update order + old-detail capture)
-- ============================================================

-- Step 0: Preview what will be changed before committing.
-- ────────────────────────────────────────────────────────
SELECT 'fin_batch_billing_jobs' AS tbl, job_ref, item_name, detail, acad_year, semester
FROM fin_batch_billing_jobs
WHERE job_ref = 'BTH000004';

-- Keep old detail in a variable so updates still work after header change
SET @job_ref := 'BTH000004';
SET @new_detail := 'Late registration fee';
SET @old_detail := (
    SELECT detail
    FROM fin_batch_billing_jobs
    WHERE job_ref = @job_ref
    LIMIT 1
);

START TRANSACTION;

-- ────────────────────────────────────────────────────────
-- Step 1: Fix individual student bill rows in fin_studentfeestracking
-- ────────────────────────────────────────────────────────
UPDATE fin_studentfeestracking t
INNER JOIN fin_batch_billing_jobs j
       ON  j.job_ref     = @job_ref
       AND t.acadyear    = j.acad_year
       AND t.semester    = j.semester
       AND t.item_code   = j.item_code
       AND t.trans_type  = 'Bill'
SET    t.detail = @new_detail
WHERE  t.detail = @old_detail
    OR t.TID = 99293;

-- ────────────────────────────────────────────────────────
-- Step 2: Fix GL ledger particulars for the same transactions
-- ────────────────────────────────────────────────────────
UPDATE fin_ledger l
INNER JOIN fin_studentfeestracking t
       ON  l.folio = CONCAT('BillNo:', t.TID)
INNER JOIN fin_batch_billing_jobs j
       ON  j.job_ref    = @job_ref
       AND t.acadyear   = j.acad_year
       AND t.semester   = j.semester
       AND t.item_code  = j.item_code
       AND t.trans_type = 'Bill'
SET    l.particulars = @new_detail
WHERE  l.particulars = @old_detail
    OR t.TID = 99293;

-- ────────────────────────────────────────────────────────
-- Step 3: Fix the batch header record (run after child rows)
-- ────────────────────────────────────────────────────────
UPDATE fin_batch_billing_jobs
SET    detail = @new_detail
WHERE  job_ref = @job_ref;

COMMIT;

-- ────────────────────────────────────────────────────────
-- Step 4: Verify — should show 'Late registration fee' everywhere
-- ────────────────────────────────────────────────────────
SELECT 'BATCH HEADER' AS source, detail, acad_year, semester
FROM   fin_batch_billing_jobs
WHERE  job_ref = 'BTH000004'

UNION ALL

SELECT CONCAT('TRACKING rows: ', COUNT(*)) AS source,
       detail, acadyear AS acad_year, semester
FROM   fin_studentfeestracking t
INNER JOIN fin_batch_billing_jobs j
       ON  j.job_ref   = 'BTH000004'
       AND t.acadyear  = j.acad_year
       AND t.semester  = j.semester
       AND t.item_code = j.item_code
       AND t.trans_type = 'Bill'
GROUP  BY detail, acadyear, semester

UNION ALL

SELECT CONCAT('GL LEDGER rows: ', COUNT(*)) AS source,
       l.particulars AS detail,
       NULL AS acad_year,
       NULL AS semester
FROM   fin_ledger l
INNER JOIN fin_studentfeestracking t ON l.folio = CONCAT('BillNo:', t.TID)
INNER JOIN fin_batch_billing_jobs j
       ON  j.job_ref   = 'BTH000004'
       AND t.acadyear  = j.acad_year
       AND t.semester  = j.semester
       AND t.item_code = j.item_code
       AND t.trans_type = 'Bill'
GROUP  BY l.particulars;
