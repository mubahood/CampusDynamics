# System-Wide Fix: One Correct Way to Read Student Payments & Balances

**Goal:** across **every** screen, control, API endpoint and DB routine in all three apps, a student's fees balance must be computed **one canonical way** so the system **never double-counts payments** and **never shows a false "overpaid"** (or false "owing").
**Databases:** `campus_dynamics` (academic) · `campus_dynamics_accounts` (finance)
**Reference fix already shipped (the model):** `API/StudentLedgerExport.aspx.cs` — see `MIGRATION_TRANSACTIONS_ANALYSIS.md`, student `MRU2024002056` (statement went 1,935,000 CR → **0**).
**Status:** 🟡 PLAN — audit complete (live code + live DB). No code changed by this document except the already-shipped `StudentLedgerExport`.

---

## 1. The problem in one paragraph

A payment legitimately lives in **two** stores: the GL (`fin_ledger`, `CR`) and the fee sub-ledger (`fin_studentfeestracking`, `Payment`). A correct balance must **combine and de-duplicate** them. The de-dup matches a tracking row to a ledger row by `voucherNo=TID` **or** `folio='BillNo:'+TID` **or** `amount+date+type+particulars`. Migration/imported payments wrote the ledger `particulars` as the **student name** (not "Fees Payment … Airtel Money"), so the **particulars match fails**, the payment is **counted twice**, and the student appears **overpaid**. The correct ("Fix B") behaviour is to **waive the particulars match for PAYMENTS only** (bills keep the strict match). Separately, many readers don't use the dual-source method at all (ledger-only or tracking-only), so different screens disagree.

**Canonical rule (must hold everywhere):**
```
balance = Σ(charges) − Σ(payments), computed from fin_ledger (GL) + fin_studentfeestracking (sub-ledger),
          de-duplicated, with the PAYMENT match waiving particulars:
   include a tracking row only if NOT EXISTS a fin_ledger row where
     voucherNo = TID
     OR folio   = CONCAT('BillNo:', TID)
     OR ( amount = amount AND DATE(date)=DATE(date)
          AND type = (Payment→CR / Bill→DR)
          AND ( trans_type='Payment'                       -- PAYMENTS: ignore particulars
                OR particulars = detail OR detail IS NULL OR detail='' ) )   -- BILLS: strict
Sign (institution rule): displayed balance = paid − billed →  + = OVERPAID (CR),  − = OWING (DR).
```

The reference implementation is `App_Code/FinanceEngine.cs` → `DUAL_LEDGER_SQL` / `ComputePeriodBalance` / `GetDualLedger`.

---

## 2. Affected-inventory (complete, by layer)

Legend: **FIXED** = already correct · **BUGGY** = still requires particulars match (double-counts payments) · **DIVERGENT** = uses a different methodology (ledger-only / tracking-only) → inconsistent · **N/A** = not a balance reader.

### 2A. Canonical engine — the reference (no change)
| File | What | Status |
|---|---|---|
| `App_Code/FinanceEngine.cs` → `DUAL_LEDGER_SQL`, `ComputePeriodBalance`, `GetDualLedger` | Master dual-source dedup + sign convention | **FIXED** |

### 2B. API layer (`CampusDynamics/API`) — all good
| Endpoint / file | Source | Status |
|---|---|---|
| `API/v2/finance.aspx.cs` — `balance, ledger, payment_history, billing_summary, billing_breakdown, fee_status, bulk_fee_check, student_financial_summary, access_status` | delegate → FinanceEngine | **FIXED** |
| `API/v2/student.aspx.cs` — `clearance` | delegate → FinanceEngine | **FIXED** |
| `API/doc_verification.aspx.cs` — access snapshot | delegate → FinanceEngine | **FIXED** |
| `API/StudentLedgerExport.aspx.cs` — HTML statement | inline DUAL_LEDGER (mirrors Fix B) | **FIXED (model)** |
| `API/v2/academic.aspx.cs` — `register` balance gate | fin_ledger **only** | **DIVERGENT** (see §3D) |

