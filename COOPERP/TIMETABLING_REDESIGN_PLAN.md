# Timetabling Module — Redesign Plan

**Detailed design + phased task doc.** Muteesa I Royal University (MRU).
Status: PLAN (nothing built yet). Date: 2026-07-19.

> Read this whole doc before writing any code. It is grounded on the **actual** database tables (verified locally) so the model does not contradict what exists.

---

## 0. Goal

Replace today's fragmented timetabling with **one clean model** in which every timetable session ("timetable item") **belongs to a Programme-Course** (`acad_programmecourses` — the row where a *course* meets a *lecturer* and a *programme*). Admins manage it through a screen modelled on `NewProgrammeCourses.aspx`; **lecturers** view their teaching load; **students** view only the sessions for the courses they are enrolled in; and everyone can **export/print** a filtered timetable. Rooms and buildings become first-class, separately-managed resources so we can see what is allocated and what is free.

Hard rules for this build:
- **Do not break or drop** any existing table or screen. The new model lives **alongside** the legacy tables and becomes the going-forward system.
- **No contradictions.** Reuse existing lookups (`acad_campuses`, `acad_timetable_weekdays`, `acad_lecturerooms`) rather than inventing parallel ones.
- **Consistent UI/UX** with the NewScreens design system (eadmin) and the ODEL/portal look (eportal).

---

## 1. What already exists (audit) — and the redesign decision

Verified tables in `campus_dynamics`:

| Table | Rows | Role today | Decision |
|---|---|---|---|
| `acad_programmecourses` | — | **The anchor**: PK `ID`; `progcode, course_code, study_year, semester, lecturer_id, course_type, is_lecturere_assigned, status`. Curriculum-level (NOT per acad_year). | **Anchor** for new timetable items (FK `programmecourse_id → ID`). Unchanged. |
| `acad_campuses` | 3 | `ID`(0=ALL,1=KAKEEKA,2=KIRUMBA), `campus_name, campus_short_name, campus_code`. | **Reuse.** `0/ALL` = the "Both campuses" option. |
| `acad_lecturerooms` | 47 | Rooms: `RoomID, RoomName, Capacity, campusId`. | **Reuse + extend** (add `building_id, room_type, is_active`). Never drop. |
| `acad_timetable_weekdays` | 8 | `DayNo(1-7 MON-SUN, 8='-'), DayName`. | **Reuse** as the weekday lookup. |
| `acad_timetable` | 1,396 | Legacy lecture timetable keyed by `programme_code+course_code+study_year+acad_year+semester+lecturer_id+day+times+room+building+campusId`. Room/building are **free text/numeric mix**; **not** linked to `acad_programmecourses.ID`. | **Legacy, keep read-only.** Optional one-time import into the new model (§11). |
| `acad_teaching_allocation` | 15,626 | Huge "who teaches what/when/where" table (`staffCode, courseID, StartTime, EndTime, roomNo, lectureday, campusId, …`). Used by existing screens. | **Do not touch.** It is a separate concern (allocation/registration feed). New model does not depend on it. |
| `acad_coursework_timetable` | 12 | CAT/coursework schedule. | Out of scope (leave). Phase 2 could fold in. |
| `acad_exam_timetable` | — | Exam schedule. | Out of scope. |

**Why redesign rather than extend `acad_timetable`:** it is not anchored to the Programme-Course row (so we cannot cleanly attach one-to-many sessions to "the course × lecturer × programme"), its room/building are unstructured, and its semantics overlap confusingly with `acad_teaching_allocation`. The new model is a single, normalized source of truth that the user explicitly asked to hang off `NewProgrammeCourses`.

---

## 2. The anchor — a "Timetable Item" belongs to a Programme-Course

- A **Programme-Course** = one `acad_programmecourses` row (`ID`), i.e. *this course, in this programme, at this study-year/semester, with this lecturer*.
- A **Timetable Item** = one scheduled weekly session for that Programme-Course in a given **academic year**. One Programme-Course can have **many** items (e.g. a 4-hour course split into 2×2h on Mon & Wed; or lecture + tutorial + practical; or the same lecture repeated on two campuses).
- The item stores its own **academic year** (because `acad_programmecourses` is curriculum-level and reused across years) and overrides (teacher, campus, room) as needed.

