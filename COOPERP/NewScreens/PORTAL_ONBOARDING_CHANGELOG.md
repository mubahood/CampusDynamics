# Campus Dynamics — Portal & Onboarding System Changelog

> Comprehensive documentation of all changes made to the Student Portal and Admin EMIS
> across multiple development sessions.
>
> **Period:** March 2026
> **System:** Campus Dynamics (Mountains of the Moon University, Uganda)
> **Sites affected:** `eadmin.mru.ac.ug` (admin) | `eportal.mru.ac.ug` (student portal)

---

## Table of Contents

1. [Employee/Staff Login Fix (Dual-Provider Authentication)](#1-employeestaff-login-fix)
2. [Student vs Staff Identification (DB Lookup)](#2-student-vs-staff-identification)
3. [UTF-8 Encoding Fix (Mojibake on Button Icons)](#3-utf-8-encoding-fix)
4. [Enrollment Verification Page (Blank Page Fix)](#4-enrollment-verification-blank-page-fix)
5. [Email Verification Wizard](#5-email-verification-wizard)
6. [OTP Email Formatting](#6-otp-email-formatting)
7. [Session Timeout Fixes](#7-session-timeout-fixes)
8. [Registration Wizard Fixes](#8-registration-wizard-fixes)
9. [Course Registration Page (New — Fixing 404)](#9-course-registration-page)
10. [Portal Onboarding Admin Page (New + Rewrite)](#10-portal-onboarding-admin-page)
11. [PortalHelper Shared Library (New)](#11-portalhelper-shared-library)
12. [Compilation & Namespace Fixes](#12-compilation--namespace-fixes)

---

## 1. Employee/Staff Login Fix

### Problem
Staff/employee users could not log in to the student portal (`eportal.mru.ac.ug`). The portal only authenticated against the portal database (`campus_dynamics_portal`), but staff accounts live in the admin database (`campus_dynamics`).

### Solution
Rewrote the `Login1_Authenticate` method in `COOPERP/fonts/lg_modern.ascx.cs` to implement **dual-provider authentication**:

1. **Resolve aliases first** — translates email, employee number, or phone to the real membership username via `ResolveToMembershipUsername()`.
2. **Try portal DB** — uses default `Membership.ValidateUser()` (campus_dynamics_portal).
3. **Try admin DB** — uses secondary `MySQLMembershipProviderAdmin` provider (campus_dynamics).
4. If admin auth succeeds, sets `Session["usertype"] = "STAFF"`.

### Files Modified
| File | Project | Change |
|------|---------|--------|
| `COOPERP/fonts/lg_modern.ascx.cs` | Portal | Complete rewrite of `Login1_Authenticate`, new `ResolveToMembershipUsername()`, updated `Login1_LoggedIn` |

### Key Code (Login1_Authenticate)
```csharp
// Try candidates against both providers
foreach (string candidate in candidates)
{
    // A: portal DB (students)
    if (Membership.ValidateUser(candidate, password)) { ... }

    // B: admin DB (staff)
    MembershipProvider adminProv = Membership.Providers["MySQLMembershipProviderAdmin"];
    if (adminProv != null && adminProv.ValidateUser(candidate, password))
    {
        Session["usertype"] = "STAFF";
        e.Authenticated = true;
        return;
    }
}
```

### Key Code (ResolveToMembershipUsername)
Resolves user input to membership username by checking:
- Student email / reg_email → `acad_student.regno`
- Staff email (emp_email) → `hrm_employee.usernames`
- Employee number (emp_id) → `hrm_employee.usernames`
- Phone / mobile → `acad_student.regno`

---

## 2. Student vs Staff Identification

### Problem
The portal could not reliably distinguish between student and staff users after login. Some staff were being treated as students and redirected through the enrollment verification flow.

### Solution
Implemented definitive DB-based identification via `PortalHelper.IsStaffUser()`:

1. Checks `Session["usertype"]` for "STAFF" (set during dual-auth login).
2. Falls back to DB lookup: queries `campus_dynamics.hrm_employee` to see if the username matches an employee record (`usernames`, `emp_id`, or `emp_email`).
3. Staff users are redirected to `MyApplications_Modern.aspx` and bypass all student enrollment gates.

### Files Modified
| File | Project | Change |
|------|---------|--------|
| `App_Code/Portal/PortalHelper.cs` | Portal | Added `IsStaffUser()` method |
| `EnrollmentVerification.aspx.cs` | Portal | Added staff check at page load |
| `EmailVerification.aspx.cs` | Portal | Added staff check at page load |
| `RegistrationWizard.aspx.cs` | Portal | Added staff check at page load |
| `CourseRegistration.aspx.cs` | Portal | Added staff check at page load |

### Key Code
```csharp
public static bool IsStaffUser(System.Web.UI.Page page, string regno)
{
    // Check session first
    string userType = page.Session["usertype"] as string;
    if (!string.IsNullOrEmpty(userType) && userType.Equals("STAFF", StringComparison.OrdinalIgnoreCase))
        return true;

    // DB fallback: check hrm_employee table
    // ...queries campus_dynamics.hrm_employee WHERE usernames=@u OR emp_id=@u...
}
```

---

## 3. UTF-8 Encoding Fix

### Problem
Special characters and icon symbols (Unicode) on button text were rendering as mojibake (`â€"` instead of `—`, broken checkmarks, etc.) across multiple portal pages.

### Solution
Added `ResponseEncoding="UTF-8"` to the `<%@ Page %>` directive of all affected `.aspx` pages:

```aspx
<%@ Page Language="C#" ... ResponseEncoding="UTF-8" %>
```

### Files Modified
| File | Project |
|------|---------|
| `EnrollmentVerification.aspx` | Portal |
| `EmailVerification.aspx` | Portal |
| `RegistrationWizard.aspx` | Portal |

---

## 4. Enrollment Verification — Blank Page Fix

### Problem
The `EnrollmentVerification.aspx` page was rendering completely blank. The page content was invisible even though the code-behind was running successfully.

### Root Cause
A CSS conflict — the page's `<style>` block had a rule that was hiding the main content container. The enrollment verification styles were colliding with the portal's master page styles.

### Solution
Fixed the CSS specificity and ensured the main content container (`div.ev-container`) was visible. Restructured the page layout to avoid master page CSS conflicts.

### Files Modified
| File | Project | Change |
|------|---------|--------|
| `EnrollmentVerification.aspx` | Portal | Fixed CSS rules, restructured layout |
| `EnrollmentVerification.aspx.cs` | Portal | Cleaned up page lifecycle |

---

## 5. Email Verification Wizard

### Problem
Students needed a way to verify their MRU email addresses after enrollment verification. This was a new feature requirement for the portal onboarding flow.

### Solution
Created a complete email verification wizard (`EmailVerification.aspx`) that:

1. **Pre-fills** the student's email from previous OTP requests.
2. **Validates** email format and checks if the email is already claimed by another student (`IsEmailTakenByAnother()`).
3. **Sends OTP** via the external email API (`https://erp.edusaterp.com/api/SecureOTP/sendotp`).
4. **Stores OTP** in `portal_otp_codes` table with 10-minute expiry.
5. **Verifies OTP** — updates `my_aspnet_users.verified_email` on success.
6. **Redirects** to `RegistrationWizard.aspx` after successful verification.

### Database Tables
| Table | Database | Purpose |
|-------|----------|---------|
| `portal_otp_codes` | campus_dynamics_portal | Stores OTP codes (auto-created by `EnsureOtpTable()`) |
| `my_aspnet_users.verified_email` | campus_dynamics_portal | Stores verified email address |

### Files Created/Modified
| File | Project | Change |
|------|---------|--------|
| `EmailVerification.aspx` | Portal | New page — OTP email verification wizard |
| `EmailVerification.aspx.cs` | Portal | New code-behind with OTP logic |
| `App_Code/Portal/PortalHelper.cs` | Portal | Added `GenerateAndStoreOtp()`, `VerifyOtp()`, `SaveVerifiedEmail()`, `IsEmailTakenByAnother()`, `GetLastOtpEmail()`, `SendOtpEmail()`, `EnsureOtpTable()` |

---

## 6. OTP Email Formatting

### Problem
Initially attempted HTML-formatted OTP emails, but the external email API (`erp.edusaterp.com`) has a URL length limit that truncated HTML content.

### Solution
Reverted to **plain text** OTP emails. The `SendOtpEmail()` method constructs a simple text message:

```
Your Mountains of the Moon University portal verification code is: 123456
This code expires in 10 minutes. Do not share it.
```

### Files Modified
| File | Project | Change |
|------|---------|--------|
| `App_Code/Portal/PortalHelper.cs` | Portal | `SendOtpEmail()` uses plain text format |

---

## 7. Session Timeout Fixes

### Problem
Portal sessions were expiring too quickly, causing students to lose their progress through the enrollment → email verification → registration wizard flow.

### Solution
Extended session and authentication timeouts:

| Setting | Old Value | New Value | Location |
|---------|----------|-----------|----------|
| Session state | Default (20 min) | InProc, no explicit timeout | `web.config` |
| Forms auth cookie | Session cookie | Persistent, 2-year lifetime | `lg_modern.ascx.cs` |
| Cache entry | Short timeout | 365 days | `lg_modern.ascx.cs` |

### Key Code (lg_modern.ascx.cs — Login1_LoggedIn)
```csharp
// Persistent forms-auth cookie (survives browser close)
FormsAuthentication.SetAuthCookie(username, true);

// Cache entry with 365-day timeout
TimeSpan timeOut = TimeSpan.FromDays(365);
HttpContext.Current.Cache.Insert(key, Session.SessionID, null,
    DateTime.MaxValue, timeOut, CacheItemPriority.NotRemovable, null);
```

---

## 8. Registration Wizard Fixes

### Problem
Multiple issues with the `RegistrationWizard.aspx` page:
1. **Wrong database** — queries were hitting `campus_dynamics_portal` instead of `campus_dynamics` for `acad_registration`.
2. **Year of study** — not being read or set correctly.
3. **No upsert** — duplicate registration records were being created.
4. **Course registration check** — Step 3 wasn't detecting existing course registrations.

### Solution

#### 8a. Database Connection Fix
The portal has **swapped connection string names** (confusingly):
- `vacConnectionString` → `campus_dynamics_portal` (portal DB)
- `campus_dynamics_portalConnectionString` → `campus_dynamics` (academic DB)

Fixed `RegistrationWizard.aspx.cs` to use the correct connection:

```csharp
private string AcadConnStr
{
    get
    {
        // acad_registration lives in campus_dynamics (academic DB),
        // NOT campus_dynamics_portal. In portal web.config the academic
        // DB is confusingly named "campus_dynamics_portalConnectionString".
        var cs = ConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"];
        if (cs != null) return cs.ConnectionString;
        return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    }
}
```

#### 8b. Year of Study Fix
Reads `studyyear` from `acad_student` and displays it in the wizard, pre-selecting the correct year.

#### 8c. Upsert for Semester Registration
Uses `INSERT ... ON DUPLICATE KEY UPDATE` to avoid duplicate `acad_registration` records:

```sql
INSERT INTO acad_registration (regno, acad_year, semester, studyyear, conducted_new_registration, ...)
VALUES (@regno, @ay, @sem, @yr, 'Yes', ...)
ON DUPLICATE KEY UPDATE conducted_new_registration='Yes', ...
```

#### 8d. Course Registration Detection
Step 3 checks `campus_dynamics_portal.acad_course_registration` for existing records. Uses `PortalHelper.HasCurrentSemesterRegistration()` and a separate course reg count check.

### Files Modified
| File | Project | Change |
|------|---------|--------|
| `RegistrationWizard.aspx` | Portal | Updated UI steps, year display |
| `RegistrationWizard.aspx.cs` | Portal | Fixed DB connection, upsert, year of study, course reg check |

---

## 9. Course Registration Page (New)

### Problem
`CourseRegistration.aspx` did not exist in the portal project, causing a **404 error** when students clicked "Register for Courses" in the Registration Wizard (Step 3).

### Solution
Created a complete course registration page from scratch:

#### Features
1. **Auth & enrollment gates** — same checks as RegistrationWizard (login, staff skip, verification, alumni redirect, email verified).
2. **Semester registration check** — must have current semester registration before accessing.
3. **Semester picker side panel** — shows available semesters from `acad_registration`.
4. **Available courses** — loads from `acad_programmecourses` + `acad_course` for the student's programme/year/semester.
5. **Already registered courses** — shows courses from `campus_dynamics_portal.acad_course_registration`.
6. **Course registration** — uses `acad_CourseRegister` stored procedure to register for selected courses.
7. **Already-checked detection** — pre-checks checkboxes for courses already registered.

#### Database Connections
| Connection | Database | Used For |
|------------|----------|----------|
| `AcadConnStr` (campus_dynamics) | Academic DB | `acad_student`, `acad_registration`, `acad_programme`, `acad_programmecourses`, `acad_course`, `acad_CourseRegister` SP |
| `PortalConnStr` (campus_dynamics_portal) | Portal DB | `acad_course_registration` (registered courses) |

### Files Created
| File | Project | Lines |
|------|---------|-------|
| `CourseRegistration.aspx` | Portal | ~280 lines (full UI with semester picker, course tables, checkboxes, submit) |
| `CourseRegistration.aspx.cs` | Portal | ~434 lines (auth gates, data loading, course registration logic) |

---

## 10. Portal Onboarding Admin Page

### Problem
Admins at `eadmin.mru.ac.ug` needed a way to see which students have completed the portal onboarding process (enrollment verification, email verification, semester registration).

### Solution — Version 1 (Initial)
Created `PortalOnboarding.aspx` with a complex approach:
- Base table: `acad_student` (all active students)
- LEFT JOINs to `campus_dynamics_portal.my_aspnet_users`, subqueries for `acad_registration` and `acad_course_registration`
- 6 summary cards, progress bar, 7 filter dropdowns, 11-column table

**Problem with V1:** The complex cross-database subquery JOINs were failing silently (empty `catch {}` blocks), resulting in no data displayed.

### Solution — Version 2 (Final — Simplified)
Completely rewritten with a **simple, portal-centric approach**:

- **Base table:** `campus_dynamics_portal.my_aspnet_users` — only students who have actually verified on the portal
- **Simple LEFT JOINs** to `acad_student`, `acad_programme`, `acad_registration` (no subqueries)
- **WHERE:** `user_verification_status IS NOT NULL AND <> ''`
- **4 summary cards** (Active Students, Alumni, Email Verified, Semester Registered)
- **4 filters** (Status, Email, Sem Reg, Programme)
- **9-column table** (Reg No, Name, Programme, Status, Email Verified, Verified Email, Sem Reg, Last Activity)
- **Pagination** (50 per page)

#### Key Query
```sql
FROM campus_dynamics_portal.my_aspnet_users u
LEFT JOIN acad_student s ON s.regno = u.name
LEFT JOIN acad_programme p ON p.progcode = s.progid
LEFT JOIN acad_registration reg ON reg.regno = u.name AND reg.acad_year = @acadYear
WHERE u.user_verification_status IS NOT NULL AND u.user_verification_status <> ''
GROUP BY u.name
ORDER BY u.lastactivitydate DESC
LIMIT @offset, @ps
```

#### Summary Stats Queries
```sql
-- Main counts (single fast query)
SELECT
  SUM(CASE WHEN user_verification_status = 'ACTIVE STUDENT' THEN 1 ELSE 0 END) AS a_cnt,
  SUM(CASE WHEN user_verification_status = 'ALUMNI' THEN 1 ELSE 0 END) AS al_cnt,
  SUM(CASE WHEN verified_email IS NOT NULL AND verified_email <> '' THEN 1 ELSE 0 END) AS e_cnt
FROM campus_dynamics_portal.my_aspnet_users
WHERE user_verification_status IS NOT NULL AND user_verification_status <> ''

-- Semester reg count (separate query)
SELECT COUNT(DISTINCT u.name)
FROM campus_dynamics_portal.my_aspnet_users u
INNER JOIN acad_registration reg ON reg.regno = u.name AND reg.acad_year = @ay
WHERE u.user_verification_status IS NOT NULL AND u.user_verification_status <> ''
```

### Files Created/Modified
| File | Project | Lines | Change |
|------|---------|-------|--------|
| `NewScreens/PortalOnboarding.aspx` | Admin | ~190 lines | Full page with summary cards, filters, data table, pagination |
| `NewScreens/PortalOnboarding.aspx.cs` | Admin | ~313 lines | Simple portal-centric queries, no subqueries |

---

## 11. PortalHelper Shared Library

### Purpose
Centralized helper class used by all portal onboarding pages. Handles enrollment gates, verification status, email verification, OTP management, and session checks.

### File
`CampusDynamics_Portal/App_Code/Portal/PortalHelper.cs` (~667 lines)

### Public Methods

| Method | Return | Purpose |
|--------|--------|---------|
| `EnforceEnrollmentGate(Page)` | `bool` | Called from `Global.asax` — redirects unverified users to appropriate step |
| `IsStaffUser(Page, regno)` | `bool` | Checks if user is staff (session + DB lookup) |
| `GetVerificationStatus(regno)` | `string` | Gets `user_verification_status` from `my_aspnet_users` |
| `SetVerificationStatus(regno, status)` | `bool` | Sets `user_verification_status` (ACTIVE STUDENT / ALUMNI) |
| `HasVerifiedEmail(regno)` | `bool` | Checks if `verified_email` is non-empty |
| `GetVerifiedEmail(regno)` | `string` | Gets the verified email address |
| `SaveVerifiedEmail(regno, email)` | `bool` | Saves verified email to `my_aspnet_users` |
| `IsEmailTakenByAnother(email, excludeRegno)` | `bool` | Checks email uniqueness |
| `GetLastOtpEmail(regno)` | `string` | Gets last email used for OTP request |
| `GenerateAndStoreOtp(regno, email)` | `string` | Generates 6-digit OTP, stores in `portal_otp_codes` |
| `VerifyOtp(regno, email, otp)` | `bool` | Validates OTP (10-minute expiry) |
| `HasCurrentSemesterRegistration(regno)` | `bool` | Checks `acad_registration` for current academic year |
| `HasCompletedNewRegistration(regno)` | `bool` | Checks `conducted_new_registration = 'Yes'` |
| `MarkNewRegistrationComplete(regno)` | `bool` | Sets `conducted_new_registration = 'Yes'` |
| `GetCurrentAcadYear()` | `string` | Gets current academic year from `acad_acadyears` |
| `GetStudentName(regno)` | `string` | Gets `firstname + othername` from `acad_student` |
| `SendOtpEmail(email, name, otp)` | `bool` | Sends OTP via external API |
| `GetRegno(Page)` | `string` | Gets regno from session |
| `GetScreenName(Page)` | `string` | Gets display name from session |
| `EnsureVerificationColumns()` | `void` | Auto-creates `user_verification_status`, `verified_email` columns |
| `EnsureOtpTable()` | `void` | Auto-creates `portal_otp_codes` table |

### Connection Strings (Portal web.config — Names are SWAPPED!)
```
vacConnectionString           → campus_dynamics_portal  (portal DB)
campus_dynamics_portalConnectionString → campus_dynamics         (academic DB)
```

### Exempt Pages (skip enrollment gate)
```
EnrollmentVerification.aspx, AlumniRedirect.aspx, RegistrationWizard.aspx,
EmailVerification.aspx, Default.aspx, MultiLogin.aspx, ErrorPage.aspx,
lg.ascx, lg_modern.ascx, Security/PasswordChange.aspx
```

---

## 12. Compilation & Namespace Fixes

### Problem
Several compilation errors were preventing the portal from building/running:
1. Namespace conflicts between portal and admin `App_Code` classes.
2. C# 6+ syntax used in a C# 5 (.NET 4.0) project.

### Solution
- Fixed namespace declarations to avoid conflicts.
- Replaced C# 6+ features (string interpolation, null-conditional operators, expression-bodied members) with C# 5 equivalents:

```csharp
// C# 6 (WRONG for .NET 4.0):
public string Name => _name;
var x = obj?.Property;
var msg = $"Hello {name}";

// C# 5 (CORRECT):
public string Name { get { return _name; } }
var x = (obj != null) ? obj.Property : null;
var msg = "Hello " + name;
```

---

## Complete Portal Onboarding Flow

The student portal onboarding flow works as follows:

```
Student logs in (lg_modern.ascx)
        │
        ▼
  ┌─────────────────┐
  │ Staff user?      │──Yes──► MyApplications_Modern.aspx (skip all gates)
  └────────┬────────┘
           │ No
           ▼
  ┌─────────────────┐
  │ Verified on      │──No──► EnrollmentVerification.aspx
  │ portal?          │        (Choose: Active Student / Alumni)
  └────────┬────────┘
           │ Yes
           ▼
  ┌─────────────────┐
  │ Is Alumni?       │──Yes──► AlumniRedirect.aspx
  └────────┬────────┘
           │ No (Active Student)
           ▼
  ┌─────────────────┐
  │ Email verified?  │──No──► EmailVerification.aspx
  └────────┬────────┘        (OTP sent to MRU email)
           │ Yes
           ▼
  ┌─────────────────┐
  │ Semester         │──No──► RegistrationWizard.aspx
  │ registered?      │        (Step 1: Confirm details, Step 2: Submit)
  └────────┬────────┘
           │ Yes
           ▼
  ┌─────────────────┐
  │ Course           │──No──► CourseRegistration.aspx
  │ registration?    │        (Select courses for semester)
  └────────┬────────┘
           │ Yes
           ▼
      dashboard.aspx
      (Normal portal access)
```

### Admin Monitoring
Admins can view onboarding progress at:
```
eadmin.mru.ac.ug/COOPERP/NewScreens/PortalOnboarding.aspx
```

Shows all students who have verified on the portal with their:
- Verification status (Active Student / Alumni)
- Email verification status
- Semester registration status
- Last portal activity date

---

## Database Schema Changes

### New Columns (auto-created by PortalHelper)
| Table | Column | Type | Purpose |
|-------|--------|------|---------|
| `my_aspnet_users` | `user_verification_status` | VARCHAR | 'ACTIVE STUDENT' or 'ALUMNI' |
| `my_aspnet_users` | `verified_email` | VARCHAR | Student's verified email address |

### New Table (auto-created by PortalHelper)
| Table | Database | Columns | Purpose |
|-------|----------|---------|---------|
| `portal_otp_codes` | campus_dynamics_portal | `id, regno, email, otp_code, created_at, expires_at, used` | OTP storage for email verification |

---

## File Inventory (All Created/Modified Files)

### Portal Project (`CampusDynamics_Portal/`)

| File | Status | Purpose |
|------|--------|---------|
| `COOPERP/fonts/lg_modern.ascx.cs` | Modified | Dual-provider login, alias resolution, session timeout |
| `App_Code/Portal/PortalHelper.cs` | Created | Centralized portal helper (667 lines) |
| `EnrollmentVerification.aspx` | Modified | Fixed CSS layout, UTF-8 encoding |
| `EnrollmentVerification.aspx.cs` | Modified | Staff check, cleaned lifecycle |
| `EmailVerification.aspx` | Created | OTP email verification wizard |
| `EmailVerification.aspx.cs` | Created | OTP send/verify logic |
| `RegistrationWizard.aspx` | Modified | UI updates, year display |
| `RegistrationWizard.aspx.cs` | Modified | Fixed DB connection, upsert, course reg check |
| `CourseRegistration.aspx` | Created | Student course registration page |
| `CourseRegistration.aspx.cs` | Created | Course loading, registration via stored proc |

### Admin Project (`COOPERP/NewScreens/`)

| File | Status | Purpose |
|------|--------|---------|
| `PortalOnboarding.aspx` | Created | Admin page showing verified portal students |
| `PortalOnboarding.aspx.cs` | Created | Simple portal-centric queries |

---

*Last updated: 2026-03-26*
