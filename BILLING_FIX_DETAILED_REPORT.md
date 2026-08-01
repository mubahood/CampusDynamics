# Billing Correction — Detailed Report (Accounts Affected & Transactions Created)

**Batch:** `BILLFIX-2026-06-24-01`
**Finance database:** `campus_dynamics_accounts` (live) · academic data: `campus_dynamics`
**Executed:** 2026-06-24 (billing run **02:25:27 → 02:52:51**, ~27 min)
**Status:** ✅ Applied · reconciled · verified · reversible
**This report verified against the live database on 2026-06-25** (read-only).

---

## 1. Executive summary

Active students appeared **overpaid by ~UGX 3.5 billion**. That credit was **phantom**, caused by two independent defects:

| # | Root cause | Magnitude | Nature |
|---|------------|----------:|--------|
| **A** | **Bills never raised** for enrolled/paid semesters (billing only fires on `REGISTERED`/`LATE REGISTERED`; 14,786 semesters were `UNREGISTERED`, with no reconciliation sweep) | **~2.06 B** | Real — data missing |
| **B** | **Payments double-counted** in the balance formula (dual-source dedup `fin_ledger`+`fin_studentfeestracking` fails when old ledger particulars = student name, not "Fees Payment …") | **~3.30 B** | Measurement bug |

The fix raised the missing bills (**Fix A — data**) and stopped the double-count (**Fix B — code**). Apparent active credit collapsed **~3.5 B → ~265 M (≈92%)**, and the cohort is now correctly **net owing**. **No money was refunded; no balance was invented.**

---

## 2. The two fixes

### Fix A — raised the missing bills (data)
Billed every **registered semester** (any registration status, **study-years 1–3**) for **active students whose displayed credit ≥ +50,000**, via the **canonical** billing path — identical wording & GL to the FeesStructure "Process Billing":

- Fee resolved by `fin_GetProgrammeFee` → the **active** `fin_programme_fees` row (`y{yr}_s{sem}_tuition` = item 1, `_functional` = item 52).
- Bills written by `fin_BillProgrammeFees → fin_TermlyItemBillingFN` (idempotent — returns *Already Billed* / *Zero Amount*).
- Driver: `fin_BillFix_Apply(batch_id)`, iterating the reviewed worklist line-by-line in per-bill transactions.

### Fix B — corrected the payment double-count (code)
Waived the **particulars-equality** match **for payments only** (bills keep the strict match) in **5** balance computations:

- `COOPERP/NewScreens/StudentLedgers.aspx.cs` → `GetBalanceCacheRebuildSql`, `ComputeStudentBalance`, `AjaxLedgerDetails`
- `App_Code/FinanceEngine.cs` → `DUAL_LEDGER_SQL`, `ComputePeriodBalance`

*(4 other consumers — BillWaivers, DoubleBillingController, FeesTransactions, StudentLedgerExport — were intentionally left for separate review.)*

---

## 3. Accounts affected

| Metric | Value |
|---|---:|
| **Students billed** | **897** |
| Of which left **owing** after billing (at run) | 93 |
| Of which **cleared** (±50k) after billing (at run) | 15 |
| Of which **still in credit** after billing (at run) | 797 |

> "At run" = effect of **billing alone** (Fix A), as captured in the registry using the pre-Fix-B balance. The remaining credit was then removed by Fix B (the double-count). See §6 for the **current** live picture.

### 3.1 Bills per student (897 students)

| Bills raised | Students |
|---:|---:|
| 1 | 5 |
| 2 | 268 |
| 3 | 20 |
| 4 | 412 |
| 5 | 4 |
| 6 | 106 |
| 7 | 2 |
| 8 | 36 |
| 10 | 20 |
| 11 | 2 |
| 12 | 16 |
| 14 | 5 |
| 18 | 1 |

### 3.2 Top 12 programmes by amount billed

| Prog | Programme | Students | Bills | Amount (UGX) |
|---|---|---:|---:|---:|
| BAED | Bachelor of Arts with Education | 117 | 489 | 332,230,000 |
| BEICT | Bachelor of Education with ICT | 80 | 345 | 243,514,000 |
| BSAF | BSc Accounting and Finance | 73 | 289 | 194,659,000 |
| BIT | Bachelor of Information Technology | 63 | 248 | 193,707,000 |
| BBA | Bachelor of Business Administration | 61 | 270 | 183,610,000 |
| BCE | BSc Civil Engineering | 25 | 96 | 135,850,000 |
| BEE | BSc Electrical Engineering | 23 | 78 | 110,616,000 |
| BED(P) | Bachelor of Education (Primary) | 100 | 480 | 106,500,000 |
| BMC | Bachelor of Mass Communication | 28 | 120 | 97,616,000 |
| SWSA | Bachelor of Social Work & Social Admin | 31 | 134 | 95,645,000 |
| BTHM | Bachelor of Tourism & Hotel Management | 24 | 89 | 79,024,500 |
| DPE | Diploma in Primary Education | 63 | 230 | 49,330,000 |

