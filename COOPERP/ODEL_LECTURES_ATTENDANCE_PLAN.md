# ODEL — Online Lectures, Roll‑Calling & Communications

**Plan of tasks + implementation & integration design**
Muteesa I Royal University (MRU) · eportal ODEL module
Status: PLAN (nothing built yet) · Author: engineering · Date: 2026‑07‑18

---

## 0. What we are building

Five tightly‑integrated additions to the existing ODEL (e‑learning) module, all living on the lecturer's **CourseManage** hub and the student's **CourseSpace** page, keyed by `?space=<courseSpaceId>` like everything else in ODEL:

1. **Online Lectures** — a lecturer schedules a lecture; it moves through **Pending → Live → Ended** (plus Cancelled). It carries an online **meeting link**, attached **resources** (files/links/library materials/notes), and supports **calendar‑style recurrence** (generate many independently‑editable instances up to a *close date*). Students **view** the schedule and **join** live sessions.
2. **Digital roll‑calling** — under each lecture the lecturer opens a **roll‑call console** built from the *expected‑students pool* (the approved roster), toggles Present/Absent per student (**auto‑saved**), and can **open a self‑check‑in window** with a close time so students mark **themselves** present from their portal.
3. **Teacher Zoom link** — each lecturer has a saved default meeting room that pre‑fills new lectures; per‑lecture override allowed.
4. **Communications / Course Updates** — the lecturer posts notes/announcements to the course; students read them in a dedicated **Updates tab** with an **unread badge**.
5. **Summaries** — a re‑imagined, better‑organised **course‑home overview** (both lecturer and student) that folds in the new lecture / attendance / updates signals.

### Non‑negotiable design principles (reuse, don't reinvent)

- **One dispatch, one convention.** Every new endpoint is a `case "ns.verb":` in `OdelApi.ashx`'s `switch`, returning a JSON string from a static method. GET = read, POST = write (JSON body). New service files: `OdelLectureService.cs` (lectures + attendance) and `OdelCommsService.cs` (updates). Teacher meeting link lives with lectures.
- **Self‑healing schema.** No migration scripts. Add `OdelCore.EnsureLectureSchema(conn)` and `EnsureCommsSchema(conn)` following the existing `_...Ensured` guard + `CREATE TABLE IF NOT EXISTS` + `AddColumn(...)` (information_schema probe) pattern. Call them at the top of the first service method that touches those tables.
- **Same auth spine.** Lecturer writes go through `StaffAuth(conn, spaceId, out empid, out err)` → `StaffOnSpace`. Student reads/writes verify the caller is an **APPROVED** roster member (`lecturer_status='APPROVED'`) exactly like `StudentSpace`/`IsEnrolled`.
- **Same roster.** The "expected students" pool is the canonical query already used by `TeachingRoster` / `AssignmentStudents`: `acad_course_registration cr … lecturer_status='APPROVED'` LEFT JOIN `campus_dynamics.acad_student s` on `TRIM(regno)`, name = `TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')))`.
- **Same DB.** All new `odel_*` tables live in `campus_dynamics_portal` (via `OdelCore.ConnStr()`), alongside `acad_course_registration`. Cross‑DB reads to `campus_dynamics.acad_student` / `acad_course` / `hrm_employee` use explicit `campus_dynamics.` prefixes.
- **Same look.** Square corners (`border-radius:0`), `odel.css` tokens (`--od-navy #05275C`, `--od-accent #174DA4`, `--od-ok`, `--od-warn`, `--od-err`), `.od-*` components, `Odel.tabs/dropzone/state/toast/loader/ic`. Icons already available: `clock, check, warn, file, page, link, video, image, clip, plus, edit, trash, eye, gear, copy, publish`.
- **Audit everything.** Every state change calls `OdelCore.Log(actorType, actorRef, spaceId, verb, objType, objId, detail)` (e.g. `"STAFF", empid, spaceId, "LECTURE_STARTED", "lecture", lectureId, ""`).
- **Lazy lifecycle.** Mirror the assignment auto‑archive trick: on every list read, a cheap sweep auto‑ends past lectures and auto‑closes expired self‑check‑in windows — no cron needed.

---

## 1. Feature — Online Lectures

### 1.1 Concept & lifecycle

A **lecture** is a single scheduled session belonging to a course space. Statuses (stored as `VARCHAR(10)`):

| Status | Meaning | Set by |
|---|---|---|
| `PENDING` | Scheduled, not yet started (the default on create) | create / edit |
| `LIVE` | Lecturer pressed **Start** — session is on air, joinable, roll‑call active | `lecture.setstatus` |
| `ENDED` | Lecturer pressed **End**, or auto‑ended past its window | `lecture.setstatus` / sweep |
| `CANCELLED` | Called off; kept for the record, greyed out to students | `lecture.setstatus` |

