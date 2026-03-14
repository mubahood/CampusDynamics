# Test NCHE SQL Queries
Add-Type -AssemblyName System.Data
[System.Reflection.Assembly]::LoadWithPartialName("MySql.Data") | Out-Null

$connString = "server=102.34.160.47;User Id=dbmanager;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics;DefaultCommandTimeout=600"

Write-Host "Testing NCHE Exporter SQL Queries`n" -ForegroundColor Cyan

# Test 1: Entry Years
Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "TEST 1: Entry Years" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow

$sql1 = @"
SELECT DISTINCT TRIM(entryyear) AS entryyear 
FROM acad_student 
WHERE entryyear IS NOT NULL AND TRIM(entryyear) != ''
ORDER BY entryyear DESC LIMIT 10
"@

try {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
    $conn.Open()
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sql1, $conn)
    $reader = $cmd.ExecuteReader()
    $count = 0
    while ($reader.Read()) {
        Write-Host $reader["entryyear"]
        $count++
    }
    $reader.Close()
    $conn.Close()
    Write-Host "✓ Success: $count entry years found`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $_`n" -ForegroundColor Red
}

# Test 2: Programmes
Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "TEST 2: Programmes" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow

$sql2 = @"
SELECT TRIM(progcode) AS progcode, 
       CONCAT(TRIM(progcode), ' - ', TRIM(progname)) AS progname 
FROM acad_programme 
WHERE TRIM(progcode) != '' 
ORDER BY progname 
LIMIT 10
"@

try {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
    $conn.Open()
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sql2, $conn)
    $reader = $cmd.ExecuteReader()
    $count = 0
    while ($reader.Read()) {
        Write-Host ("{0} = {1}" -f $reader["progcode"], $reader["progname"])
        $count++
    }
    $reader.Close()
    $conn.Close()
    Write-Host "✓ Success: $count programmes found`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $_`n" -ForegroundColor Red
}

# Test 3: Campuses
Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "TEST 3: Study Centres (Campuses)" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow

$sql3 = @"
SELECT DISTINCT TRIM(campus_code) AS campus_code, 
                TRIM(campus_name) AS campus_name 
FROM acad_campuses 
WHERE TRIM(campus_name) != '' 
ORDER BY campus_name
"@

try {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
    $conn.Open()
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sql3, $conn)
    $reader = $cmd.ExecuteReader()
    $count = 0
    while ($reader.Read()) {
        Write-Host ("{0} = {1}" -f $reader["campus_code"], $reader["campus_name"])
        $count++
    }
    $reader.Close()
    $conn.Close()
    Write-Host "✓ Success: $count campuses found`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $_`n" -ForegroundColor Red
}

# Test 4: Student Count
Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "TEST 4: Total Student Count" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow

$sql4 = "SELECT COUNT(*) as total FROM acad_student"

try {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
    $conn.Open()
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sql4, $conn)
    $result = $cmd.ExecuteScalar()
    Write-Host "Total students: $result" -ForegroundColor Green
    $conn.Close()
    Write-Host "✓ Success`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $_`n" -ForegroundColor Red
}

# Test 5: Sample Student Data
Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "TEST 5: Sample Student Records (First 3)" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow

$sql5 = @"
SELECT MAX(s.regno) as reg_no,
       MAX(CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, ''))) as name,
       MAX(s.gender) as gender,
       MAX(p.progcode) as prog_code,
       MAX(p.progname) as prog_name,
       MAX(c.campus_name) as campus_name,
       COUNT(*) as matches
FROM acad_student s
LEFT JOIN acad_programme p ON s.progid = p.progcode
LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
GROUP BY s.progid
LIMIT 3
"@

try {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
    $conn.Open()
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sql5, $conn)
    $reader = $cmd.ExecuteReader()
    $count = 0
    Write-Host ("{0,-15} {1,-30} {2,-10} {3,-10} {4,-30} {5,-15}" -f "RegNo","Name","Gender","ProgCode","ProgName","Campus") -ForegroundColor White
    Write-Host ("-" * 110) -ForegroundColor Gray
    while ($reader.Read()) {
        Write-Host ("{0,-15} {1,-30} {2,-10} {3,-10} {4,-30} {5,-15}" -f $reader["reg_no"], $reader["name"], $reader["gender"], $reader["prog_code"], $reader["prog_name"], $reader["campus_name"])
        $count++
    }
    $reader.Close()
    $conn.Close()
    Write-Host "✓ Success: $count sample records`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $_`n" -ForegroundColor Red
}

# Test 6: Student Status Values
Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "TEST 6: Student Status Values" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow

$sql6 = "SELECT DISTINCT new_status FROM acad_student WHERE new_status IS NOT NULL LIMIT 10"

try {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connString)
    $conn.Open()
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sql6, $conn)
    $reader = $cmd.ExecuteReader()
    $count = 0
    while ($reader.Read()) {
        Write-Host $reader["new_status"]
        $count++
    }
    $reader.Close()
    $conn.Close()
    Write-Host "✓ Success: $count status values found`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $_`n" -ForegroundColor Red
}

Write-Host "=" * 50 -ForegroundColor Yellow
Write-Host "All Tests Complete" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Yellow
