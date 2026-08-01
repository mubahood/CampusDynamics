@echo off
set MYSQL="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"
set Q=SELECT acad_year, semester, COUNT(*) as cnt FROM campus_dynamics.acad_registration WHERE acad_year='2025/2026' GROUP BY acad_year, semester;
%MYSQL% -h 102.34.160.47 -u dbmanager -p24thdecember1977 --default-character-set=latin1 -t -e "%Q%" > "e:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\verify_out.txt" 2>&1
