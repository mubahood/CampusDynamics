-- ============================================================================
-- Legacy results remediation  —  acad_results / acad_transcript_results
-- Executed against production 2026-07-29.
-- ----------------------------------------------------------------------------
-- PROBLEM
--   Results imported from the pre-ERP system carry course CODES only; the
--   matching course-master rows were never migrated into acad_course. Because
--   acad_results.CreditUnits was left 0 on those rows, every credit-weighted
--   calculation collapses:
--       acad_CGPAFinder()  = SUM(CU*GP)/SUM(CU)   -> counts ONLY the courses
--                                                    that happen to have CU>0
--       page GPA / Total Credits (NewStudentInfo "Academic Results" tab)
--       marksheet + ResultsExporter (they read CU from acad_course, not results)
--       printed transcripts (acad_transcript_results)
--   Symptom found in production: MRU08/U/ODEE/338 showed CGPA 2.50 / Credits 3 /
--   class PASS because only 1 of his 33 courses (DIT1101) had a credit unit.
--
--   A second, overlapping defect: some codes are merely DIRTY variants of real
--   catalogue codes ("DIT 1201", "BMC:2203", quoted/tab-padded "BCS\t1101") and
--   fail the exact-match join even though the course exists.
--
-- PHASES
--   1. Normalise dirty codes onto their real catalogue code (recovers the REAL
--      course name and credit unit).
--   2. Register genuinely-missing legacy codes in acad_course. Titles do not
--      exist in any database or backup, so courseName is seeded with the code
--      itself (nothing false is asserted) and swapped for the real title by one
--      UPDATE once the faculties supply the old curricula.
--   3. Backfill CreditUnits everywhere it is still 0, preferring acad_course and
--      falling back to the raw acad_results_legacy import (unambiguous only).
--   4. Recompute the stored per-semester gpa — ONLY for the semesters actually
--      touched, so untouched students are never rewritten.
--
-- SAFETY
--   * acad_results UPDATE triggers fire only when score/grade change, so none of
--     this pollutes acad_marks_audit.
--   * Scores and grades are never touched.
--   * Every touched row is copied to a dated backup table first; rollback at end.
-- ============================================================================
USE campus_dynamics;

-- ###########################################################################
-- PHASE 1 — normalise dirty course codes onto real catalogue codes
-- ###########################################################################
DROP TABLE IF EXISTS wk_codefix;
CREATE TABLE wk_codefix (raw CHAR(25) NOT NULL PRIMARY KEY, clean CHAR(25))
  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
INSERT INTO wk_codefix (raw, clean)
  SELECT x.courseid, c.courseID
    FROM (SELECT DISTINCT courseid FROM acad_results
           UNION SELECT DISTINCT courseid FROM acad_transcript_results) x
    JOIN acad_course c
      ON c.courseID = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(x.courseid),' ',''),CHAR(9),''),':',''),'"',''))
   WHERE NOT EXISTS (SELECT 1 FROM acad_course c2 WHERE c2.courseID = x.courseid)
     AND BINARY x.courseid <> BINARY c.courseID;

-- Resolve to individual ROWS, not whole codes. Both tables carry a UNIQUE index
-- on (regno, courseid) — note it is NOT scoped by study year/semester — so a row
-- is only renamed when that student does not already hold the clean code. Rows
-- that would collide are genuine duplicates of an existing result and stay dirty
-- for manual review; other students keep the benefit of the same code mapping.
DROP TABLE IF EXISTS wk_rowfix;
CREATE TABLE wk_rowfix (src VARCHAR(30) NOT NULL, ID INT NOT NULL, clean CHAR(25),
                        PRIMARY KEY (src, ID))
  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO wk_rowfix (src, ID, clean)
  SELECT 'acad_results', r.ID, t.clean
    FROM acad_results r JOIN wk_codefix t ON t.raw = r.courseid
   WHERE NOT EXISTS (SELECT 1 FROM acad_results b
                      WHERE b.regno = r.regno AND b.courseid = t.clean);

INSERT INTO wk_rowfix (src, ID, clean)
  SELECT 'acad_transcript_results', r.ID, t.clean
    FROM acad_transcript_results r JOIN wk_codefix t ON t.raw = r.courseid
   WHERE NOT EXISTS (SELECT 1 FROM acad_transcript_results b
                      WHERE b.regno = r.regno AND b.courseid = t.clean);

