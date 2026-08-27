# Marks displaying in the wrong semester

**Muteesa I Royal University — 27 August 2026**
Raised by: MRU2025002725 (DEBORAH NANSAMBA, DPE, in-service) — marks printing under the wrong semester on her results.

---

## 1. What was wrong

Her seven Year‑2 Semester‑2 courses were each registered **twice**:

| | Term | Her study year that term | Marks |
|---|---|---|---|
| Correct copy | 2026/2027 sem 2 | Year 2 | 3 of 7 |
| Phantom copy | 2025/2026 sem 2 | **Year 1** | 4 of 7 |

Because marks landed on whichever copy the mark‑entry screen happened to pick, four of the seven printed under **Year 1 Semester 2** and three under Year 2 Semester 2 — the same sitting, split across two academic years.

## 2. Why it happened

Three things had to line up:

1. **The course set was registered twice.** The two blocks of registration rows are contiguous and in *identical course order* (IDs 149952–149958 and 150614–150620) — one registration operation run twice, stamped with a different academic year each time. The first block was never removed.
2. **A bulk approval swept the phantom copy.** `mark_approve_records` id 21 (Lutamaguzi John Bosco, 26 July 2026, 2,658 rows) was scoped to **"year of study 1, semester 2"**. The duplicated Year‑2 courses matched that scope, because by their term columns they *were* year 1 semester 2.
3. **Publishing copied the registration's term.** `acad_results` was stamped from the registration row, so the wrong term propagated to the transcript.

All four affected registrations already carried `lecturer_status = 'REMOVED'` — the duplicates had been recognised as wrong, but the marks stayed attached to them.

## 3. What was fixed

Marks were **moved onto the curriculum‑correct registration**. No score, grade or grade point was altered anywhere — only the term a mark is filed under. The phantom duplicate registrations were then deleted.

### MRU2025002725

All seven Year‑2 courses now sit at 2026/2027 · Year 2 · Semester 2:

| Course | Mark | Was | Now |
|---|---|---|---|
| DEC2201D | 87 | 2025/2026 Yr1 Sem2 | 2026/2027 Yr2 Sem2 |
| DEC2202D | 78 | 2025/2026 Yr1 Sem2 | 2026/2027 Yr2 Sem2 |
| DEL2201D | 75 | 2025/2026 Yr1 Sem2 | 2026/2027 Yr2 Sem2 |
| DEL2202D | 75 | 2025/2026 Yr1 Sem2 | 2026/2027 Yr2 Sem2 |
| DEC2203D | 70 | already correct | 2026/2027 Yr2 Sem2 |
| DEE2201D | 68 | already correct | 2026/2027 Yr2 Sem2 |
| DGC2201D | 80 | already correct | 2026/2027 Yr2 Sem2 |

Her transcript now reads Year 1 Sem 1 (GPA 4.25), Sem 2 (4.70), Sem 3 (4.90), then Year 2 Sem 2 (4.43). 19 results before, 19 after.

### The same defect in 18 other students

45 further marks across 18 students came through **the same approval batch, in the same direction, with the same shape**. All are 2025‑entry students whose Year‑2 courses were dated to their Year‑1 term:

| Students | Marks | Correction |
|---|---|---|
| 18 | 45 | 2025/2026 Year 1 → 2026/2027 Year 2 |

Six safety assertions were checked before applying and all passed: every destination was empty, no destination was itself a source, no result row was shared between two moves, every result row sat at the expected source term, every pair was the same student and course, and no retake registrations were involved.

After the run: 45 results moved, 0 left behind; 45 marks on the correct registration, 0 destinations still empty; 0 duplicate registrations remaining; **0 scores changed**; 45 result rows still present, 0 re‑keyed. Total results per student is unchanged for all 18.

## 4. What was deliberately NOT changed

Searching the whole database for "a mark filed at a term the curriculum disagrees with" returns **37,842 rows across 2,502 students**. That definition is far too loose to act on — retakes, out‑of‑sequence study and curriculum revisions are indistinguishable from errors at that level.

Narrowing to the actual defect — the curriculum‑correct registration also exists — gives **466 marks across 231 students**. Of those, 45 were fixed. The remaining **421 are exported for registrar review** in `marks_wrong_semester_review_20260827.csv`:

| Assessment | Marks | Students |
|---|---|---|
| REVIEW — legacy migration, no independent evidence of term | 207 | 77 |
| NO ACTION — marked *after* (ordinary catch‑up study) | 74 | 42 |
| AMBIGUOUS — destination already holds a different mark | 52 | 44 |
| REVIEW — same study year, different semester | 45 | 44 |
| REVIEW — staged workflow, other batch | 41 | 23 |
| AMBIGUOUS — more than one candidate destination | 2 | 2 |

Two distinctions drove those exclusions, and both were found by checking rather than assuming:

- **Direction matters.** 74 marks sit at a study year *above* the curriculum year — a Year‑1 course marked while the student was in Year 2. MRU2024000018 is typical: nine Year‑1 courses, empty Year‑1 registrations, marks in Year 2. That is ordinary carry‑over study. Moving those marks backwards would fabricate a record of a student passing in a year they did not.
- **Provenance matters.** 207 marks were loaded by the LEGACY_MIGRATION bulk run (27 July 2026, 02:41–02:42), which stamped every row with one timestamp. Their term comes from the old system's own record, and there is no independent evidence it is wrong.

## 5. Root cause still open

The trigger is that **duplicate course registrations can exist at all**. The unique key on `acad_course_registration` is `(regno, courseID, acad_year, semester, course_status)`, so the same course under a *different academic year* is permitted by design — correctly, because that is how retakes work. Nothing therefore stops the same course set being registered twice under two different years.

Across the database there are **3,579 duplicate course‑student pairs affecting 1,047 students**. Most are harmless today, but each is a latent instance of this defect: any scoped bulk approval can sweep the wrong copy. A guard belongs in the registration path — refusing a second NORMAL (non‑retake) registration of a course a student is already registered for — rather than in the unique key. This has not been implemented; it is a change to a live write path and should be scoped separately.

## 6. Files

| File | Purpose |
|---|---|
| `sql/academics/marks_wrong_semester_fix.sql` | MRU2025002725 — the reported student |
| `sql/academics/marks_wrong_semester_fix_ROLLBACK.sql` | Reverses the above |
| `sql/academics/marks_wrong_semester_cohort_fix.sql` | The 18‑student cohort |
| `sql/academics/marks_wrong_semester_cohort_fix_ROLLBACK.sql` | Reverses the above |
| `reports/marks_wrong_semester_review_20260827.csv` | The 421 rows left for registrar review |

Backup tables retained in `campus_dynamics`:
`bk_wrongsem_results_20260827`, `bk_wrongsem_coursereg_20260827`,
`bk_wrongsem_results_cohort_20260827`, `bk_wrongsem_coursereg_cohort_20260827`,
`bk_wrongsem_gpa_before_20260827` (semester GPAs as they stood before the cohort run),
and `fix_wrongsem_pairs_20260827` (the exact 45 rows moved).
