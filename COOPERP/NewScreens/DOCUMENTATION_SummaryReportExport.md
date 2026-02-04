# Student Results Summary Report - Export Feature Documentation

## Overview
The **Export Summary Report** feature generates a professional PDF document containing student results organized by specialization. It includes curriculum validation, pass/fail status determination, and comprehensive legends for easy interpretation.

---

## Feature Location
- **File**: `NewStudentInfo.aspx` / `NewStudentInfo.aspx.cs`
- **Access**: Click "Batch Actions" button → Select "Export Summary Report"
- **Modal ID**: `#summaryReportModal`

---

## Required Filter Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| **Programme** | Searchable Dropdown | ✅ Yes | Select the academic programme |
| **Entry Year** | Searchable Dropdown | ✅ Yes | Year students entered (2000-current) |
| **Year of Study** | Dropdown | ✅ Yes | Study year (1-5) |
| **Semester** | Dropdown | ✅ Yes | Semester (1-3) |
| **Entry Numbers** | Textarea | ❌ No | Optional: Comma-separated specific entry numbers |

---

## PDF Report Structure

### 1. Header Section
```
┌──────────────────────────────────────────────────────────────────────────────┐
│  [LOGO]                    UNIVERSITY NAME                                   │
│                   STUDENT RESULTS SUMMARY REPORT                             │
├──────────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │ Programme:     [Programme Name]        │ Entry Year:    [Year]         │  │
│  │ Year of Study: Year [X]                │ Semester:      Semester [X]   │  │
│  │                                        │ Generated:     [Date/Time]    │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 2. Specialization Sections

Each specialization group includes:

#### A. Specialization Header Bar
```
┌──────────────────────────────────────────────────────────────────────────────┐
│ SPECIALIZATION NAME (X students) │ Curriculum: Y courses │ [STATUS BADGE]   │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Curriculum Status Badges:**
| Badge | Color | Meaning |
|-------|-------|---------|
| `FULLY SET` | 🟢 Green | Curriculum is complete (`is_fully_set = 'Yes'`) |
| `NOT SET` | 🟡 Orange | Curriculum exists but incomplete |
| `NO CURRICULUM` | 🔴 Red | No curriculum defined for this specialization |

#### B. Results Table
| # | Student Name | Reg No | Course1 | Course2 | ... | STATUS |
|---|--------------|--------|---------|---------|-----|--------|
| 1 | John Doe | 24/U/001 | A (85) | B+ (72) | ... | PASSED (5/5) |
| 2 | Jane Smith | 24/U/002 | C (60) | F (45) | ... | FAILED (4/5) |
| 3 | Bob Wilson | 24/U/003 | B (70) | A (90) | ... | PENDING (5/5) |

**Grade Display Format**: `Grade (Score)` e.g., `A (85)`, `F (45)`

**Status Column Values:**
| Status | Color | Condition |
|--------|-------|-----------|
| `PASSED (X/Y)` | 🟢 Green bg | Curriculum FULLY SET AND Passed results ≥ Curriculum courses |
| `FAILED (X/Y)` | 🔴 Red bg | Curriculum FULLY SET AND Passed results < Curriculum courses |
| `PENDING (X/Y)` | 🟡 Yellow bg | Curriculum exists but NOT FULLY SET (cannot determine pass/fail) |
| `N/A (X)` | 🟡 Yellow bg | No curriculum defined |

**⚠️ IMPORTANT**: A student can only be marked as **PASSED** when:
1. Curriculum is **FULLY SET** (`is_fully_set = 'Yes'` in `acad_specialisation`)
2. Student's passed courses ≥ Curriculum course count

Where:
- `X` = Number of courses passed (grade ≠ 'F')
- `Y` = Curriculum course count for that specialization/year/semester