### 2C. Main admin (`COOPERP/NewScreens`)
| File → method (approx line) | What | Status | Action |
|---|---|---|---|
| `StudentLedgers.aspx.cs` → `GetBalanceCacheRebuildSql` (~387), `AjaxLedgerDetails` (~909) | Grid cache + drilldown | **FIXED** | none |
| `BillWaivers.aspx.cs` → `HandleLoadBills` (~299) | Bills list for waiver | **BUGGY** | Fix B |
| `BillWaivers.aspx.cs` → `ComputeUnionAllBalance` (~1743) | Student balance (waiver context) | **BUGGY** | Fix B |
| `DoubleBillingController.aspx.cs` → `DB_ComputeBalance` (~1082) | Balance for dup-billing repair decisions | **BUGGY** | Fix B |
| `FeesTransactions.aspx.cs` → `BuildInnerUnion` (~418) | GL-orphan transaction grid | N/A (orphan detection) | none |
| `DoubleBillingController.aspx.cs` → `DB_DetectDuplicates` (~951) | GL-only dup detection | N/A | none |

### 2D. Student Portal (`CampusDynamics_Portal`)
| File → method (approx line) | What | Status | Action |
|---|---|---|---|
| `StudentFees.aspx.cs` → `LoadLedger` (~252) | Student fee statement (the page like the model) | **BUGGY** | Fix B |
| `StudentFees.aspx.cs` → `ComputeUnionAllBalance` (~511) | Balance for scan/fix parity | **BUGGY** | Fix B |
| `App_Code/Portal/FeeAccessHelper.cs` → `Evaluate` (~168) | **Fee-gated access** (exam card, results, registration) | **BUGGY** | Fix B |
| `App_Code/Portal/SemesterRegistrationWizardService.cs` → `GetStudentOutstandingBalance` (~1034) | **Blocks/permits new-semester registration** | **BUGGY** | Fix B (+Waiver) |
| `UserControls/Financials/StudentLedger.ascx.cs` → `LoadLedger` (~94) | Dashboard ledger card | **BUGGY** | Fix B |
| `UserControls/Security/SystemApplications_Modern.ascx.cs` → `LoadFinancialKPIs` (~1330) | Dashboard KPI cards / progress bar | **BUGGY** | Fix B (+Waiver) |
| `RegistrationWizardController.aspx.cs` → `HandleGetBalance` (~164) | AJAX balance for wizard | **BUGGY (inherited)** | fixed once FeeAccessHelper is |
| `api/Default.aspx.cs` → `HandleStudent` | Public REST `fees_balance`, `total_paid_*` | **DIVERGENT** (calls DB funcs) | see §2E / §3D |

### 2E. Database layer (`campus_dynamics_accounts`) — **newly surfaced, important**
Balance/payment logic is **also** duplicated inside MySQL routines, in three inconsistent styles:

| Routine | Method | Status | Action |
|---|---|---|---|
| `fin_GetStudentLedger` (PROC) | dual-source + **particulars** dedup | **BUGGY (verify)** | Fix B in SQL |
| `fin_GetLimitedStudentLedger` (PROC) | dual-source + **particulars** dedup | **BUGGY (verify)** | Fix B in SQL |
| `fin_GetNewFeesBalance` (FUNC) | **tracking-only** (Bill/Payment sums) | **DIVERGENT** | converge to canonical |
| `fin_TotalPayments` (FUNC) | **tracking-only** (Payment sum) | **DIVERGENT** | converge to canonical |
| `fin_GetCurrentFeesBalance`, `fin_GetCurrentStudentBalance`, `fin_GetCurrentBalance`, `fin_GetFeesBalance`, `fin_GetLimitedStudentBalance`, `fin_GetSFPBalance`, … (FUNCs) | **ledger-only** (Σ DR − Σ CR) | **DIVERGENT** (reflects in-ledger duplicates) | converge / deprecate |
| `payment_analytics` (VIEW) | references both stores | **verify** | align or document |

