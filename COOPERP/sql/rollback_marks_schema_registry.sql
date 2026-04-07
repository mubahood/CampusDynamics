-- ============================================================================
-- ROLLBACK: Marks Module — Schema Version Registry (B-01)
-- Reverses: migration_marks_schema_registry.sql (marks_001)
-- Database: campus_dynamics
-- WARNING:  Dropping sys_schema_migrations removes ALL migration tracking.
--           Only use this if also rolling back ALL marks-module migrations.
-- ============================================================================

-- Remove the version record first (in case partial rollback)
DELETE FROM sys_schema_migrations WHERE version = 'marks_001';

-- Drop the table entirely
DROP TABLE IF EXISTS sys_schema_migrations;
