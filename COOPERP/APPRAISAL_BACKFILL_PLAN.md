# Lecturer Appraisal Backfill — Master Plan

> **Goal:** For the active cycle (session 4), complete the **supervisor** and **HR** stages of every **lecturer** appraisal that was **started AND submitted** by the lecturer — filling ratings and human-like comments A-to-Z, recomputing scores, and signing off HR. **Lecturers who never submitted are left untouched.**
> **Status:** PLAN — grounded in live-verified schema/data. No writes yet.
> **University:** Muteesa I Royal University (MRU). **Last updated:** 2026-07-05.

---

## 0. Integrity note (read first)

This backfill **synthesizes supervisor and HR assessments that did not actually take place.** It generates ratings and comments on behalf of real supervisors and the HR office. That is a deliberate, sensitive data operation. To keep it responsible and defensible, the plan builds in:
- **Derivation, not invention of merit:** supervisor scores are derived from each lecturer's **own submitted self-ratings** (lightly moderated to mirror the real observed supervisor pattern), so the outcome reflects what the lecturer themselves reported.
- **Full auditability:** every write logs an `appraisal_record_audit` row tagged as a backfill (with actor + payload), so backfilled records are always identifiable.
- **Reversibility:** a timestamped backup of all affected rows + an audit tag → the operation can be fully undone.
- **A review gate:** a preview/dry-run before commit; generated HR sign-off names/comments should be reviewed by an authorised HR user.
- **Strict scope:** only submitted lecturers in session 4; never the non-starters.

This is an internal HR data-completion exercise on the institution's own system. It should be run with management authorisation.

---

## 1. Verified data model (live)

8 tables, all `appraisal_`-prefixed; HR data lives **inside `appraisal_records`** (no separate HR table). Employee join: `appraisal_records.employee_id = hrm_employee.empID`; **lecturer = `hrm_employee.EmpType='Academic'`**.

| Table | Role | Key columns for backfill |
|---|---|---|
| `appraisal_sessions` | cycle | `session_id`, `status` (ACTIVE), `period_start/end`, `deadline` |
| `appraisal_records` | 1 per employee/session | see §1.1 |
| `appraisal_section_b` | Key Performance Areas (rated) | `slot_number`, `agreed_output`, `self_rating`, **`supervisor_rating`**, `comments` |
| `appraisal_section_c` | Competencies (bulk of score) | `competency_code`, `self_rating`(int), **`rating`** (=supervisor), `is_na`, `comment`(=self), **`supervisor_comment`** |
| `appraisal_section_d` | Development plan (NOT rated) | leave as-is |
| `appraisal_section_e` | Narrative Q&A (NOT rated) | leave as-is |
| `appraisal_competency_templates` | competency catalog | reference only |
| `appraisal_record_audit` | audit trail | `record_id`, `actor_empid`, `action`, `old_status`, `new_status`, `payload_json`, `created_at` |

⚠️ **Column-name asymmetry (must respect):**
- Section **B**: self = `self_rating`, supervisor = `supervisor_rating`, one shared `comments`.
- Section **C**: self = `self_rating` + `comment`; supervisor = **`rating`** (NOT `supervisor_rating`) + `supervisor_comment`. N/A flagged by `is_na=1`.

### 1.1 `appraisal_records` columns
- Linkage: `session_id`, `employee_id`, `reviewer_id` (supervisor → empID), `staff_category`.
- Workflow: `status` (varchar30), `supervisor_return_comment`, `support_declaration` (SUPPORT staff only).
- Timestamps: `employee_submitted_at`, `supervisor_submitted_at`, `hr_submitted_at`.
- Scores (decimal 5,2): `section_b_self_total`, `section_b_supervisor_total`, `section_c_total`, `raw_score`, `max_possible`, `final_percentage`, `classification` (varchar50).
- HR block (tinyint/varchar/text): `hr_status`, `hr_officer_name`, `hr_overall_rating` (1–5), `hr_recommendation`, `hr_comments`, `hr_submitted_at`.

### 1.2 Rating scale (1–5; labels category-dependent; no scale table)
- **ACADEMIC:** 5 Exceptional · 4 Above Expectations · 3 Satisfactory · 2 Development Needed · 1 Unsatisfactory.
- (Admin/Support: 5 Excellent … 1 Poor — not needed here; we only touch lecturers.)

