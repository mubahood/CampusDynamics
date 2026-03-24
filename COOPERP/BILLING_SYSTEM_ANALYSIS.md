# Campus Dynamics — Billing System Analysis & Improvement Plan

**Date:** 2026-03-23  
**Analyst:** System Audit  
**Database:** `campus_dynamics_accounts` (MySQL 5.6)  

---

## 1. CURRENT BILLING ARCHITECTURE

### 1.1 How Billing Works Today

Billing is a **manual/batch process** triggered by finance staff through the UI. There are **no database triggers** on the registration table. When a staff member selects registered students and clicks "Bill", the system looks up the fee schedule for each student's profile and inserts bill records into the financial tracking table.

### 1.2 The 6 Key Tables

| Table | Database | Records | Purpose |
|-------|----------|---------|---------|
| `acad_student` | campus_dynamics | — | Student master — holds `progid`, `studsesion` (DAY/EVENING/WEEKEND), `billingID`, `entryyear` |
| `acad_registration` | campus_dynamics | — | Per-semester registration — holds `regstatus`, `studyyear`, `residence_status` |
| `fin_billing_systems` | campus_dynamics_accounts | 3 | Billing system types: Local (ID=1), International (ID=5), Upgrader Local (ID=6) |
| `academicbillingitems` | campus_dynamics_accounts | 26 | Fee categories (Tuition, Function, Late Reg, Retake, etc.), each linked to a GL account |
| `fin_fees_pay_schedule` | campus_dynamics_accounts | 4,808 | **Primary fee matrix** — amount per (programme, session, billing system, entry year, study year, semester, item) |
| `fin_studentfeestracking` | campus_dynamics_accounts | 62,245 | **The ledger** — Bill and Payment transactions per student (29,097 bills, 33,148 payments) |

### 1.3 Additional Tables

| Table | Records | Purpose |
|-------|---------|---------|
| `fin_fees_structure` | 8,515 | Secondary fee matrix — for penalties/special items (Late Reg, Dead Year, Retake) and Remote Learning module billing |
| `stud_billing` | 0 (empty) | Legacy programme-level billing — no longer in use |
| `fin_fees_analysis_semester` | — | Semester-level fee analysis snapshots |
| `exemptions` | — | Employee fee exemptions |

---

## 2. BILLING FLOW — STEP BY STEP

### 2.1 Student Profile Lookup

When billing runs for a student (e.g., `MRU2024000047`), the system reads from `acad_student`:
- `progid` = BSAF (programme)
- `studsesion` = DAY (session type)
- `billingID` = 1 (Local Students Billing System)
- `entryyear` = 2023 (year of admission)

### 2.2 Registration Status Check

From `acad_registration`, it gets:
- `regstatus` — must be `REGISTERED` or `LATE REGISTERED` to bill
- `studyyear` — current study year (e.g., 3)
- `residence_status` — NON RESIDENT / RESIDENT

### 2.3 Fee Schedule Lookup

The system queries `fin_fees_pay_schedule` matching **all 5 dimensions**:
```sql
SELECT ItemID, amount
FROM fin_fees_pay_schedule
WHERE progid = 'BSAF'         -- student's programme
  AND stud_session = 'DAY'    -- student's session
  AND billingID = 1            -- student's billing system
  AND curr_year = 2023         -- student's entry year
  AND studyyear = 3            -- current study year
  AND semester = 1             -- current semester
```

This returns the specific amounts — e.g., Tuition 630,000 + Function Fees 663,000.

### 2.4 Bill Record Creation

For each fee schedule match, `fin_TermlyItemBillingFN()` does:
1. **INSERT IGNORE** into `fin_studentfeestracking` with `trans_type='Bill'`
2. Creates a corresponding **GL ledger entry** via `fin_TransactionCreatorFn2` (debits student ledger, credits income account)
3. Updates `post_status` from 'Pending' to 'Posted'
4. Calls `fin_UpdateAllLedgerBalances()` to recompute balances

### 2.5 The Decision Tree (`fin_Autobilling` Stored Procedure)

| Billing Type (param) | Condition | What Gets Billed |
|----------------------|-----------|------------------|
| `REG` | REGISTERED, non-remote | All items from `fin_fees_pay_schedule` matching student profile |
| `REG` | REGISTERED, Remote Learning | Per-module from `fin_fees_structure` + non-tuition from pay schedule |
| `REG` | LATE REGISTERED | Same as REGISTERED **plus** Late Registration Fee from `fin_fees_structure` |
| `REG` | DEAD YEAR | Only Dead Year fee from `fin_fees_structure` |
| `RT/RR/SPECIAL/SUPPLEMENTARY` | Any | Specific penalty fee from `fin_fees_structure` by type name |
| `ACCOMO` | RESIDENT | Accommodation price from `acad_halls` via `acad_residence` table |

