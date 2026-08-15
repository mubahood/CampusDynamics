# Course Records Correction Centre — Design & Build Plan

**Status:** Plan approved for build · drafted 15 August 2026
**Location in system:** Academics → Exam → *Course Records Correction Centre*
**Audience:** Administrators, Deans, Heads of Department (scope-limited)

---

## 1. The problem this solves

Registrations inherited from the old system are attached to the wrong course record. Four
distinct faults, all currently fixed by hand or not at all:

| Fault | Example seen in live data |
|---|---|
| Same course, two codes — one spaced, one not | `ICT 1108B` and `ICT1108B` |
| Same course, two codes — one suffixed | `ICT1108` and `ICT1108B` |
| Registration sitting in the wrong term | A Semester 2 course registered under Semester 1 |
| Two catalogue entries that are genuinely one course | 77 already merged in the 2026-07 cleanup |

Fixing these by hand is unsafe: marks are attached to the registration, a unique index can
reject the change halfway, and there is no record of who changed what or any way back.

**The module's promise: every correction is previewed before it runs, applied atomically,
recorded row-by-row with a full before-image, and reversible at any later date by any
authorised user.**

---

## 2. Verified facts the design must respect

Everything below was read from the live database, not assumed.

### 2.1 The master table

`campus_dynamics_portal.acad_course_registration` — 615,372 rows.

> **UNIQUE `Index_UNQ` on (regno, courseID, acad_year, semester, course_status)**

This is the single biggest constraint. Re-coding or re-terming a registration can collide with
a row the student already holds. The collation is case-insensitive, so `Normal` and `NORMAL`
already occupy the same slot.

### 2.2 The published-marks table

`campus_dynamics.acad_results` — 636,777 rows.

> **UNIQUE `Index_UNQ` on (regno, courseid) — term is NOT part of the key.**

A student may therefore hold only **one** published result per course code for their whole
career. This is a tighter constraint than the registration table and will reject moves that the
registration table would accept. Both must be checked before either is written.

### 2.3 Audit triggers already on acad_results

`trg_acad_results_audit_ai / _au / _ad` write to `acad_marks_audit`. The UPDATE trigger fires
**only when `score` or `grade` changes** — a `courseid`-only update is not captured. The module
must therefore do its own recording, and must populate `mark_audit_context` (matched on
`CONNECTION_ID()` within 60 seconds) so any mark movement is attributed to the real user rather
than `system`.

### 2.4 Everything that carries a student's course record

Confirmed by column scan. Column names differ per table and are listed exactly:

| DB | Table | Rows | Student | Course | Year | Semester | Programme |
|---|---|---:|---|---|---|---|---|
| portal | **acad_course_registration** | 615,372 | `regno` | `courseID` | `acad_year` | `semester` | `prog_id` |
| main | **acad_results** | 636,777 | `regno` | `courseid` | `acad` | `semester` | `progid` |
| main | **acad_transcript_results** | 57,948 | `regno` | `courseid` | `acad` | `semester` | `progid` |
| portal | acad_retake_registrations | 185 | `regno` | `courseID` | `retake_acad_year` | `retake_semester` | `prog_id` |
| portal | acad_coursework_exceluploads | 265 | `regno` | `courseID` | `acadyear` | `semester` | `progID` |
| portal | acad_exam_exceluploads | 8 | `regno` | `courseID` | `acadyear` | `semester` | `progID` |
| portal | acad_results_complaints | 9 | `regno` | `courseid` | `acadyear` | `semester` | `progid` |

**Deliberately excluded:** `acad_results_legacy` (320,584 rows) is a frozen archive of the old
system and is never written. `campus_dynamics_portal.acad_results` has no course column.
`acad_coursework_marks` / `acad_practicalexam_marks` key on `CSID` (a course-offering id), not
on a course code, so they follow the offering and not the student — noted in §6.3.

### 2.5 Catalogue tables (Course Code Merge only)

