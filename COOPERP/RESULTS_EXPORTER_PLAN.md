# Results Export Centre — Master Plan & Roadmap

> **Screen:** `NewScreens/ResultsExporter.aspx` (eadmin) — title "Results Export Centre".
> **Audience:** Top management / academic administration (Admin, Registrar, Dean, HOD) — scoped by `MarksScopeResolver`.
> **Purpose:** A single, powerful, dynamically-configurable module to export **marks + results statistics** for external representation (Senate, Council, NCHE, external examiners, quality assurance).
> **Status:** PLAN — grounded in live-verified schema + existing code patterns. Nothing built yet.
> **Last updated:** 2026-07-04. University: **Muteesa I Royal University (MRU)**.

---

## 0. Why this module (and why it's new)

Research confirmed the exports that exist today are **scattered and inadequate for admin/external reporting**:
- `AllMarksController` — an **editing/approval console**, has **no export at all** (this is the "wrong module").
- `MarkEntry` — single-course CSV, lecturer-scoped, fixed columns, no statistics.
- `StudentResultsView` — single-student XLSX only.
- `GraduationAnalysis` — graduation summaries only, no raw marks, no format choice.

**None** can produce a filtered, multi-scope marks sheet **with statistics** in a chosen format for external representation. This module fills that gap with clean separation of concerns: *AllMarksController = edit; Results Export Centre = report & export.*

Design principles (same discipline that made the General Dashboard solid):
1. **Every figure is backed by a verified column / the system's own grading logic** — no invented metrics.
2. **Reuse existing tech** — DevExpress + SpreadsheetML + CSV patterns already in the project; the NCHE 2015 grading + GPA + award-class logic from `MarksControllerShared` / DB functions.
3. **Authoritative source = published `acad_results`** (GPA-bearing, Senate-published); provisional is opt-in.
4. **Scope is server-enforced** (`MarksScopeResolver`) — a Dean can never export beyond their faculty.
5. **Match DESIGN_SYSTEM.md exactly** — flat, navy `#05275C`, radius 0, the `fm-page-header`/`fs-filter-bar`/`fs-card`/`fs-table`/`fs-modal`/`pf-stats` components.

---

## 1. Verified Data Model (live — do not guess)

### 1.1 Published results — `campus_dynamics.acad_results` (627,151 rows; 22,010 for 2025/2026)
Authoritative, Senate-published, GPA-bearing. **Primary source for the exporter.**

| Column | Meaning | Notes |
|---|---|---|
| `regno` | student ref | join → acad_student |
| `courseid` | course code | join → acad_course |
| `acad` | academic year "2025/2026" | ⚠️ dirty values exist → filter `acad REGEXP '^[0-9]{4}/[0-9]{4}$'` |
| `semester` | 1 / 2 / 3 | |
| `studyyear` | year of study | |
| `score` | **final total mark 0–100** | ⚠️ NO CW/exam split here |
| `grade` | letter grade | ⚠️ legacy dirty grades exist (A-, B-, C-, E, 0.0) → normalize/whitelist A,B+,B,C+,C,D+,D,F |
| `gradept` | grade point 0–5 | |
| `gpa` | **semester GPA** (denormalized on every row of that student/term) | |
| `CreditUnits` | CU snapshot for the course | use directly (historical accuracy) |
| `progid` | programme code | join → acad_programme (99.98% match) |
| `is_retake` | 0/1 | |

**Real grade distribution:** B 143,746 · C+ 109,512 · B+ 101,467 · C 90,675 · A 67,844 · D 51,808 · D+ 49,610 · F 12,218 (+ tiny legacy).
**No pass/fail column** → derive: **pass = `score >= 50`** (grades A..D); fail = F / `score < 50`. Confirmed by `acad_gs_details` (D = 50–54 min pass; F = 0–49). *Masters/PG (levelCode 4/5) pass at 60 — handle per level.*

### 1.2 Provisional marks — `campus_dynamics_portal.acad_course_registration` (127,178; 52,302 for 2025/2026)
In-flight staged-workflow marks **with CW/exam split** but **no grade/GPA**. Opt-in source (for a CW/exam breakdown sheet).
- `provisional_course_work_marks`, `provisional_exam_marks`, `provisional_total_marks`, `provisional_marks_status` (`published`/`pending`/`not_entered`/`approved`/`captured`), `mark_stage`, `acad_year`, `semester`, `prog_id`, `regno`, `courseID`, `registration_type`.

