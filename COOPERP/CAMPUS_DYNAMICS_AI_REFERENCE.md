# Campus Dynamics EMIS — AI Assistant Reference
> Working reference for every session. For full design specs see `NewScreens/DESIGN_SYSTEM.md`.
> Last updated: 2026-03-27

---

## 1. System Identity

Campus Dynamics is a higher-education EMIS for Mountains of the Moon University (MRU), Uganda. It manages student records, academic results, fees, HR/payroll, and finance across two applications:

| App | Path | Purpose |
|-----|------|---------|
| Main system | `CampusDynamics/COOPERP/` | Admin/staff EMIS |
| Student portal | `CampusDynamics_Portal/` | Student self-service |

---

## 2. Tech Stack & Constraints

- **Framework**: ASP.NET 4.0 Web Forms (.NET 4.0)
- **Database**: MySQL 5.6 — use `MySqlConnection`, `MySqlCommand`, `MySqlParameter`
- **UI library**: DevExpress v16.1
- **DX Theme (main)**: Aqua
- **DX Theme (portal)**: Office2010Blue
- **Connection string key**: `vacConnectionString`
- **DB server**: `102.34.160.47` — databases: `campus_dynamics`, `campus_dynamics_accounts`, `campus_dynamics_portal`
- **New screens master page**: `NewScreens/SidebarMaster.master`

---

## 3. Design System (Quick Reference)

Full spec: `NewScreens/DESIGN_SYSTEM.md` — read that before building any screen.

### Key Colors
| Token | Value | Use |
|-------|-------|-----|
| Primary | `#05275C` | Page headers, primary buttons |
| Accent | `#174DA4` | Links, active tabs |
| Surface | `#f5f7fa` | Page bg, table header |
| Border | `#e0e5ed` | All borders |
| Text | `#1a1a2e` | Body text |
| Danger | `#dc3545` | Delete actions |
| Success btn | `#16a34a` | Confirm/save actions |

**OLD color `#422774` (purple) is retired. Never use it.**

### Border-Radius (strict)
- `0` — inputs, buttons, badges, table cells
- `2px` — modals only
- `4px` — cards/containers (optional)
- Never `8px+` on interactive elements

### Typography
- Font: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- Sizes: `10px` labels, `11px` table cells, `12px` body, `13px` modal titles, `15–17px` page title
- No shadows on buttons or cards. Modals only: `box-shadow: 0 12px 40px rgba(0,0,0,.18)`

### CSS Prefixes
`fs-` shared listing/table/modal components | `fm-` finance module | `hr-` HR module | `cd-` global

---

## 4. Database Connection & Query Patterns

```csharp
private string ConnStr =>
    ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
{
    DataTable dt = new DataTable();
    try {
        using (var conn = new MySqlConnection(ConnStr)) {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn)) {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
    } catch { }
    return dt;
}

private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
{
    using (var conn = new MySqlConnection(ConnStr)) {
        conn.Open();
        using (var cmd = new MySqlCommand(sql, conn)) {
            if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
            return cmd.ExecuteNonQuery();
        }
    }
}
```

Always use parameterized queries (`@param`). Never concatenate user input into SQL.

---

## 5. File Naming Conventions

- New screens: `PascalCase.aspx` + `PascalCase.aspx.cs` in `NewScreens/`
- All new screens inherit `SidebarMaster.master`
- CSS for a page goes inline `<style>` in the `.aspx` file (no separate per-page CSS file)
- SQL migration scripts: `NewScreens/migration_*.sql`

---

## 6. ASP.NET Patterns (Critical)

### Postback-safe Dropdown — REQUIRED for all form dropdowns
```csharp
protected void Page_Load(object sender, EventArgs e)
{
    LoadMyDropdown();  // ALWAYS unconditional
    string posted = Request.Form[ddlMyList.UniqueID];
    if (!string.IsNullOrEmpty(posted)) TrySelect(ddlMyList, posted);
    if (!IsPostBack) BindGrid();
}
private void TrySelect(DropDownList ddl, string value)
{
    var item = ddl.Items.FindByValue(value);
    if (item != null) item.Selected = true;
}
```

### Modal via Hidden Fields
```csharp
// hdnModalMode = "NEW" | "EDIT" | "LOAD"
protected void btnSave_Click(object sender, EventArgs e)
{
    string mode = hdnModalMode.Value.Trim().ToUpper();
    if (mode == "LOAD") { LoadForEdit(hdnEditId.Value); return; }
    if (mode == "NEW")  InsertRecord();
    else                UpdateRecord(hdnEditId.Value);
}
```

