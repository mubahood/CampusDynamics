# ODEL Module — Realigned Specification & Implementation Tasks

> **What this is:** Our own, reality-checked ODEL spec. It **benchmarks** the external consultant proposal (`ODEL_CONSULTANT_PROMPT.md` → their reply) against how our system is *actually* built, keeps what fits, cuts/defers what doesn't, avoids rebuilding what exists, and adds ideas borrowed from Moodle / Google Classroom plus our own. Part A = features (detailed). Part B = step-by-step implementation tasks. Design, coding and UI/UX conventions are held to our existing standards throughout.
> **Status:** PLAN (grounded in live-verified code + DB). **University:** Muteesa I Royal University (MRU). **Updated:** 2026-07-05.

---

## 0. Reality check — what we verified before planning

**Apps:** eadmin ("COOPERP", eadmin.mru.ac.ug) for admins; **eportal** (eportal.mru.ac.ug) — a *single* portal for **both students and lecturers**, gated by `PortalHelper.IsStaffUser()`. Stack: ASP.NET Web Forms 4.0, C# 5, MySQL 5.6, DevExpress 16.1, vanilla JS + Chart.js. Design: flat navy (`#05275C` / accent `#174DA4`), radius 0.

**The single biggest finding — avoid double work, but there's little to reuse from the old LMS:**
- A previous team **designed an LMS** (`Elearning.xsd` → `el_course_work`, `el_coursework_submissions`, `course_content`, `tutor_digital_classes`) targeting a separate **`campus_dynamics_elearning` DB — which does not exist**. The tables were never created, the `CourseWorkUploads/` folder is empty, and the menus are hidden (`ClientVisible="False"`) or dead links (`Stud_elearning.aspx` doesn't exist). **This LMS layer is ~0% live — abandoned scaffolding.** We do **not** resurrect it or the separate-DB approach.
- What **is** real and mature: the **marks engine**. The authoritative current path is the **provisional staged-marks workflow** on `acad_course_registration` (`provisional_course_work_marks`, `mark_stage`), captured in eportal via `LecturerProvisionalMarksController.aspx`. (An older TeachingCenter path writes `acad_coursework_marks`/`acad_results` directly — legacy, not our integration target.)

**The coursework integration point (verified):**
- Write target: `campus_dynamics_portal.acad_course_registration`, one row per `regno + courseID + acad_year + semester` (PK `ID`).
- **Coursework = `provisional_course_work_marks`, an INTEGER 0–40.** Exam is 0–60. `provisional_total_marks = cw + exam` (plain sum; **no weighting multiplier** — the 40/60 split is hardcoded as input validation). **⇒ ODEL owns the scaling** of assignment points into a 0–40 integer.
- Stage: `mark_stage` = `NOT_ENTERED → ENTERED → CAPTURED(HOD) → APPROVED(Dean) → PUBLISHED(Senate)`. `ENTERED` is set only when **both** CW and exam exist.
- The push must **mirror `LecturerProvisionalMarksController.SaveProvisionalMarks`** (line ~1435): transaction + `SELECT … FOR UPDATE`, `WHERE mark_stage IN ('NOT_ENTERED','ENTERED')`, keep `provisional_marks_status` in sync, then `TryAutoResolveMarkRequests`. Do **not** copy the REST API handlers (they skip `mark_stage`).
- Lecturer→course link: eportal's "my courses" uses **`acad_programmecourses.lecturer_id` (empID)** with `is_lecturere_assigned='YES'`; `acad_teaching_allocation` (keyed by `staffCode`) is the alternate. We standardise on `acad_programmecourses.lecturer_id` for provisioning/roster (matches existing portal code), and cross-check allocation where needed.

**Reusable patterns (confirmed):** `PortalMaster.master` (HeadContent/MainContent/ScriptContent) + `PortalHelper.GetRegno/IsStaffUser`; `SidebarMaster.master` + slug RBAC + `MarksScopeResolver` (dean=faculty, HOD=dept) for eadmin; `[WebMethod]`+`JavaScriptSerializer` AJAX; file upload via `Server.MapPath` + GUID filename + DB metadata (as `UploadContent.aspx`); `EmailSenderProtocol` HTML email; audit-log table pattern; Chart.js dashboards. Connections: `vacConnectionString` (portal), `campus_dynamics_portalConnectionString` (→ `campus_dynamics` academic).

**Naming/placement decision:** all new tables prefixed **`odel_`** in **`campus_dynamics_portal`** (same DB as `acad_course_registration`; in-flight data). Column types **match the source** columns exactly (`regno` char(25), `courseID` char(25), `acad_year` char(25), `semester` int, `empID` int) so joins use plain `=` (heed the CHAR/TRIM perf lesson). No separate DB.

---

## 1. Benchmarking the consultant — KEEP / ADJUST / CUT

| Consultant idea | Our decision | Why |
|---|---|---|
| "ODEL proposes, lecturer disposes" push; immutable snapshots; respect staged workflow | **KEEP (core)** | Matches our verified pipeline exactly; the make-or-break design |
| Auto-provision course spaces from teaching allocation | **KEEP, ADJUST** | Use `acad_programmecourses.lecturer_id` (our real link), roster from `acad_course_registration` |
| Coursework "share" out of a 40% weighting w/ FULL/PARTIAL/ADVISORY modes | **ADJUST** | CW is a **0–40 integer, not a %**. Keep ADVISORY/PARTIAL/FULL *modes* but ODEL scales to 0–40; "ODEL share" = a portion of the 40 |
| Policy hierarchy (institution→faculty→programme→course) | **KEEP, SIMPLIFY** | Powerful but heavy; ship institution + per-course override first, add faculty/programme later |
| Summary tables to avoid MySQL 5.6 window functions | **KEEP** | Correct for our DB |
| Mobile-first, size-labels, resumable uploads, autosave, receipts | **KEEP** | Exactly our context |
| Rebuild dashboards / RBAC / email / correction workflow / marks staging | **CUT (already exists)** | Reuse General-Dashboard pattern, slug RBAC + `MarksScopeResolver`, `EmailSenderProtocol`, **Mark Requests** workflow, staged marks — do **not** duplicate |
| Quizzes + question banks, forums, class analytics, at-risk console | **KEEP, DEFER to P2** | High value, not MVP |
| USSD, similarity screening, badges, peer review, audio feedback, sponsor digest, offline packs | **CUT of MVP → P3 backlog** | Real value later; scope risk now |
| Live video / streaming | **CUT** | No infra. Lecturers paste external Zoom/Meet links; ODEL only schedules + tracks attendance |
| Separate `campus_dynamics_elearning` DB / resurrect `el_*` | **CUT** | Dead approach; use `odel_*` in `campus_dynamics_portal` |
| SMS reminders | **DEFER P2** | Needs a gateway/budget decision |

**Added by us (Moodle / Classroom-informed, tuned to our reality):**
- **Classroom-style "Stream + Classwork" simplicity** as the lecturer default (not Moodle's complexity) — a single "post material / post assignment / grade" flow; progressive disclosure for rubrics/quizzes.
- **Reuse the real marks pipeline as the gradebook of record** (Moodle-style separate gradebook is *not* the record — our `acad_course_registration` is).
- **Tie ODEL compliance into the Appraisal module** we built (per-lecturer ODEL activity as an appraisal data feed).
- **"Term copy-forward"** (Classroom "reuse post") so a lecturer's second semester is one click.
- **Coursework preview inside the existing marks screen** — ODEL's computed coursework shows in `LecturerProvisionalMarksController` as a suggested value the lecturer accepts, so lecturers never leave a familiar screen.

---

## PART A — FEATURE SPECIFICATION

Legend: **P1** MVP · **P2** next · **P3** later. Every screen uses the existing master/design/AJAX/file/email/RBAC patterns.

### A1. Foundation (shared)

**F1 — Course Space auto-provisioning (P1).** A nightly + on-demand job creates one `odel_course_space` per `(courseID, acad_year, semester)` that has an assigned lecturer in `acad_programmecourses` (`lecturer_id`, `is_lecturere_assigned='YES'`). Roster is *derived live* from `acad_course_registration` (no copied enrolment). Multiple lecturers → `odel_space_staff` with one `is_push_owner`. Status DRAFT→ACTIVE (on first publish) →FROZEN (term close).

**F2 — File service (P1).** Upload/download via a handler: files saved to `~/odel-uploads/<yyyymm>/<guid>.<ext>` (outside any listing), metadata in `odel_file` (orig name, mime, size, sha1, owner). **Chunked resumable upload** (JS `File.slice`, 1 MB chunks, POST to an upload handler; server reassembles + SHA-1). Download streamed through an entitlement-checked handler. Size/type limits from policy. Reuses the `UploadContent.aspx`/`Server.MapPath` convention, hardened.

**F3 — Notifications (P1 email / P2 SMS).** Event→template→`EmailSenderProtocol.SendHtmlEmail`; per-event dedupe + log in `odel_notification_log`. SMS in P2 (needs gateway).

**F4 — ODEL activity log (P1).** Append-only `odel_activity_log` (actor, verb VIEWED/SUBMITTED/GRADED/PUSHED/CONFIGURED, object, ts). Feeds analytics + audit; nightly rollup to `odel_engagement_summary` (dashboards never scan the raw log — MySQL 5.6 kindness).

**F5 — RBAC slugs (P1).** New eadmin slugs (`odel.admin`, `odel.policy`, `odel.monitor`) reuse the existing slug system + `MarksScopeResolver` (dean=faculty, HOD=dept). eportal gates by `IsStaffUser`.

### A2. Student (eportal) — `PortalMaster.master`

**S1 — My ODEL home (P1).** All my course spaces this term (from my `acad_course_registration` rows), each with: next deadline, unread feedback, running coursework figure (out of the ODEL share), and a compliance meter ("2 of 3 required submissions done"). The screen most students live on.

**S2 — Course space (student) (P1).** Topic/week-organised materials + assignments + announcements. Every downloadable shows its **size label** ("PDF · 1.2 MB") before download; notes render as print-friendly HTML (offline/accessibility path).

**S3 — Assignment submission (P1).** File (resumable, multi-file) and/or typed answer with 30-second **server-side autosave**; explicit Submit → instant **receipt** (code + timestamp + file SHA-1, emailed). Kills "I submitted but it's lost" disputes.

**S4 — Running coursework & feedback (P1).** Per course: each assessment, my mark, class-average band, projected contribution to the 0–40 coursework figure, and lecturer feedback/rubric per submission.

**S5 — Quiz taking (P2).** Timed/untimed, one-question-per-page (tiny payloads), answer saved on each selection (resume after power cut), instant results for auto-marked types.

**S6 — Discussion (P2), deadline reminders (P2), offline pack / peer review / badges (P3).**

### A3. Lecturer (eportal) — `PortalMaster.master`

**L1 — My teaching (ODEL) home (P1).** My course spaces (from `acad_programmecourses.lecturer_id`), each with a **compliance meter** ("1 of 2 required assignments conducted"), grading-queue count, and last-activity. Makes the admin minimums visible, never an ambush.

**L2 — Content builder (P1).** Classroom-simple: add topic/week, upload files, write an HTML page in a plain rich-text box, publish/unpublish, reorder. **Copy-forward** last term's content in one click.

**L3 — Assignment builder (P1).** Title, instructions, attachments, open/due/late-until, max points, **weight (points toward the ODEL coursework share)**, `counts_toward_cw`, submission type, attempts, late-penalty (bounded by policy). Optional simple rubric.

**L4 — Grading (P1).** One-student-per-page: submission preview + mark + comment (+ optional rubric criteria). **Grading queue** with bulk **ZIP download** of submissions and **CSV marks re-upload** (validated) for offline marking.

**L5 — Coursework Push (P1)** — see A5 / Part-A §"Push". The heart of the module.

**L6 — Announcements (P1); quiz + question bank (P2); class analytics (P2); live-session scheduling + attendance via external links (P2); similarity/audio feedback (P3).**

### A4. Admin (eadmin) — `SidebarMaster.master`

**M1 — ODEL Policy Centre (P1).** Institution-level settings + per-course-term override (faculty/programme scope in P2): min assignments per lecturer per course; min submissions per student; ODEL coursework share (of the 40); best-N-of-M; late window/penalty bounds; file size/type limits; deadlines/calendar; push mode (ADVISORY/PARTIAL/FULL). Versioned + audited. An "effective policy" resolver shows *what applies and why*.

**M2 — Compliance dashboards (P1).** (a) Lecturers: per faculty/dept, each assigned course vs required-minimum assignments conducted + grading turnaround + last activity (scoped for deans/HODs via `MarksScopeResolver`). (b) Students: submission-rate by programme/course, below-minimum chase lists, exportable. Chart.js + PageMethods, General-Dashboard visual grammar.

**M3 — ODEL monitoring dashboard (P1).** Institution KPIs: active spaces, materials published, submissions this week, grading turnaround, storage growth, coursework-entered-via-ODEL %.

**M4 — Term calendar & rollover (P1 calendar / P2 rollover assistant); at-risk console (P2); workload & timetable view (P2); storage console (P2); exception/extension approvals (P2); integrity console (P3).**

### A5. The Coursework Push (linchpin, P1)

Reuse the "propose-then-confirm" design, grounded in our real write point:
1. **Where:** a wizard in eportal (lecturer), *and* an inline "use ODEL coursework" suggestion inside `LecturerProvisionalMarksController` so the lecturer sees ODEL's number next to the field they already use.
2. **Compute (ODEL owns scaling):** per student, `odel_points = Σ (raw/max × weight_points)` over counting assessments (best-N-of-M, late penalties, EXCUSED handling). Scale to the configured **ODEL coursework share of 40** (e.g. share=25 → contributes up to 25 of the 40; remaining 15 typed by lecturer in PARTIAL, or ODEL fills all 40 in FULL). Round half-up to an integer only at the final 0–40 figure.
3. **Preview → override-with-reason → password re-entry → commit.** Commit mirrors `SaveProvisionalMarks`: transaction + `FOR UPDATE`; write `provisional_course_work_marks` (0–40 int); recompute `provisional_total_marks = cw + exam` where exam present; set `mark_stage='ENTERED'` only if exam present (else leave `NOT_ENTERED`), sync `provisional_marks_status`; **guard `WHERE mark_stage IN ('NOT_ENTERED','ENTERED')`**; write an immutable `odel_cw_push` + `_detail` snapshot; audit; call `TryAutoResolveMarkRequests`. Rows past CAPTURED are untouchable → correction goes through the existing **Mark Requests** workflow (pre-filled with the ODEL snapshot).

---

## PART B — DATA MODEL (`odel_*` in `campus_dynamics_portal`, MySQL 5.6, InnoDB utf8)

Types match source columns for plain-`=` joins. Surrogate `INT AUTO_INCREMENT` PKs. Term = `acad_year CHAR(25)` + `semester INT`.

| Table | Key columns | Notes |
|---|---|---|
| `odel_course_space` | id, courseID CHAR(25), acad_year CHAR(25), semester INT, owner_empid INT, status ENUM(DRAFT,ACTIVE,FROZEN), created_at | UNIQUE(courseID,acad_year,semester) |
| `odel_space_staff` | id, space_id, empid INT, role ENUM(TEACHER,GRADER), is_push_owner TINYINT | multi-lecturer |
| `odel_topic` | id, space_id, title, sort_order, is_published | weeks/units |
| `odel_material` | id, topic_id, type ENUM(FILE,PAGE,LINK), title, file_id NULL, page_html MEDIUMTEXT NULL, url NULL, is_published, published_at | |
| `odel_file` | id, stored_path, orig_name, mime, size_bytes, sha1 CHAR(40), owner_type, owner_ref, created_at | disk + metadata |
| `odel_assignment` | id, space_id, title, instructions MEDIUMTEXT, open_at, due_at, late_until, max_points, weight_points, counts_toward_cw TINYINT, submission_type ENUM(FILE,TEXT,BOTH), max_attempts, late_penalty_pct, rubric_id NULL, is_published | |
| `odel_rubric` / `odel_rubric_criterion` | rubric(id,owner_empid,title,is_shared); criterion(id,rubric_id,name,max_points,sort_order) | optional |
| `odel_submission` | id, assignment_id, regno CHAR(25), attempt_no, text_answer MEDIUMTEXT, status ENUM(DRAFT,SUBMITTED,EXCUSED), submitted_at, is_late, receipt_code CHAR(10), receipt_hash CHAR(40) | UNIQUE(assignment_id,regno,attempt_no) |
| `odel_submission_file` | submission_id, file_id | |
| `odel_submission_grade` | id, submission_id, raw_marks, penalty_pct, final_marks, feedback MEDIUMTEXT, graded_by_empid, graded_at, version | regrades append |
| `odel_gradebook` | id, space_id, regno, odel_points DECIMAL(6,2), computed_at, detail_json TEXT | maintained summary (recompute on grade write) |
| `odel_cw_push` / `odel_cw_push_detail` | push(id,space_id,version,pushed_by_empid,pushed_at,cw_mode,odel_share,ungraded_as_zero,student_count,superseded_by NULL); detail(id,push_id,regno,computed_points,computed_cw,override_cw NULL,override_reason NULL,final_cw,prev_cw,mark_stage_at_push,breakdown_json TEXT) | **append-only, never UPDATE/DELETE** |
| `odel_policy_value` | id, policy_key, scope_level, scope_ref, acad_year, semester, value, active TINYINT, set_by, set_at | versioned |
| `odel_activity_log` / `odel_engagement_summary` | log(actor_type,actor_ref,space_id,verb,object_type,object_id,detail,created_at + indexes); summary(space_id,regno,week_start,logins,views,submissions) | dashboards read summary |
| `odel_notification_log` | channel, recipient, template, ref, status, sent_at | dedupe + budget |
| P2/P3: `odel_quiz*`, `odel_question*`, `odel_forum*`, `odel_live_session`, `odel_attendance`, `odel_exception`, `odel_atrisk_snapshot` | as consultant §5 | build when the phase arrives |

---

## PART C — IMPLEMENTATION TASKS (step by step)

Each task: **files → steps → integration → verify.** Conventions held throughout: **C# 5 only** (no `$""`/`?.`/auto-prop-initializers); parameterised `MySqlCommand`; per-widget try/catch; brace-balance + live-query verification (no compiler); plain-`=` joins; navy flat design; eportal screens on `PortalMaster.master` + `PortalHelper`; eadmin on `SidebarMaster.master` + slug RBAC + `MarksScopeResolver`; AJAX via `[WebMethod]`+`JavaScriptSerializer` (`.d` unwrap); files via `Server.MapPath`+GUID+metadata; email via `EmailSenderProtocol`; audit every state change.

### PHASE 0 — Foundations (do first)

**T0.1 — Schema.** Create the P1 `odel_*` tables (Part B) in `campus_dynamics_portal`. Steps: write DDL with source-matching types + indexes (`space_id`, term, `regno`); run live; verify with `SHOW/DESCRIBE`; seed nothing. *Verify:* tables exist, FKs/indexes present.

**T0.2 — File service + upload handler.** Files: `Portal/odel/OdelUpload.ashx` (chunked receive+reassemble+SHA-1), `OdelFile.ashx` (entitlement-checked stream), `App_Code/Odel/OdelFiles.cs`. Steps: implement 1 MB-chunk protocol (`File.slice` client loop), save to `~/odel-uploads/<yyyymm>/<guid>`, insert `odel_file`; download checks the requester owns/enrolls in the space. *Verify:* a 25 MB upload survives an interrupted connection and hashes correctly.

**T0.3 — Provisioning job.** File: `App_Code/Odel/OdelProvisioning.cs` + an admin "Provision now" button (later a nightly task). Steps: for each assigned `acad_programmecourses` row this term, upsert `odel_course_space` (+ `odel_space_staff`); never touch enrolment. *Verify:* space count = distinct assigned course-terms in a pilot faculty.

**T0.4 — Activity log + engagement rollup + RBAC slugs.** Files: `App_Code/Odel/OdelLog.cs`; register slugs `odel.admin/policy/monitor`. Steps: `OdelLog.Write(...)` helper; nightly rollup query into `odel_engagement_summary`. *Verify:* a logged event appears; rollup populates.

### PHASE 1 — MVP (the teach→submit→grade→coursework loop)

**T1.1 — Student: My ODEL home (`S1`).** Files: `Portal/odel/MyLearning.aspx(.cs)`. Steps: `PortalHelper.GetRegno`; query my `acad_course_registration` course-terms → join `odel_course_space`; per space compute next deadline + running `odel_gradebook` figure + compliance meter; render KPI cards + list (navy design). AJAX `[WebMethod] GetMyLearning()`. *Verify:* a real student sees their spaces + deadlines.

**T1.2 — Student: Course space + materials (`S2`).** Files: `Portal/odel/CourseSpace.aspx(.cs)`. Steps: topics→materials list with **size labels**; PAGE materials render print-friendly; log VIEWED. *Verify:* materials open on mobile; sizes shown pre-download.

**T1.3 — Student: Assignment submission + receipt (`S3`).** Files: `Portal/odel/Submit.aspx(.cs)` + reuse T0.2 upload. Steps: draft autosave (`[WebMethod] AutosaveDraft`, 30 s); Submit → create `odel_submission` (+files), gen `receipt_code`+hash, email via `EmailSenderProtocol`, show receipt; enforce open/due/late-until + attempts. *Verify:* submit → receipt on screen + email; late flagged.

**T1.4 — Student: Running coursework & feedback (`S4`).** Files: `Portal/odel/MyProgress.aspx(.cs)` (or a tab on CourseSpace). Steps: read `odel_gradebook` + per-assignment grades/feedback; show projected 0–40 contribution. *Verify:* numbers match a hand computation.

**T1.5 — Lecturer: My teaching home (`L1`).** Files: `Portal/odel/MyTeaching.aspx(.cs)`. Steps: resolve empID (staff), courses from `acad_programmecourses.lecturer_id` → spaces; compliance meter vs policy min; grading-queue counts. *Verify:* a lecturer sees their courses + "X of Y assignments conducted".

**T1.6 — Lecturer: Content builder + copy-forward (`L2`).** Files: `Portal/odel/BuildContent.aspx(.cs)`. Steps: CRUD topics/materials (AJAX), publish/unpublish, reorder; "copy from last term" clones topics/materials (not submissions). *Verify:* publish a topic+file; student sees it; copy-forward works.

**T1.7 — Lecturer: Assignment builder (`L3`).** Files: `Portal/odel/BuildAssignment.aspx(.cs)`. Steps: create/edit `odel_assignment` with policy-fed defaults; optional rubric; publish → notify roster. *Verify:* published assignment appears for enrolled students only.

**T1.8 — Lecturer: Grading + queue + bulk (`L4`).** Files: `Portal/odel/Grade.aspx(.cs)`. Steps: queue of ungraded `odel_submission`; one-per-page grade+comment(+rubric) → `odel_submission_grade` (version++), recompute `odel_gradebook`; **bulk ZIP** download; **CSV marks** re-upload (validated). *Verify:* grading updates student progress; ZIP/CSV round-trip works.

**T1.9 — Lecturer: Coursework Push (`L5`, linchpin).** Files: `Portal/odel/CourseworkPush.aspx(.cs)`, `App_Code/Odel/OdelPush.cs`. Steps: (1) readiness check (ungraded, weight-sum, late registrants, freeze date); (2) preview table (per student: points→computed CW, PARTIAL offline input, current `mark_stage`, class stats); (3) overrides require reason; (4) password re-entry; (5) commit **mirroring `SaveProvisionalMarks`** — txn + `FOR UPDATE`, write `provisional_course_work_marks` (0–40), recompute total, set stage per rule, `WHERE mark_stage IN ('NOT_ENTERED','ENTERED')`, write `odel_cw_push`+`_detail` snapshot, audit, `TryAutoResolveMarkRequests`. *Verify (critical):* push a pilot course in a transaction, confirm `acad_course_registration` updated correctly for NOT_ENTERED/ENTERED rows only, snapshot immutable, re-push creates v2, CAPTURED rows untouched. **Test against a scratch/rollback first.**

**T1.10 — Admin: Policy Centre (`M1`).** Files: `NewScreens/OdelPolicy.aspx(.cs)`. Steps: institution values + per-course-term override; versioned writes (`active=0` supersede); effective-policy resolver; second-approver on weighting keys. *Verify:* resolver returns the right value + source; change is audited.

**T1.11 — Admin: Compliance + monitoring dashboards (`M2`,`M3`).** Files: `NewScreens/OdelCompliance.aspx(.cs)`, `NewScreens/OdelDashboard.aspx(.cs)`. Steps: PageMethods + Chart.js (General-Dashboard grammar), read summary tables, scoped via `MarksScopeResolver`; lecturer/student compliance grids + institution KPIs; CSV export. *Verify:* dean sees only their faculty; numbers reconcile.

**T1.12 — Sidebar/menu wiring.** eportal: add "Learning" (student) / "My Teaching" (lecturer) nav in `PortalMaster` gated by `IsStaff`. eadmin: add "ODEL" group in `SidebarMaster` (slug-gated). *Verify:* menu shows for the right roles; unmapped-page RBAC rule keeps it visible appropriately.

**T1.13 — Notifications wiring (`F3`).** Assignment published, deadline T-72h/T-24h (to non-submitters), grade released, push done → `EmailSenderProtocol`; log + dedupe. *Verify:* emails send (space-stripped Gmail app-password sender already fixed).

**T1.14 — Pilot + QA.** One faculty (suggest Business & Management), push mode **ADVISORY/PARTIAL** (small ODEL share). Exit: ≥90% pilot allocations meet min-assignments; ≥1 clean push per course; zero marks-pipeline incidents; student page < 3 s on 3G.

### PHASE 2 — Engagement & intelligence
Quizzes + question banks (S5/L: `odel_quiz*`,`odel_question*`); forums; SMS + adaptive reminders (gateway procurement); class analytics; at-risk console; workload/timetable view; exception/extension approvals; rollover assistant; storage console; live-session scheduling + attendance (external links). Widen to all faculties; FULL push mode for faculties that passed a pilot term; **Appraisal feed** (per-lecturer ODEL compliance → appraisal data).

### PHASE 3 — Depth & reach
Similarity screening + integrity console; peer review; offline packs; audio feedback + templates; badges/certificates; sponsor digest; USSD (only if economics work); short-course/CPD storefront (ODEL + SchoolPay + certificates) as a separate business case.

**Explicitly deferred infra:** video hosting/streaming (external links only), WebSockets/real-time (polling suffices), ML analytics (rule-based first).

---

## PART D — Design / UI-UX / coding conventions (must hold)

- **Design:** navy `#05275C` / accent `#174DA4`, flat, radius 0, no gradients/shadows, compact; reuse existing card/table/filter/badge components so ODEL feels native to eportal & eadmin. Mobile-first: ≤150 KB/screen for students, no web fonts, Chart.js only on staff dashboards, size-labelled downloads.
- **eportal screens:** `PortalMaster.master` (HeadContent/MainContent/ScriptContent); identity via `PortalHelper.GetRegno`/`IsStaffUser`; `vacConnectionString` (portal) + `campus_dynamics_portalConnectionString` (academic).
- **eadmin screens:** `SidebarMaster.master`; slug RBAC + `MarksScopeResolver`; PageMethod + Chart.js dashboards (mirror General Dashboard / Results Export Centre).
- **Coding:** C# 5 only; parameterised queries; plain-`=` joins (source-matching column types); per-operation try/catch; transactions + `FOR UPDATE` for the push; brace-balance + live-DB verification (no compiler); audit every state change; files via `Server.MapPath`+GUID+`odel_file`; email via `EmailSenderProtocol`.
- **Marks safety (non-negotiable):** ODEL never writes marks in the background; only the signed push, only rows `mark_stage IN ('NOT_ENTERED','ENTERED')`, only `provisional_course_work_marks` (0–40 int) + recomputed total; corrections after CAPTURED go through **Mark Requests**; every push is an immutable snapshot.

---

## PART E — Risks & open decisions

**Risks (top):** marks-pipeline corruption → push-only + snapshot + stage guard + pilot in ADVISORY; large uploads on Web Forms → chunked handler; storage on-prem → quotas + size labels + archive; MySQL 5.6 analytics → summary tables; lecturer non-adoption → minimums + copy-forward + one-click push + appraisal feed; student data cost → kilobyte budgets + size labels (+ pursue MTN/Airtel zero-rating). Scope creep → phase gates; every feature traces to a Part-A row.

**Open decisions (confirm before P1 build):**
1. **ODEL coursework share of the 40** for the pilot (recommend PARTIAL with a small share, e.g. 10 of 40) and starting **push mode** (ADVISORY vs PARTIAL).
2. **Min policies** (assignments per lecturer, submissions per student) and the **consequence** of student non-compliance (report-only vs an exam-eligibility flag).
3. **Lecturer key reconciliation** — standardise on `acad_programmecourses.lecturer_id` (empID); confirm it's reliably populated for the pilot faculty (else fall back to `acad_teaching_allocation.staffCode`).
4. **Pilot faculty** (recommend Business & Management: large cohorts, standard course types).
5. **Storage** available on the IIS host; is a NAS/file server option before P2?
6. **SMS gateway** (does SchoolPay's provider offer SMS? budget owner?) — gates P2 reminders.
7. **Distance cohort** — new `studsesion` value? NCHE programme approvals constraining which programmes go online first?
8. **Clean up** the abandoned LMS scaffolding (hidden menus, dead `Stud_elearning.aspx`, phantom `campus_dynamics_elearningConnectionString`) — remove or leave dormant?

---

## Reference anchors
- Integration: `CampusDynamics_Portal/LecturerProvisionalMarksController.aspx.cs::SaveProvisionalMarks` (mirror), `acad_course_registration.provisional_course_work_marks`/`mark_stage`, `App_Code/Marks/MarkStageService.cs`, **Mark Requests** workflow, `MarksControllerShared`.
- Patterns: `PortalMaster.master` + `PortalHelper` (eportal); `SidebarMaster.master` + slug RBAC + `MarksScopeResolver` (eadmin); `UploadContent.aspx` file pattern; `EmailSenderProtocol`; General Dashboard / Results Export Centre (Chart.js + PageMethods).
- Roster/allocation: `acad_programmecourses.lecturer_id`, `acad_course_registration`, `acad_teaching_allocation`.
- Do-not-reuse: `campus_dynamics_elearning` DB, `el_*`/`course_content`/`tutor_digital_classes` (phantom), `Elearning.xsd` (reference shapes only).
- Related memory: [[marks-staged-workflow]], [[markrequests-email-notifications]], [[general-dashboard-plan]], [[results-exporter-plan]], [[appraisal-backfill-plan]], [[rbac-role-access-system]].
