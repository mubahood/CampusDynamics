@echo off
set MYSQL="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"
set CONN=-h 102.34.160.47 -u dbmanager -p24thdecember1977 --default-character-set=latin1
set OUT=E:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\repair_run_results.txt

echo ========================================= > "%OUT%"
echo SYSTEM REPAIR - REGISTER + AUTOBILL RUN >> "%OUT%"
echo Run date: %DATE% %TIME% >> "%OUT%"
echo ========================================= >> "%OUT%"

echo. >> "%OUT%"
echo === SEMESTER 2 REPAIR === >> "%OUT%"
%MYSQL% %CONN% campus_dynamics -e "CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026', 2, 53668, 'SYSTEM-REPAIR');" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === SEMESTER 1 REPAIR === >> "%OUT%"
%MYSQL% %CONN% campus_dynamics -e "CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026', 1, 53668, 'SYSTEM-REPAIR');" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === SEMESTER 3 REPAIR === >> "%OUT%"
%MYSQL% %CONN% campus_dynamics -e "CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026', 3, 53668, 'SYSTEM-REPAIR');" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === POST-REPAIR VERIFICATION === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT ar.acad_year, ar.semester, CASE WHEN EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE TRIM(ft.regno)=TRIM(ar.regno) AND ft.acadyear=ar.acad_year AND ft.semester=ar.semester AND UPPER(TRIM(ft.trans_type))='BILL' LIMIT 1) THEN 'BILLED' ELSE 'NOT_BILLED' END AS bill_status, COUNT(DISTINCT ar.regno) AS student_count FROM campus_dynamics.acad_registration ar INNER JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(ar.regno) WHERE ar.acad_year='2025/2026' AND ar.semester IN (1,2,3) AND ar.id >= 53668 AND UPPER(TRIM(IFNULL(ar.regstatus,''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR','DE-REGISTERED') GROUP BY ar.acad_year, ar.semester, bill_status ORDER BY ar.semester, bill_status;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === DONE === >> "%OUT%"
echo Results saved to: %OUT%
type "%OUT%"
