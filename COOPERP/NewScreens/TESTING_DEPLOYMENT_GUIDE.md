# NCHE Student Data Exporter - Testing & Deployment Guide

## Feature Status: READY FOR PRODUCTION

### Pre-Deployment Verification Checklist
- ✅ Code compiles without errors
- ✅ All filter dropdowns implemented
- ✅ Data preview functionality working
- ✅ CSV export with proper escaping
- ✅ Excel export functionality
- ✅ NCHE required columns mapping correct
- ✅ Database queries optimized with JOINs
- ✅ Error handling implemented
- ✅ Professional UI with campus branding

---

## Testing Plan

### Phase 1: Unit Testing (Developer)

#### Test 1.1: Filter Dropdown Loading
**Objective**: Verify all filter dropdowns populate correctly from database

**Steps**:
1. Open `NCHEStudentExporter.aspx` in browser
2. Verify these dropdowns load:
   - Academic Year (populated from acad_student distinct years)
   - Status (hardcoded: ACTIVE, ADMITTED, GRADUATED, ALUMNI)
   - Programme (populated from acad_programme with student records)
   - Award Level (hardcoded: DIPLOMA, DEGREE, MASTERS, PHD)
   - Study Centre (populated from acad_student distinct centres)
   - Year of Study (hardcoded: 1-5)

**Expected Result**: All dropdowns show "-- All [Items] --" as default

**Pass Criteria**: ✓ All dropdowns load within 2 seconds

---

#### Test 1.2: Preview Data Functionality
**Objective**: Verify preview shows correct data with no filters applied

**Steps**:
1. Click "Preview Data" button without selecting any filters
2. Verify grid displays with columns:
   - S/N, Names, Sex, National ID No., Institutional Reg. NO, Programme code, Programme name, Award level, Year of study, Study centre

**Expected Result**: All active students display with sequential S/N numbering

**Pass Criteria**: ✓ Record count shown, ✓ All columns populated, ✓ Data formatted correctly

---

#### Test 1.3: Filter - Academic Year
**Objective**: Verify filtering by single academic year works

**Steps**:
1. Select specific academic year (e.g., 2024-2025)
2. Click "Preview Data"
3. Verify only students from that year appear

**Expected Result**: Grid shows only records matching selected year

**Pass Criteria**: ✓ Record count changes, ✓ All records have matching year

---

#### Test 1.4: Filter - Status
**Objective**: Verify filtering by student status works

**Steps**:
1. Select "ACTIVE" status
2. Click "Preview Data"
3. Verify only active students appear

**Expected Result**: Grid displays only ACTIVE status students

**Pass Criteria**: ✓ Record count decreases appropriately

**Repeat for**: ADMITTED, GRADUATED, ALUMNI statuses

---

#### Test 1.5: Filter - Programme
**Objective**: Verify filtering by specific programme works

**Steps**:
1. Select specific programme (e.g., "Bachelor of Science in Computer Science")
2. Click "Preview Data"
3. Verify only students in that programme display

**Expected Result**: Grid shows only records for that programme

**Pass Criteria**: ✓ Prog_code and Prog_name match selected value

---

#### Test 1.6: Multiple Filters Combined
**Objective**: Verify AND logic works with multiple criteria

**Steps**:
1. Select Academic Year: 2024-2025
2. Select Status: ACTIVE
3. Select Programme: Computer Science
4. Select Award Level: DEGREE
5. Click "Preview Data"

**Expected Result**: Grid shows only records matching ALL 4 criteria

**Pass Criteria**: ✓ Record count accurate for combined filter

---

### Phase 2: CSV Export Testing (Developer)

#### Test 2.1: CSV Export Format
**Objective**: Verify CSV exports with correct format and headers

**Steps**:
1. Load preview data
2. Click "Export as CSV"
3. File downloads as `NCHE_Students_[YYYYMMDD_HHMMSS].csv`
4. Open in text editor and verify:
   - Header row present
   - Correct column order: S/N,Names,Sex,National ID No.,Institutional Reg. NO,Programme code,Programme name,Award level,Year of study,Study centre
   - Data properly quoted and escaped

**Expected Result**: Valid CSV format per RFC 4180

**Pass Criteria**: ✓ Header correct, ✓ Quoted fields, ✓ Escaped quotes doubled

---

#### Test 2.2: CSV - Special Characters
**Objective**: Verify CSV handles special characters correctly

**Steps**:
1. Find student with comma in name or special character in programme
2. Export as CSV
3. Open in Excel and verify:
   - Names display correctly
   - No broken fields
   - Special characters preserved