### 3.3 Top 15 affected accounts (by amount billed)

`bal_*_run` = balance before/after at run-time (billing effect only; "+" = credit, "−" = owing).

| Reg No | Bills | Billed (UGX) | Bal before | Bal after |
|---|---:|---:|---:|---:|
| MRU2021000667 | 11 | 15,585,000 | 4,070,000 | 2,582,000 |
| MRU2021000077 | 8 | 11,416,000 | 3,690,000 | 2,202,000 |
| MRU2022000100 | 8 | 11,344,000 | 5,232,000 | 3,744,000 |
| MRU2020000404 | 12 | 10,069,500 | 2,363,500 | 1,292,250 |
| MRU2020000717 | 12 | 10,069,500 | 160,000 | −911,250 |
| MRU2021000163 | 12 | 9,980,000 | 925,500 | −127,500 |
| MRU2021000091 | 14 | 9,747,000 | 515,400 | −417,600 |
| MRU2022000198 | 11 | 9,339,500 | 278,000 | −793,250 |
| MRU2020000604 | 12 | 8,660,000 | 150,000 | −783,000 |
| MRU2021000307 | 12 | 8,660,000 | 805,000 | −128,000 |
| MRU2021001213 | 6 | 8,473,000 | 6,025,000 | 4,537,000 |
| MRU2022000612 | 6 | 8,473,000 | 4,446,000 | 2,958,000 |
| MRU2022000590 | 6 | 8,473,000 | 4,441,000 | 2,953,000 |
| MRU2021000137 | 12 | 8,360,000 | 880,000 | −53,000 |
| MRU2021000614 | 12 | 8,360,000 | 1,310,000 | 433,000 |

> The **full per-account list** (all 897 students, every bill, before/after balances and the exact TIDs) lives in the registry table `fin_billfix_worklist` and in `BILLFIX-2026-06-24_dryrun_by_student.csv` / `BILLFIX-2026-06-24_worklist.csv`.

**Worked example — Gidah Nazziwa (`MRU2024002021`):** shown as **+7,589,500 overpaid** → 4 missing bills (UGX 4,876,000) raised + double-counted payment removed → **true balance +838,000** (small genuine credit). *Confirmed live: billed 7,294,000 / paid 8,132,000 / balance +838,000.*

---

## 4. Transactions created

| Object | Rows | Amount (UGX) |
|---|---:|---:|
| Tracking **Bill** rows (`fin_studentfeestracking`, `fix_batch_id`) | **3,709** | 2,336,845,300 |
| GL **DR** rows (student receivable, `source_system='BILLFIX'`) | 3,709 | 2,336,845,300 |
| GL **CR** rows (income accounts, `source_system='BILLFIX'`) | 3,709 | 2,336,845,300 |
| **Total financial rows created** | **11,127** | — |
| Registry rows (`fin_billfix_worklist`, status=APPLIED) | 3,709 | 2,336,845,300 |
| Failed / skipped | **0** | — |

**GL is balanced: DR 2,336,845,300 = CR 2,336,845,300 (net 0).**

### 4.1 By fee item

| Item | Type | Bills | Amount (UGX) |
|---|---|---:|---:|
| 1 | Tuition | 1,840 | 1,107,155,000 |
| 52 | Functional | 1,869 | 1,229,690,300 |
| | **Total** | **3,709** | **2,336,845,300** |

### 4.2 By academic year

| Academic year | Bills | Amount (UGX) |
|---|---:|---:|
| 2019/2020 | 18 | 9,960,500 |
| 2020/2021 | 22 | 13,779,250 |
| 2021/2022 | 96 | 78,674,900 |
| 2022/2023 | 678 | 399,117,900 |
| 2023/2024 | 2,258 | 1,509,277,400 |
| 2024/2025 | 366 | 217,625,350 |
| 2025/2026 | 83 | 48,171,000 |
| 2026/2027 | 188 | 60,239,000 |

### 4.3 By study year & semester

| Study year | Bills | Amount (UGX) | | Semester | Bills | Amount (UGX) |
|---|---:|---:|---|---|---:|---:|
| 1 | 2,728 | 1,711,481,100 | | 1 | 1,889 | 1,265,915,200 |
| 2 | 708 | 454,736,300 | | 2 | 1,536 | 1,004,093,100 |
| 3 | 273 | 170,627,900 | | 3 | 284 | 66,837,000 |

**Correctly NOT billed:** 89 year-4 periods (the fee resolver `fin_GetProgrammeFee` has no year-4 branch) + 42 zero-fee periods.

---

## 5. Live database verification (2026-06-25)

| Check | Live result |
|---|---|
| Batch registry | `mode=APPLIED`, students 897, bills planned 3,709 = applied 3,709, total 2,336,845,300 |
| Tracking bills tagged `fix_batch_id` | 3,709 = 2,336,845,300 |
| GL tagged `source_system='BILLFIX'` | DR 3,709 **=** CR 3,709, each 2,336,845,300 ✓ balanced |
| Worklist statuses | 3,709 **APPLIED**, 0 SKIPPED, 0 FAILED |
| Duplicate bills created by batch | **0** (see §8 note on 2 pre-existing legacy duplicates) |
| Dup-guard objects | `fin_bill_uniqueness` (35,757 rows) + triggers `trg_prevent_duplicate_bill`, `trg_sync_bill_uniqueness_delete` present |
| Backups | `bak_20260624_fin_ledger` (140,973) · `bak_20260624_fin_studentfeestracking` (72,687) |
| Run window | 02:25:27 → 02:52:51 |

