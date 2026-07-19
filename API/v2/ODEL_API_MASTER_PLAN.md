# ODEL API — Master Plan & Implementation Blueprint

**Module:** `API/v2/odel.aspx` · **Version:** 2.1 · **Status:** Phase-1 core implemented & tested
**Audience:** frontend engineers (student portal, lecturer console, mobile) and API maintainers.

This document is the single source of truth for the ODEL (Online Distance E-Learning) API. It extends — never replaces — the existing v2 API architecture (`ApiHelper` / `TokenManager` / `?action=` dispatch). Every decision here is deliberately consistent with the modules already shipped (`academic`, `student`, `campus`, `timetable`, `finance`, `staff`, …).

---

## 1. Architecture it plugs into (do not deviate)

| Concern | Convention (reused verbatim) |
|---|---|
| **Transport** | One Web-Forms page per module (`odel.aspx` + `odel.aspx.cs`, class `API_v2_odel`). GET or POST; params read via `Request[...]`. |
| **Routing** | `?action=<snake_case>` → `switch` → `private void Handle<Pascal>()`. `default` returns `INVALID_ACTION`. Whole switch wrapped in try/catch → `SERVER_ERROR`. |
| **Success envelope** | `{ "success": true, "message": "OK", "data": <object|array>, "timestamp": "<ISO-8601 UTC>" }` — via `ApiHelper.Success(Response, data, message)`. |
| **Error envelope** | `{ "success": false, "message": "...", "error_code": "<CODE>", "data": null, "timestamp": "..." }` — via `ApiHelper.Error(Response, message, code)`. **HTTP status is 200**; clients branch on `success`/`error_code`. |
| **Auth** | `token` request param → `TokenManager.RequireAuth(Request, Response)` returns `TokenInfo{ UserId, UserType, FullName }` or null. `UserId` = student `regno` or staff `usernames`. |
| **Authorization** | String `UserType` check (`student`/`staff`) + per-space gate (`StaffOnSpace`, `StudentOnSpace`). No permission tables. |
| **Pagination** | `page` (1-based) + `limit` (clamped). `pagination` object **nested inside `data`**: `{ page, limit, total, total_pages }`. Never top-level. |
| **Filtering** | Optional params appended as parameterised `AND` clauses (`filter`, `q`, `only_ungraded`, …). |
| **JSON casing** | `snake_case` everywhere (from SQL column aliases / dict keys). |
| **DB** | ODEL tables live in **`campus_dynamics_portal`** → use `ApiHelper.QueryPortal / ExecutePortal / ExecuteInsertPortal / ScalarPortal` (added for this module). Academic tables (`acad_course`, `acad_student`, `hrm_employee`, `acad_programmecourses`) are cross-DB via the `campus_dynamics.` prefix (same server). All SQL parameterised with `MySqlParameter`. |
| **Error codes** | `INVALID_ACTION, MISSING_PARAM, INVALID_PARAM, VALIDATION_ERROR, NOT_FOUND, ACCESS_DENIED, SERVER_ERROR, RATE_LIMITED, AUTH_MISSING_TOKEN, AUTH_INVALID_TOKEN`. |

### New shared helpers (added in this phase)
`ApiHelper.QueryPortal / ExecutePortal / ExecuteInsertPortal / ScalarPortal` — mirror the existing `campus_dynamics` helpers but target `campus_dynamics_portal` (via `GetPortalConnection`). Reusable by any future portal-backed module.

### Module-local helpers (in `odel.aspx.cs`)
- `StaffEmpId(username)` → `hrm_employee.empID` (via `usernames`/`EMP_CODE`/`emp_email`).
- `StaffOnSpace(spaceId, empid)` → true if space-staff member or the assigned lecturer of the course.
- `StudentOnSpace(spaceId, regno)` → true if APPROVED-enrolled (not REMOVED) in the course behind the space.
- `RequireStaff / RequireStaffOnSpace` → auth+authorization gates that emit the error and return `-1`.
- `RecomputeGradebook(spaceId, regno)` → `odel_gradebook.odel_points = Σ(final/max × weight)` over latest graded, counting attempts (called after every `save_grade`).

