# Why Thousands of Students Show as "Overpaid" — Root-Cause Analysis & Remediation Plan

**System:** Campus Dynamics ERP (Muteesa I Royal University)
**Databases:** `campus_dynamics`, `campus_dynamics_accounts`
**Date:** 2026-06-24
**Scope:** Active student accounts showing a positive (credit / "overpaid") balance
**Status:** Investigation complete — no data changed; remediation pending approval

---

## 1. Executive summary (bottom line)

Active students appear to be **overpaid by ~UGX 3.54 billion** (1,707 accounts with credit > 300,000; ~1,984 with any credit). **This is almost entirely phantom.** Students are *not* paying beyond their fees — the credit is an artefact of two independent defects:

| # | Root cause | Magnitude | Nature |
|---|------------|-----------|--------|
| A | **Bills never raised** for semesters students attended & paid for | **~2.06 B** | Real (bills missing from the data) |
| B | **Payments double-counted** in the balance calculation | **~3.30 B** | Measurement bug (no data wrong, counted twice) |

Combined distortion (≈5.36 B) exceeds the apparent credit (3.54 B). **After both are corrected, the cohort is collectively *net owing*, not overpaid.**

> ⚠️ **Do not issue any refunds or credit-forwards based on the current figures.** The "credit" is not real money owed to students.

---

## 2. How student billing is *supposed* to work

### 2.1 Fee structure
Each programme has a fee table `campus_dynamics_accounts.fin_programme_fees` defining, per **study-year × semester**, a **tuition** and a **functional** amount:

```
progcode, has_year_1..4,
y1_s1_tuition, y1_s1_functional, y1_s2_tuition, ... y4_s3_tuition, y4_s3_functional,
is_active ('Yes'/'No')
```

Example (programme **MHHS**): `y1_s1 = 1,563,500 + 914,500`, `y2_s1 = 1,563,500 + 854,500`.

### 2.2 The billing data model
| Table | Role |
|-------|------|
| `campus_dynamics.acad_registration` | One row per student per semester: `acad_year`, `semester`, `studyyear`, `regstatus` |
| `campus_dynamics_accounts.fin_studentfeestracking` | Fee sub-ledger: `trans_type` = `Bill` / `Payment`, `amount`, `acadyear`, `semester`, `item_code` (1 = Tuition, 52 = Functional), `post_status` (`Posted`), `TID` |
| `campus_dynamics_accounts.fin_ledger` | General ledger: `transactionType` `DR`/`CR`, `accountcode` = regno, `account_type='Student'`, `voucherNo`, `folio`, `tracking_ref` |

A **Bill** ⇒ a tracking `Bill` row **and** a ledger `DR` (+ an income-account `CR`).
A **Payment** ⇒ a tracking `Payment` row **and** a ledger `CR`.
**Balance** = total charges − total payments (the public/fees-statement convention shows **+ = overpaid / credit**, **− = owing / debit**).

### 2.3 When billing fires (the critical design point)
Billing is **event-driven**. Stored procedure `fin_AutoBillOnRegistration`
(`COOPERP/sql/create_auto_bill_sp.sql`) runs **after** a registrar sets a status, and bills **only** when:

```sql
IF v_regstatus IN ('REGISTERED', 'LATE REGISTERED') THEN
    CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'REG', p_user, 'AUTO');   -- tuition + functional
    IF v_resstatus = 'RESIDENT' THEN
        CALL fin_Autobilling(..., 'ACCOMO', ...);                                    -- accommodation
    END IF;
END IF;
```

**Consequences of this design:**
- If a semester is **not** set to `REGISTERED`/`LATE REGISTERED`, **no bill is ever created** — even though the student may be attending and paying.
- There is **no reconciliation sweep**. Any missed billing event is missing **permanently** until someone runs a manual repair.
- Payments arrive **independently** of registration (mobile money posts continuously), so payments accumulate against non-existent bills.

---

## 3. Root Cause A — Missing bills for enrolled / paid semesters

### 3.1 Evidence
- **`acad_registration` status distribution:**

  | regstatus | rows |
  |-----------|-----:|
  | **UNREGISTERED** | **14,786** |
  | REGISTERED | 10,821 |
  | CLEARED | 3,028 |
  | LATE REGISTERED | 192 |
  | HALTED | 96 |
  | DEAD YEAR | 22 |
  | DISCONTINUED | 1 |

  **There are more UNREGISTERED semesters than REGISTERED ones.** The auto-biller skips all 14,786 — but students in many of them have paid.

