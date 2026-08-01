# Campus Dynamics — Financial Module Standardization Report

**Date:** 2025  
**Scope:** Full portal financial audit — fees, bursaries, balance display, ledger consistency  
**Standard established:** DR − CR balance formula, UNION ALL data source, signed number display

---

## 1. The Standard

### 1.1 Balance Formula
```
Balance = SUM(DR) − SUM(CR)
```
- **Positive** → student owes money → displayed in red, labelled "Outstanding balance"
- **Negative** → student has overpaid (credit) → displayed in green, labelled "Negative balance (credit)"
- **Zero** → fully cleared → displayed in green, labelled "Fully cleared"

### 1.2 Display Format
| Value | Display | Example |
|-------|---------|---------|
| Positive | `UGX X` | `UGX 500,000` |
| Negative | `UGX -X` | `UGX -120,000` |
| Zero | `UGX 0` | `UGX 0` |

No "CR" suffix. No "(credit)" suffix on numbers. Labels carry the meaning.

### 1.3 Authoritative Balance Source — UNION ALL
**Every page that displays or computes a student balance must use:**

```sql
SELECT SUM(dr_total) - SUM(cr_total)
FROM (
  -- All GL entries
  SELECT transactionType, transaction_amount
  FROM fin_ledger
  WHERE accountcode = @reg AND transaction_amount > 0
  
  UNION ALL
  
  -- Legacy tracking entries not yet in GL (pre-dual-write)
  SELECT
    CASE WHEN trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END,
    amount
  FROM fin_studentfeestracking
  WHERE regno = @reg
    AND post_status = 'Posted'
    AND NOT EXISTS (
      SELECT 1 FROM fin_ledger fl2
      WHERE fl2.accountcode = t.regno
        AND (
          fl2.voucherNo = CAST(t.TID AS CHAR)
          OR fl2.folio = CONCAT('BillNo:', CAST(t.TID AS CHAR))
          OR (
            fl2.transaction_amount = t.amount
            AND DATE(fl2.transactionDate) = DATE(t.trans_date)
            AND fl2.transactionType = CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
            AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
          )
        )
    )
) x
```

**Why:** Using `fin_ledger` alone misses legacy "orphan" billing/payment entries that exist in `fin_studentfeestracking` but were created before the dual-write sync was deployed. This causes different pages to show different balances for the same student.

---

## 2. Changes Made

### 2.1 COOPERP/NewScreens/BillWaivers.aspx.cs
**Issue:** `ComputeUnionAllBalance` was changed to `fin_ledger`-only, breaking the Balance Fix feature. Balance Fix read a different current balance than what the student's fee page showed, resulting in a wrong delta and wrong post amount.

**Fix:** Restored `ComputeUnionAllBalance` to use the full UNION ALL query (matching `StudentFees.aspx.cs` exactly). The Balance Fix delta is now computed from the same balance the student sees.

**Additional fix:** Removed the "one active Balance Fix per student" restriction that was blocking legitimate re-runs.

**Balance Fix flow:**
1. Read current balance using UNION ALL
2. Compute `delta = currentBalance - targetBalance` where `targetBalance = -requestedMagnitude`
3. If delta > 0 → post CR (reduce outstanding balance)
4. If delta < 0 → post DR (increase)
5. Verify post-fix balance within ±0.05 UGX tolerance

---

### 2.2 COOPERP/NewScreens/BillWaivers.aspx (JavaScript)
**Issue:** Stale `_fixSelectedSign` variable references from an old refactor caused JS errors. The `formatSignedMoney` function produced incorrect output for negative values.

**Fix:**  
- Removed all `_fixSelectedSign` references  
- Fixed `formatSignedMoney(n)`: positive → `UGX X`, negative → `- UGX X`, zero → `UGX 0`
- Impact line now reads "post a credit entry" (not abbreviated "post CR")

---

