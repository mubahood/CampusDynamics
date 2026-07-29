-- Verification (run post-mutation, inside the txn for dry-run, or after commit for live)
SET NAMES utf8;
SELECT '--- NO-LOSS INVARIANT (results) ---' AS check_;
SELECT 627925 AS before_,
       (SELECT COUNT(*) FROM campus_dynamics.acad_results) AS after_,
       (SELECT COUNT(*) FROM campus_dynamics.acad_results_quarantine WHERE run_tag='dedup20260718') AS quarantined,
       (SELECT COUNT(*) FROM campus_dynamics.acad_results) +
       (SELECT COUNT(*) FROM campus_dynamics.acad_results_quarantine WHERE run_tag='dedup20260718') AS after_plus_quar,
       IF(627925 = (SELECT COUNT(*) FROM campus_dynamics.acad_results)+(SELECT COUNT(*) FROM campus_dynamics.acad_results_quarantine WHERE run_tag='dedup20260718'),'PASS','FAIL') AS verdict;

SELECT '--- NO-LOSS INVARIANT (registrations) ---' AS check_;
SELECT 130565 AS before_,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration) AS after_,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration_quarantine WHERE run_tag='dedup20260718') AS quarantined,
       IF(130565 = (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration)+(SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration_quarantine WHERE run_tag='dedup20260718'),'PASS','FAIL') AS verdict;

SELECT '--- no loser codes remain in results / registration (expect 0) ---' AS check_;
SELECT (SELECT COUNT(*) FROM campus_dynamics.acad_results r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc) AS results_with_loser,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration g JOIN campus_dynamics._cd_losers l ON TRIM(g.courseID)=l.cc) AS regs_with_loser;

SELECT '--- all MERGE losers now MERGED (after=driver count) ---' AS check_;
SELECT (SELECT COUNT(*) FROM campus_dynamics._cd_losers) AS driver_losers,
       (SELECT COUNT(*) FROM campus_dynamics.acad_course c JOIN campus_dynamics._cd_losers l ON TRIM(c.courseID)=l.cc WHERE c.course_state='MERGED') AS losers_merged;

SELECT '--- post-merge duplicate results per (regno,courseid,sem,acad) on survivor codes (expect 0) ---' AS check_;
SELECT COUNT(*) AS dup_groups FROM (
  SELECT r.regno, TRIM(r.courseid) cc, r.semester, TRIM(r.acad) acad, COUNT(*) n
  FROM campus_dynamics.acad_results r
  JOIN campus_dynamics._cd_survset s ON TRIM(r.courseid)=s.cc
  GROUP BY r.regno, TRIM(r.courseid), r.semester, TRIM(r.acad) HAVING n>1
) d;

SELECT '--- survivor result totals after merge (sample) ---' AS check_;
SELECT l.cc survivor, COUNT(*) results_now
FROM campus_dynamics.acad_results r JOIN campus_dynamics._cd_survset l ON TRIM(r.courseid)=l.cc
GROUP BY l.cc ORDER BY results_now DESC LIMIT 6;