---

## 6. Current balance picture (live cache, after **both** fixes)

`fin_student_balance_cache`, active students (`acad_student.new_status='ACTIVE'`). Sign: **+ = overpaid (credit)**, **− = owing**.

| Measure | Before fixes | Now (live) |
|---|---:|---:|
| Apparent credit held (active) | ~3.5 B | **~264.9 M** |
| Accounts in credit > 50k | ~3,800 | **450** |
| Accounts owing > 50k | ~1,200 | 1,136 |
| Total owing (active) | — | ~**−2.54 B** |

The remaining **~450 accounts / ~265 M** are now a believable set (genuine pre-payments / edge cases) for **individual review before any refund** — not a system artifact.

---

## 7. Safety, traceability & rollback

**8 reconciliation gates — all PASS** (worklist fully applied; tracking & GL tagged; no missing TIDs; no orphan GL; no new duplicate groups; per-bill DR=CR=amount; amounts = active fee structure; batch GL net 0).

**Defense-in-depth vs double billing (all active):** (1) worklist excludes already-billed (regno, year, sem, item); (2) `fin_TermlyItemBillingFN` `INSERT … WHERE NOT EXISTS`; (3) `fin_bill_uniqueness` UNIQUE; (4) `trg_prevent_duplicate_bill` BEFORE-INSERT (error 1062); (5) registry UNIQUE per (batch, regno, year, sem, item).

**Hidden traceability (not shown to students):** `fin_studentfeestracking.fix_batch_id='BILLFIX-2026-06-24-01'`; `fin_ledger.source_system='BILLFIX'` + `RefNo`; full row-level registry in `fin_billfix_worklist` (tracking TID + GL DR/CR TIDs + before/after balance). Student-visible wording is identical to normal auto-bills.

**Exact rollback (if ever needed):**
```sql
DELETE FROM fin_ledger              WHERE source_system='BILLFIX' AND RefNo='BILLFIX-2026-06-24-01';
DELETE FROM fin_studentfeestracking WHERE fix_batch_id='BILLFIX-2026-06-24-01';
-- trg_sync_bill_uniqueness_delete re-opens fin_bill_uniqueness slots automatically
CALL fin_UpdateAllLedgerBalances();   -- then rebuild fin_student_balance_cache
```
Backups `bak_20260624_*` are the ultimate fallback. Performance index `idx_curr_balance` was added (cut `fin_UpdateAllLedgerBalances` 1.55s → 0.05s).

---

## 8. Outstanding follow-ups

1. **Apply the payment-dedup fix to the remaining 4 files** (BillWaivers, DoubleBillingController, FeesTransactions, StudentLedgerExport) after confirming it suits their logic — for full system-wide consistency.
2. **Year-4 billing:** `fin_GetProgrammeFee` has no year-4 branch → 89 enrolled year-4 semesters were not billed. Extend the resolver if year-4 should be billed.
3. **Review the ~450 genuine credits (~265 M)** individually before any refund / credit-forward.
4. **Prevent recurrence:** schedule a reconciliation sweep that bills any enrolled, unbilled semester; standardise payment particulars at posting so ledger and tracking always reconcile.
5. **Drop the temporary backup tables** once satisfied (`bak_20260624_*`).
6. **Legacy data note (found during verification):** 2 pre-existing duplicate-bill groups exist table-wide, both with **`item_code=0`** and **not** from this batch (`fix_batch_id` null) — `MRU2023001401` (2023/2024 S1) and `MRU2024000575` (2025/2026 S1). They predate the fix and warrant a separate, small cleanup.

---

## 9. Artifacts

| Artifact | Location |
|---|---|
| Registry (batch + per-bill) | `fin_billfix_batch`, `fin_billfix_worklist` (`campus_dynamics_accounts`) |
| Driver procedure | `fin_BillFix_Apply` (+ `COOPERP/sql/_billfix_apply_sp.sql`) |
| Dup-guard triggers | `COOPERP/sql/_billfix_triggers.sql` |
| Run log | `COOPERP/sql/billfix_run.log` |
| Dry-run / worklist CSVs | `BILLFIX-2026-06-24_dryrun_by_student.csv`, `BILLFIX-2026-06-24_worklist.csv` |
| Root cause & plan | `OVERPAID_STUDENTS_ROOT_CAUSE_REPORT.md`, `BILLING_FIX_EXECUTION_PLAN.md` |
| Completion report | `BILLING_FIX_COMPLETION_REPORT.md` |
| Backups | `bak_20260624_fin_ledger`, `bak_20260624_fin_studentfeestracking` |
