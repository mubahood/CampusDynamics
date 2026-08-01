# Re-billing Fix — Reversed-but-Registered Semesters (2026-07-10)

**Status:** ✅ EXECUTED & VERIFIED on the live `campus_dynamics_accounts`. Fully tracked and reversible.

## The problem (recap)
When a student's semester fee was **billed → reversed in the GL → never re-raised**, and the student is **registered** for that semester, the (already-paid) money shows as a phantom **overpaid credit**. Root case: `MRU2024001135` — Sem2 2025/2026 fee (3,023,000) was self-billed (Oct-2025), reversed by the Bursar (Nov-2025, before the student had actually registered for Sem2), then the student registered for Sem2 later and no bill was re-raised.

## What was fixed
- Cohort: **45 students / 91 fee lines / UGX 65,270,400** — every case where a fee was **reversed to net-zero** in the GL for a semester the student is **REGISTERED** for. Over-reversed anomalies were **excluded** (see below).
- **Method:** an additive **re-instatement DR** per reversed fee line (source_system `REBILL_FIX_20260710`, RefNo `REBILL-2026-07-10`), which cancels the erroneous reversal and restores the exact original charge. No existing rows deleted; fee amounts taken from the *actual reversed amounts* (the fee structure can't re-derive them — `fin_GetProgrammeFee` returns 0 for several programme/years).
- Why not re-bill via `fin_BillProgrammeFees`? The original tracking Bill rows are still present (the `trg_prevent_duplicate_bill` guard would block a fresh bill), and the fee re-derivation is unreliable. The reversal only ever hit the GL, so re-instating in the GL is exact.

## Tested on SABIA first (MRU2027000002)
Full end-to-end before touching real data: baseline **2,296,500** → bill (+1,000,000) **3,296,500** → reverse **2,296,500** → **apply fix → 3,296,500 (exact, no double-count)** → cleanup → **2,296,500** (zero leftover). The fix method sums exactly.

## Verification (all green)
- **0 mismatches** across all 45: every student's balance moved by exactly the restored amount.
- Balance cache updated; **cache == live `fin_GetCanonicalStudentBalance` for all 45 (0 mismatches)**.
- Headline: `MRU2024001135` −3,020,700 (phantom overpaid) → **+2,300 (owes 2,300, i.e. paid up)**. `total_billed 19,548,400 − total_paid 19,546,100 = 2,300`.
- Cohort after fix: **39 now owing, 2 exactly zero, 4 with a genuine remaining credit** (real pre-payment beyond all their bills). The phantom credit is gone.

## Tracking / rollback artifacts (campus_dynamics_accounts)
| Object | Purpose |
|---|---|
| `fin_rebillfix_20260710` | registry: one row per re-instated fee line (reversal_tid, regno, ay, sem, amount) |
| `fin_rebillfix_20260710_before` | pre-fix canonical balance per student |
| `fin_ledger … source_system='REBILL_FIX_20260710'` | the 91 posted re-instatement DRs |
| `fin_billing_gap_log` | prevention log |
| `fin_ReconcileRegisteredBilling` | prevention procedure |

**Rollback (if ever needed):**
```sql
DELETE FROM fin_ledger WHERE source_system='REBILL_FIX_20260710';
UPDATE fin_student_balance_cache c JOIN fin_rebillfix_20260710_before b ON b.regno=c.regno
  SET c.total_balance = -b.before_bal;   -- restore prior balance (canonical = billed-paid; cache = paid-billed)
-- then a normal cache rebuild reconciles total_billed/total_paid
```

## Second fix — orphaned GL reversals (5 students)
A distinct defect surfaced in the "over-reversed" set: a bill posted to **tracking only** (never to the GL), then **reversed in the GL**. The reversal shares the bill's `folio` (`BillNo:xxxxx`), so it (a) **de-dupes the real tracking bill out of the balance** and (b) is itself **counted as a payment** — a double phantom credit. This can't be fixed additively; the orphaned reversal must be **removed** (which un-dupes the tracking bill and drops the phantom payment).
- **5 students / 10 orphaned reversal rows removed** (all `EXISTS` a real tracking Bill + `NOT EXISTS` any GL bill for that semester): `MRU2023000636`, `MRU2024000048`, `MRU2024001971`, `MRU2023001367`, `MRU2024001723`. Each flipped from a large phantom credit to correctly owing (e.g. MRU2024001723 −3,041,000 → −63,000; MRU2023000636 −2,105,000 → +541,000 owing). Deleted rows **auto-archived to `fin_deleted_ledger`** (10 rows, recoverable) + registry `fin_orphanrev_20260710`. Cache reconciled to live (0 mismatches).
- ⚠️ **`fin_ledger` is MyISAM** — transactions/ROLLBACK do NOT apply to it. (Consequence: a `START TRANSACTION … ROLLBACK` "dry run" against `fin_ledger` persists. All fixes here were done as real, tagged, archived writes; the SABIA test used explicit insert+delete cleanup, not rollback.)

## Left for manual review (NOT auto-fixed) — 3 students
Genuinely ambiguous; need a bursar decision (still showing a credit):
- `MRU2022000198` (+278,000) — **double reversal** with mismatched amounts (1 bill 630,000 vs 2 reversals 730,000+630,000).
- `MRU2023000256` (+424,000) — already has a partial **"Reversal of Reversal"** DR; mixed Term/Semester billing.
- `MRU2023000302` (+729,000) — orphaned reversal but the student is **not registered** for that (2023/2024) semester.

---

## Prevention — "a registered student can't silently miss a bill"

**1. `fin_ReconcileRegisteredBilling(p_apply)`** (installed; `COOPERP/sql/fin_ReconcileRegisteredBilling.sql`).
- `CALL fin_ReconcileRegisteredBilling(0)` — **report only**: logs every registered semester whose fee was reversed-to-zero into `fin_billing_gap_log`. Returns 0 today (cohort fixed).
- `CALL fin_ReconcileRegisteredBilling(1)` — **fix**: also posts re-instatement DRs (`source_system='REBILL_RECON'`).
- Idempotent (a restored semester's net is no longer 0 → not re-detected). **Recommended: schedule nightly in report mode**, review the log, run fix mode when confirmed (or wire it behind an approval button in Fee Administration).

**2. Guard the reversal action (code — recommend).** In the Bursar's fee-reversal UI, warn/block reversing a fee for a semester the student is currently `REGISTERED` for, requiring an explicit reason + a "re-bill / don't re-bill" decision — so a live charge can't be silently stripped.

**3. Fix self-service billing (code — recommend).** The portal semester-registration wizard let the student bill **Sem 2 before Sem 1** (the original mis-bill). It should only bill the **current/registered** semester, in order, never an arbitrary future one.

**4. (Broader, separate) never-billed sweep.** Beyond reversals, ~14,786 registered-but-unbilled semesters exist system-wide (billing is event-driven, no reconciliation). A periodic bill-on-registration reconciliation would close that gap too — larger project, tracked separately.
