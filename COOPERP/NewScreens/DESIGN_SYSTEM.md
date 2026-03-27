# Campus Dynamics — Design System
> **Authoritative reference. Supersedes all previous design documents.**
> Last updated: 2026-03-25

---

## 1. Overview & Purpose

This document defines the definitive visual and code standards for all screens in the `NewScreens/` module of the Campus Dynamics EMIS. Any older document referencing purple (`#422774`) is obsolete and must be ignored. The design language is **flat, compact, and navy-dominant** — no gradients, no large radii, no decorative shadows.

Benchmark implementation: `NewScreens/FeesStructure.aspx` — all new screens must match its visual fidelity.

---

## 2. Color System

### CSS Custom Properties (define in `<style>` or `theme.css`)

```css
:root {
    --cd-primary:          #05275C;   /* Headers, icon boxes, primary buttons, page borders */
    --cd-primary-hover:    #041d45;   /* Hover on primary buttons */
    --cd-accent:           #174DA4;   /* Links, active tab underline, focus rings */
    --cd-accent-hover:     #0f3a7d;   /* Hover on accent buttons */
    --cd-surface:          #f5f7fa;   /* Page background, table header bg, secondary panels */
    --cd-surface-card:     #ffffff;   /* Card / modal backgrounds */
    --cd-border:           #e0e5ed;   /* All borders and dividers */
    --cd-border-input:     #cdd3de;   /* Input, select, button borders */
    --cd-text-primary:     #1a1a2e;   /* Primary body text */
    --cd-text-secondary:   #555;      /* Labels, secondary text */
    --cd-text-muted:       #888;      /* Metadata, placeholder text */
    --cd-success-bg:       #e6f4ea;   /* Success badge/toast bg */
    --cd-success-text:     #155724;   /* Success text */
    --cd-success-border:   #c3e6cb;   /* Success border */
    --cd-success-btn:      #16a34a;   /* Success action button */
    --cd-danger-btn:       #dc3545;   /* Danger/delete button */
    --cd-warning-btn:      #d97706;   /* Warning/deactivate button */
    --cd-amber-bg:         #fff8e1;   /* Warning badge bg */
    --cd-amber-text:       #b45309;   /* Warning badge text */
    --cd-code-bg:          rgba(23,77,164,.07);   /* Code badge background */
    --cd-code-border:      rgba(23,77,164,.15);   /* Code badge border */
}
```

### Token Usage Rules

| Situation | Token |
|-----------|-------|
| Page header bar, icon box, primary CTA button | `--cd-primary` |
| Hovered primary button | `--cd-primary-hover` |
| Hyperlinks, active tab indicator, focus ring | `--cd-accent` |
| Page and card background | `--cd-surface` |
| Card, modal, table row background | `--cd-surface-card` |
| Table borders, card borders, dividers | `--cd-border` |
| Input, select, textarea borders | `--cd-border-input` |
| Body copy | `--cd-text-primary` |
| Form labels, column headers | `--cd-text-secondary` |
| Placeholder, timestamps, meta info | `--cd-text-muted` |
| "Active" / "Approved" status badge | `--cd-success-*` |
| Delete / remove actions | `--cd-danger-btn` |
| "Pending" / deactivate / warning | `--cd-amber-*` or `--cd-warning-btn` |
| Programme code, student number badges | `--cd-code-bg` + `--cd-code-border` |

---

## 3. Typography