Transitions: `PENDING → LIVE → ENDED`; `PENDING|LIVE → CANCELLED`. Starting stamps `actual_start`; ending stamps `actual_end` **and** force‑closes any open self‑check‑in. A "join" is offered from `scheduled_start − 10 min` while not ENDED/CANCELLED.

**Auto‑sweep (on `lecture.list`):** any `PENDING`/`LIVE` lecture with `scheduled_end < NOW() − 30 min` grace → `ENDED` (`auto_ended=1`); any lecture with `attendance_close_at < NOW()` → `attendance_open=0`. Same idea as `AssignmentList`'s archive sweep.

### 1.2 Meeting link + provider

- Free‑text `meet_link` (URL). `meet_provider` (`ZOOM|MEET|TEAMS|OTHER`) is auto‑detected from the host (`zoom.us`, `meet.google.com`, `teams.microsoft.com`) but overridable.
- New lecture pre‑fills `meet_link` from the lecturer's saved default (see §3). Per‑lecture override always wins.
- Optional physical `location` for hybrid/in‑person sessions (roll‑call still works without a link).

### 1.3 Resources ("important relevant things")

Each lecture can carry an ordered list of resources (`odel_lecture_resource`), each one of:

- **LINK** — title + URL (readings, slides on Drive, external video)
- **FILE** — uploaded via `Odel.dropzone` → `OdelUpload.ashx` → `file_id` (reuse `odel_file`)
- **MATERIAL** — reference an existing library item (`material_id` → `odel_material`) so lecture prep reuses the content library
- **NOTE** — a short rich/plain text note shown inline (agenda, instructions)

Students see resources on the lecture card; FILE/MATERIAL open in the existing CourseSpace **material viewer modal** (`window.CS.open`), LINK opens in a new tab.

### 1.4 Recurrence — "just like a calendar", independent instances

The lecturer can create **one** lecture or a **recurring series**. A series is a *generator*, not a live link: it spawns **separate `odel_lecture` rows** (each fully editable/deletable on its own) and stamps `series_id` so they can be managed together when wanted.

Series editor fields:
- Title, description, meeting link (defaults from teacher link)
- **Repeat:** `WEEKLY` (default) / `BIWEEKLY` / `DAILY`
- **Days of week:** Mon–Sun checkboxes (weekly/biweekly)
- **Start time** + **duration** (minutes)
- **Start date** and **Until date** — *"the day it will close"*
- Optional **skip dates** (holidays)

Generation (server, `lecture.series.save`): iterate `start_date … until_date`; on each matching weekday create a `PENDING` `odel_lecture` (skip explicit skip‑dates), **capped at 60 instances** (guard against runaway; report how many were created + if capped). Each generated instance is standalone afterwards.

Editing a series row later offers scope: **This lecture** (default) / **This + all future in series** / **Entire series** — like Google Calendar. Delete offers the same scopes. "This lecture" edits/deletes never touch siblings.

### 1.5 Lecturer UI — `Lectures.aspx?space=<id>` (new page)

Follows the **BuildContent/BuildAssignment** house pattern: server embeds init JSON, `odel.js` renders client‑side, writes are AJAX + re‑render. Sections:

- **Header** (`.od-hd`): course code · title · term · a **LIVE NOW** chip if any lecture is live.
- **Toolbar:** `+ Schedule lecture`, `+ Recurring series`, `Set my meeting link`, filter chips **Upcoming / Live / Past / All**, search.
- **Agenda / calendar list:** grouped by day (Today, Tomorrow, This week, later; then Past). Each lecture is a card:
  - time range, title, status badge (Pending amber / Live green pulsing / Ended grey / Cancelled red‑muted), attendance summary (`23/40 present`), resource count.
  - actions (kebab, reuse the `.mc-menu`‑style popup idea → here `.od-menu`): **Start / End / Cancel**, **Edit**, **Roll‑call**, **Open self check‑in**, **Copy link**, **Delete**.
- **Lecture editor modal:** title, date, start, duration, meeting link (+detected provider), location, description, resources builder (dropzone + add‑link + pick‑from‑library + add‑note, drag‑order).
- **Roll‑call drawer/modal** — see §2.4.

### 1.6 Student UI — CourseSpace "Lectures" tab

`OdelService.StudentSpace` is extended to include a `lectures` array + `updates` + counters (§5.3). CourseSpace gains lightweight `Odel.tabs`: **Work** (current materials+assignments view) · **Lectures** · **Updates**. The Lectures tab shows:
- **Live now** banner with a big **Join** button when a lecture is `LIVE` (or joinable window open).
- **Upcoming** list: date/time, title, countdown ("in 2h 15m"), Join (enabled in window), resources, "Add to calendar" (.ics download — nice‑to‑have).
- **Past** list: date, title, **your attendance** (Present/Absent/Not recorded), resources (recording link if the lecturer added one as a resource).
- **Self‑check‑in** call‑to‑action when a window is open (see §2.5).

