# NCHE Exporter - Database Verification & Optimization Script

## Pre-Deployment Database Check

Run these queries to verify data completeness before first use:

### 1. Check for Missing Required Fields

```sql
-- Check students missing national ID
SELECT COUNT(*) as missing_national_id FROM acad_student 
WHERE national_id IS NULL OR national_id = '';

-- Check students missing registro/registration number
SELECT COUNT(*) as missing_regno FROM acad_student 
WHERE regno IS NULL OR regno = '';

-- Check students missing name fields
SELECT COUNT(*) as missing_name FROM acad_student 
WHERE (first_name IS NULL OR first_name = '') 
  OR (last_name IS NULL OR last_name = '');

-- Check students missing programme assignment
SELECT COUNT(*) as missing_prog FROM acad_student 
WHERE prog_id IS NULL OR prog_id = '';

-- Check students missing year of study
SELECT COUNT(*) as missing_year FROM acad_student 
WHERE year_of_study IS NULL;

-- Check students with no status assigned
SELECT COUNT(*) as no_status FROM acad_student 
WHERE new_status IS NULL OR new_status = '';
```

### 2. Data Completeness Report

```sql
-- Get overall data completeness percentage
SELECT 
    (SELECT COUNT(*) FROM acad_student) as total_students,
    (SELECT COUNT(*) FROM acad_student WHERE national_id IS NOT NULL AND national_id != '') as with_national_id,
    (SELECT COUNT(*) FROM acad_student WHERE regno IS NOT NULL AND regno != '') as with_regno,
    (SELECT COUNT(*) FROM acad_student WHERE first_name IS NOT NULL) as with_name,
    (SELECT COUNT(*) FROM acad_student WHERE prog_id IS NOT NULL) as with_prog,
    (SELECT COUNT(*) FROM acad_student WHERE new_status IS NOT NULL) as with_status,
    CONCAT(
        ROUND((SELECT COUNT(*) FROM acad_student WHERE national_id IS NOT NULL AND national_id != '') / 
              (SELECT COUNT(*) FROM acad_student) * 100, 2),
        '%'
    ) as national_id_coverage
```

### 3. Programme Data Verification

```sql
-- Verify all active programmes have award levels
SELECT prog_id, prog_code, prog_name, award_level, COUNT(*) as student_count
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE s.new_status = 'ACTIVE'
GROUP BY s.prog_id
ORDER BY student_count DESC;

-- Check for orphaned programme IDs (student programme not in acad_programme table)
SELECT DISTINCT s.prog_id
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE p.prog_id IS NULL AND s.prog_id IS NOT NULL;
```

### 4. Academic Year Consistency

```sql
-- List all academic years in system
SELECT DISTINCT acad_year, COUNT(*) as student_count
FROM acad_student
WHERE acad_year IS NOT NULL
GROUP BY acad_year
ORDER BY acad_year DESC;

-- Verify current year students
SELECT current_year_value FROM (
    SELECT MAX(acad_year) as current_year_value FROM acad_student
) as current_year;
```

### 5. Student Status Distribution

```sql
-- Check status distribution
SELECT new_status, COUNT(*) as count
FROM acad_student
GROUP BY new_status
ORDER BY count DESC;

-- Expected statuses for NCHE: ACTIVE, ADMITTED, GRADUATED, ALUMNI
```

### 6. Study Centre/Campus Distribution

```sql
-- Check study centre distribution
SELECT study_centre, COUNT(*) as count
FROM acad_student
WHERE study_centre IS NOT NULL AND study_centre != ''
GROUP BY study_centre
ORDER BY count DESC;
```

## Pre-Deployment Database Fixes

### Fix 1: Populate Missing National IDs

```sql
-- For records missing national ID, set placeholder (adjust as needed)
-- IMPORTANT: Verify this is appropriate before running
UPDATE acad_student 
SET national_id = CONCAT('N', YEAR(NOW()), LPAD(id, 8, '0'))
WHERE (national_id IS NULL OR national_id = '') 
AND id > 0;
```

### Fix 2: Populate Missing Year of Study

```sql
-- Default missing year_of_study to 1
UPDATE acad_student 
SET year_of_study = 1
WHERE year_of_study IS NULL OR year_of_study = 0;
```

### Fix 3: Populate Missing Status

```sql
-- Default missing status to ACTIVE (verify business rule first)
UPDATE acad_student 
SET new_status = 'ACTIVE'
WHERE new_status IS NULL OR new_status = '';
```

### Fix 4: Assign Study Centre to Missing Records

```sql
-- Default missing study centre to Main Campus
UPDATE acad_student 
SET study_centre = 'Main Campus'
WHERE study_centre IS NULL OR study_centre = '';
```

## Performance Optimization

### Create Recommended Indexes

```sql
-- Index on academic year (for filtering)
CREATE INDEX idx_acad_year ON acad_student(acad_year);

-- Index on student status (for filtering)
CREATE INDEX idx_new_status ON acad_student(new_status);

-- Index on programme ID (for JOIN and filtering)
CREATE INDEX idx_prog_id ON acad_student(prog_id);

-- Index on study centre (for filtering)
CREATE INDEX idx_study_centre ON acad_student(study_centre);

-- Composite index for common filter combinations
CREATE INDEX idx_status_acad_year ON acad_student(new_status, acad_year);

-- Check if indexes exist before creating
-- SHOW INDEX FROM acad_student;
```

