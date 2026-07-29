-- ============================================================
-- Course De-dup — Phase 1a: SCHEMA (idempotent, additive only)
-- Adds the canonical subject layer + course-state columns +
-- reviewable merge map + audit trail. Changes NO existing data.
-- ============================================================

-- helper: add a column only if missing (MySQL 5.6 has no IF NOT EXISTS)
DELIMITER $$
DROP PROCEDURE IF EXISTS _cd_addcol $$
CREATE PROCEDURE _cd_addcol(IN db VARCHAR(64), IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl VARCHAR(400))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA=db AND TABLE_NAME=tbl AND COLUMN_NAME=col) THEN
    SET @s = CONCAT('ALTER TABLE `',db,'`.`',tbl,'` ADD COLUMN ',ddl);
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END $$
DELIMITER ;

-- 1) canonical subject catalog (non-destructive grouping layer, category B)
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_subject (
  subject_id     INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subject_name   VARCHAR(250) NOT NULL,
  norm_name      VARCHAR(250) NOT NULL,
  default_credit DOUBLE NULL,
  is_shared      TINYINT NOT NULL DEFAULT 0,
  course_count   INT NOT NULL DEFAULT 0,
  created_at     DATETIME NULL,
  updated_at     DATETIME NULL,
  UNIQUE KEY uq_norm (norm_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2) course-state + subject link columns on the catalog
CALL _cd_addcol('campus_dynamics','acad_course','subject_id',           'subject_id INT UNSIGNED NULL');
CALL _cd_addcol('campus_dynamics','acad_course','course_state',         "course_state ENUM('ACTIVE','MERGED','ARCHIVED') NOT NULL DEFAULT 'ACTIVE'");
CALL _cd_addcol('campus_dynamics','acad_course','merged_into',          'merged_into CHAR(25) NULL');
CALL _cd_addcol('campus_dynamics','acad_course','merged_at',            'merged_at DATETIME NULL');
CALL _cd_addcol('campus_dynamics','acad_course','specialisation_scope', 'specialisation_scope INT UNSIGNED NULL');
CALL _cd_addcol('campus_dynamics','acad_course','dedup_category',       "dedup_category ENUM('A_WITHIN_PROG','B_CROSS_PROG','C_ORPHAN','D_SPECIALISATION','SINGLETON') NULL");

-- 3) reviewable merge map (staging; registry-editable; drives execution)
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_course_merge_map (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  category       ENUM('A_WITHIN_PROG','B_CROSS_PROG','C_ORPHAN','D_SPECIALISATION') NOT NULL,
  progcode       CHAR(25) NULL,
  subject_name   VARCHAR(250) NULL,
  loser_code     CHAR(25) NOT NULL,
  survivor_code  CHAR(25) NULL,
  loser_results  INT NOT NULL DEFAULT 0,
  loser_regs     INT NOT NULL DEFAULT 0,
  survivor_results INT NOT NULL DEFAULT 0,
  survivor_regs  INT NOT NULL DEFAULT 0,
  loser_cu       DOUBLE NULL,
  survivor_cu    DOUBLE NULL,
  cu_conflict    TINYINT NOT NULL DEFAULT 0,
  student_overlap INT NOT NULL DEFAULT 0,
  decision       ENUM('PENDING','MERGE','KEEP','ARCHIVE','MANUAL') NOT NULL DEFAULT 'PENDING',
  reviewer       VARCHAR(100) NULL,
  reviewed_at    DATETIME NULL,
  notes          TEXT NULL,
  created_at     DATETIME NULL,
  KEY k_cat (category), KEY k_loser (loser_code), KEY k_decision (decision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 4) immutable audit of every row moved/re-keyed during a merge
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_course_merge_audit (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  run_tag      VARCHAR(40) NOT NULL,
  phase        VARCHAR(40) NOT NULL,
  db_name      VARCHAR(64) NOT NULL,
  tbl          VARCHAR(64) NOT NULL,
  action       VARCHAR(40) NOT NULL,     -- REKEY | DEDUP_DELETE | STATE | RELINK
  loser_code   CHAR(25) NULL,
  survivor_code CHAR(25) NULL,
  pk_ref       VARCHAR(120) NULL,        -- identifying key of the affected row
  detail       TEXT NULL,
  rows_affected INT NULL,
  at_ts        DATETIME NULL,
  KEY k_run (run_tag), KEY k_tbl (tbl)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP PROCEDURE IF EXISTS _cd_addcol;
