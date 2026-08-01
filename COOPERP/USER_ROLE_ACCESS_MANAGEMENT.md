# User Role & Access Management — CampusDynamics eAdmin (Classic)

> **Scope:** The main admin/staff system at `CampusDynamics/COOPERP/`  
> **Auth stack:** ASP.NET 4.0 Forms Authentication + MySQL Membership/Role Provider  
> **Last documented:** 2026-05-22

---

## 1. Authentication Flow

### How a user logs in

The login entry point is `COOPERP/fonts/lg.ascx` (classic) or `lg_modern.ascx` (modern UI).

```
User types → username OR email OR staff number (EMP_CODE)
                         │
                         ▼
            ResolveToMembershipUsername(input)
            ┌─────────────────────────────────────────────┐
            │ 1. Membership.GetUser(input)  ← direct name │
            │ 2. Membership.GetUserNameByEmail(input)      │
            │ 3. hrm_employee WHERE EMP_CODE=@v            │
            │    OR LOWER(emp_email)=LOWER(@v)             │
            │    → read usernames / emp_email field        │
            │    → re-check membership with those values   │
            └─────────────────────────────────────────────┘
                         │
                         ▼
            Membership.ValidateUser(resolved, password)
                         │ success
                         ▼
            FormsAuthentication.SetAuthCookie(username, persistent:true)
            Session["username"] = resolved_username
            Session["usernm"]   = username + password  ← cache key
            Cache[key]          = Session.SessionID    ← multi-login guard
                         │
                         ▼
            Response.Redirect("~/MyApplications.aspx")
```

### What is NOT set at admin login

| Session Key | Set in admin login? | Where it is set |
|---|---|---|
| `Session["username"]` | ✅ Yes | `Login1_LoggedIn` / `Login1_LoggingIn` |
| `Session["usernm"]` | ✅ Yes | Same |
| `Session["ScreenName"]` | ❌ No | Portal login only |
| `Session["usertype"]` | ❌ No | Portal login only |
| `Session["regno"]` | ❌ No | Portal login only |

> **Critical gap:** `Session["usertype"]` — used by the sidebar role filter — is **never populated** during admin login. See §6 for the implications.

---

## 2. Session Variables Reference

| Key | Type | Purpose | Set by |
|---|---|---|---|
| `Session["username"]` | string | Authenticated membership username | Login |
| `Session["usernm"]` | string | Cache key (`user+pass`) for multi-login detection | Login |
| `Session["ScreenName"]` | string | Display name used in audit trails | Portal login / manual pages |
| `Session["usertype"]` | string | Role type string powering sidebar filter | Portal login only |
| `Session["SelectedAcademicYear"]` | string | Current academic year context (e.g. `2025/2026`) | Sidebar dropdown |
| `Session["SelectedSemester"]` | string | `"1"`, `"2"`, or `"3"` | Sidebar dropdown |
| `Session["SelectedCampus"]` | string | Campus ID | Sidebar dropdown |
| `Session["campusno"]` | string | Alias of `SelectedCampus` (legacy compat) | Sidebar dropdown |
| `Session["otp"]` | string | One-time password (cleared at login) | Login |
| `Session["JournalType"]` | string | Finance module context | Finance pages |
| `Session["jno"]` | string | Finance journal number context | Finance pages |

---

## 3. The Two-Layer Role System

The admin system has **two separate role mechanisms** that are only partially connected.

### Layer 1 — ASP.NET Role Provider (server-side authorization)

Roles are stored in MySQL using the MySQL Membership/Role provider:

**Tables:**
- `aspnet_Users` — membership user accounts
- `aspnet_Roles` — role definitions
- `aspnet_UsersInRoles` — many-to-many user↔role mapping

**Provider config (`web.config`):**
```xml
<roleManager enabled="true" defaultProvider="MySQLRoleProvider">
  <providers>
    <add name="MySQLRoleProvider"
         type="MySql.Web.Security.MySQLRoleProvider, MySql.Web"
         connectionStringName="LocalMySqlServer"
         autogenerateschema="True" />
  </providers>
</roleManager>
```

**Role names used in code (PascalCase):**

| Code Role Name | Used in |
|---|---|
| `Administrator` | `FinanceSystemRealignmentHelper`, `User.IsInRole()` checks |
| `SuperAdmin` | `FinanceSystemRealignmentHelper` |
| `FinanceAdmin` | `FinanceSystemRealignmentHelper` |
| `Bursar` | `FinanceSystemRealignmentHelper` |
| `Accountant` | `FinanceSystemRealignmentHelper` |
| `Dean` | Various `User.IsInRole("Dean")` checks |
| `Lecturer` | `User.IsInRole("Lecturer")` checks |

**How it's checked (page-level):**
```csharp
// Pattern 1: Direct check
if (HttpContext.Current.User.IsInRole("Dean")) { ... }

// Pattern 2: Finance helper (in FinanceSystemRealignmentHelper.cs)
private static readonly string[] AllowedRoles = new[]
    { "Administrator", "FinanceAdmin", "Bursar", "Accountant", "SuperAdmin" };

public static bool EnsureFinanceAdminAccess(Page page, Label messageLabel)
{
    if (page.User == null || !page.User.Identity.IsAuthenticated)
    { page.Response.Redirect("~/Default.aspx", true); return false; }

    foreach (string role in AllowedRoles)
        if (page.User.IsInRole(role)) return true;

    // 403 — show message, return false
    return false;
}
```

---

### Layer 2 — Sidebar `data-roles` Filtering (client-side UI only)

Every `<li>` in `SidebarMaster.master` carries a `data-roles` attribute listing which roles can see it.

**Source of the role value (line 1210 of SidebarMaster.master):**
```html
<input type="hidden" id="cdUserRole"
       value="<%= (Session["usertype"] ?? "").ToString().ToLower() %>" />
```

**JavaScript filter (`filterMenuByRole()`):**
```javascript
function filterMenuByRole() {
    var userRole = document.getElementById('cdUserRole').value.trim().toLowerCase();
    if (!userRole) return;   // ← early exit if empty — shows ALL items

    // Normalize role name: lowercase + underscores
    // Role aliases handled:
    //   "administrator" ↔ "admin"
    //   "finance_officer" ↔ "accountant"  (finance_officer can also see accountant items)
    //   "bursar" → also gets "finance_officer", "accountant", "admin"
    //   "hr" / "hr_manager" / "human_resource" / "human_resources" → all equivalent

    // For each [data-roles] element:
    //   if role not in allowed list → element.style.display = 'none'
}
```

**Role codes used in `data-roles` (lowercase, underscored):**

| Sidebar Role Code | Meaning |
|---|---|
| `all` | Visible to every authenticated user (never filtered) |
| `admin` | System administrator |
| `dean` | Faculty dean |
| `registrar` | Student registrar |
| `faculty_staff` | Teaching/academic staff |
| `exam_officer` | Examination officer |
| `admissions` | Admissions processor |
| `student_services` | Student services staff |
| `fees_officer` | Fee administration |
| `bursar` | Bursary/finance head |
| `finance_officer` | Finance officer |
| `accountant` | Accountant |
| `hr_manager` | HR manager |
| `procurement` | Procurement officer |
| `vc` | Vice-Chancellor |
| `finance` | Generic finance (alias of `finance_officer`) |

---

## 4. Full Sidebar Role Map

Every section and item with its required roles:

```
HOME
  ├── Dashboard                          [all]

ACADEMICS
  ├── Heading                            [dean, registrar, faculty_staff, admin]
  ├── Students
  │   ├── Parent item                    [registrar, admissions, student_services, admin]
  │   ├── Online Applications            [admin, admissions, registrar]
  │   └── Semester Deletion Requests     [admin, registrar]
  ├── Programmes & Courses               [dean, registrar, admin]
  │   ├── Unlocated Programme Courses    [admin]
  │   ├── Allocated Programme Courses    [admin]
  │   ├── Requested Programme Courses    [admin]
  │   ├── Academic Committee Report      [admin]  (shown: [dean, registrar, admin])
  │   └── Academic Committee Report      [dean, registrar, admin]
  ├── Exam Administration                [exam_officer, registrar, faculty_staff, admin]
  │   ├── Marks Dashboard                [admin]
  │   ├── Marks Requests                 [admin]
  │   ├── Marks Controller               [admin]
  │   ├── Results Release                [admin]
  │   ├── Hold List                      [admin]
  │   ├── Audit Log                      [admin]
  │   └── Analytics                     [admin]
  ├── Allocation Management              [dean, registrar, faculty_staff, admin]
  ├── Timetable                          [dean, registrar, faculty_staff, admin]
  └── Settings (Lecture Rooms)           [dean, registrar, admin]

SCHOOL FEES
  ├── Heading                            [fees_officer, bursar, admin]
  ├── Fee Administration                 [fees_officer, bursar, admin]
  └── Bursaries & Scholarships           [bursar, admin]

EXPENDITURE & ACCOUNTS
  ├── Heading                            [finance_officer, accountant, admin]
  ├── Accounts & Ledgers                 [finance_officer, accountant, admin]
  ├── Expenditure Transactions           [finance_officer, accountant, admin]
  ├── Periods & Control                  [finance_officer, accountant, admin]
  └── Financial Reports                  [finance_officer, accountant, admin]

HUMAN RESOURCE
  ├── Heading                            [hr_manager, admin]
  ├── HR Dashboard                       [hr_manager, admin]
  ├── People & Contracts                 [hr_manager, admin]
  ├── Payroll                            [hr_manager, admin]
  ├── HR Settings                        [hr_manager, admin]
  └── Performance Appraisal             [hr_manager, admin]

REQUISITIONS
  ├── Heading                            [bursar, finance, procurement, vc, admin]
  └── All requisition items              [bursar, finance, procurement, vc, admin]

COMMUNICATIONS
  ├── Heading                            [dean, registrar, faculty_staff, admin]
  ├── Notices / Announcements            [dean, registrar, faculty_staff, admin]
  └── Support Tickets                    [admin, registrar, student_services]

SYSTEM
  ├── Heading                            [admin]
  └── All system config items            [admin]

MORE FEATURES
  ├── Knowledge Base                     [exam_officer, registrar, dean, faculty_staff,
  │                                       admissions, student_services, admin]
  └── Elections                          [registrar, admin, student_services]
      ├── Manage Elections               [registrar, admin, student_services]
      ├── Posts                          [registrar, admin, student_services]
      ├── Candidates                     [registrar, admin, student_services]
      ├── Voters                         [registrar, admin, student_services]
      └── Results                        [registrar, admin, student_services]
```

---

## 5. Role Alias Mapping (JavaScript)

The sidebar JS normalizes role names before comparing, and expands aliases:

| `Session["usertype"]` value | Effective data-roles it can match |
|---|---|
| `administrator` or `admin` | `admin`, `administrator` — and `all` always |
| `bursar` | `bursar`, `finance_officer`, `accountant`, `admin` |
| `finance_officer` or `finance` | `finance_officer`, `accountant` |
| `accountant` | `accountant`, `finance_officer` |
| `hr` or `hr_manager` or `human_resource` or `human_resources` | `hr_manager`, `hr` |
| anything else | exact match only (e.g. `dean` matches `dean`, `registrar` matches `registrar`) |

---

## 6. Critical Implementation Gap

### Problem: `Session["usertype"]` is never set in admin login

The sidebar's role filter reads from `Session["usertype"]`. The admin login (`lg.ascx.cs`) **does not set** this variable. The Portal login (`lg_modern.ascx.cs`) sets it to `"STAFF"` / `"STUDENT"` / `"LECTURER"`, which are portal-type values, not admin role codes.

**Result:** In the admin system, `cdUserRole` hidden field is always `""`. The `filterMenuByRole()` function exits immediately (`if (!userRole) return`), and **every user sees every sidebar menu item regardless of their actual role.**

### The mismatch between the two role systems

| | Layer 1 (ASP.NET Roles) | Layer 2 (Sidebar `data-roles`) |
|---|---|---|
| Role storage | `aspnet_Roles` / `aspnet_UsersInRoles` | `data-roles` attribute in markup |
| Role names | PascalCase: `Administrator`, `Bursar`, `Dean` | Lowercase/underscored: `admin`, `bursar`, `dean` |
| Enforcement | Server-side, `User.IsInRole()` — **real protection** | Client-side JS hide/show — **UI only, no security** |
| Currently working? | ✅ Yes | ❌ No (Session["usertype"] always empty in admin) |

### How to fix

To make the sidebar role filter work, populate `Session["usertype"]` at admin login with the user's ASP.NET role:

```csharp
// In Login1_LoggedIn / Login1_LoggingIn (lg.ascx.cs)
// After Membership.ValidateUser succeeds:

string[] roles = Roles.GetRolesForUser(resolved_username);
if (roles.Length > 0)
{
    // Map ASP.NET role name → sidebar role code
    Session["usertype"] = MapRoleToSidebarCode(roles[0]);
    Session["ScreenName"] = resolved_username; // or load from hrm_employee.emp_name
}

private string MapRoleToSidebarCode(string aspNetRole)
{
    switch (aspNetRole.ToLower())
    {
        case "administrator": case "superadmin": return "admin";
        case "dean":          return "dean";
        case "bursar":        return "bursar";
        case "financeadmin":  case "accountant": return "finance_officer";
        case "lecturer":      return "faculty_staff";
        default:              return aspNetRole.ToLower().Replace(" ", "_");
    }
}
```

---

## 7. Authentication Configuration (`web.config`)

```xml
<!-- Forms auth: 2-year sliding cookie -->
<authentication mode="Forms">
  <forms loginUrl="~/Default.aspx"
         timeout="1051200"
         slidingExpiration="true"
         protection="All" />
</authentication>

<!-- MySQL Membership: password hashed, min length 1 -->
<membership defaultProvider="MySQLMembershipProvider">
  <providers>
    <add name="MySQLMembershipProvider"
         type="MySql.Web.Security.MySQLMembershipProvider, MySql.Web"
         connectionStringName="LocalMySqlServer"
         enablePasswordRetrieval="False"
         enablePasswordReset="True"
         requiresUniqueEmail="False"
         passwordFormat="Hashed"
         maxInvalidPasswordAttempts="5"
         minRequiredPasswordLength="1" />
  </providers>
</membership>

<!-- MySQL Role Provider -->
<roleManager enabled="true" defaultProvider="MySQLRoleProvider">
  <providers>
    <add name="MySQLRoleProvider"
         type="MySql.Web.Security.MySQLRoleProvider, MySql.Web"
         connectionStringName="LocalMySqlServer"
         autogenerateschema="True" />
  </providers>
</roleManager>

<!-- InProc session: 1-year timeout -->
<sessionState mode="InProc" timeout="525600" cookieless="false" />
```

