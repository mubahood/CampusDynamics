<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="CourseRegistrationLedgerController.aspx.cs" Inherits="COOPERP_NewScreens_CourseRegistrationLedgerController" Title="Course Registration Ledger - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Hero ─────────────────────────────────────────────────── */
.rl-hero { background:#05275C; color:#fff; padding:16px 18px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; }
.rl-hero__title { font-size:17px; font-weight:800; margin:0 0 4px; }
.rl-hero__sub { font-size:12px; opacity:.82; margin:0; }
.rl-hero__actions { display:flex; gap:8px; flex-wrap:wrap; }

/* ── Stat tiles ───────────────────────────────────────────── */
.rl-stats { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-bottom:16px; }
.rl-stat { background:#fff; border:1px solid #e0e5ed; padding:14px; }
.rl-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; font-weight:700; }
.rl-stat__value { font-size:22px; color:#05275C; font-weight:800; margin-top:8px; }

/* ── Card ─────────────────────────────────────────────────── */
.rl-card { background:#fff; border:1px solid #e0e5ed; margin-bottom:16px; }
.rl-card__head { display:flex; justify-content:space-between; align-items:center; gap:10px; padding:12px 14px; border-bottom:2px solid #e0e5ed; background:#f8fafc; flex-wrap:wrap; }
.rl-card__title { font-size:12px; font-weight:800; color:#05275C; text-transform:uppercase; letter-spacing:.4px; }
.rl-card__body { padding:0; }

/* ── Buttons ──────────────────────────────────────────────── */
.rl-btn { display:inline-flex; align-items:center; gap:6px; padding:8px 12px; border:1px solid #d2dae6; background:#fff; color:#05275C; text-decoration:none; font-size:12px; font-weight:700; cursor:pointer; }
.rl-btn:hover { background:#f5f8ff; border-color:#174DA4; text-decoration:none; color:#174DA4; }
.rl-btn--primary { background:#05275C; border-color:#05275C; color:#fff; }
.rl-btn--primary:hover { background:#174DA4; border-color:#174DA4; color:#fff; }
.rl-btn--sm { padding:5px 10px; font-size:11px; }
.rl-btn:disabled { opacity:.45; cursor:not-allowed; }

/* ── Filters ──────────────────────────────────────────────── */
.rl-filters { display:none; padding:12px 14px; border-bottom:1px solid #e8edf3; background:#f8fafc; }
.rl-filters.show { display:block; }
.rl-filter-grid { display:flex; flex-wrap:wrap; gap:10px; align-items:flex-end; }
.rl-fg { display:flex; flex-direction:column; gap:4px; min-width:130px; }
.rl-fg--wide { min-width:240px; flex:1; }
.rl-fg label { font-size:10px; text-transform:uppercase; letter-spacing:.35px; color:#6b7280; font-weight:700; }
.rl-input, .rl-select { border:1px solid #cfd8e3; background:#fff; color:#1a1a2e; font-size:11px; padding:7px 8px; height:32px; }
.rl-input:focus, .rl-select:focus { outline:none; border-color:#174DA4; }

/* ── Meta bar ─────────────────────────────────────────────── */
.rl-meta { display:flex; justify-content:space-between; align-items:center; gap:8px; padding:8px 14px; border-bottom:1px solid #eef1f5; font-size:11px; color:#4b5563; background:#fff; }
.rl-meta strong { color:#05275C; }

/* ── Table ────────────────────────────────────────────────── */
.rl-table-wrap { overflow-x:auto; }
.rl-table { width:100%; border-collapse:collapse; }
.rl-table th { background:#f8fafc; border-bottom:2px solid #e0e5ed; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; padding:9px 10px; text-align:left; white-space:nowrap; }
.rl-table td { border-bottom:1px solid #eef2f6; font-size:12px; color:#1f2937; padding:9px 10px; vertical-align:middle; }
.rl-table tbody tr:hover td { background:#f9fbff; }
.rl-table tbody tr:nth-child(even) td { background:#fafbfc; }
.rl-table tbody tr:nth-child(even):hover td { background:#f0f5ff; }

.rl-code { font-family:Consolas,"Courier New",monospace; font-size:11px; color:#174DA4; font-weight:700; white-space:nowrap; }
.rl-link { color:#174DA4; text-decoration:none; font-weight:700; cursor:pointer; }
.rl-link:hover { text-decoration:underline; }
.rl-muted { color:#6b7280; font-size:11px; }
.rl-center { text-align:center; }

/* badges */
.rl-pill { display:inline-block; padding:3px 8px; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.35px; }
.rl-pill--regular { background:#e8f0fc; color:#174DA4; }
.rl-pill--retake  { background:#fff4e5; color:#b45309; }
.rl-pill--pending { background:#fde8e8; color:#b42318; }

/* sort headers */
.rl-th-link { color:#6b7280; text-decoration:none; display:inline-flex; align-items:center; gap:3px; }
.rl-th-link:hover { color:#174DA4; }
.rl-th-icon { font-size:10px; color:#174DA4; }

/* action buttons in cells */
.rl-actions { display:flex; gap:5px; align-items:center; justify-content:center; }
.rl-action-btn { display:inline-flex; align-items:center; justify-content:center; width:28px; height:28px; border:1px solid #cdd3de; background:#fff; color:#374151; cursor:pointer; font-size:12px; }
.rl-action-btn svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.rl-action-btn:hover:not(:disabled) { border-color:#174DA4; color:#174DA4; background:#eef3ff; }
.rl-action-btn:disabled { opacity:.4; cursor:not-allowed; }
.rl-action-btn.danger:hover:not(:disabled) { border-color:#b42318; color:#b42318; background:#fde8e8; }

/* empty state */
.rl-empty { padding:28px; text-align:center; font-size:12px; color:#6b7280; }

/* ── Pager ────────────────────────────────────────────────── */
.rl-pager { display:flex; justify-content:space-between; align-items:center; gap:8px; padding:10px 14px; border-top:1px solid #e0e5ed; background:#f8fafc; flex-wrap:wrap; font-size:11px; color:#4b5563; }
.rl-pager__links { display:flex; gap:4px; flex-wrap:wrap; }
.rl-pager__links a, .rl-pager__links span { border:1px solid #d4dbe8; background:#fff; color:#334155; font-size:11px; text-decoration:none; padding:4px 9px; }
.rl-pager__links .active { background:#05275C; border-color:#05275C; color:#fff; }

/* ── Modal (shared) ───────────────────────────────────────── */
.rl-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:9000; }
.rl-overlay.show { display:block; }
.rl-modal { display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; border:1px solid #e0e5ed; width:90%; max-width:680px; box-shadow:0 6px 24px rgba(0,0,0,.14); z-index:9001; max-height:88vh; overflow-y:auto; }
.rl-modal.show { display:block; }
.rl-modal--sm { max-width:540px; }
.rl-modal__head { display:flex; justify-content:space-between; align-items:center; padding:14px 16px; border-bottom:1px solid #e0e5ed; background:#f8fafc; }
.rl-modal__title { font-size:13px; font-weight:800; color:#05275C; margin:0; }
.rl-modal__close { background:none; border:none; font-size:20px; color:#6b7280; cursor:pointer; padding:0 4px; line-height:1; }
.rl-modal__close:hover { color:#1f2937; }
.rl-modal__body { padding:18px 16px; }
.rl-modal__foot { display:flex; justify-content:flex-end; gap:8px; padding:12px 16px; border-top:1px solid #e0e5ed; background:#f8fafc; }

/* detail sections in modal */
.rl-modal__section { margin-bottom:16px; }
.rl-modal__section:last-child { margin-bottom:0; }
.rl-modal__section-title { font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.35px; color:#6b7280; border-bottom:1px solid #eef1f5; padding-bottom:6px; margin-bottom:10px; }
.rl-modal__grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.rl-modal__row { display:flex; flex-direction:column; gap:3px; }
.rl-modal__label { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.3px; color:#6b7280; }
.rl-modal__value { font-size:12px; color:#1f2937; font-weight:500; word-break:break-word; }

/* alerts inside modals */
.rl-alert { padding:10px 12px; font-size:11px; border-radius:2px; margin-bottom:12px; display:none; }
.rl-alert.show { display:block; }
.rl-alert--error { background:#fde8e8; color:#b42318; }
.rl-alert--success { background:#e8f5e9; color:#2e7d32; }
.rl-alert--loading { background:#eef3ff; color:#174DA4; }

/* form groups inside modals */
.rl-fg-modal { margin-bottom:14px; }
.rl-fg-modal:last-child { margin-bottom:0; }
.rl-fg-modal label { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.35px; color:#6b7280; display:block; margin-bottom:5px; }
.rl-form-ctrl { width:100%; border:1px solid #cfd8e3; background:#fff; color:#1a1a2e; font-size:11px; padding:8px; font-family:inherit; }
.rl-form-ctrl:focus { outline:none; border-color:#174DA4; box-shadow:0 0 0 2px rgba(23,77,164,.1); }
.rl-form-ctrl:disabled { background:#f8f9fb; color:#9ca3af; cursor:not-allowed; }
.rl-form-err { font-size:9px; color:#b42318; margin-top:3px; display:none; }
.rl-form-err.show { display:block; }
.rl-form-help { font-size:9px; color:#6b7280; margin-top:3px; }
.rl-radio-row { display:flex; gap:12px; flex-wrap:wrap; }
.rl-radio-row label { font-size:11px; color:#1f2937; display:flex; align-items:center; gap:5px; cursor:pointer; text-transform:none; letter-spacing:0; font-weight:500; }
.rl-row-2 { display:grid; grid-template-columns:1fr 1fr; gap:10px; }

/* spinner */
.rl-spinner { display:inline-block; width:14px; height:14px; border:2px solid #cdd3de; border-top-color:#174DA4; border-radius:50%; animation:rl-spin .8s linear infinite; vertical-align:middle; }
@keyframes rl-spin { to { transform:rotate(360deg); } }

@media (max-width:900px) {
    .rl-stats { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .rl-modal__grid { grid-template-columns:1fr; }
    .rl-row-2 { grid-template-columns:1fr; }
    .rl-modal { width:96%; max-width:96%; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Hero -->
<div class="rl-hero">
    <div class="rl-hero__left">
        <div class="rl-hero__title">Course Registration Ledger</div>
        <p class="rl-hero__sub">Full audit view of all course registration records. Filter, sort, create, edit, and control the ledger.</p>
    </div>
    <div class="rl-hero__actions">
        <button type="button" class="rl-btn rl-btn--primary rl-btn--sm" onclick="openCreateFormModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            New Registration
        </button>
        <button type="button" id="btnToggleFilters" class="rl-btn rl-btn--sm" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
            Filters
        </button>
    </div>
</div>

<!-- Stat tiles -->
<div class="rl-stats">
    <div class="rl-stat"><div class="rl-stat__label">Total Records</div><div class="rl-stat__value"><asp:Literal ID="litTotal" runat="server" Text="0" /></div></div>
    <div class="rl-stat"><div class="rl-stat__label">With Marks</div><div class="rl-stat__value"><asp:Literal ID="litWithMarks" runat="server" Text="0" /></div></div>
    <div class="rl-stat"><div class="rl-stat__label">Retakes</div><div class="rl-stat__value"><asp:Literal ID="litRetakeCount" runat="server" Text="0" /></div></div>
    <div class="rl-stat"><div class="rl-stat__label">Modified Records</div><div class="rl-stat__value"><asp:Literal ID="litChangedCount" runat="server" Text="0" /></div></div>
</div>

<!-- Filter panel -->
<div class="rl-card">
    <div id="rlFilters" class="rl-filters">
        <div class="rl-filter-grid">
            <div class="rl-fg">
                <label>Academic Year</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="rl-select"></asp:DropDownList>
            </div>
            <div class="rl-fg">
                <label>Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="" Text="All"></asp:ListItem>
                    <asp:ListItem Value="1" Text="1"></asp:ListItem>
                    <asp:ListItem Value="2" Text="2"></asp:ListItem>
                    <asp:ListItem Value="3" Text="3"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg">
                <label>Programme</label>
                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="rl-select"></asp:DropDownList>
            </div>
            <div class="rl-fg">
                <label>Course</label>
                <asp:DropDownList ID="ddlCourse" runat="server" CssClass="rl-select"></asp:DropDownList>
            </div>
            <div class="rl-fg">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="" Text="All"></asp:ListItem>
                    <asp:ListItem Value="REGULAR" Text="Regular"></asp:ListItem>
                    <asp:ListItem Value="NORMAL" Text="Normal"></asp:ListItem>
                    <asp:ListItem Value="RETAKE" Text="Retake"></asp:ListItem>
                    <asp:ListItem Value="PENDING" Text="Pending"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg">
                <label>Changed</label>
                <asp:DropDownList ID="ddlChanged" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="" Text="All"></asp:ListItem>
                    <asp:ListItem Value="yes" Text="Changed"></asp:ListItem>
                    <asp:ListItem Value="no" Text="Not Changed"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg rl-fg--wide">
                <label>Student (Reg No or Name)</label>
                <asp:TextBox ID="txtStudent" runat="server" CssClass="rl-input" placeholder="e.g. REG00123 or John"></asp:TextBox>
            </div>
            <div class="rl-fg">
                <label>Rows / Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="25" Text="25"></asp:ListItem>
                    <asp:ListItem Value="50" Text="50" Selected="True"></asp:ListItem>
                    <asp:ListItem Value="100" Text="100"></asp:ListItem>
                    <asp:ListItem Value="200" Text="200"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg" style="justify-content:flex-end;">
                <label>&nbsp;</label>
                <div style="display:flex;gap:6px;">
                    <button type="button" class="rl-btn rl-btn--primary rl-btn--sm" onclick="applyFilters()">Apply</button>
                    <button type="button" class="rl-btn rl-btn--sm" onclick="resetFilters()">Reset</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Meta bar -->
    <div class="rl-meta">
        <span>Showing <strong><asp:Literal ID="litPageInfo" runat="server" Text="Page 1 of 1" /></strong> &mdash; <strong><asp:Literal ID="litPageRangeInfo" runat="server" Text="" /></strong> records</span>
        <span>Total: <strong><asp:Literal ID="litTotalDisplay" runat="server" Text="0" /></strong></span>
    </div>

    <!-- Table -->
    <div class="rl-card__body rl-table-wrap">
        <table class="rl-table">
            <thead>
                <tr>
                    <th class="rl-center" style="width:40px;"><%= BuildSortHeader("latest","#") %></th>
                    <th style="width:110px;"><%= BuildSortHeader("regno","Reg No") %></th>
                    <th><%= BuildSortHeader("student","Student") %></th>
                    <th style="width:100px;"><%= BuildSortHeader("course","Course") %></th>
                    <th><%= BuildSortHeader("course_name","Course Name") %></th>
                    <th style="width:96px;"><%= BuildSortHeader("acad_year","Year") %></th>
                    <th class="rl-center" style="width:50px;"><%= BuildSortHeader("semester","Sem") %></th>
                    <th style="width:90px;"><%= BuildSortHeader("status","Status") %></th>
                    <th class="rl-center" style="width:60px;"><%= BuildSortHeader("marks","Marks") %></th>
                    <th class="rl-center" style="width:55px;"><%= BuildSortHeader("grade","Grade") %></th>
                    <th class="rl-center" style="width:65px;">Changed</th>
                    <th style="width:120px;"><%= BuildSortHeader("change_date","Changed On") %></th>
                    <th class="rl-center" style="width:80px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptRows" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="rl-center rl-muted"><%# Eval("row_no") %></td>
                            <td class="rl-code">
                                <a class="rl-link" href="javascript:void(0);"
                                   data-regno="<%# HttpUtility.HtmlAttributeEncode(Eval("regno").ToString()) %>"
                                   data-acad_year="<%# HttpUtility.HtmlAttributeEncode(Eval("acad_year").ToString()) %>"
                                   data-semester="<%# HttpUtility.HtmlAttributeEncode(Eval("semester").ToString()) %>"
                                   data-course_id="<%# HttpUtility.HtmlAttributeEncode(Eval("courseID").ToString()) %>"
                                   onclick="openDetailModalFromEl(this)"><%# Eval("regno") %></a>
                            </td>
                            <td><%# Eval("student_name") %></td>
                            <td class="rl-code"><%# Eval("courseID") %></td>
                            <td><%# Eval("course_name") %></td>
                            <td><%# Eval("acad_year") %></td>
                            <td class="rl-center"><%# Eval("semester") %></td>
                            <td><%# GetStatusBadge(Eval("course_status")) %></td>
                            <td class="rl-center"><%# Eval("score") %></td>
                            <td class="rl-center"><%# Eval("grade") %></td>
                            <td class="rl-center rl-muted"><%# (Eval("edit_audit_trail") != null && Eval("edit_audit_trail").ToString() != "" && Eval("edit_audit_trail").ToString() != "-") ? "<span style='color:#b45309;font-weight:800;'>Yes</span>" : "No" %></td>
                            <td class="rl-muted" style="font-size:11px;"><%# Eval("change_date") %></td>
                            <td class="rl-center">
                                <div class="rl-actions">
                                    <button type="button" class="rl-action-btn" title="View details"
                                        data-regno="<%# HttpUtility.HtmlAttributeEncode(Eval("regno").ToString()) %>"
                                        data-acad_year="<%# HttpUtility.HtmlAttributeEncode(Eval("acad_year").ToString()) %>"
                                        data-semester="<%# HttpUtility.HtmlAttributeEncode(Eval("semester").ToString()) %>"
                                        data-course_id="<%# HttpUtility.HtmlAttributeEncode(Eval("courseID").ToString()) %>"
                                        onclick="openDetailModalFromEl(this)" aria-label="View">
                                        <svg viewBox="0 0 24 24"><path d="M1.5 12s3.8-7 10.5-7 10.5 7 10.5 7-3.8 7-10.5 7S1.5 12 1.5 12z"/><circle cx="12" cy="12" r="3.25"/></svg>
                                    </button>
                                    <button type="button" class="rl-action-btn" title="Edit"
                                        data-id="<%# Eval("ID") %>"
                                        data-regno="<%# HttpUtility.HtmlAttributeEncode(Eval("regno").ToString()) %>"
                                        data-courseid="<%# HttpUtility.HtmlAttributeEncode(Eval("courseID").ToString()) %>"
                                        data-acad-year="<%# HttpUtility.HtmlAttributeEncode(Eval("acad_year").ToString()) %>"
                                        data-semester="<%# HttpUtility.HtmlAttributeEncode(Eval("semester").ToString()) %>"
                                        data-status="<%# HttpUtility.HtmlAttributeEncode(Eval("course_status").ToString()) %>"
                                        onclick="openEditFormModal(this)" aria-label="Edit">
                                        <svg viewBox="0 0 24 24"><path d="M3 21l3.75-.75L19 8l-3-3L3.75 17.25 3 21z"/><path d="M14 5l3 3"/></svg>
                                    </button>
                                    <button type="button" class="rl-action-btn danger" title="Delete"
                                        data-id="<%# Eval("ID") %>"
                                        data-regno="<%# HttpUtility.HtmlAttributeEncode(Eval("regno").ToString()) %>"
                                        data-score="<%# HttpUtility.HtmlAttributeEncode(Eval("score").ToString()) %>"
                                        data-grade="<%# HttpUtility.HtmlAttributeEncode(Eval("grade").ToString()) %>"
                                        onclick="confirmDeleteReg(this)"
                                        <%# (Eval("score").ToString() != "-" || Eval("grade").ToString() != "-") ? "disabled" : "" %>  aria-label="Delete">
                                        <svg viewBox="0 0 24 24"><path d="M4 7h16"/><path d="M9 7V4h6v3"/><path d="M7 7l1 13h8l1-13"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                    <tr><td colspan="13" class="rl-empty">No records match the current filters.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>

    <div class="rl-pager">
        <span class="rl-muted">GET pagination &mdash; filters are preserved</span>
        <div class="rl-pager__links"><asp:Literal ID="litPager" runat="server" /></div>
    </div>
</div>

<!-- ───────────── DETAIL MODAL ───────────── -->
<div class="rl-overlay" id="rlDetailOverlay"></div>
<div class="rl-modal" id="rlDetailModal">
    <div class="rl-modal__head">
        <h2 class="rl-modal__title">Course Registration Details</h2>
        <button type="button" class="rl-modal__close" onclick="closeDetailModal()">&times;</button>
    </div>
    <div class="rl-modal__body">
        <div class="rl-alert rl-alert--loading" id="rlDetailLoading">&#9203; Loading details&hellip;</div>
        <div class="rl-alert rl-alert--error"   id="rlDetailError"></div>
        <div id="rlDetailContent"></div>
    </div>
</div>

<!-- ───────────── NEW REGISTRATION MODAL ───────────── -->
<div class="rl-overlay" id="rlCreateOverlay"></div>
<div class="rl-modal rl-modal--sm" id="rlCreateModal">
    <div class="rl-modal__head">
        <h2 class="rl-modal__title">Create New Course Registration</h2>
        <button type="button" class="rl-modal__close" onclick="closeCreateModal()">&times;</button>
    </div>
    <div class="rl-modal__body">
        <div class="rl-alert rl-alert--success" id="rlCreateSuccess">&#10003; Record created successfully!</div>
        <div class="rl-alert rl-alert--error"   id="rlCreateError"></div>

        <div class="rl-fg-modal">
            <label>Student Registration Number <span style="color:#b42318;">*</span></label>
            <div style="display:flex;gap:6px;">
                <input type="text" id="frmRegNo" class="rl-form-ctrl" placeholder="e.g. REG001234" maxlength="20" style="flex:1;" />
                <button type="button" class="rl-btn rl-btn--sm" onclick="verifyStudent()">Verify</button>
            </div>
            <div class="rl-form-err" id="errRegNo"></div>
            <div class="rl-form-help" id="infoStudentName"></div>
        </div>

        <div class="rl-fg-modal">
            <label>Course <span style="color:#b42318;">*</span></label>
            <input type="text" id="frmCourseSearch" class="rl-form-ctrl" placeholder="Search by code or name&hellip;" oninput="filterFormCourses()" onkeydown="handleCourseKey(event)" style="margin-bottom:5px;" />
            <select id="frmCourse" class="rl-form-ctrl" onchange="syncCourseFromSelect()">
                <option value="">-- Select a Course --</option>
            </select>
            <div class="rl-form-err" id="errCourse"></div>
        </div>

        <div class="rl-fg-modal">
            <label>Semester Registration / Year of Study <span style="color:#b42318;">*</span></label>
            <select id="frmStudentRegistration" class="rl-form-ctrl" disabled>
                <option value="">-- Verify student first --</option>
            </select>
            <div class="rl-form-help">Select the exact semester registration record to attach this course to.</div>
            <div class="rl-form-err" id="errStudentRegistration"></div>
        </div>
    </div>
    <div class="rl-modal__foot">
        <button type="button" class="rl-btn rl-btn--sm" onclick="closeCreateModal()">Cancel</button>
        <button type="button" id="btnCreateSubmit" class="rl-btn rl-btn--primary rl-btn--sm" onclick="submitCreate()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            Create
        </button>
    </div>
</div>

<!-- ───────────── EDIT REGISTRATION MODAL ───────────── -->
<div class="rl-overlay" id="rlEditOverlay"></div>
<div class="rl-modal rl-modal--sm" id="rlEditModal">
    <div class="rl-modal__head">
        <h2 class="rl-modal__title">Edit Course Registration</h2>
        <button type="button" class="rl-modal__close" onclick="closeEditModal()">&times;</button>
    </div>
    <div class="rl-modal__body">
        <div class="rl-alert rl-alert--error" id="rlEditError"></div>
        <div class="rl-fg-modal">
            <label>Student Reg No</label>
            <input type="text" id="editRegNo" class="rl-form-ctrl" disabled />
        </div>
        <div class="rl-fg-modal">
            <label>Course <span style="color:#b42318;">*</span></label>
            <input type="text" id="editCourseSearch" class="rl-form-ctrl" placeholder="Search course&hellip;" oninput="filterEditCourses()" onkeydown="handleEditCourseKey(event)" style="margin-bottom:5px;" />
            <select id="editCourseID" class="rl-form-ctrl" onchange="syncEditCourseFromSelect()">
                <option value="">-- Select --</option>
            </select>
            <div class="rl-form-err" id="errEditCourse"></div>
        </div>
        <div class="rl-row-2">
            <div class="rl-fg-modal">
                <label>Academic Year <span style="color:#b42318;">*</span></label>
                <select id="editAcadYear" class="rl-form-ctrl">
                    <option value="">-- Select --</option>
                </select>
                <div class="rl-form-err" id="errEditAcadYear"></div>
            </div>
            <div class="rl-fg-modal">
                <label>Semester <span style="color:#b42318;">*</span></label>
                <select id="editSemester" class="rl-form-ctrl">
                    <option value="">-- Select --</option>
                    <option value="1">Semester 1</option>
                    <option value="2">Semester 2</option>
                    <option value="3">Semester 3</option>
                </select>
                <div class="rl-form-err" id="errEditSemester"></div>
            </div>
        </div>
        <div class="rl-fg-modal">
            <label>Course Status <span style="color:#b42318;">*</span></label>
            <select id="editStatus" class="rl-form-ctrl">
                <option value="">-- Select --</option>
                <option value="REGULAR">Regular</option>
                <option value="RETAKE">Retake</option>
                <option value="PENDING">Pending</option>
                <option value="NORMAL">Normal</option>
            </select>
            <div class="rl-form-err" id="errEditStatus"></div>
        </div>
        <div class="rl-fg-modal">
            <label>Reason for Edit <span style="color:#b42318;">*</span></label>
            <textarea id="editReason" class="rl-form-ctrl" rows="3" placeholder="Explain the reason for this change&hellip;" style="height:auto;resize:vertical;"></textarea>
            <div class="rl-form-err" id="errEditReason"></div>
        </div>
    </div>
    <div class="rl-modal__foot">
        <button type="button" class="rl-btn rl-btn--sm" onclick="closeEditModal()">Cancel</button>
        <button type="button" id="btnEditSubmit" class="rl-btn rl-btn--primary rl-btn--sm" onclick="submitEdit()">Save Changes</button>
    </div>
</div>

<!-- ───────────── JAVASCRIPT ───────────── -->
<script type="text/javascript">
function byId(id) { return document.getElementById(id); }

/* ── response parser ─────────────────────────────── */
function parseResp(text) {
    var outer = JSON.parse(text || '{}');
    var payload = (outer && typeof outer.d !== 'undefined') ? outer.d : outer;
    if (typeof payload === 'string') payload = JSON.parse(payload);
    if (!payload || typeof payload !== 'object') return { success:false, message:'Invalid response', data:null };
    return payload;
}

/* ── alert helpers ───────────────────────────────── */
function showAlert(id, msg) { var el=byId(id); if(el){el.innerHTML=msg; el.classList.add('show');} }
function hideAlert(id)       { var el=byId(id); if(el) el.classList.remove('show'); }

/* ── filter toggling ─────────────────────────────── */
function toggleFilters() {
    var box=byId('rlFilters'), btn=byId('btnToggleFilters');
    if(!box||!btn) return;
    if(box.classList.contains('show')){ box.classList.remove('show'); btn.innerHTML='<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg> Filters'; }
    else { box.classList.add('show'); btn.innerHTML='<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg> Hide Filters'; }
}
function setOrDel(qs,key,val){ if(val&&val.length>0) qs.set(key,val); else qs.delete(key); }
function applyFilters() {
    var qs=new URLSearchParams(window.location.search);
    qs.set('page','1');
    setOrDel(qs,'acad',  byId('<%= ddlAcadYear.ClientID %>').value);
    setOrDel(qs,'sem',   byId('<%= ddlSemester.ClientID %>').value);
    setOrDel(qs,'prog',  byId('<%= ddlProgramme.ClientID %>').value);
    setOrDel(qs,'course',byId('<%= ddlCourse.ClientID %>').value);
    setOrDel(qs,'status',byId('<%= ddlStatus.ClientID %>').value);
    setOrDel(qs,'changed',byId('<%= ddlChanged.ClientID %>').value);
    setOrDel(qs,'student',byId('<%= txtStudent.ClientID %>').value.trim());
    setOrDel(qs,'size',  byId('<%= ddlPageSize.ClientID %>').value);
    window.location.href=window.location.pathname+'?'+qs.toString();
}
function resetFilters(){ window.location.href=window.location.pathname; }

function wireAutoFilter(){
    var ids=['<%= ddlAcadYear.ClientID %>','<%= ddlSemester.ClientID %>','<%= ddlProgramme.ClientID %>','<%= ddlCourse.ClientID %>','<%= ddlStatus.ClientID %>','<%= ddlChanged.ClientID %>','<%= ddlPageSize.ClientID %>'];
    for(var i=0;i<ids.length;i++){ var el=byId(ids[i]); if(el) el.addEventListener('change',applyFilters); }
    var st=byId('<%= txtStudent.ClientID %>');
    if(st) st.addEventListener('keydown',function(e){ if(e.key==='Enter'){e.preventDefault();applyFilters();} });
    if(window.location.search&&window.location.search.length>1){
        var box=byId('rlFilters'),btn=byId('btnToggleFilters');
        if(box&&btn){ box.classList.add('show'); btn.innerHTML='<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'12\' height=\'12\' viewBox=\'0 0 24 24\' fill=\'none\' stroke=\'currentColor\' stroke-width=\'2\'><polygon points=\'22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3\'/></svg> Hide Filters'; }
    }
}
document.addEventListener('DOMContentLoaded', wireAutoFilter);

/* ── DETAIL MODAL ────────────────────────────────── */
function openDetailModalFromEl(el){
    openDetailModal(el.getAttribute('data-regno'),el.getAttribute('data-acad_year'),el.getAttribute('data-semester'),el.getAttribute('data-course_id'));
}
function openDetailModal(regno,acadYear,semester,courseID){
    byId('rlDetailOverlay').classList.add('show');
    byId('rlDetailModal').classList.add('show');
    showAlert('rlDetailLoading','&#9203; Loading details&hellip;');
    hideAlert('rlDetailError');
    byId('rlDetailContent').innerHTML='';
    ajax('CourseRegistrationLedgerController.aspx/GetRecordDetailJson',{regno:regno,acad_year:acadYear,semester:semester,course_id:courseID},function(r){
        hideAlert('rlDetailLoading');
        if(r.success){ byId('rlDetailContent').innerHTML=buildDetailHtml(r.data); }
        else { showAlert('rlDetailError',r.message||'Failed to load record.'); }
    },function(err){ hideAlert('rlDetailLoading'); showAlert('rlDetailError',err); });
}
function closeDetailModal(){ byId('rlDetailOverlay').classList.remove('show'); byId('rlDetailModal').classList.remove('show'); }

function buildDetailHtml(d){
    if(!d) return '';
    function kv(label,val){ return '<div class="rl-modal__row"><span class="rl-modal__label">'+label+'</span><span class="rl-modal__value">'+(val||'-')+'</span></div>'; }
    var h='';
    h+='<div class="rl-modal__section"><div class="rl-modal__section-title">Student</div><div class="rl-modal__grid">';
    h+=kv('Reg No',d.regno); h+=kv('Name',d.student_name);
    h+='</div></div>';
    h+='<div class="rl-modal__section"><div class="rl-modal__section-title">Academic Context</div><div class="rl-modal__grid">';
    h+=kv('Programme',d.programme_name); h+=kv('Academic Year',d.acad_year);
    h+=kv('Semester',d.semester); h+=kv('Status',getBadgeHtml(d.course_status));
    h+=kv('Changed On',d.change_date);
    h+='</div></div>';
    h+='<div class="rl-modal__section"><div class="rl-modal__section-title">Course</div><div class="rl-modal__grid">';
    h+=kv('Code',d.courseID); h+=kv('Name',d.course_name);
    h+='</div></div>';
    h+='<div class="rl-modal__section"><div class="rl-modal__section-title">Assessment</div><div class="rl-modal__grid">';
    h+=kv('Marks',d.score); h+=kv('Grade',d.grade);
    h+='</div></div>';
    if(d.edit_audit_trail&&d.edit_audit_trail!=='-'){
        h+='<div class="rl-modal__section"><div class="rl-modal__section-title">Change Log</div>';
        if(d.edit_reason&&d.edit_reason!=='-') h+=kv('Last Reason',d.edit_reason);
        h+='<div class="rl-modal__row"><span class="rl-modal__label">Audit Trail</span><span class="rl-modal__value" style="white-space:pre-wrap;font-size:11px;color:#4b5563;">'+d.edit_audit_trail+'</span></div>';
        h+='</div>';
    }
    if(d.result_comment&&d.result_comment!=='-'){
        h+='<div class="rl-modal__section"><div class="rl-modal__section-title">Comment</div>';
        h+='<div class="rl-modal__row"><span class="rl-modal__value" style="white-space:pre-wrap;">'+d.result_comment+'</span></div></div>';
    }
    return h;
}
function getBadgeHtml(s){
    if(!s) s='-'; var u=s.toUpperCase();
    if(u==='REGULAR'||u==='NORMAL') return '<span class="rl-pill rl-pill--regular">'+u+'</span>';
    if(u==='RETAKE') return '<span class="rl-pill rl-pill--retake">RETAKE</span>';
    return '<span class="rl-pill rl-pill--pending">'+u+'</span>';
}

/* ── CREATE MODAL ────────────────────────────────── */
function openCreateFormModal(){
    byId('rlCreateOverlay').classList.add('show');
    byId('rlCreateModal').classList.add('show');
    resetCreateForm();
    populateCreateDropdowns();
}
function closeCreateModal(){ byId('rlCreateOverlay').classList.remove('show'); byId('rlCreateModal').classList.remove('show'); }
function resetCreateForm(){
    byId('frmRegNo').value=''; byId('frmRegNo').disabled=false;
    byId('frmCourseSearch').value=''; byId('frmCourse').selectedIndex=0;
    byId('frmStudentRegistration').innerHTML='<option value="">-- Verify student first --</option>';
    byId('frmStudentRegistration').disabled=true;
    hideAlert('rlCreateSuccess'); hideAlert('rlCreateError');
    ['errRegNo','errCourse','errStudentRegistration'].forEach(function(id){ var el=byId(id); if(el){el.innerHTML='';el.classList.remove('show');} });
    byId('infoStudentName').innerHTML='';
}
function populateCreateDropdowns(){
    initFormCourseCache();
    renderFormCourses('');
}
var _frmCourses=null;
function initFormCourseCache(){
    if(_frmCourses) return;
    _frmCourses=[];
    var src=byId('<%= ddlCourse.ClientID %>');
    if(!src) return;
    for(var i=0;i<src.options.length;i++){ var o=src.options[i]; if(o.value) _frmCourses.push({v:o.value,t:o.text}); }
}
function renderFormCourses(q){
    var sel=byId('frmCourse'); if(!sel) return {count:0};
    var prev=sel.value; q=(q||'').toLowerCase(); sel.innerHTML='<option value="">-- Select a Course --</option>';
    var count=0,first='';
    (_frmCourses||[]).forEach(function(c){ if(!q||c.v.toLowerCase().indexOf(q)>=0||c.t.toLowerCase().indexOf(q)>=0){ var o=document.createElement('option');o.value=c.v;o.text=c.t;sel.appendChild(o);if(!first)first=c.v;count++; } });
    if(q&&count===1) sel.value=first;
    else if(!q&&prev) sel.value=prev;
    return {count:count,first:first};
}
function filterFormCourses(){ renderFormCourses(byId('frmCourseSearch').value); }
function syncCourseFromSelect(){ var s=byId('frmCourse'); if(s&&s.value) byId('frmCourseSearch').value=s.options[s.selectedIndex].text; }
function handleCourseKey(e){ if(e.key==='Enter'){e.preventDefault();var r=renderFormCourses(byId('frmCourseSearch').value);if(r.count>0){byId('frmCourse').selectedIndex=1;syncCourseFromSelect();}} }
function renderStudentRegistrations(items){
    var sel=byId('frmStudentRegistration'); if(!sel) return;
    sel.innerHTML='';
    var ph=document.createElement('option');
    ph.value='';
    ph.text=(items&&items.length)?'-- Select registration record --':'-- No registration records found --';
    sel.appendChild(ph);
    (items||[]).forEach(function(r){ var o=document.createElement('option'); o.value=r.id; o.text=r.label; sel.appendChild(o); });
    sel.disabled=!(items&&items.length);
}

function verifyStudent(){
    var rn=byId('frmRegNo').value.trim();
    if(!rn){showFErr('errRegNo','Enter a registration number.');return;}
    byId('infoStudentName').innerHTML='<span style="color:#174DA4;"><span class="rl-spinner"></span> Checking&hellip;</span>';
    ajax('CourseRegistrationLedgerController.aspx/ValidateStudentExists',{regno:rn},function(r){
        if(r.success){
            hideFErr('errRegNo'); hideFErr('errStudentRegistration');
            byId('infoStudentName').innerHTML='<strong>'+r.data.student_name+'</strong> &mdash; '+r.data.programme_name;
            byId('frmRegNo').disabled=true;
            renderStudentRegistrations(r.data.registrations||[]);
            if(!(r.data.registrations||[]).length) showFErr('errStudentRegistration','No semester registration records were found for this student.');
        }
        else { showFErr('errRegNo',r.message||'Student not found.'); byId('infoStudentName').innerHTML=''; byId('frmRegNo').disabled=false; renderStudentRegistrations([]); }
    },function(){ byId('infoStudentName').innerHTML=''; showFErr('errRegNo','Network error.'); });
}
function submitCreate(){
    var rn=byId('frmRegNo').value.trim();
    var cid=byId('frmCourse').value;
    var regId=byId('frmStudentRegistration').value;
    var ok=true;
    if(!rn){showFErr('errRegNo','Required.');ok=false;}
    if(!cid){showFErr('errCourse','Required.');ok=false;}
    if(!regId){showFErr('errStudentRegistration','Required.');ok=false;}
    if(!ok) return;
    setBtn('btnCreateSubmit',true,'Saving&hellip;');
    ajax('CourseRegistrationLedgerController.aspx/CreateCourseRegistration',{regno:rn,courseID:cid,registrationId:regId},function(r){
        setBtn('btnCreateSubmit',false,'Create');
        if(r.success){ showAlert('rlCreateSuccess','&#10003; Record created successfully!'); hideAlert('rlCreateError'); setTimeout(function(){closeCreateModal();location.reload();},1500); }
        else { showAlert('rlCreateError',r.message||'Failed.'); hideAlert('rlCreateSuccess'); }
    },function(err){ setBtn('btnCreateSubmit',false,'Create'); showAlert('rlCreateError',err); });
}

/* ── EDIT MODAL ──────────────────────────────────── */
var _editCourses=null;
function openEditFormModal(el){
    var id=el.getAttribute('data-id');
    window._editId=id;
    byId('editRegNo').value=el.getAttribute('data-regno')||'';
    if(!_editCourses){ _editCourses=(_frmCourses||[]).length>0?_frmCourses:null; initFormCourseCache(); _editCourses=_frmCourses; }
    renderEditCourses('');
    var ay=byId('editAcadYear');
    if(ay&&ay.options.length<=1){
        var src=byId('<%= ddlAcadYear.ClientID %>');
        for(var i=0;i<src.options.length;i++){ var o=src.options[i]; if(o.value){ var n=document.createElement('option');n.value=o.value;n.text=o.text;ay.appendChild(n); } }
    }
    byId('editAcadYear').value=el.getAttribute('data-acad-year')||'';
    byId('editCourseID').value=el.getAttribute('data-courseid')||''; syncEditCourseFromSelect();
    byId('editSemester').value=el.getAttribute('data-semester')||'';
    byId('editStatus').value=el.getAttribute('data-status')||'';
    byId('editReason').value='';
    hideAlert('rlEditError');
    ['errEditCourse','errEditAcadYear','errEditSemester','errEditStatus','errEditReason'].forEach(function(id){ var e=byId(id);if(e){e.innerHTML='';e.classList.remove('show');} });
    byId('rlEditOverlay').classList.add('show');
    byId('rlEditModal').classList.add('show');
}
function closeEditModal(){ byId('rlEditOverlay').classList.remove('show'); byId('rlEditModal').classList.remove('show'); }
function renderEditCourses(q){
    var sel=byId('editCourseID'); if(!sel) return;
    var prev=sel.value; q=(q||'').toLowerCase(); sel.innerHTML='<option value="">-- Select --</option>';
    (_editCourses||[]).forEach(function(c){ if(!q||c.v.toLowerCase().indexOf(q)>=0||c.t.toLowerCase().indexOf(q)>=0){ var o=document.createElement('option');o.value=c.v;o.text=c.t;sel.appendChild(o); } });
    if(prev) sel.value=prev;
}
function filterEditCourses(){ renderEditCourses(byId('editCourseSearch').value); }
function syncEditCourseFromSelect(){ var s=byId('editCourseID'); if(s&&s.value) byId('editCourseSearch').value=s.options[s.selectedIndex].text; }
function handleEditCourseKey(e){ if(e.key==='Enter'){e.preventDefault();renderEditCourses(byId('editCourseSearch').value);} }
function submitEdit(){
    var cid=byId('editCourseID').value;
    var ay=byId('editAcadYear').value;
    var sem=byId('editSemester').value;
    var st=byId('editStatus').value;
    var re=byId('editReason').value.trim();
    var ok=true;
    if(!cid){showFErr('errEditCourse','Required.');ok=false;}
    if(!ay){showFErr('errEditAcadYear','Required.');ok=false;}
    if(!sem){showFErr('errEditSemester','Required.');ok=false;}
    if(!st){showFErr('errEditStatus','Required.');ok=false;}
    if(!re){showFErr('errEditReason','Required.');ok=false;}
    if(!ok) return;
    setBtn('btnEditSubmit',true,'Saving&hellip;');
    ajax('CourseRegistrationLedgerController.aspx/EditCourseRegistration',{id:window._editId,courseID:cid,acad_year:ay,semester:sem,course_status:st,edit_reason:re},function(r){
        setBtn('btnEditSubmit',false,'Save Changes');
        if(r.success){ closeEditModal(); location.reload(); }
        else { showAlert('rlEditError',r.message||'Failed.'); }
    },function(err){ setBtn('btnEditSubmit',false,'Save Changes'); showAlert('rlEditError',err); });
}

/* ── DELETE ──────────────────────────────────────── */
function confirmDeleteReg(el){
    var id=el.getAttribute('data-id'), rn=el.getAttribute('data-regno');
    if(!confirm('Delete course registration for '+rn+'?\n\nThis cannot be undone.')) return;
    ajax('CourseRegistrationLedgerController.aspx/DeleteCourseRegistration',{id:id},function(r){
        if(r.success){ location.reload(); }
        else { alert('Error: '+(r.message||'Failed to delete.')); }
    },function(err){ alert(err); });
}

/* ── AJAX helper ─────────────────────────────────── */
function ajax(url,data,onOk,onErr){
    var xhr=new XMLHttpRequest();
    xhr.open('POST',url,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.setRequestHeader('X-Requested-With','XMLHttpRequest');
    xhr.onload=function(){
        if(xhr.status===200){
            try{ var r=parseResp(xhr.responseText); onOk(r); }
            catch(e){ if(onErr) onErr('Parse error: '+e.message); }
        } else { if(onErr) onErr('HTTP '+xhr.status); }
    };
    xhr.onerror=function(){ if(onErr) onErr('Network error.'); };
    xhr.send(JSON.stringify(data));
}

/* ── helpers ─────────────────────────────────────── */
function setBtn(id,disabled,label){ var b=byId(id); if(b){b.disabled=disabled;b.innerHTML=label;} }
function showFErr(id,msg){ var e=byId(id);if(e){e.innerHTML=msg;e.classList.add('show');} }
function hideFErr(id){ var e=byId(id);if(e){e.innerHTML='';e.classList.remove('show');} }

/* ── ESC / overlay click ─────────────────────────── */
document.addEventListener('DOMContentLoaded',function(){
    [['rlDetailOverlay','closeDetailModal'],['rlCreateOverlay','closeCreateModal'],['rlEditOverlay','closeEditModal']].forEach(function(pair){
        var el=byId(pair[0]); if(el) el.addEventListener('click',function(e){if(e.target===el)window[pair[1]]();});
    });
});
document.addEventListener('keydown',function(e){
    if(e.key!=='Escape') return;
    if(byId('rlEditModal')&&byId('rlEditModal').classList.contains('show')){ closeEditModal(); return; }
    if(byId('rlCreateModal')&&byId('rlCreateModal').classList.contains('show')){ closeCreateModal(); return; }
    if(byId('rlDetailModal')&&byId('rlDetailModal').classList.contains('show')){ closeDetailModal(); }
});
</script>
</asp:Content>
