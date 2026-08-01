# Marks Change Audit & Follow-Up — Plan

**Goal:** Complete, tamper-proof "who changed what" for student marks, surfaced clearly on the
exams/marks dashboard, in tables, and in per-student / per-course detail views.

_Date: 2026-07-03. Status: **EXECUTED & verified** (DB live; C#/ASPX awaits deploy)._

## OUTCOME (what was built)
- **Phase 1 (live):** 3 triggers on `acad_results` (INSERT/UPDATE/DELETE) → `acad_marks_audit`, attributed
  via a connector-safe per-connection context table `mark_audit_context` (CONNECTION_ID()) with a **60s
  freshness guard** (stale context → `performed_by='system'`, never a wrong actor). UPDATE logs only on
  real score/grade change. Backfilled 35 historical result changes with real actors. Scripts:
  `sql/marks_audit/01_triggers.sql`, `02_backfill.sql`, `99_rollback.sql`. Tested via rolled-back txns.
- **Phase 2 (needs deploy):** `MarksDashboard.aspx(.cs)` — "Mark Changes & Audit" panel: KPIs
  (changes/editors/deletions/total), scope-filtered clickable feed (search/action/window/limit),
  detail modal (before→after, actor, source, reason, IP, links), + link to `MarksAuditTrail.aspx`.
  Endpoints `GetMarkAuditStats` + `GetMarkAuditFeed` (scope via `ProgFilter` on the student's programme).
- **Phase 4 (needs deploy):** attribution wired in `MarkRequestsAdmin` (PublishToResults + Revert) and
  `MarksControllerShared` (provisional publish + unpublish) via `SetMarkAuditContext`. Other paths safely
  log `system` until instrumented (same one-line pattern; freshness guard prevents mislabels).
- **Phase 3:** the feed endpoint accepts `regno`/`course` filters, so the same panel/modal is the
  per-student / per-course history surface. (Embedding into StudentResultsView is a trivial follow-up.)

---
_Original plan below._


---

## 1. What exists today (investigation summary)

- **`campus_dynamics.acad_marks_audit`** — a purpose-built change-log table with an ideal schema
  (`action_type, performed_by, ip_address, target_table, target_id, regno, course_id, acad_year,
  semester, progid, field_changed, old_value, new_value, old_cw_mark…new_grade, old_approved_by,
  new_approved_by, change_reason, source_page, batch_id, created_at`) — **but only 5 rows.** It is
  written **only** by the bulk faculty sheet editor (`MarksSheetService` → `MarksAuditService`,
  `source_page=FacultyExamResults.ascx`, `target_table=acad_examresults_faculty`).
- **`acad_results` changes are essentially UN-logged to `acad_marks_audit`.** They come from ≥6 paths:
  1. `App_Code/Marks/MarksControllerShared.cs` publish (`INSERT … ON DUPLICATE KEY UPDATE`) + GPA update.
  2. `MarksControllerShared` **unpublish** (`DELETE FROM acad_results`).
  3. eadmin `MarkRequestsAdmin.aspx.cs` `PublishToResults` + `RevertPublishedResult`.
  4. eportal `MarkRequestsController.aspx.cs` request publish.
  5. Direct SQL / migrations / backfills.
  6. (my earlier one-off corrections.)
  Each records only a **narrative** in `acad_results.result_comment` (`Score old→new, Grade old→new`)
  — 614 rows have comments, 106 have score changes. Fragmented + free-text.
- **No triggers** exist on `acad_results` or `acad_course_registration` (confirmed via information_schema).
- Rich complementary history in **`acad_activity_log`** (222k rows): `Faculty Exam Results Editor`
  (14,820 rows, structured old→new + user + IP), `Capture Results` (64k), the `Mark Request *` trail.
- Actor resolution (eadmin): `MarksAuthorizationService.GetCurrentUser()` (Session ScreenName→username)
  + `GetClientIP()`. Scope: `MarksScopeResolver.Resolve()` → `scope.ProgFilter(alias)`.
- Dashboards: `MarksDashboard.aspx` (AJAX, scope-filtered) is the exams dashboard. Audit screens
  `MarksAuditTrail.aspx` + `ResultsAuditLog.aspx` read `acad_activity_log`; `AuditCentre.aspx` exists.

## 2. Design principle

Make **`acad_marks_audit` the single source of truth** for final-result changes, and **guarantee
completeness with a database trigger** (no code path — app, SP, or raw SQL — can bypass it). Enrich
attribution from the app where possible; fall back safely otherwise. Then display it everywhere.

## 3. Phases

### Phase 1 — Bulletproof capture (DB; immediate, testable)  ✅ execute first
- **Triggers** on `acad_results`: `AFTER INSERT`, `AFTER UPDATE` (only when `score`/`grade` change),
  `AFTER DELETE` → one row into `acad_marks_audit`:
  - `action_type` = INSERT / UPDATE / DELETE
  - `target_table='acad_results'`, `regno, course_id(=courseid), acad_year(=acad), semester`
  - `old_total/new_total` = OLD/NEW `score`; `old_grade/new_grade` = OLD/NEW `grade`
  - `performed_by` = `NULLIF(TRIM(@mark_actor),'')` else `'system'`
  - `source_page` = `NULLIF(TRIM(@mark_source),'')` else `'db-trigger'`
  - `change_reason` = `@mark_reason`; `batch_id` = `@mark_batch`; `ip_address` = `@mark_ip`
  - No dedup needed (nothing else writes `acad_results` rows into `acad_marks_audit`).
  - Session vars are user-defined (`@mark_*`), readable in triggers; unset → safe fallback.
- **Backfill** historical `acad_results` changes into `acad_marks_audit` by parsing
  `result_comment` (`… Score <old>→<new>, Grade <old>→<new> …`, arrow = U+2192) — action_type
  `MIGRATE`, source_page `backfill:result_comment`, performed_by parsed from the comment where present.
- Verify: trigger fires (INSERT/UPDATE/DELETE) via a rolled-back transaction; backfill counts.

### Phase 2 — Display on the exams dashboard (visible deliverable)
Add a **"Mark Changes / Audit"** section to `MarksDashboard.aspx` (scope-filtered via `ProgFilter`):
- New AJAX endpoints (mirroring the page's existing `act=`/WebMethod pattern):
  `GetMarkAuditStats` (KPIs: changes today/week/total, distinct editors, by action, top editors),
  `GetMarkAuditFeed` (recent changes, filterable by date/actor/action/search/regno/course),
  `GetMarkAuditDetail` (one change: full before/after + student + course + links).
- UI: KPI row + filters + a clickable changes table + a detail modal (before→after, actor, source,
  reason, IP, time; links to student results + course). Consistent with existing design system.

### Phase 3 — Tables & details
- **Per-student / per-course change history**: reuse `GetMarkAuditFeed` filtered by `regno`/`course`
  in the marks detail surfaces (ProvisionalMarksController `GetRecordDetails`, StudentResultsView).
- Ensure the dashboard changes table is itself the "tables" deliverable (sortable, paged, exportable).

### Phase 4 — App attribution enrichment (additive; needs deploy)
Set `@mark_actor/@mark_source/@mark_reason/@mark_ip/@mark_batch` on the connection **immediately
before** each `acad_results` write, so trigger rows are richly attributed:
- `MarksControllerShared` publish + unpublish + GPA.
- eadmin `MarkRequestsAdmin` `PublishToResults` + `RevertPublishedResult`.
- eportal `MarkRequestsController` request publish.
Until deployed, those changes log as `performed_by='system'`, `source_page='db-trigger'` — still
complete; attribution improves on deploy. (All major writers set the var → no stale-var mislabel.)

## 4. Safety / no-regression
- Purely additive: new triggers + rows in an existing table + new read-only endpoints + a new panel.
- Trigger is lean (single guarded INSERT) and only logs real score/grade changes.
- Rollback: `DROP TRIGGER` scripts kept alongside the create scripts.
- Everything DB-side tested live with transactions + ROLLBACK before committing.

## 5. Files
- SQL: `COOPERP/sql/marks_audit/01_triggers.sql`, `02_backfill.sql`, `99_rollback.sql`.
- eadmin: `NewScreens/MarksDashboard.aspx(.cs)` (+ optional detail surfaces).
- Phase 4: `App_Code/Marks/MarksControllerShared.cs`, `NewScreens/MarkRequestsAdmin.aspx.cs`,
  `CampusDynamics_Portal/MarkRequestsController.aspx.cs`.
