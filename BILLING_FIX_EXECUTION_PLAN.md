# Billing Correction — Deep Execution Plan (Overpaid Accounts ≥ +50,000)

**System:** Campus Dynamics ERP (Muteesa I Royal University)
**Databases:** `campus_dynamics` (academic), `campus_dynamics_accounts` (finance)
**Date:** 2026-06-24
**Goal:** Raise the missing bills that make ~1,846 active students *appear* overpaid, with **zero
double-billing, full accuracy, full traceability, and full reversibility.**
**Status:** PLAN — nothing is executed until each gate is signed off.

---

## 0. Scope, target & sizing (grounded in live data)

| Item | Value |
|------|------:|
| **Target cohort** | Active students with credit balance **≥ +50,000** (overpaid) |
| Cohort accounts | **1,846** |
| Apparent credit held | UGX **3,554,381,525** |
| Tuition bills to raise | **1,845** → UGX **1,114,430,000** |
| Functional bills to raise | **1,874** → UGX **1,236,990,300** |
| **Total bills to raise** | **~3,719** → UGX **~2,351,420,300** |
| Students affected | 1,846 |

**Rule per your instruction:** *semester status does not matter* — every semester for which a
student has a **registration row** is billable (UNREGISTERED, REGISTERED, LATE REGISTERED,
CLEARED). Only excluded automatically: invalid study-year/semester (outside 1–4 / 1–3) and
zero-fee items. `DEAD YEAR` (22 rows) and `DISCONTINUED` (1 row) are billed too unless you
choose to exclude them (a single config flag — see §3).

**Items billed:** Tuition (`item_code 1` → GL `AC6006`) + Functional (`item_code 52` → GL `AC6007`).
Accommodation is **out of scope** for this run (residence-dependent; separate pass).

---

## 1. What already exists (we build on proven infrastructure — do not reinvent)

The finance DB already contains a hardened billing stack we will reuse:

1. **`fin_TermlyItemBillingFN(...)`** — canonical billing function. Creates the tracking `Bill`
   row **and** the GL double-entry (student receivable DR + income account CR), with the
   standard wording, and is **idempotent** (returns `'Already Billed'` / `'Zero Amount'`).
2. **`fin_bill_uniqueness`** — helper table with `UNIQUE(regno, acadyear, semester, item_code)`
   for Bill records only.
3. **`trg_prevent_duplicate_bill`** — BEFORE-INSERT trigger on `fin_studentfeestracking` that
   makes a duplicate bill **physically impossible** (raises MySQL error 1062, aborts the insert).
4. **`trg_sync_bill_uniqueness_delete`** — AFTER-DELETE trigger keeping the helper table in sync
   (so a rollback automatically re-opens the slot).
5. Hidden, non-user-facing GL columns available for tagging: **`source_system`** (varchar 25,
   indexed) and **`RefNo`** (varchar 50). Neither appears on statements/receipts.

> **Consequence:** double-billing is already structurally prevented at the DB level. Our job is
> to feed the *correct* worklist into this stack, tag every row we create, and prove the result.

---

## 2. Design guarantees (the non-negotiables)

| Guarantee | How it is enforced |
|-----------|--------------------|
| **No double billing** | 4 independent layers (see §9): worklist excludes already-billed; function's atomic `INSERT … WHERE NOT EXISTS`; `fin_bill_uniqueness` UNIQUE; BEFORE-INSERT trigger. |
| **Correct amounts** | Amount comes only from `fin_programme_fees` (active) for the student's exact programme + study-year + semester. Zero/missing fees are skipped, never guessed. |
| **Consistent wording** | We call the **canonical** `fin_TermlyItemBillingFN`, so new bills are byte-for-byte identical in format to normal auto-bills (`"Tuition Fees Sem :{n}, {year}: {regno} [AUTO]"`). |
| **Hidden session tag** | Every created row is stamped `source_system='BILLFIX'` + the batch id in `RefNo` (GL) and a new `fix_batch_id` column (tracking) + a full **registry**. None of these surface to students. |
| **Full reversibility** | The registry stores the exact TIDs of every row created → one-command, exact rollback of an entire batch. |
| **Accuracy provable** | Phase 5 reconciliation gates (GL balanced, no duplicates, per-student delta = Σ bills) must PASS before the batch is accepted. |
| **No partial writes** | Each bill (tracking + 2 GL rows + tag + log) is one transactional unit; failure rolls back that unit and records it as `FAILED`. |
| **Resumable** | The registry marks each worklist line `PLANNED → APPLIED/SKIPPED/FAILED`; an interrupted run resumes without re-touching applied lines. |

