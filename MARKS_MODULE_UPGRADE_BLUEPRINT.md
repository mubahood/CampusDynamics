# Marks Submission Module — Comprehensive Analysis & Upgrade Blueprint

**Project:** Campus Dynamics ERP — Mutesa I Royal University  
**Prepared:** April 2026  
**Scope:** Full analysis of the current marks-entry workflow, identification of all weaknesses, and a detailed blueprint for a modern parallel interface  
**Classic version:** Preserved 100% — no existing file is modified; new interface is additive only

---

## Table of Contents

1. [Module Inventory](#1-module-inventory)
2. [Teacher → Course Linkage (Current State)](#2-teacher--course-linkage-current-state)
3. [Student → Course Linkage (Current State)](#3-student--course-linkage-current-state)
4. [Marks Entry Workflow (Current State)](#4-marks-entry-workflow-current-state)
5. [Provisional vs Published Marks (Current State)](#5-provisional-vs-published-marks-current-state)
6. [Locking Mechanism (Current State)](#6-locking-mechanism-current-state)
7. [Historical Marks Access (Current State)](#7-historical-marks-access-current-state)
8. [Audit & Change Tracking (Current State)](#8-audit--change-tracking-current-state)
9. [UI/UX Assessment (Current State)](#9-uiux-assessment-current-state)
10. [Performance Assessment (Current State)](#10-performance-assessment-current-state)
11. [Security Assessment (Current State)](#11-security-assessment-current-state)
12. [Gap Summary — Classic vs Needed](#12-gap-summary--classic-vs-needed)
13. [Proposed New Interface — Design Specification](#13-proposed-new-interface--design-specification)
14. [Database Changes Required](#14-database-changes-required)
15. [Implementation Roadmap](#15-implementation-roadmap)
16. [Classic vs Modern Comparison Table](#16-classic-vs-modern-comparison-table)

---

## 1. Module Inventory

### Core Files

| File | Role |
|---|---|
| `UserControls/Results/FacultyExamResults.ascx` + `.cs` | Primary classic marks entry grid for lecturers (557 lines) |
| `UserControls/Results/ElectronicSheets.ascx` + `.cs` | Sheet browser — lists marksheets by status, opens MarksheetDetails |
| `UserControls/Results/MarksheetDetails.ascx` + `.cs` | Inline Q1–Q10 mark entry per student row; triggers `acad_CaptureResults` |
| `UserControls/Results/ResultsUpdates.ascx` + `.cs` | Post-approval corrections workflow (create → peer-approve change requests) |
| `UserControls/Results/ResearchElectronicSheets.ascx` + `.cs` | Research-specific marksheet browser |
| `UserControls/Results/ResearchMarkSheetDetails.ascx` + `.cs` | Research mark entry (Internal/External Examiner ratios) |
| `UserControls/Results/StudentResults.ascx` + `.cs` | Student-facing results viewer |
| `UserControls/Results/ResultsProblems.ascx` + `.cs` | Results anomaly reporting |
| `App_Code/Results/MarksAuditLogger.cs` | Structured audit logger writing to `acad_marks_audit` |
| `App_Code/Results/ResultsBLL.cs` | Business logic layer for Dean-only result capture |
| `App_Code/Results/ResultsData.xsd` | Typed DataSet — contains all SQL and stored procedure definitions |
| `App_Code/Results/Resultsecurity.xsd` | Deadlines and security-level typed DataSet |

### Key Database Tables

| Table | Database | Purpose |
|---|---|---|
| `acad_examresults_faculty` | `campus_dynamics` | Faculty-entered provisional marks (CW / Test / Exam per student per course) |
| `acad_examresults_faculty_settings` | `campus_dynamics` | Mark ratio configuration (CW%, Test%, Exam% per course/cohort) |
| `acad_examsettings` | `campus_dynamics_portal` | Q1–Q10-style marksheets with sheet-level status lifecycle |
| `acad_results` | `campus_dynamics_portal` | Final/published results (after Dean capture) |
| `acad_resultsupdates` | `campus_dynamics` | Post-approval change requests (old\_score → new\_score with peer approval) |
| `acad_programmecourses` | `campus_dynamics` | Programme→course mapping (progcode, course\_code, study\_year, semester) |
| `acad_results_lock` | `campus_dynamics` | Global deadline lock (RESULTS\_DEADLINE record) |
| `acad_deadlines` | `campus_dynamics` | Campus-level deadlines per activity/semester/year |
| `acad_results_securitylevel` | `campus_dynamics` | Programme-level row security toggle (1 = open, 2 = locked) |
| `acad_marks_audit` | `campus_dynamics` | Structured before/after audit log (new — from MarksAuditLogger) |
| `acad_activity_log` | `campus_dynamics` | Legacy free-text activity log |

### Key Stored Procedures

| Procedure | Called When |
|---|---|
| `acad_CreateFacultyExamSheet` | Teacher creates the marksheet for a cohort/course |
| `acad_GetFacultyExamSheet` | Load existing marksheet rows |
| `acad_CaptureFacultyResults` | Dean approves a faculty row → writes to `acad_results` |
| `acad_UpdateApprovalStatus` | Updates `approved_by` column on a row |
| `acad_GetResultSheetsByFaculty` | Fetch all sheets belonging to a faculty member |
| `acad_GetMarksheetDetails` | Fetch Q1–Q10 breakdown for a sheet |
| `acad_NewChange` | Create a post-approval change request |
| `acad_approveChanges` | Peer-approve a change request |
| `acad_UpdateChangeGrades` | Apply an approved change to the live result |

---

## 2. Teacher → Course Linkage (Current State)

### How It Currently Works

The teacher–course link is stored primarily in **`acad_examsettings.empCode`**. When a teacher creates a marksheet via `acad_CreateFacultyExamSheet`, the `empCode` parameter records which teacher owns the sheet. The `SheetsByFaculty` query `CALL acad_GetResultSheetsByFaculty(1, @fax, ...)` uses this `empCode` to filter sheets.

The `FacultyExamResults.ascx` UI, however, **does not enforce this linkage during mark entry**. A teacher filters the view manually using 9 cascading dropdowns (Campus → Programme → Entry Year → Session → Study Year → Intake → Semester → Course → Status). There is **no server-side check** that the currently logged-in teacher is actually the assigned lecturer for the selected course. Any authenticated user with access to the faculty results page can enter or edit marks for any course.

### Problems Identified

| # | Problem | Severity |
|---|---|---|
| P1 | No assignment enforcement: any faculty member can enter marks for any course | **Critical** |
| P2 | Teacher must manually select 9+ filter fields in the correct order; no auto-filtering by login | **High** |
| P3 | `empCode` stored in `acad_examsettings` is only populated at sheet-creation time; if a different teacher takes over, no reassignment workflow exists | **Medium** |
| P4 | No `hrm_employee`/`hrm_timetable` linkage — the system does not consult a timetable or teaching assignment table to verify course ownership | **High** |
| P5 | The `dsCourses` dropdown shows all courses in the programme regardless of teacher assignment | **Medium** |

### Recommendations

- **R2.1** Create or reference a **teaching assignments table** (e.g., `acad_teaching_assignments`: `teacher_username`, `course_id`, `progid`, `acadyear`, `semester`) and enforce it during mark entry.
- **R2.2** On login to the new interface, auto-populate the teacher's assigned courses — no manual course selection required.
- **R2.3** Add a Dean/HOD workflow to assign/reassign teacher–course pairs per academic year/semester.
- **R2.4** Display a clear "My Courses This Semester" dashboard as the default landing view.

---

## 3. Student → Course Linkage (Current State)

### How It Currently Works

Students are linked to courses via **`acad_programmecourses`** (programme → course mapping) combined with **`acad_registration`** (student registered for current semester). When `acad_CreateFacultyExamSheet` is called, the stored procedure joins these tables to populate `acad_examresults_faculty` with all registered students for the given cohort (programme + study year + semester + session + intake + campus + academic year).

The cohort definition requires **all 8 parameters** to match exactly. Students who are registered without an exact match on any one field (e.g., wrong intake month stored) will be silently excluded from the marksheet.

### Problems Identified

| # | Problem | Severity |
|---|---|---|
| P6 | Silent exclusion — students missing from marksheet due to a parameter mismatch are never flagged | **High** |
| P7 | Late-registering students must have the sheet manually refreshed; no automatic inclusion | **Medium** |
| P8 | Course re-registration (retake/supplementary) students appear in the same marksheet as regular students, making the view cluttered | **Medium** |
| P9 | No visual indicator when a student's registration status changes after sheet creation | **Low** |
| P10 | The system counts `acad_registration` rows but does not verify `acad_course_registration` (actual course-level registration) | **Medium** |

### Recommendations

- **R3.1** After sheet creation, show a reconciliation report: students in registration but not in sheet (missed) and students in sheet but no longer registered (dropped).
- **R3.2** Add a one-click "Sync Sheet" button that adds late-registering students and flags dropped students without deleting their existing marks.
- **R3.3** Separate regular vs retake/supplementary students into labelled tabs within the same marksheet view.
- **R3.4** Show each student's registration date and course-registration confirmation status inline in the marksheet.

---

## 4. Marks Entry Workflow (Current State)

### How It Currently Works

**Two parallel entry systems exist:**

#### System A — Faculty Results (FacultyExamResults.ascx)
1. Teacher selects 9 cascading filters.
2. Teacher clicks "Refresh Marksheet" → `acad_CreateFacultyExamSheet` populates/refreshes `acad_examresults_faculty`.
3. Mark ratios are loaded via three separate scalar DB calls (one per ratio: CW, Test, Exam).
4. Teacher edits rows inline in a DevExpress grid — one row at a time (edit → save).
5. On save (`gvMarksheet_RowUpdating`):
   - The three ratios are fetched **again** (3 more DB round-trips per save).
   - Weighted marks computed: `cw_mark = round(cw_mark_entered × cw_ratio / 100)`.
   - `total_mark = cw_mark + test_mark + ex_mark`.
   - Total capped at 100 — error thrown if exceeded.
   - `approved_by` defaults to `'-'` (provisional state).
6. Dean selects rows and clicks "Approve" → `acad_CaptureFacultyResults` writes to `acad_results`.

#### System B — Electronic Sheets (ElectronicSheets.ascx → MarksheetDetails.ascx)
1. Sheet created/managed via `acad_examsettings` (Q1–Q10 format, configurable per sheet).
2. Sheet lifecycle: `NEW` → `SUBMITTED` → `APPROVED` → `CAPTURED`.
3. Mark entry is per-question (Q1–Q10), with exam%, CW%, and practicals%.
4. Dean approval calls `acad_CaptureResults` (via `ResultsBLL`) — writes to `acad_results`.

### Problems Identified

| # | Problem | Severity |
|---|---|---|
| P11 | No real-time calculation: teacher only sees weighted marks after saving each row | **High** |
| P12 | 3 additional scalar DB calls per save for ratios that never change during a session | **High** |
| P13 | Inline-edit one row at a time — bulk entry is tedious for large classes (50–100 students) | **High** |
| P14 | No Excel import — teachers must type all marks individually even when they have a physical gradebook | **High** |
| P15 | No validation of component-level maxima (CW entered mark could be > 100 with no warning until save) | **Medium** |
| P16 | No partial-save: if browser closes or session times out, all unsaved changes are lost | **High** |
| P17 | Grade not shown until after the Dean approves — teacher has no preview of projected grade | **Medium** |
| P18 | Two parallel entry systems (FacultyExamResults + ElectronicSheets) with no clear boundary; teachers may be confused about which one to use | **High** |
| P19 | No confirmation or summary before submitting for Dean review | **Medium** |
| P20 | Session variables used to pass data between controls is fragile (pop-up navigation loses context) | **Medium** |

### Recommendations

- **R4.1** Replace inline-edit grid with a **full-page editable table** where the teacher enters all CW/Test/Exam marks for all students at once, with **live JavaScript calculations** showing weighted marks and projected grades as typing occurs — no postback required.
- **R4.2** Cache mark ratios in `ViewState` or `Session` at sheet-load time; do not re-query per save.
- **R4.3** Add **auto-save** (every 2 minutes, AJAX POST) and a "Last saved" timestamp visible to the teacher.
- **R4.4** Add **Excel/CSV import** with column mapping wizard (Match "Student ID" column → regno, "CW" → cw_mark_entered, etc.).
- **R4.5** Show live grade preview calculated in JavaScript using the configured grading system boundaries.
- **R4.6** Add component-level validation: enforce that `cw_mark_entered ≤ max_cw` (where max_cw = 100 in CW-only component) with instant on-change feedback.
- **R4.7** Add a "Submit for Review" step with a summary page showing: student count, marks entered count, missing count, average mark, distribution chart.

---

## 5. Provisional vs Published Marks (Current State)

### How It Currently Works

There are effectively **three states**, but they are split across two systems and are not clearly labelled in the UI:

| State | Indicator | Location |
|---|---|---|
| **Draft / Provisional** | `approved_by = '-'` in `acad_examresults_faculty` | Faculty-entered, not yet reviewed |
| **Approved** | `approved_by = <dean_username>` in `acad_examresults_faculty` | Dean has approved the faculty row |
| **Published/Captured** | Row exists in `acad_results` | Final result visible to students |

Sheet-level status in `acad_examsettings` adds another layer: `NEW → SUBMITTED → APPROVED → CAPTURED`.

### Problems Identified

| # | Problem | Severity |
|---|---|---|
| P21 | The two-system split (acad_examresults_faculty vs acad_results) is invisible to teachers — they cannot tell which state their students are in | **High** |
| P22 | `approved_by = '-'` is not a proper null/boolean; it is a string sentinel that could break if the column type or default changes | **Medium** |
| P23 | Students can see results in the Portal once in `acad_results`, but there is no staged "provisionally released" status where students can see tentative marks before finalization | **Medium** |
| P24 | Dean can partially approve (some rows approved, others not) with no dashboard showing completion percentage | **Medium** |
| P25 | No notification to teacher when their marks are approved or rejected | **High** |
| P26 | Sheet status in `acad_examsettings` and row-level approval status in `acad_examresults_faculty` are maintained separately with no automatic synchronization | **Medium** |

### Recommendations

- **R5.1** Define a clear, single status enum with 5 states:
  ```
  DRAFT → SUBMITTED → DEAN_APPROVED → PROVISIONAL_PUBLISHED → FINAL_PUBLISHED
  ```
  Store this at **both row-level and sheet-level** with the sheet-level derived automatically.
- **R5.2** Add a **status badge** prominently displayed at the top of the marksheet (e.g., "Status: SUBMITTED — Awaiting Dean Review") with timestamp and actor.
- **R5.3** Add email/system notifications:
  - Teacher submits → Dean gets notified.
  - Dean approves/rejects → Teacher gets notified with comments.
- **R5.4** Implement a "Provisional Release" step: marks can be visible to students as "provisional" (flagged clearly) before the Dean finalises, allowing students to raise concerns early.

---

## 6. Locking Mechanism (Current State)

### How It Currently Works

**Three independent locking mechanisms exist:**

1. **Global deadline lock** (`acad_results_lock`):  
   SQL: `SELECT COUNT(*) FROM acad_results_lock WHERE lock_type='RESULTS_DEADLINE' AND is_active=1 AND CURDATE() > deadline_date`  
   Applied to: sheet creation, row update, approve, cancel-approve.  
   One global date blocks the entire institution.

2. **Row-level approved lock** (`approved_by ≠ '-'`):  
   Once Dean approves a row, `gvMarksheet_RowUpdating` throws an exception if a teacher tries to edit it.

3. **Programme security level** (`acad_results_securitylevel.securitylevel`):  
   Toggle between 1 and 2 per programme/semester/year.  
   Purpose is not clearly documented — appears to be a manual fine-grained lock.

4. **Campus deadlines** (`acad_deadlines`):  
   Stores activity deadlines per campus/semester/year. **Not currently connected to the locking logic in FacultyExamResults** — this table exists in the XSD but `IsResultsLocked()` queries `acad_results_lock` instead.

### Problems Identified

| # | Problem | Severity |
|---|---|---|
| P27 | One global lock date covers all programmes, all campuses — no granularity by programme, faculty, or campus | **High** |
| P28 | `acad_deadlines` table is never consulted by `IsResultsLocked()` — it is effectively orphaned | **High** |
| P29 | No warning given to teachers as the deadline approaches (e.g., "Deadline in 3 days") | **Medium** |
| P30 | The security-level toggle (1/2) is undocumented — it toggles silently with no UI confirmation or audit | **Low** |
| P31 | Locks apply per server date (`CURDATE()`) but no timezone handling — could cause off-by-one day for international sessions | **Low** |
| P32 | Once `is_active=1` for the global lock, there is no UI to check who activated it or when | **Medium** |
| P33 | No CW-specific lock separate from exam-mark lock — CW marks close earlier than exam marks in practice | **High** |

### Recommendations

- **R6.1** Consolidate locking into a **unified deadline engine** backed by `acad_deadlines` (already has campus, semester, study session, academic year granularity). Deprecate `acad_results_lock`.
- **R6.2** Add **three separate configurable deadlines per course/programme/semester**:
  - `COURSEWORK_DEADLINE` — locks CW mark entry
  - `EXAM_DEADLINE` — locks exam mark entry
  - `SHEET_SUBMISSION_DEADLINE` — locks sheet submission to Dean
- **R6.3** Show a **countdown banner** on the marksheet: "CW marks lock in 5 days (April 12, 2026)".
- **R6.4** Send automated email/notification at: 7 days before, 3 days before, 24 hours before, and at lock.
- **R6.5** Implement **unlock request workflow**: teacher requests unlock, Dean/Registrar approves with reason, unlock is time-limited (e.g., 24 hours), and the entire exchange is audited.

---

## 7. Historical Marks Access (Current State)

### How It Currently Works

Historical marks are accessible by simply changing the `txtAcadYear` filter dropdown and re-running the sheet query. The `acad_GetFacultyExamSheet` and `acad_GetSemesterResults` procedures accept academic year and semester as parameters, so any past year can be loaded.

However, in practice:
- The teacher must manually set **all 9 filter fields** to an exact historical configuration.
- There is no "browse previous terms" shortcut or navigation aid.
- The system does not warn whether a historical sheet is locked or not.
- Editing old data is permitted if the global lock (`acad_results_lock`) is not active — there is no "this record is from a past academic year and should be read-only" safeguard.

### Problems Identified

| # | Problem | Severity |
|---|---|---|
| P34 | No UI protection against accidentally editing marks from a completed/graduated cohort | **Critical** |
| P35 | No "view-only" mode for historical sheets — they open in edit mode by default | **High** |
| P36 | No easy navigation: teacher must remember the exact academic year, intake, session, etc. of a past cohort | **Medium** |
| P37 | No visual differentiation between current-term and historical sheets in the sheet browser | **Medium** |
| P38 | Edits to historical records produce no alert or elevated-privilege check | **High** |

### Recommendations

- **R7.1** Implement **automatic read-only mode** for any sheet from a completed academic year (where the year has been closed/archived in `acad_acadyears`).
- **R7.2** Add a clear **"Historical / Archived" badge** for past-year sheets with a visual colour distinction (greyed out).
- **R7.3** Provide a **"My Sheets History" timeline view** on the teacher dashboard — list all sheets a teacher has owned ordered by academic year, with a direct click-to-open link.
- **R7.4** Any edit to a sheet from a prior academic year must trigger an elevated **Dean + Registrar dual approval** workflow with mandatory reason field.
- **R7.5** Add a dedicated "Past Results Search" with student-name or registration-number search across all years — useful for transcript corrections.

---

## 8. Audit & Change Tracking (Current State)

### What Exists

Two audit mechanisms run in parallel:

#### Legacy: `acad_activity_log`
- Free-text string: `"Student: MRU001 Course: ACC101 Academic Year: 2024/25 Semester: 1 Old CW: 30 New CW: 35 IP: 192.168.x.x"`
- Cannot be queried structurally (no typed columns for before/after values)
- Inserted by `sec_log.Insert()` in `gvMarksheet_RowUpdated`

#### Modern: `acad_marks_audit` (new — MarksAuditLogger.cs)
Structured table with:
- `action_type` (UPDATE / DELETE / APPROVE / UNAPPROVE)
- `performed_by`, `ip_address`
- `target_table`, `target_id`
- `regno`, `course_id`, `acad_year`, `semester`, `progid`
- `field_changed`, `old_value`, `new_value`
- `old_cw_mark`, `new_cw_mark`, `old_test_mark`, `new_test_mark`, `old_exam_mark`, `new_exam_mark`
- `old_total`, `new_total`, `old_grade`, `new_grade`
- `old_approved_by`, `new_approved_by`
- `change_reason`, `source_page`, `batch_id`

### What Is Missing

| # | Gap | Severity |
|---|---|---|
| P39 | **INSERT events** are not logged to `acad_marks_audit` — initial sheet creation and student row creation are invisible | **High** |
| P40 | `change_reason` field exists but is never populated from the UI — teacher cannot explain why a change was made | **High** |
| P41 | No dedicated **Audit Trail viewer UI** in the admin interface — data exists in DB but is not displayed anywhere | **High** |
| P42 | `acad_results_securitylevel` toggle (1↔2) is never logged to either audit table | **Medium** |
| P43 | Post-approval `acad_resultsupdates` changes are tracked in their own table but not correlated with `acad_marks_audit` via a shared `batch_id` | **Medium** |
| P44 | Audit records are never purged or archived — long-term table growth is unbounded | **Low** |
| P45 | No per-student audit timeline view — difficult to reconstruct the full history of a student's mark for an appeal | **High** |

### Recommendations

- **R8.1** Log **INSERT** events when rows are first created/sheet is populated — include who created the sheet and the initial values.
- **R8.2** Add a **mandatory reason dialog** whenever a teacher updates marks after a sheet has been submitted (state: SUBMITTED or higher). Reason is stored in `change_reason` field.
- **R8.3** Build a **"Mark Change History" panel** on the new marksheet page — show a timeline of all changes to a selected student's marks inline (who changed what, when, reason).
- **R8.4** Build an **"Audit Centre"** admin page filterable by: date range, teacher, course, academic year, action type, student — showing `acad_marks_audit` in a searchable paginated grid.
- **R8.5** Add audit coverage to security-level toggles.
- **R8.6** Implement quarterly archival of `acad_marks_audit` records older than 3 years to a cold storage table.

---

## 9. UI/UX Assessment (Current State)

### Current Interface (FacultyExamResults.ascx) Analysis

```
┌──────────────────────────────────────────────────────────────────┐
│  [Campus▼] [Year▼] [AcadYear▼] [Intake▼] [Programme▼]          │
│  [Session▼] [Course▼] [StudyYear▼] [Status▼] [Semester▼]        │
│  CW Ratio: [___] Exam Ratio: [___] Test Ratio: [___]             │
│  [Refresh Marksheet] [Approve] [Cancel Approve] [Print]          │
├──────────────────────────────────────────────────────────────────┤
│  □ | Regina | MRU001 | CW_ent | Test_ent | Exam_ent | Total | Gr│
│  □ | John   | MRU002 | [  ]   | [   ]    | [    ]   |       |   │
│  ... 50–100 more rows, one-at-a-time inline edit                │
└──────────────────────────────────────────────────────────────────┘
```

**Identified UX problems:**

| # | Problem | Impact |
|---|---|---|
| P46 | **9–10 required filters** with no default values tied to the teacher's assignment; wrong selection silently shows wrong data | Severe friction |
| P47 | **No onboarding/guidance** — new teacher has no idea what sequence to follow | High confusion risk |
| P48 | **One-row-at-a-time grid editing** is extremely slow for classes of 40–100 students | Productivity loss |
| P49 | **No class-size indicator** — teacher does not know how many students should be in the sheet | Reliability concern |
| P50 | **Error messages appear in a modal popup** (`pop_msgBox`) with no sticky visibility — missed easily | Important feedback lost |
| P51 | **Loading indicator** (`lp_loading.Show()`) blocks the page but gives no time estimate | Perceived slowness |
| P52 | **Dark "confirm" dialogs** with browser-default styling — inconsistent with DevExpress theme | Visual inconsistency |
| P53 | **Print buttons** open a separate popup iframe loading XtraReports — fails silently if session expires | Broken workflow |
| P54 | **Popup-within-popup** for MarksheetDetails creates Z-index and focus issues | UI clash |
| P55 | No **keyboard shortcuts** for moving between cells (Tab to next student) | Slow entry |
| P56 | **Mobile unusable** — the 10+ column grid with 9 filter combos does not fit small screens | Accessibility gap |
| P57 | The **"Refresh Marksheet" button** is the trigger for both creating and refreshing — no visual distinction | User error risk |

---

## 10. Performance Assessment (Current State)

### Identified Bottlenecks

| # | Issue | Estimated DB Trips Per Save |
|---|---|---|
| P58 | Three separate ratio scalar queries (`GetCourseWorkRatio`, `GetTestRatio`, `GetExamRatio`) called on every `RowUpdating` event | +3 per row save |
| P59 | The same three ratios are also queried in `cmddisplayratios_Click` (display) AND again in `RowUpdating` — no caching | Redundant |
| P60 | `gvMarksheet.DataBind()` called after every approval loop iteration — should be called once after the loop | N×DataBind per batch |
| P61 | No server-side paging on the faculty marksheet grid — large classes (100+ students) load all rows at once | Full table scan |
| P62 | `acad_CreateFacultyExamSheet` stored procedure runs a join with 8 parameters on every "Refresh" click; no built-in idempotency guard in the UI | Duplicate rows risk |
| P63 | Session variables heavily used for cross-control communication (e.g., `Session["mid"]`, `Session["csid"]`, etc.) — race conditions possible | Data integrity risk |
| P64 | Four different connection string names (`vacConnectionString`, `hoteldynamicsConnectionString`, `schoolMISConnectionString`, `campus_dynamics_portalConnectionString`) are used for what is functionally the same pair of databases — no connection pooling consolidation | Config confusion |

### Recommendations

- **R10.1** Cache mark ratios in `ViewState` on page load — never re-query per row save.
- **R10.2** Move `gvMarksheet.DataBind()` after approval/rejection loops, not inside them.
- **R10.3** Implement server-side paging (DevExpress `CallbackPageSize`) for large sheets.
- **R10.4** Add an idempotency check in `acad_CreateFacultyExamSheet` (already-created rows should not be duplicated).
- **R10.5** Consolidate redundant connection string aliases to two: one for portal DB, one for academic DB.
- **R10.6** Use AJAX callbacks (DevExpress `PerformCallback`) for mark saves instead of full postbacks.

---

## 11. Security Assessment (Current State)

### Identified Security Issues

| # | Issue | Risk |
|---|---|---|
| P65 | **No per-teacher course assignment enforcement** — any authenticated faculty member can modify any course's marks | Data integrity / academic fraud |
| P66 | `cmdApprove` is hidden for non-Dean roles but the server-side `cmdApprove_Click` handler only checks `IsInRole("Dean")` after the postback — client-side button hiding is not a security boundary | Privilege escalation possible |
| P67 | `gvMarksheet_RowUpdating` checks `approved_by != "-"` to block re-editing; this relies on the DevExpress grid passing `OldValues` correctly — if view state is tampered with, the check could be bypassed | Tampering risk |
| P68 | **No CSRF tokens** on the marks entry forms — a malicious request from an authenticated session could submit marks | CSRF risk |
| P69 | `txtAltCourseID` (alternate course ID) in MarksheetDetails is user-editable with no validation — a teacher could redirect approved results to a different course ID | Data poisoning |
| P70 | String concatenation used in legacy `acad_activity_log.Insert()` call — risk of log injection if student-supplied values contain special characters | Log injection |
| P71 | The `cmdForgot_Click` fallback in `lg.ascx.cs` uses string concatenation for SQL — historical code, but sets a bad precedent | SQL injection risk (legacy) |
| P72 | IP address logged via `Request.ServerVariables["HTTP_X_FORWARDED_FOR"]` without validation — can be spoofed by client | Spoofed audit trail |
| P73 | Session variables like `Session["otp"]` and `Session["usertype"]` used for security decisions — session fixation could elevate privileges | Session security |

### Recommendations

- **R11.1** Implement **server-side course assignment enforcement**: before processing any mark entry, verify `acad_teaching_assignments` contains a row for `(current_user, course_id, progid, acadyear, semester)`.
- **R11.2** Move all role checks to the start of every server-side event handler, before any data access.
- **R11.3** Add **AntiForgeryToken** validation on all mark-entry forms.
- **R11.4** Validate and sanitize `txtAltCourseID` against a known list of valid course codes.
- **R11.5** Replace string-concatenation activity-log messages with parameterized structured logging.
- **R11.6** Validate `X-Forwarded-For` header — accept only the first valid IPv4 address; discard malformed values.

---

## 12. Gap Summary — Classic vs Needed

| Feature | Classic Version | Gap |
|---|---|---|
| Teacher sees only their assigned courses | ✗ All courses visible | Missing assignment enforcement |
| Live calculation while typing | ✗ Only on save | Needs JS real-time calc |
| Bulk mark entry (all students at once) | ✗ One row at a time | Needs full-table edit mode |
| Excel import | ✗ None | Feature missing |
| Auto-save | ✗ None | Feature missing |
| CW deadline separate from exam deadline | ✗ One global lock | Needs granular deadlines |
| Deadline countdown | ✗ None | Feature missing |
| Student count validation (expected vs entered) | ✗ None | Feature missing |
| Mandatory reason for mark changes | ✗ None | Feature missing |
| Audit trail viewer UI | ✗ Data in DB, no viewer | Needs new admin page |
| Per-student mark history panel | ✗ None | Feature missing |
| INSERT events audited | ✗ Only updates/deletes | Gap in MarksAuditLogger |
| Unlock request workflow | ✗ None | Feature missing |
| Provisional release to students | ✗ None | Feature missing |
| Dean approval progress dashboard | ✗ None | Feature missing |
| Teacher notification on approval/rejection | ✗ None | Feature missing |
| Mobile-responsive interface | ✗ None | Feature missing |
| Historical sheet read-only auto-protection | ✗ None | Security gap |
| Teaching assignment management UI | ✗ None | Feature missing |
| Student reconciliation report | ✗ None | Feature missing |

---

## 13. Proposed New Interface — Design Specification

### 13.1 Architecture Overview

```
Classic (Preserved)                  Modern (New — Additive)
─────────────────────────            ────────────────────────────────────
FacultyExamResults.ascx              /Faculty/Marks/Dashboard.aspx
ElectronicSheets.ascx                /Faculty/Marks/MarkEntry.aspx
MarksheetDetails.ascx                /Faculty/Marks/SheetReview.aspx
ResultsUpdates.ascx                  /Faculty/Marks/ChangeRequest.aspx
                                     /Admin/Marks/AuditCentre.aspx
                                     /Admin/Marks/DeadlineManager.aspx
                                     /Admin/Marks/AssignmentManager.aspx
                                     /Dean/Marks/ApprovalDashboard.aspx
```

A "Switch to Modern Interface" link is added to the classic pages (just as MyApplications_Modern.aspx is linked from the classic dashboard). The classic pages receive no functional changes.

---

### 13.2 Teacher Dashboard (Dashboard.aspx)

```
┌─────────────────────────────────────────────────────────────┐
│  👋 Welcome, Dr. Muhindo   |  2025/2026 Semester 2          │
├─────────────────────────────────────────────────────────────┤
│  MY COURSES THIS SEMESTER                                    │
│  ┌─────────────────┬───────┬───────────┬───────────────────┐│
│  │ Course          │ Year  │ Students  │ Status            ││
│  │ ACC101 Finance  │  Y2   │  45/47 ✓  │ 🟡 SUBMITTED      ││
│  │ ACC203 Auditing │  Y3   │  38/38 ✓  │ 🔴 DRAFT (CW due) ││
│  │ BBA301 Strategy │  Y3   │  0/51  ✗  │ ⚪ NOT STARTED    ││
│  └─────────────────┴───────┴───────────┴───────────────────┘│
│  ⚠️  CW MARKS DEADLINE: April 12, 2026 (5 days)             │
└─────────────────────────────────────────────────────────────┘
```

**Implementation notes:**
- Data source: `acad_teaching_assignments` JOIN `acad_examresults_faculty` aggregate.
- Status colours: ⚪ Not started, 🔵 Draft, 🟡 Submitted, 🟢 Approved, 🔒 Locked.
- "45/47" = rows with non-null marks / total rows in sheet.
- Deadline banner auto-calculated from `acad_deadlines` for current campus/year/semester.

---

### 13.3 Mark Entry Page (MarkEntry.aspx)

**URL:** `/Faculty/Marks/MarkEntry.aspx?settingsId=12345`

**Layout:**

```
┌─ ACC101 Financial Accounting — Year 2, Sem 2, 2025/26 ─────────────────┐
│  Status: 🔵 DRAFT    |  CW Ratio: 40%  Test: 20%  Exam: 40%           │
│  Students Expected: 47   Marks Entered: 45/47   Missing: 2            │
│  CW Deadline: April 12, 2026 (5 days)  | Auto-saved: 2 min ago        │
├────────────────────────────────────────────────────────────────────────┤
│  [Import Excel] [Download Template] [Bulk Clear] [Submit for Review ▶] │
├──────┬────────────────┬────────┬────────┬────────┬───────┬────────────┤
│ #    │ Student        │ CW /70 │ Test/30│ Exam/70│ Total │ Grade      │
├──────┼────────────────┼────────┼────────┼────────┼───────┼────────────┤
│  1   │ MRU001 Aisha   │ [65]   │ [22 ]  │ [55 ]  │  100  │  A  (calc) │
│  2   │ MRU002 Peter   │ [48]   │ [18 ]  │ [  ]   │  --   │  --        │
│  3   │ MRU003 Grace   │ ⚠ [105]│ [  ]   │ [  ]   │  --   │ ▲ Exceeds  │
│  ... │                │        │        │        │       │            │
├──────┴────────────────┴────────┴────────┴────────┴───────┴────────────┤
│ Keyboard: Tab = next cell | Ctrl+S = save | Enter = next row           │
└────────────────────────────────────────────────────────────────────────┘
```

**Key behaviours:**
- **Real-time calculation**: JavaScript computes `cw_weighted = cw_entered × 40/100`, etc., and updates Total and Grade preview on each keystroke — no postback.
- **Grade preview**: Compare `total` against `acad_gs_details` ranges preloaded as a JSON array in the page.
- **Inline validation**: Red highlight if value > component maximum; soft warning if grade drops a student below pass threshold.
- **Keyboard navigation**: Tab moves right across CW→Test→Exam, then down to next student. Enter confirms and moves to next row.
- **Auto-save**: AJAX POST every 2 minutes; saves only changed rows (dirty-tracking by row index). Timestamp shown.
- **Missing mark indicator**: Rows with no marks shown with a subtle orange left border.
- **Import Excel**: Upload `.xlsx` with two columns (Student ID, Mark). Column mapping shown in a preview modal. Imports into the correct component (CW, Test, or Exam) based on a selector.

---

### 13.4 Submission Workflow

```
Teacher clicks "Submit for Review"
         │
         ▼
┌─ Submission Summary ─────────────────────────┐
│  Course: ACC101  Semester 2  2025/26         │
│  Total Students: 47                          │
│  Marks Entered: 45  |  Missing: 2 (MRU009, MRU033)│
│  Average Mark: 64.2  |  Pass Rate: 89%      │
│                                              │
│  Mark Distribution:                          │
│  A: ██████  15  B: ██████████  22  C: ████ 8 │
│  Missing: 2                                  │
│                                              │
│  Note: Missing marks will appear as 0        │
│  ☐ I confirm all marks are correct           │
│                                              │
│  [Cancel]              [Submit for Review ▶] │
└──────────────────────────────────────────────┘
```

On submit:
1. Sheet status → `SUBMITTED`.
2. All rows with `approved_by = '-'` remain editable only until Dean accepts.
3. Dean receives notification: "Dr. Muhindo has submitted ACC101 (Y2 Sem2) for review — 45 students."

---

### 13.5 Dean Approval Dashboard (ApprovalDashboard.aspx)

```
┌─ Pending Approvals — 2025/2026 Semester 2 ─────────────────────────────┐
│  Filters: [Faculty: All ▼] [Programme: All ▼] [Search _______________] │
├────────────────────┬───────┬────────┬──────────┬────────────────────────┤
│ Course             │ Yr    │ Teacher│ Students │ Actions                │
├────────────────────┼───────┼────────┼──────────┼────────────────────────┤
│ ACC101 Finance     │ Y2 S2 │ Muhindo│ 45/47    │ [Review] [Approve All] │
│ BBA201 Management  │ Y2 S2 │ Agaba  │ 38/38    │ [Review] [Approve All] │
│ CS301 Networks     │ Y3 S2 │ Kato   │ 51/51    │ [Review] [Approve All] │
└────────────────────┴───────┴────────┴──────────┴────────────────────────┘
│  Approved this week: 12 sheets   |  Pending: 7 sheets                  │
└────────────────────────────────────────────────────────────────────────┘
```

**Sheet Review Popup:**
- Shows all student rows with CW/Test/Exam marks.
- Dean can approve individual rows or "Approve All."
- Dean can **reject** a row with a comment — teacher is notified and the row returns to DRAFT.
- Batch ID generated for each Dean approval session (linked in audit log).

---

### 13.6 Lock / Deadline Manager (DeadlineManager.aspx)

```
┌─ Deadline Management — 2025/2026 Semester 2 ──────────────────────┐
│  Campus: Main    [Add Deadline]                                    │
├────────────────────┬──────────────┬────────────┬──────────────────┤
│ Activity           │ Deadline     │ Study Sys  │ Actions          │
├────────────────────┼──────────────┼────────────┼──────────────────┤
│ Coursework Entry   │ Apr 12, 2026 │ Day        │ [Edit] [Delete]  │
│ Exam Marks Entry   │ May 20, 2026 │ Day        │ [Edit] [Delete]  │
│ Sheet Submission   │ May 25, 2026 │ Day        │ [Edit] [Delete]  │
└────────────────────┴──────────────┴────────────┴──────────────────┘
│  Unlock Requests                                                   │
│  • Dr. Muhindo — ACC101 CW Lock — Reason: "Student makeup exam"    │
│  [Approve 24h Unlock] [Reject]                                     │
└────────────────────────────────────────────────────────────────────┘
```

---

### 13.7 Audit Centre (AuditCentre.aspx)

A new admin screen backed by `acad_marks_audit`:

```
┌─ Mark Change Audit Centre ────────────────────────────────────────┐
│  Date: [2026-01-01] – [2026-04-07]   User: [All ▼]               │
│  Course: [___]   Student: [___]   Action: [All ▼]   [Search]     │
├──────────┬─────────┬────────┬────────┬─────────────────┬─────────┤
│ DateTime │ User    │ Action │ Course │ Change Summary   │ Reason  │
├──────────┼─────────┼────────┼────────┼─────────────────┼─────────┤
│ Apr6 14:30│ muhindo│ UPDATE │ ACC101 │ CW:60→65, Total:│ Makeup  │
│ Apr5 09:10│ agaba  │ DELETE │ BBA201 │ MRU033 row del  │ -       │
│ Apr4 10:00│ DEAN   │ APPROVE│ CS301  │ 51 rows approved│ Batch   │
└──────────┴─────────┴────────┴────────┴─────────────────┴─────────┘
│  [Export to Excel]  [Export to PDF]                               │
└────────────────────────────────────────────────────────────────────┘
```

Per-student drill-down shows a **timeline** of all mark changes sorted by timestamp.

---

### 13.8 Excel Import Specification

Template columns:
```
| Student ID | CW Mark | Test Mark | Exam Mark |
| MRU001     | 65      | 22        | 55        |
```

Processing rules:
1. Validate Student ID exists in sheet (`acad_examresults_faculty`).
2. Validate marks are numeric and within configured maxima.
3. Show preview table with colour-coded validation: green (OK), orange (warning), red (error).
4. Allow teacher to fix errors inline before confirming import.
5. Log import as a batch operation in `acad_marks_audit` with `action_type = 'IMPORT'` and `batch_id`.

---

## 14. Database Changes Required

### 14.1 New Table: `acad_teaching_assignments`

```sql
CREATE TABLE acad_teaching_assignments (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_username VARCHAR(50) NOT NULL,
    course_id        VARCHAR(25) NOT NULL,
    progid           VARCHAR(25) NOT NULL,
    acadyear         VARCHAR(25) NOT NULL,
    semester         TINYINT UNSIGNED NOT NULL,
    study_year       TINYINT UNSIGNED NOT NULL,
    campus_id        INT UNSIGNED NOT NULL,
    stud_session     VARCHAR(25) NOT NULL,
    assigned_by      VARCHAR(50) NOT NULL,
    assigned_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active        TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uq_assignment (teacher_username, course_id, progid, acadyear, semester, study_year, campus_id, stud_session),
    INDEX idx_teacher_year (teacher_username, acadyear, semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 14.2 New Table: `acad_mark_unlock_requests`

```sql
CREATE TABLE acad_mark_unlock_requests (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    requested_by    VARCHAR(50) NOT NULL,
    course_id        VARCHAR(25),
    progid           VARCHAR(25),
    acadyear         VARCHAR(25) NOT NULL,
    semester         TINYINT UNSIGNED NOT NULL,
    deadline_type    ENUM('COURSEWORK','EXAM','SUBMISSION') NOT NULL,
    reason           TEXT NOT NULL,
    status           ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    reviewed_by      VARCHAR(50),
    reviewed_at      DATETIME,
    expires_at       DATETIME,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 14.3 Alter `acad_marks_audit` — Add Missing Column

```sql
ALTER TABLE acad_marks_audit
    ADD COLUMN action_type_ext VARCHAR(20) AFTER action_type,
    ADD COLUMN old_cw_entered  INT AFTER old_cw_mark,
    ADD COLUMN new_cw_entered  INT AFTER old_cw_entered,
    ADD COLUMN old_test_entered INT AFTER old_test_mark,
    ADD COLUMN new_test_entered INT AFTER old_test_entered,
    ADD COLUMN old_exam_entered INT AFTER old_exam_mark,
    ADD COLUMN new_exam_entered INT AFTER old_exam_entered;
-- action_type_ext captures: 'IMPORT', 'BULK_APPROVE', 'AUTO_SAVE', etc.
```

### 14.4 Alter `acad_deadlines` — Add Deadline Type

```sql
ALTER TABLE acad_deadlines
    ADD COLUMN deadline_type ENUM('COURSEWORK','EXAM','SUBMISSION','OTHER') 
        NOT NULL DEFAULT 'OTHER' AFTER ActivityName,
    ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1;
```

### 14.5 Stored Procedures Required

| Procedure | Purpose |
|---|---|
| `acad_GetTeacherCourses(teacher, acadyear, semester)` | Returns assigned courses for teacher dashboard |
| `acad_GetMarkEntrySheet(settingsId)` | Returns full marksheet rows for new entry page |
| `acad_BulkSaveMarks(settingsId, jsonRows)` | Accepts a JSON array of mark rows, saves all in one transaction |
| `acad_GetActiveDeadlines(campusId, acadyear, semester, studySession)` | Returns active deadlines for a context |
| `acad_CheckDeadlineLock(deadlineType, campusId, acadyear, semester)` | Returns 1 if deadline has passed and lock is active |
| `acad_GetMarkAuditForStudent(regno, courseId, acadyear)` | Returns all audit entries for one student in one course |

---

## 15. Implementation Roadmap

### Phase 1 — Foundation (Weeks 1–2)

- [ ] Create `acad_teaching_assignments` table and seed with current data from `acad_examsettings.empCode`.
- [ ] Create `acad_mark_unlock_requests` table.
- [ ] Alter `acad_deadlines` with `deadline_type` and `is_active` columns.
- [ ] Write stored procedures: `acad_GetTeacherCourses`, `acad_GetActiveDeadlines`, `acad_CheckDeadlineLock`.
- [ ] Add `acad_GetMarkAuditForStudent` procedure.
- [ ] Extend `MarksAuditLogger.cs` to log INSERT events and IMPORT events.
- [ ] Update `MarksAuditLogger.Log()` to accept `old_cw_entered` / `new_cw_entered` raw fields.

### Phase 2 — Teacher Dashboard (Week 3)

- [ ] Create `/Faculty/Marks/Dashboard.aspx` with course list, status badges, deadline countdown.
- [ ] Create `AssignmentManager.aspx` for Dean/HOD to manage teacher assignments.
- [ ] Add "Switch to Modern Interface" link in `FacultyExamResults.ascx` header (no logic change).

### Phase 3 — Mark Entry Page (Weeks 4–5)

- [ ] Build `/Faculty/Marks/MarkEntry.aspx` with full-table edit mode.
- [ ] Implement JavaScript real-time calculation engine (grade boundaries as JSON from grading system).
- [ ] Implement auto-save via AJAX handler (`MarkSave.ashx`).
- [ ] Implement keyboard navigation (Tab/Enter).
- [ ] Implement Excel import with preview and validation.
- [ ] Implement submission workflow with summary page and confirmation.

### Phase 4 — Dean Approval Dashboard (Week 6)

- [ ] Build `/Dean/Marks/ApprovalDashboard.aspx`.
- [ ] Implement per-row and bulk approve/reject with comment.
- [ ] Add email/system notifications (reuse existing `EmailSenderProtocol`).

### Phase 5 — Locking & Deadlines (Week 7)

- [ ] Build `DeadlineManager.aspx`.
- [ ] Wire `acad_CheckDeadlineLock` into the new mark entry save handler.
- [ ] Implement unlock request workflow (submit → Dean review → time-limited token).
- [ ] Add deadline countdown banners.

### Phase 6 — Audit Centre (Week 8)

- [ ] Build `AuditCentre.aspx` with full filter grid over `acad_marks_audit`.
- [ ] Build per-student mark history timeline panel (embeddable in MarkEntry and Dean review).
- [ ] Add mandatory reason dialog for post-submission edits.

### Phase 7 — Hardening & Security (Week 9)

- [ ] Add server-side teaching assignment enforcement to MarkEntry save handler.
- [ ] Add AntiForgeryToken to all new forms.
- [ ] Validate and sanitize all course-code inputs.
- [ ] Consolidate connection string aliases.
- [ ] Performance: cache ratios in ViewState; server-side paging.

### Phase 8 — Mobile Responsiveness & Polish (Week 10)

- [ ] Apply responsive CSS grid for MarkEntry.aspx (collapses to vertical layout on mobile).
- [ ] Test on Chrome mobile, Safari iOS.
- [ ] User acceptance testing with 3–5 faculty members.
- [ ] Documentation and training materials.

---

## 16. Classic vs Modern Comparison Table

| Dimension | Classic (FacultyExamResults.ascx) | Modern (MarkEntry.aspx) |
|---|---|---|
| **Access method** | 9-field manual filter | One-click from "My Courses" dashboard |
| **Course authorization** | None enforced | Must be in `acad_teaching_assignments` |
| **Mark entry** | One row at a time, grid inline edit | All students simultaneously, keyboard-navigable table |
| **Calculation feedback** | After save (server-side) | Instant as-you-type (JavaScript) |
| **Grade preview** | Not shown | Real-time per row |
| **Auto-save** | None | Every 2 minutes, AJAX |
| **Excel import** | Not available | Yes, with validation preview |
| **Validation** | Total > 100 throws error | Component-level, inline, real-time |
| **CW deadline** | One global date covers everything | Separate per campus/semester/study-session/type |
| **Deadline countdown** | None | Banner with days remaining |
| **Unlock request** | Manual DBA intervention | Self-service workflow with Dean approval |
| **Submission step** | Implicit (Dean approves whatever is there) | Explicit "Submit for Review" with summary modal |
| **Dean approval UI** | Grid checkbox + Approve button | Dashboard with queue, per-sheet completion %, notes |
| **Teacher notification** | None | Email on approval/rejection |
| **Audit trail UI** | Not available | Audit Centre + per-student history panel |
| **Audit completeness** | UPDATE/DELETE/APPROVE only | Creates, updates, deletes, imports, approvals, unlocks |
| **Reason for change** | Never captured | Mandatory for post-submission edits |
| **Historical sheets** | Open in edit mode | Auto read-only for closed academic years |
| **Mobile support** | None | Responsive layout |
| **Security** | Role check post-postback only | Assignment-enforced + AntiForgery + input validation |
| **Performance** | 3 DB calls per row save | Ratios cached; single bulk-save call |
| **Student reconciliation** | None | Expected vs entered count + missing student list |

---

*End of document. The classic interface remains fully operational and unchanged. All new features described above are implemented as additive pages alongside the existing system.*
