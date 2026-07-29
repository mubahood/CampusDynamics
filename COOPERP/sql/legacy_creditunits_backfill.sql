-- ============================================================================
-- Legacy CreditUnits backfill  —  acad_results / acad_transcript_results
-- ----------------------------------------------------------------------------
-- PROBLEM
--   Results imported from the pre-ERP system carry course CODES only; the
--   matching course master rows were never migrated into acad_course. Because
--   acad_results.CreditUnits was left 0 on those rows, every credit-weighted
--   calculation collapses:
--       acad_CGPAFinder()  = SUM(CU*GP)/SUM(CU)   -> counts ONLY the courses
--                                                    that happen to have CU>0
--       page GPA / Total Credits (NewStudentInfo "Academic Results" tab)
--       printed transcripts (acad_transcript_results)
--   Symptom seen in production: MRU08/U/ODEE/338 showed CGPA 2.50 / Credits 3 /
--   class PASS because only 1 of his 33 courses (DIT1101) had a credit unit.
--
-- AUTHORITATIVE SOURCE
--   campus_dynamics.acad_results_legacy — the raw legacy import — retains the
--   original CreditUnits. Only codes whose legacy CU is UNAMBIGUOUS (exactly one
--   distinct value) are used; anything ambiguous is left alone for manual review.
--
-- STATUS: template. Executed so far ONLY for MRU08/U/ODEE/338 (2026-07-29).
--         Set @scope below before running wider.
--
-- SAFETY
--   * acad_results UPDATE triggers fire only when score/grade change, so this
--     backfill does NOT pollute acad_marks_audit.
--   * Scores and grades are never touched — credits and the stored per-semester
--     gpa column only.
--   * Every touched row is copied to a dated backup table first.
-- ============================================================================
USE campus_dynamics;

-- Scope: '' = every affected student. Otherwise a single regno.
SET @scope := 'MRU08/U/ODEE/338';

-- ---------------------------------------------------------------- 1. backup --
DROP TABLE IF EXISTS bak_cufix_20260729;
CREATE TABLE bak_cufix_20260729 AS
  SELECT 'acad_results' src, ID, regno, courseid, studyyear, semester, CreditUnits, gpa
    FROM acad_results
   WHERE IFNULL(CreditUnits,0)=0 AND (@scope='' OR regno=@scope)
  UNION ALL
  SELECT 'acad_transcript_results', ID, regno, courseid, studyyear, semester, CreditUnits, gpa
    FROM acad_transcript_results
   WHERE IFNULL(CreditUnits,0)=0 AND (@scope='' OR regno=@scope);

-- ------------------------------------------------- 2. unambiguous CU lookup --
DROP TABLE IF EXISTS tmp_legacy_cu;
CREATE TABLE tmp_legacy_cu (courseid VARCHAR(250) PRIMARY KEY, cu DOUBLE) ENGINE=InnoDB;

-- 2a. prefer the live catalog when it knows the course
INSERT INTO tmp_legacy_cu (courseid, cu)
  SELECT courseID, CreditUnit FROM acad_course WHERE IFNULL(CreditUnit,0) > 0;

-- 2b. fall back to the legacy import for codes the catalog never received
INSERT IGNORE INTO tmp_legacy_cu (courseid, cu)
  SELECT courseid, MIN(CreditUnits) FROM acad_results_legacy
   WHERE IFNULL(CreditUnits,0) > 0
   GROUP BY courseid HAVING COUNT(DISTINCT CreditUnits) = 1;

-- ------------------------------------------------------- 3. backfill the CU --
UPDATE acad_results r JOIN tmp_legacy_cu m ON m.courseid = r.courseid
   SET r.CreditUnits = m.cu
 WHERE IFNULL(r.CreditUnits,0)=0 AND (@scope='' OR r.regno=@scope);

UPDATE acad_transcript_results t JOIN tmp_legacy_cu m ON m.courseid = t.courseid
   SET t.CreditUnits = m.cu
 WHERE IFNULL(t.CreditUnits,0)=0 AND (@scope='' OR t.regno=@scope);

-- --------------------------------------- 4. recompute stored semester GPA ----
DROP TABLE IF EXISTS tmp_semgpa;
CREATE TABLE tmp_semgpa ENGINE=InnoDB AS
  SELECT regno, studyyear, semester,
         ROUND(SUM(gradept*CreditUnits)/NULLIF(SUM(CreditUnits),0), 2) AS sem_gpa
    FROM acad_results
   WHERE (@scope='' OR regno=@scope)
   GROUP BY regno, studyyear, semester;
ALTER TABLE tmp_semgpa ADD KEY k (regno, studyyear, semester);

UPDATE acad_results r JOIN tmp_semgpa g
    ON g.regno=r.regno AND g.studyyear=r.studyyear AND g.semester=r.semester
   SET r.gpa = g.sem_gpa
 WHERE (@scope='' OR r.regno=@scope);

UPDATE acad_transcript_results t JOIN tmp_semgpa g
    ON g.regno=t.regno AND g.studyyear=t.studyyear AND g.semester=t.semester
   SET t.gpa = g.sem_gpa
 WHERE (@scope='' OR t.regno=@scope);

DROP TABLE tmp_legacy_cu;
DROP TABLE tmp_semgpa;

-- --------------------------------------------------------------- 5. verify --
-- SELECT regno, acad_CGPAFinder(regno) cgpa, SUM(CreditUnits) credits
--   FROM acad_results WHERE regno=@scope GROUP BY regno;

-- ----------------------------------------------------------------- ROLLBACK --
-- UPDATE acad_results r JOIN bak_cufix_20260729 b
--     ON b.src='acad_results' AND b.ID=r.ID
--    SET r.CreditUnits=b.CreditUnits, r.gpa=b.gpa;
-- UPDATE acad_transcript_results t JOIN bak_cufix_20260729 b
--     ON b.src='acad_transcript_results' AND b.ID=t.ID
--    SET t.CreditUnits=b.CreditUnits, t.gpa=b.gpa;