> The portal public API (`api/Default.aspx.cs`) returns a **ledger-only** balance (`fin_GetCurrentFeesBalance`) alongside a **tracking-only** paid total (`fin_TotalPayments`) — two different methodologies in one response, neither matching the canonical dual-source dedup. This is the DB-layer equivalent of the same disease.

---

## 3. The fix — three tracks

### Track 1 — Immediate: apply Fix B to every BUGGY dual-source reader (low risk, exact)
One-line change at each BUGGY site. Replace:
```sql
AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
```
with (payments waive particulars; bills stay strict):
```sql
AND (t.trans_type = 'Payment' OR fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
```
*(For readers that also treat Waivers/Bursaries as credits — `SemesterRegistrationWizardService`, `SystemApplications_Modern` — use `t.trans_type IN ('Payment','Waiver')` to be safe.)*

**Sites (Track 1):** COOPERP `BillWaivers` (×2), `DoubleBillingController` (×1); Portal `StudentFees` (×2), `FeeAccessHelper` (×1), `SemesterRegistrationWizardService` (×1), `StudentLedger.ascx` (×1), `SystemApplications_Modern` (×1). `RegistrationWizardController` is fixed transitively via `FeeAccessHelper`. DB procs `fin_GetStudentLedger`, `fin_GetLimitedStudentLedger` (×1 each, in SQL).

### Track 2 — Structural: one canonical computation per layer (kills recurrence by design)
The real disease is **duplication of balance logic**. Converge:

