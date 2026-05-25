<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="AdmissionsController.aspx.cs"
    Inherits="COOPERP_NewScreens_AdmissionsController"
    Title="Admissions Controller - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ADMISSIONS CONTROLLER (prefix: admc-) ========================= */

/* Page header */
.admc-hdr{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #e0e5ed;background:#fff;}
.admc-hdr__left{display:flex;align-items:center;gap:10px;}
.admc-hdr__icon{width:36px;height:36px;background:#05275C;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.admc-hdr__title{font-size:15px;font-weight:700;color:#05275C;line-height:1.2;}
.admc-hdr__sub{font-size:10px;color:#888;margin-top:1px;}
.admc-hdr__actions{display:flex;align-items:center;gap:8px;}

/* Stats */
.admc-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;padding:14px 16px;background:#fafbfc;border-bottom:1px solid #e0e5ed;}
.admc-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;position:relative;overflow:hidden;}
.admc-stat::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--sc,#ccc);}
.admc-stat__label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#888;margin-bottom:3px;}
.admc-stat__value{font-size:22px;font-weight:800;letter-spacing:-.5px;color:var(--sc,#333);}
.admc-stat__sub{font-size:10px;color:#aaa;margin-top:2px;}
.admc-stat--total{--sc:#174DA4;}
.admc-stat--submitted{--sc:#174DA4;}
.admc-stat--pending{--sc:#e65100;}
.admc-stat--admitted{--sc:#16a34a;}
.admc-stat--registered{--sc:#05275C;}
.admc-stat--rejected{--sc:#c62828;}

/* Filter bar */
.admc-filters{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fa;}
.admc-filters__row{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.admc-search-wrap{position:relative;flex:1;min-width:200px;max-width:340px;}
.admc-search-wrap svg{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#999;pointer-events:none;}
.admc-search{width:100%;border:1px solid #ddd;padding:6px 10px 6px 30px;font-size:12px;font-family:inherit;background:#fff;}
.admc-search:focus{border-color:#174DA4;outline:none;}
.admc-select{border:1px solid #ddd;padding:6px 8px;font-size:11px;font-family:inherit;background:#fff;color:#333;min-width:130px;}
.admc-select:focus{border-color:#174DA4;outline:none;}
.admc-filters__count{font-size:11px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:4px 10px;margin-left:auto;}

/* Buttons */
.admc-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;font-family:inherit;transition:all .15s;}
.admc-btn--primary{background:#05275C;color:#fff;}.admc-btn--primary:hover{background:#174DA4;}
.admc-btn--success{background:#16a34a;color:#fff;}.admc-btn--success:hover{background:#138a3e;}
.admc-btn--danger{background:#c62828;color:#fff;}.admc-btn--danger:hover{background:#b71c1c;}
.admc-btn--amber{background:#e65100;color:#fff;}.admc-btn--amber:hover{background:#bf360c;}
.admc-btn--ghost{background:#fff;border:1px solid #cdd3de;color:#555;}.admc-btn--ghost:hover{border-color:#174DA4;color:#174DA4;}
.admc-btn--sm{padding:4px 10px;font-size:10px;}
.admc-btn:disabled{opacity:.5;cursor:not-allowed;}

/* Table */
.admc-table-wrap{overflow-x:auto;}
.admc-table{width:100%;border-collapse:collapse;font-size:11px;}
.admc-table th{background:#f5f7fa;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#666;padding:9px 12px;text-align:left;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.admc-table td{padding:8px 12px;border-bottom:1px solid #f0f2f5;color:#222;vertical-align:middle;}
.admc-table tr:hover td{background:#f5f9ff;}
.admc-name{font-weight:600;color:#05275C;}
.admc-eno{font-family:monospace;font-size:11px;color:#555;font-weight:600;}
.admc-actions-cell{display:flex;gap:4px;flex-wrap:nowrap;}

/* Badges */
.admc-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border:1px solid transparent;white-space:nowrap;}
.admc-badge--pending{background:#fff8e1;color:#e65100;border-color:#ffe082;}
.admc-badge--admitted{background:#e8f5e9;color:#2e7d32;border-color:#c8e6c9;}
.admc-badge--registered{background:#e8f0fc;color:#174DA4;border-color:#bbdefb;}
.admc-badge--rejected{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}
.admc-badge--withdrawn{background:#f5f5f5;color:#757575;border-color:#e0e0e0;}

/* Empty state */
.admc-empty{text-align:center;padding:40px 20px;color:#aaa;font-size:12px;}

/* Online application indicator */
.admc-online-chip{display:inline-block;padding:1px 5px;font-size:9px;font-weight:700;background:#e8f0fc;color:#174DA4;border:1px solid #bbdefb;letter-spacing:.3px;margin-top:2px;vertical-align:middle;}
.admc-row--online td{background:#f5f9ff !important;}
.admc-row--online:hover td{background:#edf4ff !important;}

/* Pagination */
.admc-pager{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;border-top:1px solid #e0e5ed;font-size:11px;color:#666;background:#fafbfc;}
.admc-pager__nav{display:flex;gap:4px;}
.admc-pager__btn{border:1px solid #ddd;background:#fff;padding:4px 10px;font-size:11px;cursor:pointer;color:#333;font-family:inherit;text-decoration:none;display:inline-block;}
.admc-pager__btn:hover{background:#f0f4ff;border-color:#174DA4;}

/* ── Detail / Action modal ─── */
.admc-modal-bg{display:none;position:fixed;inset:0;z-index:9100;background:rgba(0,0,0,.5);align-items:flex-start;justify-content:center;padding-top:40px;overflow-y:auto;}
.admc-modal-bg.open{display:flex;}
.admc-modal{background:#fff;width:760px;max-width:96vw;border-radius:0;box-shadow:0 20px 60px rgba(0,0,0,.25);max-height:85vh;display:flex;flex-direction:column;}
.admc-modal__hdr{display:flex;align-items:center;justify-content:space-between;padding:13px 18px;background:#05275C;color:#fff;flex-shrink:0;}
.admc-modal__hdr h3{margin:0;font-size:14px;font-weight:700;}
.admc-modal__close{background:none;border:none;color:rgba(255,255,255,.8);font-size:22px;cursor:pointer;line-height:1;padding:0 4px;}
.admc-modal__close:hover{color:#fff;}
.admc-modal__body{padding:0;overflow-y:auto;flex:1;}
.admc-modal__tabs{display:flex;border-bottom:2px solid #e0e5ed;background:#f8f9fa;flex-shrink:0;}
.admc-modal__tab{padding:10px 16px;font-size:11px;font-weight:600;cursor:pointer;border:none;background:none;color:#666;border-bottom:2px solid transparent;margin-bottom:-2px;font-family:inherit;}
.admc-modal__tab.active{color:#05275C;border-bottom-color:#05275C;background:#fff;}
.admc-modal__tab:hover{color:#174DA4;}
.admc-tab-panel{display:none;padding:16px 18px;}
.admc-tab-panel.active{display:block;}
.admc-section{margin-bottom:16px;}
.admc-section__title{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#888;border-bottom:1px solid #f0f0f0;padding-bottom:5px;margin-bottom:10px;}
.admc-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:10px 20px;}
.admc-grid-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px 20px;}
.admc-field label{font-size:10px;font-weight:700;text-transform:uppercase;color:#888;letter-spacing:.3px;display:block;margin-bottom:2px;}
.admc-field__val{font-size:12px;font-weight:600;color:#05275C;}
.admc-field__val--light{font-weight:400;color:#444;}
.admc-modal__foot{display:flex;align-items:center;justify-content:space-between;padding:12px 18px;border-top:1px solid #e0e5ed;background:#fafbfc;flex-shrink:0;flex-wrap:wrap;gap:8px;}
.admc-modal__foot-right{display:flex;gap:8px;flex-wrap:wrap;}
.admc-info-row{display:flex;align-items:center;gap:6px;padding:8px 12px;font-size:11px;border:1px solid #e0e0e0;margin-bottom:10px;background:#f8f9fa;}
.admc-info-row svg{color:#174DA4;flex-shrink:0;}
.admc-warn-row{background:#fff8e1;border-color:#ffe082;color:#e65100;}

/* Batch toolbar */
.admc-batch{display:none;align-items:center;gap:8px;padding:8px 14px;background:#fff8e1;border-bottom:1px solid #ffe082;font-size:11px;}
.admc-batch.visible{display:flex;}
.admc-batch__info{font-weight:700;color:#e65100;margin-right:4px;}

/* Toast */
.admc-toast{position:fixed;bottom:24px;right:24px;z-index:9999;padding:11px 18px;font-size:12px;font-weight:600;border:1px solid transparent;display:none;min-width:240px;box-shadow:0 4px 20px rgba(0,0,0,.15);}
.admc-toast.show{display:block;}
.admc-toast--ok{background:#e8f5e9;color:#155724;border-color:#c3e6cb;}
.admc-toast--err{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}

/* Responsive polish */
@media (max-width: 900px){
    .admc-hdr{flex-direction:column;align-items:flex-start;gap:10px;}
    .admc-hdr__actions{flex-wrap:wrap;width:100%;}
    .admc-hdr__actions .admc-btn{flex:1 1 180px;justify-content:center;}
    .admc-filters__row{align-items:stretch;}
    .admc-search-wrap{max-width:none;flex:1 1 100%;}
    .admc-select{min-width:0;flex:1 1 150px;}
    .admc-filters__count{margin-left:0;}
}
@media (max-width: 640px){
    .admc-stats{grid-template-columns:repeat(2,minmax(0,1fr));padding:12px 12px 10px;}
    .admc-stat__value{font-size:18px;}
    .admc-filters{padding:10px 12px;}
    .admc-filters__row{gap:6px;}
    .admc-search{font-size:13px;}
    .admc-select{width:100%;min-width:0;font-size:12px;}
    .admc-btn{width:100%;justify-content:center;}
    .admc-table{font-size:10px;}
    .admc-table th,.admc-table td{padding:7px 8px;}
    .admc-actions-cell{flex-wrap:wrap;}
    .admc-actions-cell .admc-btn{width:auto;}
    .admc-modal-bg{padding-top:10px;}
    .admc-modal{width:100%;max-width:100vw;max-height:92vh;}
    .admc-grid-2,.admc-grid-3{grid-template-columns:1fr;}
}
@media (max-width: 420px){
    .admc-stats{grid-template-columns:1fr;}
    .admc-hdr__title{font-size:14px;}
    .admc-hdr__sub{font-size:9px;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="admc-hdr">
    <div class="admc-hdr__left">
        <div class="admc-hdr__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
        </div>
        <div>
            <div class="admc-hdr__title">Admissions Controller</div>
            <div class="admc-hdr__sub">Manage applicants — from pending admission to fully registered student</div>
        </div>
    </div>
    <div class="admc-hdr__actions">
        <a href="NewStudentRegistration.aspx" class="admc-btn admc-btn--success">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Register New Student
        </a>
        <button type="button" class="admc-btn admc-btn--ghost" onclick="window.location.reload();" title="Refresh">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
            Refresh
        </button>
    </div>
</div>

<!-- Stats (server-rendered) -->
<asp:Literal ID="litStats" runat="server"/>

<!-- Filter bar -->
<div class="admc-filters">
    <div class="admc-filters__row">
        <div class="admc-search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="admc-q" class="admc-search" placeholder="Search name, entry no, reg no…"
                value="<%= HE(FilterQ) %>"
                onkeydown="if(event.key==='Enter'){event.preventDefault();applyFilters();}">
        </div>
        <select id="admc-status" class="admc-select">
            <option value="">All Statuses</option>
            <option value="DRAFT"<%= Sel(FilterStatus,"DRAFT") %>>Draft</option>
            <option value="SUBMITTED"<%= Sel(FilterStatus,"SUBMITTED") %>>Submitted</option>
            <option value="UNDER_REVIEW"<%= Sel(FilterStatus,"UNDER_REVIEW") %>>Under Review</option>
            <option value="PENDING"<%= Sel(FilterStatus,"PENDING") %>>Pending</option>
            <option value="ADMITTED"<%= Sel(FilterStatus,"ADMITTED") %>>Admitted</option>
            <option value="REGISTERED"<%= Sel(FilterStatus,"REGISTERED") %>>Registered</option>
            <option value="REJECTED"<%= Sel(FilterStatus,"REJECTED") %>>Rejected</option>
            <option value="WITHDRAWN"<%= Sel(FilterStatus,"WITHDRAWN") %>>Withdrawn</option>
        </select>
        <select id="admc-prog" class="admc-select" style="max-width:200px;">
            <option value="">All Programmes</option>
            <asp:Literal ID="litProgOptions" runat="server"/>
        </select>
        <select id="admc-year" class="admc-select">
            <option value="">All Years</option>
            <asp:Literal ID="litYearOptions" runat="server"/>
        </select>
        <select id="admc-session" class="admc-select">
            <option value="">All Sessions</option>
            <option value="DAY"<%= Sel(FilterSession,"DAY") %>>Day</option>
            <option value="EVENING"<%= Sel(FilterSession,"EVENING") %>>Evening</option>
            <option value="WEEKEND"<%= Sel(FilterSession,"WEEKEND") %>>Weekend</option>
            <option value="DISTANCE"<%= Sel(FilterSession,"DISTANCE") %>>Distance</option>
        </select>
        <select id="admc-source" class="admc-select" title="Filter by application source">
            <option value="">All Sources</option>
            <option value="ONLINE"<%= Sel(FilterSource,"ONLINE") %>>&#127760; Online Portal</option>
            <option value="WALKIN"<%= Sel(FilterSource,"WALKIN") %>>Walk-in / Manual</option>
        </select>
        <select id="admc-min-days" class="admc-select" title="Show applications pending for at least N days">
            <option value="">All Ages</option>
            <option value="30"<%= Sel(FilterMinDays.ToString(),"30") %>>Pending 30+ days</option>
            <option value="60"<%= Sel(FilterMinDays.ToString(),"60") %>>Pending 60+ days</option>
            <option value="90"<%= Sel(FilterMinDays.ToString(),"90") %>>Pending 90+ days</option>
        </select>
        <button type="button" class="admc-btn admc-btn--primary" onclick="applyFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="4" y1="6" x2="20" y2="6"/><line x1="8" y1="12" x2="16" y2="12"/><line x1="11" y1="18" x2="13" y2="18"/></svg>
            Apply
        </button>
        <button type="button" class="admc-btn admc-btn--ghost" onclick="clearFilters()" title="Clear all filters">Clear</button>
        <select id="admc-pagesize" class="admc-select" style="min-width:90px;" onchange="applyFilters()" title="Records per page">
            <option value="25"<%= Sel(FilterSize.ToString(),"25") %>>25 / page</option>
            <option value="50"<%= Sel(FilterSize.ToString(),"50") %>>50 / page</option>
            <option value="100"<%= Sel(FilterSize.ToString(),"100") %>>100 / page</option>
            <option value="200"<%= Sel(FilterSize.ToString(),"200") %>>200 / page</option>
            <option value="500"<%= Sel(FilterSize.ToString(),"500") %>>500 / page</option>
        </select>
        <span class="admc-filters__count"><asp:Literal ID="litCount" runat="server" Text="—"/></span>
    </div>
</div>

<!-- Batch toolbar -->
<div class="admc-batch" id="admc-batch">
    <span class="admc-batch__info" id="admc-batch-info">0 selected</span>
    <button type="button" class="admc-btn admc-btn--success admc-btn--sm" onclick="batchAdmit()">Admit Selected</button>
    <button type="button" class="admc-btn admc-btn--danger admc-btn--sm" onclick="batchReject()">Reject Selected</button>
    <button type="button" class="admc-btn admc-btn--ghost admc-btn--sm" onclick="clearSelection()">Clear Selection</button>
</div>

<!-- Table area -->
<div class="admc-table-wrap">
    <table class="admc-table">
        <thead>
            <tr>
                <th style="width:32px;padding-left:14px;"><input type="checkbox" id="admc-chk-all" title="Select all" onchange="toggleSelectAll(this.checked)"></th>
                <th style="width:28px;">#</th>
                <th>Entry No</th>
                <th>Name</th>
                <th>Programme</th>
                <th>Session</th>
                <th>Year</th>
                <th>Reg No</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <asp:Literal ID="litTableRows" runat="server"/>
        </tbody>
    </table>
</div>

<!-- Pagination (server-rendered) -->
<asp:Literal ID="litPager" runat="server"/>

<!-- ═══ DETAIL MODAL ═══════════════════════════════════════════════ -->
<div class="admc-modal-bg" id="admc-modal-bg">
    <div class="admc-modal">
        <div class="admc-modal__hdr">
            <h3 id="admc-modal-title">Applicant Details</h3>
            <button type="button" class="admc-modal__close" onclick="closeModal()">&times;</button>
        </div>
        <div class="admc-modal__body">
            <div id="admc-status-row" style="padding:12px 18px 0;"></div>
            <div style="padding:4px 18px 20px;">

                <!-- Personal Details -->
                <div class="admc-section">
                    <div class="admc-section__title">Personal Details</div>
                    <div class="admc-grid-3">
                        <div class="admc-field"><label>Entry No</label><div class="admc-field__val" id="d-eno">—</div></div>
                        <div class="admc-field"><label>Reg No</label><div class="admc-field__val" id="d-regno">—</div></div>
                        <div class="admc-field"><label>Full Name</label><div class="admc-field__val" id="d-name">—</div></div>
                        <div class="admc-field"><label>Sex</label><div class="admc-field__val admc-field__val--light" id="d-sex">—</div></div>
                        <div class="admc-field"><label>Date of Birth</label><div class="admc-field__val admc-field__val--light" id="d-dob">—</div></div>
                        <div class="admc-field"><label>Nationality</label><div class="admc-field__val admc-field__val--light" id="d-nationality">—</div></div>
                        <div class="admc-field"><label>Religion</label><div class="admc-field__val admc-field__val--light" id="d-religion">—</div></div>
                        <div class="admc-field"><label>Marital Status</label><div class="admc-field__val admc-field__val--light" id="d-marital">—</div></div>
                        <div class="admc-field"><label>National ID</label><div class="admc-field__val admc-field__val--light" id="d-natid">—</div></div>
                        <div class="admc-field"><label>Disability</label><div class="admc-field__val admc-field__val--light" id="d-disability">—</div></div>
                        <div class="admc-field"><label>Title / Salutation</label><div class="admc-field__val admc-field__val--light" id="d-title">—</div></div>
                        <div class="admc-field"><label>Campus</label><div class="admc-field__val admc-field__val--light" id="d-campus">—</div></div>
                    </div>
                </div>

                <!-- Admission Details -->
                <div class="admc-section">
                    <div class="admc-section__title">Admission Details</div>
                    <div class="admc-grid-3">
                        <div class="admc-field" style="grid-column:span 2;"><label>Programme</label><div class="admc-field__val" id="d-prog">—</div></div>
                        <div class="admc-field"><label>Admission Status</label><div class="admc-field__val" id="d-admstatus">—</div></div>
                        <div class="admc-field"><label>Session</label><div class="admc-field__val admc-field__val--light" id="d-session">—</div></div>
                        <div class="admc-field"><label>Entry Year</label><div class="admc-field__val admc-field__val--light" id="d-year">—</div></div>
                        <div class="admc-field"><label>Entry Method</label><div class="admc-field__val admc-field__val--light" id="d-method">—</div></div>
                        <div class="admc-field"><label>Intake</label><div class="admc-field__val admc-field__val--light" id="d-intake">—</div></div>
                        <div class="admc-field"><label>Specialisation</label><div class="admc-field__val admc-field__val--light" id="d-spec">—</div></div>
                        <div class="admc-field"><label>Sponsor</label><div class="admc-field__val admc-field__val--light" id="d-sponsor">—</div></div>
                        <div class="admc-field"><label>Sponsor Contact</label><div class="admc-field__val admc-field__val--light" id="d-sponsorc">—</div></div>
                        <div class="admc-field"><label>Billing System</label><div class="admc-field__val admc-field__val--light" id="d-billing">—</div></div>
                    </div>
                </div>

                <!-- Education Background -->
                <div class="admc-section">
                    <div class="admc-section__title">Education Background</div>
                    <div class="admc-grid-3">
                        <div class="admc-field"><label>O-Level School</label><div class="admc-field__val admc-field__val--light" id="d-oschool">—</div></div>
                        <div class="admc-field"><label>O-Level Index No.</label><div class="admc-field__val admc-field__val--light" id="d-oidx">—</div></div>
                        <div class="admc-field"><label>O-Level Year</label><div class="admc-field__val admc-field__val--light" id="d-olyr">—</div></div>
                        <div class="admc-field"><label>O-Level Aggregate</label><div class="admc-field__val admc-field__val--light" id="d-olagg">—</div></div>
                        <div class="admc-field"><label>A-Level School</label><div class="admc-field__val admc-field__val--light" id="d-aschool">—</div></div>
                        <div class="admc-field"><label>A-Level Index No.</label><div class="admc-field__val admc-field__val--light" id="d-aidx">—</div></div>
                        <div class="admc-field"><label>A-Level Year</label><div class="admc-field__val admc-field__val--light" id="d-alyr">—</div></div>
                        <div class="admc-field"><label>A-Level Points</label><div class="admc-field__val admc-field__val--light" id="d-alpts">—</div></div>
                        <div class="admc-field"><label>Other Institution</label><div class="admc-field__val admc-field__val--light" id="d-othinst">—</div></div>
                        <div class="admc-field"><label>Other Qualification</label><div class="admc-field__val admc-field__val--light" id="d-othqual">—</div></div>
                        <div class="admc-field"><label>Other Year</label><div class="admc-field__val admc-field__val--light" id="d-othyr">—</div></div>
                        <div class="admc-field"><label>Other Grade</label><div class="admc-field__val admc-field__val--light" id="d-othgr">—</div></div>
                    </div>
                </div>

                <!-- Contact Details -->
                <div class="admc-section">
                    <div class="admc-section__title">Contact Details</div>
                    <div class="admc-grid-3">
                        <div class="admc-field"><label>Phone</label><div class="admc-field__val admc-field__val--light" id="d-phone">—</div></div>
                        <div class="admc-field"><label>Email</label><div class="admc-field__val admc-field__val--light" id="d-email">—</div></div>
                        <div class="admc-field"><label>Physical Address</label><div class="admc-field__val admc-field__val--light" id="d-address">—</div></div>
                        <div class="admc-field"><label>Home District</label><div class="admc-field__val admc-field__val--light" id="d-district">—</div></div>
                        <div class="admc-field"><label>P.O. Box</label><div class="admc-field__val admc-field__val--light" id="d-pobox">—</div></div>
                        <div class="admc-field"><label>Country</label><div class="admc-field__val admc-field__val--light" id="d-country">—</div></div>
                    </div>
                </div>

                <!-- Next of Kin -->
                <div class="admc-section">
                    <div class="admc-section__title">Next of Kin</div>
                    <div class="admc-grid-3">
                        <div class="admc-field"><label>Name</label><div class="admc-field__val admc-field__val--light" id="d-kin">—</div></div>
                        <div class="admc-field"><label>Relationship</label><div class="admc-field__val admc-field__val--light" id="d-kinrel">—</div></div>
                        <div class="admc-field"><label>Contacts</label><div class="admc-field__val admc-field__val--light" id="d-kinc">—</div></div>
                    </div>
                </div>

                <!-- Reviewer Notes -->
                <div class="admc-section" style="margin-bottom:0;">
                    <div class="admc-section__title">Reviewer Notes</div>
                    <textarea id="d-notes" placeholder="Internal notes for this application…" style="width:100%;min-height:90px;border:1px solid #d8e0eb;padding:10px;font:inherit;font-size:12px;resize:vertical;box-sizing:border-box;"></textarea>
                </div>

            </div>
        </div>

        <!-- Footer actions -->
        <div class="admc-modal__foot">
            <button type="button" class="admc-btn admc-btn--ghost" onclick="closeModal()">Close</button>
            <div class="admc-modal__foot-right" id="admc-modal-actions"></div>
        </div>
    </div>
</div>

<!-- Toast notification -->
<div class="admc-toast" id="admc-toast"></div>

<script type="text/javascript">
/* ═══════════════════════════════════════════════════════════════════
   ADMISSIONS CONTROLLER — server-rendered list, AJAX for modal only
   ═══════════════════════════════════════════════════════════════════ */
var _pageUrl       = '<%= ResolveUrl("~/COOPERP/NewScreens/AdmissionsController.aspx") %>';
var _currentEno    = null;
var _currentDetail = null;
var _selected      = {}; // batch selection: { eno: {name,status} }

// ════════════════════════════════════════════════════════════════════
// FILTER NAVIGATION  — navigate to new URL on apply/clear
// ════════════════════════════════════════════════════════════════════
function applyFilters() {
    var sp = new URLSearchParams();
    var q       = (document.getElementById('admc-q').value || '').trim();
    var status  = document.getElementById('admc-status').value;
    var prog    = document.getElementById('admc-prog').value;
    var year    = document.getElementById('admc-year').value;
    var session = document.getElementById('admc-session').value;
    var source  = document.getElementById('admc-source').value;
    var minDays = document.getElementById('admc-min-days').value;
    var psVal   = document.getElementById('admc-pagesize').value;
    if (q)       sp.set('q',              q);
    if (status)  sp.set('status',         status);
    if (prog)    sp.set('prog',           prog);
    if (year)    sp.set('year',           year);
    if (session) sp.set('session',        session);
    if (source)  sp.set('source',         source);
    if (minDays) sp.set('minDaysPending', minDays);
    if (psVal && psVal !== '100') sp.set('size', psVal);
    var qs = sp.toString();
    window.location.href = window.location.pathname + (qs ? '?' + qs : '');
}
function clearFilters() {
    window.location.href = window.location.pathname;
}

// ════════════════════════════════════════════════════════════════════
// BATCH SELECTION
// ════════════════════════════════════════════════════════════════════
function onRowCheck(chk) {
    var eno  = chk.getAttribute('data-eno');
    var name = chk.getAttribute('data-name');
    var st   = chk.getAttribute('data-status');
    if (chk.checked) _selected[eno] = { name: name, status: st };
    else             delete _selected[eno];
    syncBatchToolbar();
    syncSelectAllCheckbox();
}
function toggleSelectAll(checked) {
    var chks = document.querySelectorAll('.admc-row-chk');
    for (var i = 0; i < chks.length; i++) {
        chks[i].checked = checked;
        var eno  = chks[i].getAttribute('data-eno');
        var name = chks[i].getAttribute('data-name');
        var st   = chks[i].getAttribute('data-status');
        if (checked) _selected[eno] = { name: name, status: st };
        else         delete _selected[eno];
    }
    syncBatchToolbar();
}
function clearSelection() {
    _selected = {};
    var chks = document.querySelectorAll('.admc-row-chk');
    for (var i = 0; i < chks.length; i++) chks[i].checked = false;
    var ca = document.getElementById('admc-chk-all');
    if (ca) { ca.checked = false; ca.indeterminate = false; }
    syncBatchToolbar();
}
function syncBatchToolbar() {
    var keys = Object.keys(_selected);
    var n    = keys.length;
    var el   = document.getElementById('admc-batch');
    var info = document.getElementById('admc-batch-info');
    if (n > 0) {
        el.classList.add('visible');
        info.textContent = n + ' applicant' + (n === 1 ? '' : 's') + ' selected';
    } else {
        el.classList.remove('visible');
    }
}
function syncSelectAllCheckbox() {
    var ca   = document.getElementById('admc-chk-all');
    if (!ca) return;
    var all  = document.querySelectorAll('.admc-row-chk');
    var chkd = document.querySelectorAll('.admc-row-chk:checked');
    ca.checked       = all.length > 0 && chkd.length === all.length;
    ca.indeterminate = chkd.length > 0 && chkd.length < all.length;
}

function batchAdmit() {
    var keys = Object.keys(_selected);
    if (!keys.length) return;
    var pending = [];
    for (var i = 0; i < keys.length; i++) {
        if (_selected[keys[i]].status === 'PENDING') pending.push(keys[i]);
    }
    if (!pending.length) { showToast('No PENDING applicants in selection.', false); return; }
    if (!confirm('Admit ' + pending.length + ' applicant(s)?')) return;
    var done = 0, errs = 0, total = pending.length;
    for (var j = 0; j < pending.length; j++) {
        (function(eno) {
            postAction('admit', eno, {}, function () {
                done++;
                if (done + errs === total) {
                    showToast('✓ ' + done + ' admitted' + (errs ? ', ' + errs + ' failed' : '') + '.', errs === 0);
                    setTimeout(function(){ window.location.reload(); }, 800);
                }
            }, function () {
                errs++;
                if (done + errs === total) {
                    showToast(done + ' admitted, ' + errs + ' failed.', false);
                    setTimeout(function(){ window.location.reload(); }, 800);
                }
            });
        })(pending[j]);
    }
}

function batchReject() {
    var keys = Object.keys(_selected);
    if (!keys.length) return;
    var eligible = [];
    for (var i = 0; i < keys.length; i++) {
        var s = _selected[keys[i]].status;
        if (s === 'PENDING' || s === 'ADMITTED') eligible.push(keys[i]);
    }
    if (!eligible.length) { showToast('No PENDING/ADMITTED applicants in selection.', false); return; }
    var reason = prompt('Rejection reason for ' + eligible.length + ' applicant(s):');
    if (reason === null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    var done = 0, errs = 0, total = eligible.length;
    for (var j = 0; j < eligible.length; j++) {
        (function(eno) {
            postAction('reject', eno, { reason: reason }, function () {
                done++;
                if (done + errs === total) {
                    showToast('✓ ' + done + ' rejected' + (errs ? ', ' + errs + ' failed' : '') + '.', errs === 0);
                    setTimeout(function(){ window.location.reload(); }, 800);
                }
            }, function () {
                errs++;
                if (done + errs === total) {
                    showToast(done + ' rejected, ' + errs + ' failed.', false);
                    setTimeout(function(){ window.location.reload(); }, 800);
                }
            });
        })(eligible[j]);
    }
}

// ════════════════════════════════════════════════════════════════════
// DETAIL MODAL  (AJAX — popup only)
// ════════════════════════════════════════════════════════════════════
function openDetail(eno) {
    _currentEno = eno;
    setText('admc-modal-title', 'Applicant  —  ' + eno);
    document.getElementById('admc-status-row').innerHTML =
        '<div style="padding:10px 0;color:#174DA4;font-size:12px;">Loading…</div>';
    clearDetailFields();
    document.getElementById('admc-modal-actions').innerHTML = '';
    document.getElementById('admc-modal-bg').classList.add('open');

    fetch(_pageUrl + '?ajax=detail&eno=' + encodeURIComponent(eno))
        .then(function (r) { return r.json(); })
        .then(function (d) {
            if (!d.ok) {
                document.getElementById('admc-status-row').innerHTML =
                    '<div style="padding:10px 0;color:#c62828;font-size:12px;">⚠ ' + h(d.error) + '</div>';
                return;
            }
            _currentDetail = d;
            populateDetail(d);
        })
        .catch(function () {
            document.getElementById('admc-status-row').innerHTML =
                '<div style="padding:10px 0;color:#c62828;">Failed to load applicant detail.</div>';
        });
}
function openDetailTab(eno, tab) { openDetail(eno); }

function closeModal() {
    document.getElementById('admc-modal-bg').classList.remove('open');
    _currentEno = null;
    _currentDetail = null;
}
document.getElementById('admc-modal-bg').addEventListener('click', function (e) {
    if (e.target === this) closeModal();
});
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeModal();
});

function clearDetailFields() {
    var ids = ['d-eno','d-regno','d-name','d-sex','d-dob','d-nationality','d-religion',
               'd-marital','d-natid','d-disability','d-title','d-campus',
               'd-prog','d-session','d-year','d-method','d-intake','d-spec',
               'd-sponsor','d-sponsorc','d-billing',
               'd-oschool','d-oidx','d-olyr','d-olagg',
               'd-aschool','d-aidx','d-alyr','d-alpts',
               'd-othinst','d-othqual','d-othyr','d-othgr',
               'd-phone','d-email','d-address','d-district','d-pobox','d-country',
               'd-kin','d-kinrel','d-kinc'];
    for (var i = 0; i < ids.length; i++) {
        var el = document.getElementById(ids[i]);
        if (el) el.textContent = '—';
    }
    var notes = document.getElementById('d-notes');
    if (notes) notes.value = '';
    var dAdm = document.getElementById('d-admstatus');
    if (dAdm) dAdm.innerHTML = '—';
}

function populateDetail(d) {
    setText('d-eno',         d.eno);
    setText('d-regno',       d.regno && d.regno !== '-' ? d.regno : 'Not yet assigned');
    setText('d-name',        d.name);
    setText('d-sex',         d.sex);
    setText('d-dob',         d.dob);
    setText('d-nationality', d.nationality);
    setText('d-religion',    d.religion);
    setText('d-marital',     d.marital);
    setText('d-natid',       d.national_id);
    setText('d-disability',  d.disability);
    setText('d-title',       d.title);
    setText('d-campus',      d.campus);
    setText('d-prog',        d.programme);
    setText('d-session',     d.session);
    setText('d-year',        d.entry_year);
    setText('d-method',      d.entry_method);
    setText('d-intake',      d.intake);
    setText('d-spec',        d.specialisation || 'None');
    setText('d-sponsor',     d.sponsor);
    setText('d-sponsorc',    d.sponsor_contact);
    setText('d-billing',     d.billing);
    setText('d-oschool',     d.olevel_school);
    setText('d-oidx',        d.olevel_index);
    setText('d-olyr',        d.olevel_year);
    setText('d-olagg',       d.olevel_agg);
    setText('d-aschool',     d.alevel_school);
    setText('d-aidx',        d.alevel_index);
    setText('d-alyr',        d.alevel_year);
    setText('d-alpts',       d.alevel_points);
    setText('d-othinst',     d.other_inst);
    setText('d-othqual',     d.other_qual);
    setText('d-othyr',       d.other_year);
    setText('d-othgr',       d.other_grade);
    setText('d-phone',       d.phone);
    setText('d-email',       d.email);
    setText('d-address',     d.address);
    setText('d-district',    d.district);
    setText('d-pobox',       d.pobox);
    setText('d-country',     d.country);
    setText('d-kin',         d.kin_name);
    setText('d-kinrel',      d.kin_relationship);
    setText('d-kinc',        d.kin_contacts);
    var notes = document.getElementById('d-notes');
    if (notes) notes.value = d.reviewer_notes || '';

    var sclass = (d.status === 'PENDING') ? 'admc-warn-row' : '';
    document.getElementById('admc-status-row').innerHTML =
        '<div class="admc-info-row ' + sclass + '" style="margin:0 0 0;">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
      + '<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>'
      + '&nbsp;Status:&nbsp;<strong>' + h(d.status) + '</strong>'
      + (d.regno && d.regno !== '-'
            ? '&nbsp;&nbsp;|&nbsp;&nbsp;Reg No:&nbsp;<strong style="font-family:monospace;">' + h(d.regno) + '</strong>'
            : '')
      + '&nbsp;&nbsp;|&nbsp;&nbsp;Entry: <strong>' + h(d.eno) + '</strong>'
      + '</div>';

    var dAdm = document.getElementById('d-admstatus');
    if (dAdm) dAdm.innerHTML = statusBadge(d.status);
    setText('admc-modal-title', d.name + '  —  ' + d.eno);
    buildModalActions(d);
}

function buildModalActions(d) {
    var acts = document.getElementById('admc-modal-actions');
    acts.innerHTML = '';
    if (d.status === 'PENDING') {
        acts.innerHTML +=
            '<button type="button" class="admc-btn admc-btn--danger" onclick="rejectOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
          + ' Reject</button>'
          + '<button type="button" class="admc-btn admc-btn--success" onclick="admitOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>'
          + ' Admit</button>';
    }
    if (d.status === 'ADMITTED') {
        acts.innerHTML +=
            '<button type="button" class="admc-btn admc-btn--amber" onclick="rejectOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">Withdraw</button>'
          + '<button type="button" class="admc-btn admc-btn--primary" id="btn-reg-modal" onclick="registerOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><polyline points="17 11 19 13 23 9"/></svg>'
          + ' Register as Student</button>';
    }
    if (d.status === 'REGISTERED' && d.regno && d.regno !== '-') {
        acts.innerHTML +=
            '<button type="button" class="admc-btn admc-btn--amber" id="btn-rereg-modal" onclick="reregisterOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">Re-register / Fix</button>'
          + '<a href="StudentProfile.aspx?regno=' + encodeURIComponent(d.regno) + '" class="admc-btn admc-btn--primary" target="_blank">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>'
          + ' View Student Profile</a>';
    }
    acts.innerHTML +=
        '<button type="button" class="admc-btn admc-btn--ghost" onclick="saveNotes()">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>'
      + ' Save Notes</button>';
}

function saveNotes() {
    if (!_currentEno) return;
    var notesEl = document.getElementById('d-notes');
    var notes = notesEl ? notesEl.value || '' : '';
    postAction('note', _currentEno, { notes: notes }, function () {
        showToast('✓ Notes saved for ' + _currentEno + '.', true);
        if (_currentDetail) _currentDetail.reviewer_notes = notes;
    });
}

// ════════════════════════════════════════════════════════════════════
// ACTIONS
// ════════════════════════════════════════════════════════════════════
function admitOne(eno, name) {
    if (!confirm('Admit ' + name + ' (' + eno + ')?\nThis marks the applicant as ADMITTED.')) return;
    postAction('admit', eno, {}, function () {
        showToast('✓ ' + name + ' admitted successfully.', true);
        setTimeout(function(){ window.location.reload(); }, 800);
    });
}

function rejectOne(eno, name) {
    var reason = prompt('Reason for rejecting / withdrawing ' + name + ':');
    if (reason === null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    postAction('reject', eno, { reason: reason }, function () {
        showToast('✓ ' + name + ' rejected/withdrawn.', true);
        setTimeout(function(){ window.location.reload(); }, 800);
    });
}

function registerOne(eno, name) {
    if (!confirm('Register ' + name + ' (' + eno + ') as a student?\nThis generates a registration number and creates the full student record.')) return;
    var btn = document.getElementById('btn-reg-modal');
    if (btn) { btn.disabled = true; btn.textContent = 'Registering…'; }
    postAction('register', eno, {}, function (d) {
        showToast('✓ ' + name + ' registered! Reg No: ' + (d.regno || ''), true);
        setTimeout(function(){ window.location.reload(); }, 1200);
    }, function () {
        if (btn) { btn.disabled = false; btn.textContent = 'Register as Student'; }
    });
}

function reregisterOne(eno, name) {
    if (!confirm('Run re-registration checks for ' + name + ' (' + eno + ')?\nIf not fully registered, the system will complete registration. If already registered, it will repair missing records.')) return;
    var btn = document.getElementById('btn-rereg-modal');
    if (btn) { btn.disabled = true; btn.textContent = 'Checking…'; }
    postAction('reregister', eno, {}, function (d) {
        showToast('✓ ' + (d.message || ('Re-registration check completed for ' + name + '.')), true);
        setTimeout(function(){ window.location.reload(); }, 1000);
    }, function () {
        if (btn) { btn.disabled = false; btn.textContent = 'Re-register / Fix'; }
    });
}

// ── Generic POST ─────────────────────────────────────────────────
function postAction(action, eno, extra, onOk, onErr) {
    var payload = { eno: eno };
    var keys = Object.keys(extra);
    for (var i = 0; i < keys.length; i++) payload[keys[i]] = extra[keys[i]];
    fetch(_pageUrl + '?ajax=' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(function (r) { return r.json(); })
    .then(function (d) {
        if (!d.ok) { showToast('✗ ' + (d.error || 'Action failed.'), false); if (onErr) onErr(d.error); return; }
        if (onOk) onOk(d);
    })
    .catch(function (e) {
        showToast('✗ Network error. Please try again.', false);
        if (onErr) onErr(e);
    });
}

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════
function showToast(msg, ok) {
    var t = document.getElementById('admc-toast');
    t.textContent = msg;
    t.className   = 'admc-toast show ' + (ok ? 'admc-toast--ok' : 'admc-toast--err');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function () { t.className = 'admc-toast'; }, 5000);
}
function setText(id, val) {
    var el = document.getElementById(id);
    if (el) el.textContent = (val !== null && val !== undefined && String(val).length) ? val : '—';
}
function statusBadge(s) {
    var cls = { PENDING:'admc-badge--pending', ADMITTED:'admc-badge--admitted',
                REGISTERED:'admc-badge--registered', REJECTED:'admc-badge--rejected',
                WITHDRAWN:'admc-badge--withdrawn' };
    return '<span class="admc-badge ' + (cls[s] || '') + '">' + h(s || '—') + '</span>';
}
function h(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function escJ(s) { return String(s || '').replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }
</script>

</asp:Content>
