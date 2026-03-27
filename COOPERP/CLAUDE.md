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
| Student Info | `NewScreens/NewStudentInfo.aspx` | Student record management |
| Student Registration | `NewScreens/NewStudentRegistration.aspx` | New student onboarding |
| NCHE Exporter | `NewScreens/NCHEExporter.aspx` | Regulatory reporting export |
| Finance | `NewScreens/FinanceDashboard.aspx` | Finance overview and reporting |
| Payment Vouchers | `NewScreens/PaymentVouchers.aspx` | Outgoing payment processing |
| Accounts (classic) | `accounts/*.aspx` | Journals, receipts, vouchers |
| Login (portal) | `fonts/lg_modern.ascx` | Modern login control |

---

*Full design spec: `NewScreens/DESIGN_SYSTEM.md`*