---

## 2. Feature — Digital Roll‑Calling (Attendance)

### 2.1 Model

One row per (lecture, student) in `odel_attendance`, upserted on every toggle:

- `status`: `PRESENT | ABSENT | LATE | EXCUSED` (lecturer set) — plus the *implicit* "not recorded" = no row.
- `method`: `MANUAL` (lecturer) | `SELF` (student self‑check‑in).
- `marked_by`: empid (manual) or `SELF`; `marked_at`; optional `note`.
- Unique key `(lecture_id, regno)` → upsert = `INSERT … ON DUPLICATE KEY UPDATE`.

### 2.2 Expected‑students pool

Exactly the approved roster (`RollRoster`), reusing the `TeachingRoster` spine:
```sql
SELECT cr.regno,
       TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) nm,
       IFNULL(s.email,'') email
FROM acad_course_registration cr
LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(cr.regno)
WHERE TRIM(cr.courseID)=TRIM(@c) AND cr.acad_year=@y AND cr.semester=@sem
  AND cr.lecturer_status='APPROVED'
ORDER BY nm
```
LEFT JOIN `odel_attendance` on `(lecture_id, regno)` to fold in each student's current mark. Returns per student: `regno, name, email, status(''=unmarked), method, markedAt`.

### 2.3 Rules

- Only **APPROVED** roster members are expected/markable (keeps parity with the rest of ODEL gating; Pending/Removed students never appear).
- Marking is idempotent auto‑save; toggling PRESENT↔ABSENT just updates the row.
- Attendance is editable by the lecturer at any time (even after ENDED) — the record is authoritative, corrections happen.
- Attendance does **not** affect marks in v1 (flagged as a future option, §14).

### 2.4 Roll‑call console (lecturer)

Opened from a lecture ("Roll‑call"). Shows:
- Live counters: **Present / Absent / Not recorded / Total** + a big **rate %** and a thin meter (`.od-meter`).
- Search + filter (All / Present / Absent / Unmarked).
- Per‑student row: name, regno, a **Present / Absent** segmented toggle (auto‑saves via `lecture.attend.mark`), self‑check‑in badge if `method=SELF`.
- Bulk: **Mark all present**, **Mark all absent**, **Clear** (with confirm) via `lecture.attend.bulk`.
- **Export CSV** of the sheet (nice‑to‑have).
- **Self‑check‑in control** (§2.5).

### 2.5 Self‑check‑in ("lecturer opens the session for self roll‑call")

- Lecturer clicks **Open self check‑in**, picks a **close time** (quick chips: 5 / 10 / 15 min, or custom) → `lecture.attend.open` sets `attendance_open=1`, `attendance_close_at`, `attendance_opened_by/at`. Optional **check‑in code** (4‑digit) the lecturer reads out, to deter proxy check‑ins.
- While open, the student's CourseSpace Lectures tab shows a prominent **"I'm present"** button (+ code field if enabled) and a live countdown. Clicking → `student.attend.selfcheckin`:
  - verifies caller is APPROVED on this space, the lecture belongs to the space, `attendance_open=1`, `NOW() < attendance_close_at`, code matches (if set), and no existing PRESENT row → upsert `PRESENT, method='SELF'`.
  - returns friendly errors (window closed / already checked in / wrong code).
- The lecturer console reflects self‑check‑ins as they arrive (poll every ~10s while open, or manual refresh).
- **Close now** (`lecture.attend.close`) or auto‑close at `attendance_close_at` (sweep). After close, students who didn't check in stay "not recorded" until the lecturer optionally bulk‑marks the rest absent.

---

## 3. Feature — Teacher Zoom / Meeting link

- `odel_staff_meeting(empid PK, provider, meet_link, personal_note, updated_at)` — one saved default room per lecturer.
- `lecture.meeting.get` / `lecture.meeting.save` (from the Lectures page "Set my meeting link").
- On **new lecture** (and new series), the editor pre‑fills `meet_link` from this default; the lecturer can override per lecture.
- **Course‑level default (optional):** add `default_meet_link` column to `odel_course_space` so a space can pin its own room (used if the lecturer has no personal default). Precedence: per‑lecture → course default → teacher default → blank.

---

## 4. Feature — Communications / Course Updates

### 4.1 Model

`odel_course_update` — an announcement/note posted to a course:
- `id, space_id, title, body (HTML), pinned TINYINT, is_published TINYINT, created_by (empid), author_name, created_at, updated_at`.

