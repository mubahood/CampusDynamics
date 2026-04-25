# Fee-Based University Access Criteria — Implementation Plan

> **Project:** Campus Dynamics MRU  
> **Module:** Finance → Student Access Gate  
> **Author:** Campus Dynamics AI Engineering  
> **Date:** 15 April 2026  
> **Status:** Complete

---

## 1. Executive Summary

This module allows the **Bursar to define configurable criteria** that determine whether a student is granted university access (registration, exam sitting, portal access, etc.). The criteria cascade from general (minimum balance thresholds) to specific (payment-window amounts, bursary/scholarship status). A single active **"Access Policy"** record stores all rules. Students who fail the criteria are shown clear, colour-coded alerts with actionable guidance; those who pass see a green confirmation. An API endpoint exposes the same evaluation for the mobile app and external consumers.

---

## 2. Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                        BURSAR (Admin)                                │
│  NewScreens/FeeAccessPolicy.aspx — Wizard UI                        │
│  ┌────────┐ ┌────────────┐ ┌───────────┐ ┌──────────┐ ┌──────────┐ │
│  │ Step 1 │ │  Step 2    │ │ Step 3    │ │ Step 4   │ │ Step 5   │ │
│  │ Title  │→│ Balance    │→│ Payment   │→│ Bursary  │→│ Review   │ │
│  │ & Term │ │ Criteria   │ │ Window    │ │ & Extras │ │ & Save   │ │
│  └────────┘ └────────────┘ └───────────┘ └──────────┘ └──────────┘ │
│                                                                      │
│  Student Evaluation Grid: Meets / Does Not Meet + Reasons            │
└──────────────────────┬───────────────────────────────────────────────┘
                       │ fin_fee_access_policy (accounts DB)
                       ▼
┌──────────────────────────────────────────────────────────────────────┐
│  EVALUATION ENGINE — EvaluateStudentAccess(regno)                    │
│                                                                      │
│  1. Load active policy                                               │
│  2. Get student balance (fin_ledger via fin_GetStudentLedger)        │
│  3. Get payment-window payments (fin_ledger, date-filtered)          │
│  4. Get bursary/scholarship status (scholarshipstudents)             │
│  5. Check registration status (acad_registration)                    │
│  6. Check existing studLock flag                                     │
│  7. Apply rules → return AccessResult object                         │
└──────┬───────────────────────────────────┬───────────────────────────┘
       │                                   │
       ▼                                   ▼