---

## 3. Architecture

```
                 ┌─────────────────────────────────────────────┐
                 │ fin_billfix_batch   (one row per run)        │
                 │  batch_id, mode(DRYRUN/APPLIED/ROLLED_BACK), │
                 │  filter, counts, totals, created_by, ts      │
                 └─────────────────────────────────────────────┘
                                   │ 1
                                   │ N
   ┌──────────────────────────────▼───────────────────────────────────────┐
   │ fin_billfix_worklist (= staging + registry, one row per bill-to-make) │
   │  batch_id, regno, acadyear, semester, studyyear, item_code, amount,   │
   │  status(PLANNED/APPLIED/SKIPPED/FAILED/ROLLED_BACK),                   │
   │  tracking_tid, ledger_dr_tid, ledger_cr_tid,                          │
   │  balance_before, balance_after, reason, ts                            │
   └───────────────────────────────────────────────────────────────────────┘

   New nullable, hidden column:  fin_studentfeestracking.fix_batch_id VARCHAR(40) NULL
   GL tag on every created row:  fin_ledger.source_system='BILLFIX', RefNo=<batch_id>
```

**Why a staging+registry table:** it is simultaneously (a) the reviewed worklist before we
write anything, (b) the audit log of what we wrote, and (c) the rollback manifest. One artefact,
three jobs, zero ambiguity.

