# ODEL Assignment Management — Redesign & Deepening Plan
**MRU · CampusDynamics_Portal (eportal) · BuildAssignment + new AssignmentManage + student flow + API**

Created 2026-07-18. Goal: recreate assignment **creation + listing** as a modal-driven, card-based, drag-orderable experience (borrowing the content-library builder's modal), add a dedicated **Assignment details/management hub**, and deepen the **API** and **student** experience — robust, complete, design-system consistent.

> Reuses: `odel/odel.css` tokens + `odel/odel.js` (`Odel.get/post/dropzone/pager/tabs/state`), the BuildContent modal pattern (dark blur backdrop, scroll-lock, circular close, sectioned body), the CourseManage tabbed-hub pattern. Backend `App_Code/Odel/{OdelService,OdelCore}.cs`, routing `OdelApi.ashx`. C# 5 constraints.

---

## 1. What we have vs. what's missing
**Have:** `odel_assignment` (title, instructions, open/due/late, max_points, weight_points, counts_toward_cw, submission_type, max_attempts, late_penalty_pct, rubric_id, topic_id, is_published); create/edit/publish/delete via an **inline form + plain table**; grading queue (Part B); student submit (Submit.aspx).

**Missing / weak:**
- Inline form (no modal), plain table (no stats, no status, no ordering, no filters).
- No **per-assignment management** surface (submissions, who hasn't submitted, statistics, deadline controls all live elsewhere or nowhere).
- No **ordering**, **duplicate**, **close-now**, **scheduled** state, **per-student extensions**.
- API returns thin data (no stats, no window state, no roster).
- Student side shows minimal status; **deadline extensions not honored**.

---

## 2. Schema (additive, self-healing via `OdelCore.EnsureAssignmentSchema`)
```sql
ALTER TABLE odel_assignment
  ADD sort_order   INT NOT NULL DEFAULT 0,
  ADD published_at DATETIME NULL,
  ADD updated_at   DATETIME NULL;

CREATE TABLE odel_assignment_extension (
  id            INT UNSIGNED PK AUTO_INCREMENT,
  assignment_id INT UNSIGNED NOT NULL,
  regno         CHAR(25) NOT NULL,
  due_at        DATETIME NULL,     -- per-student override (NULL = inherit)
  late_until    DATETIME NULL,
  extra_attempts INT NOT NULL DEFAULT 0,
  reason        VARCHAR(250) NULL,
  created_by    INT NULL, created_at DATETIME NULL,
  UNIQUE KEY uq (assignment_id, regno)
);
```
Self-heal runs lazily (static-guarded) alongside `EnsureContentSchema`. Rubric tables already exist (`odel_rubric`, `odel_rubric_criterion`) — kept as a documented next phase, not wired now.

**Derived "window state"** (computed, not stored): `DRAFT` (unpublished) → `SCHEDULED` (published, now<open) → `OPEN` (open≤now≤due) → `LATE` (due<now≤late) → `CLOSED` (now>late). Per-student extensions shift due/late.

---

## 3. Backend API (OdelService) — new/reworked, all `public static string` JSON
| Action (OdelApi) | Method | Purpose |
|---|---|---|
| `asg.list` | `AssignmentList(spaceId, filter, q)` | Cards: every field + **stats** (enrolled, submitted, graded, ungraded, late, notSubmitted, mean) + windowState + sortOrder. One list query + one grouped stats query (no N+1). |
| `asg.get` | `AssignmentGet(spaceId, id)` | Full single assignment (all fields ISO-formatted) + stats + extension count — for the manage hub + edit modal. |
| `asg.save` | `AssignmentSave(spaceId, json)` | Create/update; validates; sets updated_at, published_at on first publish; supports sortOrder, topicId. (Supersedes SaveAssignment; old route kept as alias.) |
| `asg.publish` | `SetAssignmentPublished` (existing) + stamps published_at | Publish/unpublish (+ notify students on first publish). |
| `asg.delete` | `DeleteAssignment` (existing) | Guarded delete (refuses if submitted work). |
| `asg.duplicate` | `AssignmentDuplicate(spaceId, id)` | Clone as unpublished "(copy)", no submissions, next sort_order. |
| `asg.reorder` | `AssignmentReorder(spaceId, idsCsv)` | Persist card order (sort_order). |
| `asg.close` | `AssignmentClose(spaceId, id)` | Set late_until=NOW() → closes submissions immediately. |
| `asg.students` | `AssignmentStudents(spaceId, id)` | Roster with per-student status (notSubmitted/submitted/graded+mark/late), attempt count, extension (if any) — powers Students tab + extension UI. |
| `asg.stats` | `AssignmentStats(spaceId, id)` | Grade distribution buckets + submission-over-time + counts — Statistics tab. |
| `asg.extend` | `ExtensionSave(spaceId, id, regno, dueAt, lateUntil, extraAttempts, reason)` | Upsert per-student extension. |
| `asg.unextend` | `ExtensionRemove(spaceId, extId)` | Remove an extension. |
| `asg.header` | `AssignmentHeader(id)` | Resolve course/space/title for AssignmentManage code-behind header. |

**Grading** stays on the Part-B `teach.queue` (`GetQueue` already supports `assignmentId` filter + pagination + regrade flag) and `grade.save`.

**Student:** `StudentAssignment` reworked to compute the **effective** open/due/late/attempts by folding in `odel_assignment_extension` for the caller's regno, so window + attempt cap honor extensions. `StudentSpace` assignment rows enriched: windowState, dueEffective, attemptsUsed/max, graded mark, hasExtension.

---

## 4. Front-end

### 4.1 BuildAssignment.aspx — full rebuild (creation + listing)
- **Server-rendered header** + Back to course (unchanged code-behind).
- **Toolbar:** `+ New assignment` (opens modal), filter chips (All / Published / Draft), search box, live count. All state in URL (`Odel.state`).
- **Card list** (`.od-cards`-style, custom `.as-card`): drag handle · title · type badge · **status pill** (Draft/Scheduled/Open/Late/Closed, colored) · due line ("Due in 3d" / "Closed") · **mini-stats** (submitted / graded / not-submitted with tiny meters) · weight·maxPoints·countsCW · quick actions (**Manage**, Edit, Publish toggle, Duplicate, Delete). **Drag-drop reorder** (single-level, scoped sortable → `asg.reorder`).
- **Creation/edit modal** (borrowed from BuildContent): dark blur backdrop, scroll-lock, circular ×, sectioned body:
  - **Basics:** Title, Instructions (lightweight rich contenteditable like the content builder's page editor).
  - **Marking:** Max points, Weight (to CW), Counts to CW (yes/practice), Submission type (File / Text / Both).
  - **Schedule:** Open at, Due at, Late until (datetime-local) with plain-language hints.
  - **Rules:** Max attempts (0=unlimited), Late penalty %.
  - Footer: Save / Save & publish / Cancel; inline validation.
- Empty state (no assignments) with a prominent create CTA.

### 4.2 AssignmentManage.aspx?a=ID — NEW management hub
- Server-rendered header (course + assignment title via `asg.header`), Back to Assignments.
- **KPI cards:** Enrolled · Submitted · Graded · Ungraded · Late · Mean mark.
- **Action bar:** Publish/Unpublish · Close now · Extend deadline (all) · Edit (opens the same modal) · Duplicate · Delete.
- **Tabs (GET-state):**
  - **Overview** — settings summary (schedule, marking, rules) + window state + readiness (ungraded count) + quick actions.
  - **Submissions** — the grading queue for THIS assignment (`teach.queue` filtered), inline mark + feedback, attempt + regrade badges, pagination.
  - **Students** — full roster with status, attempt count, extension badge, and a **per-student Extend** action (modal: new due/late/extra attempts + reason).
  - **Statistics** — grade distribution bars, submitted-vs-not donut-ish bars, late count, mean/median.
- Reuses odel.css tokens throughout.

### 4.3 Student side
- **CourseSpace.aspx** assignment rows rebuilt: status pill (Open/Due in X/Late/Closed/Submitted/Graded m/M), attempts left, **extension badge** when the student has one, deadline honored from effective dates.
- **Submit.aspx** already shows attempts/receipts (prior work); now the window + attempt cap come from the extension-aware `StudentAssignment`, so an extended student can submit within their own window. Closed/no-attempts states clear.

---

## 5. Execution order
1. Schema self-heal (`EnsureAssignmentSchema`) + apply. 2. Backend methods + routes. 3. BuildAssignment rebuild. 4. AssignmentManage new page (+ .cs). 5. Student side (StudentAssignment/StudentSpace + CourseSpace/Submit). 6. Verify: brace/paren balance, route↔signature match, live SQL smoke tests, empty-space (6) + populated-space (1) sanity.

## Status — ALL DONE & verified 2026-07-18 (brace/paren balance + live SQL smoke tests incl. rolled-back write paths; no compiler)
- [x] **Schema** — `sort_order`/`published_at`/`updated_at` on `odel_assignment` + `odel_assignment_extension` table; applied to live DB + backfilled; self-heal `OdelCore.EnsureAssignmentSchema` (guarded).
- [x] **Backend+routes** — `AssignmentList`(stats+window), `AssignmentGet`, extended `SaveAssignment` (sort_order/topic_id/updated_at), `SetAssignmentPublished` (published_at), `AssignmentDuplicate`, `AssignmentReorder`, `AssignmentClose`, `AssignmentStudents`, `AssignmentStats`, `ExtensionSave/Remove`, `AssignmentHeader`; `WindowState`/`EnrolledCount`/`ApplyExtension` helpers; `StudentAssignment`+`StudentSpace`+`SubmitFinalize` fold in per-student extensions; 13 `asg.*` routes (all defined-once/routed-once).
- [x] **BuildAssignment** — rebuilt: filter chips (All/Published/Draft) + search + count; **card list** with drag-reorder (scoped sortable → asg.reorder), status pills, due countdown, submitted/graded/to-grade/not-submitted stats, quick actions (Manage/Edit/Publish/Duplicate/Delete); **modal builder** (dark-blur backdrop, scroll-lock, circular ×, sections Basics/Marking/Schedule/Rules, rich contenteditable instructions) with Save + Save&publish + Delete + validation.
- [x] **AssignmentManage.aspx (new)** — hub with 6 KPIs, action bar (Publish/Close now/Duplicate/Delete), tabs **Overview / Submissions (inline grading + pagination) / Students (roster + per-student Extend modal) / Statistics (distribution bars + mean/median/hi/lo) / Settings (edit form)**; `AssignmentManage.aspx.cs` resolves header via `asg.header`.
- [x] **Student side** — `Submit.aspx` shows instructions + extension note + honors effective window/attempts; `CourseSpace.aspx` assignment rows show window pill (Closed/Late/Not-open), extension badge, attempts, graded mark, context-aware action.
- [x] **Verify** — all files brace/paren balanced; every route↔method matched; live smoke tests of list/get/students/stats + rolled-back duplicate/extension-upsert/close.

**Deferred (documented next phase):** rubric-based grading (tables `odel_rubric`/`odel_rubric_criterion` + `feedback_file_id` exist, not wired); consolidated cross-course "My Assignments" student view. Deploy-time smoke test recommended (no local ASP.NET compiler).
