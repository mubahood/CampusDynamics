-- ============================================================================
-- MIGRATION: Marks Module — Deadline Schema Extension (B-04)
-- Database: campus_dynamics
-- Date:     2026-04-07
-- Author:   System
-- Depends:  marks_001 (sys_schema_migrations)
--
-- Extends the existing acad_deadlines table with:
--   - deadline_type: Categorizes deadlines as COURSEWORK, EXAM, SUBMISSION, or OTHER.
--     This enables separate CW and exam lock dates per programme/campus/semester.
--   - is_active: Soft-delete flag allowing admins to deactivate deadlines without removal.
--
-- The existing columns (ActivityName, campusid, studsession, semester, 
-- studyyear, acadyear, deadline, etc.) are preserved unchanged.
--
-- Addresses: P27 (one global lock), P28 (acad_deadlines never consulted),
--            P33 (no CW-specific lock separate from exam)
-- ============================================================================

-- ── 1. Add deadline_type column (safe: won't fail if already exists) ───────

-- Check if column exists first (MySQL-safe approach: try to add, ignore error)
-- We use a procedure to make ALTER TABLE idempotent.

DROP PROCEDURE IF EXISTS _temp_marks_deadline_ext;

DELIMITER //
CREATE PROCEDURE _temp_marks_deadline_ext()
BEGIN
    -- Add deadline_type if not exists
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_deadlines'
          AND COLUMN_NAME = 'deadline_type'
    ) THEN
        ALTER TABLE acad_deadlines
            ADD COLUMN deadline_type ENUM('COURSEWORK','EXAM','SUBMISSION','OTHER')
                NOT NULL DEFAULT 'OTHER'
                COMMENT 'Categorizes the deadline for granular lock control'
                AFTER ActivityName;
    END IF;

    -- Add is_active if not exists
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_deadlines'
          AND COLUMN_NAME = 'is_active'
    ) THEN
        ALTER TABLE acad_deadlines
            ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1
                COMMENT '1 = enforced, 0 = deactivated';
    END IF;

    -- Add index on new columns if not exists
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'acad_deadlines'
          AND INDEX_NAME = 'idx_deadline_type_active'
    ) THEN
        ALTER TABLE acad_deadlines
            ADD INDEX idx_deadline_type_active (deadline_type, is_active);
    END IF;
END //
DELIMITER ;

CALL _temp_marks_deadline_ext();
DROP PROCEDURE IF EXISTS _temp_marks_deadline_ext;


-- ── 2. Register this migration ─────────────────────────────────────────────

INSERT INTO sys_schema_migrations (version, description, applied_by, rollback_ref)
SELECT 'marks_004', 'Extend acad_deadlines with deadline_type and is_active', 'system', 'rollback_marks_deadline_extension.sql'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_schema_migrations WHERE version = 'marks_004');


-- ── 3. Verification ────────────────────────────────────────────────────────

SELECT COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'acad_deadlines'
  AND COLUMN_NAME IN ('deadline_type', 'is_active')
ORDER BY ORDINAL_POSITION;
