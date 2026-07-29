SELECT '=== SUMMARY: latest registration id by year/semester ===' AS section;
SELECT acad_year, semester, COUNT(*) AS rows_in_scope, MAX(ID) AS max_reg_id
FROM campus_dynamics.acad_registration
WHERE regstatus IN ('REGISTERED','LATE REGISTERED','LATE-REGISTERED','CLEARED')
GROUP BY acad_year, semester
ORDER BY acad_year DESC, semester DESC
LIMIT 10;

SELECT '=== DETAIL: recent registered but NOT billed (latest data year/semester) ===' AS section;
SELECT 
    r.ID AS reg_id,
    r.regno,
    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
    COALESCE(s.progid,'') AS progcode,
    COALESCE(p.progname,'') AS programme,
    r.acad_year,
    r.semester,
    r.studyyear,
    r.regstatus,
    r.conducted_new_registration,
    IFNULL(b.bill_count,0) AS bill_count
FROM campus_dynamics.acad_registration r
INNER JOIN (
    SELECT regno, acad_year, semester, MAX(ID) AS max_id
    FROM campus_dynamics.acad_registration
    WHERE regstatus IN ('REGISTERED','LATE REGISTERED','LATE-REGISTERED','CLEARED')
    GROUP BY regno, acad_year, semester
) rm ON rm.max_id = r.ID
LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(r.regno)
LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = s.progid
LEFT JOIN (
    SELECT regno, acadyear, semester, COUNT(*) AS bill_count
    FROM campus_dynamics_accounts.fin_studentfeestracking
    WHERE UPPER(TRIM(trans_type))='BILL'
    GROUP BY regno, acadyear, semester
) b ON TRIM(b.regno)=TRIM(r.regno) AND b.acadyear=r.acad_year AND b.semester=r.semester
WHERE r.acad_year = (
        SELECT ar.acad_year
        FROM campus_dynamics.acad_registration ar
        GROUP BY ar.acad_year
        ORDER BY ar.acad_year DESC
        LIMIT 1
    )
  AND r.semester = (
        SELECT ar2.semester
        FROM campus_dynamics.acad_registration ar2
        WHERE ar2.acad_year = (
            SELECT ar3.acad_year
            FROM campus_dynamics.acad_registration ar3
            GROUP BY ar3.acad_year
            ORDER BY ar3.acad_year DESC
            LIMIT 1
        )
        GROUP BY ar2.semester
        ORDER BY ar2.semester DESC
        LIMIT 1
    )
  AND IFNULL(b.bill_count,0)=0
ORDER BY r.ID DESC
LIMIT 500;

SELECT '=== DETAIL: recent registered but NOT billed (configured current academic year) ===' AS section;
SELECT 
    r.ID AS reg_id,
    r.regno,
    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
    COALESCE(s.progid,'') AS progcode,
    COALESCE(p.progname,'') AS programme,
    r.acad_year,
    r.semester,
    r.studyyear,
    r.regstatus,
    r.conducted_new_registration,
    IFNULL(b.bill_count,0) AS bill_count
FROM campus_dynamics.acad_registration r
INNER JOIN (
    SELECT regno, acad_year, semester, MAX(ID) AS max_id
    FROM campus_dynamics.acad_registration
    WHERE regstatus IN ('REGISTERED','LATE REGISTERED','LATE-REGISTERED','CLEARED')
    GROUP BY regno, acad_year, semester
) rm ON rm.max_id = r.ID
LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(r.regno)
LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = s.progid
LEFT JOIN (
    SELECT regno, acadyear, semester, COUNT(*) AS bill_count
    FROM campus_dynamics_accounts.fin_studentfeestracking
    WHERE UPPER(TRIM(trans_type))='BILL'
    GROUP BY regno, acadyear, semester
) b ON TRIM(b.regno)=TRIM(r.regno) AND b.acadyear=r.acad_year AND b.semester=r.semester
WHERE r.acad_year = (
        SELECT acadyear FROM campus_dynamics.acad_acadyears
        WHERE is_current_year='Yes'
        LIMIT 1
    )
  AND IFNULL(b.bill_count,0)=0
ORDER BY r.ID DESC
LIMIT 500;