---

## 2. Data model (28 `odel_*` tables in `campus_dynamics_portal`)

Central entity **`odel_course_space`** (one per course×term). Everything hangs off `space_id`; every student artefact carries `regno`; staff carry `empid`.

```
odel_course_space (space)
  ├─ odel_space_staff (space_id, empid, is_push_owner)
  ├─ odel_chapter ─ odel_topic ─ odel_topic_material ─ odel_material ─ odel_file
  ├─ odel_assignment ─ odel_submission ─ odel_submission_file
  │                        └─ odel_submission_grade (is_current=1)
  │                    └─ odel_assignment_extension
  ├─ odel_gradebook (space_id, regno, odel_points)
  ├─ odel_lecture ─ odel_lecture_resource / odel_attendance   (odel_lecture_series)
  ├─ odel_course_update ─ odel_update_read
  ├─ odel_cw_push ─ odel_cw_push_detail        (coursework → provisional marks)
  └─ odel_policy_value / odel_activity_log / odel_notification_log
```

**Cross-DB joins** (from the portal connection):
- Roster: `acad_course_registration cr` (portal) ⋈ `TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester`, `cr.lecturer_status='APPROVED'`.
- Course name: `campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(sp.courseID)`.
- Student: `campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(cr.regno)`.
- Lecturer identity: `campus_dynamics.hrm_employee`, `campus_dynamics.acad_programmecourses`.
- **CHAR columns are space-padded** → always `TRIM()` both sides of `regno`/`courseID` joins.

Lifecycle/soft-delete columns for archive/restore: `odel_course_space.status` (DRAFT/ACTIVE/FROZEN), `odel_assignment.is_published`+`archived_at`, `odel_submission.status`, `odel_submission_grade.is_current`, `odel_lecture.status`+`is_published`, `odel_course_update.is_published`+`pinned`, `acad_course_registration.lecturer_status`.

---

## 3. Implemented endpoints (Phase 1) — `GET/POST /API/v2/odel.aspx`

All require `token` unless noted. `space_id`, `assignment_id`, etc. are integers. Staff may pass `regno` to act on a student for read endpoints; students are always scoped to themselves.

### 3.1 Student — learning
| action | params | returns | notes |
|---|---|---|---|
| `my_learning` | *(staff: `regno`)* | `active_courses[]`, `pending_courses[]`, counts | the student's spaces + quick stats; DRAFT/non-approved → pending. Deduped by space. |
| `space` | `space_id` | `space`, `chapters[]`, `topics[]`, `materials[]`, `assignments[]` (with `my_status`/`my_marks`) | full course view. |
| `assignment` | `assignment_id` | `assignment`, `my_submission`, `my_files[]` | one assignment + the student's attempt. |
| `dashboard` | — | `active_spaces`, `live_lectures`, `unread_updates`, `next_lecture` | cross-course home widget. Student only. |
| `lectures` | `space_id` | `lectures[]` (+ `my_attendance`), `count` | published lectures for the space. |
| `updates` | `space_id` | `updates[]` (+ `is_read`), `unread_count` | announcements. |
| `attendance` | `space_id` | `records[]`, `total_lectures`, `attended`, `attendance_rate` | the student's attendance + rate. |

### 3.2 Student — writes
| action | params | effect |
|---|---|---|
| `submit_autosave` | `assignment_id`, `text` | upsert the DRAFT attempt → `{ submission_id, status:"DRAFT" }`. |
| `submit_finalize` | `assignment_id`, `text` | submit (window + attempt-limit checks, late flag, receipt) → `{ submission_id, status:"SUBMITTED", is_late, receipt_code }`. |
| `mark_update_read` | `space_id`, `update_id` (0=all) | mark announcements read → `{ marked_read }`. |
| `self_checkin` | `lecture_id`, `code?` | self roll-call during an open window → `{ status:"PRESENT" }`. |

