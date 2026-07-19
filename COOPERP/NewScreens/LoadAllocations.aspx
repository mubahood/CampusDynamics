<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LoadAllocations.aspx.cs" Inherits="COOPERP_NewScreens_LoadAllocations" Title="Teaching Allocations - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== TEACHING ALLOCATIONS PAGE (prefix: la-) ========================== */

/* Stats Row */
.la-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; margin-bottom: 10px; }
.la-stat { background: #fff; border: 1px solid #e0e5ed; padding: 8px 11px; display: flex; align-items: center; gap: 9px; position: relative; overflow: hidden; }
.la-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.la-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.la-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.la-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.la-stat--total    { --stat-c:#174DA4; } .la-stat--total .la-stat__icon    { background:#e8f0fc; } .la-stat--total .la-stat__val    { color:#174DA4; }
.la-stat--sched    { --stat-c:#2e7d32; } .la-stat--sched .la-stat__icon    { background:#e6f4ea; } .la-stat--sched .la-stat__val    { color:#2e7d32; }
.la-stat--unsched  { --stat-c:#e65100; } .la-stat--unsched .la-stat__icon  { background:#fce8de; } .la-stat--unsched .la-stat__val  { color:#e65100; }
.la-stat--lecturers{ --stat-c:#6a1b9a; } .la-stat--lecturers .la-stat__icon{ background:#f3e5f5; } .la-stat--lecturers .la-stat__val{ color:#6a1b9a; }

/* Header */
.la-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 9px; }
.la-header__left { display: flex; align-items: center; gap: 9px; }
.la-header__icon { width: 30px; height: 30px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.la-header__icon svg { color: #fff; }
.la-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.la-header__sub   { font-size: 10px; color: #888; margin-top: 1px; }

/* Filter bar */
.la-filters { display: flex; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; align-items: flex-end; }
.la-filters__group { display: flex; flex-direction: column; gap: 2px; }
.la-filters__label { font-size: 9px; font-weight: 600; text-transform: uppercase; letter-spacing: .3px; color: #666; }
.la-filters select, .la-filters input[type=text] { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; min-width: 130px; }
.la-filters select:focus { border-color: #174DA4; outline: none; }
.la-info-band { background: #e8f0fc; border: 1px solid #c7d8f7; padding: 5px 11px; font-size: 10px; color: #174DA4; margin-bottom: 8px; display: flex; gap: 12px; flex-wrap: wrap; }
.la-info-band span { font-weight: 600; }

/* Card */
.la-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 10px; }
.la-card__header { padding: 8px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.la-card__title  { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Table */
.la-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.la-table th { background:#f5f7fa; padding:7px 12px; text-align:left; font-size:10px; text-transform:uppercase; letter-spacing:.3px; color:#555; font-weight:600; border-bottom:2px solid #e0e5ed; white-space:nowrap; }
.la-table td { padding:6px 12px; border-bottom:1px solid #f0f2f5; color:#1a1a2e; vertical-align:middle; }
.la-table tbody tr:hover { background:#f0f4ff; }

/* Day badge */
.la-day { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; }
.la-day--sched   { background:#e8f0fc; color:#174DA4; }
.la-day--unsched { background:#fff3e0; color:#e65100; }

/* Unassigned lecturer tag */
.la-unassigned { color:#c62828; font-style:italic; }

/* Time display */
.la-time { font-variant-numeric: tabular-nums; color: #333; }

/* Buttons */
.la-btn { padding:7px 16px; font-size:11px; font-weight:600; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:5px; white-space:nowrap; transition:all .15s; }
.la-btn--primary { background:#05275C; color:#fff; } .la-btn--primary:hover { background:#174DA4; }
.la-btn--ghost   { background:#fff; border:1px solid #cdd3de; color:#555; } .la-btn--ghost:hover { border-color:#174DA4; color:#174DA4; }
.la-btn--danger  { background:#c62828; color:#fff; } .la-btn--danger:hover  { background:#d32f2f; }
.la-btn--sm { padding:4px 10px; font-size:10px; }
.la-btn:disabled { opacity:.5; cursor:not-allowed; }

/* Modal */
.la-overlay { display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,.35); z-index:9000; }
.la-modal   { position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; border:1px solid #cdd3de; width:580px; max-height:90vh; overflow-y:auto; z-index:9001; box-shadow:0 12px 40px rgba(0,0,0,.15); display:none; }
.la-modal__header { padding:12px 16px; border-bottom:1px solid #e0e5ed; background:#f8f9fb; display:flex; align-items:center; justify-content:space-between; }
.la-modal__title  { font-size:13px; font-weight:700; color:#05275C; }
.la-modal__close  { background:none; border:none; cursor:pointer; padding:4px; font-size:18px; color:#888; line-height:1; } .la-modal__close:hover { color:#c62828; }
.la-modal__body   { padding:16px; }
.la-modal__footer { padding:12px 16px; border-top:1px solid #e0e5ed; background:#f8f9fb; display:flex; justify-content:flex-end; gap:8px; }

/* Delete modal */
.la-del-modal { position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; border:1px solid #cdd3de; width:400px; z-index:9002; box-shadow:0 12px 40px rgba(0,0,0,.2); display:none; }
.la-del-modal__header { padding:12px 16px; border-bottom:1px solid #e0e5ed; background:#fff3f3; }
.la-del-modal__title  { font-size:13px; font-weight:700; color:#c62828; }
.la-del-modal__body   { padding:16px; font-size:12px; color:#333; }
.la-del-modal__footer { padding:12px 16px; border-top:1px solid #e0e5ed; display:flex; justify-content:flex-end; gap:8px; }

/* Bulk delete bar */
.la-bulk-bar { display:none; background:#fff3f3; border:1px solid #f5c6cb; padding:8px 14px; margin-bottom:10px; align-items:center; gap:10px; font-size:11px; color:#c62828; }
.la-bulk-bar.la-bulk-bar--visible { display:flex; }
.la-bulk-bar__count { font-weight:700; }

/* Checkbox in table */
.la-table th.la-th-check, .la-table td.la-td-check { width:28px; text-align:center; padding:6px 4px; }
.la-table input[type=checkbox] { cursor:pointer; width:14px; height:14px; }

/* Form */
.la-form-group  { margin-bottom:12px; }
.la-form-group label { display:block; font-size:10px; font-weight:600; color:#555; text-transform:uppercase; letter-spacing:.3px; margin-bottom:4px; }
.la-form-group input, .la-form-group select, .la-form-group textarea { width:100%; padding:7px 10px; font-size:11px; border:1px solid #cdd3de; background:#fff; box-sizing:border-box; }
.la-form-group input:focus, .la-form-group select:focus { border-color:#174DA4; outline:none; }
.la-form-row2 { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.la-form-row3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px; }
.la-form-err  { font-size:10px; color:#c62828; margin-top:3px; display:none; }

/* Conflict warning box */
.la-conflicts { background:#fff8e1; border:1px solid #ffcc02; padding:10px 12px; margin-bottom:12px; display:none; }
.la-conflicts__title { font-size:10px; font-weight:700; color:#e65100; text-transform:uppercase; margin-bottom:6px; }
.la-conflicts ul { margin:0; padding:0 0 0 14px; font-size:11px; color:#555; }
.la-conflicts ul li { margin-bottom:3px; }

/* Lecturer search input (above the select) */
.la-search-input { width:100%; padding:6px 10px; font-size:11px; border:1px solid #cdd3de; box-sizing:border-box; margin-bottom:3px; }
.la-search-input:focus { border-color:#174DA4; outline:none; }

/* Section divider in modal */
.la-section { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#174DA4; border-bottom:1px solid #e0e5ed; padding-bottom:5px; margin:16px 0 12px; }

/* Toast */
.la-toast { position:fixed; bottom:20px; right:20px; padding:10px 18px; font-size:12px; font-weight:600; color:#fff; z-index:10000; display:none; box-shadow:0 4px 12px rgba(0,0,0,.15); min-width:220px; }
.la-toast--ok  { background:#2e7d32; }
.la-toast--err { background:#c62828; }

/* Empty / loading */
.la-empty   { text-align:center; color:#999; padding:30px; font-size:12px; }
.la-loading { text-align:center; color:#174DA4; padding:20px; font-size:11px; }

/* Session badge */
.la-session { display:inline-block; padding:2px 7px; font-size:9px; font-weight:600; }
.la-session--day       { background:#e3f2fd; color:#1565c0; }
.la-session--weekend   { background:#f3e5f5; color:#6a1b9a; }
.la-session--inservice { background:#fff8e1; color:#f57f17; }
.la-session--evening   { background:#fce4ec; color:#880e4f; }

/* Unscheduled prompt */
.la-unsched-note { font-size:10px; color:#e65100; background:#fff3e0; padding:4px 8px; margin-bottom:8px; border-left:3px solid #e65100; display:none; }

@media(max-width:768px) {
    .la-stats { grid-template-columns: repeat(2,1fr); }
    .la-modal, .la-del-modal { width:95%; }
    .la-form-row2, .la-form-row3 { grid-template-columns:1fr; }
    .la-filters { flex-direction:column; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="la-header">
    <div class="la-header__left">
        <div class="la-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
        </div>
        <div>
            <div class="la-header__title">Teaching Allocations</div>
            <div class="la-header__sub">Assign lecturers to courses and manage the timetable schedule</div>
        </div>
    </div>
    <div style="display:flex;gap:6px;">
        <button type="button" class="la-btn la-btn--ghost" onclick="openBatchCopy()" title="Copy allocations from a previous semester">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
            Copy from Previous
        </button>
        <button type="button" class="la-btn la-btn--ghost" onclick="openAdoptModal()" title="Copy allocations to a different entry year">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><polyline points="17 11 19 13 23 9"></polyline></svg>
            Adopt Entry Year
        </button>
        <button type="button" class="la-btn la-btn--primary" onclick="openAdd()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            New Allocation
        </button>
    </div>
</div>

<!-- Stats -->
<div class="la-stats">
    <div class="la-stat la-stat--total">
        <div class="la-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg></div>
        <div><div class="la-stat__val" id="statTotal">—</div><div class="la-stat__label">Total Allocations</div></div>
    </div>
    <div class="la-stat la-stat--sched">
        <div class="la-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg></div>
        <div><div class="la-stat__val" id="statSched">—</div><div class="la-stat__label">Scheduled</div></div>
    </div>
    <div class="la-stat la-stat--unsched">
        <div class="la-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg></div>
        <div><div class="la-stat__val" id="statUnsched">—</div><div class="la-stat__label">Unscheduled</div></div>
    </div>
    <div class="la-stat la-stat--lecturers">
        <div class="la-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6a1b9a" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></div>
        <div><div class="la-stat__val" id="statLecturers">—</div><div class="la-stat__label">Active Lecturers</div></div>
    </div>
</div>

<!-- Context band (shows selected year/semester/campus from master) -->
<div class="la-info-band" id="laBand">
    Loading session context…
</div>

<!-- Filter bar -->
<div class="la-filters">
    <div class="la-filters__group">
        <span class="la-filters__label">Programme</span>
        <select id="ddlProg" onchange="onFilterChange()" style="min-width:200px;">
            <option value="">— All Programmes —</option>
        </select>
    </div>
    <div class="la-filters__group">
        <span class="la-filters__label">Study Year</span>
        <select id="ddlStudyYear" onchange="onFilterChange()">
            <option value="">— All —</option>
            <option value="1">Year 1</option>
            <option value="2">Year 2</option>
            <option value="3">Year 3</option>
            <option value="4">Year 4</option>
            <option value="5">Year 5</option>
        </select>
    </div>
    <div class="la-filters__group">
        <span class="la-filters__label">Entry Year</span>
        <select id="ddlEntry" onchange="onFilterChange()">
            <option value="">— All —</option>
        </select>
    </div>
    <div class="la-filters__group">
        <span class="la-filters__label">Session</span>
        <select id="ddlSession" onchange="onFilterChange()">
            <option value="">— All —</option>
            <option value="DAY">Day</option>
            <option value="WEEKEND">Weekend</option>
            <option value="INSERVICE">In-Service</option>
            <option value="EVENING">Evening</option>
        </select>
    </div>
    <div class="la-filters__group" style="justify-content:flex-end;">
        <span class="la-filters__label">&nbsp;</span>
        <button type="button" class="la-btn la-btn--ghost" onclick="clearFilters()">Clear Filters</button>
    </div>
    <span id="spnCount" style="font-size:10px;color:#888;align-self:flex-end;padding-bottom:6px;"></span>
</div>

<!-- Bulk Delete Bar (shown when checkboxes are selected) -->
<div class="la-bulk-bar" id="laBulkBar">
    <span class="la-bulk-bar__count" id="laBulkCount">0</span> allocation(s) selected
    <button type="button" class="la-btn la-btn--danger la-btn--sm" onclick="openBulkDelete()">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>
        Delete Selected
    </button>
    <button type="button" class="la-btn la-btn--ghost la-btn--sm" onclick="clearSelection()">Clear Selection</button>
</div>

<!-- Allocations Table -->
<div class="la-card">
    <div class="la-card__header">
        <div class="la-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
            Allocation List
        </div>
        <div style="display:flex;gap:8px;align-items:center;">
            <input type="text" id="txtSearch" placeholder="Search lecturer, course…" style="padding:5px 9px;font-size:11px;border:1px solid #cdd3de;width:160px;" oninput="filterTable()" />
            <select id="ddlSchedFilter" onchange="filterTable()" style="padding:5px 9px;font-size:11px;border:1px solid #cdd3de;">
                <option value="">All</option>
                <option value="sched">Scheduled only</option>
                <option value="unsched">Unscheduled only</option>
            </select>
        </div>
    </div>
    <div style="overflow-x:auto;">
        <table class="la-table" id="tblAllocs">
            <thead>
                <tr>
                    <th class="la-th-check"><input type="checkbox" id="chkSelectAll" onchange="toggleSelectAll(this)" title="Select all" /></th>
                    <th>#</th>
                    <th>Lecturer</th>
                    <th>Course</th>
                    <th>Programme / Yr</th>
                    <th>Day</th>
                    <th>Time</th>
                    <th>Room</th>
                    <th>Session</th>
                    <th>Entry Year</th>
                    <th style="width:90px;">Actions</th>
                </tr>
            </thead>
            <tbody id="tbdAllocs">
                <tr><td colspan="11" class="la-loading">Select a programme to load allocations…</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── Add / Edit Modal ─────────────────────────────────────────────── -->
<div class="la-overlay" id="laOverlay" onclick="closeModal()"></div>
<div class="la-modal" id="laModal">
    <div class="la-modal__header">
        <div class="la-modal__title" id="laModalTitle">New Allocation</div>
        <button type="button" class="la-modal__close" onclick="closeModal()">&times;</button>
    </div>
    <div class="la-modal__body">
        <input type="hidden" id="hdnEditId" value="" />

        <!-- Conflict warnings (shown after check) -->
        <div class="la-conflicts" id="laConflicts">
            <div class="la-conflicts__title">⚠ Scheduling Conflicts Detected</div>
            <ul id="laConflictList"></ul>
            <div style="font-size:10px;color:#888;margin-top:6px;">You can still save, but conflicts will exist in the timetable.</div>
        </div>

        <!-- Section: Assignment -->
        <div class="la-section">Assignment Details</div>

        <div class="la-form-group">
            <label>Lecturer <span style="color:#c62828">*</span></label>
            <input type="text" id="txtLecSearch" class="la-search-input" placeholder="Type to filter lecturers…" oninput="filterLecturers(this.value)" />
            <select id="ddlLecturer" size="1" onchange="clearConflicts()">
                <option value="">— Select Lecturer —</option>
            </select>
            <div class="la-form-err" id="errLecturer">Lecturer is required.</div>
        </div>

        <div class="la-form-row2">
            <div class="la-form-group">
                <label>Programme <span style="color:#c62828">*</span></label>
                <select id="ddlModalProg" onchange="loadModalCourses();clearConflicts();">
                    <option value="">— Select Programme —</option>
                </select>
                <div class="la-form-err" id="errProg">Programme is required.</div>
            </div>
            <div class="la-form-group">
                <label>Study Year <span style="color:#c62828">*</span></label>
                <select id="ddlModalStudyYear" onchange="loadModalCourses();clearConflicts();">
                    <option value="">—</option>
                    <option value="1">Year 1</option>
                    <option value="2">Year 2</option>
                    <option value="3">Year 3</option>
                    <option value="4">Year 4</option>
                    <option value="5">Year 5</option>
                </select>
                <div class="la-form-err" id="errStudyYear">Study year is required.</div>
            </div>
        </div>

        <div class="la-form-group">
            <label>Course <span style="color:#c62828">*</span></label>
            <select id="ddlCourse" onchange="clearConflicts()">
                <option value="">— Select Programme + Year first —</option>
            </select>
            <div class="la-form-err" id="errCourse">Course is required.</div>
        </div>

        <div class="la-form-row3">
            <div class="la-form-group">
                <label>Session <span style="color:#c62828">*</span></label>
                <select id="ddlModalSession">
                    <option value="DAY">Day</option>
                    <option value="WEEKEND">Weekend</option>
                    <option value="INSERVICE">In-Service</option>
                    <option value="EVENING">Evening</option>
                </select>
            </div>
            <div class="la-form-group">
                <label>Entry Year</label>
                <input type="number" id="txtEntryYear" min="2000" max="2099" placeholder="e.g. 2024" />
            </div>
            <div class="la-form-group">
                <label>Intake</label>
                <input type="text" id="txtIntake" maxlength="25" placeholder="e.g. AUGUST" />
            </div>
        </div>

        <!-- Section: Timetable Schedule (optional) -->
        <div class="la-section">Timetable Schedule <span style="font-weight:400;color:#aaa;font-size:9px;">(optional — can be set later)</span></div>

        <div class="la-unsched-note" id="laSchedNote">Leave Day blank to save as "Unscheduled" — you can add the schedule later.</div>

        <div class="la-form-row2">
            <div class="la-form-group">
                <label>Day of Week</label>
                <select id="ddlDay" onchange="onDayChange();checkConflicts();">
                    <option value="-">— Unscheduled —</option>
                    <option value="MONDAY">Monday</option>
                    <option value="TUESDAY">Tuesday</option>
                    <option value="WEDNESDAY">Wednesday</option>
                    <option value="THURSDAY">Thursday</option>
                    <option value="FRIDAY">Friday</option>
                    <option value="SATURDAY">Saturday</option>
                    <option value="SUNDAY">Sunday</option>
                </select>
            </div>
            <div class="la-form-group">
                <label>Room</label>
                <select id="ddlRoom" onchange="checkConflicts()">
                    <option value="">— No Room —</option>
                </select>
            </div>
        </div>

        <div class="la-form-row2" id="laTimeRow" style="display:none;">
            <div class="la-form-group">
                <label>Start Time</label>
                <select id="ddlStart" onchange="buildEndTimes();checkConflicts();">
                    <option value="">— Select —</option>
                </select>
                <div class="la-form-err" id="errTime">Start time must be before end time.</div>
            </div>
            <div class="la-form-group">
                <label>End Time</label>
                <select id="ddlEnd" onchange="checkConflicts()">
                    <option value="">— Select —</option>
                </select>
            </div>
        </div>

        <div class="la-form-group">
            <label>Stream</label>
            <input type="text" id="txtStream" maxlength="25" placeholder="Leave blank for default ( - )" />
        </div>
    </div>
    <div class="la-modal__footer">
        <button type="button" class="la-btn la-btn--ghost" onclick="closeModal()">Cancel</button>
        <button type="button" class="la-btn la-btn--primary" id="btnSave" onclick="saveAllocation()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Save Allocation
        </button>
    </div>
</div>

<!-- ── Delete Confirm Modal ─────────────────────────────────────────── -->
<div class="la-del-modal" id="laDelModal">
    <div class="la-del-modal__header">
        <div class="la-del-modal__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>
            Delete Allocation
        </div>
    </div>
    <div class="la-del-modal__body" id="laDelMsg">Are you sure you want to delete this allocation?</div>
    <div class="la-del-modal__footer">
        <button type="button" class="la-btn la-btn--ghost" onclick="closeDelModal()">Cancel</button>
        <button type="button" class="la-btn la-btn--danger" id="btnConfirmDel" onclick="confirmDelete()">
            Delete
        </button>
    </div>
</div>

<!-- ── Batch Copy Modal ─────────────────────────────────────────────── -->
<div class="la-modal" id="laCopyModal" style="width:460px;">
    <div class="la-modal__header">
        <div class="la-modal__title">Copy Allocations from Previous Semester</div>
        <button type="button" class="la-modal__close" onclick="closeCopyModal()">&times;</button>
    </div>
    <div class="la-modal__body">
        <p style="font-size:11px;color:#555;margin:0 0 14px;">This will copy all allocations from the source semester into the <strong>current semester</strong> for the selected programme and study year. Existing allocations will be skipped.</p>
        <div class="la-form-row2">
            <div class="la-form-group">
                <label>Source Academic Year</label>
                <select id="ddlCopySrcYear" onchange="updateCopyPreview()">
                    <option value="">— Select —</option>
                </select>
            </div>
            <div class="la-form-group">
                <label>Source Semester</label>
                <select id="ddlCopySrcSem" onchange="updateCopyPreview()">
                    <option value="1">Semester 1</option>
                    <option value="2">Semester 2</option>
                </select>
            </div>
        </div>
        <div id="copyPreview" style="display:none;background:#e8f0fc;padding:10px 12px;font-size:11px;color:#174DA4;margin-top:8px;"></div>
    </div>
    <div class="la-modal__footer">
        <button type="button" class="la-btn la-btn--ghost" onclick="closeCopyModal()">Cancel</button>
        <button type="button" class="la-btn la-btn--primary" id="btnCopyConfirm" onclick="executeCopy()" disabled="disabled">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
            Copy Now
        </button>
    </div>
</div>

<!-- Toast -->
<div class="la-toast" id="laToast"></div>

<!-- ── Adopt Entry Year Modal ─────────────────────────────────────────────── -->
<div class="la-modal" id="laAdoptModal" style="width:460px;">
    <div class="la-modal__header">
        <div class="la-modal__title">Adopt Allocations to Different Entry Year</div>
        <button type="button" class="la-modal__close" onclick="closeAdoptModal()">&times;</button>
    </div>
    <div class="la-modal__body">
        <p style="font-size:11px;color:#555;margin:0 0 14px;">This copies all allocations from a <strong>source entry year</strong> to a <strong>target entry year</strong> within the current semester. Existing allocations in the target will be skipped (no duplicates).</p>
        <div class="la-form-row2">
            <div class="la-form-group">
                <label>Source Entry Year</label>
                <select id="ddlAdoptSrcEntry" onchange="updateAdoptPreview()">
                    <option value="">— Select —</option>
                </select>
            </div>
            <div class="la-form-group">
                <label>Target Entry Year</label>
                <input type="number" id="txtAdoptDstEntry" min="2000" max="2099" placeholder="e.g. 2025" oninput="updateAdoptPreview()" />
            </div>
        </div>
        <div id="adoptPreview" style="display:none;background:#e8f0fc;padding:10px 12px;font-size:11px;color:#174DA4;margin-top:8px;"></div>
        <div id="adoptError" style="display:none;background:#fff3f3;padding:10px 12px;font-size:11px;color:#c62828;margin-top:8px;"></div>
    </div>
    <div class="la-modal__footer">
        <button type="button" class="la-btn la-btn--ghost" onclick="closeAdoptModal()">Cancel</button>
        <button type="button" class="la-btn la-btn--primary" id="btnAdoptConfirm" onclick="executeAdopt()" disabled="disabled">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><polyline points="17 11 19 13 23 9"></polyline></svg>
            Adopt Now
        </button>
    </div>
</div>

<!-- ── Bulk Delete Confirm Modal ─────────────────────────────────────────── -->
<div class="la-del-modal" id="laBulkDelModal">
    <div class="la-del-modal__header">
        <div class="la-del-modal__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>
            Bulk Delete Allocations
        </div>
    </div>
    <div class="la-del-modal__body" id="laBulkDelMsg">Are you sure you want to delete the selected allocations?</div>
    <div class="la-del-modal__footer">
        <button type="button" class="la-btn la-btn--ghost" onclick="closeBulkDelModal()">Cancel</button>
        <button type="button" class="la-btn la-btn--danger" id="btnBulkDelConfirm" onclick="confirmBulkDelete()">
            Delete All Selected
        </button>
    </div>
</div>

<script>
(function () {
    'use strict';

    // ─── State ─────────────────────────────────────────────────────────
    var BASE       = window.location.pathname;
    var allRows    = [];          // full allocation list in memory
    var allLecturers = [];        // full lecturer list for searching
    var allProgs   = [];          // programme list
    var allYears   = [];          // academic years list
    var deleteId   = 0;
    var toastTimer = null;
    var selectedIds = {};         // { allocId: true } for bulk-select tracking

    // Master-page context: injected by code-behind into hidden fields
    var CTX_YEAR    = '';
    var CTX_SEM     = '';
    var CTX_CAMPUS  = '';

    // ─── Init ───────────────────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', function () {
        buildTimeslots();
        loadDropdowns();
    });

    // ─── AJAX helper ────────────────────────────────────────────────────
    function ajax(action, data, cb) {
        var xhr  = new XMLHttpRequest();
        var url  = BASE + '?ajax=' + action;
        var body = data ? JSON.stringify(data) : null;
        xhr.open(body ? 'POST' : 'GET', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                try { cb(JSON.parse(xhr.responseText)); }
                catch (e) { cb({ error: 'Parse error: ' + e.message }); }
            }
        };
        xhr.send(body);
    }

    // ─── Load all reference dropdowns ───────────────────────────────────
    function loadDropdowns() {
        ajax('dropdowns', null, function (d) {
            if (d.error) { showToast('Failed to load dropdowns: ' + d.error, true); return; }
            CTX_YEAR   = d.acadYear   || '';
            CTX_SEM    = d.semester   || '';
            CTX_CAMPUS = d.campusId   || '';

            // Context band
            document.getElementById('laBand').innerHTML =
                'Academic Year: <span>' + esc(d.acadYear) + '</span> &nbsp;|&nbsp; '
              + 'Semester: <span>' + esc(d.semester) + '</span> &nbsp;|&nbsp; '
              + 'Campus: <span>' + esc(d.campusName) + '</span>';

            // Programmes
            allProgs = d.programmes || [];
            populateSelect('ddlProg', allProgs, 'code', 'display', '— All Programmes —');
            populateSelect('ddlModalProg', allProgs, 'code', 'display', '— Select Programme —');

            // Lecturers (stored in memory for search)
            allLecturers = d.lecturers || [];
            populateLecturers('');

            // Rooms (filtered by campus)
            populateSelect('ddlRoom', d.rooms || [], 'id', 'display', '— No Room —');

            // Entry years
            var eyears = d.entryYears || [];
            populateSelect('ddlEntry', eyears, 'val', 'val', '— All —');

            // Academic years for Copy modal
            allYears = d.allYears || [];
            populateSelect('ddlCopySrcYear', allYears, 'val', 'val', '— Select —');

            // Auto-load allocations
            loadAllocations();
        });
    }

    function populateSelect(id, items, valKey, textKey, placeholder) {
        var sel = document.getElementById(id);
        if (!sel) return;
        sel.innerHTML = '';
        var opt0 = document.createElement('option');
        opt0.value = ''; opt0.textContent = placeholder || '— Select —';
        sel.appendChild(opt0);
        items.forEach(function (it) {
            var o = document.createElement('option');
            o.value       = it[valKey];
            o.textContent = it[textKey];
            sel.appendChild(o);
        });
    }

    function populateLecturers(filter) {
        var sel = document.getElementById('ddlLecturer');
        if (!sel) return;
        var f   = (filter || '').toLowerCase();
        sel.innerHTML = '';
        var opt0 = document.createElement('option');
        opt0.value = ''; opt0.textContent = '— Select Lecturer —';
        sel.appendChild(opt0);
        allLecturers.forEach(function (l) {
            if (f && l.display.toLowerCase().indexOf(f) < 0) return;
            var o = document.createElement('option');
            o.value       = l.id;
            o.textContent = l.display;
            sel.appendChild(o);
        });
    }

    window.filterLecturers = function (q) { populateLecturers(q); };

    // ─── Load allocations from server ────────────────────────────────────
    function loadAllocations() {
        var prog   = val('ddlProg');
        var yr     = val('ddlStudyYear');
        var entry  = val('ddlEntry');
        var sess   = val('ddlSession');
        document.getElementById('tbdAllocs').innerHTML =
            '<tr><td colspan="11" class="la-loading">Loading\u2026</td></tr>';

        var qs = '?ajax=list&prog=' + enc(prog) + '&yr=' + enc(yr)
               + '&entry=' + enc(entry) + '&sess=' + enc(sess);

        ajax('list&prog=' + enc(prog) + '&yr=' + enc(yr) + '&entry=' + enc(entry) + '&sess=' + enc(sess),
             null, function (d) {
            if (d.error) {
                document.getElementById('tbdAllocs').innerHTML =
                    '<tr><td colspan="11" class="la-empty">Error: ' + esc(d.error) + '</td></tr>';
                return;
            }
            allRows = d.rows || [];
            updateStats(d.stats || {});
            selectedIds = {};
            updateBulkBar();
            filterTable();

            // Update entry year dropdown dynamically
            var eyears = d.entryYears || [];
            var selEntry = document.getElementById('ddlEntry');
            var curEntry = selEntry.value;
            populateSelect('ddlEntry', eyears, 'val', 'val', '— All —');
            if (curEntry) setVal('ddlEntry', curEntry);
        });
    }

    window.onFilterChange = function () { loadAllocations(); };

    window.clearFilters = function () {
        setVal('ddlProg', ''); setVal('ddlStudyYear', '');
        setVal('ddlEntry', ''); setVal('ddlSession', '');
        loadAllocations();
    };

    // ─── Update stats cards ───────────────────────────────────────────────
    function updateStats(s) {
        setText('statTotal',    s.total     || 0);
        setText('statSched',    s.scheduled || 0);
        setText('statUnsched',  s.unscheduled || 0);
        setText('statLecturers',s.lecturers || 0);
    }

    // ─── Filter in-memory + render ────────────────────────────────────────
    window.filterTable = function () {
        var q       = (val('txtSearch')     || '').toLowerCase();
        var sf      = val('ddlSchedFilter') || '';
        var filtered = allRows.filter(function (r) {
            var textOk = !q || r.lecturerName.toLowerCase().indexOf(q) >= 0
                           || r.courseCode.toLowerCase().indexOf(q) >= 0
                           || r.courseName.toLowerCase().indexOf(q) >= 0;
            var schedOk = !sf
                || (sf === 'sched'   && r.lectureday !== '-')
                || (sf === 'unsched' && r.lectureday === '-');
            return textOk && schedOk;
        });
        renderTable(filtered);
        document.getElementById('spnCount').textContent =
            filtered.length + ' allocation' + (filtered.length !== 1 ? 's' : '');
    };

    function renderTable(rows) {
        var tb = document.getElementById('tbdAllocs');
        if (!rows.length) {
            tb.innerHTML = '<tr><td colspan="11" class="la-empty">No allocations found for the selected filters.</td></tr>';
            return;
        }
        var html = '';
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var chk = selectedIds[r.id] ? ' checked' : '';
            var lecHtml = r.staffCode === '0' || !r.staffCode
                ? '<span class="la-unassigned">Unassigned</span>'
                : esc(r.lecturerName) + '<br><span style="font-size:9px;color:#888;">' + esc(r.empCode) + '</span>';
            var dayHtml = r.lectureday === '-' || !r.lectureday
                ? '<span class="la-day la-day--unsched">Unscheduled</span>'
                : '<span class="la-day la-day--sched">' + esc(r.lectureday.substring(0, 3)) + '</span>';
            var timeHtml = (r.startTime && r.endTime && r.lectureday !== '-')
                ? '<span class="la-time">' + esc(r.startTime) + '&nbsp;–&nbsp;' + esc(r.endTime) + '</span>'
                : '<span style="color:#ccc;">—</span>';
            var roomHtml = r.roomName
                ? esc(r.roomName)
                : (r.roomNo && r.roomNo !== '8' ? esc(r.roomNo) : '<span style="color:#ccc;">—</span>');
            var sessCls  = 'la-session la-session--' + (r.session || 'day').toLowerCase().replace(/[^a-z]/g,'');
            var progHtml = esc(r.progcode) + ' Yr' + r.cyear;
            html += '<tr>';
            html += '<td class="la-td-check"><input type="checkbox" data-id="' + r.id + '" onchange="toggleRowSelect(this)"' + chk + ' /></td>';
            html += '<td style="color:#888;font-size:10px;">' + (i + 1) + '</td>';
            html += '<td>' + lecHtml + '</td>';
            html += '<td><strong>' + esc(r.courseCode) + '</strong><br><span style="font-size:9px;color:#555;">' + esc(r.courseName) + '</span></td>';
            html += '<td style="font-size:10px;">' + progHtml + '</td>';
            html += '<td>' + dayHtml + '</td>';
            html += '<td>' + timeHtml + '</td>';
            html += '<td style="font-size:10px;">' + roomHtml + '</td>';
            html += '<td><span class="' + sessCls + '">' + esc(r.session) + '</span></td>';
            html += '<td style="font-size:10px;color:#555;">' + esc(r.entryYear) + '</td>';
            html += '<td>';
            html += '<button class="la-btn la-btn--ghost la-btn--sm" onclick="openEdit(' + r.id + ')" title="Edit">'
                  + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>'
                  + '</button> ';
            html += '<button class="la-btn la-btn--danger la-btn--sm" onclick="openDelete(' + r.id + ',\'' + esc(r.courseCode) + '\')" title="Delete">'
                  + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>'
                  + '</button>';
            html += '</td></tr>';
        }
        tb.innerHTML = html;
    }

    // ─── Time slots ──────────────────────────────────────────────────────
    function buildTimeslots() {
        var slots = [];
        for (var h = 7; h <= 20; h++) {
            slots.push(pad(h) + ':00');
            if (h < 20) slots.push(pad(h) + ':30');
        }
        var selS = document.getElementById('ddlStart');
        var opt0 = document.createElement('option');
        opt0.value = ''; opt0.textContent = '— Select Start —';
        selS.appendChild(opt0);
        slots.forEach(function (t) {
            var o = document.createElement('option'); o.value = t; o.textContent = t;
            selS.appendChild(o);
        });
        // End times built dynamically via buildEndTimes()
    }

    window.buildEndTimes = function () {
        var start  = val('ddlStart');
        var selE   = document.getElementById('ddlEnd');
        selE.innerHTML = '';
        var opt0 = document.createElement('option');
        opt0.value = ''; opt0.textContent = '— Select End —';
        selE.appendChild(opt0);
        if (!start) return;
        var startH = parseInt(start.split(':')[0], 10);
        var startM = parseInt(start.split(':')[1], 10);
        for (var h = 7; h <= 20; h++) {
            for (var m = 0; m < 60; m += 30) {
                if (h > startH || (h === startH && m > startM)) {
                    var t = pad(h) + ':' + pad(m);
                    var o = document.createElement('option');
                    o.value = t; o.textContent = t;
                    selE.appendChild(o);
                }
            }
        }
    };

    function pad(n) { return n < 10 ? '0' + n : '' + n; }

    // ─── Day change: show/hide time row ──────────────────────────────────
    window.onDayChange = function () {
        var isUnsched = val('ddlDay') === '-';
        document.getElementById('laTimeRow').style.display   = isUnsched ? 'none' : 'grid';
        document.getElementById('laSchedNote').style.display = isUnsched ? 'block' : 'none';
    };

    // ─── Load courses for modal (cascading) ──────────────────────────────
    window.loadModalCourses = function () {
        var prog = val('ddlModalProg');
        var yr   = val('ddlModalStudyYear');
        var sem  = CTX_SEM;
        var sel  = document.getElementById('ddlCourse');
        sel.innerHTML = '<option value="">Loading courses\u2026</option>';
        if (!prog || !yr) {
            sel.innerHTML = '<option value="">— Select Programme + Year first —</option>';
            return;
        }
        ajax('courses&prog=' + enc(prog) + '&yr=' + enc(yr) + '&sem=' + enc(sem), null, function (d) {
            var courses = d.courses || [];
            sel.innerHTML = '';
            var opt0  = document.createElement('option');
            opt0.value = ''; opt0.textContent = courses.length
                ? '— Select Course (' + courses.length + ' available) —'
                : '— No courses found for this filter —';
            sel.appendChild(opt0);
            courses.forEach(function (c) {
                var o = document.createElement('option'); o.value = c.code; o.textContent = c.display;
                sel.appendChild(o);
            });
        });
    };

    // ─── Conflict check ──────────────────────────────────────────────────
    window.checkConflicts = function () {
        var day   = val('ddlDay');
        var start = val('ddlStart');
        var end   = val('ddlEnd');
        var room  = val('ddlRoom');
        var staff = val('ddlLecturer');
        var editId = parseInt(val('hdnEditId') || '0', 10);

        if (day === '-' || !day || !start || !end) { clearConflicts(); return; }

        ajax('checkconflict', {
            day: day, startTime: start, endTime: end,
            roomNo: room, staffCode: staff, excludeId: editId
        }, function (d) {
            var msgs = d.conflicts || [];
            if (msgs.length === 0) { clearConflicts(); return; }
            var ul = document.getElementById('laConflictList');
            ul.innerHTML = '';
            msgs.forEach(function (m) {
                var li = document.createElement('li'); li.textContent = m;
                ul.appendChild(li);
            });
            document.getElementById('laConflicts').style.display = 'block';
        });
    };

    window.clearConflicts = function () {
        document.getElementById('laConflicts').style.display = 'none';
        document.getElementById('laConflictList').innerHTML  = '';
    };

    // ─── Open Add modal ───────────────────────────────────────────────────
    window.openAdd = function () {
        document.getElementById('laModalTitle').textContent = 'New Allocation';
        document.getElementById('hdnEditId').value   = '';
        document.getElementById('txtLecSearch').value = '';
        populateLecturers('');
        setVal('ddlLecturer',     '');
        setVal('ddlModalProg',    val('ddlProg'));
        setVal('ddlModalStudyYear', val('ddlStudyYear'));
        if (val('ddlModalProg') && val('ddlModalStudyYear')) loadModalCourses();
        else document.getElementById('ddlCourse').innerHTML = '<option value="">— Select Programme + Year first —</option>';
        setVal('ddlModalSession', val('ddlSession') || 'DAY');
        document.getElementById('txtEntryYear').value = val('ddlEntry') || '';
        document.getElementById('txtIntake').value    = '';
        document.getElementById('txtStream').value    = '';
        setVal('ddlDay',   '-');
        setVal('ddlStart', '');
        setVal('ddlEnd',   '');
        setVal('ddlRoom',  '');
        clearErrors();
        clearConflicts();
        onDayChange();
        showModal();
    };

    // ─── Open Edit modal ──────────────────────────────────────────────────
    window.openEdit = function (id) {
        var r = allRows.filter(function (x) { return x.id === id; })[0];
        if (!r) { showToast('Row not found. Please refresh.', true); return; }
        document.getElementById('laModalTitle').textContent = 'Edit Allocation';
        document.getElementById('hdnEditId').value   = r.id;
        document.getElementById('txtLecSearch').value = '';
        populateLecturers('');
        setVal('ddlLecturer',       r.staffCode);
        setVal('ddlModalProg',      r.progcode);
        setVal('ddlModalStudyYear', r.cyear);
        loadModalCourses();
        // Set course after courses load (delay)
        setTimeout(function () { setVal('ddlCourse', r.courseCode); }, 600);
        setVal('ddlModalSession',   r.session);
        document.getElementById('txtEntryYear').value = r.entryYear || '';
        document.getElementById('txtIntake').value    = r.intake || '';
        document.getElementById('txtStream').value    = r.stream || '';
        setVal('ddlDay', r.lectureday || '-');
        onDayChange();
        setVal('ddlStart', r.startTime || '');
        if (r.startTime) { buildEndTimes(); setTimeout(function () { setVal('ddlEnd', r.endTime || ''); }, 100); }
        else { setVal('ddlEnd', ''); }
        setVal('ddlRoom', r.roomNo || '');
        clearErrors();
        clearConflicts();
        showModal();
    };

    // ─── Save ─────────────────────────────────────────────────────────────
    window.saveAllocation = function () {
        var editId   = val('hdnEditId');
        var lecturer = val('ddlLecturer');
        var prog     = val('ddlModalProg');
        var studyYr  = val('ddlModalStudyYear');
        var course   = val('ddlCourse');
        var session  = val('ddlModalSession');
        var day      = val('ddlDay');
        var start    = val('ddlStart');
        var end      = val('ddlEnd');
        var room     = val('ddlRoom');
        var entryYr  = document.getElementById('txtEntryYear').value.trim();
        var intake   = document.getElementById('txtIntake').value.trim();
        var stream   = document.getElementById('txtStream').value.trim();

        var valid = true;
        clearErrors();
        if (!lecturer) { show('errLecturer'); valid = false; }
        if (!prog)     { show('errProg');     valid = false; }
        if (!studyYr)  { show('errStudyYear'); valid = false; }
        if (!course)   { show('errCourse');   valid = false; }
        if (!valid) return;

        // Time validation: if day is set, both times must be provided and in order
        if (day !== '-' && day) {
            if (!start || !end) { show('errTime'); valid = false; }
        }
        if (!valid) return;

        document.getElementById('btnSave').disabled = true;

        var action = editId ? 'update' : 'create';
        var data   = {
            id:         editId ? parseInt(editId, 10) : 0,
            staffCode:  lecturer,
            courseCode: course,
            progcode:   prog,
            cyear:      studyYr ? parseInt(studyYr, 10) : 1,
            session:    session || 'DAY',
            entryYear:  entryYr ? parseInt(entryYr, 10) : 0,
            intake:     intake  || '',
            stream:     stream  || '-',
            lectureday: day     || '-',
            startTime:  (day !== '-' && start) ? start : '',
            endTime:    (day !== '-' && end)   ? end   : '',
            roomNo:     room    || ''
        };

        ajax(action, data, function (d) {
            document.getElementById('btnSave').disabled = false;
            if (d.ok) {
                closeModal();
                showToast(editId ? 'Allocation updated.' : 'Allocation created.');
                loadAllocations();
            } else {
                showToast(d.error || 'Save failed. Please try again.', true);
            }
        });
    };

    // ─── Delete ───────────────────────────────────────────────────────────
    window.openDelete = function (id, course) {
        deleteId = id;
        document.getElementById('laDelMsg').innerHTML =
            'Are you sure you want to delete the allocation for <strong>' + esc(course) + '</strong>?<br><br>This cannot be undone.';
        document.getElementById('laDelModal').style.display = 'block';
        document.getElementById('laOverlay').style.display  = 'block';
    };
    window.closeDelModal = function () {
        deleteId = 0;
        document.getElementById('laDelModal').style.display = 'none';
        document.getElementById('laOverlay').style.display  = 'none';
    };
    window.confirmDelete = function () {
        if (!deleteId) return;
        var btn = document.getElementById('btnConfirmDel');
        btn.disabled = true;
        ajax('delete', { id: deleteId }, function (d) {
            btn.disabled = false;
            closeDelModal();
            if (d.ok)  { showToast('Allocation deleted.'); loadAllocations(); }
            else        { showToast(d.error || 'Delete failed.', true); }
        });
    };

    // ─── Batch Copy ───────────────────────────────────────────────────────
    window.openBatchCopy = function () {
        document.getElementById('laCopyModal').style.display = 'block';
        document.getElementById('laOverlay').style.display   = 'block';
        document.getElementById('copyPreview').style.display = 'none';
        document.getElementById('btnCopyConfirm').disabled   = true;
    };
    window.closeCopyModal = function () {
        document.getElementById('laCopyModal').style.display = 'none';
        document.getElementById('laOverlay').style.display   = 'none';
    };
    window.updateCopyPreview = function () {
        var srcYear = val('ddlCopySrcYear');
        var srcSem  = val('ddlCopySrcSem');
        var prog    = val('ddlProg');
        var yr      = val('ddlStudyYear');
        var prev    = document.getElementById('copyPreview');
        var btn     = document.getElementById('btnCopyConfirm');
        if (!srcYear) { prev.style.display = 'none'; btn.disabled = true; return; }
        ajax('copypreview&srcYear=' + enc(srcYear) + '&srcSem=' + enc(srcSem)
           + '&prog=' + enc(prog) + '&yr=' + enc(yr), null, function (d) {
            if (d.error) { prev.textContent = d.error; prev.style.display='block'; btn.disabled=true; return; }
            prev.innerHTML = 'Found <strong>' + (d.count||0) + '</strong> allocations to copy. '
                + '<strong>' + (d.existing||0) + '</strong> already exist and will be skipped. '
                + '<strong>' + ((d.count||0)-(d.existing||0)) + '</strong> will be added.';
            prev.style.display = 'block';
            btn.disabled = (d.count - d.existing) <= 0;
        });
    };
    window.executeCopy = function () {
        var srcYear = val('ddlCopySrcYear');
        var srcSem  = val('ddlCopySrcSem');
        var prog    = val('ddlProg');
        var yr      = val('ddlStudyYear');
        document.getElementById('btnCopyConfirm').disabled = true;
        ajax('copy', { srcYear: srcYear, srcSem: srcSem, prog: prog, studyYear: yr }, function (d) {
            closeCopyModal();
            if (d.ok) { showToast('Copied ' + (d.copied||0) + ' allocations.'); loadAllocations(); }
            else       { showToast(d.error || 'Copy failed.', true); }
        });
    };

    // ─── Modal helpers ────────────────────────────────────────────────────
    function showModal() {
        document.getElementById('laModal').style.display   = 'block';
        document.getElementById('laOverlay').style.display = 'block';
    }
    window.closeModal = function () {
        document.getElementById('laModal').style.display    = 'none';
        document.getElementById('laDelModal').style.display = 'none';
        document.getElementById('laCopyModal').style.display= 'none';
        document.getElementById('laAdoptModal').style.display= 'none';
        document.getElementById('laBulkDelModal').style.display= 'none';
        document.getElementById('laOverlay').style.display  = 'none';
    };

    function clearErrors() {
        ['errLecturer','errProg','errStudyYear','errCourse','errTime'].forEach(function(id){
            document.getElementById(id).style.display='none';
        });
    }

    // ─── Toast ─────────────────────────────────────────────────────────────
    window.showToast = function (msg, isErr) {
        var t = document.getElementById('laToast');
        t.textContent = msg;
        t.className   = 'la-toast ' + (isErr ? 'la-toast--err' : 'la-toast--ok');
        t.style.display = 'block';
        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { t.style.display = 'none'; }, 4500);
    };

    // ─── Utilities ─────────────────────────────────────────────────────────
    function val(id) { var el=document.getElementById(id); return el ? el.value : ''; }
    function setVal(id, v) { var el=document.getElementById(id); if(el) el.value = v; }
    function setText(id, v) { var el=document.getElementById(id); if(el) el.textContent=v; }
    function show(id) { var el=document.getElementById(id); if(el) el.style.display='block'; }
    function enc(s) { return encodeURIComponent(s || ''); }
    function esc(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
                        .replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }

    // ─── Selection (Bulk Delete) ──────────────────────────────────────────
    window.toggleRowSelect = function (cb) {
        var id = parseInt(cb.getAttribute('data-id'), 10);
        if (cb.checked) selectedIds[id] = true;
        else delete selectedIds[id];
        updateBulkBar();
    };

    window.toggleSelectAll = function (cb) {
        var boxes = document.querySelectorAll('#tbdAllocs input[type=checkbox]');
        for (var i = 0; i < boxes.length; i++) {
            boxes[i].checked = cb.checked;
            var id = parseInt(boxes[i].getAttribute('data-id'), 10);
            if (cb.checked) selectedIds[id] = true;
            else delete selectedIds[id];
        }
        updateBulkBar();
    };

    window.clearSelection = function () {
        selectedIds = {};
        var boxes = document.querySelectorAll('#tbdAllocs input[type=checkbox]');
        for (var i = 0; i < boxes.length; i++) boxes[i].checked = false;
        var sa = document.getElementById('chkSelectAll');
        if (sa) sa.checked = false;
        updateBulkBar();
    };

    function updateBulkBar() {
        var ids = Object.keys(selectedIds);
        var bar = document.getElementById('laBulkBar');
        if (ids.length > 0) {
            bar.classList.add('la-bulk-bar--visible');
            document.getElementById('laBulkCount').textContent = ids.length;
        } else {
            bar.classList.remove('la-bulk-bar--visible');
        }
    }

    // ─── Bulk Delete ──────────────────────────────────────────────────────
    window.openBulkDelete = function () {
        var ids = Object.keys(selectedIds);
        if (!ids.length) { showToast('No allocations selected.', true); return; }
        document.getElementById('laBulkDelMsg').innerHTML =
            'Are you sure you want to delete <strong>' + ids.length + '</strong> selected allocation(s)?<br><br>This cannot be undone.';
        document.getElementById('laBulkDelModal').style.display = 'block';
        document.getElementById('laOverlay').style.display    = 'block';
    };

    window.closeBulkDelModal = function () {
        document.getElementById('laBulkDelModal').style.display = 'none';
        document.getElementById('laOverlay').style.display    = 'none';
    };

    window.confirmBulkDelete = function () {
        var ids = Object.keys(selectedIds).map(function (k) { return parseInt(k, 10); });
        if (!ids.length) return;
        var btn = document.getElementById('btnBulkDelConfirm');
        btn.disabled = true;
        ajax('bulkdelete', { ids: ids }, function (d) {
            btn.disabled = false;
            closeBulkDelModal();
            if (d.ok) {
                showToast('Deleted ' + (d.deleted || 0) + ' allocation(s).');
                selectedIds = {};
                updateBulkBar();
                loadAllocations();
            } else {
                showToast(d.error || 'Bulk delete failed.', true);
            }
        });
    };

    // ─── Adopt Entry Year ─────────────────────────────────────────────────
    window.openAdoptModal = function () {
        var prog = val('ddlProg');
        if (!prog) { showToast('Select a programme first.', true); return; }
        // Populate source entry years from allRows
        var years = {};
        allRows.forEach(function (r) {
            if (r.entryYear && r.entryYear !== '0' && r.entryYear !== '') years[r.entryYear] = true;
        });
        var sorted = Object.keys(years).sort().reverse();
        var sel = document.getElementById('ddlAdoptSrcEntry');
        sel.innerHTML = '<option value="">\u2014 Select \u2014</option>';
        sorted.forEach(function (y) {
            var o = document.createElement('option'); o.value = y; o.textContent = y;
            sel.appendChild(o);
        });
        document.getElementById('txtAdoptDstEntry').value = '';
        document.getElementById('adoptPreview').style.display = 'none';
        document.getElementById('adoptError').style.display   = 'none';
        document.getElementById('btnAdoptConfirm').disabled   = true;
        document.getElementById('laAdoptModal').style.display = 'block';
        document.getElementById('laOverlay').style.display    = 'block';
    };

    window.closeAdoptModal = function () {
        document.getElementById('laAdoptModal').style.display = 'none';
        document.getElementById('laOverlay').style.display    = 'none';
    };

    window.updateAdoptPreview = function () {
        var srcEntry = val('ddlAdoptSrcEntry');
        var dstEntry = (document.getElementById('txtAdoptDstEntry').value || '').trim();
        var prog     = val('ddlProg');
        var yr       = val('ddlStudyYear');
        var prev     = document.getElementById('adoptPreview');
        var errDiv   = document.getElementById('adoptError');
        var btn      = document.getElementById('btnAdoptConfirm');

        prev.style.display = 'none';
        errDiv.style.display = 'none';
        btn.disabled = true;

        if (!srcEntry || !dstEntry) return;
        if (srcEntry === dstEntry) {
            errDiv.textContent = 'Source and target entry years must be different.';
            errDiv.style.display = 'block';
            return;
        }

        ajax('adoptpreview&srcEntry=' + enc(srcEntry) + '&dstEntry=' + enc(dstEntry)
           + '&prog=' + enc(prog) + '&yr=' + enc(yr), null, function (d) {
            if (d.error) {
                errDiv.textContent = d.error;
                errDiv.style.display = 'block';
                return;
            }
            prev.innerHTML = 'Found <strong>' + (d.count || 0) + '</strong> allocation(s) with entry year ' + esc(srcEntry) + '. '
                + '<strong>' + (d.existing || 0) + '</strong> already exist in target ' + esc(dstEntry) + ' and will be skipped. '
                + '<strong>' + ((d.count || 0) - (d.existing || 0)) + '</strong> will be adopted.';
            prev.style.display = 'block';
            btn.disabled = (d.count - d.existing) <= 0;
        });
    };

    window.executeAdopt = function () {
        var srcEntry = val('ddlAdoptSrcEntry');
        var dstEntry = (document.getElementById('txtAdoptDstEntry').value || '').trim();
        var prog     = val('ddlProg');
        var yr       = val('ddlStudyYear');
        document.getElementById('btnAdoptConfirm').disabled = true;
        ajax('adopt', {
            srcEntry: parseInt(srcEntry, 10),
            dstEntry: parseInt(dstEntry, 10),
            prog: prog,
            studyYear: yr
        }, function (d) {
            closeAdoptModal();
            if (d.ok) { showToast('Adopted ' + (d.adopted || 0) + ' allocation(s).'); loadAllocations(); }
            else       { showToast(d.error || 'Adopt failed.', true); }
        });
    };

}());
</script>

</asp:Content>
