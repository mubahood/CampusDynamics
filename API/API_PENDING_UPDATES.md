# Campus Dynamics API v2 — Pending Updates & Recommendations
**Generated:** 2026-05-16  
**Last Updated:** 2026-05-16 — ALL 30 ITEMS IMPLEMENTED ✅  
**Scope:** All updates required to keep the API in sync with main-system improvements, plus robustness recommendations. Core endpoint structure (URLs, auth scheme, response envelope) is **not changed**.

---

## Part 1 — How the API Works Today (Quick Reference)

| File | Purpose |
|------|---------|
| `v2/auth.aspx.cs` | Login, logout, validate, ping. HMACSHA256 password hash. Multi-path username resolution (regno, entryno, email for students; username, email for staff). |
| `v2/finance.aspx.cs` | Ledger, balance, fees_structure, payment_history, billing_summary, fee_status, bulk_fee_check, access_status. |
| `v2/academic.aspx.cs` | Results, transcript, gpa, available_courses, registered_courses, register_course, drop_course, semester_registration, registration_history, enrollment_status, course_details, course_enrollments, programme_curriculum, grading_scheme. |
| `v2/staff.aspx.cs` | Profile, photo, my_courses, class_list, marks, submit_marks, teaching_assignments, mark_sheet, save_entry_marks, submit_for_approval, sheet_status, deadlines, lookup, by_department. |
| `v2/student.aspx.cs` | Profile, photo, lock_status, summary, lookup, verify, search, by_programme. |
| `v2/campus.aspx.cs` | Notices, directory, academic_years, current_semester, programmes, campuses, faculties, departments, academic_calendar. |
| `v2/timetable.aspx.cs` | Lectures, exams. |

**Response envelope (all endpoints):**
```json
{ "success": true, "message": "...", "data": { ... }, "timestamp": "ISO-8601 UTC" }
{ "success": false, "message": "...", "error_code": "UPPER_SNAKE", "data": null }
```

---

## Part 2 — What Changed in the Main System

### 2A — Finance / Billing Architecture

The main system was refactored from a **single-table** billing model to a **dual-write General Ledger** model. This is the most impactful change.

| Before | After |
|--------|-------|
| `fin_studentfeestracking` only | Dual-write: `fin_studentfeestracking` (audit trail) **+** `fin_ledger` (GL) |
| No transaction status | `post_status` column: `Pending` or `Posted` |
| No GL structure | Full double-entry: `fin_ledger` with `transactionType` (DR/CR), `accountcode`, `transaction_amount`, `transactionDate` |
| Balance = SUM from tracking | Balance = UNION ALL from both tables, deduplicating cross-table overlap |

**New tables:**
- `fin_ledger` — General ledger with DR/CR entries; this is now the canonical balance source
- `fin_programme_fees` — Per-programme tuition/functional fee amounts (replaces `fin_fees_structure` for most programmes)
- `fin_bill_waivers` — Waiver records (full, partial, reversal, balance-fix types)
- `fin_bill_waiver_items` — Line items for each waiver
- `fin_bill_uniqueness` — Uniqueness constraint helper: UNIQUE on `(regno, acadyear, semester, item_code)`
- `fin_changed_deleted_transactions` — Audit log for edits/deletes
- `fin_double_billing_cases` — Persistent record of detected duplicate bills

**New stored procedures:**
- `fin_AutoBillingV2` / updated `fin_Autobilling` — Checks `fin_programme_fees` first, falls back to `fin_fees_structure`
- `fin_BillProgrammeFees` — Bills tuition (ItemCode=1) and functional (ItemCode=52) from programme fees table
- `fin_TermlyItemBillingFN` — Uses atomic `INSERT WHERE NOT EXISTS` to prevent duplicate billing
- `fin_GetProgrammeFee` — Returns tuition + functional fees for a programme/year/semester

**Duplicate protection (DB-level):**
- `trg_prevent_duplicate_bill` — BEFORE INSERT trigger prevents double billing at DB level
- `trg_sync_bill_uniqueness_delete` — AFTER DELETE keeps `fin_bill_uniqueness` in sync

### 2B — Registration

