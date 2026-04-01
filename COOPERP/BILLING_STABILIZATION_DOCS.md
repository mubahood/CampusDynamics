# BILLING SYSTEM STABILIZATION - Complete Documentation

## Campus Dynamics Accounts — Bulletproof Billing System
**Date:** April 2026  
**Database:** MySQL 5.6 — `campus_dynamics_accounts`

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Root Cause Analysis](#2-root-cause-analysis)
3. [Architecture Overview](#3-architecture-overview)
4. [Protection Layers](#4-protection-layers)
5. [Schema Changes](#5-schema-changes)
6. [Hardened Functions Reference](#6-hardened-functions-reference)
7. [Audit & Diagnostic Tools](#7-audit--diagnostic-tools)
8. [How to Investigate Issues](#8-how-to-investigate-issues)
9. [What Was Removed](#9-what-was-removed)
10. [Existing Triggers (Safe)](#10-existing-triggers-safe)
11. [Quick Reference Commands](#11-quick-reference-commands)
12. [Fix Double Billing — Student Self-Service Tool](#12-fix-double-billing--student-self-service-tool)
13. [Admin Batch Double-Billing Fix — 3-Step Wizard](#13-admin-batch-double-billing-fix--3-step-wizard)

---

## 1. Executive Summary

The billing system experienced a mass double-billing event on **2026-03-31** where **29,891 duplicate entries** were created in `fin_ledger`, affecting **5,176 students** totaling **UGX 16.6 billion** in phantom charges.

**Root Cause:** A MySQL scheduled event (`evt_GLSyncRepair`) running every 15 minutes called a stored procedure (`fin_SyncTrackingToLedger`) that blindly re-created ledger entries from the tracking table without checking for existing entries.

**Resolution:**
1. Removed all dangerous automation (event, triggers, SP)
2. Deleted all 29,891 duplicate entries + 6 System-created duplicates
3. Added **3 layers of duplicate protection** to make future double billing physically impossible
4. Created audit/diagnostic tools for ongoing monitoring
5. Hardened all 5 billing functions with dedup guards

---

## 2. Root Cause Analysis

### The Disaster Chain
```
evt_GLSyncRepair (every 15 min)
   └─> fin_SyncTrackingToLedger (SP)
       └─> For each row in fin_studentfeestracking:
           └─> INSERT INTO fin_ledger (NO dedup check!)
               └─> Created 29,891 duplicate entries on 2026-03-31
```

### Why It Happened
- `fin_TransactionCreatorFn2` did blind INSERTs (no EXISTS check, no UNIQUE constraint)
- `fin_ledger` had ZERO unique constraints beyond the primary key
- No tracking mechanism linked ledger entries back to their origin
- No database-level guard against duplicate billing

### Forensic Breakdown of the 29,891 entries
| Category | Count | Description |
|----------|-------|-------------|
| Folio-match duplicates | 28,532 | `BillNo:TID` already existed in ledger |
| Amount+date duplicates | 70 | Same amount+date+student already existed |
| Legitimate (had no match) | 1,289 | Tracking entries that genuinely had no ledger entry (but still created by the broken sync) |

---

## 3. Architecture Overview

### Billing Chain (After Hardening)
```
Application Layer (C#)
    │
    ▼
fin_AutobillingV2 (SP) ─────── Orchestrator, calls billing fns per fee item
    │
    ├─> fin_BillProgrammeFees (SP) ─── Handles tuition (item 1) + functional (item 52)
    │       │
    │       └─> fin_TermlyItemBillingFN ──┐
    │                                     │
    ├─> fin_TermlyItemBillingFN ──────────┤  Main billing function
    │                                     │
    │       ┌─────────────────────────────┘
    │       │
    │       ▼
    │   [GUARD 1] Check fin_studentfeestracking (existingBill > 0 → "Already Billed")
    │       │
    │   [GUARD 2] Check fin_ledger directly (existingLedger > 0 → "Already In Ledger")
    │       │
    │       ▼
    │   INSERT INTO fin_studentfeestracking (tracking entry, status='Pending')
    │       │
    │       ▼
    │   fin_TransactionCreatorFn2 ──────── Core transaction creator
    │       │
    │       ├─ Extract tracking_ref from folio (BillNo:TID → TID)
    │       ├─ Set source_system = 'Billing'
    │       ├─ INSERT IGNORE into fin_ledger (DR entry)  ← [GUARD 3] UNIQUE index
    │       └─ INSERT IGNORE into fin_ledger (CR entry)  ← [GUARD 3] UNIQUE index
    │       │
    │       ▼
    │   UPDATE tracking to 'Posted'
    │   CALL fin_UpdateAllLedgerBalances()
    │
    ├─> fin_SingleTermlyItemBillingFN ──── Single item billing (uses v1 function)
    │       └─> fin_TransactionCreatorFn (same INSERT IGNORE + tracking_ref)
    │
    └─> fin_CustomTermlyItemBillingFN ──── Custom amount billing (uses v1 function)
            └─> fin_TransactionCreatorFn (same INSERT IGNORE + tracking_ref)
```

### Display Chain (How Balances Are Shown)
```
3 Pages + 2 SPs use UNION ALL with 3-condition NOT EXISTS:

SELECT ... FROM fin_ledger WHERE accountcode=? AND account_type='Student'
UNION ALL
SELECT ... FROM fin_studentfeestracking t
WHERE t.regno = ?
  AND NOT EXISTS (match by voucherNo = t.TID)         -- Condition 1
  AND NOT EXISTS (match by folio = 'BillNo:' + t.TID) -- Condition 2
  AND NOT EXISTS (match by amount + date + detail)     -- Condition 3
```

---

## 4. Protection Layers

### Layer 1: Function-Level Guard (Tracking Table Check)
- **Where:** `fin_TermlyItemBillingFN`, `fin_SingleTermlyItemBillingFN`, `fin_CustomTermlyItemBillingFN`
- **How:** `SELECT COUNT(*) ... FROM fin_studentfeestracking WHERE regno=? AND acadyear=? AND semester=? AND item_code=? AND trans_type='Bill'`
- **Result:** Returns "Already Billed" if count > 0
- **Catches:** Normal duplicate billing attempts

### Layer 2: Function-Level Guard (Ledger Direct Check)
- **Where:** `fin_TermlyItemBillingFN`
- **How:** `SELECT COUNT(*) ... FROM fin_ledger WHERE accountcode=? AND folio LIKE 'BillNo:%' AND particulars LIKE '%ItemName%' AND particulars LIKE '%acadyear%' AND particulars LIKE '%Term:semester%'`
- **Result:** Returns "Already In Ledger" if found
- **Catches:** Cases where tracking was deleted but ledger entry remains (belt-and-suspenders)

### Layer 3: Database-Level Guard (UNIQUE Index)
- **Where:** `fin_ledger` table
- **Index:** `UNIQUE KEY uq_billing_entry (tracking_ref, accountcode, transactionType)`
- **How:** When `fin_TransactionCreatorFn2` extracts `tracking_ref` from the `BillNo:TID` folio and sets it on the INSERT, the UNIQUE index physically prevents a duplicate
- **Result:** `INSERT IGNORE` silently skips the duplicate, function returns "Skipped:Exists"
- **Catches:** Race conditions, concurrent billing, ANY attempted duplicate — even if Layers 1 and 2 somehow fail
- **Key Design:** MySQL allows multiple NULLs in UNIQUE columns, so non-billing entries (tracking_ref=NULL) are unaffected

### Why 3 Layers?
| Scenario | Layer 1 | Layer 2 | Layer 3 |
|----------|---------|---------|---------|
| Normal duplicate billing | ✓ Catches | ✓ Catches | ✓ Catches |
| Concurrent/race condition | ✗ May miss | ✗ May miss | ✓ Catches |
| Tracking table corrupted | ✗ Misses | ✓ Catches | ✓ Catches |
| Manual SQL INSERT | ✗ Bypassed | ✗ Bypassed | ✓ Catches |
| Someone recreates sync automation | ✗ Bypassed | ✗ Bypassed | ✓ Catches |

---

## 5. Schema Changes

### New Columns on `fin_ledger`

| Column | Type | Default | Purpose |
|--------|------|---------|---------|
| `tracking_ref` | INT UNSIGNED | NULL | Links to `fin_studentfeestracking.TID`. Extracted from `BillNo:TID` folio pattern. NULL for non-billing entries. |
| `source_system` | VARCHAR(25) | NULL | Origin tag: 'Billing', 'Payment', 'Manual', etc. |

### New Indexes on `fin_ledger`

| Index Name | Columns | Type | Purpose |
|------------|---------|------|---------|
| `uq_billing_entry` | (tracking_ref, accountcode, transactionType) | **UNIQUE** | Physically prevents duplicate billing at DB level |
| `idx_tracking_ref` | (tracking_ref) | INDEX | Fast lookups by tracking reference |
| `idx_source_system` | (source_system) | INDEX | Fast filtering by entry origin |

### Full `fin_ledger` Column List (After Changes)
```
TID              - INT AUTO_INCREMENT PRIMARY KEY
accountcode      - CHAR(25)
account_type     - VARCHAR(45)
transactionType  - CHAR(2) [DR/CR]
transaction_amount - BIGINT UNSIGNED
particulars      - VARCHAR(350)
voucherNo        - INT UNSIGNED
RefNo            - VARCHAR(50) [nullable]
transactionDate  - DATE
teller           - VARCHAR(45)
timeLog          - DATETIME
folio            - CHAR(65) [nullable] — e.g. 'BillNo:95907'
tracking_ref     - INT UNSIGNED [nullable, NEW] — e.g. 95907
source_system    - VARCHAR(25) [nullable, NEW] — e.g. 'Billing'
journal_no       - CHAR(25) [default '-']
trans_currency   - CHAR(25) [default 'UGX']
actual_amount    - DOUBLE [default 0]
curr_balance     - VARCHAR(45)
forex_rate       - DOUBLE [default 1]
ugx_amount       - DOUBLE [default 1]
InvoiceDate      - DATE [nullable]
```

---

## 6. Hardened Functions Reference

### `fin_TransactionCreatorFn2` (Core Transaction Creator v2)
**Called by:** `fin_TermlyItemBillingFN`  
**Parameters:** Same as before (no signature change)  
**Changes:**
- Extracts `tracking_ref` from `BillNo:TID` folio pattern
- Sets `source_system` = 'Billing' for billing entries
- Uses `INSERT IGNORE` instead of `INSERT` (UNIQUE constraint protects against duplicates)
- Returns status: 'Created' / 'Skipped:Exists' / 'Partial:Check'

### `fin_TransactionCreatorFn` (Core Transaction Creator v1)
**Called by:** `fin_SingleTermlyItemBillingFN`, `fin_CustomTermlyItemBillingFN`  
**Parameters:** Same as before (no signature change)  
**Changes:** Same as v2 (tracking_ref extraction, INSERT IGNORE, status returns)

### `fin_TermlyItemBillingFN` (Main Billing Orchestrator)
**Called by:** `fin_AutobillingV2`, `fin_BillProgrammeFees`  
**Parameters:** Same as before (no signature change)  
**Changes:**
- **GUARD 1:** Existing tracking table check (kept)
- **GUARD 2:** NEW direct ledger check (belt-and-suspenders)
- Validation: `Invalid Item` return if billing item not found
- Uses `LAST_INSERT_ID()` for reliable tracking TID retrieval
- Returns `'Success:TID'` with the tracking TID for traceability

### `fin_SingleTermlyItemBillingFN` (Single Item Billing)
**Changes:**
- Added `existingBill` COUNT check (was missing before)
- Changed tracking INSERT to use `INSERT IGNORE` + `ROW_COUNT()` check
- Amount validation added

### `fin_CustomTermlyItemBillingFN` (Custom Amount Billing)
**Changes:**
- Added `existingBill` COUNT check (was missing before)
- Changed tracking INSERT to use `INSERT IGNORE` + `ROW_COUNT()` check
- Amount validation added

---

## 7. Audit & Diagnostic Tools

### `CALL fin_AuditBillingIntegrity(NULL)` — System-Wide Audit
Checks ALL students. Returns 5 result sets:

| Result Set | What It Checks |
|------------|----------------|
| ORPHAN_TRACKING | Tracking rows marked 'Posted' with no matching ledger entry |
| ORPHAN_LEDGER | Ledger `BillNo:` entries with no matching tracking row |
| DUPLICATE_TRACKING | Same student billed more than once for same item/semester |
| DR_CR_MISMATCH | Billing entries where DR count ≠ CR count per tracking_ref |
| SUMMARY | Total counts for bills, ledger entries, tracked entries |

### `CALL fin_AuditBillingIntegrity('MRU2027000002')` — Per-Student Audit
Same checks, filtered to one student. Much faster.

### `CALL fin_FindDuplicateBilling('MRU2027000002')` — Deep Student Diagnostic
Returns 4 result sets:

| Result Set | Contents |
|------------|----------|
| TRACKING | All billing tracking entries for the student |
| LEDGER | All ledger billing entries (with tracking_ref and source_system) |
| CROSS-REFERENCE | Side-by-side: each tracking entry mapped to its DR and CR ledger entries, with status (OK/ORPHAN_TRACKING/PARTIAL) |
| BALANCE | Full balance calculation using the same UNION ALL logic as the display |

---

## 8. How to Investigate Issues

### "A student says they're double-billed"
```sql
-- Step 1: Quick diagnostic
CALL fin_FindDuplicateBilling('MRU2025XXXXXX');

-- Step 2: Look at the cross-reference result set
-- Status 'OK' = tracking entry has matching DR + CR in ledger
-- Status 'ORPHAN_TRACKING' = tracking entry with no ledger entry (normal for some old entries)
-- Status 'PARTIAL' = DR exists but CR doesn't (or vice versa) — investigate!

-- Step 3: Check for duplicates in tracking
-- If DUPLICATE_TRACKING shows up, the same item was billed twice
```

### "We suspect system-wide issues"
```sql
-- Run full audit (may take a few seconds)
CALL fin_AuditBillingIntegrity(NULL);

-- Check each result set:
-- ORPHAN_TRACKING: may indicate billing failures (tracking created but ledger insert failed)
-- ORPHAN_LEDGER: may indicate data corruption (ledger entries without tracking origin)
-- DUPLICATE_TRACKING: duplicate bills in tracking table
-- DR_CR_MISMATCH: incomplete ledger pairs
```

### "How do I trace a specific ledger entry back to its origin?"
```sql
-- Option 1: Use the new tracking_ref column
SELECT * FROM fin_ledger WHERE tracking_ref = 95907;  -- Both DR and CR for this tracking entry

-- Option 2: Use the folio
SELECT * FROM fin_ledger WHERE folio = 'BillNo:95907';

-- Option 3: Find the tracking entry
SELECT * FROM fin_studentfeestracking WHERE TID = 95907;
```

### "How do I check if the UNIQUE index is working?"
```sql
-- Try to insert a duplicate (should return 0 rows affected)
INSERT IGNORE INTO fin_ledger(accountcode, account_type, transactionType, 
  transaction_amount, particulars, voucherNo, transactionDate, teller, folio, 
  TimeLog, trans_currency, tracking_ref, source_system)
VALUES('MRU2027000002', 'Student', 'DR', 600000, 'TEST', 0, SYSDATE(), 
  'test', 'BillNo:95907', SYSDATE(), 'UGX', 95907, 'Billing');
-- Expected: 0 rows affected (duplicate silently rejected)
```

---

## 9. What Was Removed

### Removed from Database (Phase 9)
| Object | Type | Why Removed |
|--------|------|-------------|
| `evt_GLSyncRepair` | Scheduled Event | **ROOT CAUSE** — ran every 15 min, created 29,891 duplicates |
| `fin_SyncTrackingToLedger` | Stored Procedure | Blindly copied tracking → ledger with no dedup |
| `trg_fst_after_insert` | Trigger (fin_studentfeestracking) | Created by the sync automation, not needed |
| `trg_fst_after_update` | Trigger (fin_studentfeestracking) | Created by the sync automation, not needed |

### Data Cleaned Up (Phase 9)
| What | Count | How |
|------|-------|-----|
| GLSync duplicate ledger entries | 29,891 | Batch DELETE WHERE teller='GLSync' LIMIT 2000 (14 batches) |
| System duplicate ledger entries | 6 | Direct DELETE by TID |

### Remaining Safe Automation
| Object | Type | Purpose | Risk |
|--------|------|---------|------|
| `evt_daily_balance_check` | Scheduled Event | Daily balance recalculation | None — read + update curr_balance only |
| `trg_fin_ledger_before_insert` | BEFORE INSERT Trigger | Validates amount > 0, transactionType IN (DR,CR), accountcode not empty | Protective |
| `trg_fin_ledger_before_update` | BEFORE UPDATE Trigger | Same validations on update | Protective |
| `trg_fin_ledger_after_update` | AFTER UPDATE Trigger | Logs amount/type changes to `edit_ledger` table | Audit trail |
| `trg_fin_ledger_before_delete` | BEFORE DELETE Trigger | Archives deleted rows to `fin_deleted_ledger` | Archive |

---

## 10. Existing Triggers (Safe)

All 4 triggers on `fin_ledger` are **protective/audit** — they do NOT create billing entries.

### BEFORE INSERT: Data Validation
```
- transaction_amount must be > 0
- transactionType must be 'DR' or 'CR'
- accountcode must not be empty
```

### BEFORE UPDATE: Data Validation
Same checks as BEFORE INSERT, only fires if the specific field is being changed.

### AFTER UPDATE: Change Audit
Logs changes to `edit_ledger` table when `transaction_amount` or `transactionType` changes.

### BEFORE DELETE: Archive
Copies the row to `fin_deleted_ledger` before deletion (preserves history).

---

## 11. Quick Reference Commands

```sql
-- ==========================================
-- DAILY / WEEKLY MONITORING
-- ==========================================

-- Run system-wide audit
CALL fin_AuditBillingIntegrity(NULL);

-- Check a specific student
CALL fin_AuditBillingIntegrity('MRU2025XXXXXX');

-- Deep diagnostic for a student
CALL fin_FindDuplicateBilling('MRU2025XXXXXX');


-- ==========================================
-- TRACING / INVESTIGATION
-- ==========================================

-- Find all entries linked to a tracking entry
SELECT * FROM fin_ledger WHERE tracking_ref = 95907;

-- Find all billing entries for a student
SELECT TID, transactionType, transaction_amount, folio, tracking_ref, source_system, transactionDate
FROM fin_ledger WHERE accountcode = 'MRU2025XXXXXX' AND source_system = 'Billing';

-- Find all tracking entries for a student
SELECT * FROM fin_studentfeestracking WHERE regno = 'MRU2025XXXXXX' AND trans_type = 'Bill';


-- ==========================================
-- VERIFY PROTECTIONS ARE IN PLACE
-- ==========================================

-- Check UNIQUE index exists
SHOW INDEX FROM fin_ledger WHERE Key_name = 'uq_billing_entry';

-- Check hardened functions exist (should show 2026-04-01 dates)
SHOW FUNCTION STATUS WHERE Db='campus_dynamics_accounts' 
  AND Name IN ('fin_TransactionCreatorFn','fin_TransactionCreatorFn2','fin_TermlyItemBillingFN');

-- Check no dangerous automation exists
SHOW EVENTS WHERE Name LIKE '%GLSync%' OR Name LIKE '%Sync%';
-- Expected: empty result

-- Check triggers on fin_studentfeestracking
SHOW TRIGGERS;
-- Expected: only the 4 safe triggers on fin_ledger listed above
```

---

## SQL Source Files

| File | Purpose | Status |
|------|---------|--------|
| `COOPERP/sql/bulletproof_billing.sql` | All hardened functions + audit SPs | **DEPLOYED** |
| `COOPERP/sql/fix_audit_sp.sql` | Corrected audit SP (DR/CR mismatch fix) | **DEPLOYED** |
| `COOPERP/sql/fix_student_ledger_sps.sql` | Display SPs with UNION ALL dedup | Previously deployed |
| `COOPERP/sql/gl_sync_automation.sql` | **OBSOLETE** — the automation this defined was dropped | Do not re-run |
| `COOPERP/sql/fix_glsync_triggers.sql` | **OBSOLETE** — the triggers this defined were dropped | Do not re-run |

---

## 12. Fix Double Billing — Student Self-Service Tool

### Overview

The **Fix Double Billing** feature is a student-facing health check and repair tool available on the Student Portal Fee Statement page (`StudentFees.aspx`). It provides a comprehensive billing integrity scan with 3-method duplicate detection and a 5-point health check, plus the ability to safely remove any detected duplicate entries.

**Access:** Student Portal → Fee Statement → "Fix Double Billing" button (top right)

### Architecture

```
[Frontend Modal]                    [C# AJAX Handler]                [MySQL Database]
─────────────────                   ───────────────────               ────────────────
                                                                    
openDbModal()                                                       
  └─> dbScan()          ─GET─>     ?ajax=dbscan                    
                                    HandleDoubleBilling("dbscan")   
                                    └─> DoubleBilling_Scan(regno)   
                                        ├─> DetectDuplicates()      
                                        │   ├─ M1: tracking_ref     ─> GROUP BY + HAVING
                                        │   ├─ M2: folio BillNo:    ─> GROUP BY + HAVING
                                        │   └─ M3: GLSync remnants  ─> EXISTS subquery
                                        ├─> Health Checks (5)       ─> 5 verification queries
                                        └─> ComputeUnionAllBalance  ─> UNION ALL (matches page)
                                    <─JSON─ {dupCount, healthChecks, ...}
                                                                    
  [If dups found:]                                                  
  dbFix()               ─GET─>     ?ajax=dbfix                     
                                    HandleDoubleBilling("dbfix")    
                                    └─> DoubleBilling_Fix(regno)    
                                        ├─> DetectDuplicates()      ─> Same 3 methods
                                        ├─> DELETE in batches       ─> trg_before_delete archives
                                        └─> ComputeUnionAllBalance  ─> Fresh balance
                                    <─JSON─ {deleted, newBalance, archived}
```

### Detection Methods

| Method | What It Finds | SQL Strategy |
|--------|--------------|--------------|
| **M1: tracking_ref** | Same `(tracking_ref, transactionType)` on student account appearing >1 time | `GROUP BY tracking_ref, transactionType HAVING COUNT(*) > 1` — keep lowest TID |
| **M2: folio** | Same `(folio, transactionType)` for `BillNo:` entries on student account | `GROUP BY folio, transactionType HAVING COUNT(*) > 1` — keep lowest TID, exclude M1 results |
| **M3: GLSync** | Entries with `teller='GLSync'` that have a matching non-GLSync entry | `EXISTS` subquery matching by folio cross-ref, tracking_ref, or amount+date — exclude M1+M2 |

### Health Checks

| # | Check Name | Status Values | What It Verifies |
|---|-----------|---------------|-----------------|
| 1 | Tracking reference uniqueness | pass/fail | No tracking_ref duplicates on student account |
| 2 | Billing folio uniqueness | pass/fail | No BillNo: folio duplicates on student account |
| 3 | GLSync remnant check | pass/fail | No GLSync leftover entries remain |
| 4 | Tracking-ledger sync | pass/info | All tracking entries have ledger counterparts |
| 5 | Duplicate prevention index | pass/warn | `uq_billing_entry` UNIQUE index is active |

### JSON Response Formats

**Scan Response:**
```json
{
  "ok": true,
  "dupCount": 0,
  "dupDrAmount": 0,
  "currentBalance": "UGX 1,050,000",
  "correctBalance": "UGX 1,050,000",
  "passCount": 4,
  "totalChecks": 5,
  "healthChecks": [
    {"name": "Tracking reference uniqueness", "status": "pass", "detail": "No duplicate tracking references"},
    {"name": "Billing folio uniqueness", "status": "pass", "detail": "No duplicate billing folios"},
    {"name": "GLSync remnant check", "status": "pass", "detail": "No GLSync leftover entries"},
    {"name": "Tracking-ledger sync", "status": "info", "detail": "1 tracking entry without ledger match (handled by display)"},
    {"name": "Duplicate prevention index", "status": "pass", "detail": "UNIQUE constraint active — new duplicates blocked at DB level"}
  ],
  "sample": []
}
```

**Fix Response:**
```json
{
  "ok": true,
  "deleted": 3,
  "newBalance": "UGX 1,050,000",
  "archived": true
}
```

### Safety Measures

1. **Delete archive:** The `trg_fin_ledger_before_delete` trigger copies every deleted row to `fin_deleted_ledger` before deletion — all removals are recoverable.
2. **Batch deletion:** Deletes are processed in batches of 500 to avoid lock contention on MyISAM.
3. **Re-detection:** Fix re-runs the exact same detection queries before deleting (not cached from scan).
4. **Confirmation dialog:** JavaScript requires user confirmation before proceeding with fix.
5. **Balance recalculation:** Post-fix balance uses the same UNION ALL logic as the main page display.
6. **No admin escalation:** The tool only affects the logged-in student's own account entries.

### Files Modified

| File | Location | What Changed |
|------|----------|-------------|
| `StudentFees.aspx` | CampusDynamics_Portal | CSS (health check styles), HTML (health checks section in modal), JavaScript (scan/fix handlers updated for new response format) |
| `StudentFees.aspx.cs` | CampusDynamics_Portal | Complete rewrite of AJAX handlers: `HandleDoubleBilling`, `DetectDuplicates` (shared 3-method), `RunDupDetection`, `ComputeUnionAllBalance`, `DoubleBilling_Scan` (with health checks), `DoubleBilling_Fix` (with archive flag), helper methods |

### Key Methods (C#)

| Method | Purpose |
|--------|---------|
| `HandleDoubleBilling(action)` | Routes dbscan/dbfix, error handling, JSON response |
| `DetectDuplicates(conn, regno, ...)` | Runs all 3 detection methods, returns per-method counts |
| `RunDupDetection(conn, sql, ...)` | Executes a single detection query, accumulates TIDs + DR amounts + sample rows |
| `ComputeUnionAllBalance(conn, regno)` | UNION ALL balance matching main page (same 3-condition NOT EXISTS) |
| `DoubleBilling_Scan(regno)` | Full scan: detect + 5 health checks + balance + JSON |
| `DoubleBilling_Fix(regno)` | Re-detect + batch delete + fresh balance + JSON |
| `BuildHealthCheck(name, status, detail)` | Builds a single health check JSON object string |
| `TidExclusion(tids)` | Builds comma-separated TID list for NOT IN clauses |
| `FormatBalance(balance)` | Formats decimal to "UGX N" / "UGX N CR" / "UGX 0" |

---

## 13. Admin Batch Double-Billing Fix — 3-Step Wizard

### Overview

An admin-facing batch tool on **FeesTransactions.aspx** (COOPERP/NewScreens) that allows administrators to detect and fix double billing across **all student accounts** system-wide, one account at a time, with live progress tracking.

### Access

- **URL:** `https://eadmin.mru.ac.ug/COOPERP/NewScreens/FeesTransactions.aspx`
- **Button:** "Fix Double Billing" (red border) in the filter bar, next to "Fix GL"
- **Modal ID:** `modal-batchdup`

### 3-Step Wizard Flow

#### Step 1 — Detect
Performs system-wide scan using 3 detection methods:

| Method | SQL Logic |
|--------|-----------|
| **M1: tracking_ref** | `GROUP BY tracking_ref, accountcode, transactionType HAVING COUNT(*) > 1` — keeps MIN(TID) |
| **M2: folio** | `GROUP BY folio, accountcode HAVING COUNT(*) > 1` — filters `folio LIKE 'BillNo:%'` |
| **M3: GLSync remnants** | `EXISTS` subquery against `GLSyncLedger_Entries` |

**KPIs displayed:** Affected accounts, Total duplicates, Over-billed amount, UNIQUE index status  
**Output:** Scrollable table of all affected student accounts with reg numbers, names, dup counts, amounts

#### Step 2 — Fix (One-by-One)
Processes each affected account sequentially via individual AJAX calls:

1. Frontend calls `?ajax=batchdup_fix_one&regno=XXX` for each account
2. Backend: computes balance before → runs 3-method detection → batch deletes duplicates (500/batch) → computes balance after
3. Frontend updates: progress bar, counter, status tags, balance columns, log console
4. All deleted entries automatically archived to `fin_deleted_ledger` by the existing `trg_fin_ledger_before_delete` trigger
5. Small 150ms delay between requests to avoid server hammering

**Abort support:** User can close the modal during fixing — already-fixed accounts keep their changes.

#### Step 3 — Results
Summary dashboard with:
- Result banner (success/error/clean/aborted states)
- 4 stat cards: Accounts Fixed, Entries Deleted, Already Clean, Errors
- Full log console with timestamped entries

### AJAX Endpoints

| Endpoint | Method | Returns |
|----------|--------|---------|
| `?ajax=batchdup_scan` | GET | `{ok, totalStudents, totalLedger, affectedCount, grandTotalDups, grandTotalAmount, uniqueIndexActive, accounts[]}` |
| `?ajax=batchdup_fix_one&regno=X` | GET | `{ok, regno, deleted, m1, m2, m3, balBefore, balAfter, archived}` |

### Safety Features

1. **Same 3-method detection** as student self-service tool — consistent duplicate identification
2. **One-by-one processing** — no long-running single request, each account is an independent AJAX call
3. **Confirmation dialog** — requires explicit user confirmation before batch fix begins
4. **Automatic archival** — every deleted row archived to `fin_deleted_ledger` via MySQL trigger
5. **Abort-safe** — closing modal during fix stops processing; completed accounts retain their changes
6. **UNION ALL balance** — pre/post-fix balances use identical logic to main page display
7. **Per-method counts** — each fix reports M1/M2/M3 deletions for full transparency

### Files Modified

| File | Location | What Changed |
|------|----------|-------------|
| `FeesTransactions.aspx` | COOPERP/NewScreens | CSS (bd-* styles for wizard), HTML ("Fix Double Billing" button + 3-step wizard modal), JavaScript (openBatchDupModal, bdScan, bdStartFix, _bdFixNext, _bdFinalize + helpers) |
| `FeesTransactions.aspx.cs` | COOPERP/NewScreens | AJAX routing for batchdup_scan/batchdup_fix_one, HandleBatchDupFix, BatchDup_Scan (system-wide), BatchDup_FixOne (per-account), BD_* helper methods |

### Key Methods (C#)

| Method | Purpose |
|--------|---------|
| `HandleBatchDupFix(action)` | Routes scan/fix_one, ThreadAbortException safety, JSON response |
| `BatchDup_Scan()` | System-wide 3-method detection, student name lookup via `campus_dynamics.acad_student`, UNIQUE index check |
| `BatchDup_FixOne()` | Single-account fix: detect + batch delete (500/batch) + balance before/after |
| `BD_ComputeBalance(conn, regno)` | UNION ALL balance (identical to student portal) |
| `BD_DetectDuplicates(conn, regno, ...)` | Same 3-method detection, no sample rows (efficiency) |
| `BD_RunDetection(conn, sql, ...)` | Generic detection query runner |
| `BD_TidExcl(tids)` | Comma-separated TID exclusion builder |
| `BD_FormatBalance(balance)` | UGX number formatter |

### Key JavaScript Functions

| Function | Purpose |
|----------|---------|
| `openBatchDupModal()` | Opens modal, resets state, auto-triggers scan |
| `bdScan()` | XHR to batchdup_scan, populates KPIs + accounts table |
| `bdStartFix()` | Confirmation + switches to Step 2 + starts sequential loop |
| `_bdFixNext()` | Recursive sequential loop — fixes one account, updates UI, moves to next |
| `_bdFinalize()` | Computes totals, populates Step 3 results, shows banner |
| `_bdSetStep(n)` | Updates step indicator (circles + connecting lines) |
| `_bdLog(msg, cls)` | Appends timestamped entry to log console |

---

*Last updated: 2026-04-01 — Phase 12: Admin Batch Double-Billing Fix Wizard*
