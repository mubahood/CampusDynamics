-- =====================================================================
--  Remove one orphaned published result — MRU2025002744, ICT1101B
--
--  The student's Results page showed a single course, ICT1101B 2025/2026
--  Semester 1, mark 25, grade F, flagged "no registration", giving a CGPA
--  of 0.00 and a classification of "Below Pass".
--
--  What happened: the student held two 2025/2026 registrations —
--  Semester 1 REGISTERED and Semester 2 DEAD YEAR — and both were deleted
--  (they survive in acad_registration_regdel_bak). The result was left
--  behind. There is no semester registration for that year and no course
--  registration for ICT1101B either, so nothing supports the mark.
--
--  WHY ONLY THIS ONE ROW.
--
--  "A result with no semester registration" is NOT a usable definition of
--  an orphan: 513,645 results across 15,922 students match it, because
--  the marks migrated from the old system never had semester registrations
--  created. Deleting on that basis would destroy most of the results table.
--
--  Narrowing to results whose registration was actually DELETED gives 16
--  rows across 2 students. Of those, MRU2024000048's seven marks still
--  have their course registrations intact — only the semester row went, so
--  those results are real and are deliberately left alone. That student's
--  missing semester registration should be restored instead, which is a
--  separate matter raised with the Registrar.
--
--  That leaves exactly one row: no semester registration, no course
--  registration, and a dead year behind it.
--
--  Backed up before deletion. To restore:
--      INSERT INTO campus_dynamics.acad_results
--      SELECT * FROM campus_dynamics.bak_orphanresult_20260820;
-- =====================================================================
USE campus_dynamics;

DROP TABLE IF EXISTS bak_orphanresult_20260820;
CREATE TABLE bak_orphanresult_20260820 AS
SELECT * FROM acad_results
 WHERE regno='MRU2025002744' AND courseid='ICT1101B' AND acad='2025/2026';

SELECT '=== what is being removed (backed up above) ===' AS x;
SELECT ID, regno, courseid, acad, semester, score, grade, gradept, CreditUnits, progid
  FROM bak_orphanresult_20260820;

-- Attribute the change, so the acad_results delete trigger records a person.
INSERT INTO mark_audit_context (conn_id, actor, source, reason, ip, set_at)
VALUES (CONNECTION_ID(), 'MIS', 'orphan-result-cleanup',
        'Result left behind after the 2025/2026 registrations (incl. DEAD YEAR) were deleted', NULL, NOW())
ON DUPLICATE KEY UPDATE actor=VALUES(actor), source=VALUES(source), reason=VALUES(reason), set_at=NOW();

DELETE FROM acad_results
 WHERE regno='MRU2025002744' AND courseid='ICT1101B' AND acad='2025/2026';

SELECT '=== after ===' AS x;
SELECT (SELECT COUNT(*) FROM acad_results WHERE regno='MRU2025002744') AS results_left,
       (SELECT COUNT(*) FROM bak_orphanresult_20260820)                AS rows_backed_up,
       (SELECT IFNULL(acad_CGPAFinder('MRU2025002744'),0))             AS cgpa_now;

SELECT '=== the other student is untouched, and why ===' AS x;
SELECT regno, COUNT(*) AS results_kept,
       'course registrations still exist — marks are real; restore the semester row instead' AS note
  FROM acad_results WHERE regno='MRU2024000048' AND acad='2025/2026' GROUP BY regno;