`odel_update_read` — read receipts for the unread badge:
- `id, update_id, regno, read_at`, unique `(update_id, regno)`.

### 4.2 Lecturer UI

Reuse the Lectures page as a two‑mode hub, **or** a small dedicated `CourseUpdates.aspx?space=<id>` (recommended: a tab on the Lectures page to avoid page sprawl — "Lectures" | "Updates"). Compose/edit an update (title + rich text), pin/unpin, publish/unpublish, delete. Shows how many students have read each update (`COUNT` from `odel_update_read`) — a light engagement signal.

API: `update.list`, `update.save`, `update.pin`, `update.delete`.

### 4.3 Student UI — "Updates" tab (the "special tab")

- CourseSpace **Updates** tab lists published updates, pinned first, newest next; each shows author, date, body.
- Opening the tab (or an update) fires `student.update.read` → marks read; the tab's **unread count badge** clears.
- Unread count is surfaced in three places for "perfect integration":
  1. the CourseSpace Updates tab label (`Updates •3`),
  2. the MyLearning course tile (a small dot/'•N' on courses with unread updates),
  3. optional email on new post (reuse `OdelNotify` email pattern; default **off** or throttled to avoid noise — see §13).

---

## 5. Feature — Summaries redesign (course home)

### 5.1 Lecturer overview (`CourseManage` upgrade)

Keep CourseManage server‑rendered, but re‑organise `Build()` around the new signals from an extended `CourseDashboard`:

- **Hero strip:** course code · title · term · status; a **● LIVE NOW — Join/Manage** ribbon if a lecture is live; else **Next lecture: Thu 10:00 (in 2d)**.
- **KPI grid** (`.od-kpis`): Students · Materials · Assignments · To‑grade · CW weight · **Lectures (upcoming)** · **Attendance rate** · **Updates (unread by class)**.
- **This week agenda:** next 3–5 upcoming lectures as compact rows (time, title, join, roll‑call).
- **Engagement snapshot:** attendance‑rate meter (avg present ÷ expected across ENDED lectures), submission rate, materials published — small horizontal meters.
- **Setup checklist** (existing) + new items: *Meeting link set*, *At least one upcoming lecture*, *Posted an update this week*.
- **Manage links** (existing hub) + new: **Live lectures & attendance** (`Lectures.aspx`), **Course updates**.

New stats computed in `CourseDashboard`: `liveLecture`, `nextLecture{when,title,id}`, `upcomingLectures`, `attendanceRate`, `endedLectures`, `updates`, `unreadUpdatesClass`.

### 5.2 Student course home (CourseSpace "Work"/overview)

Enrich the existing `cs-kpi` strip + add a top **"At a glance"** block:
- **Next lecture** countdown + Join (if in window); **Live now** banner when applicable.
- **Your attendance:** % present across past lectures + Present/Absent counts.
- **To do:** pending assignments / overdue (already computed).
- **Unread updates:** count → jumps to Updates tab.

### 5.3 Data plumbing

- Extend `OdelService.StudentSpace` JSON with `lectures[]`, `updates[]`, `unreadUpdates`, `attendance{present,total,rate}`, `liveLecture`, `nextLecture`.
- Extend `OdelService.CourseDashboard` JSON with the lecturer stats above.
- Both reuse small scalar helpers (`ScalarSp`) already present.

---

## 6. Data model (DDL) — all `CREATE TABLE IF NOT EXISTS`, InnoDB, no hard FKs, indexed

> Engine InnoDB; no cross‑engine/cross‑DB foreign keys (ODEL convention). Enums stored as `VARCHAR`. All timestamps `DATETIME`. Self‑heal via `EnsureLectureSchema` / `EnsureCommsSchema` + `AddColumn` probes.