### 2.6 Two Fee Tables — Why?

- **`fin_fees_pay_schedule`** — Primary source for **normal/regular billing** (Tuition + Function Fees). Amount varies by programme, session, billing system, entry year, study year, semester.
- **`fin_fees_structure`** — Used for **penalty/special items** and **Remote Learning** module-based billing. Same dimensions but different lookup logic.

---

## 3. ENTRY POINTS (Who Triggers Billing)

### 3.1 Manual Billing UI — `studentbilling.ascx`
- Staff selects students from a DevExpress grid
- Clicks "Create | Refresh"
- Loops through selected rows, calls `STUD.fin_Autobilling(regno, acadYear, semester, "REG", ...)` for each
- If student is RESIDENT, also calls with type `"ACCOMO"`
- **Location:** `UserControls/financials/studentbilling.ascx.cs`

### 3.2 Residence Allocation — `ResidenceAllocation.ascx`
- When allocating students to halls
- Automatically triggers `fin_Autobilling(..., "ACCOMO", ...)` for residents
- **Location:** `UserControls/StudentInfo/ResidenceAllocation.ascx.cs`

### 3.3 Batch SP — `BillUnbilledStudents`
- Finds all REGISTERED students with zero records in `fin_studentfeestracking`
- Bills them in bulk
- **PROBLEM:** Currently **hardcoded** to `2025/2026`, semester `2`

### 3.4 Registration Status Changes (NO auto-billing)
- `FeesRegistration.aspx.cs` — Register/Late Register/Change Status buttons
- `StudentsRegistration.aspx.cs` — Same actions (duplicated code)
- **Neither page calls billing after registration** — billing is a completely separate step

---

## 4. CRITICAL PROBLEMS FOUND

### 4.1 Double Billing — ACTIVE PROBLEM

**Root Cause:** The unique index `Index_UNQ` on `fin_studentfeestracking` includes the `detail` column. Since the detail string changes slightly between billing runs (e.g., `[]` vs `[-]`), the `INSERT IGNORE` does NOT prevent duplicate bills.

**Evidence (live data):**
```
| TID   | item_code | amount | detail                                          |
|-------|-----------|--------|-------------------------------------------------|
| 15989 | 1         | 630000 | Tuition Fees Sem :1, 2025/2026: MRU2024000047 [] |
| 71449 | 1         | 630000 | Tuition Fees Sem :1, 2025/2026: MRU2024000047 [-]|
```
Same student, same year, same semester, same item — **billed twice** because `[]` ≠ `[-]`.

**Scale:**
- **905** duplicate bill groups found
- **913** extra bill records in the system
- **UGX 647,228,950** (~647 million) in excess billing amounts
- Affects student ledger balances, making them appear to owe more than they actually do

### 4.2 No Automated Billing on Registration

When staff clicks "Register" on a student in `FeesRegistration.aspx` or `StudentsRegistration.aspx`:
- The `regstatus` is updated to `REGISTERED`
- **No billing is triggered**
- Staff must go to a separate `studentbilling.ascx` control to bill students
- This creates a gap where students can be registered but unbilled

### 4.3 Hardcoded Year/Semester in Batch SP

`BillUnbilledStudents` has:
```sql
WHERE r.acad_year = '2025/2026' AND r.semester = 2
```
This must be manually edited each semester — error-prone and easily forgotten.

### 4.4 No Billing Reversal Mechanism

- If a bill is created in error, there's no UI-based way to reverse/void it
- Double bills can only be fixed by direct database intervention
- No audit trail of who created/reversed bills

### 4.5 No Pre-billing Validation

- `fin_Autobilling` doesn't check if a fee schedule exists before attempting to bill
- If no schedule matches the student's profile, billing silently produces nothing
- No warning that a student's programme/session/entry year combination has no fee schedule

### 4.6 Duplicated Registration Code

Registration status changes exist in both:
- `FeesRegistration.aspx.cs` (lines 395–435, 730–775, 900–940)
- `StudentsRegistration.aspx.cs` (lines 750–1030)

Any fix to registration (e.g., adding auto-billing) must be applied in multiple places.

---

## 5. CONCRETE EXAMPLE: Student MRU2024000047

| Attribute | Value |
|-----------|-------|
| Programme | BSAF |
| Session | DAY |
| Billing System | 1 (Local) |
| Entry Year | 2023 |
| Current Study Year | 3 |

**Fee schedule for year 3, semester 1:**
- Tuition Fees: 630,000
- Function Fees: 663,000

