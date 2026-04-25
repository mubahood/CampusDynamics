<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="DashboardNewProgrammeCourses.aspx.cs" Inherits="COOPERP_NewScreens_DashboardNewProgrammeCourses" Title="Programme Courses Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Stat tiles ─────────────────────────────────────────────── */
.pc-stats { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:10px; margin:8px 0 10px; }
.pc-stat { background:#fff; border:1px solid #e0e5ed; padding:12px; }
.pc-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; font-weight:700; }
.pc-stat__value { font-size:21px; color:#05275C; font-weight:800; margin-top:6px; }

/* ── Card ───────────────────────────────────────────────────── */
.pc-card { background:#fff; border:1px solid #e0e5ed; margin-bottom:12px; }
.pc-card__head { border-bottom:2px solid #e0e5ed; background:#f8fafc; }
.pc-card__head-main { display:flex; justify-content:space-between; align-items:center; gap:10px; padding:10px 12px; flex-wrap:wrap; }
.pc-card__head-filters { padding:8px 12px; border-top:1px solid #e8edf4; }
.pc-card__title { font-size:12px; font-weight:800; color:#05275C; text-transform:uppercase; letter-spacing:.4px; }

/* ── Buttons ────────────────────────────────────────────────── */
.pc-btn { display:inline-flex; align-items:center; gap:6px; padding:8px 12px; border:1px solid #d2dae6; background:#fff; color:#05275C; text-decoration:none; font-size:12px; font-weight:700; cursor:pointer; }
.pc-btn:hover { background:#f5f8ff; border-color:#174DA4; color:#174DA4; text-decoration:none; }
.pc-btn--primary { background:#05275C; border-color:#05275C; color:#fff; }
.pc-btn--primary:hover { background:#174DA4; border-color:#174DA4; color:#fff; }
.pc-btn--danger { background:#b42318; border-color:#b42318; color:#fff; }
.pc-btn--danger:hover { background:#991b1b; border-color:#991b1b; color:#fff; }
.pc-btn--sm { padding:5px 10px; font-size:11px; }

/* ── Filter bar ─────────────────────────────────────────────── */
.pc-filter-bar { display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
.pc-search { border:1px solid #cfd8e3; background:#fff; padding:7px 10px; font-size:12px; color:#1f2937; min-width:260px; }
.pc-search:focus { outline:none; border-color:#174DA4; }
.pc-select-sm { border:1px solid #cfd8e3; background:#fff; padding:6px 8px; font-size:11px; color:#1f2937; height:32px; }
.pc-select-sm:focus { outline:none; border-color:#174DA4; }

/* ── Meta bar ───────────────────────────────────────────────── */
.pc-meta { display:flex; justify-content:space-between; align-items:center; padding:8px 14px; border-bottom:1px solid #eef1f5; font-size:11px; color:#4b5563; }
.pc-meta strong { color:#05275C; }

/* ── Table ──────────────────────────────────────────────────── */
.pc-table-wrap { position:relative; max-width:100%; overflow-x:auto; overflow-y:hidden; -webkit-overflow-scrolling:touch; }
.pc-table { width:max-content; min-width:100%; table-layout:auto; border-collapse:separate; border-spacing:0; }
.pc-table th { background:#f8fafc; border-bottom:2px solid #e0e5ed; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; padding:9px 10px; text-align:left; white-space:nowrap; }
.pc-table td { border-bottom:1px solid #eef2f6; font-size:12px; color:#1f2937; padding:9px 10px; vertical-align:middle; }
.pc-table tbody tr:hover td { background:#f9fbff; }
.pc-table tbody tr:nth-child(even) td { background:#fafbfc; }
.pc-table tbody tr:nth-child(even):hover td { background:#f0f5ff; }
.pc-table th { position:sticky; top:0; z-index:2; }
.pc-table th,
.pc-table td { overflow:visible; text-overflow:clip; white-space:nowrap; }
.pc-col-prog { min-width:230px; max-width:320px; white-space:normal !important; line-height:1.25; word-break:break-word; }
.pc-col-spec { min-width:120px; max-width:180px; white-space:normal !important; }
.pc-col-name { min-width:220px; max-width:360px; white-space:normal !important; }
.pc-col-lect { min-width:190px; max-width:280px; white-space:normal !important; }
.pc-desktop-view { display:none; }
.pc-mobile-view { display:block; }
.pc-code { font-family:Consolas,"Courier New",monospace; font-size:11px; color:#174DA4; font-weight:700; white-space:nowrap; }
.pc-muted { color:#6b7280; font-size:11px; }
.pc-center { text-align:center; }
.pc-pill { display:inline-block; padding:3px 8px; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.35px; }
.pc-pill--core { background:#e8f0fc; color:#174DA4; }
.pc-pill--elective { background:#fff4e5; color:#b45309; }
.pc-pill--ok { background:#ecfdf3; color:#027a48; }
.pc-pill--warn { background:#fff7e6; color:#b45309; }
.pc-pill--bad { background:#fde8e8; color:#b42318; }
.pc-pill--muted { background:#f3f4f6; color:#6b7280; }

/* ── Action buttons ─────────────────────────────────────────── */
.pc-actions { display:flex; gap:5px; align-items:center; justify-content:center; }
.pc-action-btn { display:inline-flex; align-items:center; justify-content:center; width:28px; height:28px; border:1px solid #cdd3de; background:#fff; color:#374151; cursor:pointer; }
.pc-action-btn svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.pc-action-btn:hover { border-color:#174DA4; color:#174DA4; background:#eef3ff; }
.pc-action-btn.danger:hover { border-color:#b42318; color:#b42318; background:#fde8e8; }

/* ── Empty state ────────────────────────────────────────────── */
.pc-empty { padding:28px; text-align:center; font-size:12px; color:#6b7280; }

/* ── Mobile cards ─────────────────────────────────────────── */
.pc-mobile-list { display:grid; grid-template-columns:repeat(auto-fit,minmax(340px,1fr)); gap:8px; }
.pc-mcard { border:1px solid #e4e9f1; background:#fff; padding:8px 9px; }
.pc-mcard__head { display:flex; justify-content:space-between; align-items:flex-start; gap:6px; margin-bottom:6px; }
.pc-mcard__title { font-size:11.5px; font-weight:800; color:#05275C; line-height:1.3; }
.pc-mcard__sub { font-size:10.5px; color:#6b7280; margin-top:2px; }
.pc-mcard__meta { display:flex; flex-direction:column; gap:4px; margin-bottom:6px; }
.pc-mline { font-size:11px; color:#1f2937; line-height:1.3; }
.pc-mline__k { color:#6b7280; font-weight:700; margin-right:4px; }
.pc-mline__v { color:#1f2937; }
.pc-mcard__actions { display:flex; gap:6px; flex-wrap:wrap; margin-top:4px; }
.pc-mobile-list .pc-empty { grid-column:1 / -1; }

/* ── Pager ──────────────────────────────────────────────────── */
.pc-pager { display:flex; justify-content:space-between; align-items:center; gap:8px; padding:10px 14px; border-top:1px solid #e0e5ed; background:#f8fafc; flex-wrap:wrap; font-size:11px; color:#4b5563; }
.pc-pager__links { display:flex; gap:4px; flex-wrap:wrap; }
.pc-pager__links a, .pc-pager__links span { border:1px solid #d4dbe8; background:#fff; color:#334155; font-size:11px; text-decoration:none; padding:4px 9px; }
.pc-pager__links .active { background:#05275C; border-color:#05275C; color:#fff; }

/* ── Modal ──────────────────────────────────────────────────── */
.pc-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:9000; }
.pc-overlay.show { display:block; }
.pc-modal { display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; border:1px solid #e0e5ed; width:92%; max-width:600px; box-shadow:0 6px 24px rgba(0,0,0,.14); z-index:9001; max-height:90vh; overflow-y:auto; }
.pc-modal.show { display:block; }
.pc-modal__head { display:flex; justify-content:space-between; align-items:center; padding:14px 16px; border-bottom:1px solid #e0e5ed; background:#f8fafc; }
.pc-modal__title { font-size:13px; font-weight:800; color:#05275C; margin:0; }
.pc-modal__close { background:none; border:none; font-size:20px; color:#6b7280; cursor:pointer; padding:0 4px; line-height:1; }
.pc-modal__close:hover { color:#1f2937; }
.pc-modal__body { padding:18px 16px; }
.pc-modal__foot { display:flex; justify-content:flex-end; gap:8px; padding:12px 16px; border-top:1px solid #e0e5ed; background:#f8fafc; }

/* ── Modal form controls ────────────────────────────────────── */
.pc-fg { margin-bottom:14px; }
.pc-fg:last-child { margin-bottom:0; }
.pc-fg label { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.35px; color:#6b7280; display:block; margin-bottom:5px; }
.pc-fg label .req { color:#b42318; }
.pc-ctrl { width:100%; border:1px solid #cfd8e3; background:#fff; color:#1a1a2e; font-size:12px; padding:8px; font-family:inherit; height:34px; }
.pc-ctrl:focus { outline:none; border-color:#174DA4; box-shadow:0 0 0 2px rgba(23,77,164,.1); }
.pc-row-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px; }
.pc-alert { padding:10px 12px; font-size:11px; margin-bottom:12px; display:none; }
.pc-alert.show { display:block; }
.pc-alert--error { background:#fde8e8; color:#b42318; }
.pc-alert--warning { background:#fff7e6; color:#b45309; border:1px solid #f3d19a; display:block; margin-bottom:12px; }

/* ── Searchable dropdown (SD) ───────────────────────────────── */
.sd-wrap { position:relative; }
.sd-toggle { display:flex; justify-content:space-between; align-items:center; border:1px solid #cfd8e3; background:#fff; padding:7px 10px; cursor:pointer; font-size:12px; min-height:34px; }
.sd-toggle:hover { border-color:#174DA4; }
.sd-toggle-text { color:#1f2937; }
.sd-toggle-text.placeholder { color:#9ca3af; }
.sd-toggle-arrow { color:#9ca3af; font-size:11px; }
.sd-panel { display:none; position:absolute; top:100%; left:0; right:0; z-index:500; background:#fff; border:1px solid #cfd8e3; border-top:none; box-shadow:0 4px 12px rgba(0,0,0,.1); max-height:220px; overflow-y:auto; }
.sd-panel.is-open { display:block; }
.sd-search { width:100%; border:none; border-bottom:1px solid #e0e5ed; padding:7px 10px; font-size:12px; }
.sd-search:focus { outline:none; }
.sd-list { }
.sd-item { padding:8px 10px; font-size:12px; cursor:pointer; color:#1f2937; }
.sd-item:hover, .sd-item.is-sel { background:#eef3ff; color:#174DA4; }
.sd-empty { padding:10px; font-size:11px; color:#9ca3af; text-align:center; }

/* ── Course search autocomplete ─────────────────────────────── */
.pc-search-wrap { position:relative; }
.pc-search-dropdown { position:absolute; top:100%; left:0; right:0; z-index:600; background:#fff; border:1px solid #cfd8e3; border-top:none; box-shadow:0 4px 12px rgba(0,0,0,.1); display:none; max-height:220px; overflow-y:auto; }
.pc-search-dropdown.is-open { display:block; }
.pc-search-item { display:flex; gap:10px; align-items:baseline; padding:8px 10px; cursor:pointer; }
.pc-search-item:hover { background:#eef3ff; }
.pc-si-code { font-family:Consolas,"Courier New",monospace; font-size:11px; font-weight:700; color:#174DA4; min-width:70px; }
.pc-si-name { font-size:12px; color:#374151; }
.pc-selected-course { display:none; align-items:center; gap:8px; padding:7px 10px; margin-top:5px; background:#eef3ff; border:1px solid #c7d8fb; font-size:12px; }
.pc-sc-code { font-family:Consolas,"Courier New",monospace; font-size:11px; font-weight:700; color:#174DA4; }
.pc-sc-clear { margin-left:auto; background:none; border:none; color:#9ca3af; cursor:pointer; font-size:16px; line-height:1; padding:0 2px; }
.pc-sc-clear:hover { color:#b42318; }

@media (max-width:900px) {
    .pc-stats { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .pc-row-3 { grid-template-columns:1fr; }
    .pc-modal { width:96%; max-width:96%; }
    .pc-filter-bar { flex-direction:column; align-items:flex-start; }
    .pc-search,
    .pc-select-sm,
    .pc-filter-bar .sd-wrap,
    .pc-filter-bar .pc-btn { width:100%; min-width:100% !important; }
    .pc-mobile-list { grid-template-columns:1fr; }
        .pc-mcard__actions .pc-btn { flex:1 1 auto; justify-content:center; }
    .pc-pager { flex-direction:column; align-items:flex-start; }
}

@media (max-width:1200px) {
    .pc-table { min-width:1320px; }
    .pc-table th { padding:8px 8px; }
    .pc-table td { padding:8px 8px; }
}

@media (max-width:1500px) {
    .pc-table th { font-size:9px; padding:7px 7px; }
    .pc-table td { font-size:11px; padding:7px 7px; }
}

@media (max-width:1024px) {
    .pc-stats { grid-template-columns:1fr 1fr; }
    .pc-card__head-main { flex-direction:column; align-items:flex-start; }
    .pc-card__head-main .pc-btn { width:100%; justify-content:center; }
    .pc-card__head-filters { padding:8px 10px; }
}

@media (max-width:640px) {
    .pc-stats { grid-template-columns:1fr; }
    .pc-meta { flex-direction:column; align-items:flex-start; gap:4px; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- Hidden postback infrastructure (unchanged) -->
    <asp:HiddenField ID="hdnEditId"        runat="server" />
    <asp:HiddenField ID="hdnModalMode"     runat="server" />
    <asp:HiddenField ID="hdnSelectedCourse" runat="server" />
    <asp:Literal ID="litRows" runat="server" Visible="false" />
    <asp:Button ID="btnSave"     runat="server" style="display:none" OnClick="btnSave_Click"     UseSubmitBehavior="false" />
    <asp:Button ID="btnDelete"   runat="server" style="display:none" OnClick="btnDelete_Click"   UseSubmitBehavior="false" />
    <asp:Button ID="btnLoadEdit" runat="server" style="display:none" OnClick="btnLoadEdit_Click" UseSubmitBehavior="false" />

    <!-- Dropdowns (hidden, used by postbacks) -->
    <asp:DropDownList ID="ddlProgramme"     runat="server" style="display:none" />
    <asp:DropDownList ID="ddlSpecialisation" runat="server" style="display:none" />
    <asp:DropDownList ID="ddlYear" runat="server" style="display:none">
        <asp:ListItem Value="1" /><asp:ListItem Value="2" /><asp:ListItem Value="3" />
        <asp:ListItem Value="4" /><asp:ListItem Value="5" /><asp:ListItem Value="6" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlSemester" runat="server" style="display:none">
        <asp:ListItem Value="1" /><asp:ListItem Value="2" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlCourseType" runat="server" style="display:none">
        <asp:ListItem Value="CORE" /><asp:ListItem Value="ELECTIVE" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlIsLecturerAssigned" runat="server" style="display:none">
        <asp:ListItem Value="No" /><asp:ListItem Value="Yes" />
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLecturer" runat="server" style="display:none" />
    <asp:DropDownList ID="ddlAssignmentStatus" runat="server" style="display:none">
        <asp:ListItem Value="Active" /><asp:ListItem Value="Inactive" />
    </asp:DropDownList>

    <asp:PlaceHolder ID="phMigrationNotice" runat="server" Visible="false">
        <div class="pc-alert pc-alert--warning">
            <asp:Literal ID="litMigrationNotice" runat="server" />
        </div>
    </asp:PlaceHolder>

    <!-- ── Stat tiles ────────────────────────────────────────── -->
    <div class="pc-stats">
        <div class="pc-stat"><div class="pc-stat__label">Active Courses</div><div class="pc-stat__value"><asp:Literal ID="litTotal" runat="server" Text="0" /></div></div>
        <div class="pc-stat"><div class="pc-stat__label">Unlocated Courses</div><div class="pc-stat__value"><asp:Literal ID="litCoreCount" runat="server" Text="0" /></div></div>
        <div class="pc-stat"><div class="pc-stat__label">Requested Courses</div><div class="pc-stat__value"><asp:Literal ID="litElectiveCount" runat="server" Text="0" /></div></div>
        <div class="pc-stat"><div class="pc-stat__label">Programmes</div><div class="pc-stat__value"><asp:Literal ID="litProgCount" runat="server" Text="0" /></div></div>
    </div>

    <!-- ── Table card ────────────────────────────────────────── -->
    <div class="pc-card">
        <div class="pc-card__head">
            <div class="pc-card__head-main">
                <div class="pc-card__title">Programme Courses Dashboard <asp:Literal ID="litRequestAlert" runat="server" /></div>
            </div>
            <div class="pc-card__head-filters">
                <div class="pc-filter-bar">
                    <select id="pcFilterView" class="pc-select-sm" onchange="applyUrlFilter()" title="Dashboard focus">
                        <option value="all">All Focus</option>
                        <option value="active">Active Courses</option>
                        <option value="unlocated">Unlocated Courses</option>
                        <option value="requested">Requested Courses</option>
                    </select>
                    <input type="text" id="pcSearchInput" class="pc-search" placeholder="Search by programme, course code, name or specialisation&hellip;" oninput="filterPcTable(this.value)" />
                    <select id="pcFilterYear" class="pc-select-sm" onchange="applyUrlFilter()" title="Filter by year">
                        <option value="">All Years</option>
                        <option value="1">Year 1</option><option value="2">Year 2</option>
                        <option value="3">Year 3</option><option value="4">Year 4</option>
                        <option value="5">Year 5</option><option value="6">Year 6</option>
                    </select>
                    <select id="pcFilterSem" class="pc-select-sm" onchange="applyUrlFilter()" title="Filter by semester">
                        <option value="">All Sem</option>
                        <option value="1">Sem 1</option><option value="2">Sem 2</option><option value="3">Sem 3</option>
                    </select>
                    <select id="pcFilterAssigned" class="pc-select-sm" onchange="applyUrlFilter()" title="Filter by assignment">
                        <option value="">All Assigned</option>
                        <option value="Yes">Assigned = Yes</option>
                        <option value="No">Assigned = No</option>
                    </select>
                    <input type="hidden" id="pcFilterLecturer" value="" />
                    <div class="sd-wrap" style="min-width:210px;">
                        <div class="sd-toggle" id="sdFLectToggle" title="Filter by lecturer" style="min-height:32px;padding:6px 10px;">
                            <span class="sd-toggle-text placeholder" id="sdFLectText">All Lecturers</span>
                            <span class="sd-toggle-arrow">&#9662;</span>
                        </div>
                        <div class="sd-panel" id="sdFLectPanel">
                            <input type="text" class="sd-search" id="sdFLectSearch" placeholder="Search lecturers by name&hellip;" autocomplete="off" />
                            <div class="sd-list" id="sdFLectList"></div>
                        </div>
                    </div>
                    <select id="pcFilterType" class="pc-select-sm" onchange="applyUrlFilter()" title="Filter by type">
                        <option value="">All Types</option>
                        <option value="CORE">Core</option><option value="ELECTIVE">Elective</option>
                    </select>
                    <select id="pcFilterReq" class="pc-select-sm" onchange="applyUrlFilter()" title="Filter by allocation requests">
                        <option value="">All Requests</option>
                        <option value="pending">Pending Requests</option>
                        <option value="approved">Approved Requests</option>
                        <option value="rejected">Rejected Requests</option>
                        <option value="requested">Any Request</option>
                    </select>
                    <button type="button" class="pc-btn pc-btn--sm" onclick="resetFilters()">Reset</button>
                </div>
            </div>
        </div>

        <div class="pc-meta">
            <span>Showing <strong><asp:Literal ID="litPageInfo" runat="server" Text="all records" /></strong></span>
            <span>Total: <strong><asp:Literal ID="litMetaTotal" runat="server" Text="0" /></strong></span>
        </div>

        <div class="pc-mobile-view">
            <div class="pc-mobile-list" id="pcMobileList">
                <asp:Literal ID="litRowsMobile" runat="server" />
            </div>
        </div>

        <div class="pc-pager">
            <span class="pc-muted">Page navigation</span>
            <div class="pc-pager__links"><asp:Literal ID="litPager" runat="server" /></div>
        </div>
    </div>

    <!-- ── Allocation Request Decision Modal ──────────────── -->
    <div class="pc-overlay" id="pcReqDecisionOverlay"></div>
    <div class="pc-modal" id="pcReqDecisionModal" style="max-width:640px;">
        <div class="pc-modal__head">
            <h2 class="pc-modal__title">Review Allocation Request</h2>
            <button type="button" class="pc-modal__close" onclick="closeRequestDecisionModal()">&times;</button>
        </div>
        <div class="pc-modal__body">
            <div class="pc-alert pc-alert--error" id="reqDecisionErr"></div>
            <div class="pc-fg">
                <label>Course Context</label>
                <div id="reqDecisionCtx" class="pc-muted" style="font-size:12px;"></div>
            </div>
            <div class="pc-fg">
                <label>Requested By</label>
                <div id="reqDecisionLecturer" class="pc-muted" style="font-size:12px;"></div>
            </div>
            <div class="pc-fg">
                <label>Lecturer Message</label>
                <div id="reqDecisionMessage" style="font-size:12px;background:#f8fafc;border:1px solid #e5e7eb;padding:8px;white-space:pre-wrap;"></div>
            </div>
            <div class="pc-fg">
                <label>Decision</label>
                <select id="reqDecisionStatus" class="pc-ctrl">
                    <option value="Approved">Approve</option>
                    <option value="Rejected">Reject</option>
                    <option value="Pending">Keep Pending</option>
                </select>
            </div>
            <div class="pc-fg">
                <label>Admin Message</label>
                <textarea id="reqDecisionAdminMessage" class="pc-ctrl" style="height:88px;resize:vertical;"></textarea>
            </div>
        </div>
        <div class="pc-modal__foot">
            <button type="button" class="pc-btn pc-btn--sm" onclick="closeRequestDecisionModal()">Cancel</button>
            <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" id="btnReqDecisionSave" onclick="submitRequestDecision()">Save Decision</button>
        </div>
    </div>

    <!-- ── Add / Edit Modal ──────────────────────────────────── -->
    <div class="pc-overlay" id="pcOverlay"></div>
    <div class="pc-modal" id="pcModal">
        <div class="pc-modal__head">
            <h2 class="pc-modal__title" id="modalTitle">Add Programme Course</h2>
            <button type="button" class="pc-modal__close" onclick="closeModal()">&times;</button>
        </div>
        <div class="pc-modal__body">
            <div class="pc-alert pc-alert--error" id="modalResult"></div>

            <!-- Programme -->
            <div class="pc-fg">
                <label>Programme <span class="req">*</span></label>
                <div class="sd-wrap" id="sdProgWrap">
                    <div class="sd-toggle" id="sdProgToggle">
                        <span class="sd-toggle-text placeholder" id="sdProgText">-- Select Programme --</span>
                        <span class="sd-toggle-arrow">&#9662;</span>
                    </div>
                    <div class="sd-panel" id="sdProgPanel">
                        <input type="text" class="sd-search" id="sdProgSearch" placeholder="Search programmes&hellip;" autocomplete="off" />
                        <div class="sd-list" id="sdProgList"></div>
                    </div>
                </div>
            </div>

            <!-- Specialisation -->
            <div class="pc-fg">
                <label>Specialisation <span class="req">*</span></label>
                <div class="sd-wrap" id="sdSpecWrap">
                    <div class="sd-toggle" id="sdSpecToggle">
                        <span class="sd-toggle-text placeholder" id="sdSpecText">-- Select Specialisation --</span>
                        <span class="sd-toggle-arrow">&#9662;</span>
                    </div>
                    <div class="sd-panel" id="sdSpecPanel">
                        <input type="text" class="sd-search" id="sdSpecSearch" placeholder="Search specialisations&hellip;" autocomplete="off" />
                        <div class="sd-list" id="sdSpecList"></div>
                    </div>
                </div>
            </div>

            <!-- Course search -->
            <div class="pc-fg pc-search-wrap">
                <label>Course <span class="req">*</span></label>
                <input type="text" id="courseSearchInput" class="pc-ctrl" placeholder="Type course code or name to search&hellip;" autocomplete="off" />
                <div id="courseSearchResults" class="pc-search-dropdown"></div>
                <div id="courseSelectedDisplay" class="pc-selected-course"></div>
            </div>

            <!-- Year / Semester / Type -->
            <div class="pc-row-3">
                <div class="pc-fg">
                    <label>Study Year <span class="req">*</span></label>
                    <select id="uiYear" class="pc-ctrl" onchange="document.getElementById('<%= ddlYear.ClientID %>').value=this.value">
                        <option value="1">Year 1</option><option value="2">Year 2</option>
                        <option value="3">Year 3</option><option value="4">Year 4</option>
                        <option value="5">Year 5</option><option value="6">Year 6</option>
                    </select>
                </div>
                <div class="pc-fg">
                    <label>Semester <span class="req">*</span></label>
                    <select id="uiSemester" class="pc-ctrl" onchange="document.getElementById('<%= ddlSemester.ClientID %>').value=this.value">
                        <option value="1">Semester 1</option><option value="2">Semester 2</option>
                    </select>
                </div>
                <div class="pc-fg">
                    <label>Course Type</label>
                    <select id="uiCourseType" class="pc-ctrl" onchange="document.getElementById('<%= ddlCourseType.ClientID %>').value=this.value">
                        <option value="CORE">Core</option><option value="ELECTIVE">Elective</option>
                    </select>
                </div>
            </div>

            <div class="pc-row-3">
                <div class="pc-fg">
                    <label>Is Lecturer Assigned?</label>
                    <select id="uiIsLecturerAssigned" class="pc-ctrl" onchange="onAssignedFlagChange(this.value);document.getElementById('<%= ddlIsLecturerAssigned.ClientID %>').value=this.value;">
                        <option value="No">No</option>
                        <option value="Yes">Yes</option>
                    </select>
                </div>
                <div class="pc-fg" id="fgLecturer">
                    <label>Lecturer</label>
                    <div class="sd-wrap" id="sdLectWrap">
                        <div class="sd-toggle" id="sdLectToggle">
                            <span class="sd-toggle-text placeholder" id="sdLectText">-- Select Lecturer --</span>
                            <span class="sd-toggle-arrow">&#9662;</span>
                        </div>
                        <div class="sd-panel" id="sdLectPanel">
                            <input type="text" class="sd-search" id="sdLectSearch" placeholder="Search by name&hellip;" autocomplete="off" />
                            <div class="sd-list" id="sdLectList"></div>
                        </div>
                    </div>
                </div>
                <div class="pc-fg">
                    <label>Assignment Status</label>
                    <select id="uiAssignmentStatus" class="pc-ctrl" onchange="document.getElementById('<%= ddlAssignmentStatus.ClientID %>').value=this.value">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="pc-modal__foot">
            <button type="button" class="pc-btn pc-btn--sm" onclick="closeModal()">Cancel</button>
            <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" onclick="saveRecord()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                Save
            </button>
        </div>
    </div>

    <!-- ── Batch Assignment Modal ───────────────────────────── -->
    <div class="pc-overlay" id="pcBatchOverlay"></div>
    <div class="pc-modal" id="pcBatchModal" style="max-width:700px;">
        <div class="pc-modal__head">
            <h2 class="pc-modal__title">Batch Lecturer Assignment</h2>
            <button type="button" class="pc-modal__close" onclick="closeBatchModal()">&times;</button>
        </div>
        <div class="pc-modal__body">
            <div class="pc-alert pc-alert--error" id="batchResult"></div>

            <div class="pc-fg">
                <label>Programme Course IDs (comma/new line separated) <span class="req">*</span></label>
                <textarea id="batchIds" class="pc-ctrl" style="height:100px;resize:vertical;" placeholder="Example: 101, 102, 120"></textarea>
            </div>

            <div class="pc-row-3">
                <div class="pc-fg">
                    <label>Is Lecturer Assigned?</label>
                    <select id="batchAssigned" class="pc-ctrl" onchange="onBatchAssignedFlagChange(this.value)">
                        <option value="No">No</option>
                        <option value="Yes">Yes</option>
                    </select>
                </div>
                <div class="pc-fg" id="fgBatchLecturer">
                    <label>Lecturer</label>
                    <input type="hidden" id="hdnBatchLecturerVal" />
                    <div class="sd-wrap" id="sdBLectWrap">
                        <div class="sd-toggle" id="sdBLectToggle">
                            <span class="sd-toggle-text placeholder" id="sdBLectText">-- Select Lecturer --</span>
                            <span class="sd-toggle-arrow">&#9662;</span>
                        </div>
                        <div class="sd-panel" id="sdBLectPanel">
                            <input type="text" class="sd-search" id="sdBLectSearch" placeholder="Search by name&hellip;" autocomplete="off" />
                            <div class="sd-list" id="sdBLectList"></div>
                        </div>
                    </div>
                </div>
                <div class="pc-fg">
                    <label>Status</label>
                    <select id="batchStatus" class="pc-ctrl">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="pc-modal__foot">
            <button type="button" class="pc-btn pc-btn--sm" onclick="closeBatchModal()">Cancel</button>
            <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" onclick="submitBatchAssignment()">Apply Batch Update</button>
        </div>
    </div>

    <!-- ── Import from Load Allocations Wizard ──────────────── -->
    <div class="pc-overlay" id="pcImportOverlay"></div>
    <div class="pc-modal" id="pcImportModal" style="max-width:800px;max-height:92vh;">
        <div class="pc-modal__head">
            <h2 class="pc-modal__title" id="importStepTitle">Import Lecturers from Load Allocations - Step 1</h2>
            <button type="button" class="pc-modal__close" onclick="closeImportWizard()">&times;</button>
        </div>
        <div class="pc-modal__body">
            <div class="pc-alert pc-alert--error" id="importError"></div>
            <div class="pc-alert pc-alert--warning" id="importWarning"></div>

            <!-- Step indicator -->
            <div style="display:flex;gap:10px;margin-bottom:14px;font-size:11px;font-weight:700;color:#6b7280;">
                <span id="stepInd1" style="padding:4px 8px;background:#f0f0f0;border-radius:3px;">1. Discover</span>
                <span id="stepInd2" style="padding:4px 8px;background:#e0e0e0;border-radius:3px;opacity:0.5;">2. Summary</span>
                <span id="stepInd3" style="padding:4px 8px;background:#e0e0e0;border-radius:3px;opacity:0.5;">3. Review</span>
                <span id="stepInd4" style="padding:4px 8px;background:#e0e0e0;border-radius:3px;opacity:0.5;">4. Confirm</span>
                <span id="stepInd5" style="padding:4px 8px;background:#e0e0e0;border-radius:3px;opacity:0.5;">5. Execute</span>
                <span id="stepInd6" style="padding:4px 8px;background:#e0e0e0;border-radius:3px;opacity:0.5;">6. Complete</span>
            </div>

            <!-- STEP 1: Discover (select year/semester) -->
            <div id="importStep1" style="display:block;">
                <p style="font-size:12px;color:#374151;margin-bottom:14px;">
                    This wizard will help you import lecturer assignments from Load Allocations. It matches lecturers assigned in the Load Allocation 
                    section to Programme Courses, considering Year and Semester.<br/><br/>
                    <strong>Important:</strong> Only lecturers NOT YET assigned on this page will be imported. Already-matched records will be skipped.
                </p>
                <div class="pc-row-3">
                    <div class="pc-fg">
                        <label>Academic Year <span class="req">*</span></label>
                        <select id="importYear" class="pc-ctrl">
                            <option value="1">Year 1</option><option value="2">Year 2</option>
                            <option value="3">Year 3</option><option value="4">Year 4</option>
                            <option value="5">Year 5</option><option value="6">Year 6</option>
                        </select>
                    </div>
                    <div class="pc-fg">
                        <label>Semester <span class="req">*</span></label>
                        <select id="importSem" class="pc-ctrl">
                            <option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option>
                        </select>
                    </div>
                    <div class="pc-fg">
                        <label>&nbsp;</label>
                        <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" style="height:34px;" onclick="importStep1_Discover()">
                            Discover Candidates
                        </button>
                    </div>
                </div>
            </div>

            <!-- STEP 2: Summary of results -->
            <div id="importStep2" style="display:none;">
                <div style="background:#f0f7ff;border:1px solid #c7d8fb;padding:12px;border-radius:4px;margin-bottom:14px;font-size:11px;">
                    <div style="font-weight:700;color:#05275C;margin-bottom:8px;">Discovery Summary</div>
                    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;font-size:12px;">
                        <div><strong>Lecturers Found:</strong> <span id="s2LecturerCount">0</span></div>
                        <div><strong>Courses to Assign:</strong> <span id="s2CourseCount">0</span></div>
                        <div><strong>Assignments to Create:</strong> <span id="s2AssignmentCount">0</span></div>
                    </div>
                </div>
                <div style="margin-bottom:14px;">
                    <div style="font-weight:700;color:#374151;font-size:12px;margin-bottom:8px;">Candidates Found:</div>
                    <div id="s2CandidatesList" style="max-height:180px;overflow-y:auto;border:1px solid #e0e5ed;border-radius:3px;background:#fff;">
                        <!-- populated by JS -->
                    </div>
                </div>
            </div>

            <!-- STEP 3: Review & filter -->
            <div id="importStep3" style="display:none;">
                <p style="font-size:12px;color:#374151;margin-bottom:12px;">
                    Review the candidates below. You can deselect any that should not be imported.
                </p>
                <div style="max-height:220px;overflow-y:auto;border:1px solid #e0e5ed;border-radius:3px;background:#fff;">
                    <div id="s3ReviewList" style="padding:8px;">
                        <!-- populated by JS -->
                    </div>
                </div>
                <div style="margin-top:12px;font-size:11px;color:#6b7280;">
                    <input type="checkbox" id="s3CheckAll" onchange="importStep3_ToggleAll()"/> <label for="s3CheckAll">Select/Deselect All</label>
                </div>
            </div>

            <!-- STEP 4: Confirmation -->
            <div id="importStep4" style="display:none;">
                <div style="background:#fef3e6;border:1px solid #f3d19a;padding:12px;border-radius:4px;margin-bottom:14px;font-size:11px;">
                    <div style="font-weight:700;color:#b45309;margin-bottom:6px;">⚠ Confirmation Required</div>
                    <p style="margin:6px 0;font-size:12px;color:#374151;">
                        The following will be imported:
                    </p>
                    <ul style="margin:6px 0 0 20px;font-size:11px;color:#374151;">
                        <li>Year: <strong id="s4Year">-</strong></li>
                        <li>Semester: <strong id="s4Sem">-</strong></li>
                        <li>Total Assignments: <strong id="s4Total">0</strong></li>
                    </ul>
                    <p style="margin:8px 0 0 0;font-size:11px;color:#b45309;">
                        <strong>This is a permanent action.</strong> All selected lecturers will be added to the Programme Courses system.
                    </p>
                </div>
            </div>

            <!-- STEP 5: Executing -->
            <div id="importStep5" style="display:none;">
                <p style="font-size:12px;color:#374151;margin-bottom:14px;">
                    Processing your request. This may take a moment...
                </p>
                <div style="background:#f0f7ff;border:1px solid #c7d8fb;padding:12px;border-radius:4px;text-align:center;">
                    <div style="font-size:14px;color:#05275C;font-weight:700;">
                        <span style="display:inline-block;animation:spin .8s linear infinite;margin-right:8px;">⟳</span>
                        Processing...
                    </div>
                </div>
            </div>

            <!-- STEP 6: Complete -->
            <div id="importStep6" style="display:none;">
                <div style="background:#e8f5e9;border:1px solid #4caf50;padding:12px;border-radius:4px;margin-bottom:14px;">
                    <div style="font-weight:700;color:#2e7d32;margin-bottom:8px;">✓ Import Complete</div>
                    <div id="s6ResultText" style="font-size:12px;color:#374151;line-height:1.6;">
                        <!-- populated by JS -->
                    </div>
                </div>
            </div>
        </div>
        <div class="pc-modal__foot">
            <button type="button" class="pc-btn pc-btn--sm" id="importBtnCancel" onclick="closeImportWizard()">Cancel</button>
            <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" id="importBtnNext" style="display:none;" onclick="importStep_Next()">Next</button>
            <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" id="importBtnConfirm" style="display:none;" onclick="importStep4_Confirm()">Confirm & Execute</button>
            <button type="button" class="pc-btn pc-btn--primary pc-btn--sm" id="importBtnClose" style="display:none;" onclick="closeImportWizard()">Close</button>
        </div>
    </div>

    <!-- Import wizard animation -->
    <style>
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
    </style>

<script type="text/javascript">
// ============================================================
// IMPORT FROM LOAD ALLOCATIONS WIZARD
// ============================================================
var importState = {
    currentStep: 1,
    year: 1,
    semester: 1,
    candidates: [],    // list of {lecturerId, lecturerName, courseId, courseCode, courseName, progcode, progname, specId, specName, study_year, semester}
    selected: {}        // map of candidate index to bool
};

function updateImportStepIndicator(step) {
    for (var i = 1; i <= 6; i++) {
        var ind = byId('stepInd' + i);
        if (i <= step) {
            ind.style.background = '#05275C';
            ind.style.color = '#fff';
            ind.style.opacity = '1';
        } else {
            ind.style.background = '#e0e0e0';
            ind.style.color = '#6b7280';
            ind.style.opacity = '0.5';
        }
    }
}

function showImportStep(step) {
    for (var i = 1; i <= 6; i++) {
        var el = byId('importStep' + i);
        if (el) el.style.display = (i === step) ? 'block' : 'none';
    }
    importState.currentStep = step;
    updateImportStepIndicator(step);

    var btnNext = byId('importBtnNext'),
        btnConfirm = byId('importBtnConfirm'),
        btnClose = byId('importBtnClose'),
        btnCancel = byId('importBtnCancel');
    
    btnNext.style.display = (step >= 2 && step <= 4) ? 'inline-flex' : 'none';
    btnConfirm.style.display = (step === 4) ? 'inline-flex' : 'none';
    btnClose.style.display = (step === 6) ? 'inline-flex' : 'none';
    btnCancel.style.display = (step < 5) ? 'inline-flex' : 'none';

    if (step === 2) byId('importStepTitle').textContent = 'Import Lecturers - Step 2: Summary';
    else if (step === 3) byId('importStepTitle').textContent = 'Import Lecturers - Step 3: Review';
    else if (step === 4) byId('importStepTitle').textContent = 'Import Lecturers - Step 4: Confirm';
    else if (step === 5) byId('importStepTitle').textContent = 'Import Lecturers - Step 5: Executing';
    else if (step === 6) byId('importStepTitle').textContent = 'Import Lecturers - Step 6: Complete';
    else byId('importStepTitle').textContent = 'Import Lecturers - Step ' + step;

    clearImportErrors();
}

function clearImportErrors() {
    var e = byId('importError'), w = byId('importWarning');
    if (e) { e.textContent = ''; e.classList.remove('show'); }
    if (w) { w.textContent = ''; w.classList.remove('show'); }
}

function showImportError(msg) {
    var e = byId('importError');
    if (e) { e.textContent = msg; e.classList.add('show'); }
}

function showImportWarning(msg) {
    var w = byId('importWarning');
    if (w) { w.textContent = msg; w.classList.add('show'); }
}

function openImportFromLoadAllocationsWizard() {
    clearImportErrors();
    importState.candidates = [];
    importState.selected = {};
    showImportStep(1);
    byId('pcImportOverlay').classList.add('show');
    byId('pcImportModal').classList.add('show');
}

function closeImportWizard() {
    byId('pcImportOverlay').classList.remove('show');
    byId('pcImportModal').classList.remove('show');
}

function importStep1_Discover() {
    var year = byId('importYear').value,
        sem = byId('importSem').value;
    if (!year || !sem) { showImportError('Please select Year and Semester.'); return; }
    
    importState.year = year;
    importState.semester = sem;

    byId('importBtnNext').disabled = true;
    fetch('DashboardNewProgrammeCourses.aspx/ImportStep_DiscoverCandidates', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify({ request: { year: parseInt(year, 10), semester: parseInt(sem, 10) } })
    })
    .then(function(r) { return r.json(); })
    .then(function(payload) {
        var d = payload && payload.d ? payload.d : null;
        if (!d || d.Success !== true) { 
            showImportError((d && d.Message) ? d.Message : 'Failed to discover candidates.');
            byId('importBtnNext').disabled = false;
            return;
        }
        importState.candidates = d.Candidates || [];
        if (importState.candidates.length === 0) {
            showImportWarning((d && d.Message) ? d.Message : ('No candidates found for Year ' + year + ', Semester ' + sem + '.'));
            byId('importBtnNext').disabled = false;
            return;
        }

        // Populate summary stats
        var lecturerIds = {}, courseIds = {};
        for (var i = 0; i < importState.candidates.length; i++) {
            var c = importState.candidates[i];
            lecturerIds[c.lecturerId] = 1;
            courseIds[c.courseId] = 1;
        }

        byId('s2LecturerCount').textContent = Object.keys(lecturerIds).length;
        byId('s2CourseCount').textContent = Object.keys(courseIds).length;
        byId('s2AssignmentCount').textContent = importState.candidates.length;

        // Populate candidate list
        var html = '';
        for (var i = 0; i < importState.candidates.length; i++) {
            var c = importState.candidates[i];
            html += '<div style="padding:8px;border-bottom:1px solid #eee;font-size:11px;">' +
                    '<strong>' + escH(c.lecturerName) + '</strong> → ' +
                    '<span style="color:#174DA4;font-weight:600;">' + escH(c.courseCode) + '</span> ' +
                    escH(c.courseName) + ' (' + escH(c.progname) + ')' +
                    '</div>';
        }
        byId('s2CandidatesList').innerHTML = html || '<div style="padding:8px;color:#999;">No candidates.</div>';

        // Pre-select all for step 3
        importState.selected = {};
        for (var i = 0; i < importState.candidates.length; i++) {
            importState.selected[i] = true;
        }

        showImportStep(2);
        byId('importBtnNext').disabled = false;
    })
    .catch(function(err) {
        showImportError('Error: ' + (err && err.message ? err.message : 'Unknown'));
        byId('importBtnNext').disabled = false;
    });
}

function importStep_Next() {
    if (importState.currentStep === 2) {
        // Move from Summary to Review
        populateReviewList();
        showImportStep(3);
    } else if (importState.currentStep === 3) {
        // Move from Review to Confirm
        var selectedCount = 0;
        for (var k in importState.selected) { if (importState.selected[k]) selectedCount++; }
        if (selectedCount === 0) { showImportError('Please select at least one candidate.'); return; }

        byId('s4Year').textContent = 'Year ' + importState.year;
        byId('s4Sem').textContent = 'Semester ' + importState.semester;
        byId('s4Total').textContent = selectedCount;
        showImportStep(4);
    }
}

function populateReviewList() {
    var html = '';
    for (var i = 0; i < importState.candidates.length; i++) {
        var c = importState.candidates[i];
        var chk = importState.selected[i];
        html += '<div style="padding:8px;border-bottom:1px solid #eee;font-size:11px;display:flex;gap:8px;align-items:flex-start;">' +
                '<input type="checkbox" id="candChk' + i + '" ' + (chk ? 'checked' : '') + ' onchange="importStep3_UpdateSelection(' + i + ', this.checked)" style="margin-top:2px;" />' +
                '<label for="candChk' + i + '" style="flex:1;cursor:pointer;font-size:12px;">' +
                '<strong>' + escH(c.lecturerName) + '</strong> → ' +
                '<span style="color:#174DA4;font-weight:600;">' + escH(c.courseCode) + '</span> ' +
                escH(c.courseName) + ' (' + escH(c.progname) + ', Year ' + c.study_year + ', Sem ' + c.semester + ')' +
                '</label>' +
                '</div>';
    }
    byId('s3ReviewList').innerHTML = html || '<div style="padding:8px;color:#999;">No candidates.</div>';
}

function importStep3_UpdateSelection(idx, isSelected) {
    importState.selected[idx] = isSelected;
}

function importStep3_ToggleAll() {
    var all = byId('s3CheckAll').checked;
    for (var i = 0; i < importState.candidates.length; i++) {
        var chk = byId('candChk' + i);
        if (chk) { chk.checked = all; importState.selected[i] = all; }
    }
}

function importStep4_Confirm() {
    // Collect selected and execute
    var toImport = [];
    for (var i = 0; i < importState.candidates.length; i++) {
        if (importState.selected[i]) {
            var c = importState.candidates[i] || {};
            toImport.push({
                lecturerId: parseInt(c.lecturerId, 10) || 0,
                courseCode: (c.courseCode || '').toString(),
                progcode: (c.progcode || '').toString(),
                specId: parseInt(c.specId, 10) || 0,
                study_year: parseInt(c.study_year, 10) || 0,
                semester: parseInt(c.semester, 10) || 0
            });
        }
    }

    if (toImport.length === 0) { showImportError('No candidates selected.'); return; }

    showImportStep(5);
    byId('importBtnConfirm').disabled = true;

    fetch('DashboardNewProgrammeCourses.aspx/ImportStep_ExecuteAssignments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify({ request: { candidates: toImport } })
    })
    .then(function(r) { return r.json(); })
    .then(function(payload) {
        var d = payload && payload.d ? payload.d : null;
        if (!d) { showImportError('Execution failed: No response.'); showImportStep(4); return; }
        
        if (d.Success !== true) {
            showImportError((d.Message || 'Execution failed.'));
            showImportStep(4);
            byId('importBtnConfirm').disabled = false;
            return;
        }

        // Show results
        var html = '<strong>Successfully Imported:</strong><br/>' +
                   '&nbsp;&nbsp;• <strong>' + (d.SuccessCount || 0) + '</strong> lecturer assignment(s) created<br/>';
        if (d.SkippedCount && d.SkippedCount > 0) {
            html += '&nbsp;&nbsp;• <strong>' + d.SkippedCount + '</strong> skipped (already assigned)<br/>';
        }
        if (d.ErrorCount && d.ErrorCount > 0) {
            html += '&nbsp;&nbsp;• <strong>' + d.ErrorCount + '</strong> failed<br/>';
        }
        if (d.Details) {
            html += '<br/><strong>Details:</strong><br/>' + escH(d.Details).replace(/\n/g, '<br/>');
        }
        byId('s6ResultText').innerHTML = html;
        showImportStep(6);
    })
    .catch(function(err) {
        showImportError('Error: ' + (err && err.message ? err.message : 'Unknown'));
        showImportStep(4);
        byId('importBtnConfirm').disabled = false;
    });
}

// Overlay click
document.addEventListener('DOMContentLoaded', function(){
    var importOverlay = document.getElementById('pcImportOverlay');
    if(importOverlay){
        importOverlay.addEventListener('click', function(e){
            if (e.target === importOverlay) closeImportWizard();
        });
    }
});
</script>

<!-- ── JavaScript ──────────────────────────────────────────── -->
<script type="text/javascript">
/* ── Server data ──────────────────────────────────────────── */
var __allProgs  = <%= BuildProgrammesJson() %>;
var __allSpecs  = <%= BuildSpecsJson() %>;
var __allCourses = <%= BuildCoursesJson() %>;
var __allLecturers = <%= BuildLecturersJson() %>;

function byId(id){ return document.getElementById(id); }

/* ── URL filter helpers ───────────────────────────────────── */
function applyUrlFilter(){
    var qs=new URLSearchParams(window.location.search);
    qs.set('page','1');
    qs.delete('focusId'); qs.delete('page');
    var yr=byId('pcFilterYear').value; if(yr) qs.set('yr',yr); else qs.delete('yr');
    var sem=byId('pcFilterSem').value; if(sem) qs.set('sem',sem); else qs.delete('sem');
    var asg=byId('pcFilterAssigned').value; if(asg) qs.set('asg',asg); else qs.delete('asg');
    var lec=byId('pcFilterLecturer').value; if(lec) qs.set('lec',lec); else qs.delete('lec');
    var tp=byId('pcFilterType').value; if(tp) qs.set('tp',tp); else qs.delete('tp');
    var rq=byId('pcFilterReq').value; if(rq) qs.set('rq',rq); else qs.delete('rq');
    var vw=byId('pcFilterView').value; if(vw) qs.set('view',vw); else qs.delete('view');
    var sq=(byId('pcSearchInput').value||'').trim(); if(sq) qs.set('q',sq); else qs.delete('q');
    window.location.href=window.location.pathname+'?'+qs.toString();
}
function resetFilters(){
    byId('pcSearchInput').value='';
    filterPcTable('');
    window.location.href=window.location.pathname;
}
(function initFilterSelects(){
    var qs=new URLSearchParams(window.location.search);
    var yr=qs.get('yr'), sem=qs.get('sem'), asg=qs.get('asg'), lec=qs.get('lec'), tp=qs.get('tp'), rq=qs.get('rq'), view=qs.get('view');
    if(yr){ var el=byId('pcFilterYear'); if(el) el.value=yr; }
    if(sem){ var el=byId('pcFilterSem'); if(el) el.value=sem; }
    if(asg){ var el=byId('pcFilterAssigned'); if(el) el.value=asg; }
    if(lec){ var el=byId('pcFilterLecturer'); if(el) el.setAttribute('data-selected', lec); }
    if(tp){ var el=byId('pcFilterType'); if(el) el.value=tp; }
    if(rq){ var el=byId('pcFilterReq'); if(el) el.value=rq; }
    if(view){ var el=byId('pcFilterView'); if(el) el.value=view; }
    var sq=qs.get('q'); if(sq){ var si=byId('pcSearchInput'); if(si) si.value=sq; }
})();

var _reqDecisionId='';
function openRequestDecisionModal(id,ctx,lecturer,reqMsg,adminMsg){
    _reqDecisionId=id||'';
    byId('reqDecisionErr').classList.remove('show');
    byId('reqDecisionCtx').textContent=ctx||'-';
    byId('reqDecisionLecturer').textContent=lecturer||'-';
    byId('reqDecisionMessage').textContent=reqMsg||'-';
    byId('reqDecisionAdminMessage').value=adminMsg||'';
    byId('reqDecisionStatus').value='Approved';
    byId('pcReqDecisionOverlay').classList.add('show');
    byId('pcReqDecisionModal').classList.add('show');
}
function closeRequestDecisionModal(){
    byId('pcReqDecisionOverlay').classList.remove('show');
    byId('pcReqDecisionModal').classList.remove('show');
}
function submitRequestDecision(){
    var id=parseInt(_reqDecisionId||'0',10);
    if(!id){ var e=byId('reqDecisionErr'); e.textContent='Invalid row selected.'; e.classList.add('show'); return; }
    var decision=byId('reqDecisionStatus').value||'Pending';
    var adminMessage=(byId('reqDecisionAdminMessage').value||'').trim();
    var btn=byId('btnReqDecisionSave'); btn.disabled=true;

    fetch('DashboardNewProgrammeCourses.aspx/ProcessAllocationRequestDecision',{
        method:'POST',
        headers:{'Content-Type':'application/json; charset=utf-8'},
        body:JSON.stringify({request:{programmeCourseId:id,decision:decision,adminMessage:adminMessage}})
    })
    .then(function(r){return r.json();})
    .then(function(payload){
        btn.disabled=false;
        var d=payload&&payload.d?payload.d:null;
        if(!d||d.Success!==true){
            var e=byId('reqDecisionErr');
            e.textContent=(d&&d.Message)||'Failed to update request.';
            e.classList.add('show');
            return;
        }
        closeRequestDecisionModal();
        showToast(d.Message||'Request decision saved.','success');
        setTimeout(function(){ window.location.reload(); }, 250);
    })
    .catch(function(){
        btn.disabled=false;
        var e=byId('reqDecisionErr');
        e.textContent='Network error while saving decision.';
        e.classList.add('show');
    });
}

function loadLecturerFilterOptions(){
    var filterVal = byId('pcFilterLecturer');
    if(!filterVal) return;
    fetch('DashboardNewProgrammeCourses.aspx/GetLecturerFilterOptions',{
        method:'POST',
        headers:{'Content-Type':'application/json; charset=utf-8'},
        body:'{}'
    })
    .then(function(r){ return r.json(); })
    .then(function(payload){
        var d = payload && payload.d ? payload.d : null;
        if(!d || d.Success!==true || !d.Items) return;
        var selected = filterVal.getAttribute('data-selected') || '';
        var data = [{ v:'', t:'All Lecturers' }];
        for(var i=0;i<d.Items.length;i++){
            var it = d.Items[i] || {};
            var id = (it.id || '').toString();
            var name = (it.name || '').toString();
            if(!id || !name) continue;
            data.push({ v:id, t:name });
        }
        if(SD && SD['flect']){
            sdSetData('flect', data);
            if(selected) sdSetValue('flect', selected); else sdSetValue('flect', '');
        }
    })
    .catch(function(){ /* keep page usable even if ajax fails */ });
}

/* ── Search: debounce then reload server-side ────────────── */
var _searchTimer=null;
function filterPcTable(q){
    clearTimeout(_searchTimer);
    _searchTimer=setTimeout(function(){ applyUrlFilter(); }, 420);
}

/* ── Modal open/close ─────────────────────────────────────── */
function openModal(mode, editId){
    byId('modalResult').innerHTML=''; byId('modalResult').classList.remove('show');
    byId('<%= hdnModalMode.ClientID %>').value=mode||'NEW';
    byId('<%= hdnEditId.ClientID %>').value=editId||'';
    if(mode==='NEW'){
        byId('modalTitle').textContent='Add Programme Course';
        setCourseEditable(true);
        sdReset('prog'); sdSetData('spec',[]);
        clearCourseSelection(); clearCourseSearch();
        byId('uiYear').value='1'; byId('<%= ddlYear.ClientID %>').value='1';
        byId('uiSemester').value='1'; byId('<%= ddlSemester.ClientID %>').value='1';
        byId('uiCourseType').value='CORE'; byId('<%= ddlCourseType.ClientID %>').value='CORE';
        byId('uiIsLecturerAssigned').value='No'; byId('<%= ddlIsLecturerAssigned.ClientID %>').value='No';
        byId('uiAssignmentStatus').value='Active'; byId('<%= ddlAssignmentStatus.ClientID %>').value='Active';
        if(SD&&SD['lect']) sdReset('lect'); byId('<%= ddlLecturer.ClientID %>').value='';
        onAssignedFlagChange('No');
    } else {
        byId('modalTitle').textContent='Edit Programme Course';
        setCourseEditable(false);
    }
    byId('pcOverlay').classList.add('show');
    byId('pcModal').classList.add('show');
    if(!window._csInit){ initCourseSearch(); window._csInit=true; }
}
function closeModal(){
    byId('pcOverlay').classList.remove('show');
    byId('pcModal').classList.remove('show');
    setCourseEditable(true);
    clearCourseSearch();
}

function setCourseEditable(isEditable){
    var inp=byId('courseSearchInput');
    if(!inp) return;
    inp.disabled=!isEditable;
    inp.placeholder=isEditable?'Type course code or name to search…':'Course is locked in Edit mode';
}

function onAssignedFlagChange(v){
    var fg=byId('fgLecturer');
    var isYes=(v||'No')==='Yes';
    if(fg) fg.style.opacity=isYes?'1':'0.55';
    if(!isYes){
        if(SD&&SD['lect']) sdReset('lect');
        byId('<%= ddlLecturer.ClientID %>').value='';
    }
}

/* ── Edit & Delete row actions ────────────────────────────── */
function editRow(id){
    byId('<%= hdnEditId.ClientID %>').value=id;
    byId('<%= hdnModalMode.ClientID %>').value='LOAD';
    __doPostBack('<%= btnLoadEdit.UniqueID %>','');
}
function deleteRow(id,courseCode){
    if(!confirm('Delete course "'+courseCode+'" from this programme?\n\nThis cannot be undone.')) return;
    byId('<%= hdnEditId.ClientID %>').value=id;
    __doPostBack('<%= btnDelete.UniqueID %>','');
}

/* ── Save ─────────────────────────────────────────────────── */
function saveRecord(){
    var prog=byId('<%= ddlProgramme.ClientID %>').value;
    var spec=byId('<%= ddlSpecialisation.ClientID %>').value;
    var course=byId('<%= hdnSelectedCourse.ClientID %>').value;
    var assigned=byId('<%= ddlIsLecturerAssigned.ClientID %>').value || 'No';
    var lecturerId=byId('<%= ddlLecturer.ClientID %>').value || '';
    if(lecturerId && assigned!=='Yes'){
        assigned='Yes';
        byId('<%= ddlIsLecturerAssigned.ClientID %>').value='Yes';
        if(byId('uiIsLecturerAssigned')) byId('uiIsLecturerAssigned').value='Yes';
        onAssignedFlagChange('Yes');
    }
    if(!prog){ showModalError('Please select a Programme.'); return; }
    if(!spec){ showModalError('Please select a Specialisation.'); return; }
    if(!course){ showModalError('Please search and select a Course.'); return; }
    if(assigned==='Yes' && !lecturerId){ showModalError('Please select a Lecturer when assignment is Yes.'); return; }
    __doPostBack('<%= btnSave.UniqueID %>','');
}
function showModalError(msg){
    var r=byId('modalResult'); r.textContent=msg; r.classList.add('show');
}

/* ── Toast ────────────────────────────────────────────────── */
function showToast(msg,type){
    var t=document.createElement('div');
    t.style.cssText='position:fixed;bottom:20px;right:20px;z-index:99999;padding:10px 18px;font-size:13px;font-weight:600;color:#fff;box-shadow:0 3px 10px rgba(0,0,0,.2);opacity:1;transition:opacity .4s;';
    t.style.background=type==='success'?'#16a34a':type==='danger'?'#dc3545':type==='warning'?'#d97706':'#174DA4';
    t.textContent=msg;
    document.body.appendChild(t);
    setTimeout(function(){t.style.opacity='0';setTimeout(function(){if(t.parentNode)t.parentNode.removeChild(t);},400);},3000);
}

/* ── Searchable Dropdown (SD) ─────────────────────────────── */
var SD={};
function sdInit(key,cfg){
    SD[key]={toggle:byId(cfg.toggleId),panel:byId(cfg.panelId),search:byId(cfg.searchId),list:byId(cfg.listId),select:byId(cfg.selectId),data:cfg.data||[],placeholder:cfg.placeholder||'-- Select --',onChange:cfg.onChange||null,value:'',text:''};
    var d=SD[key];
    d.toggle.addEventListener('click',function(e){e.stopPropagation();sdTogglePanel(key);});
    d.panel.addEventListener('click',function(e){e.stopPropagation();});
    d.search.addEventListener('input',function(){sdRender(key);});
    sdRender(key); sdUpdateDisplay(key);
}
function sdTogglePanel(key){var d=SD[key];var isOpen=d.panel.classList.contains('is-open');sdCloseAll();if(!isOpen){d.panel.classList.add('is-open');d.search.value='';sdRender(key);d.search.focus();}}
function sdCloseAll(){for(var k in SD) SD[k].panel.classList.remove('is-open');}
function sdRender(key){
    var d=SD[key],q=d.search.value.toLowerCase().trim(),items=d.data;
    if(q) items=items.filter(function(it){return it.t.toLowerCase().indexOf(q)!=-1||(it.v&&it.v.toLowerCase().indexOf(q)!=-1);});
    if(items.length===0){d.list.innerHTML='<div class="sd-empty">No matches found</div>';return;}
    var h='';
    for(var i=0;i<items.length;i++){var sel=items[i].v===d.value?' is-sel':'';h+='<div class="sd-item'+sel+'" onclick="sdSelect(\''+key+'\',\''+escA(items[i].v)+'\',\''+escA(items[i].t)+'\')">'+escH(items[i].t)+'</div>';}
    d.list.innerHTML=h;
}
function sdSelect(key,value,text){var d=SD[key];d.value=value;d.text=text;d.select.value=value;d.panel.classList.remove('is-open');sdUpdateDisplay(key);if(d.onChange) d.onChange(value);}
function sdUpdateDisplay(key){var d=SD[key];var span=d.toggle.querySelector('.sd-toggle-text');if(d.value&&d.text){span.textContent=d.text;span.classList.remove('placeholder');}else{span.textContent=d.placeholder;span.classList.add('placeholder');}}
function sdSetData(key,data){var d=SD[key];d.data=data;d.value='';d.text='';if(d.select&&d.select.tagName==='SELECT') d.select.selectedIndex=0; else if(d.select) d.select.value='';sdUpdateDisplay(key);}
function sdSetValue(key,value){var d=SD[key];var item=null;for(var i=0;i<d.data.length;i++){if(d.data[i].v===value){item=d.data[i];break;}}if(item){d.value=item.v;d.text=item.t;d.select.value=item.v;}else{d.value=value;d.text='';d.select.value=value;}sdUpdateDisplay(key);}
function sdReset(key){var d=SD[key];d.value='';d.text='';if(d.select&&d.select.tagName==='SELECT') d.select.selectedIndex=0; else if(d.select) d.select.value='';sdUpdateDisplay(key);}
function getSpecsForProg(p){if(!p) return [];return __allSpecs.filter(function(s){return s.p===p;}).map(function(s){return{v:s.id,t:s.n};});}
document.addEventListener('click',sdCloseAll);

/* ── Course search autocomplete ───────────────────────────── */
var _csTimer;
function initCourseSearch(){
    var inp=byId('courseSearchInput'),dd=byId('courseSearchResults');
    if(!inp||!dd) return;
    inp.addEventListener('input',function(){
        clearTimeout(_csTimer);
        var q=this.value.toLowerCase().trim();
        if(q.length<2){dd.classList.remove('is-open');dd.innerHTML='';return;}
        _csTimer=setTimeout(function(){
            var all=__allCourses||[],m=[];
            for(var i=0;i<all.length&&m.length<20;i++){if(all[i].c.toLowerCase().indexOf(q)!=-1||all[i].n.toLowerCase().indexOf(q)!=-1) m.push(all[i]);}
            dd.innerHTML=m.length===0?'<div style="padding:8px 10px;font-size:12px;color:#888;">No courses found</div>':m.map(function(x){return'<div class="pc-search-item" onclick="selectCourse(\''+escA(x.c)+'\',\''+escA(x.n)+'\')"><span class="pc-si-code">'+escH(x.c)+'</span><span class="pc-si-name">'+escH(x.n)+'</span></div>';}).join('');
            dd.classList.add('is-open');
        },120);
    });
    document.addEventListener('click',function(e){if(!inp.contains(e.target)&&!dd.contains(e.target))dd.classList.remove('is-open');});
}
function selectCourse(code,name){
    byId('<%= hdnSelectedCourse.ClientID %>').value=code;
    byId('courseSearchInput').value='';
    byId('courseSearchResults').classList.remove('is-open');
    var d=byId('courseSelectedDisplay');
    d.innerHTML='<span class="pc-sc-code">'+escH(code)+'</span> '+escH(name)+'<button type="button" class="pc-sc-clear" onclick="clearCourseSelection()" title="Clear">&times;</button>';
    d.style.display='flex';
}
function clearCourseSelection(){byId('<%= hdnSelectedCourse.ClientID %>').value='';var d=byId('courseSelectedDisplay');d.style.display='none';d.innerHTML='';}
function clearCourseSearch(){var inp=byId('courseSearchInput');if(inp)inp.value='';var dd=byId('courseSearchResults');if(dd){dd.innerHTML='';dd.classList.remove('is-open');}clearCourseSelection();}

/* ── Lecturer selects ─────────────────────────────────────── */
function populateLecturerSelects(){
    var data=(__allLecturers||[]).map(function(it){return{v:String(it.id),t:it.n};});
    sdSetData('lect',data);
    sdSetData('blect',data);
}

/* ── Batch modal / ajax ───────────────────────────────────── */
function openBatchModal(){
    var r=byId('batchResult'); r.innerHTML=''; r.classList.remove('show');
    byId('batchAssigned').value='No';
    byId('batchStatus').value='Active';
    if(SD&&SD['blect']) sdReset('blect'); byId('hdnBatchLecturerVal').value='';
    onBatchAssignedFlagChange('No');
    byId('pcBatchOverlay').classList.add('show');
    byId('pcBatchModal').classList.add('show');
}
function closeBatchModal(){
    byId('pcBatchOverlay').classList.remove('show');
    byId('pcBatchModal').classList.remove('show');
}
function onBatchAssignedFlagChange(v){
    var fg=byId('fgBatchLecturer');
    var isYes=(v||'No')==='Yes';
    if(fg) fg.style.opacity=isYes?'1':'0.55';
    if(!isYes){ if(SD&&SD['blect']) sdReset('blect'); byId('hdnBatchLecturerVal').value=''; }
}
function showBatchError(msg){
    var r=byId('batchResult'); r.textContent=msg; r.classList.add('show');
}
function parseBatchIds(raw){
    raw=(raw||'').replace(/\n/g,',').replace(/;/g,',');
    var bits=raw.split(',');
    var out=[]; var seen={};
    for(var i=0;i<bits.length;i++){
        var n=parseInt((bits[i]||'').trim(),10);
        if(!isNaN(n) && n>0 && !seen[n]){ seen[n]=1; out.push(n); }
    }
    return out;
}
function submitBatchAssignment(){
    var ids=parseBatchIds(byId('batchIds').value);
    if(ids.length===0){ showBatchError('Please provide at least one Programme Course ID.'); return; }
    var assigned=byId('batchAssigned').value||'No';
    var lecturerId=byId('hdnBatchLecturerVal').value||'';
    var status=byId('batchStatus').value||'Active';
    if(assigned==='Yes' && !lecturerId){ showBatchError('Please select a Lecturer when assignment is Yes.'); return; }

    fetch('DashboardNewProgrammeCourses.aspx/BatchAssignLecturers',{
        method:'POST',
        headers:{'Content-Type':'application/json; charset=utf-8'},
        body:JSON.stringify({request:{courseIds:ids, lecturerId:lecturerId?parseInt(lecturerId,10):null, isAssigned:assigned, status:status}})
    })
    .then(function(r){ return r.json(); })
    .then(function(payload){
        var d=payload&&payload.d?payload.d:null;
        if(!d || d.Success!==true){ showBatchError((d&&d.Message)?d.Message:'Batch update failed.'); return; }
        closeBatchModal();
        showToast('Batch assignment completed for '+d.UpdatedCount+' record(s).','success');
        window.location.reload();
    })
    .catch(function(err){ showBatchError('Batch update failed: '+(err&&err.message?err.message:'Unknown error')); });
}

/* ── Helpers ──────────────────────────────────────────────── */
function escH(s){var d=document.createElement('div');d.appendChild(document.createTextNode(s));return d.innerHTML;}
function escA(s){return s.replace(/\\/g,'\\\\').replace(/'/g,"\\'");}

/* ── ESC / overlay click ──────────────────────────────────── */
document.addEventListener('DOMContentLoaded',function(){
    var ov=byId('pcOverlay'); if(ov) ov.addEventListener('click',function(e){if(e.target===ov)closeModal();});
    var bov=byId('pcBatchOverlay'); if(bov) bov.addEventListener('click',function(e){if(e.target===bov)closeBatchModal();});
    var rov=byId('pcReqDecisionOverlay'); if(rov) rov.addEventListener('click',function(e){if(e.target===rov)closeRequestDecisionModal();});
    loadLecturerFilterOptions();
    populateLecturerSelects();
    onAssignedFlagChange(byId('uiIsLecturerAssigned') ? byId('uiIsLecturerAssigned').value : 'No');
    onBatchAssignedFlagChange(byId('batchAssigned') ? byId('batchAssigned').value : 'No');
});
document.addEventListener('keydown',function(e){
    if(e.key!=='Escape') return;
    if(byId('pcReqDecisionModal') && byId('pcReqDecisionModal').classList.contains('show')){ closeRequestDecisionModal(); return; }
    var anySD=false; for(var k in SD){if(SD[k].panel.classList.contains('is-open')){anySD=true;break;}}
    if(anySD) sdCloseAll(); else closeModal();
});

/* ── Init searchable dropdowns ────────────────────────────── */
sdInit('prog',{toggleId:'sdProgToggle',panelId:'sdProgPanel',searchId:'sdProgSearch',listId:'sdProgList',selectId:'<%= ddlProgramme.ClientID %>',data:__allProgs,placeholder:'-- Select Programme --',onChange:function(val){var specs=getSpecsForProg(val);sdSetData('spec',specs);if(specs.length===1) sdSetValue('spec',specs[0].v);}});
sdInit('spec',{toggleId:'sdSpecToggle',panelId:'sdSpecPanel',searchId:'sdSpecSearch',listId:'sdSpecList',selectId:'<%= ddlSpecialisation.ClientID %>',data:[],placeholder:'-- Select Specialisation --'});
sdInit('lect',{toggleId:'sdLectToggle',panelId:'sdLectPanel',searchId:'sdLectSearch',listId:'sdLectList',selectId:'<%= ddlLecturer.ClientID %>',data:[],placeholder:'-- Select Lecturer --',onChange:function(val){if(val){byId('<%= ddlIsLecturerAssigned.ClientID %>').value='Yes';if(byId('uiIsLecturerAssigned')) byId('uiIsLecturerAssigned').value='Yes';onAssignedFlagChange('Yes');}}});
sdInit('blect',{toggleId:'sdBLectToggle',panelId:'sdBLectPanel',searchId:'sdBLectSearch',listId:'sdBLectList',selectId:'hdnBatchLecturerVal',data:[],placeholder:'-- Select Lecturer --'});
sdInit('flect',{toggleId:'sdFLectToggle',panelId:'sdFLectPanel',searchId:'sdFLectSearch',listId:'sdFLectList',selectId:'pcFilterLecturer',data:[{v:'',t:'All Lecturers'}],placeholder:'All Lecturers',onChange:function(){applyUrlFilter();}});
</script>
</asp:Content>