---

## 8. Database Tables for Users & Roles

**Connection string:** `LocalMySqlServer` = `vacConnectionString` → database `campus_dynamics`

| Table | Purpose | Key Columns |
|---|---|---|
| `aspnet_Users` | Membership accounts | `UserId`, `UserName`, `LoweredUserName`, `IsAnonymous`, `LastActivityDate` |
| `aspnet_Membership` | Password & lockout data | `UserId`, `Password`, `PasswordFormat`, `IsLockedOut`, `FailedPasswordAttemptCount` |
| `aspnet_Roles` | Role definitions | `RoleId`, `RoleName`, `LoweredRoleName` |
| `aspnet_UsersInRoles` | User↔Role mapping | `UserId`, `RoleId` |
| `hrm_employee` | Staff directory (used for login resolution) | `empID`, `emp_name`, `EMP_CODE`, `usernames`, `emp_email`, `EmpType` |

---

## 9. How to Assign a Role to a User

Roles are assigned through the **ASP.NET Role Provider API** or directly in the database.

### Via code:
```csharp
Roles.AddUserToRole("john.doe", "Dean");
Roles.RemoveUserFromRole("john.doe", "Dean");
string[] userRoles = Roles.GetRolesForUser("john.doe");
```

### Via direct SQL (campus_dynamics database):
```sql
-- Find user ID
SELECT UserId FROM aspnet_Users WHERE LoweredUserName = 'john.doe';

-- Find role ID
SELECT RoleId FROM aspnet_Roles WHERE LoweredRoleName = 'dean';

-- Assign role
INSERT INTO aspnet_UsersInRoles (UserId, RoleId) VALUES (@userId, @roleId);

-- Remove role
DELETE FROM aspnet_UsersInRoles WHERE UserId = @userId AND RoleId = @roleId;

-- List all users with their roles
SELECT u.UserName, r.RoleName
FROM aspnet_Users u
JOIN aspnet_UsersInRoles ur ON u.UserId = ur.UserId
JOIN aspnet_Roles r ON ur.RoleId = r.RoleId
ORDER BY u.UserName;
```

---

## 10. Complete Role Reference Card

### Sidebar `data-roles` codes → Modules accessible

| Role Code | Modules Visible |
|---|---|
| `admin` | Everything |
| `dean` | Academics, Allocation, Timetable, Communications, Knowledge Base |
| `registrar` | Academics, Students, Programmes, Allocation, Timetable, Settings, Communications, Tickets, Elections, Knowledge Base |
| `faculty_staff` | Academics, Allocation, Timetable, Communications, Knowledge Base |
| `exam_officer` | Exam Administration, Knowledge Base |
| `admissions` | Students (Online Applications), Knowledge Base |
| `student_services` | Students, Tickets, Elections, Knowledge Base |
| `fees_officer` | School Fees |
| `bursar` | School Fees, Bursaries, Expenditure & Accounts, Requisitions |
| `finance_officer` | Expenditure & Accounts |
| `accountant` | Expenditure & Accounts |
| `hr_manager` | Human Resource (all sub-modules) |
| `procurement` | Requisitions |
| `vc` | Requisitions |
| `finance` | Expenditure & Accounts (alias of `finance_officer`) |

### ASP.NET Role names → Finance page access (FinanceSystemRealignmentHelper)

| ASP.NET Role | Finance Admin Access |
|---|---|
| `Administrator` | ✅ |
| `SuperAdmin` | ✅ |
| `FinanceAdmin` | ✅ |
| `Bursar` | ✅ |
| `Accountant` | ✅ |
| `Dean` | ❌ |
| `Lecturer` | ❌ |

---

## 11. SidebarMaster.master.cs — What it does NOT do

The master page code-behind (`SidebarMaster.master.cs`) performs **no role checking at all**. It only:

1. Checks `Session["username"] != null` — redirects to `Default.aspx` if not logged in
2. Calls `SetPageTitle()` — maps URL page name to a human-readable title
3. `LoadAcademicYears()` — populates year dropdown from `acad_acadyears`
4. `LoadSemesters()` — populates semester dropdown (1, 2, 3)
5. `LoadCampuses()` — populates campus dropdown from `acad_campuses`
6. Saves dropdown selections to `Session["SelectedAcademicYear"]`, `Session["SelectedSemester"]`, `Session["SelectedCampus"]`

**No** server-side role-based menu suppression. All role gating in the sidebar is client-side JavaScript (and currently non-functional — see §6).

---

## 12. Multi-Login Prevention (Cache Guard)

```
Login success
│
├── Cache[username+password] = Session.SessionID
│   (never expires, NotRemovable priority)
│
└── Session["usernm"] = username+password

On subsequent page loads:
  key = Session["usernm"]
  cachedId = Cache[key]
  if (cachedId != Session.SessionID)
      → Another device logged in with same credentials
      → Force logout / show message
```

This prevents the same account from being used concurrently on multiple devices.

---

## 13. Known Issues & Recommendations

| Issue | Impact | Recommended Fix |
|---|---|---|
| `Session["usertype"]` not set at admin login | Sidebar shows ALL modules to ALL users — no UI role filtering | Set `Session["usertype"]` after login using `Roles.GetRolesForUser()` mapped to sidebar code |
| `Session["ScreenName"]` not set at admin login | Audit trails in finance/HR/appraisal log empty or username instead of display name | Load `emp_name` from `hrm_employee` at login, store in `Session["ScreenName"]` |
| ASP.NET role names (PascalCase) vs sidebar codes (snake_case) mismatch | No automatic connection between the two systems | Build `MapRoleToSidebarCode()` converter (see §6) |
| No admin UI for role management | Roles must be assigned by direct SQL or code | Build a User Management screen under System menu using `Roles.AddUserToRole()` / `Roles.GetRolesForUser()` |
| Sidebar filtering is client-side only | Hiding menu items doesn't protect pages — a user can navigate directly to any URL | Add server-side role check in `Page_Load` of sensitive pages (`if (!User.IsInRole("Dean")) { Response.Redirect... }`) |

---

---

# PART II — Architectural Improvement Plan
## Dynamic Role & Access Management System

> **Goal:** Replace the current static, hardcoded, client-side-only role system with a fully dynamic, database-driven, server-enforced permission engine that a Super Admin can manage through a dedicated UI without touching code.

---

## 14. Vision: What the New System Achieves

| Capability | Current State | Target State |
|---|---|---|
| Menu item access rules | Hardcoded in HTML `data-roles` attributes | Stored in DB, editable through admin UI |
| Role assignment | Direct SQL or `Roles.AddUserToRole()` in code | Admin UI with search, assign, revoke, expiry |
| Access enforcement | Client-side JS hide/show only | Server-side check on every page load |
| Menu item identity | No identity — items have no slug/key | Every item has a unique slug registered in DB |
| New role creation | Requires developer | Super Admin creates roles in UI, maps to slugs |
| Section-level control | Not possible | Entire sections can be shown/hidden per role |
| Audit trail | None for role changes | Every grant/revoke logged with actor + timestamp |
| Super Admin | No dedicated module | Full module: Users, Roles, Permissions matrix, Audit |

---

## 15. Menu Slug Registry — Giving Every Item an Identity

### The concept

Every sidebar menu item — headings, parent items, subitems — gets a **permanent unique slug**. A slug never changes once assigned. Roles are then granted access to a list of slugs.

### Slug naming convention

```
{section}.{module}.{page}

Examples:
  academics                          ← section heading
  academics.students                 ← parent menu item
  academics.students.online_apps     ← subitem / leaf page
  academics.students.deletions       ← subitem
  academics.programmes               ← parent menu item
  academics.exam                     ← parent
  academics.exam.marks_dashboard     ← subitem
  fees                               ← section heading
  fees.fee_admin                     ← parent
  fees.fee_admin.structure           ← subitem
  fees.fee_admin.registration        ← subitem
  fees.bursaries                     ← parent
  finance                            ← section heading
  finance.accounts                   ← parent
  finance.accounts.chart             ← subitem
  finance.accounts.general_ledger    ← subitem
  hr                                 ← section heading
  hr.employees                       ← parent
  hr.payroll                         ← parent
  hr.appraisal                       ← parent
  requisitions                       ← section heading
  requisitions.dashboard             ← subitem
  requisitions.bursar                ← subitem
  requisitions.finance               ← subitem
  communications                     ← section heading
  communications.notices             ← parent
  communications.tickets             ← subitem
  system                             ← section heading
  system.user_roles                  ← parent  ← NEW Super Admin module
  system.user_roles.users            ← subitem
  system.user_roles.roles            ← subitem
  system.user_roles.permissions      ← subitem
  system.user_roles.audit            ← subitem
  system.academic_years              ← subitem
  more.elections                     ← parent
  more.knowledgebase                 ← parent
```

### Rules
- Slugs are **immutable** once published — rename the label in DB but never the slug
- A **section heading** slug controls visibility of the entire section block
- A **parent item** slug controls the toggle row (chevron item)
- A **subitem** slug controls a single leaf link
- Granting a subitem slug without its parent slug → parent is auto-shown (controlled by DB query)

---

## 16. Database Schema — Dynamic Permission Engine

```sql
-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE 1: Menu item registry — every slug in the system
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sys_menu_items (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug          VARCHAR(120) NOT NULL UNIQUE,          -- e.g. academics.students.online_apps
    label         VARCHAR(120) NOT NULL,                  -- display name
    section       VARCHAR(60)  NOT NULL,                  -- top-level section: academics, fees, finance...
    parent_slug   VARCHAR(120) DEFAULT NULL,              -- NULL = section heading or top-level item
    item_type     ENUM('heading','parent','subitem') NOT NULL DEFAULT 'subitem',
    url           VARCHAR(300) DEFAULT NULL,              -- relative URL for leaf items
    icon_svg      TEXT         DEFAULT NULL,              -- inline SVG for the item
    sort_order    SMALLINT     NOT NULL DEFAULT 100,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT NOW(),
    INDEX idx_section (section),
    INDEX idx_parent  (parent_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE 2: Roles — replaces/extends aspnet_Roles
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sys_roles (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_code       VARCHAR(60)  NOT NULL UNIQUE,   -- sidebar code: admin, dean, bursar...
    role_name       VARCHAR(120) NOT NULL,           -- display: "System Administrator"
    description     TEXT         DEFAULT NULL,
    color_hex       VARCHAR(7)   DEFAULT '#64748b',  -- badge color in UI
    is_system_role  TINYINT(1)   NOT NULL DEFAULT 0, -- 1 = cannot be deleted
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_by      VARCHAR(100) DEFAULT NULL,
    created_at      DATETIME     NOT NULL DEFAULT NOW(),
    updated_at      DATETIME     DEFAULT NULL ON UPDATE NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE 3: Role ↔ Menu slug permissions
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sys_role_permissions (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id     INT UNSIGNED NOT NULL,
    menu_slug   VARCHAR(120) NOT NULL,
    can_view    TINYINT(1)   NOT NULL DEFAULT 1,
    can_edit    TINYINT(1)   NOT NULL DEFAULT 0,   -- future: page-level write access
    can_delete  TINYINT(1)   NOT NULL DEFAULT 0,   -- future: destructive action access
    granted_by  VARCHAR(100) NOT NULL,
    granted_at  DATETIME     NOT NULL DEFAULT NOW(),
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_role_slug (role_id, menu_slug),
    INDEX idx_slug (menu_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE 4: User ↔ Role assignments (custom, replaces aspnet_UsersInRoles)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sys_user_roles (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(100) NOT NULL,              -- membership username
    emp_id      INT          DEFAULT NULL,          -- FK to hrm_employee.empID (optional)
    role_id     INT UNSIGNED NOT NULL,
    granted_by  VARCHAR(100) NOT NULL,
    granted_at  DATETIME     NOT NULL DEFAULT NOW(),
    expires_at  DATETIME     DEFAULT NULL,          -- NULL = permanent
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    notes       VARCHAR(300) DEFAULT NULL,
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_role (username, role_id),
    INDEX idx_username (username),
    INDEX idx_emp     (emp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE 5: Audit log for all role management actions
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sys_role_audit (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('ROLE_CREATED','ROLE_UPDATED','ROLE_DELETED',
                     'PERMISSION_GRANTED','PERMISSION_REVOKED',
                     'USER_ROLE_ASSIGNED','USER_ROLE_REVOKED',
                     'USER_ROLE_EXPIRED') NOT NULL,
    target_type ENUM('role','permission','user_role') NOT NULL,
    target_id   VARCHAR(200) NOT NULL,              -- role_code, slug, or username
    detail      TEXT         DEFAULT NULL,          -- JSON snapshot of what changed
    actor       VARCHAR(100) NOT NULL,              -- who performed the action
    ip_address  VARCHAR(45)  DEFAULT NULL,
    created_at  DATETIME     NOT NULL DEFAULT NOW(),
    INDEX idx_actor  (actor),
    INDEX idx_type   (action_type),
    INDEX idx_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE 6: Section visibility overrides per role
-- Controls whether an entire section (heading) is collapsed or expanded by default
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sys_role_section_settings (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id         INT UNSIGNED NOT NULL,
    section_slug    VARCHAR(60)  NOT NULL,           -- matches sys_menu_items.section
    default_open    TINYINT(1)   NOT NULL DEFAULT 0, -- 1 = section auto-expanded on load
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_role_section (role_id, section_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 17. How Slug-Based Access Works End-to-End

```
User logs in
     │
     ▼
Login sets Session["username"] = "john.doe"
     │
     ▼
RoleAccessService.LoadUserAccess("john.doe")
     │
     ├── Query sys_user_roles WHERE username = 'john.doe'
     │   AND (expires_at IS NULL OR expires_at > NOW()) AND is_active = 1
     │
     ├── For each role_id → load sys_role_permissions slugs (can_view = 1)
     │
     ├── Union all slugs from all the user's roles
     │
     └── Store in Session["access_slugs"] = "academics,academics.students,
                                              academics.students.online_apps,
                                              fees,fees.fee_admin, ..."

SidebarMaster.master Page_Load
     │
     ├── Read Session["access_slugs"] → HashSet<string>
     │
     └── Render sidebar: for each <li> check its slug against the set
         → slug in set? render it  : skip it  (SERVER-SIDE, not JS)

Individual page Page_Load
     │
     └── RoleAccessService.RequireSlug("academics.students.online_apps")
         → slug in Session["access_slugs"]? continue : Response.Redirect("~/403.aspx")
```

---

## 18. RoleAccessService — Core C# Service Class

```csharp
// App_Code/RoleAccessService.cs

public static class RoleAccessService
{
    private const string SESSION_KEY = "access_slugs";
    private const string ROLE_KEY    = "user_role_code";
    private const string SCREEN_KEY  = "ScreenName";

