# Accounting Center Module — Complete System Documentation

> **Module**: `COOPERP/accounts/AccountingCenter.aspx`  
> **Database**: `campus_dynamics_accounts` (MySQL)  
> **Framework**: ASP.NET Web Forms (.NET 4.0) + DevExpress v16.1  
> **Last Updated**: June 2025

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture](#2-architecture)
3. [Page Routing (AccountingPageLoader)](#3-page-routing-accountingpageloader)
4. [Navigation Menu](#4-navigation-menu)
5. [Core Modules](#5-core-modules)
   - 5.1 [Homescreen (pid=0)](#51-homescreen-pid0)
   - 5.2 [Chart of Accounts (pid=1)](#52-chart-of-accounts-pid1)
   - 5.3 [Supplier Manager (pid=2)](#53-supplier-manager-pid2)
   - 5.4 [Receipt Centre (pid=3)](#54-receipt-centre-pid3)
   - 5.5 [Journal Centre / Vouchers Centre (pid=4)](#55-journal-centre--vouchers-centre-pid4)
   - 5.6 [Voucher Centre (pid=5)](#56-voucher-centre-pid5)
   - 5.7 [Ledgers Centre (pid=6)](#57-ledgers-centre-pid6)
   - 5.8 [Document Centre (pid=7)](#58-document-centre-pid7)
   - 5.9 [Escalated Issues (pid=8)](#59-escalated-issues-pid8)
6. [Transaction Pages (Popup Wizards)](#6-transaction-pages-popup-wizards)
   - 6.1 [Student Receipt](#61-student-receipt)
   - 6.2 [Sponsor Receipt](#62-sponsor-receipt)
   - 6.3 [Create Journal](#63-create-journal)
   - 6.4 [Payment Voucher](#64-payment-voucher)
   - 6.5 [Contra Voucher](#65-contra-voucher)
   - 6.6 [Receipt Details](#66-receipt-details)
   - 6.7 [Student Receipt Details](#67-student-receipt-details)
   - 6.8 [Transaction Details](#68-transaction-details)
7. [Standalone Pages](#7-standalone-pages)
   - 7.1 [General Ledger Drill-Down](#71-general-ledger-drill-down)
   - 7.2 [Account Ledger](#72-account-ledger)
   - 7.3 [Cash Book](#73-cash-book)
   - 7.4 [Bank Reconciliation](#74-bank-reconciliation)
   - 7.5 [Company Info](#75-company-info)
   - 7.6 [Accounting Periods](#76-accounting-periods)
   - 7.7 [Budget Manager](#77-budget-manager)
   - 7.8 [Fees Tracking](#78-fees-tracking)
   - 7.9 [Night Audit](#79-night-audit)
8. [Business Logic Layer (BLL)](#8-business-logic-layer-bll)
9. [Data Access Layer](#9-data-access-layer)
10. [Database Schema](#10-database-schema)
11. [Stored Procedures](#11-stored-procedures)
12. [Security & Role-Based Access](#12-security--role-based-access)
13. [Cross-Module Connections](#13-cross-module-connections)
14. [Transaction Flow Diagrams](#14-transaction-flow-diagrams)
15. [Session Variables Reference](#15-session-variables-reference)
16. [File Inventory](#16-file-inventory)

---

## 1. System Overview

The **Accounting Center** is the financial backbone of CampusDynamics. It is a full double-entry bookkeeping system that handles:

- **Chart of Accounts** — 5 main categories (Assets, Expenses, Income, Liabilities, Equity) with unlimited sub-accounts
- **Student & Sponsor Receipts** — Recording payments from students and sponsors
- **General Journals** — Free-form journal entries with financial period controls
- **Payment Vouchers** — Outgoing payments to suppliers/vendors (single and multi-payee)
- **Contra Vouchers** — Bank-to-bank transfers
- **Account Ledgers** — Full ledger views with adjustments (reverse, correct, cancel, clear)
- **General Ledger Drill-Down** — Trial balance with 3-level drill-down
- **Cash Book** — Bank-specific ledger view
- **Bank Reconciliation** — Statement import, auto/manual matching, adjustments
- **Budget Management** — Annual budget planning with actual vs planned tracking
- **Financial Reports** — Trial Balance, Income Statement, Balance Sheet, Payments, Defaulters
- **Audit Trail** — Activity logging for all sensitive operations
- **Night Audit** — Hotel/residence end-of-day reconciliation (6-stage wizard)

The system uses **MySQL** (`campus_dynamics_accounts` database) and operates on **UGX** as the base currency with multi-currency (forex) support.

---

## 2. Architecture

### Pattern: Thin Shell + UserControl Routing

```
AccountingCenter.aspx (shell page)
    └── AccountingCenter.aspx.cs
         └── AccountingPageLoader.PageLocator(pid)   ← from Systems.Settings.SD.dll
              └── Loads UserControl from ~/UserControls/Accounts/
                   └── UserControl .ascx.cs contains all real logic
```

All standalone pages (`GLDrillDown.aspx`, `CashBook.aspx`, etc.) follow the same thin-shell pattern — the `.aspx.cs` code-behind is empty, and the `.aspx` markup hosts a UserControl from `~/UserControls/Accounts/`.

### Layer Diagram

```
┌─────────────────────────────────────────────────────┐
│  Presentation Layer (ASPX/ASCX + DevExpress Grids)  │
├─────────────────────────────────────────────────────┤
│  Business Logic Layer (App_Code/)                    │
│    ├── CoreAccounting/AccountsBLL.cs                 │
│    └── Finance/StudentBillsPaymentBLL.cs             │
├─────────────────────────────────────────────────────┤
│  Data Access Layer (Typed DataSets / TableAdapters)  │
│    ├── CoreAccounting/CoopERPData.xsd                │
│    ├── CoreAccounting/AdjustmentsCentre.xsd          │
│    ├── Finance/FinancialData.xsd                     │
│    ├── Finance/FinancialAnalytics.xsd                │
│    ├── Finance/GraduationFinance.xsd                 │
│    └── Finance/StudentAccountingData.xsd             │
├─────────────────────────────────────────────────────┤
│  Database: campus_dynamics_accounts (MySQL)           │
│    ├── fin_mainaccounts, fin_subaccounts              │
│    ├── fin_ledger, fin_ledgertypes                    │
│    ├── fin_vouchernumbers, fin_voucher                │
│    ├── fin_journalnumbers, fin_journaltypes           │
│    ├── fin_financial_years, fin_financial_periods     │
│    ├── fin_budget, fin_currency                       │
│    ├── fin_reconciliationstatement                    │
│    ├── fin_reco_bank_entries, fin_reco_adjustments    │
│    ├── supplier, companyinfo, acc_activity_log        │
│    └── Stored Procedures (fin_*, Cancel*, Clean*)     │
└─────────────────────────────────────────────────────┘
```

### Connection Strings

| Name | Database | Usage |
|------|----------|-------|
| `campus_dynamics_accountsConnectionString` | `campus_dynamics_accounts` | Primary — all accounting tables |
| `vacConnectionString` | `campus_dynamics` | Admin system — student data, programs, academic info |

---

## 3. Page Routing (AccountingPageLoader)

The `AccountingCenter.aspx` page uses `AccountingPageLoader.PageLocator()` from `Systems.Settings.SD.dll` (compiled, no source available) to dynamically load UserControls based on the `?pid=N` query parameter.

### AccountingPageLoader.PageLocator() Method (Reconstructed)

```csharp
// From Systems.Settings.SD.dll (decompiled)
public static string PageLocator(int PageCode)
{
    switch (PageCode)
    {
        case 0: return "~/UserControls/Accounts/Homescreen.ascx";
        case 1: return "~/UserControls/Accounts/ChartAccounts.ascx";
        case 2: return "~/UserControls/Accounts/SupplierManager.ascx";
        case 3: return "~/UserControls/Accounts/ReceiptCentre.ascx";
        case 4: return "~/UserControls/Accounts/JournalCentre.ascx";
        case 5: return "~/UserControls/Accounts/voucherCentre.ascx";
        case 6: return "~/UserControls/Accounts/LedgersCentre.ascx";
        case 7: return "~/UserControls/Accounts/DocumentCentre.ascx";
        case 8: return "~/UserControls/Accounts/EscalatedIssues.ascx";
        default: return "~/UserControls/Accounts/Homescreen.ascx";
    }
}
```

### AccountingCenter.aspx.cs Code

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    int PageCode = 0;
    if (Request.QueryString["pid"] != null)
        PageCode = Convert.ToInt32(Request.QueryString["pid"]);

    string controlPath = AccountingPageLoader.PageLocator(PageCode);
    Control userControl = LoadControl(controlPath);
    pnl_centre.Controls.Add(userControl);
}
```

### URL Pattern

| URL | Module |
|-----|--------|
| `AccountingCenter.aspx` | Homescreen (default) |
| `AccountingCenter.aspx?pid=0` | Homescreen |
| `AccountingCenter.aspx?pid=1` | Chart of Accounts |
| `AccountingCenter.aspx?pid=2` | Supplier Manager |
| `AccountingCenter.aspx?pid=3` | Receipt Centre |
| `AccountingCenter.aspx?pid=4` | Journal Centre (Vouchers Centre) |
| `AccountingCenter.aspx?pid=4&j=Payment` | Payment Vouchers (filtered) |
| `AccountingCenter.aspx?pid=5` | Voucher Centre |
| `AccountingCenter.aspx?pid=6` | Ledgers Centre |
| `AccountingCenter.aspx?pid=7` | Document Centre (Financial Reports) |
| `AccountingCenter.aspx?pid=8` | Escalated Issues (Audit Log) |

---

## 4. Navigation Menu

The `MasterPage.master` in the accounts folder defines the full navigation structure:

### Menu Structure

```
Dashboard
  └── ~/MyApplications.aspx

Accounts Settings
  ├── Company Info          → CompanyInfo.aspx
  ├── Chart of Accounts     → Default.aspx  (AccountingCenter default)
  └── Accounting Periods    → AccountingPeriod.aspx

Budget Management
  └── Budget Manager        → BudgetManager.aspx

Vouchers & Account Ledgers
  ├── General Ledger        → GLDrillDown.aspx
  ├── Vouchers Centre       → AccountingCenter.aspx?pid=4
  ├── Account Ledgers       → AccountLedger.aspx
  └── Payment Vouchers      → AccountingCenter.aspx?pid=4&j=Payment

Audits & Bank Reconciliation
  ├── Cash Book             → CashBook.aspx
  ├── Reconciliation        → BankReconciliation.aspx
  └── Escalated Transactions → AccountingCenter.aspx?pid=8

Financial Documents
  └── (links to ?pid=7)     → AccountingCenter.aspx?pid=7
```

### Authentication

The MasterPage enforces session-based authentication:

```csharp
if (Session["username"] == null)
    Response.Redirect("~/Default.aspx");
```

---

## 5. Core Modules

### 5.1 Homescreen (pid=0)

**Control**: `~/UserControls/Accounts/Homescreen.ascx`  
**Purpose**: Dashboard landing page for the accounting module.

---

### 5.2 Chart of Accounts (pid=1)

**Control**: `~/UserControls/Accounts/ChartAccounts.ascx`  
**Purpose**: Manage the two-tier chart of accounts structure.

#### Structure

```
Main Accounts (fin_mainaccounts)          ← 5 fixed categories
  ├── 100 - Assets
  ├── 200 - Expenses
  ├── 300 - Income
  ├── 400 - Liabilities
  └── 500 - Equity
       └── Sub-Accounts (fin_subaccounts)  ← User-created accounts
            ├── 100-001 - Cash at Hand
            ├── 100-002 - Bank Account (Centenary)
            └── ...
```

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_mainaccountsTableAdapter` | `fin_mainaccounts` | Get, Add, Update, Delete |
| `fin_subaccountsTableAdapter` | `fin_subaccounts` | Get, Add, Update, Delete |
| `fin_currencyTableAdapter` | `fin_currency` | Currency dropdown |

#### Key Features

- **Master-Detail Grid**: Top grid shows 5 main categories; clicking a row reveals sub-accounts
- **Auto-generated Account Codes**: `NextAccountCode()` generates sequential codes per category
- **Export to Excel**: Entire chart exportable to XLSX
- **Ledger Type Management**: Popup to `ledgerTypes.aspx` for managing ledger type categories
- **BLL Integration**: Uses `AccountsBLL` for all CRUD operations

#### Database Fields

**fin_mainaccounts**: `CategoryCode` (PK), `CategoryName`, `Description`  
**fin_subaccounts**: `AccountCode` (PK), `MainAccountCode` (FK→fin_mainaccounts), `AccountName`, `accounttype`, `collectionLedgerType`, `base_currency`

---

### 5.3 Supplier Manager (pid=2)

**Control**: `~/UserControls/Accounts/SupplierManager.ascx`  
**Purpose**: CRUD management for suppliers/vendors.

#### Data Adapter

| Adapter | Table | Operations |
|---------|-------|------------|
| `supplierTableAdapter` | `supplier` | Get, Add, Update, Delete |

#### Database Fields

**supplier**: `supplierID` (auto PK), `supplierName`, `supplierAdress`, `supplierPhone`

#### Key Features

- Simple inline-editing grid with filter row
- Add new row, delete with confirmation dialog
- Referenced by voucher/journal entries across the accounting system

---

### 5.4 Receipt Centre (pid=3)

**Control**: `~/UserControls/Accounts/ReceiptCentre.ascx`  
**Purpose**: Central hub for creating and managing student/sponsor receipts.

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_vouchernumbersTableAdapter` | `fin_vouchernumbers` | Get receipts, Create, Delete |

#### Key Features

- **New Receipt Creation**: Inserts a new row into `fin_vouchernumbers` with auto-generated voucher number
- **Document Type Routing**: Based on document type, routes to different edit pages:
  - Sponsor receipts → `SponsorReceiptDetails.aspx`
  - General receipts → `ReceiptDetails.aspx`
- **Delete**: Calls `fin_ReceiptRemover` stored procedure (safely removes receipt and associated ledger entries)
- **Grid Columns**: Voucher number, date, amount, document type, status, payee

#### Stored Procedures

| Procedure | Purpose |
|-----------|---------|
| `fin_ReceiptRemover` | Safely removes a receipt and its associated ledger entries |

---

### 5.5 Journal Centre / Vouchers Centre (pid=4)

**Control**: `~/UserControls/Accounts/JournalCentre.ascx`  
**Purpose**: Central hub for ALL transaction types — journals, receipts, payments, contras.

This is the **most critical routing hub** in the accounting system. It supports multiple transaction flows based on the combination of `Journal Type` and `Document Type`.

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_journalnumbersTableAdapter` | `fin_journalnumbers` | Get, Create, Delete |
| `fin_journaltypesTableAdapter` | `fin_journaltypes` | Journal type dropdown |

#### Journal Types

| Type | Description |
|------|-------------|
| Journal | General journal entry |
| Receipt | Incoming payment receipt |
| Payment | Outgoing payment |
| Contra | Bank-to-bank transfer |

#### Document Types

| Type | Description |
|------|-------------|
| Student Receipt | Student tuition/fee payment |
| Sponsor Receipt | Sponsor paying on behalf of student |
| Sponsorship Distribution | Distributing sponsor funds to students |
| Donation | Donation receipt |
| Payment Voucher | Supplier/vendor payment |

#### Routing Matrix

| Journal Type + Document Type | Target Page |
|-----------------------------|-------------|
| Receipt + Student Receipt | `StudentReceipt.aspx` |
| Receipt + Sponsor Receipt | `SponsorReceipt.aspx` |
| Journal (any) | `CreateJournal.aspx` |
| Payment + Payment Voucher | `PaymentVoucher.aspx` |
| Contra (any) | `ContraVoucher.aspx` |

#### Key Behaviors

- **Page_Load**: Calls `CleanJournalDetails()` on every load to remove incomplete/orphaned journal entries
- **Query Parameter**: `?j=Payment` pre-filters the grid to show only Payment vouchers
- **Delete**: Removes journal entry and associated ledger entries
- **Session Variable**: Sets `Session["JournalID"]` for use by target transaction pages

#### Stored Procedures

| Procedure | Purpose |
|-----------|---------|
| `CleanJournalDetails` | Removes incomplete/orphaned journal entries on every page load |

---

### 5.6 Voucher Centre (pid=5)

**Control**: `~/UserControls/Accounts/voucherCentre.ascx`  
**Purpose**: Payment voucher management (alternative view).

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_vouchernumbersTableAdapter` | `fin_vouchernumbers` | Get, Create, Delete |

#### Key Features

- Lists payment vouchers from `fin_vouchernumbers`
- Opens `voucherDetails.aspx` popup for editing
- Separate from pid=4 but operates on similar data

---

### 5.7 Ledgers Centre (pid=6)

**Control**: `~/UserControls/Accounts/LedgersCentre.ascx`  
**Purpose**: View and adjust ledger transactions for any account.

This is the **primary account investigation tool**. It allows viewing all transactions for any account with powerful filtering and adjustment capabilities.

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_GetAccountLedgerTableAdapter` | `fin_ledger` (via SP) | Main ledger query |
| `fin_GetPayeeAccountsTableAdapter` | `fin_subaccounts` | Account picker by category |
| `fin_ledgertypesTableAdapter` | `fin_ledgertypes` | Ledger type filter |
| `fin_GetLedgerCategoriesTableAdapter` | `fin_mainaccounts` | Category filter |
| `fin_currencyTableAdapter` | `fin_currency` | Currency filter |
| `fin_ledgerTableAdapter` (Adjustments) | `fin_ledger` | Reversals/corrections/cancellations |

#### Filter Parameters

- **Account**: Selected from category → sub-account dropdown cascade
- **Date Range**: Start/end dates (defaults to academic year)
- **Ledger Type**: e.g., Bank, Cash, Student, Sponsor
- **Currency**: UGX, USD, etc.

#### Adjustment Engine (4 Modes)

| Mode | Description | Requirements | Stored Procedure |
|------|-------------|-------------|-----------------|
| **Reverse** | Reverses a transaction with a reason | Any user | `fin_TransactionReversal` |
| **Correct Amount** | Changes the transaction amount | Bursar only, same-day only | `fin_UpdatePayAmount` |
| **Cancel** | Cancels a transaction entirely | Bursar only | `CancelTransaction` |
| **Clear Ledger** | Clears the entire ledger for re-posting | Any user | `fin_ClearLedger` |

#### Grid Columns

`title`, `transactiondate`, `teller`, `cramount`, `dramount`, `particulars`, `curr_balance`, `voucherno`, `curr`

#### Popup Links

- **Transaction Details**: Opens `TransactionDetails.aspx` for read-only drill-down
- **Print**: Opens XtraReports viewer (`xtraReportCentre.aspx`)

---

### 5.8 Document Centre (pid=7)

**Control**: `~/UserControls/Accounts/DocumentCentre.ascx`  
**Purpose**: Financial report generation centre.

#### Available Reports

| Report | Description |
|--------|-------------|
| **Trial Balance** | Summary of all account balances |
| **Income Statement** | Revenue minus expenses |
| **Balance Sheet** | Assets = Liabilities + Equity |
| **Payments** | All outgoing payment records |
| **Defaulters** | Students with outstanding balances |

#### Key Features

- Opens XtraReports viewer in popup window
- Reports generated from stored procedures against `fin_ledger` aggregates
- Date-range filtered

---

### 5.9 Escalated Issues (pid=8)

**Control**: `~/UserControls/Accounts/EscalatedIssues.ascx`  
**Purpose**: View audit trail / activity log for accounting operations.

#### Data Adapter

| Adapter | Table | Operations |
|---------|-------|------------|
| `acc_activity_logTableAdapter` | `acc_activity_log` | Get by date range |

#### Database Fields

**acc_activity_log**: `logid`, `user_id`, `page_function` (category), `comments` (transaction description), `par` (details), `access_date`

#### Key Features

- Date-filtered (defaults to last 7 days)
- Read-only grid with filter rows
- Captures: reversals, corrections, cancellations, and other sensitive operations
- Written to by other modules (LedgersCentre adjustments, etc.)

---

## 6. Transaction Pages (Popup Wizards)

These pages open as popup windows from the Journal Centre, Receipt Centre, or Voucher Centre. They handle the actual creation of financial transactions.

### 6.1 Student Receipt

**Page**: `StudentReceipt.aspx` → `StudentReceipt.aspx.cs`  
**Purpose**: Record a student payment via bank.

#### Double-Entry Logic

```
CR (Credit) → Student Account (reduces student debt)
DR (Debit)  → Bank Account (increases bank balance)
```

#### Data Adapters

| Adapter | Operations |
|---------|------------|
| `fin_journalnumbersTableAdapter` | `fin_CreateJournal`, `fin_ApproveJournal` |
| `fin_ledgerTableAdapter` | `AddJournalDetails`, `fin_UpdateAllLedgerBalances` |

#### Key Features

- **Student Lookup**: Search by student number/name, auto-populates account
- **Bank Account Selection**: From sub-accounts where type = "Bank"
- **Amount Entry**: With currency support
- **Approval Flow**: Draft → Approved (requires Administrator/Bursar role)
- **Session Variable**: Uses `Session["JournalID"]` from Journal Centre

#### Stored Procedures

| Procedure | Purpose |
|-----------|---------|
| `fin_CreateJournal` | Creates a new journal entry |
| `fin_ApproveJournal` | Marks journal as approved |
| `AddJournalDetails` | Inserts individual ledger lines |
| `fin_UpdateAllLedgerBalances` | Recalculates running balances across accounts |

---

### 6.2 Sponsor Receipt

**Page**: `SponsorReceipt.aspx` → `SponsorReceipt.aspx.cs`  
**Purpose**: Record a sponsor payment via bank.

Same logic as Student Receipt but for sponsor accounts (`typ="Sponsor"`). Sponsor pays on behalf of one or more students.

#### Double-Entry Logic

```
CR (Credit) → Sponsor Account
DR (Debit)  → Bank Account
```

---

### 6.3 Create Journal

**Page**: `CreateJournal.aspx` → `CreateJournal.aspx.cs`  
**Purpose**: General-purpose journal entry with full double-entry control.

#### Key Features

- **Financial Period Validation**: `IsInOpenFinancialPeriod()` checks `fin_financial_years` table — only allows entries within an open period
- **Reference Numbers**: Auto-generated or user-specified
- **Multi-line Entries**: Add multiple debit/credit lines
- **Forex Support**: Multi-currency with exchange rate
- **Line Item Deletion**: Remove individual journal lines
- **Balance Validation**: Total debits must equal total credits before approval

#### Financial Period Check

```csharp
bool IsInOpenFinancialPeriod()
{
    // Queries fin_financial_years for status = "Open"
    // Validates transaction date falls within open period's start_date..end_date
    // Returns false if period is "Closed" → blocks journal creation
}
```

---

### 6.4 Payment Voucher

**Page**: `PaymentVoucher.aspx` → `PaymentVoucher.aspx.cs`  
**Purpose**: Record outgoing payments to suppliers/vendors.

#### Double-Entry Logic

```
CR (Credit) → Bank Account (reduces bank balance)
DR (Debit)  → Payee/Expense Account (increases expense)
```

#### Key Features

- **Single Payee Mode**: One supplier, one amount
- **Multiple Payee Mode**: Multiple suppliers, distributes amounts
- **Forex Support**: Multi-currency with exchange rate
- **Supplier Lookup**: From `supplier` table
- **Approval Flow**: Draft → Approved

---

### 6.5 Contra Voucher

**Page**: `ContraVoucher.aspx` → `ContraVoucher.aspx.cs`  
**Purpose**: Record bank-to-bank transfers.

#### Double-Entry Logic

```
CR (Credit) → Source Bank Account (money leaves)
DR (Debit)  → Destination Bank Account (money arrives)
```

#### Key Features

- **Source ≠ Destination Validation**: Prevents transfer to same account
- **Bank Account Dropdowns**: Both source and destination from bank-type sub-accounts
- **Amount Match**: Transfer amount is identical on both sides

---

### 6.6 Receipt Details

**Page**: `ReceiptDetails.aspx` → `ReceiptDetails.aspx.cs`  
**Purpose**: Edit a general (non-student) receipt.

#### Key Features

- Uses `AccountsBLL.NewVoucherEntry()` for saving
- Opens from Receipt Centre (pid=3)
- Popup editor for receipt line items

---

### 6.7 Student Receipt Details

**Page**: `StudentReceiptDetails.aspx` → `StudentReceiptDetails.aspx.cs`  
**Purpose**: Edit a student-specific receipt with academic period fields.

#### Additional Fields (vs Receipt Details)

- **Term**: Academic term (1, 2, 3) — auto-calculated via `StudentBillsPaymentBLL.DefaultTerm()`
  - Jan–Apr → Term 1
  - May–Aug → Term 2
  - Sep–Dec → Term 3
- **Academic Year**: Year dropdown

---

### 6.8 Transaction Details

**Page**: `TransactionDetails.aspx` → `TransactionDetails.aspx.cs`  
**Purpose**: Read-only drill-down view of a specific voucher/journal.

#### Data Adapter

| Adapter | Operation |
|---------|-----------|
| `fin_ledgerTableAdapter` | `GetSingleTransactionDetails(voucherNo)` |

#### Key Features

- **Read-only**: No editing capability
- **Shows all ledger entries** for a single voucher/journal number
- **Columns**: Account name, debit, credit, particulars, currency
- **Opens from**: Ledgers Centre, Cash Book, Bank Reconciliation (anywhere a transaction is clickable)

---

## 7. Standalone Pages

These pages have their own dedicated URLs (not routed through AccountingCenter.aspx).

### 7.1 General Ledger Drill-Down

**Page**: `GLDrillDown.aspx` → `~/UserControls/Accounts/GLDrillDown.ascx`  
**Purpose**: Trial Balance view with 3-level drill-down into transactions.

#### Data Adapters

| Adapter | Purpose |
|---------|---------|
| `fin_TrialBalanceTableAdapter` | Top-level GL balances by date range |
| `fin_GetGeneralDrillDownDetailsTableAdapter` | Sub-account balances for a category |
| `fin_GetDrillDownDetailsTableAdapter` | Individual transactions for a sub-account |

#### 3-Level Drill-Down

```
Level 1: Trial Balance (by main account category)
  ├── Assets:       DR 50,000,000  CR 10,000,000
  ├── Expenses:     DR 30,000,000  CR 0
  └── Income:       DR 0           CR 80,000,000
       │
       └── Level 2: Sub-Account Breakdown (click a category)
            ├── Cash at Hand:     DR 5,000,000   CR 1,000,000
            ├── Bank (Centenary): DR 45,000,000  CR 9,000,000
            └── ...
                 │
                 └── Level 3: Individual Transactions (click a sub-account)
                      ├── 2025-01-15  Receipt #1001  DR 2,000,000  Student Fee
                      ├── 2025-01-16  PV #501        CR 500,000    Supplier Payment
                      └── ...
```

#### Key Features

- **Auto-defaults to academic year**: Start date = August 1 of current academic year
- **Export to XLSX**: Full trial balance exportable
- **Popup GL listing**: Links to `GLAccount.aspx` for detailed account view
- **Session variables**: `subacc_code`, `acc_code` for drill-down state

---

### 7.2 Account Ledger

**Page**: `AccountLedger.aspx` → `~/UserControls/Accounts/LedgersCentre.ascx`  
**Purpose**: Same as pid=6 (Ledgers Centre). Standalone URL entry point.

See [Section 5.7 — Ledgers Centre](#57-ledgers-centre-pid6) for full details.

---

### 7.3 Cash Book

**Page**: `CashBook.aspx` → `~/UserControls/Accounts/CashBook.ascx`  
**Purpose**: Simplified, read-only ledger view restricted to bank accounts only.

#### Data Adapters

| Adapter | Parameters |
|---------|-----------|
| `fin_GetPayeeAccountsTableAdapter` | Hard-coded `typ="Bank"` |
| `fin_GetAccountLedgerTableAdapter` | Hard-coded `typ="Chart Account"`, `displayCurr="UGX"` |

#### Key Features

- **Bank-only filter**: Only shows bank-type accounts (not student, supplier, etc.)
- **Read-only**: No adjustment capabilities (unlike Ledgers Centre)
- **Date-filtered**: Defaults to academic year
- **Print**: Via XtraReports (`xtraReportCentre.aspx`)
- **Transaction Details**: Popup to `TransactionDetails.aspx`

---

### 7.4 Bank Reconciliation

**Page**: `BankReconciliation.aspx` → `~/UserControls/Accounts/BankReconciliation.ascx`  
**Purpose**: Full bank reconciliation workflow — match bank statements to internal ledger.

This is the **most complex UserControl** in the accounting system.

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_GetPayeeAccountsTableAdapter` | Bank accounts | Account picker |
| `fin_GetRecoLedgerTableAdapter` | Ledger (filtered) | Ledger entries with reconciliation status |
| `fin_reconciliationstatementTableAdapter` | `fin_reconciliationstatement` | Statement CRUD, `fin_GetLastRecoBalance`, `finPerformAutoReconciliation`, `GetBankReconciliations`, `GetSingleStatement` |
| `fin_reco_bank_entriesTableAdapter` | `fin_reco_bank_entries` | Bank entries with `ManualReconcile`, `UnReconcile`, `ClearTable`, `GetBankRecoStatementData` |
| `fin_reco_adjustmentsTableAdapter` | `fin_reco_adjustments` | Reconciliation adjustments CRUD |

#### Database Tables

**fin_reconciliationstatement**: `ID`, `rec_date`, `last_rec_balance`, `statement_date`, `statement_balance`, `rec_status`, `bank_code`, `title`

**fin_reco_bank_entries**: `ID`, `track_no`, `trans_date`, `details`, `trans_typ`, `Curr_Balance`, `match_TID`, `RecoID`, `amount`

**fin_reco_adjustments**: `category`, `type`, `RecoID`, `bank_code`, `amount`, `details`

#### Reconciliation Workflow

```
1. SELECT BANK ACCOUNT
   └── Choose from bank-type sub-accounts

2. CREATE RECONCILIATION STATEMENT
   └── Set statement date & statement balance
   └── Auto-fetches last reconciliation balance

3. IMPORT BANK STATEMENT
   └── Excel import via ExcellDataLoader.aspx
   └── Parses into fin_reco_bank_entries

4. RECONCILE (Auto or Manual)
   ├── AUTO: finPerformAutoReconciliation stored procedure
   │        (matches by amount + date proximity)
   └── MANUAL: Select matching bank entry + ledger entry
               Validates amounts match
               Calls ManualReconcile

5. REVIEW & ADJUST
   ├── Uncredited Deposits (Add)
   ├── Unpresented Cheques (Less)
   ├── Direct Debits (Less)
   └── Direct Credits (Add)

6. UN-RECONCILE (if needed)
   └── Reverts matched entries via UnReconcile
```

#### Layout

Side-by-side dual grid:
- **Left**: Bank Statement entries (imported from Excel)
- **Right**: Bank Ledger entries (from internal system)

#### Related Pages

- `ExcellDataLoader.aspx` — Excel file importer
- `RecoAdjustments.aspx` — View/edit reconciliation adjustments
- `TransactionDetails.aspx` — Drill-down popup

---

### 7.5 Company Info

**Page**: `CompanyInfo.aspx` → `~/UserControls/Accounts/CompanyInfo.ascx`  
**Purpose**: Manage company profile and financial year lifecycle.

#### Data Adapters

| Adapter | Table |
|---------|-------|
| `companyinfoTableAdapter` | `companyinfo` |
| `fin_financial_periodsTableAdapter` | `fin_financial_periods` |

#### Database Tables

**companyinfo**: `ID`, `companyname`, `companycontacts`, `logo` (binary image)

**fin_financial_periods**: `ID`, `title`, `start_date`, `end_date`, `external_audit` (Pending/On-Going/Completed), `audit_date`, `final_close_date`, `active_status` (Active/Archived/Pending)

#### Key Features

- Inline editing for company info with logo display
- Popup edit form for financial years with audit tracking
- Delete support on company records, not on financial years
- Financial years shared with Budget Manager

---

### 7.6 Accounting Periods

**Page**: `AccountingPeriod.aspx` → `~/UserControls/Accounts/AccountingPeriods.ascx`  
**Purpose**: Manage chart of accounts structure and financial period open/close lifecycle.

#### Data Adapters

| Adapter | Table |
|---------|-------|
| `fin_financial_yearsTableAdapter` | `fin_financial_years` |
| `AccountsBLL` | Sub-accounts (via BLL) |

#### Database Table

**fin_financial_years**: `id`, `finacial_Year`, `start_date`, `end_date`, `status` (Open/Closed)

> **Note**: `fin_financial_years` is a SEPARATE table from `fin_financial_periods`. The former controls journal entry validation; the latter tracks audit/archival-level financial periods.

#### Key Features

- **Role-based**: Only Administrator/Bursar can access
- **Single Open Period Enforcement**: 
  - Blocks adding a new period if one is already Open
  - Blocks changing a period to "Open" if another is already Open
  - Enforced in `RowUpdating` event handler
- **Master-Detail**: Financial periods → sub-accounts grid
- **Academic Year Dropdown**: Uses `CommonRoutines.ReturnAcademicYrs()`

#### Business Rule

```
Only ONE financial period can be "Open" at any time.
All journal entries (CreateJournal.aspx) validate against this:
  → IsInOpenFinancialPeriod() checks if transaction date falls within the Open period
  → If no Open period exists, journal creation is blocked
```

---

### 7.7 Budget Manager

**Page**: `BudgetManager.aspx` → `~/UserControls/Accounts/BudgetManager.ascx`  
**Purpose**: Annual budget planning, editing, and actual vs planned tracking.

#### Data Adapters

| Adapter | Table | Operations |
|---------|-------|------------|
| `fin_budgetTableAdapter` | `fin_budget` | `GetAnnualBudget`, `fin_CreateBudget`, inline CRUD |
| `fin_financial_periodsTableAdapter` | `fin_financial_periods` | Financial year picker |

#### Database Table

**fin_budget**: `ID`, `item_code`, `details`, `planned_amount`, `actual_amount`, `vote_status`, `item_category`, `budget_year`, `accountname`

#### Key Features

- **Budget Creation**: `fin_CreateBudget(year, category)` auto-populates budget line items from chart of accounts
- **Batch Editing**: DevExpress batch mode for editing planned amounts in-grid
- **Budget vs Actual**: Side-by-side comparison with summary row totals
- **Export to XLSX**: Full budget exportable
- **Filter by Category**: INCOME or EXPENDITURE
- **Budget items linked to chart of accounts** via `item_code`/`accountname`

---

### 7.8 Fees Tracking

**Page**: `FeesTracking.aspx` → `~/UserControls/schools/TermlyClasses.ascx`  
**Purpose**: Fee structure management by class and term.

> **Note**: This is a **cross-module bridge** — it loads a schools/academics UserControl (`TermlyClasses.ascx`) within the accounting section. It connects fee structures defined in the academic system to the accounting system.

---

### 7.9 Night Audit

**Page**: `NightAudit.aspx` → Dynamic UserControl loading  
**Purpose**: Hotel/Residence Night Audit — 6-stage end-of-day reconciliation wizard.

> **Note**: This is the **only COOPERP accounts page with real code-behind logic** (not a thin shell).

#### Stage Wizard

| Stage | UserControl | Purpose |
|-------|-------------|---------|
| 0 | `AuditStartAudit.ascx` | Initialize audit session |
| 1-2 | `AuditTodayBookings.ascx` | Review today's bookings |
| 3-4 | `AuditTodayBillings.ascx` | Review today's billings |
| 5 | `AuditCompleteAudit.ascx` | Finalize and close audit |

#### Session Variables

| Variable | Values | Purpose |
|----------|--------|---------|
| `Session["typ"]` | `"DR"`, `"CR"`, `"CheckIn Pending"`, `"Checked-In"` | Filter mode for bookings/billings |

#### Navigation

- Previous/Next buttons navigate through stages via `rbl_nightaudit.SelectedIndex`
- On completion → redirect to `~/MyApplications.aspx`

---

## 8. Business Logic Layer (BLL)

### 8.1 AccountsBLL

**File**: `App_Code/CoreAccounting/AccountsBLL.cs`  
**Namespace**: `CoopERPDataTableAdapters`  
**Decoration**: `[DataObject]` for ObjectDataSource binding

#### Table Adapters Used

| Adapter | Table |
|---------|-------|
| `fin_mainaccountsTableAdapter` | Main account categories |
| `fin_subaccountsTableAdapter` | Sub-accounts |
| `fin_GetLedgerTypesByCategoryTableAdapter` | Ledger type lookup |
| `fin_vouchernumbersTableAdapter` | Voucher number sequence |
| `fin_voucherTableAdapter` | Voucher line entries |

#### Public Methods

| Method | Purpose | Stored Procedure |
|--------|---------|-----------------|
| `GetMainAccounts()` | Get all 5 main categories | — |
| `GetAccountsByCategory(CategoryCode)` | Get sub-accounts for a category | — |
| `GetAllLedgerTypes()` | Get all ledger type records | — |
| `AddCategory(...)` | Add main account category | `MainAccountEditor` |
| `UpdateCategory(...)` | Update main account category | `MainAccountEditor` |
| `DeleteCategory(...)` | Delete main account category | `DeleteMainAccount` |
| `AddAccount(...)` | Add sub-account | `AccountEditor` |
| `UpdateAccount(...)` | Update sub-account | `AccountEditor` |
| `DeleteAccount(...)` | Delete sub-account | `DeleteAccount` |
| `AddLedgerCategory(...)` | Add ledger category | `fin_LedgerCategoryEditor` |
| `EditLedgerCategory(...)` | Edit ledger category | `fin_LedgerCategoryEditor` |
| `DeleteLedgerCategory(...)` | Delete ledger category | `fin_DeleteLedgerCategory` |
| `CreateVoucher(voucherType)` | Insert into `fin_vouchernumbers` | — |
| `NewVoucherEntry(...)` | Create voucher line entry | `fin_VoucherCreator` |

#### Audit Stamping

All operations stamp with `HttpContext.Current.User.Identity.Name` for audit trail.

---

### 8.2 StudentBillsPaymentBLL

**File**: `App_Code/Finance/StudentBillsPaymentBLL.cs`

#### Table Adapter

| Adapter | Table |
|---------|-------|
| `student_billingTableAdapter` | `student_billing` (via FinancialData.xsd) |

#### Public Methods

| Method | Purpose |
|--------|---------|
| `GetBillsPerTerm(cls, trm, yr)` | Get student bills per class/term/year |
| `DeleteBill(bill_id, original_bill_id)` | Delete a student bill (audit-stamped) |
| `DefaultTerm()` | Static: Jan–Apr→1, May–Aug→2, Sep–Dec→3 |

---

## 9. Data Access Layer

The data access layer uses **Typed DataSets** (`.xsd` files) which auto-generate `TableAdapter` classes.

### XSD Files

| XSD | Location | Purpose |
|-----|----------|---------|
| `CoopERPData.xsd` | `App_Code/CoreAccounting/` | **Core ERP dataset** — all `fin_*` tables, trial balance, ledger, accounts, reconciliation, budget, vouchers, suppliers |
| `AdjustmentsCentre.xsd` | `App_Code/CoreAccounting/` | Separate dataset for ledger adjustments (reversals, corrections, cancellations) |
| `FinancialData.xsd` | `App_Code/Finance/` | Student billing data |
| `FinancialAnalytics.xsd` | `App_Code/Finance/` | Financial analytics/reporting queries |
| `GraduationFinance.xsd` | `App_Code/Finance/` | Graduation financial data (clearance, fees) |
| `StudentAccountingData.xsd` | `App_Code/Finance/` | Student account balances and records |

### Key Adapter Namespaces

- `CoopERPDataTableAdapters` — Core accounting adapters
- `AdjustmentsCentreTableAdapters` — Ledger adjustment adapters
- `FinancialDataTableAdapters` — Student billing adapters

---

## 10. Database Schema

### Core Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `fin_mainaccounts` | 5 main account categories | `CategoryCode` (PK), `CategoryName`, `Description` |
| `fin_subaccounts` | Sub-accounts under main categories | `AccountCode` (PK), `MainAccountCode` (FK), `AccountName`, `accounttype`, `collectionLedgerType`, `base_currency` |
| `fin_ledger` | Central ledger — ALL financial transactions | `transactiondate`, `teller`, `cramount`, `dramount`, `particulars`, `curr_balance`, `voucherno`, `curr`, `title` |
| `fin_ledgertypes` | Ledger type categories | Type name, description |
| `fin_vouchernumbers` | Voucher number sequence/registry | Voucher number, date, amount, type, status, payee |
| `fin_voucher` | Voucher line items | Line details per voucher |
| `fin_journalnumbers` | Journal number registry | Journal number, type, document type, status |
| `fin_journaltypes` | Journal type definitions | Journal, Receipt, Payment, Contra |
| `fin_currency` | Currency definitions | Currency code, name, exchange rate |
| `fin_financial_years` | Financial periods (Open/Closed) | `finacial_Year`, `start_date`, `end_date`, `status` |
| `fin_financial_periods` | Financial year lifecycle/audit | `title`, `start_date`, `end_date`, `external_audit`, `active_status` |
| `fin_budget` | Annual budget items | `item_code`, `planned_amount`, `actual_amount`, `budget_year` |
| `supplier` | Supplier/vendor registry | `supplierID`, `supplierName`, `supplierAdress`, `supplierPhone` |
| `companyinfo` | Company profile | `companyname`, `companycontacts`, `logo` |
| `acc_activity_log` | Audit trail | `user_id`, `page_function`, `comments`, `par`, `access_date` |

### Reconciliation Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `fin_reconciliationstatement` | Bank reconciliation statements | `rec_date`, `last_rec_balance`, `statement_balance`, `rec_status`, `bank_code` |
| `fin_reco_bank_entries` | Imported bank statement entries | `track_no`, `trans_date`, `details`, `amount`, `match_TID`, `RecoID` |
| `fin_reco_adjustments` | Reconciliation adjustments | `category`, `type`, `amount`, `details`, `RecoID` |

### Entity Relationships

```
fin_mainaccounts (5 categories)
    │
    └── 1:N ──► fin_subaccounts (unlimited sub-accounts)
                    │
                    └── Referenced by ──► fin_ledger (all transactions)
                                              │
                                              ├── Created by ──► fin_journalnumbers
                                              ├── Created by ──► fin_vouchernumbers
                                              └── Reconciled by ──► fin_reco_bank_entries

fin_financial_years ──► Controls ──► CreateJournal.aspx (period validation)
fin_financial_periods ──► Used by ──► BudgetManager, CompanyInfo

fin_budget.item_code ──► References ──► fin_subaccounts.AccountCode

supplier ──► Referenced by ──► Payment Vouchers

acc_activity_log ──► Written by ──► LedgersCentre adjustments, etc.
```

---

## 11. Stored Procedures

### Transaction Management

| Procedure | Purpose | Called From |
|-----------|---------|------------|
| `fin_CreateJournal` | Creates a new journal entry in `fin_journalnumbers` | StudentReceipt, SponsorReceipt, CreateJournal |
| `fin_ApproveJournal` | Marks a journal as approved | StudentReceipt, SponsorReceipt |
| `AddJournalDetails` | Inserts individual ledger line items into `fin_ledger` | StudentReceipt, SponsorReceipt, CreateJournal |
| `fin_UpdateAllLedgerBalances` | Recalculates running balances across all accounts | StudentReceipt, SponsorReceipt |
| `fin_VoucherCreator` | Creates voucher line entries | AccountsBLL.NewVoucherEntry() |
| `CleanJournalDetails` | Removes incomplete/orphaned journal entries | JournalCentre (on every Page_Load) |

### Receipt/Voucher Operations

| Procedure | Purpose | Called From |
|-----------|---------|------------|
| `fin_ReceiptRemover` | Safely removes receipt + associated ledger entries | ReceiptCentre |
| `MainAccountEditor` | Insert/update main account categories | AccountsBLL |
| `DeleteMainAccount` | Delete main account category | AccountsBLL |
| `AccountEditor` | Insert/update sub-accounts | AccountsBLL |
| `DeleteAccount` | Delete sub-account | AccountsBLL |
| `fin_LedgerCategoryEditor` | Insert/update ledger categories | AccountsBLL |
| `fin_DeleteLedgerCategory` | Delete ledger category | AccountsBLL |

### Ledger Adjustments

| Procedure | Purpose | Called From |
|-----------|---------|------------|
| `fin_TransactionReversal` | Reverses a transaction (creates offsetting entry) | LedgersCentre |
| `fin_UpdatePayAmount` | Corrects a transaction amount (same-day, Bursar only) | LedgersCentre |
| `CancelTransaction` | Cancels a transaction entirely (Bursar only) | LedgersCentre |
| `fin_ClearLedger` | Clears entire ledger for re-posting | LedgersCentre |

### Reconciliation

| Procedure | Purpose | Called From |
|-----------|---------|------------|
| `finPerformAutoReconciliation` | Auto-matches bank entries to ledger entries | BankReconciliation |
| `fin_GetLastRecoBalance` | Gets last reconciliation balance for a bank | BankReconciliation |
| `ManualReconcile` | Manually matches bank + ledger entry pair | BankReconciliation |
| `UnReconcile` | Reverts a matched pair | BankReconciliation |

### Query Procedures

| Procedure | Purpose | Called From |
|-----------|---------|------------|
| `fin_GetAccountLedger` | Gets ledger entries for an account by filters | LedgersCentre, CashBook |
| `fin_GetPayeeAccounts` | Gets accounts by category/type | LedgersCentre, CashBook, BankReco |
| `fin_GetLedgerCategories` | Gets ledger category list | LedgersCentre |
| `fin_TrialBalance` | Trial balance by date range | GLDrillDown |
| `fin_GetGeneralDrillDownDetails` | Sub-account balances for GL drill-down | GLDrillDown |
| `fin_GetDrillDownDetails` | Individual transactions for GL drill-down | GLDrillDown |
| `fin_GetStudentLedger` | Student ledger (used by portal) | StudentLedger (portal) |
| `fin_CreateBudget` | Auto-creates budget from chart of accounts | BudgetManager |
| `GetBankReconciliations` | Gets all reconciliation statements | BankReconciliation |
| `GetSingleStatement` | Gets a single reconciliation statement | BankReconciliation |
| `GetSingleTransactionDetails` | Gets all ledger lines for one voucher | TransactionDetails |
| `GetBankRecoStatementData` | Gets bank entries for a reconciliation | BankReconciliation |

---

## 12. Security & Role-Based Access

### Authentication

- **Session-based**: `Session["username"]` checked on MasterPage
- **Unauthenticated users**: Redirected to `~/Default.aspx`

### Role-Based Restrictions

| Feature | Required Role | Enforced In |
|---------|--------------|-------------|
| Access Accounting Periods | Administrator OR Bursar | AccountingPeriod.ascx |
| Correct Transaction Amount | Bursar | LedgersCentre.ascx |
| Cancel Transaction | Bursar | LedgersCentre.ascx |
| Approve Journal | Administrator OR Bursar | StudentReceipt.aspx |
| General access | Any authenticated user | MasterPage.master |

### Audit Trail

All sensitive operations log to `acc_activity_log`:
- Transaction reversals
- Amount corrections
- Cancellations
- Ledger clears

Each log entry includes: `user_id`, `page_function`, `comments`, `par` (details), `access_date`

---

## 13. Cross-Module Connections

### Internal Accounting Connections

```
Chart of Accounts (pid=1)
    ├── Provides account list to → Journal Centre, Receipt Centre, Voucher Centre
    ├── Account codes used in → fin_ledger entries
    ├── Budget items derived from → Budget Manager
    └── Sub-accounts used as → Bank accounts in Cash Book, Reconciliation

Journal Centre (pid=4)
    ├── Creates journals → fin_journalnumbers
    ├── Routes to → StudentReceipt, SponsorReceipt, CreateJournal, PaymentVoucher, ContraVoucher
    └── Entries posted to → fin_ledger (via stored procedures)

Ledgers Centre (pid=6) / Account Ledger
    ├── Reads from → fin_ledger
    ├── Adjustments write to → fin_ledger (via AdjustmentsCentre.xsd)
    └── Adjustments logged to → acc_activity_log (Escalated Issues)

GL Drill-Down
    ├── Reads from → fin_ledger (aggregated into trial balance)
    └── Drill-down references → fin_subaccounts, fin_mainaccounts

Bank Reconciliation
    ├── Reads from → fin_ledger (bank accounts only)
    ├── Imports from → Excel bank statements
    └── Matches → fin_reco_bank_entries ↔ fin_ledger entries

Accounting Periods
    ├── Controls → CreateJournal (period validation)
    └── One Open period rule → blocks/allows journal creation

Financial Periods + Company Info
    └── Shared data → Budget Manager (year picker)
```

### External Module Connections

| Module | Connection | Mechanism |
|--------|-----------|-----------|
| **Student Portal** | Student ledger view | `fin_GetStudentLedger` stored procedure |
| **Schools/Academics** | Fee structures | FeesTracking.aspx → TermlyClasses.ascx |
| **Hotel/Residence** | Night audit | NightAudit.aspx → Audit wizard controls |
| **Graduation** | Graduation fees | `GraduationFinance.xsd` |
| **Student Info** | Student lookup | Student number search in receipt pages |
| **Admissions** | Application fees | Via student billing system |

---

## 14. Transaction Flow Diagrams

### Student Fee Payment Flow

```
1. JOURNAL CENTRE (pid=4)
   │  User selects: Type=Receipt, Doc=Student Receipt
   │  System creates: fin_journalnumbers entry
   │  Session: JournalID set
   │
   └──► 2. STUDENT RECEIPT (popup)
         │  User enters: Student#, Bank Account, Amount
         │  System calls:
         │    • fin_CreateJournal → creates journal
         │    • AddJournalDetails → CR Student, DR Bank
         │    • fin_UpdateAllLedgerBalances → recalculates
         │
         ├──► 3a. APPROVAL (Admin/Bursar)
         │       fin_ApproveJournal → marks approved
         │
         └──► 3b. POSTED TO LEDGER
                 fin_ledger now contains:
                   Row 1: CR Student Account  -2,000,000
                   Row 2: DR Bank Account     +2,000,000
                             │
                             └──► Visible in:
                                  • Ledgers Centre (pid=6)
                                  • GL Drill-Down
                                  • Cash Book (bank side)
                                  • Student Ledger (portal)
                                  • Trial Balance reports
```

### Payment Voucher Flow

```
1. JOURNAL CENTRE (pid=4, j=Payment)
   │  User selects: Type=Payment, Doc=Payment Voucher
   │  System creates: fin_journalnumbers entry
   │
   └──► 2. PAYMENT VOUCHER (popup)
         │  User enters: Payee, Bank, Amount
         │  System posts:
         │    CR Bank Account     -500,000
         │    DR Expense Account  +500,000
         │
         └──► 3. POSTED TO LEDGER
                 Visible in:
                   • Ledgers Centre
                   • GL Drill-Down
                   • Cash Book
                   • Document Centre reports
```

### Bank Reconciliation Flow

```
1. SELECT BANK & STATEMENT PERIOD
   │
   ├──► 2. IMPORT BANK STATEMENT (Excel)
   │       Parsed into fin_reco_bank_entries
   │
   ├──► 3. AUTO-RECONCILE
   │       finPerformAutoReconciliation matches by amount+date
   │
   ├──► 4. MANUAL RECONCILE (remaining items)
   │       Select bank entry + ledger entry → validate amounts → match
   │
   ├──► 5. ADJUSTMENTS
   │       Add: Uncredited Deposits, Direct Credits
   │       Less: Unpresented Cheques, Direct Debits
   │
   └──► 6. FINALIZE
           Statement balanced ✓
```

### Ledger Adjustment Flow

```
1. LEDGERS CENTRE (pid=6)
   │  User views account ledger
   │  Selects a transaction row
   │
   ├──► REVERSE
   │     Reason required → fin_TransactionReversal
   │     Creates offsetting entry in fin_ledger
   │     Logs to acc_activity_log
   │
   ├──► CORRECT AMOUNT (Bursar only, same-day)
   │     New amount entered → fin_UpdatePayAmount
   │     Updates existing ledger entry
   │     Logs to acc_activity_log
   │
   ├──► CANCEL (Bursar only)
   │     CancelTransaction → marks transaction cancelled
   │     Logs to acc_activity_log
   │
   └──► CLEAR LEDGER
         fin_ClearLedger → clears all entries for re-posting
         Logs to acc_activity_log
```

---

## 15. Session Variables Reference

| Variable | Set By | Used By | Values |
|----------|--------|---------|--------|
| `Session["username"]` | Login page | MasterPage (auth guard) | Username string |
| `Session["JournalID"]` | JournalCentre | StudentReceipt, SponsorReceipt, CreateJournal, PaymentVoucher, ContraVoucher | Journal ID integer |
| `Session["subacc_code"]` | GLDrillDown | GLDrillDown (drill-down level 3) | Sub-account code |
| `Session["acc_code"]` | GLDrillDown | GLDrillDown (drill-down level 2) | Main account code |
| `Session["typ"]` | NightAudit | Audit sub-controls | `"DR"`, `"CR"`, `"CheckIn Pending"`, `"Checked-In"` |
| `Session["role"]` | Login page | LedgersCentre, AccountingPeriod | User role string |

---

## 16. File Inventory

### COOPERP/accounts/ Directory (44 files)

#### Shell Pages (load UserControls)

| File | UserControl Loaded |
|------|-------------------|
| `AccountingCenter.aspx` / `.cs` | Dynamic via AccountingPageLoader (pid 0-8) |
| `AccountLedger.aspx` / `.cs` | `LedgersCentre.ascx` |
| `AccountingPeriod.aspx` / `.cs` | `AccountingPeriods.ascx` |
| `BankReconciliation.aspx` / `.cs` | `BankReconciliation.ascx` |
| `BranchInfo.aspx` / `.cs` | `BranchInfo.ascx` |
| `BudgetManager.aspx` / `.cs` | `BudgetManager.ascx` |
| `CashBook.aspx` / `.cs` | `CashBook.ascx` |
| `CompanyInfo.aspx` / `.cs` | `CompanyInfo.ascx` |
| `FeesTracking.aspx` / `.cs` | `TermlyClasses.ascx` (schools module) |
| `GLDrillDown.aspx` / `.cs` | `GLDrillDown.ascx` |

#### Transaction Pages (popup wizards)

| File | Purpose |
|------|---------|
| `StudentReceipt.aspx` / `.cs` | Student fee receipt |
| `SponsorReceipt.aspx` / `.cs` | Sponsor payment receipt |
| `CreateJournal.aspx` / `.cs` | General journal entry |
| `PaymentVoucher.aspx` / `.cs` | Outgoing payment |
| `ContraVoucher.aspx` / `.cs` | Bank-to-bank transfer |
| `ReceiptDetails.aspx` / `.cs` | General receipt editing |
| `StudentReceiptDetails.aspx` / `.cs` | Student receipt with term/year |
| `TransactionDetails.aspx` / `.cs` | Read-only voucher drill-down |

#### Other Pages

| File | Purpose |
|------|---------|
| `NightAudit.aspx` / `.cs` | Night audit wizard (only page with real code-behind) |
| `MasterPage.master` / `.cs` | Accounts section master page |
| `GLAccount.aspx` / `.cs` | GL account listing (popup from GLDrillDown) |
| `ledgerTypes.aspx` / `.cs` | Ledger type management (popup from ChartAccounts) |
| `voucherDetails.aspx` / `.cs` | Voucher details editing |
| `SponsorReceiptDetails.aspx` / `.cs` | Sponsor receipt editing |

#### BLL Files

| File | Purpose |
|------|---------|
| `App_Code/CoreAccounting/AccountsBLL.cs` | Chart of Accounts + Voucher BLL |
| `App_Code/CoreAccounting/CoopERPData.xsd` | Core ERP typed dataset |
| `App_Code/CoreAccounting/AdjustmentsCentre.xsd` | Ledger adjustments typed dataset |
| `App_Code/Finance/StudentBillsPaymentBLL.cs` | Student billing BLL |
| `App_Code/Finance/FinancialData.xsd` | Student billing dataset |
| `App_Code/Finance/FinancialAnalytics.xsd` | Financial analytics dataset |
| `App_Code/Finance/GraduationFinance.xsd` | Graduation finance dataset |
| `App_Code/Finance/StudentAccountingData.xsd` | Student accounting dataset |

#### XtraReports

| File | Purpose |
|------|---------|
| `XtraReports/xtraReportCentre.aspx` | Report viewer popup |
| Various `.repx` files | Report definitions (Trial Balance, Income Statement, etc.) |

---

## Summary

The Accounting Center is a comprehensive double-entry bookkeeping system with:

- **9 routed modules** via AccountingPageLoader (pid 0-8)
- **8+ standalone pages** with their own URLs
- **8 transaction popup wizards** for creating financial entries
- **20+ stored procedures** for data manipulation
- **6 typed datasets** (.xsd) for data access
- **2 BLL classes** for business logic
- **5 main account categories** with unlimited sub-accounts
- **Multi-currency support** with forex rates
- **Bank reconciliation** with Excel import and auto-matching
- **Budget management** with actual vs planned tracking
- **Role-based security** (Bursar role for sensitive operations)
- **Full audit trail** via `acc_activity_log`

The central data flow is: **Journal/Voucher creation → Ledger posting → Balance updates → Report generation**, with all financial transactions ultimately landing in the `fin_ledger` table and becoming visible across GL Drill-Down, Account Ledgers, Cash Book, and Financial Reports.