### 3.3 Lecturer — teaching (read)
| action | params | returns |
|---|---|---|
| `teaching_spaces` | — | `spaces[]` (roster/assignments/ungraded counts). |
| `course_dashboard` | `space_id` | `space`, `stats{ roster, assignments, published_assignments, ungraded_submissions, materials, lectures }`. |
| `roster` | `space_id`, `page?`, `limit?`, `q?` | `students[]` + `pagination`. |
| `assignments` | `space_id`, `filter?` (all/published/draft/archived) | `assignments[]` (submitted/graded stats). |
| `assignment_students` | `space_id`, `assignment_id` | `students[]` (per-student submission status). |
| `grading_queue` | `space_id`, `assignment_id`, `page?`, `limit?`, `only_ungraded?` | `submissions[]` (latest attempt) + `pagination`. |
| `lecture_list` | `space_id` | `lectures[]` (+ present_count). |
| `roll_roster` | `space_id`, `lecture_id` | `roster[]` with each student's mark. |
| `attendance_summary` | `space_id` | per-lecture present/absent counts. |
| `update_list` | `space_id` | announcements + `read_count`. |

### 3.4 Lecturer — writes
| action | params | effect |
|---|---|---|
| `save_grade` | `space_id`, `submission_id`, `raw_marks`, `feedback?` | version the grade (late penalty applied), recompute gradebook → `{ final_marks, penalty_pct, version }`. |
| `update_save` | `space_id`, `update_id?`, `title`, `body?`, `pinned?`, `is_published?` | create/update announcement. |
| `update_delete` | `space_id`, `update_id` | delete announcement + read receipts. |
| `mark_attendance` | `space_id`, `lecture_id`, `regno`, `status` (PRESENT/ABSENT/LATE/EXCUSED/CLEAR) | upsert/clear one student's attendance. |
| `lecture_set_status` | `space_id`, `lecture_id`, `status` (PENDING/LIVE/ENDED/CANCELLED) | transition a lecture (stamps actual_start/end). |

### 3.5 Meta
| action | auth | returns |
|---|---|---|
| `ping` | none | `{ status:"ok", module:"odel", spaces }` |

### Example
```
GET /API/v2/odel.aspx?action=space&space_id=1&token=<TOKEN>
→ { "success": true, "data": { "space": {...}, "assignments": [ { "assignment_id":1, "title":"Assignment 1: Word processing", "my_status":"SUBMITTED", "my_marks":80.00 }, ... ] } }

POST /API/v2/odel.aspx   action=save_grade&space_id=1&submission_id=42&raw_marks=85&feedback=Good&token=<TOKEN>
→ { "success": true, "data": { "submission_id":42, "final_marks":85.0, "version":2 }, "message":"Grade saved" }
```

---

## 4. CRUD coverage matrix (per entity)

| Entity | List | Detail | Create | Update | Delete/Archive | Status | Stats |
|---|---|---|---|---|---|---|---|
| Course space | `my_learning` / `teaching_spaces` | `space` / `course_dashboard` | *(auto-provisioned)* | *(Phase 2)* | *(status)* | *(Phase 2 freeze)* | `course_dashboard` |
| Content (chapter/topic/material) | in `space` | in `space` | **Phase 2** | **Phase 2** | **Phase 2** | publish (Phase 2) | — |
| Assignment | `assignments` | `assignment` | **Phase 2** | **Phase 2** | **Phase 2** archive | publish (Phase 2) | `assignments` |
| Submission | `grading_queue` | `assignment` | `submit_finalize` | `submit_autosave` | — | status | — |
| Grade | in queue | in queue | `save_grade` | `save_grade` (versioned) | — | is_current | `assignment_students` |
| Lecture | `lecture_list` | **Phase 2** | **Phase 2** | **Phase 2** | **Phase 2** | `lecture_set_status` | `attendance_summary` |
| Attendance | `roll_roster` | `attendance` | `mark_attendance`/`self_checkin` | `mark_attendance` | `mark_attendance CLEAR` | — | `attendance_summary` |
| Announcement | `update_list` | in list | `update_save` | `update_save` | `update_delete` | pin/publish | read_count |
| Push-to-marks | **Phase 2** | **Phase 2** | **Phase 2** commit | — | — | supersede | preview |

