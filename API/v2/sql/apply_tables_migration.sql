-- =============================================================================
-- Campus Dynamics — Student Application System
-- Migration: Create all tables required by apply.aspx and admissions.aspx APIs
-- Run against: campus_dynamics (main) AND campus_dynamics_portal (portal)
-- Safe to re-run: uses CREATE TABLE IF NOT EXISTS + ALTER TABLE IF NOT EXISTS pattern
-- Generated: 2026-05-24
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SECTION 1: campus_dynamics (main database)
-- -----------------------------------------------------------------------------

USE campus_dynamics;

-- ── apply_intakes ─────────────────────────────────────────────────────────────
-- Defines which application cycles are currently open for submissions.
CREATE TABLE IF NOT EXISTS apply_intakes (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    intake_year   INT          NOT NULL,
    intake_label  VARCHAR(100) NOT NULL,          -- e.g. "August 2026 Intake"
    session_type  VARCHAR(30)  NOT NULL DEFAULT 'ALL', -- DAY, EVENING, WEEKEND, ALL
    is_open       TINYINT(1)   NOT NULL DEFAULT 0,
    open_from     DATE         NULL,
    open_to       DATE         NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ai_open (is_open, intake_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed: insert a default open intake if the table is empty
INSERT INTO apply_intakes (intake_year, intake_label, session_type, is_open, open_from, open_to)
SELECT 2026, 'August 2026 Intake', 'ALL', 1, '2026-03-01', '2026-07-31'
WHERE NOT EXISTS (SELECT 1 FROM apply_intakes LIMIT 1);

-- ── apply_documents ───────────────────────────────────────────────────────────
-- One row per uploaded document file per application.
CREATE TABLE IF NOT EXISTS apply_documents (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    stud_entry_no     VARCHAR(30)  NOT NULL,
    doc_type          VARCHAR(20)  NOT NULL,           -- PHOTO, OLEVEL, ALEVEL, NATID, OTHER
    original_filename VARCHAR(255) NOT NULL,
    stored_path       VARCHAR(500) NOT NULL,
    file_size_bytes   INT          NOT NULL DEFAULT 0,
    uploaded_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ad_eno     (stud_entry_no),
    INDEX idx_ad_type    (stud_entry_no, doc_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── apply_notifications ────────────────────────────────────────────────────────
-- In-app notifications delivered to applicants (user_id = my_aspnet_users.id).
CREATE TABLE IF NOT EXISTS apply_notifications (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT          NOT NULL,
    message    TEXT         NOT NULL,
    is_read    TINYINT(1)   NOT NULL DEFAULT 0,
    link       VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_an_uid  (user_id),
    INDEX idx_an_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── apply_audit_log ───────────────────────────────────────────────────────────
-- Immutable audit trail of every status change on an application.
CREATE TABLE IF NOT EXISTS apply_audit_log (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    stud_entry_no VARCHAR(30)  NOT NULL,
    actor         VARCHAR(100) NOT NULL,            -- staff username or 'APPLICANT'
    action        VARCHAR(50)  NOT NULL,            -- ADMITTED, REJECTED, NOTIFIED, etc.
    detail        TEXT         NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_aal_eno (stud_entry_no),
    INDEX idx_aal_at  (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── acad_application_notes ────────────────────────────────────────────────────
-- Staff reviewer notes attached to an application.
CREATE TABLE IF NOT EXISTS acad_application_notes (
    note_id       INT AUTO_INCREMENT PRIMARY KEY,
    stud_entry_no VARCHAR(30)  NOT NULL,
    note_text     TEXT         NOT NULL,
    added_by      VARCHAR(100) NOT NULL,
    added_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ann_eno (stud_entry_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── acad_applications — add applicant-specific columns ────────────────────────
-- These columns extend the existing acad_applications table used by the web
-- portal. All ADDs are wrapped in IF NOT EXISTS guards.

ALTER TABLE acad_applications
    ADD COLUMN IF NOT EXISTS applicant_user_id  INT          NULL    COMMENT 'my_aspnet_users.id of the applicant account',
    ADD COLUMN IF NOT EXISTS app_status         VARCHAR(30)  NOT NULL DEFAULT 'DRAFT'
        COMMENT 'DRAFT | SUBMITTED | UNDER_REVIEW | ADMITTED | REJECTED | WITHDRAWN',
    ADD COLUMN IF NOT EXISTS app_submitted_at   DATETIME     NULL,
    ADD COLUMN IF NOT EXISTS app_last_updated_at DATETIME    NULL,
    ADD COLUMN IF NOT EXISTS app_created_at     DATETIME     NULL DEFAULT CURRENT_TIMESTAMP;

-- Add indexes if missing (safe on existing tables because of IF NOT EXISTS)
ALTER TABLE acad_applications
    ADD INDEX IF NOT EXISTS idx_aa_uid    (applicant_user_id),
    ADD INDEX IF NOT EXISTS idx_aa_status (app_status);

-- ── acad_applicant_choices — ensure stud_reg_no column exists ─────────────────
ALTER TABLE acad_applicant_choices
    ADD COLUMN IF NOT EXISTS stud_reg_no VARCHAR(50) NULL COMMENT 'Filled once applicant is registered as student';

-- ── acad_applications — backfill app_created_at if NULL ──────────────────────
UPDATE acad_applications
SET app_created_at = NOW()
WHERE app_created_at IS NULL;

-- -----------------------------------------------------------------------------
-- SECTION 2: campus_dynamics_portal database
-- -----------------------------------------------------------------------------

USE campus_dynamics_portal;

-- ── apply_email_tokens ────────────────────────────────────────────────────────
-- OTP tokens for email verification and password reset (6-digit, 30-min expiry).
CREATE TABLE IF NOT EXISTS apply_email_tokens (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT          NOT NULL,              -- my_aspnet_users.id
    token      VARCHAR(10)  NOT NULL,              -- 6-digit OTP
    token_type VARCHAR(30)  NOT NULL,              -- EMAIL_VERIFY_OTP | PASSWORD_RESET_OTP
    expires_at DATETIME     NOT NULL,
    used       TINYINT(1)   NOT NULL DEFAULT 0,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_aet_uid  (user_id),
    INDEX idx_aet_type (user_id, token_type, used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── my_aspnet_users — add applicant columns if missing ───────────────────────
ALTER TABLE my_aspnet_users
    ADD COLUMN IF NOT EXISTS user_type      VARCHAR(30)  NULL DEFAULT NULL
        COMMENT 'NULL = normal student/staff; APPLICANT = applicant account',
    ADD COLUMN IF NOT EXISTS user_full_name VARCHAR(200) NULL,
    ADD COLUMN IF NOT EXISTS user_mobile    VARCHAR(30)  NULL,
    ADD COLUMN IF NOT EXISTS verified_email VARCHAR(200) NULL
        COMMENT 'Populated after OTP email verification';

ALTER TABLE my_aspnet_users
    ADD INDEX IF NOT EXISTS idx_mau_type  (user_type),
    ADD INDEX IF NOT EXISTS idx_mau_email (name);

-- ── my_aspnet_membership — ensure failedPasswordAttemptCount exists ───────────
ALTER TABLE my_aspnet_membership
    ADD COLUMN IF NOT EXISTS failedPasswordAttemptCount INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS failedPasswordAttemptWindowStart DATETIME NULL,
    ADD COLUMN IF NOT EXISTS isLockedOut    TINYINT(1)   NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS lastLockoutDate DATETIME    NULL,
    ADD COLUMN IF NOT EXISTS passwordKey   VARCHAR(500)  NULL
        COMMENT 'Base64 HMACSHA256 salt — replaces legacy passwordSalt for applicant accounts',
    ADD COLUMN IF NOT EXISTS lastLoginDate DATETIME NULL,
    ADD COLUMN IF NOT EXISTS lastPasswordChangedDate DATETIME NULL;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
-- After running, verify with:
--   SHOW TABLES LIKE 'apply_%';           -- in campus_dynamics
--   SHOW TABLES LIKE 'apply_email%';      -- in campus_dynamics_portal
--   DESCRIBE acad_applications;           -- confirm new columns
--   DESCRIBE my_aspnet_users;             -- confirm user_type, verified_email
-- =============================================================================