### 3. Summary Statistics Section
```
┌──────────────────────────────────────────────────────────────────────────────┐
│ REPORT SUMMARY                                                               │
│                                                                              │
│ Total Students: XX    │ Specializations: X    │ Report Period: Year X, Sem X│
│                                                                              │
│ Status Legend:                                                               │
│ [PASSED] = Results ≥ Curriculum  [FAILED] = Results < Curriculum  [N/A] = No│
│                                                                              │
│ Curriculum:                                                                  │
│ [FULLY SET] = Complete  [NOT SET] = Incomplete  [NO CURRICULUM] = Not Defined│
└──────────────────────────────────────────────────────────────────────────────┘
```

### 4. Footer
```
UNIVERSITY NAME  |  Student Results Summary Report  |  Generated: DD MMM YYYY, HH:MM
```

---

## Database Tables Used

### Primary Tables
| Table | Purpose |
|-------|---------|
| `acad_student` | Student information (regno, entryno, progid, specialisation, entryyear) |
| `acad_results` | Student results (regno, courseid, grade, score, studyyear, semester) |
| `acad_programme` | Programme details (progcode, progname) |
| `acad_course` | Course details (courseID, courseName) |
| `acad_specialisation` | Specialization info (spec_id, spec, prog_id, is_fully_set, is_default) |
| `acad_programmecourses` | Curriculum definition (progcode, course_code, specialisation_id, study_year, semester) |
| `acad_university` | University name |

### Key Relationships
```
acad_student.regno → acad_results.regno
acad_student.progid → acad_programme.progcode
acad_student.specialisation → acad_specialisation.spec_id
acad_results.courseid → acad_course.courseID
acad_programmecourses.specialisation_id → acad_specialisation.spec_id
```

---

## Curriculum Validation Logic

### Step 1: Determine Specialization
```csharp
// If student has no specialisation, use programme's default
if (string.IsNullOrEmpty(specId))
{
    SELECT spec_id FROM acad_specialisation 
    WHERE prog_id = @progId AND is_default = 'Yes' LIMIT 1
}
```

### Step 2: Check Curriculum Status
```csharp
SELECT is_fully_set FROM acad_specialisation WHERE spec_id = @specId
// Returns 'Yes' or 'No'
```

### Step 3: Get Curriculum Course Count
```csharp
SELECT COUNT(*) FROM acad_programmecourses 
WHERE specialisation_id = @specId 
AND study_year = @studyYear 
AND semester = @semester
```

### Step 4: Count Student's Passed Courses
```csharp
// Count results where grade ≠ 'F'
foreach (course in displayedCourses)
{
    if (grade != null && grade != "F")
        studentPassedCount++;
}
```

### Step 5: Determine Pass/Fail
```csharp
// IMPORTANT: Student can only be marked as PASSED if:
// 1. Curriculum is fully set (IsFullySet = true)
// 2. Curriculum has courses defined (CurriculumCourseCount > 0)
// 3. Student's passed count >= curriculum course count

if (curriculumCourseCount > 0 && isFullySet)
{
    // Curriculum is complete - can determine pass/fail
    studentPassed = (studentPassedCount >= curriculumCourseCount);
    status = studentPassed ? "PASSED" : "FAILED";
}
else if (curriculumCourseCount > 0 && !isFullySet)
{
    // Curriculum exists but NOT fully set - cannot determine pass status
    status = "PENDING"; // Awaiting curriculum completion
}
else
{
    status = "N/A"; // No curriculum defined
}
```

**⚠️ CRITICAL RULE**: A student can NEVER be marked as "PASSED" unless the curriculum is fully set (`is_fully_set = 'Yes'`). If curriculum exists but is not fully set, the status will be "PENDING".

---

## Key C# Methods

### `GenerateSummaryReportPdf(DataTable data, string studyYear, string semester, string entryYear)`
Main method that generates the PDF document.

### `GetCurriculumInfo(string specId, string progId, string studyYear, string semester)`
Returns curriculum validation information:
```csharp
class CurriculumInfo
{
    string SpecId;              // Specialization ID
    int CurriculumCourseCount;  // Number of courses in curriculum
    bool IsFullySet;            // Whether curriculum is complete
    bool IsDefault;             // Whether using programme's default spec
    string SpecName;            // Specialization name
}
```

