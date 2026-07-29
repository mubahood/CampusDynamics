-- Post-repair billing verification
USE campus_dynamics;

SELECT
    ar.acad_year,
    ar.semester,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM campus_dynamics_accounts.fin_studentfeestracking ft
            WHERE TRIM(ft.regno) = TRIM(ar.regno)
              AND ft.acadyear = ar.acad_year
              AND ft.semester = ar.semester
              AND UPPER(TRIM(ft.trans_type)) = 'BILL'
            LIMIT 1
        ) THEN 'BILLED'
        ELSE 'NOT_BILLED'
    END AS bill_status,
    COUNT(DISTINCT ar.regno) AS student_count
FROM campus_dynamics.acad_registration ar
INNER JOIN campus_dynamics.acad_student s
    ON TRIM(s.regno) = TRIM(ar.regno)
WHERE ar.acad_year = '2025/2026'
  AND ar.semester IN (1, 2, 3)
  AND ar.id >= 53668
  AND UPPER(TRIM(IFNULL(ar.regstatus, ''))) NOT IN ('DISCONTINUED', 'HALTED', 'DEAD YEAR', 'DE-REGISTERED')
GROUP BY ar.acad_year, ar.semester, bill_status
ORDER BY ar.semester, bill_status;

SELECT COUNT(*) AS bills_created_today, MIN(TID) AS first_tid, MAX(TID) AS last_tid
FROM campus_dynamics_accounts.fin_studentfeestracking
WHERE trans_type = 'Bill' AND DATE(trans_date) = '2026-05-05';
