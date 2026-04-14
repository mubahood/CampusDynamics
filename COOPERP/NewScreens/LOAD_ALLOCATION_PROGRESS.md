# Load Allocation Module — Implementation Progress

> **Module:** Load Allocation  
> **Started:** 2026-04-11  
> **Location:** `COOPERP/NewScreens/`  
> **Reference:** [LOAD_ALLOCATION_TASKS.md](LOAD_ALLOCATION_TASKS.md) | [ACADEMICS_MODULE_DEEP_ANALYSIS.md](../../ACADEMICS_MODULE_DEEP_ANALYSIS.md)

---

## Implementation Batch Plan

| Batch | Tasks | Focus | Status |
|-------|-------|-------|--------|
| **Batch 1** | 11, 2, 3 | DB Foundation — Cleanup, Schema, VIEW | ✅ Complete |
| **Batch 2** | 9, 4 | Helper Engine + Lecture Rooms Page | ✅ Complete |
| **Batch 3** | 5 | Teaching Allocations Page (Core) | 🔄 In Progress |
| **Batch 4** | 6, 7, 8 | Timetable View + Workload + Dashboard | ⬜ Not Started |
| **Batch 5** | 10, 12, 13, 14 | Batch Ops, API Fix, Testing, QA | ⬜ Not Started |

---

## Pre-Flight Analysis (2026-04-11)

### Database State Before Changes

| Table | Rows | Columns | PK | Indexes |
|-------|------|---------|----|---------|
| `acad_teaching_allocation` | 20,747 | 16 | `ID` (auto_increment) | PRIMARY only |
| `acad_lecturerooms` | 47 | 4 | `RoomID` (auto_increment) | PRIMARY only |

### Duplicate Analysis

- **5,241 duplicate records** to remove (records beyond first in each group)
- Top offender: staffCode=89, PRC3106B, BPLM 2025/2026 S1 → 24 copies
- Duplicates span all academic years; grouping: `(staffCode, courseID, progcode, acad_year, semester, cyear, EntryYear, stud_session, lectureday)`

### API View Status

- `acad_timetable` table does **NOT exist** — API returns errors
- Related tables that DO exist: `acad_coursework_timetable`, `acad_exam_timetable`, `acad_timetable_weekdays`
- API expects columns: `day_of_week`, `start_time`, `end_time`, `course_code`, `room`, `building`, `lecturer_id`, `programme_code`, `study_year`, `acad_year`, `semester`

---

## Batch 1: DB Foundation (Tasks 11, 2, 3)

### Task 11: Data Cleanup — Fix Duplicate Allocations

**Status:** ✅ Complete

#### Step 11.1: Create Backup Table
```
Timestamp: 2026-04-11
Command: CREATE TABLE acad_teaching_allocation_backup_20260411 AS SELECT * FROM acad_teaching_allocation;
Result: ✅ Created — 20,747 rows backed up
```

#### Step 11.2: Verify Backup Count
```
Timestamp: 2026-04-11
Query: SELECT COUNT(*) FROM acad_teaching_allocation_backup_20260411;
Expected: 20,747
Result: ✅ 20,747 confirmed
```

#### Step 11.3: Remove Duplicates (keep highest ID per group)
```
Timestamp: 2026-04-11
Strategy: DELETE WHERE ID NOT IN (SELECT MAX(ID) GROUP BY 9-col key)
Result: ✅ 5,241 records removed
```

#### Step 11.4: Verify Post-Cleanup Count
```
Timestamp: 2026-04-11
Expected: 15,506
Result: ✅ 15,506 confirmed
```

#### Step 11.5: Confirm No Remaining Duplicates
```
Timestamp: 2026-04-11
Query: GROUP BY ... HAVING COUNT(*) > 1
Result: ✅ 0 duplicate groups remaining
```

---

### Task 2: DB Schema — Add Audit Columns & Indexes

**Status:** ✅ Complete

#### Step 2.1: Add Audit Columns
```
ALTER TABLE acad_teaching_allocation
    ADD COLUMN created_by VARCHAR(100) DEFAULT NULL,
    ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN updated_by VARCHAR(100) DEFAULT NULL,
    ADD COLUMN updated_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP;
```

#### Step 2.2: Add Performance Indexes
```
ALTER TABLE acad_teaching_allocation
    ADD INDEX idx_lookup (acad_year, semester, progcode, campusId),
    ADD INDEX idx_staff (staffCode, acad_year, semester),
    ADD INDEX idx_room (roomNo, lectureday, acad_year, semester);
```

#### Step 2.3: Add Unique Constraint
```
ALTER TABLE acad_teaching_allocation
    ADD UNIQUE INDEX uq_allocation 
    (staffCode, courseID, progcode, acad_year, semester, cyear, EntryYear, stud_session, lectureday);
```

