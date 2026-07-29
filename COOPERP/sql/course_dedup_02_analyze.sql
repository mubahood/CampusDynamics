-- ============================================================
-- Course De-dup — Phase 1b: ANALYZER (READ-ONLY w.r.t. real data)
-- Builds staging aggregates, classifies every course A/B/C/D/SINGLETON,
-- and populates acad_course_merge_map with MERGE (A) + ARCHIVE (C) rows.
-- Writes only to _cd_* staging tables, acad_course.dedup_category,
-- and acad_course_merge_map. Touches NO results/registration data.
-- Safe to re-run (rebuilds staging + map each time).
-- ============================================================
SET NAMES utf8;   -- align literal collation with the utf8_general_ci course columns

-- ---- 1) per-course result counts (one scan) --------------------------------
DROP TABLE IF EXISTS campus_dynamics._cd_res;
CREATE TABLE campus_dynamics._cd_res (cc VARCHAR(25) PRIMARY KEY, n INT) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_res
SELECT TRIM(courseid), COUNT(*) FROM campus_dynamics.acad_results GROUP BY TRIM(courseid);

-- ---- 2) per-course registration counts -------------------------------------
DROP TABLE IF EXISTS campus_dynamics._cd_reg;
CREATE TABLE campus_dynamics._cd_reg (cc VARCHAR(25) PRIMARY KEY, n INT) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_reg
SELECT TRIM(courseID), COUNT(*) FROM campus_dynamics_portal.acad_course_registration GROUP BY TRIM(courseID);

-- ---- 3) per-course programme mapping (prog count, single prog, spec flag) ---
DROP TABLE IF EXISTS campus_dynamics._cd_prog;
CREATE TABLE campus_dynamics._cd_prog (
  cc VARCHAR(25) PRIMARY KEY, prog_count INT, one_prog CHAR(25) NULL, spec_any INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_prog
SELECT TRIM(course_code),
       COUNT(DISTINCT TRIM(progcode)),
       CASE WHEN COUNT(DISTINCT TRIM(progcode))=1 THEN MAX(TRIM(progcode)) ELSE NULL END,
       MAX(IF(IFNULL(specialisation_id,0)>0,1,0))
FROM campus_dynamics.acad_programmecourses
GROUP BY TRIM(course_code);

-- ---- 4) master per-course aggregate ----------------------------------------
DROP TABLE IF EXISTS campus_dynamics._cd_course_agg;
CREATE TABLE campus_dynamics._cd_course_agg (
  cc VARCHAR(25) PRIMARY KEY,
  norm_name VARCHAR(250),
  cu DOUBLE NULL,
  prog_count INT NOT NULL DEFAULT 0,
  one_prog CHAR(25) NULL,
  spec_any INT NOT NULL DEFAULT 0,
  results_cnt INT NOT NULL DEFAULT 0,
  regs_cnt INT NOT NULL DEFAULT 0,
  KEY k_norm (norm_name), KEY k_oneprog (one_prog)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- GROUP BY TRIM collapses whitespace-variant catalog rows (e.g. 'BAG2101B' vs 'BAG2101B ')
-- into one logical code; the re-key later matches on TRIM too, so this is consistent.
INSERT INTO campus_dynamics._cd_course_agg
SELECT TRIM(c.courseID), MIN(TRIM(UPPER(c.courseName))), MIN(c.CreditUnit),
       IFNULL(MAX(p.prog_count),0), MAX(p.one_prog), IFNULL(MAX(p.spec_any),0),
       IFNULL(MAX(r.n),0), IFNULL(MAX(g.n),0)
FROM campus_dynamics.acad_course c
LEFT JOIN campus_dynamics._cd_prog p ON p.cc=TRIM(c.courseID)
LEFT JOIN campus_dynamics._cd_res  r ON r.cc=TRIM(c.courseID)
LEFT JOIN campus_dynamics._cd_reg  g ON g.cc=TRIM(c.courseID)
GROUP BY TRIM(c.courseID);

-- ---- 5) cross-program subject share (norm_name used by >1 program) ----------
DROP TABLE IF EXISTS campus_dynamics._cd_xprog;
CREATE TABLE campus_dynamics._cd_xprog (norm_name VARCHAR(250) PRIMARY KEY, prog_span INT) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_xprog
SELECT norm_name, COUNT(DISTINCT one_prog) FROM campus_dynamics._cd_course_agg
WHERE one_prog IS NOT NULL GROUP BY norm_name;

