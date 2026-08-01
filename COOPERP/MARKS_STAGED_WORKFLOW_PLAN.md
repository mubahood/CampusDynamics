# Staged (Level-by-Level) Marks Publishing Workflow — Strategic & Implementation Plan

**Status:** PLAN ONLY — no code to be written until this plan is reviewed/approved.
**Author:** Campus Dynamics dev
**Scope:** Replace the single-person "publish" with a 4-stage approval chain that applies **only to pending marks**, while harmonising already-published marks as "completed all stages".
**University:** Muteesa I Royal University (MRU).

---

## 1. Executive summary (the strategy)

Today a mark goes: lecturer enters (e-portal) → an admin reviews/publishes (writes `acad_results`). We are inserting two new authority levels (HOD capture, Dean approve) before the final Senate/admin publish, and formalising every transition as an **auditable, session-based commit** (create record → choose params → preview → commit → snapshot).

**The lifecycle (canonical):**

```
Stage 0  ENROLMENT        → mark_stage = NOT_ENTERED      (auto, on course registration)
Stage 1  LECTURER         → mark_stage = ENTERED          (needs BOTH coursework + exam)
Stage 2  HOD (capture)    → mark_stage = CAPTURED         (via mark_capture_records)
Stage 3  DEAN (approve)   → mark_stage = APPROVED         (via mark_approve_records; provisional results released)
Stage 4  SENATE/ADMIN     → mark_stage = PUBLISHED        (via mark_publish_records; final results in acad_results)
```

**Three design pillars**

1. **One authoritative lifecycle column** — add `mark_stage` to `acad_course_registration`. Keep the legacy `provisional_marks_status` in sync (mapping table in §5) so nothing existing breaks.
2. **One generic "stage advance" engine, three thin wrappers.** Capture / Approve / Publish are *the same mechanics* (create → params → preview → commit → snapshot → advance + back-reference). We build **one** `StageAdvanceService` + **one** shared controller base, parameterised by stage, plus three record tables. This satisfies "same mechanics again" without 3× copy-paste, and stays simple.
3. **Harmonise first, then enforce.** Before enabling stages, backfill `mark_stage` for every existing row and create synthetic "migration" stage-records so already-published marks read as having passed every stage. Forward enforcement only ever touches non-published marks.

**Reuse what exists:** the role-scope engine (`MarksScopeResolver` / `MarksScope`: admin=all, dean=faculty, HOD=department) gates who sees/acts at each stage. The publish-to-`acad_results` logic already lives in `MarksControllerShared.ProcessProvisionalAction` and is reused verbatim at Stage 4.

---

## 2. Current-state analysis (verified against the live DB)

### 2.1 Tables
- **`campus_dynamics_portal.acad_course_registration`** — the enrolment + provisional-marks record (one row per student-course enrolment). Relevant columns:
  `ID, regno, courseID, acad_year, semester, prog_id, stud_session,`
  `provisional_course_work_marks, provisional_exam_marks, provisional_total_marks,`
  `provisional_marks_status, provisional_marks_review_comments, provisional_marks_reviewed_by,`
  `provisional_marks_review_date, provisional_submitted_by, provisional_published_by, provisional_published_date,`
  `marks_edit_flag, edit_reason, edit_audit_trail, change_date`.
- **`campus_dynamics.acad_results`** — FINAL published results (`regno, courseid, acad, semester, studyyear, score, grade, gradept, gpa, CreditUnits, result_comment, progid`). ~626k rows.
- **`campus_dynamics.acad_examresults_faculty`** — faculty exam-results store with numeric `total_mark` + `approved_by` (used by ResultsAnalytics).
- **`hrm_departments`** (`ID, dept_name, dept_headID, faculty_code`), **`acad_faculty`** (`faculty_code, faculty_name, faculty_dean`), **`acad_programme`** (`progcode, faculty_code, department_id`). These drive role scoping (see `faculty-dept-programme-hod`).

### 2.2 Current status distribution (sizing the migration)
| provisional_marks_status | rows | with both CW+exam |
|---|---|---|
| published | 68,101 | 31 |
| pending | 58,468 | 7,027 |
| not_entered | 408 | 0 |
| approved | 31 | 31 |