| Change | Detail |
|--------|--------|
| New registration statuses | UNREGISTERED, REGISTERED, LATE REGISTERED, CLEARED, DISCONTINUED, HALTED, DEAD YEAR |
| Semester active flag | `acad_acadyears` now has `semester_1_is_active`, `semester_2_is_active`, `semester_3_is_active` (Yes/No). Registration blocked in inactive semesters. |
| Per-student billing system | `acad_student.billingID` — selects which billing system to apply at registration |
| Accommodation billing | RESIDENT students automatically billed accommodation fees during registration |
| Auto-billing SP | Now calls updated `fin_Autobilling` which checks `fin_programme_fees` first |

### 2C — Courses

| Change | Detail |
|--------|--------|
| Course status on programme | `acad_programmecourses.status` column: `Active`/`Inactive` |
| Lecturer assignment on programme | `acad_programmecourses.is_lecturere_assigned` (Yes/No) and `lecturer_id` (FK to `hrm_employee.empID`) |

### 2D — Marks Workflow

- `MarksSheetSyncService` and `MarksWorkflowService` classes were **removed** as part of a refactor. The API endpoints `mark_sheet`, `save_entry_marks`, `submit_for_approval`, `sheet_status`, `deadlines` need verification that they do not depend on those removed services.

---

## Part 3 — Required API Updates (Bugs / Mismatches)

These are **correctness issues** — the API will return wrong data or fail without these fixes.

---

### FIX-01 — Balance calculation must use UNION ALL (dual-source)
**File:** `v2/finance.aspx.cs` — `HandleLedger`, `HandleBalance`, `HandleBillingSummary`  
**Severity:** CRITICAL

**Problem:** All three handlers call `MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter`, which queries `fin_studentfeestracking` only. The main system now writes bills and payments to both `fin_ledger` (GL) and `fin_studentfeestracking`. The adapter misses `fin_ledger`-only entries (e.g. manual journal adjustments, GL-sync entries, waivers posted directly to GL).

**Required fix:** Replace the adapter call with a UNION ALL query that:
1. Pulls DR/CR entries from `fin_ledger` where `accountcode = @regno`
2. Pulls from `fin_studentfeestracking` where `post_status = 'Posted'` AND no matching row exists in `fin_ledger` for the same transaction (to avoid double-counting)
3. Excludes `Pending` status entries from balance

Reference pattern (from `StudentLedgers.aspx.cs` and `access_status` handler):
```sql
SELECT ... FROM (
  SELECT transactionDate, transactionType, transaction_amount, narration, ...
  FROM fin_ledger WHERE accountcode = @regno AND transaction_amount > 0
  UNION ALL
  SELECT trans_date, trans_type, amount, detail, ...
  FROM fin_studentfeestracking t WHERE t.regno = @regno AND t.post_status = 'Posted'
  AND NOT EXISTS (
    SELECT 1 FROM fin_ledger fl WHERE fl.accountcode = t.regno
    AND ABS(fl.transaction_amount - t.amount) < 0.01
    AND fl.transactionDate = t.trans_date
    AND fl.transactionType = IF(t.trans_type='Bill','DR','CR')
  )
) combined ORDER BY transactionDate
```

---

### FIX-02 — `fees_structure` must check `fin_programme_fees` first
**File:** `v2/finance.aspx.cs` — `HandleFeesStructure`  
**Severity:** HIGH

**Problem:** The handler queries `fin_fees_structure` only. The main system now uses `fin_programme_fees` as the primary source for tuition and functional fees, with fallback to `fin_fees_structure`. Students on programmes covered by `fin_programme_fees` will see incorrect/empty fee structures from the API.

**Required fix:**
1. Check if the student's programme has an entry in `fin_programme_fees` for the given study year and semester
2. If yes: return fees from `fin_programme_fees` (ItemCode 1 = tuition, ItemCode 52 = functional) plus other items from `fin_fees_structure` (non-tuition)
3. If no: fall back to full `fin_fees_structure` query (current behaviour)

Call or mirror the logic in stored procedure `fin_GetProgrammeFee`.

---

### FIX-03 — `semester_registration` must check active-semester flag
**File:** `v2/academic.aspx.cs` — `HandleSemesterRegistration`  
**Severity:** HIGH

**Problem:** The main system blocks registration for semesters where `acad_acadyears.semester_X_is_active = 'No'`. The API bypasses this check.

**Required fix:** Before processing registration, query:
```sql
SELECT semester_1_is_active, semester_2_is_active, semester_3_is_active
FROM acad_acadyears WHERE acad_year = @year LIMIT 1
```
If the requested semester is `'No'`, return:
```json
{ "success": false, "message": "Registration for this semester is currently closed.", "error_code": "SEMESTER_CLOSED" }
```

