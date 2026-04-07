-- ═══════════════════════════════════════════════════════════════════════
-- Rollback: Remove Backfilled Teaching Assignments
-- Reverses: migration_marks_backfill_assignments.sql (marks_006)
-- Task:     B-07
-- ═══════════════════════════════════════════════════════════════════════
--
-- Only removes rows that were backfilled by SYSTEM_BACKFILL.
-- Manually created assignments are preserved.
-- ═══════════════════════════════════════════════════════════════════════

-- Step 1: Count rows to be removed
SELECT COUNT(*) AS rows_to_remove
FROM acad_teaching_assignments
WHERE assigned_by = 'SYSTEM_BACKFILL';

-- Step 2: Remove backfilled rows only
DELETE FROM acad_teaching_assignments
WHERE assigned_by = 'SYSTEM_BACKFILL';

-- Step 3: Verify
SELECT COUNT(*) AS remaining_assignments FROM acad_teaching_assignments;

-- Step 4: Remove migration record
DELETE FROM sys_schema_migrations WHERE version = 'marks_006';

SELECT 'Rollback marks_006 (assignment backfill) complete.' AS result;
