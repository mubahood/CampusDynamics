# AJAX Module Development Guide — Campus Dynamics (COOPERP)

> **Reference Implementation:** `BillWaivers.aspx` + `BillWaivers.aspx.cs`  
> This document captures the architecture, patterns, and conventions used to build the Bill Waiver module — a self-contained AJAX-driven WebForms page with wizard UI, modal overlays, and transactional database writes. Use this as a blueprint for future modules.

---

## 1. Architecture Overview

```
┌───────────────────────────────────────────────────────────┐
│  BillWaivers.aspx                                         │
│  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐  │
│  │ CSS     │ │ HTML     │ │ Modals   │ │ JavaScript   │  │
│  │ (bw-)   │ │ (server  │ │ (wizard, │ │ (IIFE, AJAX, │  │
│  │ prefix  │ │  rendered│ │  detail, │ │  state mgmt) │  │
│  │         │ │  + aspx  │ │  reverse)│ │              │  │
│  └─────────┘ └──────────┘ └──────────┘ └──────────────┘  │
└────────────────────┬──────────────────────────────────────┘
                     │ XHR (?ajax=action)
                     ▼
┌───────────────────────────────────────────────────────────┐
│  BillWaivers.aspx.cs                                      │
│  Page_Load() routes AJAX by ?ajax= query string           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐  │
│  │ search       │ │ bills        │ │ apply / reverse  │  │
│  │ (GET, JSON)  │ │ (GET, JSON)  │ │ (POST, JSON)     │  │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────────┘  │
│         │                │                │               │
│         ▼                ▼                ▼               │
│    campus_dynamics   campus_dynamics_accounts              │
│    (vacConnStr)      (accountsConnStr)                    │
│    └── acad_student  └── fin_studentfeestracking          │
│                      └── fin_ledger                       │
│                      └── fin_bill_waivers                 │
│                      └── fin_bill_waiver_items            │
└───────────────────────────────────────────────────────────┘
```

### Key Principle: **Single-file AJAX routing in Page_Load**

Instead of separate ASHX handlers or Web API controllers, all AJAX logic lives in the `.aspx.cs` code-behind. The `Page_Load` method inspects `?ajax=` and routes to the appropriate handler method, each of which writes JSON directly to `Response` and calls `Response.End()`.

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
    if (ajax == "search")  { HandleStudentSearch(); return; }
    if (ajax == "bills")   { HandleLoadBills();     return; }
    if (ajax == "apply")   { HandleApplyWaiver();   return; }
    if (ajax == "detail")  { HandleWaiverDetail();  return; }
    if (ajax == "reverse") { HandleReverseWaiver(); return; }

    if (!IsPostBack)
    {
        LoadWaiverHistory();  // Server-rendered on first load
    }
}
```

This approach:
- Keeps everything in one page (no scattered handlers)
- Works with Forms Auth seamlessly (session + cookies travel with XHR)
- Allows the page to render server-side HTML on first load AND handle AJAX on subsequent requests

---

## 2. AJAX Handler Pattern

Every AJAX handler follows this exact structure:

```csharp
private void HandleSomeAction()
{
    Response.Clear();
    Response.ContentType = "application/json";
    try
    {
        // 1. Read input (QueryString for GET, Request.InputStream for POST)
        // 2. Validate
        // 3. Execute DB logic
        // 4. Write success JSON
        Response.Write("{\"ok\":true, ...}");
    }
    catch (Exception ex)
    {
        Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
    }
    Response.End();
}
```

### GET Endpoints (lightweight reads)
- Use `Request.QueryString["param"]` for input
- Return arrays: `{"results":[...]}` or `{"bills":[...]}`
- Example: `?ajax=search&q=sabia`, `?ajax=bills&regno=MRU2027000002`

### POST Endpoints (writes/mutations)
- Read JSON body via `new System.IO.StreamReader(Request.InputStream).ReadToEnd()`
- Parse with `JavaScriptSerializer().Deserialize<Dictionary<string, object>>(body)`
- Wrap all writes in a MySQL transaction
- Return: `{"ok":true, ...}` or `{"ok":false, "error":"..."}`

---

## 3. JSON Handling

### Parsing (Server)
Use `System.Web.Script.Serialization.JavaScriptSerializer` (available in .NET 4.0):

```csharp
using System.Web.Script.Serialization;

