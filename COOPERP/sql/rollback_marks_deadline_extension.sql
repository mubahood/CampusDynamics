-- ============================================================================
-- ROLLBACK: Marks Module — Deadline Schema Extension (B-04)
-- Reverses: migration_marks_deadline_extension.sql (marks_004)
-- Database: campus_dynamics
-- WARNING:  Removes deadline_type and is_active columns from acad_deadlines.
--           Any data stored in these columns will be lost.
-- ============================================================================

-- Remove migration record
DELETE FROM sys_schema_migrations WHERE version = 'marks_004';

-- Drop index first
DROP PROCEDURE IF EXISTS _temp_rollback_deadline_ext;

DELIMITER //
CREATE PROCEDURE _temp_rollback_deadline_ext()
BEGIN
    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_deadlines'
          AND INDEX_NAME = 'idx_deadline_type_active'
    ) THEN
        ALTER TABLE acad_deadlines DROP INDEX idx_deadline_type_active;
    END IF;

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_deadlines'
          AND COLUMN_NAME = 'is_active'
    ) THEN
        ALTER TABLE acad_deadlines DROP COLUMN is_active;
    END IF;

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_deadlines'
          AND COLUMN_NAME = 'deadline_type'
    ) THEN
        ALTER TABLE acad_deadlines DROP COLUMN deadline_type;
    END IF;
END //
DELIMITER ;

CALL _temp_rollback_deadline_ext();
DROP PROCEDURE IF EXISTS _temp_rollback_deadline_ext;
