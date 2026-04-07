-- ============================================================================
-- MIGRATION: Marks Module — Unlock Requests Table (B-03)
-- Database: campus_dynamics
-- Date:     2026-04-07
-- Author:   System
-- Depends:  marks_001 (sys_schema_migrations)
--
-- Creates the acad_mark_unlock_requests table that tracks teacher requests
-- to temporarily unlock a deadline-locked marksheet. The workflow is:
--   1. Teacher submits unlock request with mandatory reason.
--   2. Dean/Registrar reviews and approves (with time-limited expiry) or rejects.
--   3. On approval, the mark entry page allows edits until expires_at.
--   4. After expiry, the lock automatically re-engages.
--   5. The entire lifecycle is audited.
--
-- Addresses: P27, P29, P33 (locking granularity and unlock workflow)
-- ============================================================================

-- ── 1. Unlock Requests Table ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS acad_mark_unlock_requests (
    id              INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    requested_by    VARCHAR(50)     NOT NULL        COMMENT 'Teacher username requesting the unlock',
    course_id       VARCHAR(25)     DEFAULT NULL    COMMENT 'Specific course (NULL = programme-wide request)',
    progid          VARCHAR(25)     DEFAULT NULL    COMMENT 'Programme code if applicable',
    acadyear        VARCHAR(25)     NOT NULL        COMMENT 'Academic year context',
    semester        TINYINT UNSIGNED NOT NULL        COMMENT 'Semester number',
    deadline_type   ENUM('COURSEWORK','EXAM','SUBMISSION') NOT NULL COMMENT 'Which deadline type to unlock',
    reason          TEXT            NOT NULL        COMMENT 'Mandatory free-text reason from teacher',
    status          ENUM('PENDING','APPROVED','REJECTED','EXPIRED') NOT NULL DEFAULT 'PENDING' COMMENT 'Request lifecycle status',
    reviewed_by     VARCHAR(50)     DEFAULT NULL    COMMENT 'Dean/Registrar who reviewed',
    reviewed_at     DATETIME        DEFAULT NULL    COMMENT 'When the review happened',
    review_notes    VARCHAR(500)    DEFAULT NULL    COMMENT 'Reviewer comments (especially on rejection)',
    expires_at      DATETIME        DEFAULT NULL    COMMENT 'Unlock window expiry (approval only)',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When the request was created',
    INDEX idx_requested_by (requested_by),
    INDEX idx_status (status),
    INDEX idx_course_year (course_id, acadyear, semester),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Teacher unlock requests for deadline-locked marksheets — tracks full approval lifecycle';


-- ── 2. Register this migration ─────────────────────────────────────────────

INSERT INTO sys_schema_migrations (version, description, applied_by, rollback_ref)
SELECT 'marks_003', 'Create acad_mark_unlock_requests table', 'system', 'rollback_marks_unlock_requests.sql'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_schema_migrations WHERE version = 'marks_003');


-- ── 3. Verification ────────────────────────────────────────────────────────

SELECT 'acad_mark_unlock_requests' AS tbl, COUNT(*) AS rows FROM acad_mark_unlock_requests;
