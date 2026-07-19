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
.admc-stat--draft{--sc:#94a3b8;}
a.admc-stat{text-decoration:none;cursor:pointer;transition:box-shadow .12s,transform .12s,border-color .12s;}
a.admc-stat:hover{box-shadow:0 3px 10px rgba(5,39,92,.14);transform:translateY(-1px);border-color:var(--sc,#ccc);}
a.admc-stat.admc-stat--active{border-color:var(--sc,#333);box-shadow:inset 0 0 0 1px var(--sc,#333);}
.admc-stat__sub{font-size:9.5px;color:#94a3b8;font-weight:600;margin-top:3px;}
/* searchable dropdown (enhances long native selects) */
.admc-combo{position:relative;display:inline-block;min-width:130px;}
.admc-combo__inp{width:100%;box-sizing:border-box;}
.admc-combo__list{position:absolute;top:100%;left:0;z-index:9000;background:#fff;border:1px solid #cfd8e3;max-height:260px;overflow:auto;display:none;box-shadow:0 6px 18px rgba(0,0,0,.13);min-width:240px;}
.admc-combo__list.on{display:block;}
.admc-combo__i{padding:7px 10px;font-size:12px;cursor:pointer;border-bottom:1px solid #f0f2f5;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.admc-combo__i:hover{background:#eef4ff;} .admc-combo__i--none{color:#9ca3af;cursor:default;}

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
.admc-table td{padding:8px 12px;border-bottom:1px solid #f0f2f5;color:#222;vertical-align:middle;overflow:visible;}
.admc-table tr:hover td{background:#f5f9ff;}
.admc-name{font-weight:600;color:#05275C;text-decoration:none;}
a.admc-name:hover{color:#174DA4;text-decoration:underline;}
.admc-eno{font-family:monospace;font-size:11px;color:#555;font-weight:600;}
.admc-actions-cell{display:flex;gap:4px;flex-wrap:nowrap;position:relative;}
/* ── Row ⋮ menu ──────────────────────────────────────────── */
.admc-row-menu-wrap{position:relative;display:inline-flex;}
.admc-row-trigger{display:inline-flex;align-items:center;justify-content:center;width:28px;height:26px;border:1px solid #d2dae6;background:#fff;color:#555;cursor:pointer;font-size:15px;line-height:1;padding:0;border-radius:5px;flex-shrink:0;}
.admc-row-trigger:hover{background:#f0f4fc;border-color:#174DA4;color:#174DA4;}
.admc-row-menu{display:none;position:absolute;right:0;top:calc(100% + 3px);min-width:186px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 8px 28px rgba(0,0,0,.15);padding:5px;z-index:9100;}
.admc-row-menu.open{display:block;}
.admc-row-menu__item{display:flex;align-items:center;gap:8px;width:100%;padding:8px 12px;border:0;background:transparent;color:#1e293b;font-size:11px;font-weight:600;text-align:left;border-radius:5px;cursor:pointer;white-space:nowrap;font-family:inherit;text-decoration:none;}
.admc-row-menu__item:hover{background:#f0f4fc;color:#05275C;text-decoration:none;}
.admc-row-menu__item--success:hover{background:#f0fdf4;color:#166534;}
.admc-row-menu__item--danger:hover{background:#fef2f2;color:#b91c1c;}
.admc-row-menu__item--edit{color:#174DA4;}.admc-row-menu__item--edit:hover{background:#eef5ff;color:#0c3580;}
.admc-row-menu__sep{height:1px;background:#edf2f7;margin:4px 2px;}

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
.admc-modal{background:#fff;width:920px;max-width:96vw;border-radius:0;box-shadow:0 20px 60px rgba(0,0,0,.25);max-height:90vh;display:flex;flex-direction:column;}
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
.admc-modal__foot-right{display:flex;gap:8px;flex-wrap:wrap;align-items:center;}
/* ── Detail view sections ───────────────────────────────────── */
.adm-detail-wrap{padding:0;}
.adm-section{padding:14px 20px 12px;border-bottom:1px solid #eef0f4;}
.adm-section:last-child{border-bottom:none;margin-bottom:0;}
.adm-section-hdr{display:flex;align-items:center;gap:7px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#174DA4;border-left:3px solid #174DA4;padding-left:8px;margin-bottom:12px;line-height:1.3;}
.adm-section-hdr svg{flex-shrink:0;opacity:.8;}
/* Grids */
.adm-g4{display:grid;grid-template-columns:repeat(4,1fr);gap:10px 14px;}
.adm-g3{display:grid;grid-template-columns:repeat(3,1fr);gap:10px 14px;}
.adm-g2{display:grid;grid-template-columns:1fr 1fr;gap:10px 14px;}
.adm-s2{grid-column:span 2;}.adm-s3{grid-column:span 3;}.adm-s4{grid-column:span 4;}
/* Fields */
.adm-f label{display:block;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#999;font-weight:700;margin-bottom:3px;}
.adm-fv{font-size:12px;color:#1a1a2e;font-weight:600;word-break:break-word;line-height:1.45;}
.adm-fv.lt{font-weight:400;color:#333;}
.adm-fv.mo{font-family:monospace;font-size:11px;letter-spacing:.3px;}
.adm-fv.na{color:#bbb;font-weight:400;font-style:italic;}
/* Education sub-blocks */
.adm-edu-blk{background:#fafbfd;border:1px solid #eaecf2;padding:10px 12px;margin-bottom:8px;}
.adm-edu-blk:last-child{margin-bottom:0;}
.adm-edu-blk-ttl{font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;margin-bottom:8px;}
/* Document cards */
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
/* Status banner */
.adm-banner{padding:10px 20px;background:#f0f4fc;border-bottom:1px solid #dde3ef;display:flex;align-items:center;gap:12px;flex-wrap:wrap;font-size:12px;}
.adm-banner strong{color:#05275C;}
/* ── Footer overflow / actions menu ──────────────────────── */
.admc-act-wrap{position:relative;display:inline-flex;}
.admc-act-trigger{display:inline-flex;align-items:center;justify-content:center;width:32px;height:32px;border:1px solid #d2dae6;background:#fff;color:#374151;border-radius:6px;cursor:pointer;font-size:18px;line-height:1;padding:0;}
.admc-act-trigger:hover{background:#f4f8ff;border-color:#174DA4;color:#174DA4;}
.admc-act-menu{display:none;position:absolute;bottom:calc(100% + 6px);right:0;min-width:200px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 8px 28px rgba(0,0,0,.15);padding:5px;z-index:9200;}
.admc-act-menu.open{display:block;}
.admc-act-menu__item{display:flex;align-items:center;gap:9px;width:100%;padding:9px 12px;border:0;background:transparent;color:#1e293b;font-size:12px;font-weight:600;text-align:left;border-radius:5px;cursor:pointer;white-space:nowrap;font-family:inherit;}
.admc-act-menu__item:hover{background:#f0f4fc;color:#05275C;}
.admc-act-menu__item--danger:hover{background:#fef2f2;color:#b91c1c;}
.admc-act-menu__sep{height:1px;background:#edf2f7;margin:4px 2px;}
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
    .adm-g4{grid-template-columns:1fr 1fr;}
    .adm-g3{grid-template-columns:1fr 1fr;}
    .adm-s3,.adm-s4{grid-column:span 2;}
    .adm-doc-card{max-width:100%;}
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
            <h3 id="admc-modal-title">Application Details</h3>
            <button type="button" class="admc-modal__close" onclick="closeModal()">&times;</button>
        </div>
        <div class="admc-modal__body">

            <!-- Status banner -->
            <div class="adm-banner" id="admc-status-row"></div>

            <div class="adm-detail-wrap">

            <!-- ── 1. IDENTITY & PERSONAL INFORMATION ─────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    Identity &amp; Personal Information
                </div>
                <div class="adm-g4">
                    <div class="adm-f"><label>Entry No</label><div class="adm-fv mo" id="d-eno">—</div></div>
                    <div class="adm-f"><label>Reg No</label><div class="adm-fv mo" id="d-regno">—</div></div>
                    <div class="adm-f"><label>Title / Salutation</label><div class="adm-fv lt" id="d-title">—</div></div>
                    <div class="adm-f"><label>Sex</label><div class="adm-fv lt" id="d-sex">—</div></div>

                    <div class="adm-f adm-s2"><label>Full Name</label><div class="adm-fv" id="d-name">—</div></div>
                    <div class="adm-f"><label>Date of Birth</label><div class="adm-fv lt" id="d-dob">—</div></div>
                    <div class="adm-f"><label>Nationality</label><div class="adm-fv lt" id="d-nationality">—</div></div>

                    <div class="adm-f"><label>Religion</label><div class="adm-fv lt" id="d-religion">—</div></div>
                    <div class="adm-f"><label>Marital Status</label><div class="adm-fv lt" id="d-marital">—</div></div>
                    <div class="adm-f"><label>National ID / NIN</label><div class="adm-fv mo lt" id="d-natid">—</div></div>
                    <div class="adm-f"><label>Physical Disability</label><div class="adm-fv lt" id="d-disability">—</div></div>
                </div>
            </div>

            <!-- ── 2. ACADEMIC ADMISSION ──────────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                    Academic Admission
                </div>
                <div class="adm-g4">
                    <div class="adm-f adm-s3"><label>Programme</label><div class="adm-fv" id="d-prog">—</div></div>
                    <div class="adm-f"><label>Admission Status</label><div class="adm-fv" id="d-admstatus">—</div></div>

                    <div class="adm-f adm-s2"><label>Specialisation / Major</label><div class="adm-fv lt" id="d-spec">—</div></div>
                    <div class="adm-f"><label>Campus</label><div class="adm-fv lt" id="d-campus">—</div></div>
                    <div class="adm-f"><label>Billing System</label><div class="adm-fv lt" id="d-billing">—</div></div>

                    <div class="adm-f"><label>Study Session</label><div class="adm-fv lt" id="d-session">—</div></div>
                    <div class="adm-f"><label>Entry Year</label><div class="adm-fv lt" id="d-year">—</div></div>
                    <div class="adm-f"><label>Intake</label><div class="adm-fv lt" id="d-intake">—</div></div>
                    <div class="adm-f"><label>Entry Method</label><div class="adm-fv lt" id="d-method">—</div></div>
                </div>
            </div>

            <!-- ── 3. EDUCATION BACKGROUND ────────────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                    Education Background
                </div>

                <!-- O-Level / UCE -->
                <div class="adm-edu-blk">
                    <div class="adm-edu-blk-ttl">O&#8209;Level &nbsp;/&nbsp; UCE</div>
                    <div class="adm-g4">
                        <div class="adm-f adm-s2"><label>School / Institution</label><div class="adm-fv lt" id="d-oschool">—</div></div>
                        <div class="adm-f"><label>Index / Exam No.</label><div class="adm-fv mo lt" id="d-oidx">—</div></div>
                        <div class="adm-f"><label>Year of Completion</label><div class="adm-fv lt" id="d-olyr">—</div></div>
                        <div class="adm-f"><label>Aggregate Points</label><div class="adm-fv lt" id="d-olagg">—</div></div>
                    </div>
                </div>

                <!-- A-Level / UACE -->
                <div class="adm-edu-blk">
                    <div class="adm-edu-blk-ttl">A&#8209;Level &nbsp;/&nbsp; UACE</div>
                    <div class="adm-g4">
                        <div class="adm-f adm-s2"><label>School / Institution</label><div class="adm-fv lt" id="d-aschool">—</div></div>
                        <div class="adm-f"><label>Index / Exam No.</label><div class="adm-fv mo lt" id="d-aidx">—</div></div>
                        <div class="adm-f"><label>Year of Completion</label><div class="adm-fv lt" id="d-alyr">—</div></div>
                        <div class="adm-f"><label>Points / Passes</label><div class="adm-fv lt" id="d-alpts">—</div></div>
                    </div>
                </div>

                <!-- Other Qualification -->
                <div class="adm-edu-blk" id="d-edu-other-blk">
                    <div class="adm-edu-blk-ttl">Other Qualification &nbsp;<span style="font-weight:400;text-transform:none;color:#aaa;font-size:9px;">(Diploma / Degree / Certificate)</span></div>
                    <div class="adm-g4">
                        <div class="adm-f adm-s2"><label>Institution</label><div class="adm-fv lt" id="d-othinst">—</div></div>
                        <div class="adm-f"><label>Qualification / Award</label><div class="adm-fv lt" id="d-othqual">—</div></div>
                        <div class="adm-f"><label>Year of Completion</label><div class="adm-fv lt" id="d-othyr">—</div></div>
                        <div class="adm-f"><label>Grade / Class</label><div class="adm-fv lt" id="d-othgr">—</div></div>
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

            <!-- ── 5. SPONSOR, NEXT OF KIN & REFEREE ─────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    Sponsor, Next of Kin &amp; Referee
                </div>
                <div class="adm-g4">
                    <!-- Sponsor -->
                    <div class="adm-f adm-s2"><label>Sponsor Name</label><div class="adm-fv lt" id="d-sponsor">—</div></div>
                    <div class="adm-f adm-s2"><label>Sponsor Contact</label><div class="adm-fv lt" id="d-sponsorc">—</div></div>
                    <!-- Next of Kin -->
                    <div class="adm-f adm-s2"><label>Next of Kin Name</label><div class="adm-fv lt" id="d-kin">—</div></div>
                    <div class="adm-f"><label>Relationship</label><div class="adm-fv lt" id="d-kinrel">—</div></div>
                    <div class="adm-f"><label>Kin Contact</label><div class="adm-fv lt" id="d-kinc">—</div></div>
                    <!-- Referee -->
                    <div class="adm-f adm-s2"><label>Referee Name</label><div class="adm-fv lt" id="d-refname">—</div></div>
                    <div class="adm-f adm-s2"><label>Referee Contact</label><div class="adm-fv lt" id="d-refcon">—</div></div>
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

            <!-- ── 7. APPLICATION RECORD & NOTES ──────────────────────── -->
            <div class="adm-section">
                <div class="adm-section-hdr">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    Application Record
                </div>
                <div class="adm-g4" style="margin-bottom:12px;">
                    <div class="adm-f"><label>Application Source</label><div class="adm-fv" id="d-source">—</div></div>
                    <div class="adm-f"><label>Submitted At</label><div class="adm-fv lt" id="d-submitted">—</div></div>
                    <div class="adm-f"><label>Last Updated</label><div class="adm-fv lt" id="d-lastupdated">—</div></div>
                    <div class="adm-f"><label>Reviewer / Processor</label><div class="adm-fv lt" id="d-processor" style="display:none;">—</div></div>
                </div>
                <label style="display:block;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#999;font-weight:700;margin-bottom:5px;">Internal Reviewer Notes</label>
                <textarea id="d-notes" placeholder="Add internal notes about this application…" style="width:100%;min-height:80px;border:1px solid #d0d7e6;padding:9px 10px;font:inherit;font-size:12px;resize:vertical;box-sizing:border-box;background:#fafbfc;"></textarea>
            </div>

            </div><!-- /adm-detail-wrap -->
        </div><!-- /admc-modal__body -->

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
// Navigate to centralised edit form for this entry number
window.goToEditForm = function(eno) {
    if (!eno) return;
    window.location.href = 'NewStudentRegistration.aspx?eno=' + encodeURIComponent(eno) + '&returnUrl=' + encodeURIComponent('AdmissionsController.aspx');
};

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
    var ids = [
        'd-eno','d-regno','d-title','d-sex','d-name','d-dob','d-nationality',
        'd-religion','d-marital','d-natid','d-disability',
        'd-prog','d-spec','d-campus','d-billing',
        'd-session','d-year','d-intake','d-method',
        'd-oschool','d-oidx','d-olyr','d-olagg',
        'd-aschool','d-aidx','d-alyr','d-alpts',
        'd-othinst','d-othqual','d-othyr','d-othgr',
        'd-phone','d-email','d-district','d-country','d-address','d-pobox',
        'd-sponsor','d-sponsorc','d-kin','d-kinrel','d-kinc',
        'd-refname','d-refcon',
        'd-source','d-submitted','d-lastupdated'
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
    document.getElementById('admc-status-row').innerHTML = '';
}

// Returns '—' for blank/missing values; optionally uses a custom fallback string
function dVal(v, fallback) {
    if (v === null || v === undefined) return fallback || '—';
    var s = String(v).trim();
    return s.length > 0 ? s : (fallback || '—');
}

function populateDetail(d) {
    // ── Identity ─────────────────────────────────────────────
    setText('d-eno',         dVal(d.eno));
    setText('d-regno',       d.regno && d.regno !== '-' ? d.regno : 'Not yet assigned');
    setText('d-title',       dVal(d.title));
    setText('d-sex',         dVal(d.sex));
    setText('d-name',        dVal(d.name));
    setText('d-dob',         dVal(d.dob));
    setText('d-nationality', dVal(d.nationality));
    setText('d-religion',    dVal(d.religion));
    setText('d-marital',     dVal(d.marital));
    setText('d-natid',       dVal(d.national_id));
    setText('d-disability',  dVal(d.disability, 'None declared'));

    // ── Admission ─────────────────────────────────────────────
    setText('d-prog',    dVal(d.programme));
    setText('d-spec',    dVal(d.specialisation, 'Not applicable'));
    setText('d-campus',  dVal(d.campus));
    setText('d-billing', dVal(d.billing));
    setText('d-session', dVal(d.session));
    setText('d-year',    dVal(d.entry_year));
    setText('d-intake',  dVal(d.intake));
    setText('d-method',  dVal(d.entry_method));
    var admEl = document.getElementById('d-admstatus');
    if (admEl) admEl.innerHTML = statusBadge(d.status);

    // ── Education ─────────────────────────────────────────────
    setText('d-oschool', dVal(d.olevel_school));
    setText('d-oidx',    dVal(d.olevel_index));
    setText('d-olyr',    dVal(d.olevel_year));
    setText('d-olagg',   dVal(d.olevel_agg));
    setText('d-aschool', dVal(d.alevel_school));
    setText('d-aidx',    dVal(d.alevel_index));
    setText('d-alyr',    dVal(d.alevel_year));
    setText('d-alpts',   dVal(d.alevel_points));
    setText('d-othinst', dVal(d.other_inst));
    setText('d-othqual', dVal(d.other_qual));
    setText('d-othyr',   dVal(d.other_year));
    setText('d-othgr',   dVal(d.other_grade));

    // ── Contact ───────────────────────────────────────────────
    setText('d-phone',    dVal(d.phone));
    setText('d-email',    dVal(d.email));
    setText('d-district', dVal(d.district));
    setText('d-country',  dVal(d.country));
    setText('d-address',  dVal(d.address));
    setText('d-pobox',    dVal(d.pobox));

    // ── Sponsor / Kin / Referee ───────────────────────────────
    setText('d-sponsor',  dVal(d.sponsor));
    setText('d-sponsorc', dVal(d.sponsor_contact));
    setText('d-kin',      dVal(d.kin_name));
    setText('d-kinrel',   dVal(d.kin_relationship));
    setText('d-kinc',     dVal(d.kin_contacts));
    setText('d-refname',  dVal(d.referee_name));
    setText('d-refcon',   dVal(d.referee_contacts));

    // ── Documents ─────────────────────────────────────────────
    renderDocuments(d.docs || [], d.eno);

    // ── Application record ────────────────────────────────────
    var isOnline = d.submitted_at && d.submitted_at.trim().length > 0;
    var sourceEl = document.getElementById('d-source');
    if (sourceEl) sourceEl.innerHTML = isOnline
        ? '<span style="background:#d1fae5;color:#065f46;font-size:10px;font-weight:700;padding:2px 8px;">ONLINE PORTAL</span>'
        : '<span style="background:#f0f4fc;color:#05275C;font-size:10px;font-weight:700;padding:2px 8px;">WALK-IN / DIRECT</span>';
    setText('d-submitted',   dVal(d.submitted_at));
    setText('d-lastupdated', dVal(d.last_updated));

    var notes = document.getElementById('d-notes');
    if (notes) notes.value = d.reviewer_notes || '';

    // ── Status banner ─────────────────────────────────────────
    document.getElementById('admc-status-row').innerHTML =
        statusBadge(d.status) +
        '&nbsp;&nbsp;<strong>' + h(d.name) + '</strong>' +
        '&nbsp;&nbsp;|&nbsp;&nbsp;Entry:&nbsp;<strong style="font-family:monospace;">' + h(d.eno) + '</strong>' +
        (d.regno && d.regno !== '-'
            ? '&nbsp;&nbsp;|&nbsp;&nbsp;Reg:&nbsp;<strong style="font-family:monospace;">' + h(d.regno) + '</strong>'
            : '') +
        (d.programme ? '&nbsp;&nbsp;|&nbsp;&nbsp;' + h(d.programme) : '');

    setText('admc-modal-title', d.name + '  —  ' + d.eno);
    buildModalActions(d);
}

// ── Document card renderer ────────────────────────────────────
var _docBadgeCls = {
    PHOTO:'tp-photo', OLEVEL:'tp-olevel', ALEVEL:'tp-alevel',
    NATID:'tp-natid', PASSPORT:'tp-passport', OTHER:'tp-other'
};
var _docLabels = {
    PHOTO:'Passport Photo', OLEVEL:'O-Level (UCE)', ALEVEL:'A-Level (UACE)',
    NATID:'National ID', PASSPORT:'Passport', TRANSCRIPT:'Transcript',
    BIRTH_CERTIFICATE:'Birth Cert.', RECOMMENDATION:'Recommendation',
    MEDICAL:'Medical', OTHER:'Other'
};
function fmtBytes(b) {
    if (!b || b < 1024) return (b || 0) + ' B';
    if (b < 1048576) return Math.round(b / 1024) + ' KB';
    return (b / 1048576).toFixed(1) + ' MB';
}
function renderDocuments(docs, eno) {
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
        var lbl = _docLabels[doc.type] || doc.type;
        var cls = _docBadgeCls[doc.type] || '';
        html += '<div class="adm-doc-card">'
              + '<span class="adm-doc-badge ' + cls + '">' + h(lbl) + '</span>'
              + '<div class="adm-doc-info">'
              + '<div class="fn" title="' + h(doc.filename) + '">' + h(doc.filename) + '</div>'
              + '<div class="fm">' + h(fmtBytes(doc.size)) + ' &nbsp;&middot;&nbsp; ' + h(doc.date) + '</div>'
              + '</div>'
              + '<a href="' + viewBase + doc.id + '" target="_blank" class="adm-doc-view">View</a>'
              + '</div>';
    }
    html += '</div>';
    el.innerHTML = html;
}

function buildModalActions(d) {
    var acts = document.getElementById('admc-modal-actions');
    acts.innerHTML = '';

    // Edit Application — always a main visible button; navigates to centralized form
    acts.innerHTML +=
        '<a href="NewStudentRegistration.aspx?eno=' + encodeURIComponent(d.eno) + '&returnUrl=' + encodeURIComponent('AdmissionsController.aspx') + '" class="admc-btn admc-btn--ghost">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:-1px;margin-right:3px;"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>Edit Application</a>';

    // Primary status-driven action buttons
    if (d.status === 'PENDING') {
        acts.innerHTML +=
            '<button type="button" class="admc-btn admc-btn--danger" onclick="rejectOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="vertical-align:-1px;margin-right:3px;"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>Reject</button>'
          + '<button type="button" class="admc-btn admc-btn--success" onclick="admitOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="vertical-align:-1px;margin-right:3px;"><polyline points="20 6 9 17 4 12"/></svg>Admit</button>';
    }
    if (d.status === 'ADMITTED') {
        acts.innerHTML +=
            '<button type="button" class="admc-btn admc-btn--amber" onclick="rejectOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">Withdraw</button>'
          + '<button type="button" class="admc-btn admc-btn--primary" id="btn-reg-modal" onclick="registerOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="vertical-align:-1px;margin-right:3px;"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><polyline points="17 11 19 13 23 9"/></svg>Register</button>';
    }
    if (d.status === 'REGISTERED' && d.regno && d.regno !== '-') {
        acts.innerHTML +=
            '<button type="button" class="admc-btn admc-btn--amber" id="btn-rereg-modal" onclick="reregisterOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">Re-register / Fix</button>'
          + '<a href="StudentProfile.aspx?regno=' + encodeURIComponent(d.regno) + '" class="admc-btn admc-btn--primary" target="_blank">View Profile</a>';
    }

    // Admission Letter button — for ADMITTED and REGISTERED
    if (d.status === 'ADMITTED' || d.status === 'REGISTERED') {
        var letterType = d.status === 'REGISTERED' ? 'official' : 'provisional';
        var letterLabel = d.status === 'REGISTERED' ? 'Official Letter' : 'Provisional Letter';
        acts.innerHTML +=
            '<a href="AdmissionLetter.aspx?eno=' + encodeURIComponent(d.eno) + '&type=' + letterType + '" target="_blank" class="admc-btn admc-btn--ghost" title="Open admission letter in new tab" style="border-color:#05275C;color:#05275C;">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:-1px;margin-right:3px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>'
          + h(letterLabel) + '</a>';
    }

    // ⋮ overflow: Save Notes + Delete
    var isReg = d.status === 'REGISTERED' && d.regno && d.regno !== '-';
    acts.innerHTML +=
        '<div class="admc-act-wrap" id="admc-act-wrap">'
      + '<button type="button" class="admc-act-trigger" onclick="toggleActMenu(event)" title="More actions" aria-haspopup="true">&#8942;</button>'
      + '<div class="admc-act-menu" id="admc-act-menu">'
      + '<button type="button" class="admc-act-menu__item" onclick="closeActMenu();saveNotes();">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>Save Notes</button>'
      + '<div class="admc-act-menu__sep"></div>'
      + '<button type="button" class="admc-act-menu__item admc-act-menu__item--danger" onclick="closeActMenu();deleteOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\',' + isReg + ');">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>Delete Application</button>'
      + '</div></div>';
}
function toggleActMenu(e) {
    e.stopPropagation();
    var m = document.getElementById('admc-act-menu');
    if (m) m.classList.toggle('open');
}
function closeActMenu() {
    var m = document.getElementById('admc-act-menu');
    if (m) m.classList.remove('open');
}
// ── Row ⋮ menu (list table) ──────────────────────────────────
window.toggleRowMenu = function(btn) {
    var menu = btn.parentNode.querySelector('.admc-row-menu');
    var wasOpen = menu && menu.classList.contains('open');
    closeRowMenus();
    if (!wasOpen && menu) menu.classList.add('open');
};
window.closeRowMenus = function() {
    document.querySelectorAll('.admc-row-menu.open').forEach(function(m) {
        m.classList.remove('open');
    });
};
document.addEventListener('click', function(e) {
    closeActMenu();
    if (!e.target.closest('.admc-row-menu-wrap')) closeRowMenus();
});


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

function deleteOne(eno, name, isRegistered) {
    if (isRegistered) {
        var typed = prompt(
            'WARNING — PERMANENT DELETE\n\n' +
            'This will delete the fully-registered student:\n' +
            '  ' + name + '  (' + eno + ')\n\n' +
            'ALL records will be removed: student file, registration,\n' +
            'application data and portal account.\n\n' +
            'Type  DELETE  to confirm (case-insensitive):'
        );
        if (typed === null) return;
        if (typed.trim().toUpperCase() !== 'DELETE') {
            if (typed.trim().length > 0) alert('Deletion cancelled — confirmation text did not match.');
            return;
        }
    } else {
        if (!confirm('Delete application for ' + name + ' (' + eno + ')?\n\nThis permanently removes the application and cannot be undone.')) return;
    }
    postAction('delete', eno, {}, function(d) {
        showToast('✓ Application for ' + name + ' deleted.', true);
        closeModal();
        setTimeout(function() { window.location.reload(); }, 800);
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

// ════════════════════════════════════════════════════════════════════
// SEARCHABLE DROPDOWN — enhances long native <select>s in place
// ════════════════════════════════════════════════════════════════════
function enhanceSelect(sel){
    if(!sel || sel._enh) return; sel._enh = true;
    var opts=[]; for(var i=0;i<sel.options.length;i++) opts.push({v:sel.options[i].value,t:sel.options[i].text});
    var wrap=document.createElement('div'); wrap.className='admc-combo';
    if(sel.style.maxWidth) wrap.style.maxWidth=sel.style.maxWidth;
    sel.parentNode.insertBefore(wrap, sel); wrap.appendChild(sel); sel.style.display='none';
    var inp=document.createElement('input'); inp.type='text'; inp.className='admc-combo__inp admc-select'; inp.autocomplete='off';
    inp.placeholder=opts[0]?opts[0].t:'Search…';
    var list=document.createElement('div'); list.className='admc-combo__list';
    wrap.appendChild(inp); wrap.appendChild(list);
    var cur=opts.filter(function(o){return String(o.v)===String(sel.value);})[0]; if(cur&&cur.v) inp.value=cur.t;
    function draw(f){ f=(f||'').toLowerCase();
        var m=opts.filter(function(o){ return !f || o.t.toLowerCase().indexOf(f)>=0; });
        if(!m.length){ list.innerHTML='<div class="admc-combo__i admc-combo__i--none">No match</div>'; return; }
        list.innerHTML=m.slice(0,150).map(function(o){ return '<div class="admc-combo__i" data-v="'+h(o.v)+'">'+h(o.t)+'</div>'; }).join('');
        [].forEach.call(list.querySelectorAll('.admc-combo__i[data-v]'),function(el){ el.onmousedown=function(e){ e.preventDefault(); sel.value=el.getAttribute('data-v'); inp.value=el.textContent; list.classList.remove('on'); }; });
    }
    inp.addEventListener('focus',function(){ draw(''); list.classList.add('on'); });
    inp.addEventListener('input',function(){ sel.value=''; draw(inp.value); list.classList.add('on'); });
    inp.addEventListener('keydown',function(e){ if(e.key==='Enter'){ e.preventDefault(); var f=list.querySelector('.admc-combo__i[data-v]'); if(f){ sel.value=f.getAttribute('data-v'); inp.value=f.textContent; } list.classList.remove('on'); applyFilters(); } });
    inp.addEventListener('blur',function(){ setTimeout(function(){ list.classList.remove('on'); },160); });
}
(function(){ enhanceSelect(document.getElementById('admc-prog')); enhanceSelect(document.getElementById('admc-year')); })();
</script>

</asp:Content>