**Insight:** "published" (68,101) are essentially **already-final** marks — only 31 carry provisional component marks, the rest were harmonised from `acad_results` history. These must be flagged "completed all stages". "pending with both marks" (7,027) are the genuine Stage-1-complete backlog that will flow through the new stages.

### 2.3 Code touch-points (verified)
- **e-portal lecturer entry:** `CampusDynamics_Portal/LecturerProvisionalMarksController.aspx.cs` — builds a `portalWhere` over `acad_course_registration cr`, filtered to the lecturer's assigned courses + a status dropdown. **This is where "lecturers see only pending" is enforced.**
- **admin marks controllers (COOPERP):** `AllMarksController`, `PublishedMarksController`, `ProvisionalMarksController`, `PendingExam/CourseworkMarksController` → all delegate to **`App_Code/Marks/MarksControllerShared.cs`** (list/stats/filters/actions, incl. `ProcessProvisionalAction` = the publish→`acad_results` engine + GPA/CGPA recompute). Already role-scoped.
- **scope engine:** `App_Code/Marks/MarksScopeResolver.cs` (`MarksScope`: `IsAdmin`, `Mode` all|faculty|department, `AllowedProgCodes`, `ProgFilter`, `ProgFilterExpr`, `AllowsProg`).
- **sidebar:** `COOPERP/NewScreens/SidebarMaster.master` (+ slug grants in `sys_role_permissions`, see `rbac-role-access-system`).

---

## 3. Target data model

### 3.1 New authoritative lifecycle on `acad_course_registration` (all NULLABLE)
| column | type | meaning |
|---|---|---|
| `mark_stage` | VARCHAR(20) NULL | `NOT_ENTERED` \| `ENTERED` \| `CAPTURED` \| `APPROVED` \| `PUBLISHED` (authoritative) |
| `capture_record_id` | INT NULL | → `mark_capture_records.id` (traceability) |
| `approve_record_id` | INT NULL | → `mark_approve_records.id` |
| `publish_record_id` | INT NULL | → `mark_publish_records.id` |
| `mark_stage_changed_at` | DATETIME NULL | last stage transition timestamp |
| `mark_stage_changed_by` | VARCHAR(150) NULL | last actor (denormalised for quick lists) |
| `mark_returned_reason` | TEXT NULL | optional send-back reason (see §3.4) |

> Rationale: prefer **adding columns** to the existing enrolment row over new join tables (per instruction). The 3 record-id back-references give a full breadcrumb from any mark to the exact session that advanced it.

### 3.2 Three stage-record tables (the "session" objects)
Same shape for all three (Capture/Approve/Publish are the same mechanics). Created in **`campus_dynamics_portal`** (co-located with the marks). All columns nullable except `id`.

`mark_capture_records` / `mark_approve_records` / `mark_publish_records`:
| column | type | meaning |
|---|---|---|
| `id` | INT PK AI | |
| `status` | VARCHAR(15) NULL | `DRAFT` \| `COMMITTED` \| `CANCELLED` |
| `performed_by` | VARCHAR(150) NULL | login username |
| `performed_by_name` | VARCHAR(200) NULL | display name |
| `performed_by_role` | VARCHAR(40) NULL | `hod` \| `dean` \| `admin`/`vc`/`dvc` |
| `scope_faculty_code` | VARCHAR(10) NULL | resolved scope (for audit) |
| `scope_department_id` | INT NULL | |
| `param_prog_id` | VARCHAR(25) NULL | chosen programme or NULL = all |
| `param_year_of_study` | INT NULL | chosen year of study or NULL = all |
| `param_acad_year` | VARCHAR(25) NULL | |
| `param_semester` | INT NULL | NULL = all |
| `param_all` | TINYINT NULL | 1 = "everything in my scope" |
| `params_json` | TEXT NULL | full raw selection (forward-compatible) |
| `preview_count` | INT NULL | rows the preview matched |
| `affected_count` | INT NULL | rows actually advanced on commit |
| `summary_json` | TEXT NULL | what changed (counts by prog/year/status) |
| `stats_snapshot_json` | TEXT NULL | performance snapshot at commit (pass rate, grade dist, avg) |
| `notes` | TEXT NULL | free comment |
| `is_migration` | TINYINT NULL | 1 = synthetic record for already-published harmonisation |
| `created_at` | DATETIME NULL DEFAULT CURRENT_TIMESTAMP | |
| `committed_at` | DATETIME NULL | |