    /// <summary>
    /// Called immediately after successful login.
    /// Loads all accessible slugs and the primary role into session.
    /// </summary>
    public static void LoadUserAccess(string username, HttpSessionState session)
    {
        var slugs    = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        string roleCode  = "";
        string roleName  = "";

        string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();

            // Get all active roles for this user (not expired)
            const string roleSql = @"
                SELECT r.role_code, r.role_name
                FROM sys_user_roles ur
                JOIN sys_roles r ON ur.role_id = r.id
                WHERE ur.username = @u AND ur.is_active = 1
                  AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                ORDER BY r.id ASC";

            var roles = new List<(string code, string name)>();
            using (var cmd = new MySqlCommand(roleSql, conn))
            {
                cmd.Parameters.AddWithValue("@u", username);
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        roles.Add((dr.GetString(0), dr.GetString(1)));
            }

            if (roles.Count == 0) return; // no roles assigned

            // Primary role = first one (lowest ID = highest precedence)
            roleCode = roles[0].code;
            roleName = roles[0].name;

            // Load all slugs from all roles (union)
            const string slugSql = @"
                SELECT DISTINCT rp.menu_slug
                FROM sys_role_permissions rp
                JOIN sys_user_roles ur ON rp.role_id = ur.role_id
                WHERE ur.username = @u AND ur.is_active = 1
                  AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                  AND rp.can_view = 1";

            using (var cmd = new MySqlCommand(slugSql, conn))
            {
                cmd.Parameters.AddWithValue("@u", username);
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read()) slugs.Add(dr.GetString(0));
            }

            // Admin gets everything — bypass slug check
            if (roleCode == "admin")
                slugs.Add("*"); // wildcard — CanAccess() treats this as full access
        }

        session[SESSION_KEY] = string.Join(",", slugs);
        session[ROLE_KEY]    = roleCode;
        session["usertype"]  = roleCode;  // feeds the sidebar hidden input
    }

    /// <summary>True if the current user can view the given slug.</summary>
    public static bool CanAccess(HttpSessionState session, string slug)
    {
        string raw = session[SESSION_KEY] as string ?? "";
        if (raw == "*" || raw.Split(',').Contains("*")) return true; // admin wildcard
        return Array.IndexOf(raw.Split(','), slug.ToLower()) >= 0;
    }

    /// <summary>
    /// Call at the top of any page's Page_Load to enforce access.
    /// Redirects to 403 page if the user lacks the required slug.
    /// </summary>
    public static void RequireSlug(Page page, string slug)
    {
        if (page.Session["username"] == null)
        { page.Response.Redirect("~/Default.aspx"); return; }

        if (!CanAccess(page.Session, slug))
            page.Response.Redirect("~/COOPERP/NewScreens/AccessDenied.aspx?slug=" + slug);
    }

    /// <summary>Get the current user's primary role code.</summary>
    public static string GetRoleCode(HttpSessionState session)
        => (session[ROLE_KEY] as string ?? "").ToLower();

    /// <summary>True if the user holds the super admin role.</summary>
    public static bool IsSuperAdmin(HttpSessionState session)
        => GetRoleCode(session) == "admin";
}
```

**Usage in any page:**
```csharp
// Online Applications page — top of Page_Load:
protected void Page_Load(object sender, EventArgs e)
{
    RoleAccessService.RequireSlug(this, "academics.students.online_apps");
    // ... rest of page logic
}
```

---

## 19. Dynamic Sidebar Rendering

Instead of hardcoded `data-roles`, the SidebarMaster renders items server-side:

```csharp
// In SidebarMaster.master.cs Page_Load, after loading dropdowns:

private void RenderDynamicSidebar()
{
    string username = Session["username"]?.ToString();
    if (string.IsNullOrEmpty(username)) return;

    // Load the menu tree from DB
    var items = LoadMenuTree();

    // Get user's accessible slugs
    string rawSlugs = Session["access_slugs"] as string ?? "";
    bool isAdmin = rawSlugs.Contains("*");
    var slugSet  = new HashSet<string>(rawSlugs.Split(','), StringComparer.OrdinalIgnoreCase);

    // Build sidebar HTML — only include items the user can access
    var sb = new StringBuilder();
    string currentSection = "";

    foreach (var item in items)
    {
        bool canSee = isAdmin || slugSet.Contains(item.Slug);
        if (!canSee) continue;

        if (item.Section != currentSection)
        {
            currentSection = item.Section;
            // render section heading if user has any item in this section
        }

        switch (item.ItemType)
        {
            case "heading": sb.Append(RenderHeading(item)); break;
            case "parent":  sb.Append(RenderParent(item, items, slugSet, isAdmin)); break;
            case "subitem": /* rendered inside parent */ break;
        }
    }

    litSidebarItems.Text = sb.ToString(); // Literal in the master page
}
```

---

## 20. Super Admin — User Role Management Module

### Location in sidebar
```
SYSTEM (section)
  └── User & Role Management
        ├── Users              [system.user_roles.users]
        ├── Roles              [system.user_roles.roles]
        ├── Permission Matrix  [system.user_roles.permissions]
        └── Audit Log          [system.user_roles.audit]
```

**Access:** Only `admin` role (`system.user_roles` slug) — hardcoded server-side guard, not just sidebar filtering.

---

### Page 1: Users (`UserRoleUsers.aspx`)

**What it shows:**
- Search bar — find by name, username, or EMP_CODE
- Grid: Username | Display Name | Primary Role | All Roles | Status | Expires | Actions
- Each row: **Assign Role** button, **Revoke** button, **View Access** link

**Assign Role flow:**
```
Super Admin clicks "Assign Role" on a user row
    → Modal opens: dropdown of all sys_roles
    → Optional: set expiry date
    → Optional: notes
    → Save → INSERT into sys_user_roles
    → LOG to sys_role_audit (action: USER_ROLE_ASSIGNED)
    → RoleAccessService.LoadUserAccess() called for that user next time they load a page
```

**What the grid queries:**
```sql
SELECT
    u.UserName,
    e.emp_name,
    GROUP_CONCAT(r.role_name ORDER BY r.id SEPARATOR ', ') AS roles,
    MAX(ur.expires_at) AS next_expiry,
    MAX(ur.granted_at) AS last_assigned
FROM aspnet_Users u
LEFT JOIN hrm_employee e ON UPPER(TRIM(e.usernames)) = UPPER(u.UserName)
LEFT JOIN sys_user_roles ur ON ur.username = u.UserName AND ur.is_active = 1
LEFT JOIN sys_roles r ON ur.role_id = r.id
GROUP BY u.UserName, e.emp_name
ORDER BY e.emp_name;
```

---

### Page 2: Roles (`UserRoleRoles.aspx`)

**What it shows:**
- Role cards (colored by `color_hex`): Role Name | Code | # Users | # Permissions | System Role badge
- **Create Role** button (for non-system roles)
- **Edit** → change label, description, color
- **Delete** → only allowed if `is_system_role = 0` and 0 users assigned
- **Manage Permissions** → opens Permission Matrix filtered to this role

**Create Role form:**
```
Role Code:    [fees_admin         ]  ← slug-safe, lowercase, underscores
Role Name:    [Fees Administrator ]
Description:  [Manages all fee... ]
Color:        [color picker       ]
```

---

### Page 3: Permission Matrix (`UserRolePermissions.aspx`)

**The centrepiece of the system.** A visual grid:

```
                         [Role: Dean]

SECTION / MENU ITEM                        VIEW   EDIT   DELETE
─────────────────────────────────────────────────────────────────
▶ ACADEMICS (section heading)               ✅     —      —
  ├ Students (parent)                       ✅     —      —
  │  ├ Online Applications (subitem)        ✅     —      —
  │  └ Semester Deletion Requests           ❌     —      —
  ├ Programmes & Courses (parent)           ✅     —      —
  └ Exam Administration (parent)            ✅     —      —
▶ SCHOOL FEES                               ❌     —      —
▶ EXPENDITURE & ACCOUNTS                   ❌     —      —
▶ HUMAN RESOURCE                           ❌     —      —
▶ REQUISITIONS                             ❌     —      —
▶ COMMUNICATIONS                           ✅     —      —
▶ SYSTEM                                   ❌     —      —
```

**How it works:**
- Rows = `sys_menu_items` ordered by `sort_order`, grouped by section
- Columns = `sys_role_permissions` for the selected role
- Toggle a checkbox → `INSERT ... ON DUPLICATE KEY UPDATE can_view = 1` or `DELETE`
- Auto-infers parent: granting a subitem auto-grants its parent heading too
- **Save** → bulk upsert → LOG to `sys_role_audit`

**Filtering:**
- Role selector dropdown at top
- "Compare Roles" toggle: show two role columns side-by-side

---

### Page 4: Audit Log (`UserRoleAudit.aspx`)

**What it shows:**
- Timeline of every role change: Who did what to whom, when
- Filter: by date range, action type, actor, target user
- Export to CSV

```
2026-05-22 09:14  admin_user  → ASSIGNED role [Dean] to [dr.kiggundu]  (expires: never)
2026-05-22 09:15  admin_user  → GRANTED [academics.students.online_apps] to role [Dean]
2026-05-20 14:32  admin_user  → REVOKED role [Bursar] from [j.okello]
```

---

## 21. Section-Level Controls (Accordion Defaults)

Each role can define whether a sidebar section starts **collapsed** or **expanded** by default on page load. This is stored in `sys_role_section_settings`.

```
Role: Registrar — Section defaults:
  ACADEMICS      → default_open = 1  (auto-expanded — their primary work)
  SCHOOL FEES    → default_open = 0  (collapsed)
  COMMUNICATIONS → default_open = 1  (expanded)
  all others     → default_open = 0
```

**How it's applied in sidebar JS:**
```javascript
// After role is loaded, apply section open defaults
var sectionDefaults = JSON.parse(
    document.getElementById('cdSectionDefaults').value || '{}'
);
// e.g. { "academics": true, "communications": true }

document.querySelectorAll('.cd-sidebar__item--has-submenu').forEach(function(item) {
    var section = item.getAttribute('data-section');
    if (section && sectionDefaults[section]) {
        item.classList.add('open');
    }
});
```

**The hidden field is rendered by SidebarMaster:**
```html
<input type="hidden" id="cdSectionDefaults"
       value="<%= GetSectionDefaultsJson() %>" />
```

```csharp
private string GetSectionDefaultsJson()
{
    // Load from sys_role_section_settings for the current user's role
    // Return: {"academics":true,"communications":true}
}
```

---

## 22. Login Update — Wiring Everything Together

The admin login (`lg.ascx.cs`) must be updated to call `RoleAccessService.LoadUserAccess()` after successful authentication:

```csharp
protected void Login1_LoggedIn(object sender, EventArgs e)
{
    string username = Login1.UserName;

    FormsAuthentication.SetAuthCookie(username, true);
    Session["username"] = username;

    // ── NEW: load role + slugs + screen name ──────────────────
    RoleAccessService.LoadUserAccess(username, Session);

    // Load display name from hrm_employee
    string empName = LoadEmployeeName(username);
    if (!string.IsNullOrEmpty(empName))
        Session["ScreenName"] = empName;

    // Multi-login cache guard
    string key = username + Login1.Password;
    HttpContext.Current.Cache.Insert(key, Session.SessionID, null,
        DateTime.MaxValue, TimeSpan.FromDays(365),
        System.Web.Caching.CacheItemPriority.NotRemovable, null);
    Session["usernm"] = key;
}

private string LoadEmployeeName(string username)
{
    string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    using (var conn = new MySqlConnection(connStr))
    {
        conn.Open();
        using (var cmd = new MySqlCommand(
            "SELECT emp_name FROM hrm_employee WHERE UPPER(TRIM(usernames))=UPPER(@u) OR UPPER(TRIM(EMP_CODE))=UPPER(@u) LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@u", username);
            var result = cmd.ExecuteScalar();
            return result != null && result != DBNull.Value ? result.ToString().Trim() : "";
        }
    }
}
```

---

## 23. Migration Strategy — From Static to Dynamic (Step-by-Step)

```
Phase 1 — Schema (Week 1)
  ├── Run CREATE TABLE statements for all 6 new tables
  ├── Seed sys_menu_items with all current sidebar slugs + URLs
  ├── Seed sys_roles with all current role codes + names
  └── Seed sys_role_permissions with current data-roles mappings
      (convert hardcoded data-roles HTML → DB rows)

Phase 2 — Service Layer (Week 1)
  ├── Write App_Code/RoleAccessService.cs
  ├── Update lg.ascx.cs Login1_LoggedIn to call LoadUserAccess()
  └── Update lg_modern.ascx.cs as well

Phase 3 — Sidebar (Week 2)
  ├── Add slug attribute to every <li> in SidebarMaster.master
  ├── Write RenderDynamicSidebar() in SidebarMaster.master.cs
  └── Remove hardcoded data-roles attributes (or keep as fallback)

Phase 4 — Page Guards (Week 2-3)
  └── Add RoleAccessService.RequireSlug(this, "slug") at top of each
      sensitive page's Page_Load

Phase 5 — Admin UI (Week 3-4)
  ├── Build UserRoleUsers.aspx
  ├── Build UserRoleRoles.aspx
  ├── Build UserRolePermissions.aspx (permission matrix)
  └── Build UserRoleAudit.aspx

Phase 6 — Wire Super Admin only (deploy-time)
  └── Set sys_user_roles for the admin account manually in DB
      (first user must be seeded directly; thereafter use UI)
```

---

## 24. Seed SQL — Bootstrapping the System

```sql
-- ── Seed roles ────────────────────────────────────────────────────────────
INSERT INTO sys_roles (role_code, role_name, description, color_hex, is_system_role) VALUES
('admin',           'System Administrator',     'Full unrestricted access',            '#05275C', 1),
('dean',            'Dean',                     'Faculty academic oversight',           '#7c3aed', 1),
('registrar',       'Registrar',                'Student registration & records',       '#174DA4', 1),
('faculty_staff',   'Faculty Staff',            'Teaching and academic staff',          '#0369a1', 1),
('exam_officer',    'Examination Officer',      'Exam administration & results',        '#d97706', 1),
('admissions',      'Admissions Officer',       'Applications processing',              '#16a34a', 1),
('student_services','Student Services',         'Student support staff',                '#059669', 1),
('fees_officer',    'Fees Officer',             'Fee administration',                   '#ca8a04', 1),
('bursar',          'Bursar',                   'Bursary management & routing',         '#b45309', 1),
('finance_officer', 'Finance Officer',          'Finance operations & accounts',        '#0891b2', 1),
('accountant',      'Accountant',               'Accounting & ledger operations',       '#0e7490', 1),
('hr_manager',      'HR Manager',               'Human resources & payroll',            '#be185d', 1),
('procurement',     'Procurement Officer',      'Procurement & requisitions',           '#9333ea', 1),
('vc',              'Vice-Chancellor',          'Executive oversight & approvals',      '#1e293b', 1);

