-- ═══════════════════════════════════════════════════════════════════════════
-- Knowledgebase Module — Database Migration
-- Campus Dynamics EMIS
-- Date: 2026-04-30
--
-- This migration creates category and article models for a reusable
-- Knowledgebase Management module in the Admin portal.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sys_knowledgebase_categories` (
    `ID`            INT             NOT NULL AUTO_INCREMENT,
    `category_key`  VARCHAR(160)    NOT NULL COMMENT 'Stable slug key',
    `title`         VARCHAR(200)    NOT NULL,
    `description`   TEXT            NULL,
    `photo_path`    VARCHAR(600)    NULL,
    `display_order` INT             NOT NULL DEFAULT 0,
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `created_by`    VARCHAR(120)    NOT NULL DEFAULT '',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by`    VARCHAR(120)    NULL,
    `updated_at`    DATETIME        NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_kb_category_key` (`category_key`),
    INDEX `idx_kb_category_order` (`is_active`, `display_order`, `title`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sys_knowledgebase_articles` (
    `ID`            INT             NOT NULL AUTO_INCREMENT,
    `category_id`   INT             NOT NULL,
    `article_key`   VARCHAR(180)    NOT NULL COMMENT 'Stable slug key',
    `title`         VARCHAR(250)    NOT NULL,
    `description`   TEXT            NULL,
    `content`       MEDIUMTEXT      NOT NULL,
    `photo_path`    VARCHAR(600)    NULL,
    `is_youtube_video` TINYINT(1)   NOT NULL DEFAULT 0,
    `youtube_url`   VARCHAR(500)    NULL,
    `display_order` INT             NOT NULL DEFAULT 0,
    `view_count`    INT             NOT NULL DEFAULT 0,
    `visibility`    VARCHAR(20)     NOT NULL DEFAULT 'BOTH' COMMENT 'STUDENTS | EMPLOYEES | BOTH',
    `status`        VARCHAR(20)     NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT | PUBLISHED | ARCHIVED',
    `created_by`    VARCHAR(120)    NOT NULL DEFAULT '',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by`    VARCHAR(120)    NULL,
    `updated_at`    DATETIME        NULL ON UPDATE CURRENT_TIMESTAMP,
    `published_at`  DATETIME        NULL,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_kb_article_key` (`article_key`),
    INDEX `idx_kb_article_cat` (`category_id`, `display_order`, `title`(100)),
    INDEX `idx_kb_article_status` (`status`, `visibility`, `display_order`),
    CONSTRAINT `fk_kb_article_category`
        FOREIGN KEY (`category_id`) REFERENCES `sys_knowledgebase_categories` (`ID`)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