┌────────────────────┐          ┌────────────────────────┐
│ STUDENT PORTAL     │          │ API v2 Endpoint        │
│ Dashboard Alert    │          │ ?action=access_status  │
│ (PortalMaster /    │          │ JSON response          │
│  dashboard.aspx)   │          │ (mobile / external)    │
└────────────────────┘          └────────────────────────┘
```

---

## 3. Data Model

### 3.1 Table: `fin_fee_access_policy` (in `campus_dynamics_accounts` database)

| Column | Type | Description |
|--------|------|-------------|
| `policy_id` | INT AUTO_INCREMENT PK | Primary key |
| `policy_title` | VARCHAR(200) | Descriptive title (e.g. "Semester 1 2025/2026 Access Policy") |
| `academic_year` | VARCHAR(20) | Target academic year (e.g. "2025/2026") |
| `semester` | INT | Target semester (1 or 2) |
| `is_active` | TINYINT(1) DEFAULT 0 | Only one active policy at a time |
| `created_by` | VARCHAR(100) | Admin username |
| `created_at` | DATETIME | Creation timestamp |
| `updated_at` | DATETIME | Last update timestamp |
| **Balance Rule** | | |
| `rule_min_balance_enabled` | TINYINT(1) DEFAULT 0 | Enable minimum-balance check |
| `rule_min_balance_amount` | DECIMAL(15,2) DEFAULT 0 | Maximum outstanding balance allowed (e.g. 500000 = student must owe ≤ 500k) |
| **Payment Window Rule** | | |
| `rule_payment_window_enabled` | TINYINT(1) DEFAULT 0 | Enable payment-window check |
| `rule_payment_min_amount` | DECIMAL(15,2) DEFAULT 0 | Minimum amount that must have been paid within the window |
| `rule_payment_window_start` | DATE NULL | Start of payment window |
| `rule_payment_window_end` | DATE NULL | End of payment window |
| **Percentage-Paid Rule** | | |
| `rule_pct_paid_enabled` | TINYINT(1) DEFAULT 0 | Enable percentage-paid check |
| `rule_pct_paid_minimum` | DECIMAL(5,2) DEFAULT 0 | Minimum % of total bill that must be paid (e.g. 60.00) |
| **Bursary/Scholarship Rule** | | |
| `rule_bursary_exempt` | TINYINT(1) DEFAULT 1 | Auto-grant access to active bursary/scholarship holders |
| `rule_bursary_min_coverage` | DECIMAL(5,2) DEFAULT 0 | Minimum bursary coverage % to qualify for exemption (0 = any bursary) |
| **Registration Rule** | | |
| `rule_require_registration` | TINYINT(1) DEFAULT 0 | Student must be registered for the target semester |
| **Combination Logic** | | |
| `rule_logic` | VARCHAR(10) DEFAULT 'ALL' | `'ALL'` = must pass every enabled rule; `'ANY'` = pass at least one |
| **Notes** | | |
| `policy_notes` | TEXT NULL | Free-text notes for the bursar |

> **Design rationale:** A single flat row is simpler to query, inspect, and maintain than a normalised rule-chain. The number of rule types is bounded and well-defined, so a flat schema avoids the complexity of an EAV pattern while remaining extensible (adding a new rule = adding 2-3 columns + a wizard step).

---

## 4. Evaluation Logic — `EvaluateStudentAccess()`

### 4.1 Inputs
- `string regno` — student registration number
- Active policy loaded from `fin_fee_access_policy WHERE is_active = 1`

### 4.2 Algorithm (pseudocode)

```
function EvaluateStudentAccess(regno):
    policy = LoadActivePolicy()
    if policy is null:
        return AccessResult(allowed=true, reason="No active access policy configured")

    results = []

    // ── Rule 1: Minimum Balance ──
    if policy.rule_min_balance_enabled:
        balance = GetStudentBalance(regno)           // DR - CR from fin_ledger
        if balance > policy.rule_min_balance_amount:
            results.add(FAIL, "Outstanding balance {balance} exceeds maximum allowed {policy.rule_min_balance_amount}")
        else:
            results.add(PASS, "Balance within acceptable range")

    // ── Rule 2: Payment Window ──
    if policy.rule_payment_window_enabled:
        windowPayments = GetPaymentsInWindow(regno, policy.rule_payment_window_start, policy.rule_payment_window_end)
        if windowPayments < policy.rule_payment_min_amount:
            results.add(FAIL, "Payments of {windowPayments} between {start}-{end} below required {min}")
        else:
            results.add(PASS, "Payment window requirement met")

    // ── Rule 3: Percentage Paid ──
    if policy.rule_pct_paid_enabled:
        totalBill = GetTotalBill(regno)
        totalPaid = GetTotalPaid(regno)
        pctPaid = totalBill > 0 ? (totalPaid / totalBill * 100) : 100
        if pctPaid < policy.rule_pct_paid_minimum:
            results.add(FAIL, "Only {pctPaid}% paid, minimum required is {policy.rule_pct_paid_minimum}%")
        else:
            results.add(PASS, "Percentage paid requirement met")

    // ── Rule 4: Bursary Exemption ──
    if policy.rule_bursary_exempt:
        bursary = GetActiveBursary(regno, policy.academic_year, policy.semester)
        if bursary exists:
            coverage = bursary.amount_offered / totalBill * 100
            if coverage >= policy.rule_bursary_min_coverage:
                return AccessResult(allowed=true, reason="Bursary/scholarship holder — exempt",
                                    bursary_status="Active: {bursary.scheme_name}")

    // ── Rule 5: Registration Check ──
    if policy.rule_require_registration:
        isRegistered = CheckRegistration(regno, policy.academic_year, policy.semester)
        if not isRegistered:
            results.add(FAIL, "Not registered for {academic_year} Semester {semester}")
        else:
            results.add(PASS, "Registered for current semester")

    // ── Combine results ──
    if policy.rule_logic == 'ALL':
        allowed = all results are PASS
    else:  // ANY
        allowed = at least one result is PASS

    return AccessResult(allowed, results, balance, totalBill, totalPaid, bursaryStatus)
