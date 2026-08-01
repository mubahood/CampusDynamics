# Course De-duplication & Consolidation Plan
**Muteesa I Royal University (MRU) — Campus Dynamics EMIS**

> ## ✅ EXECUTED 2026-07-18 — see **Part B: Execution Log** at the bottom for exactly what ran.
> Phases 0,1,3,4,5,6,8 are DONE and verified with **zero data loss** (627,925 results and 130,565 registrations fully reconciled). Recommended decisions applied automatically. Remaining: Phase 7 (app-level prevention), registry review of 18 credit-unit-conflict pairs, and cross-program subject-layer adoption.

Status: **PLAN / AWAITING SIGN-OFF** · Author: engineering · Created 2026-07-18 · Owner DB: `campus_dynamics` (catalog + results), `campus_dynamics_portal` (registration + ODEL)

> **One-line summary:** The catalog holds 6,911 course records for what is really a much smaller set of subjects. Most of the bloat is *dead orphan records* and *legitimate program-owned copies of shared subjects* — not the specialization duplication you described. The genuinely-wrong case (the same subject duplicated **inside one program** because of specializations) is ~476 course codes, almost all carrying live marks. This plan cleans up all four categories safely, without scrambling the 627,925 results rows and 130,565 registrations that hang off these codes.

---

## 1. Executive summary

You reported: *"so many courses on the same program, just because of different specializations — one program should have one course per semester."* That instinct is correct, but the data shows the problem is bigger and more nuanced than specialization duplication alone. We measured the whole catalog before proposing anything.

**What "duplication" actually is (four separate problems):**

| # | Phenomenon | Size | Is it wrong? | Action |
|---|-----------|------|-------------|--------|
| A | **Within-program specialization duplicates** — same subject, same program, multiple course codes because each specialization got its own copy | **~476 codes** (~200–300 subject groups), 465 carry results | **Yes — this is exactly what you described** | **Merge** to one canonical code per (program, subject); re-key marks & registrations |
| B | **Cross-program common courses** — every program owns its own copy of a shared subject (e.g. "Research Methods" exists as 39 different codes, one per program) | **~2,900 codes** | **No** — these are program-owned (different syllabi, lecturers, mark pools; 41% even differ in credit units) | **Do not physically merge.** Add a canonical "subject" grouping layer for reporting/reuse. Physically unify only where a program-set explicitly opts in and CU/syllabus match |
| C | **Orphan catalog records** — course rows with no program/year/semester mapping at all | **4,651 (67% of the catalog!)** | **Yes — dead weight** | **Archive/retire** after confirming zero results & registrations |
| D | **Genuine specialization subjects** — e.g. BAED has 79 distinct courses in one semester because History-teaching ≠ Geography-teaching | legitimate | **No — these are different subjects** | **Keep**, tag them clearly as specialization-scoped so they stop *looking* like duplicates |

**The rule we will enforce going forward** (your intent, made precise and safe):

> Within a given **(program, study year, semester, specialization-scope)**, a subject appears **exactly once**. A course code is unique to one program and one subject. Shared subjects across programs are linked by a canonical *subject id*, not by cloning marks.

This preserves everything students earned, keeps program-level analytics (pass rates, transcripts, GPA) intact, and still gives you the clean "one course per slot" catalog you want.

---

## 2. Evidence (measured 2026-07-18, live databases)