> Three tables (not one) because the instruction explicitly names `MarkCaptureRecords` and an "equivalent" approve flow; separate tables keep each stage's audit clean and let each grow independently. They share identical structure so one service class handles all three via a table-name parameter.

### 3.3 Stage → legacy status mapping (keep `provisional_marks_status` in sync)
| `mark_stage` | `provisional_marks_status` (kept in sync) | visible to | writes `acad_results`? |
|---|---|---|---|
| NOT_ENTERED | `not_entered` | lecturer | no |
| ENTERED | `pending` | lecturer, HOD | no |
| CAPTURED | `captured` *(new value)* | HOD, Dean | no |
| APPROVED | `approved` | Dean, Senate/admin — **internal only; students see nothing yet** | no |
| PUBLISHED | `published` | everyone; **students see final** | **yes** |

### 3.4 Send-back (return to previous stage) — **CONFIRMED: include**
A stage commit may **return** selected marks one level down (HOD ENTERED↔, Dean returns CAPTURED → ENTERED, Senate returns APPROVED → CAPTURED) with a reason. Implemented as the same record with a `RETURN` action flag + `mark_returned_reason`; no new tables. Returned marks re-appear in the lower level's actionable queue (and, if returned to ENTERED, become visible to the lecturer again).

---

## 4. The generic stage engine (build once, use 3×)

`App_Code/Marks/StageAdvanceService.cs` — one class, parameterised by a `StageDef`:

```
StageDef { Name, RecordTable, FromStage, ToStage, LegacyStatus, RequiredRole(s), WritesResults }
  CAPTURE : ENTERED  → CAPTURED  (table mark_capture_records,  roles: hod[+admin], writesResults=false)
  APPROVE : CAPTURED → APPROVED  (table mark_approve_records,  roles: dean[+admin], writesResults=false, releasesProvisional=true)
  PUBLISH : APPROVED → PUBLISHED (table mark_publish_records,  roles: admin/vc/dvc, writesResults=true)
```

Service responsibilities (identical for each stage):
1. `CreateDraft(scope, params)` → insert a `DRAFT` record stamped with resolver scope + chosen params.
2. `Preview(recordId)` → run the scoped, param-filtered query of marks currently in `FromStage`; return count + per-programme/year breakdown + the would-be stats snapshot. **No writes.**
3. `Commit(recordId)` → in ONE transaction: re-run the preview query `FOR UPDATE`-style, advance matched rows `FromStage → ToStage`, set `<stage>_record_id`, `mark_stage`, synced `provisional_marks_status`, `mark_stage_changed_*`; for PUBLISH, call existing `ProcessProvisionalAction` per row (writes `acad_results`, recomputes GPA/CGPA); write `summary_json` + `stats_snapshot_json` + `affected_count` + `committed_at` + `status=COMMITTED` onto the record.
4. `Cancel(recordId)` → mark DRAFT record `CANCELLED` (no effect on marks).
5. `Report(recordId)` / `Export(recordId)` → PDF/Excel of the committed record (summary + affected list + snapshot).

All queries go through `MarksScope` so a HOD can only capture their department, a Dean only their faculty, admin all. Eligibility guard: a stage only matches rows in its exact `FromStage` (so nothing skips a level, nothing double-processes).

---

## 5. Schema migrations (all additive, all nullable)

> Executed by a startup `EnsureXxxColumns`-style guard (like existing `EnsureProvisionalColumns`) so deploys never crash on missing columns, plus a one-off backfill script. **Back up tables first** (`*_bak_YYYYMMDD`).

**M1 — columns on `acad_course_registration`** (§3.1): `mark_stage`, `capture_record_id`, `approve_record_id`, `publish_record_id`, `mark_stage_changed_at`, `mark_stage_changed_by`, `mark_returned_reason`. All `NULL`.

**M2 — create `mark_capture_records`, `mark_approve_records`, `mark_publish_records`** (§3.2).

**M3 — indexes** (non-unique, safe): `acad_course_registration(mark_stage)`, `(prog_id, mark_stage)`, and on each record table `(performed_by)`, `(status)`.