-- ── Seed the admin user ───────────────────────────────────────────────────
-- Run AFTER the schema is created; replace 'admin_username' with real username
INSERT INTO sys_user_roles (username, role_id, granted_by, notes)
SELECT 'admin_username', id, 'system', 'Initial bootstrap'
FROM sys_roles WHERE role_code = 'admin';
```

---

## 25. Summary: The Target Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ADMIN LOGS IN                                │
│  lg.ascx.cs → Membership.ValidateUser() → SUCCESS                  │
│  → RoleAccessService.LoadUserAccess(username, Session)             │
│       ├── Reads sys_user_roles → gets role_code → Session["usertype"]│
│       └── Reads sys_role_permissions → slugs → Session["access_slugs"]│
└───────────────────────────┬─────────────────────────────────────────┘
                            │
              ┌─────────────▼──────────────┐
              │     SIDEBAR RENDERS         │
              │  SidebarMaster.Page_Load    │
              │  → RenderDynamicSidebar()   │
              │  → Only renders items whose │
              │    slug ∈ access_slugs      │
              │  (SERVER-SIDE, not JS)      │
              └─────────────┬──────────────┘
                            │
              ┌─────────────▼──────────────┐
              │     USER NAVIGATES          │
              │  Each page Page_Load calls  │
              │  RequireSlug("page.slug")   │
              │  → Not in access_slugs?     │
              │  → Redirect to 403 page     │
              └─────────────┬──────────────┘
                            │
              ┌─────────────▼──────────────┐
              │   SUPER ADMIN MANAGES       │
              │  UserRolePermissions.aspx   │
              │  → Toggle checkboxes in     │
              │    permission matrix grid   │
              │  → DB updated instantly     │
              │  → Next login of affected   │
              │    user picks up new slugs  │
              └────────────────────────────┘
```

**Three guarantees the new system provides:**
1. **Menu items are invisible** to roles that don't have the slug (server-side render)
2. **Pages are unreachable** to roles that don't have the slug (server-side guard)
3. **Every change is logged** with actor, timestamp, and what changed (audit trail)

---

## 26. Implementation Task Plan — Master Status Board

This section converts §14–§25 into a concrete, sequentially-executable task list. Every task below maps to exact files and actions. Status is updated in place as work progresses.

### Status Legend
| Symbol | Meaning |
|--------|---------|
| ✅ | Complete — implemented and verified |
| 🔄 | In Progress |
| ⬜ | Not Started |
| ⚠️ | Blocked — see note |

---

### Phase 1 — Database Schema

| # | Task | Status | Output |
|---|------|--------|--------|
| 1.1 | Run DDL: create 6 new tables in `campus_dynamics` | ✅ | `sql/role_management_schema.sql` |
| 1.2 | Seed `sys_roles` (14 system roles) | ✅ | Same file, §Seed roles |
| 1.3 | Seed `sys_menu_items` (complete slug registry — all 80+ sidebar items) | ✅ | Same file, §Seed menu items |
| 1.4 | Seed `sys_role_permissions` (translate current `data-roles` to DB rows) | ✅ | Same file, §Seed permissions |

**Verification:** `SELECT COUNT(*) FROM sys_menu_items` → ≥ 80 rows; `SELECT COUNT(*) FROM sys_role_permissions` → ≥ 200 rows.

---

### Phase 2 — Service Layer

| # | Task | Status | Output |
|---|------|--------|--------|
| 2.1 | Create `App_Code/RoleAccessService.cs` | ✅ | New file |
| 2.2 | Update `fonts/lg.ascx.cs` — `Login1_LoggedIn` calls `LoadUserAccess()` | ✅ | Modified file |
| 2.3 | Update `fonts/lg_modern.ascx.cs` — same wiring | ✅ | Modified file |

**Verification:** Log in as admin → `Session["usertype"]` == `"admin"`, `Session["access_slugs"]` contains `"*"`.

---

### Phase 3 — Sidebar Refactor

| # | Task | Status | Output |
|---|------|--------|--------|
| 3.1 | Replace hardcoded sidebar `<ul>` content with `<asp:Literal ID="litSidebarMenu">` in `SidebarMaster.master` | ✅ | Modified master |
| 3.2 | Implement `RenderDynamicSidebar()` in `SidebarMaster.master.cs` — reads slugs, builds HTML server-side | ✅ | Modified code-behind |
| 3.3 | Implement `GetSectionDefaultsJson()` — returns JSON of section open/close defaults per role | ✅ | Modified code-behind |
| 3.4 | Add `<input type="hidden" id="cdSectionDefaults">` to master page, update sidebar JS to read it | ✅ | Modified master + JS |

**Verification:** Log in as `fees_officer` → sidebar shows only School Fees section, not Academics or HR.

---

### Phase 4 — Page Guards

| # | Task | Status | Output |
|---|------|--------|--------|
| 4.1 | Create `NewScreens/AccessDenied.aspx` — styled 403 page | ✅ | New file |
| 4.2 | Add `RoleAccessService.RequireSlug(this, "slug")` to the top of every sensitive `NewScreens` page's `Page_Load` | ✅ | ~40 modified files |

**Verification:** Navigate to `FeesStructure.aspx` while logged in as `dean` → redirect to `AccessDenied.aspx`.

---

### Phase 5 — Super Admin UI (4 Pages)

| # | Task | Status | Output |
|---|------|--------|--------|
| 5.1 | Build `NewScreens/UserRoleUsers.aspx` + `.aspx.cs` — user list, role badge, assign/revoke | ✅ | New files |
| 5.2 | Build `NewScreens/UserRoleRoles.aspx` + `.aspx.cs` — role cards, create/edit/delete | ✅ | New files |
| 5.3 | Build `NewScreens/UserRolePermissions.aspx` + `.aspx.cs` — permission matrix grid | ✅ | New files |
| 5.4 | Build `NewScreens/UserRoleAudit.aspx` + `.aspx.cs` — audit log with filters | ✅ | New files |

**Verification:** Open Permission Matrix → select role `registrar` → toggle `fees.fee_admin.dashboard` → save → confirm row exists in `sys_role_permissions`.

---

### Phase 6 — Wiring & Bootstrap

| # | Task | Status | Output |
|---|------|--------|--------|
| 6.1 | Add "User & Role Management" section to `SidebarMaster.master` System menu (links to 4 new pages) | ✅ | Modified master |
| 6.2 | Run bootstrap SQL: insert admin user into `sys_user_roles` | ✅ | `sql/role_management_bootstrap.sql` |

**Verification:** Log in as admin → System section shows "User & Role Management" submenu with 4 links.

---

## 27. Complete Slug Registry

This is the authoritative mapping of every sidebar item to its slug. Used to seed `sys_menu_items` in Task 1.3.

### Conventions
- Section headings: `section` (1 part)
- Parent groups: `section.group` (2 parts)
- Leaf pages: `section.group.page` (3 parts)
- `admin` wildcard `*` bypasses all slug checks

```
── HOME ─────────────────────────────────────────────────
home.dashboard              NewDashboard.aspx                         all roles

── ACADEMICS ────────────────────────────────────────────
academics                   [section heading]                         dean registrar faculty_staff admin

  academics.students        [Students parent]                         registrar admissions student_services admin
  academics.students.online_applications      OnlineApplicationsController.aspx   admin admissions registrar
  academics.students.register_new            NewStudentRegistration.aspx          registrar admin
  academics.students.semester_registration   StudentsRegistration.aspx            registrar admin
  academics.students.semester_deletions      SemesterDeletionRequestsController.aspx  admin registrar
  academics.students.course_registration     CourseRegistration.aspx              registrar admin
  academics.students.enrollment_analysis     EnrollmentAnalysis.aspx              dean registrar admin
  academics.students.active_students         ActiveStudents.aspx                  all
  academics.students.all_students            AllStudents.aspx                     all
  academics.students.alumni                  AlumniStudents.aspx                  registrar admin
  academics.students.id_card_status          IDCardStatus.aspx                    registrar admin student_services
  academics.students.portal_onboarding       PortalOnboarding.aspx                admin registrar
  academics.students.nche_export             NCHEExporter.aspx                    admin registrar
  academics.students.admissions_controller   AdmissionsController.aspx            admissions registrar admin

  academics.programmes      [Programmes & Courses parent]             dean registrar admin
  academics.programmes.faculties             NewFaculties.aspx                    dean registrar admin
  academics.programmes.programmes            NewFacultyProgrammes.aspx            dean registrar admin
  academics.programmes.specialisations       NewSpecialisations.aspx              dean registrar admin
  academics.programmes.course_bank           NewCourses.aspx                      dean registrar admin
  academics.programmes.programme_courses     NewProgrammeCourses.aspx             dean registrar admin
  academics.programmes.unlocated_courses     UnlocatedNewProgrammeCourses.aspx    admin
  academics.programmes.allocated_courses     AllocatedNewProgrammeCourses.aspx    admin
  academics.programmes.requested_courses     RequestedNewProgrammeCourses.aspx    admin
  academics.programmes.courses_dashboard     DashboardNewProgrammeCourses.aspx    admin
  academics.programmes.committee_report      AcademicCommitteeReport.aspx         dean registrar admin

  academics.exam            [Exam parent]                             exam_officer registrar faculty_staff admin
  academics.exam.marks_dashboard             MarksDashboard.aspx                  admin
  academics.exam.mark_requests               MarkRequestsAdmin.aspx               admin
  academics.exam.all_marks                   AllMarksController.aspx              admin
  academics.exam.published_marks             PublishedMarksController.aspx        admin
  academics.exam.provisional_marks           ProvisionalMarksController.aspx      admin
  academics.exam.pending_exam_marks          PendingExamMarksController.aspx      admin
  academics.exam.pending_coursework_marks    PendingCourseworkMarksController.aspx admin

  academics.allocation      [Allocation Management parent]            dean registrar faculty_staff admin
  academics.allocation.dashboard             LoadAllocationDashboard.aspx         dean registrar admin
  academics.allocation.teaching_allocations  LoadAllocations.aspx                 dean registrar faculty_staff admin
  academics.allocation.workload_analysis     WorkloadAnalysis.aspx                dean registrar admin

  academics.timetable       [Timetable parent]                        dean registrar faculty_staff admin
  academics.timetable.view                   TimetableView.aspx                   dean registrar faculty_staff admin

  academics.settings        [Settings parent]                         dean registrar admin
  academics.settings.lecture_rooms           LectureRooms.aspx                    dean registrar admin

── SCHOOL FEES ──────────────────────────────────────────
fees                        [section heading]                         fees_officer bursar admin

  fees.fee_admin            [Fee Administration parent]               fees_officer bursar admin
  fees.fee_admin.dashboard                   FeesManagement.aspx                  fees_officer bursar admin
  fees.fee_admin.access_policy               FeeAccessPolicy.aspx                 fees_officer bursar admin
  fees.fee_admin.access_checker              FeeAccessChecker.aspx                fees_officer bursar admin
  fees.fee_admin.structure                   FeesStructure.aspx                   fees_officer bursar admin
  fees.fee_admin.registration                FeesRegistration.aspx                fees_officer bursar admin
  fees.fee_admin.audit_trail                 FeesAuditTrail.aspx                  fees_officer bursar admin
  fees.fee_admin.other_fees_billing          OtherFeesBilling.aspx                fees_officer bursar admin
  fees.fee_admin.bill_waivers                BillWaivers.aspx                     fees_officer bursar admin
  fees.fee_admin.transactions                FeesTransactions.aspx                fees_officer bursar admin
  fees.fee_admin.student_ledgers             StudentLedgers.aspx                  fees_officer bursar admin
  fees.fee_admin.double_billing              DoubleBillingController.aspx         fees_officer bursar admin
  fees.fee_admin.active_students             ActiveStudents.aspx                  fees_officer bursar admin

  fees.bursaries            [Bursaries & Scholarships parent]         bursar admin
  fees.bursaries.dashboard                   BursaryDashboard.aspx                bursar admin
  fees.bursaries.schemes                     BursarySchemes.aspx                  bursar admin
  fees.bursaries.beneficiaries               BursaryBeneficiaries.aspx            bursar admin

── EXPENDITURE & ACCOUNTS ───────────────────────────────
accounts                    [section heading]                         finance_officer accountant admin

  accounts.ledgers          [Accounts & Ledgers parent]               finance_officer accountant admin
  accounts.ledgers.main_accounts             MainAccountsController.aspx          finance_officer accountant admin
  accounts.ledgers.sub_accounts              SubAccountsController.aspx           finance_officer accountant admin
  accounts.ledgers.categories                LedgerCategories.aspx                finance_officer accountant admin
  accounts.ledgers.general_ledger            GeneralLedger.aspx                   finance_officer accountant admin
  accounts.ledgers.suppliers                 SupplierManagement.aspx              finance_officer accountant admin

  accounts.transactions     [Expenditure Transactions parent]         finance_officer accountant admin
  accounts.transactions.journal_entries      JournalEntries.aspx                  finance_officer accountant admin
  accounts.transactions.payment_vouchers     PaymentVouchers.aspx                 finance_officer accountant admin
  accounts.transactions.contra_vouchers      ContraVouchers.aspx                  finance_officer accountant admin

  accounts.control          [Periods & Control parent]                finance_officer accountant admin
  accounts.control.finance_dashboard         FinanceDashboard.aspx                finance_officer accountant admin
  accounts.control.financial_periods         FinancialPeriods.aspx                finance_officer accountant admin
  accounts.control.audit_trail               FinanceAuditTrail.aspx               finance_officer accountant admin
  accounts.control.batch_monitor             Finance/Admin/TransactionBatchMonitor.aspx    admin
  accounts.control.double_entry              Finance/Admin/DoubleEntryValidation.aspx      admin
  accounts.control.period_management        Finance/Admin/PeriodManagement.aspx           admin
  accounts.control.period_close              Finance/Admin/PeriodClose.aspx               admin
  accounts.control.reversal_approvals        Finance/Admin/ReversalApprovals.aspx         admin
  accounts.control.audit_trail_tx            Finance/Admin/TransactionAuditTrail.aspx     admin
  accounts.control.bank_reco_import          Finance/Admin/BankReconciliationImport.aspx  admin
  accounts.control.bank_reco_match           Finance/Admin/BankRecoMatching.aspx          admin
  accounts.control.account_lifecycle         Finance/Admin/AccountManagement.aspx         admin
  accounts.control.reversal_request          Finance/Admin/ReversalRequest.aspx           finance_officer accountant admin
  accounts.control.correction_request        Finance/Admin/CorrectionRequest.aspx         finance_officer accountant admin

  accounts.reports          [Financial Reports parent]                finance_officer accountant admin
  accounts.reports.trial_balance             TrialBalance.aspx                    finance_officer accountant admin
  accounts.reports.income_statement          IncomeStatement.aspx                 finance_officer accountant admin
  accounts.reports.balance_sheet             BalanceSheet.aspx                    finance_officer accountant admin

── HUMAN RESOURCE ───────────────────────────────────────
hr                          [section heading]                         hr_manager admin
hr.dashboard                HRDashboard.aspx                          hr_manager admin

  hr.people                 [People & Contracts parent]               hr_manager admin
  hr.people.employees                        HREmployees.aspx                     hr_manager admin
  hr.people.contracts                        HRContracts.aspx                     hr_manager admin
  hr.people.leave                            HRLeaveManagement.aspx               hr_manager admin

  hr.payroll                [Payroll parent]                          hr_manager admin
  hr.payroll.management                      HRPayroll.aspx                       hr_manager admin
  hr.payroll.payslips                        HRPayslips.aspx                      hr_manager admin
  hr.payroll.allowances                      HRAllowances.aspx                    hr_manager admin
  hr.payroll.deductions                      HRDeductions.aspx                    hr_manager admin

  hr.settings               [HR Settings parent]                      hr_manager admin
  hr.settings.org_structure                  HRSettings.aspx                      hr_manager admin
  hr.settings.payroll_config                 HRConfig.aspx                        hr_manager admin

  hr.appraisal              [Performance Appraisal parent]            hr_manager admin
  hr.appraisal.dashboard                     AppraisalDashboard.aspx              hr_manager admin
  hr.appraisal.sessions                      AppraisalSessions.aspx               hr_manager admin
  hr.appraisal.view                          AppraisalView.aspx                   hr_manager admin
  hr.appraisal.reports                       AppraisalReports.aspx                hr_manager admin

── REQUISITIONS ─────────────────────────────────────────
requisitions                [section heading]                         bursar finance_officer procurement vc admin

  requisitions.main         [Requisitions parent]                     bursar finance_officer procurement vc admin
  requisitions.main.controller               RequisitionsController.aspx          bursar finance_officer procurement vc admin
  requisitions.main.bursar_queue             BursarRequisitions.aspx              bursar admin
  requisitions.main.finance_queue            FinanceRequisitions.aspx             finance_officer admin

── COMMUNICATIONS ───────────────────────────────────────
comms                       [section heading]                         dean registrar faculty_staff admin

  comms.notices             [Notices parent]                          dean registrar faculty_staff admin
  comms.notices.manage                       Communications.aspx                  dean registrar faculty_staff admin
  comms.notices.analytics                    CommunicationAnalytics.aspx          dean registrar admin

comms.tickets               TicketsController.aspx                    admin registrar student_services

── SYSTEM ───────────────────────────────────────────────
system                      [section heading]                         admin

  system.config             [Configuration parent]                    admin
  system.config.academic_years               AcademicYears.aspx                   admin
  system.config.system_config                SystemConfig.aspx                    admin

  system.more               [More Features parent]                    all (filtered by subitem)
  system.more.elections_dashboard            ElectionsDashboard.aspx              registrar admin student_services
  system.more.election_posts                 ElectionPosts.aspx                   registrar admin student_services
  system.more.election_candidates            ElectionCandidates.aspx              registrar admin student_services
  system.more.election_voters                ElectionVoters.aspx                  registrar admin student_services
  system.more.election_results               ElectionResults.aspx                 registrar admin student_services
  system.more.validation_stats               SystemValidationStats.aspx           all
  system.more.knowledgebase                  KnowledgebaseManagement.aspx         admin
  system.more.id_cards                       StudentsIDCards.aspx                 registrar admin student_services
  system.more.graduating_students            GraduateStudents.aspx                registrar dean admin
  system.more.specialisations                StudentsSpecialisation.aspx          registrar admin
  system.more.year_promotions                StudentsPromotion.aspx               registrar admin
  system.more.student_documents             StudentDocuments.aspx                 registrar admin student_services
  system.more.residence_allocation           ResidenceAllocation.aspx             admin student_services
  system.more.nche_student_exporter          NCHEStudentExporter.aspx             admin registrar
  system.more.research_marksheets            ResearchMarksheets.aspx              exam_officer registrar dean admin
  system.more.academic_results               AcademicResults.aspx                 exam_officer registrar dean admin
  system.more.results_release                ResultsRelease.aspx                  exam_officer registrar admin
  system.more.results_updates                ResultsUpdates.aspx                  exam_officer registrar admin
  system.more.hold_list                      ResultsHoldList.aspx                 exam_officer registrar admin
  system.more.results_audit_log              ResultsAuditLog.aspx                 exam_officer registrar admin
  system.more.student_profile                StudentProfile.aspx                  registrar admin student_services
  system.more.results_analytics              ResultsAnalytics.aspx                exam_officer registrar dean admin
  system.more.student_results_view           StudentResultsView.aspx              exam_officer registrar admin
  system.more.chart_of_accounts              ChartOfAccounts.aspx                 finance_officer accountant admin

── USER & ROLE MANAGEMENT (Super Admin Only) ────────────
system.user_roles           [User & Role Mgmt parent]                 admin only (hardcoded guard)
system.user_roles.users                      UserRoleUsers.aspx                   admin
system.user_roles.roles                      UserRoleRoles.aspx                   admin
system.user_roles.permissions                UserRolePermissions.aspx             admin
system.user_roles.audit                      UserRoleAudit.aspx                   admin
```