```

### 4.3 Output: `AccessResult`

| Field | Type | Description |
|-------|------|-------------|
| `allowed` | bool | Overall access granted or denied |
| `policy_title` | string | Title of the active policy |
| `criteria` | List | Per-rule pass/fail with human-readable reason |
| `total_bill` | decimal | Total charges (DR) |
| `total_paid` | decimal | Total payments (CR) |
| `balance` | decimal | Outstanding balance |
| `bursary_status` | string | "Active: {scheme}", "None", or "Expired" |
| `guidance` | string | If denied: what the student needs to do |

---

## 5. Component Breakdown

### 5.1 Admin: `FeeAccessPolicy.aspx` (Wizard UI)

**Location:** `COOPERP/NewScreens/FeeAccessPolicy.aspx`  
**Master:** `SidebarMaster.master`  
**CSS prefix:** `fap-`

#### Wizard Steps

| Step | Title | Fields |
|------|-------|--------|
| 1 | **Policy Details** | Title, Academic Year (dropdown), Semester (dropdown), Combination Logic (ALL/ANY toggle), Notes |
| 2 | **Balance Threshold** | Enable toggle, Maximum Outstanding Balance amount input |
| 3 | **Payment Window** | Enable toggle, Minimum Payment amount, Start Date, End Date |
| 4 | **Percentage & Extras** | Percentage-paid enable + minimum %, Bursary exemption toggle + minimum coverage %, Require Registration toggle |
| 5 | **Review & Activate** | Summary card, Student impact preview (sample counts), Activate/Save as Draft button |

#### Student Evaluation Grid

Below the wizard: a searchable, paginated grid showing all students with:
- Name, RegNo, Programme
- Total Bill, Total Paid, Balance
- Access Status (green ✓ / red ✗)
- Reasons (expandable)

Supports export to CSV.

### 5.2 Portal: Dashboard Alert

**Location:** `CampusDynamics_Portal/dashboard.aspx` (+ code-behind)

A prominent alert card at the top of the dashboard:
- **Green (access granted):** "You meet the current fee requirements for access."
- **Red (access denied):** "You do not currently meet fee requirements." + list of failed criteria + guidance text.
- **Grey (no policy):** No alert shown.

### 5.3 API v2 Endpoint

**Location:** `CampusDynamics/API/v2/finance.aspx.cs`  
**Action:** `?action=access_status`

**Request:**
```
GET /API/v2/finance.aspx?action=access_status
Header: Authorization: Bearer <token>
Optional: ?regno=MRU2025XXXXXX (staff only)
```

**Response:**
```json
{
  "ok": true,
  "data": {
    "regno": "MRU2025000001",
    "access_allowed": true,
    "policy_title": "Semester 1 2025/2026 Access Policy",
    "total_bill": 3500000,
    "total_paid": 2800000,
    "balance": 700000,
    "currency": "UGX",
    "bursary_status": "None",
    "criteria": [
      { "rule": "Minimum Balance", "status": "PASS", "detail": "Balance 700,000 within allowed maximum 1,000,000" },
      { "rule": "Payment Window", "status": "PASS", "detail": "Paid 1,500,000 between 01/01/2026-15/04/2026 (required: 1,000,000)" },
      { "rule": "Percentage Paid", "status": "PASS", "detail": "80.0% paid (required: 60%)" }
    ],
    "guidance": null
  }
}
```

**Failure response example:**
```json
{
  "ok": true,
  "data": {
    "regno": "MRU2025000099",
    "access_allowed": false,
    "policy_title": "Semester 1 2025/2026 Access Policy",
    "total_bill": 3500000,
    "total_paid": 500000,
    "balance": 3000000,
    "currency": "UGX",
    "bursary_status": "None",
    "criteria": [
      { "rule": "Minimum Balance", "status": "FAIL", "detail": "Balance 3,000,000 exceeds maximum allowed 1,000,000" },
      { "rule": "Payment Window", "status": "FAIL", "detail": "Paid 200,000 between 01/01/2026-15/04/2026 (required: 1,000,000)" },
      { "rule": "Percentage Paid", "status": "FAIL", "detail": "14.3% paid (required: 60%)" }
    ],
    "guidance": "Please pay at least 2,000,000 UGX to meet the minimum balance requirement, or make a payment of at least 800,000 UGX within the current payment window."
  }
}
```

---

## 6. Implementation Tasks

| # | Task | Status | Target Date |
|---|------|--------|-------------|
| 1 | Write implementation plan (this document) | ✅ Complete | 15 Apr 2026 |
| 2 | Create `fin_fee_access_policy` table (auto-migration in code) | ✅ Complete | 15 Apr 2026 |
| 3 | Build `FeeAccessPolicy.aspx` — wizard UI + CSS | ✅ Complete | 15 Apr 2026 |
| 4 | Build `FeeAccessPolicy.aspx.cs` — CRUD, evaluation engine, student grid | ✅ Complete | 15 Apr 2026 |
| 5 | Add portal dashboard access alert (`PortalMaster.master` + `FeeAccessHelper.cs`) | ✅ Complete | 16 Apr 2026 |
| 6 | Add API v2 `access_status` endpoint (`finance.aspx.cs`) | ✅ Complete | 16 Apr 2026 |
| 7 | Link admin sidebar to new page | ✅ Complete | 15 Apr 2026 |
| 8 | End-to-end verification (zero compile errors) | ✅ Complete | 16 Apr 2026 |

---

## 7. Flowchart — Student Access Evaluation

```
    ┌─────────────────────┐
    │  Student requests    │
    │  access check        │
    │  (portal/API/gate)   │
    └─────────┬───────────┘
              │
              ▼
    ┌─────────────────────┐
    │ Load active policy   │──── No policy? ──→ ACCESS GRANTED (default open)
    └─────────┬───────────┘
              │ Policy found
              ▼
    ┌─────────────────────┐
    │ Is student a bursary │
    │ holder with enough   ├── Yes & coverage ≥ min ──→ ACCESS GRANTED (exempt)
    │ coverage?            │
    └─────────┬───────────┘
              │ No / not enough
              ▼
    ┌─────────────────────┐
    │ Evaluate each        │
    │ enabled rule:        │
    │ • Balance threshold  │
    │ • Payment window     │
    │ • Percentage paid    │
    │ • Registration check │
    └─────────┬───────────┘
              │
              ▼
    ┌─────────────────────┐
    │ Combine using logic: │
    │ ALL → every rule pass│
    │ ANY → at least one   │
    └─────────┬───────────┘
              │
         ┌────┴────┐
         │         │
      All PASS   Any FAIL
         │         │
         ▼         ▼
    GRANTED    DENIED + reasons + guidance