- **App code (C#):** every balance read goes through **`FinanceEngine`** (`ComputePeriodBalance` / `GetDualLedger`). Replace inline dual-source SQL in the buggy files with a call to the engine where practical; where a page must keep inline SQL (e.g. a statement renderer), it must paste the **exact** `DUAL_LEDGER_SQL` (as `StudentLedgerExport` now does). No bespoke variants.
- **Portal:** the portal can't reference the COOPERP `FinanceEngine` assembly directly, so create a **single portal helper** (`PortalFinance.ComputeBalance` / `GetDualLedger`) holding the identical canonical SQL, and route `FeeAccessHelper`, `StudentFees`, `StudentLedger.ascx`, `SystemApplications_Modern`, and `SemesterRegistrationWizardService` through it. One definition, many callers.
- **Database:** define **one** canonical balance object — either a function `fin_GetCanonicalBalance(regno[,yr,sem])` or a view `v_student_balance` — implementing the dual-source dedup, and make `fin_GetStudentLedger`, `fin_TotalPayments`, `fin_GetNewFeesBalance`, the `fin_Get*Balance` family, and `payment_analytics` **delegate** to it (or be deprecated). The materialised `fin_student_balance_cache` already implements the canonical method and should be treated as the fast read path.

### Track 3 — Permanent cure at the source (stops duplicates being created)
The dedup is only fragile because GL and sub-ledger lack a **shared key** for migrated payments.
1. **At posting/import**, always write a shared reference: GL `voucherNo = tracking TID` (or `folio='BillNo:'+TID`, or a `TransCode`). Then dedup is **exact** (by key), independent of particulars/amount/date — and genuine same-day, same-amount payments are no longer ambiguous.
2. **Back-fill** that key onto historic `SB_COLLECTIONS` / `CB_COLLECTIONS` / `Manual` rows where the twin matches 1:1.
3. **Nightly reconciliation** report: per student, GL-credit total vs deduped sub-ledger total — flag drift; also flag enrolled-but-unbilled semesters.
4. **Freeze** any re-import that mirrors payments without the shared key.

---

## 4. Per-file change list (Track 1)

| # | File | Method (approx line) | Change |
|---|---|---|---|
| 1 | `COOPERP/NewScreens/BillWaivers.aspx.cs` | `HandleLoadBills` (~299) | add `t.trans_type='Payment' OR` to dedup |
| 2 | `COOPERP/NewScreens/BillWaivers.aspx.cs` | `ComputeUnionAllBalance` (~1743) | add `t.trans_type='Payment' OR` |
| 3 | `COOPERP/NewScreens/DoubleBillingController.aspx.cs` | `DB_ComputeBalance` (~1082) | add `t.trans_type='Payment' OR` |
| 4 | `Portal/StudentFees.aspx.cs` | `LoadLedger` (~252) | add `t.trans_type='Payment' OR` |
| 5 | `Portal/StudentFees.aspx.cs` | `ComputeUnionAllBalance` (~511) | add `t.trans_type='Payment' OR` |
| 6 | `Portal/App_Code/Portal/FeeAccessHelper.cs` | `Evaluate` (~168) | add `t.trans_type='Payment' OR` |
| 7 | `Portal/App_Code/Portal/SemesterRegistrationWizardService.cs` | `GetStudentOutstandingBalance` (~1034) | add `t.trans_type IN ('Payment','Waiver') OR` |
| 8 | `Portal/UserControls/Financials/StudentLedger.ascx.cs` | `LoadLedger` (~94) | add `t.trans_type='Payment' OR` |
| 9 | `Portal/UserControls/Security/SystemApplications_Modern.ascx.cs` | `LoadFinancialKPIs` (~1330) | add `t.trans_type IN ('Payment','Waiver') OR` |
| 10 | DB `fin_GetStudentLedger` | dedup clause | add `t.trans_type='Payment' OR` (SQL) |
| 11 | DB `fin_GetLimitedStudentLedger` | dedup clause | add `t.trans_type='Payment' OR` (SQL) |

`RegistrationWizardController.HandleGetBalance` requires no edit — it calls `FeeAccessHelper` (#6).

---

## 5. Rollout plan (phased, tested against the model student)

1. **Phase 1 — App code (Track 1, sites 1–9).** One-line edits; no data change. Build each app.
2. **Phase 2 — DB dual-source procs (sites 10–11).** Patch `fin_GetStudentLedger` / `fin_GetLimitedStudentLedger`; verify their callers.
3. **Phase 3 — Converge the DIVERGENT DB functions (Track 2).** Introduce the canonical function/view; point `fin_TotalPayments`, `fin_GetNewFeesBalance`, the `fin_Get*Balance` family, `payment_analytics`, and `api/Default.aspx` at it; deprecate duplicates. (Higher risk → do behind tests, one routine at a time, with before/after spot-checks.)
4. **Phase 4 — Track 3 permanent cure.** Shared-key at posting + back-fill + nightly reconciliation + import freeze.

**Acceptance test (every phase):** for a known set incl. **`MRU2024002056`** (must read **billed 4,614,000 / paid 4,614,000 / balance 0**) and 4–5 migration-heavy students, **every** surface — admin grid & drilldown, portal statement, portal dashboard KPIs, registration gate, public API, DB functions — returns the **same** balance as `fin_student_balance_cache` (the canonical materialisation).

---

## 6. Verification queries (per student, any phase)

```sql
-- canonical (truth) for a student
SELECT SUM(dr) billed, SUM(cr) paid, SUM(cr)-SUM(dr) balance FROM (
  SELECT CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END dr,
         CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END cr
  FROM fin_ledger WHERE accountcode=@reg AND transaction_amount>0
  UNION ALL
  SELECT CASE WHEN t.trans_type='Bill' THEN t.amount ELSE 0 END,
         CASE WHEN t.trans_type='Payment' THEN t.amount ELSE 0 END
  FROM fin_studentfeestracking t
  WHERE t.regno=@reg AND t.post_status='Posted'
    AND NOT EXISTS (SELECT 1 FROM fin_ledger fl2 WHERE fl2.accountcode=t.regno
      AND (fl2.voucherNo=CAST(t.TID AS CHAR) OR fl2.folio=CONCAT('BillNo:',CAST(t.TID AS CHAR))
        OR (fl2.transaction_amount=t.amount AND DATE(fl2.transactionDate)=DATE(t.trans_date)
            AND fl2.transactionType=CASE WHEN t.trans_type='Payment' THEN 'CR' ELSE 'DR' END
            AND (t.trans_type='Payment' OR fl2.particulars=t.detail OR t.detail IS NULL OR t.detail=''))))
) x;
-- compare to cache:
SELECT total_billed, total_paid, total_balance FROM fin_student_balance_cache WHERE regno=@reg;
```

---

## 7. Risks & guardrails

| Risk | Guardrail |
|---|---|
| Editing DB functions affects many callers | Phase 3 only; one routine at a time; before/after spot-checks; keep `_legacy` copies. |
| Over-collapsing genuine same-day, same-amount payments | The real cure is Track 3 (shared key); until then dedup stays 1:1 on key first, amount+date last. |
| Portal can't reference COOPERP engine | Single portal helper holding identical SQL (Track 2). |
| Registration gate / fee-access change behaviour | `FeeAccessHelper` + `SemesterRegistrationWizardService` fixes make gates **more** correct (fewer false "overpaid/clear"); test the 234 restored-credit students. |
| Ledger-only funcs reflect in-ledger duplicates | Track 2 convergence + the in-ledger dedup cleanup from `MIGRATION_TRANSACTIONS_ANALYSIS.md` (299 groups). |

---

## 8. Summary

- **API layer: already correct** (delegates to the canonical engine).
- **Track 1 (one-line Fix B) clears the active double-count** on **9 app sites + 2 DB procs** — this is what stops false "overpaid" everywhere students/staff actually look.
- **Track 2 (one canonical computation per layer)** ends the fragmentation that let this bug exist in ~30 places.
- **Track 3 (shared key + reconciliation)** removes the root cause so duplicates are never created again.
- **Definition of done:** every surface returns the **same** number as `fin_student_balance_cache`, and the model student `MRU2024002056` reads **0** everywhere.

*Awaiting approval to execute Phase 1 (the 9 app-code one-line fixes) — fast and low-risk. Phases 2–4 staged after.*

---

## 9. Execution record — Phases 1 & 2 (2026-06-25)

**Phase 1 — app code (DONE):**
| File | Site | Change |
|---|---|---|
| `COOPERP/NewScreens/BillWaivers.aspx.cs` | `ComputeUnionAllBalance` | Fix B applied. (`HandleLoadBills` is bills-only → correctly **left strict**.) |
| `COOPERP/NewScreens/DoubleBillingController.aspx.cs` | `DB_ComputeBalance` | **Rewritten to canonical** (added unmirrored tracking *payments* + Fix B; was bills-only). |
| `Portal/StudentFees.aspx.cs` | `LoadLedger` | Fix B applied. |
| `Portal/StudentFees.aspx.cs` | `ComputeUnionAllBalance` | **Rewritten to canonical** (was bills-only). |
| `Portal/App_Code/Portal/FeeAccessHelper.cs` | `Evaluate` | Fix B applied. |
| `Portal/App_Code/Portal/SemesterRegistrationWizardService.cs` | `GetStudentOutstandingBalance` | Fix B (+Waiver). |
| `Portal/UserControls/Financials/StudentLedger.ascx.cs` | `LoadLedger` | Fix B applied. |
| `Portal/UserControls/Security/SystemApplications_Modern.ascx.cs` | `LoadFinancialKPIs` | Fix B (+Waiver). |

`RegistrationWizardController.HandleGetBalance` needs no edit (delegates to `FeeAccessHelper`).

**Phase 2 — DB procedures (DONE, live):**
- `fin_GetStudentLedger` — Fix B applied live (backup `COOPERP/sql/_backup_fin_GetStudentLedger_20260625.sql`, apply `COOPERP/sql/balance_read_fix_fin_GetStudentLedger.sql`). Verified present.
- `fin_GetLimitedStudentLedger` — **already correct** (it suppresses SB/CB migration twins *and* its tracking dedup already includes `OR t.trans_type IN ('Payment','Waiver')`). No change.

**Tests (live DB):**
- **Model `MRU2024002056`:** BUGGY paid 6,549,000 → balance −1,935,000 (the false overpaid); **FIXED paid 4,614,000 → balance 0** ✓ (matches cache & StudentLedgerExport).
- Migration-heavy: `MRU2024001364` −2,834,400 doubles removed (cache +783,000); `MRU2023000651` −1,673,000 (cache +221,000); `MRU2023001406` −2,475,000 (cache +140,000) — fixed paid matches the canonical cache ✓.

**Deployment note:** the C# edits take effect when the **COOPERP** and **Portal** apps are rebuilt/redeployed; the `fin_GetStudentLedger` DB fix is **live now**.

## 10. Execution record — Phase 3 (2026-06-25, live, low blast-radius)

**Blast-radius check first:** `fin_GetCurrentFeesBalance` used by portal `api/Default.aspx` + 2 DB procs (`fin_StudentClearance`, `fin_CreateGraduationClearanceList`); `fin_GetCurrentStudentBalance` had no server-side callers; no COOPERP/`API v2` callers. `fin_StudentClearance` parses the **string** (`LIKE '%CREDIT'`) → format must be preserved.

**Applied (DONE, live):**
- **`fin_GetCanonicalStudentBalance(reg)` → DECIMAL** — new, additive single source of truth (dual-source + Fix B; billed−paid, owing positive).
- **`fin_GetCurrentFeesBalance`** and **`fin_GetCurrentStudentBalance`** now **delegate** to it, keeping their exact `"X CREDIT"/"X DEBIT"` string output. Only the number became canonical → portal public API balance and graduation/registration clearance are now consistent with every other surface.
- Backup `COOPERP/sql/_backup_balance_funcs_20260625.sql`; apply `COOPERP/sql/balance_read_phase3_canonical_funcs.sql`.

**Verified:** `MRU2024002056` → canonical 0 → "0 CREDIT" (cache 0); `MRU2024001364` → canonical −783,000 → "783,000 CREDIT" (cache +783,000). Consistent.

**Deferred for stability (documented, not changed):**
- `fin_TotalPayments` (period payments, tracking-only) and `fin_GetNewFeesBalance` (period, tracking-only) — period-specific semantics; **not** a double-count source (single store). Need a *period-aware* canonical before converging; left as-is.
- `fin_GetFeesBalance`, `fin_GetLimitedStudentBalance`, `fin_GetSFPBalance`, `payment_analytics` view — require individual caller analysis; left as-is.
- **Track 3 (permanent cure):** shared reference key at posting/import (GL `voucherNo`=tracking `TID`) + back-fill + nightly reconciliation + import freeze — the only thing that stops duplicates being *created*. Still recommended next.

**Net status:** every **dual-source** reader across app + API + the two student-ledger DB procs + the two current-balance DB functions now use the identical canonical dedup. Remaining items are single-source/period helpers that don't double-count, plus the structural permanent cure.

## 11. Track 3 (monitoring) + Fee Administration page convergence (2026-06-25)

**Track 3 — recommended permanent cure, done in its STABLE form:**
- **Reconciliation view (live, read-only):** `v_student_fee_reconciliation` (`COOPERP/sql/balance_reconciliation_view.sql`) — per student: canonical (cache) vs ledger-only vs tracking-only, to surface any drift/residual duplication instantly. Zero risk (a view). Verified (e.g. `MRU2024001364`: canonical 783,000 vs ledger-only 3,617,400 → the in-ledger dup inflation is now visible).
- **Staged (NOT applied — needs a coordinated, separately-tested change):** the *shared reference key at posting/import* (GL `voucherNo`=tracking `TID`) + 1:1 back-fill + nightly reconciliation job + import freeze. This is the only thing that stops duplicates being *created*; deferred deliberately for stability (touches posting paths + a historic data back-fill). Recommended as the next dedicated change.

**Fee Administration submenu (School Fees) — audited all 12 pages; converged the contradicting per-student/decision surfaces to the canonical cache:**

| Page | Finding | Action |
|---|---|---|
| `FeeAccessPolicyPreviewService.cs` (FeeAccessPolicy.aspx preview) | **ledger-only** bulk balance → wrong pass/fail; missed tracking-only students | **Fixed** → reads `fin_student_balance_cache` |
| `OtherFeesBilling.aspx` balance picker | tracking-only, year-scoped → different balance than StudentLedgers | **Fixed** → canonical cache (all-time owing) |
| `FeesManagement.aspx` `LoadTopDebtors` | tracking-only, year-scoped per-student ranking | **Fixed** → canonical cache, ranked by `total_balance ASC` among ACTIVE |
| `FeeAccessChecker.aspx` | delegates to API (→ FinanceEngine) | already canonical |
| `FeesStructure.aspx`, `FeesAuditTrail.aspx`, `ActiveStudents.aspx` | config / audit / redirect — no balance | N/A |
| `FeesManagement.aspx` hero KPIs, fee-type breakdown, payment-trend charts | **year-scoped operational aggregates** with an intentional cash/bursary/waiver split; tracking-only so they **do not double-count or show overpaid** | **Left by design** (distinct lens, not a per-student balance) — documented |
| `FeesRegistration.aspx` per-semester billed/paid grid | legitimately **per-semester** (not all-time balance) | **Left by design** — documented |

**Principle established:** any surface that shows a **specific student's balance, ranks/filters students by balance, or gates access by balance** uses the **canonical** method (FinanceEngine in code, `fin_student_balance_cache` for fast/bulk reads) and therefore agrees everywhere. Pages that show **period/operational aggregates** keep their scope but are tracking-only (no double-count, no false overpaid). 

**Verified (live):** model `MRU2024002056` = 0 across canonical; canonical Top-Debtors and access-preview read the same cache the StudentLedgers grid and portal use.

**Deploy:** all C# edits (this section + Phases 1–3 app code) take effect on **COOPERP + Portal rebuild/redeploy**; the DB view/function/proc changes are **live now**. The balance cache refreshes on its 5-min TTL (or via StudentLedgers `EnsureBalanceCache`).

## 12. Printed Student Ledger report — `fin_GetLimitedStudentLedger` (2026-06-26, live)

The DevExpress **StudentLedger** report (`App_Code/.../StudentLedger.cs`, query named `…fin_GetStudentLedger` but actually calling **`fin_GetLimitedStudentLedger`**) reconciled with the canonical balance for the model and most students, but a **rare-edge contradiction** was found: for students with a **duplicate same-day tracking payment**, its SB/CB display-suppression hid the single bank ledger row (step 1) while adding *both* tracking twins (step 2) → over-credit. Example `MRU2024001364`: report **803,000CR** vs canonical **783,000CR** (+20,000).

**Fix (live, surgical, full routines backup `_backup_routines_20260626.sql`):** aligned the proc's dedup to the canonical —
1. keep **all** `fin_ledger` rows (removed step-1 SB/CB suppression);
2. step-2 tracking dedup now matches **any** ledger row (removed the SB/CB exclusion), so a tracking twin of a kept bank row is suppressed → counted once;
3. cosmetic: kept bank/cash credit rows are relabelled **"Fees Payment (Bank/Cash Collection)"** on the printout (so they don't show the student's name).
Apply script: `COOPERP/sql/balance_fix_fin_GetLimitedStudentLedger.sql`.

**Verified (live, report closing == canonical):** `MRU2024002056` 0CR=0; `MRU2024001364` 783,000CR=783,000; `MRU2023000651` 221,000CR=221,000; `MRU2023001406` 140,000CR=140,000. The printed statement now reconciles exactly with StudentLedgers / the portal / the cache.
