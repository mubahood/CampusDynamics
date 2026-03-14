# Simple Database Test Script
Add-Type -AssemblyName System.Data
[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")

$connString = "server=102.34.160.47;User Id=dbmanager;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics;DefaultCommandTimeout=600"

function RunTest {
    param([string]$Title, [string]$SQL)
    Write-Host "`n$Title" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    try {
        $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
        $conn.Open()
        $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($SQL, $conn)
        $reader = $cmd.ExecuteReader()
        
        $count = 0
        while ($reader.Read()) {
            $output = ""
            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $val = if ($reader.IsDBNull($i)) { "NULL" } else { $reader.GetValue($i) }
                $output += "$val `t "
            }
            Write-Host $output
            $count++
        }
        
        $reader.Close()
        $conn.Close()
        Write-Host ("Result: OK - $count rows") -ForegroundColor Green
    }
    catch {
        Write-Host ("Error: " + $_.Exception.Message) -ForegroundColor Red
    }
}

# Test queries
Write-Host "DATABASE VERIFICATION TESTS" -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("Started: " + (Get-Date)) -ForegroundColor Yellow

RunTest "TEST 1: Entry Years" -SQL "SELECT DISTINCT TRIM(entryyear) as year FROM acad_student WHERE entryyear IS NOT NULL AND entryyear != '' ORDER BY entryyear DESC LIMIT 5"

RunTest "TEST 2: Programmes" -SQL "SELECT TRIM(progcode) as code, TRIM(progname) as name FROM acad_programme WHERE TRIM(progcode) != '' ORDER BY progname LIMIT 5"

RunTest "TEST 3: Campuses" -SQL "SELECT TRIM(campus_code) as code, TRIM(campus_name) as name FROM acad_campuses WHERE TRIM(campus_name) != '' ORDER BY campus_name"

RunTest "TEST 4: Total Students" -SQL "SELECT COUNT(*) as total_students FROM acad_student"

RunTest "TEST 5: Students by Status" -SQL "SELECT new_status, COUNT(*) as count FROM acad_student WHERE new_status IS NOT NULL GROUP BY new_status LIMIT 10"

RunTest "TEST 6: Student Sample" -SQL "SELECT s.regno, LEFT(CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')), 30) as name, s.gender, p.progcode, c.campus_name FROM acad_student s LEFT JOIN acad_programme p ON s.progid = p.progcode LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code LIMIT 3"

Write-Host "`nCompleted: $(Get-Date)" -ForegroundColor Yellow