**Actual bills in system for 2025/2026 sem 1:**
- TID 15989: Tuition 630,000 (billed 2024-10-22) — `[]`
- TID 15990: Function 693,000 (billed 2024-10-22) — `[]`
- TID 71449: Tuition 630,000 (billed 2025-10-05) — `[-]` ← DUPLICATE
- TID 71450: Function 663,000 (billed 2025-10-05) — `[-]` ← DUPLICATE

**Result:** Student owes 2,616,000 instead of 1,293,000 for this semester alone.

---

## 6. IMPROVEMENT PLAN

### Phase 1: Fix Double-Billing (URGENT — Data Integrity)

**6.1.1 Fix the Unique Index**
```sql
-- Drop the broken unique index (includes 'detail' column which varies)
ALTER TABLE fin_studentfeestracking DROP INDEX Index_UNQ;

-- Create a proper unique index WITHOUT the detail column
ALTER TABLE fin_studentfeestracking 
ADD UNIQUE INDEX UNQ_student_bill (regno, acadyear, semester, item_code, trans_type);
```
> **Note:** This will fail if duplicates exist. Must clean up duplicates first.

**6.1.2 Clean Up Existing Duplicates**
```sql
-- Identify and remove duplicate bills (keep the earliest TID)
DELETE t1 FROM fin_studentfeestracking t1
INNER JOIN fin_studentfeestracking t2
ON t1.regno = t2.regno
   AND t1.acadyear = t2.acadyear
   AND t1.semester = t2.semester
   AND t1.item_code = t2.item_code
   AND t1.trans_type = t2.trans_type
   AND t1.TID > t2.TID;

-- Also need to clean up the corresponding GL ledger entries
```

**6.1.3 Update `fin_TermlyItemBillingFN` to Pre-check**
Add a check at the start of the function:
```sql
-- Before INSERT, check if bill already exists
IF EXISTS (SELECT 1 FROM fin_studentfeestracking 
           WHERE regno=reg AND acadyear=acadyr AND semester=sems 
           AND item_code=ItemID AND trans_type='Bill') THEN
    RETURN 'Already Billed';
END IF;
```

### Phase 2: Automate Billing on Registration

**6.2.1 Create a New Stored Procedure: `fin_AutoBillOnRegistration`**
```sql
CREATE PROCEDURE fin_AutoBillOnRegistration(
    IN p_registration_id INT,
    IN p_user VARCHAR(45)
)
BEGIN
    DECLARE v_regno CHAR(35);
    DECLARE v_acad_year VARCHAR(45);
    DECLARE v_semester INT;
    DECLARE v_regstatus CHAR(25);
    DECLARE v_residence CHAR(25);
    
    -- Get registration details
    SELECT regno, acad_year, semester, regstatus, residence_status
    INTO v_regno, v_acad_year, v_semester, v_regstatus, v_residence
    FROM campus_dynamics.acad_registration WHERE ID = p_registration_id;
    
    -- Only bill if registered and not already billed
    IF v_regstatus IN ('REGISTERED', 'LATE REGISTERED') THEN
        IF NOT EXISTS (
            SELECT 1 FROM fin_studentfeestracking 
            WHERE regno = v_regno AND acadyear = v_acad_year 
            AND semester = v_semester AND trans_type = 'Bill'
        ) THEN
            CALL fin_Autobilling(v_regno, v_acad_year, v_semester, 'REG', p_user, '-');
            IF v_residence = 'RESIDENT' THEN
                CALL fin_Autobilling(v_regno, v_acad_year, v_semester, 'ACCOMO', p_user, '-');
            END IF;
        END IF;
    END IF;
END
```

**6.2.2 Integrate into Registration Code**
After every `DoSetStatus()` call that sets `REGISTERED` or `LATE REGISTERED`, add:
```csharp
// After successful registration, auto-bill
using (var acctConn = new MySqlConnection(AcctConnStr))
{
    acctConn.Open();
    using (var billCmd = new MySqlCommand("CALL fin_AutoBillOnRegistration(@regId, @user)", acctConn))
    {
        billCmd.Parameters.AddWithValue("@regId", id);
        billCmd.Parameters.AddWithValue("@user", GetCurrentUser());
        billCmd.ExecuteNonQuery();
    }
}
```

**6.2.3 Centralise Registration Logic**
Create `RegistrationHelper.cs` in `App_Code` to eliminate the duplicated code between `FeesRegistration.aspx.cs` and `StudentsRegistration.aspx.cs`:
```csharp
public static class RegistrationHelper
{
    public static bool RegisterStudent(int registrationId, string newStatus, string user)
    public static bool UnregisterStudent(int registrationId, string user)
    public static bool ClearStudent(int registrationId, string user)
    public static void AutoBillIfNeeded(int registrationId, string user)
}
```