### 1.3 Grading / GPA / classification (NCHE 2015 — from DB, matches `MarksControllerShared`)
- **Grade→point→range** in `campus_dynamics.acad_gs_details` (`gsID, grade, gradep, min_mark, max_mark, acad_lev`). Bachelors bands: **A 5.0 (80–100) · B+ 4.5 (75–79) · B 4.0 (70–74) · C+ 3.5 (65–69) · C 3.0 (60–64) · D+ 2.5 (55–59) · D 2.0 (50–54) · F 0.0 (0–49)**.
- **GPA/CGPA** = `SUM(CreditUnits*gradept)/SUM(CreditUnits)` (stored fns `acad_GPAFinder` per term / `acad_CGPAFinder` cumulative). **Computable directly in SQL** — the exporter will compute in SQL (fast, no per-row proc calls).
- **Degree classification** in `campus_dynamics.acad_gs_award` (`gsID, lowerlim, upperlim, award, acad_level`). Bachelors: **First 4.40–5.00 · Second Upper 3.60–4.39 · Second Lower 2.80–3.59 · Pass/Third 2.00–2.79**. (Diploma/Cert/Masters have their own rows/labels — use `acad_programme.levelCode` → `acad_level`.)

### 1.4 Course metadata & joins
- `acad_course` (`courseID`, `courseName`, `CreditUnit`) — but `acad_results.CreditUnits` is already snapshotted; use it.
- Names: `acad_programme.progname`, `acad_faculty.faculty_name`, `acad_programme.levelCode`.
- Join paths (verified ~99–100%): `acad_results.regno→acad_student.regno`; `.progid→acad_programme.progcode`; `progcode→faculty_code→acad_faculty`; `.courseid→acad_course.courseID`.
- **PERF (learned from the General Dashboard):** CHAR join keys are space-padded, but MySQL `=` and `DISTINCT` **ignore trailing padding** — so use **plain `=` joins, NOT `TRIM()=TRIM()`** (TRIM defeats the index and makes 627k-row joins crawl). Verify equivalence per join, then use plain `=`. Keep TRIM only in cheap `IFNULL(...)<>''` empty-checks / dirty-year regex.

---

## 2. Architecture

| Concern | Decision |
|---|---|
| **Page shell** | `SidebarMaster.master`, `Inherits="COOPERP_NewScreens_ResultsExporter"`, ScriptManager available from master. |
| **Two interaction modes** | **(a) Preview + stats via AJAX PageMethods** (fast, dynamic, no reload — like the dashboard); **(b) File download via postback** (`Response.End` streams the file — the proven `NCHEExporter` pattern). |
| **Config carrier** | A single hidden field `hdnConfig` holds the JSON config (filters + report mode + format + column choices). JS keeps it in sync; the AJAX preview reads it; the export postback reads the same JSON server-side → identical scope for preview and download. |
| **Connections** | `vacConnectionString` (campus_dynamics) for results; `campus_dynamics_portal.` fully-qualified for provisional. |
| **Scope** | `MarksScopeResolver.Resolve()` server-side on **every** endpoint + export; `scope.ProgFilter("r","progid")` injected into WHERE. No client can widen it. |
| **Grading logic** | Read `grade`/`gradept`/`gpa` directly from `acad_results`; compute CGPA + class in SQL using the verified `acad_gs_award` thresholds (match `MarksControllerShared.ComputeAwardClass`). |
| **Language** | C# 5 only (no `$""`, `?.`, auto-prop initializers). Verify via brace balance + live queries. |

### Export mechanisms (all already in the codebase — no new deps)
- **CSV** → `StringBuilder` + `text/csv` + `Response.End` (pattern from `AuditCentre`/`MarkEntry`), with a robust `CsvEsc`.
- **Excel** → **multi-sheet SpreadsheetML** (`application/vnd.ms-excel` XML, pattern from `FeesStructureExport`) — branded, styled, dependency-free, and lets us emit **Cover + Statistics + Data** sheets. (DevExpress `WriteXlsxToResponse` is the fallback for a single flat grid.)
- **PDF / print** → a print-optimized HTML view (pattern from `TranscriptPrint`) opened in a new tab → browser "Save as PDF". Best-looking for external representation, lowest risk. (DevExpress `PrintingSystem.ExportToPdf` is a later enhancement.)

---

## 3. Report Modes (what admins can export)

The core "dynamic configuration": pick a **mode**, apply **filters**, choose a **format**. Each mode is backed by verified columns.