| DB | Table | Rows | Course column |
|---|---|---:|---|
| main | acad_course | 6,599 | `courseID` |
| main | acad_programmecourses | 6,770 | `course_code` |
| main | acad_teaching_allocation | 15,611 | `courseID` + `course_code` |
| main | acad_teaching_allocation_for_registration | 1,079 | `courseID` |
| main | acad_timetable_item | 87 | `course_code` |
| main | acad_exam_timetable | 110 | `courseID` |
| main | acad_coursework_timetable | 12 | `courseID` |
| portal | acad_examsettings | 11,694 | `courseID` |
| portal | acad_researchexamsettings | 10,832 | `courseID` |
| portal | acad_coursework_settings | 8,414 | `courseID` |
| portal | odel_course_space | 2,876 | `courseID` |
| portal | acad_practicalexam_settings | 371 | `courseID` |
| portal | acad_examination_papers | 37 | `courseID` |

### 2.6 Transactional safety

**Every table above is InnoDB.** Both schemas live on the same server, so a single connection
can wrap the whole correction — main DB and portal DB — in **one transaction**. There is no
two-phase-commit problem to solve.

### 2.7 Prior art to reuse

The 2026-07 course consolidation left `acad_course_merge_map` and `acad_course_merge_audit`.
Their *concepts* (loser/survivor, category, decision) are carried forward, but the new module
writes to its own tables so that all three operations share one uniform reversal path.

### 2.8 Access model

- Scope: `MarksScopeResolver.Resolve()` → admin = all, Dean = faculty, HOD = department;
  enforced in SQL via `scope.ProgFilter(alias, column)`.
- Menu: a row in `sys_menu_items` under parent `academics.exam`, granted to roles in
  `sys_role_permissions` (`admin`, `registrar`, `exam_officer`, `dean`, `hod`).
- Sidebar markup uses `data-roles="admin registrar exam_officer dean hod"`.

### 2.9 Test subject

**`MRU2027000002`** — programme `TEST`, 24 course registrations that between them cover every
edge case the module must survive:

- the same code in two semesters (`ADM1106B` in Sem 2 and Sem 3)
- the same code, same term, differing only by `course_status` (`ICT1108B` NORMAL + RETAKE)
- four spellings of status in use (`REGULAR`, `NORMAL`, `Normal`, `RETAKE`)
- mark stages `PUBLISHED` and `NOT_ENTERED`; lecturer status `APPROVED`, `REMOVED`, `PENDING`
- retake rows carrying `registration_type='RT'`
- **no `acad_results` rows** — so results-side behaviour needs rows created deliberately for test

---

## 3. Module shape and naming

Wording chosen to be plain and institutional — "migration" reads as an IT word; these are
**corrections** to a student record.

| Thing | Name |
|---|---|
| Module | **Course Records Correction Centre** |
| Operation 1 | **Course Code Transfer** — move registrations from one code to another |
| Operation 2 | **Registration Term Transfer** — move registrations to a different year/semester |
| Operation 3 | **Course Code Merge** — permanently consolidate two catalogue entries |
| History & undo | **Correction Register** |
| A single run | **Correction batch**, referenced `CC-YYYYMMDD-NNNN` |

**Screens**

| File | Purpose |
|---|---|
| `CourseCorrectionCentre.aspx` | Tabbed hub — the three wizards |
| `CourseCorrectionRegister.aspx` | Every batch, its rows, and the Reverse action |
| `App_Code/Academics/CourseCorrectionService.cs` | All logic — preview, apply, reverse |
| `App_Code/Academics/CourseCorrectionModels.cs` | Config / verdict / result types |
| `COOPERP/sql/academics/course_correction_schema.sql` | Table DDL + menu + permissions |

Front end follows `ResultsExporter.aspx` exactly: `[WebMethod(EnableSession = true)]` PageMethods
returning a JSON string, called by a small `XMLHttpRequest` helper, with a JSON config object
built from the form and round-tripped to the server so preview and apply can never diverge.

---

## 4. Wizard flow (identical for all three operations)

