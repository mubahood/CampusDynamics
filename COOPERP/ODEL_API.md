# ODEL API Reference

> Complete reference for every ODEL endpoint powering the eportal web portal and the eadmin monitoring screens. Verified live 2026-07-06. University: Muteesa I Royal University (MRU).

---

## 1. Overview & conventions

**Base (portal):** `https://eportal.mru.ac.ug/OdelApi.ashx` — a single centralized handler that routes every portal operation by an `action` value to the App_Code service layer (`OdelService`, `OdelPushService`, `OdelNotify`). No business logic is duplicated in pages.

**Method convention**
- **GET = reads** (idempotent, refresh-safe, bookmarkable). Params in the query string. Responses are marked `no-cache`; the client also appends a `_=<ts>` cache-buster.
- **POST = writes** (mutations). Params in a JSON body: `{"action":"<action>", ...params}`.

**Auth** — session-based (the portal login sets `Session["username"]` / `Session["regno"]`). No token/header is required; the browser session cookie carries identity. Each endpoint resolves the caller and enforces:
- **Student** endpoints require a signed-in student and **enrolment** in the course (a row in `acad_course_registration` for that course/term).
- **Lecturer** endpoints require a signed-in staff member who is **assigned to the space** (`odel_space_staff`).

**Response envelope** — every endpoint returns JSON with a boolean `success`. On failure: `{"success":false,"message":"..."}`. On success, the documented fields plus `success:true`.

**Common errors**
| Message | Meaning |
|---|---|
| `Not signed in.` / `Not signed in as staff.` | No valid session for the required role. |
| `You are not registered for this course.` | Student not enrolled in the space's course/term. |
| `You do not teach this course.` | Staff not on `odel_space_staff` for the space. |
| `Unknown action: <x>` | Action not recognised by the router. |
| `Course space not found.` / `Assignment not available.` | Bad id or unpublished resource. |

**Content type** — responses are `application/json`. The central API returns raw JSON (no ASP.NET `.d` wrapper); the shared client (`odel.js`) parses it directly. (The eadmin PageMethods in §5 do use the `.d` wrapper — noted there.)

---

## 2. Health

### `ping` — GET
Service heartbeat. No auth.
- **Response:** `{ success:true, service:"ODEL API", time:"yyyy-MM-dd HH:mm:ss" }`
- **Example:** `GET OdelApi.ashx?action=ping`

---

## 3. Student endpoints

### `student.home` — GET
The student's ODEL dashboard: every active course space with deadlines, running coursework, and submission compliance. Auth: student.
- **Params:** none.
- **Response:** `{ success, spaces:[ { id, courseID, title, acadYear, semester, required, submitted, materials, nextDue, cw, cwShare } ] }`
  - `required` = published counting assignments; `submitted` = distinct submitted by me; `cw` = running coursework (0–`cwShare`); `nextDue` = earliest unmet deadline.
- **Example:** `GET OdelApi.ashx?action=student.home`

### `student.space` — GET
One course space (student view): topics + materials, assignments with my status/grade/feedback, and my running coursework. Auth: student enrolled.
- **Params:** `spaceId` (int, required).
- **Response:** `{ success, courseID, title, acadYear, semester, coursework, cwShare, topics:[ { id, title, materials:[ { id, type(FILE|PAGE|LINK), title, fileId, url, fileName, size } ] } ], assignments:[ { id, title, maxPoints, dueAt, subType, status, submittedAt, receipt, isLate, graded(0|1), finalMarks, feedback } ] }`
- **Example:** `GET OdelApi.ashx?action=student.space&spaceId=1`

### `student.assignment` — GET
One assignment's detail + the student's current submission (for the Submit screen). Auth: student enrolled.
- **Params:** `assignmentId` (int, required).
- **Response:** `{ success, courseID, title, maxPoints, subType, dueAt, lateUntil, window(open|late|notopen|closed), current:{ id, attempt, text, status, submittedAt, receipt, isLate }|null, files:[ { id, name, size } ] }`
- **Example:** `GET OdelApi.ashx?action=student.assignment&assignmentId=12`