- **Paid-but-unbilled periods (active students):** **1,100** student-semester periods have `Payment` rows but **zero `Bill` rows**, holding **UGX 744,512,796** in payments against no bill at all.

- **Expected-vs-actual billing:** modelling the correct bill from `fin_programme_fees` (tuition + functional) for every *enrolled* semester (including unregistered-but-attended) and subtracting what was actually billed gives an **unbilled gap of ~UGX 2.06 billion**. Billing those semesters would flip **544 "overpaid" accounts to owing** and **clear 117**.

### 3.2 Why semesters stay UNREGISTERED and unbilled
1. Student paid but was never formally registered by the registrar → status stuck at `UNREGISTERED` → auto-bill skips them.
2. Registration predates the auto-bill SP, or the auto-bill call wasn't fired / failed at the time, and nothing re-checks later.
3. No nightly/periodic reconciliation exists to catch the gap.

---

## 4. Root Cause B — Double-counted payments (measurement bug)

### 4.1 The mechanism
The student balance is computed from **two** payment stores combined and de-duplicated:
`fin_ledger` (`CR`) **+** `fin_studentfeestracking` (`Payment`). The dedup keeps a tracking
payment **unless** it can be matched to a ledger credit on one of:

- `voucherNo = TID`, or
- `folio = 'BillNo:' + TID`, or
- **`amount` + `DATE(date)` + `transactionType='CR'` + `particulars = detail`**.

For **older payments**, the ledger `particulars` is the **student's name** (e.g. `"MRU2024002021 GIDAH NAZZIWA"`), while the tracking `detail` is `"Fees Payment … thru Airtel Money"`. The particulars **don't match**, the dedup **fails**, and the **same payment is counted twice**.

### 4.2 Evidence (scale)
Across active students, **10,114 tracking payment rows = UGX 3,304,413,871** failed the dedup **yet have a same-regno / same-amount / same-date ledger credit** — i.e. they are duplicates that were counted twice.

> This inflates `total_paid` **everywhere** the dual-source formula is used: the StudentLedgers grid cache, `ComputeStudentBalance`, **and** the canonical `App_Code/FinanceEngine.cs` (`DUAL_LEDGER_SQL` / `ComputePeriodBalance`) — so the **student account and fees statement are affected too.**

---

## 5. Worked example — Gidah Nazziwa (MRU2024002021)

System shows **+7,589,500 "overpaid"**. Reality:

| Item | Detail |
|------|--------|
| Programme / status | MHHS, ACTIVE, entry 2024, study-year 2 |
| Registrations | 2024/2025 S1 **UNREGISTERED**, 2024/2025 S2 **UNREGISTERED**, 2025/2026 S1 **REGISTERED** |
| Enrolled semesters (proven) | **4** — waiver entries exist for Yr1S1, Yr1S2, Yr2S1, Yr2S2 |
| Bills actually raised | **1 only** — Tuition 1,563,500 + Functional 854,500 = **2,418,000** (`[AUTO]`, 2026-03-29) |
| Should have been billed | ≈ **9.7 M** (≈2.4–2.5 M × 4 semesters) |
| Cash payments (12, mobile money) | 5,691,000 |
| Waiver credits (25% MRU scholarship) | 2,441,000 |
| **True credits** | **8,132,000** (ledger `CR` total) |
| **True balance** | ≈ **−1.6 M (OWING)** |

**Phantom inflation breakdown:** ~7.3 M of missing bills **+** 1,875,500 of double-counted payments (his **first 4 payments** — 500k, 500k, 575.5k, 300k — failed dedup because the ledger labelled them with his name, not "Fees Payment").

| Source | Payments total |
|--------|---------------:|
| Cache `total_paid` (what the system uses) | **10,007,500** |
| Ledger `CR` (true, incl. waivers) | 8,132,000 |
| Tracking `Payment` only | 5,691,000 |

The 10,007,500 = 8,132,000 ledger + 1,875,500 that were **double counted**.

---

## 6. The true financial picture (cohort)

