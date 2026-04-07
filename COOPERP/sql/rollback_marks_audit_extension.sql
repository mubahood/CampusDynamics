-- ============================================================================
-- ROLLBACK: Marks Module — Audit Schema Extension (B-05)
-- Reverses: migration_marks_audit_extension.sql (marks_005)
-- Database: campus_dynamics
-- WARNING:  Removes extended audit columns from acad_marks_audit.
--           Any data in these columns will be lost.
-- ============================================================================

-- Remove migration record
DELETE FROM sys_schema_migrations WHERE version = 'marks_005';

-- Drop columns idempotently
DROP PROCEDURE IF EXISTS _temp_rollback_audit_ext;

DELIMITER //
CREATE PROCEDURE _temp_rollback_audit_ext()
BEGIN
    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND INDEX_NAME = 'idx_action_type_ext'
    ) THEN
        ALTER TABLE acad_marks_audit DROP INDEX idx_action_type_ext;
    END IF;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'new_exam_entered') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN new_exam_entered;
    END IF;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'old_exam_entered') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN old_exam_entered;
    END IF;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'new_test_entered') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN new_test_entered;
    END IF;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'old_test_entered') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN old_test_entered;
    END IF;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'new_cw_entered') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN new_cw_entered;
    END IF;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'old_cw_entered') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN old_cw_entered;
    END IF;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_marks_audit' AND COLUMN_NAME = 'action_type_ext') THEN
        ALTER TABLE acad_marks_audit DROP COLUMN action_type_ext;
    END IF;
END //
DELIMITER ;

CALL _temp_rollback_audit_ext();
DROP PROCEDURE IF EXISTS _temp_rollback_audit_ext;