1. **Marks Sheet (detailed)** — one row per student×course: RegNo, Name, Programme, Study Year, Course code+name, CU, Score, Grade, Points, Sem GPA, Retake. *(Published source; or Provisional to include CW/Exam split.)* The workhorse results export.
2. **Student Results Summary** — one row per student: RegNo, Name, Programme, Faculty, courses taken, credits attempted/earned, **Semester GPA, CGPA, Award Class**, passed/failed counts. For Senate result lists & graduation.
3. **Course Performance Statistics** — one row per course: enrolled, sat, passed, **pass rate %**, mean score, **grade distribution (A…F)**, best/worst. For QA & external examiners.
4. **Programme / Faculty Statistics** — one row per programme (or faculty rollup): students, mean score, mean GPA, pass rate, grade distribution, **class-of-degree distribution**. For management & NCHE/Council.
5. **Grade Distribution** — grade counts + percentages (overall or grouped by course/programme). Quick QA snapshot.

---

## 4. Dynamic Filter / Config Model

Filter bar (real values from DB, scope-limited):
| Filter | Source / values |
|---|---|
| **Source** | Published (`acad_results`) [default] · Provisional (`acad_course_registration`) |
| **Academic year** | distinct clean `acad` (regex-filtered), newest first; default = current busiest year |
| **Semester** | 1 / 2 / 3 / All |
| **Study year** | 1..N / All |
| **Faculty** | `acad_faculty` (scope-limited) |
| **Programme** | `acad_programme` (cascades from faculty; scope-limited) |
| **Course** | optional, `acad_course` (typeahead) |
| **Retakes** | Include / Exclude / Only (`is_retake`) |
| **Grade** | optional single grade filter |
| **Pass/Fail** | All / Pass only / Fail only (derived `score>=50`) |
| **Report mode** | the 5 modes above |
| **Format** | Excel (multi-sheet) · CSV · Print/PDF |
| **Columns** | per-mode column toggles (include/exclude optional columns) |

Rules: AND-combined; "All" omits the predicate; whitelist→fixed-SQL mapping (parameterized, injection-safe); scope predicate always appended server-side.

---

## 5. Statistics Catalog (preview panel + embedded in exports)

Shown live in the preview (KPI cards + small charts, Chart.js) and written into the **Statistics sheet** of Excel / the Print view:
- **Headline:** records, distinct students, distinct courses, mean score, **overall pass rate**, mean GPA.
- **Grade distribution** (A,B+,B,C+,C,D+,D,F) counts + %.
- **Pass rate by course** (top & bottom performers).
- **Programme summary** (students, mean score, pass rate, mean GPA, class distribution).
- **Class-of-degree distribution** (First/2:1/2:2/Pass) — for summary mode.
- **GPA buckets** (e.g. <2.0, 2.0–2.79, 2.8–3.59, 3.6–4.39, 4.4–5.0).

---

## 6. UI/UX Layout (matches DESIGN_SYSTEM.md / FeesStructure)

```
┌ fm-page-header (navy) ── "Results Export Centre" + scope chip ─────────────┐
├ fs-filter-bar ── Source · Year · Semester · Study Year · Faculty · Programme
│                  · Course · Retakes · Grade · Pass/Fail   [Preview] [Reset] │
├ config row ───── Report mode (segmented) · Format (segmented) · Columns ▾   │
├ pf-stats ─────── headline KPI cards (records, students, pass rate, mean GPA)│
├ fs-card ──────── charts: grade distribution · class distribution (Chart.js) │
├ fs-card ──────── PREVIEW table (fs-table, first ~100 rows) + "N total rows" │
└ action bar ───── [Export Excel] [Export CSV] [Open Print View]              │
```
- Loader overlay during preview (reuse `.md-loader`).
- Empty/zero/no-access states everywhere.
- Toast on export start; graceful error surface (no raw stack traces).

---

## 7. Access Control & Sidebar

- **Data scope:** `MarksScopeResolver` — Admin=all, Dean=faculty, HOD=dept, else no-access message.
- **Sidebar:** add under the **Academics** section (results reporting), `data-roles="dean registrar hod admin"`. Not added to `sys_menu_items` → RBAC slug filter leaves it visible to those roles (fail-open). Icon: download/report SVG.
- Every export writes an **audit entry** (who exported what scope, when) — reuse the existing activity-log pattern so external-representation exports are traceable.

---

## 8. Phased Roadmap & Tasks

### Phase 0 — Foundation & verification
- [ ] 0.1 Live-verify plain `=` join equivalence on `acad_results` (regno/progid/courseid) + timing; confirm CGPA/class SQL vs `acad_CGPAFinder`/`acad_gs_award`.
- [ ] 0.2 Confirm clean-year regex + grade normalization set; confirm `acad_programme.levelCode` values and pass mark per level.
- [ ] 0.3 Scaffold `ResultsExporter.aspx(.cs)` (master, HeadContent, ScriptManager, filter bar, `hdnConfig`, loader). Add sidebar item; verify menu visibility for a dean-role session.
- [ ] 0.4 `GetFilterOptions()` PageMethod (scope-limited years/faculties/programmes/courses + currentYear).