### Font Family
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, sans-serif;
```

### Scale

| Size | Usage |
|------|-------|
| `10px` | Column header labels (UPPERCASE, `letter-spacing: 0.4px`), badges, filter labels |
| `11px` | Table cell text, secondary UI, small action buttons |
| `12px` | Base body text, form inputs, primary UI elements |
| `13px` | Modal titles, page sub-titles, prominent form labels |
| `15px–17px` | Page title (`fm-page-header__title`) |
| `20px–22px` | KPI / stat values (`pf-stat__value`) |

### Weights
- `400` — body text, table cells
- `500` — labels, badge text, tab labels
- `600` — card titles, modal titles, stat values
- `700` — page header title only

---

## 4. Spacing & Layout Scale

| Value | Application |
|-------|-------------|
| `3px–4px` | Gap between inline icon and label text |
| `5px–8px` | Badge padding, small button inner padding |
| `8px–12px` | Standard button padding, table cell padding |
| `10px–14px` | Card header/body padding, modal section padding |
| `14px–18px` | Modal body padding, major section spacing |
| `20px–24px` | Between top-level sections |

### Grid / Layout
- Stats row: `display:grid; grid-template-columns: repeat(4,1fr); gap:10px;`
- Filter bar: `display:flex; flex-wrap:wrap; align-items:flex-end; gap:10px;`
- Form rows: `display:flex; flex-wrap:wrap; gap:12px;` — each group `flex:1 1 220px`

---

## 5. Border-Radius Rules (CRITICAL — strict)

| Element | Radius |
|---------|--------|
| All inputs, selects, textareas | `0` |
| All buttons (including icon buttons) | `0` |
| Badges, status chips, code tags | `0` |
| Action trigger buttons | `0` |
| Table cells | `0` |
| Modal overlay + modal container | `2px` |
| Stat/KPI cards | `4px` (allowed, not required) |
| Container cards (`fs-card`) | `4px` (allowed, not required) |
| Avatar circles / loading spinners | `50%` |

**Rule**: If in doubt, use `0`. Large radii (`8px+`) are forbidden on all interactive or content components.

---

## 6. Component Reference

### 6.1 Page Header

```css
.fm-page-header {
    display: flex; align-items: center; justify-content: space-between;
    background: #05275C; color: #fff;
    padding: 14px 20px; border-bottom: 3px solid #041d45;
}
.fm-page-header__left { display: flex; align-items: center; gap: 12px; }
.fm-page-header__icon {
    width: 40px; height: 40px; background: rgba(255,255,255,.12);
    border-radius: 4px; display: flex; align-items: center; justify-content: center;
}
.fm-page-header__title { font-size: 16px; font-weight: 700; }
.fm-page-header__sub   { font-size: 12px; opacity: .75; margin-top: 2px; }
```

```html
<div class="fm-page-header">
  <div class="fm-page-header__left">
    <div class="fm-page-header__icon">
      <!-- SVG icon, white stroke, 22×22 viewBox -->
      <svg width="22" height="22" fill="none" stroke="#fff" stroke-width="1.8"
           viewBox="0 0 24 24"><path d="M12 2l9 7v13H3V9z"/></svg>
    </div>
    <div>
      <div class="fm-page-header__title">Module Name</div>
      <div class="fm-page-header__sub">Brief description of what this page does</div>
    </div>
  </div>
  <!-- Optional right-side action -->
  <button class="fs-btn fs-btn--ghost-inv">+ Add New</button>
