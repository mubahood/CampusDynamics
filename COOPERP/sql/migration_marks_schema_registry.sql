-- ============================================================================
-- MIGRATION: Marks Module — Schema Version Registry (B-01)
-- Database: campus_dynamics
-- Date:     2026-04-07
-- Author:   System
--
-- Creates the sys_schema_migrations table to track all applied migrations.
-- Each migration script writes one row upon successful execution.
-- Rollback scripts reference the version to guarantee correct undo ordering.
--
-- This is a foundational table: all subsequent marks-module migrations
-- depend on it for version tracking and deployment gating.
-- ============================================================================

-- ── 1. Schema Migrations Registry ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS sys_schema_migrations (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version         VARCHAR(50)     NOT NULL        COMMENT 'Migration version label, e.g. marks_001',
    description     VARCHAR(250)    NOT NULL        COMMENT 'Short human-readable description',
    applied_by      VARCHAR(50)     NOT NULL        COMMENT 'Username or system actor that ran the migration',
    applied_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When the migration was applied',
    checksum        VARCHAR(64)     DEFAULT NULL    COMMENT 'SHA-256 of the migration file for tamper detection',
    rollback_ref    VARCHAR(100)    DEFAULT NULL    COMMENT 'Filename of the corresponding rollback script',
    verified_by     VARCHAR(50)     DEFAULT NULL    COMMENT 'Who verified the migration post-apply',
    verified_at     DATETIME        DEFAULT NULL    COMMENT 'When verification was performed',
    UNIQUE KEY uq_version (version),
    INDEX idx_applied_at (applied_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Schema migration version registry — tracks all applied DB migrations';


-- ── 2. Register this migration ─────────────────────────────────────────────

INSERT INTO sys_schema_migrations (version, description, applied_by, rollback_ref)
SELECT 'marks_001', 'Create sys_schema_migrations registry table', 'system', 'rollback_marks_schema_registry.sql'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_schema_migrations WHERE version = 'marks_001');


-- ── 3. Verification ────────────────────────────────────────────────────────

SELECT 'sys_schema_migrations' AS tbl, COUNT(*) AS rows FROM sys_schema_migrations;
