# Campus Dynamics - Quick Reference Card

## NCHE Student Data Exporter + Masters Letter of Award

**Print this page and keep it with your system documentation**

---

## 🎯 FEATURE OVERVIEW

### Masters Letter of Award
- **What**: Generates professional A4 award letters for Master's degree graduates
- **Where**: Settings → Registry & Results → Masters Letter of Award
- **Output**: PDF letter with barcode, QR code, and institutional seal
- **Status**: ✅ Ready

### NCHE Student Data Exporter  
- **What**: Exports student data in format required by National Council for Higher Education
- **Where**: Students → New Student Info → Batch Operations → Export NCHE Student Data
- **Output**: CSV or Excel file with 10 NCHE-required columns
- **Deadline**: 25 February 2026
- **Status**: ✅ Ready

---

## 📋 NCHE DATA EXPORT FORMAT

**10 Required Columns (in exact order)**:
1. S/N (Sequence number, auto-generated)
2. Names (Student full name)
3. Sex (Gender: M/F)
4. National ID No. (Government ID)
5. Institutional Reg. NO (Student registration)
6. Programme code (Course code)
7. Programme name (Full course name)
8. Award level (DIPLOMA/DEGREE/MASTERS/PHD)
9. Year of study (1-5)
10. Study centre (Campus location)

---

## 🔧 QUICK START - NCHE EXPORT

### Step 1: Navigate
Students → New Student Info → Batch Operations → "Export NCHE Student Data"

### Step 2: Set Filters (Optional)
- Academic Year: [Choose or leave blank for all]
- Status: ACTIVE, ADMITTED, GRADUATED, or ALUMNI
- Programme: [Choose or leave blank]
- Award Level: DIPLOMA, DEGREE, MASTERS, PHD
- Study Centre: [Choose or leave blank]
- Year of Study: 1-5 [Choose or leave blank]

### Step 3: Preview
- Click "Preview Data"
- Verify record count shows expected number
- Review sample records in grid below

### Step 4: Export
- Click "Export as CSV" (for Excel/Sheets)
- OR Click "Export as Excel" (for .xlsx format)
- File downloads automatically

### Step 5: Verify
- Open file in Excel or text editor
- Confirm all 10 columns present
- Check data accuracy with spot checks

---

## 🔧 QUICK START - MASTERS LETTER

### Step 1: Navigate
Settings → Registry & Results → Transcripts

### Step 2: Select Criteria
- Academic Year: [Select from dropdown]
- Programme: [Select from dropdown]
- Student: [Click to select from list]

### Step 3: Verify Information
- Graduation Date: [System will show if set]
- Senate Approval Date: [System will show if set]
- Honours: [Optional - for "With Distinction"]

### Step 4: Generate
- Click "Generate Master Letter"
- System opens print preview
- Review letter for accuracy

### Step 5: Print/Save
- Print to physical paper (A4 size recommended)
- OR save as PDF to file

---

## 💾 FILE LOCATIONS

**If you need to access implementation files**:

```
COOPERP/
├── App_Code/XtraReports/
│   └── MastersLetterOfAward.cs
├── NewScreens/
│   ├── NCHEStudentExporter.aspx
│   ├── NCHEStudentExporter.aspx.cs
│   └── NewStudentInfo.aspx
└── UserControls/Registry/
    └── TranscriptDocumentCentre.ascx.cs
```

---

## 🆘 TROUBLESHOOTING

### Problem: "No students found matching criteria"
**Solution**: 
- Remove filters and try again
- Check that academic year exists in database
- Verify student status values match (ACTIVE, ADMITTED, etc.)

### Problem: Export downloads but file is empty
**Solution**:
- Apply at least one filter
- Click "Preview Data" first to verify records exist
- If still empty, contact IT

### Problem: Special characters show incorrectly in CSV
**Solution**:
- Use "Export as Excel" (.xlsx) instead of CSV
- Excel handles special characters better

### Problem: Masters Letter shows "Error! Make Sure you have selected all required fields"
**Solution**:
- Verify graduation date is set (use "Set Graduation Info" button)
- Verify senate date is set
- Select student from list (not just from dropdown)

### Problem: Export takes very long time (> 1 minute)
**Solution**:
- This is normal for 5,000+ records
- Wait for download to complete
- For production: IT can add database indexes (see DATABASE_VERIFICATION.md)

---

## 📊 DATABASE FIELDS EXPORTED

| Export Column | Database Field | Table | Notes |
|---------------|----------------|-------|-------|
| S/N | ROW_NUMBER() | [Auto] | Sequential, auto-generated |
| Names | first_name + middle_name + last_name | acad_student | Concatenated |
| Sex | gender | acad_student | M/F |
| National ID No. | national_id | acad_student | Government ID |
| Institutional Reg. NO | regno | acad_student | Student registration # |
| Programme code | prog_code | acad_programme | Course code |
| Programme name | prog_name | acad_programme | Full course name |
| Award level | award_level | acad_programme | Degree level |
| Year of study | year_of_study | acad_student | Current year (1-5) |
| Study centre | study_centre | acad_student | Campus location |

---

## ⚠️ IMPORTANT NOTES

### Data Completeness
- **National ID**: Must be present for NCHE submission
- **Registration Number**: Must be unique per student
- **Programme Assignment**: All students should have a programme
- **Study Centre**: All students should have a campus assigned