| Measure | Value |
|---------|------:|
| Apparent credit — active, overpaid > 300k (1,707 accts) | **3,535,963,332** |
| Apparent credit — active, any overpaid (~1,984 accts) | ~**3,537,595,025** |
| Cause A — missing bills (should be raised) | **~2,059,362,667** |
| Cause B — double-counted payments (phantom) | **~3,304,413,871** |
| Accounts that flip to **owing** once enrolled semesters billed | **544** |
| Accounts that **clear** (≈ zero) | 117 |

Once **A** (raise missing bills) and **B** (stop double-counting) are corrected, the
collective "overpayment" disappears and becomes **net receivable owed to the university**.

### Distribution of the apparent credit (active, > 300k)
| Credit band (UGX) | Accounts | Total credit |
|-------------------|---------:|-------------:|
| 300,001 – 450,000 | 50 | 19,505,400 |
| 450,001 – 600,000 | 66 | 33,875,000 |
| 600,001 – 1,000,000 | 145 | 123,184,525 |
| 1,000,001 – 2,000,000 | 615 | 960,852,853 |
| 2,000,001 – 5,000,000 | 770 | 2,031,676,204 |
| > 5,000,000 | 61 | 366,869,350 |

The bulk sit in the 1M–5M range — far too large to be genuine over-payments, consistent with one or more whole semesters unbilled.

---

## 7. Remediation plan (careful, phased)

> Do these **in order**. Phase 1 changes **no data** — it only stops mis-counting.

### Phase 1 — Fix the payment double-count *(non-destructive; do first)*
Relax the **payment** side of the dedup to match on **regno + amount + date** (paired 1:1)
and **ignore the particulars text** — or treat the GL `fin_ledger` as the single source of
truth for cash and only add tracking payments that have **no** same-amount/same-date ledger
credit. This removes the ~3.30 B phantom credit from the grid, `ComputeStudentBalance`, and
`FinanceEngine` **without touching any transaction**.
**Guard:** pair duplicates 1:1 so two *genuine* identical same-day payments aren't collapsed.

**Files affected:** `App_Code/FinanceEngine.cs` (`DUAL_LEDGER_SQL`, `ComputePeriodBalance`),
`COOPERP/NewScreens/StudentLedgers.aspx.cs` (`GetBalanceCacheRebuildSql`,
`ComputeStudentBalance`, `AjaxLedgerDetails`).

### Phase 2 — Reconcile, then bill the missing semesters *(data change, reviewed)*
1. Build a per-student worklist: enrolled semesters vs billed semesters vs (corrected)
   payments vs expected bill from `fin_programme_fees`.
2. **Bill only semesters with real evidence of enrolment** (a registration row and/or
   payments in that period). **Do not** blanket-bill all 14,786 `UNREGISTERED` — route
   no-evidence cases to the registrar to correct status first.
3. Use the **existing** machinery — `fin_Autobilling` / the StudentLedgers **Fix Billing**
   wizard (`GetUnbilledSemesters` + `CreateBillEntries`) — which creates tracking `Bill` +
   ledger `DR` + income `CR` **idempotently** ("Already Billed" pre-check) and **previews**
   before applying. Extend its candidate set to "enrolled-but-unregistered **with payments**."
4. Run in **batches**, inside a **transaction**, **dry-run first**, reconcile the GL after each batch.

### Phase 3 — Re-derive and handle genuine credits
Re-compute balances. The "overpaid" list should shrink to a small set of *genuinely*
overpaid students. **Only those**, verified individually, are candidates for refund / credit-forward.

### Phase 4 — Prevent recurrence
- Add a **scheduled reconciliation sweep** that bills any enrolled, unbilled semester
  (closes the "missed event" gap permanently).
- **Standardise payment particulars** at posting so ledger and tracking always match
  (eliminates the dedup failure at source).

---

## 8. Appendix — verification queries used

> Run against `campus_dynamics` / `campus_dynamics_accounts` (same server).