```sql
-- 6.1 Lecture (single instance; recurrence produces many of these)
CREATE TABLE IF NOT EXISTS odel_lecture (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  space_id        INT NOT NULL,
  series_id       INT NULL,                 -- groups a recurring set (nullable)
  title           VARCHAR(200) NOT NULL,
  description      TEXT NULL,               -- agenda / notes (HTML or plain)
  meet_link       VARCHAR(500) NULL,
  meet_provider   VARCHAR(10)  NULL,        -- ZOOM|MEET|TEAMS|OTHER
  location        VARCHAR(200) NULL,        -- optional physical venue (hybrid)
  scheduled_start DATETIME NOT NULL,
  scheduled_end   DATETIME NOT NULL,
  status          VARCHAR(10) NOT NULL DEFAULT 'PENDING', -- PENDING|LIVE|ENDED|CANCELLED
  actual_start    DATETIME NULL,
  actual_end      DATETIME NULL,
  auto_ended      TINYINT NOT NULL DEFAULT 0,
  attendance_open TINYINT NOT NULL DEFAULT 0,
  attendance_close_at DATETIME NULL,
  attendance_code VARCHAR(12) NULL,         -- optional self check-in code
  attendance_opened_by INT NULL,
  attendance_opened_at DATETIME NULL,
  is_published    TINYINT NOT NULL DEFAULT 1, -- visible to students (allow drafts=0)
  created_by      INT NOT NULL,             -- empid
  created_at      DATETIME NOT NULL,
  updated_at      DATETIME NOT NULL,
  KEY ix_lec_space (space_id, scheduled_start),
  KEY ix_lec_series (series_id),
  KEY ix_lec_status (space_id, status)
);

-- 6.2 Recurring series template (generator only)
CREATE TABLE IF NOT EXISTS odel_lecture_series (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  space_id      INT NOT NULL,
  title         VARCHAR(200) NOT NULL,
  description    TEXT NULL,
  meet_link     VARCHAR(500) NULL,
  repeat_kind   VARCHAR(10) NOT NULL DEFAULT 'WEEKLY', -- WEEKLY|BIWEEKLY|DAILY
  days_mask     INT NOT NULL DEFAULT 0,     -- bitmask Mon=1..Sun=64
  start_time    TIME NOT NULL,
  duration_min  INT NOT NULL DEFAULT 60,
  start_date    DATE NOT NULL,
  until_date    DATE NOT NULL,              -- "the day it will close"
  skip_dates    TEXT NULL,                  -- CSV of yyyy-mm-dd to skip
  created_by    INT NOT NULL,
  created_at    DATETIME NOT NULL,
  KEY ix_series_space (space_id)
);

-- 6.3 Lecture resources (attachments / relevant things)
CREATE TABLE IF NOT EXISTS odel_lecture_resource (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  lecture_id  INT NOT NULL,
  kind        VARCHAR(10) NOT NULL,         -- LINK|FILE|MATERIAL|NOTE
  title       VARCHAR(200) NULL,
  url         VARCHAR(600) NULL,
  file_id     INT NULL,                     -- -> odel_file
  material_id INT NULL,                     -- -> odel_material (library reuse)
  note_text   TEXT NULL,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  DATETIME NOT NULL,
  KEY ix_res_lec (lecture_id, sort_order)
);

-- 6.4 Attendance (one row per student per lecture; upsert)
CREATE TABLE IF NOT EXISTS odel_attendance (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  lecture_id INT NOT NULL,
  regno      VARCHAR(40) NOT NULL,
  status     VARCHAR(10) NOT NULL DEFAULT 'PRESENT', -- PRESENT|ABSENT|LATE|EXCUSED
  method     VARCHAR(8)  NOT NULL DEFAULT 'MANUAL',  -- MANUAL|SELF
  marked_by  VARCHAR(40) NULL,             -- empid or 'SELF'
  marked_at  DATETIME NOT NULL,
  note       VARCHAR(200) NULL,
  UNIQUE KEY uq_att (lecture_id, regno),
  KEY ix_att_reg (regno)
);

-- 6.5 Teacher default meeting room
CREATE TABLE IF NOT EXISTS odel_staff_meeting (
  empid       INT PRIMARY KEY,
  provider    VARCHAR(10) NULL,
  meet_link   VARCHAR(500) NULL,
  personal_note VARCHAR(200) NULL,
  updated_at  DATETIME NOT NULL
);

-- 6.6 Course updates (communications)
CREATE TABLE IF NOT EXISTS odel_course_update (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  space_id    INT NOT NULL,
  title       VARCHAR(200) NOT NULL,
  body        MEDIUMTEXT NULL,
  pinned      TINYINT NOT NULL DEFAULT 0,
  is_published TINYINT NOT NULL DEFAULT 1,
  created_by  INT NOT NULL,
  author_name VARCHAR(150) NULL,
  created_at  DATETIME NOT NULL,
  updated_at  DATETIME NOT NULL,
  KEY ix_upd_space (space_id, pinned, created_at)
);

-- 6.7 Update read receipts (unread badge)
CREATE TABLE IF NOT EXISTS odel_update_read (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  update_id INT NOT NULL,
  regno     VARCHAR(40) NOT NULL,
  read_at   DATETIME NOT NULL,
  UNIQUE KEY uq_read (update_id, regno)
);

-- 6.8 Optional column on the space (course-level default room)
-- via AddColumn(conn,"odel_course_space","default_meet_link","VARCHAR(500) NULL")
```

---

## 7. API action catalogue (new `OdelApi.ashx` cases)

