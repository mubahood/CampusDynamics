@echo off
"C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe" -h 102.34.160.47 -u dbmanager -p24thdecember1977 --default-character-set=latin1 campus_dynamics < "e:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\sql\verify_repair_results.sql" > "e:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\verify_out.txt" 2>&1
