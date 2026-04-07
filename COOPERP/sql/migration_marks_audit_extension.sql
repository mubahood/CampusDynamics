-- ============================================================================
-- MIGRATION: Marks Module — Audit Schema Extension (B-05)
-- Database: campus_dynamics
-- Date:     2026-04-07
-- Author:   System
-- Depends:  marks_001 (sys_schema_migrations)
--
-- Extends the existing acad_marks_audit table with:
--   - action_type_ext: Sub-categorizes actions beyond the main action_type
--     (e.g. 'IMPORT', 'BULK_APPROVE', 'AUTO_SAVE', 'UNLOCK_REQUEST')
--   - old_cw_entered / new_cw_entered: Tracks the raw entered CW mark
--     (before weighting) alongside the existing weighted columns.
--   - old_test_entered / new_test_entered: Same for test marks.
--   - old_exam_entered / new_exam_entered: Same for exam marks.
--
-- This enables full before/after tracking at both the raw-entry and 
-- weighted-score levels, and distinguishes bulk operations from 
-- individual mark edits in audit analysis.
--
-- Addresses: P39 (INSERT events), P40 (change_reason), P43 (batch_id correlation)
-- ============================================================================

-- ── 1. Add columns idempotently ────────────────────────────────────────────

DROP PROCEDURE IF EXISTS _temp_marks_audit_ext;

DELIMITER //
CREATE PROCEDURE _temp_marks_audit_ext()
BEGIN
    -- action_type_ext
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'action_type_ext'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN action_type_ext VARCHAR(20) DEFAULT NULL
                COMMENT 'Sub-action: IMPORT, BULK_APPROVE, AUTO_SAVE, UNLOCK, etc.'
                AFTER action_type;
    END IF;

    -- old_cw_entered
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'old_cw_entered'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN old_cw_entered INT DEFAULT NULL
                COMMENT 'Raw CW mark entered (before weighting) — old value'
                AFTER old_cw_mark;
    END IF;

    -- new_cw_entered
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'new_cw_entered'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN new_cw_entered INT DEFAULT NULL
                COMMENT 'Raw CW mark entered (before weighting) — new value'
                AFTER old_cw_entered;
    END IF;

    -- old_test_entered
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'old_test_entered'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN old_test_entered INT DEFAULT NULL
                COMMENT 'Raw test mark entered — old value'
                AFTER old_test_mark;
    END IF;

    -- new_test_entered
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'new_test_entered'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN new_test_entered INT DEFAULT NULL
                COMMENT 'Raw test mark entered — new value'
                AFTER old_test_entered;
    END IF;

    -- old_exam_entered
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'old_exam_entered'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN old_exam_entered INT DEFAULT NULL
                COMMENT 'Raw exam mark entered — old value'
                AFTER old_exam_mark;
    END IF;

    -- new_exam_entered
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND COLUMN_NAME = 'new_exam_entered'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD COLUMN new_exam_entered INT DEFAULT NULL
                COMMENT 'Raw exam mark entered — new value'
                AFTER old_exam_entered;
    END IF;

    -- Index on action_type_ext for filtering
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_marks_audit'
          AND INDEX_NAME = 'idx_action_type_ext'
    ) THEN
        ALTER TABLE acad_marks_audit
            ADD INDEX idx_action_type_ext (action_type_ext);
    END IF;
END //
DELIMITER ;

CALL _temp_marks_audit_ext();
DROP PROCEDURE IF EXISTS _temp_marks_audit_ext;


-- ── 2. Register this migration ─────────────────────────────────────────────

INSERT INTO sys_schema_migrations (version, description, applied_by, rollback_ref)
SELECT 'marks_005', 'Extend acad_marks_audit with raw-entered columns and action_type_ext', 'system', 'rollback_marks_audit_extension.sql'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_schema_migrations WHERE version = 'marks_005');


-- ── 3. Verification ────────────────────────────────────────────────────────

SELECT COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_marks_audit'
  AND COLUMN_NAME IN ('action_type_ext','old_cw_entered','new_cw_entered',
                       'old_test_entered','new_test_entered',
                       'old_exam_entered','new_exam_entered')
ORDER BY ORDINAL_POSITION;
