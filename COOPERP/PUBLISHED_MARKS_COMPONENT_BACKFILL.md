# Published Marks — Component (CW / Exam) Backfill: Analysis & Plan

**Date:** 2026-07-08 · **DB server:** localhost (= 102.34.160.47) · **Status:** ✅ **EXECUTED & VERIFIED 2026-07-08** (40/60 split; lecturer-entered marks preserved). See §9.

---

## 1. Executive summary

When results were **imported from the old system**, the official final scores landed in the results ledger (`campus_dynamics.acad_results`) — but the matching provisional-marks rows in the staged-workflow table (`campus_dynamics_portal.acad_course_registration`) were only stamped as **published**; their **coursework, exam and total component values were left NULL**.

So today we have **~68,000 marks that are genuinely published (final score exists, grade exists, GPA computed) but show blank CW / Exam / Total** on the marks screens. This makes stats and per-mark views look "empty / not entered" even though the mark is final.

**The fix:** for every such published row, read its final score from `acad_results`, split it into a coursework figure (0–40) and an exam figure (0–60) that **add up exactly to the final score**, and write them back. The rows are already at `mark_stage = PUBLISHED` with a publish audit record, so no stage change is needed for the main group — we are only *completing* the numbers. A small second group (242 rows) is genuinely mis-staged and also gets advanced to PUBLISHED.

**Nothing about the official result (score/grade/GPA in `acad_results`) changes.** We only fill in the component breakdown on the provisional side so the two are consistent.

---

## 2. The data model (two tables, one truth)

| Table | DB | Role | Relevant columns |
|---|---|---|---|
| `acad_results` | `campus_dynamics` | **Official / published truth** (transcripts, GPA). 627,152 rows. | `regno, courseid, acad, semester, studyyear, score(0–100), grade, gradept, gpa, CreditUnits, progid` |
| `acad_course_registration` | `campus_dynamics_portal` | **Provisional + staged-workflow** (what the marks consoles read). 127,240 rows. | `regno, courseID, acad_year, semester, prog_id,` `provisional_course_work_marks, provisional_exam_marks, provisional_total_marks, provisional_marks_status, mark_stage, publish_record_id` |

**Join key:** `regno = regno`, `courseID = courseid`, `acad_year = acad`, `semester = semester`.
(`regno` has **no** padding; `courseid`/`acad` have a handful of padded values — see §4. The join must stay **index-friendly** — see §5.)

**Weighting convention (system-wide):** coursework is scored **out of 40**, exam **out of 60**, and `total = coursework + exam` (plain sum, max 100). Pass mark = 50 (NCHE 2015).

---

## 3. What the analysis found

### Current `mark_stage` × `provisional_marks_status` (all 127,240 rows)

| mark_stage | status | rows |
|---|---|---|
| PUBLISHED | published | **68,538** |
| NOT_ENTERED | pending | 47,852 |
| ENTERED | pending | 9,827 |
| CAPTURED | captured | 584 |
| NOT_ENTERED | not_entered | 404 |
| APPROVED | approved | 31 |
| APPROVED | published | 3 |
| CAPTURED | published | 1 |

### Population A — published, but component values blank  ← **the main target**

Of the **68,538** rows at `mark_stage = PUBLISHED`:

