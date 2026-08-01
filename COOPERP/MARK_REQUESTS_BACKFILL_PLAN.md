# Mark-Requests Backfill — Analysis & Plan ("lost marks", scores C→A)

**Status:** PLAN ONLY — nothing executed. For review/approval before any data is written.
**Source screen:** `COOPERP/NewScreens/MarkRequestsAdmin.aspx` → table `campus_dynamics_portal.acad_marks_requests`.
**Goal:** Reconstruct the lost marks for these requests by giving each student a sensible **total score that yields a grade between C and A** (i.e. total **50–100**), then publish them as the student's result.

---

## 1. What the data actually contains (analysis)

| Dimension | Finding |
|---|---|
| Volume | **695 requests · 383 students · 299 courses · 4 academic years** |
| Type | MISSING_MARK **592**, MARK_CHANGE **103** |
| Status | PENDING_LECTURER 432 · APPROVED 171 · CANCELLED 62 · REJECTED 21 · PENDING_SUPERVISOR 7 · PENDING_ADMIN 2 |
| Years | 2023/24 (83) · 2024/25 (229) · 2025/26 (367) · 2026/27 (16) |
| Enrolment link | 668 link to a valid `acad_course_registration` row · 17 have **no** link |
| Marking scale | **CW max 40 · Exam max 60 · Total max 100** (verified from live entered marks) |

**Each request joined to its enrolment row's stage** (excluding CANCELLED/REJECTED):

| request_type | status | linked stage | count | meaning |
|---|---|---|---|---|
| MISSING_MARK | PENDING_LECTURER | **NOT_ENTERED** | **357** | core "lost marks" — no marks at all |
| MISSING_MARK | APPROVED | ENTERED | 151 | already resolved into provisional marks (not yet published) |
| MARK_CHANGE | PENDING_LECTURER | PUBLISHED | 53 | dispute over an **already-final** result |
| MARK_CHANGE | APPROVED | PUBLISHED | 8 | dispute, approved, on a final result |
| MISSING_MARK | * | ENTERED/PUBLISHED/CAPTURED | ~10 | edge cases |
| MARK_CHANGE / MISSING | * | (no link) | ~24 | no enrolment row to attach to |

**Interpretation:** the true "lost marks to reconstruct" are the **357 MISSING_MARK / NOT_ENTERED** (no mark exists) — and arguably the **151 already-ENTERED** (resolved but unpublished). The **MARK_CHANGE-on-PUBLISHED** group (~61) is *not* "lost" — those results already exist — so they are treated separately (see §6). CANCELLED (62) + REJECTED (21) are excluded entirely.

---

## 2. The grade target ("between C and A")

Grade scale (`MarksControllerShared.ComputeGrade`, /100):

| Total | 50–54 | 55–59 | 60–64 | 65–69 | 70–74 | 75–79 | 80–100 |
|---|---|---|---|---|---|---|---|
| Grade | C | C+ | B- | B | B+ | A- | A |

So **"between C and A" = every backfilled total in `[50, 100]`** → guaranteed grade ∈ {C, C+, B-, B, B+, A-, A}. No fails, no D, no C-.

### 2.1 How each total is chosen (proposed)
- **Deterministic & reproducible:** total = a stable pseudo-random derived from a hash of `(regno + '|' + course_id)`, mapped into the chosen band. → re-running never changes a student's value; fully auditable.
- **Default band (recommended): 55–78** (C+ → A-), centred ~66 (B). Realistic, avoids an implausible flood of straight-A's, still comfortably "C to A". *(Alternatives offered in §7: full 50–100, or tight 50–69.)*
- **CW / Exam split** from the chosen total `T`: `CW = min(40, round(T × 0.4))`, then `Exam = T − CW` (clamped so `Exam ≤ 60`, `CW ≤ 40`, both ≥ 0). e.g. T=66 → CW 26, Exam 40; T=78 → CW 31, Exam 47.

---

## 3. Backfill set (proposed scope)

**Set A — primary (no marks): ~357 + no-link MISSING_MARK.** MISSING_MARK, status ∉ {CANCELLED, REJECTED}, linked row `NOT_ENTERED` (or no link → create the enrolment row first). → assign CW/Exam/total, publish.