---

## 5. Roadmap (Phase 2+ — designed, consistent, ready to build)

These follow the identical envelope/auth/patterns. Ordered by frontend value.

**Content authoring (lecturer):** `chapter_save`, `chapter_delete`, `chapter_reorder`, `topic_save`, `topic_delete`, `topic_reorder`, `link_add`, `link_remove`, `content_publish`, `library_search`, `library_save`, `library_delete`, `copy_forward`.
**Assignments (lecturer):** `assignment_save`, `assignment_publish`, `assignment_archive`, `assignment_delete`, `assignment_duplicate`, `assignment_reorder`, `assignment_stats`, `extension_save`, `extension_remove`.
**Lectures (lecturer):** `lecture_save`, `lecture_series_save`, `lecture_delete`, `open_checkin`, `close_checkin`, `mark_all_attendance`, `lecture_meeting_get/save`.
**Push-to-marks (lecturer):** `push_preview`, `push_commit`, `push_history`, `push_snapshot`.
**Files:** `file_upload` (multipart), `file_download` (stream), submission-file attach/detach.
**Admin (institution):** `admin_dashboard`, `policy_get`, `policy_save`, `activity_log`.
**Engagement/analytics:** `engagement_summary`, per-space analytics.
**Notifications:** `notifications_list`, `notification_read`.

**Frontend-readiness checklist (met by Phase 1, required of all Phase 2):** lightweight list endpoints vs detailed views; `page`/`limit` pagination with `total_pages`; `q` search; `filter` params; consistent snake_case; stable error codes with human `message`; nested relationships (space→assignments→my_status) to avoid N+1; idempotent writes (`ON DUPLICATE KEY`, draft upsert); every write returns the affected id + new state.

---

## 6. Security & performance notes

- **Every** endpoint authenticates; **every** space-scoped endpoint authorises via `StudentOnSpace`/`StaffOnSpace` before returning or mutating data — a student cannot read another course, a lecturer cannot touch a space they don't teach.
- All SQL is parameterised (`MySqlParameter`); only static fragments (filter/sort keywords chosen from a fixed set) are concatenated.
- Rate limiting via `ApiHelper.IsRateLimited` (120/min per token).
- Recommended indexes (verify on deploy): `odel_submission(assignment_id, regno, status)`, `odel_submission_grade(submission_id, is_current)`, `odel_attendance(lecture_id, regno)` (unique), `odel_update_read(update_id, regno)` (unique), `odel_gradebook(space_id, regno)` (unique), `acad_course_registration(courseID, acad_year, semester)`.
- Gradebook recompute is O(assignments) per grade save — acceptable; heavy analytics belong in `odel_engagement_summary` (Phase 2, precomputed).

---

## 7. Testing status

Validated against live data (`campus_dynamics_portal`) using the seeded test pair — student **MRU2027000002** (sabia) enrolled in **space 1 / ICT1108B (ACTIVE)** owned by lecturer **muhindo (empID 307)** with 2 published assignments:
- Reads: `my_learning` (deduped), `space`, `assignments`, per-student status, `course_dashboard`, `teaching_spaces`, `roster` — correct rows.
- Writes (rolled-back transactions): `save_grade` (versioning + gradebook upsert), `update_save`, `mark_attendance`/`self_checkin` (ON DUPLICATE KEY) — all valid against the schema.
- Compilation: `odel.aspx.cs` + `ApiHelper.cs` + `TokenManager.cs` compile clean under `csc` (.NET 4).

Full live HTTP testing (login → token → every action) should be run post-deploy against `https://eadmin.mru.ac.ug/API/v2/odel.aspx` with the two test accounts.