```

---

## 8. Potential Challenges & Mitigations

| Challenge | Mitigation |
|-----------|------------|
| **Performance:** Evaluating all students for the admin grid could be slow with 2500+ students | Paginate the grid (50 per page). Use a single query that JOINs student data with aggregated ledger totals instead of N+1 queries. Cache the active policy in a static field with a short TTL. |
| **Dual data sources:** `fin_ledger` vs `fin_studentfeestracking` inconsistencies | Use `fin_ledger` (via `fin_GetStudentLedger` stored procedure) as the canonical source for balance reads — consistent with the existing portal `StudentFees.aspx` and API v2 pattern. |
| **Only one active policy:** Bursar might accidentally deactivate the wrong one | Auto-deactivate previous policy when a new one is activated. Show clear confirmation dialog. Keep history of all policies (soft-delete via `is_active = 0`). |
| **Bursary data in accounts DB, student data in main DB:** Cross-database joins | Use two separate connection strings (`accountsConnectionString` + `vacConnectionString`) and fetch data in two queries, joining in C# — same pattern as `BursaryBeneficiaries.aspx.cs`. |
| **Timezone / date boundary issues** for payment window | Store dates as DATE (not DATETIME). Compare with `<=` on end date so the full final day is included. Server timezone matches Uganda (EAT, UTC+3). |
| **C# 5 compatibility** | No `?.` operator, no string interpolation, no `out var`. Use `SafeInt()`, `SafeDec()`, `string.Format()`, explicit null checks — same pattern as all existing NewScreens pages. |
| **Stale balance data** during payment processing | Evaluation is always real-time (queries `fin_ledger` at call time). No caching of student-level financial data. |

---

## 9. Future Enhancements

| Enhancement | Description |
|-------------|-------------|
| **Per-programme overrides** | Allow different thresholds for different programmes (e.g. Medical vs Arts). Could add a `fin_fee_access_policy_overrides` table keyed by `progid`. |
| **Temporal auto-activation** | Allow bursar to schedule policy activation/deactivation dates so policies automatically switch at semester boundaries. |
| **SMS/Email notifications** | When a student's status changes from denied to granted (e.g. after a payment), auto-send a notification. |
| **Audit trail** | Log every policy change with before/after values and the admin who made the change. |
| **Student self-service payment link** | In the denial alert, include a direct link to the payment portal or mobile money integration. |
| **Bulk lock/unlock** | After evaluation, allow bursar to one-click lock all non-compliant students and unlock all compliant ones (updating `acad_student.studLock`). |
| **Dashboard analytics** | Show compliance trends over time (e.g. % of students compliant by week leading up to exam period). |
| **Webhook notifications** | Push access-status changes to external systems (e.g. campus gate controllers, LMS). |

---

## 10. Files to Create / Modify

| File | Action | Purpose |
|------|--------|---------|
| `COOPERP/NewScreens/FeeAccessPolicy.aspx` | **Create** | Admin wizard UI |
| `COOPERP/NewScreens/FeeAccessPolicy.aspx.cs` | **Create** | Admin code-behind + evaluation engine |
| `CampusDynamics_Portal/dashboard.aspx` | **Modify** | Add access status alert card |
| `CampusDynamics_Portal/dashboard.aspx.cs` | **Modify** | Add access evaluation call |
| `CampusDynamics/API/v2/finance.aspx.cs` | **Modify** | Add `access_status` action |
| `FEE_ACCESS_CRITERIA_IMPLEMENTATION.md` | **Create** | This document |

---

*End of implementation plan.*