### 2.3 COOPERP/NewScreens/StudentLedgers.aspx.cs (Admin Ledger)
**Issue:** Per-row running balance was displaying with old "CR" suffix convention. Filter dropdown said "Credit / Overpaid".

**Fix:**  
- Per-row balance: signed `N0` format (negative shown as `-X`)  
- Filter label: renamed to "Negative Balance"

---

### 2.4 COOPERP/NewScreens/FeesTransactions.aspx.cs
**Issue:** Net balance pill was labelled confusingly and formatted inconsistently.

**Fix:**  
- Label changed to "Net Balance"  
- Value: signed `N0` format  
- `BD_FormatBalance`: negative shows `UGX -X` (no "CR" suffix)

---

### 2.5 COOPERP/NewScreens/DoubleBillingController.aspx.cs
**Issue:** `DB_FormatBalance` showed credit balances without negative sign, using "CR" suffix.

**Fix:** `DB_FormatBalance` now returns `UGX -X` for negative values (standard signed format).

---

### 2.6 CampusDynamics_Portal/UserControls/Financials/StudentLedger.ascx.cs
**Critical fix (this session):**

**Issue:** The student-facing `StudentLedger` user control was calling the `fin_GetStudentLedger` stored procedure, which reads from `fin_ledger` ONLY. This meant the control could show a different balance and transaction count than `StudentFees.aspx` (which uses UNION ALL). For students with legacy orphan tracking entries, the balances would disagree — a confusing and incorrect inconsistency visible to the student.

**Fix:** Replaced the stored procedure call with inline UNION ALL SQL identical to the query in `StudentFees.aspx.cs`. The control now reads from the same combined data source as the main fee statement page.

**Before:**
```csharp
using (MySqlCommand cmd = new MySqlCommand("fin_GetStudentLedger", conn))
{
    cmd.CommandType = CommandType.StoredProcedure;
    // fin_ledger ONLY — can miss legacy tracking entries
}
```

**After:**
```csharp
const string sql =
    "SELECT fl.voucherNo, DATE_FORMAT(...) AS formated_date, ... " +
    "FROM fin_ledger fl WHERE fl.accountcode = @reg ... " +
    "UNION ALL " +
    "SELECT CAST(t.TID AS CHAR) AS voucherNo, ... " +
    "FROM fin_studentfeestracking t " +
    "WHERE t.regno = @reg AND t.post_status = 'Posted' AND NOT EXISTS (...) " +
    "ORDER BY raw_date ASC, voucherNo ASC";
// CommandType.Text — uses UNION ALL matching StudentFees.aspx.cs exactly
```

**Balance display (also patched):**
- Summary cards: signed format — positive → "Outstanding balance", negative → "Negative balance (credit)", zero → "Fully cleared"
- Per-row `balance_display`: signed `N0` (negative = credit/overpaid)
- Footer totals: signed `N0`

---

### 2.7 CampusDynamics_Portal/App_Code/Portal/FeeAccessHelper.cs
**Status:** Already using UNION ALL ✅

**Minor fix (label wording):** Balance criterion description changed: "negative balance of -X" (not "credit balance of X") — consistent with standard.

---

### 2.8 CampusDynamics_Portal/UserControls/Security/SystemApplications_Modern.ascx.cs
**LoadFinancialStats — data source:** Already using correct UNION ALL query ✅

**Fix (this session) — credit balance state:**  
When a student's balance is negative (overpaid/in credit):
- **Before:** Card showed orange "balance" color and said "Outstanding balance"
- **After:** Card shows green "paid" color and says "Negative balance (credit)"

Three-state logic:
| Balance | Card Color | Sub-label |
|---------|-----------|-----------|
| = 0 | Green | "Fully cleared" |
| < 0 (credit) | Green | "Negative balance (credit)" |
| > 0 (owes) | Orange/Red | "Outstanding balance" |

Progress bar: now turns green for credit balances (pct > 100 capped at 100%).

