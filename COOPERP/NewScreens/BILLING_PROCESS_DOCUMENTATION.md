# Campus Dynamics — Fees & Billing Process Documentation
**File:** `COOPERP/NewScreens/FeesStructure.aspx`  
**Code-behind:** `COOPERP/NewScreens/FeesStructure.aspx.cs` (~1744 lines)  
**Last updated:** June 2025  

---

## Table of Contents
1. [Overview](#1-overview)
2. [Architecture & Databases](#2-architecture--databases)
3. [Database Tables](#3-database-tables)
4. [Page Lifecycle & Key Constraint](#4-page-lifecycle--key-constraint)
5. [Tab 1 — Programme Fee Structures](#5-tab-1--programme-fee-structures)
   - 5.1 Fee Structure Data Model
   - 5.2 Add/Edit a Fee Structure
   - 5.3 Activate / Deactivate
   - 5.4 Batch Operations
   - 5.5 Delete
6. [Tab 2 — Process Billing](#6-tab-2--process-billing)
   - 6.1 Preview Step
   - 6.2 Execute Step
   - 6.3 Stored Procedure: `fin_BillProgrammeFees`
7. [Tab 3 — Billing Items](#7-tab-3--billing-items)
8. [Tab 4 — Billing Systems](#8-tab-4--billing-systems)
9. [Auto-Billing on Registration](#9-auto-billing-on-registration)
10. [Business Rules & Validations](#10-business-rules--validations)
11. [Known Gotchas & Technical Notes](#11-known-gotchas--technical-notes)

---

## 1. Overview

`FeesStructure.aspx` is the **central configuration screen** for the Campus Dynamics billing pipeline. It handles three interconnected concerns:

| Concern | Description |
|---|---|
| **Programme Fee Structures** | Define per-semester tuition & functional fees for each programme, broken down by year (Year 1/2/3) and semester (S1/S2/S3). |
| **Process Billing** | Bulk-apply a fee structure to all registered students in the current academic year, inserting bill records into `fin_studentfeestracking`. |
| **Billing Items & Systems** | Reference tables that classify fee line items and billing systems/currencies. |

The page is a post-back–driven ASP.NET Web Forms page running on top of **two MySQL databases** (`campus_dynamics` for academic data, `campus_dynamics_accounts` for financial data).

---

## 2. Architecture & Databases

### Connection Strings (web.config)
| Alias in code | Config key | Database |
|---|---|---|
| `MainConnStr` | `vacConnectionString` | `campus_dynamics` — academic, student, registration data |
| `AcctConnStr` | `accountsConnectionString` | `campus_dynamics_accounts` — financial/billing data |

### Cross-database JOINs
Several queries JOIN across both databases, e.g.:
```sql
SELECT pf.*, p.progname
FROM campus_dynamics_accounts.fin_programme_fees pf
LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = pf.progcode
```
MySQL allows this as both databases are on the same server instance.

---

## 3. Database Tables

### `campus_dynamics_accounts.fin_programme_fees`
**Core fee structure definition table. One row per fee structure version per programme.**

| Column | Type | Description |
|---|---|---|
| `ID` | INT PK AUTO_INCREMENT | Unique record ID |
| `progcode` | VARCHAR | Programme code (FK → `acad_programme.progcode`) |
| `has_year_1` | VARCHAR(`Yes`/`No`) | Whether Year 1 is applicable |
| `has_year_2` | VARCHAR(`Yes`/`No`) | Whether Year 2 is applicable |
| `has_year_3` | VARCHAR(`Yes`/`No`) | Whether Year 3 is applicable |
| `y1_s1_tuition` | DECIMAL | Year 1, Semester 1 — Tuition fee |
| `y1_s1_functional` | DECIMAL | Year 1, Semester 1 — Functional fee |
| `y1_s2_tuition` | DECIMAL | Year 1, Semester 2 — Tuition fee |
| `y1_s2_functional` | DECIMAL | Year 1, Semester 2 — Functional fee |
| `y1_s3_tuition` | DECIMAL | Year 1, Semester 3 — Tuition fee |
| `y1_s3_functional` | DECIMAL | Year 1, Semester 3 — Functional fee |
| `y2_s1_tuition` … `y2_s3_functional` | DECIMAL | Year 2 equivalents (6 columns) |
| `y3_s1_tuition` … `y3_s3_functional` | DECIMAL | Year 3 equivalents (6 columns) |
| `is_active` | VARCHAR(`Yes`/`No`) | Only ONE active record per `progcode` is enforced in code |
| `created_by` | VARCHAR | Username who created the record |

> **Total amount columns: 18** (3 years × 3 semesters × 2 fee types)

---

### `campus_dynamics_accounts.fin_studentfeestracking`
**Per-student billing/payment transaction ledger.** Billing inserts `trans_type='Bill'` rows here.

| Column | Description |
|---|---|
| `regno` | Student registration number |
| `item_code` | Fee item code (1 = Tuition, 52 = Functional) |
| `amount` | Amount |
| `trans_type` | `'Bill'` (charge) or `'Payment'` |
| `acadyear` | e.g., `2024/2025` |
| `semester` | 1, 2, or 3 |
| `created_by` | Username |

---

### `campus_dynamics_accounts.academicbillingitems`
**Reference table for fee line item types.**

| Column | Description |
|---|---|
| `ItemCode` | PK — numeric code (1 = Tuition, 52 = Functional, etc.) |
| `ItemName` | Display name |
| `AccountCode` | GL account code for accounting integration |
| `PriorityCode` | `> 0` = Core (required), `0` = Optional |

---

### `campus_dynamics_accounts.fin_billing_systems`
**Reference table for billing system configurations.**

| Column | Description |
|---|---|
| `ID` | PK |
| `bs_name` | System name |
| `bs_description` | Description |
| `bs_currency` | Currency code (e.g., `GHS`) |

---

### Academic Tables (in `campus_dynamics`)
| Table | Used for |
|---|---|
| `acad_programme` | Programmes list — `progcode`, `progname`, `faculty_code` |
| `acad_faculty` | Faculty names |
| `acad_student` | Student records — `regno`, `progid` (= progcode), `studsesion` (Day/Evening/Weekend) |
| `acad_registration` | Registration records — `regno`, `studyyear`, `semester`, `regstatus`, `acad_year` |
| `acad_acadyears` | Academic years — `acadyear`, `is_current_year` |

---

## 4. Page Lifecycle & Key Constraint

### ViewState Disabled — Critical Constraint
The master page (`SidebarMaster.master`) has `EnableViewState="false"`. This means **all dropdown values are lost between postbacks** unless the control is repopulated before ASP.NET's postback processing.

### Lifecycle Order (ASP.NET Web Forms)
```
OnInit()  ← RUNS FIRST (before ProcessPostData)
    ↓
ProcessPostData  ← ASP.NET matches posted form values to controls
    ↓
Page_Load()  ← RUNS AFTER matching — too late to add items
    ↓
(Event handlers)
    ↓
OnPreRender()  ← Final data load before rendering
```

### The Fix in Place
Because of the ViewState constraint, the programme dropdown MUST be populated in `OnInit()`:

```csharp
protected override void OnInit(EventArgs e)
{
    base.OnInit(e);
    // Populate with ALL programmes so ASP.NET can match the posted value
    PopulatePFProgrammeDropdown("__ALL__");
}

protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
        // First load: filter out already-configured programmes
        PopulatePFProgrammeDropdown("");
}
```

`PopulatePFProgrammeDropdown(includeProgcode)` behaviour:
- `includeProgcode = ""` (empty) → excludes programmes that already have a fee structure (for the Add modal)
- `includeProgcode = any non-empty string` → includes ALL programmes (for OnInit, and for Edit where we must include the current programme)
- `includeProgcode = "__ALL__"` → sentinel value used specifically in OnInit

---

## 5. Tab 1 — Programme Fee Structures

### 5.1 Fee Structure Data Model

Each fee structure covers up to **3 study years**, each with up to **3 semesters**. Each year must be explicitly enabled (`has_year_1/2/3 = 'Yes'`). This allows programmes that run for 1, 2, or 3 years to be handled with the same table.

The **grand total** displayed in the list is computed at runtime:
```csharp
// For each year where has_year_N = 'Yes', sum all 3 semesters (tuition + functional)
// Only counts the semesters even if fee is zero
grandTotal = sum(y1_s1_tuition + y1_s1_functional + y1_s2... + y1_s3...) for active years
```

The **display** shows:
- Year dots (coloured circles: ●●● for active, ○○○ for inactive years)
- Y1 S1 Tuition (first semester fee as a reference)
- Grand total across all active years and semesters
- Active/Inactive badge

### 5.2 Add/Edit a Fee Structure

**Add (`btnAddStructure_Click`):**
1. Sets `hfEditId` to empty
2. Repopulates dropdown excluding already-configured programmes
3. Resets all 18 amount fields to `0`
4. Sets Year 1 = checked, Year 2/3 = unchecked, Status = `No` (inactive by default)
5. JS opens the `modal-prog-fee` modal

**Save (`btnSavePF_Click`):**
1. Validates: programme must be selected
2. Parses 18 fee amount fields via `ParseAmt()` (strips commas, converts to `double`)
3. Reads year checkboxes (`chkYear1/2/3`) → `"Yes"` / `"No"`
4. **Prevent duplicate active:** If saving as active, checks that no other active structure exists for that `progcode`
5. If `hfEditId` is empty → `INSERT INTO fin_programme_fees`
6. If `hfEditId` has a value → `UPDATE fin_programme_fees WHERE ID=@id`
7. All 18 columns updated; `created_by` only set on INSERT

**Edit (`btnToggleActive_Click` with `hfEditType = "PF_EDIT"`):**
- Calls `LoadPFForEdit(pfId)` which reads the record and populates all form fields
- Repopulates dropdown with the current programme included
- Injects JS to open modal and update its title to `"Edit Fee Structure #N"`

### 5.3 Activate / Deactivate

Toggle via action menu → sets `hfEditType = "PF_TOGGLE"`:
1. Reads current `is_active` status
2. If activating: checks no other active structure exists for that `progcode` (enforces one-active-per-programme rule)
3. Updates `fin_programme_fees SET is_active = newActive WHERE ID = @id`

**Batch activate/deactivate** (via `btnBatchAction_Click`):
- Iterates over selected IDs and updates each individually
- No duplicate-check is performed on batch activate (allows setting multiple active for a programme via batch — be cautious)

### 5.4 Batch Operations

Accessed via the multi-select batch action toolbar. Four actions:

| Action | What it does |
|---|---|
| `ACTIVATE` | Sets `is_active = 'Yes'` for all selected IDs |
| `DEACTIVATE` | Sets `is_active = 'No'` for all selected IDs |
| `DELETE` | Deletes all selected fee structure records |
| `ADJUST` | Multiplies all tuition and/or functional fees by `(1 + pct/100)`, rounded to nearest integer |

The `ADJUST` action supports targeting:
- `TUITION` — adjusts only `y*_s*_tuition` columns
- `FUNCTIONAL` — adjusts only `y*_s*_functional` columns
- `ALL` — adjusts both

SQL for adjust is dynamically built as `UPDATE fin_programme_fees SET col=ROUND(col*@mult,0) WHERE ID=@id`.

### 5.5 Delete

Individual delete via action menu → sets `hfEditType = "PF"` → `btnDeleteRow_Click` runs:
```sql
DELETE FROM fin_programme_fees WHERE ID=@id
```
> **Note:** Deleting a fee structure does NOT delete existing billing records in `fin_studentfeestracking`. Historical billing data is preserved.

---

## 6. Tab 2 — Process Billing

Process Billing is the mechanism for batch-applying a fee structure to all currently registered students of the applicable programme.

### 6.1 Preview Step (`btnPreviewBilling_Click`)

Triggered when user clicks "Process Billing" from the action menu. `hfBillingPfId` holds the fee structure ID.

**Algorithm (optimised — 4 database queries total, no N+1):**

```
Step 1: Load fee structure from fin_programme_fees
        → builds feeLookup["year_sem"] = [tuition, functional]

Step 2: Load ALL registered students for that progcode in current acad year
        Query: acad_registration JOIN acad_student
        Filter: regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
        → builds list of StudentBillingInfo with tuition/functional from feeLookup

Step 3: Batch-load ALL existing bills in ONE query
        Query: fin_studentfeestracking JOIN acad_student
        Filter: trans_type='Bill' AND item_code IN (1, 52) AND acadyear=@acad
        → builds existingBills dict: "regno|semester|itemcode" → amount

Step 4: Classify students in-memory (zero DB calls)
        - Both tuition (item 1) AND functional (item 52) billed → "Already Billed"
        - Only one billed → partial — remaining goes to "To Be Billed"
        - Neither billed, has fees → "To Be Billed"
        - Neither billed, no fees defined for their year/sem → "No Fee Defined" count

Step 5: Build HTML preview output
        - Unbilled students table (with amounts to be billed)
        - Already-billed students table (with historical amounts)
        - Summary cards: To Be Billed count, Already Billed count, Total Registered, Amount to Bill
        - Warning if fee structure is INACTIVE
        - "Proceed" button disabled if no students to bill OR fee structure is inactive
```

### 6.2 Execute Step (`btnExecuteBilling_Click`)

Triggered when user clicks "Confirm" or "Proceed" in the billing modal after previewing.

**Algorithm:**

```
Step 1: Load fee structure — MUST be is_active='Yes' (hard requirement)
        → builds feeLookup["year_sem"] = [tuition, functional]

Step 2: Load registered students (same query as preview)

Step 3: Batch-load existing bills into a HashSet<string>
        (same keys as preview: "regno|semester|itemcode")

Step 4: For each student:
        IF tuition AND functional already in existingBills → skip (alreadyBilledCount++)
        IF tuition <= 0 AND functional <= 0 → skip (noFeeSkipped++)
        ELSE → CALL fin_BillProgrammeFees SP

Step 5: Show result summary (success/partial/error)
```

**SP Call signature:**
```sql
CALL fin_BillProgrammeFees(
    @reg    -- student regno
    @prog   -- programme code
    @sess   -- session (Day/Evening/Weekend, defaults to 'Day' if empty)
    @yr     -- study year (1/2/3)
    @sem    -- semester (1/2/3)
    @acad   -- academic year string (e.g. '2024/2025')
    @user   -- username
    @csid   -- call site ID ('BATCH' for batch process billing)
)
```

### 6.3 Stored Procedure: `fin_BillProgrammeFees`

This SP is defined in MySQL (`campus_dynamics_accounts`). It:
1. Looks up the active fee structure for the given `progcode`
2. Calls `fin_TermlyItemBillingFN` (a function) for each fee item (tuition item code 1, functional item code 52)
3. `fin_TermlyItemBillingFN` has a built-in **duplicate check** — it will not insert a bill if one already exists for the same student/year/semester/item/acadyear combination
4. Inserts into `fin_studentfeestracking` with `trans_type='Bill'`

> **Design note:** The C# code pre-filters already-billed students before calling the SP (using the in-memory HashSet), but the SP also has its own duplicate guard. The pre-filter is a performance optimization (avoids SP overhead for already-billed students), not a replacement for the SP's own safety check.

---

## 7. Tab 3 — Billing Items

Reference table `academicbillingitems` — defines the types of fee charges that can appear in `fin_studentfeestracking`.

**Key item codes used in billing:**
| ItemCode | Meaning |
|---|---|
| `1` | Tuition fee |
| `52` | Functional fee |

**Fields managed:**
- `ItemName` — display name
- `AccountCode` — GL account code for accounts integration
- `PriorityCode` — `> 0` = Core/required, `0` = Optional

CRUD operations are standard INSERT/UPDATE/DELETE via `btnSaveBillingItem_Click` and `btnDeleteRow_Click` (with `hfEditType = "BI"`).

---

## 8. Tab 4 — Billing Systems

Reference table `fin_billing_systems` — defines billing systems (e.g., different currencies or billing rule sets).

**Fields managed:**
- `bs_name` — system name
- `bs_description` — description
- `bs_currency` — currency code

CRUD via `btnSaveBillingSystem_Click` and `btnDeleteRow_Click` (with `hfEditType = "BS"`).

> This table is currently a reference/lookup store. It is not yet directly wired to fee structure assignment — future use may link fee structures to specific billing systems.

---

## 9. Auto-Billing on Registration

Beyond the manual "Process Billing" feature, the system supports **auto-billing on student registration**. This occurs in the student registration flow (outside `FeesStructure.aspx`), calling the same `fin_BillProgrammeFees` SP with `@csid = 'AUTO'` or similar — the SP is the single shared billing entry point.

The `@csid` parameter distinguishes call origin:
- `'BATCH'` — triggered from Process Billing on FeesStructure.aspx
- Other values — e.g., from auto-billing hooks in the registration pages

---

## 10. Business Rules & Validations

| Rule | Where enforced |
|---|---|
| Only **one ACTIVE** fee structure per programme | `btnSavePF_Click` (on save) and `btnToggleActive_Click` (on activate) — both check for existing active record |
| Only **ACTIVE** fee structures can be used for billing | `btnExecuteBilling_Click` — queries `WHERE is_active='Yes'` |
| **Preview must be shown** before billing can be executed | JS disables Proceed button until preview completes; `_pbPreviewDone` flag |
| Students must have `regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')` | Both preview and execute queries filter on these statuses |
| A student is billed per (regno, semester, item_code, acadyear) combination | SP's internal duplicate check + C# pre-filter using existingBills |
| Billing uses **current academic year** only | `GET acad_acadyears WHERE is_current_year='Yes'` — billing will abort if no current year set |
| Batch activate does NOT enforce one-active-per-programme | Known gap — bulk activation can create multiple active structures for same programme |
| Amounts are stored and displayed as integers (rounded) | `ParseAmt()` converts to double; display uses `ROUND(...,0)` in SQL for adjustments |

---

## 11. Known Gotchas & Technical Notes

### ViewState Disabled — Dropdown Population
Because `SidebarMaster.master` sets `EnableViewState="false"`, ALL DropDownLists must be populated in `OnInit()` (before `ProcessPostData`), not in `Page_Load`. The `OnInit` populates with all programmes (`"__ALL__"` sentinel), and `Page_Load` re-populates filtered on first load only.

### Cross-Database Queries
Queries in `FeesStructure.aspx.cs` that reference both databases use fully-qualified table names (`campus_dynamics.acad_student`, `campus_dynamics.acad_programme`). This requires the MySQL user to have SELECT grants on both databases.

### `hfEditType` State Machine
The hidden field `hfEditType` drives the action router in `btnToggleActive_Click` and `btnDeleteRow_Click`:

| Value | Action |
|---|---|
| `PF_EDIT` | Load fee structure into edit modal |
| `PF_TOGGLE` | Toggle is_active on the fee structure |
| `PF` | Delete fee structure |
| `BI` | Delete billing item |
| `BS` | Delete billing system |

### `hfActivePanel` Tab Persistence
`hfActivePanel` stores the name of the active tab across postbacks (`"prog-fees"`, `"billing-items"`, `"billing-systems"`). Every button handler sets this before returning, so the page re-renders with the correct tab visible.

### Error Handling in Batch Billing
Errors from individual SP calls are collected (up to 5 displayed) and a partial-success result is shown if some students billed and some errored. The operation is NOT transactional — a failure on student N does not roll back students 1..N-1.

### Fee Amount Display
- **List view:** Y1S1 Tuition displayed as reference; grand total is runtime-calculated
- **Form input:** text boxes accept comma-formatted numbers; `ParseAmt()` strips commas
- **Database:** stored as DECIMAL; retrieved as `double` in C#

### `fin_TermlyItemBillingFN`
This is a MySQL **function** (not a procedure) referenced internally by `fin_BillProgrammeFees`. It is the atomic billing unit — inserts one `fin_studentfeestracking` row and enforces the per-student duplicate constraint.

---

*This document was generated as a reference for the billing pipeline implemented in FeesStructure.aspx/cs. For changes to the stored procedures, consult the MySQL database directly — they are not stored in the COOPERP codebase.*
