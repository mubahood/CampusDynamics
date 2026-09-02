-- ============================================================================
--  Exam configuration — scoped policy switches for the examinations module
--  Muteesa I Royal University                                     2026-09-02
--
--  WHAT ALREADY EXISTS, and why this is not a fourth copy of it:
--
--    acad_deadlines        per campus / year / semester / study system, typed
--                          COURSEWORK | EXAM | SUBMISSION. Answers "by WHEN".
--    acad_results_lock     one global row, the older blunt version of the same
--                          idea. MarksDeadlineService already treats it as a
--                          fallback. Answers "by when", globally.
--    acad_examsettings     per marksheet: the CW/exam split and question maxima
--    acad_coursework_settings  per marksheet: assignment and test maxima
--
--  All four answer "by when" or "how much for this one sheet". NONE of them can
--  answer "is coursework entry open at all", "may a lecturer reopen a sheet they
--  already submitted", "may marks be uploaded from Excel", or "can students see
--  results yet" — and none can be set for one faculty without touching another.
--
--  A deadline is a DATE. A policy is a SWITCH. Today the only way to close mark
--  entry is to backdate a deadline, and the only way to close it for one
--  programme is not to. This table holds the switches.
--
--  RESOLUTION: most specific scope wins, then the most specific period.
--      PROGRAMME > FACULTY > CAMPUS > GLOBAL
--      exact (year+semester) > year only > any period
--  So a Registrar sets a rule once globally and a Dean narrows it where needed,
--  which is how these decisions are actually made.
--
--  Re-runnable: CREATE TABLE IF NOT EXISTS, and the seed uses INSERT IGNORE
--  against the uniqueness key, so a second run changes nothing.
-- ============================================================================

CREATE TABLE IF NOT EXISTS acad_exam_config (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,

  config_key    VARCHAR(64)  NOT NULL COMMENT 'e.g. coursework.entry.enabled',

  -- Scope. scope_value is the campus id, faculty_code or progcode; ignored (and
  -- stored as '') for GLOBAL, so the uniqueness key still works.
  scope_type    ENUM('GLOBAL','CAMPUS','FACULTY','PROGRAMME') NOT NULL DEFAULT 'GLOBAL',
  scope_value   VARCHAR(32)  NOT NULL DEFAULT '',

  -- Period. Empty acad_year means "any year"; semester 0 means "any semester".
  acad_year     VARCHAR(15)  NOT NULL DEFAULT '',
  semester      TINYINT UNSIGNED NOT NULL DEFAULT 0,

  -- Value, kept as text with a declared type so one table serves switches,
  -- numbers and dates without a column per kind.
  value_type    ENUM('BOOL','INT','DECIMAL','DATE','TEXT') NOT NULL DEFAULT 'BOOL',
  config_value  VARCHAR(255) NOT NULL DEFAULT '',

  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  notes         VARCHAR(255) NULL COMMENT 'why this override exists',
  updated_by    VARCHAR(100) NULL,
  updated_at    DATETIME     NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  -- One value per key per scope per period. Without this an override could be
  -- entered twice and resolution would depend on insertion order.
  UNIQUE KEY uq_scope (config_key, scope_type, scope_value, acad_year, semester),
  KEY ix_key (config_key, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
  COMMENT='Scoped policy switches for the examinations module. Deadlines live in acad_deadlines.';

-- Every change, so a closed entry window can always be traced to a person.
CREATE TABLE IF NOT EXISTS acad_exam_config_log (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  config_key   VARCHAR(64)  NOT NULL,
  scope_type   VARCHAR(16)  NOT NULL,
  scope_value  VARCHAR(32)  NOT NULL DEFAULT '',
  acad_year    VARCHAR(15)  NOT NULL DEFAULT '',
  semester     TINYINT UNSIGNED NOT NULL DEFAULT 0,
  old_value    VARCHAR(255) NULL,
  new_value    VARCHAR(255) NULL,
  action       VARCHAR(16)  NOT NULL DEFAULT 'SET',
  actor        VARCHAR(100) NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_key (config_key, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ── the settings themselves, seeded at GLOBAL scope ─────────────────────────
-- Defaults are chosen to preserve TODAY'S behaviour, so installing this file
-- changes nothing until somebody deliberately turns a switch. Entry switches
-- default to enabled because entry is currently governed by deadlines alone.
INSERT IGNORE INTO acad_exam_config
  (config_key, scope_type, scope_value, acad_year, semester, value_type, config_value, notes, updated_by, updated_at)
VALUES
  -- what a lecturer may do
  ('coursework.entry.enabled','GLOBAL','','',0,'BOOL','1','Lecturers may enter coursework marks','seed',NOW()),
  ('exam.entry.enabled',      'GLOBAL','','',0,'BOOL','1','Lecturers may enter final exam marks','seed',NOW()),
  ('practical.entry.enabled', 'GLOBAL','','',0,'BOOL','1','Lecturers may enter practical marks','seed',NOW()),
  ('marks.excel.upload.enabled','GLOBAL','','',0,'BOOL','1','Lecturers may upload marks from Excel','seed',NOW()),
  ('marks.edit.after.submit', 'GLOBAL','','',0,'BOOL','0','A submitted marksheet may be edited again by the lecturer','seed',NOW()),
  ('marks.allow.blank.submit','GLOBAL','','',0,'BOOL','0','A marksheet may be submitted with marks missing','seed',NOW()),

  -- how a mark is made up (defaults for new marksheets)
  ('marks.split.coursework',  'GLOBAL','','',0,'INT','40','Coursework percentage of the final mark','seed',NOW()),
  ('marks.split.exam',        'GLOBAL','','',0,'INT','60','Final exam percentage of the final mark','seed',NOW()),
  ('marks.split.practical',   'GLOBAL','','',0,'INT','0','Practical percentage of the final mark','seed',NOW()),
  ('marks.total',             'GLOBAL','','',0,'INT','100','Total the three percentages must add up to','seed',NOW()),
  ('marks.max.score',         'GLOBAL','','',0,'INT','100','Highest mark that may be typed for one component','seed',NOW()),
  ('marks.allow.decimal',     'GLOBAL','','',0,'BOOL','1','Marks may carry a decimal point','seed',NOW()),

  -- what a student may see
  ('results.students.visible','GLOBAL','','',0,'BOOL','1','Students may view published results in the portal','seed',NOW()),
  ('results.hide.on.balance', 'GLOBAL','','',0,'BOOL','0','Hide results from students who owe fees','seed',NOW());

-- ── checks ──────────────────────────────────────────────────────────────────
SELECT config_key, scope_type, value_type, config_value, notes
FROM acad_exam_config ORDER BY config_key;

SELECT CONCAT('settings seeded: ', COUNT(*)) AS result FROM acad_exam_config;
