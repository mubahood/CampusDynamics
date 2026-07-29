-- ============================================================
-- ODEL assignment-management schema (idempotent). Run on PRODUCTION
-- campus_dynamics_portal so the new assignment features work even if the
-- app-level self-heal (OdelCore.EnsureAssignmentSchema) lacks ALTER/CREATE
-- privileges. Safe to run repeatedly.
-- ============================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS _odel_addcol $$
CREATE PROCEDURE _odel_addcol(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl VARCHAR(400))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tbl AND COLUMN_NAME=col) THEN
    SET @s = CONCAT('ALTER TABLE `',tbl,'` ADD COLUMN ',ddl);
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END $$
DELIMITER ;

CALL _odel_addcol('odel_assignment','sort_order','INT NOT NULL DEFAULT 0');
CALL _odel_addcol('odel_assignment','published_at','DATETIME NULL');
CALL _odel_addcol('odel_assignment','updated_at','DATETIME NULL');
DROP PROCEDURE IF EXISTS _odel_addcol;

CREATE TABLE IF NOT EXISTS odel_assignment_extension (
  id             INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  assignment_id  INT UNSIGNED NOT NULL,
  regno          CHAR(25) NOT NULL,
  due_at         DATETIME NULL,
  late_until     DATETIME NULL,
  extra_attempts INT NOT NULL DEFAULT 0,
  reason         VARCHAR(250) NULL,
  created_by     INT NULL,
  created_at     DATETIME NULL,
  UNIQUE KEY uq_ext (assignment_id, regno),
  KEY ix_asg (assignment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- backfill order/audit for existing rows (harmless if already set)
UPDATE odel_assignment SET sort_order=id WHERE sort_order=0;
UPDATE odel_assignment SET published_at=created_at WHERE is_published=1 AND published_at IS NULL;
UPDATE odel_assignment SET updated_at=created_at WHERE updated_at IS NULL;
