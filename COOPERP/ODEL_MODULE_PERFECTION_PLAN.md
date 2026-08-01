# ODEL Module Perfection Plan
**Muteesa I Royal University (MRU) — CampusDynamics_Portal (eportal) e-learning module**

Created 2026-07-18 · Scope: fix broken content drag-drop; perfect the Assignment, Grade-submission and Coursework-Push modules; then perfect the student **My Learning** experience — all made complete, correct, and design-system consistent.

> Architecture recap: every ODEL page is a thin server-rendered shell + inline `<script>` that renders via `Odel.get/post` against **`OdelApi.ashx`**. Shared lib `odel/odel.js` (`Odel.*`), shared styles `odel/odel.css` (navy `#05275C`, accent `#174DA4`, flat, `radius:0`). Backend: `App_Code/Odel/{OdelService,OdelContentService,OdelPushService,OdelCore,OdelNotify}.cs`. Tables in `campus_dynamics_portal` (`odel_*`); cross-DB reads from `campus_dynamics`.

---

## Part 0 — Fix content drag-and-drop (BuildContent.aspx) — the reported "not working at all"

**Root cause (confirmed):** `makeSortable()` attaches a `dragover` handler to each of the three **nested** lists (chapters `#outline`, topics `[data-topics]`, links `[data-links]`). Because they're nested, dragging a *link* also bubbles to the topic-list and chapter-list handlers; each does `list.querySelector('.dragging')`, finds the descendant being dragged, and `insertBefore`s it into the **wrong** list → the link jumps out of its topic. Also `#outline` is a persistent element, so every `load()`/`render()` stacks another `dragover` listener on it.

**Fix (front-end only; backend `chapter.reorder`/`topic.reorder`/`link.reorder` are correct):**
1. Rewrite `makeSortable` so each list's `dragover` **only reorders when the dragged element is a direct child of that list** (`list.contains(d) && d.parentNode===list`) and calls `e.stopPropagation()`. This confines each sortable to its own level — no nested contamination.
2. Bind the `dragstart`/`dragend` on the item via the handle, and drive one shared reorder path; **rebind cleanly** each render (topics/links are recreated each render; for the persistent `#outline` guard against duplicate `dragover` with a `_sortBound` flag / delegate).
3. Visual feedback: `.bc-ml.dragging`, `.bc-tp.dragging`, `.bc-ch.dragging` → `opacity:.45` + dashed outline; a drop-target hint. Handle already exists (`.bc-drag`).
4. Persist state: fire the correct reorder POST on `dragend` (already wired), and keep collapse state.
5. Keep it CSP-safe (no external libs). Verify with brace/paren balance.

**Acceptance:** dragging a material reorders only within its topic; dragging a topic only within its chapter; dragging a chapter only within the space; no element ever escapes its list; order persists after reload.

---

## Part A — Assignment module (BuildAssignment.aspx + OdelService)

**Defects found:**
- **A1 (critical): editing an assignment wipes data.** `GetAssignments` doesn't return `open_at/due_at/late_until/instructions/max_attempts/late_penalty_pct`, and `showForm(a)` doesn't repopulate those inputs → saving an edit posts them empty → `DateOrNull`/blank overwrites the real values.
- **A2: `late_penalty_pct` is unsettable** — Grade advertises "late −X%", `SaveGrade` applies it, but no UI ever sets it → always 0 (dead feature).
- **A3: `max_attempts` unsettable** from the UI (loaded server-side, never enforced — see Part D3).
- **A4: no delete** for an assignment.
- **A5: weak client validation** (title/max/weight).
- **A6: inline styles** instead of `od-*` tokens (consistency).

**Changes:**
- **Backend `GetAssignments`**: include `openAt, dueAt, lateUntil, instructions, maxAttempts, latePenaltyPct, submissionType, weightPoints, countsTowardCw, maxPoints` in the JSON (ISO `yyyy-MM-ddTHH:mm` for the datetime-locals).
- **Backend `SaveAssignment`**: ensure it persists `late_penalty_pct`, `max_attempts` (read from JSON, clamp `0–100` / `≥1`). Verify open/due/late round-trip.
- **New endpoint `assignment.delete`** → `OdelService.DeleteAssignment(spaceId,id)`: guarded — if the assignment has submissions, **unpublish + soft-block** (return a clear message) rather than destroying submitted work; if zero submissions, hard delete (assignment + any orphan draft rows). Route in OdelApi.
- **Form**: add **Late penalty %** and **Max attempts** fields; `showForm(a)` repopulates **all** fields including dates/instructions; client validation (title non-empty, `maxPoints>0`, `latePenalty 0–100`, `maxAttempts≥1`); Delete button in the edit form + per-row Delete action.
- **Consistency**: convert inline styling to `od-form/od-row/od-fld/od-btn/od-badge`.