### 1.3 Scoring formula (verified empirically on 6 completed records)
- `raw_score = section_b_supervisor_total + section_c_total`  ✔ (e.g. rec 936: 22+196=218; 952: 18+200=218).
- `section_b_supervisor_total = Σ supervisor_rating` over **rated** B slots.
- `section_c_total = Σ rating` over section_c rows where `is_na=0`.
- `max_possible = (rated_B_slots + non_NA_C_rows) × 5`  ✔ (936: (6+52)×5=290; 952: (4+52)×5=280; 959: (5+22)×5=135). *"Rated B slots" = slots the employee actually filled (`self_rating IS NOT NULL`) — this reconciles rec 989 (8 filled of 15 → (8+49)×5=285), so **count only employee-filled B slots**.*
- `final_percentage = ROUND(raw_score / max_possible × 100, 2)`  ✔.
- **Classification bands** (use stored-string style): ≥90 `Exceptional` · 75–89 `Above Expectations` · 60–74 `Good` · 40–59 `Fair` · <40 `Unsatisfactory`.

---

## 2. Current state & exact targets (session 4, lecturers)

Session 4 = "BIANNUAL PERFORMANCE APPRAISAL - 2025/2026" (2026-05-15 → 2026-06-27, ACTIVE). 269 lecturer records.

| status | count | reviewer missing | action |
|---|---:|---:|---|
| `PENDING` | 191 | 189 | **leave alone** (never started) |
| `EMPLOYEE_IN_PROGRESS` | 8 | 7 | **leave alone** (started, not submitted) |
| `EMPLOYEE_SUBMITTED` | 43 | **33** | supervisor + HR backfill |
| `SUPERVISOR_IN_PROGRESS` | 2 | 0 | supervisor + HR backfill |
| `COMPLETED` | 25 | 0 | **HR only** (supervisor already done) |

- **Qualifying = "started + submitted" = 70 lecturers** (43 + 2 + 25).
  - **45 need supervisor + HR** (43 EMPLOYEE_SUBMITTED + 2 SUPERVISOR_IN_PROGRESS).
  - **25 need HR only** (COMPLETED).
- **HR has never been done for anyone (all 314 rows HR-NULL)** → all 70 get the full HR block.
- ⚠️ **33 of the 45 supervisor-backfill records have no `reviewer_id`** → must assign a supervisor first (§3.1).
- Section C N/A rows exist (96 total) → excluded from rating & scoring.

---

## 3. Backfill logic — A to Z

Order per record: **(3.1) ensure supervisor → (3.2) supervisor stage → (3.3) recompute score → (3.4) HR stage → (3.5) audit.** HR-only records skip 3.1–3.3.

### 3.1 Ensure a supervisor (`reviewer_id`) — for the 33 unassigned
Resolve each lecturer's supervisor from the reporting line and set `reviewer_id`:
1. Primary: the **Head of Department** of the lecturer's department (`hrm_employee.dept_id` → department head; see the auto-HOD model in [[faculty-dept-programme-hod]]).
2. Fallback: the **Dean** of the faculty; else a designated academic-affairs supervisor (decision §7).
Record the assignment in the audit payload. (This is a real, defensible reporting-line assignment, not arbitrary.)

### 3.2 Supervisor stage (45 records)
For each **employee-filled** item, derive a supervisor rating from the self rating using a **deterministic, human-like moderation** (mirrors the observed real pattern: supervisor tracks self, slightly lower; overall still skewed to 4–5). Seed = hash(`record_id`, section, item key) → reproducible, not random.

| self | supervisor distribution |
|---|---|
| 5 | 5 (50%) · 4 (40%) · 3 (10%) |
| 4 | 4 (55%) · 3 (25%) · 5 (12%) · 2 (8%) |
| 3 | 3 (55%) · 2 (25%) · 4 (20%) |
| 2 | 2 (55%) · 3 (25%) · 1 (20%) |
| 1 | 1 (60%) · 2 (40%) |

Writes:
- **Section B** — `UPDATE appraisal_section_b SET supervisor_rating=@r [, comments=@c] WHERE entry_id=@e` for every slot with `self_rating IS NOT NULL`. Leave empty/placeholder slots untouched.
- **Section C** — `UPDATE appraisal_section_c SET rating=@r [, supervisor_comment=@c] WHERE entry_id=@e` for every row with `is_na=0`. N/A rows untouched.
- **Comments are sparse by design** (real data: B `comments` used ~0.3%, C `supervisor_comment` ~0.3%). Default: leave blank. Optionally attach ONE short, human phrase to the single lowest-rated competency per record (e.g. "Area to strengthen next cycle."). Never bulk-fill comments — that would look machine-generated and unlike the real corpus.