### `submit.autosave` — POST
Autosaves the student's draft text answer (called ~every second while typing). Auth: student enrolled.
- **Body:** `{ action:"submit.autosave", assignmentId:int, text:string }`
- **Response:** `{ success, id, savedAt }`

### `submit.finalize` — POST
Finalises a submission: links uploaded files, sets `SUBMITTED`, generates a receipt code, emails the student. Enforces open/due/late windows. Auth: student enrolled.
- **Body:** `{ action:"submit.finalize", assignmentId:int, text:string, fileIdsJson:string("[1,2]") }`
- **Response:** `{ success, receipt, isLate, submittedAt }`
- **Errors:** `This assignment is not open yet.` / `The submission window has closed.`

---

## 4. Lecturer endpoints

### 4.1 Teaching home

#### `teach.spaces` — GET
The lecturer's course spaces with compliance meters, roster/material/grading counts, and last push version. Self-heals provisioning from `acad_programmecourses`. Auth: staff.
- **Params:** none.
- **Response:** `{ success, empid, spaces:[ { id, courseID, title, acadYear, semester, status(DRAFT|ACTIVE|FROZEN), pushOwner(0|1), roster, assignments, materials, ungraded, lastPush, minAssign } ] }`

### 4.2 Content builder

#### `teach.content` — GET
Topics + materials for a space (lecturer view, incl. drafts). Auth: staff on space.
- **Params:** `spaceId` (int).
- **Response:** `{ success, courseID, title, topics:[ { id, title, published, materials:[ { id, type, title, fileId, url, published, fileName } ] } ] }`

#### `content.topic` — POST
Create (`id=0`) or rename a topic. Auth: staff on space.
- **Body:** `{ action:"content.topic", spaceId:int, id:int, title:string }`
- **Response:** `{ success, id }`

#### `content.material` — POST
Create/update a material (FILE/PAGE/LINK). For FILE, upload first via `OdelUpload.ashx` (§6) and pass the returned `fileId`. Auth: staff on space.
- **Body:** `{ action:"content.material", spaceId:int, json:"{ id, topicId, type, title, fileId, url, pageHtml }" }`
- **Response:** `{ success, id }`

#### `content.publish` — POST
Publish/unpublish a topic or material. Publishing activates a DRAFT space. Auth: staff on space.
- **Body:** `{ action:"content.publish", spaceId:int, kind:"topic"|"material", id:int, publish:bool }`
- **Response:** `{ success }`

#### `content.copyforward` — POST
Copies topics + materials from the same course's most recent prior space (drafts; files reused by reference). Auth: staff on space.
- **Body:** `{ action:"content.copyforward", spaceId:int }`
- **Response:** `{ success, topics, materials }` (counts copied) — or `{success:false, message:"No previous course space to copy from."}`

### 4.3 Assignments

#### `teach.assignments` — GET
All assignments in a space + the coursework-share/total-weight context. Auth: staff on space.
- **Params:** `spaceId` (int).
- **Response:** `{ success, courseID, title, cwShare, totalWeight, assignments:[ { id, title, maxPoints, weightPoints, countsCw, subType, dueAt, published, subs } ] }`

#### `assignment.save` — POST
Create (`id=0`) or update an assignment. Auth: staff on space.
- **Body:** `{ action:"assignment.save", spaceId:int, json:"{ id, title, maxPoints, weightPoints, countsCw, subType, openAt, dueAt, lateUntil, instructions }" }`
- **Response:** `{ success, id }`

#### `assignment.publish` — POST
Publish/unpublish an assignment. **First publish** emails the enrolled roster (via `OdelNotify`) and activates a DRAFT space. Auth: staff on space.
- **Body:** `{ action:"assignment.publish", spaceId:int, id:int, publish:bool }`
- **Response:** `{ success }`

### 4.4 Grading

#### `teach.queue` — GET
The grading queue: submitted work (ungraded first) with student, files, text, and any current grade. Auth: staff on space.
- **Params:** `spaceId` (int).
- **Response:** `{ success, courseID, queue:[ { submissionId, assignmentId, assignment, maxPoints, latePenalty, regno, name, submittedAt, isLate, textAnswer, graded(0|1), finalMarks, rawMarks, feedback, files:[ { id, name, size } ] } ] }`