### Multi-select ListBox — read raw POST data
```csharp
// Never use listBox.Items — items are cleared on postback
string[] selected = Request.Form.GetValues(lstItems.UniqueID);
if (selected == null || selected.Length == 0) { ShowModalError("..."); return; }
```

### ScriptManager Notifications
```csharp
// Success
ScriptManager.RegisterStartupScript(this, GetType(), "saved",
    "closeModal('myModal');showToast('Saved.','success');", true);

// Error (keep modal open)
string js = "(function(){document.getElementById('myModal').style.display='flex';" +
    "var r=document.getElementById('modalResult');r.className='fs-toast fs-toast--error';" +
    "r.style.display='block';r.textContent='" + msg.Replace("'","\\'") + "';})();";
ScriptManager.RegisterStartupScript(this, GetType(), "err", js, true);
```

### DevExpress Opacity — integer only
```aspx
<ModalBackgroundStyle Opacity="72" />   <%-- Correct: integer 0-100 --%>
<%-- WRONG: Opacity="0.72" causes runtime error --%>
```

---

## 7. What NEVER to Do

| Never | Reason |
|-------|--------|
| `border-radius: 8px+` on inputs/buttons/badges | Violates design language |
| Gradient backgrounds on buttons or cards | Flat design only |
| `box-shadow` on buttons or cards | Modals only |
| Color `#422774` purple | Old retired scheme |
| `AutoPostBack="true"` on dropdowns inside modals | Causes unintended postback / modal close |
| Load dropdowns only in `if (!IsPostBack)` when they're posted in forms | `SelectedValue` is empty on postback |
| `ddl.SelectedValue` without reloading items first | Always empty |
| Iterate `listBox.Items` for selections after postback | Items cleared — always empty |
| `DevExpress Opacity="0.72"` (decimal) | Runtime error — must be integer |
| Concatenate user input into SQL strings | SQL injection risk |
| `git add -A` when committing | May include sensitive/large files |
| `<asp:Button Enabled="false">` with `UseSubmitBehavior="false"` | `__doPostBack` not rendered — button will never fire (see §13) |
| `EnableCallBacks="false"` on DX grids | Breaks filtering, sorting, pagination (see §12) |
| `BindGrid()` only in `if (!IsPostBack)` for DX grids | DX callbacks need data on every request (see §12) |
| Use `acad_ProgramData` table | Old/wrong table — use `acad_programme` instead (see §11) |
| Trust hidden fields for student identity on portal | Use `PortalHelper.GetRegno(this)` instead |

---

## 8. Reference Implementations

| File | What it benchmarks |
|------|--------------------|
| `NewScreens/FeesStructure.aspx` | **Primary benchmark** — complete design system |
| `NewScreens/NewFacultyProgrammes.aspx` | Modal CRUD, postback-safe dropdowns |
| `NewScreens/HRContracts.aspx` | Action popover, status badges |
| `NewScreens/HRPayroll.aspx` | Multi-panel, batch operations |
| `NewScreens/FeesManagement.aspx` | Tab navigation + sub-tabs |

When in doubt about any UI decision, look at `FeesStructure.aspx` first.

---

## 9. Module Inventory