**Total slugs: ~108** (headings + parents + leaf pages)

---

## 28. Phase 1 SQL — Complete Schema + Seeds

> **File:** `COOPERP/sql/role_management_schema.sql`
> **Run against:** `campus_dynamics` database
> **Run order:** DDL → roles → menu_items → permissions → bootstrap

### 28A. DDL (Tables)

```sql
-- ── role_management_schema.sql ─────────────────────────────────────────────
-- Run against: campus_dynamics
-- Tables: sys_menu_items, sys_roles, sys_role_permissions,
--         sys_user_roles, sys_role_audit, sys_role_section_settings
-- ──────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS sys_menu_items (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug        VARCHAR(120) NOT NULL UNIQUE,
    label       VARCHAR(120) NOT NULL,
    section     VARCHAR(60)  NOT NULL,
    item_type   ENUM('heading','parent','subitem','standalone') NOT NULL DEFAULT 'subitem',
    parent_slug VARCHAR(120) DEFAULT NULL,
    url         VARCHAR(300) DEFAULT NULL,
    icon_svg    TEXT         DEFAULT NULL,
    sort_order  SMALLINT     NOT NULL DEFAULT 100,
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    created_at  DATETIME     NOT NULL DEFAULT NOW(),
    INDEX idx_section (section),
    INDEX idx_parent  (parent_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_roles (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_code       VARCHAR(60)  NOT NULL UNIQUE,
    role_name       VARCHAR(120) NOT NULL,
    description     TEXT         DEFAULT NULL,
    color_hex       VARCHAR(7)   DEFAULT '#64748b',
    is_system_role  TINYINT(1)   NOT NULL DEFAULT 0,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_by      VARCHAR(100) DEFAULT NULL,
    created_at      DATETIME     NOT NULL DEFAULT NOW(),
    updated_at      DATETIME     DEFAULT NULL ON UPDATE NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_permissions (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id     INT UNSIGNED NOT NULL,
    menu_slug   VARCHAR(120) NOT NULL,
    can_view    TINYINT(1)   NOT NULL DEFAULT 1,
    can_edit    TINYINT(1)   NOT NULL DEFAULT 0,
    can_delete  TINYINT(1)   NOT NULL DEFAULT 0,
    granted_by  VARCHAR(100) NOT NULL DEFAULT 'system',
    granted_at  DATETIME     NOT NULL DEFAULT NOW(),
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_role_slug (role_id, menu_slug),
    INDEX idx_slug (menu_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_user_roles (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(100) NOT NULL,
    emp_id      INT          DEFAULT NULL,
    role_id     INT UNSIGNED NOT NULL,
    granted_by  VARCHAR(100) NOT NULL DEFAULT 'system',
    granted_at  DATETIME     NOT NULL DEFAULT NOW(),
    expires_at  DATETIME     DEFAULT NULL,
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    notes       VARCHAR(300) DEFAULT NULL,
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_role (username, role_id),
    INDEX idx_username (username),
    INDEX idx_emp      (emp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_audit (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('ROLE_CREATED','ROLE_UPDATED','ROLE_DELETED',
                     'PERMISSION_GRANTED','PERMISSION_REVOKED',
                     'USER_ROLE_ASSIGNED','USER_ROLE_REVOKED',
                     'USER_ROLE_EXPIRED') NOT NULL,
    target_type ENUM('role','permission','user_role') NOT NULL,
    target_id   VARCHAR(200) NOT NULL,
    detail      TEXT         DEFAULT NULL,
    actor       VARCHAR(100) NOT NULL,
    ip_address  VARCHAR(45)  DEFAULT NULL,
    created_at  DATETIME     NOT NULL DEFAULT NOW(),
    INDEX idx_actor  (actor),
    INDEX idx_type   (action_type),
    INDEX idx_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_section_settings (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id         INT UNSIGNED NOT NULL,
    section_slug    VARCHAR(60)  NOT NULL,
    default_open    TINYINT(1)   NOT NULL DEFAULT 0,
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_role_section (role_id, section_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 28B. Roles Seed

```sql
-- ── Seed sys_roles ─────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_roles (role_code, role_name, description, color_hex, is_system_role) VALUES
('admin',           'System Administrator',  'Full unrestricted access to all modules',        '#05275C', 1),
('dean',            'Dean',                  'Faculty academic oversight',                     '#7c3aed', 1),
('registrar',       'Registrar',             'Student registration and records management',    '#174DA4', 1),
('faculty_staff',   'Faculty Staff',         'Teaching and academic delivery staff',           '#0369a1', 1),
('exam_officer',    'Examination Officer',   'Exam administration, results and transcripts',   '#d97706', 1),
('admissions',      'Admissions Officer',    'Application processing and admissions workflow', '#16a34a', 1),
('student_services','Student Services',      'Student support, welfare and services',          '#059669', 1),
('fees_officer',    'Fees Officer',          'Student fee collection and administration',      '#ca8a04', 1),
('bursar',          'Bursar',                'Bursary management and financial routing',       '#b45309', 1),
('finance_officer', 'Finance Officer',       'Finance operations, ledgers and accounts',      '#0891b2', 1),
('accountant',      'Accountant',            'Accounting, ledgers and financial reporting',   '#0e7490', 1),
('hr_manager',      'HR Manager',            'Human resources, payroll and staff management', '#be185d', 1),
('procurement',     'Procurement Officer',   'Procurement workflow and requisitions',          '#9333ea', 1),
('vc',              'Vice-Chancellor',       'Executive oversight and high-level approvals',  '#1e293b', 1);
```

### 28C. Menu Items Seed

```sql
-- ── Seed sys_menu_items ────────────────────────────────────────────────────
-- sort_order increments by 10 per item, by 100 per section boundary

INSERT IGNORE INTO sys_menu_items (slug, label, section, item_type, parent_slug, url, sort_order) VALUES

-- HOME
('home.dashboard','Dashboard','home','standalone',NULL,'~/COOPERP/NewScreens/NewDashboard.aspx',10),

-- ACADEMICS
('academics','Academics','academics','heading',NULL,NULL,100),
('academics.students','Students','academics','parent','academics',NULL,110),
('academics.students.online_applications','Online Applications','academics','subitem','academics.students','~/COOPERP/NewScreens/OnlineApplicationsController.aspx',111),
('academics.students.register_new','Register New Student','academics','subitem','academics.students','~/COOPERP/NewScreens/NewStudentRegistration.aspx',112),
('academics.students.semester_registration','Semester Registration','academics','subitem','academics.students','~/COOPERP/NewScreens/StudentsRegistration.aspx',113),
('academics.students.semester_deletions','Semester Deletion Requests','academics','subitem','academics.students','~/COOPERP/NewScreens/SemesterDeletionRequestsController.aspx',114),
('academics.students.course_registration','Student Course Registration','academics','subitem','academics.students','~/COOPERP/NewScreens/CourseRegistration.aspx',115),
('academics.students.enrollment_analysis','Enrolment Analysis','academics','subitem','academics.students','~/COOPERP/NewScreens/EnrollmentAnalysis.aspx',116),
('academics.students.active_students','Active Students','academics','subitem','academics.students','~/COOPERP/NewScreens/ActiveStudents.aspx',117),
('academics.students.all_students','All Students','academics','subitem','academics.students','~/COOPERP/NewScreens/AllStudents.aspx',118),
('academics.students.alumni','Alumni','academics','subitem','academics.students','~/COOPERP/NewScreens/AlumniStudents.aspx',119),
('academics.students.id_card_status','ID Card Status','academics','subitem','academics.students','~/COOPERP/NewScreens/IDCardStatus.aspx',120),
('academics.students.portal_onboarding','Portal Onboarding','academics','subitem','academics.students','~/COOPERP/NewScreens/PortalOnboarding.aspx',121),
('academics.students.nche_export','NCHE Data Export','academics','subitem','academics.students','~/COOPERP/NewScreens/NCHEExporter.aspx',122),
('academics.students.admissions_controller','Admissions Controller','academics','subitem','academics.students','~/COOPERP/NewScreens/AdmissionsController.aspx',123),

('academics.programmes','Programmes & Courses','academics','parent','academics',NULL,130),
('academics.programmes.faculties','Faculties','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewFaculties.aspx',131),
('academics.programmes.programmes','Programmes','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewFacultyProgrammes.aspx',132),
('academics.programmes.specialisations','Specialisations','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewSpecialisations.aspx',133),
('academics.programmes.course_bank','Course Bank','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewCourses.aspx',134),
('academics.programmes.programme_courses','Programme Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewProgrammeCourses.aspx',135),
('academics.programmes.unlocated_courses','Unlocated Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/UnlocatedNewProgrammeCourses.aspx',136),
('academics.programmes.allocated_courses','Allocated Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/AllocatedNewProgrammeCourses.aspx',137),
('academics.programmes.requested_courses','Requested Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/RequestedNewProgrammeCourses.aspx',138),
('academics.programmes.courses_dashboard','Programme Courses Dashboard','academics','subitem','academics.programmes','~/COOPERP/NewScreens/DashboardNewProgrammeCourses.aspx',139),
('academics.programmes.committee_report','Academic Committee Report','academics','subitem','academics.programmes','~/COOPERP/NewScreens/AcademicCommitteeReport.aspx',140),

