-- ============================================================================
--  Exam configuration — mark-entry WINDOWS (opens .. closes)
--  Muteesa I Royal University                                     2026-09-02
--
--  acad_deadlines holds one date: the day entry stops. There is nowhere to say
--  when it STARTS, so "coursework entry runs from 1 to 30 September" cannot be
--  expressed — a lecturer can type marks the moment a course exists, and the only
--  control is a closing date that arrives without warning.
--
--  These four settings give each kind of entry a start and an end, and because
--  they live in acad_exam_config they inherit its scoping: a window can be set for
--  the whole university, or for one campus, faculty or programme, for a particular
--  year and semester. acad_deadlines can only do campus and study system.
--
--  HOW THE THREE CONTROLS COMBINE, most restrictive wins:
--      the switch      coursework.entry.enabled   — closed by hand, any time
--      the window      opens .. closes            — the schedule
--      acad_deadlines  the legacy closing date    — still honoured
--  Entry is open only when all three allow it, and the portal says WHICH one is
--  closing it, so a lecturer is never told the wrong reason.
--
--  Values are 'yyyy-MM-dd HH:mm' in server local time, or empty for "no limit".
--  Empty means unbounded, NOT closed: a half-configured window must not lock
--  anybody out.
--
--  Re-runnable. The ENUM is widened only if DATETIME is not already a member, so a
--  second run is a no-op rather than an error.
-- ============================================================================

-- Widen value_type to carry a date and time.
SET @has := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_exam_config'
    AND COLUMN_NAME = 'value_type' AND COLUMN_TYPE LIKE '%DATETIME%'
);
SET @sql := IF(@has = 0,
  'ALTER TABLE acad_exam_config MODIFY value_type ENUM(''BOOL'',''INT'',''DECIMAL'',''DATE'',''DATETIME'',''TEXT'') NOT NULL DEFAULT ''BOOL''',
  'SELECT ''value_type already carries DATETIME'' AS note');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- The windows themselves, seeded EMPTY at global scope.
-- Empty is deliberate: installing this file must not start gating anything. An
-- administrator sets the dates when they want the schedule to begin applying.
INSERT IGNORE INTO acad_exam_config
  (config_key, scope_type, scope_value, acad_year, semester, value_type, config_value, notes, updated_by, updated_at)
VALUES
  ('coursework.entry.opens', 'GLOBAL','','',0,'DATETIME','','When coursework mark entry opens. Empty means no start limit.','seed',NOW()),
  ('coursework.entry.closes','GLOBAL','','',0,'DATETIME','','When coursework mark entry closes. Empty means no end limit.','seed',NOW()),
  ('exam.entry.opens',       'GLOBAL','','',0,'DATETIME','','When final exam mark entry opens. Empty means no start limit.','seed',NOW()),
  ('exam.entry.closes',      'GLOBAL','','',0,'DATETIME','','When final exam mark entry closes. Empty means no end limit.','seed',NOW());

-- ── checks ──────────────────────────────────────────────────────────────────
SELECT COLUMN_TYPE AS value_type_now FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'acad_exam_config' AND COLUMN_NAME = 'value_type';

SELECT config_key, value_type, IF(config_value='','(not set)',config_value) AS value, notes
FROM acad_exam_config WHERE config_key LIKE '%.entry.open%' OR config_key LIKE '%.entry.close%'
ORDER BY config_key;