| Module | Key Files | Notes |
|--------|-----------|-------|
| Fees Structure | `NewScreens/FeesStructure.aspx` | Fee templates, year/semester grids |
| Fees Management | `NewScreens/FeesManagement.aspx` | Fee assignment and overrides |
| Fees Registration | `NewScreens/FeesRegistration.aspx` | Student fee registration |
| HR Payroll | `NewScreens/HRPayroll.aspx` | Salary computation, batch processing |
| HR Contracts | `NewScreens/HRContracts.aspx` | Employment contracts |
| HR Allowances | `NewScreens/HRAllowances.aspx` | Staff allowance definitions |
| HR Deductions | `NewScreens/HRDeductions.aspx` | Payroll deduction rules |
| HR Config | `NewScreens/HRConfig.aspx` | HR system configuration |
| Academic Results | `NewScreens/AcademicResults.aspx` | Result entry and management |
| Course Registration | `NewScreens/CourseRegistration.aspx` | Student course enrollment |
| Programme Courses | `NewScreens/NewProgrammeCourses.aspx` | Programme-course assignment (modal CRUD, searchable dropdowns) |
| Student Info | `NewScreens/NewStudentInfo.aspx` | Student record management |
| Student Registration | `NewScreens/NewStudentRegistration.aspx` | New student onboarding |
| NCHE Exporter | `NewScreens/NCHEExporter.aspx` | Regulatory reporting export |
| Finance | `NewScreens/FinanceDashboard.aspx` | Finance overview and reporting |
| Payment Vouchers | `NewScreens/PaymentVouchers.aspx` | Outgoing payment processing |
| Accounts (classic) | `accounts/*.aspx` | Journals, receipts, vouchers |
| Login (portal) | `fonts/lg_modern.ascx` | Modern login control |
| Portal Dashboard | `CampusDynamics_Portal/MyApplications_Modern.aspx` | Delegates to `UserControls/Security/SystemApplications_Modern.ascx` |
| Portal Course Reg | `CampusDynamics_Portal/CourseRegistration.aspx` | 3-step wizard: Select → Confirm → Done |
| Portal Results | `CampusDynamics_Portal/Results.aspx` | Student results view |
| Portal Fees | `CampusDynamics_Portal/Fees.aspx` | Student fees/billing view |
| Portal Profile | `CampusDynamics_Portal/Profile.aspx` | Student profile self-service |
| Portal Coursework | `CampusDynamics_Portal/Coursework.aspx` | Coursework results |
| Portal Notices | `CampusDynamics_Portal/Notices.aspx` | Announcements/notices |

---

*Full design spec: `NewScreens/DESIGN_SYSTEM.md`*

---

## 10. Student Portal Architecture

### URLs & Hosting
| Site | URL | Purpose |
|------|-----|---------|
| Admin | `https://eadmin.mru.ac.ug` | Staff/admin EMIS |
| Portal | `https://eportal.mru.ac.ug` | Student self-service |

### Portal Connection Strings
The portal uses three connection strings (defined in `CampusDynamics_Portal/web.config`):

| Key | Database | Use |
|-----|----------|-----|
| `campus_dynamics_portalConnectionString` | `campus_dynamics` | Academic data (students, programmes, registration, results) |
| `campus_dynamics_accountsConnectionString` | `campus_dynamics_accounts` | Financial data (fees, billing, payments) |
| `vacConnectionString` | `campus_dynamics_portal` | Portal-specific data (notices, announcements) |

### Portal Page Architecture
- **Master page**: `CampusDynamics_Portal/PortalMaster.master`
- **Dashboard**: `MyApplications_Modern.aspx` → delegates to user control `UserControls/Security/SystemApplications_Modern.ascx` (+ `.ascx.cs`)
- **Course Registration**: `CampusDynamics_Portal/CourseRegistration.aspx` (+ `.aspx.cs`) — 3-step wizard
- **Results, Fees, Profile, Coursework, Notices**: Built as separate pages under portal root

### Portal CSS Prefixes
| Prefix | Scope |
|--------|-------|
| `sp-` | Student portal dashboard components (`sp-card`, `sp-banner`, `sp-reg-row`, `sp-badge`, `sp-notice`, `sp-results-tbl`) |
| `cr-` | Course registration page (`cr-wizard`, `cr-step`, `cr-success-*`) |

### Portal Security
- **`PortalHelper.GetRegno(this)`** — the **only** secure way to get the logged-in student's registration number on portal pages. Never trust hidden fields or query strings for the reg number.

---

## 11. Database Schema Reference

### Core Academic Tables (in `campus_dynamics`)

#### `acad_programme` — THE canonical programme table
| Column | Type | Notes |
|--------|------|-------|
| `progcode` | PK | Programme code (e.g., `BCS`) |
| `progname` | varchar | Full programme name |

> **WARNING**: `acad_ProgramData` (columns `ProgCode`, `ProgramName`) is an OLD/WRONG table. Never use it — always use `acad_programme`.

#### `acad_student` — Student records
| Column | Type | Notes |
|--------|------|-------|
| `regno` | PK | Student registration number |
| `progid` | FK → `acad_programme.progcode` | Programme enrolled in |
| `specialisation` | FK → `acad_specialisation.spec_id` | Specialisation (nullable) |
| `studsesion` | varchar | Student session (e.g., `DAY`, `WEEKEND`) |

#### `acad_specialisation` — Programme specialisations
| Column | Type | Notes |
|--------|------|-------|
| `spec_id` | PK | Specialisation ID |
| `prog_id` | FK → `acad_programme.progcode` | Parent programme |
| `spec` | varchar | Specialisation name |
| `abbrev` | varchar | Abbreviation |
| `is_active` | int | Active flag |

