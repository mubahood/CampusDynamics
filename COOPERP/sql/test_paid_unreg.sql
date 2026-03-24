-- Test paid but unregistered query
SELECT ft.regno,
    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
    COALESCE(s.progid,'') AS progid,
    SUM(ft.amount) AS total_paid_30d,
    MAX(ft.trans_date) AS last_payment,
    COALESCE(r.regstatus, 'NO RECORD') AS reg_status
FROM fin_studentfeestracking ft
LEFT JOIN campus_dynamics.acad_student s ON s.regno = ft.regno
LEFT JOIN campus_dynamics.acad_registration r 
    ON r.regno = ft.regno AND r.acad_year = '2025/2026'
    AND r.semester = (SELECT MAX(r2.semester) FROM campus_dynamics.acad_registration r2 WHERE r2.regno=ft.regno AND r2.acad_year='2025/2026')
WHERE ft.trans_type = 'Payment'
  AND ft.acadyear = '2025/2026'
  AND ft.trans_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  AND (r.regstatus IS NULL OR r.regstatus NOT IN ('REGISTERED','LATE REGISTERED','CLEARED'))
GROUP BY ft.regno
ORDER BY total_paid_30d DESC
LIMIT 20;
