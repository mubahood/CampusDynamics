-- ============================================================
-- Course De-dup — MERGE PREP (staging only; DDL; NO real-data mutation)
-- Computes driver + keep/discard sets from PRE-merge data and creates
-- the (empty) quarantine tables. Idempotent. Safe to commit.
-- Run this BEFORE the mutate step (which is wrapped in a transaction).
-- ============================================================
SET NAMES utf8;
SET SESSION group_concat_max_len = 1000000;

-- driver: loser -> survivor (approved MERGE rows only)
DROP TABLE IF EXISTS campus_dynamics._cd_losers;
CREATE TABLE campus_dynamics._cd_losers (cc VARCHAR(25) PRIMARY KEY, surv VARCHAR(25)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO campus_dynamics._cd_losers
SELECT loser_code, survivor_code FROM campus_dynamics.acad_course_merge_map
WHERE category='A_WITHIN_PROG' AND decision='MERGE';

DROP TABLE IF EXISTS campus_dynamics._cd_survset;
CREATE TABLE campus_dynamics._cd_survset (cc VARCHAR(25) PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO campus_dynamics._cd_survset SELECT DISTINCT surv FROM campus_dynamics._cd_losers;

-- ---- RESULTS: universe / keep / discard ----
DROP TABLE IF EXISTS campus_dynamics._cd_res_all;
CREATE TABLE campus_dynamics._cd_res_all (
  rid INT PRIMARY KEY, regno VARCHAR(85), sem INT, acad VARCHAR(25),
  target VARCHAR(25), score INT, is_loser TINYINT, KEY g(regno,sem,acad,target)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_all
SELECT r.ID, TRIM(r.regno), r.semester, TRIM(r.acad),
       IF(l.cc IS NOT NULL, l.surv, TRIM(r.courseid)), IFNULL(r.score,0), IF(l.cc IS NOT NULL,1,0)
FROM campus_dynamics.acad_results r
LEFT JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc
WHERE TRIM(r.courseid) IN (SELECT cc FROM campus_dynamics._cd_losers)
   OR TRIM(r.courseid) IN (SELECT cc FROM campus_dynamics._cd_survset);

-- ACTIVE groups only = (regno,target) that actually contain a loser row.
-- (acad_results unique index is (regno,courseid): one result per course per student.)
-- Rows in pure-survivor groups are left completely untouched (no over-reach).
DROP TABLE IF EXISTS campus_dynamics._cd_res_active;
CREATE TABLE campus_dynamics._cd_res_active (regno VARCHAR(85), target VARCHAR(25), PRIMARY KEY(regno,target)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_active
SELECT regno,target FROM campus_dynamics._cd_res_all WHERE is_loser=1 GROUP BY regno,target;

-- keep ONE best result per active (regno,target): highest score, tie -> highest ID
DROP TABLE IF EXISTS campus_dynamics._cd_res_keep;
CREATE TABLE campus_dynamics._cd_res_keep (keep_rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_keep
SELECT CAST(SUBSTRING_INDEX(GROUP_CONCAT(a.rid ORDER BY a.score DESC, a.rid DESC),',',1) AS UNSIGNED)
FROM campus_dynamics._cd_res_all a
JOIN campus_dynamics._cd_res_active ac ON ac.regno=a.regno AND ac.target=a.target
GROUP BY a.regno,a.target;

-- discard = rows in an active group that are NOT the keeper
DROP TABLE IF EXISTS campus_dynamics._cd_res_discard;
CREATE TABLE campus_dynamics._cd_res_discard (rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_discard
SELECT a.rid FROM campus_dynamics._cd_res_all a
JOIN campus_dynamics._cd_res_active ac ON ac.regno=a.regno AND ac.target=a.target
LEFT JOIN campus_dynamics._cd_res_keep k ON k.keep_rid=a.rid
WHERE k.keep_rid IS NULL;

-- ---- REGISTRATIONS: universe / keep / discard ----
-- registration unique index = (regno,courseID,acad_year,semester,course_status):
-- group by the FULL key (target replaces courseID) so we only ever collapse
-- genuine index-duplicates, and only in groups that contain a loser row.
DROP TABLE IF EXISTS campus_dynamics._cd_reg_all;
CREATE TABLE campus_dynamics._cd_reg_all (
  rid INT PRIMARY KEY, regno VARCHAR(85), acad VARCHAR(25), sem INT, cstat VARCHAR(25),
  target VARCHAR(25), rank_val INT, is_loser TINYINT, KEY g(regno,acad,sem,cstat,target)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_all
SELECT g.ID, TRIM(g.regno), TRIM(g.acad_year), g.semester, TRIM(g.course_status),
       IF(l.cc IS NOT NULL, l.surv, TRIM(g.courseID)), IFNULL(g.provisional_total_marks,0), IF(l.cc IS NOT NULL,1,0)
FROM campus_dynamics_portal.acad_course_registration g
LEFT JOIN campus_dynamics._cd_losers l ON TRIM(g.courseID)=l.cc
WHERE TRIM(g.courseID) IN (SELECT cc FROM campus_dynamics._cd_losers)
   OR TRIM(g.courseID) IN (SELECT cc FROM campus_dynamics._cd_survset);

DROP TABLE IF EXISTS campus_dynamics._cd_reg_active;
CREATE TABLE campus_dynamics._cd_reg_active (regno VARCHAR(85), acad VARCHAR(25), sem INT, cstat VARCHAR(25), target VARCHAR(25),
  PRIMARY KEY(regno,acad,sem,cstat,target)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_active
SELECT regno,acad,sem,cstat,target FROM campus_dynamics._cd_reg_all WHERE is_loser=1 GROUP BY regno,acad,sem,cstat,target;

DROP TABLE IF EXISTS campus_dynamics._cd_reg_keep;
CREATE TABLE campus_dynamics._cd_reg_keep (keep_rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_keep
SELECT CAST(SUBSTRING_INDEX(GROUP_CONCAT(a.rid ORDER BY a.rank_val DESC, a.rid DESC),',',1) AS UNSIGNED)
FROM campus_dynamics._cd_reg_all a
JOIN campus_dynamics._cd_reg_active ac ON ac.regno=a.regno AND ac.acad=a.acad AND ac.sem=a.sem AND ac.cstat=a.cstat AND ac.target=a.target
GROUP BY a.regno,a.acad,a.sem,a.cstat,a.target;

DROP TABLE IF EXISTS campus_dynamics._cd_reg_discard;
CREATE TABLE campus_dynamics._cd_reg_discard (rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_discard
SELECT a.rid FROM campus_dynamics._cd_reg_all a
JOIN campus_dynamics._cd_reg_active ac ON ac.regno=a.regno AND ac.acad=a.acad AND ac.sem=a.sem AND ac.cstat=a.cstat AND ac.target=a.target
LEFT JOIN campus_dynamics._cd_reg_keep k ON k.keep_rid=a.rid
WHERE k.keep_rid IS NULL;

-- ---- quarantine tables (empty; full rows also live in *_predup20260718) ----
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_results_quarantine (
  q_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, run_tag VARCHAR(40), reason VARCHAR(80),
  quar_at DATETIME, orig_id INT, regno VARCHAR(85), courseid VARCHAR(25), semester INT,
  acad VARCHAR(25), studyyear INT, score INT, grade VARCHAR(5), gpa DOUBLE, progid VARCHAR(25),
  KEY k_orig(orig_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS campus_dynamics_portal.acad_course_registration_quarantine (
  q_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, run_tag VARCHAR(40), reason VARCHAR(80),
  quar_at DATETIME, orig_id INT, regno VARCHAR(85), courseID VARCHAR(25), acad_year VARCHAR(25),
  semester INT, prog_id VARCHAR(25), KEY k_orig(orig_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- pre-merge baselines for the runner's reconciliation
SELECT 'PREP_DONE' status,
  (SELECT COUNT(*) FROM campus_dynamics._cd_losers) losers,
  (SELECT COUNT(*) FROM campus_dynamics._cd_res_discard) res_discards,
  (SELECT COUNT(*) FROM campus_dynamics._cd_reg_discard) reg_discards;