```
Step 1  Choose what to correct     →  source code / source term
Step 2  Choose the target          →  target code / target term
Step 3  Narrow the scope           →  programme, academic year, semester, study year,
                                      mark stage, registration type, specific students
Step 4  Preview                    →  per-student verdict table + counts + conflicts
Step 5  Confirm and apply          →  typed confirmation, then atomic run
Step 6  Receipt                    →  batch reference, what changed, link to Register
```

No step may be skipped, and **Step 5 re-runs the Step 4 query inside the transaction**. If the
row set has changed since preview (someone else edited meanwhile), the batch aborts untouched.

---

## 5. Data model — the audit and reversal store

Two new tables in `campus_dynamics`.

### 5.1 `acad_correction_batch` — one row per run

```
id                BIGINT PK
batch_ref         VARCHAR(30) UNIQUE      -- CC-20260815-0001
operation         VARCHAR(24)             -- COURSE_TRANSFER | TERM_TRANSFER | COURSE_MERGE
status            VARCHAR(16)             -- PREVIEW | APPLIED | REVERSED | FAILED
source_code, target_code            CHAR(25)
source_year, target_year            CHAR(25)
source_semester, target_semester    INT
config_json       LONGTEXT                -- the exact wizard configuration
scope_label       VARCHAR(200)            -- "Dean — Faculty of Education"
rows_scanned, rows_applied, rows_skipped, students_affected   INT
tables_touched    VARCHAR(500)
performed_by      VARCHAR(150)
performed_at      DATETIME
performed_ip      VARCHAR(45)
reason            VARCHAR(400)            -- required from the user
duration_ms       INT
reversed_by       VARCHAR(150)
reversed_at       DATETIME
reverse_reason    VARCHAR(400)
reverse_batch_ref VARCHAR(30)
notes             TEXT
```

### 5.2 `acad_correction_row` — one row per record touched

```
id            BIGINT PK
batch_id      BIGINT  (indexed)
db_name       VARCHAR(64)
table_name    VARCHAR(64)
pk_column     VARCHAR(64)
pk_value      VARCHAR(64)
regno         VARCHAR(25)  (indexed)
action        VARCHAR(16)   -- UPDATE | SKIP | DELETE | INSERT
verdict       VARCHAR(32)   -- MOVED | SKIPPED_DUPLICATE | SKIPPED_TARGET_HAS_MARKS | ...
before_json   LONGTEXT      -- COMPLETE original row
after_json    LONGTEXT      -- COMPLETE new row
note          VARCHAR(300)
reversed      TINYINT DEFAULT 0
reversed_at   DATETIME
```

**Why a full row image rather than a diff:** reversal must still work if a column is added later,
and an investigator must be able to see exactly what a record looked like before anyone touched
it — without needing the module's code to interpret it.

---

## 6. The three operations in detail

### 6.1 Course Code Transfer