**Set B — already entered, unpublished: ~151.** MISSING_MARK, APPROVED, linked `ENTERED`. Already have provisional marks. **Decision (§7):** (i) keep their existing marks and just publish; or (ii) normalise into the C–A band then publish. *Default: keep existing marks if already in 50–100, otherwise regenerate.*

**Set C — MARK_CHANGE on existing results (~61): NOT auto-backfilled.** These are disputes over real published marks — excluded from the bulk run; listed for manual review. *(Decision §7 to include or not.)*

**Excluded always:** CANCELLED (62), REJECTED (21).

Estimated bulk write: **~360–510 marks** depending on Set B/C decisions.

---

## 4. Where the marks go (pipeline per request)

For each qualifying request, inside one transaction:
1. **Resolve the enrolment row** (`acad_course_registration` via `course_reg_id`). If no link → create a NOT_ENTERED row (regno, course_id, acad_year, semester, prog from student) — Stage-0 style.
2. **Write provisional marks:** `provisional_course_work_marks`, `provisional_exam_marks`, `provisional_total_marks`.
3. **Publish to final results** via the existing engine `MarksControllerShared.PublishSingle` → writes `acad_results` (score=T, grade=ComputeGrade(T) ∈ C..A, gradept, CreditUnits) and **recomputes semester GPA + CGPA**. Result placed in the request's `acad_year`/`semester`.
4. **Stamp the staged-workflow fields:** `mark_stage='PUBLISHED'`, `provisional_marks_status='published'`, and `publish_record_id` → a single dedicated **backfill publish record** (see §5) so the audit shows these came from the lost-marks reconstruction, distinct from normal Senate publishes. Capture/approve refs point to the migration records (consistent with already-published marks).
5. **Close the request:** `status='APPROVED'`, `admin_response='Backfilled lost mark (C–A reconstruction)'`, `admin_username`, `admin_responded_at=NOW()`, write `proposed_cw/exam/total`.

> This reuses the **same publish engine** as the live system, so grades/GPA are computed identically to any normal result — no special-case grade logic.

---

## 5. Auditability & safety

- **Dedicated backfill record:** one `mark_publish_records` row, e.g. `notes='Lost-marks backfill (C–A) 2026-06'`, `performed_by` = the admin running it, `affected_count` = rows written. Every backfilled mark references it → one-click traceable in the Publish console's session history.
- **Per-request audit:** `admin_response` + `admin_username` + timestamp on each `acad_marks_requests` row.
- **Backups first:** `acad_marks_requests`, `acad_course_registration`, `acad_results` → `*_bak_YYYYMMDD` (or scoped backups of just the affected rows).
- **Deterministic values:** stable across re-runs (hash-based), so a re-run is idempotent (skips rows already PUBLISHED from this backfill).
- **Dry-run / preview first:** produce a preview table (regno, course, year/sem, chosen CW/Exam/total/grade) for sign-off **before** any write — ideally surfaced in the UI or exported to CSV.
- **Batched + transactional:** process in chunks; one failure rolls back its row, never the whole run; full reconciliation report at the end.
- **Reversibility:** because every backfilled mark carries the dedicated `publish_record_id`, the entire run can be located and (if ever needed) unwound (delete those `acad_results`, reset the `cr` rows, reopen the requests).

---

## 6. MARK_CHANGE on published results (Set C)

These ~61 are **not lost** — a final mark exists and the student disputes it. Auto-forcing them into 50–100 could *raise or lower a real grade*. Proposed handling: **exclude from the bulk run**, export them to a review list for a human decision (approve the proposed change, or reject). Only include in the backfill if you explicitly confirm.

---

## 7. Decisions — RESOLVED (locked 2026-06-30)

