# Test NCHE Exporter SQL Queries
Add-Type -AssemblyName System.Data
[System.Reflection.Assembly]::LoadWithPartialName("MySql.Data") | Out-Null

$connString = "server=102.34.160.47;User Id=dbmanager;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics;DefaultCommandTimeout=600"

function Test-Query {
    param(
        [string]$QueryName,
        [string]$SQL
    )
    
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "TEST: $QueryName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "SQL: $SQL`n" -ForegroundColor Gray
    
    try {
        $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
        $conn.Open()
        
        $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($SQL, $conn)
        $cmd.CommandTimeout = 10
        $reader = $cmd.ExecuteReader()
        
        $count = 0
        while ($reader.Read()) {
            if ($count -eq 0) {
                # Print headers
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    Write-Host $reader.GetName($i).PadRight(30) -NoNewline -ForegroundColor Green
                }
                Write-Host ""
                Write-Host ([string]::new('-', $reader.FieldCount * 30)) -ForegroundColor Green
            }
            
            # Print row
            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $value = if ($reader.IsDBNull($i)) { "(null)" } else { $reader.GetValue($i).ToString() }
                Write-Host $value.PadRight(30) -NoNewline
            }
            Write-Host ""
            $count++
        }
        
        $reader.Close()
        $conn.Close()
        
        Write-Host "`nRESULT: ✓ Success - $count rows returned" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: $_" -ForegroundColor Red
        Write-Host "RESULT: ✗ Failed" -ForegroundColor Red
    }
}

# Test 1: Entry Years
Test-Query "Entry Years Dropdown" `
    "SELECT DISTINCT TRIM(entryyear) AS entryyear FROM acad_student WHERE entryyear IS NOT NULL AND TRIM(entryyear) <> '' ORDER BY entryyear DESC LIMIT 10;"

# Test 2: Programmes
Test-Query "Programmes Dropdown" `
    "SELECT TRIM(progcode) AS progcode, CONCAT(TRIM(progcode), ' - ', TRIM(progname)) AS progname FROM acad_programme WHERE TRIM(progcode) <> '' ORDER BY progname LIMIT 10;"

# Test 3: Study Centres/Campuses  
Test-Query "Study Centres Dropdown" `
    "SELECT DISTINCT TRIM(campus_code) AS campus_code, TRIM(campus_name) AS campus_name FROM acad_campuses WHERE TRIM(campus_name) <> '' ORDER BY campus_name;"

# Test 4: Student Data Count
Test-Query "Student Data Count (All)" `
    "SELECT COUNT(*) as total_students FROM acad_student s LEFT JOIN acad_programme p ON s.progid = p.progcode;"

# Test 5: Student Data Sample
Test-Query "Student Data Sample (First 5)" `
    "SELECT CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) as names, COALESCE(s.gender, '') as sex, s.regno as reg_no, p.progcode, p.progname, COALESCE(c.campus_name, s.studCampus, 'Main Campus') as study_centre FROM acad_student s LEFT JOIN acad_programme p ON s.progid = p.progcode LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code LIMIT 5;"

# Test 6: Check if new_status values exist
Test-Query "Student Status Values" `
    "SELECT DISTINCT new_status FROM acad_student WHERE new_status IS NOT NULL LIMIT 10;"

Write-Host "`n===========================================" -ForegroundColor Yellow
Write-Host "Tests Complete" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Yellow