-- ---- 6) within-program duplicate groups (>=2 codes, same prog+name) ---------
DROP TABLE IF EXISTS campus_dynamics._cd_grp;
CREATE TABLE campus_dynamics._cd_grp (
  one_prog CHAR(25), norm_name VARCHAR(250), n INT,
  PRIMARY KEY (one_prog, norm_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_grp
SELECT one_prog, norm_name, COUNT(*) FROM campus_dynamics._cd_course_agg
WHERE one_prog IS NOT NULL
GROUP BY one_prog, norm_name HAVING COUNT(*)>1;

-- ---- 7) survivor per dup group (RELIABLE, order-preserving GROUP_CONCAT) ----
--    survivor = most results, then most regs, then lowest code (minimises re-key)
SET SESSION group_concat_max_len = 100000;
DROP TABLE IF EXISTS campus_dynamics._cd_surv;
CREATE TABLE campus_dynamics._cd_surv (
  one_prog CHAR(25), norm_name VARCHAR(250), survivor_cc VARCHAR(25),
  PRIMARY KEY (one_prog, norm_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO campus_dynamics._cd_surv
SELECT a.one_prog, a.norm_name,
  SUBSTRING_INDEX(
    GROUP_CONCAT(a.cc ORDER BY a.results_cnt DESC, a.regs_cnt DESC, a.cc ASC SEPARATOR '||'),
    '||', 1)
FROM campus_dynamics._cd_course_agg a
JOIN campus_dynamics._cd_grp g ON g.one_prog=a.one_prog AND g.norm_name=a.norm_name
GROUP BY a.one_prog, a.norm_name;

-- ---- 8) populate merge_map: category A (every non-survivor code = a loser) --
DELETE FROM campus_dynamics.acad_course_merge_map WHERE category IN ('A_WITHIN_PROG','C_ORPHAN');
INSERT INTO campus_dynamics.acad_course_merge_map
  (category, progcode, subject_name, loser_code, survivor_code,
   loser_results, loser_regs, survivor_results, survivor_regs,
   loser_cu, survivor_cu, cu_conflict, student_overlap, decision, created_at)
SELECT 'A_WITHIN_PROG', a.one_prog, a.norm_name, a.cc, s.survivor_cc,
       a.results_cnt, a.regs_cnt, sa.results_cnt, sa.regs_cnt,
       a.cu, sa.cu, IF(IFNULL(a.cu,-1)<>IFNULL(sa.cu,-1),1,0), 0,
       -- auto-decision: MANUAL if CU conflict, else MERGE
       IF(IFNULL(a.cu,-1)<>IFNULL(sa.cu,-1),'MANUAL','MERGE'), NOW()
FROM campus_dynamics._cd_course_agg a
JOIN campus_dynamics._cd_grp  g  ON g.one_prog=a.one_prog AND g.norm_name=a.norm_name
JOIN campus_dynamics._cd_surv s  ON s.one_prog=a.one_prog AND s.norm_name=a.norm_name
JOIN campus_dynamics._cd_course_agg sa ON sa.cc=s.survivor_cc
WHERE a.cc <> s.survivor_cc;

-- ---- 9) student overlap per A pair (both codes held by same regno) ----------
DROP TABLE IF EXISTS campus_dynamics._cd_regset;
CREATE TABLE campus_dynamics._cd_regset (cc VARCHAR(25), rn VARCHAR(40), PRIMARY KEY(cc,rn)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO campus_dynamics._cd_regset
SELECT TRIM(courseID), TRIM(regno) FROM campus_dynamics_portal.acad_course_registration
WHERE TRIM(courseID) IN (
  SELECT loser_code FROM campus_dynamics.acad_course_merge_map WHERE category='A_WITHIN_PROG'
  UNION SELECT survivor_code FROM campus_dynamics.acad_course_merge_map WHERE category='A_WITHIN_PROG');
UPDATE campus_dynamics.acad_course_merge_map m
SET student_overlap = (
  SELECT COUNT(*) FROM campus_dynamics._cd_regset a
  JOIN campus_dynamics._cd_regset b ON a.rn=b.rn
  WHERE a.cc=m.loser_code AND b.cc=m.survivor_code)
WHERE m.category='A_WITHIN_PROG';

-- ---- 10) category C: orphans (no programme mapping) ------------------------
--     archive-safe = zero results AND zero regs; else flag MANUAL (keep).
INSERT INTO campus_dynamics.acad_course_merge_map
  (category, progcode, subject_name, loser_code, survivor_code,
   loser_results, loser_regs, cu_conflict, student_overlap,
   decision, notes, created_at)
SELECT 'C_ORPHAN', NULL, a.norm_name, a.cc, NULL,
       a.results_cnt, a.regs_cnt, 0, 0,
       IF(a.results_cnt=0 AND a.regs_cnt=0,'ARCHIVE','MANUAL'),
       IF(a.results_cnt=0 AND a.regs_cnt=0,'no data','ORPHAN BUT HAS DATA - keep/review'),
       NOW()
FROM campus_dynamics._cd_course_agg a
WHERE a.prog_count=0;

-- ---- 11) stamp dedup_category on the catalog (informational) ----------------
UPDATE campus_dynamics.acad_course c
JOIN campus_dynamics._cd_course_agg a ON a.cc=TRIM(c.courseID)
LEFT JOIN campus_dynamics._cd_grp g ON g.one_prog=a.one_prog AND g.norm_name=a.norm_name
LEFT JOIN campus_dynamics._cd_xprog x ON x.norm_name=a.norm_name
SET c.dedup_category =
  CASE
    WHEN a.prog_count=0 THEN 'C_ORPHAN'
    WHEN g.n IS NOT NULL THEN 'A_WITHIN_PROG'
    WHEN IFNULL(x.prog_span,0)>1 THEN 'B_CROSS_PROG'
    WHEN a.spec_any=1 THEN 'D_SPECIALISATION'
    ELSE 'SINGLETON'
  END;