**A. Paid-but-unbilled periods (active students)**
```sql
SELECT COUNT(*) AS paid_unbilled_periods, SUM(pay_amt) AS payments_in_those_periods
FROM (
  SELECT t.regno, t.acadyear, t.semester, SUM(t.amount) AS pay_amt
  FROM campus_dynamics_accounts.fin_studentfeestracking t
  JOIN campus_dynamics.acad_student s
    ON s.regno=t.regno AND UPPER(COALESCE(s.new_status,''))='ACTIVE'
  WHERE t.trans_type='Payment' AND t.post_status='Posted'
  GROUP BY t.regno, t.acadyear, t.semester
  HAVING NOT EXISTS (
    SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking b
    WHERE b.regno=t.regno AND b.acadyear=t.acadyear
      AND b.semester=t.semester AND b.trans_type='Bill')
) x;   -- => 1,100 periods, 744,512,796
```

**B. Phantom double-counted payments (dedup failures with a real ledger match)**
```sql
SELECT COUNT(*) AS phantom_rows, SUM(t.amount) AS phantom_credit
FROM campus_dynamics_accounts.fin_studentfeestracking t
JOIN campus_dynamics.acad_student s
  ON s.regno=t.regno AND UPPER(COALESCE(s.new_status,''))='ACTIVE'
WHERE t.trans_type='Payment' AND t.post_status='Posted'
  AND NOT EXISTS (   -- canonical dedup fails
    SELECT 1 FROM campus_dynamics_accounts.fin_ledger fl2
    WHERE fl2.accountcode=t.regno
      AND ( fl2.voucherNo=CAST(t.TID AS CHAR)
         OR fl2.folio=CONCAT('BillNo:',CAST(t.TID AS CHAR))
         OR ( fl2.transaction_amount=t.amount
              AND DATE(fl2.transactionDate)=DATE(t.trans_date)
              AND fl2.transactionType='CR'
              AND (fl2.particulars=t.detail OR t.detail IS NULL OR t.detail=''))))
  AND EXISTS (        -- but a same amount+date ledger CR DOES exist => duplicate
    SELECT 1 FROM campus_dynamics_accounts.fin_ledger l
    WHERE l.accountcode=t.regno AND l.transactionType='CR'
      AND l.transaction_amount=t.amount AND DATE(l.transactionDate)=DATE(t.trans_date));
-- => 10,114 rows, 3,304,413,871
```

**C. Expected-bill reconciliation (active overpaid; enrolled incl. unregistered)**
```sql
SELECT COUNT(*) AS overpaid_active,
  SUM((c.total_paid - e.expected_bill) < -50000) AS would_owe,
  SUM((c.total_paid - e.expected_bill) BETWEEN -50000 AND 50000) AS would_clear,
  SUM(GREATEST(e.expected_bill - c.total_billed,0)) AS unbilled_gap
FROM campus_dynamics_accounts.fin_student_balance_cache c
JOIN campus_dynamics.acad_student s
  ON s.regno=c.regno AND UPPER(COALESCE(s.new_status,''))='ACTIVE'
JOIN (
  SELECT rp.regno, SUM(CASE
    WHEN rp.studyyear=1 AND rp.semester=1 THEN f.y1_s1_tuition+f.y1_s1_functional
    WHEN rp.studyyear=1 AND rp.semester=2 THEN f.y1_s2_tuition+f.y1_s2_functional
    /* … y1_s3 … y4_s3 … */
    ELSE 0 END) AS expected_bill
  FROM (SELECT DISTINCT regno, acad_year, semester, studyyear
        FROM campus_dynamics.acad_registration
        WHERE regstatus NOT IN ('DEAD YEAR','DISCONTINUED','HALTED')) rp
  JOIN campus_dynamics.acad_student s2 ON s2.regno=rp.regno
  JOIN campus_dynamics_accounts.fin_programme_fees f
    ON f.progcode=s2.progid AND f.is_active='Yes'
  GROUP BY rp.regno
) e ON e.regno=c.regno
WHERE (c.total_paid - c.total_billed) > 0;
-- => 2,022 overpaid; 544 would owe; 117 clear; unbilled_gap 2,059,362,667
```

---

## 9. Recommended next steps
1. **Implement Phase 1** (dedup fix) — safe, immediately corrects the headline numbers.
2. **Produce the Phase 2 worklist** (read-only CSV: per student — enrolled vs billed semesters,
   expected bill, corrected payments, true balance, exact bills to raise) for finance review.
3. Bill only after finance sign-off, in dry-run-previewed batches.

*Neither step 1 nor step 2 alters any financial transaction; billing (step 3) is gated on approval.*