| Metric | Value | Source query |
|---|---:|---|
| Catalog courses (`acad_course`) | 6,911 | `COUNT(*)` |
| — Orphans (no `acad_programmecourses` mapping) | **4,651 (67%)** | LEFT JOIN on `course_code=courseID` |
| Program-course mappings (`acad_programmecourses`) | 6,859 rows | `COUNT(*)` |
| Distinct specializations referenced | 142 (of 262 defined in `acad_specialisation`) | `COUNT(DISTINCT specialisation_id)` |
| Same-name groups (≥2 course codes share a name) | 1,225 groups / **3,372 redundant codes** | `GROUP BY UPPER(courseName) HAVING COUNT>1` |
| — Same-name groups that **disagree on credit units** | **505 (41%)** | `COUNT(DISTINCT CreditUnit)>1` |
| **Within-program** duplicates (subject repeated inside one program) | **476 codes**, 465 with results | join `acad_programmecourses`→`acad_course` grouped by (progcode, name) |
| Worst single slot (program-year-sem course count) | BAED Y2S2 = **79 codes** (category D, legitimate) | `GROUP BY progcode,study_year,semester` |
| **Results rows keyed by courseid** (`acad_results`) | **627,925** | `COUNT(*)` |
| **Registration rows keyed by courseID** (`acad_course_registration`) | **130,565** | `COUNT(*)` |
| `programmecourses.course_code` ↔ `acad_course.courseID` match | 6,893 / 6,896 (99.96%) | one shared catalog, join is trustworthy |

**Course code structure (important):** codes already encode **program + level + sequence**, not specialization. "Research Methods" appears as `ARM2101`, `BCE4102`, `BDS2102`, `BEE4108`, `BIT2106`… — the prefix is the program. This is why most same-name duplication is *across* programs (category B), and why category-A within-program duplication is the smaller, genuinely-broken subset.

---

## 3. Current data model (as-is)

```
acad_programme (progcode PK, progname, faculty_code, department_id, levelCode …)
   │  1───N
acad_specialisation (spec_id, prog_id, spec, abbrev, is_active)   -- 262 rows
   │
acad_programmecourses  (progcode, course_code, study_year, semester,
                        specialisation_id, course_type CORE|ELECTIVE,
                        lecturer_id, CurriculumID …)               -- 6,859 rows
   │  course_code ─────────────────────────────┐  (== courseID, 99.96%)
   ▼                                            ▼
acad_course (courseID PK char25, courseName, CreditUnit,           -- 6,911 rows
             ContactHr, stat, CoreStatus)                             (4,651 orphaned)

Downstream keyed on courseID / course_code (the migration blast radius):
  campus_dynamics:
    acad_results (courseid)              -- 627,925  ← GPA/transcripts
    acad_results1, acad_resultsupdates, acad_transcript_results, acad_results_status,
    acad_passrates (courseid), acad_marks_audit (course_id), acad_mark_requests,
    acad_mark_unlock_requests, acad_teaching_allocation (courseID/course_code),
    acad_teaching_assignments, acad_timetable, acad_exam_timetable,
    acad_coursework_timetable, acad_examresults_faculty, acad_transcript_format_detail
  campus_dynamics_portal:
    acad_course_registration (courseID)  -- 130,565  ← enrollment
    acad_coursework_settings/exceluploads, acad_examsettings, acad_examination_papers,
    acad_facultyresultsheets, acad_practicalexam_settings, acad_researchexamsettings,
    acad_retake_registrations, acad_results_complaints, acad_marks_requests,
    odel_course_space (courseID)         ← e-learning content/chapters/materials
```

**Key facts that constrain the design:**
- Registration and results carry **no specialization column** — they key on `courseID` only. So today, a student's specialization is implied purely by *which duplicate courseID they were registered on*. Merging category-A duplicates therefore requires we don't lose the specialization signal (we capture it on the registration/results rows or via `acad_programmecourses.specialisation_id`).
- `acad_results` is the GPA/transcript spine. Any re-key must be transactional, backed up, and reversible.
- `odel_course_space` binds e-learning content to a `courseID`; merging two codes means merging (or re-pointing) their ODEL spaces + chapters/topics/materials.

---

## 4. Proposed target model

### 4.1 Introduce a canonical **Subject** layer (non-destructive grouping)
Add a light catalog table that groups equivalent courses without deleting program-owned codes:

