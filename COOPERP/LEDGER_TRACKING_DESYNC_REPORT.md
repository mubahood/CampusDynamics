# Ledger ↔ Tracking Desync — Diagnosis & Repair Plan

**Date:** 2026-07-30
**Trigger:** MRU2024001579 (and many others) show UNREGISTERED / "unbilled" for 2026/2027 and cannot be billed by any backfill or by `BillingReconciliation.aspx`.

---

## 1. Root cause (definitive)

Billing writes each fee to **two tables** inside `fin_TermlyItemBillingFN`:

1. `INSERT INTO fin_studentfeestracking (…)` — **InnoDB (transactional)**
2. then `fin_TransactionCreatorFn2(…)` writes the `fin_ledger` mirror (`folio='BillNo:<trackingTID>'`) — **MyISAM (non-transactional, auto-commits, irreversible)**

When a billing call is **interrupted** — client/command timeout, killed connection, lock-wait/deadlock — **after** the MyISAM ledger row has committed but **before** the InnoDB tracking transaction commits, the tracking insert **rolls back while the ledger row survives**. Proof: the absent `tracking_ref` TIDs are permanent auto-increment holes (InnoDB does not reuse a rolled-back auto-increment value), and the surviving ledger rows carry `source_system='Billing'` with `BillNo:<missingTID>`.

**Result — a "ghost bill":** the fee exists in `fin_ledger` but not in `fin_studentfeestracking`.

### Why this breaks everything downstream
- Every "is this student billed?" check — `BillingReconciliation`, the reconcile sweep, dashboards, fee statements — reads **`fin_studentfeestracking`** → sees no bill → reports the student **unbilled** and flags them as a reconciliation candidate.
- The billing engine's anti-duplicate guard (`fin_TermlyItemBillingFN`) reads **`fin_ledger`** → `existingLedger > 0` → returns **`'Already In Ledger'`** and refuses to (re)create the bill.
- Net: the student is **shown unbilled but is un-billable** — a permanent deadlock. This is exactly why "run the backfill and it still won't bill."

It is **ongoing**: every interrupted billing run (the SP takes ~15–20s per student due to non-sargable `fin_ledger` `LIKE` dup-scans on a large MyISAM table, so interruptions are common) mints new ghosts.

---

## 2. Scale

Ghost = `fin_ledger` DR student bill (`folio LIKE 'BillNo:%'`, `tracking_ref>0`) whose `tracking_ref` is **absent** from `fin_studentfeestracking`.

| Academic year | Ghost rows | Students | Amount |
|---|---|---|---|
| 2022/2023 | 14 | 7 | 5,545,000 |
| 2023/2024 | 123 | 62 | 51,172,650 |
| 2024/2025 | 302 | 124 | 157,272,000 |
| 2025/2026 | 112 | 58 | 74,328,700 |
| 2026/2027 | 12 | 7 | 12,127,750 |
| **Total** | **563** | **248 (distinct)** | **≈300,445,000** |

---

## 3. Repair classification (per ghost)

| Verdict | Rows | Students | Meaning & action |
|---|---|---|---|
| **RECREATE_TRACKING** | 37 | 22 | No tracking bill for the cell **and** student is REGISTERED for the period → the bill is legitimate but its tracking row was lost. **Recreate** the tracking row (reuse the hole TID so `folio='BillNo:TID'` linkage is restored). |
| **DELETE_LEDGER** (pure-dup) | 291 | 118 | A valid tracking bill for the cell **already has its own ledger DR**. The ghost is an **extra** GL debit (the student was re-billed after the interrupted attempt) → **delete** the ghost ledger row. |
| **RELINK_LEDGER** (split-lineage) | 220 | 114 | A valid tracking bill exists but has **no** ledger DR of its own. The ghost **is** that bill's ledger entry → **repoint** the ghost (`folio`/`tracking_ref` → the valid tracking TID), do **not** delete. |
| **REVIEW_NOREG** | 14 | 7 | No tracking **and** no valid registration for the period → possibly a bill for a deleted semester or an intended reversal. **Manual review.** |
| **REVIEW_ITEM** | 1 | 1 | Item code couldn't be resolved. Manual. |

> Counts are per ledger row. `DELETE_LEDGER`/`RELINK_LEDGER` were split by whether the valid tracking bill already carries a ledger DR.

### ⚠ Must be repaired at the FEE-CELL level, not per row
Some fee cells `(regno, acadyear, semester, item_code)` have **multiple** orphaned ledger bills (e.g. **MRU2024000256**, 2024/2025 S1 has two tuition + two function ghosts). Recreating tracking for each ghost would **double-bill**. The repair must, per cell, converge to the target invariant:

> **Exactly one tracking Bill row and exactly one ledger DR, linked by `folio='BillNo:<trackingTID>'`.**

Per cell: keep one complete pair; recreate a tracking row only if none exists; relink an orphan ledger to a track-only bill; delete every surplus ghost ledger. This is why a blind per-row script is unsafe.

---

## 4. Prevention (stop new ghosts)

The desync will keep regenerating until the write path is made resilient. Options, best first:

1. **Self-healing dup-check (smallest, targeted).** In `fin_TermlyItemBillingFN`, change the `existingLedger > 0` branch: instead of unconditionally returning `'Already In Ledger'`, when `existingBill = 0` (tracking missing) **recreate the tracking row linked to the existing ledger and return success**, rather than skipping. This makes the very next billing attempt self-repair a ghost and removes the deadlock — no schema change.
2. **Make `fin_ledger` transactional (InnoDB).** Then an interrupted billing call rolls back *both* sides atomically and no ghost can form. Correct but heavy (large MyISAM table; test balance/reporting code that may rely on MyISAM behaviour; schedule downtime).
3. **Operational mitigation now.** Never run billing SPs with a short client timeout — a client timeout does **not** stop the SP server-side (it keeps running and can commit the MyISAM half). Run billing in the background / with generous timeouts. (This session's own timed-out billing loops created several of the 2026/2027 ghosts.)

---

## 5. Related student-billing findings (same investigation)

For 2026/2027 Sem 1, 405 UNREGISTERED = 384 alumni (correctly skipped) + 21 active/admitted. Those 21:
- **12 beyond-programme finalists** (BCE/BEE year 5, BIT year 4) — rolled past programme end; `fin_GetProgrammeFee` has no such year → impossible to bill; should be **graduated** (incl. MRU2024001579).
- **3 ledger-desync** (this report): MRU2024001338, 2024001573, 2025002137.
- **5 admitted no-shows** (never enrolled year 1).

See memory `unbillable-unregistered-root-causes` and `wizard-finalise-billing-perf`.

---

## 6. Status

- Analysis materialised in `campus_dynamics_accounts.zz_ghost_bills` (563 rows, classified).
- **No repair writes have been applied** — the fee-cell dedup requirement (multi-ghost cells) and the 300M financial scope require finance sign-off + staged, monitored execution (a mid-run timeout would spawn *more* ghosts).
- Repair script: `COOPERP/sql/ledger_tracking_desync_repair.sql` (preview-first, backed up, fee-cell aware).