### `GetSummaryReportData(string programme, string entryYear, string studyYear, string semester, string entryNumbers)`
Retrieves student and results data from database.

### `GetSummaryReportStudentCount(string programme, string entryYear, string studyYear, string semester, string entryNumbers)`
Returns count of students for preview before export.

---

## JavaScript Functions (Frontend)

| Function | Purpose |
|----------|---------|
| `openSummaryReportModal()` | Opens the export modal |
| `closeSummaryReportModal()` | Closes the modal |
| `resetSummaryReportForm()` | Resets all form fields |
| `previewSummaryReport()` | AJAX call to get student count preview |
| `exportSummaryReport()` | Triggers PDF generation and download |
| `filterProgrammeDropdown(text)` | Filters programme searchable dropdown |
| `filterEntryYearDropdown(text)` | Filters entry year searchable dropdown |
| `selectProgramme(value, text)` | Handles programme selection |
| `selectEntryYear(value, text)` | Handles entry year selection |

---

## Color Scheme Reference

### Brand Colors
| Element | RGB | Hex | Usage |
|---------|-----|-----|-------|
| Brand Blue | 23, 77, 164 | #174DA4 | University name, values, headers |
| Dark Gray | 51, 51, 51 | #333333 | Labels, text |
| Light Gray | 102, 102, 102 | #666666 | Secondary text |

### Status Colors
| Status | Background RGB | Text RGB | Usage |
|--------|---------------|----------|-------|
| Success/Passed | 212, 237, 218 | 21, 87, 36 | Passed students |
| Danger/Failed | 248, 215, 218 | 114, 28, 36 | Failed students |
| Warning/N/A | 255, 243, 205 | 133, 100, 4 | No curriculum |

### Curriculum Badge Colors
| Badge | Background RGB | Usage |
|-------|---------------|-------|
| FULLY SET | 39, 174, 96 (Green) | Complete curriculum |
| NOT SET | 243, 156, 18 (Orange) | Incomplete curriculum |
| NO CURRICULUM | 192, 57, 43 (Red) | No curriculum defined |

---

## File Output

- **Format**: PDF (A4 Landscape)
- **Filename**: `SummaryReport_YYYYMMDD_HHMMSS.pdf`
- **Margins**: 10px all sides
- **Generation**: DevExpress XtraPrinting

---

## Troubleshooting

### Issue: "No data found for the selected filters"
**Cause**: No results match the selected Programme + Entry Year + Study Year + Semester combination.
**Solution**: Verify students have results for the selected period in `acad_results` table.

### Issue: All students show "N/A" status
**Cause**: No curriculum defined in `acad_programmecourses` for the specialization/year/semester.
**Solution**: Add curriculum courses via Programme Courses management screen.

### Issue: Badge shows "NO CURRICULUM"
**Cause**: Either:
1. Student has no specialization and programme has no default
2. No courses assigned to the specialization for selected year/semester
**Solution**: Set a default specialization or add curriculum courses.

### Issue: Wrong pass/fail calculation
**Check**: 
1. Curriculum course count in `acad_programmecourses`
2. Student's actual results in `acad_results`
3. Ensure `grade` field is not NULL and not 'F' for passed courses

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-03 | 1.0 | Initial implementation with basic export |
| 2026-02-03 | 1.1 | Added Year of Study and Semester filters |
| 2026-02-03 | 1.2 | Added curriculum validation headers |
| 2026-02-03 | 1.3 | Added Status column with pass/fail logic |
| 2026-02-03 | 1.4 | Added comprehensive summary and legend section |
| 2026-02-03 | 1.5 | Made Entry Year searchable, Semester up to 3 |

---

## Author
Campus Dynamics Development Team

## Related Files
- `NewStudentInfo.aspx` - Frontend markup and JavaScript
- `NewStudentInfo.aspx.cs` - Backend code-behind
- `acad_programmecourses` - Curriculum table
- `acad_specialisation` - Specialization with `is_fully_set` field