### Phase 1 — Preview + core exports (primary deliverable)
- [ ] 1.1 Config JSON model (JS ↔ hidden field) + `GetPreview(configJson)` PageMethod → returns headline stats + grade/class distributions + first ~100 preview rows + total count. Scope-enforced.
- [ ] 1.2 Render preview: KPI cards, Chart.js grade + class charts, preview table. Wire filters/mode/format → live preview.
- [ ] 1.3 **Marks Sheet** + **Student Summary** modes end-to-end (SQL builders shared by preview & export).
- [ ] 1.4 **CSV export** (postback reads `hdnConfig`; streamed).
- [ ] 1.5 **Excel export** (multi-sheet SpreadsheetML: Cover + Statistics + Data; branded).
- [ ] 1.6 Audit-log each export.

### Phase 2 — Statistics modes + print
- [ ] 2.1 **Course Performance Statistics** + **Programme/Faculty Statistics** + **Grade Distribution** modes.
- [ ] 2.2 **Print/PDF view** (print-optimized HTML, branded letterhead like TranscriptPrint).
- [ ] 2.3 Per-mode column toggles.

### Phase 3 — Polish & power
- [ ] 3.1 Provisional source (CW/exam split sheet) + status filter.
- [ ] 3.2 Saved export presets; comparison (year-over-year) stats.
- [ ] 3.3 DevExpress native PDF (optional), scheduled/emailed exports (optional).

---

## 9. Error-Prevention Checklist
- [ ] **C# 5 only**; brace-balance after each `.cs` edit.
- [ ] **Plain `=` joins** (verified equivalent, index-backed) — never `TRIM()=TRIM()` on 627k rows.
- [ ] **Dirty data hygiene:** `acad REGEXP '^[0-9]{4}/[0-9]{4}$'`; normalize legacy grades to the 8 NCHE grades; derive pass/fail (no boolean).
- [ ] **Pass mark by level:** 50 for Cert/Diploma/Bachelors; 60 for Masters/PG (via `acad_gs_details.acad_lev`).
- [ ] **Scope on every query + export** (`MarksScopeResolver`); no client widening.
- [ ] **Parameterize everything**; whitelist filter→SQL mapping.
- [ ] **Big-export safety:** stream/limit; preview capped (~100 rows) but export returns all in scope; guard OutOfMemory on very large scopes (chunked write for CSV/Excel).
- [ ] **Download robustness:** `Response.Clear()`; correct `Content-Disposition`; swallow `ThreadAbortException` from `Response.End`.
- [ ] **CSV/Excel injection:** escape values; neutralize leading `= + - @` in cells (formula-injection safety) for external files.
- [ ] **Verify each metric live** before wiring; keep verifying query in a comment.
- [ ] **UI:** flat/navy, radius 0, no purple `#422774`; postback-safe dropdowns (load always + restore `Request.Form`).

## 10. Open Decisions (confirm before/within Phase 1)
1. **v1 report modes:** ship all 5, or start with Marks Sheet + Student Summary + Course Stats (defer Programme/Faculty + Grade-Distribution to Phase 2)?
2. **v1 formats:** Excel + CSV now, Print/PDF in Phase 2? (Recommended.)
3. **Source in v1:** Published only (authoritative), add Provisional later? (Recommended.)
4. **Access:** management-only (`dean registrar hod admin`) vs all admin users? (Recommended: management-only + scope.)

## 11. Reference anchors
- Grading engine: `App_Code/Marks/MarksControllerShared.cs` (grade/point/GPA/CGPA/award-class); DB fns `acad_GPAFinder`, `acad_CGPAFinder`, `acad_GetDegClass`; tables `acad_gs_details`, `acad_gs_award`.
- Export patterns: `FeesStructureExport.aspx.cs` (SpreadsheetML), `AuditCentre.aspx.cs`/`MarkEntry.aspx.cs` (CSV), `NCHEExporter.aspx.cs` / `AcademicResults.aspx.cs` (DevExpress XLSX), `TranscriptPrint.aspx` (HTML print).
- Scope: `MarksScopeResolver`. UI: `NewScreens/DESIGN_SYSTEM.md`, `NewScreens/FeesStructure.aspx`.
- Related memory: [[marks-results-data-model]], [[marks-staged-workflow]], [[allmarks-controller-upgrade]], [[general-dashboard-plan]] (perf: plain `=` joins), [[transcript-html-print]].
```