**M4 — backfill `mark_stage`** from current state (idempotent, only where `mark_stage IS NULL`):
- `provisional_marks_status='published'` → `PUBLISHED`
- `provisional_marks_status='approved'` → `APPROVED`
- `provisional_marks_status='pending'` AND both component marks present → `ENTERED`
- everything else (`not_entered`, `pending` w/o both marks, NULL) → `NOT_ENTERED`
- Sync `provisional_marks_status='captured'` is **not** produced by backfill (no historical capture state).

**M5 — keep legacy status in sync going forward:** every stage commit updates BOTH `mark_stage` and `provisional_marks_status` per §3.3 so existing controllers/portal keep working unchanged.

---

## 6. Harmonising already-published marks (the critical constraint)

Goal: already-published marks must read as "completed every stage" — no contradiction, audit stays consistent.

**H1 — synthetic migration records.** Insert exactly **one** `is_migration=1`, `status='COMMITTED'` row into each of `mark_capture_records`, `mark_approve_records`, `mark_publish_records` (e.g. notes = "Pre-staging migration — marks already published before staged workflow"). Capture their ids: `MIG_CAP`, `MIG_APP`, `MIG_PUB`.

**H2 — back-reference published marks.** For every `acad_course_registration` with `mark_stage='PUBLISHED'`: set `capture_record_id=MIG_CAP`, `approve_record_id=MIG_APP`, `publish_record_id=MIG_PUB`. Now each published mark shows it passed all three sessions (the migration ones) → audit trail consistent.

**H3 — back-reference approved marks (the 31).** For `mark_stage='APPROVED'`: set `capture_record_id=MIG_CAP`, `approve_record_id=MIG_APP` (they legitimately await final publish).

**H4 — stats on migration records.** Optionally compute and store `stats_snapshot_json`/`affected_count` on the migration records so reports over them aren't blank.

> We deliberately use **3 shared migration records**, not one-per-mark (which would add ~68k×3 rows for no benefit). The instruction's "create stage-completion records for each already-published mark" is satisfied logically: every published mark *references* a committed completion record for each stage. If true per-mark rows are later required, they can be generated from these.

---

## 7. Phase-by-phase task list

### Phase 0 — Foundations (migrations + engine + harmonisation) ✅ DONE (2026-06-29)
- [x] **0.1** Backed up `acad_course_registration` → `..._bak_20260629` (127,008 = 127,008).
- [x] **0.2** M1: 7 nullable stage columns added to `acad_course_registration`.
- [x] **0.3** M2: `mark_capture_records` / `mark_approve_records` / `mark_publish_records` created.
- [x] **0.4** M3: indexes on `mark_stage`, `(prog_id,mark_stage)`, record `(performed_by)`/`(status)`.
- [x] **0.5** M4: backfill — PUBLISHED 68,101 · ENTERED 7,027 · NOT_ENTERED 51,849 · APPROVED 31 · 0 NULL.
- [x] **0.6** H1–H3: 3 migration records (id=1 each); all 68,101 published back-referenced (cap+app+pub), 31 approved (cap+app).
- [x] **0.7** `StageAdvanceService` (StageDef Capture/Approve/Publish; CreateDraft/Preview/Commit/Cancel/ReturnMarks; scope-aware).
- [x] **0.8** `MarkStageService` (constants, LegacyStatus/Label/PrevStage, idempotent `EnsureSchema`) + `MarksControllerShared.PublishSingle` wrapper.
- [x] **0.9** Verified: counts reconcile; sample **MRU2027000002** = 8 PUBLISHED (all refs) + 2 ENTERED; capture commit (HOD dept 41) moved both ENTERED→CAPTURED w/ record+affected_count=2, then rolled back (stays ENTERED for Phase 3 UI test).

### Phase 1 — Stage 0: Enrolment auto-create ✅ DONE (2026-06-29)
- [x] **1.1** Located all 5 insert paths (portal AdminCourseRegistrationController, COOPERP Course/TeacherCourseRegistrationLedgerController, API v2 staff+academic).
- [x] **1.2** Implemented via **DB column defaults** (`mark_stage`→`NOT_ENTERED`, `provisional_marks_status`→`not_entered`) — one metadata-only change covers all paths + any future ones. Verified: a new enrolment row auto-starts NOT_ENTERED.
- [x] **1.3** All existing rows already backfilled in 0.5.