### Phase 3: Parameterise the Batch SP

**6.3.1 Replace Hardcoded `BillUnbilledStudents`**
```sql
DROP PROCEDURE IF EXISTS BillUnbilledStudents;

CREATE PROCEDURE BillUnbilledStudents(
    IN p_acad_year VARCHAR(25),
    IN p_semester INT,
    IN p_user VARCHAR(45)
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_regno CHAR(35);
    DECLARE v_count INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT r.regno
        FROM campus_dynamics.acad_registration r
        WHERE r.acad_year = p_acad_year
          AND r.semester = p_semester
          AND r.regstatus IN ('REGISTERED', 'LATE REGISTERED')
          AND NOT EXISTS (
              SELECT 1 FROM fin_studentfeestracking ft
              WHERE ft.regno = r.regno 
                AND ft.acadyear = p_acad_year 
                AND ft.semester = p_semester
                AND ft.trans_type = 'Bill'
          );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    loop1: LOOP
        FETCH cur INTO v_regno;
        IF done = 1 THEN LEAVE loop1; END IF;
        CALL fin_Autobilling(v_regno, p_acad_year, p_semester, 'REG', p_user, '-');
        CALL fin_Autobilling(v_regno, p_acad_year, p_semester, 'ACCOMO', p_user, '-');
        SET v_count = v_count + 1;
    END LOOP;
    CLOSE cur;
    
    SELECT v_count AS students_billed;
END
```

### Phase 4: Admin Billing Management Page

Create a new **BillingManagement.aspx** page with:

1. **Dashboard Panel:**
   - Total billed vs unbilled students per year/semester
   - Total bill amount vs payment amount vs outstanding balance
   - Collection rate percentage

2. **Billing Actions Panel:**
   - "Bill All Unbilled" button (calls parameterised `BillUnbilledStudents`)
   - "Bill Selected Students" with student search/selection
   - Year/semester/programme filters

3. **Billing Audit Panel:**
   - Log of all billing actions (who billed, when, how many students)
   - Requires new `fin_billing_audit` table

4. **Bill Reversal Panel:**
   - Search by student → show their bills
   - "Void Bill" action (creates a negative `Bill` entry or marks as `Voided`)
   - Requires approval workflow for large reversals

5. **Fee Schedule Validation Panel:**
   - Shows programmes with missing fee schedules
   - Highlights students whose profile has no matching schedule
   - Prevents silent billing failures

### Phase 5: Billing Audit Trail

**New table:**
```sql
CREATE TABLE fin_billing_audit (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('BILL','VOID','REVERSE','BATCH_BILL') NOT NULL,
    regno VARCHAR(25),
    acadyear VARCHAR(25),
    semester INT,
    item_code INT,
    amount DOUBLE,
    tracking_tid INT UNSIGNED,
    performed_by VARCHAR(45) NOT NULL,
    performed_at DATETIME NOT NULL DEFAULT NOW(),
    notes VARCHAR(500),
    INDEX idx_regno (regno),
    INDEX idx_date (performed_at)
);
```

---

## 7. IMPLEMENTATION PRIORITY

| Priority | Task | Impact | Effort |
|----------|------|--------|--------|
| **P0** | Fix unique index + clean duplicates | Stops 647M UGX data corruption | 1 day |
| **P0** | Add pre-check in `fin_TermlyItemBillingFN` | Prevents future double billing | 30 min |
| **P1** | Create `fin_AutoBillOnRegistration` SP | Automates billing on registration | 2 hours |
| **P1** | Integrate auto-billing into FeesRegistration + StudentsRegistration | End-to-end automation | 1 day |
| **P2** | Parameterise `BillUnbilledStudents` | Eliminates hardcoded semester | 1 hour |
| **P2** | Create `RegistrationHelper.cs` | Eliminates code duplication | 1 day |
| **P3** | Create `BillingManagement.aspx` admin page | Full admin control | 3-5 days |
| **P3** | Create `fin_billing_audit` table + logging | Audit trail | 1 day |
| **P4** | Fee schedule validation panel | Prevents silent failures | 1 day |

---

## 8. STORED PROCEDURE CALL CHAIN

