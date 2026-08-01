# My Learning (student) — Rebuild to mirror My Teaching
**MRU · CampusDynamics_Portal (eportal) · MyLearning.aspx + CourseSpace.aspx**

Created 2026-07-18. Goal: make the **student** experience a read-only mirror of the **lecturer** experience — a server-rendered course **listing** (like `MyTeaching.aspx`) that opens a rich read-only course **hub** (like `CourseManage.aspx`, but view-only). Students *see and access*, never manage.

---

## 1. How the teaching side works (the template we mirror)
- **`MyTeaching.aspx`** — thin shell (`<asp:Literal litBody>`). **`MyTeaching.aspx.cs`** server-renders on first load (no AJAX flash): calls `OdelService.TeachingSpacesLite()`, builds `od-tile` cards (courseID · title · year/sem/status + an assignments meter + roster/materials stats), each linking to `CourseManage.aspx?space=<id>`, with **GET pagination** (`?page=`).
- **`CourseManage.aspx(.cs)`** — server-rendered hub: navy compact header (`cm-head`) + KPI strip (`cm-kpi`) + two panels (Manage actions + Setup checklist), from `OdelService.CourseDashboard(space)`.

Both are **server-rendered + GET-driven** — the pattern the student side must match.

## 2. Current student side (to replace)
- **`MyLearning.aspx`** — AJAX SPA (`student.home`), `.od-cards` tiles + a summary strip. Works, but doesn't match the server-rendered teaching listing and has a loading flash.
- **`CourseSpace.aspx`** — AJAX student course view (chapters→topics→materials + assignments + coursework). Functional but lacks the header/KPI hub styling of CourseManage.
- Backend `StudentHome()` already returns per registered course: `id, courseID, title, acadYear, semester` + `required, submitted, materials, nextDue, overdue, cw, cwShare` (add `status`).

## 3. Target design

### 3.1 MyLearning.aspx — server-rendered listing (mirror MyTeaching)
- `MyLearning.aspx`: thin shell with `litBody` + the same tile CSS as MyTeaching (hover lift, `od-cards` grid).
- `MyLearning.aspx.cs`: on `Page_Load`, call `OdelService.StudentHome()`, deserialize, and render **tiles** (no AJAX). Each tile → `CourseSpace.aspx?space=<id>`:
  - Header: **courseID** (bold) · title · `year Sem N` · status badge.
  - Body: **Coursework `cw/cwShare`** headline + a deadline chip (overdue → red / due-soon → amber / none → green "caught up"); a **progress meter** (`submitted/required`, clamped 0–100, green when complete); stats row: `submitted/required submitted` · `materials materials`.
  - `od-tile--ok` styling when the student has no overdue work and is caught up.
- **GET pagination** (`?page=`), page size 12, identical Pager markup to MyTeaching.
- Empty state: "You are not enrolled in any online courses yet."
- Optional compact summary line above the grid (courses · deadlines due · coursework earned · materials) — student value-add, still server-rendered.

### 3.2 CourseSpace.aspx — read-only student hub (consistent with CourseManage)
- Add a **navy compact header** (course code + title · year/sem · status) with a "← My Learning" link — same look as `cm-head`.
- Add a **KPI strip** (`cm-kpi`-style): Coursework (`cw/cwShare`) · Assignments (total) · Submitted · Graded · Materials · Next deadline. Computed from the `student.space` payload in JS (assignments[] + chapters[] materials).
- Keep the two content sections, restyled consistently: **Assignments** (each row: title, window pill Open/Due-in/Late/Closed, submitted/graded badge, attempts, extension badge, and a Submit / View link — the read-only student actions already built) and **Course materials** (chapters → topics → materials by kind: YouTube embed, image, reading download, page, link).
- No manage buttons anywhere — students only view and submit.
- Stays AJAX (`student.space`) for the interactive material embeds, but visually matches the teaching hub.

## 4. Backend
- `StudentHome()`: add `sp.status` to the SELECT + the per-space dictionary so tiles can show ACTIVE/FROZEN (mirrors MyTeaching showing status).
- No other backend changes required; `StudentSpace()` already returns everything CourseSpace needs (chapters, assignments with status/attempts/extension, coursework, cwShare). KPIs are derived client-side.

## 5. Nav & consistency
- "My Learning" nav highlight already fixed (`InferNavFromUrl` → Learning for MyLearning/CourseSpace/Submit). Design tokens (`od-*`), icons (`Odel.ic`), and the flat navy theme reused throughout. No POST; all navigation is GET (tile links, pager).

## Status — DONE & verified 2026-07-18 (balance + live SQL; no compiler)
- [x] **Backend** — `StudentHome()` now returns `sp.status` per space (mirrors MyTeaching showing status).
- [x] **MyLearning server-render** — `MyLearning.aspx` is now a thin `litBody` shell; `MyLearning.aspx.cs` server-renders (no AJAX flash) exactly like MyTeaching: a compact `od-sum` summary strip (enrolled courses · with deadlines · coursework earned · materials) + `od-cards` tiles → `CourseSpace.aspx?space=<id>`, with **GET pagination** (`?page=`). Each tile: courseID · title · year/sem/status; coursework `cw/cwShare` headline + deadline chip (overdue red / due-soon amber / caught-up green); a `submitted/required` progress meter; and `submitted/required` + `materials` stats. `od-tile--ok` when caught up.
- [x] **CourseSpace read-only hub** — added a navy `cs-head` header (course code · title · year/sem, "← My Learning") + a `cs-kpi` strip (Coursework · Assignments · Submitted · Graded · To-do[warn] · Materials, derived client-side) + a next-deadline line, above the existing Assignments (window pills, badges, submit/view links) and Course-materials sections — same look as CourseManage, but view-only.
- [x] **Verify** — MyLearning.aspx/.cs, CourseSpace.aspx, OdelService.cs all brace/paren balanced; `sp.status` query valid on live DB; nav highlight already routes MyLearning/CourseSpace → "Learning". All navigation is GET; students only view/submit.