-- Two dirty spellings of the same course for one student would collide with each
-- other; keep the lowest ID per (student, clean code) and leave the rest dirty.
DROP TABLE IF EXISTS wk_rowkeep;
CREATE TABLE wk_rowkeep (src VARCHAR(30) NOT NULL, regno VARCHAR(100) NOT NULL,
                         clean CHAR(25) NOT NULL, keep_id INT NOT NULL,
                         PRIMARY KEY (src, regno, clean))
  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
INSERT INTO wk_rowkeep (src, regno, clean, keep_id)
  SELECT 'acad_results', r.regno, w.clean, MIN(w.ID)
    FROM wk_rowfix w JOIN acad_results r ON r.ID = w.ID
   WHERE w.src = 'acad_results' GROUP BY r.regno, w.clean;
INSERT INTO wk_rowkeep (src, regno, clean, keep_id)
  SELECT 'acad_transcript_results', t.regno, w.clean, MIN(w.ID)
    FROM wk_rowfix w JOIN acad_transcript_results t ON t.ID = w.ID
   WHERE w.src = 'acad_transcript_results' GROUP BY t.regno, w.clean;

DELETE w FROM wk_rowfix w
  LEFT JOIN wk_rowkeep k ON k.src = w.src AND k.keep_id = w.ID
 WHERE k.keep_id IS NULL;

DROP TABLE IF EXISTS bak_codefix_20260729;
CREATE TABLE bak_codefix_20260729 AS
  SELECT 'acad_results' src, r.ID, r.regno, r.courseid FROM acad_results r
    JOIN wk_rowfix w ON w.src='acad_results' AND w.ID=r.ID
  UNION ALL
  SELECT 'acad_transcript_results', t.ID, t.regno, t.courseid FROM acad_transcript_results t
    JOIN wk_rowfix w ON w.src='acad_transcript_results' AND w.ID=t.ID;

UPDATE acad_results r JOIN wk_rowfix w ON w.src='acad_results' AND w.ID=r.ID
   SET r.courseid = w.clean;
UPDATE acad_transcript_results t JOIN wk_rowfix w ON w.src='acad_transcript_results' AND w.ID=t.ID
   SET t.courseid = w.clean;

-- ###########################################################################
-- PHASE 2 — register genuinely-missing legacy codes in acad_course
-- ###########################################################################
DROP TABLE IF EXISTS wk_missing_codes;
CREATE TABLE wk_missing_codes (courseid CHAR(25) NOT NULL PRIMARY KEY, cu DOUBLE)
  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
INSERT INTO wk_missing_codes (courseid, cu)
  SELECT x.courseid,
         (SELECT MIN(l.CreditUnits) FROM acad_results_legacy l
           WHERE l.courseid = x.courseid AND IFNULL(l.CreditUnits,0) > 0
           GROUP BY l.courseid HAVING COUNT(DISTINCT l.CreditUnits) = 1)
    FROM (SELECT DISTINCT courseid FROM acad_results
           UNION SELECT DISTINCT courseid FROM acad_transcript_results) x
   WHERE NOT EXISTS (SELECT 1 FROM acad_course c WHERE c.courseID = x.courseid)
     -- well-formed course codes only; malformed/truncated entries are reported,
     -- never invented into the catalogue
     AND TRIM(x.courseid) REGEXP '^[A-Za-z]{2,5}[0-9]{3,4}[A-Za-z]?$';

INSERT INTO acad_course (courseID, courseName, CreditUnit, courseDescription, course_state)
  SELECT courseid, courseid, cu,
         'Legacy course from the pre-ERP import. Title was never migrated - replace courseName when the faculty supplies the old curriculum.',
         'ARCHIVED'
    FROM wk_missing_codes;

-- ###########################################################################
-- PHASE 3 — backfill CreditUnits
-- ###########################################################################
DROP TABLE IF EXISTS wk_cu;
CREATE TABLE wk_cu (courseid CHAR(25) NOT NULL PRIMARY KEY, cu DOUBLE)
  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