('academics.exam','Exam','academics','parent','academics',NULL,150),
('academics.exam.marks_dashboard','Marks Dashboard','academics','subitem','academics.exam','~/COOPERP/NewScreens/MarksDashboard.aspx',151),
('academics.exam.mark_requests','Mark Requests','academics','subitem','academics.exam','~/COOPERP/NewScreens/MarkRequestsAdmin.aspx',152),
('academics.exam.all_marks','All Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/AllMarksController.aspx',153),
('academics.exam.published_marks','Published Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/PublishedMarksController.aspx',154),
('academics.exam.provisional_marks','Provisional Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/ProvisionalMarksController.aspx',155),
('academics.exam.pending_exam_marks','Pending Exam Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/PendingExamMarksController.aspx',156),
('academics.exam.pending_coursework_marks','Pending Coursework Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/PendingCourseworkMarksController.aspx',157),

('academics.allocation','Allocation Management','academics','parent','academics',NULL,160),
('academics.allocation.dashboard','Allocation Dashboard','academics','subitem','academics.allocation','~/COOPERP/NewScreens/LoadAllocationDashboard.aspx',161),
('academics.allocation.teaching_allocations','Teaching Allocations','academics','subitem','academics.allocation','~/COOPERP/NewScreens/LoadAllocations.aspx',162),
('academics.allocation.workload_analysis','Workload Analysis','academics','subitem','academics.allocation','~/COOPERP/NewScreens/WorkloadAnalysis.aspx',163),

('academics.timetable','Timetable','academics','parent','academics',NULL,170),
('academics.timetable.view','Timetable View','academics','subitem','academics.timetable','~/COOPERP/NewScreens/TimetableView.aspx',171),

('academics.settings','Settings','academics','parent','academics',NULL,180),
('academics.settings.lecture_rooms','Lecture Rooms','academics','subitem','academics.settings','~/COOPERP/NewScreens/LectureRooms.aspx',181),

-- SCHOOL FEES
('fees','School Fees','fees','heading',NULL,NULL,200),
('fees.fee_admin','Fee Administration','fees','parent','fees',NULL,210),
('fees.fee_admin.dashboard','Fees Dashboard','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesManagement.aspx',211),
('fees.fee_admin.access_policy','Fee Access Policy','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeeAccessPolicy.aspx',212),
('fees.fee_admin.access_checker','Fee Access Checker','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeeAccessChecker.aspx',213),
('fees.fee_admin.structure','Fee Structure & Settings','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesStructure.aspx',214),
('fees.fee_admin.registration','Fee Registration','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesRegistration.aspx',215),
('fees.fee_admin.audit_trail','Audit Trail','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesAuditTrail.aspx',216),
('fees.fee_admin.other_fees_billing','Other Fees Billing','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/OtherFeesBilling.aspx',217),
('fees.fee_admin.bill_waivers','Bill Waivers','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/BillWaivers.aspx',218),
('fees.fee_admin.transactions','Transactions','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesTransactions.aspx',219),
('fees.fee_admin.student_ledgers','Student Ledgers','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/StudentLedgers.aspx',220),
('fees.fee_admin.double_billing','Double Billing','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/DoubleBillingController.aspx',221),
('fees.fee_admin.active_students_fees','Active Students','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/ActiveStudents.aspx',222),

('fees.bursaries','Bursaries & Scholarships','fees','parent','fees',NULL,230),
('fees.bursaries.dashboard','Bursary Dashboard','fees','subitem','fees.bursaries','~/COOPERP/NewScreens/BursaryDashboard.aspx',231),
('fees.bursaries.schemes','Bursary Schemes','fees','subitem','fees.bursaries','~/COOPERP/NewScreens/BursarySchemes.aspx',232),
('fees.bursaries.beneficiaries','Bursary Beneficiaries','fees','subitem','fees.bursaries','~/COOPERP/NewScreens/BursaryBeneficiaries.aspx',233),

-- EXPENDITURE & ACCOUNTS
('accounts','Expenditure & Accounts','accounts','heading',NULL,NULL,300),
('accounts.ledgers','Accounts & Ledgers','accounts','parent','accounts',NULL,310),
('accounts.ledgers.main_accounts','Main Accounts Controller','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/MainAccountsController.aspx',311),
('accounts.ledgers.sub_accounts','Sub Accounts Controller','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/SubAccountsController.aspx',312),
('accounts.ledgers.categories','Ledger Categories','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/LedgerCategories.aspx',313),
('accounts.ledgers.general_ledger','General Ledger','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/GeneralLedger.aspx',314),
('accounts.ledgers.suppliers','Supplier Management','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/SupplierManagement.aspx',315),

('accounts.transactions','Expenditure Transactions','accounts','parent','accounts',NULL,320),
('accounts.transactions.journal_entries','Journal Entries','accounts','subitem','accounts.transactions','~/COOPERP/NewScreens/JournalEntries.aspx',321),
('accounts.transactions.payment_vouchers','Payment Vouchers','accounts','subitem','accounts.transactions','~/COOPERP/NewScreens/PaymentVouchers.aspx',322),
('accounts.transactions.contra_vouchers','Contra Vouchers','accounts','subitem','accounts.transactions','~/COOPERP/NewScreens/ContraVouchers.aspx',323),

('accounts.control','Periods & Control','accounts','parent','accounts',NULL,330),
('accounts.control.finance_dashboard','Finance Dashboard','accounts','subitem','accounts.control','~/COOPERP/NewScreens/FinanceDashboard.aspx',331),
('accounts.control.financial_periods','Financial Periods','accounts','subitem','accounts.control','~/COOPERP/NewScreens/FinancialPeriods.aspx',332),
('accounts.control.audit_trail','Audit Trail','accounts','subitem','accounts.control','~/COOPERP/NewScreens/FinanceAuditTrail.aspx',333),
('accounts.control.batch_monitor','Transaction Batch Monitor','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/TransactionBatchMonitor.aspx',334),
('accounts.control.double_entry','Double-Entry Validation','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/DoubleEntryValidation.aspx',335),
('accounts.control.period_management','Accounting Period Management','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/PeriodManagement.aspx',336),
('accounts.control.period_close','Period Close Management','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/PeriodClose.aspx',337),
('accounts.control.reversal_approvals','Reversal & Correction Approvals','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/ReversalApprovals.aspx',338),
('accounts.control.audit_trail_tx','Transaction Audit Trail','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/TransactionAuditTrail.aspx',339),
('accounts.control.bank_reco_import','Bank Reconciliation Import','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/BankReconciliationImport.aspx',340),
('accounts.control.bank_reco_match','Bank Reconciliation Matching','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/BankRecoMatching.aspx',341),
('accounts.control.account_lifecycle','Chart of Accounts Lifecycle','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/AccountManagement.aspx',342),
('accounts.control.reversal_request','Initiate Reversal Request','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/ReversalRequest.aspx',343),
('accounts.control.correction_request','Initiate Correction Request','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/CorrectionRequest.aspx',344),

('accounts.reports','Financial Reports','accounts','parent','accounts',NULL,350),
('accounts.reports.trial_balance','Trial Balance','accounts','subitem','accounts.reports','~/COOPERP/NewScreens/TrialBalance.aspx',351),
('accounts.reports.income_statement','Income Statement','accounts','subitem','accounts.reports','~/COOPERP/NewScreens/IncomeStatement.aspx',352),
('accounts.reports.balance_sheet','Balance Sheet','accounts','subitem','accounts.reports','~/COOPERP/NewScreens/BalanceSheet.aspx',353),

-- HUMAN RESOURCE
('hr','Human Resource','hr','heading',NULL,NULL,400),
('hr.dashboard','HR Dashboard','hr','standalone',NULL,'~/COOPERP/NewScreens/HRDashboard.aspx',401),
('hr.people','People & Contracts','hr','parent','hr',NULL,410),
('hr.people.employees','Employee Directory','hr','subitem','hr.people','~/COOPERP/NewScreens/HREmployees.aspx',411),
('hr.people.contracts','Contracts','hr','subitem','hr.people','~/COOPERP/NewScreens/HRContracts.aspx',412),
('hr.people.leave','Leave Management','hr','subitem','hr.people','~/COOPERP/NewScreens/HRLeaveManagement.aspx',413),

('hr.payroll','Payroll','hr','parent','hr',NULL,420),
('hr.payroll.management','Payroll Management','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRPayroll.aspx',421),
('hr.payroll.payslips','Payslips','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRPayslips.aspx',422),
('hr.payroll.allowances','Allowance Records','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRAllowances.aspx',423),
('hr.payroll.deductions','Deduction Records','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRDeductions.aspx',424),

('hr.settings','HR Settings','hr','parent','hr',NULL,430),
('hr.settings.org_structure','Org Structure & Scales','hr','subitem','hr.settings','~/COOPERP/NewScreens/HRSettings.aspx',431),
('hr.settings.payroll_config','Payroll & Tax Config','hr','subitem','hr.settings','~/COOPERP/NewScreens/HRConfig.aspx',432),

('hr.appraisal','Performance Appraisal','hr','parent','hr',NULL,440),
('hr.appraisal.dashboard','Appraisal Dashboard','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalDashboard.aspx',441),
('hr.appraisal.sessions','Appraisal Sessions','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalSessions.aspx',442),
('hr.appraisal.view','View Appraisals','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalView.aspx',443),
('hr.appraisal.reports','Appraisal Reports','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalReports.aspx',444),

-- REQUISITIONS
('requisitions','Requisitions','requisitions','heading',NULL,NULL,500),
('requisitions.main','Requisitions','requisitions','parent','requisitions',NULL,510),
('requisitions.main.controller','Master Dashboard','requisitions','subitem','requisitions.main','~/COOPERP/NewScreens/RequisitionsController.aspx',511),
('requisitions.main.bursar_queue','Bursar Queue','requisitions','subitem','requisitions.main','~/COOPERP/NewScreens/BursarRequisitions.aspx',512),
('requisitions.main.finance_queue','Finance Queue','requisitions','subitem','requisitions.main','~/COOPERP/NewScreens/FinanceRequisitions.aspx',513),

-- COMMUNICATIONS
('comms','Communications','comms','heading',NULL,NULL,600),
('comms.notices','Notices','comms','parent','comms',NULL,610),
('comms.notices.manage','Manage Communications','comms','subitem','comms.notices','~/COOPERP/NewScreens/Communications.aspx',611),
('comms.notices.analytics','Read Analytics','comms','subitem','comms.notices','~/COOPERP/NewScreens/CommunicationAnalytics.aspx',612),
('comms.tickets','Support Tickets','comms','standalone',NULL,'~/COOPERP/NewScreens/TicketsController.aspx',620),

-- SYSTEM
('system','System','system','heading',NULL,NULL,700),
('system.config','Configuration','system','parent','system',NULL,710),
('system.config.academic_years','Academic Years','system','subitem','system.config','~/COOPERP/NewScreens/AcademicYears.aspx',711),
('system.config.system_config','System Configuration','system','subitem','system.config','~/COOPERP/NewScreens/SystemConfig.aspx',712),

('system.more','More Features','system','parent','system',NULL,720),
('system.more.elections_dashboard','Elections Dashboard','system','subitem','system.more','~/COOPERP/NewScreens/ElectionsDashboard.aspx',721),
('system.more.election_posts','Election Posts','system','subitem','system.more','~/COOPERP/NewScreens/ElectionPosts.aspx',722),
('system.more.election_candidates','Election Candidates','system','subitem','system.more','~/COOPERP/NewScreens/ElectionCandidates.aspx',723),
('system.more.election_voters','Election Voters','system','subitem','system.more','~/COOPERP/NewScreens/ElectionVoters.aspx',724),
('system.more.election_results','Election Results','system','subitem','system.more','~/COOPERP/NewScreens/ElectionResults.aspx',725),
('system.more.validation_stats','Validation Stats','system','subitem','system.more','~/COOPERP/NewScreens/SystemValidationStats.aspx',726),
('system.more.knowledgebase','Knowledgebase Management','system','subitem','system.more','~/COOPERP/NewScreens/KnowledgebaseManagement.aspx',727),
('system.more.id_cards','ID Cards','system','subitem','system.more','~/COOPERP/NewScreens/StudentsIDCards.aspx',728),
('system.more.graduating_students','Graduating Students','system','subitem','system.more','~/COOPERP/NewScreens/GraduateStudents.aspx',729),
('system.more.specialisations','Student Specialisations','system','subitem','system.more','~/COOPERP/NewScreens/StudentsSpecialisation.aspx',730),
('system.more.year_promotions','Year Promotions','system','subitem','system.more','~/COOPERP/NewScreens/StudentsPromotion.aspx',731),
('system.more.student_documents','Student Documents','system','subitem','system.more','~/COOPERP/NewScreens/StudentDocuments.aspx',732),
('system.more.residence_allocation','Residence Allocation','system','subitem','system.more','~/COOPERP/NewScreens/ResidenceAllocation.aspx',733),
('system.more.nche_student_exporter','NCHE Student Exporter','system','subitem','system.more','~/COOPERP/NewScreens/NCHEStudentExporter.aspx',734),
('system.more.research_marksheets','Research Marksheets','system','subitem','system.more','~/COOPERP/NewScreens/ResearchMarksheets.aspx',735),
('system.more.academic_results','Academic Results','system','subitem','system.more','~/COOPERP/NewScreens/AcademicResults.aspx',736),
('system.more.results_release','Results Release','system','subitem','system.more','~/COOPERP/NewScreens/ResultsRelease.aspx',737),
('system.more.results_updates','Results Updates','system','subitem','system.more','~/COOPERP/NewScreens/ResultsUpdates.aspx',738),
('system.more.hold_list','Hold List','system','subitem','system.more','~/COOPERP/NewScreens/ResultsHoldList.aspx',739),
('system.more.results_audit_log','Results Audit Log','system','subitem','system.more','~/COOPERP/NewScreens/ResultsAuditLog.aspx',740),
('system.more.student_profile','Student Profile','system','subitem','system.more','~/COOPERP/NewScreens/StudentProfile.aspx',741),
('system.more.results_analytics','Results Analytics','system','subitem','system.more','~/COOPERP/NewScreens/ResultsAnalytics.aspx',742),
('system.more.student_results_view','Student Results View','system','subitem','system.more','~/COOPERP/NewScreens/StudentResultsView.aspx',743),
('system.more.chart_of_accounts','Chart of Accounts','system','subitem','system.more','~/COOPERP/NewScreens/ChartOfAccounts.aspx',744),