| Action (`ns.verb`) | Method | Handler (returns JSON string) | Who |
|---|---|---|---|
| `lecture.list` | GET | `OdelLectureService.List(spaceId, filter, q)` | staff |
| `lecture.get` | GET | `OdelLectureService.Get(spaceId, id)` | staff |
| `lecture.save` | POST | `OdelLectureService.Save(spaceId, json)` | staff |
| `lecture.series.save` | POST | `OdelLectureService.SaveSeries(spaceId, json)` | staff |
| `lecture.setstatus` | POST | `OdelLectureService.SetStatus(spaceId, id, status)` | staff |
| `lecture.delete` | POST | `OdelLectureService.Delete(spaceId, id, scope)` | staff |
| `lecture.resource.save` | POST | `OdelLectureService.ResourceSave(spaceId, lectureId, json)` | staff |
| `lecture.resource.delete` | POST | `OdelLectureService.ResourceDelete(spaceId, id)` | staff |
| `lecture.resource.reorder` | POST | `OdelLectureService.ResourceReorder(spaceId, lectureId, idsCsv)` | staff |
| `lecture.roster` | GET | `OdelLectureService.RollRoster(spaceId, lectureId)` | staff |
| `lecture.attend.mark` | POST | `OdelLectureService.MarkAttendance(spaceId, lectureId, regno, status)` | staff |
| `lecture.attend.bulk` | POST | `OdelLectureService.MarkAll(spaceId, lectureId, status)` | staff |
| `lecture.attend.open` | POST | `OdelLectureService.OpenSelfCheckin(spaceId, lectureId, minutes, code)` | staff |
| `lecture.attend.close` | POST | `OdelLectureService.CloseSelfCheckin(spaceId, lectureId)` | staff |
| `lecture.meeting.get` | GET | `OdelLectureService.GetMyMeeting()` | staff |
| `lecture.meeting.save` | POST | `OdelLectureService.SaveMyMeeting(link, provider, note)` | staff |
| `student.lectures` | GET | `OdelLectureService.StudentLectures(spaceId)` | student |
| `student.attend.selfcheckin` | POST | `OdelLectureService.SelfCheckin(spaceId, lectureId, code)` | student |
| `update.list` | GET | `OdelCommsService.List(spaceId)` | staff |
| `update.save` | POST | `OdelCommsService.Save(spaceId, json)` | staff |
| `update.pin` | POST | `OdelCommsService.Pin(spaceId, id, pinned)` | staff |
| `update.delete` | POST | `OdelCommsService.Delete(spaceId, id)` | staff |
| `student.updates` | GET | `OdelCommsService.StudentUpdates(spaceId)` | student |
| `student.update.read` | POST | `OdelCommsService.MarkRead(spaceId, updateId)` | student |

All staff handlers begin with `StaffAuth(conn, spaceId, out empid, out err)`; all student handlers resolve `regno` from session and verify APPROVED membership on the space before doing anything.

---

## 8. New / changed files

**New backend**
- `App_Code/Odel/OdelLectureService.cs` — lectures, resources, attendance, teacher meeting link.
- `App_Code/Odel/OdelCommsService.cs` — course updates + read receipts.

**Changed backend**
- `OdelApi.ashx` — add the ~24 `case` lines from §7.
- `App_Code/Odel/OdelCore.cs` — add `EnsureLectureSchema(conn)`, `EnsureCommsSchema(conn)` (with `_lectureSchemaEnsured` / `_commsSchemaEnsured` guards), and (optional) `default_meet_link` AddColumn on space.
- `App_Code/Odel/OdelService.cs` — extend `StudentSpace` (lectures/updates/attendance/unread) and `CourseDashboard` (lecture/attendance/updates stats).
- `App_Code/Odel/OdelNotify.cs` — optional `LectureScheduled` / `UpdatePosted` email helpers (mirroring `AssignmentPublished`), throttled.

**New frontend**
- `Lectures.aspx` (+ `.cs`) — lecturer lectures + roll‑call + updates hub (tabs: Lectures | Updates | My meeting link). Client‑rendered with `odel.js`.
- CSS: extend `odel/odel.css` with `.od-lec*`, `.od-roll*`, `.od-cal*`, `.od-upd*` component classes (square, tokenised). No new stylesheet.

**Changed frontend**
- `CourseManage.aspx(.cs)` — richer overview (§5.1) + two new hub links.
- `CourseSpace.aspx(.cs)` — add `Odel.tabs` (Work | Lectures | Updates), render lectures/updates/self‑check‑in from extended `StudentSpace` JSON, reuse the material‑viewer modal for lecture resources.
- `MyTeaching.aspx.cs` — (optional) surface "next lecture / live now" on the teaching tile.
- `MyLearning.aspx.cs` — (optional) unread‑updates dot on course tiles.

---

## 9. Security, auth & integrity

