-- ============================================================================
-- ROLLBACK: Marks Module — Unlock Requests Table (B-03)
-- Reverses: migration_marks_unlock_requests.sql (marks_003)
-- Database: campus_dynamics
-- WARNING:  This will lose all unlock request data.
-- ============================================================================

-- Remove migration record
DELETE FROM sys_schema_migrations WHERE version = 'marks_003';

-- Drop the table
DROP TABLE IF EXISTS acad_mark_unlock_requests;