-- USER & ROLE MANAGEMENT (Super Admin only)
('system.user_roles','User & Role Management','system','parent','system',NULL,800),
('system.user_roles.users','Users','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRoleUsers.aspx',801),
('system.user_roles.roles','Roles','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRoleRoles.aspx',802),
('system.user_roles.permissions','Permission Matrix','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRolePermissions.aspx',803),
('system.user_roles.audit','Audit Log','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRoleAudit.aspx',804);
```

### 28D. Role Permissions Seed

```sql
-- ── Seed sys_role_permissions ──────────────────────────────────────────────
-- Translates existing data-roles HTML attributes into DB permission rows.
-- Pattern: INSERT IGNORE for each (role_id, slug) pair the role can access.

-- Helper: Insert all slugs for a role in one readable block.
-- Substituting role IDs via subquery so insert is ID-agnostic.

SET @admin_id     = (SELECT id FROM sys_roles WHERE role_code='admin');
SET @dean_id      = (SELECT id FROM sys_roles WHERE role_code='dean');
SET @registrar_id = (SELECT id FROM sys_roles WHERE role_code='registrar');
SET @faculty_id   = (SELECT id FROM sys_roles WHERE role_code='faculty_staff');
SET @exam_id      = (SELECT id FROM sys_roles WHERE role_code='exam_officer');
SET @admit_id     = (SELECT id FROM sys_roles WHERE role_code='admissions');
SET @svc_id       = (SELECT id FROM sys_roles WHERE role_code='student_services');
SET @fees_id      = (SELECT id FROM sys_roles WHERE role_code='fees_officer');
SET @bursar_id    = (SELECT id FROM sys_roles WHERE role_code='bursar');
SET @fin_id       = (SELECT id FROM sys_roles WHERE role_code='finance_officer');
SET @acc_id       = (SELECT id FROM sys_roles WHERE role_code='accountant');
SET @hr_id        = (SELECT id FROM sys_roles WHERE role_code='hr_manager');
SET @proc_id      = (SELECT id FROM sys_roles WHERE role_code='procurement');
SET @vc_id        = (SELECT id FROM sys_roles WHERE role_code='vc');

-- ── ADMIN gets wildcard (handled in code via role_code='admin', no DB rows needed)
-- ── but we still insert explicit rows for completeness & audit trail

-- ── Dean permissions ──────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@dean_id,'home.dashboard'),
(@dean_id,'academics'),
(@dean_id,'academics.students'),
(@dean_id,'academics.students.enrollment_analysis'),
(@dean_id,'academics.students.active_students'),
(@dean_id,'academics.students.all_students'),
(@dean_id,'academics.programmes'),
(@dean_id,'academics.programmes.faculties'),
(@dean_id,'academics.programmes.programmes'),
(@dean_id,'academics.programmes.specialisations'),
(@dean_id,'academics.programmes.course_bank'),
(@dean_id,'academics.programmes.programme_courses'),
(@dean_id,'academics.programmes.committee_report'),
(@dean_id,'academics.exam'),
(@dean_id,'academics.allocation'),
(@dean_id,'academics.allocation.dashboard'),
(@dean_id,'academics.allocation.teaching_allocations'),
(@dean_id,'academics.allocation.workload_analysis'),
(@dean_id,'academics.timetable'),
(@dean_id,'academics.timetable.view'),
(@dean_id,'academics.settings'),
(@dean_id,'academics.settings.lecture_rooms'),
(@dean_id,'comms'),
(@dean_id,'comms.notices'),
(@dean_id,'comms.notices.manage'),
(@dean_id,'comms.notices.analytics'),
(@dean_id,'system.more'),
(@dean_id,'system.more.graduating_students'),
(@dean_id,'system.more.research_marksheets'),
(@dean_id,'system.more.academic_results'),
(@dean_id,'system.more.results_analytics');

-- ── Registrar permissions ─────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@registrar_id,'home.dashboard'),
(@registrar_id,'academics'),
(@registrar_id,'academics.students'),
(@registrar_id,'academics.students.online_applications'),
(@registrar_id,'academics.students.register_new'),
(@registrar_id,'academics.students.semester_registration'),
(@registrar_id,'academics.students.semester_deletions'),
(@registrar_id,'academics.students.course_registration'),
(@registrar_id,'academics.students.enrollment_analysis'),
(@registrar_id,'academics.students.active_students'),
(@registrar_id,'academics.students.all_students'),
(@registrar_id,'academics.students.alumni'),
(@registrar_id,'academics.students.id_card_status'),
(@registrar_id,'academics.students.portal_onboarding'),
(@registrar_id,'academics.students.nche_export'),
(@registrar_id,'academics.students.admissions_controller'),
(@registrar_id,'academics.programmes'),
(@registrar_id,'academics.programmes.faculties'),
(@registrar_id,'academics.programmes.programmes'),
(@registrar_id,'academics.programmes.specialisations'),
(@registrar_id,'academics.programmes.course_bank'),
(@registrar_id,'academics.programmes.programme_courses'),
(@registrar_id,'academics.programmes.committee_report'),
(@registrar_id,'academics.exam'),
(@registrar_id,'academics.allocation'),
(@registrar_id,'academics.allocation.dashboard'),
(@registrar_id,'academics.allocation.teaching_allocations'),
(@registrar_id,'academics.allocation.workload_analysis'),
(@registrar_id,'academics.timetable'),
(@registrar_id,'academics.timetable.view'),
(@registrar_id,'academics.settings'),
(@registrar_id,'academics.settings.lecture_rooms'),
(@registrar_id,'comms'),
(@registrar_id,'comms.notices'),
(@registrar_id,'comms.notices.manage'),
(@registrar_id,'comms.notices.analytics'),
(@registrar_id,'comms.tickets'),
(@registrar_id,'system.more'),
(@registrar_id,'system.more.elections_dashboard'),
(@registrar_id,'system.more.election_posts'),
(@registrar_id,'system.more.election_candidates'),
(@registrar_id,'system.more.election_voters'),
(@registrar_id,'system.more.election_results'),
(@registrar_id,'system.more.validation_stats'),
(@registrar_id,'system.more.id_cards'),
(@registrar_id,'system.more.graduating_students'),
(@registrar_id,'system.more.specialisations'),
(@registrar_id,'system.more.year_promotions'),
(@registrar_id,'system.more.student_documents'),
(@registrar_id,'system.more.nche_student_exporter'),
(@registrar_id,'system.more.research_marksheets'),
(@registrar_id,'system.more.academic_results'),
(@registrar_id,'system.more.results_release'),
(@registrar_id,'system.more.results_updates'),
(@registrar_id,'system.more.hold_list'),
(@registrar_id,'system.more.results_audit_log'),
(@registrar_id,'system.more.student_profile'),
(@registrar_id,'system.more.results_analytics'),
(@registrar_id,'system.more.student_results_view');

-- ── Fees Officer permissions ──────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@fees_id,'home.dashboard'),
(@fees_id,'fees'),
(@fees_id,'fees.fee_admin'),
(@fees_id,'fees.fee_admin.dashboard'),
(@fees_id,'fees.fee_admin.access_policy'),
(@fees_id,'fees.fee_admin.access_checker'),
(@fees_id,'fees.fee_admin.structure'),
(@fees_id,'fees.fee_admin.registration'),
(@fees_id,'fees.fee_admin.audit_trail'),
(@fees_id,'fees.fee_admin.other_fees_billing'),
(@fees_id,'fees.fee_admin.bill_waivers'),
(@fees_id,'fees.fee_admin.transactions'),
(@fees_id,'fees.fee_admin.student_ledgers'),
(@fees_id,'fees.fee_admin.double_billing'),
(@fees_id,'fees.fee_admin.active_students_fees');

-- ── Bursar permissions ────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@bursar_id,'home.dashboard'),
(@bursar_id,'fees'),
(@bursar_id,'fees.fee_admin'),
(@bursar_id,'fees.fee_admin.dashboard'),
(@bursar_id,'fees.fee_admin.access_policy'),
(@bursar_id,'fees.fee_admin.access_checker'),
(@bursar_id,'fees.fee_admin.structure'),
(@bursar_id,'fees.fee_admin.registration'),
(@bursar_id,'fees.fee_admin.audit_trail'),
(@bursar_id,'fees.fee_admin.other_fees_billing'),
(@bursar_id,'fees.fee_admin.bill_waivers'),
(@bursar_id,'fees.fee_admin.transactions'),
(@bursar_id,'fees.fee_admin.student_ledgers'),
(@bursar_id,'fees.fee_admin.double_billing'),
(@bursar_id,'fees.fee_admin.active_students_fees'),
(@bursar_id,'fees.bursaries'),
(@bursar_id,'fees.bursaries.dashboard'),
(@bursar_id,'fees.bursaries.schemes'),
(@bursar_id,'fees.bursaries.beneficiaries'),
(@bursar_id,'requisitions'),
(@bursar_id,'requisitions.main'),
(@bursar_id,'requisitions.main.controller'),
(@bursar_id,'requisitions.main.bursar_queue');

-- ── Finance Officer permissions ───────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@fin_id,'home.dashboard'),
(@fin_id,'accounts'),
(@fin_id,'accounts.ledgers'),
(@fin_id,'accounts.ledgers.main_accounts'),
(@fin_id,'accounts.ledgers.sub_accounts'),
(@fin_id,'accounts.ledgers.categories'),
(@fin_id,'accounts.ledgers.general_ledger'),
(@fin_id,'accounts.ledgers.suppliers'),
(@fin_id,'accounts.transactions'),
(@fin_id,'accounts.transactions.journal_entries'),
(@fin_id,'accounts.transactions.payment_vouchers'),
(@fin_id,'accounts.transactions.contra_vouchers'),
(@fin_id,'accounts.control'),
(@fin_id,'accounts.control.finance_dashboard'),
(@fin_id,'accounts.control.financial_periods'),
(@fin_id,'accounts.control.audit_trail'),
(@fin_id,'accounts.control.reversal_request'),
(@fin_id,'accounts.control.correction_request'),
(@fin_id,'accounts.reports'),
(@fin_id,'accounts.reports.trial_balance'),
(@fin_id,'accounts.reports.income_statement'),
(@fin_id,'accounts.reports.balance_sheet'),
(@fin_id,'requisitions'),
(@fin_id,'requisitions.main'),
(@fin_id,'requisitions.main.controller'),
(@fin_id,'requisitions.main.finance_queue');

-- ── Accountant permissions (same as finance_officer minus requisitions) ───
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@acc_id,'home.dashboard'),
(@acc_id,'accounts'),
(@acc_id,'accounts.ledgers'),
(@acc_id,'accounts.ledgers.main_accounts'),
(@acc_id,'accounts.ledgers.sub_accounts'),
(@acc_id,'accounts.ledgers.categories'),
(@acc_id,'accounts.ledgers.general_ledger'),
(@acc_id,'accounts.ledgers.suppliers'),
(@acc_id,'accounts.transactions'),
(@acc_id,'accounts.transactions.journal_entries'),
(@acc_id,'accounts.transactions.payment_vouchers'),
(@acc_id,'accounts.transactions.contra_vouchers'),
(@acc_id,'accounts.control'),
(@acc_id,'accounts.control.finance_dashboard'),
(@acc_id,'accounts.control.financial_periods'),
(@acc_id,'accounts.control.audit_trail'),
(@acc_id,'accounts.reports'),
(@acc_id,'accounts.reports.trial_balance'),
(@acc_id,'accounts.reports.income_statement'),
(@acc_id,'accounts.reports.balance_sheet');

-- ── HR Manager permissions ────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@hr_id,'home.dashboard'),
(@hr_id,'hr'),
(@hr_id,'hr.dashboard'),
(@hr_id,'hr.people'),
(@hr_id,'hr.people.employees'),
(@hr_id,'hr.people.contracts'),
(@hr_id,'hr.people.leave'),
(@hr_id,'hr.payroll'),
(@hr_id,'hr.payroll.management'),
(@hr_id,'hr.payroll.payslips'),
(@hr_id,'hr.payroll.allowances'),
(@hr_id,'hr.payroll.deductions'),
(@hr_id,'hr.settings'),
(@hr_id,'hr.settings.org_structure'),
(@hr_id,'hr.settings.payroll_config'),
(@hr_id,'hr.appraisal'),
(@hr_id,'hr.appraisal.dashboard'),
(@hr_id,'hr.appraisal.sessions'),
(@hr_id,'hr.appraisal.view'),
(@hr_id,'hr.appraisal.reports');

-- ── Procurement Officer permissions ───────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@proc_id,'home.dashboard'),
(@proc_id,'requisitions'),
(@proc_id,'requisitions.main'),
(@proc_id,'requisitions.main.controller');

-- ── VC permissions ────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@vc_id,'home.dashboard'),
(@vc_id,'requisitions'),
(@vc_id,'requisitions.main'),
(@vc_id,'requisitions.main.controller');

-- ── Faculty Staff permissions ─────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@faculty_id,'home.dashboard'),
(@faculty_id,'academics'),
(@faculty_id,'academics.exam'),
(@faculty_id,'academics.allocation'),
(@faculty_id,'academics.allocation.teaching_allocations'),
(@faculty_id,'academics.timetable'),
(@faculty_id,'academics.timetable.view'),
(@faculty_id,'comms'),
(@faculty_id,'comms.notices'),
(@faculty_id,'comms.notices.manage');

-- ── Exam Officer permissions ──────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@exam_id,'home.dashboard'),
(@exam_id,'academics'),
(@exam_id,'academics.exam'),
(@exam_id,'academics.exam.marks_dashboard'),
(@exam_id,'academics.exam.mark_requests'),
(@exam_id,'academics.exam.all_marks'),
(@exam_id,'academics.exam.published_marks'),
(@exam_id,'academics.exam.provisional_marks'),
(@exam_id,'academics.exam.pending_exam_marks'),
(@exam_id,'academics.exam.pending_coursework_marks'),
(@exam_id,'system.more'),
(@exam_id,'system.more.research_marksheets'),
(@exam_id,'system.more.academic_results'),
(@exam_id,'system.more.results_release'),
(@exam_id,'system.more.results_updates'),
(@exam_id,'system.more.hold_list'),
(@exam_id,'system.more.results_audit_log'),
(@exam_id,'system.more.results_analytics'),
(@exam_id,'system.more.student_results_view');

-- ── Admissions Officer permissions ────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@admit_id,'home.dashboard'),
(@admit_id,'academics'),
(@admit_id,'academics.students'),
(@admit_id,'academics.students.online_applications'),
(@admit_id,'academics.students.active_students'),
(@admit_id,'academics.students.all_students');