</div>
```

---

### 6.2 Tab Navigation (cross-page)

```css
.fm-tabs { display:flex; gap:2px; background:#f0f2f5; border-bottom:2px solid #e0e5ed; padding:0 20px; }
.fm-tab  { padding:9px 16px; font-size:12px; font-weight:500; color:#555;
           text-decoration:none; border-bottom:2px solid transparent; margin-bottom:-2px; }
.fm-tab:hover { color:#05275C; }
.fm-tab--active { color:#05275C; border-bottom-color:#05275C; font-weight:600; }
```

```html
<div class="fm-tabs">
  <a class="fm-tab" href="FeesManagement.aspx">Fees Management</a>
  <a class="fm-tab fm-tab--active" href="FeesStructure.aspx">Fee Structure</a>
  <a class="fm-tab" href="FeesRegistration.aspx">Fee Registration</a>
</div>
```

---

### 6.3 Section Sub-Tabs (within page)

```css
.fs-section-tabs { display:flex; gap:4px; margin-bottom:14px; }
.fs-section-tab  {
    padding:7px 14px; font-size:11px; font-weight:500; background:#fff;
    border:1px solid #e0e5ed; color:#555; cursor:pointer; border-radius:0;
}
.fs-section-tab--active { background:#05275C; color:#fff; border-color:#05275C; }
```

```html
<div class="fs-section-tabs">
  <button class="fs-section-tab fs-section-tab--active"
          onclick="showPanel('panel-a', this)">Section A</button>
  <button class="fs-section-tab"
          onclick="showPanel('panel-b', this)">Section B</button>
</div>
<div id="panel-a" class="fs-panel-section">...</div>
<div id="panel-b" class="fs-panel-section" style="display:none;">...</div>
```

```javascript
function showPanel(id, btn) {
    document.querySelectorAll('.fs-panel-section').forEach(p => p.style.display = 'none');
    document.querySelectorAll('.fs-section-tab').forEach(b => b.classList.remove('fs-section-tab--active'));
    document.getElementById(id).style.display = 'block';
    btn.classList.add('fs-section-tab--active');
}
```

---

### 6.4 Filter Bar

```css
.fs-filter-bar { display:flex; flex-wrap:wrap; align-items:flex-end; gap:10px;
                 background:#fff; padding:12px 16px; border:1px solid #e0e5ed;
                 border-radius:4px; margin-bottom:14px; }
.fs-filter-grp { display:flex; flex-direction:column; gap:4px; }
.fs-filter-grp__label { font-size:10px; font-weight:600; text-transform:uppercase;
                         letter-spacing:.4px; color:#555; }
.fs-filter-select { padding:6px 8px; border:1px solid #cdd3de; font-size:12px;
                    border-radius:0; min-width:140px; }
```

```html
<div class="fs-filter-bar">
  <div class="fs-filter-grp">
    <label class="fs-filter-grp__label">Academic Year</label>
    <asp:DropDownList ID="ddlYear" runat="server" CssClass="fs-filter-select" />
  </div>
  <div class="fs-filter-grp">
    <label class="fs-filter-grp__label">Programme</label>
    <asp:DropDownList ID="ddlProg" runat="server" CssClass="fs-filter-select" />
  </div>
  <asp:Button ID="btnFilter" runat="server" CssClass="fs-btn fs-btn--primary"
              Text="Apply" OnClick="btnFilter_Click" />
  <asp:Button ID="btnReset" runat="server" CssClass="fs-btn fs-btn--ghost"
              Text="Reset" OnClick="btnReset_Click" />
</div>
```

---

### 6.5 Stats / KPI Cards

```css
.pf-stats { display:grid; grid-template-columns:repeat(4,1fr); gap:10px; margin-bottom:16px; }
.pf-stat  { background:#fff; border:1px solid #e0e5ed; border-radius:4px;
            padding:14px 16px; }
.pf-stat__label { font-size:10px; font-weight:600; text-transform:uppercase;
                   letter-spacing:.4px; color:#888; margin-bottom:4px; }
.pf-stat__value { font-size:22px; font-weight:700; color:#05275C; line-height:1; }
.pf-stat__sub   { font-size:11px; color:#888; margin-top:4px; }
```

```html
<div class="pf-stats">
  <div class="pf-stat">
    <div class="pf-stat__label">TOTAL STUDENTS</div>
    <div class="pf-stat__value">1,284</div>
    <div class="pf-stat__sub">enrolled this year</div>
  </div>
  <div class="pf-stat">
    <div class="pf-stat__label">OUTSTANDING FEES</div>
    <div class="pf-stat__value" id="statOutstanding">—</div>
    <div class="pf-stat__sub">UGX</div>
  </div>
</div>
```

---

### 6.6 Card + Table

```css
.fs-card           { background:#fff; border:1px solid #e0e5ed; border-radius:4px;
                     overflow:hidden; margin-bottom:16px; }
.fs-card__header   { display:flex; align-items:center; justify-content:space-between;
                     padding:11px 16px; border-bottom:1px solid #e0e5ed; background:#f5f7fa; }
.fs-card__title    { font-size:13px; font-weight:600; color:#1a1a2e; }
.fs-card__meta     { font-size:11px; color:#888; }

.fs-table          { width:100%; border-collapse:collapse; font-size:11px; }
.fs-table thead tr { background:#f5f7fa; }
.fs-table th       { padding:8px 12px; text-align:left; font-size:10px; font-weight:600;
                     text-transform:uppercase; letter-spacing:.4px; color:#555;
                     border-bottom:2px solid #e0e5ed; white-space:nowrap; }
.fs-table td       { padding:9px 12px; border-bottom:1px solid #e0e5ed; color:#1a1a2e; vertical-align:middle; }
.fs-table tbody tr:hover { background:#f9fafc; }
.fs-table tbody tr:last-child td { border-bottom:none; }
```

```html
<div class="fs-card">
  <div class="fs-card__header">
    <div class="fs-card__title">Fee Structure Records</div>
    <div class="fs-card__meta">
      <asp:Label ID="lblCount" runat="server" Text="0 records" />
    </div>
  </div>
  <table class="fs-table">
    <thead>
      <tr>
        <th><input type="checkbox" id="chkAll" onclick="toggleAll(this)" /></th>
        <th>Code</th>
        <th>Name</th>
        <th>Amount</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <!-- Populated via GridView or Repeater -->
    </tbody>
  </table>
</div>
```

---

### 6.7 Action Popover Menu

```css
.fs-action-wrap    { position:relative; display:inline-block; }
.fs-action-trigger {
    padding:5px 10px; font-size:11px; background:#fff; border:1px solid #cdd3de;
    cursor:pointer; border-radius:0; color:#333; white-space:nowrap;
}
.fs-action-trigger--open { background:#05275C; color:#fff; border-color:#05275C; }
.fs-action-menu {
    display:none; position:absolute; right:0; top:100%; min-width:150px;
    background:#fff; border:1px solid #e0e5ed; box-shadow:0 4px 12px rgba(0,0,0,.1);
    z-index:999; border-radius:2px;
}
.fs-action-menu--visible        { display:block; }
.fs-action-menu__item           { display:block; width:100%; text-align:left;
                                   padding:8px 14px; font-size:12px; border:none;
                                   background:none; cursor:pointer; color:#1a1a2e; }
.fs-action-menu__item:hover     { background:#f5f7fa; }
.fs-action-menu__item--danger   { color:#dc3545; }
.fs-action-menu__item--danger:hover { background:#fef5f5; }
.fs-action-menu__divider        { border-top:1px solid #e0e5ed; margin:4px 0; }
```

```html
<div class="fs-action-wrap">
  <button type="button" class="fs-action-trigger" onclick="toggleMenu(this)">
    Actions &#9660;
  </button>
  <div class="fs-action-menu">
    <button class="fs-action-menu__item" onclick="openEdit('<%# Eval("id") %>')">Edit</button>
    <button class="fs-action-menu__item" onclick="openView('<%# Eval("id") %>')">View</button>
    <div class="fs-action-menu__divider"></div>
    <button class="fs-action-menu__item fs-action-menu__item--danger"
            onclick="confirmDelete('<%# Eval("id") %>')">Delete</button>
  </div>
</div>
```

```javascript
function toggleMenu(trigger) {
    document.querySelectorAll('.fs-action-menu--visible').forEach(function(m) {
        if (m !== trigger.nextElementSibling) {
            m.classList.remove('fs-action-menu--visible');
            m.previousElementSibling.classList.remove('fs-action-trigger--open');
        }
    });
    var menu = trigger.nextElementSibling;
    var isOpen = menu.classList.contains('fs-action-menu--visible');
    menu.classList.toggle('fs-action-menu--visible', !isOpen);
    trigger.classList.toggle('fs-action-trigger--open', !isOpen);
}
document.addEventListener('click', function(e) {
    if (!e.target.closest('.fs-action-wrap')) {
        document.querySelectorAll('.fs-action-menu--visible').forEach(function(m) {
            m.classList.remove('fs-action-menu--visible');
            m.previousElementSibling.classList.remove('fs-action-trigger--open');
        });
    }
});
```

---

### 6.8 Modal Pattern

```css
.fs-modal-overlay {
    display:none; position:fixed; inset:0; background:rgba(0,0,0,.45);
    z-index:1000; align-items:center; justify-content:center;
}
/* Show: set display:flex via JS */
.fs-modal {
    background:#fff; border-radius:2px; width:520px; max-width:95vw;
    max-height:90vh; overflow-y:auto; box-shadow:0 12px 40px rgba(0,0,0,.18);
}
.fs-modal--wide   { width:720px; }
.fs-modal--xlarge { width:96vw; }

.fs-modal__header { background:#05275C; color:#fff; padding:14px 18px;
                    display:flex; align-items:center; justify-content:space-between; }
.fs-modal__title  { font-size:13px; font-weight:600; }
.fs-modal__close  { background:none; border:none; color:#fff; font-size:20px;
                    cursor:pointer; line-height:1; padding:0; opacity:.8; }
.fs-modal__close:hover { opacity:1; }
.fs-modal__body   { padding:18px; }
.fs-modal__footer { padding:12px 18px; border-top:1px solid #e0e5ed;
                    display:flex; justify-content:flex-end; gap:8px; background:#f9fafc; }

.fs-form-row     { display:flex; flex-wrap:wrap; gap:12px; margin-bottom:12px; }
.fs-form-group   { display:flex; flex-direction:column; gap:4px; flex:1 1 200px; }
.fs-form-label   { font-size:11px; font-weight:600; color:#555; }
.fs-form-input,
.fs-form-select,
.fs-form-textarea { padding:7px 9px; border:1px solid #cdd3de; font-size:12px;
                    border-radius:0; width:100%; box-sizing:border-box; }
.fs-form-textarea { resize:vertical; min-height:72px; }
```

```html
<div id="modalCreate" class="fs-modal-overlay">
  <div class="fs-modal">
    <div class="fs-modal__header">
      <span class="fs-modal__title">Add New Record</span>
      <button class="fs-modal__close" onclick="closeModal('modalCreate')">&#215;</button>
    </div>
    <div class="fs-modal__body">
      <div class="fs-form-row">
        <div class="fs-form-group">
          <label class="fs-form-label">Name *</label>
          <asp:TextBox ID="txtName" runat="server" CssClass="fs-form-input" />
        </div>
        <div class="fs-form-group">
          <label class="fs-form-label">Category</label>
          <asp:DropDownList ID="ddlCategory" runat="server" CssClass="fs-form-select" />
        </div>
      </div>
      <div id="modalResult" style="display:none;"></div>
    </div>
    <div class="fs-modal__footer">
      <button class="fs-btn fs-btn--ghost" onclick="closeModal('modalCreate')">Cancel</button>
      <asp:Button ID="btnSaveModal" runat="server" CssClass="fs-btn fs-btn--primary"
                  Text="Save" OnClick="btnSave_Click" />
    </div>
  </div>
</div>
```

```javascript
function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }
// Close on overlay click
document.querySelectorAll('.fs-modal-overlay').forEach(function(ov) {
    ov.addEventListener('click', function(e) {
        if (e.target === ov) closeModal(ov.id);
    });
});
```

---

### 6.9 Batch Selection Bar

```css
.fs-batch-bar {
    position:fixed; bottom:0; left:0; right:0; background:#05275C;
    color:#fff; padding:12px 24px; display:none;
    align-items:center; justify-content:space-between;
    z-index:500; border-top:3px solid #041d45;
}
.fs-batch-bar--visible      { display:flex; }
.fs-batch-bar__count        { font-size:15px; font-weight:700; margin-right:6px; }
.fs-batch-bar__label        { font-size:12px; opacity:.8; }
.fs-batch-bar__actions      { display:flex; gap:8px; }
.fs-batch-btn               { padding:7px 14px; font-size:11px; font-weight:600;
                               border:none; cursor:pointer; border-radius:0; }
.fs-batch-btn--activate     { background:#16a34a; color:#fff; }
.fs-batch-btn--delete       { background:#dc3545; color:#fff; }
.fs-batch-btn--clear        { background:transparent; color:#fff;
                               border:1px solid rgba(255,255,255,.4); }
```

```html
<div id="batchBar" class="fs-batch-bar">
  <div class="fs-batch-bar__info">
    <span class="fs-batch-bar__count" id="batchCount">0</span>
    <span class="fs-batch-bar__label">records selected</span>
  </div>
  <div class="fs-batch-bar__actions">
    <button class="fs-batch-btn fs-batch-btn--activate" onclick="batchOp('ACTIVATE')">Activate</button>
    <button class="fs-batch-btn fs-batch-btn--delete"   onclick="batchOp('DELETE')">Delete</button>
    <button class="fs-batch-btn fs-batch-btn--clear"    onclick="clearBatch()">Clear</button>
  </div>
</div>
```

---

### 6.10 Toast / Inline Notifications

```css
.fs-toast { padding:10px 16px; font-size:12px; font-weight:500; margin-bottom:14px;
             border-radius:2px; display:none; }
.fs-toast--success { background:#e6f4ea; color:#155724; border:1px solid #c3e6cb; }
.fs-toast--error   { background:#fef5f5; color:#dc3545; border:1px solid #f5c6cb; }
```

```csharp
// Server-side: after save/delete
ScriptManager.RegisterStartupScript(this, GetType(), "toast",
    "showToast('Record saved successfully.', 'success');", true);

// JS function (include once in master/page)
```

```javascript
function showToast(msg, type) {
    var t = document.getElementById('pageToast');
    t.className = 'fs-toast fs-toast--' + (type || 'success');
    t.textContent = msg;
    t.style.display = 'block';
    setTimeout(function() { t.style.display = 'none'; }, 4000);
}
```

---

### 6.11 Code / Monospace Badge

```css
.fs-code {
    font-family: Consolas, "Courier New", monospace;
    font-size: 11px; font-weight: 600;
    background: rgba(23,77,164,.07); border: 1px solid rgba(23,77,164,.15);
    color: #174DA4; padding: 2px 6px; border-radius: 0;
}
```

```html
<span class="fs-code">PROG-001</span>
<span class="fs-code">2024/2025</span>
```

---

### 6.12 Status Badges

```css
.fs-badge            { font-size:10px; font-weight:600; padding:3px 7px;
                        border-radius:0; text-transform:uppercase; letter-spacing:.3px; }
.fs-badge--green     { background:#e6f4ea; color:#155724; border:1px solid #c3e6cb; }
.fs-badge--amber     { background:#fff8e1; color:#b45309; border:1px solid #fcd34d; }
.fs-badge--red       { background:#fef5f5; color:#dc3545; border:1px solid #f5c6cb; }
.fs-badge--primary   { background:rgba(5,39,92,.08); color:#05275C;
                        border:1px solid rgba(5,39,92,.2); }
.fs-badge--blue      { background:rgba(23,77,164,.08); color:#174DA4;
                        border:1px solid rgba(23,77,164,.2); }
```

```html
<span class="fs-badge fs-badge--green">Active</span>
<span class="fs-badge fs-badge--amber">Pending</span>
<span class="fs-badge fs-badge--red">Inactive</span>
<span class="fs-badge fs-badge--primary">Draft</span>
<span class="fs-badge fs-badge--blue">Submitted</span>
```

---

### 6.13 Buttons

```css
.fs-btn           { padding:7px 16px; font-size:12px; font-weight:500;
                    border:1px solid transparent; cursor:pointer; border-radius:0;
                    display:inline-flex; align-items:center; gap:5px; }
.fs-btn--primary  { background:#05275C; color:#fff; border-color:#05275C; }
.fs-btn--primary:hover { background:#041d45; }
.fs-btn--accent   { background:#174DA4; color:#fff; border-color:#174DA4; }
.fs-btn--accent:hover { background:#0f3a7d; }
.fs-btn--success  { background:#16a34a; color:#fff; border-color:#16a34a; }
.fs-btn--danger   { background:#dc3545; color:#fff; border-color:#dc3545; }
.fs-btn--ghost    { background:#fff; color:#333; border-color:#cdd3de; }
.fs-btn--ghost:hover { background:#f5f7fa; }
.fs-btn--ghost-inv { background:transparent; color:#fff; border:1px solid rgba(255,255,255,.5); }
.fs-btn--ghost-inv:hover { background:rgba(255,255,255,.1); }
.fs-btn--sm       { padding:4px 10px; font-size:11px; }
```

---

### 6.14 Year / Collapsible Section (Fee Grid groups)

```css
.fs-year-section         { margin-bottom:10px; border:1px solid #e0e5ed; border-radius:4px; overflow:hidden; }
.fs-year-header          { background:#f0f2f7; padding:10px 16px; cursor:pointer;
                            display:flex; align-items:center; justify-content:space-between;
                            font-size:12px; font-weight:600; color:#05275C; }
.fs-year-header:hover    { background:#e8ebf2; }
.fs-year-header__toggle  { font-size:16px; line-height:1; color:#888; }
.fs-year-body            { /* visible by default; toggle display:none to collapse */ }
```

```html
<div class="fs-year-section">
  <div class="fs-year-header" onclick="toggleYear(this)">
    <span>Year 1 — Semester 1</span>
    <span class="fs-year-header__toggle">&#9660;</span>
  </div>
  <div class="fs-year-body">
    <table class="fs-table">...</table>
  </div>
</div>
```

```javascript
function toggleYear(header) {
    var body = header.nextElementSibling;
    var visible = body.style.display !== 'none';
    body.style.display = visible ? 'none' : 'block';
    header.querySelector('.fs-year-header__toggle').innerHTML = visible ? '&#9658;' : '&#9660;';
}
```

---

## 7. ASP.NET Code-Behind Patterns

### 7.1 Postback-safe Server-side Dropdown (REQUIRED pattern)

Dropdowns that are submitted in forms MUST be loaded unconditionally (not inside `!IsPostBack`). After reload, restore selection from raw POST data.

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    LoadProgrammeDropdown();  // ALWAYS — not inside !IsPostBack
    string posted = Request.Form[ddlProgramme.UniqueID];
    if (!string.IsNullOrEmpty(posted))
        TrySelect(ddlProgramme, posted);

    if (!IsPostBack)
        BindGrid();
}

private void LoadProgrammeDropdown()
{
    DataTable dt = ExecuteQuery(
        "SELECT prog_id, prog_name FROM programmes WHERE status='A' ORDER BY prog_name");
    ddlProgramme.Items.Clear();
    ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
    foreach (DataRow r in dt.Rows)
        ddlProgramme.Items.Add(new ListItem(r["prog_name"].ToString(), r["prog_id"].ToString()));
}

private void TrySelect(DropDownList ddl, string value)
{
    ListItem item = ddl.Items.FindByValue(value);
    if (item != null) item.Selected = true;
}
```

### 7.2 Modal via Hidden Fields + Invisible Trigger Button

```aspx
<asp:HiddenField ID="hdnModalMode" runat="server" />  <%-- "NEW" | "EDIT" | "LOAD" --%>
<asp:HiddenField ID="hdnEditId"    runat="server" />
<asp:Button ID="btnLoadTrigger" runat="server" style="display:none"
            OnClick="btnSave_Click" />
<asp:Button ID="btnSaveModal" runat="server" CssClass="fs-btn fs-btn--primary"
            Text="Save" OnClick="btnSave_Click" />
```

```csharp
protected void btnSave_Click(object sender, EventArgs e)
{
    string mode = hdnModalMode.Value.Trim().ToUpper();
    if (mode == "LOAD") { LoadForEdit(hdnEditId.Value); return; }
    if (mode == "NEW")  { InsertRecord(); }
    else                { UpdateRecord(hdnEditId.Value); }
}

private void LoadForEdit(string id)
{
    DataTable dt = ExecuteQuery(
        "SELECT * FROM my_table WHERE id=@id",
        new MySqlParameter("@id", id));
    if (dt.Rows.Count == 0) return;
    DataRow r = dt.Rows[0];
    txtName.Text = r["name"].ToString();
    TrySelect(ddlCategory, r["category_id"].ToString());
    // Re-open modal via JS
    ScriptManager.RegisterStartupScript(this, GetType(), "reopen",
        "document.getElementById('modalCreate').style.display='flex';", true);
}
```

### 7.3 Multi-select ListBox on Postback

Items are cleared/reloaded each `Page_Load`, so `.SelectedItems` is empty. Read raw POST data:

```csharp
string[] selected = Request.Form.GetValues(lstItems.UniqueID);
if (selected == null || selected.Length == 0)
{
    ShowModalError("Please select at least one item.");
    return;
}
foreach (string val in selected)
{
    // process val
}
```

### 7.4 Standard DB Helpers

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
    } catch { /* log if needed */ }
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

### 7.5 ScriptManager Notifications

```csharp
// Success: close modal + show toast
ScriptManager.RegisterStartupScript(this, GetType(), "saved",
    "closeModal('modalCreate');showToast('Record saved successfully.','success');", true);

// Error: keep modal open, show inline error
private void ShowModalError(string msg, string modalId = "modalCreate")
{
    BindGrid();
    string js = "(function(){" +
        "document.getElementById('" + modalId + "').style.display='flex';" +
        "var r=document.getElementById('modalResult');" +
        "r.className='fs-toast fs-toast--error';r.style.display='block';" +
        "r.textContent=" + JsString(msg) + ";})();";
    ScriptManager.RegisterStartupScript(this, GetType(), "modErr", js, true);
}

private string JsString(string s) =>
    "'" + s.Replace("\\","\\\\").Replace("'","\\'") + "'";
```

### 7.6 DevExpress Controls — Opacity (integer, NOT decimal)

```aspx
<%-- CORRECT --%>
<dx:ASPxPopupControl ID="popConfirm" runat="server" ...>
    <ModalBackgroundStyle Opacity="72" />
</dx:ASPxPopupControl>

<%-- WRONG — runtime error --%>
<%-- <ModalBackgroundStyle Opacity="0.72" /> --%>
```

---

## 8. CSS Naming Conventions

Each page/module uses a **2–3 letter scoped prefix** to prevent class collisions.

| Prefix | Module / Page |
|--------|---------------|
| `cd-` | Global shared (CSS variables, reset, shared utilities) |
| `fm-` | Finance module shared (page header, tabs) |
| `fs-` | FeesStructure + shared listing components (cards, tables, modals, buttons, badges) |
| `pf-` | Programme fees modal and stat cards |
| `pb-` | Process billing modal |
| `hr-` | HR module pages (HRPayroll, HRContracts, etc.) |

**Naming follows BEM-lite** `block__element--modifier`:

```
.fs-card              ← block
.fs-card__header      ← element
.fs-card__title       ← element
.fs-btn               ← block
.fs-btn--primary      ← modifier
.fs-btn--sm           ← modifier
.fs-badge--green      ← modifier
```

New pages MUST introduce their own prefix. Reuse `fs-` classes for listing/table/modal structures where they are already defined in shared CSS.

---

## 9. Anti-Patterns — Do NOT Do

| Anti-pattern | Why |
|--------------|-----|
| `border-radius: 8px+` on inputs, buttons, badges | Violates flat design language |
| Gradient backgrounds on buttons or cards | Flat design — solid fills only |
| `box-shadow` on buttons or non-modal elements | Shadows on modals only |
| Color `#422774` purple anywhere | OLD scheme — replaced by navy `#05275C` |
| `AutoPostBack="true"` on dropdowns inside modals | Causes unintended full postback / modal close |
| Loading dropdowns only inside `if (!IsPostBack)` when they're submitted in forms | Returns empty `SelectedValue` on postback |
| Reading `ddl.SelectedValue` without reloading items first | Empty string every time |
| Iterating `listBox.Items` for selected items after postback | Items are cleared — always empty |
| `DevExpress Opacity="0.72"` (decimal) | Runtime parser error — must be integer 0–100 |
| Inline styles for repeated patterns | Define a CSS class instead |
| Making GridView columns `ReadOnly` in `gvMain_CellEditorInitialize` | Breaks inline batch editing |
| `<asp:ScriptManager>` inside an `<asp:UpdatePanel>` | Must be outside any UpdatePanel |

---

## 10. Reference Implementations

| File | What it demonstrates |
|------|---------------------|
| `NewScreens/FeesStructure.aspx` | **Primary benchmark** — full design system: filter bar, stats cards, listing, action menus, collapsible year sections, fee grids, batch bar, modals |
| `NewScreens/NewFacultyProgrammes.aspx` | Modal CRUD (create / edit / delete), postback-safe dropdowns |
| `NewScreens/HRContracts.aspx` | Action popover pattern, inline status badges, contract state machine |
| `NewScreens/HRPayroll.aspx` | Multi-panel layout, batch operations, create modals |
| `NewScreens/FeesManagement.aspx` | Cross-page tab navigation + section sub-tabs pattern |

---

## 11. File Structure

```
COOPERP/
├── NewScreens/
│   ├── css/
│   │   ├── sidebar.css        ← Sidebar nav styles
│   │   └── theme.css          ← Global shared tokens, reset, shared utilities
│   ├── SidebarMaster.master   ← Master page for all NewScreens
│   ├── SidebarMaster.master.cs
│   ├── FeesStructure.aspx     ← PRIMARY BENCHMARK
│   ├── FeesManagement.aspx
│   ├── HRPayroll.aspx
│   ├── HRContracts.aspx
│   ├── DESIGN_SYSTEM.md       ← THIS FILE
│   └── DESIGN_PRINCIPLES.md   ← Short redirect doc
├── fonts/
│   ├── lg_modern.ascx         ← Modern login control
│   └── lg.ascx                ← Classic login (fallback)
├── css/
│   └── login_modern.css
└── CLAUDE.md                  ← AI assistant working reference
```

---

*End of Design System. All new screens must conform to these specifications.*