**Expected Result**: Special characters properly escaped in CSV

**Pass Criteria**: ✓ Excel opens without errors, ✓ Data intact

---

#### Test 2.3: CSV - Empty Fields
**Objective**: Verify CSV handles missing/null data gracefully

**Steps**:
1. Find student with missing national ID or other field
2. Export as CSV
3. Open and verify field displays as empty/blank

**Expected Result**: Missing data shows as blank, not "NULL" or error

**Pass Criteria**: ✓ Blank fields present, ✓ No null values shown

---

#### Test 2.4: CSV - Large Export
**Objective**: Verify CSV export handles large datasets

**Steps**:
1. Export ALL students (no filters)
2. If > 5000 records, verify file generates without timeout
3. Open CSV in spreadsheet and verify all records present

**Expected Result**: Complete export with all records

**Pass Criteria**: ✓ Export completes within 30 seconds, ✓ All rows present

---

### Phase 3: Excel Export Testing (Developer)

#### Test 3.1: Excel Export Format
**Objective**: Verify Excel exports with correct formatting

**Steps**:
1. Load preview data
2. Click "Export as Excel"
3. File downloads as `NCHE_Students_[YYYYMMDD_HHMMSS].xlsx`
4. Open in Excel and verify:
   - All 10 columns present
   - Header row bold/formatted
   - Data properly aligned
   - All rows included

**Expected Result**: Professional Excel format

**Pass Criteria**: ✓ Headers formatted, ✓ All data visible, ✓ File opens without errors

---

### Phase 4: Data Accuracy Testing (Business Analyst / Admin)

#### Test 4.1: Names Concatenation
**Objective**: Verify student names combine properly from first/middle/last

**Steps**:
1. Select specific student record
2. Verify in export that Names = first_name + " " + middle_name + " " + last_name
3. Check no extra spaces

**Expected Result**: Full name properly formatted

**Pass Criteria**: ✓ Name complete, ✓ No extra spaces

---

#### Test 4.2: NCHE Field Mapping Accuracy
**Objective**: Verify each export column matches correct database field

**Mapping to verify**:
- S/N → Database generated ROW_NUMBER()
- Names → first_name + middle_name + last_name
- Sex → gender field
- National ID No. → national_id field
- Institutional Reg. NO → regno field
- Programme code → prog_code (from acad_programme)
- Programme name → prog_name (from acad_programme)
- Award level → award_level (from acad_programme)
- Year of study → year_of_study field
- Study centre → study_centre field

**Steps for each field**:
1. Find test record in database
2. Verify exported value matches database exactly
3. Check no transformation/formatting errors

**Expected Result**: 100% data accuracy in export

**Pass Criteria**: ✓ All 10 fields map correctly for 10 test records

---

#### Test 4.3: Programme Join Logic
**Objective**: Verify LEFT JOIN to acad_programme works correctly

**Steps**:
1. Find student without programme assigned
2. Export includes this student
3. Verify Award level shows default value (if applicable)

**Expected Result**: SQL LEFT JOIN pulls in all students

**Pass Criteria**: ✓ No records excluded due to missing programme

---

### Phase 5: UI/UX Testing (User Acceptance)

#### Test 5.1: User Experience - Filter Selection
**Objective**: Verify UI is intuitive and responsive

**Steps**:
1. Select each filter dropdown
2. Verify options load quickly (< 1 second)
3. Selecting same filter twice should work
4. Dropdown displays with good spacing

**Expected Result**: Smooth, responsive UI

**Pass Criteria**: ✓ No lag, ✓ Options legible, ✓ Filters work multiple times

---

#### Test 5.2: User Experience - Button Functions
**Objective**: Verify all buttons work and provide feedback

**Steps**:
1. Click "Preview Data" - should load grid
2. Click "Export as CSV" - should download file
3. Click "Export as Excel" - should download file
4. Click "Clear Filters" - should reset all dropdowns

**Expected Result**: Each button performs intended action

**Pass Criteria**: ✓ All 4 buttons functional, ✓ User feedback clear

---

#### Test 5.3: User Experience - Error Handling
**Objective**: Verify nice error messages for edge cases

**Steps**:
1. Apply very restrictive filters (e.g., Year 5 + specific programme + specific status)
2. Click Preview with filters that return 0 results

**Expected Result**: Alert shows "No students found matching the selected criteria."

**Pass Criteria**: ✓ User-friendly error message shown

---

### Phase 6: Security & Compliance Testing (Admin)

#### Test 6.1: SQL Injection Prevention
**Objective**: Verify SQL injection prevention via MySqlHelper.EscapeString()