- **Lecturer actions:** `StaffAuth(conn, spaceId, …)` → `StaffOnSpace` (space‑staff **or** assigned `acad_programmecourses` lecturer). Every mutating handler re‑checks the object belongs to `spaceId` (e.g. `WHERE l.id=@id AND l.space_id=@sp`) so IDs can't be cross‑tenanted.
- **Student actions:** resolve `regno` from session; verify `lecturer_status='APPROVED'` membership on the space (same guard as `IsEnrolled`) before any read/write. Self‑check‑in additionally verifies window‑open + not‑expired + code.
- **Roster truth:** only APPROVED students are expected/markable/able‑to‑self‑check‑in, keeping attendance consistent with the module‑wide gating.
- **Idempotency:** attendance and read‑receipts use `INSERT … ON DUPLICATE KEY UPDATE` on their unique keys; self‑check‑in is a no‑op if already PRESENT.
- **Audit:** `OdelCore.Log` on create/edit/delete, start/end/cancel, open/close check‑in, bulk mark, update post/delete.

---

## 10. Auto‑lifecycle sweeps (no cron)

Run cheaply at the top of `lecture.list` / `student.lectures` (guarded to one UPDATE each):
1. `UPDATE odel_lecture SET status='ENDED', auto_ended=1 WHERE space_id=@sp AND status IN ('PENDING','LIVE') AND scheduled_end < NOW() - INTERVAL 30 MINUTE`.
2. `UPDATE odel_lecture SET attendance_open=0 WHERE space_id=@sp AND attendance_open=1 AND attendance_close_at < NOW()`.
Mirrors the proven `AssignmentList` auto‑archive approach; keeps statuses honest without a scheduler.

---

## 11. Notifications (email only — no mobile push exists)

Reuse `EmailSenderProtocol.SendHtmlEmail(to, name, subject, body)` and the `OdelNotify` fire‑and‑forget `ThreadPool` pattern, logging to `odel_notification_log`:
- **New single lecture** → optional email to APPROVED students. **Recurring series → send ONE digest**, never one email per generated instance (spam guard).
- **New course update** → optional email; **default OFF**, or a per‑post "Notify students" checkbox so the lecturer opts in.
- In‑app is always the primary channel (Updates tab + unread badges).

---

## 12. Reused vs new — integration map

| Need | Reuse | New |
|---|---|---|
| Dispatch/routing | `OdelApi.ashx` switch | +24 cases |
| Auth | `StaffAuth`, `StaffOnSpace`, `StaffEmpId` | — |
| Roster/pool | `TeachingRoster` spine | `RollRoster` (roster ⨝ attendance) |
| Schema self‑heal | `AddColumn`, `CREATE IF NOT EXISTS`, `_...Ensured` | `EnsureLectureSchema`, `EnsureCommsSchema` |
| File attach | `Odel.dropzone` → `OdelUpload.ashx` → `odel_file` | `odel_lecture_resource` |
| Library reuse | `odel_material` | resource `MATERIAL` kind |
| Viewer modal | CourseSpace `window.CS.open` | reuse for lecture resources |
| Tabs/UI kit | `Odel.tabs`, `.od-*`, tokens, icons | `.od-lec/.od-roll/.od-upd` |
| Audit | `OdelCore.Log` | new verbs |
| Email | `EmailSenderProtocol`, `OdelNotify` | optional `LectureScheduled`/`UpdatePosted` |
| Summaries | `CourseDashboard`, `StudentSpace` | extended stats |

---

## 13. Edge cases & gotchas

- **MySQL 5.6:** no `ADD COLUMN IF NOT EXISTS` → use `AddColumn` probe. DDL implicit‑commits. Don't reference a temp table twice in one query. Can't UPDATE a table referenced in its own subquery (1093).
- **C# 5 / .NET 4.0 Web Forms:** no string interpolation, no `?.`, no auto‑property initializers. Verify with `csc.exe` + brace/paren balance (filter cross‑file CS0246/CS0103).
- **Cross‑DB:** `odel_*` + `acad_course_registration` in `campus_dynamics_portal`; `acad_student`/`acad_course`/`hrm_employee`/`acad_programmecourses` in `campus_dynamics` — always prefix.
- **TRIM joins:** regno/courseID joins must `TRIM(...)` both sides (legacy padding) — reuse the exact roster expression.
- **Recurrence cap:** hard‑cap generated instances (60) and report truncation via `log()` — never silently drop.
- **Timezone:** store/compare in server local time (`NOW()`), consistent with existing `due_at` handling; render human times client‑side.
- **Self‑check‑in abuse:** optional code + single‑window + APPROVED‑only. (Geo/IP fencing explicitly out of scope v1.)
- **Deleting a series:** default "this only"; "all/future" scopes must be explicit and confirmed.
- **Square corners:** any inline styles emitted from code‑behind use `border-radius:0`.
- **Production reachability:** all DDL is self‑heal at runtime; nothing to run manually on deploy. Verify locally (root/24thdecember1977) with rolled‑back transactions.