---

## 3. Files Audited — No Changes Required

### 3.1 CampusDynamics_Portal/StudentFees.aspx.cs
- Uses correct UNION ALL ✅
- Balance display: positive → danger color, negative → `UGX -X` with note ✅

### 3.2 COOPERP/NewScreens/BursaryBeneficiaries.aspx.cs
- Bursary posting uses `BursaryManager.Create` (atomic, 3-table transaction) ✅
- Supports FIXED, PERCENTAGE (of tuition from `fin_programme_fees`), and CUSTOM amounts ✅
- Student registration status validated before posting ✅
- Duplicate restriction removed (students may receive multiple bursaries per semester) ✅
- Toast messages include exact amount and transaction ID ✅

### 3.3 COOPERP/NewScreens/BursarySchemes.aspx.cs
- Scheme types: FIXED / PERCENTAGE / CUSTOM ✅
- Auto-migration for `scheme_type` and `scheme_value` column addition ✅

### 3.4 COOPERP/NewScreens/BursaryDashboard.aspx.cs
- KPI cards: total beneficiaries, total amount disbursed, active schemes, linked transactions ✅
- Correctly reads from `scholarshipstudents` and `scholarships` tables ✅

### 3.5 CampusDynamics_Portal/StudentFeeStructure.aspx.cs
- Reads `fin_programme_fees` for programme fee matrix ✅
- Grand total: `"UGX " + grandTotal.ToString("N0")` ✅
- Highlights student's current enrolled semester in the matrix ✅

---

## 4. Data Source Matrix

| Page / Control | Balance Source | Status |
|----------------|---------------|--------|
| `StudentFees.aspx.cs` | UNION ALL | ✅ |
| `SystemApplications_Modern.ascx.cs` `LoadFinancialStats` | UNION ALL | ✅ |
| `FeeAccessHelper.cs` | UNION ALL | ✅ |
| `BillWaivers.aspx.cs` `ComputeUnionAllBalance` | UNION ALL | ✅ Fixed |
| `StudentLedger.ascx.cs` | **UNION ALL** | ✅ Fixed (was SP) |
| `StudentLedgers.aspx.cs` (admin) | Per-page query | ✅ |
| `FeesTransactions.aspx.cs` | Per-page query | ✅ |

---

## 5. Terminology Standard

| Avoid | Use instead |
|-------|------------|
| "Credit / Overpaid" | "Negative Balance" |
| "CR" suffix on amounts | Negative sign: `-X` |
| "credit balance" | "negative balance (credit)" |
| "Fully paid" | "Fully cleared" |
| "post CR" (in descriptions) | "post a credit entry" |

---

## 6. Key Tables Reference

| Table | Purpose |
|-------|---------|
| `fin_ledger` | General ledger — all GL entries (DR/CR). Authoritative for completed transactions. |
| `fin_studentfeestracking` | Fee tracking — billing and payment records. Some may not be in fin_ledger (pre-dual-write). |
| `fin_bill_waivers` | Waiver headers |
| `fin_bill_waiver_items` | Waiver line items |
| `fin_programme_fees` | Fee structure per programme per year/semester |
| `scholarships` | Bursary/scholarship scheme definitions |
| `scholarshipstudents` | Bursary beneficiary records |
| `acad_registration` | Student registration records (status, year, semester) |

---

## 7. Connection String Names

| Name | Database | Used In |
|------|---------|---------|
| `campus_dynamics_accountsConnectionString` | campus_dynamics_accounts | Portal pages (FeeAccessHelper, StudentLedger control, SystemApplications_Modern) |
| `accountsConnectionString` | campus_dynamics_accounts | COOPERP admin pages (BillWaivers, StudentLedgers, FeesTransactions, etc.) |
| `campus_dynamics_portalConnectionString` / `vacConnectionString` | campus_dynamics | Academic/registration data |
