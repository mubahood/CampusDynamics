# acad_programmecourses — Phantom Offerings & Duplicate Analysis

**Date:** 2026-07-14
**Scope:** Read-only diagnosis of `campus_dynamics.acad_programmecourses` (6,839 rows, 67 programmes, 2,170 distinct courses).
**Screen:** `NewScreens/NewProgrammeCourses.aspx`
**Status:** ANALYSIS ONLY — no data changed.

## How "used" is measured
A programme-course row is `(progcode, course_code, study_year, semester, specialisation_id)`.
- **Students** = rows in `campus_dynamics_portal.acad_course_registration` matched on `prog_id = progcode AND courseID = course_code` (TRIM, case-insensitive).
- **Marks** = rows in `campus_dynamics.acad_results` matched on `progid = progcode AND courseid = course_code`.

---

## Finding 1 — Phantom offerings (no students AND no marks)

| Bucket | Rows |
|---|---|
| Total programme-course rows | 6,839 |
| **Used** (≥1 registration OR ≥1 result in that programme) | 6,051 |
| **Phantom** (0 registrations AND 0 results in that programme) | **788** |

Breaking down the 788 phantom rows by whether the *course itself* is used anywhere:

| Sub-bucket | Rows | Meaning |
|---|---|---|
| Course never taken in **any** programme | 105 | Truly dead / junk rows |
| Course **is** taken, but under a **different** programme code | 683 | Mis-mapped assignment |

- The **105 dead** rows are largely garbage: **16 have a blank `course_code`** (a programme-course mapping pointing at no course at all), the rest are codes that exist in the catalogue but were never registered or graded.
- The **683 mis-mapped** rows mean the course is real and students take it — just under a *different* `progcode` than the one it's assigned to here. This is the same code-proliferation problem behind the duplicates below.

### Phantom rows concentrate in a few (mostly invalid) programme codes
| progcode | phantom rows | note |
|---|---|---|
| `06503` | 137 | numeric legacy code |
| `BED(S)` | 104 | |
| `-` | 97 | **invalid/blank programme** |
| `06504` | 78 | numeric legacy code |
| `BAED` | 70 | |
| `CAD` | 54 | |
| `DPE` | 43 | |
| `06501` / `06502` | 35 | numeric legacy codes |

Related data-quality counts across the whole table:
- **97 rows** have a `-` or blank `progcode`.
- **250 rows** have a numeric progcode (`06xxx`).
- **251 rows** point at a `progcode` that does **not exist** in `acad_programme` (orphan programme).

---

## Finding 2 — Duplicates within the same programme + year + semester

### 2a. Same course_code repeated in the same slot
948 duplicate groups, **2,918 redundant rows** total. Split by cause:

| Type | Redundant rows | What it is |
|---|---|---|
| **True accidental duplicate** (identical incl. `specialisation_id`) | **191** | Nothing distinguishes the rows — safe to collapse to one |
| **Specialisation-multiplied** (same course, different `specialisation_id`) | 2,727 | Common course listed once per subject-combination |

The 2,727 are the BAED-style pattern — e.g. in **BAED Year 1 Sem 2** the single course `BEF1201` appears **39 times**, once per specialisation. Whether these are wrong depends on policy: if the course is offered to every specialisation, one "General" row would replace 39; if listing per-spec is intentional, they're legitimate. The **191 true duplicates are unambiguous redundancy.**

### 2b. Same subject, different codes, in the same slot
**137 slots** carry the same course *name* under **142 redundant course codes**. Examples:

| Programme | Yr/Sem | Subject | Codes |
|---|---|---|---|
| BAED | 2 / 1 | Quantitative Methods | `BEC2102`, `ECO2102`, `FIN2102B` |
| BAED | 2 / 2 | Economics Teaching Methods | `BEC 2205`, `BEC2205`, `ECO2205` |
| BHRM | 1 / 1 | Financial Accounting | `BHRM1105`, `FIN1101B`, `FIN1103B` |
| 06503 | 2 / 1 | Historical Foundations of Education | `BEF 2101`, `BEF2101` |

Note the whitespace-variant pairs (`BEC 2205` vs `BEC2205`, `BEF 2101` vs `BEF2101`) — the *same* code with an embedded space treated as two distinct courses. These overlap with the code-normalisation work from the earlier course-dedup migration.

