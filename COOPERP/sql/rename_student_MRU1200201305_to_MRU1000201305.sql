-- ============================================================
-- STUDENT SYSTEM-ID RENAME
-- FROM : MRU1200201305
-- TO   : MRU1000201305
-- entryno (reg number) : 12/U/DPE/0019/KB/INSRV  (UNCHANGED)
--
-- PRE-FLIGHT (verified before executing):
--   Source MRU1200201305 exists in:
--     acad_student             1 row
--     acad_results            31 rows
--     acad_transcript_results 31 rows
--     acad_registration        6 rows
--     acad_graduands           1 row
--     acad_examresults_faculty 31 rows
--   Target MRU1000201305 exists in NONE of those tables (zero collision)
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES   = 0;

START TRANSACTION;

-- ── 1. acad_results  (31 rows) ───────────────────────────────
UPDATE acad_results
   SET regno = 'MRU1000201305'
 WHERE regno = 'MRU1200201305';

-- ── 2. acad_transcript_results  (31 rows) ────────────────────
UPDATE acad_transcript_results
   SET regno = 'MRU1000201305'
 WHERE regno = 'MRU1200201305';

-- ── 3. acad_registration  (6 rows) ───────────────────────────
UPDATE acad_registration
   SET regno = 'MRU1000201305'
 WHERE regno = 'MRU1200201305';

-- ── 4. acad_graduands  (1 row) ───────────────────────────────
UPDATE acad_graduands
   SET regno = 'MRU1000201305'
 WHERE regno = 'MRU1200201305';

-- ── 5. acad_examresults_faculty  (31 rows) ───────────────────
UPDATE acad_examresults_faculty
   SET regno = 'MRU1000201305'
 WHERE regno = 'MRU1200201305';

-- ── 6. acad_student  (1 row — PK, always last) ───────────────
UPDATE acad_student
   SET regno = 'MRU1000201305'
 WHERE regno = 'MRU1200201305';

-- ============================================================
-- POST-CHANGE VERIFICATION
-- Expected NEW counts : 1 / 31 / 31 / 6 / 1 / 31
-- Expected OLD counts : all 0
-- If ANY old-count column shows > 0 the rename is incomplete.
-- If ANY new-count column shows 0  the rename is incomplete.
-- ============================================================
SELECT
    'NEW acad_student'             AS check_item,
    COUNT(*)                       AS row_count,
    IF(COUNT(*)=1,'OK','** PROBLEM **') AS status
FROM acad_student WHERE regno='MRU1000201305'
UNION ALL
SELECT 'NEW acad_results', COUNT(*),
    IF(COUNT(*)=31,'OK','** PROBLEM **')
FROM acad_results WHERE regno='MRU1000201305'
UNION ALL
SELECT 'NEW acad_transcript_results', COUNT(*),
    IF(COUNT(*)=31,'OK','** PROBLEM **')
FROM acad_transcript_results WHERE regno='MRU1000201305'
UNION ALL
SELECT 'NEW acad_registration', COUNT(*),
    IF(COUNT(*)=6,'OK','** PROBLEM **')
FROM acad_registration WHERE regno='MRU1000201305'
UNION ALL
SELECT 'NEW acad_graduands', COUNT(*),
    IF(COUNT(*)=1,'OK','** PROBLEM **')
FROM acad_graduands WHERE regno='MRU1000201305'
UNION ALL
SELECT 'NEW acad_examresults_faculty', COUNT(*),
    IF(COUNT(*)=31,'OK','** PROBLEM **')
FROM acad_examresults_faculty WHERE regno='MRU1000201305'
UNION ALL
SELECT '--- OLD ID MUST BE ZERO ------', NULL, NULL
UNION ALL
SELECT 'OLD acad_student', COUNT(*),
    IF(COUNT(*)=0,'OK','** PROBLEM **')
FROM acad_student WHERE regno='MRU1200201305'
UNION ALL
SELECT 'OLD acad_results', COUNT(*),
    IF(COUNT(*)=0,'OK','** PROBLEM **')
FROM acad_results WHERE regno='MRU1200201305'
UNION ALL
SELECT 'OLD acad_transcript_results', COUNT(*),
    IF(COUNT(*)=0,'OK','** PROBLEM **')
FROM acad_transcript_results WHERE regno='MRU1200201305'
UNION ALL
SELECT 'OLD acad_registration', COUNT(*),
    IF(COUNT(*)=0,'OK','** PROBLEM **')
FROM acad_registration WHERE regno='MRU1200201305'
UNION ALL
SELECT 'OLD acad_graduands', COUNT(*),
    IF(COUNT(*)=0,'OK','** PROBLEM **')
FROM acad_graduands WHERE regno='MRU1200201305'
UNION ALL
SELECT 'OLD acad_examresults_faculty', COUNT(*),
    IF(COUNT(*)=0,'OK','** PROBLEM **')
FROM acad_examresults_faculty WHERE regno='MRU1200201305';

-- If you see ** PROBLEM ** above, run ROLLBACK; instead of COMMIT;
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES   = 1;

-- Final confirmation
SELECT 'RENAME COMPLETE' AS result,
       regno, entryno, firstname, progid
FROM acad_student WHERE regno='MRU1000201305';