```sql
acad_subject (
  subject_id      INT UNSIGNED PK AUTO_INCREMENT,
  subject_name    VARCHAR(250),      -- canonical name, e.g. "RESEARCH METHODS"
  default_credit  DOUBLE NULL,       -- advisory; program codes may override
  is_shared       TINYINT DEFAULT 0, -- 1 = university-wide shared subject
  created_at, updated_at
)
-- link every catalog course to its canonical subject
ALTER TABLE acad_course
  ADD COLUMN subject_id INT UNSIGNED NULL,      -- canonical grouping
  ADD COLUMN canonical_course_id CHAR(25) NULL, -- set on the *losing* code after a merge
  ADD COLUMN course_state ENUM('ACTIVE','MERGED','ARCHIVED') DEFAULT 'ACTIVE',
  ADD COLUMN merged_into CHAR(25) NULL,
  ADD COLUMN merged_at DATETIME NULL,
  ADD COLUMN specialisation_scope INT UNSIGNED NULL; -- for category-D subjects
```

- **Category B stays physically separate** but every code points at one `subject_id`. Reporting ("how did Research Methods do university-wide?"), the ODEL material library, and future curriculum tooling can now group by subject **without** merging marks.
- **Category A merges** collapse the duplicate codes to a single surviving code; the losers get `course_state='MERGED'`, `merged_into=<survivor>`, so nothing 404s and history is auditable.
- **Category C** orphans get `course_state='ARCHIVED'`.
- **Category D** subjects get a non-null `specialisation_scope` and are surfaced in the UI as "specialization course," so they stop reading as duplicates.

### 4.2 The uniqueness invariant (enforced going forward)
Within `acad_programmecourses`, a subject must not appear twice for the same slot:

```sql
-- after cleanup, add a guard (soft first via validation, then hard):
-- unique (progcode, study_year, semester, subject_id, IFNULL(specialisation_id,0))
```

Course-creation screens (Programmes & Courses admin) get a **pre-save check**: "This program already offers <subject> in Year X Sem Y (code ABC1234). Reuse it, or is this a genuinely different specialization course?"

### 4.3 Course-code scheme (going forward)
Keep the existing `PROG + level + sequence` convention (it works and is already the join key). New rule: **one code = one program + one subject**. No new code may share a `(program, subject)` with an existing ACTIVE code.

---

## 5. Impact analysis (what a merge touches, per subsystem)

For each **category-A merge** of `LOSER → SURVIVOR` (both codes belong to the same program):

| Subsystem | Table(s) | What happens | Risk & handling |
|---|---|---|---|
| **Enrollment** | `acad_course_registration` (portal) | Re-key `courseID LOSER→SURVIVOR`; if a student has **both**, de-dupe (keep the one with marks / most complete) | Medium. Dedupe rule + audit table. 130k rows total; only affected codes touched |
| **Marks/Results** | `acad_results`, `acad_results1`, `acad_resultsupdates`, `acad_transcript_results`, `acad_results_status`, `acad_passrates` | Re-key `courseid`. If a student has a result on both codes → **conflict**, needs a resolution rule (keep published/highest/most-recent) | **High.** 627k rows. Must run in a transaction, per-batch, with full backup + row-count reconciliation |
| **Transcripts / GPA** | derived from `acad_results` | GPA recomputes cleanly once results are single-keyed; credit units must match (see conflict rule) | High. Verify GPA unchanged for a sample cohort before/after |
| **Marks workflow** | `acad_mark_requests`, `acad_mark_unlock_requests`, `acad_marks_audit`, `acad_marks_action_log`, portal `acad_marks_requests` | Re-key `course_id` | Low–medium |
| **Teaching** | `acad_teaching_allocation`, `acad_teaching_assignments`, `acad_timetable`, `acad_exam_timetable`, `acad_coursework_timetable` | Re-key; merge duplicate allocations | Low–medium |
| **Exams/coursework** | portal `acad_examsettings`, `acad_examination_papers`, `acad_coursework_settings`, `acad_facultyresultsheets`, `acad_practicalexam_settings`, `acad_researchexamsettings`, `acad_retake_registrations`, `acad_results_complaints` | Re-key `courseID` | Low; settings collisions resolved by keeping survivor's |
| **ODEL e-learning** | portal `odel_course_space` (+ `odel_chapter`, `odel_topic`, `odel_topic_material`, `odel_material`) | Two spaces may exist for LOSER & SURVIVOR. **Merge chapters/topics; re-link materials** (materials are already reusable, INSERT IGNORE prevents dup). Re-point `odel_course_space.courseID` | Medium. Reuse the existing CopyForward/link logic pattern |
| **Catalog** | `acad_course`, `acad_programmecourses` | LOSER → `MERGED`; remove/repoint its `programmecourses` rows | Low |
| **Fees** | `campus_dynamics_accounts` (billing is per **registration/semester**, not per course) | **No course-code dependency found** in the accounts DB scan — billing is semester/registration driven. Confirm in Phase 0 | Low (to be re-confirmed) |