### Verify Index Creation

```sql
-- List all indexes on acad_student table
SHOW INDEX FROM acad_student;

-- Check index size
SELECT object_schema, object_name, index_name, 
       ROUND(stat_value*@@innodb_page_size/1024/1024, 2) as size_mb
FROM mysql.innodb_index_stats
WHERE object_schema = 'campus_dynamics'
  AND object_name = 'acad_student'
  AND stat_name = 'size';
```

## Test Data Queries

### Create Test Records (Optional - for testing only)

```sql
-- Add test student record for validation
INSERT INTO acad_student 
(first_name, middle_name, last_name, gender, national_id, regno, prog_id, acad_year, new_status, year_of_study, study_centre)
VALUES 
('Test', 'Data', 'Student', 'M', 'NIN123456789', 'TEST001/2024', 1, '2024-2025', 'ACTIVE', 1, 'Main Campus');

-- After testing, delete:
-- DELETE FROM acad_student WHERE regno = 'TEST001/2024';
```

## Export Verification Queries

### Query 1: Simulate NCHE Export

```sql
-- Exact query used in NCHEStudentExporter (verify results)
SELECT 
    ROW_NUMBER() OVER (ORDER BY s.regno) as sn,
    CONCAT(COALESCE(s.first_name, ''), ' ', COALESCE(s.middle_name, ''), ' ', COALESCE(s.last_name, '')) as names,
    COALESCE(s.gender, '') as sex,
    COALESCE(s.national_id, '') as national_id,
    s.regno as reg_no,
    p.prog_code,
    p.prog_name,
    COALESCE(p.award_level, 'Degree') as award_level,
    COALESCE(s.year_of_study, '1') as year_study,
    COALESCE(s.study_centre, 'Main Campus') as study_centre
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
ORDER BY s.regno
LIMIT 10;
```

### Query 2: Verify Filter Logic

```sql
-- Test with Academic Year filter
SELECT COUNT(*) as count
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE s.acad_year = '2024-2025'
ORDER BY s.regno;

-- Test with Status filter
SELECT COUNT(*) as count
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE s.new_status = 'ACTIVE'
ORDER BY s.regno;

-- Test with multiple filters
SELECT COUNT(*) as count
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE s.acad_year = '2024-2025' 
  AND s.new_status = 'ACTIVE'
  AND s.year_of_study = 1
ORDER BY s.regno;
```

## Monitoring Queries

### Monitor Export Activity

```sql
-- After implementing logging, track exports:
-- This would require adding a nche_exports log table first

-- Recommended log table structure:
CREATE TABLE IF NOT EXISTS nche_export_log (
    export_id INT AUTO_INCREMENT PRIMARY KEY,
    export_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    exported_by VARCHAR(100),
    record_count INT,
    filter_criteria TEXT,
    export_format ENUM('CSV', 'EXCEL') DEFAULT 'CSV',
    status ENUM('SUCCESS', 'ERROR') DEFAULT 'SUCCESS',
    error_message TEXT,
    INDEX idx_export_date (export_date)
);

-- Log export activity:
INSERT INTO nche_export_log (exported_by, record_count, filter_criteria, export_format, status)
VALUES ('admin_user', 5432, 'acad_year=2024-2025,status=ACTIVE', 'CSV', 'SUCCESS');
```

## Troubleshooting Guide

### Issue: "No students found matching criteria"

**Possible Causes:**
1. Selected filters too restrictive
2. Academic year not in database
3. Programme not assigned to any students
4. Study centre not matching database values

**Verification Query:**
```sql
-- Check what values exist for each filter
SELECT DISTINCT acad_year FROM acad_student ORDER BY acad_year DESC;
SELECT DISTINCT new_status FROM acad_student;
SELECT DISTINCT prog_id FROM acad_student;
SELECT DISTINCT study_centre FROM acad_student;
```

### Issue: Missing Programme Information

**Possible Causes:**
1. Student programme_id doesn't exist in acad_programme table
2. Orphaned programme reference

**Verification Query:**
```sql
-- Find students with missing programme data
SELECT s.id, s.regno, s.first_name, s.prog_id, p.prog_name
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE p.prog_id IS NULL AND s.prog_id IS NOT NULL
LIMIT 10;
```

### Issue: Special Characters Showing Incorrectly

**Cause**: Database character encoding mismatch

**Verification:**
```sql
-- Check database character set
SELECT DEFAULT_CHARACTER_SET_NAME FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'campus_dynamics';

-- Should show: utf8mb4 or utf8
```

## Connection String Verification

Verify this connection string in web.config matches your database:

```xml
<connectionStrings>
    <add name="vacConnectionString" 
         connectionString="Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;" 
         providerName="MySql.Data.MySqlClient" />
</connectionStrings>
```

**Security Note**: Store sensitive credentials in web.config with proper encryption or in Azure Key Vault for production.

## Rollback Procedures

If export format needs changes:

1. **Backup current files**:
   - Save NCHEStudentExporter.aspx
   - Save NCHEStudentExporter.aspx.cs

2. **Edit query** in NCHEStudentExporter.aspx.cs GetStudentData() method (around line 220)

3. **Test changes** with test data first

4. **Redeploy** to production

---

**Ready for Deployment**: Yes ✓
**Last Database Check**: [To be completed]
**Performance Baseline**: [To be measured in testing]
