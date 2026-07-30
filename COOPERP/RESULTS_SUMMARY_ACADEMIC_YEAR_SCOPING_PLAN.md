# Results / Marks Summary — Academic‑Year & Semester‑Registration Scoping

**Status:** proposal + implementation plan
**Scope:** the "Student Results & Marks Submission Summary" and the per‑student marksheet
(`NewStudentInfo.aspx` → `ExportPerformanceReport` / `ExportSummaryReport`, reused by
`ResultsExporter.aspx`).
**Author:** MIS
**Verified against production** (`campus_dynamics`, `campus_dynamics_portal`).

---

## 1. The problem, stated precisely

A summary requested as **"BEE · Year 2 · Semester 2"** returned 36 students, of whom
**only 1 is actually at Year 2** — 18 have progressed to Year 3 and 17 to Year 4 — and it
**pooled marks from two academic years** (2024/2025 and 2025/2026) into one sheet and one set
of averages.

Root cause, in the current report:

1. It scopes students by **programme + entry year + year‑of‑study + semester**, where
   *year‑of‑study is taken from the course's curriculum position*, not from the student's
   registration. So anyone who has ever passed a Year‑2 course lands on the Year‑2 sheet.
2. **There is no academic‑year filter at all.** Every sitting of those courses, across all
   years, is merged.

Consequence: the sheet is not a sitting; it is "everyone in this intake who has ever holds a
Year‑2 mark." For Year 4 the same mechanism surfaces students who have already completed and
graduated. The marks/grades themselves are computed correctly — the defect is **which
students and which academic year** are included.

---

## 2. What the data model actually says

Established by tracing real records (student `MRU2024000044` and the BEE cohort):

| Table | Grain | Academic year | Year of study | Notes |
|---|---|---|---|---|
| `campus_dynamics.acad_registration` | **semester registration** (regno, acad_year, studyyear, semester) | `acad_year` | `studyyear` = **student's** registered year | The authoritative "what did the student register for". `regstatus` ∈ REGISTERED / CLEARED / LATE REGISTERED / **UNREGISTERED** (forward placeholder) / HALTED / DEAD YEAR / DISCONTINUED. |
| `campus_dynamics.acad_results` | published mark per course | `acad` | `studyyear` = **course's** curriculum year | Well‑populated back to 2012. |
| `campus_dynamics_portal.acad_course_registration` | per‑course reg + provisional marks | `acad_year` | *(none)* — derive year‑of‑study from `acad_programmecourses` | Source for the "all / staged" modes. |

Two facts that shape the whole design:

- **A student registers for a specific `(academic year, study year, semester)`** and their marks
  carry that same `acad_year` + `semester`. So the natural, defensible anchor of any results
  report is the **sitting = (academic year, year‑of‑study, semester)** — identified from the
  marks' own `acad`/`acad_year`, not from the student's *current* standing.
- **`acad_registration` coverage is partial** — only ~36 % of these result rows have a matching
  registration row (legacy/migrated marks were never registered). Therefore registration
  **cannot** be the primary scope (it would silently drop the majority). It is reliable only as
  an **optional refinement**.

---

## 3. The dilemma, and how we resolve it

> "Students have already registered for the next semester but have not sat its exams. If a
> report scopes by *current standing*, their completed old‑semester marks get dropped."

This is a real trap, and it is exactly what any "use the student's latest registration" approach
would cause. We avoid it with one principle:

> **A results report is anchored to the SITTING it asks for — `(academic year, year‑of‑study,
> semester)` — never to the student's current position.**

Under this principle:

- A student who sat **Y2 S2 in 2024/2025** and has since moved to Year 3 appears on the
  **2024/2025 · Year 2 · Sem 2** report (with their real marks) **and** on the
  **2025/2026 · Year 3** report (marks where sat, pending where not). Nothing is ever lost,
  because inclusion is decided by the academic year of the marks, not by where the student is now.
- Re‑running an old semester later still reproduces the same sheet — reports become
  **stable and reproducible**, which they are not today.

So the primary fix is **not** a "current cohort" filter — it is simply **adding the academic‑year
anchor** the report is missing.

---

## 4. Filter design (export popup)

Both popups (`NewStudentInfo` `summaryReportModal`, `ResultsExporter` `srModal`) get:

| Filter | State | Behaviour |
|---|---|---|
| **Programme** | existing | — |
| **Academic Year** | **NEW — primary anchor** | Distinct academic years that have data for the programme, newest first; **default = most recent**. Filters marks to that year. |
| **Year of Study** | existing | Selects the curriculum level (the course set / columns). |
| **Semester** | existing | — |
| **Results Source** | existing | published / approved / captured / entered / all. |
| **Minimum courses to pass** | existing | Unchanged. |
| **Entry Year** | existing → **now OPTIONAL** ("All intakes" default) | Secondary cohort narrowing only. It is *not* the anchor — the same academic‑year Year‑2 sitting can contain more than one intake. |
| **☐ Exclude students already promoted beyond this semester** | **NEW — default OFF** | Registration‑based. OFF = include everyone with marks for the sitting (nothing dropped). ON = keep only students whose latest active registration is **not** after `(academic year, semester)`. Directly answers "give me only those still at this level." |
| **☐ Include registered students with no marks yet (pending)** | **NEW — default OFF (Phase 2)** | Builds the roster from `acad_registration` and LEFT‑JOINs marks, so registered‑but‑unsubmitted students show as *pending*. Turns the sheet into a genuine "submission" checklist. Off by default because registration coverage is partial. |

