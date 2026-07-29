-- ============================================================================
--  ID Card Module — schema (Phase 0). Idempotent; matches IDCardService.EnsureSchema.
--  DB: campus_dynamics (main) — same DB as acad_student.id_card_status, eadmin
--  controller, and reachable cross-DB by the eportal app.
--  MySQL 5.6 compatible (no partial indexes; one-active-request enforced in code).
-- ============================================================================

CREATE TABLE IF NOT EXISTS idcard_requests (
  id                     INT PRIMARY KEY AUTO_INCREMENT,
  request_no             VARCHAR(20) NOT NULL,
  requester_type         VARCHAR(10) NOT NULL,          -- STUDENT | STAFF
  regno                  VARCHAR(35) NULL,              -- students (acad_student.regno)
  emp_id                 INT NULL,                      -- staff (hrm_employee.empID)
  card_type              VARCHAR(15) NOT NULL,          -- NEW | REPLACEMENT
  status                 VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
  photo_ref              VARCHAR(255) NULL,
  photo_confirmed        TINYINT NOT NULL DEFAULT 0,
  guidelines_ack         TINYINT NOT NULL DEFAULT 0,
  finance_ok             TINYINT NULL,
  finance_snapshot_json  TEXT NULL,
  replacement_fee_ref    VARCHAR(60) NULL,
  replacement_fee_date   DATE NULL,
  replacement_fee_method VARCHAR(20) NULL,              -- DFCU | AIRTEL
  replacement_fee_notes  VARCHAR(255) NULL,
  window_id              INT NULL,
  halt_reason            VARCHAR(255) NULL,
  submitted_at           DATETIME NULL,
  approved_at            DATETIME NULL,
  printed_at             DATETIME NULL,
  ready_at               DATETIME NULL,
  collected_at           DATETIME NULL,
  approved_by            VARCHAR(150) NULL,
  printed_by             VARCHAR(150) NULL,
  collected_by           VARCHAR(150) NULL,
  notes                  VARCHAR(255) NULL,
  created_by             VARCHAR(150) NULL,
  created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             DATETIME NULL,
  UNIQUE KEY uq_request_no (request_no),
  KEY ix_status (status),
  KEY ix_regno (regno),
  KEY ix_emp (emp_id),
  KEY ix_type (requester_type),
  KEY ix_window (window_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS idcard_request_events (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  request_id  INT NOT NULL,
  from_status VARCHAR(20) NULL,
  to_status   VARCHAR(20) NOT NULL,
  actor       VARCHAR(150) NULL,
  actor_role  VARCHAR(40) NULL,
  channel     VARCHAR(12) NULL,          -- eportal | eadmin | api | system
  note        VARCHAR(500) NULL,
  email_sent  TINYINT NULL,             -- 1 ok, 0 failed, NULL not attempted
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_req (request_id),
  KEY ix_to (to_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS idcard_windows (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  title           VARCHAR(150) NOT NULL,
  requester_scope VARCHAR(10) NOT NULL DEFAULT 'BOTH',  -- STUDENT | STAFF | BOTH
  opens_at        DATETIME NOT NULL,
  closes_at       DATETIME NOT NULL,
  is_active       TINYINT NOT NULL DEFAULT 1,
  notes           VARCHAR(255) NULL,
  created_by      VARCHAR(150) NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_active (is_active),
  KEY ix_range (opens_at, closes_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