---

## Summary

| Issue | Count | Confidence it's junk |
|---|---|---|
| Phantom rows — course never used anywhere | 105 | High (esp. the 16 blank-code rows) |
| Phantom rows — course used under another programme | 683 | Medium — mis-mapping, needs re-point not delete |
| True accidental duplicate rows | 191 | High |
| Specialisation-multiplied rows | 2,727 | Policy call |
| Subject duplicates (same name, diff code) | 142 | Medium — merge candidates |
| Rows with blank/`-` progcode | 97 | High |
| Rows with orphan (non-existent) progcode | 251 | High |
| Rows with blank course_code | 16 | High |

**Safest immediate cleanup targets** (high confidence, low risk): the 16 blank-course rows, the 191 true duplicate rows, and the 97 blank/`-` progcode rows. Everything else (mis-mappings, spec-multiplication, subject merges) needs a policy decision before touching, because real students/marks hang off the "correct" side of each pair.

---

## Actions taken (2026-07-18)

### Executed — zero-loss cleanup of the unambiguous junk
Script: [`sql/programmecourses_cleanup_01.sql`](sql/programmecourses_cleanup_01.sql). Applied to the working DB; **fully reversible** (restore round-trip tested — 109 rows reinsert with no conflicts).

- **109 rows quarantined** and removed from the live table (6,839 → 6,730):
  - 16 with a blank `course_code`
  - 93 with a blank/`-` `progcode`
- **Hard guards enforced** — a row was skipped (kept live) if it had a lecturer assigned, any matching registration, or any matching result. This preserved **4 lecturer-assigned `-`-programme rows** on purpose (they need re-pointing, not deletion — see review export).
- **Nothing hard-deleted.** Full backup in `acad_programmecourses_bak_20260718`; removed rows sit in `acad_programmecourses_quarantine` (batch `cleanup_01_20260718`) with reason/date. Undo block is in the script footer.

> Deploy note: run the same script against production `campus_dynamics` (localhost DB here is a working copy; production `102.34.160.47` is not reachable from this environment). Counts should match: 109 quarantined, 6,730 remaining.

### Handed off for human decision — review exports (not auto-changed)
Because real students/marks hang off the "correct" side of these, they are exported, not touched:
- [`sql/reports/review_mismapped.tsv`](sql/reports/review_mismapped.tsv) — **597** rows assigned to a programme with no local students/marks, each annotated with the programme code(s) where the course *is* actually taken (`progs_with_students` / `progs_with_marks`) so it can be re-pointed.
- [`sql/reports/review_subject_dups.tsv`](sql/reports/review_subject_dups.tsv) — **136** slots where one subject exists under multiple codes in the same programme+year+semester (includes whitespace-variant codes like `BEC 2205` vs `BEC2205`).

Still untouched pending policy: the 2,727 specialisation-multiplied rows and the 191 curriculum-version duplicates (differ by `CurriculumID` — may be legitimate).

### Built — in-UI Data Quality Review panel (NewProgrammeCourses.aspx)
A **Data Quality** button (with a live count badge) on the toolbar opens a review modal with two tabs:
- **Mis-mapped** — paginated list of assignments with no local students/marks, each showing the programme(s) where the course is actually taken. Per-row actions: **Safe-remove** (guarded quarantine) and **Re-point** to a real target programme (validated: target must actually use the course, and must not collide with an existing row).
- **Subject Duplicates** — grouped by programme/year/semester slot, each code annotated with its live `reg`/`marks` counts; only phantom codes (0/0) expose a **Safe-remove** button, real ones show "keep".

Backend PageMethods on `NewProgrammeCourses.aspx.cs`: `DQ_Stats`, `DQ_ListMismapped`, `DQ_ListSubjectDups`, `DQ_QuarantineRows`, `DQ_RepointRow`. Every write is guarded (never removes a row with students/marks/lecturer), self-provisions the quarantine + `acad_programmecourses_dq_audit` tables, and is reversible. Usage is computed via per-call temp aggregates (`_dq_pc`, `_dq_course`) referenced once per query to satisfy MySQL's single-reference rule for temporary tables.