var jss = new JavaScriptSerializer();
var data = jss.Deserialize<Dictionary<string, object>>(body);
string value = data.ContainsKey("key") ? Convert.ToString(data["key"]) : "";
```

For arrays, cast to `System.Collections.ArrayList`:
```csharp
System.Collections.ArrayList items = data["items"] as System.Collections.ArrayList;
foreach (object raw in items)
{
    Dictionary<string, object> item = raw as Dictionary<string, object>;
    int tid = item.ContainsKey("tid") ? Convert.ToInt32(item["tid"]) : 0;
}
```

### Building JSON (Server)
Use `StringBuilder` with `AppendFormat` and the `JsEsc()` helper:

```csharp
private static string JsEsc(string val)
{
    if (string.IsNullOrEmpty(val)) return "";
    return val.Replace("\\", "\\\\").Replace("\"", "\\\"")
              .Replace("\r", "").Replace("\n", "\\n");
}
```

### Consuming (Client)
```javascript
var xhr = new XMLHttpRequest();
xhr.open('POST', pageUrl + '?ajax=apply', true);
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.onload = function () {
    var resp = JSON.parse(xhr.responseText);
    if (resp.ok) { /* success */ }
    else { alert(resp.error); }
};
xhr.send(JSON.stringify(payload));
```

---

## 4. Database Transaction Pattern

All mutating operations use a **single MySQL transaction** with try/catch/rollback:

```csharp
using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
{
    conn.Open();
    MySqlTransaction tx = conn.BeginTransaction();
    try
    {
        // Step 1: Validate (SELECT ... FOR UPDATE to lock rows)
        // Step 2: INSERT into fin_studentfeestracking
        // Step 3: INSERT into fin_ledger (GL mirror — dual-write)
        // Step 4: INSERT into module-specific tables
        tx.Commit();
        // Write success JSON
    }
    catch
    {
        try { tx.Rollback(); } catch { }
        throw;  // Let outer catch write error JSON
    }
}
```

### Dual-Write Pattern (Financial Transactions)
Every financial transaction MUST write to BOTH:
1. **`fin_studentfeestracking`** — the student fees tracking table
2. **`fin_ledger`** — the general ledger

The GL entry's `voucherNo` = the tracking table's `TID` (via `LastInsertedId`).

| Operation | Tracking trans_type | Ledger transactionType |
|-----------|-------------------|----------------------|
| Bill      | `'Bill'`          | `'DR'`               |
| Payment   | `'Payment'`       | `'CR'`               |
| Waiver    | `'Payment'`       | `'CR'`               |
| Reversal  | `'Bill'`          | `'DR'`               |

### Row Locking (TOCTOU Prevention)
Use `SELECT ... FOR UPDATE` within the transaction for validation queries:
```sql
SELECT TID FROM fin_studentfeestracking
WHERE TID = @tid AND regno = @r AND trans_type = 'Bill'
FOR UPDATE
```
This prevents two concurrent requests from waiving/reversing the same record.

---

## 5. Connection Strings

Two databases, two connection strings:

| Database | Config Key | Property | Contains |
|----------|-----------|----------|----------|
| `campus_dynamics_accounts` | `accountsConnectionString` | `AcctConnStr` | All financial data (fees, ledger, billing) |
| `campus_dynamics` | `vacConnectionString` | `MainConnStr` | Student records, programmes, HR |

Define as properties in the code-behind:
```csharp
private string AcctConnStr
{
    get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
}
```

**Note:** `FinanceDB` (static helper in `App_Code/Finance/`) is NOT available in COOPERP pages — use direct `MySqlConnection`/`MySqlCommand` instead.

---

## 6. Frontend Architecture

### CSS Conventions (from DESIGN_SYSTEM.md)
- **Module prefix:** Every module gets a unique CSS prefix (e.g., `bw-` for Bill Waivers, `fs-` for Fees Structure)
- **Colors:** Primary navy `#05275C`, accent blue `#174DA4`, green `#2e7d32`, red `#c62828`
- **Border-radius:** Always `0` (sharp corners)
- **No gradients/shadows** except modals (modal gets `box-shadow`)
- **BEM-lite naming:** `.bw-card`, `.bw-card__header`, `.bw-card--active`
- **Font sizes:** Labels `9-10px` uppercase, body `11-12px`, headings `13-15px`

