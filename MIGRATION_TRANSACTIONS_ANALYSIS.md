# Migration / Imported Transactions — Analysis of "Payments Appearing Twice" & Phantom Overpayment

**Finance database:** `campus_dynamics_accounts` (live) · academic: `campus_dynamics`
**Analysed:** 2026-06-25 (read-only, against the live server)
**Example account used:** `MRU2024002056` (Damalie Nabwogi)
**Relationship:** complements `OVERPAID_STUDENTS_ROOT_CAUSE_REPORT.md`, `BILLING_FIX_COMPLETION_REPORT.md`, `BILLING_FIX_DETAILED_REPORT.md`.

---

## 1. Executive summary

The finance ledger (`fin_ledger`) was populated over time by several **imports / migrations**, identified by the hidden `source_system` column. Two of these patterns are responsible for students *appearing* overpaid:

| Pattern | Migration sources | What it does | Effect on a student's balance |
|---|---|---|---|
| **1. Dual-store mirror** | `SB_COLLECTIONS`, `CB_COLLECTIONS`, `Manual`, `(null)` | Mirrors each **payment** into the GL while the *same* payment also lives in the fee sub-ledger `fin_studentfeestracking` | **Payment counted twice** when the de-dup fails (old GL particulars = student **name**, sub-ledger says "Fees Payment … Airtel Money") → inflated credit |
| **2. One-sided restored credit** | `RESTORED_STUDENT_LEDGER` (+ contra `RSL_GL_SIDE`) | Restores **credits** (opening balances, sponsor money, waivers) that existed in the old system (EIS) directly onto the student ledger, with **no** sub-ledger twin | Genuine credit, but shows as **overpaid if the matching charge/bill was not also restored** |

- **Pattern 1 is the "appears twice" the user describes.** It is the same defect as root-cause **B**, and the computation side was corrected by **Fix B** (the dedup relaxation) — but only in 5 of 9 places, and the duplicate **data still exists in both stores**.
- **Pattern 2 (`RESTORED_STUDENT_LEDGER`) is NOT a double payment.** Verified: **0** of its 3,874 student-side credits duplicate another ledger credit, and **0** have a sub-ledger twin. They are real one-sided credits — they only look like overpayment when the corresponding **bill is missing** (root-cause **A**, addressed by the billing fix).
- A **third, smaller** issue exists and is **not** covered by either fix: **in-ledger duplicate credits** (two identical CR rows on the same student/amount/date) — **299 groups, ≤ UGX 112.7 M**.

---

## 2. Inventory of `source_system` values in `fin_ledger`

| source_system | rows | Σ amount (UGX) | Nature |
|---|---:|---:|---|
| Manual | 36,358 | 40,254,057,374 | Manual postings + mobile-money imports |
| SB_COLLECTIONS | 35,186 | 23,457,761,538 | **Stanbic bank** collection import (migration) |
| Billing | 33,835 | 20,304,679,904 | Normal auto-billing (charges) |
| (null) | 16,348 | 10,866,540,222 | Legacy / untagged |
| **BILLFIX** | 7,418 | 4,673,690,600 | Our billing correction (3,709 DR + 3,709 CR) |
| CB_COLLECTIONS | 5,216 | 2,722,898,530 | Cash-book collection import (migration) |
| **RESTORED_STUDENT_LEDGER** | 4,978 | 2,193,005,424 | **Student-side ledger restore (migration)** |
| **RSL_GL_SIDE** | 4,966 | 2,187,807,424 | **GL contra side of the restore (chart accounts)** |
| CB_OPERATIONS | 1,870 | 22,002,405,048 | Cash-book operations |
| PC_KAMPALA / PC_MASAKA | 1,496 / 644 | 135.4 M / 63.0 M | Petty-cash imports |
| JOURNAL_VOUCHERS | 68 | 9,024,103,120 | Journals |
| OPENING_BALANCE | 55 | 71,777,799,020 | Institutional opening balances (chart accounts) |
| DFCU / LOAN / REVERSAL | 46 / 2 / 2 | — | Misc |