#### Step 2.4: Verify Column Count & Row Count
```
DESCRIBE acad_teaching_allocation; → should show 20 columns (16 orig + 4 audit)
SELECT COUNT(*) → should match post-cleanup count
```

---

### Task 3: Create `acad_timetable` VIEW for API

**Status:** ✅ Complete

#### Results:
- VIEW created with 17 columns mapping to API expectations
- 1,396 scheduled entries visible (where lectureday != '-' and times are set)
- Confirmed in `information_schema` as TABLE_TYPE = VIEW

#### Step 3.1: Create VIEW
API expects: `day_of_week`, `start_time`, `end_time`, `course_code`, `room`, `building`, `lecturer_id`, `programme_code`, `study_year`, `acad_year`, `semester`

```sql
CREATE OR REPLACE VIEW acad_timetable AS
SELECT 
    ta.ID,
    ta.progcode AS programme_code,
    ta.courseID AS course_code,
    ta.cyear AS study_year,
    CAST(ta.staffCode AS UNSIGNED) AS lecturer_id,
    ta.lectureday AS day_of_week,
    ta.StartTime AS start_time,
    ta.EndTime AS end_time,
    CAST(ta.roomNo AS CHAR) AS room,
    lr.RoomName AS building,
    ta.acad_year,
    ta.semester,
    ta.stud_session,
    ta.campusId,
    ta.EntryYear,
    ta.intake,
    ta.stream
FROM acad_teaching_allocation ta
LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
WHERE ta.lectureday != '-' 
  AND ta.lectureday IS NOT NULL
  AND ta.StartTime IS NOT NULL 
  AND ta.EndTime IS NOT NULL;
```

#### Step 3.2: Test VIEW
```
SELECT * FROM acad_timetable WHERE acad_year = '2025/2026' LIMIT 10;
SELECT COUNT(*) FROM acad_timetable;
```

---

## Batch 2: Helper Engine + Lecture Rooms (Tasks 9, 4)

### Task 9: Collision Detection Engine — `App_Code/AllocationHelper.cs`

**Status:** ⬜ Not Started

- `CheckRoomCollision()` — detect room double-booking
- `CheckLecturerCollision()` — detect lecturer time conflicts
- `GetAllCollisions()` — summary for dashboard alerts

### Task 4: Lecture Rooms Page — `LectureRooms.aspx`

**Status:** ⬜ Not Started

- Room CRUD with modal form
- Stats cards (total rooms, capacity, per-campus)
- DevExpress grid with filter row
- Delete protection (block if room used in allocations)

---

## Batch 3: Teaching Allocations (Task 5)

### Task 5: Teaching Allocations Page — `LoadAllocations.aspx`

**Status:** ⬜ Not Started

- Filter bar: Programme, Study Year, Entry Year, Session, Intake
- DevExpress grid with lecturer, course, day, time, room columns
- Modal form for create/edit with cascading dropdowns
- Collision detection integration
- Stats bar (total, scheduled, unscheduled, lecturers)

---

## Batch 4: Views & Dashboard (Tasks 6, 7, 8)

### Task 6: Timetable View — `TimetableView.aspx`
### Task 7: Workload Analysis — `WorkloadAnalysis.aspx`
### Task 8: Dashboard — `LoadAllocationDashboard.aspx`

**Status:** ⬜ Not Started

---

## Batch 5: Polish & Testing (Tasks 10, 12, 13, 14)

### Task 10: Batch Operations
### Task 12: API Fix
### Task 13: Integration Testing
### Task 14: Comprehensive QA

**Status:** ⬜ Not Started

---

## Files Created/Modified Log

| Timestamp | File | Action | Notes |
|-----------|------|--------|-------|
| 2026-04-10 | `SidebarMaster.master` | Modified | Task 1: Added Load Allocation menu section |
| 2026-04-10 | `SidebarMaster.master.cs` | Modified | Task 1: Added 5 SetPageTitle cases |
| 2026-04-11 | `LOAD_ALLOCATION_PROGRESS.md` | Created | This tracking document |
| 2026-04-11 | `App_Code/AllocationHelper.cs` | Created | Task 9: Collision detection engine (CheckRoomCollision, CheckLecturerCollision, GetCollisionSummary, GetRoomUsageCount, TimeUtils) |
| 2026-04-11 | `COOPERP/NewScreens/LectureRooms.aspx` | Created | Task 4: Lecture Rooms page — AJAX-driven CRUD with stats, table, add/edit/delete modals |
| 2026-04-11 | `COOPERP/NewScreens/LectureRooms.aspx.cs` | Created | Task 4: Code-behind — 5 AJAX endpoints (list, campuses, create, update, delete) |

---

*Last Updated: 2026-04-11*
