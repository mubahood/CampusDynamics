USE campus_dynamics;

-- Cohort under the ENTRY-YEAR method, v2.
-- CHANGE FROM v1: programme length now comes from the programme master
-- (acad_programme.couselength) FIRST, falling back to the per-student
-- acad_student.duration only when the master is missing. The master is
-- internally consistent with level and award name (all 40 diplomas = 2 years)
-- and is corroborated by the fee structures; the per-student field is
-- free data entry and holds 57 contradictions, 15 of them diplomas
-- carrying 3 or 4 years against a 2-year award.
DROP TABLE IF EXISTS _ey2;
CREATE TABLE _ey2 AS
SELECT
    s.regno,
    s.entryyear,
    (2026 - s.entryyear + 1)                              AS yr_by_entry,
    r.studyyear                                           AS yr_recorded,
    s.progid,
    COALESCE(NULLIF(p.couselength,0), NULLIF(s.duration,0), 0) AS prog_len,
    COALESCE(NULLIF(s.duration,0), 0)                     AS stud_len,
    IFNULL(p.levelCode,0)                                 AS level_code,
    CASE IFNULL(p.levelCode,0)
        WHEN 1 THEN 'Certificate' WHEN 2 THEN 'Diploma' WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Postgraduate Diploma' WHEN 5 THEN 'Masters' ELSE '(unclassified)' END AS award,
    IFNULL(s.studCampus,0)                                AS campus_id,
    IFNULL(c.campus_name,'(unassigned)')                  AS campus_name,
    TRIM(IFNULL(p.faculty_code,'00'))                     AS faculty_code,
    IFNULL(f.faculty_name,'(unmapped)')                   AS faculty_name,
    s.gender,
    IFNULL((SELECT SUM(l.transaction_amount) FROM campus_dynamics_accounts.fin_ledger l
             WHERE l.accountcode = s.regno AND l.transactionType='CR'),0)                 AS paid_all
FROM (SELECT regno, MIN(studyyear) studyyear FROM acad_registration
       WHERE acad_year='2026/2027' AND IFNULL(studyyear,0)>0 GROUP BY regno) r
JOIN acad_student s ON s.regno = r.regno
LEFT JOIN acad_programme p ON p.progcode = s.progid
LEFT JOIN acad_faculty   f ON TRIM(f.faculty_code) = TRIM(p.faculty_code)
LEFT JOIN acad_campuses  c ON c.ID = s.studCampus
WHERE s.entryyear BETWEEN 2019 AND 2026;

ALTER TABLE _ey2 ADD PRIMARY KEY(regno);
ALTER TABLE _ey2 ADD COLUMN money_ok TINYINT DEFAULT 0;
UPDATE _ey2 SET money_ok = (entryyear = 2026 OR paid_all > 500000);
ALTER TABLE _ey2 ADD COLUMN status VARCHAR(20);
UPDATE _ey2 SET status = CASE
    WHEN prog_len = 0                  THEN 'unknown length'
    WHEN yr_by_entry >  prog_len       THEN 'beyond duration'
    WHEN yr_by_entry =  prog_len       THEN 'graduating'
    ELSE 'continuing' END;
ALTER TABLE _ey2 ADD INDEX ix(status, money_ok, yr_by_entry);

SELECT '=== 1. HOW MANY CHANGED BECAUSE OF THE LENGTH SOURCE ===' AS x;
SELECT award, COUNT(*) students,
       SUM(stud_len<>prog_len AND stud_len>0) AS 'student record contradicts master'
  FROM _ey2 GROUP BY award ORDER BY level_code;

SELECT '=== 2. CONTINUING (money test applied) ===' AS x;
SELECT yr_by_entry AS year, COUNT(*) students
  FROM _ey2 WHERE status='continuing' AND money_ok=1 GROUP BY yr_by_entry ORDER BY yr_by_entry;

SELECT '=== 3. GRADUATING, BY AWARD (money test applied) ===' AS x;
SELECT award, prog_len AS years, COUNT(*) students
  FROM _ey2 WHERE status='graduating' AND money_ok=1
 GROUP BY award, prog_len ORDER BY level_code, prog_len;

SELECT '=== 4. GRADUATING BY CAMPUS AND AWARD ===' AS x;
SELECT campus_name, award, COUNT(*) students
  FROM _ey2 WHERE status='graduating' AND money_ok=1
 GROUP BY campus_name, award ORDER BY campus_name, level_code;

SELECT '=== 5. BEYOND NOMINAL DURATION (entered earlier than their award allows) ===' AS x;
SELECT award, prog_len AS years, yr_by_entry AS years_since_entry, COUNT(*) students,
       SUM(money_ok) AS pass_money
  FROM _ey2 WHERE status='beyond duration'
 GROUP BY award, prog_len, yr_by_entry ORDER BY level_code, yr_by_entry;

SELECT '=== 6. CONTINUING BY CAMPUS / FACULTY ===' AS x;
SELECT campus_name, COUNT(*) s FROM _ey2 WHERE status='continuing' AND money_ok=1 GROUP BY campus_name;
SELECT faculty_name, COUNT(*) s FROM _ey2 WHERE status='continuing' AND money_ok=1 GROUP BY faculty_name ORDER BY s DESC;

SELECT '=== 7. WHOLE PICTURE ===' AS x;
SELECT status, SUM(money_ok=1) passes_money, SUM(money_ok=0) excluded_by_money, COUNT(*) total
  FROM _ey2 GROUP BY status;