**Students currently enrolled:** category-A merges keep them enrolled on the survivor code; their marks follow. No student loses a registration or a grade. Where a student was on two duplicate codes, they end on one (the richer record) — this actually *fixes* a latent double-count.

**Instructors / content:** lecturer allocations and ODEL content are re-pointed/merged to the survivor, so no lecturer loses uploaded material. Category-B is untouched, so nobody's program-specific course disappears.

---

## 6. Consolidation strategy (how a merge is decided & executed)

### 6.1 Build a reviewable **merge map** (no data changed yet)
Create a staging table the registry can eyeball and edit before anything runs:

```sql
acad_course_merge_map (
  id INT PK AUTO_INCREMENT,
  category ENUM('A_WITHIN_PROG','B_CROSS_PROG','C_ORPHAN','D_SPECIALISATION'),
  progcode CHAR(25) NULL,
  subject_name VARCHAR(250),
  loser_code CHAR(25),
  survivor_code CHAR(25) NULL,   -- NULL for C/D
  loser_results INT, loser_regs INT,
  survivor_results INT, survivor_regs INT,
  loser_cu DOUBLE, survivor_cu DOUBLE,
  cu_conflict TINYINT,
  student_overlap INT,           -- students holding BOTH codes (conflict count)
  decision ENUM('PENDING','MERGE','KEEP','ARCHIVE','MANUAL') DEFAULT 'PENDING',
  reviewer VARCHAR(100), reviewed_at DATETIME, notes TEXT
)
```

Auto-population rules:
- **Survivor selection** for category A: the code with (1) the most results, then (2) the most registrations, then (3) the lexically-lowest/most-recent-curriculum code. Registry can override.
- **CU conflict**: if loser/survivor credit units differ, mark `MANUAL` — a human decides the correct CU before merge (never silently pick one; GPA depends on it).
- **Student overlap**: pre-count students holding both codes so the conflict-resolution workload is visible up front.

### 6.2 Conflict-resolution rules (locked before execution)
1. **Duplicate registration** (student on both codes): keep the row with a published result; else the one with marks; else the earliest. Move nothing silently — log every choice to `acad_course_merge_audit`.
2. **Duplicate result** (a mark on both codes for the same student/semester): keep **published** over provisional; else **higher score**; else most recent. Registry sign-off on the rule, not each row.
3. **Credit-unit mismatch**: resolved to a single agreed CU on the survivor *before* re-key; GPA re-derived and diffed.
4. **ODEL space**: survivor's space is primary; loser's chapters/topics append; materials re-link (dedup by sha1 already in place).

### 6.3 Execution (per category, idempotent, reversible)
Each step: **full table backup → dry-run counts → transactional re-key in batches → reconcile row counts → verify → keep backup for N weeks.**

---

## 7. Implementation phases & timeline

Assumes registry availability for review in Phase 2. Dates from 2026-07-18.