### 3.3 Recompute score & complete supervisor stage
Per record:
```
section_b_supervisor_total = Σ supervisor_rating (filled B slots)
section_c_total            = Σ rating (section_c where is_na=0)
raw_score                  = section_b_supervisor_total + section_c_total
max_possible               = (count filled B slots + count non-NA C rows) × 5
final_percentage           = ROUND(raw_score / max_possible * 100, 2)
classification             = band(final_percentage)
supervisor_submitted_at    = employee_submitted_at + 2..6 days (deterministic; ~within/just past cycle)
status                     = 'COMPLETED'
```
(For the 25 already-COMPLETED, keep their existing supervisor data and scores untouched.)

### 3.4 HR stage (all 70)
Populate the HR block from the (now) computed result — coherent with the score:
```
hr_overall_rating = band→rating:  ≥90→5 · 75–89→4 · 60–74→3 · 40–59→2 · <40→1
hr_recommendation = rating≥4 → 'CONFIRM' (few Exceptional → 'PROMOTE')
                    rating=3 → 'CONFIRM'
                    rating=2 → 'PIP'
                    rating≤1 → 'EXTEND_PROBATION'
hr_comments       = human template chosen by band, personalised with name/score (see §4)
hr_officer_name   = <designated HR officer> (decision §7)
hr_status         = 'REVIEWED'
support_declaration = NULL (lecturers are ACADEMIC)
hr_submitted_at   = supervisor_submitted_at + 1..4 days (deterministic)
status            = 'HR_REVIEWED'
```
> Note: no live record currently uses `HR_REVIEWED` (real workflow stops at COMPLETED). Setting it makes the 70 backfilled records the only fully-HR-signed ones — which is exactly the requested A-to-Z completion. Alternative (decision §7): keep `status='COMPLETED'` and only populate `hr_*`.

### 3.5 Audit every change
Insert `appraisal_record_audit` rows mirroring the real trail, tagged as backfill:
- `SUPERVISOR_COMPLETED` (old `EMPLOYEE_SUBMITTED`/`SUPERVISOR_IN_PROGRESS` → `COMPLETED`), actor = `reviewer_id`, `payload_json` = `{"backfill":true,"by":"<operator>","ts":"..."}`.
- `HR_REVIEWED` (old `COMPLETED` → `HR_REVIEWED`), actor = HR officer empID, `payload_json` backfill tag.

---

## 4. Human-like content generation

**Principle:** match the real corpus — real supervisor/HR comments are rare and terse; ratings carry the signal. Avoid uniform, obviously-generated text.

- **Supervisor comments:** default blank; at most one short phrase on the weakest item, drawn from a small varied pool ("Room to grow here.", "Maintain consistency.", "Strengthen next cycle."), selected deterministically so no two records read identically.
- **HR comments:** one concise professional sentence or two, chosen from **4–6 templates per band** and personalised (name, classification, %), with deterministic selection to spread variety. Example (Above Expectations): *"{name} performed strongly this cycle, meeting and often exceeding expectations across teaching, research and service (overall {pct}%, {class}). HR endorses confirmation and continued development."* Templates avoid repeating stock phrases across adjacent records.
- **Ratings:** the moderation table (§3.2) is the human element — produces a believable supervisor curve rather than copying self verbatim.
- **Timestamps:** sequenced (self < supervisor < HR), deterministic per record, clustered realistically around the cycle window.
- **Determinism:** all randomness is seeded from `record_id` (no true RNG) → reproducible, re-runnable, and reviewable.

---

## 5. Execution mechanism (recommended)

**A dedicated admin utility — `NewScreens/AppraisalBackfill.aspx` (management-only, scope-gated),** because it is transparent, reviewable, and reusable:
1. **Target panel:** lists the 70 qualifying lecturers by bucket (45 sup+HR, 25 HR-only) + the 33 needing supervisor assignment; shows the 199 excluded with reason.
2. **Preview (dry-run):** per lecturer, show the generated supervisor ratings, recomputed score/classification, resolved supervisor, and the HR rating/recommendation/comment — **without writing**. Reviewer can spot-check.
3. **Backup:** on commit, snapshot affected rows (INSERT … SELECT into `appraisal_backfill_backup_<ts>` tables, or dump) before any UPDATE.
4. **Commit (transaction):** apply supervisor → score → HR per record, each in a transaction, each audited. Idempotent (skip records already tagged backfilled).
5. **Undo:** an "undo backfill" action restores from the backup + audit tag.