```
acad_programmecourses (ID)  1 ──────< N  acad_timetable_item (programmecourse_id)
```

---

## 3. Data model (new tables + safe extensions)

All new objects live in `campus_dynamics` (with the anchor) so **both** eadmin and eportal reach them (eportal already reads `campus_dynamics.*` cross-DB, as ODEL does). All creation is **self-healing at runtime** (`CREATE TABLE IF NOT EXISTS` + guarded `ALTER TABLE ADD COLUMN`), mirroring `NewProgrammeCourses.aspx.cs`'s existing ensure-schema style — **no migration scripts to run on deploy**.

### 3.1 `acad_building` (NEW)
```sql
CREATE TABLE IF NOT EXISTS acad_building (
  building_id   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  building_name VARCHAR(120) NOT NULL,
  building_code VARCHAR(20)  NULL,
  campus_id     INT NOT NULL DEFAULT 0,     -- -> acad_campuses.ID (0=ALL)
  floors        INT NULL,
  notes         VARCHAR(300) NULL,
  is_active     TINYINT NOT NULL DEFAULT 1,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NULL,
  KEY ix_bldg_campus (campus_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 3.2 `acad_lecturerooms` (EXTEND — never drop the 47 existing rows)
Add via guarded `AddColumn`:
- `building_id INT NULL` → `acad_building.building_id`
- `room_type VARCHAR(20) NULL` (LECTURE / LAB / SEMINAR / HALL / OFFICE)
- `is_active TINYINT NOT NULL DEFAULT 1`
- `notes VARCHAR(300) NULL`

Existing columns kept: `RoomID, RoomName, Capacity, campusId`.

### 3.3 `acad_timetable_item` (NEW — the core)
```sql
CREATE TABLE IF NOT EXISTS acad_timetable_item (
  item_id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  programmecourse_id INT UNSIGNED NOT NULL,          -- -> acad_programmecourses.ID (the anchor)
  acad_year          CHAR(15) NOT NULL,              -- e.g. '2026/2027' (item is year-specific)
  -- denormalised anchor snapshot (for fast filtering / student & lecturer views without heavy joins)
  progcode           CHAR(15) NULL,
  course_code        CHAR(25) NULL,
  study_year         INT NULL,
  semester           INT NULL,
  -- WHEN
  day_no             INT NOT NULL,                   -- -> acad_timetable_weekdays.DayNo (1-7)
  start_time         TIME NOT NULL,
  duration_min       INT NOT NULL DEFAULT 60,
  end_time           TIME NOT NULL,                  -- = start_time + duration_min (set on save)
  -- WHO
  teacher_id         INT NULL,                       -- -> hrm_employee.empID; NULL => use pc.lecturer_id
  -- WHERE
  campus_id          INT NOT NULL DEFAULT 0,         -- -> acad_campuses.ID (0=ALL/Both)
  building_id        INT NULL,                       -- -> acad_building.building_id
  room_id            INT NULL,                       -- -> acad_lecturerooms.RoomID
  room_label         VARCHAR(80) NULL,               -- free-text fallback (Online / TBD / external)
  -- WHAT / HOW
  session_type       VARCHAR(15) NOT NULL DEFAULT 'LECTURE',  -- LECTURE|TUTORIAL|PRACTICAL|SEMINAR|CAT
  delivery_mode      VARCHAR(10) NOT NULL DEFAULT 'PHYSICAL',  -- PHYSICAL|ONLINE|HYBRID
  meet_link          VARCHAR(400) NULL,              -- for ONLINE/HYBRID (ties into ODEL lectures later)
  description        VARCHAR(400) NULL,
  -- lifecycle
  status             VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',    -- ACTIVE|CANCELLED
  created_by         VARCHAR(100) NULL,
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by         VARCHAR(100) NULL,
  updated_at         DATETIME NULL,
  KEY ix_tti_pc (programmecourse_id),
  KEY ix_tti_year (acad_year, semester),
  KEY ix_tti_teacher (teacher_id, acad_year, day_no),
  KEY ix_tti_room (room_id, acad_year, day_no),
  KEY ix_tti_cohort (progcode, study_year, semester, acad_year, day_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**Design notes**
- **Time**: store `start_time` (TIME) + `duration_min` (INT); compute and store `end_time` on save (`end_time = ADDTIME(start_time, SEC_TO_TIME(duration_min*60))`). Storing `end_time` too keeps overlap SQL simple and index-friendly.
- **Teacher default**: `teacher_id` NULL means "use the Programme-Course's `lecturer_id`". Effective teacher = `IFNULL(item.teacher_id, pc.lecturer_id)`.
- **Campus = Both**: `campus_id = 0 (ALL)`. When Both, a single physical room usually doesn't apply → `room_id` optional; use `room_label` or two items (one per campus). The manager UI nudges the user accordingly.
- **Denormalised `progcode/course_code/study_year/semester`**: copied from the anchor on save so student/lecturer views and the calendar filter fast without always joining `acad_programmecourses`. The anchor remains the source of truth; a lightweight resync runs on item save.
- **`meet_link` + `delivery_mode`**: forward hook to unify with the ODEL live-lecture module later (a physical timetable slot can also be the online session). Not required for v1 but cheap to include.

### 3.4 Nothing is stored for conflicts
Conflicts (room/lecturer/cohort double-booking) are **computed on demand** (§5), never stored — so they can never go stale.

---

## 4. Reused lookups & their semantics

- **Weekday** — `acad_timetable_weekdays.DayNo` (1=MON … 7=SUN). Item stores `day_no`; display uses `DayName`.
- **Campus** — `acad_campuses.ID`: `1=KAKEEKA`, `2=KIRUMBA`, `0=ALL` shown to the user as **"Both campuses"**. The manager's campus dropdown lists Kakeeka, Kirumba, Both.
- **Room** — `acad_lecturerooms.RoomID` (with `Capacity`, `campusId`, and new `building_id`). Selecting a room implies its campus & building.
- **Building** — new `acad_building`.

---

## 5. Conflict & validation engine (the "no room for error" core)

A shared `TimetableService` (eadmin `App_Code`) exposes conflict checks reused by every save/preview. All checks are **time-overlap on the same weekday within the same academic year**, `status='ACTIVE'`, excluding the item being edited.

Overlap predicate (two items A,B): `A.day_no=B.day_no AND A.acad_year=B.acad_year AND A.start_time < B.end_time AND B.start_time < A.end_time`.

1. **Room clash** — same `room_id` (non-null), overlapping. A room can't host two sessions at once.
2. **Lecturer clash** — same effective teacher (`IFNULL(teacher_id,pc.lecturer_id)`), overlapping. A lecturer can't be in two places.
3. **Cohort clash** — same `(progcode, study_year, semester)` **student cohort**, overlapping → students would be double-booked. (This is the subtle one most timetables get wrong.)
4. **Capacity note** (soft) — room `Capacity` vs the cohort's registered headcount (`acad_course_registration`/`acad_registration`) → warn if over.
5. **Campus/room mismatch** (soft) — room's `campusId` ≠ item `campus_id` (and item not Both) → warn.
6. **Sanity** — `duration_min > 0`, `end_time > start_time`, day 1-7, times within a configurable day window (e.g. 07:00–22:00).

Policy: **hard-block** on sanity errors; **warn + allow override (with confirm)** on clashes 1-5, because real institutions sometimes knowingly overlap (Both-campus, split streams). Every override is logged. The calendar (§6.3) paints clashes red so they're visible at a glance.

---

## 6. Screens

All eadmin screens use `~/COOPERP/NewScreens/SidebarMaster.master`, `vacConnectionString` (→ campus_dynamics), PageMethods AJAX, and the **NewScreens design system** (navy `#05275C`, accent `#174DA4`, square corners, FeesStructure.aspx card/modal/table/badge patterns). All eportal views use the ODEL/portal look (`odel.css` tokens, square corners). Icons in the main-dashboard style.

### 6.1 (Admin) `TimetableManager.aspx` — *copy of NewProgrammeCourses*
The heart of the module. Structurally clones `NewProgrammeCourses.aspx`:
- **Filter bar**: programme, course, lecturer, study-year, semester, **academic year** (new), campus, "has/needs timetable" toggle, search.
- **List**: one row per Programme-Course (course code + name, programme, study-year/sem, lecturer), plus a **"Sessions" count** column (how many timetable items it has for the selected acad-year) and a status chip (Scheduled / Not scheduled / Has conflicts).
- **Manage panel/modal** (per row): lists that Programme-Course's timetable items for the chosen acad-year, with **Add / Edit / Delete**. The item editor has every field from §3.3:
  - Day (dropdown MON-SUN), Start time, Duration (min) → live end-time preview.
  - Teacher (dropdown from `hrm_employee`, **defaulted to the course lecturer**, overridable).
  - Campus (Kakeeka / Kirumba / Both).
  - Building → Room (cascading; room list filtered by campus+building; shows capacity & free/busy for that slot), or free-text room label.
  - Session type, delivery mode (+ meet link when Online/Hybrid), description.
  - **Inline conflict preview**: as the user picks day/time/room/teacher, an AJAX `PreviewConflicts` call shows any room/lecturer/cohort clash before saving.
- **Bulk helpers**: "duplicate to another day", "copy last year's timetable for this course", "apply default room".
- Self-heal schema runs on first load (creates the 3 new objects), exactly like NewProgrammeCourses ensures its allocation columns.

### 6.2 (Admin) `RoomsBuildings.aspx` — resources controller
Two-tab screen (Buildings | Rooms):
- **Buildings**: CRUD `acad_building` (name, code, campus, floors, notes, active).
- **Rooms**: CRUD over `acad_lecturerooms` (name, capacity, campus, building, type, active).
- **Utilisation view**: per room, a weekly free/busy strip for a chosen acad-year (from `acad_timetable_item`) → instantly see which rooms are free when. "Find a free room" helper: pick day+time+campus+min-capacity → list available rooms.

### 6.3 (Admin) `TimetableCalendar.aspx` — the "calendar that shows locations"
A weekly grid (columns = MON-SUN, rows = time slots) rendered from `acad_timetable_item`, filterable by **acad-year, campus, building, room, programme, study-year, lecturer, course**. Two lenses:
- **By location**: choose a room/building → grid shows that venue's occupancy (who/what is where), free cells obvious.
- **By cohort/lecturer**: choose programme+year or a lecturer → their week.
- **Conflict overlay**: overlapping cells (room/lecturer/cohort) are outlined red with a tooltip listing the clash. Click a cell → jump to that item in the manager.

### 6.4 (Admin) `TimetableExport.aspx` — generation & export
Filter form (acad-year, semester, campus, programme, study-year, lecturer, room, day) → **generate** a print-optimised timetable:
- **HTML print** (adaptive, page-fit) reusing the transcript print approach (`TranscriptPrint`-style) — weekly grid or grouped list.
- **CSV/Excel** export of the filtered rows.
- **PDF** via the existing print-to-PDF path (browser) or DevExpress XtraReport (Phase 2).
Presets: "Programme timetable", "Lecturer load", "Room schedule", "Campus master timetable".

### 6.5 (Lecturer, eportal) `LecturerTimetable.aspx`
- Resolves the logged-in lecturer → `hrm_employee.empID` (via `usernames`, the existing resolver used by ODEL).
- Shows their **teaching load**: all `acad_timetable_item` where effective teacher = empID for the current acad-year/semester (with an acad-year switch).
- Weekly grid + list, per-session detail (course, programme, cohort, room, campus, join link if online), and **export** (HTML print / CSV).
- Linked from **MyTeaching** ("My timetable").

### 6.6 (Student, eportal) `StudentTimetable.aspx`
- Resolves regno → `acad_student.progid` + current `acad_registration` (`acad_year`, `semester`, `studyyear`).
- Shows **only their sessions**: items where `progcode=progid AND study_year=studyyear AND semester=semester AND acad_year=currentYear`, **intersected with the courses they actually registered** (`acad_course_registration` for that term) so electives they didn't take are excluded. Fallback to full programme-year set if no course picks found.
- Weekly grid + list + per-session detail (room, campus, lecturer, online link) + **export**.
- Linked from **MyLearning** ("My timetable") and shown as a compact "today / next class" widget on the ODEL student dashboard.

---

## 7. Backend architecture

- **eadmin**: each screen exposes PageMethods (`[WebMethod] static`) exactly like `NewProgrammeCourses.aspx.cs` (`ExecuteQuery`/`ExecuteNonQuery`/`ConnStrStatic` helpers, JSON dictionaries). Shared logic (conflict checks, effective-teacher, item CRUD, room free/busy, exports) lives in a new `App_Code/Timetable/TimetableService.cs` so the manager, calendar, rooms and export screens don't duplicate SQL.
- **eportal**: a small `App_Code/Timetable/TimetableRead.cs` (read-only) queries `campus_dynamics.acad_timetable_item` (+ joins to `acad_course`, `acad_campuses`, `acad_lecturerooms`, `acad_building`, `hrm_employee`) cross-DB, returning JSON for the lecturer/student pages (server-rendered first paint like ODEL). No writes from eportal.
- **Effective-teacher / room / campus resolution** is centralised (one SQL expression reused everywhere) to avoid drift.

Representative reads:
- Manager list: `acad_programmecourses pc LEFT JOIN (count of items) …` filtered.
- Student: join `acad_timetable_item` on denormalised cohort keys, intersect with `acad_course_registration`.
- Lecturer: `acad_timetable_item` where `IFNULL(teacher_id, pc.lecturer_id)=@e`.

---

## 8. Student / lecturer resolution (exact mapping)

- **Lecturer → empID**: `SELECT empID FROM hrm_employee WHERE usernames=@login` (same resolver ODEL uses). Effective teacher of an item = `IFNULL(item.teacher_id, pc.lecturer_id)`.
- **Student → cohort**: `acad_student.progid` = programme; current term from `acad_registration` (latest `acad_year`+`semester`, `studyyear`); actual courses from `acad_course_registration` (regno, courseID, acad_year, semester). Their timetable = items matching (progcode, study_year, semester, acad_year) **and** courseID ∈ their registrations.

---

## 9. Export / generation design

- Reuse the proven **adaptive HTML-print** approach (as in `TranscriptPrint.aspx`): a print stylesheet, page-fit scaling, MRU header. Two layouts: **weekly grid** (best for a single cohort/lecturer/room) and **grouped list** (best for master exports).
- **CSV** for spreadsheets. **PDF** via browser print or a Phase-2 XtraReport.
- Same generator on admin, lecturer and student sides — parameterised by the filter/identity — so output is consistent everywhere.

---

## 10. UI/UX consistency

- eadmin: `SidebarMaster.master`, NewScreens tokens, FeesStructure.aspx component patterns (cards, modal, filter toolbar, table, badges), **square corners**.
- eportal: `PortalMaster.master`, `odel.css` tokens (`--od-navy`, `--od-accent`, square corners), the same KPI-grid/ribbon idiom introduced for the ODEL dashboards, and the same weekly-grid component shared between lecturer & student.
- One shared weekly-grid CSS/JS component so admin, lecturer and student calendars look identical.

---

## 11. Coexistence with legacy (non-destructive)

- `acad_timetable`, `acad_teaching_allocation`, `acad_coursework_timetable`, `acad_exam_timetable` and their screens are **left intact and functional**. The new module writes only to `acad_timetable_item` / `acad_building` and the added `acad_lecturerooms` columns.
- **Optional one-time import** (admin-triggered, dry-run first): map `acad_timetable` rows → `acad_timetable_item` by matching `(programme_code, course_code, study_year, semester, acad_year)` to an `acad_programmecourses.ID`; carry day/time/room/building/campus. Rows that can't be matched to an anchor are reported, never force-created. This is a convenience, not a dependency.
- No screen or query that currently reads the legacy tables is modified.

---

## 12. Security & roles

- **Admins** (eadmin): full CRUD on items, rooms, buildings; run import/export. Gated by the existing eadmin auth + (optionally) the RBAC slug system.
- **Lecturers** (eportal): read-only, scoped to their own load.
- **Students** (eportal): read-only, scoped to their own registrations.
- All writes stamp `created_by/updated_by` (login) and, for overrides of conflict warnings, log the reason.

---

## 13. Edge cases & gotchas (must respect)

- **MySQL 5.6**: no `ADD COLUMN IF NOT EXISTS` → guard via `information_schema` (as NewProgrammeCourses already does). DDL auto-commits. One `CURRENT_TIMESTAMP` DATETIME default per table.
- **TIME as TIME, legacy as VARCHAR**: new model uses real `TIME`; don't mix with legacy varchar times. Overlap math uses `TIME` comparisons.
- **TRIM joins**: `course_code`/`progcode`/`regno` have legacy padding — `TRIM()` both sides on every cross-join.
- **Cross-DB (eportal)**: prefix `campus_dynamics.` for timetable tables from the portal (works, like ODEL's `campus_dynamics.acad_student`).
- **Campus 0 = Both**: never treat `campus_id=0` as a real venue; it means "runs on both campuses" (room optional).
- **Anchor is curriculum-level**: `acad_programmecourses` has no acad_year → the **item** must carry `acad_year`; never assume one timetable per programme-course across all years.
- **Duplicate/whitespace course codes** exist (`'BIT 1104'` vs `'BIT1104'`) — normalise with TRIM and match on the anchor `ID`, not on the raw code, wherever possible.
- **Square corners** on any inline styles.
- **Deploy**: all schema self-heals at runtime; nothing to run manually. Verify locally (root/24thdecember1977) with rolled-back transactions.

---

## 14. Phased task list

### Phase 0 — Schema & service scaffolding
- [ ] `TimetableService.EnsureSchema()` — create `acad_building`, `acad_timetable_item`; extend `acad_lecturerooms` (`building_id, room_type, is_active, notes`) via guarded AddColumn. Verify DDL locally.
- [ ] Conflict/effective-teacher SQL helpers + unit-style rolled-back tests.

### Phase 1 — Rooms & Buildings controller (`RoomsBuildings.aspx`)
- [ ] Buildings CRUD; Rooms CRUD (extend acad_lecturerooms); free/busy utilisation + "find a free room".

### Phase 2 — Timetable manager (`TimetableManager.aspx`, copy of NewProgrammeCourses)
- [ ] Filter bar + programme-course list with session counts + status chips.
- [ ] Per-record item editor (all §3.3 fields, cascading building→room, teacher default) with live `PreviewConflicts`.
- [ ] Save/edit/delete items; end_time compute; denormalised anchor snapshot; audit + override logging.
- [ ] Bulk helpers (duplicate day, copy last year, default room).

### Phase 3 — Calendar (`TimetableCalendar.aspx`)
- [ ] Shared weekly-grid component; by-location and by-cohort/lecturer lenses; conflict overlay; click-through to manager.

### Phase 4 — Export/generation (`TimetableExport.aspx`)
- [ ] Filter form; adaptive HTML print (grid + list); CSV; presets. Wire the same generator for reuse.

### Phase 5 — Lecturer view (eportal `LecturerTimetable.aspx`)
- [ ] `TimetableRead` cross-DB; empID resolution; weekly grid + list + export; link from MyTeaching.

### Phase 6 — Student view (eportal `StudentTimetable.aspx`)
- [ ] Cohort + registration intersection; weekly grid + list + export; link from MyLearning; "next class" widget.

### Phase 7 — Legacy import (optional) + polish
- [ ] Dry-run importer `acad_timetable → acad_timetable_item` with unmatched report; sidebar links; full compile + verification.

---

## 15. Open decisions (recommended defaults in **bold** — will proceed with these unless told otherwise)

1. **Conflict policy**: **warn + allow override with confirm** (vs hard-block). Sanity errors always block.
2. **Student scope**: **intersect programme-year-semester items with the student's actual `acad_course_registration`** (vs show all programme-year items). Fallback to full set when no course picks.
3. **New tables placement**: **`campus_dynamics`** (with the anchor), reached cross-DB from eportal.
4. **Lecturer/student pages**: **eportal** standalone pages linked from MyTeaching/MyLearning (vs eadmin), since lecturers & students live in the portal.
5. **Time storage**: **`start_time` + `duration_min`, with `end_time` computed & stored** (vs start/end only).
6. **Legacy import**: **build it but run only on explicit admin action, dry-run first** (vs auto-migrate).
7. **Export formats v1**: **HTML print + CSV** (PDF via browser print; DevExpress XtraReport deferred to Phase 2).
8. **Naming**: new item table **`acad_timetable_item`** (distinct from legacy `acad_timetable`), buildings **`acad_building`**, rooms stay **`acad_lecturerooms`** (extended).
