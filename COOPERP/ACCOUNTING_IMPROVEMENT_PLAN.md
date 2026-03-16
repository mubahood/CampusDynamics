# Accounting Module — Improvement Plan

> **Database**: `campus_dynamics_accounts` (MySQL)  
> **Module**: `COOPERP/accounts/AccountingCenter.aspx` + standalone pages  
> **Created**: March 16, 2026  
> **Principle**: ZERO data loss — all improvements preserve existing 139,032 ledger records

---

## Table of Contents

1. [How Double-Entry Works in This System](#1-how-double-entry-works-in-this-system)
2. [What Is Broken](#2-what-is-broken)
3. [How We Work](#3-how-we-work)
4. [Action Plan](#4-action-plan)
5. [Technical Reference](#5-technical-reference)

---

## 1. How Double-Entry Works in This System

### The Fundamental Rule

Every financial transaction in this system follows the **Double-Entry Bookkeeping** principle:

> **For every Debit (DR), there must be an equal and opposite Credit (CR).**  
> For any given voucher, the sum of all DR amounts must exactly equal the sum of all CR amounts.

This is not optional — it is the mathematical foundation that makes the accounting equation hold:

$$\text{Assets} = \text{Liabilities} + \text{Equity}$$

### How It Lives in the Database

The central table is `fin_ledger`. Every financial event produces **at least 2 rows** in this table — one DR and one CR — linked by the same `voucherNo`:

```
fin_ledger table:
┌──────┬─────────────┬────────────────┬──────────────────┬───────────┐
│ TID  │ accountcode │ transactionType│ transaction_amount│ voucherNo │
├──────┼─────────────┼────────────────┼──────────────────┼───────────┤
│ 1001 │ MRU2024001  │ CR             │ 2,000,000        │ 43679     │  ← Student account credited (debt reduced)
│ 1002 │ AC1303      │ DR             │ 2,000,000        │ 43679     │  ← Bank account debited (cash received)
└──────┴─────────────┴────────────────┴──────────────────┴───────────┘
                                                           ↑
                                              Same voucherNo links them
```

The `transactionType` column is either `DR` or `CR`. The `transaction_amount` is always a positive integer (BIGINT UNSIGNED). The direction of money movement is determined by the type, not the sign.

### The Journal-to-Ledger Pipeline

Every transaction follows this pipeline:

```
1. JOURNAL CREATED  →  fin_journalnumbers (header: who, when, what type)
        │                   ↓ JournalNo (PK, auto-increment)
        │                   ↓ GL_VoucherNo (the public voucher number)
        │
2. LEDGER LINES     →  fin_ledger (individual DR and CR entries)
        │                   ↓ voucherNo = fin_journalnumbers.GL_VoucherNo
        │                   ↓ journal_no = fin_journalnumbers.JournalNo (zero-padded char)
        │
3. APPROVAL          →  fin_journalnumbers.PostStatus set to 'Posted'
        │
4. BALANCE UPDATE   →  fin_UpdateAllLedgerBalances recalculates running totals
```

### Transaction Types and Their Double-Entry

| Transaction | DR (Debit) Account | CR (Credit) Account | Effect |
|------------|-------------------|---------------------|--------|
| **Student pays fees** | Bank (AC1303) | Student (MRU2024001) | Bank ↑, Student debt ↓ |
| **Sponsor pays for student** | Bank (AC1303) | Sponsor account | Bank ↑, Sponsor obligation ↓ |
| **Payment to supplier** | Expense (AC2001) | Bank (AC1303) | Expense ↑, Bank ↓ |
| **General journal** | Any account | Any account | Flexible — user chooses both sides |
| **Bank transfer (Contra)** | Destination Bank | Source Bank | One bank ↑, other bank ↓ |
| **Transaction reversal** | Original CR account | Original DR account | Reverses the original flow |

### The Five Account Categories

The Chart of Accounts (`fin_mainaccounts`) defines 5 top-level categories that mirror standard accounting:

| Code | Category | Normal Balance | DR Effect | CR Effect |
|------|----------|---------------|-----------|-----------|
| AC1xxx | **Assets** (Cash, Bank, Receivables) | Debit | Increase | Decrease |
| AC2xxx | **Expenses** (Operating, Admin, Academic) | Debit | Increase | Decrease |
| AC6xxx | **Income** (Tuition, Fees) | Credit | Decrease | Increase |
| AC7xxx | **Equity** (Retained earnings) | Credit | Decrease | Increase |
| AC9xxx | **Liabilities** (Payables, Current) | Credit | Decrease | Increase |

Each main category has sub-accounts in `fin_subaccounts` (265 accounts), plus student accounts (MRU#### format) that live in the main `campus_dynamics` database.

### How a Student Receipt Flows Through the System

```
USER ACTION: Student MRU2024001364 pays UGX 2,000,000 via Centenary Bank

1. Journal Centre (pid=4)
   → User selects: Journal Type = "Receipt", Document Type = "Student Receipt"
   → System inserts: fin_journalnumbers row (GL_VoucherNo = 43679, PostStatus = 'Pending')
   → Popup opens: StudentReceipt.aspx

2. StudentReceipt.aspx
   → User enters: Student = MRU2024001364, Bank = AC1303, Amount = 2,000,000
   → System calls: AddJournalDetails("CR", MRU2024001364, 2000000, 43679)
                    AddJournalDetails("DR", AC1303, 2000000, 43679)
   → fin_ledger now has 2 rows for voucherNo 43679
   
3. Approval
   → Administrator/Bursar clicks "Approve"
   → System calls: fin_ApproveJournal(43679)
   → PostStatus changes to 'Posted'
   → fin_UpdateAllLedgerBalances() recalculates running balances

4. Result
   → The student's ledger shows -2,000,000 (credit = debt reduced)
   → The bank ledger shows +2,000,000 (debit = cash received)
   → Trial Balance: Total DR = Total CR (balanced)
   → The accounting equation holds ✓
```

### The Balance Verification Test

At any point, this query should return zero for every voucher:

```sql
SELECT voucherNo,
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) as total_DR,
    SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) as total_CR
FROM fin_ledger
GROUP BY voucherNo
HAVING ABS(total_DR - total_CR) > 0;
-- Should return ZERO rows in a healthy system
```

**Current reality: This query returns 2,906 rows** — the system has 2,906 vouchers where DR ≠ CR, violating the fundamental accounting principle.

---

## 2. What Is Broken

### Data-Level Findings (from live database audit)

| # | Finding | Count | Severity | Root Cause |
|---|---------|-------|----------|------------|
| D1 | Unbalanced vouchers (DR ≠ CR) | 2,906 of 70,790 (4.1%) | CRITICAL | No balance validation before posting |
| D2 | Global DR/CR imbalance | UGX 753,502,285 | CRITICAL | Accumulation of unbalanced vouchers |
| D3 | One-sided reconciliation entries | 3 entries, UGX 1.598B | CRITICAL | Manual recon entries with no CR side |
| D4 | Orphan ledger entries (no journal) | 121,898 of 139,032 (87.7%) | HIGH | Student fee billing bypasses journal system |
| D5 | Orphan account codes (not in subaccounts) | 68,058 (97.9% are student IDs) | EXPECTED | Student IDs (MRU####) stored in different database — by design |
| D6 | Empty journals (no ledger entries) | 616 | MODERATE | Abandoned entries, browser crashes, `CleanJournalDetails` race condition |
| D7 | Zero/null amount entries | 50 | LOW | No CHECK constraint on transaction_amount |
| D8 | Only 1 financial period defined | 2025/2026 only | MODERATE | 2023/2024 data has no period controls |
| D9 | No foreign keys on fin_ledger | 0 FKs | CRITICAL | Referential integrity not enforced at DB level |
| D10 | No indexes on voucherNo, journal_no | Missing | MODERATE | Slow joins, bad query performance |

### Code-Level Findings (from source code audit)

| # | Finding | Scope | Severity | Root Cause |
|---|---------|-------|----------|------------|
| C1 | ZERO database transactions anywhere | All 7 transaction files | CRITICAL | Multi-step writes with no atomicity — partial records on any failure |
| C2 | PaymentVoucher conditionally skips CR entry | PaymentVoucher.aspx.cs L55-58 | CRITICAL | `if (rb_payeetype.SelectedIndex == 0)` — only adds CR when index is 0 |
| C3 | Anyone can clear entire ledger | LedgersCentre.ascx.cs L147-152 | CRITICAL | No authorization check on `fin_ClearLedger` |
| C4 | Anyone can reverse transactions | LedgersCentre.ascx.cs L88-104 | HIGH | No role check on `fin_TransactionReversal` |
| C5 | Silent exception swallowing | 20+ catch blocks across module | CRITICAL | `catch (Exception) { }` hides errors and corruption |
| C6 | `CleanJournalDetails()` on every page load | JournalCentre.ascx.cs L15-16 | HIGH | Destroys other users' in-progress work |
| C7 | Financial period not checked on most pages | 6 of 7 transaction pages | HIGH | Only CreateJournal.aspx.cs checks; all others skip |
| C8 | No input validation on amounts | All transaction pages | HIGH | `decimal.Parse(txtAmount.Text)` with no TryParse or range check |
| C9 | `throw ex` destroys stack traces | AccountsBLL.cs (7 instances) | MODERATE | Should be `throw;` to preserve original stack |
| C10 | No audit logging on most operations | All except partial in LedgersCentre | HIGH | No `acc_activity_log` writes from transaction pages |
| C11 | No double-entry balance check before approval | All approval flows | CRITICAL | Journals can be approved while unbalanced |
| C12 | Race conditions on grid row references | All popup transaction pages | MODERATE | `gvParticulars.GetRowValues(0, ...)` assumes row 0 is the user's entry |

---

## 3. How We Work

### Process

We work through the action plan **top-to-bottom**, one task at a time. Each task follows this cycle:

```
1. PICK the next Pending task (top-down, respecting dependencies)
2. STATUS → "In Progress"
3. IMPLEMENT the change
4. TEST — verify the fix works and nothing is broken
5. STATUS → "Done"
6. COMMIT with a clear message referencing the task ID
7. MOVE to the next task
```

We do **not** skip ahead. We do **not** start a child task before its parent is done. We do **not** mark "Done" until tested.

### Database Changes: Migrations Only

Every database structure change (ALTER TABLE, CREATE INDEX, CREATE PROCEDURE, etc.) is done through the **SQL-first migration system** already built into this project:

```powershell
# Create a new migration for the accounts database
.\database\cd-db.ps1 make:migration <descriptive_name> -Database accounts

# This creates a file at:
# database/migrations/YYYYMMDD_HHMMSS__accounts__<descriptive_name>.up.sql

# Write the SQL in that file, then apply:
.\database\cd-db.ps1 migrate -Database accounts

# Preview without executing:
.\database\cd-db.ps1 migrate -Database accounts -DryRun
```

The migration system tracks execution history in `cd_schema_migrations` table. Migrations are:
- **Ordered** by timestamp filename
- **Idempotent** — safe to run again
- **Auditable** — tracked in migration history
- **Reversible** — each `.up.sql` should have a corresponding `.down.sql` when destructive

We NEVER run raw ALTER TABLE statements directly on the database. Everything goes through a migration file.

### Testing After Each Task

After each task is implemented:

1. **Verify the specific fix** — run the relevant diagnostic query or test the specific page
2. **Run the balance verification check** — ensure no NEW unbalanced vouchers were created
3. **Smoke test the transaction flow** — create a test journal entry end-to-end if applicable
4. **Check for regressions** — verify other pages still work

### Status Values

| Status | Meaning |
|--------|---------|
| `Pending` | Not yet started |
| `In Progress` | Currently being worked on (only ONE task at a time) |
| `Done` | Implemented, tested, and committed |
| `Blocked` | Cannot proceed — dependency not met or needs external input |

---

## 4. Action Plan

### Group A: Database Foundation (must be done first — all other work depends on this)

These tasks make the database faster, safer, and properly structured. They are prerequisites for everything else because code fixes need proper indexes and constraints to work correctly.

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| A1 | Create data audit snapshot tables | — | `Done` | Migration | Snapshot `fin_ledger`, `fin_journalnumbers`, `fin_subaccounts`, `fin_mainaccounts` into `*_audit_snapshot_20260316` backup tables. Preserves current state before any changes. |
| A2 | Add missing indexes to `fin_ledger` | A1 | `Done` | Migration | Add indexes on `voucherNo`, `journal_no`, `transactionDate`, `accountcode+transactionDate`. Zero-risk, immediate performance improvement. |
| A3 | Add missing indexes to `fin_journalnumbers` | A1 | `Done` | Migration | Add indexes on `GL_VoucherNo`, `PostStatus`, `journalDate`. |
| A4 | Add missing financial periods | A1 | `Done` | Migration | Insert `2023/2024` (Closed) and `2024/2025` (Closed) into `fin_financial_years`. The `2025/2026` (Open) already exists. |
| A5 | Add CHECK constraints to `fin_ledger` | A2 | `Done` | Migration | MySQL 5.6 doesn't enforce CHECK — used BEFORE INSERT/UPDATE triggers instead. Rules: `transaction_amount > 0`, `transactionType IN ('DR','CR')`, `accountcode != ''`. |
| A6 | Add `void_reason` column to `fin_journalnumbers` | A3 | `Done` | Migration | `ALTER TABLE fin_journalnumbers ADD COLUMN void_reason VARCHAR(100) DEFAULT NULL`. Needed for voiding empty journals. |
| A7 | Create `fin_repair_log` table | A1 | `Done` | Migration | Tracking table for all data repairs: `repair_id`, `repair_type`, `voucherNo`, `original_dr`, `original_cr`, `difference`, `action_taken`, `repaired_by`, `repair_date`. |

### Group B: Stop the Bleeding (code fixes that prevent NEW bad data)

These fix the most dangerous active bugs. They must come after Group A because the indexes are needed for the validation queries, and the constraints provide a safety net.

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| B1 | Fix PaymentVoucher double-entry violation | A5 | `Done` | Code | `PaymentVoucher.aspx.cs` — removed the `if (rb_payeetype.SelectedIndex == 0)` conditional. Both DR and CR now ALWAYS inserted. |
| B2 | Remove `CleanJournalDetails()` from Page_Load | A6 | `Done` | Code | `JournalCentre.ascx.cs` — removed destructive cleanup call from Page_Load. Was deleting orphaned `fin_journal_details` on every request. |
| B3 | Lock down "Clear Ledger" — require Administrator | A1 | `Done` | Code | `LedgersCentre.ascx.cs` — added Administrator-only guard before `fin_ClearLedger`. |
| B4 | Lock down "Reverse Transaction" — require Bursar | A1 | `Done` | Code | `LedgersCentre.ascx.cs` — added `IsInRole("Administrator") || IsInRole("Bursar")` guard before `fin_TransactionReversal`. |
| B5 | Fix silent exception swallowing — StudentReceipt | A1 | `Done` | Code | `StudentReceipt.aspx.cs` — fixed 3 catches: show `ex.Message` instead of generic/empty error handling. |
| B6 | Fix silent exception swallowing — PaymentVoucher | B1 | `Done` | Code | `PaymentVoucher.aspx.cs` — fixed 3 catches: show `ex.Message` instead of generic/empty error handling. |
| B7 | Fix silent exception swallowing — CreateJournal | A1 | `Done` | Code | `CreateJournal.aspx.cs` — fixed 1 empty catch in ButtonManager: shows default button state on failure. |
| B8 | Fix `throw ex` → `throw` in AccountsBLL | A1 | `Done` | Code | `AccountsBLL.cs` — fixed 7 instances of `throw ex` to `throw` (preserves stack trace). |
| B9 | Add financial period validation to StudentReceipt | A4 | `Done` | Code | `StudentReceipt.aspx.cs` — added `IsInOpenFinancialPeriod()` check at top of `AddNewItem_Click`. Blocks transactions outside open period. |
| B10 | Add financial period validation to SponsorReceipt | A4 | `Done` | Code | `SponsorReceipt.aspx.cs` — same pattern as B9. |
| B11 | Add financial period validation to PaymentVoucher | A4, B1 | `Done` | Code | `PaymentVoucher.aspx.cs` — same pattern as B9. |
| B12 | Add financial period validation to ContraVoucher | A4 | `Done` | Code | `ContraVoucher.aspx.cs` — same pattern as B9. |
| B13 | Add financial period validation to LedgersCentre | A4 | `Done` | Code | `LedgersCentre.ascx.cs` — blocks ALL ledger operations (reverse, correct, cancel, clear) outside open period. Added `using CoopERPDataTableAdapters`. |

### Group C: Transaction Atomicity (wrap all multi-step writes in DB transactions)

This group makes every financial operation atomic — either ALL steps succeed, or NONE do. This prevents the orphaned/partial records that are the root cause of most data corruption. Depends on Group B because we need the bugs fixed before wrapping them in transactions.

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| C1 | Add TransactionScope to StudentReceipt.AddNewItem_Click | B5, B9 | `Done` | Code | Wrapped `AddJournalDetails(CR)`, `AddJournalDetails(DR)`, `UpdateParticulars`, `UpdateJournalAmounts` in `TransactionScope`. Added `using System.Transactions` and `System.Transactions` assembly to web.config. |
| C2 | Add TransactionScope to SponsorReceipt.AddNewItem_Click | B10 | `Done` | Code | Same pattern as C1. |
| C3 | Add TransactionScope to CreateJournal.cmdCreateNew_Click | B7 | `Done` | Code | Wrapped `fin_CreateJournal` + `UpdateRefNo` in TransactionScope. |
| C4 | Add TransactionScope to PaymentVoucher.AddNewItem_Click | B1, B6, B11 | `Done` | Code | Same pattern as C1. |
| C5 | Add TransactionScope to ContraVoucher.AddNewItem_Click | B12 | `Done` | Code | Same pattern as C1. |
| C6 | Add TransactionScope to LedgersCentre.cmdProcess_Click | B3, B4, B13 | `Done` | Code | Wrapped reversal loop, correction loop, cancellation loop each in own TransactionScope. Return without Complete() on auth failure = automatic rollback. |
| C7 | Add input validation to all transaction pages | C1, C2, C3, C4, C5 | `Done` | Code | Added non-empty account/payee checks + `decimal.TryParse` + range (>0, <10B UGX) to StudentReceipt, SponsorReceipt, PaymentVoucher, ContraVoucher. CreateJournal: account + transaction type checks. |

### Group D: Double-Entry Enforcement at Database Level (make it impossible to create bad data)

After code-level fixes (Groups B-C), we enforce the rules at the database level so that even if code has a bug, the database itself rejects unbalanced entries.

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| D1 | Create `fin_ValidateAndPostJournal` stored procedure | A5 | `Done` | Migration | New SP that checks: (1) at least 2 ledger lines, (2) SUM(DR) = SUM(CR), (3) financial period is open. Only if all pass → set PostStatus = 'Posted'. Returns error message on failure. |
| D2 | Create `fin_ApproveJournal_Safe` stored procedure | D1 | `Done` | Migration | Replacement for existing `fin_ApproveJournal`. Adds balance verification + period check + audit log entry before approving. This becomes the SINGLE gate for all approvals. |
| D3 | Update StudentReceipt to use `fin_ApproveJournal_Safe` | D2, C1 | `Done` | Code | Replace `fin_ApproveJournal` call with `fin_ApproveJournal_Safe`. Check the OUT parameter for errors and display to user. |
| D4 | Update SponsorReceipt to use `fin_ApproveJournal_Safe` | D2, C2 | `Done` | Code | Same as D3. |
| D5 | Update CreateJournal to use `fin_ApproveJournal_Safe` | D2, C3 | `Done` | Code | Same as D3. Updated JournalDisplay.aspx.cs, ViewJournal.aspx.cs |
| D6 | Update PaymentVoucher to use `fin_ApproveJournal_Safe` | D2, C4 | `Done` | Code | Same as D3. Updated PaymentVoucher.aspx.cs, DisplayPaymentVoucher.aspx.cs |
| D7 | Update ContraVoucher to use `fin_ApproveJournal_Safe` | D2, C5 | `Done` | Code | Same as D3. Also updated SponsorshipDistribution.aspx.cs |
| D8 | Create ledger modification trigger | A7 | `Done` | Migration | `AFTER UPDATE` trigger on `fin_ledger` — logs old/new values to `edit_ledger` for every change. |
| D9 | Create ledger deletion trigger | A7 | `Done` | Migration | `BEFORE DELETE` trigger on `fin_ledger` — archives deleted rows to `fin_deleted_ledger` before removal. No hard deletes. |

### Group E: Data Repair (fix existing corruption without losing records)

Now that we've stopped creating new bad data (Groups B-D), we repair the existing problems. Every repair is logged in `fin_repair_log`.

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| E1 | Log all 2,906 unbalanced vouchers to repair table | A7, D1 | `Done` | Migration | INSERT into `fin_repair_log` with each voucher's DR total, CR total, and difference. Status = 'PENDING_REVIEW'. |
| E2 | Fix 3 massive one-sided recon entries (60407, 60408, 60411) | E1 | `Done` | Manual + Migration | Migration inserts offsetting entries to AC-RECONCILE-DIFF dynamically. Down migration provided for rollback. Bursar should verify post-run. |
| E3 | Void 616 empty journals | A6, E1 | `Done` | Migration | Set `PostStatus = 'Void'` and `void_reason = 'Auto-voided: No ledger entries (2026 audit)'` for journals with no matching ledger entries. |
| E4 | Create `v_all_accounts` view | A1 | `Done` | Migration | View that unions `fin_subaccounts` (chart accounts) with `campus_dynamics.acad_student` (student IDs). Resolves the 68K "orphan" account codes by providing a single lookup source. |
| E5 | Analyze and categorize remaining unbalanced vouchers | E1, E2 | `Done` | Research | Migration classifies each entry into: VOID_INCOMPLETE, INSERT_OFFSETTING_CR/DR, INSERT_CORRECTIVE_ENTRY, MANUAL_REVIEW_STUDENT_RECEIPT. Writes strategy to fin_repair_log. |
| E6 | Execute batch repair of categorized unbalanced vouchers | E5 | `Done` | Migration | Batch repair processes all strategy categories. Voids single-line journals; inserts corrective entries to AC-RECONCILE-DIFF for all others; skips MANUAL_REVIEW items. Calls fin_UpdateAllLedgerBalances() after. |

### Group F: Audit Trail Enhancement (full accountability)

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| F1 | Enhance `acc_activity_log` table | A1 | `Done` | Migration | Add columns: `ip_address VARCHAR(45)`, `session_id VARCHAR(100)`, `affected_voucherNo INT`, `affected_amount DECIMAL(18,2)`, `before_value TEXT`, `after_value TEXT`. Add indexes on `access_date`, `user_id`, `page_function`. |
| F2 | Create `AuditLogger.cs` centralized logging class | F1 | `Done` | Code | Static class `AuditLogger.Log(action, details, voucherNo?, amount?, before?, after?)` that writes to `acc_activity_log` with IP + session ID. |
| F3 | Add audit logging to StudentReceipt | F2, D3 | `Done` | Code | Log: RECEIPT_CREATED (on post). Approval logged by SP. |
| F4 | Add audit logging to SponsorReceipt | F2, D4 | `Done` | Code | Log: SPONSOR_RECEIPT_CREATED. |
| F5 | Add audit logging to CreateJournal | F2, D5 | `Done` | Code | Log: JOURNAL_CREATED. Approval logged by SP. |
| F6 | Add audit logging to PaymentVoucher | F2, D6 | `Done` | Code | Log: VOUCHER_CREATED. |
| F7 | Add audit logging to ContraVoucher | F2, D7 | `Done` | Code | Log: CONTRA_CREATED. |
| F8 | Add audit logging to LedgersCentre adjustments | F2, C6 | `Done` | Code | Log: TRANSACTION_REVERSED (with reason), AMOUNT_CORRECTED (old→new), TRANSACTION_CANCELLED, LEDGER_CLEARED. |
| F9 | Add audit logging to ReceiptCentre | F2 | `Done` | Code | Log: RECEIPT_DELETED (with voucher number). |
| F10 | Add audit logging to JournalCentre | F2 | `Done` | Code | Log: JOURNAL_DELETED (with journal number, type, status). |

### Group G: UI/UX Improvements (make the system usable)

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| G1 | Build financial dashboard (Homescreen replacement) | E1, F1 | `Done` | Code | Replace blank Homescreen.ascx with summary cards (Total DR, Total CR, Balance, Pending Journals), recent transactions list, and alerts panel (unbalanced entries, pending approvals). |
| G2 | Add real-time DR/CR balance indicator to CreateJournal | D5 | `Done` | Code | Show running "Total DR / Total CR / Balance" below the journal lines grid. Disable "Approve" button when unbalanced. |
| G3 | Add real-time balance indicator to all transaction pages | G2, D3-D7 | `Done` | Code | Apply the G2 pattern to StudentReceipt, SponsorReceipt, PaymentVoucher, ContraVoucher. |
| G4 | Add confirmation dialogs to destructive operations | C6, F8 | `Done` | Code | LedgersCentre: confirm before reverse, correct, cancel, clear. JournalCentre/ReceiptCentre: confirm before delete. Show what will happen. |
| G5 | Simplify navigation menu | G1 | `Done` | Code | Restructure MasterPage.master menu from 6 nested sections to 4 clear sections: Dashboard, Transactions, Ledgers & Reports, Settings. |
| G6 | Add global transaction search | F1 | `Done` | Code | Search bar in MasterPage that queries `fin_ledger` + `fin_journalnumbers` by voucher number, student ID, amount, or date. Results link to TransactionDetails popup. |
| G7 | Replace popup-based transaction flow with inline wizard | G3, G4 | `Pending` | Code | Transaction pages render inline in the AccountingCenter panel instead of as separate popup windows. Step-by-step wizard: Select Type → Enter Details → Review Double-Entry → Post. |

### Group H: Ongoing Monitoring (permanent safeguards)

| ID | Task | Depends On | Status | Type | Details |
|----|------|-----------|--------|------|---------|
| H1 | Create daily balance verification event | D1 | `Done` | Migration | MySQL scheduled event that runs daily. Checks all posted vouchers for DR = CR. Logs any violations to `acc_activity_log`. |
| H2 | Create monthly reconciliation summary procedure | E6 | `Done` | Migration | Stored procedure that generates DR/CR totals per main account category for a given month. Used for monthly closing review. |
| H3 | Add validation queries to database.settings.json | D1, D2 | `Done` | Config | Add validation queries for the accounts database: "All posted vouchers balanced", "No zero-amount entries", "Financial periods defined". Run via `.\database\cd-db.ps1 validate`. |

---

## 5. Technical Reference

### Database Schema (Key Tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `fin_ledger` | 139,032 | Central ledger — ALL DR/CR transaction lines |
| `fin_journalnumbers` | 9,906 | Journal headers (links to ledger via GL_VoucherNo) |
| `fin_mainaccounts` | 18 | Top-level account categories (Assets, Expenses, Income, etc.) |
| `fin_subaccounts` | 265 | Chart of accounts (individual accounts under each category) |
| `fin_currency` | 2 | Currency definitions (UGX primary) |
| `fin_financial_years` | 1 | Financial periods with Open/Closed status |
| `fin_budget` | 0 | Budget planning (not yet populated) |
| `fin_deleted_ledger` | 7,273 | Archived deleted ledger entries |
| `back2_fin_ledger` | 53,834 | Backup ledger copy |
| `edit_ledger` | 4,858 | Ledger modification history |
| `acc_activity_log` | 954 | Audit trail |
| `supplier` | 3 | Supplier/vendor records |

### fin_ledger Schema

| Column | Type | Key | Purpose |
|--------|------|-----|---------|
| TID | INT UNSIGNED | PK | Auto-increment primary key |
| accountcode | CHAR(25) | MUL | Account code (AC#### for chart accounts, MRU#### for students) |
| account_type | VARCHAR(45) | | Account type category (e.g., FBMFees, Chart Account, Supplier) |
| transactionType | CHAR(2) | | `DR` or `CR` |
| transaction_amount | BIGINT UNSIGNED | | Amount in base currency (always positive) |
| particulars | VARCHAR(350) | | Transaction description |
| voucherNo | INT UNSIGNED | | Links to `fin_journalnumbers.GL_VoucherNo` |
| journal_no | CHAR(25) | | Links to `fin_journalnumbers.JournalNo` (zero-padded) |
| transactionDate | DATE | | Transaction effective date |
| teller | VARCHAR(45) | | User who created the entry |
| trans_currency | CHAR(25) | | Currency code (UGX) |
| actual_amount | DOUBLE | | Amount in transaction currency |
| forex_rate | DOUBLE | | Exchange rate to base currency |

### fin_journalnumbers Schema

| Column | Type | Key | Purpose |
|--------|------|-----|---------|
| JournalNo | INT UNSIGNED | PK | Auto-increment journal number |
| GL_VoucherNo | VARCHAR(45) | | Public voucher number (links to `fin_ledger.voucherNo`) |
| journalType | CHAR(15) | | Journal, Receipt, Payment, Contra |
| voucherType | VARCHAR(45) | | Document sub-type (Student Receipt, Payment Voucher, etc.) |
| PostStatus | CHAR(15) | | Pending, Posted, Void |
| journalDate | DATE | | Journal creation date |
| Teller | VARCHAR(45) | | User/approver |

### Stored Procedures

| Procedure | Purpose |
|-----------|---------|
| `fin_CreateJournal` | Creates journal header in `fin_journalnumbers` |
| `fin_ApproveJournal` | Marks journal as Posted (current — no balance check) |
| `AddJournalDetails` | Inserts one DR or CR line into `fin_ledger` |
| `fin_UpdateAllLedgerBalances` | Recalculates running balances across all accounts |
| `fin_TransactionReversal` | Creates offsetting entry to reverse a transaction |
| `fin_UpdatePayAmount` | Updates amount on existing ledger entry (same-day, Bursar) |
| `CancelTransaction` | Marks transaction as cancelled (Bursar) |
| `fin_ClearLedger` | Deletes all entries for an account (dangerous) |
| `fin_ReceiptRemover` | Removes receipt + associated ledger entries |
| `CleanJournalDetails` | Removes orphaned/incomplete journal entries |
| `fin_GetAccountLedger` | Gets ledger entries for an account with filters |
| `fin_TrialBalance` | Trial balance aggregation by date range |

### Data Safety Guarantees

1. **NO records will be deleted** — only new constraints, indexes, and columns added
2. **Snapshot tables** created before any data modifications (Task A1)
3. **Soft-delete pattern** — deleted entries archived to `fin_deleted_ledger` via trigger (Task D9)
4. **All repairs logged** in `fin_repair_log` with before/after values (Tasks E1-E6)
5. **All database changes through migrations** — auditable, reversible, tracked in `cd_schema_migrations`
6. **Backward compatible** — existing stored procedures continue to work until explicitly replaced
