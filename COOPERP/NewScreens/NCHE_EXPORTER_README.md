# NCHE Student Data Exporter - Implementation Guide

## Overview
The NCHE Student Data Exporter is a comprehensive solution for exporting student information in the format required by the National Council for Higher Education (NCHE) as per their directive NCHE/GR/U/78 dated 9th February 2026.

**Deadline:** 25th February 2026

## Features

### 1. Flexible Filtering Criteria
The exporter provides multiple filtering options to extract specific student records:
- **Academic Year**: Filter by specific academic years
- **Status**: Filter by student status (ACTIVE, ADMITTED, GRADUATED, ALUMNI)
- **Programme**: Filter by specific degree programme
- **Award Level**: Filter by degree level (DIPLOMA, DEGREE, MASTERS, PHD)
- **Study Centre/Campus**: Filter by physical campus location
- **Year of Study**: Filter by current year in programme (1-5)

### 2. Data Preview
- View all records that will be exported before committing to export
- Real-time record count display
- Grid-based preview with proper column organization
- Pagination support for large datasets

### 3. Export Formats
- **CSV Export**: Comma-separated values format (opens in Excel/Sheets)
- **Excel Export**: Native .xlsx format with proper formatting

### 4. NCHE Compliant Output
The exporter produces data in the exact format specified by NCHE:

| Column | Description | Source |
|--------|-------------|--------|
| S/N | Sequential Number | Auto-generated |
| Names | Student Full Name | acad_student (first_name + middle_name + last_name) |
| Sex | Gender | acad_student.gender |
| National ID No. | National Identity Number | acad_student.national_id |
| Institutional Reg. NO | Registration Number | acad_student.regno |
| Programme code | Programme Code | acad_programme.prog_code |
| Programme name | Full Programme Name | acad_programme.prog_name |
| Award level | Degree Level | acad_programme.award_level |
| Year of study | Current Year in Programme | acad_student.year_of_study |
| Study centre | Campus Location | acad_student.study_centre |

## File Locations

### Main Files
- **Frontend**: `/COOPERP/NewScreens/NCHEStudentExporter.aspx`
- **Code-Behind**: `/COOPERP/NewScreens/NCHEStudentExporter.aspx.cs`
- **Integration Point**: `/COOPERP/NewScreens/NewStudentInfo.aspx` (menu item added)

### Access Points
1. Student Management → New Student Info page
2. Batch Operations menu → "Export NCHE Student Data"
3. Direct URL: `~/COOPERP/NewScreens/NCHEStudentExporter.aspx`

## Database Schema

### Tables Used
1. **acad_student**
   - Fields: regno, first_name, middle_name, last_name, gender, national_id, prog_id, acad_year, new_status, year_of_study, study_centre

2. **acad_programme**
   - Fields: prog_id, prog_code, prog_name, award_level

### Query Logic
The exporter uses a LEFT JOIN to connect students with their programmes, ensuring records are returned even if programme data is incomplete.

```sql
SELECT 
    ROW_NUMBER() OVER (ORDER BY s.regno) as sn,
    CONCAT(first_name, ' ', middle_name, ' ', last_name) as names,
    gender as sex,
    national_id,
    regno as reg_no,
    prog_code,
    prog_name,
    COALESCE(award_level, 'Degree') as award_level,
    COALESCE(year_of_study, '1') as year_study,
    COALESCE(study_centre, 'Main Campus') as study_centre
FROM acad_student s
LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
WHERE [filter conditions]
ORDER BY s.regno
```

## Usage Instructions

### Step 1: Access the Exporter
1. Navigate to Students section → New Student Info page
2. Click "Batch Operations" button
3. Select "Export NCHE Student Data"

### Step 2: Set Filtering Criteria
- Choose desired filters from the dropdown lists
- Leave filters blank for "All" option
- Multiple filters work with AND logic

### Step 3: Preview Data
- Click "Preview Data" button
- Review records to be exported
- Verify accuracy of student information
- Total count displayed for validation

### Step 4: Export
- Choose export format:
  - **CSV**: Click "Export as CSV" for spreadsheet-compatible format
  - **Excel**: Click "Export as Excel" for native .xlsx format
- File automatically downloads to your computer

### Step 5: Submit to NCHE
- Open exported file
- Verify all required columns are present
- Check data completeness
- Submit to NCHE via their designated portal

## Technical Details

### CSV Export
- Format: UTF-8 encoded
- Delimiter: Comma (,)
- Text qualifiers: Quotes (")
- Filename: `NCHE_Students_YYYYMMDD_HHMMSS.csv`

### Excel Export
- Format: .xlsx (Office Open XML)
- Contains single sheet with all records
- Headers properly formatted
- Filename: `NCHE_Students_YYYYMMDD_HHMMSS.xlsx`

### Data Validation
- Empty national ID numbers are exported as blanks
- Missing programme information defaults to standard values
- International characters properly encoded
- Special characters escaped in CSV format

## Error Handling

### Common Issues & Solutions

#### Issue: "No students found matching criteria"
- **Cause**: Filter combination too restrictive
- **Solution**: Clear some filters and try again

#### Issue: Missing columns in export
- **Cause**: Database field not populated
- **Solution**: Verify data entry in student records

#### Issue: Special characters display incorrectly
- **Cause**: Character encoding issue with CSV
- **Solution**: Use Excel export format (.xlsx)

## Security & Compliance

### Access Control
- Restricted to authenticated admin users
- Filter by user permissions in future versions

### Data Privacy
- Includes National IDs (use securely)
- Store exported files securely
- Follow data protection regulations

### Audit Trail
- Exported file timestamps for tracking
- Consider logging exports for compliance

## Maintenance & Updates

### Regular Tasks
1. **Monthly**: Verify student data completeness
2. **Before deadline**: Run test exports to verify format
3. **Post-export**: Archive submission proof

### Data Quality
- Ensure all students have:
  - Valid registration numbers
  - Complete names
  - Assigned programmes
  - Current study year

## Future Enhancements

Potential improvements:
1. Email export directly to NCHE portal
2. Schedule automatic exports
3. Historical export tracking
4. Data validation rules before export
5. Batch updates based on NCHE feedback
6. Integration with NCHE portal API

## Support & Contact

For issues or questions about the NCHE exporter:
1. Check this documentation
2. Verify database data quality
3. Contact system administrator
4. Review NCHE requirements: NCHE/GR/U/78

## NCHE Reference Information

**Organization**: National Council for Higher Education
**Reference**: NCHE/GR/U/78
**Date**: 9th February 2026
**Deadline**: 25th February 2026
**Purpose**: Piloting of national NCHE Student Admission Number
**Contact**: NCHE, Plot M834, Kyadondo Road, Kyambogo, Kampala

**Important Note**: Ensure compliance with this directive. Non-compliance may affect the institution's standing with NCHE.

---