```
Staff clicks "Register" on FeesRegistration.aspx
    → DoSetStatus(id, "REGISTERED", ...) — updates acad_registration
    → [PROPOSED] AutoBillIfNeeded(id, user)
        → CALL fin_AutoBillOnRegistration(id, user)
            → Checks: is REGISTERED? not already billed?
            → CALL fin_Autobilling(regno, acadYear, semester, 'REG', user, '-')
                → Reads acad_student (progid, session, billingID, entryYear)
                → Reads acad_registration (regstatus, studyYear, residence)
                → Queries fin_fees_pay_schedule for matching amounts
                → For each fee item:
                    → fin_TermlyItemBillingFN(...)
                        → [PROPOSED] Pre-check: already billed?
                        → INSERT IGNORE into fin_studentfeestracking (trans_type='Bill')
                        → fin_TransactionCreatorFn2(...) — creates GL entries
                        → UPDATE post_status = 'Posted'
                        → fin_UpdateAllLedgerBalances()
            → If RESIDENT: CALL fin_Autobilling(..., 'ACCOMO', ...)
```

---

*End of Analysis*

---

## 9. IMPLEMENTATION LOG (2026-03-23)

### 9.1 Completed Actions

| # | Action | Status |
|---|--------|--------|
| 1 | **Backup created** — `fin_studentfeestracking_backup_20260323`, `fin_ledger_backup_20260323` | ✅ |
| 2 | **Cleaned 913 duplicate bill records** — kept MIN(TID) per group | ✅ |
| 3 | **Cleaned GL entries** for removed duplicate bill TIDs | ✅ |
| 4 | **Dropped broken `Index_UNQ`** — was `(regno, semester, acadyear, item_code, trans_type, detail)` with `detail` column causing duplicates | ✅ |
| 5 | **Added `idx_student_billing`** — non-unique index `(regno, acadyear, semester, item_code, trans_type)` for query performance | ✅ |
| 6 | **Modified `fin_TermlyItemBillingFN`** — added pre-check: returns 'Already Billed' if bill exists for same (regno, acadyear, semester, item_code). Changed `INSERT IGNORE` to plain `INSERT`. Returns `char(25)` instead of `char(11)` | ✅ |
| 7 | **Created `fin_AutoBillOnRegistration` SP** — wrapper that checks registration status and calls `fin_Autobilling` for REG + ACCOMO. Safe to call repeatedly | ✅ |
| 8 | **Parameterised `BillUnbilledStudents` SP** — replaced hardcoded `'2025/2026'` and `2` with `(p_acadyear, p_semester)` parameters | ✅ |
| 9 | **Integrated auto-billing into FeesRegistration.aspx.cs** — `AutoBillStudent()` called after: individual register, late-register, batch register, batch late-register, add-registration modal, change-status modal | ✅ |
| 10 | **Integrated auto-billing into StudentsRegistration.aspx.cs** — identical hooks as FeesRegistration | ✅ |
| 11 | **Added Anomaly Stats to FeesManagement dashboard** — 3 cards: Registered-Not-Billed (111), Bills-No-GL (291), Duplicate-Bills (0) | ✅ |
| 12 | **Added Paid-but-Unregistered list** — students with payments in last 30 days but not REGISTERED/LATE REGISTERED/CLEARED | ✅ |

### 9.2 Test Results (MRU2024000047)

- Pre-check returns "Already Billed" for existing bills ✅
- Bill count unchanged after re-billing attempts (2 bills per semester) ✅
- `fin_AutoBillOnRegistration` SP safe for repeated calls ✅
- No duplicates possible with new pre-check mechanism ✅

### 9.3 Post-Implementation Data State

| Metric | Before | After |
|--------|--------|-------|
| Total records | 62,245 | 61,333 |
| Total bills | 29,097 | 28,184 |
| Duplicate bill groups | 905 | 0 |
| Excess bills removed | — | 913 |

### 9.4 Files Modified

- `COOPERP/NewScreens/FeesRegistration.aspx.cs` — Added AcctConnStr, AutoBillStudent(), billing hooks
- `COOPERP/NewScreens/StudentsRegistration.aspx.cs` — Same as above
- `COOPERP/NewScreens/FeesManagement.aspx` — Added anomaly section CSS/HTML, paid-unregistered panel
- `COOPERP/NewScreens/FeesManagement.aspx.cs` — LoadAnomalyStats(), LoadPaidButUnregistered()

### 9.5 SQL Files

- `sql/fix_billing_function.sql` — Modified fin_TermlyItemBillingFN with pre-check
- `sql/create_auto_bill_sp.sql` — fin_AutoBillOnRegistration SP
- `sql/fix_bill_unbilled_sp.sql` — Parameterised BillUnbilledStudents
- `sql/cleanup_step1_gl.sql` — GL cleanup for duplicate bills
- `sql/cleanup_step2_bills.sql` — Duplicate bill record deletion