---

## 14. Deliberately deferred (v2 candidates)

- Attendance → **mark impact** (e.g. attendance % feeds a participation component) — schema is ready (`odel_attendance`), wiring deferred.
- **Recording auto‑attach** (Zoom cloud recording API) — for now, lecturer pastes the recording as a LINK resource on the ended lecture.
- **.ics calendar export** / external calendar sync.
- **Live attendee sync** from the meeting provider (Zoom participant API) → auto roll‑call.
- **Mobile push** (no infra today; email only).

---

## 15. Phased task list

### Phase 0 — Schema & scaffolding
- [ ] `OdelCore.EnsureLectureSchema(conn)` — tables 6.1–6.5 + `_lectureSchemaEnsured` guard.
- [ ] `OdelCore.EnsureCommsSchema(conn)` — tables 6.6–6.7 + guard.
- [ ] (Optional) `AddColumn` `odel_course_space.default_meet_link`.
- [ ] Verify DDL locally (rolled‑back tx), confirm indexes, confirm no dup‑create.

### Phase 1 — Lectures backend
- [ ] `OdelLectureService.cs`: `List` (+auto‑sweep), `Get`, `Save`, `SaveSeries` (generation + cap), `SetStatus`, `Delete` (scopes), resource CRUD + reorder.
- [ ] Provider auto‑detect helper; teacher meeting `Get/Save`; course/teacher/lecture link precedence.
- [ ] Wire `lecture.*` cases into `OdelApi.ashx`; `OdelCore.Log` on each mutation.

### Phase 2 — Roll‑calling backend
- [ ] `RollRoster` (roster ⨝ attendance), `MarkAttendance` (upsert), `MarkAll`, `OpenSelfCheckin`, `CloseSelfCheckin`.
- [ ] `StudentLectures`, `SelfCheckin` (all guards), attendance counters.
- [ ] Wire `lecture.attend.*` + `student.*` cases.

### Phase 3 — Lecturer UI (`Lectures.aspx`)
- [ ] Agenda/calendar list + status badges + filters/search (client‑render, embedded init JSON).
- [ ] Lecture editor modal (single + recurring series) + resources builder (dropzone/link/library/note, drag‑order).
- [ ] Start/End/Cancel controls; copy link; delete scopes.
- [ ] Roll‑call console: toggles (auto‑save), counters/meter, bulk ops, self‑check‑in open/close (+ code + countdown), CSV export.
- [ ] "My meeting link" tab.
- [ ] `.od-lec/.od-roll/.od-cal` CSS (square, tokens).

### Phase 4 — Communications
- [ ] `OdelCommsService.cs` + `update.*` + `student.updates` + `student.update.read`.
- [ ] Lecturer Updates tab (compose/edit/pin/publish/delete, read‑count).
- [ ] Student Updates tab + read receipts + unread badges (CourseSpace label, MyLearning tile).

### Phase 5 — Student CourseSpace integration
- [ ] Extend `StudentSpace` JSON (lectures/updates/attendance/unread/live/next).
- [ ] Add `Odel.tabs` (Work | Lectures | Updates); render lectures (live/upcoming/past + your attendance), self‑check‑in CTA, updates.
- [ ] Reuse material‑viewer modal for lecture resources.

### Phase 6 — Summaries redesign
- [ ] Extend `CourseDashboard` stats; rebuild CourseManage overview (hero/live‑now/next‑lecture, KPI grid, this‑week agenda, engagement meters, new checklist items, new hub links).
- [ ] Student "At a glance" block (next lecture, attendance %, to‑do, unread).

### Phase 7 — Notifications & polish (optional)
- [ ] `OdelNotify.LectureScheduled` (series digest) / `UpdatePosted` (opt‑in), logged.
- [ ] Empty states, loaders, toasts; brace/paren + `csc.exe` verification of all `.cs`; end‑to‑end rolled‑back DB tests per role.

---

## 16. Open decisions to confirm before building

1. **Attendance & marks:** keep attendance purely informational in v1 (recommended), or should present‑rate feed a participation/coursework component now?
2. **Self‑check‑in trust:** enable the optional 4‑digit check‑in code by default, or leave it off (window‑only)?
3. **Update emails:** default OFF with an opt‑in "Notify students" checkbox (recommended), or always email on post?
4. **Lecturer page shape:** one `Lectures.aspx` with internal tabs (Lectures | Updates | Meeting link) — recommended — vs. separate `CourseUpdates.aspx`?
5. **Course vs teacher default link precedence:** confirm per‑lecture → course → teacher → blank.

*(Recommended defaults are marked; if you're happy with them I'll proceed straight to Phase 0.)*