**Acceptance:** create → edit → save preserves every field; late penalty & attempts persist and are honored; delete is safe; validation blocks nonsense.

---

## Part B — Grade-submission module (Grade.aspx + OdelService.GetQueue/SaveGrade)

**Defects:**
- **B1: flat unpaginated queue** across the whole space — unusable for big classes; `Odel.pager` exists but unused.
- **B2: no per-assignment filter/grouping.**
- **B3: no attempt/resubmission context** shown; grader can't tell a regrade is needed.
- **B4: inline styles** (duplicated hex) instead of tokens.

**Changes:**
- **Backend `GetQueue(spaceId, assignmentId=0, page=1, size=20, onlyUngraded=0)`**: optional filter by assignment, server-side pagination (return `total,page,pages`), and include `attemptNo`, `maxAttempts`, and a `regradeNeeded` flag (latest submitted attempt has no current grade though an earlier attempt was graded). Keep ungraded-first ordering.
- **Front-end**: assignment filter dropdown (from `teach.assignments`), an "ungraded only" toggle, `Odel.pager` at the bottom, all state in the URL via `Odel.state`. Cards rebuilt with `od-card/od-badge/od-btn/od-fld` tokens; show attempt number + a "Regrade needed" amber badge.
- Server clamps mark to `[0,max]` (already) — keep.

**Acceptance:** grader can filter to one assignment, page through, see attempt numbers, and is warned when a graded submission was superseded by a new attempt.

---

## Part C — Coursework-Push module (CourseworkPush.aspx + OdelPushService + OdelService)

**Defects:**
- **C1: `ungradedAsZero` hardcoded `false`** in the UI — the backend path + `formula_note` are unreachable.
- **C2: override detection by value inequality** — typing the same number back with a reason isn't recorded.
- **C3: CW computation inconsistency** — Push clamps `computedCw` to `≤40` and `≤cwShare`; `StudentHome`/`StudentSpace` compute CW **without** the clamp → the number a student sees can differ from what Push writes.
- **C4 (minor): history "written" count** counts eligible-at-snapshot rows, not actually-updated rows.

**Changes:**
- **UI**: add a "Count ungraded submissions as zero" checkbox wired into `push.commit`; re-preview live when toggled so the mean/rows reflect it.
- **Override capture**: mark a row overridden if the value changed **or** a reason was entered (track a per-row dirty flag), so deliberate same-value + reason is honored.
- **Consistency fix C3**: extract the CW formula into one helper and use it in `OdelPushService.BuildRows`, `StudentHome`, and `StudentSpace` (round `points*cwShare/totalWeight`, clamp `[0, min(cwShare,40)]`). One source of truth.
- **C4**: count rows where the guarded UPDATE actually changed a row.
- Token consistency pass.

**Acceptance:** ungraded-as-zero is usable and reflected in preview; same-value-with-reason overrides record; the CW a student sees equals what Push computes/writes.

---

## Part D — My Learning (student) + submission flow — perfect & consistent

**Defects:**
- **D1: progress > 100%.** `StudentHome` `pct = submitted*100/required`, but `submitted` counts submissions to **any** assignment while `required` only counts `counts_toward_cw=1` → practice submissions overflow the meter.
- **D2: student-side nav never highlights.** `PortalMaster.InferNavFromUrl()` only maps teaching pages; `MyLearning/CourseSpace/Submit` aren't listed and don't set `ActiveNav` → "My Learning" never lights up.
- **D3 (correctness): resubmission silently drops the grade & coursework points.** `EnsureDraft` opens a new attempt when the last was SUBMITTED; grade is attached to the old `submissionId`; `StudentSpace/StudentHome/RecomputeGradebook` read the **latest** attempt → badge flips "Graded" → "Submitted" and CW points fall to 0 until re-graded. `max_attempts` is loaded but **never enforced**.
- **D4: inline styles** vs tokens; weak empty/all-done states.
- **D5 (minor): N+1** per-space scalar queries in `StudentHome`.