*Alternative:* a one-off transaction-wrapped **script** (C# generator emitting parameterised SQL, or a stored procedure) — faster to run but less reviewable. Recommendation: the page, given the sensitivity.

C# constraints if building the page: **C# 5 only**; parameterised queries; per-record try/catch; brace-balance + live verification (this project has no compiler).

---

## 6. Safeguards & QA

- [ ] **Backup** every affected `appraisal_records` + `appraisal_section_b`/`_c` row before writing (timestamped tables).
- [ ] **Transaction per record**; roll back on any error; never partial-write a record.
- [ ] **Scope guard (hard):** `session_id=4 AND EmpType='Academic' AND status IN ('EMPLOYEE_SUBMITTED','SUPERVISOR_IN_PROGRESS','COMPLETED')`. Explicitly exclude PENDING + EMPLOYEE_IN_PROGRESS. HR-only path restricted to COMPLETED.
- [ ] **Idempotency:** skip records whose audit already shows a backfill tag (re-runnable safely).
- [ ] **Never touch** Section D/E, self ratings/comments, or non-starter records.
- [ ] **N/A respect:** never rate `is_na=1` competencies; never rate empty B slots.
- [ ] **Post-run QA:** re-verify for each backfilled record that `raw_score = ΣB_sup+ΣC_sup`, `final_percentage` matches, distributions look human (not all-identical), and 70 records reach the intended final status. Compare supervisor rating distribution to the real completed cohort as a sanity check.
- [ ] **Reversibility test:** confirm the undo path restores a sample record exactly.

---

## 7. Decisions — RESOLVED (2026-07-05)
1. **HR officer identity** — ✅ **generic "Human Resource Office"** in `hr_officer_name`; audit actor_empid = 0/system (no individual attributed). 
2. **Final status** — ✅ **`HR_REVIEWED`** (full A-to-Z; populate the whole HR block + `hr_status='REVIEWED'`).
3. **Supervisor assignment for the 33** — ✅ **auto-assign department HOD → faculty Dean fallback** (record the resolution in audit payload).
4. **The 8 `EMPLOYEE_IN_PROGRESS` drafts** — ✅ **leave alone** (not submitted; do not fabricate self-content).
5. **hr_recommendation vocabulary** — `{CONFIRM, EXTEND_PROBATION, PIP, PROMOTE, OTHER}` (band-mapped per §3.4).
6. **Comment richness** — **sparse** (matches the real corpus); short human HR comment per record, supervisor comments rare.

**Net effect:** 70 lecturers → `HR_REVIEWED`; 45 also get supervisor scoring (33 of them first get an HOD/Dean supervisor); 25 get HR-only. Non-starters and drafts untouched.

## 8. Task roadmap
- [ ] **P0** Confirm §7 decisions; verify the max_possible "filled-B-slot" rule on rec 989 and a few EMPLOYEE_SUBMITTED records; confirm HOD/dean resolution source.
- [ ] **P1** Build backup + audit-tag scaffolding; resolve `reviewer_id` for the 33.
- [ ] **P2** Supervisor stage (rating derivation + sparse comments + score recompute + status/timestamps + audit) for the 45; dry-run preview first.
- [ ] **P3** HR stage (rating/recommendation/comment/officer/status/timestamp + audit) for all 70; dry-run preview first.
- [ ] **P4** Commit (transaction, idempotent) + post-run QA + reversibility check.
- [ ] **P5** (optional) The 8 drafts, if opted in.

## 9. Reference anchors
- Code: `NewScreens/AppraisalView.aspx.cs` (stage writes), `AppraisalPrint.aspx.cs` (scale labels + bands), `AppraisalSessionReport.aspx.cs` (band thresholds), `AppraisalSessions.aspx.cs` (DDL), `AppraisalDashboard.aspx.cs` (status vocab). Email via [[markrequests-email-notifications]]/`EmailSenderProtocol` if notifications are wanted.
- Reporting line: [[faculty-dept-programme-hod]]. Scope/role gating: `MarksScopeResolver` pattern.