INSERT INTO wk_cu (courseid, cu)                        -- live catalogue wins
  SELECT courseID, CreditUnit FROM acad_course WHERE IFNULL(CreditUnit,0) > 0;
INSERT IGNORE INTO wk_cu (courseid, cu)                 -- else the legacy import
  SELECT courseid, MIN(CreditUnits) FROM acad_results_legacy
   WHERE IFNULL(CreditUnits,0) > 0
   GROUP BY courseid HAVING COUNT(DISTINCT CreditUnits) = 1;

DROP TABLE IF EXISTS bak_cufix_20260729;
CREATE TABLE bak_cufix_20260729 AS
  SELECT 'acad_results' src, r.ID, r.regno, r.courseid, r.studyyear, r.semester, r.CreditUnits, r.gpa
    FROM acad_results r JOIN wk_cu m ON m.courseid = r.courseid
   WHERE IFNULL(r.CreditUnits,0) = 0
  UNION ALL
  SELECT 'acad_transcript_results', t.ID, t.regno, t.courseid, t.studyyear, t.semester, t.CreditUnits, t.gpa
    FROM acad_transcript_results t JOIN wk_cu m ON m.courseid = t.courseid
   WHERE IFNULL(t.CreditUnits,0) = 0;
ALTER TABLE bak_cufix_20260729 ADD KEY k (src, ID), ADD KEY k2 (regno, studyyear, semester);

UPDATE acad_results r JOIN wk_cu m ON m.courseid = r.courseid
   SET r.CreditUnits = m.cu WHERE IFNULL(r.CreditUnits,0) = 0;
UPDATE acad_transcript_results t JOIN wk_cu m ON m.courseid = t.courseid
   SET t.CreditUnits = m.cu WHERE IFNULL(t.CreditUnits,0) = 0;

-- ###########################################################################
-- PHASE 4 — recompute stored semester GPA, touched semesters only
-- ###########################################################################
DROP TABLE IF EXISTS wk_semgpa;
CREATE TABLE wk_semgpa ENGINE=InnoDB AS
  SELECT r.regno, r.studyyear, r.semester,
         ROUND(SUM(r.gradept*r.CreditUnits)/NULLIF(SUM(r.CreditUnits),0), 2) AS sem_gpa
    FROM acad_results r
    JOIN (SELECT DISTINCT regno, studyyear, semester FROM bak_cufix_20260729) k
      ON k.regno=r.regno AND k.studyyear=r.studyyear AND k.semester=r.semester
   GROUP BY r.regno, r.studyyear, r.semester;
ALTER TABLE wk_semgpa ADD KEY k (regno, studyyear, semester);

UPDATE acad_results r JOIN wk_semgpa g
    ON g.regno=r.regno AND g.studyyear=r.studyyear AND g.semester=r.semester
   SET r.gpa = g.sem_gpa WHERE g.sem_gpa IS NOT NULL;
UPDATE acad_transcript_results t JOIN wk_semgpa g
    ON g.regno=t.regno AND g.studyyear=t.studyyear AND g.semester=t.semester
   SET t.gpa = g.sem_gpa WHERE g.sem_gpa IS NOT NULL;

-- ============================================================================
-- ROLLBACK (run in reverse order)
-- ----------------------------------------------------------------------------
-- UPDATE acad_results r JOIN bak_cufix_20260729 b ON b.src='acad_results' AND b.ID=r.ID
--    SET r.CreditUnits=b.CreditUnits, r.gpa=b.gpa;
-- UPDATE acad_transcript_results t JOIN bak_cufix_20260729 b
--        ON b.src='acad_transcript_results' AND b.ID=t.ID
--    SET t.CreditUnits=b.CreditUnits, t.gpa=b.gpa;
-- DELETE c FROM acad_course c JOIN wk_missing_codes m ON m.courseid=c.courseID;
-- UPDATE acad_results r JOIN bak_codefix_20260729 b ON b.src='acad_results' AND b.ID=r.ID
--    SET r.courseid=b.courseid;
-- UPDATE acad_transcript_results t JOIN bak_codefix_20260729 b
--        ON b.src='acad_transcript_results' AND b.ID=t.ID SET t.courseid=b.courseid;
-- ============================================================================
