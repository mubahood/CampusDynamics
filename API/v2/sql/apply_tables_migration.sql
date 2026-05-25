-- =============================================================================
-- Campus Dynamics — Student Application System
-- Migration: Create all tables required by apply.aspx and admissions.aspx APIs
-- Run against: campus_dynamics (main) AND campus_dynamics_portal (portal)
-- Compatible : MySQL 5.6+ and MariaDB 10+
-- Safe to re-run: IF NOT EXISTS / conditional ADD COLUMN pattern
-- Generated: 2026-05-25
-- =============================================================================

-- =============================================================================
-- SECTION 1: campus_dynamics (main database)
-- =============================================================================

USE campus_dynamics;

-- ── apply_intakes ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS apply_intakes (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    intake_year   INT          NOT NULL,
    intake_label  VARCHAR(100) NOT NULL,
    session_type  VARCHAR(30)  NOT NULL DEFAULT 'ALL',
    is_open       TINYINT(1)   NOT NULL DEFAULT 0,
    open_from     DATE         NULL,
    open_to       DATE         NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ai_open (is_open, intake_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO apply_intakes (intake_year, intake_label, session_type, is_open, open_from, open_to)
SELECT 2026, 'August 2026 Intake', 'ALL', 1, '2026-03-01', '2026-07-31'
WHERE NOT EXISTS (SELECT 1 FROM apply_intakes LIMIT 1);

-- ── apply_documents ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS apply_documents (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    stud_entry_no     VARCHAR(30)  NOT NULL,
    doc_type          VARCHAR(20)  NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    stored_path       VARCHAR(500) NOT NULL,
    file_size_bytes   INT          NOT NULL DEFAULT 0,
    uploaded_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ad_eno  (stud_entry_no),
    INDEX idx_ad_type (stud_entry_no, doc_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── apply_notifications ───────────────────────────────────────────────────────
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
CREATE TABLE IF NOT EXISTS apply_audit_log (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    stud_entry_no VARCHAR(30)  NOT NULL,
    actor         VARCHAR(100) NOT NULL,
    action        VARCHAR(50)  NOT NULL,
    detail        TEXT         NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_aal_eno (stud_entry_no),
    INDEX idx_aal_at  (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── acad_application_notes ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS acad_application_notes (
    note_id       INT AUTO_INCREMENT PRIMARY KEY,
    stud_entry_no VARCHAR(30)  NOT NULL,
    note_text     TEXT         NOT NULL,
    added_by      VARCHAR(100) NOT NULL,
    added_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ann_eno (stud_entry_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── acad_applications — add applicant-specific columns (MySQL 5.6 compatible) ──
-- Uses a helper procedure to avoid ADD COLUMN IF NOT EXISTS (MySQL 8+ only)

DROP PROCEDURE IF EXISTS _cd_add_col;
DELIMITER //
CREATE PROCEDURE _cd_add_col(
    IN p_db  VARCHAR(100),
    IN p_tbl VARCHAR(100),
    IN p_col VARCHAR(100),
    IN p_def TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = p_db AND TABLE_NAME = p_tbl AND COLUMN_NAME = p_col
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE _stmt FROM @_sql;
        EXECUTE _stmt;
        DEALLOCATE PREPARE _stmt;
    END IF;
END //
DELIMITER ;

CALL _cd_add_col('campus_dynamics', 'acad_applications', 'applicant_user_id',   'INT NULL');
CALL _cd_add_col('campus_dynamics', 'acad_applications', 'app_status',           "VARCHAR(30) NOT NULL DEFAULT 'DRAFT'");
CALL _cd_add_col('campus_dynamics', 'acad_applications', 'app_submitted_at',     'DATETIME NULL');
CALL _cd_add_col('campus_dynamics', 'acad_applications', 'app_last_updated_at',  'DATETIME NULL');
CALL _cd_add_col('campus_dynamics', 'acad_applications', 'app_created_at',       'DATETIME NULL DEFAULT CURRENT_TIMESTAMP');

CALL _cd_add_col('campus_dynamics', 'acad_applicant_choices', 'stud_reg_no', 'VARCHAR(50) NULL');

DROP PROCEDURE IF EXISTS _cd_add_col;

-- Indexes on acad_applications (safe: CREATE INDEX fails if exists, so wrapped)
DROP PROCEDURE IF EXISTS _cd_add_idx;
DELIMITER //
CREATE PROCEDURE _cd_add_idx(
    IN p_db  VARCHAR(100),
    IN p_tbl VARCHAR(100),
    IN p_idx VARCHAR(100),
    IN p_col VARCHAR(200)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = p_db AND TABLE_NAME = p_tbl AND INDEX_NAME = p_idx
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD INDEX `', p_idx, '` (', p_col, ')');
        PREPARE _stmt FROM @_sql;
        EXECUTE _stmt;
        DEALLOCATE PREPARE _stmt;
    END IF;
END //
DELIMITER ;

CALL _cd_add_idx('campus_dynamics', 'acad_applications', 'idx_aa_uid',    'applicant_user_id');
CALL _cd_add_idx('campus_dynamics', 'acad_applications', 'idx_aa_status',  'app_status');

DROP PROCEDURE IF EXISTS _cd_add_idx;

-- Backfill app_created_at
UPDATE acad_applications SET app_created_at = NOW() WHERE app_created_at IS NULL;

-- =============================================================================
-- SECTION 2: campus_dynamics_portal database
-- =============================================================================

USE campus_dynamics_portal;

-- ── apply_email_tokens ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS apply_email_tokens (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT          NOT NULL,
    token      VARCHAR(10)  NOT NULL,
    token_type VARCHAR(30)  NOT NULL,
    expires_at DATETIME     NOT NULL,
    used       TINYINT(1)   NOT NULL DEFAULT 0,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_aet_uid  (user_id),
    INDEX idx_aet_type (user_id, token_type, used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── my_aspnet_users and my_aspnet_membership — conditional column adds ─────────
-- Uses the same helper procedure pattern (MySQL 5.6 compatible)

DROP PROCEDURE IF EXISTS _cdp_add_col;
DELIMITER //
CREATE PROCEDURE _cdp_add_col(
    IN p_db  VARCHAR(100),
    IN p_tbl VARCHAR(100),
    IN p_col VARCHAR(100),
    IN p_def TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = p_db AND TABLE_NAME = p_tbl AND COLUMN_NAME = p_col
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE _stmt FROM @_sql;
        EXECUTE _stmt;
        DEALLOCATE PREPARE _stmt;
    END IF;
END //
DELIMITER ;

-- my_aspnet_users
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_users', 'user_type',      "VARCHAR(30) NULL DEFAULT NULL");
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_users', 'user_full_name', 'VARCHAR(200) NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_users', 'user_mobile',    'VARCHAR(30) NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_users', 'verified_email', 'VARCHAR(200) NULL');

-- my_aspnet_membership
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'passwordKey',                   'VARCHAR(500) NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'isLockedOut',                   'TINYINT(1) NOT NULL DEFAULT 0');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'lastLockoutDate',               'DATETIME NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'failedPasswordAttemptCount',    'INT NOT NULL DEFAULT 0');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'failedPasswordAttemptWindowStart', 'DATETIME NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'lastLoginDate',                 'DATETIME NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'lastPasswordChangedDate',       'DATETIME NULL');
CALL _cdp_add_col('campus_dynamics_portal', 'my_aspnet_membership', 'creationDate',                  'DATETIME NULL');

DROP PROCEDURE IF EXISTS _cdp_add_col;

-- Indexes on my_aspnet_users
DROP PROCEDURE IF EXISTS _cdp_add_idx;
DELIMITER //
CREATE PROCEDURE _cdp_add_idx(
    IN p_db  VARCHAR(100),
    IN p_tbl VARCHAR(100),
    IN p_idx VARCHAR(100),
    IN p_col VARCHAR(200)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = p_db AND TABLE_NAME = p_tbl AND INDEX_NAME = p_idx
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD INDEX `', p_idx, '` (', p_col, ')');
        PREPARE _stmt FROM @_sql;
        EXECUTE _stmt;
        DEALLOCATE PREPARE _stmt;
    END IF;
END //
DELIMITER ;

CALL _cdp_add_idx('campus_dynamics_portal', 'my_aspnet_users', 'idx_mau_type',  'user_type');
CALL _cdp_add_idx('campus_dynamics_portal', 'my_aspnet_users', 'idx_mau_email', 'name');

DROP PROCEDURE IF EXISTS _cdp_add_idx;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
-- Run this entire script as a MySQL root/admin user who can access both databases.
-- Verify with:
--   USE campus_dynamics;   SHOW TABLES LIKE 'apply_%';
--   USE campus_dynamics_portal; DESCRIBE my_aspnet_membership;
-- =============================================================================
