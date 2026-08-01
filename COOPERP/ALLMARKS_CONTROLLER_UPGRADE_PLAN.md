# AllMarksController Upgrade — Plan

_Date: 2026-07-04. Status: **EXECUTED & verified** (needs compile/deploy)._

## OUTCOME
1. **AllMarksController.aspx.cs** — rewritten: every WebMethod delegates through a `Run()` wrapper that
   logs an independent, timed, attributed record to `acad_marks_action_log` (page=AllMarksController,
   action, actor, IP, context {id/ids/status/marks/...}, outcome derived from the result, duration);
   all WebMethods now `EnableSession=true` (needed for actor + scope); Page_Load access gate
   (`scope.HasAccess`) shows a friendly denial to no-scope users.
2. **Sidebar** — AllMarks `data-roles` broadened to `admin registrar exam_officer dean hod`; new
   **"Admin Action Log"** item → `MarksActionLog.aspx` (same roles).
3. **MarksActionLog.aspx(.cs)** — NEW read-only log viewer, gated to `CanViewAudit()`. KPIs (total /
   window / today / users / errors), filters (window, page, user, action, outcome, search, limit),
   paged table, detail modal (full context_json, IP, duration, correlation), side lists (top users /
   busiest pages). AJAX `?ajax=stats|feed|detail`. SQL smoke-tested live.
4. **MarksControllerShared.ForceSetStatus** — clears stale `provisional_published_by/date` when a
   record is moved OFF 'published' (cascade completeness). Forcing TO 'published' already runs the full
   cascade via ProcessProvisionalAction. Publish/unpublish attribution flows into the acad_results audit.

## Known follow-ups (noted, not blocking)
- Force-downgrade of a published record clears the flags but does NOT delete the live acad_results row —
  use the explicit **Unpublish** action to remove a published mark (which does the full reversal).
  Extending BulkForceSetStatus + a full auto-unpublish on force-downgrade is the same one-block pattern.

---
_Original plan below._


## Goal
Make `AllMarksController.aspx` powerful, consistent, and accessible to top management (deans/HODs/
registrar) with scoped edit rights; ensure status changes cascade all relevant fields; log every
admin action on the page as an independent record; and add a sidebar-linked admin action-log viewer.

## Current state (investigation)
- `AllMarksController.aspx.cs` is a **thin delegation layer** — every WebMethod just calls
  `MarksControllerShared.X(...)`. So it can be wrapped with logging/auth WITHOUT touching shared code
  used by other pages (ProvisionalMarksController etc.).
- `MarksControllerShared` actions already **enforce scope** via `RecordInScope()` (admin=all,
  dean=faculty progs, HOD=dept progs) — so dean/HOD editing is already backend-supported; only the
  sidebar (`data-roles="admin"`) and missing `EnableSession` hid it.
- `MarksActionLogger` (+ `acad_marks_action_log`) EXISTS with a clean API (StartTimer/StopAndLog/
  QuickLog/BuildContext, OUTCOME_* constants, self-creating table, swallows own errors) but is
  **never called from the mark actions**. This is the gap.
- Publish cascade is complete (acad_results score/grade/gradept/CU/gpa + provisional_* published_by/
  date/status; my `acad_results` triggers + `SetMarkAuditContext` already attribute it). Small gap:
  reject/reset does NOT clear `provisional_published_by/date` (orphan).
- `MarksAuthorizationService`: roles + `GetCurrentUser()`/`GetClientIP()`; scope via `MarksScopeResolver`.
- `MarksAlertDashboard.aspx` reads the action log but is operational-health focused (not a trace viewer).
- Sidebar `SidebarMaster.master`: `cd-sidebar__subitem data-roles="..."` items under the Exam section;
  RBAC also filtered by `sys_menu_items` slugs.

## Execution
1. **AllMarksController.aspx.cs** — wrap all WebMethods with `MarksActionLogger` (StartTimer → call →
   StopAndLog with page="AllMarksController", action name, outcome parsed from result JSON, context
   {id/ids/status/...}); add `EnableSession=true` (needed for actor + scope); add a Page_Load access
   gate (allow anyone with a marks scope; friendly deny otherwise). Result: every action on THIS page
   is an independent, timed, attributed log record.
2. **Sidebar** — broaden AllMarksController `data-roles` to `admin dean hod registrar`; add an
   **"Admin Action Log"** item → `MarksActionLog.aspx`.
3. **MarksActionLog.aspx(.cs)** — NEW dedicated log-viewer controller (role-gated to management):
   KPIs (total / today / distinct users / errors), filters (page, user, action, outcome, date, search),
   a rich paged table, and a detail modal (full context_json, IP, duration, correlation). AJAX endpoints
   `?ajax=stats|feed|detail`. Reads `acad_marks_action_log`.
4. **MarksControllerShared** — reject/reset path clears `provisional_published_by/date` (cascade
   completeness) — the only shared-code change, a pure correctness fix.

## Safety
Additive: logging swallows its own errors (never breaks actions); the log viewer is read-only; access
broadening is backed by existing scope enforcement; cascade fix is a targeted UPDATE. DB-side tested live.