#### `acad_registration` — Semester registration records
| Column | Type | Notes |
|--------|------|-------|
| `regno` | FK → `acad_student.regno` | Student |
| `acad_year` | varchar | Academic year (e.g., `2025/2026`) |
| `studyyear` | int | Year of study (1, 2, 3...) |
| `semester` | int | Semester number |
| `regstatus` | varchar | Registration status text |

#### `acad_course_registration` (in `campus_dynamics_portal` schema)
| Column | Type | Notes |
|--------|------|-------|
| `regno` | FK | Student |
| `courseID` | FK | Course code |
| `acad_year` | varchar | Academic year |
| `semester` | int | Semester |

> **Cross-DB access**: From the academic DB connection, reference as `campus_dynamics_portal.acad_course_registration`.

### Canonical JOIN Pattern (student → programme → registration)
```sql
SELECT s.progid, p.progname, sp.spec AS spec_name,
       r.studyyear, r.semester, r.regstatus
FROM acad_registration r
INNER JOIN acad_student s ON r.regno = s.regno
LEFT JOIN acad_programme p ON s.progid = p.progcode
LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id
WHERE r.regno = @r AND r.acad_year = @y
ORDER BY r.semester DESC LIMIT 1
```

### Financial Tables (in `campus_dynamics_accounts`)

#### `fin_studentfeestracking` — Student fee transactions
| Column | Type | Notes |
|--------|------|-------|
| `regno` | FK | Student |
| `acadyear` | varchar | Academic year |
| `item_code` | varchar | Fee item code |
| `trans_type` | varchar | `Bill` or `Payment` |
| `amount` | decimal | Transaction amount |

---

## 12. DevExpress Grid Patterns (Critical)

### EnableCallBacks MUST be true
```aspx
<dx:ASPxGridView EnableCallBacks="true" ...>
```
Setting `EnableCallBacks="false"` **breaks** filtering, sorting, and pagination because DX AJAX is disabled. Always keep `true`.

### Bind on EVERY request (not just !IsPostBack)
```csharp
protected void Page_Load(object sender, EventArgs e)
{
    BindGrid();  // ALWAYS — DX callbacks need data on every request
    if (!IsPostBack) { /* initial-only logic */ }
}
```
If `BindGrid()` only runs on `!IsPostBack`, DX callbacks (filter, page, sort) will fail because the grid has no data source.

### DX Glass Theme CSS Overrides (design system compliance)
Apply these to make DX grids match the Campus Dynamics design system:
```css
.dxgvControl_Glass { border: 1px solid #e0e5ed !important; }
.dxgvHeader_Glass td {
    background: #f5f7fa !important; color: #555 !important;
    font-size: 10px !important; font-weight: 600 !important;
    text-transform: uppercase !important; letter-spacing: .3px !important;
    padding: 9px 12px !important; border-bottom: 2px solid #e0e5ed !important;
}
.dxgvDataRow_Glass td {
    font-size: 11px !important; color: #1a1a2e !important;
    padding: 8px 12px !important; border-bottom: 1px solid #f0f2f5 !important;
}
.dxgvFilterRow_Glass td {
    padding: 4px 6px !important; background: #fff !important;
}
.dxgvFilterRow_Glass input {
    border: 1px solid #e0e5ed !important; border-radius: 0 !important;
    font-size: 11px !important; padding: 3px 6px !important;
}
.dxgvPagerBar_Glass {
    background: #f5f7fa !important; border-top: 1px solid #e0e5ed !important;
    padding: 6px 12px !important;
}
```

### Action Columns — Disable Filter & Sort
```aspx
<dx:GridViewDataColumn Caption="Actions" Width="80">
    <Settings AllowAutoFilter="False" AllowSort="False" />
</dx:GridViewDataColumn>
```

### Responsive Grid Wrapper
Wrap DX grids in an overflow container for horizontal scroll on small screens:
```html
<div class="fs-grid-wrap" style="overflow-x:auto;">
    <dx:ASPxGridView ... />
</div>
```

---

## 13. ASP.NET Button Pitfalls

