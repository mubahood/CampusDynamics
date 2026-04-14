# Academics Module — Deep Analysis & Improvement Plan

> **System:** Campus Dynamics EMIS — Mountains of the Moon University  
> **Date:** 2026-04-10  
> **Scope:** Teacher–Programme–Course–Load Allocation–Timetable relationships across Classic and New System interfaces  
> **Platform:** ASP.NET 4.0 Web Forms / MySQL / DevExpress v16.1

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Complete Entity Relationship Model](#2-complete-entity-relationship-model)
3. [Database Schema Reference](#3-database-schema-reference)
4. [Classic System — Page-by-Page Analysis](#4-classic-system--page-by-page-analysis)
5. [New System Interface — Page-by-Page Analysis](#5-new-system-interface--page-by-page-analysis)
6. [Teaching Center (Portal) Analysis](#6-teaching-center-portal-analysis)
7. [API Layer Analysis](#7-api-layer-analysis)
8. [Data Flow — End to End](#8-data-flow--end-to-end)
9. [Data Quality Audit (Live Database)](#9-data-quality-audit-live-database)
10. [Critical Issues & Risks](#10-critical-issues--risks)
11. [Improvement Plan for New System Interface](#11-improvement-plan-for-new-system-interface)
12. [Migration & Transition Strategy](#12-migration--transition-strategy)
13. [Implementation Roadmap](#13-implementation-roadmap)
14. [Best Practices & Recommendations](#14-best-practices--recommendations)

---

## 1. Executive Summary

The academics module is the **core engine** of Campus Dynamics. It connects:

```
Faculty → Programme → Course → Teaching Allocation → Timetable → Results
                                       ↕
                              HR Employee (Lecturer)
                                       ↕
                              Student → Course Registration → Results
```

**Current State:**
- **131 programmes** across 6 faculties
- **6,905 courses** linked via **6,778 programme-course records**
- **20,747 teaching allocations** (historical, spanning 2019–2026)
- **309 HR employees** (lecturers, admin, support staff)
- **31,112 students** with **27,987 registrations** and **626,490 result records**

**Key Findings:**
1. Only **8% of teaching allocations** have actual timetable schedules (day/time/room set)
2. **92% of allocations** have `lectureday = '-'` — they record WHO teaches WHAT but not WHEN or WHERE
3. The API timetable endpoint references a **non-existent `acad_timetable` table** — students see no timetable data
4. `staffCode` stores **`empID` (integer)** not `EMP_CODE` (alphanumeric) — the column name is misleading
5. Significant **duplicate allocations exist** (same lecturer + course + programme + year + semester appearing 2–4 times)
6. Two New System pages (`NewProgrammeCourses.aspx` and `NewFacultyProgrammes.aspx`) write to the **same table with different schemas** (one includes specialisation/course_type, the other doesn't)
7. The **curriculum system is being abandoned** — new pages hardcode `CurriculumID = 0`

---

## 2. Complete Entity Relationship Model

```
┌────────────────────────┐
│     acad_faculty        │
│ PK: faculty_code        │ ◄─── 6 faculties (STEAD, SSAH, Education, Business, Graduate, Other)
│     faculty_name        │
│     faculty_dean        │
└──────────┬─────────────┘
           │ 1:N
           ▼
┌────────────────────────┐       ┌──────────────────────────┐
│    acad_programme       │       │    acad_curriculum        │
│ PK: progcode            │ ◄─N──│ PK: ID                   │
│     progname            │       │     Tittle, Description   │
│     abbrev              │       │     Progcode, StartYear   │
│ FK: faculty_code        │       └──────────────────────────┘
│     levelCode           │
│     study_system        │       ┌──────────────────────────┐
│     couselength         │──1:N─►│   acad_specialisation     │
│     maxduration         │       │ PK: spec_id               │
│     mincredit           │       │ FK: prog_id → progcode    │
│     is_fully_set        │       │     spec (name), abbrev   │
└──────────┬─────────────┘       │     is_fully_set          │
           │ 1:N                  └──────────────────────────┘
           ▼
┌────────────────────────┐       ┌──────────────────────────┐
│  acad_programmecourses  │──N:1─►│      acad_course          │
│ PK: ID                  │       │ PK: courseID              │
│ FK: progcode            │       │     courseName            │
│ FK: course_code →courseID│      │     CreditUnit            │
│     study_year          │       │     ContactHr, LectureHr  │
│     semester            │       │     PracticalHr           │
│     CurriculumID        │       │     stat (Active/InActive)│
│     specialisation_id   │       │     CoreStatus            │
│     course_type         │       └──────────────────────────┘
│     (CORE/ELECTIVE)     │
└──────────┬─────────────┘
           │ (course_code + progcode form the link to allocations)
           ▼
┌─────────────────────────────────────────────────────────────┐
│              acad_teaching_allocation                         │
│ PK: ID                                                       │
│     staffCode  ─── empID (integer) → hrm_employee.empID      │
│     courseID   ─── FK → acad_course.courseID                  │
│     progcode   ─── FK → acad_programme.progcode              │
│     acad_year  ─── e.g. "2025/2026"                          │
│     semester   ─── 1, 2, or 3                                │
│     cyear      ─── study year (1, 2, 3, 4)                   │
│     stud_session ── Day / Weekend / INSERVICE / EVENING      │
│     intake     ─── intake period                             │
│     stream     ─── usually "-"                               │
│     campusId   ─── FK → acad_campuses.ID                     │
│     EntryYear  ─── student entry year (2020, 2021, etc)      │
│     ─────────── TIMETABLE FIELDS (often empty) ──────────    │
│     lectureday ─── MONDAY–SUNDAY (default: "-")             │
│     StartTime  ─── e.g. "08:00" (default: NULL)             │
│     EndTime    ─── e.g. "10:00" (default: NULL)             │
│     roomNo     ─── FK → acad_lecturerooms.RoomID (default: "8") │
└─────────────────────────────────────────────────────────────┘
           │
           ├────► acad_coursework_timetable (parallel table for coursework schedules)
           ├────► acad_exam_timetable (parallel table for exam schedules)
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│                    hrm_employee                              │
│ PK: empID (auto-increment integer)                           │
│     emp_name, EMP_CODE (alphanumeric), EmpType               │
│     emp_phone, emp_email, emp_qualifications                 │
│     usernames (login username)                               │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│                  hrm_emp_contracts                            │
│ PK: ID                                                       │
│ FK: empID → hrm_employee.empID                               │
│     jobID → hrm_jobs.ID, departmentID → hrm_departments.ID  │
│     contractStart, contractEnd, contractStatus               │
│     contract_type (FULL TIME / PART TIME)                    │
│     payscale, fixedamount                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    acad_student                               │
│ PK: regno                                                    │
│     firstname, othername, email, programme (→progcode)        │
│     progid (FK → acad_programme.progcode... uses "progid")   │
└──────────┬──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│                  acad_registration                            │
│ PK: ID                                                       │
│ FK: regno → acad_student.regno                               │
│     acad_year, semester, studyyear, regstatus                │
│     examClearance, registeredBy                              │
└──────────┬──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│     campus_dynamics_portal.acad_course_registration           │
│     (Cross-database table in the PORTAL database)            │
│     courseID, acad_year, semester, prog_id, stud_session      │
│     course_status (NORMAL / RETAKE)                          │
└──────────┬──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│                     acad_results                             │
│ PK: ID                                                       │
│ FK: regno, courseid, acad, semester, studyyear, progid       │
│     score, grade, gradept, gpa, CreditUnits                  │
│     result_comment                                           │
└─────────────────────────────────────────────────────────────┘
```

### Parallel Results Processing Chain

```
Teaching Allocation
    │
    ├──► Teaching Center (Portal)
    │    └──► Coursework marks → acad_coursework_marks (portal DB)
    │    └──► Exam marks → acad_examresults_faculty (main DB)
    │    └──► Research marks, Practical marks
    │
    └──► Results Processing (Admin)
         └──► acad_results (final grades, GPA)
         └──► acad_results_status (quality workflow: DRAFT → SUBMITTED → APPROVED)
```

---

## 3. Database Schema Reference

### 3.1 Core Academic Tables

| Table | Records | Purpose | Key Columns |
|-------|---------|---------|-------------|
| `acad_faculty` | 6 | University faculties | `faculty_code` PK, `faculty_name`, `faculty_dean` |
| `acad_programme` | 131 | Academic programmes (degrees) | `progcode` PK, `progname`, `faculty_code` FK, `levelCode`, `study_system`, `couselength` |
| `acad_course` | 6,905 | Course catalog | `courseID` PK, `courseName`, `CreditUnit`, `stat`, `CoreStatus` |
| `acad_programmecourses` | 6,778 | Programme-Course mapping (curriculum) | `ID` PK, `progcode`, `course_code`, `study_year`, `semester`, `CurriculumID`, `specialisation_id`, `course_type` |
| `acad_specialisation` | varies | Programme specialisation tracks | `spec_id` PK, `prog_id`, `spec`, `abbrev` |
| `acad_curriculum` | varies | Curriculum versions per programme | `ID` PK, `Progcode`, `Tittle`, `StartYear`, `intake` |

### 3.2 Teaching & Timetable Tables

| Table | Records | Purpose | Key Columns |
|-------|---------|---------|-------------|
| `acad_teaching_allocation` | 20,747 | **Core allocation** — links lecturer to course/programme/semester | `staffCode` (→empID), `courseID`, `progcode`, `acad_year`, `semester`, `lectureday`, `StartTime`, `EndTime`, `roomNo` |
| `acad_coursework_timetable` | 12 | Coursework submission schedules (dates) | Same shape as teaching_allocation but with `testdate` instead of `lectureday`/`EntryYear` |
| `acad_exam_timetable` | 437 | Exam schedules | Same shape + `ExamDate`, `Entryyear`, `ExamType` |
| `acad_lecturerooms` | varies | Physical rooms with capacity | `RoomID` PK, `RoomName`, `Capacity`, `campusId` |
| `acad_campuses` | 3 | Campus locations | `ID` PK (0=ALL, 1=KAKEEKA, 2=KIRUMBA) |
| `acad_timetable_weekdays` | 7 | Days of the week reference | `DayNo`, `DayName` |

### 3.3 HR/Staff Tables

| Table | Records | Purpose | Key Columns |
|-------|---------|---------|-------------|
| `hrm_employee` | 309 | All employees | `empID` PK (auto-int), `EMP_CODE` (alphanumeric), `emp_name`, `EmpType`, `usernames` |
| `hrm_emp_contracts` | varies | Employment contracts | `empID` FK, `jobID`, `departmentID`, `contractStatus`, `contract_type` |
| `hrm_departments` | varies | Departments | Referenced by contracts |

### 3.4 Student & Registration Tables

| Table | Records | Purpose | Key Columns |
|-------|---------|---------|-------------|
| `acad_student` | 31,112 | Student master | `regno` PK, `firstname`, `othername`, `progid`, `email` |
| `acad_registration` | 27,987 | Semester registrations | `regno`, `acad_year`, `semester`, `studyyear`, `regstatus` |
| `portal.acad_course_registration` | varies | Per-course registrations (portal DB) | `courseID`, `acad_year`, `semester`, `regno`, `prog_id`, `course_status` |

### 3.5 Results & Assessment Tables

| Table | Records | Purpose | Key Columns |
|-------|---------|---------|-------------|
| `acad_results` | 626,490 | Final aggregated results | `regno`, `courseid`, `score`, `grade`, `gradept`, `gpa` |
| `acad_examresults_faculty` | varies | Faculty-level exam results (per-student, per-course) | `course_id`, `progid`, `acadyear`, `semester`, marks detail, `settingsID` |
| `acad_examresults_faculty_settings` | varies | Coursework/exam/test ratio settings per course instance | `course_id`, `acadyear`, `semester`, `coursework_ratio`, `exam_ratio`, `test_ratio` |
| `acad_results_status` | varies | Results quality workflow | `course_id`, `progid`, `acadyear`, `status` (DRAFT→SUBMITTED→APPROVED→PUBLISHED) |
| `acad_programme_resultsratios` | varies | Default cw/practical/exam ratios per programme | `progcode` PK, `Coursework=40`, `Practicals=0`, `Exams=60` |

### 3.6 Important Column Mapping: `staffCode`

```
acad_teaching_allocation.staffCode = hrm_employee.empID (CAST AS INTEGER)
                                  ≠ hrm_employee.EMP_CODE (alphanumeric HR code)
```

The column is named `staffCode` but stores the numeric `empID`. The Teaching Center (portal) uses `Session["userName"]` (which maps to `hrm_employee.usernames`) to identify the lecturer, not `empID`.

---

## 4. Classic System — Page-by-Page Analysis

### 4.1 Faculty Management (Classic)

#### `COOPERP/Faculty/Programmes.aspx`
- **Purpose:** Master list of all 131 programmes
- **Data Layer:** `FacultyDataTableAdapters.acad_programmeTableAdapter`
- **CRUD:** Full (via DevExpress grid + ObjectDataSource)
- **Connections:** Opens `ProgrammeStructure.aspx` popup for course assignment

#### `COOPERP/Faculty/ProgrammeStructure.aspx`
- **Purpose:** Assign courses to a programme by curriculum version
- **Data Layer:** `FacultyDataTableAdapters.acad_programmecoursesTableAdapter`
- **Key Features:**
  - Curriculum version management (create, switch, copy courses across curricula)
  - Batch course addition by prefix (e.g., "ICT" adds all ICT courses)
  - Validation that coursework + practicals + exams ratios = 100%
  - **⚠ Inserts default `study_year=1, semester=1`** — must batch-edit afterward
  - **⚠ No specialisation support** (added only in new system)

#### `COOPERP/Faculty/CourseInfo.aspx`
- **Purpose:** Course catalog master (6,905 courses)
- **Data Layer:** `FacultyDataTableAdapters.acad_courseTableAdapter`
- **CRUD:** Full via grid
- **Note:** `CoreStatus` column stores "Optional" for what the UI labels "Elective"

### 4.2 Teaching Allocation (Classic)

#### `UserControls/Timetables/TeachingAllocations.ascx` — **THE KEY PAGE**
- **Purpose:** Create and manage lecturer-to-course assignments with timetable data
- **Data Layer:** `TimetableDataTableAdapters.acad_teaching_allocationTableAdapter` + direct `MySqlConnection`
- **Filter Chain:**
  ```
  Campus → Programme → Academic Year → Semester → Study Year → Entry Year → Intake → Session
  ```
- **Record Creation (`cmdAddNew_Click`):**
  ```
  staffCode (empID) + courseID + acad_year + semester + progcode + cyear + 
  stud_session + intake + stream("-") + campusId + lectureday("-") + EntryYear
  ```
  Creates with **no schedule** — `lectureday="-"`, `StartTime=NULL`, `EndTime=NULL`
- **Timetable Assignment:** Done via **batch edit** on the grid — user edits `lectureday`, `StartTime`, `EndTime`, `roomNo` columns inline
- **Adopt Feature:** Copies allocations from one entry year to another (stored proc `AdoptTimeTable`)
- **BindCourses SQL:**
  ```sql
  SELECT DISTINCT pc.course_code, COALESCE(c.courseName, pc.course_code) AS course_name
  FROM acad_programmecourses pc
  LEFT JOIN acad_course c ON c.courseID = pc.course_code
  WHERE pc.progcode = @prog
  ORDER BY c.courseName, pc.course_code
  ```
  **⚠ Shows ALL courses for a programme regardless of study_year/semester** — potentially confusing

### 4.3 Other Classic Pages

| Page | Status | Purpose |
|------|--------|---------|
| `Timetables/coursework_timetables.aspx` | Active | Manages coursework assessment schedules (dates, not lectures) + score ratios |
| `Timetables/CourseRegistration.aspx` | **Empty shell** | Code-behind has no logic — dead page |
| `Timetables/CourseRegistrationSelections.aspx` | **Empty shell** | Code-behind has no logic — dead page |
| `HumanResource/TeachingCentre.aspx` | References missing control | Loads `hr_teaching_allocation.ascx` (not found in workspace) |
| `HumanResource/TeacherMgt/teachermgt.ascx` | Active (K-12) | Teacher management — but uses Vienna College code/naming. Not MRU-specific |
| `HumanResource/TeacherMgt/AcademicStaffDetails.ascx` | Active (K-12 only) | Subject allocation for `int_subjectallocation` — **NOT university teaching** |

---

## 5. New System Interface — Page-by-Page Analysis

### 5.1 `NewScreens/NewCourses.aspx`
- **Purpose:** Modern course catalog management with stat dashboard
- **Improvements Over Classic:**
  - Statistics cards (Total / Active / Inactive counts)
  - Modern design system with card layout
  - Action popovers for row operations
- **Tables:** `acad_course` (same as classic)
- **Issues:**
  - ⚠ **Hardcoded DB credentials** in fallback connection string
  - Stats don't refresh after grid update (only after full page reload)

### 5.2 `NewScreens/NewFacultyProgrammes.aspx`
- **Purpose:** Modern programme management with modal forms
- **Improvements Over Classic:**
  - Modal form for add/edit (replaces grid-inline editing)
  - Auto-schema migration (`EnsureColumns()` adds `is_fully_set` if missing)
  - Programme structure popup (delegates to classic `ProgrammeStructure.aspx`)
  - Inline course assignment modal (add courses without leaving the page)
  - Specialisation count displayed per programme
- **Tables:** `acad_programme`, `acad_faculty`, `acad_programmecourses`, `acad_course`, `acad_specialisation`
- **Issues:**
  - ⚠ `EnsureColumns()` runs on **every page load** (INFORMATION_SCHEMA query each time)
  - ⚠ Programme delete cascades to `acad_specialisation` but **NOT** to `acad_programmecourses`, `acad_teaching_allocation`, or `acad_registration` — **orphan data risk**
  - ⚠ Course-add modal uses simple insert `(progcode, course_code, study_year, semester)` — **no `specialisation_id`, no `course_type`, no `CurriculumID`** — conflicts with `NewProgrammeCourses.aspx`

### 5.3 `NewScreens/NewProgrammeCourses.aspx`
- **Purpose:** Modern programme-course mapping with full specialisation + CORE/ELECTIVE support
- **Improvements Over Classic:**
  - Full specialisation_id support (classic doesn't have it)
  - Course type distinction (CORE / ELECTIVE)
  - Client-side course search via JSON array
  - Cascading specialisation dropdown (filtered by programme)
  - Proper duplicate detection (not exception-catching)
  - Year/Semester settable at insert time (classic defaults to 1/1)
- **Tables:** `acad_programmecourses`, `acad_programme`, `acad_course`, `acad_specialisation`
- **Issues:**
  - ⚠ `CurriculumID` hardcoded to `0` — **curriculum system abandoned**
  - ⚠ Specialisation is required in the modal — blocks programmes without specialisations
  - ⚠ Builds full JSON arrays of ALL courses (6,905) and all specialisations on **every request** — performance concern
  - ⚠ `LoadProgrammes()` and `BindGrid()` run unconditionally — not PostBack-aware

### 5.4 `NewScreens/CourseRegistration.aspx`
- **Purpose:** Bulk course registration by admin staff — the most complex new screen
- **Features:**
  - Pending student list (registered but not yet course-registered)
  - Registered student list per course
  - Bulk register / remove / retake operations
  - Quick Edit popup for student profile inline editing
  - Semester active validation before registration
- **Tables:** `acad_registration`, `acad_student`, `acad_programmecourses`, `acad_course`, `portal.acad_course_registration`, `acad_specialisation`, `acad_campuses`, `acad_applications`, `fin_billing_systems`
- **Issues:**
  - ⚠ **Cross-database query** to `campus_dynamics_portal.acad_course_registration`
  - ⚠ **Hardcoded accounts DB credentials** as fallback
  - ⚠ `btnRemoveSelected_Click` passes `@act='Registered'` to the same SP used for register — semantically confusing
  - ⚠ Quick Edit updates **18 fields** on `acad_student` — a mini student management system embedded here

---

## 6. Teaching Center (Portal) Analysis

The Teaching Center is where **lecturers manage marks and results** for their allocated courses. It lives in `CampusDynamics_Portal/COOPERP/TeachingCenter/`.

### How a Lecturer Sees Their Courses

```
Login → TeachingAllocations grid (filtered by acad_year + semester)
    ↓
Grid Source: acad_teaching_allocation WHERE staffCode = Session["userName"]
    ↓                                         ▲
    ↓                              (staffCode = empID... but Session["userName"] = ??)
    ↓
Click Course → Course Profile (popup)
    ↓
    ├── Coursework Results tab → Enter marks (4 assignments + 3 tests)
    ├── Exam Results tab → Enter marks (Q1–Q10)
    ├── Research Results tab → Internal/External examiner marks
    ├── Practical Exam tab → Task marks (5 tasks)
    └── Student Complaints tab → (empty placeholder)
```

### Critical Connection:

The Teaching Center filters `acad_teaching_allocation` by `staffCode` matching `Session["userName"]`. This means:
- `Session["userName"]` must equal the string representation of `empID` (integer)
- The login system must set `Session["userName"]` to the employee's **empID** (not their username or EMP_CODE)

### Mark Flow:

```
TeachingAllocations → CourseProfile → CourseWorkDetails
    ↓                                        ↓
Session["courseID"],                   acad_coursework_settings (portal DB)
Session["progcode"],                   acad_coursework_marks (portal DB)
Session["acad"],                       ↓
Session["sem"],                   SUBMITTED → APPROVED → CAPTURED
Session["lecturerID"]                  ↓
    ↓                              acad_results (main DB) — final grades
ExamResultsData → ResultsDetails
    ↓
acad_examresults_faculty (main DB)
acad_examresults_faculty_settings (main DB)
```

### Full documentation: See `TEACHING_CENTER_DOCUMENTATION.md`

---

## 7. API Layer Analysis

### `API/v2/academic.aspx` — 14 Endpoints

| Endpoint | Purpose | Status |
|----------|---------|--------|
| `results` | Student result transcripts | ✅ Working |
| `transcript` | Full transcript with programme info | ✅ Working |
| `gpa` | GPA calculation | ✅ Working |
| `available_courses` | Pending course registration options | ✅ Working (SP-based) |
| `registered_courses` | Student's registered courses | ✅ Working |
| `register_course` | Self-service course registration | ✅ Working |
| `drop_course` | Drop a registered course | ✅ Working |
| `semester_registration` | Semester registration with auto-billing | ✅ Working |
| `registration_history` | Semester registration history | ✅ Working |
| `enrollment_status` | Current enrollment details | ✅ Working |
| `course_details` | Course information with prerequisites | ⚠ **Column name mismatches** |
| `course_enrollments` | Course enrollment counts (staff) | ⚠ **Column name mismatches** |
| `programme_curriculum` | Programme structure | ⚠ **Column name mismatches** |
| `grading_scheme` | Grade scale | ✅ Working (hardcoded fallback) |

### `API/v2/timetable.aspx` — 2 Endpoints

| Endpoint | Purpose | Status |
|----------|---------|--------|
| `lectures` | Student/staff lecture timetable | ❌ **BROKEN — queries non-existent `acad_timetable` table** |
| `exams` | Exam schedule | ⚠ Queries `acad_exam_timetable` — may work if data exists |

### API Column Name Mismatches

The API was written against a **different schema version or expected schema**:

| API References | Actual Column Name | Table |
|---------------|-------------------|-------|
| `acad_programmecourses.courseID` | `course_code` | `acad_programmecourses` |
| `acad_programmecourses.studyYear` | `study_year` | `acad_programmecourses` |
| `acad_programme.proglevel` | `levelCode` | `acad_programme` |
| `acad_programme.progfaculty` | `faculty_code` | `acad_programme` |
| `acad_programme.progduration` | `couselength` | `acad_programme` |
| `acad_programme.progdept` | **does not exist** | `acad_programme` |
| `acad_timetable.*` | **table does not exist** | — |

---

## 8. Data Flow — End to End

### The Full Academic Lifecycle

```
1. SETUP PHASE (Admin)
   ┌─────────────────────────────────────────────────────────────────┐
   │ Create Faculty → Create Programme → Create Courses             │
   │    (Programmes.aspx)  (ProgrammeStructure.aspx or             │
   │                         NewProgrammeCourses.aspx)              │
   │                                                                 │
   │ Assign courses to programmes with year/semester/specialisation │
   └─────────────────────────────────────────────────────────────────┘
                              ↓

2. ALLOCATION PHASE (Admin — each semester)
   ┌─────────────────────────────────────────────────────────────────┐
   │ TeachingAllocations.ascx:                                       │
   │   Select Programme + Year + Semester + Session + Entry Year    │
   │   Assign Lecturer + Course → creates acad_teaching_allocation  │
   │   (Optional) Set lectureday + StartTime + EndTime + Room       │
   └─────────────────────────────────────────────────────────────────┘
                              ↓

3. REGISTRATION PHASE (Admin + Student)
   ┌─────────────────────────────────────────────────────────────────┐
   │ Admin: CourseRegistration.aspx (NewScreens)                     │
   │   Bulk-register students for courses they're supposed to take  │
   │                                                                 │
   │ Student: CourseRegistration.aspx (Portal)                       │
   │   Self-service course registration from available courses      │
   └─────────────────────────────────────────────────────────────────┘
                              ↓

4. TEACHING PHASE (Lecturer — Portal Teaching Center)
   ┌─────────────────────────────────────────────────────────────────┐
   │ Lecturer logs into portal → sees their teaching allocations    │
   │ Clicks a course → enters coursework marks (assignments/tests)  │
   │ Clicks a course → enters exam marks (Q1–Q10)                  │
   │ Submits results → status changes to SUBMITTED                 │
   └─────────────────────────────────────────────────────────────────┘
                              ↓

5. RESULTS PROCESSING (Admin)
   ┌─────────────────────────────────────────────────────────────────┐
   │ HOD approves submitted results (SUBMITTED → APPROVED)          │
   │ Results captured into acad_results (APPROVED → CAPTURED)       │
   │ Final grades, GPA computed                                     │
   │ Published to student transcript (CAPTURED → LOCKED)            │
   └─────────────────────────────────────────────────────────────────┘
                              ↓

6. STUDENT ACCESS
   ┌─────────────────────────────────────────────────────────────────┐
   │ Student views results on portal                                │
   │ Student views timetable (API — currently broken)               │
   │ Student downloads transcript                                   │
   └─────────────────────────────────────────────────────────────────┘
```

### How the Key Entities Connect

```
FACULTY ──(1:N)──► PROGRAMME ──(1:N)──► PROGRAMME_COURSES ──(N:1)──► COURSE
                        │                       │
                        │                       ├── study_year, semester
                        │                       ├── specialisation_id
                        │                       └── CurriculumID
                        │
                        ├──(1:N)──► TEACHING_ALLOCATION ──(N:1)──► EMPLOYEE (Lecturer)
                        │              │
                        │              ├── acad_year, semester, cyear
                        │              ├── stud_session, intake, EntryYear
                        │              └── lectureday, StartTime, EndTime, roomNo
                        │
                        └──(1:N)──► STUDENT ──(1:N)──► REGISTRATION ──(1:N)──► COURSE_REG
                                                                                    │
                                                                                    ▼
                                                                               RESULTS
```

---

## 9. Data Quality Audit (Live Database)

### Teaching Allocation Analysis

| Metric | Value | % | Status |
|--------|-------|---|--------|
| Total allocations | 20,747 | 100% | — |
| With schedule (day/time set) | 1,648 | **7.9%** | ⚠ Critical gap |
| Without schedule (lectureday = "-") | 19,099 | 92.1% | — |
| Lecturer assigned (staffCode ≠ 0) | 20,191 | 97.3% | ✅ Good |
| Unassigned (staffCode = 0) | 556 | 2.7% | ⚠ Needs attention |

### Duplicate Allocations

Many duplicate records exist (same lecturer + course + programme + year + semester appearing multiple times). First 10 duplicates sampled, most have `staffCode = 0` (unassigned). Root cause: batch creation without uniqueness constraints.

### Session Distribution

| Session | Records | % |
|---------|---------|---|
| Day | 13,772 | 66.4% |
| Weekend | 3,804 | 18.3% |
| INSERVICE | 3,099 | 14.9% |
| EVENING | 67 | 0.3% |
| Unset ("-") | 5 | <0.1% |

### Academic Year Distribution

| Year | Records |
|------|---------|
| 2025/2026 | 5,933 |
| 2024/2025 | 7,678 |
| 2023/2024 | 5,020 |
| 2022/2023 | 1,002 |
| Older | 1,114 |

### The `staffCode` ≠ `EMP_CODE` Problem

- `acad_teaching_allocation.staffCode` stores **`empID`** (integer as string): `"49"`, `"78"`, `"143"`
- `hrm_employee.EMP_CODE` stores **HR codes**: `"MRU0078"`, `"AT01022022LQA"`
- The **JOIN** must use `CAST(staffCode AS UNSIGNED) = empID`, not `staffCode = EMP_CODE`
- The Teaching Center portal uses `Session["userName"]` — need to verify what value this holds

---

## 10. Critical Issues & Risks

### 🔴 Critical (Must Fix)

| # | Issue | Impact | Location |
|---|-------|--------|----------|
| C1 | **API timetable endpoint references non-existent `acad_timetable` table** | Students and mobile app see NO timetable data | `API/v2/timetable.aspx.cs` |
| C2 | **API column name mismatches** in `course_details`, `course_enrollments`, `programme_curriculum` | SQL errors on these endpoints | `API/v2/academic.aspx.cs` |
| C3 | **92% of teaching allocations have no timetable data** | The "timetable" part of the allocation system is barely used | `acad_teaching_allocation` |
| C4 | **Two pages write to `acad_programmecourses` with different schemas** | Data inconsistency (some records have specialisation, some don't) | `NewProgrammeCourses.aspx` vs `NewFacultyProgrammes.aspx` |

### 🟡 High (Should Fix)

| # | Issue | Impact | Location |
|---|-------|--------|----------|
| H1 | **No UNIQUE constraint** on `(staffCode, courseID, progcode, acad_year, semester, EntryYear)` | Duplicate allocations accumulate | `acad_teaching_allocation` |
| H2 | **`staffCode` column naming is misleading** — stores `empID` not `EMP_CODE` | Developer confusion, potential JOIN bugs | All allocation-related code |
| H3 | **Hardcoded DB credentials** in fallback connection strings | Security risk | `NewCourses.aspx.cs`, `CourseRegistration.aspx.cs` |
| H4 | **`EnsureColumns()` runs on every page load** | INFORMATION_SCHEMA query per request | `NewFacultyProgrammes.aspx.cs` |
| H5 | **Programme delete doesn't cascade** to allocations, registrations, course mappings | Orphan data if programme deleted | `NewFacultyProgrammes.aspx.cs` |
| H6 | **No time overlap/room collision detection** in UI | Double-bookings possible | `TeachingAllocations.ascx.cs` |
| H7 | **Curriculum system abandoned** — new pages set `CurriculumID=0` | Legacy curriculum data becomes meaningless | `NewProgrammeCourses.aspx.cs` |

### 🟠 Medium (Improve)

| # | Issue | Impact | Location |
|---|-------|--------|----------|
| M1 | **Cross-database queries** from main to portal DB | Tight coupling, privilege requirements | `CourseRegistration.aspx.cs` |
| M2 | **Session-based page state** — concurrent tabs clobber each other | Bug-prone user experience | All classic pages |
| M3 | **Full JSON arrays** of 6,905 courses loaded on every request | Performance degradation | `NewProgrammeCourses.aspx.cs` |
| M4 | **No audit trail** on teaching allocation changes | Cannot track who changed what | `acad_teaching_allocation` |
| M5 | **BindCourses ignores study_year/semester** | Shows all courses for a programme regardless of year | `TeachingAllocations.ascx.cs` |

---

## 11. Improvement Plan for New System Interface

### 11.1 New Teaching Allocation Page (`NewTeachingAllocations.aspx`)

**Goal:** A single, modern page that replaces the classic `TeachingAllocations.ascx` with:

#### Core Improvements

1. **Unified Allocation + Schedule (One-Step)**
   - Instead of creating allocation with `lectureday = "-"` then batch-editing, the modal form should include ALL fields:
     ```
     Lecturer + Course + Day + Start Time + End Time + Room
     ```
   - Day/Time/Room should still be optional (for planning-phase allocations)

2. **Smart Course Filtering**
   - Filter courses by `study_year + semester` from `acad_programmecourses` (unlike classic which shows all courses)
   - Show credit units, course type (CORE/ELECTIVE), and contact hours in the dropdown

3. **Lecturer Workload Dashboard**
   - Show total courses assigned, total contact hours, per-day breakdown
   - Badge for overloaded lecturers (e.g., > 18 contact hours/week)
   - Cross-reference with `hrm_emp_contracts.contract_type` (full-time vs part-time)

4. **Room Collision Detection**
   ```sql
   SELECT COUNT(*) FROM acad_teaching_allocation
   WHERE roomNo = @room AND lectureday = @day
     AND acad_year = @year AND semester = @sem AND campusId = @campus
     AND ((StartTime >= @start AND StartTime < @end)
       OR (EndTime > @start AND EndTime <= @end)
       OR (StartTime <= @start AND EndTime >= @end))
     AND ID != @excludeId
   ```
   Show warning before saving if collision detected

5. **Lecturer Time Conflict Detection**
   Same query but filtered by `staffCode` instead of `roomNo`

6. **Duplicate Prevention**
   - Add `UNIQUE INDEX` on `(staffCode, courseID, progcode, acad_year, semester, EntryYear, stud_session)` to `acad_teaching_allocation`
   - Check before insert in code

7. **Audit Trail**
   - Add `created_by`, `created_at`, `updated_by`, `updated_at` columns
   - Log all changes

#### UI Design

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Page Header: Teaching Allocations]                                  │
│                                                                      │
│ ┌─────────┐ ┌──────────┐ ┌───────┐ ┌──────┐ ┌──────┐ ┌───────────┐│
│ │ Campus  │ │Programme │ │ Year  │ │ Sem  │ │ Yr   │ │ Session   ││
│ │ ▼       │ │ ▼        │ │ ▼     │ │ ▼    │ │ ▼    │ │ ▼         ││
│ └─────────┘ └──────────┘ └───────┘ └──────┘ └──────┘ └───────────┘│
│                                                                      │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐                           │
│ │ 24 Total │  │ 18 Sched │  │ 6 Pend   │  [+ New Allocation]      │
│ └──────────┘  └──────────┘  └──────────┘                           │
│                                                                      │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Lecturer    │ Course      │ Day  │ Time       │ Room │ Actions │ │
│ │ Dr. Smith   │ ICT2206 OOP │ MON  │ 08:00-10:00│ Lab1 │ ✏️ 🗑️  │ │
│ │ Prof. Jane  │ BIT3101 DB  │ TUE  │ 10:00-12:00│ Q2   │ ✏️ 🗑️  │ │
│ │ ⚠ Unassigned│ ICT2205 Scr │  —   │     —      │  —   │ ✏️ 🗑️  │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│ ─── Modal: New / Edit Allocation ───────────────────────────────    │
│ │ Lecturer: [Search dropdown — emp_name (EMP_CODE)]              │  │
│ │ Course:   [Filtered by year/semester — shows credit units]     │  │
│ │ Day:      [MON-SUN dropdown]                                   │  │
│ │ Time:     [Start ▼] - [End ▼]  (30-min slots)                │  │
│ │ Room:     [Filtered by campus — shows capacity]                │  │
│ │ ⚠ Collision Warning: "Room Q2 is already booked MON 08-10"    │  │
│ │                    [Save Anyway] [Choose Different Room]       │  │
│ └──────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

### 11.2 Timetable View Page (`NewTimetable.aspx`)

**Goal:** A visual weekly timetable grid (like a calendar) that reads from `acad_teaching_allocation`

```
┌──────────────────────────────────────────────────────────────────┐
│ [Programme ▼] [Year ▼] [Semester ▼] [Entry Year ▼] [Session ▼] │
│                                                                  │
│        MON       TUE       WED       THU       FRI       SAT    │
│ 07:00  ┌───┐                                                    │
│ 08:00  │ICT│    ┌───┐                ┌───┐                      │
│        │220│    │BIT│                │ICT│                      │
│ 09:00  │6  │    │310│    ┌───┐       │220│                      │
│        │Lab│    │1  │    │BER│       │5B │                      │
│ 10:00  └───┘    │Q2 │    │320│       │Lab│    ┌───┐             │
│                 └───┘    │5  │       └───┘    │   │             │
│ 11:00                    │MH │                │   │             │
│ 12:00                    └───┘                └───┘             │
│                                                                  │
│ Each block shows: Course Code, Lecturer, Room, Time              │
└──────────────────────────────────────────────────────────────────┘
```

### 11.3 Fix `NewProgrammeCourses.aspx` Inconsistencies

1. **Make specialisation optional** (not required) — many programmes don't have specialisations
2. **Unify the insert schema** with `NewFacultyProgrammes.aspx` — both should write `specialisation_id`, `course_type`, `CurriculumID=0`
3. **Lazy-load course JSON** via AJAX endpoint instead of embedding 6,905 records on page load

### 11.4 Fix API Endpoints

1. **Create `acad_timetable` as a VIEW** on `acad_teaching_allocation`:
   ```sql
   CREATE OR REPLACE VIEW acad_timetable AS
   SELECT 
       ta.progcode AS programme_code,
       ta.cyear AS study_year,
       ta.courseID AS course_code,
       CAST(ta.staffCode AS UNSIGNED) AS lecturer_id,
       ta.lectureday AS day_of_week,
       ta.StartTime AS start_time,
       ta.EndTime AS end_time,
       ta.roomNo AS room,
       '' AS building,
       ta.acad_year,
       ta.semester,
       ta.stud_session,
       ta.campusId
   FROM acad_teaching_allocation ta
   WHERE ta.lectureday != '-' AND ta.lectureday IS NOT NULL
     AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL;
   ```

2. **Fix column name mappings** in `academic.aspx.cs` for `course_details`, `course_enrollments`, `programme_curriculum`

---

## 12. Migration & Transition Strategy

### Principles

1. **Additive, not destructive** — new pages READ from same tables as classic; never break existing data
2. **Both systems run simultaneously** — classic pages remain accessible while new pages are built
3. **Feature parity first** — new page must do everything classic page does before replacing it
4. **Gradual rollover** — redirect classic URLs to new pages once ready

### Phase Plan

```
Phase 1: Data Foundation (Fix Schema)
├── Add UNIQUE constraints to acad_teaching_allocation
├── Add audit columns (created_by, created_at, updated_by, updated_at)
├── Create acad_timetable VIEW for API
├── Fix duplicate records in existing data
└── Unify NewProgrammeCourses/NewFacultyProgrammes insert schemas

Phase 2: New Teaching Allocation Page
├── Build NewTeachingAllocations.aspx 
├── Include collision detection, workload display
├── Full CRUD with modal form (one-step allocation + schedule)
├── Read same tables as classic — zero data migration needed
└── Test side-by-side with classic page

Phase 3: Timetable View
├── Build NewTimetable.aspx (visual weekly grid)
├── Read from acad_teaching_allocation (same source)
├── Add print/export capability
└── Link from portal for student timetable access

Phase 4: API Fixes
├── Create acad_timetable VIEW
├── Fix column name mismatches in academic.aspx.cs
├── Test all API endpoints with mobile app
└── Enable student timetable viewing

Phase 5: Cleanup & Retirement
├── Redirect classic TeachingAllocations to NewTeachingAllocations
├── Remove hardcoded DB credentials
├── Remove EnsureColumns() (one-time migration done)
└── Archive classic ProgrammeStructure.aspx (curriculum features)
```

### What NOT to Change

- **Do NOT rename `staffCode` column** — too many downstream consumers. Instead, add clear comments/aliases
- **Do NOT delete `CurriculumID`** — keep for backward compatibility, just default to 0
- **Do NOT merge the two databases** (main + portal) — too risky
- **Do NOT change the Teaching Center portal** — it works. The new pages focus on admin allocation

---

## 13. Implementation Roadmap

### Immediate (This Session / Next Session)

| # | Task | Effort | Priority |
|---|------|--------|----------|
| 1 | Create `acad_timetable` VIEW for API | 15 min | 🔴 Critical |
| 2 | Add UNIQUE index to prevent duplicate allocations | 30 min | 🔴 Critical |
| 3 | Fix API column mismatches (`academic.aspx.cs`) | 1 hr | 🔴 Critical |
| 4 | Remove hardcoded DB credentials | 15 min | 🟡 High |
| 5 | Make specialisation optional in `NewProgrammeCourses` | 30 min | 🟡 High |
| 6 | Unify course-add schema in `NewFacultyProgrammes` | 30 min | 🟡 High |
| 7 | Move `EnsureColumns()` to one-time migration | 15 min | 🟠 Medium |

### Short-Term (1–2 Weeks)

| # | Task | Effort | Priority |
|---|------|--------|----------|
| 8 | Build `NewTeachingAllocations.aspx` — core page | 2–3 days | 🔴 Critical |
| 9 | Add collision detection (room + lecturer) | 1 day | 🟡 High |
| 10 | Add lecturer workload display | 1 day | 🟡 High |
| 11 | Clean up duplicate allocations in DB | 1 hr | 🟡 High |

### Medium-Term (3–4 Weeks)

| # | Task | Effort | Priority |
|---|------|--------|----------|
| 12 | Build `NewTimetable.aspx` — visual weekly grid | 2–3 days | 🟡 High |
| 13 | Timetable print/export (PDF, Excel) | 1 day | 🟠 Medium |
| 14 | Portal student timetable integration | 1 day | 🟠 Medium |
| 15 | Batch allocation import (from previous semester) | 1 day | 🟠 Medium |

---

## 14. Best Practices & Recommendations

### Architecture

1. **Use the design system** — All new pages under `SidebarMaster.master` with CSS prefix `ac-` (academics)
2. **Inline SQL with parameterized queries** — Follow the `ExecuteQuery` / `ExecuteNonQuery` pattern from `CAMPUS_DYNAMICS_AI_REFERENCE.md`
3. **Postback-safe dropdowns** — Always use the `LoadDropdowns() → TrySelect(posted)` pattern
4. **JSON endpoints for search** — Expose large catalogs (courses, lecturers) as AJAX-loaded JSON, not page-embedded arrays
5. **Modal forms over popups** — Use HTML modals (like NewProgrammeCourses) instead of DevExpress popup windows (like ProgrammeStructure)

### Data Integrity

6. **Add UNIQUE constraints** at the DB level — don't rely on application code alone
7. **Cascade deletes carefully** — Check foreign key dependencies before DELETE; show a warning listing affected records
8. **Audit trail on allocations** — Every insert/update/delete should record `who` + `when`
9. **Validate before save** — Check for duplicates, time conflicts, room conflicts BEFORE executing DML

### Performance

10. **Cache reference data** — Faculties (6), campuses (3), and academic years don't change often; cache in Application state
11. **Lazy-load dropdowns** — Use AJAX cascading instead of loading all data upfront
12. **Index key queries** — Ensure `acad_teaching_allocation` has indexes on `(acad_year, semester, progcode)` and `(staffCode, acad_year, semester)`

### User Experience

13. **One-step allocation** — Modal includes lecturer + course + schedule in a single form
14. **Visual timetable** — Users should SEE the weekly grid, not just a data table
15. **Conflict warnings, not blocks** — Warn about double-bookings but allow override (with audit note)
16. **Workload visibility** — Show lecturer's total hours/courses when assigning
17. **Batch operations** — Allow "copy all allocations from Semester 1 to Semester 2" or "copy from last year"

### Security

18. **Remove all hardcoded credentials** — Use `ConfigurationManager.ConnectionStrings` only
19. **Validate permissions** — Check user role before allowing allocation changes
20. **Parameterize ALL queries** — No string concatenation for SQL

---

## Appendix A: File Inventory

### Classic System (CampusDynamics/COOPERP/)

| File | Purpose | Status |
|------|---------|--------|
| `Faculty/Programmes.aspx` + `.cs` | Programme CRUD (delegates to UserControl) | Active |
| `Faculty/ProgrammeStructure.aspx` + `.cs` | Programme → Course mapping with curriculum | Active |
| `Faculty/CourseInfo.aspx` + `.cs` | Course catalog CRUD (delegates to UserControl) | Active |
| `Timetables/coursework_timetables.aspx` + `.cs` | Coursework assessment schedules | Active |
| `Timetables/CourseRegistration.aspx` + `.cs` | **Empty shell** | Dead |
| `Timetables/CourseRegistrationSelections.aspx` + `.cs` | **Empty shell** | Dead |
| `HumanResource/TeachingCentre.aspx` + `.cs` | HR-side allocation view (missing control) | Broken |
| `UserControls/Timetables/TeachingAllocations.ascx` + `.cs` | **Core allocation page** | Active |
| `UserControls/Faculty/Programme.ascx` + `.cs` | Programme grid control | Active |
| `UserControls/HumanResource/TeacherMgt/teachermgt.ascx` + `.cs` | Teacher list (K-12 legacy) | Legacy |
| `UserControls/HumanResource/TeacherMgt/AcademicStaffDetails.ascx` + `.cs` | K-12 subject allocation | Legacy/K-12 |

### New System Interface (CampusDynamics/COOPERP/NewScreens/)

| File | Purpose | Status |
|------|---------|--------|
| `NewCourses.aspx` + `.cs` | Modern course catalog | Active |
| `NewFacultyProgrammes.aspx` + `.cs` | Modern programme management | Active |
| `NewProgrammeCourses.aspx` + `.cs` | Modern programme-course mapping | Active |
| `CourseRegistration.aspx` + `.cs` | Modern bulk course registration | Active |

### Teaching Center (CampusDynamics_Portal/)

| File | Purpose | Status |
|------|---------|--------|
| `COOPERP/TeachingCenter/Default.aspx` | Entry point | Active |
| `UserControls/TeachingCenter/TeachingAllocations.ascx` + `.cs` | Lecturer's allocation grid | Active |
| Full list in `TEACHING_CENTER_DOCUMENTATION.md` | — | — |

### API

| File | Purpose | Status |
|------|---------|--------|
| `API/v2/academic.aspx` + `.cs` | Academic data API (14 endpoints) | Partial |
| `API/v2/timetable.aspx` + `.cs` | Timetable API (2 endpoints) | **Broken** |

---

## Appendix B: SQL Queries for Data Verification

```sql
-- Teaching allocations by academic year
SELECT acad_year, COUNT(*) as cnt 
FROM acad_teaching_allocation GROUP BY acad_year ORDER BY acad_year DESC;

-- Allocations with vs without schedules
SELECT 
    SUM(CASE WHEN lectureday != '-' THEN 1 ELSE 0 END) as scheduled,
    SUM(CASE WHEN lectureday = '-' THEN 1 ELSE 0 END) as unscheduled,
    COUNT(*) as total
FROM acad_teaching_allocation;

-- Duplicate allocations
SELECT staffCode, courseID, progcode, acad_year, semester, COUNT(*) as dupes
FROM acad_teaching_allocation
GROUP BY staffCode, courseID, progcode, acad_year, semester
HAVING COUNT(*) > 1;

-- Lecturer workload (current year)
SELECT ta.staffCode, e.emp_name, COUNT(*) as courses, 
       SUM(c.ContactHr) as total_contact_hours
FROM acad_teaching_allocation ta
LEFT JOIN hrm_employee e ON CAST(ta.staffCode AS UNSIGNED) = e.empID
LEFT JOIN acad_course c ON ta.courseID = c.courseID
WHERE ta.acad_year = '2025/2026'
GROUP BY ta.staffCode, e.emp_name
ORDER BY courses DESC;

-- Room utilization (scheduled allocations)
SELECT ta.roomNo, lr.RoomName, lr.Capacity, ta.lectureday,
       ta.StartTime, ta.EndTime, ta.courseID, e.emp_name
FROM acad_teaching_allocation ta
LEFT JOIN acad_lecturerooms lr ON CAST(ta.roomNo AS UNSIGNED) = lr.RoomID
LEFT JOIN hrm_employee e ON CAST(ta.staffCode AS UNSIGNED) = e.empID
WHERE ta.lectureday != '-' AND ta.acad_year = '2025/2026'
ORDER BY ta.roomNo, ta.lectureday, ta.StartTime;
```

---

*Generated: 2026-04-10 | Campus Dynamics Academics Module Deep Analysis*
