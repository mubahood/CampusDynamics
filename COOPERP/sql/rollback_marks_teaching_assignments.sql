-- ============================================================================
-- ROLLBACK: Marks Module — Teaching Assignments Table (B-02)
-- Reverses: migration_marks_teaching_assignments.sql (marks_002)
-- Database: campus_dynamics
-- WARNING:  This will lose all teaching assignment data.
--           Ensure a backup exists before running.
-- ============================================================================

-- Remove migration record
DELETE FROM sys_schema_migrations WHERE version = 'marks_002';

-- Drop the table
DROP TABLE IF EXISTS acad_teaching_assignments;