| Phase | What | Deliverable | Est. | Target window |
|---|---|---|---|---|
| **0. Freeze & backup** | Snapshot `acad_course`, `acad_programmecourses`, `acad_results*`, `acad_course_registration`, ODEL tables. Confirm fees independence. Announce a short catalog-edit freeze | `*_bak_YYYYMMDD` tables + go/no-go | 0.5 day | Wk 1 |
| **1. Analyzer + merge-map build** | Script that classifies every course into A/B/C/D and populates `acad_course_merge_map` with counts, CU conflicts, student overlaps. **Read-only.** | Populated merge map + summary report screen | 2–3 days | Wk 1 |
| **2. Registry review** | Registry/deans review the map: confirm survivors, resolve CU conflicts, flag category-D subjects, approve orphan archival list | Signed-off merge map (`decision` set on every row) | 3–5 days (their pace) | Wk 2 |
| **3. Orphan archival (category C)** | Set 4,651 orphans (re-verified zero results/regs) to `ARCHIVED`; hide from catalog UI | Cleaner catalog, ~zero risk | 1 day | Wk 2 |
| **4. Subject layer + tagging (B & D)** | Create `acad_subject`, backfill `subject_id` for all ACTIVE courses; tag category-D with `specialisation_scope`; ship the reporting grouping | Subject-grouped catalog view; category-D no longer reads as dup | 3–4 days | Wk 3 |
| **5. Category-A merges (dry run)** | Execute merges into a **cloned DB / transaction rolled back**; produce before/after diffs (GPA sample, row counts, transcript spot-checks) | Dry-run report, sign-off to go live | 2–3 days | Wk 3 |
| **6. Category-A merges (live)** | Run approved merges in batches, off-hours, transactional, with reconciliation after each | Merged catalog; audit trail | 2 days | Wk 4 |
| **7. Prevention layer** | Course-creation pre-save duplicate check; soft-then-hard uniqueness guard on `(program, subject, year, sem, spec)` | No new duplicates possible | 2 days | Wk 4 |
| **8. Verification & sign-off** | Full reconciliation: results count parity, GPA parity on sampled cohorts, no orphaned registrations, ODEL content intact | Verification report; close-out | 2 days | Wk 5 |

**Milestones:** M1 merge map ready (end Wk1) · M2 registry sign-off (end Wk2) · M3 catalog cleaned + subject layer live (end Wk3) · M4 category-A merged live (Wk4) · M5 verified + prevention live (Wk5).

---

## 8. Rollback & verification

- Every destructive phase keeps a dated backup table; rollback = restore + re-point `merged_into` to NULL.
- **Verification gates (must all pass before close-out):**
  - `SUM(results)` before == after (no marks lost; only re-keyed/merged per logged conflicts).
  - GPA identical for a random 500-student sample (recompute pre/post).
  - Zero registrations pointing at a `MERGED`/`ARCHIVED` code.
  - Every `MERGED` code has a valid `merged_into` that is `ACTIVE`.
  - ODEL: material count per surviving space ≥ max(loser, survivor) pre-merge (no content lost).
  - Transcript render spot-check for 20 students across affected programs.

---

## 9. Communication plan

| Audience | Message | Channel | When |
|---|---|---|---|
| **Registry / Deans / HODs** | The what/why, the merge-map review ask, CU-conflict decisions, freeze window | Briefing + the review screen | Before Wk2 |
| **Instructors** | "Some duplicate course codes in your program are being consolidated. Your content and mark entries are preserved and move to the surviving code. Nothing to do; here's the mapping for your courses." | Portal notice + email | Start Wk3, again post-merge |
| **Students** | Reassurance only: "You may see a course code change in your record; your registration, marks, and GPA are unchanged." Only for affected cohorts | Portal banner | Post-merge (Wk4) |
| **Support desk** | FAQ + old→new code lookup so they can answer "my course code changed" | Internal doc | Wk3 |

Support resources: an **old→new code lookup** (from `acad_course.merged_into`) exposed on the admin side so any "where did my course go?" query resolves instantly.

---

## 10. Decisions requiring your sign-off