Add `SEMESTER_CLOSED` to the standard error codes list in the documentation.

---

### FIX-04 — `available_courses` must filter by `status = 'Active'`
**File:** `v2/academic.aspx.cs` — `HandleAvailableCourses`  
**Severity:** MEDIUM

**Problem:** The new `acad_programmecourses.status` column marks courses as `Active` or `Inactive`. Inactive courses should not appear in the registration list, but the API does not filter on this column.

**Required fix:** Add `AND (pc.status IS NULL OR pc.status = 'Active')` to the available courses query (the `IS NULL` handles older rows that predate the column).

---

### FIX-05 — Ledger must exclude `Pending` transactions
**File:** `v2/finance.aspx.cs` — `HandleLedger`, `HandleBalance`  
**Severity:** MEDIUM

**Problem:** `fin_studentfeestracking` now has `post_status` with values `Pending` and `Posted`. Only `Posted` entries represent confirmed financial transactions. If the API includes `Pending` entries, the balance and ledger shown to students will be inflated with unconfirmed charges.

**Required fix:** Add `AND t.post_status = 'Posted'` to all queries against `fin_studentfeestracking`. (Already done correctly in `access_status` — apply the same filter everywhere else.)

---

### FIX-06 — `registration_history` and `enrollment_status` missing new statuses
**File:** `v2/academic.aspx.cs` — `HandleRegistrationHistory`, `HandleEnrollmentStatus`  
**Severity:** MEDIUM

**Problem:** Both handlers were written before the registration status expansion. They may not return or correctly label: `HALTED`, `DEAD YEAR`, `LATE REGISTERED`, `CLEARED`.

**Required fix:**
- Confirm the `regstatus` column values returned are passed through as-is (not filtered)
- Add human-readable label mapping in the response for all statuses:
  - `UNREGISTERED` → "Not Registered"
  - `REGISTERED` → "Registered"
  - `LATE REGISTERED` → "Late Registered"
  - `CLEARED` → "Exam Cleared"
  - `DISCONTINUED` → "Discontinued"
  - `HALTED` → "Halted"
  - `DEAD YEAR` → "Dead Year"
- `enrollment_status` response should include `status_label` field alongside the raw `status` value

---

### FIX-07 — `fm_student_ledger` vs `fin_ledger` table name mismatch
**File:** `v2/finance.aspx.cs` — `HandleFeeStatus`  
**Severity:** MEDIUM

**Problem:** `HandleFeeStatus` queries a table called `fm_student_ledger`. All other references in the main system use `fin_ledger`. If `fm_student_ledger` is a view, verify it is still up to date with the dual-write schema. If it is a legacy table name, replace with `fin_ledger`.

**Required fix:**
1. Check whether `fm_student_ledger` exists and whether it is a view or table
2. If view: ensure it unions both `fin_ledger` and non-duplicated `fin_studentfeestracking` entries
3. If table: migrate queries to use `fin_ledger` directly with the UNION ALL pattern

---

### FIX-08 — `semester_registration` billing SP needs update
**File:** `v2/academic.aspx.cs` — `HandleSemesterRegistration`  
**Severity:** MEDIUM

**Problem:** The auto-billing triggered on semester registration may still call the old `fin_Autobilling` SP. The SP has been updated to check `fin_programme_fees` first, so this may self-resolve — but the API should explicitly call `fin_AutoBillingV2` (or confirm the updated `fin_Autobilling` is what gets called). Also, the API does not pass `billingID` (the per-student billing system selector from `acad_student.billingID`) to the SP.

**Required fix:**
1. Confirm which SP is called on `semester_registration`
2. Ensure `billingID` is fetched from `acad_student` and passed to the billing SP
3. Ensure accommodation billing for RESIDENT students is triggered (check `acad_student.studResidence`)

---

### FIX-09 — `access_status` UNION ALL should filter Pending
**File:** `v2/finance.aspx.cs` — `HandleAccessStatus`  
**Severity:** LOW

**Problem:** The `access_status` balance query already uses UNION ALL correctly but the `fin_studentfeestracking` side may not filter by `post_status = 'Posted'`, which could include unconfirmed pending bills in the access policy evaluation.

**Required fix:** Verify and add `AND t.post_status = 'Posted'` to the `fin_studentfeestracking` subquery inside `HandleAccessStatus`.

