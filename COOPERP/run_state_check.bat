@echo off
set MYSQL="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"
set CONN=-h 102.34.160.47 -u dbmanager -p24thdecember1977 --default-character-set=latin1
set OUT=E:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\current_state.txt

echo === CURRENT BILLING STATE AFTER REPAIR === > "%OUT%"
echo Run date: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === Summary: billed vs unbilled per semester (recent IDs since 53668) === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT ar.acad_year, ar.semester, CASE WHEN EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE TRIM(ft.regno)=TRIM(ar.regno) AND ft.acadyear=ar.acad_year AND ft.semester=ar.semester AND UPPER(TRIM(ft.trans_type))='BILL' LIMIT 1) THEN 'BILLED' ELSE 'NOT_BILLED' END AS bill_status, COUNT(DISTINCT ar.regno) AS students FROM campus_dynamics.acad_registration ar INNER JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(ar.regno) WHERE ar.acad_year='2025/2026' AND ar.semester IN (1,2,3) AND ar.id >= 53668 AND UPPER(TRIM(IFNULL(ar.regstatus,''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR','DE-REGISTERED') GROUP BY ar.acad_year, ar.semester, bill_status ORDER BY ar.semester, bill_status;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Registration status distribution for unbilled students === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT ar.regstatus, COUNT(DISTINCT ar.regno) AS cnt FROM campus_dynamics.acad_registration ar INNER JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(ar.regno) WHERE ar.acad_year='2025/2026' AND ar.semester IN (1,2,3) AND ar.id >= 53668 AND NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE TRIM(ft.regno)=TRIM(ar.regno) AND ft.acadyear=ar.acad_year AND ft.semester=ar.semester AND UPPER(TRIM(ft.trans_type))='BILL' LIMIT 1) AND UPPER(TRIM(IFNULL(ar.regstatus,''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR','DE-REGISTERED') GROUP BY ar.regstatus ORDER BY cnt DESC;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Sample of still-unbilled students === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT ar.regno, ar.acad_year, ar.semester, ar.regstatus FROM campus_dynamics.acad_registration ar INNER JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(ar.regno) WHERE ar.acad_year='2025/2026' AND ar.semester IN (1,2,3) AND ar.id >= 53668 AND NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE TRIM(ft.regno)=TRIM(ar.regno) AND ft.acadyear=ar.acad_year AND ft.semester=ar.semester AND UPPER(TRIM(ft.trans_type))='BILL' LIMIT 1) AND UPPER(TRIM(IFNULL(ar.regstatus,''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR','DE-REGISTERED') LIMIT 20;" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === Total bills created today (2026-05-05) === >> "%OUT%"
%MYSQL% %CONN% -e "SELECT COUNT(*) AS bills_today, MIN(TID) AS min_tid, MAX(TID) AS max_tid FROM campus_dynamics_accounts.fin_studentfeestracking WHERE trans_type='Bill' AND DATE(trans_date)='2026-05-05';" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === DONE === >> "%OUT%"