### JavaScript Pattern: IIFE + Window Exports
```javascript
(function () {
    'use strict';

    // Private state
    var _step = 1;
    var _student = null;

    // Page URL for AJAX calls
    var _pageUrl = window.location.pathname;

    // Public functions (attached to window for onclick handlers)
    window.openWizard = function () { ... };
    window.closeWizard = function () { ... };

    // Private functions
    function doSearch(q) { ... }
    function renderAC(results) { ... }

    // XSS-safe escape for HTML output
    function esc(s) {
        if (!s) return '';
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(s));
        return d.innerHTML.replace(/"/g, '&quot;');
    }

    function formatNum(n) {
        return Number(n).toLocaleString('en-US', { maximumFractionDigits: 0 });
    }
})();
```

### Modal / Overlay Pattern
```html
<div id="myOverlay" class="mod-overlay">
    <div class="mod-modal">
        <div class="bw-modal__header">...</div>
        <div class="mod-modal__body" id="bodyContent">...</div>
        <div class="bw-modal__footer">
            <button class="bw-btn bw-btn--ghost" onclick="closeModal()">Cancel</button>
            <button class="bw-btn bw-btn--primary" onclick="confirm()">Confirm</button>
        </div>
    </div>
</div>
```

Open/close by toggling CSS class:
```javascript
document.getElementById('myOverlay').className = 'mod-overlay mod-overlay--visible';
document.getElementById('myOverlay').className = 'mod-overlay';
```

### Wizard Pattern (Multi-Step Modal)
1. Define step tabs with `.bw-steps` > `.bw-step` indicators
2. Define panels with `.bw-panel`, show with `.bw-panel--active`
3. Track `_step` variable, update UI via `updateStepUI()`
4. `wizardNext()` validates current step before advancing
5. `wizardPrev()` decrements step
6. Step indicators get states: default → `.bw-step--active` → `.bw-step--done`

---

## 7. Auto-Migration Pattern

Tables are auto-created on first page load using `CREATE TABLE IF NOT EXISTS`:

```csharp
private void EnsureWaiverTables()
{
    try
    {
        string ddl = @"CREATE TABLE IF NOT EXISTS fin_bill_waivers (
            waiver_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
            ...
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8";

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(ddl, conn)) { cmd.ExecuteNonQuery(); }
        }
    }
    catch { /* Silently ignore — tables likely exist */ }
}
```

Call this in `Page_Load` before any AJAX routing. This ensures the module is self-deploying — no manual migration scripts needed for production.

---

## 8. User Identity / Audit Trail

```csharp
private string GetCurrentUser()
{
    // 1. Check Session (set by login flow)
    if (Session != null && Session["ScreenName"] != null) return Session["ScreenName"].ToString();
    if (Session != null && Session["username"] != null) return Session["username"].ToString();
    // 2. Fall back to Forms Auth identity
    if (User != null && User.Identity != null && User.Identity.IsAuthenticated)
        return User.Identity.Name;
    // 3. Try HttpContext directly
    if (HttpContext.Current != null && HttpContext.Current.User != null
        && HttpContext.Current.User.Identity != null
        && HttpContext.Current.User.Identity.IsAuthenticated)
        return HttpContext.Current.User.Identity.Name;
    return "Unknown";
}
```

