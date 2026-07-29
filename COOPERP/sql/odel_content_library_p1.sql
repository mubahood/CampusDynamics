-- ============================================================================
--  ODEL Content Library — Phase 1 schema (ADDITIVE, non-breaking)
--
--  Introduces Chapter level, a reusable Material Library, and the many-to-many
--  topic<->material link. OLD columns (odel_material.topic_id/type/sort_order/
--  is_published) are KEPT for now so the existing UI keeps working until the new
--  builder/service go live. Content is near-greenfield (1 topic, 0 materials).
--
--  Idempotent: safe to re-run. Run against campus_dynamics_portal.
-- ============================================================================

-- 1) Chapters ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS odel_chapter (
  id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  space_id     INT UNSIGNED NOT NULL,
  title        VARCHAR(250) NOT NULL,
  sort_order   INT NOT NULL DEFAULT 0,
  is_published TINYINT NOT NULL DEFAULT 0,
  is_system    TINYINT NOT NULL DEFAULT 0,          -- 1 = undeletable "General" chapter
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NULL,
  KEY ix_space (space_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2) Topic <-> Material link (reuse; per-link order + student publish) --------
CREATE TABLE IF NOT EXISTS odel_topic_material (
  id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  topic_id     INT UNSIGNED NOT NULL,
  material_id  INT UNSIGNED NOT NULL,
  sort_order   INT NOT NULL DEFAULT 0,
  is_published TINYINT NOT NULL DEFAULT 0,           -- student-visible in THIS topic
  added_by     INT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_link (topic_id, material_id),
  KEY ix_topic (topic_id, sort_order),
  KEY ix_material (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 3) Topic: add chapter grouping + system flag -------------------------------
--    (ALTER IGNORE / conditional adds are done in code; here plain ADD — the
--     stored procedure below makes each add idempotent for re-runs.)

DROP PROCEDURE IF EXISTS odel_addcol;
DELIMITER //
CREATE PROCEDURE odel_addcol(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl VARCHAR(255))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tbl AND COLUMN_NAME=col) THEN
    SET @s = CONCAT('ALTER TABLE ', tbl, ' ADD COLUMN ', col, ' ', ddl);
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END //
DELIMITER ;

CALL odel_addcol('odel_topic', 'chapter_id', 'INT UNSIGNED NULL');
CALL odel_addcol('odel_topic', 'is_system',  'TINYINT NOT NULL DEFAULT 0');
CALL odel_addcol('odel_topic', 'updated_at', 'DATETIME NULL');

-- 4) Material -> Library item (additive; old cols kept) ----------------------
CALL odel_addcol('odel_material', 'owner_empid', 'INT NULL');
CALL odel_addcol('odel_material', 'kind',        "VARCHAR(10) NULL");   -- YOUTUBE|READING|PAGE|LINK
CALL odel_addcol('odel_material', 'description', 'VARCHAR(500) NULL');
CALL odel_addcol('odel_material', 'visibility',  "VARCHAR(8) NOT NULL DEFAULT 'PRIVATE'");
CALL odel_addcol('odel_material', 'category',    'VARCHAR(40) NULL');
CALL odel_addcol('odel_material', 'tags',        'VARCHAR(400) NULL');
CALL odel_addcol('odel_material', 'space_id',    'INT UNSIGNED NULL');
CALL odel_addcol('odel_material', 'updated_at',  'DATETIME NULL');

DROP PROCEDURE IF EXISTS odel_addcol;

-- library items are not topic-owned: relax the legacy NOT NULL columns
ALTER TABLE odel_material MODIFY topic_id INT UNSIGNED NULL;
ALTER TABLE odel_material MODIFY type VARCHAR(6) NULL;

-- 5) Seed the undeletable "General" chapter + topic for every existing space --
INSERT INTO odel_chapter (space_id, title, sort_order, is_published, is_system, created_at)
SELECT sp.id, 'General', 0, 1, 1, NOW()
FROM odel_course_space sp
WHERE NOT EXISTS (SELECT 1 FROM odel_chapter c WHERE c.space_id=sp.id AND c.is_system=1);

-- move any existing chapter-less topics under their space's General chapter
UPDATE odel_topic t
JOIN odel_chapter c ON c.space_id=t.space_id AND c.is_system=1
SET t.chapter_id=c.id
WHERE t.chapter_id IS NULL OR t.chapter_id=0;

-- ensure a system "General" topic exists per space
INSERT INTO odel_topic (space_id, chapter_id, title, sort_order, is_published, is_system, created_at)
SELECT sp.id, c.id, 'General', 0, 1, 1, NOW()
FROM odel_course_space sp
JOIN odel_chapter c ON c.space_id=sp.id AND c.is_system=1
WHERE NOT EXISTS (SELECT 1 FROM odel_topic t WHERE t.space_id=sp.id AND t.is_system=1);

SELECT (SELECT COUNT(*) FROM odel_chapter) chapters,
       (SELECT COUNT(*) FROM odel_topic WHERE is_system=1) system_topics,
       (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='odel_material' AND COLUMN_NAME='kind') has_kind,
       (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='odel_topic_material') has_link;