---

## 3. Pattern 1 — the dual-store "appears twice" (the main issue)

### 3.1 Mechanism
A student's balance is computed from **two** stores combined and de-duplicated:
`fin_ledger` (GL, `CR`) **+** `fin_studentfeestracking` (sub-ledger, `Payment`). Every cash payment is meant to exist in **both**. The de-dup keeps a sub-ledger payment **unless** it matches a GL credit by `voucherNo=TID`, `folio='BillNo:'+TID`, **or** `amount + date + particulars`.

The import migrations wrote the GL `particulars` as the **student's name** (e.g. `"MRU2024002056 DAMALIE NABWOGI"`), while the sub-ledger `detail` is `"Fees Payment … thru Airtel Money"`. The particulars don't match → de-dup **fails** → the same payment is **counted twice**.

### 3.2 Scale (live)
- **36,470 sub-ledger payments (UGX 13,035,799,277)** have a GL credit twin (same regno+amount+date). This is the legitimate overlap that **must** de-dup to one.
- Pre-fix, the subset whose particulars didn't match — **10,114 rows ≈ UGX 3.30 B** (per the root-cause report) — slipped through and **doubled**.
- **Fix B** relaxed the payment match to **regno + amount + date (ignore particulars)**, so the whole 13.04 B overlap now de-dups correctly **in the 5 corrected computations**.

### 3.3 Worked example — `MRU2024002056`
Every cash credit in the GL has exactly **one** sub-ledger twin; the two waivers are ledger-only (correct):

| Date | Amount | GL source_system | Sub-ledger twin? |
|---|---:|---|:--:|
| 2025-02-05 | 1,000,000 | SB_COLLECTIONS | ✔ 1 |
| 2025-06-15 | 300,000 | SB_COLLECTIONS | ✔ 1 |
| 2025-07-02 | 500,000 | SB_COLLECTIONS | ✔ 1 |
| 2025-07-03 | 100,000 | SB_COLLECTIONS | ✔ 1 |
| 2025-07-14 | 35,000 | SB_COLLECTIONS | ✔ 1 |
| 2025-07-23 | 215,000 | **RESTORED_STUDENT_LEDGER** (Waiver) | ✘ 0 (ledger-only ✓) |
| 2025-08-26 → 2026-03-30 | 200k…500k | Manual (mobile money) | ✔ 1 each |
| 2025-10-07 | 215,000 | Manual (Waiver) | ✘ 0 (ledger-only ✓) |
| 2026-04-21 | 215,000 | (null) (Bursary) | ✔ 1 |
| 2026-04-25 | 104,000 | (null) | ✔ 1 |

**Before fixes:** each twinned payment was counted in *both* stores → roughly **double** the cash → the student appeared heavily overpaid.
**After fixes (live now):** `total_billed = 4,614,000`, `total_paid = 4,614,000`, **balance = 0**. The duplication is gone from the computed balance (Fix B), and the missing bills were added (Fix A).

> The duplicate rows still physically exist in both stores — Fix B makes the **reading** correct; it does not delete the redundant data.

---

## 4. Pattern 2 — `RESTORED_STUDENT_LEDGER` (a restore, **not** a double payment)

### 4.1 What it is
A migration that **restored student-side credits** from the old EIS system directly into `fin_ledger` on the student account, with the **double-entry contra** in `RSL_GL_SIDE` on chart-of-accounts.

- `RESTORED_STUDENT_LEDGER`: **on student accounts** (account_type FBMFees/FOEFees/FSSAHFees/FSTEADFees/Student). CR ≈ 1.744 B, DR ≈ 0.449 B.
- `RSL_GL_SIDE`: **on chart accounts only** (account_type `Chart Account`, 0 on student accounts) → **does not affect student balances** (the balance formula filters `accountcode = regno`). This is the correct GL counterpart.

### 4.2 What the restored credits are (3,874 student-side CRs = UGX 1,744,346,669)