Cascade becomes **Programme → Academic Year → Year of Study → Semester** (each populated only
with combinations that actually have data), with Entry Year as an independent optional filter.

---

## 5. Scoping logic (per source)

Let `@acadYear`, `@studyYear`, `@semester` be the request; `@entryYear` optional.

**Published (`acad_results r`):**
```
WHERE r.acad = @acadYear
  AND r.studyyear = @studyYear         -- course curriculum year (matches the sitting level)
  AND r.semester = @semester
  [AND s.entryyear = @entryYear]       -- only if supplied
  AND s.progid = @programme
```

**All / staged (portal `acad_course_registration`, via the existing derived table):** the derived
table already exposes `cr.acad_year AS acad` and a `studyyear` from `acad_programmecourses`, so the
same three predicates apply on the derived alias `r` (`r.acad = @acadYear`, `r.studyyear =
@studyYear`, `r.semester = @semester`).

**Optional "exclude promoted" (all sources):**
```
AND NOT EXISTS (
  SELECT 1 FROM campus_dynamics.acad_registration g
  WHERE g.regno = s.regno
    AND g.regstatus IN ('REGISTERED','CLEARED','LATE REGISTERED')
    AND ( g.acad_year > @acadYear
       OR (g.acad_year = @acadYear AND g.semester > @semester) ) )
```
Academic‑year strings are fixed `YYYY/YYYY`, so `>` compares chronologically.

The **only structural change** is adding `r.acad = @acadYear` everywhere, making `@entryYear`
optional, and the optional `NOT EXISTS`. Grade/GPA/pass‑fail computation is untouched.

---

## 6. Edge cases & decisions

- **Retake of a lower‑year course in this semester** — its mark carries this `acad_year`/`semester`,
  so it appears on this sheet. Correct: it *was* sat this sitting. (The is_retake flag already
  distinguishes it.)
- **Marks with no registration row** — unaffected by default (we anchor on the marks). Only the
  optional registration toggles touch registration.
- **Forward `UNREGISTERED` rows** (2026/2027, 2027/2028 already exist) — excluded from the
  "promoted" test via the `regstatus` filter, so a placeholder future row does not wrongly drop a
  student.
- **Dirty academic‑year values** (`2202/2203`, `2023/204` — a handful) — harmless; they simply
  won't match a real `@acadYear` and won't appear in the cascade.
- **Entry year vs academic year** — entry year is unreliable as a progression signal (entry‑2024
  students first register at studyyear 2 in 2024/2025). Hence academic year, not entry year, is the
  anchor.

---

## 7. Implementation steps

1. **Backend (`NewStudentInfo.aspx.cs`)**
   - Read `acadYear` + `excludePromoted` (+ optional `includePending`) from the query string in
     `HandleExportPerformanceReport`, `HandleExportSummaryReport`, `HandlePreviewSummaryReport`.
   - Thread `acadYear` into `GetPerformanceReportData`, `GetSummaryReportData`,
     `GetSummaryReportStudentCount`; add `r.acad = @acadYear`; make `entryYear` optional; add the
     optional `NOT EXISTS` promoted filter.
   - Extend `HandleSummaryReportCascade` to return `ay` (academic year) in each combo, and add an
     `acadYears` list.
   - Stamp the chosen academic year on the PDF header/among the report parameters.
2. **`NewStudentInfo.aspx`** — add the Academic Year `<select>` + the checkbox(es) to
   `summaryReportModal`; make Entry Year optional; update the cascade JS and the
   preview/export URL builders (`&acadYear=`, `&excludePromoted=`).
3. **`ResultsExporter.aspx`** — mirror the same fields in `srModal` and its `collect()` / `query()`.
4. **Verify** on BEE Year 2/3/4 for a chosen academic year; confirm counts match the true sitting
   and progressed/graduated students drop out.

**Default behaviour (as built):** both popups **require** an Academic Year, and the cascade
auto‑selects the most‑recent sitting that has data — so the normal path is always a single sitting.
Server‑side, a **blank `acadYear` is an explicit "all academic years" view** (the old pooled
behaviour, kept deliberately for the rare all‑time cohort look and for backward‑compatible direct
links). `excludePromoted` absent ⇒ OFF. This keeps every request expressible — "one sitting" is the
default, "all years" is available on purpose rather than by accident.

---

## 8. One‑line summary

Add the missing **academic‑year anchor** so every summary is a real *sitting*
`(academic year · year of study · semester)`; use semester registration only for optional
"exclude promoted / include pending" refinements — never to decide inclusion by a student's
current position, so no completed‑semester marks are ever dropped.