**Before 25 Feb deadline**: Run [DATABASE_VERIFICATION.md](DATABASE_VERIFICATION.md) SQL queries to fix missing data.

### Filing & Compliance
- Keep export file in secure location
- National IDs are sensitive data - handle carefully
- Archive export file after NCHE submission
- Document submission date and confirmation

### Performance
- Export of 1,000 students: ~5-10 seconds
- Export of 10,000 students: ~30-60 seconds  
- Larger exports: May require optimization

---

## 📱 KEY CONTACTS

| Role | Action |
|------|--------|
| **Registrar** | Approves NCHE export, verifies data |
| **IT Ministry** | Deploys code, manages servers |
| **System Admin** | Manages database, user access |
| **End User** | Runs exports, generates letters |

**NCHE Contact**: NCHE/GR/U/78 - Plot M834, Kyadondo Road, Kampala

---

## 📝 CHECKLIST - BEFORE NCHE SUBMISSION

**Do this before 25 February 2026:**

- [ ] Export all students to CSV/Excel
- [ ] Open file and verify all columns present
- [ ] Count records vs. institutional records (verify match)
- [ ] Spot check 10 random student records
- [ ] Verify no blank National ID numbers
- [ ] Check file opens in Excel without errors
- [ ] Save file with naming: `NCHE_Submission_2025-26_[DATE].xlsx`
- [ ] Archive file securely
- [ ] Submit to NCHE portal by deadline
- [ ] Record submission confirmation

---

## 🔐 SECURITY REMINDERS

1. **National IDs**: Don't share email without encryption
2. **File Storage**: Keep on encrypted drive, not public folders
3. **Access Control**: Only authorized staff should export
4. **Audit Trail**: Document who exported when
5. **Backup**: Always backup data before export

---

## ✅ DEPLOYMENT VERIFICATION

**Before going live, verify**:

- [x] Code compiles (no errors reported)
- [x] Menu item appears in batch operations
- [x] Sample export runs successfully
- [x] Output format matches NCHE specification
- [ ] Database indexes created (performance optimization)
- [ ] Staff trained on export process
- [ ] Error logging configured

---

## 📞 SUPPORT MATRIX

| Issue | Contact | Solution |
|-------|---------|----------|
| Can't access export menu | System Admin | Check user permissions |
| Export fails with timeout | IT Ministry | Optimize database/indexes |
| Data looks wrong | Registrar | Verify database data quality |
| Format doesn't match NCHE | Product Team | Review TESTING_DEPLOYMENT_GUIDE.md |
| Special characters broken | IT Ministry | Use Excel export format |
| Need training | Project Manager | Schedule demo session |

---

## 📚 FULL DOCUMENTATION

For detailed information, see:

1. **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project overview
2. **[NCHE_EXPORTER_README.md](NCHE_EXPORTER_README.md)** - User guide with examples
3. **[TESTING_DEPLOYMENT_GUIDE.md](TESTING_DEPLOYMENT_GUIDE.md)** - QA testing procedures (42 tests)
4. **[DATABASE_VERIFICATION.md](DATABASE_VERIFICATION.md)** - SQL scripts to verify/fix data
5. **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Deployment tracking

---

## 🎓 HOW TO GET HELP

### Quick Questions
1. Check this Quick Reference Card first
2. Review the relevant documentation above
3. Check troubleshooting section

### Technical Issues  
1. Contact IT Ministry
2. Provide error message (from screen or logs)
3. Reference this Quick Reference Card

### Data Issues
1. Contact Registrar's Office
2. Run [DATABASE_VERIFICATION.md](DATABASE_VERIFICATION.md) queries
3. Fix missing data before export

### NCHE Compliance Questions
1. Review NCHE/GR/U/78 requirements
2. Check [NCHE_EXPORTER_README.md](NCHE_EXPORTER_README.md)
3. Contact external NCHE team for guidance

---

## 🏁 SUCCESS INDICATORS

### ✓ System is working correctly when:
- Export completes in < 30 seconds (all students)
- CSV/Excel files open without errors in Excel
- All 10 required columns present in export
- Student count matches institutional records
- Special characters display correctly
- Filters work as expected (adding filter = fewer records)

### ✓ Master Letter is working correctly when:
- Report generates without error messages
- All student information present on letter
- Barcode/QR code visible and scannable  
- Layout fits on single A4 page
- Dates formatted correctly

---

## 📅 KEY DATES

| Date | Task |
|------|------|
| 25 Feb 2026 | **DEADLINE: Submit to NCHE** |
| 20 Feb 2026 | Final export run & verification |
| 10 Feb 2026 | Complete UAT testing |
| 01 Feb 2026 | Deployment to production |

---

## 🎯 SUCCESS CRITERIA

**Project successful when**:
- ✅ Export file contains all 10 NCHE columns
- ✅ All enrolled students included in export
- ✅ No missing National ID numbers
- ✅ Report submitted to NCHE by deadline
- ✅ Masters Letters generate professionally
- ✅ System runs without errors for 1+ week

---

**Print Date**: _____________  
**Review Date**: _____________  
**Last Updated**: 2026-02  
**Next Update**: Post-deployment

---

*Keep this card with your system documentation and operational manuals*
