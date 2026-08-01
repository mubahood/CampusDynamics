<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="OnlineApplicationsController.aspx.cs"
    Inherits="COOPERP_NewScreens_OnlineApplicationsController"
    Title="Online Applications - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ONLINE APPLICATIONS CONTROLLER (prefix: oa-) ========================= */

.oa-hdr{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #e0e5ed;background:#fff;}
.oa-hdr__left{display:flex;align-items:center;gap:10px;}
.oa-hdr__icon{width:36px;height:36px;background:#05275C;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.oa-hdr__title{font-size:15px;font-weight:700;color:#05275C;line-height:1.2;}
.oa-hdr__sub{font-size:10px;color:#888;margin-top:1px;}
.oa-hdr__actions{display:flex;align-items:center;gap:8px;}

/* Stats */
.oa-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;padding:14px 16px;background:#fafbfc;border-bottom:1px solid #e0e5ed;}
.oa-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;position:relative;overflow:hidden;}
.oa-stat::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--sc,#ccc);}
.oa-stat__label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#888;margin-bottom:3px;}
.oa-stat__value{font-size:22px;font-weight:800;letter-spacing:-.5px;color:var(--sc,#333);}
.oa-stat--total{--sc:#05275C;}
.oa-stat--draft{--sc:#9ca3af;}
.oa-stat--submitted{--sc:#174DA4;}
.oa-stat--review{--sc:#d97706;}
.oa-stat--admitted{--sc:#d97706;}
.oa-stat--rejected{--sc:#c62828;}

/* Filter bar */
.oa-filters{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fa;}
.oa-filters__row{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.oa-search-wrap{position:relative;flex:1;min-width:200px;max-width:320px;}
.oa-search-wrap svg{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#999;pointer-events:none;}
.oa-search{width:100%;border:1px solid #ddd;padding:6px 10px 6px 30px;font-size:12px;font-family:inherit;background:#fff;}
.oa-search:focus{border-color:#174DA4;outline:none;}
.oa-select{border:1px solid #ddd;padding:6px 8px;font-size:11px;font-family:inherit;background:#fff;color:#333;min-width:130px;}
.oa-select:focus{border-color:#174DA4;outline:none;}
.oa-filters__count{font-size:11px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:4px 10px;margin-left:auto;}

/* Buttons */
.oa-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;font-family:inherit;transition:all .15s;}
.oa-btn--primary{background:#05275C;color:#fff;}.oa-btn--primary:hover{background:#174DA4;}
.oa-btn--amber{background:#d97706;color:#fff;}.oa-btn--amber:hover{background:#b45309;}
.oa-btn--danger{background:#c62828;color:#fff;}.oa-btn--danger:hover{background:#b71c1c;}
.oa-btn--ghost{background:#fff;border:1px solid #cdd3de;color:#555;}.oa-btn--ghost:hover{border-color:#174DA4;color:#174DA4;}
.oa-btn--sm{padding:4px 10px;font-size:10px;}
.oa-btn:disabled{opacity:.5;cursor:not-allowed;}

/* Table */
.oa-table-wrap{overflow-x:auto;}
.oa-table{width:100%;border-collapse:collapse;font-size:11px;}
.oa-table th{background:#f5f7fa;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#666;padding:9px 12px;text-align:left;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.oa-table td{padding:8px 12px;border-bottom:1px solid #f0f2f5;color:#222;vertical-align:middle;overflow:visible;}
.oa-table tr:hover td{background:#f5f9ff;}
.oa-name{font-weight:600;color:#05275C;}
.oa-eno{font-family:monospace;font-size:11px;color:#555;font-weight:600;}
.oa-secondary{font-size:10px;color:#888;font-weight:400;}
.oa-prog-cell{max-width:180px;white-space:normal;font-size:11px;}
.oa-date-cell{color:#888;font-size:10px;white-space:nowrap;}
.oa-clickrow{cursor:pointer;}
/* Doc count badges */
.oa-doc-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:700;white-space:nowrap;}
.oa-doc-badge--none{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;}
.oa-doc-badge--few{background:#fffbeb;color:#b45309;border:1px solid #fde68a;}
.oa-doc-badge--ok{background:#f0fdf4;color:#16a34a;border:1px solid #bbf7d0;}
/* With-docs stat */
.oa-stat--docs{--sc:#065f46;}
.oa-actions-cell{display:flex;gap:4px;flex-wrap:nowrap;position:relative;}
/* ── Row ⋮ menu ──────────────────────────────────────────── */
.oa-row-menu-wrap{position:relative;display:inline-flex;}
.oa-row-trigger{display:inline-flex;align-items:center;justify-content:center;width:28px;height:26px;border:1px solid #d2dae6;background:#fff;color:#555;cursor:pointer;font-size:15px;line-height:1;padding:0;border-radius:5px;flex-shrink:0;}
.oa-row-trigger:hover{background:#f0f4fc;border-color:#174DA4;color:#174DA4;}
.oa-row-menu{display:none;position:absolute;right:0;top:calc(100% + 3px);min-width:186px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 8px 28px rgba(0,0,0,.15);padding:5px;z-index:9100;}
.oa-row-menu.open{display:block;}
.oa-row-menu__item{display:flex;align-items:center;gap:8px;width:100%;padding:8px 12px;border:0;background:transparent;color:#1e293b;font-size:11px;font-weight:600;text-align:left;border-radius:5px;cursor:pointer;white-space:nowrap;font-family:inherit;text-decoration:none;}
.oa-row-menu__item:hover{background:#f0f4fc;color:#05275C;text-decoration:none;}
.oa-row-menu__item--success:hover{background:#f0fdf4;color:#166534;}
.oa-row-menu__item--danger:hover{background:#fef2f2;color:#b91c1c;}
.oa-row-menu__item--edit{color:#174DA4;}.oa-row-menu__item--edit:hover{background:#eef5ff;color:#0c3580;}
.oa-row-menu__sep{height:1px;background:#edf2f7;margin:4px 2px;}

/* Status badges */
.oa-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border:1px solid transparent;white-space:nowrap;}
.oa-badge--draft{background:#f5f5f5;color:#555;border-color:#e0e0e0;}
.oa-badge--submitted{background:#e8f0fc;color:#174DA4;border-color:#bbdefb;}
.oa-badge--under_review{background:#fff8e1;color:#b45309;border-color:#fde68a;}
.oa-badge--admitted{background:#fef9ec;color:#d97706;border-color:#fde68a;}
.oa-badge--rejected{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}
.oa-badge--withdrawn{background:#f5f5f5;color:#757575;border-color:#e0e0e0;}

/* Payment-proof badges */
.oa-pay-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border:1px solid transparent;white-space:nowrap;}
.oa-pay-badge--none{background:#fef2f2;color:#dc2626;border-color:#fecaca;}
.oa-pay-badge--pending{background:#fff8e1;color:#b45309;border-color:#fde68a;}
.oa-pay-badge--verified{background:#f0fdf4;color:#16a34a;border-color:#bbf7d0;}
.oa-pay-badge--rejected{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}
.oa-btn--success{background:#16a34a;color:#fff;}.oa-btn--success:hover{background:#15803d;}
/* Payment detail block */
.oa-pay-box{background:#fafbfd;border:1px solid #eaecf2;padding:12px 14px;}

/* Empty / loading */
.oa-empty{text-align:center;padding:40px 20px;color:#aaa;font-size:12px;}

/* Pagination */
.oa-pager{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;border-top:1px solid #e0e5ed;font-size:11px;color:#666;background:#fafbfc;}
.oa-pager__nav{display:flex;gap:4px;}
.oa-pager__btn{border:1px solid #ddd;background:#fff;padding:4px 10px;font-size:11px;cursor:pointer;color:#333;font-family:inherit;text-decoration:none;display:inline-block;}
.oa-pager__btn:hover{background:#f0f4ff;border-color:#174DA4;color:#174DA4;}

/* Detail modal */
.oa-modal-bg{display:none;position:fixed;inset:0;z-index:9100;background:rgba(0,0,0,.5);align-items:flex-start;justify-content:center;padding-top:40px;overflow-y:auto;}
.oa-modal-bg.open{display:flex;}
.oa-modal{background:#fff;width:920px;max-width:96vw;box-shadow:0 20px 60px rgba(0,0,0,.25);max-height:90vh;display:flex;flex-direction:column;}
.oa-modal__hdr{display:flex;align-items:center;justify-content:space-between;padding:13px 18px;background:#05275C;color:#fff;flex-shrink:0;}
.oa-modal__hdr h3{margin:0;font-size:14px;font-weight:700;}
.oa-modal__close{background:none;border:none;color:rgba(255,255,255,.8);font-size:22px;cursor:pointer;line-height:1;padding:0 4px;}
.oa-modal__close:hover{color:#fff;}
.oa-modal__body{padding:0;overflow-y:auto;flex:1;}
.oa-modal__tabs{display:flex;border-bottom:2px solid #e0e5ed;background:#f8f9fa;flex-shrink:0;}
.oa-modal__tab{padding:10px 16px;font-size:11px;font-weight:600;cursor:pointer;border:none;background:none;color:#666;border-bottom:2px solid transparent;margin-bottom:-2px;font-family:inherit;}
.oa-modal__tab.active{color:#05275C;border-bottom-color:#05275C;background:#fff;}
.oa-modal__tab:hover{color:#174DA4;}
.oa-tab-panel{display:none;padding:16px 18px;}
.oa-tab-panel.active{display:block;}
.oa-section{margin-bottom:16px;}
.oa-section__title{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#888;border-bottom:1px solid #f0f0f0;padding-bottom:5px;margin-bottom:10px;}
.oa-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:10px 20px;}
.oa-grid-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px 20px;}
.oa-field label{font-size:10px;font-weight:700;text-transform:uppercase;color:#888;letter-spacing:.3px;display:block;margin-bottom:2px;}
.oa-field__val{font-size:12px;font-weight:600;color:#05275C;}
.oa-field__val--light{font-weight:400;color:#444;}
.oa-modal__foot{display:flex;align-items:center;justify-content:space-between;padding:12px 18px;border-top:1px solid #e0e5ed;background:#fafbfc;flex-shrink:0;flex-wrap:wrap;gap:8px;}
.oa-modal__foot-right{display:flex;gap:8px;flex-wrap:wrap;align-items:center;}
/* ── Detail-view sections (prefix: adm-, shared with AdmissionsController) ── */
.adm-detail-wrap{padding:0;}
.adm-section{padding:14px 20px 12px;border-bottom:1px solid #eef0f4;}
.adm-section:last-child{border-bottom:none;}
.adm-section-hdr{display:flex;align-items:center;gap:7px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#174DA4;border-left:3px solid #174DA4;padding-left:8px;margin-bottom:12px;line-height:1.3;}
.adm-section-hdr svg{flex-shrink:0;opacity:.8;}
.adm-g4{display:grid;grid-template-columns:repeat(4,1fr);gap:10px 14px;}
.adm-g3{display:grid;grid-template-columns:repeat(3,1fr);gap:10px 14px;}
.adm-g2{display:grid;grid-template-columns:1fr 1fr;gap:10px 14px;}
.adm-s2{grid-column:span 2;}.adm-s3{grid-column:span 3;}.adm-s4{grid-column:span 4;}
.adm-f label{display:block;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#999;font-weight:700;margin-bottom:3px;}
.adm-fv{font-size:12px;color:#1a1a2e;font-weight:600;word-break:break-word;line-height:1.45;}
.adm-fv.lt{font-weight:400;color:#333;}.adm-fv.mo{font-family:monospace;font-size:11px;letter-spacing:.3px;}
.adm-edu-blk{background:#fafbfd;border:1px solid #eaecf2;padding:10px 12px;margin-bottom:8px;}
.adm-edu-blk:last-child{margin-bottom:0;}
.adm-edu-blk-ttl{font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;margin-bottom:8px;}
.adm-docs-grid{display:flex;flex-wrap:wrap;gap:8px;margin-top:4px;}
.adm-doc-card{border:1px solid #dde3ef;padding:8px 10px;display:flex;align-items:flex-start;gap:8px;background:#fff;min-width:190px;flex:1;max-width:calc(50% - 4px);}
.adm-doc-badge{font-size:8px;font-weight:700;text-transform:uppercase;padding:2px 6px;background:#05275C;color:#fff;flex-shrink:0;white-space:nowrap;margin-top:2px;}
.adm-doc-badge.tp-photo{background:#6d28d9;}.adm-doc-badge.tp-olevel{background:#065f46;}.adm-doc-badge.tp-alevel{background:#0c4a6e;}
.adm-doc-badge.tp-natid{background:#92400e;}.adm-doc-badge.tp-passport{background:#1e3a5f;}.adm-doc-badge.tp-other{background:#4b5563;}
.adm-doc-info{flex:1;min-width:0;}
.adm-doc-info .fn{font-size:11px;font-weight:600;color:#1a1a2e;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.adm-doc-info .fm{font-size:10px;color:#888;margin-top:1px;}
.adm-doc-view{font-size:10px;font-weight:700;color:#174DA4;text-decoration:none;flex-shrink:0;margin-top:2px;}
.adm-doc-view:hover{text-decoration:underline;}
.adm-nodocs{font-size:11px;color:#aaa;font-style:italic;padding:6px 0;}
.adm-chip{display:inline-block;background:#e8ecf4;color:#555;font-size:10px;font-weight:700;padding:1px 7px;margin-left:6px;vertical-align:middle;}
.adm-banner{padding:10px 20px;background:#f0f4fc;border-bottom:1px solid #dde3ef;display:flex;align-items:center;gap:12px;flex-wrap:wrap;font-size:12px;}
.adm-banner strong{color:#05275C;}
/* ── Footer overflow / actions menu ─────────────────────── */
.oa-act-wrap{position:relative;display:inline-flex;}
.oa-act-trigger{display:inline-flex;align-items:center;justify-content:center;width:32px;height:32px;border:1px solid #d2dae6;background:#fff;color:#374151;border-radius:6px;cursor:pointer;font-size:18px;line-height:1;padding:0;}
.oa-act-trigger:hover{background:#f4f8ff;border-color:#174DA4;color:#174DA4;}
.oa-act-menu{display:none;position:absolute;bottom:calc(100% + 6px);right:0;min-width:200px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 8px 28px rgba(0,0,0,.15);padding:5px;z-index:9200;}
.oa-act-menu.open{display:block;}
.oa-act-menu__item{display:flex;align-items:center;gap:9px;width:100%;padding:9px 12px;border:0;background:transparent;color:#1e293b;font-size:12px;font-weight:600;text-align:left;border-radius:5px;cursor:pointer;white-space:nowrap;font-family:inherit;}
.oa-act-menu__item:hover{background:#f0f4fc;color:#05275C;}
.oa-act-menu__sep{height:1px;background:#edf2f7;margin:4px 2px;}
.oa-info-row{display:flex;align-items:center;gap:6px;padding:8px 12px;font-size:11px;border:1px solid #e0e0e0;margin-bottom:10px;background:#f8f9fa;}
.oa-info-row svg{color:#174DA4;flex-shrink:0;}
.oa-warn-row{background:#fff8e1;border-color:#fde68a;color:#b45309;}

/* Toast */
.oa-toast{position:fixed;bottom:24px;right:24px;z-index:9999;padding:11px 18px;font-size:12px;font-weight:600;border:1px solid transparent;display:none;min-width:240px;box-shadow:0 4px 20px rgba(0,0,0,.15);}
.oa-toast.show{display:block;}
.oa-toast--ok{background:#e8f5e9;color:#155724;border-color:#c3e6cb;}
.oa-toast--err{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}
/* ── Inline edit mode ─────────────────────────────────────── */
.oa-edit-inp{width:100%;border:1px solid #174DA4;background:#fff;padding:3px 7px;font-size:12px;color:#1a1a2e;box-sizing:border-box;font-family:inherit;outline:none;border-radius:3px;}
.oa-edit-inp:focus{border-color:#05275C;box-shadow:0 0 0 2px rgba(23,77,164,.13);}
.oa-field__val--editing{background:#eef5ff;padding:2px;border-radius:3px;}
.oa-edit-banner{padding:7px 18px 6px;background:#fff8e1;border-bottom:1px solid #ffe082;font-size:11px;color:#7c5c00;display:flex;align-items:center;gap:6px;}

/* Doc list in modal */
.oa-doc-list{list-style:none;margin:0;padding:0;}
.oa-doc-list li{display:flex;align-items:center;gap:8px;padding:6px 0;border-bottom:1px solid #f0f2f5;font-size:11px;}
.oa-doc-list li:last-child{border-bottom:none;}
.oa-doc-list .oa-doc-icon{width:26px;height:26px;background:#f0f4ff;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.oa-doc-label{font-weight:600;color:#05275C;flex:1;}
.oa-doc-file{color:#888;font-size:10px;}

@media (max-width:900px){
    .oa-hdr{flex-direction:column;align-items:flex-start;gap:10px;}
    .oa-filters__row{align-items:stretch;}
    .oa-search-wrap{max-width:none;flex:1 1 100%;}
    .oa-select{min-width:0;flex:1 1 150px;}
    .oa-filters__count{margin-left:0;}
}
@media (max-width:640px){
    .oa-stats{grid-template-columns:repeat(2,minmax(0,1fr));padding:12px;}
    .oa-stat__value{font-size:18px;}
    .oa-table{font-size:10px;}
    .oa-table th,.oa-table td{padding:7px 8px;}
    .oa-modal-bg{padding-top:10px;}
    .oa-modal{width:100%;max-width:100vw;max-height:92vh;}
    .oa-grid-2,.oa-grid-3{grid-template-columns:1fr;}
    .adm-g4{grid-template-columns:1fr 1fr;}
    .adm-g3{grid-template-columns:1fr 1fr;}
    .adm-s3,.adm-s4{grid-column:span 2;}
    .adm-doc-card{max-width:100%;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="oa-hdr">
    <div class="oa-hdr__left">
        <div class="oa-hdr__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <div>
            <div class="oa-hdr__title">Online Applications</div>
            <div class="oa-hdr__sub">Review and process applications submitted through the student portal</div>
        </div>
    </div>
    <div class="oa-hdr__actions">
        <a href="AdmissionsController.aspx" class="oa-btn oa-btn--ghost">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
            Admissions Controller
        </a>
        <button type="button" class="oa-btn oa-btn--ghost" onclick="window.location.reload()" title="Refresh">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
            Refresh
        </button>
    </div>
</div>

<!-- Stats (server-rendered) -->
<asp:Literal ID="litStats" runat="server"/>

<!-- Filters -->
<div class="oa-filters">
    <div class="oa-filters__row">
        <div class="oa-search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="oa-q" class="oa-search" placeholder="Search name, entry no, email…"
                value="<%= HE(FilterQ) %>"
                onkeydown="if(event.key==='Enter'){event.preventDefault();applyFilters();}">
        </div>
        <select id="oa-status" class="oa-select">
            <option value="">All Statuses</option>
            <option value="DRAFT"<%= Sel(FilterStatus,"DRAFT") %>>Draft</option>
            <option value="SUBMITTED"<%= Sel(FilterStatus,"SUBMITTED") %>>Submitted</option>
            <option value="UNDER_REVIEW"<%= Sel(FilterStatus,"UNDER_REVIEW") %>>Under Review</option>
            <option value="ADMITTED"<%= Sel(FilterStatus,"ADMITTED") %>>Admitted</option>
            <option value="REJECTED"<%= Sel(FilterStatus,"REJECTED") %>>Rejected</option>
            <option value="WITHDRAWN"<%= Sel(FilterStatus,"WITHDRAWN") %>>Withdrawn</option>
        </select>
        <select id="oa-prog" class="oa-select" style="max-width:200px;">
            <option value="">All Programmes</option>
            <asp:Literal ID="litProgOptions" runat="server"/>
        </select>
        <select id="oa-year" class="oa-select">
            <option value="">All Years</option>
            <asp:Literal ID="litYearOptions" runat="server"/>
        </select>
        <select id="oa-session" class="oa-select">
            <option value="">All Sessions</option>
            <option value="DAY"<%= Sel(FilterSession,"DAY") %>>Day</option>
            <option value="EVENING"<%= Sel(FilterSession,"EVENING") %>>Evening</option>
            <option value="WEEKEND"<%= Sel(FilterSession,"WEEKEND") %>>Weekend</option>
            <option value="DISTANCE"<%= Sel(FilterSession,"DISTANCE") %>>Distance</option>
        </select>
        <button type="button" class="oa-btn oa-btn--primary" onclick="applyFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="4" y1="6" x2="20" y2="6"/><line x1="8" y1="12" x2="16" y2="12"/><line x1="11" y1="18" x2="13" y2="18"/></svg>
            Filter
        </button>
        <button type="button" class="oa-btn oa-btn--ghost" onclick="clearFilters()">Clear</button>
        <select id="oa-pagesize" class="oa-select" style="min-width:90px;" onchange="applyFilters()">
            <option value="25"<%= Sel(FilterSize.ToString(),"25") %>>25 / page</option>
            <option value="50"<%= Sel(FilterSize.ToString(),"50") %>>50 / page</option>
            <option value="100"<%= Sel(FilterSize.ToString(),"100") %>>100 / page</option>
            <option value="200"<%= Sel(FilterSize.ToString(),"200") %>>200 / page</option>
        </select>
        <span class="oa-filters__count"><asp:Literal ID="litCount" runat="server" Text="—"/></span>
    </div>
</div>

<!-- Table -->
<div class="oa-table-wrap">
    <table class="oa-table">
        <thead>
            <tr>
                <th style="width:28px;">#</th>
                <th>Entry No</th>
                <th>Applicant &amp; Phone</th>
                <th>Programme</th>
                <th>Session &amp; Intake</th>
                <th>Year</th>
                <th>Status</th>
                <th style="text-align:center;">Docs</th>
                <th style="text-align:center;">Payment</th>
                <th>Submitted</th>
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
<div class="oa-modal-bg" id="oa-modal-bg">
    <div class="oa-modal">
        <div class="oa-modal__hdr">
            <h3 id="oa-modal-title">Application Details</h3>
            <button type="button" class="oa-modal__close" onclick="closeModal()">&times;</button>
        </div>
        <div class="oa-modal__body">

            <!-- Status banner -->
            <div class="adm-banner" id="oa-status-row"></div>

            <div class="adm-detail-wrap">

            <!-- ── 1. IDENTITY & PERSONAL INFORMATION ─────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    Identity &amp; Personal Information
                </div>
                <div class="adm-g4">
                    <div class="adm-f"><label>Entry No</label><div class="adm-fv mo" id="d-eno">—</div></div>
                    <div class="adm-f"><label>Title / Salutation</label><div class="adm-fv lt" id="d-title">—</div></div>
                    <div class="adm-f"><label>Gender</label><div class="adm-fv lt" id="d-gender">—</div></div>
                    <div class="adm-f"><label>Date of Birth</label><div class="adm-fv lt" id="d-dob">—</div></div>

                    <div class="adm-f adm-s2"><label>Full Name</label><div class="adm-fv" id="d-name">—</div></div>
                    <div class="adm-f"><label>Nationality</label><div class="adm-fv lt" id="d-nationality">—</div></div>
                    <div class="adm-f"><label>National ID / NIN</label><div class="adm-fv mo lt" id="d-natid">—</div></div>

                    <div class="adm-f"><label>Religion</label><div class="adm-fv lt" id="d-religion">—</div></div>
                    <div class="adm-f"><label>Marital Status</label><div class="adm-fv lt" id="d-marital">—</div></div>
                    <div class="adm-f adm-s2"><label>Physical Disability</label><div class="adm-fv lt" id="d-disability">—</div></div>
                </div>
            </div>

            <!-- ── 2. PROGRAMME & ADMISSION ──────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                    Programme &amp; Admission
                </div>
                <div class="adm-g4">
                    <div class="adm-f adm-s3"><label>Programme (1st Choice)</label><div class="adm-fv" id="d-prog">—</div></div>
                    <div class="adm-f"><label>Application Status</label><div class="adm-fv" id="d-admstatus">—</div></div>

                    <div class="adm-f adm-s2"><label>Specialisation / Major</label><div class="adm-fv lt" id="d-spec">—</div></div>
                    <div class="adm-f"><label>Campus</label><div class="adm-fv lt" id="d-campus">—</div></div>
                    <div class="adm-f"><label>Billing System</label><div class="adm-fv lt" id="d-billing">—</div></div>

                    <div class="adm-f"><label>Study Session</label><div class="adm-fv lt" id="d-session">—</div></div>
                    <div class="adm-f"><label>Entry Year</label><div class="adm-fv lt" id="d-year">—</div></div>
                    <div class="adm-f"><label>Intake</label><div class="adm-fv lt" id="d-intake">—</div></div>
                    <div class="adm-f"><label>Entry Method</label><div class="adm-fv lt" id="d-entrymethod">—</div></div>
                </div>
            </div>

            <!-- ── 3. EDUCATION BACKGROUND ────────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                    Education Background
                </div>
                <div class="adm-edu-blk">
                    <div class="adm-edu-blk-ttl">O&#8209;Level &nbsp;/&nbsp; UCE</div>
                    <div class="adm-g4">
                        <div class="adm-f adm-s2"><label>School / Institution</label><div class="adm-fv lt" id="d-oschool">—</div></div>
                        <div class="adm-f"><label>Index / Exam No.</label><div class="adm-fv mo lt" id="d-oidx">—</div></div>
                        <div class="adm-f"><label>Year of Completion</label><div class="adm-fv lt" id="d-oyr">—</div></div>
                        <div class="adm-f"><label>Aggregate Points</label><div class="adm-fv lt" id="d-oagg">—</div></div>
                    </div>
                </div>
                <div class="adm-edu-blk">
                    <div class="adm-edu-blk-ttl">A&#8209;Level &nbsp;/&nbsp; UACE</div>
                    <div class="adm-g4">
                        <div class="adm-f adm-s2"><label>School / Institution</label><div class="adm-fv lt" id="d-aschool">—</div></div>
                        <div class="adm-f"><label>Index / Exam No.</label><div class="adm-fv mo lt" id="d-aidx">—</div></div>
                        <div class="adm-f"><label>Year of Completion</label><div class="adm-fv lt" id="d-ayr">—</div></div>
                        <div class="adm-f"><label>Points / Passes</label><div class="adm-fv lt" id="d-apts">—</div></div>
                    </div>
                </div>
                <div class="adm-edu-blk">
                    <div class="adm-edu-blk-ttl">Other Qualification &nbsp;<span style="font-weight:400;text-transform:none;color:#aaa;font-size:9px;">(Diploma / Degree / Certificate)</span></div>
                    <div class="adm-g4">
                        <div class="adm-f adm-s2"><label>Institution</label><div class="adm-fv lt" id="d-oinst">—</div></div>
                        <div class="adm-f"><label>Qualification / Award</label><div class="adm-fv lt" id="d-oqual">—</div></div>
                        <div class="adm-f"><label>Year of Completion</label><div class="adm-fv lt" id="d-oqyr">—</div></div>
                        <div class="adm-f"><label>Grade / Class</label><div class="adm-fv lt" id="d-oqgr">—</div></div>
                    </div>
                </div>
            </div>

            <!-- ── 4. CONTACT INFORMATION ─────────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                    Contact Information
                </div>
                <div class="adm-g4">
                    <div class="adm-f"><label>Phone Number</label><div class="adm-fv" id="d-phone">—</div></div>
                    <div class="adm-f"><label>Email Address</label><div class="adm-fv lt" id="d-email">—</div></div>
                    <div class="adm-f"><label>Home District</label><div class="adm-fv lt" id="d-district">—</div></div>
                    <div class="adm-f"><label>Residence Country</label><div class="adm-fv lt" id="d-country">—</div></div>

                    <div class="adm-f adm-s3"><label>Physical / Postal Address</label><div class="adm-fv lt" id="d-address">—</div></div>
                    <div class="adm-f"><label>P.O. Box</label><div class="adm-fv lt" id="d-pobox">—</div></div>
                </div>
            </div>

            <!-- ── 5. SPONSOR, KIN, REFEREE & EMERGENCY ──────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    Sponsor, Next of Kin, Referee &amp; Emergency Contact
                </div>
                <div class="adm-g4">
                    <div class="adm-f adm-s2"><label>Sponsor Name</label><div class="adm-fv lt" id="d-sponsor">—</div></div>
                    <div class="adm-f adm-s2"><label>Sponsor Contact</label><div class="adm-fv lt" id="d-sponsorc">—</div></div>

                    <div class="adm-f adm-s2"><label>Next of Kin Name</label><div class="adm-fv lt" id="d-kinname">—</div></div>
                    <div class="adm-f"><label>Relationship</label><div class="adm-fv lt" id="d-kinrel">—</div></div>
                    <div class="adm-f"><label>Kin Contact</label><div class="adm-fv lt" id="d-kincon">—</div></div>

                    <div class="adm-f adm-s2"><label>Referee Name</label><div class="adm-fv lt" id="d-refname">—</div></div>
                    <div class="adm-f adm-s2"><label>Referee Contact</label><div class="adm-fv lt" id="d-refcon">—</div></div>

                    <div class="adm-f adm-s2"><label>Emergency Contact Name</label><div class="adm-fv lt" id="d-emname">—</div></div>
                    <div class="adm-f"><label>Relationship</label><div class="adm-fv lt" id="d-emrel">—</div></div>
                    <div class="adm-f"><label>Emergency Phone</label><div class="adm-fv lt" id="d-emphone">—</div></div>
                </div>
            </div>

            <!-- ── 6. SUPPORTING DOCUMENTS ────────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/></svg>
                    Supporting Documents
                    <span class="adm-chip" id="d-doc-count"></span>
                </div>
                <div id="d-docs-list"><div class="adm-nodocs">Loading…</div></div>
            </div>

            <!-- ── 6b. PROOF OF PAYMENT ───────────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                    Proof of Payment (Application Fee)
                    <span class="adm-chip" id="d-pay-chip"></span>
                </div>
                <div id="d-pay-none" class="adm-nodocs" style="display:none;">No proof of payment submitted yet.</div>
                <div id="d-pay-body" class="oa-pay-box">
                    <div class="adm-g4">
                        <div class="adm-f"><label>Status</label><div class="adm-fv" id="d-pay-status">—</div></div>
                        <div class="adm-f"><label>Reference / TID</label><div class="adm-fv mo" id="d-pay-ref">—</div></div>
                        <div class="adm-f"><label>Amount Paid</label><div class="adm-fv" id="d-pay-amount">—</div></div>
                        <div class="adm-f"><label>Date Paid</label><div class="adm-fv lt" id="d-pay-date">—</div></div>

                        <div class="adm-f"><label>Method</label><div class="adm-fv lt" id="d-pay-method">—</div></div>
                        <div class="adm-f"><label>Submitted On</label><div class="adm-fv lt" id="d-pay-created">—</div></div>
                        <div class="adm-f adm-s2"><label>Receipt</label><div class="adm-fv" id="d-pay-receipt">—</div></div>

                        <div class="adm-f adm-s4"><label>Applicant Notes</label><div class="adm-fv lt" id="d-pay-notes">—</div></div>
                        <div class="adm-f adm-s4" id="d-pay-adminnotes-wrap" style="display:none;"><label>Admin Decision Notes</label><div class="adm-fv lt" id="d-pay-adminnotes">—</div></div>
                    </div>
                </div>
            </div>

            <!-- ── 7. APPLICATION RECORD & NOTES ──────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    Application Record
                </div>
                <div class="adm-g4" style="margin-bottom:12px;">
                    <div class="adm-f"><label>Application Source</label><div class="adm-fv" id="d-appsource">—</div></div>
                    <div class="adm-f"><label>Submitted At</label><div class="adm-fv lt" id="d-submitted">—</div></div>
                    <div class="adm-f"><label>Last Updated</label><div class="adm-fv lt" id="d-lastupdated">—</div></div>
                    <div class="adm-f"><label>&nbsp;</label></div>
                </div>
                <label style="display:block;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#999;font-weight:700;margin-bottom:5px;">Internal Reviewer Notes</label>
                <textarea id="d-notes" placeholder="Add internal notes about this application…" style="width:100%;min-height:80px;border:1px solid #d0d7e6;padding:9px 10px;font:inherit;font-size:12px;resize:vertical;box-sizing:border-box;background:#fafbfc;"></textarea>
            </div>

            </div><!-- /adm-detail-wrap -->
        </div><!-- /oa-modal__body -->

        <!-- Edit mode banner -->
        <div class="oa-edit-banner" id="oa-edit-banner" style="display:none;">
          <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          Edit mode — modify any field, then click <strong>Save Changes</strong>. Status is not editable here.
        </div>

        <!-- Footer -->
        <div class="oa-modal__foot">
            <button type="button" class="oa-btn oa-btn--ghost" id="oa-close-btn" onclick="closeModal()">Close</button>
            <div class="oa-modal__foot-right" id="oa-modal-actions"></div>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="oa-toast" id="oa-toast"></div>

<script type="text/javascript">
/* ═══════════════════════════════════════════════════════════════════
   ONLINE APPLICATIONS CONTROLLER
   ═══════════════════════════════════════════════════════════════════ */
var _pageUrl       = '<%= ResolveUrl("~/COOPERP/NewScreens/OnlineApplicationsController.aspx") %>';
var _currentEno    = null;
var _currentDetail = null;
// Navigate to centralised edit form
window.goToOaEditForm = function(eno) {
    if (!eno) return;
    window.location.href = 'NewStudentRegistration.aspx?eno=' + encodeURIComponent(eno) + '&returnUrl=' + encodeURIComponent('OnlineApplicationsController.aspx');
};

// ── Filters → GET navigation ─────────────────────────────────────
function applyFilters() {
    var sp      = new URLSearchParams();
    var q       = (document.getElementById('oa-q').value || '').trim();
    var status  = document.getElementById('oa-status').value;
    var prog    = document.getElementById('oa-prog').value;
    var year    = document.getElementById('oa-year').value;
    var session = document.getElementById('oa-session').value;
    var psSel   = document.getElementById('oa-pagesize');
    var psVal   = psSel ? psSel.value : '50';
    if (q)                   sp.set('q',       q);
    if (status)              sp.set('status',  status);
    if (prog)                sp.set('prog',    prog);
    if (year)                sp.set('year',    year);
    if (session)             sp.set('session', session);
    if (psVal && psVal !== '50') sp.set('size', psVal);
    var qs = sp.toString();
    window.location.href = window.location.pathname + (qs ? '?' + qs : '');
}
function clearFilters() {
    window.location.href = window.location.pathname;
}

// ── Detail modal ─────────────────────────────────────────────────
function openDetail(eno) {
    _currentEno = eno;
    setText('oa-modal-title', 'Application — ' + eno);
    document.getElementById('oa-status-row').innerHTML =
        '<div style="padding:10px 18px;color:#174DA4;font-size:12px;">Loading…</div>';
    clearDetailFields();
    document.getElementById('oa-modal-actions').innerHTML = '';
    document.getElementById('oa-modal-bg').classList.add('open');

    fetch(_pageUrl + '?ajax=detail&eno=' + encodeURIComponent(eno))
        .then(function (r) {
            if (r.status === 403) {
                document.getElementById('oa-status-row').innerHTML =
                    '<div style="padding:10px 18px;color:#c62828;font-size:12px;">&#9888; Your session has expired. '
                  + '<a href="' + window.location.href + '" style="color:#c62828;font-weight:700;text-decoration:underline;">Reload the page</a> to continue.</div>';
                return null;
            }
            return r.json();
        })
        .then(function (d) {
            if (!d) return;
            if (!d.ok) {
                var msg = d.error === 'session_expired'
                    ? 'Session expired — reload the page to continue.'
                    : (d.error || 'Failed to load detail.');
                document.getElementById('oa-status-row').innerHTML =
                    '<div style="padding:10px 18px;color:#c62828;font-size:12px;">&#9888; ' + h(msg) + '</div>';
                return;
            }
            _currentDetail = d;
            populateDetail(d);
        })
        .catch(function () {
            document.getElementById('oa-status-row').innerHTML =
                '<div style="padding:10px 18px;color:#c62828;">Failed to load application detail. Check your connection and try again.</div>';
        });
}

function closeModal() {
    document.getElementById('oa-modal-bg').classList.remove('open');
    _currentEno = null;
    _currentDetail = null;
}
document.getElementById('oa-modal-bg').addEventListener('click', function (e) {
    if (e.target === this) closeModal();
});
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeModal();
});

function clearDetailFields() {
    var ids = [
        'd-eno','d-title','d-gender','d-dob','d-name','d-nationality','d-natid',
        'd-religion','d-marital','d-disability',
        'd-prog','d-spec','d-campus','d-billing','d-session','d-year','d-intake','d-entrymethod',
        'd-oschool','d-oidx','d-oyr','d-oagg',
        'd-aschool','d-aidx','d-ayr','d-apts',
        'd-oinst','d-oqual','d-oqyr','d-oqgr',
        'd-phone','d-email','d-district','d-country','d-address','d-pobox',
        'd-sponsor','d-sponsorc','d-kinname','d-kinrel','d-kincon',
        'd-refname','d-refcon',
        'd-emname','d-emrel','d-emphone',
        'd-appsource','d-submitted','d-lastupdated'
    ];
    for (var i = 0; i < ids.length; i++) {
        var el = document.getElementById(ids[i]);
        if (el) el.textContent = '—';
    }
    var admEl = document.getElementById('d-admstatus');
    if (admEl) admEl.innerHTML = '—';
    var notes = document.getElementById('d-notes');
    if (notes) notes.value = '';
    var docList = document.getElementById('d-docs-list');
    if (docList) docList.innerHTML = '<div class="adm-nodocs">Loading…</div>';
    var docCount = document.getElementById('d-doc-count');
    if (docCount) docCount.textContent = '';
    // Reset payment block
    var payIds = ['d-pay-ref','d-pay-amount','d-pay-date','d-pay-method','d-pay-created','d-pay-notes','d-pay-adminnotes'];
    for (var p = 0; p < payIds.length; p++) { var pe = document.getElementById(payIds[p]); if (pe) pe.textContent = '—'; }
    var payStatusEl = document.getElementById('d-pay-status'); if (payStatusEl) payStatusEl.innerHTML = '—';
    var payChip = document.getElementById('d-pay-chip'); if (payChip) payChip.textContent = '';
    var payRec = document.getElementById('d-pay-receipt'); if (payRec) payRec.textContent = '—';
    var payAnw = document.getElementById('d-pay-adminnotes-wrap'); if (payAnw) payAnw.style.display = 'none';
    var payBody = document.getElementById('d-pay-body'); if (payBody) payBody.style.display = 'block';
    var payNone = document.getElementById('d-pay-none'); if (payNone) payNone.style.display = 'none';
    document.getElementById('oa-status-row').innerHTML = '';
}

function oaDVal(v, fallback) {
    if (v === null || v === undefined) return fallback || '—';
    var s = String(v).trim();
    return s.length > 0 ? s : (fallback || '—');
}

function populateDetail(d) {
    // ── Identity ──────────────────────────────────────────────
    setText('d-eno',         oaDVal(d.eno));
    setText('d-title',       oaDVal(d.title));
    setText('d-gender',      oaDVal(d.gender));
    setText('d-dob',         oaDVal(d.dob));
    setText('d-name',        oaDVal(d.name));
    setText('d-nationality', oaDVal(d.nationality));
    setText('d-natid',       oaDVal(d.natid));
    setText('d-religion',    oaDVal(d.religion));
    setText('d-marital',     oaDVal(d.marital));
    setText('d-disability',  oaDVal(d.disability, 'None declared'));

    // ── Programme ─────────────────────────────────────────────
    setText('d-prog',        oaDVal(d.programme));
    setText('d-spec',        oaDVal(d.specialisation, 'Not applicable'));
    setText('d-campus',      oaDVal(d.campus));
    setText('d-billing',     oaDVal(d.billing));
    setText('d-session',     oaDVal(d.session));
    setText('d-year',        oaDVal(d.entry_year));
    setText('d-intake',      oaDVal(d.intake));
    setText('d-entrymethod', oaDVal(d.entry_method));
    var admEl = document.getElementById('d-admstatus');
    if (admEl) admEl.innerHTML = statusBadge(d.status);

    // ── Education ─────────────────────────────────────────────
    setText('d-oschool', oaDVal(d.olevel_school));
    setText('d-oidx',    oaDVal(d.olevel_index));
    setText('d-oyr',     oaDVal(d.olevel_year));
    setText('d-oagg',    oaDVal(d.olevel_agg));
    setText('d-aschool', oaDVal(d.alevel_school));
    setText('d-aidx',    oaDVal(d.alevel_index));
    setText('d-ayr',     oaDVal(d.alevel_year));
    setText('d-apts',    oaDVal(d.alevel_points));
    setText('d-oinst',   oaDVal(d.other_inst));
    setText('d-oqual',   oaDVal(d.other_qual));
    setText('d-oqyr',    oaDVal(d.other_year));
    setText('d-oqgr',    oaDVal(d.other_grade));

    // ── Contact ───────────────────────────────────────────────
    setText('d-phone',    oaDVal(d.phone));
    setText('d-email',    oaDVal(d.email));
    setText('d-district', oaDVal(d.district));
    setText('d-country',  oaDVal(d.country));
    setText('d-address',  oaDVal(d.address));
    setText('d-pobox',    oaDVal(d.pobox));

    // ── Sponsor / Kin / Referee / Emergency ───────────────────
    setText('d-sponsor',  oaDVal(d.sponsor));
    setText('d-sponsorc', oaDVal(d.sponsor_contact));
    setText('d-kinname',  oaDVal(d.kin_name));
    setText('d-kinrel',   oaDVal(d.kin_relationship));
    setText('d-kincon',   oaDVal(d.kin_contacts));
    setText('d-refname',  oaDVal(d.referee_name));
    setText('d-refcon',   oaDVal(d.referee_contacts));
    setText('d-emname',   oaDVal(d.emerg_name));
    setText('d-emrel',    oaDVal(d.emerg_rel));
    setText('d-emphone',  oaDVal(d.emerg_phone));

    // ── Documents ─────────────────────────────────────────────
    oaRenderDocuments(d.docs || [], d.eno);

    // ── Proof of payment ──────────────────────────────────────
    oaRenderPayment(d.payment, d.eno);

    // ── Application record ────────────────────────────────────
    var sourceEl = document.getElementById('d-appsource');
    if (sourceEl) sourceEl.innerHTML = d.submitted_at && d.submitted_at.trim()
        ? '<span style="background:#d1fae5;color:#065f46;font-size:10px;font-weight:700;padding:2px 8px;">ONLINE PORTAL</span>'
        : '<span style="background:#f0f4fc;color:#05275C;font-size:10px;font-weight:700;padding:2px 8px;">ONLINE PORTAL</span>';
    setText('d-submitted',   oaDVal(d.submitted_at));
    setText('d-lastupdated', oaDVal(d.updated_at));

    var notes = document.getElementById('d-notes');
    if (notes) notes.value = d.reviewer_notes || '';

    // ── Status banner ─────────────────────────────────────────
    document.getElementById('oa-status-row').innerHTML =
        statusBadge(d.status) +
        '&nbsp;&nbsp;<strong>' + h(d.name) + '</strong>' +
        '&nbsp;&nbsp;|&nbsp;&nbsp;Entry:&nbsp;<strong style="font-family:monospace;">' + h(d.eno) + '</strong>' +
        (d.submitted_at ? '&nbsp;&nbsp;|&nbsp;&nbsp;Submitted:&nbsp;<strong>' + h(d.submitted_at) + '</strong>' : '') +
        (d.programme ? '&nbsp;&nbsp;|&nbsp;&nbsp;' + h(d.programme) : '');

    setText('oa-modal-title', d.name + '  —  ' + d.eno);
    buildModalActions(d);
}

// ── Document card renderer ────────────────────────────────────
var _oaDocBadgeCls = {
    PHOTO:'tp-photo', OLEVEL:'tp-olevel', ALEVEL:'tp-alevel',
    NATID:'tp-natid', PASSPORT:'tp-passport', OTHER:'tp-other'
};
var _oaDocLabels = {
    PHOTO:'Passport Photo', OLEVEL:'O-Level (UCE)', ALEVEL:'A-Level (UACE)',
    NATID:'National ID', PASSPORT:'Passport', TRANSCRIPT:'Transcript',
    BIRTH_CERTIFICATE:'Birth Cert.', RECOMMENDATION:'Recommendation',
    MEDICAL:'Medical', OTHER:'Other'
};
function oaFmtBytes(b) {
    if (!b || b < 1024) return (b || 0) + ' B';
    if (b < 1048576) return Math.round(b / 1024) + ' KB';
    return (b / 1048576).toFixed(1) + ' MB';
}
function oaRenderDocuments(docs, eno) {
    var el = document.getElementById('d-docs-list');
    var ct = document.getElementById('d-doc-count');
    if (!el) return;
    if (ct) ct.textContent = docs.length + ' file' + (docs.length !== 1 ? 's' : '');
    if (!docs.length) {
        el.innerHTML = '<div class="adm-nodocs">No documents uploaded yet.</div>';
        return;
    }
    var viewBase = 'NewStudentRegistration.aspx?ajax=view_doc&eno=' + encodeURIComponent(eno) + '&id=';
    var html = '<div class="adm-docs-grid">';
    for (var i = 0; i < docs.length; i++) {
        var doc = docs[i];
        var lbl = _oaDocLabels[doc.type] || doc.type;
        var cls = _oaDocBadgeCls[doc.type] || '';
        html += '<div class="adm-doc-card">'
              + '<span class="adm-doc-badge ' + cls + '">' + h(lbl) + '</span>'
              + '<div class="adm-doc-info">'
              + '<div class="fn" title="' + h(doc.filename) + '">' + h(doc.filename) + '</div>'
              + '<div class="fm">' + h(oaFmtBytes(doc.size)) + ' &nbsp;&middot;&nbsp; ' + h(doc.date) + '</div>'
              + '</div>'
              + '<a href="' + viewBase + doc.id + '" target="_blank" class="adm-doc-view">View</a>'
              + '</div>';
    }
    html += '</div>';
    el.innerHTML = html;
}

// ── Payment-proof renderer ────────────────────────────────────
function oaPayLabel(s) {
    s = (s || '').toUpperCase();
    return s === 'VERIFIED' ? 'Verified' : s === 'REJECTED' ? 'Rejected' : s === 'PENDING' ? 'Pending' : '—';
}
function oaPayBadge(s) {
    s = (s || '').toUpperCase();
    var cls = s === 'VERIFIED' ? 'oa-pay-badge--verified'
            : s === 'REJECTED' ? 'oa-pay-badge--rejected'
            : s === 'PENDING'  ? 'oa-pay-badge--pending'
            : 'oa-pay-badge--none';
    return '<span class="oa-pay-badge ' + cls + '">' + h(oaPayLabel(s)) + '</span>';
}
function oaRenderPayment(p, eno) {
    var none = document.getElementById('d-pay-none');
    var body = document.getElementById('d-pay-body');
    var chip = document.getElementById('d-pay-chip');
    if (!p) {
        if (none) none.style.display = 'block';
        if (body) body.style.display = 'none';
        if (chip) chip.textContent = 'None';
        return;
    }
    if (none) none.style.display = 'none';
    if (body) body.style.display = 'block';
    if (chip) chip.textContent = oaPayLabel(p.status);

    var st = document.getElementById('d-pay-status');
    if (st) st.innerHTML = oaPayBadge(p.status);
    setText('d-pay-ref',     oaDVal(p.reference));
    var amt = (p.amount && String(p.amount).trim()) ? ((p.currency ? p.currency + ' ' : '') + p.amount) : '';
    setText('d-pay-amount',  oaDVal(amt));
    setText('d-pay-date',    oaDVal(p.date));
    setText('d-pay-method',  oaDVal(p.method));
    setText('d-pay-created', oaDVal(p.created));
    setText('d-pay-notes',   oaDVal(p.notes, 'None'));

    var rec = document.getElementById('d-pay-receipt');
    if (rec) {
        if (p.has_receipt)
            rec.innerHTML = '<a href="' + _pageUrl + '?ajax=view_receipt&eno=' + encodeURIComponent(eno)
                          + '" target="_blank" class="adm-doc-view">View / Download Receipt</a>';
        else
            rec.textContent = 'Not attached';
    }
    var anw = document.getElementById('d-pay-adminnotes-wrap');
    if (p.admin_notes && p.admin_notes.trim()) { if (anw) anw.style.display = ''; setText('d-pay-adminnotes', p.admin_notes); }
    else if (anw) anw.style.display = 'none';
}

function buildModalActions(d) {
    var acts = document.getElementById('oa-modal-actions');
    acts.innerHTML = '';

    // Payment-proof actions (when a proof has been submitted)
    if (d.payment) {
        if (d.payment.status !== 'VERIFIED')
            acts.innerHTML +=
                '<button type="button" class="oa-btn oa-btn--success" onclick="verifyPayment(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
              + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>'
              + ' Verify Payment</button>';
        if (d.payment.status !== 'REJECTED')
            acts.innerHTML +=
                '<button type="button" class="oa-btn oa-btn--ghost" onclick="rejectPayment(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
              + 'Reject Payment</button>';
    }

    if (d.status === 'SUBMITTED') {
        acts.innerHTML +=
            '<button type="button" class="oa-btn oa-btn--amber" onclick="moveToReview(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + 'Mark Under Review</button>';
    }
    if (d.status === 'SUBMITTED' || d.status === 'UNDER_REVIEW') {
        acts.innerHTML +=
            '<button type="button" class="oa-btn oa-btn--danger" onclick="rejectOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
          + ' Reject</button>'
          + '<button type="button" class="oa-btn oa-btn--amber" onclick="admitOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>'
          + ' Admit</button>';
    }
    if (d.status === 'ADMITTED') {
        acts.innerHTML +=
            '<a href="AdmissionsController.aspx?q=' + encodeURIComponent(d.eno) + '" class="oa-btn oa-btn--primary" target="_blank">'
          + 'Open in Admissions Controller</a>';
    }
    // ⋮ overflow menu: Edit Application + Save Notes
    acts.innerHTML +=
        '<div class="oa-act-wrap" id="oa-act-wrap">'
      + '<button type="button" class="oa-act-trigger" onclick="toggleOaActMenu(event)" title="More actions" aria-haspopup="true">&#8942;</button>'
      + '<div class="oa-act-menu" id="oa-act-menu">'
      + '<button type="button" class="oa-act-menu__item oa-act-menu__item--edit" onclick="closeOaActMenu();goToOaEditForm(_currentEno);">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>Edit Application</button>'
      + '<div class="oa-act-menu__sep"></div>'
      + '<button type="button" class="oa-act-menu__item" onclick="closeOaActMenu();saveNotes();">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>Save Notes</button>'
      + '</div></div>';
}
function toggleOaActMenu(e) {
    e.stopPropagation();
    var m = document.getElementById('oa-act-menu');
    if (m) m.classList.toggle('open');
}
function closeOaActMenu() {
    var m = document.getElementById('oa-act-menu');
    if (m) m.classList.remove('open');
}
// ── Row ⋮ menu (list table) ──────────────────────────────────
window.oaToggleRowMenu = function(btn) {
    var menu = btn.parentNode.querySelector('.oa-row-menu');
    var wasOpen = menu && menu.classList.contains('open');
    oaCloseRowMenus();
    if (!wasOpen && menu) menu.classList.add('open');
};
window.oaCloseRowMenus = function() {
    document.querySelectorAll('.oa-row-menu.open').forEach(function(m) {
        m.classList.remove('open');
    });
};
window.oaOpenDetailAndEdit = function(eno) {
    openDetail(eno);
    var attempts = 0;
    var poll = setInterval(function() {
        attempts++;
        if (_currentDetail && _currentDetail.eno === eno) {
            clearInterval(poll);
            enterOaEditMode();
        }
        if (attempts > 30) clearInterval(poll);
    }, 100);
};
document.addEventListener('click', function(e) {
    closeOaActMenu();
    if (!e.target.closest('.oa-row-menu-wrap')) oaCloseRowMenus();
});


// ── Actions ──────────────────────────────────────────────────────
function moveToReview(eno, name) {
    if (!confirm('Mark ' + name + ' (' + eno + ') as Under Review?')) return;
    postAction('review', eno, {}, function () {
        showToast('✓ ' + name + ' moved to Under Review.', true);
        setTimeout(function () { window.location.reload(); }, 1200);
    });
}

function admitOne(eno, name) {
    if (!confirm('Admit ' + name + ' (' + eno + ')?\n\nThis will mark the application as ADMITTED and also update the admissions record.')) return;
    postAction('admit', eno, {}, function () {
        showToast('✓ ' + name + ' admitted successfully.', true);
        setTimeout(function () { window.location.reload(); }, 1200);
    });
}

function rejectOne(eno, name) {
    var reason = prompt('Reason for rejecting the application of ' + name + ':');
    if (reason === null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    postAction('reject', eno, { reason: reason }, function () {
        showToast('✓ Application rejected.', true);
        setTimeout(function () { window.location.reload(); }, 1200);
    });
}

function verifyPayment(eno, name) {
    if (!confirm('Confirm the application-fee payment for ' + name + ' (' + eno + ') as VERIFIED?')) return;
    postAction('pay_verify', eno, {}, function () {
        showToast('✓ Payment verified.', true);
        setTimeout(function () { window.location.reload(); }, 1000);
    });
}

function rejectPayment(eno, name) {
    var reason = prompt('Reason for rejecting the payment proof of ' + name + ':');
    if (reason === null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    postAction('pay_reject', eno, { reason: reason }, function () {
        showToast('✓ Payment proof rejected.', true);
        setTimeout(function () { window.location.reload(); }, 1000);
    });
}

function saveNotes() {
    if (!_currentEno) return;
    var notesEl = document.getElementById('d-notes');
    var notes = notesEl ? notesEl.value || '' : '';
    postAction('note', _currentEno, { notes: notes }, function () {
        showToast('✓ Notes saved.', true);
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
    .then(function (r) {
        if (r.status === 403) {
            showToast('✗ Session expired — please reload the page.', false);
            return null;
        }
        return r.json();
    })
    .then(function (d) {
        if (!d) return;
        if (!d.ok) { showToast('✗ ' + (d.error === 'session_expired' ? 'Session expired — reload the page.' : (d.error || 'Action failed.')), false); if (onErr) onErr(d.error); return; }
        if (onOk) onOk(d);
    })
    .catch(function (e) {
        showToast('✗ Network error — check your connection.', false);
        if (onErr) onErr(e);
    });
}

// ── Status badge (used in modal status row) ───────────────────────
function statusBadge(s) {
    var map = {
        DRAFT:        'oa-badge--draft',
        SUBMITTED:    'oa-badge--submitted',
        UNDER_REVIEW: 'oa-badge--under_review',
        ADMITTED:     'oa-badge--admitted',
        REJECTED:     'oa-badge--rejected',
        WITHDRAWN:    'oa-badge--withdrawn'
    };
    var label = (s === 'UNDER_REVIEW') ? 'Under Review' : (s || '—');
    return '<span class="oa-badge ' + (map[s] || '') + '">' + h(label) + '</span>';
}

// ── Tabs removed — these stubs prevent any existing call-sites from erroring ──
function switchTab(btn, panelId) { /* tabs replaced with sections */ }
function switchTabById(panelId) {
    void 0; // no-op
    var panel = document.getElementById(panelId);
    if (panel) panel.classList.add('active');
    else if (panels.length) panels[0].classList.add('active');
}

// ── Helpers ──────────────────────────────────────────────────────
function showToast(msg, ok) {
    var t = document.getElementById('oa-toast');
    t.textContent = msg;
    t.className   = 'oa-toast show ' + (ok ? 'oa-toast--ok' : 'oa-toast--err');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function () { t.className = 'oa-toast'; }, 5000);
}
function setText(id, val) {
    var el = document.getElementById(id);
    if (el) el.textContent = (val !== null && val !== undefined && String(val).length) ? val : '—';
}
function fmtN(n) { return (parseInt(n, 10) || 0).toLocaleString(); }
function h(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function escJ(s) { return String(s || '').replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }
</script>

</asp:Content>