**Important:** In the CampusDynamics admin app, `Session["ScreenName"]` is only set by the Portal login. The admin login only sets `Session["username"]`. Always include the `User.Identity.Name` fallback for cases where session expired but auth cookie is still valid.

---

## 9. Server-Side Rendered History + Client-Side Modals

The landing page uses **server-side rendering** for the history table (in `LoadWaiverHistory()`), but all interactions (view, create, reverse) use **client-side AJAX modals**.

This hybrid pattern gives:
- Fast initial page load (no JS needed for first paint)
- Rich interactions without full postbacks
- Stats computed server-side with `<asp:Literal>` controls

After a mutation (create waiver, reverse waiver), the page reloads:
```javascript
window.location.reload();  // Refreshes server-rendered history
```

---

## 10. C# 5 Compatibility Checklist

The project targets .NET 4.0 / C# 5. **Do NOT use:**

| Feature | C# Version | Alternative |
|---------|-----------|-------------|
| `?.` (null-conditional) | C# 6 | `x != null ? x.Foo : default` |
| `$""` (string interpolation) | C# 6 | `String.Format("...", args)` |
| `nameof()` | C# 6 | `"PropertyName"` literal |
| Expression-bodied members | C# 6 | Full `{ get { return ...; } }` |
| `??=` (null-coalesce assign) | C# 8 | `if (x == null) x = val;` |
| `switch` expressions | C# 8 | `if/else if` chain |

---

## 11. File Structure Convention

```
COOPERP/
├── NewScreens/
│   ├── SidebarMaster.master       ← Menu entries added here
│   ├── BillWaivers.aspx           ← CSS + HTML + JavaScript (single file)
│   ├── BillWaivers.aspx.cs        ← All backend logic (AJAX handlers)
│   └── ...
├── sql/
│   ├── migration_bill_waivers.sql ← Schema (also auto-created by EnsureWaiverTables)
│   └── test_bill_waivers.sql      ← Verification queries
└── App_Code/
    └── Finance/
        └── FinanceDB.cs           ← NOT usable by COOPERP pages (different App_Code)
```

### Adding a Sidebar Menu Entry
Edit `SidebarMaster.master`, find the relevant section `<ul>`, and add:
```html
<li>
    <asp:HyperLink ID="lnkModuleName" runat="server"
        NavigateUrl="~/COOPERP/NewScreens/ModuleName.aspx">
        <img src="..." /> Module Name
    </asp:HyperLink>
</li>
```

---

## 12. Testing Workflow

1. **Schema:** Run migration SQL or let `EnsureWaiverTables()` auto-create
2. **Unit test queries:** Write SQL verification scripts (see `test_bill_waivers.sql`)
3. **Compilation:** Check for zero errors in VS Code before deploying
4. **AJAX endpoints:** Test each endpoint directly:
   - `GET /BillWaivers.aspx?ajax=search&q=sabia`
   - `GET /BillWaivers.aspx?ajax=bills&regno=MRU2027000002`
   - `POST /BillWaivers.aspx?ajax=apply` with JSON body
5. **End-to-end:** Run the full wizard flow, then verify with SQL queries
6. **Balance verification:** Always check both `fin_studentfeestracking` and `fin_ledger` balances match

---

## 13. Quick-Start Template

To create a new module following this pattern:

1. Copy `BillWaivers.aspx` and `BillWaivers.aspx.cs` as templates
2. Change class name: `COOPERP_NewScreens_YourModule`
3. Change CSS prefix: `ym-` (for "Your Module")
4. Replace AJAX handlers with your logic
5. Replace wizard steps with your workflow
6. Add `EnsureYourTables()` for auto-migration
7. Add sidebar menu entry in `SidebarMaster.master`
8. Test with a known student (MRU2027000002)