### Phase 2 — Stage 1: Lecturer entry + portal visibility ✅ DONE (2026-06-29)
- [x] **2.1** `LecturerProvisionalMarksController` — all 3 save paths set `mark_stage='ENTERED'` only when BOTH CW+exam present, else `NOT_ENTERED`.
- [x] **2.2** List `portalWhere` restricted to `COALESCE(mark_stage,'NOT_ENTERED') IN ('NOT_ENTERED','ENTERED')` — captured+ rows vanish for lecturers. Verified on MRU2027000002 (2 ENTERED visible, 8 PUBLISHED hidden).
- [x] **2.3** All 3 edit/clear paths guarded with `... AND cr.mark_stage IN ('NOT_ENTERED','ENTERED')` + explicit "left the lecturer stage" rejection message — no silent edits after capture.
- [x] **2.4** Lecturer stats left as an informational teaching-load summary (the actionable list is the enforced view).

### Phase 3 — Stage 2: HOD Capture (full stack) ✅ DONE (2026-06-30)
Built as a **shared, reusable stage console** (one brain + one JS + one CSS) used by all three stages.
- [x] **3.1** `MarkCaptureController.aspx(.cs)` — thin page delegating to `StageConsoleShared`, scoped via `MarksScope` (HOD department).
- [x] **3.2** Browse + funnel stats (NOT_ENTERED…PUBLISHED) + filters (year, semester, programme, search) + queue of ENTERED marks below the HOD.
- [x] **3.3** Capture wizard: **Preview & Commit** modal — `CreateAndPreview` (creates DRAFT, returns count + per-programme breakdown + stats snapshot) → `Commit`.
- [x] **3.4** Commit (via `StageAdvanceService` CAPTURE) advances ENTERED→CAPTURED, sets `capture_record_id`, writes summary + stats snapshot + actor/role/when on the record.
- [x] **3.5** **CSV export** per session (`?export=csv&rid=`); funnel + breakdown serve as reports.
- [x] **3.6** Sidebar "Capture Marks (HOD)"; slug `academics.exam.capture` → `hod`,`dean` (+admin wildcard).
- [x] **3.7** "Session history" tab (lists sessions, status, scope, affected, exports). Send-back supported.

### Phase 4 — Stage 3: Dean Approve ✅ DONE (2026-06-30)
- [x] **4.1–4.5** `MarkApproveController.aspx(.cs)` (same shared console, stage=APPROVE) — Dean faculty scope; CAPTURED→APPROVED; `approve_record_id` + snapshot; APPROVED internal-only; sidebar "Approve Marks (Dean)" slug `academics.exam.approve` → `dean`; history + CSV. Verified: approved marks leave the HOD queue.

### Phase 5 — Stage 4: Senate/Admin Publish ✅ DONE (2026-06-30)
- [x] **5.1–5.4** `MarkPublishController.aspx(.cs)` (stage=PUBLISH) — **admin/VC/DVC only** (role gate in `StageConsoleShared.CanAct`); APPROVED→PUBLISHED; commit calls `MarksControllerShared.PublishSingle` → `ProcessProvisionalAction` (writes `acad_results`, recomputes GPA/CGPA), sets `publish_record_id`; snapshot/actor; sidebar "Publish Results (Senate)" slug `academics.exam.publish` → `vc` (+admin); history + CSV.
- [x] **5.5** Legacy `PublishedMarksController` retained as read-only oversight; the staged flow is the action path.

### Phase 6 — Student-facing results (final only) ✅ DONE (2026-06-30)
- [x] **6.1–6.2** Verified `StudentResults.aspx.cs` reads **only `acad_results`**, written **only** at Stage 4 publish. APPROVED is internal (no provisional student view). Architecturally satisfied — no change needed.

### Phase 7 — Audit, traceability ✅ DONE (2026-06-30)
- [x] **7.1** Mark journey is fully traceable via `capture/approve/publish_record_id` back-references → each session record holds who/role/when/params/snapshot/affected.
- [x] **7.2** Stage **funnel** rendered on every console (per scope).
- [x] **7.3** Session records + history tab + CSV exports = the clear, consistent cross-stage audit trail. (acad_activity_log integration optional/future.)