---

### FIX-10 — Mark sheet endpoints need verification post-service-removal
**File:** `v2/staff.aspx.cs` — `HandleMarkSheet`, `HandleSubmitForApproval`, `HandleSheetStatus`, `HandleDeadlines`  
**Severity:** MEDIUM

**Problem:** `MarksSheetSyncService` and `MarksWorkflowService` were removed from the codebase. If any of these four API handlers call or instantiate those services, they will throw a compile-time or runtime error.

**Required fix:**
1. Grep all four handlers for references to `MarksSheetSyncService`, `MarksWorkflowService`
2. If found, replace with direct SQL equivalents or the new approach used in the main system
3. Test each marks endpoint end-to-end in a staging environment

---

### FIX-11 — `course_details` should expose lecturer assignment
**File:** `v2/academic.aspx.cs` — `HandleCourseDetails`  
**Severity:** LOW

**Problem:** The new `acad_programmecourses.lecturer_id` and `is_lecturere_assigned` columns are not included in the `course_details` response. Moodle/ODEL integrations that use this endpoint to set up course materials won't know who the assigned lecturer is.

**Required fix:** Join `acad_programmecourses` with `hrm_employee` and include in the response:
```json
"lecturer": {
  "assigned": true,
  "staff_id": "ST001",
  "name": "Dr. John Doe"
}
```

---

## Part 4 — New Endpoints Recommended

These do not exist in the API but would fill real gaps exposed by the main system improvements.

---

### NEW-01 — `finance.aspx?action=waivers`
**Priority:** HIGH

Students currently have no way to see their waivers via the API. The waiver system (`fin_bill_waivers`, `fin_bill_waiver_items`) is fully operational in the main system.

**Proposed response:**
```json
{
  "waivers": [
    {
      "waiver_id": 12,
      "category": "Bursary Waiver",
      "status": "Active",
      "total_amount": 450000,
      "created_at": "2025-09-10T08:30:00Z",
      "items": [
        { "item_code": 1, "item_name": "Tuition", "amount": 400000 },
        { "item_code": 52, "item_name": "Functional Fees", "amount": 50000 }
      ]
    }
  ],
  "total_waived": 450000
}
```

---

### NEW-02 — `academic.aspx?action=semester_status`
**Priority:** HIGH

Mobile apps and portals need to know which semesters are open for registration before showing registration UI. Currently there is no API for this.

**Proposed:** GET, no auth required (or token optional)

**Proposed response:**
```json
{
  "acad_year": "2025/2026",
  "semesters": [
    { "semester": 1, "is_active": true },
    { "semester": 2, "is_active": false },
    { "semester": 3, "is_active": false }
  ]
}
```

---

### NEW-03 — `finance.aspx?action=billing_breakdown`
**Priority:** MEDIUM

Extends `billing_summary` to include waivers, and distinguishes Posted vs Pending transactions per semester. Students and admin integrations need this level of detail.

**Proposed response per semester entry:**
```json
{
  "acad_year": "2025/2026",
  "semester": 1,
  "total_billed": 1800000,
  "total_paid": 1200000,
  "total_waived": 200000,
  "pending_charges": 50000,
  "net_balance": 350000,
  "line_items": [...]
}
```

---

### NEW-04 — `auth.aspx?action=refresh`
**Priority:** MEDIUM

Tokens expire but there is no way to extend a session without full re-login (which requires resending credentials). Add a `refresh` action that exchanges a still-valid token for a new one with a fresh expiry.

**Proposed:** POST with `token` parameter. Returns a new token if the existing token is valid and not expired. Old token is invalidated.

---

### NEW-05 — `academic.aspx?action=retake_courses`
**Priority:** MEDIUM

Students who have failed courses need to see which ones are eligible for retake registration. There is no dedicated endpoint for this.

**Proposed:** GET with token. Queries results for failed/incomplete grades and cross-references with `acad_programmecourses` to return retakeable courses for the current semester.

---

### NEW-06 — `finance.aspx?action=accommodation_status`
**Priority:** LOW

For RESIDENT students, accommodation billing is now automatic on registration. An endpoint exposing accommodation status and the associated billing amount would be useful for the portal and mobile apps.

**Proposed response:**
```json
{
  "is_resident": true,
  "accommodation_type": "On-Campus",
  "billed_amount": 300000,
  "acad_year": "2025/2026",
  "semester": 1
}
```

