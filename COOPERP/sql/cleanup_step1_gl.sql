-- STEP 1: Delete GL ledger entries for duplicate bill TIDs
-- Keep MIN(TID) for each (regno, acadyear, semester, item_code, 'Bill') group
-- Delete ledger entries where folio = 'BillNo:<extra_tid>'

DELETE FROM fin_ledger 
WHERE folio IN (
    SELECT CONCAT('BillNo:', ft.TID)
    FROM fin_studentfeestracking ft
    WHERE ft.trans_type = 'Bill'
      AND ft.TID NOT IN (
        SELECT min_tid FROM (
          SELECT MIN(TID) AS min_tid 
          FROM fin_studentfeestracking 
          WHERE trans_type = 'Bill'
          GROUP BY regno, acadyear, semester, item_code
        ) keep_list
      )
      AND EXISTS (
        SELECT 1 FROM (
          SELECT regno, acadyear, semester, item_code
          FROM fin_studentfeestracking 
          WHERE trans_type = 'Bill'
          GROUP BY regno, acadyear, semester, item_code
          HAVING COUNT(*) > 1
        ) dup_groups
        WHERE dup_groups.regno = ft.regno 
          AND dup_groups.acadyear = ft.acadyear
          AND dup_groups.semester = ft.semester 
          AND dup_groups.item_code = ft.item_code
      )
);