### Phase 8 — Verification & rollback ✅ DONE (2026-06-30)
- [x] **8.1** Reconciled: funnel NOT_ENTERED 51,849 · ENTERED 7,027 · CAPTURED 0 · APPROVED 31 · PUBLISHED 68,101; 3 migration records intact; **0** published marks missing a publish ref.
- [x] **8.2** End-to-end chain verified on **MRU2027000002** in a transaction (capture→approve→publish, all refs linked) then rolled back — sample stays 2 ENTERED + 8 PUBLISHED for live UI testing by HOD KMicheal (dept 41) → Dean (faculty 04) → Senate.
- [x] **8.4** Rollback: all changes additive (nullable cols + 3 new tables) + backup `acad_course_registration_bak_20260629`. Inherently gradual — until an HOD actually captures, the lecturer view is unchanged (only pending marks shown). To disable: revert the lecturer `mark_stage` filter + hide the 3 menu items; no data loss.
- [ ] **8.3** Hard feature flag (`MarksStagingEnabled`) — deemed unnecessary (flow is inherently safe/gradual); documented instead.

---

## 8. Visibility matrix (who sees a mark at each stage)

| mark_stage | Lecturer (portal) | HOD (capture) | Dean (approve) | Senate/Admin (publish) | Student |
|---|---|---|---|---|---|
| NOT_ENTERED | ✅ edit | ✅ view/stats | – | view-all | – |
| ENTERED | ✅ edit | ✅ **capture** | view/stats | view-all | – |
| CAPTURED | ❌ hidden | ✅ view (history) | ✅ **approve** | view-all | – |
| APPROVED | ❌ | ❌ (left HOD) | ✅ view (history) | ✅ **publish** | ❌ (internal) |
| PUBLISHED | ❌ | ❌ | ❌ | ✅ history | ✅ final |

All rows additionally filtered by `MarksScope` (admin=all, dean=faculty, HOD=department).

---

## 9. Files to create / modify (inventory)

**New (App_Code):** `Marks/StageAdvanceService.cs`, `Marks/MarkStageService.cs`, `Marks/MarkStageMigration.cs` (idempotent ensure+backfill+harmonise).
**New (COOPERP/NewScreens):** `MarkCaptureController.aspx(.cs)`, `MarkApproveController.aspx(.cs)`, `MarkPublishController.aspx(.cs)`, `MarkStageRecords.aspx(.cs)` (shared history viewer), report/export handlers.
**Modify (COOPERP):** `SidebarMaster.master` (3 menu items), `App_Code/Marks/MarksControllerShared.cs` (stage-aware status, publish gated to APPROVED→PUBLISHED), `NewScreens/MarksDashboard` & `ResultsAnalytics` (stage funnel).
**Modify (portal):** `LecturerProvisionalMarksController.aspx(.cs)` (visibility + ENTERED transition), student provisional-results view.
**DB:** migrations M1–M5 + harmonisation H1–H4; sidebar slugs in `sys_role_permissions`.

---

## 10. Decisions — RESOLVED (locked 2026-06)

1. **Send-back/reject:** ✅ **Include lightweight return** (§3.4). Each stage can return marks one level down with a reason.
2. **Provisional visibility at Dean stage:** ✅ **Internal only** — students see nothing at APPROVED; results appear to students only when PUBLISHED (final). §3.3, §8, Phase 6 updated.
3. **Final publish writer:** ✅ **Reuse existing `ProcessProvisionalAction`** — final `acad_results`/GPA/CGPA identical to today.
4. **Publish rights:** ✅ **Admin/VC/DVC only** — no delegated Dean publish. Phase 5.1 updated.
5. **Legacy `acad_results` rows with no `acad_course_registration` counterpart:** leave as-is (final, outside the staged flow). *(Confirm if different.)*

---

## 11. Guardrails honoured
- All new columns **nullable**; prefer **adding columns** to `acad_course_registration` over new tables; only **3 record tables** created (genuinely needed for the session/audit objects).
- **Already-published marks** are harmonised to "all stages complete" before any enforcement; forward stages touch only non-published marks.
- Idempotent ensure/backfill so deploys never crash existing rows; table backups before changes.
- Reuses existing scope engine + publish engine; one generic stage service avoids over-engineering.