---

### NEW-07 — `student.aspx?action=bulk_enrollment` (staff only)
**Priority:** LOW

`bulk_fee_check` exists for checking fees in bulk. A matching `bulk_enrollment_status` endpoint would let Moodle sync enrollment status for entire cohorts in one call instead of N individual calls.

**Proposed:** POST (staff only), body: `{ "students": ["REG001", "REG002", ...], "acad_year": "...", "semester": 1 }`. Returns array of `{ regno, status, is_registered, programme }`.

---

## Part 5 — Robustness & Quality Recommendations

These do not fix specific bugs but will make the API more reliable, secure, and maintainable.

---

### ROB-01 — Rate limiting
**Priority:** HIGH

No rate limiting exists on any endpoint. A client (or attacker) can hammer `login`, `ledger`, or `access_status` without limit.

**Recommendation:**
- Add per-IP rate limiting using `System.Web.Caching.Cache` as a sliding window counter
- Stricter limits on `auth.aspx` (e.g. 10 login attempts per minute per IP)
- Standard limit on data endpoints (e.g. 120 requests per minute per token)
- Return HTTP 429 with `error_code: RATE_LIMITED` and `Retry-After` header

---

### ROB-02 — Token security improvements
**Priority:** HIGH

Current tokens appear to be random hex strings stored in a DB table. Recommendations:
- Add a `last_used_at` column to the token table and update it on each request. Alert/invalidate tokens unused for 30+ days.
- Enforce a maximum concurrent token count per user (e.g. 5). On login when limit exceeded, revoke the oldest token.
- Log token creation, validation failures, and revocation with IP address for audit trail.

---

### ROB-03 — Pagination on `ledger` endpoint
**Priority:** MEDIUM

A student with many years of transactions can have hundreds of ledger entries. The `ledger` endpoint returns all entries at once with no pagination.

**Recommendation:** Add optional `page` (default 1) and `limit` (default 50, max 200) parameters. Include `total_count`, `page`, `total_pages` in the response. Running balance should still be computed on the full dataset but only the paged slice returned.

---

### ROB-04 — Input sanitisation on all string parameters
**Priority:** MEDIUM

`ApiHelper.Param` retrieves raw query string values. Verify that all string parameters passed into SQL queries go through parameterised queries (`MySqlCommand` with `@param`). Specifically audit:
- `directory` action: the `category` parameter
- `search` action: the `q` parameter
- `by_programme` action: the `progcode` parameter
- All `acad_year` parameters (string format, not integer)

---

### ROB-05 — Consistent error handling for DB connection failures
**Priority:** MEDIUM

If the MySQL server is unavailable, some handlers may return an unhandled exception stacktrace instead of a clean JSON error. The outer `try/catch` in `Page_Load` catches this but only after the Content-Type may not have been set, causing the response to be misinterpreted as HTML.

**Recommendation:** Set `Response.ContentType = "application/json"` as the very first line in `Page_Load`, before the CORS check, action switch, and try block. This ensures JSON content type is always present.

---

### ROB-06 — `register_course` duplicate prevention
**Priority:** MEDIUM

The main system now has a DB-level uniqueness trigger (`trg_prevent_duplicate_bill`) and a `fin_bill_uniqueness` helper table. The `register_course` and `semester_registration` API actions should catch the MySQL duplicate key exception specifically and return a clean `ALREADY_REGISTERED` error code rather than the raw MySQL error message.

---

### ROB-07 — `submit_marks` — validate score ranges before insert
**Priority:** MEDIUM

`submit_marks` accepts coursework and exam scores as free-form input. Before inserting, validate:
- Scores are numeric
- Coursework ≤ configured maximum coursework marks (from the mark sheet ratio)
- Exam ≤ configured maximum exam marks
- Neither is negative

Return field-level validation errors, not a generic server error.

---

### ROB-08 — Add `X-API-Version` response header
**Priority:** LOW

No versioning header is returned. Clients cannot detect which version of the API they are talking to without parsing the URL.

**Recommendation:** Add `Response.AppendHeader("X-API-Version", "2.0")` in `ApiHelper` so every response carries the version.

---

### ROB-09 — `ping` endpoint should include DB connectivity check
**Priority:** LOW