| Measure | Count |
|---|---|
| Have full components already (CW+Exam present) | 471 |
| **Missing CW *and* Exam *and* Total (all NULL)** | **68,067** |
| — of those, a matching final score exists in `acad_results` | **68,062**  ← backfillable |
| — of those, **no** matching result (orphans, can't backfill) | **5** |
| "CW only" / "Exam only" (partial) | 0 (it's always all-or-nothing) |

These 68,067 rows are **already fully published structurally**: `mark_stage = PUBLISHED`, `provisional_marks_status = 'published'`, and **all of them already carry `publish_record_id`** (pointing at the synthetic migration publish record `#1`, `is_migration=1`). **They only lack the three number columns.** So for Population A we do **not** touch the stage — we just fill CW/Exam/Total.

**Score profile of the 68,062 backfillable rows:** min **6**, max **98**, avg **70.2**; **0** scores above 100, **0** zeros; **929** below 50 (fails) and **67,133** ≥ 50 (pass). Clean, bounded 0–100 data — no special-casing needed.

### Population B — genuinely mis-staged (shows "not entered / entered" but a result is already published)  ← secondary cleanup

Rows **not** at PUBLISHED that nevertheless have a **same-term** published result in `acad_results`:

| Current mark_stage | rows | Have components? |
|---|---|---|
| NOT_ENTERED | 149 | No (blank) |
| ENTERED | 91 | Yes (lecturer-entered) |
| CAPTURED | 1 | Yes |
| APPROVED | 1 | Yes |
| **Total** | **242** | — |

Because the match is on the **same** academic year + semester as the registration (not a different term), these are **not retakes** — they are true inconsistencies where the result was published but the registration row's stage/components were never harmonised. This is the *"showing in not-entered yet already entered"* case.

### Edge cases discovered

- **Duplicate results:** 658 of 66,746 matched keys have **2** `acad_results` rows for the same `(regno, courseid, acad, semester)`. The backfill must be **deterministic** → we take **`MAX(score)`** per key.
- **5 orphans** (Population A with no source score) → cannot be backfilled; leave as-is and list them for manual review (likely bad/incomplete imports).
- **Fails (929):** a failed final score (e.g. 34) is still split (e.g. CW 14 / Exam 20). That is correct — a fail is still a real, published mark.

---

## 4. What we will write (the split rule)

For a final score `S` (0–100), when a component is missing:

```
total = S
CW    = ROUND(S * 0.4)          -- 0..40
Exam  = S - ROUND(S * 0.4)      -- remainder → 0..60, so CW + Exam = S exactly
```

Worked examples (verified against live data):

| Final score S | CW (≤40) | Exam (≤60) | CW+Exam |
|---|---|---|---|
| 6 | 2 | 4 | 6 |
| 50 | 20 | 30 | 50 |
| 70 | 28 | 42 | 70 |
| 98 | 39 | 59 | 98 |

- `CW + Exam = S` **always** (Exam is computed as the remainder, so rounding can never break the total).
- Caps respected: max S=98 → CW 39, Exam 59.
- **Where a component already exists** (Population B/ENTERED etc.) we **do not overwrite** lecturer-entered marks — see §6, decision D2.

---

## 5. Backfill approach — batched, set-based, RAM/CPU-safe

**Principles**
1. **Server-side set operations only.** No application loop pulling 68k rows into RAM — everything is a SQL `UPDATE … JOIN`. The DB never materialises more than one small batch at a time.
2. **Small batches by primary key.** Population A spans `id` 4 → 153,406. We process in windows of **5,000 ids** (~2,000 rows each, ~31 batches). Each batch is its **own short transaction** → tiny undo log, sub-second row locks, no long table lock that would block the live marks consoles.
3. **Index-friendly joins only.** Join on the raw indexed columns (`regno`, `courseid`) — **never wrap the join keys in `TRIM()`** (that was what made an earlier exploratory query hang: it disables the `Index_UNQ(courseid, regno)` index). The verified plan uses `idx_mark_stage` on the target and `Index_UNQ` on `acad_results` (≈1 matched row each).
4. **Deterministic** via a batch-scoped `MAX(score)` derived table (handles the 658 duplicate keys).
5. **Idempotent & resumable.** The `WHERE … CW IS NULL AND Exam IS NULL` guard means re-running a batch is a no-op; a crash mid-run can simply be re-run from the start.

### Phase 0 — Backup (once, fast, metadata-only clone of the affected slice)

```sql
-- lightweight backup of ONLY the columns/rows we will touch (both populations)
CREATE TABLE campus_dynamics_portal.bak_markbackfill_20260708 AS
SELECT id, regno, courseID, acad_year, semester,
       provisional_course_work_marks, provisional_exam_marks, provisional_total_marks,
       provisional_marks_status, mark_stage, publish_record_id, mark_stage_changed_at, mark_stage_changed_by
FROM   campus_dynamics_portal.acad_course_registration
WHERE (mark_stage='PUBLISHED' AND provisional_course_work_marks IS NULL AND provisional_exam_marks IS NULL)
   OR  id IN ( /* Population B ids, captured by the §6 selector */ );
```

### Phase 1 — Population A (fill components; stage already correct)

Run this in a loop, advancing `@lo` by 5,000 from 0 to 153,410:

```sql
-- @lo, @hi are the current batch window (@hi = @lo + 5000)
UPDATE campus_dynamics_portal.acad_course_registration cr
JOIN (
    SELECT ar.regno, ar.courseid, ar.acad, ar.semester, MAX(ar.score) AS score
    FROM   campus_dynamics.acad_results ar
    JOIN   campus_dynamics_portal.acad_course_registration c2
           ON c2.regno=ar.regno AND c2.courseID=ar.courseid
          AND c2.acad_year=ar.acad AND c2.semester=ar.semester
    WHERE  c2.mark_stage='PUBLISHED'
      AND  c2.provisional_course_work_marks IS NULL
      AND  c2.provisional_exam_marks IS NULL
      AND  c2.id >= @lo AND c2.id < @hi
      AND  ar.score IS NOT NULL
    GROUP BY ar.regno, ar.courseid, ar.acad, ar.semester   -- MAX(score) dedups the 658 dup keys
) best
  ON best.regno=cr.regno AND best.courseid=cr.courseID
 AND best.acad=cr.acad_year AND best.semester=cr.semester
SET cr.provisional_total_marks       = best.score,
    cr.provisional_course_work_marks = ROUND(best.score * 0.4),
    cr.provisional_exam_marks        = best.score - ROUND(best.score * 0.4)
WHERE cr.mark_stage='PUBLISHED'
  AND cr.provisional_course_work_marks IS NULL
  AND cr.provisional_exam_marks IS NULL
  AND cr.id >= @lo AND cr.id < @hi;
```

Between batches: optional `SELECT SLEEP(0.2)` to yield to live traffic. Expected total wall-time: a few minutes; peak memory: one 5k-id slice.

**Driver options (pick one):**
- A tiny stored procedure with a `WHILE` loop over the id windows (runs entirely in MySQL — zero app RAM), **or**
- a short shell/mysql loop (`for lo in $(seq 0 5000 153410)`) issuing one `UPDATE` per window, **or**
- a one-off admin page that loops the windows server-side. (Recommended: the stored-procedure or shell loop — no web request timeout risk.)

### Phase 2 — Population B (242 rows; advance stage, fill blanks only)

Small enough for single statements (no batching needed).

```sql
-- B-1: blank + mis-staged  → fill components AND advance to PUBLISHED
UPDATE campus_dynamics_portal.acad_course_registration cr
JOIN ( SELECT ar.regno, ar.courseid, ar.acad, ar.semester, MAX(ar.score) score
       FROM campus_dynamics.acad_results ar
       JOIN campus_dynamics_portal.acad_course_registration c2
         ON c2.regno=ar.regno AND c2.courseID=ar.courseid AND c2.acad_year=ar.acad AND c2.semester=ar.semester
       WHERE c2.mark_stage<>'PUBLISHED'
         AND c2.provisional_course_work_marks IS NULL AND c2.provisional_exam_marks IS NULL
         AND ar.score IS NOT NULL
       GROUP BY ar.regno, ar.courseid, ar.acad, ar.semester ) best
  ON best.regno=cr.regno AND best.courseid=cr.courseID AND best.acad=cr.acad_year AND best.semester=cr.semester
SET cr.provisional_total_marks=best.score,
    cr.provisional_course_work_marks=ROUND(best.score*0.4),
    cr.provisional_exam_marks=best.score-ROUND(best.score*0.4),
    cr.provisional_marks_status='published',
    cr.mark_stage='PUBLISHED',
    cr.publish_record_id=COALESCE(cr.publish_record_id,1),
    cr.mark_stage_changed_at=NOW(),
    cr.mark_stage_changed_by='migration-component-backfill-2026-07-08'
WHERE cr.mark_stage<>'PUBLISHED'
  AND cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL;

-- B-2: already has lecturer components, only the stage is stuck → advance stage ONLY (keep their marks)
UPDATE campus_dynamics_portal.acad_course_registration cr
SET cr.provisional_marks_status='published',
    cr.mark_stage='PUBLISHED',
    cr.publish_record_id=COALESCE(cr.publish_record_id,1),
    cr.mark_stage_changed_at=NOW(),
    cr.mark_stage_changed_by='migration-stage-fix-2026-07-08'
WHERE cr.mark_stage IN ('ENTERED','CAPTURED','APPROVED')
  AND cr.provisional_course_work_marks IS NOT NULL
  AND EXISTS (SELECT 1 FROM campus_dynamics.acad_results ar
              WHERE ar.regno=cr.regno AND ar.courseid=cr.courseID
                AND ar.acad=cr.acad_year AND ar.semester=cr.semester AND ar.score IS NOT NULL);
```

---

## 6. Verification (run before → after)

```sql
-- should fall to ~5 (the orphans) after Phase 1
SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration
WHERE mark_stage='PUBLISHED' AND provisional_course_work_marks IS NULL;

-- integrity: every backfilled row must satisfy CW+Exam = Total, CW≤40, Exam≤60
SELECT COUNT(*) AS broken FROM campus_dynamics_portal.acad_course_registration
WHERE provisional_course_work_marks IS NOT NULL
  AND ( provisional_course_work_marks+provisional_exam_marks <> provisional_total_marks
        OR provisional_course_work_marks>40 OR provisional_exam_marks>60 );   -- expect 0

-- consistency with the official ledger: total must equal acad_results.score
SELECT COUNT(*) AS mismatched
FROM campus_dynamics_portal.acad_course_registration cr
JOIN campus_dynamics.acad_results ar
  ON ar.regno=cr.regno AND ar.courseid=cr.courseID AND ar.acad=cr.acad_year AND ar.semester=cr.semester
WHERE cr.mark_stage_changed_by LIKE 'migration-%2026-07-08'
  AND cr.provisional_total_marks <> ar.score;   -- expect 0 (allowing MAX-dup rule)

-- Population B cleared
SELECT mark_stage, COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
WHERE mark_stage<>'PUBLISHED' AND EXISTS (SELECT 1 FROM campus_dynamics.acad_results ar
   WHERE ar.regno=cr.regno AND ar.courseid=cr.courseID AND ar.acad=cr.acad_year AND ar.semester=cr.semester AND ar.score IS NOT NULL)
GROUP BY mark_stage;   -- expect empty
```

## 7. Rollback

```sql
UPDATE campus_dynamics_portal.acad_course_registration cr
JOIN campus_dynamics_portal.bak_markbackfill_20260708 b ON b.id=cr.id
SET cr.provisional_course_work_marks=b.provisional_course_work_marks,
    cr.provisional_exam_marks=b.provisional_exam_marks,
    cr.provisional_total_marks=b.provisional_total_marks,
    cr.provisional_marks_status=b.provisional_marks_status,
    cr.mark_stage=b.mark_stage,
    cr.publish_record_id=b.publish_record_id,
    cr.mark_stage_changed_at=b.mark_stage_changed_at,
    cr.mark_stage_changed_by=b.mark_stage_changed_by;
```

---

## 8. Decisions / risks to confirm before running

- **D1 — Split ratio.** Default is **40 % CW / 60 % Exam** (matches the system's CW≤40 / Exam≤60 convention). If the registrar prefers a different notional split (e.g. 30/70), it's a one-line change. CW+Exam always equals the real score regardless.
- **D2 — Population B/ENTERED (91 rows) with existing lecturer marks.** Default: **advance the stage but keep their entered marks** (do not overwrite). If their entered total disagrees with the published `acad_results.score`, that's a pre-existing discrepancy we'll list separately rather than silently overwrite. Alternative on request: force-align them to the published score.
- **D3 — 5 orphans** (published, no source score): left untouched; listed for manual review.
- **D4 — Grades don't move.** We only write component numbers whose sum equals the existing published score, so any grade re-derived from the total is identical to the published grade. `acad_results` is never written.
- **Run window.** Batched + short locks make it safe during working hours, but running it off-peak is still preferable.

*Prepared from live data on 2026-07-08. Re-run the §3 counts immediately before executing, in case marks moved.*

---

## 9. Execution results (2026-07-08) ✅

Ran with **Decision D1 = 40/60 split** and **D2 = keep lecturer-entered marks (advance stage only)**. Backup taken first (`bak_markbackfill_20260708`, 68,309 rows).

| Step | Rows | Notes |
|---|---|---|
| **Phase 1** — Population A backfilled (batched, 5k-id windows) | **68,062** | components filled from `acad_results.score`; stage already PUBLISHED |
| **Orphan recovery** — 4 rows with a leading-space courseID (`' BAG2102B'`) matched via a *scoped* TRIM join (5 rows only → instant) | **4** | scores 77/76/80/86 |
| **Phase 2 B-1** — mis-staged + blank → filled + advanced to PUBLISHED | **146** | |
| **Phase 2 B-2** — mis-staged + lecturer marks → advanced stage only (marks kept) | **93** | |
| **Phase 2 B-3** — 3 leftover NOT_ENTERED rows with stray/partial components → aligned to published score + advanced | **3** | |
| **Total rows corrected** | **≈ 68,308** | |

**Final verification (all green):**
- Backfill-created integrity errors (CW+Exam≠Total / CW>40 / Exam>60): **0**.
- PUBLISHED rows now carrying components: **68,779** (of 68,780).
- Mis-staged rows still holding a published result: **0** (the "not-entered yet published" problem is gone).
- Every backfilled `provisional_total_marks` = the official `acad_results.score`; **no grade/GPA change** (`acad_results` untouched).

### 9.1 Final hardening pass (leaving no room for error)

A raw `col = col` join in MySQL ignores **trailing** spaces but **not leading** ones, so a second, TRIM-tolerant sweep was run to make sure nothing with a padded key was missed:

- **38** registration rows have a **leading-space courseID**; `acad_results` has **45** leading-space courseids (regno/acad are clean). All were audited with scoped TRIM matches (a handful of rows each → instant, no full-table TRIM scan).
- Result: **4** PUBLISHED-blank rows (`' BAG2102B'`) were the only real casualties — recovered above. The **11** non-published leading-space rows have **no** result even with TRIM (genuinely not-entered). The 45 padded results are either already-PUBLISHED or **historical rows with no registration row** (pre-portal transcripts — correctly out of scope).
- **Mis-staged left-outs after the TRIM sweep: 0** (both raw and padded).

**The last anomaly resolved:** `MRU2025003468 / BCE3103 / 2025/2026 S1` (id 117934) was PUBLISHED but had **no mark anywhere** — no `acad_results` row under any key, no components (the student has 5 other results; 229 other students have BCE3103 results, so it's this one enrolment that was never marked). A "published" mark with no score is itself a wrong stat, so it was **reverted to NOT_ENTERED** (its honest state — a current enrolment awaiting marks). `publish_record_id` cleared.

### 9.2 Verified end state (all zero)

| Check | Result |
|---|---|
| Published rows | **68,779** |
| Published rows **without** components | **0** ✅ |
| Backfill integrity errors (CW+Exam≠Total / CW>40 / Exam>60) | **0** ✅ |
| Mis-staged rows still holding a published result (raw) | **0** ✅ |
| Mis-staged rows via padded keys (TRIM) | **0** ✅ |

**Every published mark now carries a coursework + exam breakdown that sums exactly to its official `acad_results` score. Nothing published is left blank; nothing already-published is still showing as not-entered.**

**Left untouched (by design):**
- **3 discrepancy rows** (Population B, lecturer-entered total ≠ published score) — kept the lecturer's marks, advanced the stage, listed here for review:
  - `MRU2025002193 / ICT1108B / 2025/2026 S1` — entered 76 vs published 74
  - `MRU2023000887 / ADM3108B / 2025/2026 S1` — entered 84 vs published 68
  - `MRU2024002309 / DME2301D / 2025/2026 S3` — entered 77 vs published 73
- **1 pre-existing quirk** (unrelated to this task) — test student `MRU2027000002 / ADM1106B` (APPROVED, CW34+Exam57 but Total 89, entered by a real user); no published result, left as-is.

**Rollback** remains available via §7 against `bak_markbackfill_20260708`. Drop that backup table once the result is confirmed good in production.
