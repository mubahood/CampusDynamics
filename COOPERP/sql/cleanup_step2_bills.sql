DELETE FROM fin_studentfeestracking 
WHERE trans_type = 'Bill'
  AND TID NOT IN (
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
    WHERE dup_groups.regno = fin_studentfeestracking.regno 
      AND dup_groups.acadyear = fin_studentfeestracking.acadyear
      AND dup_groups.semester = fin_studentfeestracking.semester 
      AND dup_groups.item_code = fin_studentfeestracking.item_code
  );
