-- ============================================================
--  Requisition Management System — Database Schema
--  Campus Dynamics MRU · campus_dynamics DB
--  Compatible: MySQL 5.6+
--  Safe to re-run: uses CREATE TABLE IF NOT EXISTS
-- ============================================================

-- ─────────────────────────────────────────────────────────────
--  1. sys_requisitions — Master Requisition Table
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_requisitions` (
  `ID`                     INT            NOT NULL AUTO_INCREMENT,
  `req_number`             VARCHAR(20)    NOT NULL,
  `title`                  VARCHAR(255)   NOT NULL,
  `description`            TEXT,
  `req_type`               VARCHAR(20)    NOT NULL DEFAULT 'GOODS',
  `priority`               VARCHAR(10)    NOT NULL DEFAULT 'MEDIUM',
  `status`                 VARCHAR(30)    NOT NULL DEFAULT 'DRAFT',
  `total_amount`           DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
  `currency`               VARCHAR(5)     NOT NULL DEFAULT 'UGX',
  `financial_year`         VARCHAR(10),
  `period_label`           VARCHAR(50),

  -- Requester
  `requester_id`           INT,
  `requester_name`         VARCHAR(150),
  `requester_email`        VARCHAR(150),
  `requester_phone`        VARCHAR(30),
  `department`             VARCHAR(150),
  `section`                VARCHAR(100),

  -- Supervisor Stage
  `supervisor_id`          INT,
  `supervisor_name`        VARCHAR(150),
  `supervisor_action`      VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
  `supervisor_remarks`     TEXT,
  `supervisor_at`          DATETIME,

  -- Bursar Stage
  `bursar_action`          VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
  `bursar_remarks`         TEXT,
  `bursar_route`           VARCHAR(20)    NOT NULL DEFAULT 'FINANCE',
  `bursar_processed_by`    VARCHAR(150),
  `bursar_at`              DATETIME,

  -- VC Stage
  `vc_action`              VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
  `vc_remarks`             TEXT,
  `vc_processed_by`        VARCHAR(150),
  `vc_at`                  DATETIME,

  -- Procurement Stage
  `procurement_status`     VARCHAR(50),
  `procurement_remarks`    TEXT,
  `procurement_processed_by` VARCHAR(150),
  `procurement_at`         DATETIME,
  `lpo_number`             VARCHAR(50),

  -- Finance Stage
  `finance_action`         VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
  `finance_remarks`        TEXT,
  `finance_processed_by`   VARCHAR(150),
  `finance_at`             DATETIME,
  `payment_method`         VARCHAR(30),
  `payment_ref`            VARCHAR(100),
  `payment_date`           DATE,
  `ledger_ref`             VARCHAR(100),
  `ledger_posted`          TINYINT(1)     NOT NULL DEFAULT 0,
  `ledger_posted_at`       DATETIME,

  -- Meta
  `submitted_at`           DATETIME,
  `created_by`             VARCHAR(100),
  `created_at`             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted`             TINYINT(1)     NOT NULL DEFAULT 0,

  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_req_number` (`req_number`),
  KEY `idx_status` (`status`),
  KEY `idx_requester_id` (`requester_id`),
  KEY `idx_supervisor_id` (`supervisor_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ─────────────────────────────────────────────────────────────
--  2. sys_requisition_items — Line Items
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_requisition_items` (
  `ID`              INT           NOT NULL AUTO_INCREMENT,
  `requisition_id`  INT           NOT NULL,
  `item_no`         INT           NOT NULL DEFAULT 1,
  `description`     VARCHAR(500)  NOT NULL,
  `unit`            VARCHAR(30)   NOT NULL DEFAULT 'pcs',
  `qty`             DECIMAL(10,2) NOT NULL DEFAULT 1.00,
  `unit_price`      DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `total_price`     DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `category`        VARCHAR(100),
  `notes`           TEXT,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  KEY `idx_req_items` (`requisition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ─────────────────────────────────────────────────────────────
--  3. sys_requisition_audit — Full Audit Trail
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_requisition_audit` (
  `ID`              INT           NOT NULL AUTO_INCREMENT,
  `requisition_id`  INT           NOT NULL,
  `action_code`     VARCHAR(50)   NOT NULL,
  `old_status`      VARCHAR(30),
  `new_status`      VARCHAR(30),
  `actor_name`      VARCHAR(150),
  `actor_role`      VARCHAR(80),
  `remarks`         TEXT,
  `ip_address`      VARCHAR(45),
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  KEY `idx_audit_req` (`requisition_id`),
  KEY `idx_audit_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ─────────────────────────────────────────────────────────────
--  4. sys_requisition_attachments — Supporting Documents
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_requisition_attachments` (
  `ID`              INT           NOT NULL AUTO_INCREMENT,
  `requisition_id`  INT           NOT NULL,
  `file_name`       VARCHAR(255)  NOT NULL,
  `file_path`       VARCHAR(500)  NOT NULL,
  `file_size`       INT           NOT NULL DEFAULT 0,
  `file_type`       VARCHAR(20),
  `uploaded_by`     VARCHAR(150),
  `uploaded_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  KEY `idx_attach_req` (`requisition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ─────────────────────────────────────────────────────────────
--  Verify
-- ─────────────────────────────────────────────────────────────
SELECT 'sys_requisitions'         AS tbl, COUNT(*) AS rows FROM sys_requisitions
UNION ALL
SELECT 'sys_requisition_items'    AS tbl, COUNT(*) AS rows FROM sys_requisition_items
UNION ALL
SELECT 'sys_requisition_audit'    AS tbl, COUNT(*) AS rows FROM sys_requisition_audit
UNION ALL
SELECT 'sys_requisition_attachments' AS tbl, COUNT(*) AS rows FROM sys_requisition_attachments;