### Never use `Enabled="false"` on server buttons
```aspx
<!-- WRONG: prevents __doPostBack from rendering — button will NEVER work -->
<asp:Button ID="btn" runat="server" Enabled="false" UseSubmitBehavior="false" OnClick="btn_Click" />

<!-- CORRECT: use JavaScript to disable visually, keep Enabled="true" server-side -->
<asp:Button ID="btn" runat="server" UseSubmitBehavior="false" OnClick="btn_Click"
    OnClientClick="this.disabled=true;this.value='Processing...';" />
```
When `Enabled="false"` is set server-side on an `<asp:Button>` with `UseSubmitBehavior="false"`, ASP.NET does NOT render the `onclick="__doPostBack(...)"` attribute, so even if JavaScript later sets `disabled=false`, clicking the button does nothing.

**Pattern for deferred-enable buttons**: Set `Enabled="true"` on the server, then immediately disable via JS in `DOMContentLoaded`. Re-enable via JS when the user completes a prerequisite step.

---

## 14. Portal Dashboard Data Flow

`SystemApplications_Modern.ascx.cs` loads the dashboard in `Page_Load`:
```
Page_Load → LoadUserInfo(regno)          // Name, photo, reg number
          → LoadStudentDetails(regno, ay) // Programme, specialisation, year, semester, courses, status
          → LoadFinancialStats(regno)     // Billed, Paid, Balance KPIs
          → LoadCGPA(regno)              // Cumulative GPA
          → LoadLatestResults(regno, ay)  // Most recent semester results table
          → LoadAnnouncements()          // Active notices
          → LoadFeeBreakdown(regno, ay)  // Semester fee line items
          → BindApplications()           // Portal app shortcuts
```

### Registration Info Card (right column)
Shows 7 rows: Programme, Specialisation (if set), Academic Year, Study Year, Semester, Courses Registered, Status.
- Programme comes from `acad_programme.progname` (joined via `acad_student.progid`)
- Specialisation from `acad_specialisation.spec` (joined via `acad_student.specialisation`)
- Course count from `campus_dynamics_portal.acad_course_registration` (COUNT for current year+semester)
- Status is color-coded: green (`sp-reg-row__val--ok`) if Registered/Active, red (`sp-reg-row__val--warn`) otherwise

---

## 15. Change Log

### 2026-03-27 — Session changes

#### CourseRegistration.aspx — Submit button fix
- **Problem**: `<asp:Button Enabled="false">` prevented `__doPostBack` from rendering; clicking after JS enable did nothing
- **Fix**: Removed `Enabled="false"`, added `OnClientClick` for double-click prevention, added `disableSubmit()` in `DOMContentLoaded` to disable until confirmation
- **Security**: Changed `btnRegister_Click` to use `PortalHelper.GetRegno(this)` instead of `hfRegNo.Value`

#### CourseRegistration.aspx — Step 3 success wizard page
- **Added**: Third wizard step ("Done") after successful registration
- Changed wizard from 2-step to 3-step indicator: Select Courses → Confirm → Done
- `ShowSuccessStep()` queries all registered courses, builds summary with "Just Registered" vs "Previously" badges
- Stats strip shows: Newly Registered count, Total Courses count, Semester
- CSS classes: `.cr-success-icon`, `.cr-success-title`, `.cr-success-sub`, `.cr-success-stats`, `.cr-success-stat`, `.cr-success-table`, `.cr-success-divider`

#### NewProgrammeCourses.aspx — Grid fix
- **Problem**: `EnableCallBacks="false"` broke DX filtering and pagination; no design system CSS
- **Fix**: Set `EnableCallBacks="true"`, moved `BindGrid()` to run on every request (not just `!IsPostBack`)
- Added full DX Glass theme CSS overrides matching design system
- Added `.fs-grid-wrap` responsive overflow container
- Action column: `AllowAutoFilter="False"`, `AllowSort="False"`
- Removed unused `SettingsEditing Mode="Inline"`, set `AllowGroup="False"`
- Course code column: `ForeColor="#05275C"`

#### SystemApplications_Modern.ascx — Dashboard Registration Info fix
- **Problem**: Used wrong table `acad_ProgramData` (doesn't exist / obsolete); showed only 4 fields
- **Fix**: Rewrote `LoadStudentDetails()`:
  - Changed to correct `acad_programme` table with `LEFT JOIN acad_specialisation`
  - Added course registration count from `campus_dynamics_portal.acad_course_registration`
  - Expanded info card from 4 rows to 7 rows (Programme, Specialisation, Academic Year, Study Year, Semester, Courses Registered, Status)
  - Added color-coded status (green/red)
- CSS: Added `.sp-reg-row__val--ok` (green), `.sp-reg-row__val--warn` (red), `max-width: 60%` + `word-break` on `.sp-reg-row__val`