| Kind | Rows | Amount (UGX) |
|---|---:|---:|
| "Other" (opening balances, sponsor money) | 1,814 | 935,147,729 |
| Waiver | 1,975 | 742,819,890 |
| Fees Payment | 85 | 66,379,050 |

"Other" examples: *"Being an opening balance from EIS"* (651 rows, 166.7 M), *"…money received from HESFB for yr1 sem1/sem2"* (HESFB government loan, 55.2 M + 53.9 M), *State-House sponsorship*, *RTGS Vision For Africa* sponsor payments.

### 4.3 Key verification (it is clean)
- **0** of the 3,874 restored credits duplicate another ledger credit (same regno+amount+date, different source).
- **0** of them have a sub-ledger payment twin → they are **not** double-counted via Pattern 1, and **Fix B does not touch them**.
- They are **legitimate, one-sided restored credits**.

### 4.4 Why they can still look like overpayment
A restored credit (e.g. an EIS opening balance or HESFB receipt) only balances correctly if the **matching charge** from the old system was *also* restored. Where the old bills were **not** migrated, the student shows a phantom credit — this is exactly **root-cause A (missing bills)**, which the billing fix targets. **234 currently-overpaid active students** hold at least one `RESTORED_STUDENT_LEDGER` credit and should be reviewed for a missing matching charge.

---

## 5. Pattern 3 — in-ledger duplicate credits (small, not yet fixed)

Two identical GL credit rows on the same `regno + amount + date` are **both** summed by the balance formula (no GL-internal de-dup exists). Upper bound:

- **299 groups, 329 extra rows, ≤ UGX 112,741,450.**

By source pair (extra amount):

| Sources in the group | Groups | Extra amount (UGX) |
|---|---:|---:|
| (null) + (null) | 81 | 44,211,450 |
| Manual + Manual | 103 | 35,667,000 |
| RESTORED_STUDENT_LEDGER ×2 | 54 | 22,700,500 |
| SB_COLLECTIONS ×2 | 57 | 8,462,500 |
| Billing + Manual | 2 | 870,000 |
| Billing ×2 | 2 | 830,000 |

> These are mostly **same-source self-duplicates**. Note: same amount on the same day **can be genuine** (a student really paid twice), so 112.7 M is an *upper bound*; each group needs 1:1 review before reversing the extra. The migration (`RESTORED_STUDENT_LEDGER`) contributes ~22.7 M of this.

---

## 6. How this relates to the billing correction we made

| Defect | Source | Status |
|---|---|---|
| Missing bills (charges never raised / not restored) | event-driven billing + partial migration of charges | **Fix A** raised 3,709 bills (UGX 2.34 B) for 897 students |
| Payment double-count (dual-store, Pattern 1) | import migrations wrote GL twins with name-particulars | **Fix B** de-dups by regno+amount+date in **5** computations |
| Restored one-sided credits (Pattern 2) | `RESTORED_STUDENT_LEDGER` | **Not a double**; resolved only when the matching charge exists (overlaps Fix A) |
| In-ledger duplicate credits (Pattern 3) | same-source re-imports | **Not addressed** by A or B |

Combined effect (live): active apparent credit fell **~3.5 B → ~265 M**; `MRU2024002056` went from heavily overpaid to **exactly 0**.

---

## 7. Risks / what is NOT yet fixed

1. **Duplicate data still physically present.** Fix B only corrects the *computation*. The **4 other consumers** still double-count Pattern 1: `BillWaivers`, `DoubleBillingController`, `FeesTransactions`, `StudentLedgerExport`.
2. **No shared reference key** between GL and sub-ledger for migrated payments → de-dup relies on `amount + date`, which **cannot distinguish two genuine identical same-day payments from a duplicate** (collapse risk one way, double-count the other).
3. **Pattern 3 (≤112.7 M)** in-ledger duplicates remain.
4. **234 overpaid students** carry restored credits whose matching charges may be missing.
5. **Re-running any import/migration** that re-mirrors payments without a reference key will recreate Pattern 1/3 duplicates.