#### `grade.save` — POST
Grades a submission (versioned; late penalty auto-applied), then recomputes the student's gradebook (feeds the coursework push). Auth: staff on space.
- **Body:** `{ action:"grade.save", spaceId:int, submissionId:int, raw:number, feedback:string }`
- **Response:** `{ success, finalMarks, penaltyPct }`

### 4.5 Coursework Push (the marks-pipeline integration)

#### `push.preview` — GET
Computes coursework (0–40) for every roster student from the ODEL gradebook, with readiness checks. **Writes nothing.** Auth: staff on space.
- **Params:** `spaceId` (int).
- **Response:** `{ success, space:{ id, courseID, title, acadYear, semester }, cwShare, cwMode(FULL|PARTIAL|ADVISORY), totalWeight, readiness:{ ungraded, weightMismatch, editable, locked }, stats:{ count, meanCw, zeros }, rows:[ { regno, name, points, computedCw, curCw, exam, stage, editable } ] }`

#### `push.commit` — POST
Writes coursework into `acad_course_registration.provisional_course_work_marks` (0–40), mirroring the lecturer marks-entry routine (transaction + row lock, only `mark_stage IN ('NOT_ENTERED','ENTERED')`, recompute total, set stage). Creates an **immutable snapshot** + audit. Auth: push-owner staff.
- **Body:** `{ action:"push.commit", spaceId:int, overridesJson:"{ \"REGNO\": { cw:int, reason:string } }", ungradedAsZero:bool }`
- **Response:** `{ success, written, skipped }` (`skipped` = locked rows left untouched)

#### `push.history` — GET
Prior pushes for a space (version, when, mode, counts, actor). Auth: staff on space.
- **Params:** `spaceId` (int).
- **Response:** `{ success, pushes:[ { id, version, pushedAt, mode, share, students, by, written } ] }`

#### `push.snapshot` — GET
The per-student detail of one push (immutable provenance). Auth: staff on the push's space.
- **Params:** `pushId` (int).
- **Response:** `{ success, pushId, rows:[ { regno, points, computedCw, overrideCw, reason, finalCw, prevCw, stage } ] }`

---

## 5. eadmin endpoints (monitoring & governance)

These are ASP.NET **PageMethods** (POST, `application/json`, response wrapped as `{"d":"<json-string>"}`) on the eadmin app (`eadmin.mru.ac.ug`), scope-gated by `MarksScopeResolver` + RBAC slugs. They read the same `odel_*` tables.

### `OdelDashboard.aspx/GetDashboard` — POST
Institution monitoring: KPIs, an 8-week submission trend, and per-course compliance.
- **Body:** `{}`
- **Response (inside `.d`):** `{ success, roleNote, scopeLabel, kpi:{ spaces, assignments, materials, subsTotal, subsWeek, ungraded, pushes, students, cwViaOdel }, trend:[ { label, count } ], compliance:[ { space, courseID, term, owner, assignments, roster, ungraded, pushed } ] }`

### `OdelPolicy.aspx/GetPolicies` — POST
Current institution policy values (self-healing to defaults) + recent course-term overrides.
- **Body:** `{}`
- **Response (inside `.d`):** `{ success, policies:[ { key, label, value, default } ], overrides:[ { key, scope, value, by, at } ] }`

### `OdelPolicy.aspx/SavePolicy` — POST
Versioned policy write (supersedes the prior active value; audited).
- **Body:** `{ key, value, scopeLevel:"INSTITUTION"|"COURSE_TERM", scopeRef }`
- **Response (inside `.d`):** `{ success }`

**Policy keys:** `cw_share`, `cw_mode`, `min_assignments_per_course`, `min_submissions_per_student`, `best_n_of_m`, `late_window_hours`, `late_penalty_pct`, `max_file_mb`, `max_files`, `autosave_seconds`.

---

## 6. File handlers