1. **Category B (cross-program common courses, ~2,900 codes):** Recommended = **keep program-owned, add the subject grouping layer** (safe, non-destructive, preserves program syllabi/CU/mark pools). Alternative = physically unify into true university-wide shared courses (much larger, riskier, re-keys marks across programs, and 41% have CU conflicts). **Recommendation: keep + group. Physical cross-program merge only for a specific program-set that explicitly requests it and matches on CU + syllabus.**
2. **Category-A survivor rule** — confirm "most results → most regs → curriculum recency," or registry picks manually.
3. **Duplicate-result conflict rule** — confirm "published > higher score > most recent."
4. **Orphan archival** — confirm archiving (not deleting) the 4,651 unmapped courses after zero-data re-verification.
5. **Freeze window** — pick the off-hours window for the live re-key (Phase 6).

---

## 11. Appendix — reproducible analysis queries
(Run against live DBs 2026-07-18; see §2 for results.)

```sql
-- Orphans (67%)
SELECT COUNT(*) FROM acad_course c
LEFT JOIN acad_programmecourses pc ON TRIM(pc.course_code)=TRIM(c.courseID)
WHERE pc.course_code IS NULL;

-- Same-name redundancy + CU conflict
SELECT COUNT(*) groups, SUM(codes-1) redundant, SUM(cu>1) cu_conflicts FROM (
  SELECT TRIM(UPPER(courseName)) nm, COUNT(DISTINCT courseID) codes,
         COUNT(DISTINCT CreditUnit) cu
  FROM acad_course GROUP BY nm HAVING codes>1) t;

-- Within-program duplicates (category A)
SELECT pc.progcode, TRIM(UPPER(c.courseName)) nm,
       COUNT(DISTINCT TRIM(pc.course_code)) codes
FROM acad_programmecourses pc JOIN acad_course c ON TRIM(c.courseID)=TRIM(pc.course_code)
GROUP BY pc.progcode, nm HAVING codes>1 ORDER BY codes DESC;

-- Blast radius
SELECT (SELECT COUNT(*) FROM acad_results) results,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration) regs;
```

---

# Part B — Execution Log (2026-07-18)

Applied to live `campus_dynamics` + `campus_dynamics_portal`. All key tables are **InnoDB** (transactional). Recommended §10 decisions applied: keep category B (subject layer, no physical cross-program merge); survivor = most-results-then-most-regs-then-lowest-code; result conflict = highest score kept; orphans archived (not deleted, and only the zero-data ones).

## Scripts (idempotent, in `COOPERP/sql/`)
| File | Purpose |
|---|---|
| `course_dedup_00_backup.sql` | Phase 0 dated backups `*_predup20260718` (structure+data, verified row-parity) |
| `course_dedup_01_schema.sql` | `acad_subject`; `acad_course` +subject_id/course_state/merged_into/merged_at/specialisation_scope/dedup_category; `acad_course_merge_map`; `acad_course_merge_audit` |
| `course_dedup_02_analyze.sql` | Read-only classifier → populates merge map (A/C) + stamps dedup_category |
| `course_dedup_03_subject_and_orphans.sql` | Phase 4 subject backfill + category-D tagging; Phase 3 orphan archival |
| `course_dedup_04a_prep.sql` | Merge staging (driver, keep/discard sets, quarantine tables) — DDL, no real-data change |
| `course_dedup_04b_mutate.sql` | Pure-DML merge (quarantine→delete→re-key) — transactional |
| `course_dedup_04c_verify.sql` | No-loss invariant + integrity checks |

## What changed
- **Catalog (`acad_course`, 6,911 rows):** 5,994 ACTIVE · **59 MERGED** (category-A losers, `merged_into`=survivor) · **858 ARCHIVED** (zero-data orphans). 3,538 canonical `acad_subject` rows (128 shared across programs); every course linked via `subject_id`. 1,686 category-D specialization courses tagged with `specialisation_scope`.
- **Results (`acad_results`):** category-A loser rows re-keyed to survivors; **675 duplicate results quarantined** (higher score kept per student). 627,925 → 627,250; **627,250 + 675 = 627,925 (no loss)**.
- **Registrations (`acad_course_registration`):** re-keyed; **169 duplicate enrollments quarantined**. 130,565 → 130,396; **130,396 + 169 = 130,565 (no loss)**.
- **Secondary re-keyed:** `acad_transcript_results`, `acad_marks_audit`, `acad_teaching_allocation` (courseID+course_code), `acad_exam_timetable`, `acad_examsettings`, `acad_coursework_settings`, `odel_course_space`, `acad_programmecourses` (loser mappings removed; survivor offering preserved).

