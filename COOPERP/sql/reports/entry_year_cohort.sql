USE campus_dynamics;

-- ENTRY-YEAR BASIS, v3 — THREE COMPONENTS ONLY.
--   1. entry year        -> year of study
--   2. programme length  -> who is graduating
--   3. positive transactions > 500,000 (anyone not entry 2026)
-- Semester registration is NOT used anywhere: the base population is every
-- student record with an entry year of 2023-2026, registered or not.
--
-- "Positive transaction" = any credit, whatever its source (cash, bursary,
-- waiver, adjustment). Two tables hold them and they overlap, so GREATEST is
-- used rather than a sum — adding them would double-count and wrongly PASS
-- students, which is the direction that matters for a threshold test.
DROP TABLE IF EXISTS _ey3;
CREATE TABLE _ey3 AS
SELECT
    s.regno,
    s.entryyear,
    (2026 - s.entryyear + 1)                                   AS yr_by_entry,
    s.progid,
    COALESCE(NULLIF(p.couselength,0), NULLIF(s.duration,0), 0) AS prog_len,
    IFNULL(p.levelCode,0)                                      AS level_code,
    CASE IFNULL(p.levelCode,0)
        WHEN 1 THEN 'Certificate' WHEN 2 THEN 'Diploma' WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Postgraduate Diploma' WHEN 5 THEN 'Masters'
        ELSE '(unclassified)' END                              AS award,
    IFNULL(c.campus_name,'(unassigned)')                       AS campus_name,
    IFNULL(f.faculty_name,'(unmapped)')                        AS faculty_name,
    s.gender,
    IFNULL((SELECT SUM(l.transaction_amount) FROM campus_dynamics_accounts.fin_ledger l
             WHERE l.accountcode = s.regno AND l.transactionType='CR'),0)          AS cr_ledger,
    IFNULL((SELECT SUM(t.amount) FROM campus_dynamics_accounts.fin_studentfeestracking t
             WHERE t.regno = s.regno AND t.trans_type='Payment'),0)                AS cr_track
FROM acad_student s
LEFT JOIN acad_programme p ON p.progcode = s.progid
LEFT JOIN acad_faculty   f ON TRIM(f.faculty_code) = TRIM(p.faculty_code)
LEFT JOIN acad_campuses  c ON c.ID = s.studCampus
WHERE s.entryyear BETWEEN 2023 AND 2026;

ALTER TABLE _ey3 ADD PRIMARY KEY(regno);
ALTER TABLE _ey3 ADD COLUMN positive_txn DOUBLE DEFAULT 0;
UPDATE _ey3 SET positive_txn = GREATEST(cr_ledger, cr_track);
ALTER TABLE _ey3 ADD COLUMN money_ok TINYINT DEFAULT 0;
UPDATE _ey3 SET money_ok = (entryyear = 2026 OR positive_txn > 500000);
ALTER TABLE _ey3 ADD COLUMN status VARCHAR(20);
UPDATE _ey3 SET status = CASE
    WHEN prog_len = 0            THEN 'unknown length'
    WHEN yr_by_entry >  prog_len THEN 'past duration'
    WHEN yr_by_entry =  prog_len THEN 'graduating'
    ELSE 'continuing' END;
ALTER TABLE _ey3 ADD INDEX ix(status, money_ok, yr_by_entry);

SELECT '=== 1. BASE POPULATION (no register filter) ===' AS x;
SELECT entryyear, yr_by_entry, COUNT(*) students FROM _ey3 GROUP BY entryyear ORDER BY entryyear DESC;

SELECT '=== 2. DOES THE SECOND MONEY SOURCE CHANGE ANYONE? ===' AS x;
SELECT SUM(cr_ledger > 500000)  AS pass_on_ledger_only,
       SUM(cr_track  > 500000)  AS pass_on_tracking_only,
       SUM(positive_txn > 500000) AS pass_on_greatest,
       SUM(cr_track > 500000 AND cr_ledger <= 500000) AS 'rescued by tracking',
       SUM(cr_ledger + cr_track > 500000 AND positive_txn <= 500000) AS 'would pass only if double-counted'
  FROM _ey3 WHERE entryyear <> 2026;

SELECT '=== 3. THE MONEY TEST ===' AS x;
SELECT CASE WHEN entryyear=2026 THEN 'Year 1 (entry 2026) - exempt'
            WHEN positive_txn > 500000 THEN 'passes'
            ELSE 'EXCLUDED' END AS verdict, COUNT(*) students, ROUND(AVG(positive_txn)) avg_txn
  FROM _ey3 GROUP BY verdict;

SELECT '=== 4. CONTINUING ===' AS x;
SELECT yr_by_entry AS year, COUNT(*) students FROM _ey3
 WHERE status='continuing' AND money_ok=1 GROUP BY yr_by_entry ORDER BY yr_by_entry;

SELECT '=== 5. GRADUATING, BY AWARD ===' AS x;
SELECT award, prog_len AS years, COUNT(*) students FROM _ey3
 WHERE status='graduating' AND money_ok=1 GROUP BY award, prog_len ORDER BY level_code;

SELECT '=== 6. WHOLE PICTURE ===' AS x;
SELECT status, SUM(money_ok=1) counted, SUM(money_ok=0) excluded, COUNT(*) total
  FROM _ey3 GROUP BY status;

SELECT '=== 7. CAMPUS / FACULTY (continuing) ===' AS x;
SELECT campus_name, SUM(yr_by_entry=1) y1, SUM(yr_by_entry=2) y2, SUM(yr_by_entry=3) y3, COUNT(*) tot
  FROM _ey3 WHERE status='continuing' AND money_ok=1 GROUP BY campus_name;
SELECT faculty_name, SUM(yr_by_entry=1) y1, SUM(yr_by_entry=2) y2, SUM(yr_by_entry=3) y3, COUNT(*) tot
  FROM _ey3 WHERE status='continuing' AND money_ok=1 GROUP BY faculty_name ORDER BY tot DESC;

SELECT '=== 8. GRADUANDS BY CAMPUS / FACULTY ===' AS x;
SELECT campus_name, award, COUNT(*) s FROM _ey3 WHERE status='graduating' AND money_ok=1
 GROUP BY campus_name, award ORDER BY campus_name, level_code;
SELECT faculty_name, COUNT(*) s FROM _ey3 WHERE status='graduating' AND money_ok=1
 GROUP BY faculty_name ORDER BY s DESC;