### `OdelUpload.ashx` — POST (multipart)
Uploads one file. Validates against the `max_file_mb` policy, stores it under `~/odel-uploads/<yyyymm>/<guid>.<ext>`, records `odel_file` (with SHA-1), returns its id. Auth: any signed-in user. Used by the shared drag-&-drop dropzone.
- **Request:** `multipart/form-data` with field `file`.
- **Response:** `{ success, fileId, name, size }` — or `{ success:false, message:"File exceeds N MB limit." }`

### `OdelFile.ashx?id=<fileId>` — GET
Streams a stored file with an **entitlement check**: submission files are released only to the owning student or a staff member on the space; other files to any signed-in user. Auth required.
- **Params:** `id` (int).
- **Response:** the file stream (`Content-Disposition: attachment`), or HTTP 403/404.

### `ViewPage.aspx?m=<materialId>` — GET
Renders a published PAGE material as a print-friendly HTML page (browser → Save as PDF). Auth required.

---

## 7. Endpoint index (quick reference)

| Action | Method | Role | Purpose |
|---|---|---|---|
| `ping` | GET | any | Health check |
| `student.home` | GET | student | My courses + deadlines + coursework |
| `student.space` | GET | student | Course materials + assignments + grades |
| `student.assignment` | GET | student | Assignment detail + my submission |
| `submit.autosave` | POST | student | Autosave draft |
| `submit.finalize` | POST | student | Submit + receipt |
| `teach.spaces` | GET | staff | My teaching spaces + compliance |
| `teach.content` | GET | staff | Topics + materials (editor) |
| `content.topic` | POST | staff | Create/rename topic |
| `content.material` | POST | staff | Create/update material |
| `content.publish` | POST | staff | Publish/unpublish topic/material |
| `content.copyforward` | POST | staff | Copy content from prior term |
| `teach.assignments` | GET | staff | Assignments list |
| `assignment.save` | POST | staff | Create/update assignment |
| `assignment.publish` | POST | staff | Publish (emails roster) |
| `teach.queue` | GET | staff | Grading queue |
| `grade.save` | POST | staff | Grade a submission |
| `push.preview` | GET | staff | Preview computed coursework |
| `push.commit` | POST | push-owner | Write coursework → marks pipeline |
| `push.history` | GET | staff | Past pushes |
| `push.snapshot` | GET | staff | One push's per-student detail |
| `OdelUpload.ashx` | POST | any | Upload a file |
| `OdelFile.ashx` | GET | any | Download a file (entitlement-checked) |
| `OdelDashboard/GetDashboard` | POST | mgmt | eadmin monitoring |
| `OdelPolicy/GetPolicies` | POST | mgmt | Read policies |
| `OdelPolicy/SavePolicy` | POST | mgmt | Write policy (versioned) |

---

## 8. Client usage (shared library)

The portal front-ends never call the API directly; they use `odel/odel.js`:
```js
Odel.get('student.home', null, function(d){ /* d.spaces ... */ });
Odel.get('student.space', { spaceId: 1 }, cb);
Odel.post('grade.save', { spaceId:1, submissionId:12, raw:80, feedback:'Good' }, cb);
```
`Odel.get` → GET (with cache-buster); `Odel.post` → POST JSON. Both parse the JSON response and pass it to the callback. The library also provides `Odel.dropzone` (drag-&-drop upload against `OdelUpload.ashx`), `Odel.state` (URL/GET state), `Odel.toast`, `Odel.loader`, `Odel.pager`, and `Odel.tabs`.

## 9. Notes
- All new endpoints are implemented and verified live (2026-07-06): `ping`, `push.history`, `push.snapshot` were added in the mastering pass and confirmed routing.
- Marks safety: only `push.commit` writes to the marks pipeline, only for `NOT_ENTERED`/`ENTERED` rows, always snapshot + audited; corrections after `CAPTURED` go through the existing Mark Requests workflow.
- Source: `OdelApi.ashx` (router) → `App_Code/Odel/OdelService.cs`, `OdelPushService.cs`, `OdelNotify.cs`, `OdelCore.cs`. Companion: `ODEL_MODULE_SPEC_AND_TASKS.md`, `ODEL_PROGRESS.md`.