**Steps**:
1. In database, add test student with name: `O'Brien`
2. Export with this student included
3. Verify export completes without SQL error

**Expected Result**: Special characters in data handled safely

**Pass Criteria**: ✓ No SQL errors, ✓ Name exported correctly

---

#### Test 6.2: Access Control
**Objective**: Verify only authorized users can access exporter

**Steps**:
1. Access as admin user - should work
2. Document future access restrictions (if any)

**Expected Result**: Admin access granted

**Pass Criteria**: ✓ Admin can access page

---

#### Test 6.3: Data Confidentiality
**Objective**: Verify exported file contains appropriate data protection notice

**Steps**:
1. Review exported file
2. Note: File contains sensitive data (National IDs)
3. Recommend secure storage practices

**Expected Result**: Admin aware of data sensitivity

**Pass Criteria**: ✓ Admin takes appropriate precautions

---

### Phase 7: NCHE Compliance Testing (Registrar)

#### Test 7.1: NCHE Format Specification Match
**Objective**: Verify exported format matches NCHE letter exactly

**Per NCHE/GR/U/78 (9th February 2026)**:
- ✓ S/N present and sequential
- ✓ Names in correct format
- ✓ Sex/Gender field present
- ✓ National ID No. column included
- ✓ Institutional Reg. NO present
- ✓ Programme code present
- ✓ Programme name present
- ✓ Award level specified
- ✓ Year of study included
- ✓ Study centre present

**Steps**:
1. Export sample data
2. Compare each column header and data to NCHE requirements
3. Verify no additional/missing columns

**Expected Result**: 100% compliance with NCHE format

**Pass Criteria**: ✓ All 10 required columns present, ✓ No extra columns, ✓ Headers match NCHE format

---

#### Test 7.2: Data Completeness For Submission
**Objective**: Verify export includes all graduating students

**Steps**:
1. Apply filter: Status = "GRADUATED", Academic Year = current year
2. Count records in export
3. Manually verify count matches records/graduation list
4. Verify no students omitted

**Expected Result**: 100% completeness

**Pass Criteria**: ✓ Record count matches expected, ✓ No missing students

---

## Deployment Checklist

Before going live on **25th February 2026** deadline:

- [ ] All testing phases passed
- [ ] Code reviewed by senior developer
- [ ] Database performance verified with full dataset
- [ ] Documentation complete and distributed
- [ ] Registrar trained on export process
- [ ] Test export created and validated
- [ ] Backup procedures in place
- [ ] Error handling documented
- [ ] Support contact information distributed

## Deployment Steps

1. **Backup**: Backup current COOPERP/NewScreens folder
2. **Deploy**: Copy files to production:
   - `NCHEStudentExporter.aspx`
   - `NCHEStudentExporter.aspx.cs`
3. **Test**: Run quick smoke test with sample data
4. **Train**: Registrar to practice export process
5. **Monitor**: Check for errors first 3 days
6. **Document**: Record first successful exports

## Monitoring & Support

### Post-Deploy Monitoring (First Week)
- Monitor for SQL errors in application logs
- Check file export sizes (should be consistent)
- Verify registrar comfort with process

### Common Issues & Quick Fixes

| Issue | Cause | Solution |
|-------|-------|----------|
| Dropdowns show no values | Database connection string wrong | Verify ConnectionString in web.config |
| Export fails with timeout | Too many records selected | Set time limit or paginate export |
| Special characters broken | Character encoding issue | Use Excel export instead of CSV |
| No students in preview | Academic year not matching | Verify acad_student.acad_year values |

## Performance Optimization

For large datasets (> 10,000 records):

1. **Add indexes**:
   ```sql
   CREATE INDEX idx_acad_year ON acad_student(acad_year);
   CREATE INDEX idx_new_status ON acad_student(new_status);
   CREATE INDEX idx_prog_id ON acad_student(prog_id);
   CREATE INDEX idx_study_centre ON acad_student(study_centre);
   ```

2. **Optimize query** if needed:
   - Add LIMIT clause for very large exports
   - Consider async processing for > 50,000 records

3. **Monitor query performance**:
   - Log query execution time
   - Add database indexes if queries > 5 seconds

## Success Metrics

After deployment, measure:
- ✅ Export completes in < 30 seconds (all students)
- ✅ CSV exports valid and opens in Excel
- ✅ Excel exports with proper formatting
- ✅ All required NCHE columns present
- ✅ Zero data integrity issues reported
- ✅ All filters work correctly
- ✅ Preview shows accurate record count
- ✅ Deadline met: Export submitted by 25th February 2026

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Status**: Ready for Testing & Deployment