`auth.aspx?action=ping` currently returns a static health check. Enhance it to actually test DB connectivity (run a lightweight `SELECT 1`) and return `"db_status": "ok"` or `"db_status": "error"`. This makes it useful for uptime monitoring.

---

### ROB-10 — Standardise `acad_year` format validation
**Priority:** LOW

Academic year strings like `"2025/2026"` are accepted as-is. A client sending `"2025-2026"` or `"25/26"` will silently return empty data. Add a regex validation (`^\d{4}/\d{4}$`) on all `acad_year` parameters and return `INVALID_PARAM` with a descriptive message if the format does not match.

---

### ROB-11 — Document `error_code` values in docs
**Priority:** LOW

The docs page lists 8 standard error codes but individual handlers introduce additional codes (e.g., `ALREADY_REGISTERED`, `DEADLINE_PASSED`, `SHEET_LOCKED`) that are not documented. Maintain a full, machine-readable error code registry in `docs.aspx` so client developers can handle every case explicitly.

---

### ROB-12 — CORS origin whitelist
**Priority:** LOW

`ApiHelper.HandleCors` likely returns `Access-Control-Allow-Origin: *`. With token-based auth this is not catastrophic, but tightening to a whitelist (`eportal.mru.ac.ug`, `eadmin.mru.ac.ug`, Moodle domain) reduces the attack surface.

---

## Part 6 — Implementation Status

| # | ID | Description | Effort | Status |
|---|-----|-------------|--------|--------|
| 1 | FIX-01 | Dual-source UNION ALL balance calculation | High | ✅ DONE |
| 2 | FIX-02 | fees_structure checks fin_programme_fees first | Medium | ✅ DONE |
| 3 | FIX-03 | semester_registration checks active-semester flag | Low | ✅ DONE |
| 4 | FIX-05 | Exclude Pending transactions from ledger/balance | Low | ✅ DONE |
| 5 | FIX-07 | Resolve fm_student_ledger vs fin_ledger name | Low | ✅ DONE |
| 6 | FIX-10 | Verify mark sheet endpoints post-service-removal | Medium | ✅ DONE (grep — no references) |
| 7 | FIX-04 | available_courses status = 'Active' filter | Low | ✅ DONE |
| 8 | FIX-06 | registration_history/enrollment_status new statuses | Low | ✅ DONE |
| 9 | FIX-08 | semester_registration billing SP + billingID | Medium | ✅ DONE |
| 10 | FIX-09 | access_status Pending filter | Low | ✅ DONE (already correct) |
| 11 | ROB-01 | Rate limiting | High | ✅ DONE (all endpoints) |
| 12 | NEW-01 | finance waivers endpoint | Medium | ✅ DONE |
| 13 | NEW-02 | academic semester_status endpoint | Low | ✅ DONE |
| 14 | ROB-02 | Token security improvements | Medium | ✅ DONE (max 5 tokens, evict oldest) |
| 15 | ROB-03 | Ledger pagination | Medium | ✅ DONE |
| 16 | NEW-04 | auth refresh endpoint | Medium | ✅ DONE |
| 17 | FIX-11 | course_details lecturer assignment | Low | ✅ DONE |
| 18 | ROB-05 | Content-Type set before try block | Low | ✅ DONE |
| 19 | ROB-06 | register_course duplicate key clean error | Low | ✅ DONE (ALREADY_REGISTERED) |
| 20 | ROB-07 | submit_marks score range validation | Medium | ✅ DONE |
| 21 | NEW-03 | finance billing_breakdown endpoint | Medium | ✅ DONE |
| 22 | NEW-05 | academic retake_courses endpoint | Medium | ✅ DONE |
| 23 | ROB-04 | Input sanitisation audit | Medium | ✅ DONE (SanitiseParam in ApiHelper) |
| 24 | ROB-08 | X-API-Version response header | Low | ✅ DONE |
| 25 | ROB-09 | ping DB connectivity check | Low | ✅ DONE |
| 26 | ROB-10 | acad_year format validation | Low | ✅ DONE (ValidateAcadYear) |
| 27 | ROB-11 | Document all error_codes | Low | ✅ DONE (docs.aspx) |
| 28 | ROB-12 | CORS origin whitelist | Low | ✅ DONE (web.config + ApiHelper) |
| 29 | NEW-06 | finance accommodation_status endpoint | Low | ✅ DONE |
| 30 | NEW-07 | student bulk_enrollment endpoint | Low | ✅ DONE |

