-- Migration: create_api_tokens_table
-- Logical database: main
-- Purpose: Create the API token persistence table used by API v2.

CREATE TABLE IF NOT EXISTS api_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    token VARCHAR(64) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) NOT NULL DEFAULT 'student',
    full_name VARCHAR(200) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    last_used DATETIME NULL,
    ip_address VARCHAR(45) NULL,
    UNIQUE KEY uk_api_tokens_token (token),
    KEY ix_api_tokens_user_id (user_id),
    KEY ix_api_tokens_expires_at (expires_at),
    KEY ix_api_tokens_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
