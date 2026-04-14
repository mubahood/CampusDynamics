# Load Allocation Module — Implementation Task List

> **Module:** Load Allocation (New System Interface)  
> **Date Created:** 2026-04-10  
> **Scope:** Teaching allocations, timetable management, lecture rooms, workload analysis  
> **Location:** `COOPERP/NewScreens/` with `SidebarMaster.master` integration  
> **Owner:** Campus Dynamics — Mountains of the Moon University  

---

## Quick Status Overview

| # | Task | Priority | Status | Est. Effort |
|---|------|----------|--------|-------------|
| 1 | [Sidebar Menu — Add "Load Allocation" Section](#task-1-sidebar-menu--add-load-allocation-section) | 🔴 Critical | ✅ Complete | 30 min |
| 2 | [DB Schema — Add Audit Columns & Unique Constraints](#task-2-db-schema--add-audit-columns--unique-constraints) | 🔴 Critical | ✅ Complete | 1 hr |
| 3 | [DB Schema — Create `acad_timetable` VIEW for API](#task-3-db-schema--create-acad_timetable-view-for-api) | 🔴 Critical | ✅ Complete | 30 min |
| 4 | [Lecture Rooms Page — `LectureRooms.aspx`](#task-4-lecture-rooms-page--lectureroomsaspx) | 🟡 High | ✅ Complete | 3 hrs |
| 5 | [Teaching Allocations Page — `LoadAllocations.aspx`](#task-5-teaching-allocations-page--loadallocationsaspx) | 🔴 Critical | ✅ Complete | 8 hrs |
| 6 | [Timetable View Page — `TimetableView.aspx`](#task-6-timetable-view-page--timetableviewaspx) | 🟡 High | ✅ Complete | 6 hrs |
| 7 | [Workload Analysis Page — `WorkloadAnalysis.aspx`](#task-7-workload-analysis-page--workloadanalysisaspx) | 🟡 High | ✅ Complete | 5 hrs |
| 8 | [Load Allocation Dashboard — `LoadAllocationDashboard.aspx`](#task-8-load-allocation-dashboard--loadallocationdashboardaspx) | 🟠 Medium | ✅ Complete | 4 hrs |
| 9 | [Collision Detection Engine](#task-9-collision-detection-engine) | 🟡 High | ✅ Complete | 3 hrs |
| 10 | [Batch Operations — Adopt & Copy Allocations](#task-10-batch-operations--adopt--copy-allocations) | 🟠 Medium | ✅ Complete | 3 hrs |
| 11 | [Data Cleanup — Fix Existing Duplicate Allocations](#task-11-data-cleanup--fix-existing-duplicate-allocations) | 🟡 High | ✅ Complete | 2 hrs |
| 12 | [API Fix — Timetable & Academic Endpoints](#task-12-api-fix--timetable--academic-endpoints) | 🔴 Critical | ✅ Complete | 3 hrs |
| 13 | [Classic ↔ New Integration Testing](#task-13-classic--new-integration-testing) | 🔴 Critical | ⬜ Not Started | 3 hrs |
| 14 | [Comprehensive Testing & QA](#task-14-comprehensive-testing--qa) | 🔴 Critical | ⬜ Not Started | 4 hrs |

---

## Architecture Overview

### New Pages Under `COOPERP/NewScreens/`

```
LoadAllocationDashboard.aspx    — Summary stats, quick links, alerts
LoadAllocations.aspx            — Main CRUD for teaching allocations
TimetableView.aspx              — Visual weekly timetable grid
LectureRooms.aspx               — Room CRUD with capacity management
WorkloadAnalysis.aspx           — Lecturer workload overview
```

### Sidebar Menu Structure

```
Load Allocation  (heading — roles: dean, registrar, faculty_staff, admin)
├── Allocation Management  (submenu)
│   ├── Allocation Dashboard
│   ├── Teaching Allocations
│   └── Workload Analysis
├── Timetable  (submenu)
│   └── Timetable View
└── Settings  (submenu)
    └── Lecture Rooms
```

### Shared Patterns (Must Follow)

| Pattern | Source | Rule |
|---------|--------|------|
| Master page | `SidebarMaster.master` | All pages use `MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"` |
| CSS prefix | Design system | Use `la-` prefix for page-local styles (Load Allocation) |
| Connection | `vacConnectionString` | `ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString` — NO hardcoded credentials |
| Helpers | Inline per page | `ExecuteQuery(sql, params)` → `DataTable`, `ExecuteNonQuery(sql, params)` → `int`, `TrySelect(ddl, val)` |
| Grid | DevExpress `ASPxGridView` | FilterRow enabled, action popover column, custom callback paging |
| Modal | HTML overlay | `la-modal-overlay` > `la-modal` pattern (no DevExpress popups) |
| Toast | `showToast()` JS | Feedback via `ScriptManager.RegisterStartupScript` calling `showToast(msg, type)` |
| Postback | `EnableViewState="false"` | Reload-on-every-request pattern; restore posted dropdown values via `Request.Form[ddl.UniqueID]` |
| Header dropdowns | Master page | Use `Session["SelectedAcademicYear"]`, `Session["SelectedSemester"]`, `Session["SelectedCampus"]` from master |
| Page title | `SetPageTitle()` | Add `case` entries in `SidebarMaster.master.cs` for each new page |
| .NET version | 4.0 | NO `?.`, NO `$""`, use `String.Format()` and explicit null checks |
| DevExpress | v16.1 | Register assemblies as per existing pages |

### Database Tables — Core

| Table | Purpose | Action Needed |
|-------|---------|---------------|
| `acad_teaching_allocation` | Main allocation records | Add audit columns, unique constraint |
| `acad_lecturerooms` | Room definitions | No schema changes needed |
| `acad_course` | Course catalog | Read-only in this module |
| `acad_programme` | Programme list | Read-only in this module |
| `acad_programmecourses` | Programme-course links | Read-only (for course filtering) |
| `hrm_employee` | Lecturer details | Read-only (for lecturer dropdowns) |
| `hrm_emp_contracts` | Employment type | Read-only (for workload context) |
| `acad_campuses` | Campus list | Read-only |
| `acad_timetable_weekdays` | Days reference | Read-only |

---

## Task 1: Sidebar Menu — Add "Load Allocation" Section

**Priority:** 🔴 Critical  
**Status:** ✅ Complete  
**Estimated Effort:** 30 minutes  
**Dependencies:** None  

### Description

Add a new "Load Allocation" section to the sidebar navigation in `SidebarMaster.master`, positioned between the Academics/Examinations sections and the HR section. Also register all new page titles in `SetPageTitle()` within `SidebarMaster.master.cs`.

### Steps

1. **Edit `SidebarMaster.master`:**
   - Add a new heading `<li class="cd-sidebar__heading" data-roles="dean registrar faculty_staff admin">Load Allocation</li>`
   - Add 3 submenu groups:
     - **Allocation Management:** Dashboard, Teaching Allocations, Workload Analysis
     - **Timetable:** Timetable View
     - **Settings:** Lecture Rooms
   - Use SVG icons consistent with the existing sidebar style (Feather icons, 16px toggle / 14px submenu)
   - Each `<asp:HyperLink>` points to the respective `.aspx` file under `~/COOPERP/NewScreens/`
   - `data-roles="dean registrar faculty_staff admin"` on heading and all submenu items

2. **Edit `SidebarMaster.master.cs`:**
   - Add `case` entries in `SetPageTitle()` for:
     - `loadallocationdashboard` → "Allocation Dashboard"
     - `loadallocations` → "Teaching Allocations"
     - `timetableview` → "Timetable View"
     - `lecturerooms` → "Lecture Rooms"
     - `workloadanalysis` → "Workload Analysis"

### Expected Outcome

- New "Load Allocation" heading appears in the sidebar for users with roles: `dean`, `registrar`, `faculty_staff`, `admin`
- All 5 new menu links are visible and clickable (they'll 404 until pages are built)
- Page titles display correctly in the header breadcrumb

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Wrong insertion point breaks sidebar | Insert between Elections and System sections with proper comment block |
| Existing role-based filtering misses new section | Use same `data-roles` attribute pattern as other sections |
| Link IDs must be unique | Prefix all IDs with `lnkLA` (Load Allocation) |

---

## Task 2: DB Schema — Add Audit Columns & Unique Constraints

**Priority:** 🔴 Critical  
**Status:** ⬜ Not Started  
**Estimated Effort:** 1 hour  
**Dependencies:** None (can run before any pages are built)  

### Description

Enhance `acad_teaching_allocation` with audit tracking and duplicate prevention. This MUST be done before building the new pages so that all new records automatically get audit data.

### Steps

1. **Add audit columns to `acad_teaching_allocation`:**
   ```sql
   ALTER TABLE acad_teaching_allocation
       ADD COLUMN created_by VARCHAR(100) DEFAULT NULL,
       ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
       ADD COLUMN updated_by VARCHAR(100) DEFAULT NULL,
       ADD COLUMN updated_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP;
   ```

2. **Add unique constraint:**
   ```sql
   -- First, identify and resolve existing duplicates (see Task 11)
   -- Then add the constraint:
   ALTER TABLE acad_teaching_allocation
       ADD UNIQUE INDEX uq_allocation 
       (staffCode, courseID, progcode, acad_year, semester, cyear, EntryYear, stud_session, lectureday);
   ```
   > **Note:** `lectureday` is included because the same lecturer can teach the same course on multiple days. The unique combination ensures no exact duplicate rows.

3. **Add index for common queries:**
   ```sql
   ALTER TABLE acad_teaching_allocation
       ADD INDEX idx_lookup (acad_year, semester, progcode, campusId),
       ADD INDEX idx_staff (staffCode, acad_year, semester),
       ADD INDEX idx_room (roomNo, lectureday, acad_year, semester);
   ```

4. **Verify no data loss:** Run `SELECT COUNT(*) FROM acad_teaching_allocation` before and after each ALTER to confirm record count is unchanged.

### Expected Outcome

- Every new allocation records WHO created/modified it and WHEN
- Duplicate allocations are prevented at the database level
- Query performance improved via indexes

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Existing duplicates block UNIQUE constraint | Run Task 11 (data cleanup) first, OR use `IGNORE` to skip duplicates |
| ALTER on a 20K row table may lock | Run during low-traffic period; table is small enough for instant ALTER |
| Classic pages don't populate audit columns | `created_at` has default `CURRENT_TIMESTAMP`; `created_by` will be NULL for classic insertions (acceptable) |

---

## Task 3: DB Schema — Create `acad_timetable` VIEW for API

**Priority:** 🔴 Critical  
**Status:** ⬜ Not Started  
**Estimated Effort:** 30 minutes  
**Dependencies:** None  

### Description

The API `timetable.aspx` queries a non-existent `acad_timetable` table. Students and mobile apps get NO timetable data. Fix this by creating a VIEW over `acad_teaching_allocation` that matches the column names the API expects.

### Steps

1. **Read the API code** to identify expected column names:
   - Located at `API/v2/timetable.aspx.cs`
   - Identify the exact SELECT columns and WHERE clauses

2. **Create the VIEW:**
   ```sql
   CREATE OR REPLACE VIEW acad_timetable AS
   SELECT 
       ta.ID,
       ta.progcode AS programme_code,
       ta.courseID AS course_code,
       c.courseName AS course_name,
       ta.cyear AS study_year,
       CAST(ta.staffCode AS UNSIGNED) AS lecturer_id,
       e.emp_name AS lecturer_name,
       ta.lectureday AS day_of_week,
       ta.StartTime AS start_time,
       ta.EndTime AS end_time,
       ta.roomNo AS room_id,
       lr.RoomName AS room_name,
       ta.acad_year,
       ta.semester,
       ta.stud_session,
       ta.campusId,
       ta.EntryYear,
       ta.intake,
       ta.stream
   FROM acad_teaching_allocation ta
   LEFT JOIN acad_course c ON c.courseID = ta.courseID
   LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
   LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
   WHERE ta.lectureday != '-' 
     AND ta.lectureday IS NOT NULL
     AND ta.StartTime IS NOT NULL 
     AND ta.EndTime IS NOT NULL;
   ```

3. **Test the VIEW:**
   ```sql
   SELECT * FROM acad_timetable WHERE acad_year = '2025/2026' LIMIT 10;
   ```

4. **Verify API responds** — hit the timetable endpoint and confirm data returns

### Expected Outcome

- `acad_timetable` VIEW exists and returns scheduled allocations
- API `timetable.aspx` lectures endpoint returns real data
- Students and mobile apps can see their timetables
- No new table is created — VIEW reads live from `acad_teaching_allocation`

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| API expects columns we didn't map | Read the exact API code first; adjust VIEW aliases accordingly |
| VIEW performance with JOINs | Add indexes on join columns (covered in Task 2) |
| API may have additional filters we need to support | Test all API query parameters against the VIEW |

---

## Task 4: Lecture Rooms Page — `LectureRooms.aspx`

**Priority:** 🟡 High  
**Status:** ⬜ Not Started  
**Estimated Effort:** 3 hours  
**Dependencies:** Task 1 (menu must exist)  

### Description

Create a modern page to manage lecture rooms (`acad_lecturerooms` table). This is a prerequisite for the main allocation page because users need rooms to assign. Currently rooms can only be managed via the classic system.

### Steps

1. **Create `LectureRooms.aspx`:**
   - Page directive with `SidebarMaster.master`
   - `<asp:Content ID="HeadContent">` with `la-` prefixed CSS
   - Header: icon + "Lecture Rooms" title + "Add New Room" button
   - Stats cards: Total Rooms / Total Capacity / Rooms per Campus
   - DevExpress `ASPxGridView` with columns:
     - Room Name
     - Capacity (integer)
     - Campus (from `acad_campuses`)
     - Building (if column exists; add if not)
     - Status (Active/Inactive — add column if needed)
     - Actions (edit/delete popover)
   - FilterRow enabled for quick search
   - Modal form for Create/Edit with fields:
     - Room Name (text input)
     - Capacity (number input, min=1)
     - Campus (dropdown from `acad_campuses`)
   - Delete with confirmation (check if room is used in any allocation first)

2. **Create `LectureRooms.aspx.cs`:**
   - `ConnStr` property from `vacConnectionString`
   - `ExecuteQuery()` / `ExecuteNonQuery()` helpers
   - `BindGrid()`: `SELECT lr.*, c.campus_name FROM acad_lecturerooms lr LEFT JOIN acad_campuses c ON lr.campusId = c.ID ORDER BY lr.RoomName`
   - `LoadStats()`: Total rooms, total capacity, per-campus counts
   - `LoadCampuses()`: Populate campus dropdown
   - Create: `INSERT INTO acad_lecturerooms (RoomName, Capacity, campusId) VALUES (@name, @capacity, @campus)`
   - Update: `UPDATE acad_lecturerooms SET RoomName=@name, Capacity=@capacity, campusId=@campus WHERE RoomID=@id`
   - Delete: Check allocations first — `SELECT COUNT(*) FROM acad_teaching_allocation WHERE roomNo = @id` — block if in use
   - Hidden fields pattern: `hdnModalMode`, `hdnEditId`, triggered via hidden `Button`

3. **Register page title** in `SidebarMaster.master.cs` (done in Task 1)

### Expected Outcome

- Users can view all lecture rooms in a searchable grid
- Add, edit, delete rooms with modal form
- Stats dashboard shows room counts and capacity per campus
- Cannot delete a room that is assigned in any allocation
- Follows all design system patterns (CSS, modals, toasts)

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| `acad_lecturerooms` may have minimal columns | Check with DESCRIBE; add missing columns (building, status) via ALTER |
| Room capacity is stored but never validated | Add capacity display in allocation page room dropdown |
| Classic system also manages rooms | Both systems write to same table — no conflict since it's basic CRUD |

---

## Task 5: Teaching Allocations Page — `LoadAllocations.aspx`

**Priority:** 🔴 Critical  
**Status:** ✅ Complete  
**Estimated Effort:** 8 hours  
**Dependencies:** Task 1 (menu), Task 2 (schema), Task 4 (rooms), Task 9 (collision detection)  
**Completed:** Code-behind (LoadAllocations.aspx.cs) built with 9 AJAX endpoints — dropdowns, list, courses, checkconflict, create, update, delete, copypreview, copy. Front-end .aspx was already built.  

### Description

This is the **core page** of the Load Allocation module. It replaces the classic `TeachingAllocations.ascx` with a modern, full-featured interface. Users can assign lecturers to courses, set timetable schedules, and manage all allocations for a given programme/semester.

### Steps

1. **Create `LoadAllocations.aspx`:**

   **Filter Bar (top of page):**
   ```
   [Programme ▼] [Study Year ▼] [Entry Year ▼] [Session ▼] [Intake ▼]
   ```
   - Academic Year, Semester, Campus come from master page header (`Session["SelectedAcademicYear"]`, etc.)
   - Programme dropdown: `SELECT progcode, CONCAT(abbrev, ' - ', progname) FROM acad_programme ORDER BY progname`
   - Study Year: 1, 2, 3, 4, 5 (static)
   - Entry Year: dynamic from allocations `SELECT DISTINCT EntryYear FROM acad_teaching_allocation WHERE acad_year = @year ORDER BY EntryYear DESC`
   - Session: DAY, Weekend, INSERVICE, EVENING (from DB or hardcoded)
   - Intake: dynamic `SELECT DISTINCT intake FROM acad_teaching_allocation WHERE acad_year = @year ORDER BY intake`

   **Stats Bar:**
   ```
   [Total Allocations: 24] [Scheduled: 18] [Unscheduled: 6] [Lecturers: 8]
   ```

   **Grid (DevExpress `ASPxGridView`):**
   - Columns: Lecturer Name, Course Code, Course Name, Day, Start Time, End Time, Room, Credit Units, Session, Entry Year, Actions
   - FilterRow enabled
   - Lecturer Name: shows `emp_name` (from JOIN), highlights unassigned in red
   - Day: shows "—" for unscheduled in orange
   - Actions: Edit (opens modal), Delete (with confirmation)

   **Modal Form — "New Allocation" / "Edit Allocation":**
   ```
   Lecturer:    [Searchable dropdown — emp_name (EMP_CODE) — filtered to Academic staff]
   Course:      [Dropdown filtered by programme + study_year + semester from acad_programmecourses]
   Day:         [MONDAY–SUNDAY dropdown + "— Not Scheduled" option]
   Start Time:  [Dropdown: 07:00, 07:30, 08:00 ... 20:00 in 30-min slots]
   End Time:    [Dropdown: auto-filtered to > Start Time]
   Room:        [Dropdown from acad_lecturerooms filtered by campus — shows "Name (Cap: N)"]
   Entry Year:  [Dropdown or text input]
   Session:     [Dropdown: DAY, Weekend, INSERVICE, EVENING]
   Intake:      [Text input]
   Stream:      [Text input, default "-"]
   
   ⚠ Collision Warning Area (dynamic, shows after validation):
      "Room Q2 is already booked on MONDAY 08:00–10:00 by Dr. Smith (ICT2206)"
      "Dr. Jane already teaches on MONDAY 08:00–09:00 (BIT3101)"
   
   [Save] [Cancel]
   ```

   **Client-Side Behavior:**
   - Course dropdown cascades from Programme + Study Year + Semester
   - End Time dropdown auto-filters to show only times after Start Time
   - Room dropdown filters by selected Campus (from master page)
   - On Save click, AJAX check for collisions BEFORE postback (show warnings)
   - Allow saving with warnings (soft block, not hard block) — with audit note

2. **Create `LoadAllocations.aspx.cs`:**

   **Properties:**
   ```csharp
   private string ConnStr { get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; } }
   ```

   **Helper Methods:**
   - `ExecuteQuery(sql, params)` → `DataTable`
   - `ExecuteNonQuery(sql, params)` → `int`
   - `TrySelect(ddl, value)`
   - `GetSelectedAcademicYear()` → reads `Session["SelectedAcademicYear"]`
   - `GetSelectedSemester()` → reads `Session["SelectedSemester"]`
   - `GetSelectedCampus()` → reads `Session["SelectedCampus"]`

   **Page_Load:**
   ```csharp
   // EnableViewState = false pattern
   LoadProgrammes();
   LoadLecturers();
   LoadRooms();
   // Restore posted values
   TrySelect(ddlProgramme, Request.Form[ddlProgramme.UniqueID]);
   // etc.
   BindGrid();
   LoadStats();
   ```

   **BindGrid SQL:**
   ```sql
   SELECT ta.ID, ta.staffCode, e.emp_name, e.EMP_CODE,
          ta.courseID, c.courseName, c.CreditUnit,
          ta.lectureday, ta.StartTime, ta.EndTime,
          ta.roomNo, lr.RoomName, lr.Capacity,
          ta.cyear, ta.EntryYear, ta.stud_session, ta.intake, ta.stream
   FROM acad_teaching_allocation ta
   LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
   LEFT JOIN acad_course c ON c.courseID = ta.courseID
   LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
   WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
     AND ta.progcode = @prog AND ta.cyear = @studyYear
   ORDER BY ta.lectureday, ta.StartTime, c.courseName
   ```

   **Create Allocation:**
   ```sql
   INSERT INTO acad_teaching_allocation 
       (staffCode, courseID, acad_year, semester, progcode, cyear, 
        stud_session, intake, stream, campusId, lectureday, 
        EntryYear, StartTime, EndTime, roomNo, created_by, created_at)
   VALUES 
       (@staff, @course, @year, @sem, @prog, @cyear,
        @session, @intake, @stream, @campus, @day,
        @entryYear, @start, @end, @room, @user, NOW())
   ```

   **Update Allocation:**
   ```sql
   UPDATE acad_teaching_allocation SET
       staffCode = @staff, courseID = @course, lectureday = @day,
       StartTime = @start, EndTime = @end, roomNo = @room,
       stud_session = @session, intake = @intake, stream = @stream,
       EntryYear = @entryYear, updated_by = @user, updated_at = NOW()
   WHERE ID = @id
   ```

   **Delete Allocation:**
   ```sql
   DELETE FROM acad_teaching_allocation WHERE ID = @id
   ```

   **Collision Check (server-side, called before save):**
   - Room collision: `CheckRoomCollision(day, start, end, room, excludeId)` — see Task 9
   - Lecturer collision: `CheckLecturerCollision(day, start, end, staffCode, excludeId)` — see Task 9

   **LoadCourses (cascading, filtered):**
   ```sql
   SELECT DISTINCT pc.course_code, 
          CONCAT(c.courseID, ' - ', c.courseName, ' (', c.CreditUnit, ' CU)') AS display
   FROM acad_programmecourses pc
   LEFT JOIN acad_course c ON c.courseID = pc.course_code
   WHERE pc.progcode = @prog AND pc.study_year = @year AND pc.semester = @sem
   ORDER BY c.courseName
   ```

   **LoadLecturers:**
   ```sql
   SELECT e.empID, CONCAT(e.emp_name, ' (', e.EMP_CODE, ')') AS display
   FROM hrm_employee e
   WHERE e.EmpType = 'Academic' OR e.EmpType = 'Part Time'
   ORDER BY e.emp_name
   ```

3. **Register page title** in `SidebarMaster.master.cs` (done in Task 1)

### Expected Outcome

- Full CRUD for teaching allocations with modern modal-based UI
- Courses filtered by programme + study year + semester (unlike classic which shows ALL courses)
- Lecturer dropdown shows only academic staff with name + code
- Room dropdown shows room name + capacity, filtered by campus
- Collision warnings for room and lecturer conflicts
- Stats cards show allocation overview
- Audit trail (created_by, updated_by) on every change
- Classic system keeps reading/writing same table — zero data migration

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| `staffCode` stores `empID` as string | Use `CAST(ta.staffCode AS UNSIGNED) = e.empID` for JOINs; store new values as string `empID.ToString()` |
| Classic creates allocations with `lectureday = '-'` | Display these as "Unscheduled" in orange badge; allow editing to add schedule |
| Some programmes have no courses in `acad_programmecourses` | Show "No courses found for this programme/year/semester" message |
| Large number of lecturers (309) | Use searchable dropdown with JS text filter |
| Entry Year is not always set correctly | Default to current year portion of `acad_year` (e.g., "2025" from "2025/2026") |
| Session-based state from master page | Read `Session["SelectedAcademicYear"]` etc. on every `Page_Load` — never cache |

---

## Task 6: Timetable View Page — `TimetableView.aspx`

**Priority:** 🟡 High  
**Status:** ✅ Complete  
**Estimated Effort:** 6 hours  
**Dependencies:** Task 1 (menu), Task 5 (allocations must exist with schedules)  

### Description

A visual weekly timetable grid showing the schedule for a selected programme/study year. Renders as a calendar-style grid with time slots on the Y-axis and days on the X-axis. Each block shows course code, lecturer, and room.

### Steps

1. **Create `TimetableView.aspx`:**

   **Filter Bar:**
   ```
   [Programme ▼] [Study Year ▼] [Entry Year ▼] [Session ▼] [View: Compact | Detailed ▼]
   ```

   **Weekly Grid (HTML table, NOT DevExpress grid):**
   ```
   Time     | MONDAY           | TUESDAY          | WEDNESDAY        | THURSDAY         | FRIDAY           | SATURDAY
   07:00    |                  |                  |                  |                  |                  |
   07:30    |                  |                  |                  |                  |                  |
   08:00    | ┌────────────┐   |                  |                  | ┌────────────┐   |                  |
            | │ ICT2206    │   |                  |                  | │ BIT3101    │   |                  |
   08:30    | │ Dr. Smith  │   |                  |                  | │ Prof. Jane │   |                  |
            | │ Lab 1      │   |                  |                  | │ Room Q2    │   |                  |
   09:00    | └────────────┘   | ┌────────────┐   |                  | └────────────┘   |                  |
            |                  | │ BER3205    │   |                  |                  |                  |
   09:30    |                  | │ Mr. Kato   │   |                  |                  |                  |
            |                  | │ Main Hall  │   |                  |                  |                  |
   10:00    |                  | └────────────┘   |                  |                  |                  |
   ```
   - Each block is color-coded (different color per lecturer or per course)
   - Compact view: shows course code only
   - Detailed view: shows course code + lecturer + room
   - Clicking a block opens the edit modal from LoadAllocations page (or a read-only detail popup)

   **Additional Views (tabs or toggle):**
   - **By Programme:** Default — shows all courses for a programme/year
   - **By Lecturer:** Shows all courses for a specific lecturer across all programmes
   - **By Room:** Shows room utilization for a specific room across all programmes

   **Print / Export:**
   - Print button: CSS `@media print` optimized layout
   - Export to Excel: server-side export of the timetable data

2. **Create `TimetableView.aspx.cs`:**

   **BindTimetable SQL:**
   ```sql
   SELECT ta.ID, ta.courseID, c.courseName, ta.staffCode, e.emp_name,
          ta.lectureday, ta.StartTime, ta.EndTime, ta.roomNo, lr.RoomName,
          ta.progcode, p.abbrev AS progAbbrev, ta.cyear
   FROM acad_teaching_allocation ta
   LEFT JOIN acad_course c ON c.courseID = ta.courseID
   LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
   LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
   LEFT JOIN acad_programme p ON p.progcode = ta.progcode
   WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
     AND ta.progcode = @prog AND ta.cyear = @studyYear
     AND ta.lectureday != '-' AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL
   ORDER BY ta.lectureday, ta.StartTime
   ```

   **Render Logic (server-side):**
   - Build a 2D array: `timeSlots[dayIndex][slotIndex]` = list of allocations
   - Time slots: 07:00 to 20:00 in 30-minute increments (26 slots)
   - Days: Monday to Saturday (6 columns)
   - For each allocation, calculate its rowspan based on `(EndTime - StartTime) / 30min`
   - Render as HTML `<table>` with `rowspan` for multi-slot blocks
   - Apply color classes based on hash of `courseID` or `staffCode`

3. **CSS for timetable:**
   - `.la-timetable` — main table container
   - `.la-timetable__slot` — empty 30-min cell
   - `.la-timetable__block` — filled lecture block with color
   - `.la-timetable__block--color1` through `--color8` — 8 distinct colors
   - Print-friendly styles with `@media print`

### Expected Outcome

- Visual weekly timetable grid that staff can view and print
- Three view modes: By Programme, By Lecturer, By Room
- Each lecture block shows course code, lecturer name, room
- Color-coded for visual distinction
- Print-optimized layout
- Compact and detailed view toggle

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Only 8% of allocations have schedules | Show "X of Y allocations are scheduled" warning banner |
| Overlapping time slots (data quality) | Render overlapping blocks side-by-side within the same cell (columns within a day) |
| Time slot rendering with variable rowspan | Pre-compute a 2D occupied array; skip cells that are part of a rowspan |
| Print layout may break | Use `@media print` with fixed column widths and page-break rules |
| No start/end time for 92% of records | "Unscheduled" tab/section listing courses without times |

---

## Task 7: Workload Analysis Page — `WorkloadAnalysis.aspx`

**Priority:** 🟡 High  
**Status:** ✅ Complete  
**Estimated Effort:** 5 hours  
**Dependencies:** Task 1 (menu), Task 2 (schema for better queries)  

### Description

A read-only dashboard showing lecturer workloads for the selected academic year/semester. Helps deans and registrars balance teaching loads and identify overloaded or underloaded lecturers.

### Steps

1. **Create `WorkloadAnalysis.aspx`:**

   **Filter Bar:**
   ```
   [Faculty ▼] [Programme ▼ (optional)] [Contract Type ▼: All/Full Time/Part Time]
   ```

   **Summary Cards:**
   ```
   [Total Lecturers: 85] [Avg Courses/Lecturer: 3.2] [Overloaded (>6): 5] [Unassigned Courses: 12]
   ```

   **Workload Grid:**
   | Lecturer | EMP Code | Department | Contract | Courses | Contact Hrs | Programmes | Status |
   |----------|----------|------------|----------|---------|-------------|------------|--------|
   | Dr. Smith | MRU0078 | ICT | Full Time | 6 | 18 | 3 | ⚠ Heavy |
   | Prof. Jane | MRU0042 | Business | Full Time | 4 | 12 | 2 | ✅ Normal |
   | Mr. Kato | MRU0123 | Education | Part Time | 2 | 6 | 1 | ✅ Normal |
   | — Unassigned | — | — | — | 12 | 36 | 5 | ❌ Unassigned |

   - Status badges: Normal (green), Heavy (orange for >5 courses or >15 hrs), Overloaded (red for >7 courses or >21 hrs)
   - Click a lecturer name to expand/see their individual course list
   - "Unassigned" row at the bottom summarizes courses with `staffCode = '0'`

   **Detail Panel (expand on lecturer click):**
   ```
   Dr. Smith — Full Time, ICT Department
   ┌─────────────────────────────────────────────────────────┐
   │ Course     │ Programme          │ Day  │ Time       │ CU │
   │ ICT2206    │ BICT Yr 2          │ MON  │ 08:00-10:00│ 3  │
   │ ICT3101    │ BICT Yr 3          │ TUE  │ 10:00-12:00│ 4  │
   │ ICT2206    │ BSWE Yr 2 (W/E)   │ SAT  │ 08:00-10:00│ 3  │
   │ ICT1100    │ BICT Yr 1          │  —   │     —      │ 3  │
   └─────────────────────────────────────────────────────────┘
   Total: 4 courses | 13 Credit Units | 10 Scheduled Hours
   ```

2. **Create `WorkloadAnalysis.aspx.cs`:**

   **Main Workload Query:**
   ```sql
   SELECT ta.staffCode, e.emp_name, e.EMP_CODE, e.EmpType,
          c2.contract_type, d.departmentName,
          COUNT(DISTINCT ta.courseID) AS course_count,
          COUNT(DISTINCT ta.progcode) AS programme_count,
          COALESCE(SUM(DISTINCT_COURSE.CreditUnit), 0) AS total_credits,
          SUM(CASE WHEN ta.lectureday != '-' THEN 
              TIMESTAMPDIFF(MINUTE, 
                  STR_TO_DATE(ta.StartTime, '%H:%i'), 
                  STR_TO_DATE(ta.EndTime, '%H:%i')
              ) / 60.0 ELSE 0 END) AS scheduled_hours
   FROM acad_teaching_allocation ta
   LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
   LEFT JOIN hrm_emp_contracts c2 ON c2.empID = e.empID AND c2.contractStatus = 'Active'
   LEFT JOIN hrm_departments d ON d.ID = c2.departmentID
   LEFT JOIN (
       SELECT DISTINCT ta2.staffCode, ta2.courseID, c.CreditUnit
       FROM acad_teaching_allocation ta2
       JOIN acad_course c ON c.courseID = ta2.courseID
       WHERE ta2.acad_year = @year AND ta2.semester = @sem
   ) DISTINCT_COURSE ON DISTINCT_COURSE.staffCode = ta.staffCode AND DISTINCT_COURSE.courseID = ta.courseID
   WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
   GROUP BY ta.staffCode, e.emp_name, e.EMP_CODE, e.EmpType, c2.contract_type, d.departmentName
   ORDER BY course_count DESC, e.emp_name
   ```

### Expected Outcome

- Clear overview of who is teaching what and how much
- Overloaded lecturers highlighted visually
- Unassigned courses tracked
- Expandable detail for each lecturer
- Helps deans make informed allocation decisions

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Complex SQL with multiple JOINs | Pre-test query in MySQL client; optimize with subqueries if needed |
| Contract data may be incomplete | LEFT JOIN ensures lecturers without contracts still appear |
| "Overloaded" threshold is subjective | Make thresholds configurable or use sensible defaults (>5 courses, >15 hrs) |
| Duplicate allocations inflate counts | Use `COUNT(DISTINCT courseID)` not `COUNT(*)` |

---

## Task 8: Load Allocation Dashboard — `LoadAllocationDashboard.aspx`

**Priority:** 🟠 Medium  
**Status:** ✅ Complete  
**Estimated Effort:** 4 hours  
**Dependencies:** Task 1 (menu), Task 5 (allocations page for links)  

### Description

An overview dashboard for the Load Allocation module showing key metrics, alerts, and quick navigation links. Similar in style to the HR Dashboard and Fees Dashboard.

### Steps

1. **Create `LoadAllocationDashboard.aspx`:**

   **Stats Row (4 cards):**
   ```
   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
   │ Total        │ │ Scheduled    │ │ Unscheduled  │ │ Active       │
   │ Allocations  │ │              │ │              │ │ Lecturers    │
   │     326      │ │     48       │ │     278      │ │     42       │
   │  ▲ 12% yoy   │ │  ▲ 5% yoy    │ │  ▼ 8% yoy    │ │  ▲ 3% yoy    │
   └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
   ```

   **Alerts Panel:**
   ```
   ⚠ 278 allocations have no timetable schedule
   ⚠ 12 courses have no lecturer assigned (staffCode = 0)
   ⚠ 3 room collisions detected
   ⚠ 2 lecturer time conflicts detected
   ```

   **Quick Actions:**
   ```
   [🔗 Manage Allocations] [🔗 View Timetable] [🔗 Workload Report] [🔗 Lecture Rooms]
   ```

   **Programme Coverage Table:**
   | Programme | Allocated | Scheduled | Total Courses | Coverage |
   |-----------|-----------|-----------|---------------|----------|
   | BICT Yr 2 | 12 | 8 | 12 | 100% / 67% |
   | BBA Yr 1 | 8 | 3 | 10 | 80% / 30% |

   **Recent Activity (from audit columns):**
   | Action | User | Details | Time |
   |--------|------|---------|------|
   | Created | admin | Dr. Smith → ICT2206 (BICT Yr 2) | 5 min ago |
   | Updated | registrar | Changed room Q2 → Lab1 for BIT3101 | 1 hr ago |

2. **Create `LoadAllocationDashboard.aspx.cs`:**
   - Multiple summary queries against `acad_teaching_allocation`
   - Collision detection queries (reuse from Task 9)
   - Recent activity from `created_at` / `updated_at` audit columns

### Expected Outcome

- At-a-glance overview of allocation status for the current semester
- Alerts highlight issues that need attention
- Quick links to all sub-pages
- Programme coverage shows which programmes are fully allocated

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Multiple queries on page load | Use a single large JOIN query with GROUP BY, not many small queries |
| Audit columns don't exist yet | Depends on Task 2; show "No recent activity" if columns are NULL |
| Year-over-year comparison | Compare current semester to same semester last year |

---

## Task 9: Collision Detection Engine

**Priority:** 🟡 High  
**Status:** ⬜ Not Started  
**Estimated Effort:** 3 hours  
**Dependencies:** Task 2 (indexes for performance)  

### Description

Build reusable server-side methods for detecting room and lecturer scheduling conflicts. These will be used by Task 5 (allocations page), Task 8 (dashboard alerts), and optionally exposed as an AJAX endpoint for client-side pre-validation.

### Steps

1. **Create `App_Code/AllocationHelper.cs`** (shared helper class):

   ```csharp
   public static class AllocationHelper
   {
       /// <summary>
       /// Check if a room is already booked at the given day/time.
       /// Returns list of conflicting allocation descriptions.
       /// </summary>
       public static List<string> CheckRoomCollision(
           string connStr, string roomNo, string day, string startTime, string endTime,
           string acadYear, string semester, string campusId, int excludeId)
       {
           // SQL: Find allocations where room + day overlap with the given time range
           // Overlap condition: existing.Start < @end AND existing.End > @start
       }

       /// <summary>
       /// Check if a lecturer is already teaching at the given day/time.
       /// Returns list of conflicting allocation descriptions.
       /// </summary>
       public static List<string> CheckLecturerCollision(
           string connStr, string staffCode, string day, string startTime, string endTime,
           string acadYear, string semester, int excludeId)
       {
           // SQL: Find allocations where staffCode + day overlap with the given time range
       }

       /// <summary>
       /// Get all collisions for the current semester (for dashboard alerts).
       /// Returns count of room collisions and lecturer collisions.
       /// </summary>
       public static CollisionSummary GetAllCollisions(
           string connStr, string acadYear, string semester, string campusId)
       {
           // Self-join query to find all pairs of overlapping allocations
       }
   }
   ```

2. **Room Collision SQL:**
   ```sql
   SELECT ta.ID, ta.courseID, c.courseName, e.emp_name, ta.StartTime, ta.EndTime
   FROM acad_teaching_allocation ta
   LEFT JOIN acad_course c ON c.courseID = ta.courseID
   LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
   WHERE ta.roomNo = @room AND ta.lectureday = @day
     AND ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
     AND ta.lectureday != '-'
     AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL
     AND STR_TO_DATE(ta.StartTime, '%H:%i') < STR_TO_DATE(@endTime, '%H:%i')
     AND STR_TO_DATE(ta.EndTime, '%H:%i') > STR_TO_DATE(@startTime, '%H:%i')
     AND ta.ID != @excludeId
   ```

3. **Lecturer Collision SQL:**
   ```sql
   SELECT ta.ID, ta.courseID, c.courseName, lr.RoomName, ta.StartTime, ta.EndTime
   FROM acad_teaching_allocation ta
   LEFT JOIN acad_course c ON c.courseID = ta.courseID
   LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
   WHERE ta.staffCode = @staffCode AND ta.lectureday = @day
     AND ta.acad_year = @year AND ta.semester = @sem
     AND ta.lectureday != '-'
     AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL
     AND STR_TO_DATE(ta.StartTime, '%H:%i') < STR_TO_DATE(@endTime, '%H:%i')
     AND STR_TO_DATE(ta.EndTime, '%H:%i') > STR_TO_DATE(@startTime, '%H:%i')
     AND ta.ID != @excludeId
   ```

4. **AJAX Endpoint (optional, for client-side pre-check):**
   - Add a WebMethod or handler that accepts JSON `{roomNo, day, start, end, staffCode, ...}` and returns collision list
   - Call from JS on modal form before save to show warnings inline

### Expected Outcome

- Reusable detection functions in `App_Code/AllocationHelper.cs`
- Room collisions detected before save (warning, not hard block)
- Lecturer time conflicts detected before save
- Dashboard can summarize total collisions for the semester
- AJAX pre-check possible for real-time validation in modal

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Time stored as strings (`"08:00"`) not TIME type | Use `STR_TO_DATE()` in MySQL for comparison; validate format in code |
| Some allocations have NULL StartTime/EndTime | Filter these out in the WHERE clause (`IS NOT NULL`) |
| Collision across different campuses | Room collision scoped to same `campusId`; lecturer collision NOT scoped (lecturer can only be in one place) |
| Performance with self-join for "all collisions" | Index on `(acad_year, semester, lectureday, roomNo)` makes this fast |

---

## Task 10: Batch Operations — Adopt & Copy Allocations

**Priority:** 🟠 Medium  
**Status:** ✅ Complete  
**Estimated Effort:** 3 hours  
**Dependencies:** Task 5 (allocations page must exist)  

### Description

Add batch operations to the Teaching Allocations page: copy allocations from a previous semester/year, and adopt allocations from one entry year to another. These replicate the classic system's "Adopt" feature with improvements.

### Steps

1. **"Copy from Previous" feature:**
   - Button on LoadAllocations page: "Copy from Previous Semester"
   - Modal: Select source Academic Year + Semester
   - Logic:
     ```sql
     INSERT INTO acad_teaching_allocation 
         (staffCode, courseID, acad_year, semester, progcode, cyear, stud_session,
          intake, stream, campusId, lectureday, EntryYear, StartTime, EndTime, roomNo,
          created_by, created_at)
     SELECT staffCode, courseID, @newYear, @newSem, progcode, cyear, stud_session,
            intake, stream, campusId, lectureday, EntryYear, StartTime, EndTime, roomNo,
            @user, NOW()
     FROM acad_teaching_allocation
     WHERE acad_year = @sourceYear AND semester = @sourceSem
       AND progcode = @prog AND cyear = @studyYear AND campusId = @campus
       AND NOT EXISTS (
           SELECT 1 FROM acad_teaching_allocation dup
           WHERE dup.acad_year = @newYear AND dup.semester = @newSem
             AND dup.staffCode = acad_teaching_allocation.staffCode
             AND dup.courseID = acad_teaching_allocation.courseID
             AND dup.progcode = acad_teaching_allocation.progcode
             AND dup.cyear = acad_teaching_allocation.cyear
       )
     ```
   - Show preview count before executing: "X allocations will be copied. Y already exist and will be skipped."

2. **"Adopt Entry Year" feature:**
   - Button: "Adopt Allocations"
   - Modal: Select target Entry Year
   - Logic: Same as copy but changes `EntryYear` in the INSERT
   - Skips duplicates

3. **"Bulk Delete" feature:**
   - Checkbox column in grid
   - "Delete Selected" button
   - Confirmation: "Are you sure you want to delete X allocations?"

### Expected Outcome

- Semester setup is fast — copy last semester's allocations in one click
- Entry year adoption handles intake variations
- Bulk delete for cleanup
- All operations respect unique constraints (skip duplicates)
- Audit trail on all batch-created records

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Copying many records at once | Use single INSERT...SELECT with NOT EXISTS to avoid duplicates |
| Lecturers may have changed between semesters | Copied allocations keep old lecturer — admin can update individually |
| Courses may have changed in programme structure | Copied allocations reference old course codes — orphaned courses will show as "(Unknown Course)" in grid |

---

## Task 11: Data Cleanup — Fix Existing Duplicate Allocations

**Priority:** 🟡 High  
**Status:** ⬜ Not Started  
**Estimated Effort:** 2 hours  
**Dependencies:** None (should be done before Task 2 unique constraint)  

### Description

Clean up duplicate records in `acad_teaching_allocation` that have accumulated over time due to the lack of unique constraints.

### Steps

1. **Identify duplicates:**
   ```sql
   SELECT staffCode, courseID, progcode, acad_year, semester, cyear, 
          EntryYear, stud_session, lectureday,
          COUNT(*) as cnt, GROUP_CONCAT(ID) as duplicate_ids
   FROM acad_teaching_allocation
   GROUP BY staffCode, courseID, progcode, acad_year, semester, cyear, 
            EntryYear, stud_session, lectureday
   HAVING COUNT(*) > 1
   ORDER BY cnt DESC;
   ```

2. **Analyze duplicates:**
   - How many duplicate groups exist?
   - Are duplicates identical or do they differ in time/room?
   - Which academic years are most affected?

3. **Create backup:**
   ```sql
   CREATE TABLE acad_teaching_allocation_backup_20260410 AS
   SELECT * FROM acad_teaching_allocation;
   ```

4. **Remove duplicates (keep the one with the most data):**
   ```sql
   -- Keep the record with the most schedule data (lectureday != '-'),
   -- or the highest ID (most recent) if both are equal
   DELETE ta FROM acad_teaching_allocation ta
   INNER JOIN (
       SELECT MIN(ID) as keep_id, staffCode, courseID, progcode, 
              acad_year, semester, cyear, EntryYear, stud_session, lectureday
       FROM acad_teaching_allocation
       GROUP BY staffCode, courseID, progcode, acad_year, semester, cyear, 
               EntryYear, stud_session, lectureday
       HAVING COUNT(*) > 1
   ) dup ON ta.staffCode = dup.staffCode 
        AND ta.courseID = dup.courseID
        AND ta.progcode = dup.progcode
        AND ta.acad_year = dup.acad_year
        AND ta.semester = dup.semester
        AND ta.cyear = dup.cyear
        AND ta.EntryYear = dup.EntryYear
        AND ta.stud_session = dup.stud_session
        AND ta.lectureday = dup.lectureday
        AND ta.ID != dup.keep_id;
   ```

5. **Verify:**
   ```sql
   SELECT COUNT(*) FROM acad_teaching_allocation;
   -- Compare with backup count
   SELECT COUNT(*) FROM acad_teaching_allocation_backup_20260410;
   -- Confirm no duplicate groups remain
   ```

6. **Now safe to add UNIQUE constraint** (Task 2)

### Expected Outcome

- All duplicate allocations removed (keeping one per group)
- Backup table preserved for rollback if needed
- Database ready for UNIQUE constraint
- Record count reduction documented

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Some "duplicates" may be intentional (same course, different time) | Include `lectureday` in the grouping — so same course at different times = not a duplicate |
| Teaching Center references specific allocation IDs | Teaching Center filters by `staffCode + courseID + acad_year + semester` — not by ID. Safe to delete duplicates |
| Large DELETE may lock table | Run during low traffic; the 20K table is small enough for instant operations |

---

## Task 12: API Fix — Timetable & Academic Endpoints

**Priority:** 🔴 Critical  
**Status:** ✅ Complete  
**Estimated Effort:** 3 hours  
**Dependencies:** Task 3 (VIEW must exist for timetable)  
**Completed:** Fixed 3 column mismatches in academic.aspx.cs (HandleCourseDetails + HandleProgrammeCurriculum) and 2 FIELD() day-casing fixes in timetable.aspx.cs.  

### Description

Fix broken API endpoints so that students and mobile apps can see timetable data and course details.

### Steps

1. **Read `API/v2/timetable.aspx.cs`** to identify exact expected columns from `acad_timetable`

2. **Adjust VIEW** created in Task 3 to match API's expected column names exactly

3. **Test the `lectures` endpoint:**
   - `GET /API/v2/timetable.aspx?action=lectures&regno=MRU2025...&acad_year=2025/2026&semester=1`
   - Should return lecture schedule for the student

4. **Read `API/v2/academic.aspx.cs`** for `course_details`, `course_enrollments`, `programme_curriculum` endpoints

5. **Fix column name mappings:**
   | API Expects | Actual Column | Fix |
   |-------------|---------------|-----|
   | `acad_programmecourses.courseID` | `course_code` | Change API SQL to use `course_code` |
   | `acad_programmecourses.studyYear` | `study_year` | Change API SQL to use `study_year` |
   | `acad_programme.proglevel` | `levelCode` | Change API SQL to use `levelCode` |
   | `acad_programme.progfaculty` | `faculty_code` | Change API SQL to use `faculty_code` |
   | `acad_programme.progduration` | `couselength` | Change API SQL to use `couselength` |
   | `acad_programme.progdept` | Remove | This column doesn't exist; remove from SELECT |

6. **Test each fixed endpoint** with real data

### Expected Outcome

- Timetable API returns lecture schedule data for students
- Academic API endpoints for course details, enrollments, curriculum work correctly
- Mobile app shows timetable
- No SQL errors from column mismatches

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| API may be compiled into a DLL (not editable source) | Check if API is inline code (`.aspx.cs`) or precompiled — our project uses CodeFile, so it's editable |
| Fixing API may break existing consumers if column names in JSON output change | Keep JSON output key names the same; only fix SQL column names |
| VIEW may need different columns than expected | Read API code first, then adjust VIEW |

---

## Task 13: Classic ↔ New Integration Testing

**Priority:** 🔴 Critical  
**Status:** ⬜ Not Started  
**Estimated Effort:** 3 hours  
**Dependencies:** Tasks 5, 6, 7, 8 (all pages built)  

### Description

Verify that the new Load Allocation pages and the classic `TeachingAllocations.ascx` can coexist without data corruption. Both systems read/write the same `acad_teaching_allocation` table.

### Steps

1. **Test: Create allocation in NEW, view in CLASSIC:**
   - Open `LoadAllocations.aspx`, create a new allocation with lecturer, course, day, time, room
   - Open classic `TeachingAllocations.ascx` with same filters
   - Verify the new record appears in the classic grid
   - Verify all fields display correctly (especially `lectureday`, `StartTime`, `EndTime`, `roomNo`)

2. **Test: Create allocation in CLASSIC, view in NEW:**
   - Open classic, add a new allocation (will have `lectureday="-"`)
   - Open `LoadAllocations.aspx` with same filters
   - Verify the record appears as "Unscheduled" with orange badge
   - Edit the record in new system to add schedule
   - Verify update appears correctly in classic

3. **Test: Edit allocation in NEW, verify in CLASSIC:**
   - Change lecturer, day, time, room in new page
   - Verify classic grid shows updated values

4. **Test: Delete allocation in NEW, verify in CLASSIC:**
   - Delete a record in new page
   - Verify it disappears from classic grid

5. **Test: Adopt in CLASSIC, view in NEW:**
   - Use classic Adopt feature to copy allocations
   - Verify copied records appear in new page

6. **Test: Teaching Center (Portal) still works:**
   - Log in as a lecturer on the portal
   - Verify Teaching Center still shows their allocations
   - Verify coursework/exam mark entry still works
   - Verify that changes made via new admin page are reflected

7. **Test: Audit columns:**
   - Records created via NEW page should have `created_by` populated
   - Records created via CLASSIC page should have `created_by = NULL` (acceptable)
   - Records edited via NEW page should have `updated_by` populated

8. **Test: API endpoints:**
   - Hit timetable API and verify new allocations appear
   - Hit academic API and verify no errors

### Expected Outcome

- Both systems coexist without data corruption
- All CRUD operations from either system are visible in the other
- Teaching Center portal unaffected
- API returns corrected data
- Zero data loss

### Potential Challenges

| Challenge | Mitigation |
|-----------|------------|
| Classic ObjectDataSource may cache data | Classic pages use TypedDataSets which re-query on bind — no caching issue |
| Classic stores `roomNo` as string, new stores as int | Store as string in both — `roomNo` column is VARCHAR |
| Classic doesn't populate audit columns | Acceptable — `created_by` defaults to NULL, `created_at` defaults to CURRENT_TIMESTAMP |
| Session conflicts between classic and new | Each page uses its own Session keys; no overlap since new pages use master page sessions |

---

## Task 14: Comprehensive Testing & QA

**Priority:** 🔴 Critical  
**Status:** ⬜ Not Started  
**Estimated Effort:** 4 hours  
**Dependencies:** All previous tasks  

### Description

Full end-to-end testing of all Load Allocation pages, covering functionality, edge cases, data integrity, and UI consistency.

### Steps

1. **Functional Test Matrix:**

   | Page | Action | Test Case | Expected |
   |------|--------|-----------|----------|
   | LectureRooms | Create | Add room with name, capacity, campus | Room appears in grid |
   | LectureRooms | Edit | Change room capacity | Updated in grid and allocation dropdowns |
   | LectureRooms | Delete (allowed) | Delete unused room | Room removed |
   | LectureRooms | Delete (blocked) | Delete room used in allocation | Error: "Room is in use by X allocations" |
   | LoadAllocations | Create | Full allocation with schedule | Record in DB, appears in grid |
   | LoadAllocations | Create | Allocation without schedule (day = —) | Record created with lectureday='-' |
   | LoadAllocations | Edit | Change lecturer | staffCode updated |
   | LoadAllocations | Edit | Add schedule to unscheduled | lectureday/time/room set |
   | LoadAllocations | Delete | Delete allocation | Record removed from DB |
   | LoadAllocations | Collision | Room already booked | Warning message displayed |
   | LoadAllocations | Collision | Lecturer already booked | Warning message displayed |
   | LoadAllocations | Duplicate | Same lecturer+course+prog+sem | Unique constraint error handled gracefully |
   | LoadAllocations | Cascade filter | Change programme | Courses refresh, grid refreshes |
   | TimetableView | View | Select programme + year | Weekly grid renders with blocks |
   | TimetableView | Empty | No scheduled allocations | "No timetable data" message |
   | TimetableView | Print | Click print | Clean printable layout |
   | WorkloadAnalysis | View | Default (no filters) | All lecturers listed with counts |
   | WorkloadAnalysis | Filter | Filter by faculty | Only lecturers from that faculty |
   | WorkloadAnalysis | Expand | Click lecturer name | Detail panel shows courses |
   | Dashboard | Load | Default | Stats, alerts, coverage table |
   | Dashboard | Alert | Collisions exist | Alert panel shows count |

2. **Edge Case Tests:**
   - Programme with no courses in `acad_programmecourses`
   - Lecturer with `EmpType` not "Academic" but assigned
   - Allocation with `staffCode = '0'` (unassigned)
   - Allocation with invalid room reference (room deleted)
   - Time overlap: 08:00–10:00 and 09:00–11:00
   - Academic year with no semester active
   - Campus = "ALL" (ID = 0) selections

3. **Data Integrity Tests:**
   - Count records before and after each operation
   - Verify audit columns are populated
   - Verify unique constraint prevents duplicates
   - Verify VIEW `acad_timetable` reflects changes immediately

4. **UI/UX Tests:**
   - All pages load without JS errors
   - Modals open/close correctly
   - Toast messages appear for success/error
   - FilterRow works on all grids
   - Mobile-responsive layout (sidebar collapses)
   - Print layout is clean

5. **Performance Tests:**
   - Page load time with full data (20K allocations)
   - Grid pagination (100 records per page)
   - Workload query with 300+ employees

### Expected Outcome

- All test cases pass
- Zero data corruption
- Consistent UI with existing new system pages
- All edge cases handled gracefully
- Performance acceptable (<2s page load)

---

## Appendix A: File Inventory (To Be Created)

| File | Type | Task |
|------|------|------|
| `COOPERP/NewScreens/LoadAllocationDashboard.aspx` | Page | Task 8 |
| `COOPERP/NewScreens/LoadAllocationDashboard.aspx.cs` | Code-behind | Task 8 |
| `COOPERP/NewScreens/LoadAllocations.aspx` | Page | Task 5 |
| `COOPERP/NewScreens/LoadAllocations.aspx.cs` | Code-behind | Task 5 |
| `COOPERP/NewScreens/TimetableView.aspx` | Page | Task 6 |
| `COOPERP/NewScreens/TimetableView.aspx.cs` | Code-behind | Task 6 |
| `COOPERP/NewScreens/LectureRooms.aspx` | Page | Task 4 |
| `COOPERP/NewScreens/LectureRooms.aspx.cs` | Code-behind | Task 4 |
| `COOPERP/NewScreens/WorkloadAnalysis.aspx` | Page | Task 7 |
| `COOPERP/NewScreens/WorkloadAnalysis.aspx.cs` | Code-behind | Task 7 |
| `App_Code/AllocationHelper.cs` | Shared helper | Task 9 |
| `SidebarMaster.master` | Modified | Task 1 |
| `SidebarMaster.master.cs` | Modified | Task 1 |

## Appendix B: Dependency Graph

```
Task 1 (Menu) ──────────────────────────────────────┐
                                                     │
Task 11 (Data Cleanup) ──► Task 2 (Schema) ──┐      │
                                              │      │
Task 3 (VIEW) ──────────► Task 12 (API Fix) ──┤     │
                                              │      │
                         Task 9 (Collisions) ──┤     │
                                              │      │
Task 4 (Rooms) ───────────────────────────────┤      │
                                              ▼      ▼
                                   Task 5 (Allocations Page) ──┐
                                              │                │
                                   Task 10 (Batch Ops) ────────┤
                                              │                │
                                   Task 6 (Timetable View) ────┤
                                              │                │
                                   Task 7 (Workload) ──────────┤
                                              │                │
                                   Task 8 (Dashboard) ─────────┤
                                                               ▼
                                                    Task 13 (Integration Test)
                                                               │
                                                               ▼
                                                    Task 14 (Full QA)
```

## Appendix C: Risk Register

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Classic pages break when schema changes | 🔴 Critical | Low | Only ADD columns (never rename/remove); classic ignores new columns |
| Teaching Center portal sees different data | 🔴 Critical | Low | Portal reads same table; new pages write same schema |
| Data loss from duplicate cleanup | 🟡 High | Low | Always create backup table before DELETE; verify counts |
| API consumers break from column changes | 🟡 High | Medium | VIEW aliases match API expectations; test all endpoints |
| Performance degradation from new indexes | 🟠 Medium | Low | Indexes on 20K row table have negligible overhead |
| Concurrent edits lose data | 🟠 Medium | Medium | `updated_at` column enables optimistic concurrency (future) |

---

*Created: 2026-04-10 | Campus Dynamics — Load Allocation Module Task List*