**Scope parameters** (all optional except the two codes):
programme · academic year · semester · study year · mark stage · registration type
(normal/retake) · lecturer status · specific student list · campus · faculty/department
(auto-applied from the user's scope, never widenable from the browser).

**Per-student verdict engine** — computed in preview, re-checked at apply:

| Verdict | Condition | Action |
|---|---|---|
| `MOVED` | No target row for that student/term/status; no `acad_results` clash | Update registration + every satellite row |
| `SKIPPED_DUPLICATE` | Target registration already exists | Leave untouched, list for review |
| `SKIPPED_RESULT_CLASH` | Student already has an `acad_results` row for the target code | Leave untouched — this is the one the unique index would reject |
| `SKIPPED_OUT_OF_SCOPE` | Programme outside the user's scope | Never shown as actionable |
| `SKIPPED_LOCKED` | Mark stage is PUBLISHED **and** "include published" was not ticked | Leave untouched |
| `CONFLICT_REVIEW` | Both source and target hold marks and they differ | Never auto-resolved |

**Rule: the module never deletes a mark and never overwrites one mark with another.** Anything
that would require that is reported for a human decision.

### 6.2 Registration Term Transfer

Same engine, different key: `acad_year` and `semester` move instead of the code. Additional
handling:

- The **paired `acad_results` row must move with it** — `acad`/`semester` updated in the same
  transaction. Because `acad_results` is unique on (regno, courseid) only, the term change
  cannot collide there, but the registration side can.
- `acad_transcript_results` follows the same rule.
- `acad_retake_registrations.retake_acad_year` / `retake_semester` follow when the row is linked
  by `course_reg_id`.
- **Study year is recomputed, not carried**, from `acad_programmecourses` for that programme and
  course; if the curriculum has no entry, the original value is kept and the row is flagged.

### 6.3 Course Code Merge

Catalogue-level and the most destructive, so it is the most guarded.

Order of work inside one transaction:

1. Student records first — every table in §2.4, loser code → survivor code, with the same verdict
   engine as 6.1 (conflicts stop the batch rather than being skipped, because a merge that
   leaves rows behind is not a merge).
2. Curriculum — `acad_programmecourses` repointed; a row that would duplicate an existing
   (progcode, course_code, study_year, semester) is deleted **after** its snapshot is stored.
3. Delivery — teaching allocations, timetables, exam/coursework/research settings, ODEL spaces.
4. Catalogue — the loser row in `acad_course` is **archived, never deleted** (status flag), so
   historical joins still resolve.

**Credit-unit guard:** if loser and survivor carry different `CreditUnit`, the wizard refuses to
proceed until the operator explicitly chooses which value survives — a silent CU change would
corrupt every GPA computed from it.

`acad_coursework_marks` / `acad_practicalexam_marks` attach to a course *offering* (`CSID`), not
a code. Merging codes leaves those attached to the surviving offering; where two offerings merge,
the plan is to repoint `CSID` and report the count, not to move individual marks.

---

## 7. Safety architecture — the ten rules

1. **Preview and apply share one query builder.** No second implementation can drift.
2. **Apply re-runs the preview inside the transaction** and compares row count and an ordered
   id-checksum. Any drift → abort, nothing written.
3. **Snapshot before write.** The `acad_correction_row` insert happens before the UPDATE, in the
   same transaction, so a snapshot can never be missing for an applied change.
4. **One transaction per batch**, across both schemas. Chunked at 500 rows with ordered ids for
   large batches, following the pattern already proven in the marks publish engine.
5. **Server-side scope only.** `MarksScopeResolver` is applied in SQL; the browser cannot widen it.
6. **Typed confirmation.** The operator types the batch reference to commit — no accidental
   double-click.
7. **Anti-forgery token + single-use batch token**, so a replayed POST cannot run twice.
8. **`mark_audit_context` is set** before any write, so the existing `acad_results` triggers
   attribute changes to the real user.
9. **A reason is mandatory** and stored on the batch.
10. **Every action logged** through `MarksActionLogger` (which already honours `sys_log_exempt`),
    in addition to the batch record.

---

## 8. Reversal design

Reversal is a **new batch** that references the original, so the audit trail is append-only and a
reversal can itself be inspected.

For each `acad_correction_row` of the original batch, newest first:

1. Read the row's current state from the database.
2. Compare it with `after_json`. If it differs, something changed after the correction —
   the row is **skipped and flagged `CHANGED_SINCE`**, never blindly overwritten.
3. If it matches, restore `before_json`.
4. `DELETE` actions are restored by re-inserting the snapshot; `INSERT` actions by deleting.

The Register shows, for every batch: who, when, from what to what, the scope, counts, the full
row list with before/after, and — if reversed — who reversed it and why.

**Partial reversal** is supported at student level: an operator may reverse a single student out
of a batch, which creates a reversal batch containing only that student's rows.

---

## 9. Access control

| Role | Preview | Apply | Reverse |
|---|---|---|---|
| Administrator | All programmes | Yes | Yes |
| Dean | Their faculty | Yes, within faculty | Own faculty's batches |
| Head of Department | Their department | Yes, within department | Own department's batches |
| Everyone else | No access |

Course Code Merge is **administrator-only** — it changes the catalogue for the whole institution,
not one faculty's students.

---

## 10. Build tasks

Executed in order; each testable on its own before the next began.

- [x] **T1 — Schema.** `acad_correction_batch` + `acad_correction_row`, plus the `sys_menu_items`
      rows and 10 `sys_role_permissions` grants. Re-runnable script at
      `COOPERP/sql/academics/course_correction_schema.sql`.
- [x] **T2 — Models.** `App_Code/Academics/CourseCorrectionModels.cs`.
- [x] **T3 — Table registry.** `CourseTableRegistry` — the §2.4/§2.5 map written once, so no query
      hard-codes a column name. `DeliberatelyExcluded` records the archive tables as a decision.
- [x] **T4 — Preview engine.** Set-wise verdicts: a 5,000-row batch costs three queries, not
      15,000. Scope applied in SQL.
- [x] **T5 — Apply engine.** One cross-schema transaction, checksum re-check, snapshot-then-write.
- [x] **T6 — Reversal engine.** Column-level diff restore with the `CHANGED_SINCE` guard.
- [x] **T7 — Term Transfer.** Shares the engine; results and transcript rows move with the
      registration.
- [ ] **T8 — Course Code Merge.** Catalogue phases, CU guard, archive-not-delete. *Engine and UI
      accept it; the catalogue phase is the remaining work — see below.*
- [x] **T9 — Front end: the hub.** `CourseCorrectionCentre.aspx`, five-step wizard, Export Centre
      AJAX pattern, design-system tokens, responsive.
- [x] **T10 — Front end: the Register.** History, drill-down with before→after diff, whole-batch
      and per-student reversal.
- [x] **T11 — Navigation.** Sidebar entries under Exam + RBAC slugs live for admin, registrar,
      exam officer, dean and HOD.
- [x] **T12 — Rehearsal on `MRU2027000002`.** Transfer, term move, reversal, and a confirmed
      return to the exact starting state.
- [x] **T13 — Adversarial tests.** 47 assertions, all passing (§12).
- [ ] **T14 — Documentation** for the Registrar's office.

### Test results — 47 assertions, all passing

Harness builds fixtures on `MRU2027000002`, runs the engine against the live database, asserts,
and removes every fixture.

| Scenario | What it proves |
|---|---|
| A — clean move + reversal | Registration, result and transcript all move; three snapshots stored; reversal restores all three; batch marked REVERSED; a second reversal is refused |
| B — duplicate target | The occupied slot is skipped, the other term still moves |
| C — published marks | Excluded by default, included only when ticked |
| D — result clash | `acad_results` UNIQUE (regno, courseid) collision caught **before any write**; both results intact |
| E — drift | A record edited between preview and apply aborts the batch with nothing written |
| F — changed since | Reversal leaves a hand-edited record alone, records it `CHANGED_SINCE`, marks the batch PARTIALLY_REVERSED |
| G — scope | A department-scoped user sees nothing out of scope and cannot apply |
| H — validation | Same source and target refused; missing reason refused; merge refused for non-administrators |
| I — term transfer | Registration and result term both move, and both restore |

### What remains

**Course Code Merge** is present as an operation and correctly restricted to administrators, but
only its student-record phase runs today — it behaves as a Course Code Transfer over every
student. The catalogue phases (curriculum repointing, teaching allocations, timetables, exam and
coursework settings, ODEL spaces, and archiving the retired `acad_course` row via the existing
`course_state`/`merged_into` columns) are specified in §6.3 and not yet built. Until they are,
merging leaves the retired code in the catalogue.

---

## 11. What could still go wrong, and the answer

| Risk | Mitigation |
|---|---|
| Unique index rejects a move mid-batch | Verdict engine pre-computes every collision; the index is a backstop, not the control |
| Someone edits a mark between preview and apply | Re-check inside the transaction; abort on drift |
| A reversal undoes a *later*, legitimate change | `CHANGED_SINCE` comparison against `after_json`; flagged, never overwritten |
| A Dean corrects another faculty's students | Scope applied in SQL, not in the UI |
| A very large batch times out | Chunked and ordered; batch stays open with resumable state |
| Marks silently lost | The module never deletes or overwrites a mark; conflicts are reported |
| Nobody knows who did it | Batch record + row snapshots + `MarksActionLogger` + `mark_audit_context` |