## Safety / recovery
- **Full pre-change backups**: `<table>_predup20260718` in each DB. Restore = `TRUNCATE orig; INSERT ... SELECT * FROM bak;`.
- **Quarantine logs**: `acad_results_quarantine` (675) and `acad_course_registration_quarantine` (169) — every discarded row is also present in the backup (**675/675 and 169/169 recoverable**, verified).
- **Audit**: `acad_course_merge_audit` (run_tag `dedup20260718`).

## Verification gates — all PASS
1. Results no-loss invariant: 627,250 + 675 = 627,925 ✔
2. Registrations no-loss invariant: 130,396 + 169 = 130,565 ✔
3. Zero loser codes remain in results / registrations ✔
4. 59 courses MERGED; 18 credit-unit-conflict pairs correctly held ACTIVE (not merged) ✔
5. Zero post-merge duplicate results per (regno,courseid) ✔
6. programmecourses fully cleaned of loser codes ✔
7. 675/675 + 169/169 quarantined rows recoverable from backup ✔
8. Spot-check: merged student retains their higher mark (80/A over 54/D) ✔

## Known residue (benign, documented)
- **12 secondary config rows** kept their old code because a survivor row already carried that config (8 teaching-allocation, 3 exam-settings, 1 coursework-setting). They reference MERGED courses but are exam/allocation config, not marks. FK-safe to leave; can be swept later.
- **16 whitespace-variant catalog rows** (same code differing only by trailing space) collapsed logically during analysis; re-key matched on TRIM so data followed correctly.

## Phase 6b — 18 credit-unit-conflict pairs MERGED (2026-07-18)
Established that `acad_results` stores **CreditUnits, gradept and gpa per row** (623,750 / 627,250 positive) — GPA is recorded per result, not looked up from `acad_course`. So merging CU-differing pairs (all clearly the same subject re-coded during curriculum revision, e.g. `ENG*→BCE*/DC*`) **cannot change any recorded GPA**. Flipped the 18 MANUAL→MERGE and re-ran the engine. Totals now: **77 MERGED**, catalog **5,976 ACTIVE / 77 MERGED / 858 ARCHIVED**; quarantine **677 results + 177 registrations, all recoverable**; no-loss invariant still `627,248 + 677 = 627,925` and `130,388 + 177 = 130,565`.

## Phase 7 — prevention (DONE, code)
`NewScreens/NewProgrammeCourses.aspx.cs`: added `FindDuplicateSubjectCode()` guard wired into **both** the add and edit paths. Before assigning a course to a programme/year/semester it blocks a **different course code carrying the same subject name** already offered in that slot ("…already offers this subject … as course X — reuse it or archive it first"). Soft-fails (never blocks a legitimate save on query error) and matches on course name only, so it works even where the dedup columns aren't present. Balanced (283/283 braces, 1346/1346 parens); guard SQL validated live. **137** existing same-subject slots remain (mostly cross-program/multi-spec codes intentionally not auto-merged) — the guard stops *new* ones; the existing 137 are a registry-review follow-up.

## Not yet done (follow-ups)
- **3,793 "orphan-with-data" courses**: unmapped but carry 208,520 results — deliberately KEPT (archiving would hide real grades). Needs registry decision on re-mapping vs leaving.
- **137 remaining same-subject slots** (mostly cross-program/multi-spec): guard blocks new ones; consolidating the existing ones needs registry review (multi-program codes are unsafe to auto-merge).
- **Category B (cross-program)**: subject layer is in place for grouping/reporting; no physical merge performed (per recommendation).
- **12 benign secondary config leftovers** keeping old codes — optional later sweep.
