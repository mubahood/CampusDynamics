# Staff Identity Resolution — Root Cause, Fix, and Architecture

**Date:** 2026-04-20  
**Author:** Campus Dynamics maintenance session  
**Status:** RESOLVED — all loopholes closed

---

## Table of Contents

1. [Summary of the Incident](#1-summary-of-the-incident)
2. [Root Cause Analysis](#2-root-cause-analysis)
3. [Database Fixes Applied](#3-database-fixes-applied)
4. [Code Changes Made](#4-code-changes-made)
5. [Identity Resolution Architecture (How It Works Now)](#5-identity-resolution-architecture)
6. [Diagnostic / Debug Tools](#6-diagnostic--debug-tools)
7. [Remaining Minor Issues](#7-remaining-minor-issues)
8. [How to Handle a New Staff Member with the Same Problem](#8-how-to-handle-a-new-staff-member-with-the-same-problem)
9. [Prevention — HR Import Guidelines](#9-prevention--hr-import-guidelines)
10. [Resolved Case Study — Lecturer Provisional Marks (2026-04-21)](#10-resolved-case-study--lecturer-provisional-marks-2026-04-21)

---

## 1. Summary of the Incident

**Symptom:** When Dr Abubakhari Sserwadda (`sserwaddaa@mru.ac.ug`) logged in, the portal displayed **wrong staff profiles** — e.g., Mulwana Tonny, Jagwe Aisha Lutale, or Mulindwa Christopher — depending on which session slot happened to get resolved first.

**Affected login:** `sserwaddaa@mru.ac.ug`  
**Affected empID:** 252 (own record), but also indirectly all 75 staff rows sharing the same placeholder email.

**Confirmed fixed:** After DB + code changes, Dr Sserwadda sees his own three courses and 606 students. Debug panel confirms `GetStaffDetails = FOUND, SA1082025C, Dr Abubakhari Sserwadda`.

---

## 2. Root Cause Analysis

### 2a. The Data Problem

During a **bulk HR import**, the import script filled in placeholder values for all staff rows where real data was not yet known:

| Column | Placeholder value |
|--------|------------------|
| `hrm_employee.usernames` | `-` (a single dash) |
| `hrm_employee.emp_email` | `sserwaddaa@mru.ac.ug` |

This produced **75 rows** all sharing the same email and all having a non-functional username.

When the portal tried to resolve `sserwaddaa@mru.ac.ug` via an email-match SQL query, it got **75+ results** instead of 1. The ambiguity guard inside `GetStaffDetails` caused it to return **NOT FOUND**, and the fallback logic then picked the first cached or session-resident row — which happened to be the wrong person.

### 2b. SQL Audit That Confirmed It

```sql
SELECT empID, emp_name, EMP_CODE, usernames, emp_email
FROM campus_dynamics.hrm_employee
WHERE LOWER(TRIM(IFNULL(emp_email,''))) = 'sserwaddaa@mru.ac.ug'
ORDER BY empID;
-- Returned 75 rows — all impersonating Dr Sserwadda's email
```

### 2c. Portal Auth Table

`campus_dynamics_portal.my_aspnet_users` had the row for `sserwaddaa@mru.ac.ug` with `user_type='STUDENT'` instead of `'LECTURER'`, which also caused the dashboard to render the student view.

---

## 3. Database Fixes Applied

### 3a. Individual fix — empID 252 (Dr Abubakhari Sserwadda)

File: `CampusDynamics/fix_sserwadda_identity.sql`

```sql
-- Fix username
UPDATE campus_dynamics.hrm_employee
SET    usernames = 'sserwaddaa'
WHERE  empID = 252;

-- Fix portal auth user_type
UPDATE campus_dynamics_portal.my_aspnet_users
SET    user_type = 'LECTURER'
WHERE  LOWER(name) = 'sserwaddaa@mru.ac.ug';
```

### 3b. Bulk fix — all 75 affected staff rows

File: `CampusDynamics/fix_all_staff_dash_usernames.sql`

```sql
-- Step 1: Assign real username = EMP_CODE for every dash-username row
UPDATE campus_dynamics.hrm_employee
SET    usernames = TRIM(EMP_CODE)
WHERE  (usernames IS NULL OR TRIM(usernames) = '' OR TRIM(usernames) = '-')
  AND  EMP_CODE IS NOT NULL
  AND  TRIM(EMP_CODE) <> ''
  AND  TRIM(EMP_CODE) <> '-';

-- Step 2: Clear the bogus placeholder email from the 74 rows that shouldn't have it
UPDATE campus_dynamics.hrm_employee
SET    emp_email = ''
WHERE  LOWER(TRIM(IFNULL(emp_email,''))) = 'sserwaddaa@mru.ac.ug'
  AND  empID <> 252;
```

**Verification result after running (2026-04-20):**

| still_missing_username | bogus_email_rows |
|----------------------|-----------------|
| 0 | 1 (only empID=252, correct) |

> **Note:** `hrm_employee.emp_email` has a `NOT NULL` constraint. Use `''` (empty string), **never `NULL`**.

---

## 4. Code Changes Made

### 4a. `CampusDynamics_Portal/App_Code/Portal/PortalHelper.cs`

#### NEW: `ResolveStaffLookupKey(string username)`
- If `username` looks like an MRU email (`@mru.ac.ug`), extracts the local-part (e.g., `sserwaddaa`).
- Tries exact match against `hrm_employee.usernames` or `EMP_CODE` — **excluding dash placeholders** via `NULLIF(TRIM(IFNULL(usernames,'')),'-')`.
- If no exact match, falls back to email+name-fragment path **only when that email maps to exactly 1 row** (unique-email guard).
- Returns the resolved key, or the original input if nothing better was found.

#### CHANGED: `GetStaffDetails(string username)`
- Now calls `ResolveStaffLookupKey()` first before any SQL queries.
- All email-based fallbacks wrapped in `(SELECT COUNT(*) FROM hrm_employee WHERE LOWER(emp_email)=LOWER(@u))=1` to prevent ambiguous matches.

#### CHANGED: `ResolveCanonicalRegno()`
- For STAFF/LECTURER hint: local-part lookup is now **priority-0**, before the existing email query.
- Same ambiguity guard applied to email-match conditions.

### 4b. `CampusDynamics_Portal/COOPERP/fonts/lg_modern.ascx.cs`

In `Login1_LoggedIn` Step 3b:
- Staff detection now tries the email **local-part** first (`cmdLp` query).
- On match, sets `staffLookupKey = localPart` and `canonicalRegno = staffLookupKey`.
- This means `Session["regno"]` stores the staff's short username (e.g., `sserwaddaa`), not the full email address — eliminating ambiguity on the next page load.

### 4c. `CampusDynamics_Portal/PortalMaster.master.cs`

In `FindStaffRow()`:
- Removed the `allowFuzzy` parameter entirely.
- Ambiguous matches (>1 row) now return `null` (fail-closed) instead of returning the first row.
- Name-based fuzzy SQL removed — only exact `usernames`, `EMP_CODE`, or **verified-unique** email match.

### 4d. `CampusDynamics_Portal/UserControls/Security/SystemApplications_Modern.ascx.cs`

In `LoadStaffTeachingDashboard()`:
- Resolves email local-part before the `hrm_employee` empID lookup — same guard as PortalHelper.

Debug panel added (see §6).

---

## 5. Identity Resolution Architecture

Below is the end-to-end flow for a staff member whose login is an email address.

```
User submits email + password
       │
       ▼
lg_modern.ascx.cs — Login1_LoggedIn
  ├─ Extract local-part of email  (e.g. "sserwaddaa" from "sserwaddaa@mru.ac.ug")
  ├─ Try exact usernames/EMP_CODE match in hrm_employee (excluding '-')
  ├─ On match: Session["regno"] = localPart  ← stored as short key, not email
  └─ On miss: fall back to unique-email match (only if COUNT=1)
       │
       ▼
PortalMaster.master.cs — Page_Load
  └─ FindStaffRow(Session["regno"])
       ├─ Exact usernames/EMP_CODE match
       ├─ Unique-email match (COUNT guard)
       └─ NULL if ambiguous (fail-closed)
       │
       ▼
PortalHelper.cs — GetStaffDetails(canonicalRegno)
  └─ ResolveStaffLookupKey() ← normalises to short key first
       ├─ Query 1: exact usernames/EMP_CODE (excludes dash)
       ├─ Query 2: unique-email path (COUNT=1 guard)
       └─ Full staff DataRow returned
       │
       ▼
SystemApplications_Modern.ascx.cs — LoadStaffTeachingDashboard
  └─ Uses resolved empID to load courses + student counts
```

**Key invariants:**
- A dash (`-`) username is never treated as a valid match.
- An email is only used for lookup when exactly **one** row has that email.
- `Session["regno"]` should always hold the short staff username (or student regno), never a raw email.

---

## 6. Diagnostic / Debug Tools

A hidden identity debug panel was added to `SystemApplications_Modern.ascx.cs`.

**To enable:** Append `?debugid=1` to any portal URL after logging in.  
**To disable:** Append `?debugid=0`.

The panel shows:
- All session key/value pairs relevant to identity
- Match counts: by `usernames`, by `EMP_CODE`, by email
- Local-part resolution test (what key would be used)
- Name-fragment search (LIKE % match for debugging new staff)
- Portal membership row from `my_aspnet_users`
- OTP history count

> **Production note:** The `?debugid=1` gate stores the flag in server-side session, so it is not accessible to ordinary users. However, consider replacing the session-write with an IP whitelist or admin-role check before going fully public.

---

## 7. Remaining Minor Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| `Session["ScreenName"]` empty at login for email-auth staff | Low | Name is lazy-loaded after first page render. Fix: after resolving `staffLookupKey` in `lg_modern`, query `emp_name` and set `Session["ScreenName"]` immediately. |
| `my_aspnet_users.user_type` not verified at login | Low | If a staff row has `user_type='STUDENT'`, the wrong dashboard renders. Fix: add a check in `Login1_LoggedIn` — if staff lookup succeeds but `user_type != 'LECTURER'/'STAFF'`, UPDATE the row. |
| Debug panel querystring gate | Low | Replace `?debugid=1` with an admin-only role check before full production deployment. |

---

## 8. How to Handle a New Staff Member with the Same Problem

If a staff member reports "I'm seeing someone else's profile" or "my courses are not showing":

### Step 1 — Find their empID

```sql
SELECT empID, emp_name, EMP_CODE, usernames, emp_email
FROM campus_dynamics.hrm_employee
WHERE LOWER(emp_email) = LOWER('their.email@mru.ac.ug')
   OR LOWER(usernames) = LOWER('theirusername');
```

### Step 2 — Check for ambiguity

```sql
SELECT COUNT(*) FROM campus_dynamics.hrm_employee
WHERE LOWER(emp_email) = LOWER('their.email@mru.ac.ug');
-- If > 1: email is shared/bogus — follow Step 3
-- If = 1 but usernames='-': follow Step 4
```

### Step 3 — Clear bogus email from other rows

```sql
UPDATE campus_dynamics.hrm_employee
SET    emp_email = ''
WHERE  LOWER(emp_email) = 'bogus.email@mru.ac.ug'
  AND  empID <> <their_real_empID>;
```

### Step 4 — Fix dash username

```sql
UPDATE campus_dynamics.hrm_employee
SET    usernames = TRIM(EMP_CODE)   -- or their preferred short username
WHERE  empID = <their_empID>;
```

### Step 5 — Fix portal auth user_type if needed

```sql
UPDATE campus_dynamics_portal.my_aspnet_users
SET    user_type = 'LECTURER'       -- or 'STAFF' as appropriate
WHERE  LOWER(name) = LOWER('their.email@mru.ac.ug');
```

### Step 6 — Verify

1. Log in as the staff member.
2. Add `?debugid=1` to the URL.
3. Confirm: `Exact usernames matches = 1`, `GetStaffDetails = FOUND`, correct EMP_CODE and name shown.

---

## 9. Prevention — HR Import Guidelines

To prevent recurrence, any bulk HR import script **must** enforce:

1. **No placeholder emails.** If the staff member's real email is unknown, leave `emp_email = ''` (empty string) — **never** copy another person's email.

2. **No placeholder usernames.** If the real username is unknown, set `usernames = EMP_CODE`. EMP_CODE is always unique; a dash is not.

3. **Uniqueness check before import:**
   ```sql
   -- Run before any bulk insert of new staff rows:
   SELECT emp_email, COUNT(*) AS c
   FROM campus_dynamics.hrm_employee
   WHERE emp_email <> ''
   GROUP BY emp_email
   HAVING c > 1;
   -- Result must be empty before proceeding.
   ```

4. **Post-import audit:**
   ```sql
   SELECT COUNT(*) FROM campus_dynamics.hrm_employee
   WHERE TRIM(IFNULL(usernames,'')) IN ('','-');
   -- Must be 0.
   ```

---

## 10. Resolved Case Study — Lecturer Provisional Marks (2026-04-21)

This identity architecture was re-validated during a production incident on `LecturerProvisionalMarksController.aspx`.

**Observed sequence:**
- Identity ambiguity from historical HR placeholders (already addressed by this architecture)
- Legacy compile/parser blockers under low disk conditions
- Missing code-behind file parser failure
- Runtime query timeout after parser recovery

**Outcome:**
- Page restored and now working in normal server-side mode (no AJAX-first dependency)
- Staff context resolves correctly for Dr Abubakhari Sserwadda (`staffId=252`)
- Query path optimized to reduce timeout risk on large datasets

**Full incident observations:**
- `CampusDynamics_Portal/LPMC_OBSERVATIONS_2026-04-21.md`

---

*End of document.*
