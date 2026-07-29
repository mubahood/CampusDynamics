-- Backfill historical acad_results changes (recorded in result_comment as "Score <old>→<new>")
-- into acad_marks_audit as MIGRATE rows. The arrow is matched via its UTF-8 bytes (0xE28692) so
-- terminal/pipe encoding is irrelevant. Idempotent (NOT EXISTS guard). No reliable historical
-- timestamp exists in result_comment, so created_at = import time and the dashboard EXCLUDES
-- action_type='MIGRATE' from time-windowed KPIs (shown as "imported history").
USE campus_dynamics;

INSERT INTO acad_marks_audit
  (action_type, performed_by, target_table, target_id, regno, course_id, acad_year, semester,
   field_changed, new_total, new_grade, change_reason, source_page, created_at)
SELECT 'MIGRATE',
  LEFT(IFNULL(NULLIF(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(result_comment, ' by ', -1), ';', 1)), ''), 'legacy-import'), 50),
  'acad_results', ID, IFNULL(regno, ''), IFNULL(courseid, ''), acad, semester,
  'result', score, grade, LEFT(result_comment, 200), 'backfill:result_comment', NOW()
FROM acad_results
WHERE result_comment LIKE CONCAT('%Score %', CONVERT(0xE28692 USING utf8), '%')
  AND NOT EXISTS (
    SELECT 1 FROM acad_marks_audit a
    WHERE a.target_table = 'acad_results' AND a.target_id = acad_results.ID AND a.action_type = 'MIGRATE');

-- Also seed the "Published from provisional marks by <actor> [Overwrite: was <old>]" changes.
INSERT INTO acad_marks_audit
  (action_type, performed_by, target_table, target_id, regno, course_id, acad_year, semester,
   field_changed, new_total, new_grade, change_reason, source_page, created_at)
SELECT 'MIGRATE',
  LEFT(IFNULL(NULLIF(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(result_comment, ' by ', -1), ' [', 1), ';', 1)), ''), 'legacy-import'), 50),
  'acad_results', ID, IFNULL(regno, ''), IFNULL(courseid, ''), acad, semester,
  'result', score, grade, LEFT(result_comment, 200), 'backfill:result_comment', NOW()
FROM acad_results
WHERE (result_comment LIKE 'Published from provisional%' OR result_comment LIKE '%Overwrite: was%')
  AND NOT EXISTS (
    SELECT 1 FROM acad_marks_audit a
    WHERE a.target_table = 'acad_results' AND a.target_id = acad_results.ID AND a.action_type = 'MIGRATE');