---

## 8. Advice & way forward (prioritised)

**P1 — Make every balance reader consistent (low risk, code only).**
Apply the Fix B payment de-dup to the remaining 4 files so the *whole* system reads payments once. Until then, those screens still show the inflated (double) figure.

**P2 — Standardise the matching key at the source (root cause).**
On every payment posting/import, write a **shared reference** into both stores — GL `voucherNo = sub-ledger TID` (or `folio='BillNo:'+TID` / a `TransCode`) — so de-dup is **exact** and no longer depends on `amount + date`. Back-fill this key onto the migrated `SB_COLLECTIONS` / `CB_COLLECTIONS` / `Manual` rows where the twin can be matched 1:1. This permanently kills Pattern 1 and removes the genuine-vs-duplicate ambiguity.

**P3 — Clean Pattern 3 duplicates (data, careful).**
Review the 299 in-ledger duplicate-credit groups with strict **1:1 pairing** (keep the earliest, reverse the extra), starting with the migration self-dups (`RESTORED_STUDENT_LEDGER` 54, `SB_COLLECTIONS` 57). Tag the reversals like BILLFIX (`source_system`, `RefNo`, registry) and reconcile GL after — fully reversible. Skip any group that is a *genuine* repeat payment.

**P4 — Reconcile restored credits to charges (the 234).**
For students holding `RESTORED_STUDENT_LEDGER` credits, confirm the matching charge exists; if the old bill was not migrated, raise it via the same canonical `fin_BillProgrammeFees` path used by BILLFIX (extends Fix A). Only **genuine** residual credit then remains.

**P5 — One source of truth + reconciliation report.**
Treat `fin_ledger` as the authoritative GL and `fin_studentfeestracking` as the sub-ledger, with a **nightly reconciliation** that flags any student whose GL-credit total ≠ deduped sub-ledger total, and any enrolled-unbilled semester. This closes both root-cause A and B at the source and surfaces future drift immediately.

**P6 — Freeze ad-hoc re-imports.**
Do not re-run collection/restore migrations that mirror payments unless they carry the shared reference key (P2); otherwise they will recreate duplicates.

---

## 9. Appendix — key queries (read-only)

```sql
-- Dual-store overlap (Pattern 1): sub-ledger payments that have a GL twin
SELECT COUNT(*), SUM(t.amount)
FROM fin_studentfeestracking t
WHERE t.trans_type='Payment' AND t.post_status='Posted'
  AND EXISTS (SELECT 1 FROM fin_ledger l
              WHERE l.accountcode=t.regno AND l.transactionType='CR'
                AND l.transaction_amount=t.amount AND DATE(l.transactionDate)=DATE(t.trans_date));
-- => 36,470 rows, 13,035,799,277

-- RESTORED_STUDENT_LEDGER credits that duplicate another ledger credit  => 0
SELECT COUNT(*) FROM fin_ledger r
WHERE r.source_system='RESTORED_STUDENT_LEDGER' AND r.transactionType='CR' AND r.accountcode LIKE 'MRU%'
  AND EXISTS (SELECT 1 FROM fin_ledger o WHERE o.accountcode=r.accountcode AND o.transactionType='CR'
              AND o.transaction_amount=r.transaction_amount AND o.transactionDate=r.transactionDate
              AND IFNULL(o.source_system,'')<>'RESTORED_STUDENT_LEDGER');

-- RESTORED_STUDENT_LEDGER credits with a sub-ledger twin  => 0 (all ledger-only, 1,744,346,669)

-- In-ledger duplicate credit groups (Pattern 3)  => 299 groups, 112,741,450
SELECT COUNT(*), SUM((c-1)*amt) FROM (
  SELECT transaction_amount amt, COUNT(*) c FROM fin_ledger
  WHERE accountcode LIKE 'MRU%' AND transactionType='CR' AND transaction_amount>0
  GROUP BY accountcode, transaction_amount, transactionDate HAVING COUNT(*)>1) g;
```
