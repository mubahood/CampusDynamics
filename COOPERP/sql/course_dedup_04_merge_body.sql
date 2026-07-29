-- ============================================================
-- Course De-dup — Category-A MERGE ENGINE (body only, NO txn control)
-- Driver = acad_course_merge_map rows with decision='MERGE'.
-- GUARANTEE: every result/registration row is either re-keyed (kept)
-- or copied to a *_quarantine log AND preserved in the Phase-0 backup.
-- Invariant checked by the runner: after + quarantined == before.
-- Self-contained + re-runnable (rebuilds its own driver/snapshots).
-- ============================================================
SET NAMES utf8;
SET SESSION group_concat_max_len = 1000000;

-- ---------- driver: loser -> survivor (approved MERGE rows) ------------------
DROP TABLE IF EXISTS campus_dynamics._cd_losers;
CREATE TABLE campus_dynamics._cd_losers (cc VARCHAR(25) PRIMARY KEY, surv VARCHAR(25)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO campus_dynamics._cd_losers
SELECT loser_code, survivor_code FROM campus_dynamics.acad_course_merge_map
WHERE category='A_WITHIN_PROG' AND decision='MERGE';

DROP TABLE IF EXISTS campus_dynamics._cd_survset;
CREATE TABLE campus_dynamics._cd_survset (cc VARCHAR(25) PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO campus_dynamics._cd_survset SELECT DISTINCT surv FROM campus_dynamics._cd_losers;

-- ==================== RESULTS (authoritative marks) =========================
-- universe = every result row whose course is a loser OR a survivor, with the
-- code it will carry after merge (target).
DROP TABLE IF EXISTS campus_dynamics._cd_res_all;
CREATE TABLE campus_dynamics._cd_res_all (
  rid INT PRIMARY KEY, regno VARCHAR(85), sem INT, acad VARCHAR(25),
  target VARCHAR(25), score INT, is_loser TINYINT,
  KEY g(regno,sem,acad,target)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_all
SELECT r.ID, TRIM(r.regno), r.semester, TRIM(r.acad),
       IF(l.cc IS NOT NULL, l.surv, TRIM(r.courseid)),
       IFNULL(r.score,0), IF(l.cc IS NOT NULL,1,0)
FROM campus_dynamics.acad_results r
LEFT JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc
WHERE TRIM(r.courseid) IN (SELECT cc FROM campus_dynamics._cd_losers)
   OR TRIM(r.courseid) IN (SELECT cc FROM campus_dynamics._cd_survset);

-- keeper = best row per (regno,sem,acad,target): highest score, tie -> highest ID
DROP TABLE IF EXISTS campus_dynamics._cd_res_keep;
CREATE TABLE campus_dynamics._cd_res_keep (keep_rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_keep
SELECT CAST(SUBSTRING_INDEX(GROUP_CONCAT(rid ORDER BY score DESC, rid DESC),',',1) AS UNSIGNED)
FROM campus_dynamics._cd_res_all GROUP BY regno,sem,acad,target;

-- discards = involved rows that are NOT the keeper of their group
DROP TABLE IF EXISTS campus_dynamics._cd_res_discard;
CREATE TABLE campus_dynamics._cd_res_discard (rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res_discard
SELECT a.rid FROM campus_dynamics._cd_res_all a
LEFT JOIN campus_dynamics._cd_res_keep k ON k.keep_rid=a.rid
WHERE k.keep_rid IS NULL;

-- quarantine log (full row also preserved in acad_results_predup20260718)
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_results_quarantine (
  q_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, run_tag VARCHAR(40), reason VARCHAR(80),
  quar_at DATETIME, orig_id INT, regno VARCHAR(85), courseid VARCHAR(25), semester INT,
  acad VARCHAR(25), studyyear INT, score INT, grade VARCHAR(5), gpa DOUBLE, progid VARCHAR(25),
  KEY k_orig(orig_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics.acad_results_quarantine
  (run_tag,reason,quar_at,orig_id,regno,courseid,semester,acad,studyyear,score,grade,gpa,progid)
SELECT 'dedup20260718','A_MERGE_dup_result',NOW(),r.ID,r.regno,r.courseid,r.semester,r.acad,
       r.studyyear,r.score,r.grade,r.gpa,r.progid
FROM campus_dynamics.acad_results r JOIN campus_dynamics._cd_res_discard d ON d.rid=r.ID;

-- delete discarded duplicates, then re-key the survivors of each group
DELETE r FROM campus_dynamics.acad_results r JOIN campus_dynamics._cd_res_discard d ON d.rid=r.ID;
UPDATE campus_dynamics.acad_results r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc
  SET r.courseid=l.surv;

-- ==================== REGISTRATIONS ========================================
DROP TABLE IF EXISTS campus_dynamics._cd_reg_all;
CREATE TABLE campus_dynamics._cd_reg_all (
  rid INT PRIMARY KEY, regno VARCHAR(85), acad VARCHAR(25), sem INT,
  target VARCHAR(25), rank_val INT, is_loser TINYINT,
  KEY g(regno,acad,sem,target)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_all
SELECT g.ID, TRIM(g.regno), TRIM(g.acad_year), g.semester,
       IF(l.cc IS NOT NULL, l.surv, TRIM(g.courseID)),
       IFNULL(g.provisional_total_marks,0), IF(l.cc IS NOT NULL,1,0)
FROM campus_dynamics_portal.acad_course_registration g
LEFT JOIN campus_dynamics._cd_losers l ON TRIM(g.courseID)=l.cc
WHERE TRIM(g.courseID) IN (SELECT cc FROM campus_dynamics._cd_losers)
   OR TRIM(g.courseID) IN (SELECT cc FROM campus_dynamics._cd_survset);

DROP TABLE IF EXISTS campus_dynamics._cd_reg_keep;
CREATE TABLE campus_dynamics._cd_reg_keep (keep_rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_keep
SELECT CAST(SUBSTRING_INDEX(GROUP_CONCAT(rid ORDER BY rank_val DESC, rid DESC),',',1) AS UNSIGNED)
FROM campus_dynamics._cd_reg_all GROUP BY regno,acad,sem,target;

DROP TABLE IF EXISTS campus_dynamics._cd_reg_discard;
CREATE TABLE campus_dynamics._cd_reg_discard (rid INT PRIMARY KEY) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg_discard
SELECT a.rid FROM campus_dynamics._cd_reg_all a
LEFT JOIN campus_dynamics._cd_reg_keep k ON k.keep_rid=a.rid
WHERE k.keep_rid IS NULL;

CREATE TABLE IF NOT EXISTS campus_dynamics_portal.acad_course_registration_quarantine (
  q_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, run_tag VARCHAR(40), reason VARCHAR(80),
  quar_at DATETIME, orig_id INT, regno VARCHAR(85), courseID VARCHAR(25), acad_year VARCHAR(25),
  semester INT, prog_id VARCHAR(25), KEY k_orig(orig_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics_portal.acad_course_registration_quarantine
  (run_tag,reason,quar_at,orig_id,regno,courseID,acad_year,semester,prog_id)
SELECT 'dedup20260718','A_MERGE_dup_registration',NOW(),g.ID,g.regno,g.courseID,g.acad_year,g.semester,g.prog_id
FROM campus_dynamics_portal.acad_course_registration g
JOIN campus_dynamics._cd_reg_discard d ON d.rid=g.ID;

DELETE g FROM campus_dynamics_portal.acad_course_registration g
  JOIN campus_dynamics._cd_reg_discard d ON d.rid=g.ID;
UPDATE campus_dynamics_portal.acad_course_registration g
  JOIN campus_dynamics._cd_losers l ON TRIM(g.courseID)=l.cc SET g.courseID=l.surv;

-- ==================== STRAIGHT RE-KEY (secondary tables) ====================
UPDATE campus_dynamics.acad_transcript_results r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc SET r.courseid=l.surv;
UPDATE campus_dynamics.acad_teaching_allocation r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc   SET r.courseID=l.surv;
UPDATE campus_dynamics.acad_teaching_allocation r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_code)=l.cc SET r.course_code=l.surv;
UPDATE campus_dynamics.acad_marks_audit r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_id)=l.cc SET r.course_id=l.surv;
UPDATE campus_dynamics.acad_timetable r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_code)=l.cc SET r.course_code=l.surv;
UPDATE campus_dynamics.acad_exam_timetable r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE campus_dynamics_portal.acad_examsettings r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE campus_dynamics_portal.acad_coursework_settings r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE campus_dynamics_portal.odel_course_space r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;

-- programmecourses: re-key then drop resulting exact-duplicate offerings (keep min ID)
UPDATE campus_dynamics.acad_programmecourses r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_code)=l.cc SET r.course_code=l.surv;
DROP TABLE IF EXISTS campus_dynamics._cd_pc_dup;
CREATE TABLE campus_dynamics._cd_pc_dup (keep_id INT) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_pc_dup
SELECT MIN(ID) FROM campus_dynamics.acad_programmecourses
GROUP BY TRIM(progcode),TRIM(course_code),study_year,semester,IFNULL(specialisation_id,0);
DELETE p FROM campus_dynamics.acad_programmecourses p
LEFT JOIN campus_dynamics._cd_pc_dup k ON k.keep_id=p.ID
WHERE k.keep_id IS NULL
  AND TRIM(p.course_code) IN (SELECT DISTINCT surv FROM campus_dynamics._cd_losers);

-- ==================== CATALOG: mark losers MERGED ==========================
UPDATE campus_dynamics.acad_course c JOIN campus_dynamics._cd_losers l ON TRIM(c.courseID)=l.cc
  SET c.course_state='MERGED', c.merged_into=l.surv, c.merged_at=NOW();

-- ==================== AUDIT summary =========================================
INSERT INTO campus_dynamics.acad_course_merge_audit (run_tag,phase,db_name,tbl,action,detail,rows_affected,at_ts)
SELECT 'dedup20260718','P6_MERGE','campus_dynamics','acad_results','REKEY',
       'category-A loser results re-keyed to survivor', ROW_COUNT(), NOW();
