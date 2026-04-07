-- ============================================================================
-- TEST: Marks Module — Batch 1 Migration Verification (B-01 through B-05)
-- Database: campus_dynamics
-- Date:     2026-04-07
-- Purpose:  Run after all Batch 1 migrations to verify correctness.
--           Every check returns a status row: PASS or FAIL with detail.
-- ============================================================================

-- ── Test 1: sys_schema_migrations table exists and has expected versions ────

SELECT 
    'T01 - sys_schema_migrations exists' AS test_name,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    CONCAT(COUNT(*), ' version(s) registered') AS detail
FROM sys_schema_migrations
WHERE version IN ('marks_001','marks_002','marks_003','marks_004','marks_005');


-- ── Test 2: All 5 migration versions are registered ────────────────────────

SELECT 
    'T02 - All 5 marks migrations registered' AS test_name,
    CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL' END AS result,
    CONCAT(COUNT(*), '/5 versions found') AS detail
FROM sys_schema_migrations
WHERE version IN ('marks_001','marks_002','marks_003','marks_004','marks_005');


-- ── Test 3: acad_teaching_assignments table exists with correct columns ─────

SELECT 
    'T03 - acad_teaching_assignments has required columns' AS test_name,
    CASE WHEN COUNT(*) >= 12 THEN 'PASS' ELSE 'FAIL' END AS result,
    CONCAT(COUNT(*), ' columns found') AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_teaching_assignments';


-- ── Test 4: acad_teaching_assignments unique key exists ─────────────────────

SELECT 
    'T04 - acad_teaching_assignments unique key present' AS test_name,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    'uq_assignment constraint' AS detail
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_teaching_assignments'
  AND INDEX_NAME = 'uq_assignment';


-- ── Test 5: acad_mark_unlock_requests table exists ──────────────────────────

SELECT 
    'T05 - acad_mark_unlock_requests exists' AS test_name,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    CONCAT(COUNT(*), ' columns found') AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_mark_unlock_requests';


-- ── Test 6: unlock_requests has ENUM status column ──────────────────────────

SELECT 
    'T06 - unlock_requests.status is correct ENUM' AS test_name,
    CASE WHEN COLUMN_TYPE LIKE '%PENDING%APPROVED%REJECTED%EXPIRED%' THEN 'PASS' ELSE 'FAIL' END AS result,
    COLUMN_TYPE AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_mark_unlock_requests'
  AND COLUMN_NAME = 'status';


-- ── Test 7: acad_deadlines has deadline_type column ─────────────────────────

SELECT 
    'T07 - acad_deadlines.deadline_type exists' AS test_name,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    'ENUM column' AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_deadlines'
  AND COLUMN_NAME = 'deadline_type';


-- ── Test 8: acad_deadlines has is_active column ─────────────────────────────

SELECT 
    'T08 - acad_deadlines.is_active exists' AS test_name,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    'TINYINT(1) column' AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_deadlines'
  AND COLUMN_NAME = 'is_active';


-- ── Test 9: acad_marks_audit has action_type_ext column ─────────────────────

SELECT 
    'T09 - acad_marks_audit.action_type_ext exists' AS test_name,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    'VARCHAR(20)' AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_marks_audit'
  AND COLUMN_NAME = 'action_type_ext';


-- ── Test 10: acad_marks_audit has all 6 raw-entered columns ─────────────────

SELECT 
    'T10 - acad_marks_audit has 6 raw-entered columns' AS test_name,
    CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'FAIL' END AS result,
    CONCAT(COUNT(*), '/6 columns found') AS detail
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_marks_audit'
  AND COLUMN_NAME IN ('old_cw_entered','new_cw_entered',
                       'old_test_entered','new_test_entered',
                       'old_exam_entered','new_exam_entered');


-- ── Summary ─────────────────────────────────────────────────────────────────

SELECT '=== BATCH 1 VERIFICATION COMPLETE ===' AS summary,
       NOW() AS verified_at;