-- ── Student Services permissions ──────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@svc_id,'home.dashboard'),
(@svc_id,'academics'),
(@svc_id,'academics.students'),
(@svc_id,'academics.students.active_students'),
(@svc_id,'academics.students.all_students'),
(@svc_id,'academics.students.id_card_status'),
(@svc_id,'comms.tickets'),
(@svc_id,'system.more'),
(@svc_id,'system.more.elections_dashboard'),
(@svc_id,'system.more.election_posts'),
(@svc_id,'system.more.election_candidates'),
(@svc_id,'system.more.election_voters'),
(@svc_id,'system.more.election_results'),
(@svc_id,'system.more.id_cards'),
(@svc_id,'system.more.student_documents'),
(@svc_id,'system.more.residence_allocation'),
(@svc_id,'system.more.student_profile');
```

### 28E. Bootstrap SQL

```sql
-- ── role_management_bootstrap.sql ─────────────────────────────────────────
-- Run ONCE after schema + seeds.
-- Replace 'YOUR_ADMIN_USERNAME' with the real admin membership username.
-- ──────────────────────────────────────────────────────────────────────────

INSERT IGNORE INTO sys_user_roles (username, role_id, granted_by, notes)
SELECT 'YOUR_ADMIN_USERNAME', id, 'system', 'Initial super admin bootstrap'
FROM sys_roles WHERE role_code = 'admin';

-- Verify:
SELECT u.username, r.role_name
FROM sys_user_roles u
JOIN sys_roles r ON u.role_id = r.id
WHERE u.username = 'YOUR_ADMIN_USERNAME';
```

---

## 29. Phase 2 — RoleAccessService.cs (Complete File)

> **File:** `COOPERP/App_Code/RoleAccessService.cs`

```csharp
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Slug-based permission service. Called at login to load the user's
/// accessible menu slugs into session, and at page load to enforce access.
/// </summary>
public static class RoleAccessService
{
    public const string SESSION_SLUGS    = "access_slugs";
    public const string SESSION_ROLE     = "user_role_code";
    public const string SESSION_ROLENAME = "user_role_name";
    public const string ADMIN_WILDCARD   = "*";

    // ── Load at login ──────────────────────────────────────────────────────

    public static void LoadUserAccess(string username, HttpSessionState session)
    {
        var slugs    = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        string roleCode  = "";
        string roleName  = "";

        try
        {
            string cs = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();

                // All active, non-expired roles for this user
                const string roleSql = @"
                    SELECT r.role_code, r.role_name
                    FROM sys_user_roles ur
                    JOIN sys_roles r ON ur.role_id = r.id
                    WHERE ur.username = @u AND ur.is_active = 1
                      AND r.is_active = 1
                      AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                    ORDER BY r.id ASC LIMIT 1";

                using (var cmd = new MySqlCommand(roleSql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", username);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            roleCode = dr.GetString(0);
                            roleName = dr.GetString(1);
                        }
                    }
                }

                if (string.IsNullOrEmpty(roleCode)) return; // no role — leave session empty

                // Admin wildcard — full access without slug enumeration
                if (roleCode == "admin")
                {
                    slugs.Add(ADMIN_WILDCARD);
                }
                else
                {
                    // Load all slugs from all the user's active roles (union)
                    const string slugSql = @"
                        SELECT DISTINCT rp.menu_slug
                        FROM sys_role_permissions rp
                        JOIN sys_user_roles ur ON rp.role_id = ur.role_id
                        WHERE ur.username = @u AND ur.is_active = 1
                          AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                          AND rp.can_view = 1";

                    using (var cmd = new MySqlCommand(slugSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@u", username);
                        using (var dr = cmd.ExecuteReader())
                            while (dr.Read()) slugs.Add(dr.GetString(0));
                    }
                }
            }
        }
        catch { /* silent — user gets empty access, will be bounced at RequireSlug */ }

        session[SESSION_SLUGS]    = string.Join(",", slugs);
        session[SESSION_ROLE]     = roleCode;
        session[SESSION_ROLENAME] = roleName;
        session["usertype"]       = roleCode; // feeds legacy sidebar hidden input
    }

    // ── Access checks ──────────────────────────────────────────────────────

    public static bool CanAccess(HttpSessionState session, string slug)
    {
        string raw = session[SESSION_SLUGS] as string ?? "";
        if (string.IsNullOrEmpty(raw)) return false;
        if (raw.Contains(ADMIN_WILDCARD)) return true;
        var parts = raw.Split(new[]{','}, StringSplitOptions.RemoveEmptyEntries);
        return parts.Any(p => string.Equals(p.Trim(), slug, StringComparison.OrdinalIgnoreCase));
    }

    public static bool IsAdmin(HttpSessionState session)
    {
        string raw = session[SESSION_SLUGS] as string ?? "";
        return raw.Contains(ADMIN_WILDCARD);
    }

    public static string GetRoleCode(HttpSessionState session)
        => (session[SESSION_ROLE] as string ?? "").ToLower();

    // ── Page guard ─────────────────────────────────────────────────────────

    /// <summary>
    /// Call at top of Page_Load for any sensitive page.
    /// Redirects to login if not authenticated, 403 if no slug access.
    /// </summary>
    public static void RequireSlug(System.Web.UI.Page page, string slug)
    {
        if (page.Session["username"] == null || page.Session["username"].ToString().Trim() == "")
        {
            page.Response.Redirect("~/Default.aspx", true);
            return;
        }
        if (!CanAccess(page.Session, slug))
        {
            page.Response.Redirect(
                "~/COOPERP/NewScreens/AccessDenied.aspx?slug=" + HttpUtility.UrlEncode(slug),
                true);
        }
    }

    // ── Section defaults (for sidebar accordion) ───────────────────────────

    public static string GetSectionDefaultsJson(HttpSessionState session)
    {
        string roleCode = GetRoleCode(session);
        if (string.IsNullOrEmpty(roleCode)) return "{}";

        // Role → sections that should be open by default
        var defaults = new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            { "dean",            new[]{ "academics", "comms" } },
            { "registrar",       new[]{ "academics", "comms" } },
            { "faculty_staff",   new[]{ "academics" } },
            { "exam_officer",    new[]{ "academics" } },
            { "admissions",      new[]{ "academics" } },
            { "student_services",new[]{ "academics", "comms" } },
            { "fees_officer",    new[]{ "fees" } },
            { "bursar",          new[]{ "fees", "requisitions" } },
            { "finance_officer", new[]{ "accounts", "requisitions" } },
            { "accountant",      new[]{ "accounts" } },
            { "hr_manager",      new[]{ "hr" } },
            { "procurement",     new[]{ "requisitions" } },
            { "vc",              new[]{ "requisitions" } },
            { "admin",           new[]{ "system" } }
        };

        string[] openSections;
        if (!defaults.TryGetValue(roleCode, out openSections))
            openSections = new string[0];

        var parts = openSections.Select(s => "\"" + s + "\":true");
        return "{" + string.Join(",", parts) + "}";
    }
}
```

---

## 30. Phase 3 — Sidebar Refactor Notes

The sidebar refactor keeps HTML generation server-side so JS role-filtering is eliminated entirely.

### What changes in SidebarMaster.master

Replace the entire hardcoded `<ul class="cd-sidebar__menu">` content block with:

```html
<ul class="cd-sidebar__menu">
    <asp:Literal ID="litSidebarMenu" runat="server"></asp:Literal>
</ul>
<!-- Hidden input for section accordion defaults -->
<input type="hidden" id="cdSectionDefaults"
       runat="server" clientidmode="Static"
       value="" />
```

### What changes in SidebarMaster.master.cs

Add to `Page_Load` (after `LoadDropdowns()`):

```csharp
RenderDynamicSidebar();
```

```csharp
private void RenderDynamicSidebar()
{
    string username = Session["username"]?.ToString();
    if (string.IsNullOrEmpty(username)) return;

    string rawSlugs = Session[RoleAccessService.SESSION_SLUGS] as string ?? "";
    bool isAdmin = rawSlugs.Contains(RoleAccessService.ADMIN_WILDCARD);
    var slugSet  = new HashSet<string>(
        rawSlugs.Split(new[]{','}, StringSplitOptions.RemoveEmptyEntries),
        StringComparer.OrdinalIgnoreCase);

    // Always show Dashboard
    var sb = new System.Text.StringBuilder();
    sb.AppendLine(BuildDashboardItem());

    string[] sections = {"academics","fees","accounts","hr","requisitions","comms","system"};
    foreach (string sec in sections)
    {
        // Check if user has ANY slug in this section
        bool hasSection = isAdmin || slugSet.Any(s => s.StartsWith(sec, StringComparison.OrdinalIgnoreCase));
        if (!hasSection) continue;

        // Load menu items for this section from sys_menu_items
        var items = LoadSectionItems(sec);

        // Section heading
        var heading = items.FirstOrDefault(i => i.ItemType == "heading");
        if (heading != null)
            sb.AppendLine($"<li class=\"cd-sidebar__heading\">{heading.Label}</li>");

        // Parents and their children
        foreach (var parent in items.Where(i => i.ItemType == "parent"))
        {
            bool canSeeParent = isAdmin || slugSet.Contains(parent.Slug);
            if (!canSeeParent) continue;

            var children = items.Where(i => i.ParentSlug == parent.Slug).ToList();
            var visibleChildren = children.Where(c => isAdmin || slugSet.Contains(c.Slug)).ToList();
            if (visibleChildren.Count == 0 && !isAdmin) continue;

            sb.AppendLine(BuildParentItem(parent, visibleChildren));
        }

        // Standalone items (not inside a parent)
        foreach (var item in items.Where(i => i.ItemType == "standalone"))
        {
            if (!isAdmin && !slugSet.Contains(item.Slug)) continue;
            sb.AppendLine(BuildStandaloneItem(item));
        }
    }

    litSidebarMenu.Text = sb.ToString();

    // Section defaults for accordion JS
    var cdSectionDefaultsInput = (System.Web.UI.HtmlControls.HtmlInputHidden)
        FindControl("cdSectionDefaults");
    if (cdSectionDefaultsInput != null)
        cdSectionDefaultsInput.Value = RoleAccessService.GetSectionDefaultsJson(Session);
}
```

> **Note:** `LoadSectionItems()`, `BuildParentItem()`, `BuildStandaloneItem()`, and `BuildDashboardItem()` are helper methods that query `sys_menu_items` for a given section and render the appropriate HTML matching the existing `cd-sidebar__*` CSS classes. Full implementation is in Phase 3 of the code.

---

## 31. Phase 5 — Admin UI Page Specs

### UserRoleUsers.aspx
- **Master:** `SidebarMaster.master`
- **Slug guard:** `system.user_roles.users`
- **Grid columns:** Username | Display Name | Role Badges | Status | Expires | [Assign Role] [Remove]
- **AJAX actions:** `action=assign_role` (POST: username, role_id, expires_at, notes), `action=revoke_role` (POST: username, role_id)
- **Search:** client-side filter on Username + Display Name

### UserRoleRoles.aspx
- **Master:** `SidebarMaster.master`
- **Slug guard:** `system.user_roles.roles`
- **Cards layout:** One card per role, colored by `color_hex`
- **Actions:** Create role (modal), Edit role name/description/color, Delete (if not system + 0 users)
- **Safeguard:** `is_system_role = 1` roles cannot be deleted, only edited

### UserRolePermissions.aspx
- **Master:** `SidebarMaster.master`
- **Slug guard:** `system.user_roles.permissions`
- **Layout:** Role selector dropdown → permission matrix table
- **Rows:** All `sys_menu_items` ordered by `sort_order`, visually grouped by section
- **Columns:** Menu Item | VIEW checkbox | (future: EDIT | DELETE)
- **Save:** Bulk AJAX — calculates diff vs. current state, runs INSERTs + DELETEs
- **Auto-propagation:** Granting a subitem → auto-grants its parent and section heading
- **Visual cue:** Section heading rows are dark navy `#05275C`, parent rows are light blue, subitems are indented white

### UserRoleAudit.aspx
- **Master:** `SidebarMaster.master`
- **Slug guard:** `system.user_roles.audit`
- **Filters:** Date range | Action type | Actor | Target user
- **Export:** CSV download of filtered rows
- **Grid:** Timestamp | Actor | Action | Target | Detail | IP

---

## 32. Sidebar System Section — Final HTML Block

This block is inserted into `SidebarMaster.master` inside the System section, after `system.config`, replacing the hardcoded navigation once Phase 3 (dynamic rendering) is complete. In the interim, add it as a static block guarded by a code-behind role check.

```html
<!-- User & Role Management — admin only -->
<li class="cd-sidebar__item cd-sidebar__item--has-submenu" data-roles="admin">
    <a href="javascript:void(0)" class="cd-sidebar__link cd-sidebar__link--toggle">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2"
             stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            <line x1="18" y1="8" x2="23" y2="8"/>
            <line x1="21" y1="5" x2="21" y2="11"/>
        </svg>
        <span>User &amp; Role Management</span>
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2"
             stroke-linecap="round" stroke-linejoin="round"
             class="cd-sidebar__arrow"><polyline points="9 18 15 12 9 6"/></svg>
    </a>
    <ul class="cd-sidebar__submenu">
        <li class="cd-sidebar__subitem">
            <asp:HyperLink ID="lnkUserRoleUsers" runat="server"
                NavigateUrl="~/COOPERP/NewScreens/UserRoleUsers.aspx"
                CssClass="cd-sidebar__sublink">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14"
                     viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                </svg>
                <span>Users</span>
            </asp:HyperLink>
        </li>
        <li class="cd-sidebar__subitem">
            <asp:HyperLink ID="lnkUserRoleRoles" runat="server"
                NavigateUrl="~/COOPERP/NewScreens/UserRoleRoles.aspx"
                CssClass="cd-sidebar__sublink">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14"
                     viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="2" y="7" width="20" height="14" rx="2"/>
                    <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
                </svg>
                <span>Roles</span>
            </asp:HyperLink>
        </li>
        <li class="cd-sidebar__subitem">
            <asp:HyperLink ID="lnkUserRolePermissions" runat="server"
                NavigateUrl="~/COOPERP/NewScreens/UserRolePermissions.aspx"
                CssClass="cd-sidebar__sublink">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14"
                     viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                    <rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/>
                </svg>
                <span>Permission Matrix</span>
            </asp:HyperLink>
        </li>
        <li class="cd-sidebar__subitem">
            <asp:HyperLink ID="lnkUserRoleAudit" runat="server"
                NavigateUrl="~/COOPERP/NewScreens/UserRoleAudit.aspx"
                CssClass="cd-sidebar__sublink">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14"
                     viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
                <span>Audit Log</span>
            </asp:HyperLink>
        </li>
    </ul>
</li>
```