**Execution engine choice:** a dedicated, auditable procedure `fin_BillFix_Apply(batch_id)` that
iterates `fin_billfix_worklist` and, per line, calls the **canonical** `fin_TermlyItemBillingFN`,
then locates and tags the created rows and writes the registry. (Alternative: extend the existing
C# *Batch Fix Billing* wizard — same logic, nicer UI. Either way the candidate query is the change.)

---

## 4. PHASE 0 — Preparation & safety net *(no billing yet)*

1. **Maintenance window / freeze.** Run when payment posting and registration are quiet
   (overnight). Announce a short finance freeze.
2. **Backups (mandatory, verified):**
   ```sql
   CREATE TABLE bak_20260624_fin_ledger              AS SELECT * FROM fin_ledger;
   CREATE TABLE bak_20260624_fin_studentfeestracking AS SELECT * FROM fin_studentfeestracking;
   CREATE TABLE bak_20260624_fin_bill_uniqueness      AS SELECT * FROM fin_bill_uniqueness;
   -- verify row counts match source before proceeding
   ```
3. **Schema additions (additive, safe):**
   ```sql
   ALTER TABLE fin_studentfeestracking ADD COLUMN fix_batch_id VARCHAR(40) NULL;   -- hidden
   CREATE TABLE fin_billfix_batch    ( ... as §3 ... );
   CREATE TABLE fin_billfix_worklist ( ... as §3 ... , 
        UNIQUE KEY unq_line (batch_id, regno, acadyear, semester, item_code) );
   ```
   *All additive; existing INSERTs name columns explicitly, so nothing breaks.*
4. **Confirm the guard rails are live:** verify `fin_bill_uniqueness`, both triggers, and that
   `fin_TermlyItemBillingFN` is the duplicate-safe version (it is, per `migration_prevent_duplicate_billing.sql`).
5. **Snapshot balances** of all 1,846 cohort students into the batch row (`balance_before`).

**Gate 0:** backups verified + schema applied on a staging copy first → sign off.

---

## 5. PHASE 1 — Build & validate the worklist *(read-only)*

Populate `fin_billfix_worklist` (status `PLANNED`) from the candidate query — **every enrolled
semester-item for the cohort that is not yet billed and has a positive fee**:

```sql
INSERT INTO fin_billfix_worklist (batch_id, regno, acadyear, semester, studyyear, item_code, amount, status)
SELECT @batch, w.regno, w.acad_year, w.semester, w.studyyear, w.item_code, w.fee, 'PLANNED'
FROM (
  /* distinct enrolled periods for the cohort × {tuition, functional}, with the fee resolved
     from fin_programme_fees by (progid, studyyear, semester), excluding already-billed and zero-fee */
) w;
```

**Validation report (must be reviewed before anything is written):**
- Bills by item, by programme, by academic year; totals (expect ≈ 1,845 / 1,874 / 2.35B).
- **Fee-coverage check:** list any programme with `is_active='Yes'` missing or zero fees for a
  needed (year, sem) → those lines are **excluded** and listed for manual fee-structure fixing.
- **Sanity checks:** study-year ∈ 1..4, semester ∈ 1..3, amount > 0, programme exists, fee row exists.
- **Programme-change check:** flag students whose `progid` differs from the programme implied by
  historic registration (fee could be wrong) → hold for review.
- **DEAD YEAR / DISCONTINUED** lines listed separately with an include/exclude toggle.

**Gate 1:** finance reviews the worklist totals & exclusions → sign off.

---

## 6. PHASE 2 — Dry-run / shadow billing *(projected impact, still no writes)*

Compute, **without writing any bill**, each student's projected balance:
`balance_after = corrected_paid − (already_billed + Σ planned bills)` and write it to the worklist.

Deliverables for finance:
- Per-student before/after balance; counts of accounts that **flip to owing**, **clear**, or
  **remain in credit** after billing.
- A CSV of the full worklist (every bill that *would* be created, with amount and new balance).
- Top-impact students for manual spot-check (e.g., the Gidah case: +7.59M → ≈ −1.6M owing).

**Gate 2:** projected outcome accepted → authorise a canary run.

---

## 7. PHASE 3 — Canary execution *(tiny, fully verified)*

- Apply the batch for a **small, representative sample (e.g. 20 students)** only.
- Run the full Phase-5 reconciliation on the sample.
- **Manually verify 3–5 students** end-to-end: tracking Bill created once, GL DR=CR, balance
  delta exactly equals Σ bills, wording identical to existing auto-bills, hidden tags present,
  nothing visible to the student changed except the (correct) new bill.
- **Benchmark performance** (the canonical function recomputes ledger balances per call — confirm
  throughput; if too slow, switch to the batch variant that defers
  `fin_UpdateAllLedgerBalances()` to a single call at the end — equivalence proven on the canary).

**Gate 3:** canary clean → proceed to full run. If anything is off, **roll back the canary**
(Phase rollback) and fix before continuing.

---

## 8. PHASE 4 — Full controlled execution

`CALL fin_BillFix_Apply(@batch)` processes each `PLANNED` line:

```
FOR each worklist line (ordered by regno):
  START TRANSACTION
    result := fin_TermlyItemBillingFN('REG', regno, item_code, semester, progid,
                                      session, T_Date, user, studyyear, acadyear,
                                      'AUTO', amount);     -- canonical wording + GL + idempotent
    IF result = '1 Bill' THEN
        tracking_tid := (SELECT TID FROM fin_studentfeestracking
                         WHERE regno,acadyear,semester,item_code, trans_type='Bill');   -- unique
        UPDATE fin_studentfeestracking SET fix_batch_id=@batch WHERE TID=tracking_tid;
        UPDATE fin_ledger SET source_system='BILLFIX', RefNo=@batch
               WHERE folio = CONCAT('BillNo:', tracking_tid);                            -- DR + CR
        record ledger_dr_tid, ledger_cr_tid; status='APPLIED'
    ELSIF result IN ('Already Billed','Zero Amount') THEN status='SKIPPED'; reason=result
    END IF
  COMMIT  (per-line; on exception → ROLLBACK this line, status='FAILED', reason=SQLSTATE)
```

Properties:
- **Idempotent & resumable** — only `PLANNED` lines are processed; re-running is safe.
- **Per-line atomicity** — a failure never leaves a half-written bill.
- **Every created row carries the hidden batch tag** and is recorded in the registry.
- Update the batch row with final counts/totals and set `mode='APPLIED'`.

---

## 9. Why double-billing is impossible (defense-in-depth)

| Layer | Mechanism | Catches |
|------:|-----------|---------|
| 1 | Worklist excludes any (regno, year, sem, item) that already has a Bill | 99%+ up front |
| 2 | `fin_TermlyItemBillingFN`: atomic `INSERT … SELECT … WHERE NOT EXISTS` | race within a run |
| 3 | `fin_bill_uniqueness` UNIQUE(regno, acadyear, semester, item_code) | any pathway, ever |
| 4 | `trg_prevent_duplicate_bill` BEFORE INSERT → error 1062 aborts | 100% race-proof |
| 5 | Registry UNIQUE(batch, regno, year, sem, item) | re-processing the same line |

Even a deliberate attempt to bill twice fails at layer 3/4 with a hard DB error.

---

## 10. PHASE 5 — Reconciliation & verification gates *(must all PASS)*

Run automatically after the full batch; **any FAIL halts acceptance**:

1. **GL balanced:** `Σ(DR) = Σ(CR)` for `source_system='BILLFIX'` rows of this batch.
2. **No duplicate bills:** zero `(regno, acadyear, semester, item_code)` with >1 Bill (whole table).
3. **Per-student delta:** for each student, `new_total_billed − old_total_billed = Σ(this batch's bills)`.
4. **Tag completeness:** every `fin_billfix_worklist.status='APPLIED'` line has a non-null
   `tracking_tid`, `ledger_dr_tid`, `ledger_cr_tid`; every created GL row has `source_system='BILLFIX'`.
5. **Amount integrity:** each created bill amount = the fee-structure value (re-derived independently).
6. **No orphans:** every created tracking Bill has exactly one matching GL DR and one income CR.
7. **Cohort recount:** number of accounts still in credit ≥ +50,000 dropped as projected in Phase 2.

**Gate 5:** all checks PASS → batch accepted and finance signs the reconciliation report.

---

## 11. PHASE 6 — Fix the payment double-count *(separate, non-destructive — restores true balances)*

Billing alone removes ~2.35B of the phantom credit; the remaining ~1.2B is **double-counted
payments** (a measurement bug, not bad data): the same payment exists in both `fin_ledger` (CR)
and `fin_studentfeestracking` (Payment), and the balance dedup fails when the ledger particulars
(old rows = student name) differ from the tracking detail ("Fees Payment … Airtel Money").

**Fix (code-only, touches no transaction):** in the dual-source dedup
(`FinanceEngine.DUAL_LEDGER_SQL` / `ComputePeriodBalance`, the StudentLedgers cache rebuild,
`ComputeStudentBalance`, `AjaxLedgerDetails`), match a tracking payment to a ledger CR on
**(regno + amount + date)** paired **1:1**, *without* requiring particulars equality.
Guard: pair duplicates one-to-one so two genuine identical same-day payments are never collapsed.

This is independent of billing and can run before or after it; doing it makes the **final**
balances true. (Optional data cleanup later: standardise historic payment particulars so the two
stores always reconcile.)

**Gate 6:** balances recomputed; the student account & fees statement now show the true position.

---

## 12. PHASE 7 — Handle the genuine credits

After Phases 4 + 6, re-run the overpaid query. The list collapses to the **truly** overpaid
students. Only these — verified individually against receipts — are routed to the
refund / credit-forward process. **No refund is ever based on pre-correction numbers.**

---

## 13. PHASE 8 — Prevent recurrence

1. **Scheduled reconciliation sweep** (nightly/weekly): bill any enrolled, unbilled semester
   automatically — closes the "missed registration event" gap permanently. Reuses the same
   worklist logic and the same idempotent function, so it can never double-bill.
2. **Standardise payment particulars at posting** so `fin_ledger` and `fin_studentfeestracking`
   always reconcile (kills root-cause B at the source for all future payments).
3. **Make billing independent of registration status** going forward (or guarantee
   `fin_AutoBillOnRegistration` is always fired), per your rule that enrolment = billable.

---

## 14. Rollback procedure (any batch, exact)

Because every created row is recorded in `fin_billfix_worklist` with its TIDs:

```sql
-- 1. Delete GL rows created by the batch (DR + CR)
DELETE FROM fin_ledger
WHERE source_system='BILLFIX' AND RefNo=@batch;            -- or by the recorded ledger TIDs

-- 2. Delete the tracking Bill rows created by the batch
DELETE FROM fin_studentfeestracking WHERE fix_batch_id=@batch;
--    → trg_sync_bill_uniqueness_delete auto-frees fin_bill_uniqueness slots

-- 3. Recompute ledger balances + mark batch
CALL fin_UpdateAllLedgerBalances();
UPDATE fin_billfix_batch SET mode='ROLLED_BACK' WHERE batch_id=@batch;
```

Deterministic, complete, and leaves the system exactly as before the batch. Backups from
Phase 0 are the ultimate fallback.

---

## 15. Hidden session-tag specification (traceability, not shown to students)

| Object | Field | Value | Visible to student? |
|--------|-------|-------|---------------------|
| `fin_studentfeestracking` (Bill) | `fix_batch_id` | `BILLFIX-2026-06-24-01` | No (not on any statement/receipt) |
| `fin_ledger` (DR + CR) | `source_system` | `BILLFIX` | No |
| `fin_ledger` (DR + CR) | `RefNo` | `BILLFIX-2026-06-24-01` | No |
| `fin_billfix_worklist` | full row | TIDs + before/after | No (internal registry) |
| `detail` / `particulars` (visible) | wording | identical to normal auto-bills | Yes — intentionally consistent |

Anytime later, every fix-created transaction is found instantly via
`source_system='BILLFIX'` or `fix_batch_id=...`.

---

## 16. Edge cases & handling

| Case | Handling |
|------|----------|
| Bill already exists (tracking or GL orphan DR) | Skipped — layer 1 + function returns `Already Billed` |
| Fee = 0 for that (year, sem) | Skipped (legitimately no charge) |
| Programme has no active fee row | Excluded + listed for fee-structure fix (never guessed) |
| Study-year > 4 / invalid semester | Excluded + flagged |
| Duplicate registration rows same semester | Collapsed via `DISTINCT (regno, year, sem, studyyear)` |
| Student changed programme | Flagged (fee may differ) → manual review before billing |
| Existing waivers (credit CRs) | Untouched; the new bill correctly nets against them |
| DEAD YEAR / DISCONTINUED | Billed only if the include-toggle is on; else listed |
| Accommodation fees | Out of scope this run (separate residence-based pass) |
| Interruption mid-run | Resume — only `PLANNED` lines reprocessed |

---

## 17. Acceptance criteria (sign-off gates summary)

| Gate | Phase | Pass condition |
|-----:|-------|----------------|
| 0 | Prep | Backups verified, schema applied on staging |
| 1 | Worklist | Totals ≈ 3,719 bills / 2.35B; exclusions reviewed |
| 2 | Dry-run | Projected balances accepted |
| 3 | Canary | 20 students clean + manually verified |
| 5 | Reconcile | All 7 reconciliation checks PASS |
| 6 | Dedup | Final balances true (no double-counted payments) |
| 7 | Credits | Only genuine credits routed to refunds |

---

## 18. Recommended execution order

1. Phase 0 → 1 → 2 (read-only; produce worklist + dry-run CSV for finance).
2. **Sign-off.**
3. Phase 3 canary → verify → Phase 4 full run → Phase 5 reconcile.
4. Phase 6 dedup fix (can run in parallel with billing review).
5. Phase 7 genuine-credit handling.
6. Phase 8 recurrence prevention.

> Nothing financial is written before Gate 2. Every write is tagged, logged, and reversible.
> Double-billing is structurally impossible. Amounts come only from the official fee structure.