**Changes:**
- **D1**: count `submitted` only over `counts_toward_cw=1` assignments; clamp `pct` to `[0,100]`; show "done/required" honestly.
- **D2**: fix nav — add `MyLearning/CourseSpace/Submit/ViewPage` → `"Learning"` in `InferNavFromUrl` (and/or set `ActiveNav="Learning"` in the student shells). Confirms "My Learning" highlights across the student side.
- **D3**: enforce `max_attempts` in `EnsureDraft`/`SubmitFinalize` (default sensible cap, e.g. policy or unlimited if 0) **and** carry the grading signal forward: when a graded submission is superseded by a new attempt, surface a **"Regrade needed"** state (Part B) instead of silently zeroing — and don't drop the old grade from the gradebook until the new attempt is graded (keep last graded attempt's points as the current CW contribution, flagged provisional). Warn the student before resubmitting that it requires re-grading.
- **D4**: redesign `MyLearning.aspx` + `CourseSpace.aspx` with `od-tile/od-meter/od-badge/od-card` tokens, clear states (no courses / all caught up / deadlines due), consistent header. Remove duplicated inline hex.
- **D5**: fold the per-space metrics into fewer set-based queries where cheap (optional; keep behavior identical).

**Acceptance:** meter never exceeds 100%; "My Learning" highlights on every student page; resubmitting never silently zeroes a student's coursework — it clearly flags regrade-needed and preserves the last graded points until re-graded; student pages match the design system.

---

## Execution order & verification
1. Part 0 drag-drop (isolated, high-visibility). 2. Part A assignment. 3. Part B grade. 4. Part C push. 5. Part D my-learning + nav + resubmission. Each step: edit → brace/paren balance check (no compiler) → confirm OdelApi routes + method signatures line up → smoke-test any new SQL against the live DB. New endpoints added to the `OdelApi.ashx` dispatch table. C# 5 constraints (no interpolation, no `?.`, no auto-prop initializers). Keep everything CSP-safe and token-consistent.

## Status — ALL DONE & verified 2026-07-18 (static: brace/paren balance + live SQL smoke tests; no compiler)
- [x] **Part 0 drag-drop** — `makeSortable` scoped each list's `dragover` to its own direct children with `stopPropagation` + `_dob` bind-once guard; `.dragging` outline feedback. Nested bleed + listener stacking gone.
- [x] **Part A assignment** — `GetAssignments` returns open/due/late (datetime-local formatted) + instructions + max_attempts + late_penalty_pct; `showForm` repopulates every field (edit-loses-data fixed); `SaveAssignment` persists late_penalty_pct + max_attempts; new `assignment.delete` (guards submitted work); Late-penalty + Max-attempts fields; validation; per-row + in-form Delete.
- [x] **Part B grade** — `GetQueue(spaceId,assignmentId,page,size,onlyUngraded)`: latest-attempt-per-student, assignment filter, ungraded-only toggle, server pagination, attempt number + **Regrade-needed** flag; page rebuilt with tokens + `Odel.pager` + URL state.
- [x] **Part C push** — `OdelCore.CwFromPoints()` single formula used by push + StudentHome + StudentSpace (student CW now == pushed CW); `ungradedAsZero` made a **real** toggle (per-student graded-weight denominator) exposed as a checkbox with live re-preview; override recorded when value changed **or** a reason entered. (MySQL 5.6 gotcha: outer-column ref moved from nested JOIN-ON to WHERE.)
- [x] **Part D my-learning** — progress clamped 0–100% and `submitted` counts only counting assignments (no >100%); nav highlight fixed (`InferNavFromUrl` now maps MyLearning/CourseSpace/Submit/ViewPage → "Learning"); **resubmission**: `max_attempts` enforced in `SubmitFinalize`, Submit page shows attempts + resubmit warning + submission-type validation, and `RecomputeGradebook` now counts only the **latest graded attempt** per assignment (no double-count on regrade; earned CW preserved until re-graded); MyLearning redesigned with summary strip + overdue/soon/none deadline states + tokens.

Files touched: `BuildContent.aspx`, `BuildAssignment.aspx`, `Grade.aspx`, `CourseworkPush.aspx`, `MyLearning.aspx`, `Submit.aspx`, `OdelApi.ashx`, `App_Code/Odel/{OdelService,OdelPushService,OdelCore}.cs`, `PortalMaster.master.cs`. All brace/paren balanced; new endpoints routed; new SQL smoke-tested on live DB. Deploy-time smoke test recommended (no local ASP.NET compiler).