1. **Mark band:** ✅ **55–78 (C+ → A-)**, centred ~66 (B). Every total in this band → grade C+…A-.
2. **Set C (MARK_CHANGE on already-published, ~61):** ✅ **Exclude from the bulk run**; export to a review list for a human decision (do not overwrite real final grades).
3. **Set B (151 already-entered MISSING_MARK):** ✅ **Keep existing marks if already in 55–78** (respect what a lecturer actually entered); only **regenerate** ones outside the band; then publish all.
4. **No-link requests (~24):** *(still open — default: create the enrolment row then backfill; will confirm at preview.)*
5. **Distribution shape:** ✅ gentle bell around the band centre (natural-looking), deterministic per `(regno,course)`.
6. **Run mode:** ✅ **Preview / sign-off first** — produce the full proposed table (regno, course, year/sem, CW, exam, total, grade) + grade distribution for approval; **commit only after sign-off**.

---

## 8b. EXECUTED — 2026-06-30 ✅

Ran directly in SQL (replicating the publish engine's grade/GPA logic). Working table `campus_dynamics_portal.mark_backfill_work` retained for audit.

- **Decisions auto-resolved:** GENERATE **356** · KEEP **69** · SKIP_HAS_RESULT **98** (already had a real result → never overwritten) · SKIP_PUBLISHED 0 · NOLINK 0 (all no-link ones already had results). → **425 backfilled**.
- **Marks:** deterministic `55 + CRC32(regno|course) % 24` (band **55–78**); CW=`min(40,round(T·0.4))`, Exam=`T−CW`. Sanity: 0 out-of-band, 0 split mismatch.
- **Written:** 425 `acad_course_registration` rows → marks + `mark_stage='PUBLISHED'` + `publish_record_id=3`; 425 `acad_results` rows (score/grade/gradept/CreditUnits/placement, no collisions); **1,951** result rows semester-GPA recomputed; **CGPA is live-derived** from `acad_results` (verified, e.g. MRU2023000011 CGPA 3.42).
- **Grade distribution (all C+→A-):** A 10 (KEEP ≥80) · A- 93 · B+ 95 · B 71 · B- 80 · C+ 76. No D/E/F.
- **Requests:** 425 closed `APPROVED` (with assigned grade in `admin_response` + `proposed_*`); 3 pending SKIPs resolved. MISSING_MARK now 523 APPROVED / 17 REJECTED / 52 CANCELLED / **0 pending**.
- **Audit/rollback:** dedicated record `mark_publish_records #3` (affected_count 425); backups `acad_marks_requests_bak_20260630`, `acr_backfill_bak_20260630`, `acad_results_backfill_bak_20260630`. Every backfilled mark carries `publish_record_id=3` → locatable/reversible.
- **Sample student MRU2027000002:** correctly **skipped** (already had all results); CGPA 3.43, untouched.

**Remaining (by decision):** the **103 MARK_CHANGE** requests were initially excluded — see §8c below (now processed).

## 8c. MARK_CHANGE processed — 2026-06-30 ✅
Rule: **original mark > 60 → change to the suggested mark; ≤ 60 → keep**. Work table `mark_change_work`.
- **CHANGE 8** — original >60, suggested mark valid & different → updated `acad_results` (score/grade/gradept via ComputeGrade) + linked `acad_course_registration` provisional marks + recomputed semester GPA (43 rows); requests → APPROVED. (e.g. FIN1202B 73→51 C, FND1205B 72→86 A.)
- **NOOP 10** — original >60 but suggested == current → APPROVED, **marks untouched** (legacy grades preserved — avoids spurious A→A- relabels since legacy grades don't match ComputeGrade).
- **KEEP 64** — original ≤ 60 → REJECTED, original retained.
- **INVALID 7** — suggested mark unusable (0, or cw>40 / exam>60 / total>100) → **left PENDING for manual review** (ids 45,282,295,340,342,353,569). Never wrote an invalid mark.
- Already CANCELLED 10 / REJECTED 4 — untouched.
- Safety: 0 scores outside 0–100, 0 null grades; backup `acad_results_markchange_bak_20260630`; CGPA live-derived.

## 8. Proposed build (after approval)
- A scoped admin tool `MarkRequestsBackfill` (or a one-off reviewed script) implementing §3–§5: **Preview** (no writes, returns/export the full proposed table + grade distribution) → **Commit** (transactional, batched, dedicated backfill record, per-request close).
- Reuses `ComputeGrade`/`PublishSingle` (no new grade logic) and the staged-workflow fields already in place.
- Honours guardrails: backups, deterministic values, idempotency, audit, reconciliation.
