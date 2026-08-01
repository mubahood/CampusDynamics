$mysqlPath = 'C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe'
$outFile = 'e:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\sem_repair_final.txt'

function RunMysql($sql, $label) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $mysqlPath
    $psi.Arguments = '-h 102.34.160.47 -u dbmanager -p24thdecember1977 --default-character-set=latin1 campus_dynamics'
    $psi.RedirectStandardInput  = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($psi)
    $p.StandardInput.Write($sql)
    $p.StandardInput.Close()
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return "=== $label ===`r`n$out`r`nSTDERR: $err`r`n"
}

$result = ""

$result += RunMysql "CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026', 2, 53668, 'SYSTEM-REPAIR');" "SEM 2 REPAIR (3rd run)"
$result += RunMysql "CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026', 1, 53668, 'SYSTEM-REPAIR');" "SEM 1 REPAIR"
$result += RunMysql "CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026', 3, 53668, 'SYSTEM-REPAIR');" "SEM 3 REPAIR"

$verifyQ = @"
SELECT ar.acad_year, ar.semester,
  CASE WHEN EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft WHERE TRIM(ft.regno)=TRIM(ar.regno) AND ft.acadyear=ar.acad_year AND ft.semester=ar.semester AND UPPER(TRIM(ft.trans_type))='BILL' LIMIT 1) THEN 'BILLED' ELSE 'NOT_BILLED' END AS bill_status,
  COUNT(DISTINCT ar.regno) AS students
FROM campus_dynamics.acad_registration ar
INNER JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(ar.regno)
WHERE ar.acad_year='2025/2026' AND ar.semester IN (1,2,3) AND ar.id >= 53668
  AND UPPER(TRIM(IFNULL(ar.regstatus,''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR','DE-REGISTERED')
GROUP BY ar.acad_year, ar.semester, bill_status ORDER BY ar.semester, bill_status;
"@
$result += RunMysql $verifyQ "FINAL VERIFICATION"

$countQ = "SELECT COUNT(*) AS total_bills_today, COUNT(DISTINCT regno) AS students_billed_today FROM campus_dynamics_accounts.fin_studentfeestracking WHERE trans_type='Bill' AND DATE(trans_date)='2026-05-05';"
$result += RunMysql $countQ "BILLS CREATED TODAY"

$result | Set-Content $outFile
Write-Host "Done. Output written to $outFile"
Write-Host $result
