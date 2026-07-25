# Export Summary Report — Upgrade Plan

Aligns `NewStudentInfo.aspx` "Export Summary Report" with the current marks/results
management structure (staged workflow + NCHE grading), per confirmed decisions.

## Current state (as investigated)
- Entry: `NewStudentInfo.aspx?status=ALL` → batch menu → **Export Summary Report** → `summaryReportModal`.
- Inputs: Programme, Entry Year, Year of Study, Semester (all required), or specific reg numbers.
- Actions (in `NewStudentInfo.aspx.cs`):
  - `PreviewSummaryReport` → `GetSummaryReportStudentCount` (count over `acad_student` ⋈ `acad_results`).
  - `ExportSummaryReport` ("Export Results") → `GetSummaryReportData`/`BuildSummaryReportTable` → `GenerateSummaryReportPdf` — per-student marksheet from **published `acad_results`**, enriched with CW/Exam/Total + status left-joined from `campus_dynamics_portal.acad_course_registration`.
  - `ExportPerformanceReport` ("Summary Report") → `GetPerformanceReportData` → `GeneratePerformanceReportPdf` — categorizes by "CGPA" (actually **semester** GPA) into VC's List ≥4.40 / Dean's List ≥3.60 / Second Class Lower ≥2.80 / Pass ≥2.00; `<2.00` excluded. DevExpress `BrickGraphics` letterhead.

## Problems
1. Reads **published only**; its stated purpose (present to Senate for approval) needs the **APPROVED** stage (pre-publish, in `acad_course_registration`).
2. "CGPA" is a single-semester GPA (mislabeled, not retake-aware).
3. Flat, non-level-aware classification; drops fails/retakes/incompletes.
4. No on-the-fly NCHE grading for unpublished stages.
5. `entryno` used for the reg-number filter (canonical key is `regno`).

## Decisions (confirmed)
- **Source:** selectable **Published / Approved / Captured / Entered**, default **Approved**; grades computed on the fly (NCHE 2015) for unpublished stages.
- **Classification:** honor lists (VC's/Dean's) **and** full level-aware NCHE classes, plus **Fail**, **Retake/Referred**, **Incomplete/Missing** sections.
- **GPA:** show **both** Sem GPA and cumulative CGPA; categorize by CGPA (`acad_CGPAFinder` for published, credit-weighted for staged).
- **Scope:** open to all admin users (no `MarksScopeResolver` restriction).

## Implementation
- **Source-aware SQL** (private helpers in `NewStudentInfo.aspx.cs`, formulas identical to `ResultsExporter`): `StageFor`, `IsPublished`, `GradeCase`, `GptCase`, `SourceLabel`, `ResultsFrom(source)`. Unpublished → derived table over `acad_course_registration` at that `mark_stage`, exposing `score`(=provisional_total_marks), on-the-fly `grade`/`gradept`, `CreditUnits`(from `acad_course`), `studyyear`(from `acad_programmecourses`), `is_retake`, plus `cw_marks`/`exam_marks`/`prov_total`/`sub_status` for the marksheet — same column names as the published path.
- **Reg-number filter** matches `regno` (and `entryno` for back-compat).
- **Preview / marksheet / performance** methods all take `source`.
- **Performance report:** per student compute **Sem GPA** and **CGPA**; sections = Honor Lists (VC's ≥4.40, Dean's 3.60–4.39) → NCHE classes (level-aware) → Fail → Retake/Referred (any score<50) → Incomplete/Missing (registered, no gradeable marks in source). Both GPA columns shown.
- **Templates:** header shows the source + a "provisional / pending Senate approval" note for unpublished; new category sections rendered.
- **UI:** add Source dropdown to the modal; wire into preview/export JS.

## Validation
- SQL validated against production for each source (as done for ResultsExporter).
- DevExpress DLLs absent locally → cannot compile/render; verify on a deployed environment.
