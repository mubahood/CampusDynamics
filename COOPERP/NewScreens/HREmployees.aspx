<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HREmployees.aspx.cs" Inherits="COOPERP_NewScreens_HREmployees" Title="Employee Management - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== EMPLOYEE MANAGEMENT - RESPONSIVE ===== */
*,*::before,*::after{box-sizing:border-box;}

/* ── Brand tokens ── */
:root{--brand:#174DA4;--brand-light:#e8eef8;--brand-dark:#0f3670;--success:#28a745;--danger:#dc3545;--warning:#ffc107;--info:#17a2b8;--grey:#6c757d;--grey-light:#f4f5f7;--border:#dee2e6;--radius:6px;--shadow:0 1px 3px rgba(0,0,0,.08);}

/* ── Page header ── */
.em-page-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.em-page-header__icon{width:44px;height:44px;border-radius:10px;background:var(--brand);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.em-page-header__title{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.em-page-header__sub{font-size:12px;color:#888;margin-top:1px;}
.em-page-header__actions{margin-left:auto;}

/* ── Stats bar ── */
.em-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:18px;}
.em-stat{background:#fff;border-radius:var(--radius);border:1px solid var(--border);padding:14px 16px;display:flex;align-items:center;gap:12px;transition:box-shadow .15s;cursor:pointer;}
.em-stat:hover{box-shadow:0 3px 12px rgba(0,0,0,.1);}
.em-stat__icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.em-stat--blue  .em-stat__icon{background:#e8eef8;color:var(--brand);}
.em-stat--green .em-stat__icon{background:#e6f7eb;color:var(--success);}
.em-stat--red   .em-stat__icon{background:#fdecea;color:var(--danger);}
.em-stat--amber .em-stat__icon{background:#fff8e1;color:#e67e00;}
.em-stat--grey  .em-stat__icon{background:#f0f0f0;color:var(--grey);}
.em-stat__body{min-width:0;}
.em-stat__val{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.em-stat__label{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;}

/* ── Card container ── */
.cd-card{background:#fff;border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden;}
.cd-card__header{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid #eee;flex-wrap:wrap;gap:8px;}
.cd-card__title{font-size:15px;font-weight:600;color:#1a1a1a;}
.cd-card__meta{font-size:12px;color:#999;}

/* ── Filter bar ── */
.em-filters{padding:14px 20px;background:#fafbfc;border-bottom:1px solid #eee;}
.em-filters__top{display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-bottom:10px;}
.em-search-wrap{position:relative;flex:1;min-width:200px;max-width:400px;}
.em-search-box{width:100%;padding:7px 12px 7px 34px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px;outline:none;transition:border .15s;}
.em-search-box:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(23,77,164,.12);}
.em-search-wrap::before{content:'';position:absolute;left:10px;top:50%;transform:translateY(-50%);width:16px;height:16px;background:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23999' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E") no-repeat center/contain;}
.em-filters__count{font-size:12px;color:#999;margin-left:auto;}
.em-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:center;}
.em-filter-grp{display:flex;align-items:center;gap:4px;}
.em-filter-grp__label{font-size:11px;color:#888;white-space:nowrap;}
.em-filter-select{padding:5px 8px;border:1px solid var(--border);border-radius:4px;font-size:12px;background:#fff;cursor:pointer;min-width:0;}
.em-filter-sep{width:1px;height:22px;background:#ddd;margin:0 4px;}

/* ── Buttons ── */
.hr-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 16px;border:none;border-radius:var(--radius);font-size:13px;font-weight:500;cursor:pointer;transition:all .15s;line-height:1.4;text-decoration:none;}
.hr-btn--primary{background:var(--brand);color:#fff;}.hr-btn--primary:hover{background:var(--brand-dark);}
.hr-btn--success{background:var(--success);color:#fff;}.hr-btn--success:hover{background:#218838;}
.hr-btn--danger{background:var(--danger);color:#fff;}.hr-btn--danger:hover{background:#c82333;}
.hr-btn--outline{background:#fff;color:var(--brand);border:1px solid var(--brand);}.hr-btn--outline:hover{background:var(--brand-light);}
.hr-btn--ghost{background:transparent;color:#555;border:1px solid var(--border);}.hr-btn--ghost:hover{background:#f4f4f4;}
.hr-btn--sm{padding:4px 10px;font-size:12px;}

/* ── Badges ── */
.hr-badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;line-height:1.5;white-space:nowrap;}
.hr-badge--valid{background:#d4edda;color:#155724;}
.hr-badge--expired{background:#f8d7da;color:#721c24;}
.hr-badge--terminated{background:#fff3cd;color:#856404;}
.hr-badge--resigned{background:#e2e3e5;color:#383d41;}
.hr-badge--none{background:#f0f0f0;color:#999;}
.hr-badge--academic{background:#e8eef8;color:var(--brand);}
.hr-badge--admin{background:#fff3cd;color:#856404;}

/* ── Table ── */
.em-table-wrap{overflow-x:auto;-webkit-overflow-scrolling:touch;}
.em-grid{width:100%;border-collapse:collapse;font-size:13px;}
.em-grid thead th{background:#f8f9fa;padding:10px 12px;text-align:left;font-weight:600;color:#555;font-size:11px;text-transform:uppercase;letter-spacing:.3px;white-space:nowrap;border-bottom:2px solid #dee2e6;position:sticky;top:0;z-index:1;}
.em-grid thead th.em-sortable{cursor:pointer;user-select:none;transition:color .15s;}
.em-grid thead th.em-sortable:hover{color:var(--brand);}
.em-grid thead th .em-sort-icon{display:inline-block;margin-left:4px;font-size:10px;color:#ccc;vertical-align:middle;}
.em-grid thead th.em-sorted .em-sort-icon{color:var(--brand);}
.em-grid thead th.em-sorted{color:var(--brand);}
.em-grid tbody td{padding:10px 12px;border-bottom:1px solid #f0f0f0;vertical-align:middle;color:#333;}
.em-grid tbody tr:hover{background:#f8f9fc;}
.ct-col-num{width:50px;text-align:center;color:#999;font-size:12px;}
.ct-col-pay{text-align:right;white-space:nowrap;font-weight:600;font-size:12px;}
.ct-col-actions{width:48px;text-align:center;}
.ct-empty-state{text-align:center;padding:40px 20px !important;}

/* ── Employee cell ── */
.emp-cell{display:flex;align-items:center;gap:10px;min-width:200px;}
.emp-thumb{width:36px;height:36px;border-radius:50%;object-fit:cover;flex-shrink:0;cursor:pointer;border:2px solid #eee;transition:border .15s;}
.emp-thumb:hover{border-color:var(--brand);}
.emp-info{min-width:0;}
.emp-name{font-weight:600;color:#1a1a1a;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px;font-size:13px;}
.emp-sub{font-size:11px;color:#999;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px;}
.emp-code{font-family:'Consolas','Courier New',monospace;font-size:12px;color:var(--brand);font-weight:600;background:var(--brand-light);padding:2px 8px;border-radius:4px;white-space:nowrap;}
.emp-scale{font-size:10px;color:#888;margin-top:1px;}

/* ── Pagination ── */
.em-grid-footer{display:flex;align-items:center;justify-content:space-between;padding:12px 20px;border-top:1px solid #eee;flex-wrap:wrap;gap:8px;}
.em-pager-info{font-size:12px;color:#888;}
.ct-pager{display:flex;gap:4px;align-items:center;}
.ct-pager__item{display:inline-flex;align-items:center;justify-content:center;min-width:32px;height:32px;padding:0 8px;border:1px solid var(--border);border-radius:4px;font-size:12px;color:#555;text-decoration:none;cursor:pointer;transition:all .12s;}
.ct-pager__item:hover{background:var(--brand-light);color:var(--brand);border-color:var(--brand);}
.ct-pager__item--active{background:var(--brand);color:#fff;border-color:var(--brand);font-weight:600;}
.ct-pager__item--disabled{color:#ccc;cursor:default;pointer-events:none;}
.ct-pager__ellipsis{padding:0 4px;color:#999;}

/* ── Action popover ── */
.cd-action-wrapper{position:relative;display:inline-block;}
.cd-action-trigger{background:none;border:1px solid transparent;border-radius:4px;cursor:pointer;padding:4px;color:#777;transition:all .12s;}
.cd-action-trigger:hover{background:#f0f0f0;color:#333;}
.cd-action-popover{display:none;position:absolute;right:0;top:100%;margin-top:4px;background:#fff;border:1px solid #e0e0e0;border-radius:8px;box-shadow:0 8px 24px rgba(0,0,0,.12);min-width:180px;z-index:100;overflow:hidden;}
.cd-action-popover.is-open{display:block;}
.cd-action-popover__menu{list-style:none;margin:0;padding:4px 0;}
.cd-action-popover__item{margin:0;}
.cd-action-popover__btn{display:flex;align-items:center;gap:8px;width:100%;padding:8px 14px;background:none;border:none;font-size:12.5px;color:#333;cursor:pointer;text-align:left;transition:background .1s;}
.cd-action-popover__btn:hover{background:#f5f5f5;}
.cd-action-popover__btn--view{color:var(--brand);}
.cd-action-popover__btn--edit{color:#e67e00;}
.cd-action-popover__btn--danger{color:var(--danger);}
.cd-action-popover__btn--success{color:var(--success);}
.cd-action-popover__divider{height:1px;background:#eee;margin:4px 0;}

/* ── Modal ── */
.hr-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;justify-content:center;align-items:flex-start;padding:30px 16px;overflow-y:auto;}
.hr-modal{background:#fff;border-radius:10px;box-shadow:0 20px 60px rgba(0,0,0,.2);width:100%;animation:modalSlide .2s ease-out;}
.hr-modal--lg{max-width:720px;}
.hr-modal--md{max-width:500px;}
.hr-modal--xl{max-width:960px;}
@keyframes modalSlide{from{opacity:0;transform:translateY(-20px);}to{opacity:1;transform:translateY(0);}}
.hr-modal__header{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid #eee;}
.hr-modal__header h3{margin:0;font-size:16px;font-weight:600;color:#1a1a1a;}
.hr-modal__close{background:none;border:none;font-size:22px;color:#999;cursor:pointer;padding:0 4px;line-height:1;}
.hr-modal__close:hover{color:#333;}
.hr-modal__body{padding:20px;max-height:70vh;overflow-y:auto;}
.hr-modal__footer{display:flex;align-items:center;justify-content:flex-end;gap:8px;padding:14px 20px;border-top:1px solid #eee;}
.hr-modal__section{font-size:12px;font-weight:700;color:var(--brand);text-transform:uppercase;letter-spacing:.5px;margin:18px 0 10px;padding-bottom:6px;border-bottom:1px solid #eef2f7;}
.hr-modal__section:first-child{margin-top:0;}

/* ── Form elements ── */
.hr-form-row{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:8px;}
.hr-form-row3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px;margin-bottom:8px;}
.hr-form-group{display:flex;flex-direction:column;gap:4px;margin-bottom:6px;}
.hr-form-label{font-size:12px;font-weight:600;color:#555;}
.req{color:var(--danger);margin-left:2px;}
.hr-form-input,.hr-form-select,.hr-form-textarea{padding:7px 10px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px;outline:none;transition:border .15s;width:100%;}
.hr-form-input:focus,.hr-form-select:focus,.hr-form-textarea:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(23,77,164,.12);}
.hr-form-textarea{resize:vertical;min-height:60px;font-family:inherit;}
.hr-form-hint{font-size:11px;color:#999;margin-top:1px;}

/* ── Result messages ── */
.hr-result{min-height:18px;font-size:13px;padding:4px 0;transition:all .2s;}
.hr-result--err{color:var(--danger);}
.hr-result--ok{color:var(--success);}

/* ── Supervisor autocomplete ── */
.hr-ac{position:relative;}
.hr-ac__input{width:100%;padding:7px 34px 7px 10px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px;outline:none;transition:border .15s;}
.hr-ac__input:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(23,77,164,.12);}
.hr-ac__input--selected{background:#f0faf3;border-color:var(--success);}
.hr-ac__spinner{display:none;position:absolute;right:10px;top:50%;transform:translateY(-50%);width:16px;height:16px;border:2px solid #ddd;border-top-color:var(--brand);border-radius:50%;animation:hrSpin .6s linear infinite;}
.hr-ac__spinner--visible{display:block;}
@keyframes hrSpin{to{transform:translateY(-50%) rotate(360deg);}}
.hr-ac__clear{display:none;position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;border:none;font-size:16px;color:#999;cursor:pointer;padding:0 2px;line-height:1;}
.hr-ac__clear--visible{display:block;}
.hr-ac__list{display:none;position:absolute;top:100%;left:0;right:0;background:#fff;border:1px solid #e0e0e0;border-radius:0 0 var(--radius) var(--radius);box-shadow:0 8px 24px rgba(0,0,0,.12);max-height:220px;overflow-y:auto;z-index:200;}
.hr-ac__list--visible{display:block;}
.hr-ac__item{display:flex;align-items:center;gap:10px;padding:8px 12px;cursor:pointer;transition:background .1s;}
.hr-ac__item:hover,.hr-ac__item--active{background:#f0f4ff;}
.hr-ac__avatar{width:34px;height:34px;border-radius:50%;background:var(--brand);color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;flex-shrink:0;}
.hr-ac__info{flex:1;min-width:0;}
.hr-ac__name{font-size:13px;font-weight:600;color:#1a1a1a;}
.hr-ac__meta{font-size:11px;color:#888;}
.hr-ac__code{font-size:11px;color:var(--brand);font-family:Consolas,monospace;white-space:nowrap;}
.hr-ac__empty{padding:12px;font-size:12px;color:#999;text-align:center;}
.hr-ac__hint{padding:6px 12px;font-size:10px;color:#bbb;text-align:center;border-top:1px solid #f0f0f0;}
.hr-selected-sup{display:none;margin-top:6px;background:#f0faf3;border:1px solid #c3e6cb;border-radius:var(--radius);padding:8px 12px;align-items:center;gap:10px;animation:empSlide .2s ease-out;}
.hr-selected-sup--visible{display:flex;}
@keyframes empSlide{from{opacity:0;transform:translateY(-8px);}to{opacity:1;transform:translateY(0);}}
.hr-selected-sup__avatar{width:32px;height:32px;border-radius:50%;background:var(--brand);color:#fff;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0;}
.hr-selected-sup__info{flex:1;min-width:0;}
.hr-selected-sup__name{font-size:13px;font-weight:600;color:#155724;}
.hr-selected-sup__detail{font-size:11px;color:#666;}
.hr-selected-sup__code{font-size:11px;color:var(--brand);font-family:Consolas,monospace;}
.hr-selected-sup__remove{background:none;border:none;color:#888;cursor:pointer;font-size:18px;padding:0 4px;line-height:1;}
.hr-selected-sup__remove:hover{color:var(--danger);}

/* ── Searchable select widget ── */
.cd-srch{position:relative;}
.cd-srch__input{width:100%;padding:7px 28px 7px 10px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px;outline:none;cursor:pointer;background:#fff;transition:border .15s;}
.cd-srch__input:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(23,77,164,.12);cursor:text;}
.cd-srch__input--has-value{font-weight:500;color:#1a1a1a;}
.cd-srch__arrow{position:absolute;right:8px;top:50%;transform:translateY(-50%);color:#999;font-size:10px;pointer-events:none;}
.cd-srch__panel{display:none;position:absolute;top:100%;left:0;right:0;background:#fff;border:1px solid #e0e0e0;border-radius:0 0 var(--radius) var(--radius);box-shadow:0 6px 20px rgba(0,0,0,.1);max-height:200px;overflow-y:auto;z-index:200;}
.cd-srch__panel--open{display:block;}
.cd-srch__opt{padding:7px 12px;font-size:13px;cursor:pointer;transition:background .08s;}
.cd-srch__opt:hover,.cd-srch__opt--active{background:#f0f4ff;}
.cd-srch__opt--selected{font-weight:600;color:var(--brand);}
.cd-srch__empty{padding:10px 12px;font-size:12px;color:#999;text-align:center;}

/* ── Lightbox ── */
.em-lightbox{display:none;position:fixed;inset:0;background:rgba(0,0,0,.8);z-index:2000;justify-content:center;align-items:center;flex-direction:column;gap:10px;cursor:zoom-out;}
.em-lightbox.is-open{display:flex;}
.em-lightbox img{max-width:90vw;max-height:70vh;border-radius:8px;box-shadow:0 8px 40px rgba(0,0,0,.4);}
.em-lightbox__caption{color:#fff;font-size:14px;text-align:center;}
.em-lightbox__close{position:absolute;top:16px;right:20px;background:none;border:none;color:#fff;font-size:28px;cursor:pointer;}

/* ── Employee Profile Panel ── */
.ep-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1100;justify-content:flex-end;}
.ep-overlay.is-open{display:flex;}
.ep-panel{width:680px;max-width:100%;height:100%;background:#fff;box-shadow:-4px 0 30px rgba(0,0,0,.15);display:flex;flex-direction:column;animation:epSlide .25s ease-out;}
@keyframes epSlide{from{transform:translateX(100%);}to{transform:translateX(0);}}
.ep-header{display:flex;align-items:center;gap:14px;padding:20px;border-bottom:1px solid #eee;flex-shrink:0;}
.ep-photo{width:64px;height:64px;border-radius:50%;object-fit:cover;border:3px solid #eee;}
.ep-header-info{flex:1;min-width:0;}
.ep-header-name{font-size:18px;font-weight:700;color:#1a1a1a;}
.ep-header-meta{font-size:12px;color:#888;margin-top:2px;}
.ep-header-badges{display:flex;gap:6px;margin-top:6px;flex-wrap:wrap;}
.ep-close{background:none;border:none;font-size:24px;color:#999;cursor:pointer;padding:4px;}
.ep-close:hover{color:#333;}

.ep-summary{display:grid;grid-template-columns:repeat(4,1fr);gap:0;border-bottom:1px solid #eee;flex-shrink:0;}
.ep-summary-item{padding:12px 16px;text-align:center;border-right:1px solid #eee;}
.ep-summary-item:last-child{border-right:none;}
.ep-summary-label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.3px;}
.ep-summary-value{font-size:14px;font-weight:700;color:#1a1a1a;margin-top:2px;}

.ep-tabs{display:flex;border-bottom:1px solid #eee;flex-shrink:0;overflow-x:auto;}
.ep-tab{padding:10px 18px;font-size:12px;font-weight:600;color:#888;cursor:pointer;border-bottom:2px solid transparent;white-space:nowrap;transition:all .15s;}
.ep-tab:hover{color:#333;}
.ep-tab--active{color:var(--brand);border-bottom-color:var(--brand);}

.ep-content{flex:1;overflow-y:auto;padding:0;}
.ep-tab-pane{display:none;padding:16px 20px;}
.ep-tab-pane--active{display:block;}

.ep-section-title{font-size:12px;font-weight:700;color:var(--brand);text-transform:uppercase;letter-spacing:.4px;margin:16px 0 8px;padding-bottom:5px;border-bottom:1px solid #eef2f7;}
.ep-section-title:first-child{margin-top:0;}
.ep-bio-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:0;padding:0 4px;}
.ep-bio-item{padding:6px 8px;}
.ep-bio-label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.3px;margin-bottom:1px;}
.ep-bio-value{font-size:13px;color:#1a1a1a;font-weight:500;}
.ep-empty{padding:24px;text-align:center;color:#999;font-size:13px;}
.ep-tbl-scroll{overflow-x:auto;margin:4px 0;}
.ep-data-table{width:100%;border-collapse:collapse;font-size:12px;}
.ep-data-table th{background:#f8f9fa;padding:7px 10px;text-align:left;font-weight:600;color:#555;font-size:10px;text-transform:uppercase;border-bottom:1px solid #dee2e6;white-space:nowrap;}
.ep-data-table td{padding:7px 10px;border-bottom:1px solid #f0f0f0;color:#333;}
.ep-data-table .text-right{text-align:right;}
.ep-data-table .text-center{text-align:center;}
.ep-loading{display:flex;align-items:center;justify-content:center;height:200px;color:#999;}
.ep-loading__spinner{width:24px;height:24px;border:3px solid #eee;border-top-color:var(--brand);border-radius:50%;animation:hrSpin .6s linear infinite;margin-right:10px;}

/* ── Responsive ── */
@media(max-width:1100px){
    .em-stats{grid-template-columns:repeat(3,1fr);}
    .ep-bio-grid{grid-template-columns:repeat(2,1fr);}
}
@media(max-width:768px){
    .em-stats{grid-template-columns:repeat(2,1fr);}
    .em-page-header{flex-wrap:wrap;}
    .em-page-header__actions{margin-left:0;width:100%;}
    .em-page-header__actions .hr-btn{width:100%;justify-content:center;}
    .em-filters__top{flex-direction:column;}
    .em-search-wrap{max-width:100%;}
    .em-filters__row{flex-direction:column;gap:6px;}
    .em-filter-sep{display:none;}
    .hr-form-row,.hr-form-row3{grid-template-columns:1fr;}
    .hr-modal__body{max-height:80vh;}
    .ep-panel{width:100%;}
    .ep-summary{grid-template-columns:repeat(2,1fr);}
    .ep-bio-grid{grid-template-columns:1fr;}
    .em-grid-footer{flex-direction:column;align-items:flex-start;}
}
@media(max-width:480px){
    .em-stats{grid-template-columns:1fr;}
    .em-stat{padding:10px 12px;}
    .em-grid{font-size:12px;}
    .em-grid thead th,.em-grid tbody td{padding:6px 8px;}
    .emp-cell{min-width:160px;}
    .emp-name{max-width:120px;}
    .cd-card__header{padding:12px 14px;}
    .em-filters{padding:10px 14px;}
    .em-grid-footer{padding:10px 14px;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══ Hidden fields & server buttons ════════════════════════════════════ -->
<asp:HiddenField ID="hdnEditEmpID"   runat="server" />
<asp:HiddenField ID="hdnDeleteEmpID" runat="server" />
<asp:HiddenField ID="hdnPwdEmpID"    runat="server" />
<asp:HiddenField ID="hfSupervisorID" runat="server" />

<asp:Button ID="btnAddEmployee"    runat="server" OnClick="btnAddEmployee_Click"    style="display:none" />
<asp:Button ID="btnEditEmployee"   runat="server" OnClick="btnEditEmployee_Click"   style="display:none" />
<asp:Button ID="btnDeleteEmployee" runat="server" OnClick="btnDeleteEmployee_Click" style="display:none" />
<asp:Button ID="btnChangePassword" runat="server" OnClick="btnChangePassword_Click" style="display:none" />

<!-- ═══ Page header ══════════════════════════════════════════════════════ -->
<div class="em-page-header">
    <div class="em-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
    </div>
    <div>
        <div class="em-page-header__title">Employee Management</div>
        <div class="em-page-header__sub">Manage employee records, profiles and credentials</div>
    </div>
    <div class="em-page-header__actions">
        <button type="button" class="hr-btn hr-btn--primary" onclick="openAddModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            New Employee
        </button>
    </div>
</div>

<!-- ═══ Stats bar ════════════════════════════════════════════════════════ -->
<div class="em-stats">
    <div class="em-stat em-stat--blue" onclick="resetFilters()">
        <div class="em-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div class="em-stat__body">
            <div class="em-stat__val"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div>
            <div class="em-stat__label">Total Employees</div>
        </div>
    </div>
    <div class="em-stat em-stat--blue" onclick="filterByType('Academic')">
        <div class="em-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 2 4 3 6 3s6-1 6-3v-5"/></svg>
        </div>
        <div class="em-stat__body">
            <div class="em-stat__val"><asp:Literal ID="litStatAcademic" runat="server" Text="0" /></div>
            <div class="em-stat__label">Academic</div>
        </div>
    </div>
    <div class="em-stat em-stat--amber" onclick="filterByType('Administrative')">
        <div class="em-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        </div>
        <div class="em-stat__body">
            <div class="em-stat__val"><asp:Literal ID="litStatAdmin" runat="server" Text="0" /></div>
            <div class="em-stat__label">Administrative</div>
        </div>
    </div>
    <div class="em-stat em-stat--green" onclick="filterByStatus('VALID')">
        <div class="em-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="em-stat__body">
            <div class="em-stat__val"><asp:Literal ID="litStatActive" runat="server" Text="0" /></div>
            <div class="em-stat__label">Active Contracts</div>
        </div>
    </div>
    <div class="em-stat em-stat--grey" onclick="filterByStatus('NONE')">
        <div class="em-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div class="em-stat__body">
            <div class="em-stat__val"><asp:Literal ID="litStatInactive" runat="server" Text="0" /></div>
            <div class="em-stat__label">Inactive / No Contract</div>
        </div>
    </div>
</div>

<!-- ═══ Main card with filters + table ══════════════════════════════════ -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">Employee Directory</div>
    </div>

    <!-- ── Filters ── -->
    <div class="em-filters">
        <div class="em-filters__top">
            <div class="em-search-wrap">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="em-search-box" placeholder="Search name, code, email, phone..." />
            </div>
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="applyFilters()">Search</button>
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="resetFilters()">Reset</button>
        </div>
        <div class="em-filters__row">
            <div class="em-filter-grp">
                <span class="em-filter-grp__label">Status</span>
                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="em-filter-select" onchange="applyFilters()">
                    <asp:ListItem Value="" Text="All Statuses" />
                    <asp:ListItem Value="VALID" Text="Valid" />
                    <asp:ListItem Value="EXPIRED" Text="Expired" />
                    <asp:ListItem Value="TERMINATED" Text="Terminated" />
                    <asp:ListItem Value="RESIGNED" Text="Resigned" />
                </asp:DropDownList>
            </div>
            <div class="em-filter-grp">
                <span class="em-filter-grp__label">Type</span>
                <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="em-filter-select" onchange="applyFilters()">
                    <asp:ListItem Value="" Text="All Types" />
                    <asp:ListItem Value="Academic" Text="Academic" />
                    <asp:ListItem Value="Administrative" Text="Administrative" />
                </asp:DropDownList>
            </div>
            <div class="em-filter-grp">
                <span class="em-filter-grp__label">Department</span>
                <asp:DropDownList ID="ddlFilterDept" runat="server" CssClass="em-filter-select" onchange="applyFilters()" />
            </div>
            <div class="em-filter-grp">
                <span class="em-filter-grp__label">Station</span>
                <asp:DropDownList ID="ddlFilterStation" runat="server" CssClass="em-filter-select" onchange="applyFilters()" />
            </div>
            <div class="em-filter-sep"></div>
            <div class="em-filter-grp">
                <span class="em-filter-grp__label">Show</span>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="em-filter-select">
                    <asp:ListItem Value="25" Text="25" />
                    <asp:ListItem Value="50" Text="50" Selected="True" />
                    <asp:ListItem Value="100" Text="100" />
                    <asp:ListItem Value="200" Text="200" />
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- ── Table ── -->
    <div class="em-table-wrap">
        <table class="em-grid">
            <thead>
                <tr>
                    <th class="ct-col-num">#</th>
                    <th class="em-sortable<%= QsSort=="" || QsSort=="name" ? " em-sorted" : "" %>" onclick="doSort('name')">
                        Employee<span class="em-sort-icon"><%= (QsSort=="" || QsSort=="name") ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="code" ? " em-sorted" : "" %>" onclick="doSort('code')">
                        Staff Code<span class="em-sort-icon"><%= QsSort=="code" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="phone" ? " em-sorted" : "" %>" onclick="doSort('phone')">
                        Phone<span class="em-sort-icon"><%= QsSort=="phone" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="type" ? " em-sorted" : "" %>" onclick="doSort('type')">
                        Type<span class="em-sort-icon"><%= QsSort=="type" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="dept" ? " em-sorted" : "" %>" onclick="doSort('dept')">
                        Department<span class="em-sort-icon"><%= QsSort=="dept" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="supervisor" ? " em-sorted" : "" %>" onclick="doSort('supervisor')">
                        Supervisor<span class="em-sort-icon"><%= QsSort=="supervisor" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="station" ? " em-sorted" : "" %>" onclick="doSort('station')">
                        Station<span class="em-sort-icon"><%= QsSort=="station" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="status" ? " em-sorted" : "" %>" onclick="doSort('status')">
                        Status<span class="em-sort-icon"><%= QsSort=="status" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="em-sortable<%= QsSort=="pay" ? " em-sorted" : "" %>" onclick="doSort('pay')" style="text-align:right">
                        Pay<span class="em-sort-icon"><%= QsSort=="pay" ? (QsSortDir=="ASC" ? "&#9650;" : "&#9660;") : "&#9650;&#9660;" %></span></th>
                    <th class="ct-col-actions"></th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litGridBody" runat="server" />
            </tbody>
        </table>
    </div>

    <!-- ── Footer / Pager ── -->
    <div class="em-grid-footer">
        <div class="em-pager-info"><asp:Literal ID="litPagerInfo" runat="server" /></div>
        <asp:Literal ID="litPager" runat="server" />
    </div>
</div>

<!-- ═══ Image Lightbox ══════════════════════════════════════════════════ -->
<div class="em-lightbox" id="imgLightbox" onclick="closeLightbox()">
    <button class="em-lightbox__close" type="button">&times;</button>
    <img id="lightboxImg" src="" alt="" />
    <div class="em-lightbox__caption" id="lightboxCaption"></div>
</div>

<!-- ═══ Employee Profile Side Panel ═══════════════════════════════════════ -->
<div class="ep-overlay" id="profileOverlay">
    <div class="ep-panel" onclick="event.stopPropagation()">
        <div class="ep-header">
            <img id="epPhoto" class="ep-photo" src="../staffimages/default.jpg" onerror="this.onerror=null;this.src='../staffimages/default.jpg'" alt="" />
            <div class="ep-header-info">
                <div class="ep-header-name" id="epName">Loading...</div>
                <div class="ep-header-meta" id="epCode"></div>
                <div class="ep-header-badges" id="epBadges"></div>
            </div>
            <button class="ep-close" type="button" onclick="closeProfile()">&times;</button>
        </div>
        <div class="ep-summary">
            <div class="ep-summary-item"><div class="ep-summary-label">Department</div><div class="ep-summary-value" id="epDept">&mdash;</div></div>
            <div class="ep-summary-item"><div class="ep-summary-label">Station</div><div class="ep-summary-value" id="epStation">&mdash;</div></div>
            <div class="ep-summary-item"><div class="ep-summary-label">Pay</div><div class="ep-summary-value" id="epPay">&mdash;</div></div>
            <div class="ep-summary-item"><div class="ep-summary-label">Status</div><div class="ep-summary-value" id="epStatus">&mdash;</div></div>
        </div>
        <div class="ep-tabs" id="epTabs">
            <div class="ep-tab ep-tab--active" data-tab="bio">Bio Data</div>
            <div class="ep-tab" data-tab="contracts">Contracts</div>
            <div class="ep-tab" data-tab="qualifications">Qualifications</div>
            <div class="ep-tab" data-tab="leave">Leave</div>
            <div class="ep-tab" data-tab="payroll">Payroll</div>
            <div class="ep-tab" data-tab="emergency">Emergency</div>
        </div>
        <div class="ep-content">
            <div class="ep-tab-pane ep-tab-pane--active" id="epPane_bio"><div class="ep-loading"><div class="ep-loading__spinner"></div>Loading profile...</div></div>
            <div class="ep-tab-pane" id="epPane_contracts"></div>
            <div class="ep-tab-pane" id="epPane_qualifications"></div>
            <div class="ep-tab-pane" id="epPane_leave"></div>
            <div class="ep-tab-pane" id="epPane_payroll"></div>
            <div class="ep-tab-pane" id="epPane_emergency"></div>
        </div>
    </div>
</div>

<!-- ═══ Add / Edit Employee Modal ═══════════════════════════════════════ -->
<div class="hr-modal-overlay" id="empFormModal">
    <div class="hr-modal hr-modal--lg">
        <div class="hr-modal__header">
            <h3 id="empFormTitle">New Employee</h3>
            <button type="button" class="hr-modal__close" onclick="closeEmpFormModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="empFormResult" class="hr-result"></div>

            <div class="hr-modal__section">Personal Information</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Full Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtEmpName" runat="server" CssClass="hr-form-input" placeholder="Enter full name" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Email <span class="req">*</span></label>
                    <asp:TextBox ID="txtEmpEmail" runat="server" CssClass="hr-form-input" TextMode="Email" placeholder="email@example.com" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Phone <span class="req">*</span></label>
                    <asp:TextBox ID="txtEmpPhone" runat="server" CssClass="hr-form-input" placeholder="+256..." />
                </div>
            </div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Date of Birth</label>
                    <asp:TextBox ID="txtEmpDOB" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Gender</label>
                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="Male" Text="Male" />
                        <asp:ListItem Value="Female" Text="Female" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Marital Status</label>
                    <asp:DropDownList ID="ddlMarital" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="SINGLE" Text="Single" />
                        <asp:ListItem Value="MARRIED" Text="Married" />
                        <asp:ListItem Value="DIVORCED" Text="Divorced" />
                        <asp:ListItem Value="WIDOWED" Text="Widowed" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Nationality</label>
                    <asp:DropDownList ID="ddlNationality" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="UGANDAN" Text="Ugandan" />
                        <asp:ListItem Value="KENYAN" Text="Kenyan" />
                        <asp:ListItem Value="TANZANIAN" Text="Tanzanian" />
                        <asp:ListItem Value="RWANDESE" Text="Rwandese" />
                        <asp:ListItem Value="CONGOLESE" Text="Congolese" />
                        <asp:ListItem Value="OTHER" Text="Other" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Religion</label>
                    <asp:TextBox ID="txtReligion" runat="server" CssClass="hr-form-input" placeholder="e.g. Catholic, Muslim..." />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Tribe</label>
                    <asp:TextBox ID="txtTribe" runat="server" CssClass="hr-form-input" placeholder="e.g. Baganda, Banyankole..." />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">NIN (National ID Number)</label>
                    <asp:TextBox ID="txtNIN" runat="server" CssClass="hr-form-input" placeholder="CM12345678ABCDE" MaxLength="50" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Current Residence</label>
                    <asp:TextBox ID="txtResidence" runat="server" CssClass="hr-form-input" placeholder="e.g. Kampala" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Address</label>
                <asp:TextBox ID="txtAddress" runat="server" CssClass="hr-form-input" placeholder="P.O. Box..." />
            </div>

            <div class="hr-modal__section">Employment Details</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Employee Type <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEmpType" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="Administrative" Text="Administrative" />
                        <asp:ListItem Value="Academic" Text="Academic" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Station</label>
                    <asp:DropDownList ID="ddlStation" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Entry Year</label>
                    <asp:TextBox ID="txtEntryYear" runat="server" CssClass="hr-form-input" TextMode="Number" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Max Education Level</label>
                    <asp:DropDownList ID="ddlEducation" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="NA" Text="N/A" />
                        <asp:ListItem Value="Certificate" Text="Certificate" />
                        <asp:ListItem Value="Diploma" Text="Diploma" />
                        <asp:ListItem Value="Bachelors" Text="Bachelor's Degree" />
                        <asp:ListItem Value="Postgraduate" Text="Postgraduate Diploma" />
                        <asp:ListItem Value="Masters" Text="Master's Degree" />
                        <asp:ListItem Value="PhD" Text="PhD / Doctorate" />
                        <asp:ListItem Value="Professor" Text="Professor" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Qualifications</label>
                    <asp:TextBox ID="txtQualifications" runat="server" CssClass="hr-form-input" placeholder="e.g. BSc Computer Science" />
                </div>
            </div>

            <!-- Supervisor autocomplete -->
            <div class="hr-form-group" id="supAcGroup">
                <label class="hr-form-label">Supervisor <span style="color:#dc2626;" title="Required">*</span></label>
                <div class="hr-ac" id="supAcWrap">
                    <input type="text" class="hr-ac__input" id="supAcInput" autocomplete="off" placeholder="Search supervisor by name or code..." />
                    <span class="hr-ac__spinner" id="supAcSpinner"></span>
                    <button type="button" class="hr-ac__clear" id="supAcClear">&times;</button>
                    <div class="hr-ac__list" id="supAcList"></div>
                </div>
                <div class="hr-selected-sup" id="selectedSupCard">
                    <div class="hr-selected-sup__avatar" id="supAvatar"></div>
                    <div class="hr-selected-sup__info">
                        <div class="hr-selected-sup__name" id="supName"></div>
                        <div class="hr-selected-sup__detail" id="supPosition"></div>
                    </div>
                    <span class="hr-selected-sup__code" id="supCode"></span>
                    <button type="button" class="hr-selected-sup__remove" onclick="SupAC.clear()">&times;</button>
                </div>
                <div id="supRequiredMsg" style="display:none;color:#dc2626;font-size:12px;margin-top:4px;">Supervisor is required. Please search and select a supervisor.</div>
                <div class="hr-form-hint">Required &mdash; search by name or staff code to assign a supervisor</div>
            </div>

            <div class="hr-modal__section">Employment Status &amp; Appraisal</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Employment Status</label>
                    <asp:DropDownList ID="ddlEmpStatus" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="ACTIVE" Text="Active" Selected="True" />
                        <asp:ListItem Value="PROBATION" Text="Probation" />
                        <asp:ListItem Value="SUSPENDED" Text="Suspended" />
                        <asp:ListItem Value="ON_LEAVE" Text="On Leave" />
                        <asp:ListItem Value="TERMINATED" Text="Terminated" />
                        <asp:ListItem Value="RESIGNED" Text="Resigned" />
                        <asp:ListItem Value="RETIRED" Text="Retired" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Date Joined</label>
                    <asp:TextBox ID="txtDateJoined" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Probation End Date</label>
                    <asp:TextBox ID="txtProbationEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">To Be Appraised?</label>
                    <asp:DropDownList ID="ddlAppraised" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Yes" Selected="True" />
                        <asp:ListItem Value="0" Text="No" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Appraisal Cycle</label>
                    <asp:DropDownList ID="ddlAppraisalCycle" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="ANNUAL" Text="Annual" Selected="True" />
                        <asp:ListItem Value="SEMI_ANNUAL" Text="Semi-Annual" />
                        <asp:ListItem Value="QUARTERLY" Text="Quarterly" />
                        <asp:ListItem Value="PROBATION" Text="Probation" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">&nbsp;</div>
            </div>
            <!-- Reviewer autocomplete (counter-signer for appraisals) -->
            <div class="hr-form-group">
                <asp:HiddenField ID="hfReviewerID" runat="server" />
                <label class="hr-form-label">Reviewer / Counter-Signer</label>
                <div class="hr-ac" id="revAcWrap">
                    <input type="text" class="hr-ac__input" id="revAcInput" autocomplete="off" placeholder="Search reviewer by name or code..." />
                    <span class="hr-ac__spinner" id="revAcSpinner"></span>
                    <button type="button" class="hr-ac__clear" id="revAcClear">&times;</button>
                    <div class="hr-ac__list" id="revAcList"></div>
                </div>
                <div class="hr-selected-sup" id="selectedRevCard" style="display:none;">
                    <div class="hr-selected-sup__avatar" id="revAvatar"></div>
                    <div class="hr-selected-sup__info">
                        <div class="hr-selected-sup__name" id="revName"></div>
                        <div class="hr-selected-sup__detail" id="revPosition"></div>
                    </div>
                    <span class="hr-selected-sup__code" id="revCode"></span>
                    <button type="button" class="hr-selected-sup__remove" onclick="RevAC.clear()">&times;</button>
                </div>
                <div class="hr-form-hint">The reviewer counter-signs appraisals (typically the supervisor's supervisor or HOD)</div>
            </div>

            <div class="hr-modal__section">Financial Details</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">TIN</label>
                    <asp:TextBox ID="txtTIN" runat="server" CssClass="hr-form-input" placeholder="Tax ID Number" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">NSSF No.</label>
                    <asp:TextBox ID="txtNSSF" runat="server" CssClass="hr-form-input" placeholder="NSSF Number" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Bank</label>
                    <asp:DropDownList ID="ddlBank" runat="server" CssClass="hr-form-select" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Bank Account No.</label>
                <asp:TextBox ID="txtBankAccount" runat="server" CssClass="hr-form-input" placeholder="Account number" />
            </div>

            <div class="hr-modal__section">Family</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Spouse Name</label>
                    <asp:TextBox ID="txtSpouse" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">No. of Children</label>
                    <asp:TextBox ID="txtChildren" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Father's Name</label>
                    <asp:TextBox ID="txtFather" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Mother's Name</label>
                <asp:TextBox ID="txtMother" runat="server" CssClass="hr-form-input" />
            </div>

            <div class="hr-modal__section">Emergency Contact</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-form-label">Contact Person</label>
                    <asp:TextBox ID="txtContactPerson" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Relationship</label>
                    <asp:TextBox ID="txtRelation" runat="server" CssClass="hr-form-input" placeholder="e.g. Spouse, Parent..." />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Contact Phone</label>
                    <asp:TextBox ID="txtContactPhone" runat="server" CssClass="hr-form-input" placeholder="+256..." />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Referee 1</label>
                    <asp:TextBox ID="txtReferee1" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Referee 2</label>
                    <asp:TextBox ID="txtReferee2" runat="server" CssClass="hr-form-input" />
                </div>
            </div>

            <div class="hr-modal__section">Additional Information</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Medical Background</label>
                <asp:TextBox ID="txtMedical" runat="server" CssClass="hr-form-textarea" TextMode="MultiLine" Rows="2" placeholder="Known medical conditions, allergies, etc." />
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Academic / Professional Training</label>
                <asp:TextBox ID="txtSchooling" runat="server" CssClass="hr-form-textarea" TextMode="MultiLine" Rows="2" placeholder="Schools attended, certifications..." />
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Employment History</label>
                <asp:TextBox ID="txtEmploymentHist" runat="server" CssClass="hr-form-textarea" TextMode="MultiLine" Rows="2" placeholder="Previous employers, positions..." />
            </div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeEmpFormModal()">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary" id="btnEmpFormSubmit" onclick="submitEmpForm()">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                Save Employee
            </button>
        </div>
    </div>
</div>

<!-- ═══ Change Password Modal ════════════════════════════════════════════ -->
<div class="hr-modal-overlay" id="changePwdModal">
    <div class="hr-modal hr-modal--md">
        <div class="hr-modal__header">
            <h3>Reset Employee Access</h3>
            <button type="button" class="hr-modal__close" onclick="closePwdModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="pwdResult" class="hr-result"></div>
            <p id="pwdUserInfo" style="font-size:13px;color:#555;margin:0 0 10px;"></p>

            <div class="hr-form-group" style="margin-bottom:12px;">
                <label class="hr-form-label" style="margin-bottom:6px;display:block;">Type Password (optional)</label>
                <input type="password" id="pwdManualValue" class="hr-form-input" placeholder="Leave blank to auto-generate" autocomplete="new-password" />
                <div class="hr-form-hint" style="margin-top:6px;">If provided, this exact password will be set for the user.</div>
            </div>

            <div style="background:#f8f9fc;border:1px solid #e4e7f2;border-radius:6px;padding:10px 12px;font-size:12px;color:#445;line-height:1.5;">
                This action unlocks the account and resets the password.<br />
                If no membership account exists, one is created automatically.
            </div>
            <div id="pwdTempWrap" style="display:none;margin-top:12px;">
                <label class="hr-form-label" style="margin-bottom:6px;display:block;">Final Password</label>
                <div style="display:flex;gap:8px;align-items:center;">
                    <input type="text" id="pwdTempValue" class="hr-form-input" readonly="readonly" style="font-family:Consolas,monospace;font-weight:600;" />
                    <button type="button" class="hr-btn hr-btn--outline hr-btn--sm" onclick="copyTempPassword()">Copy</button>
                </div>
                <div class="hr-form-hint" style="margin-top:6px;">Share this once with the employee and ask them to change it immediately.</div>
            </div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closePwdModal()">Cancel</button>
            <button type="button" id="pwdSubmitBtn" class="hr-btn hr-btn--primary" onclick="submitPwdForm()">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span id="pwdSubmitBtnText">Set Password</span>
            </button>
        </div>
    </div>
</div>

<!-- ═══ JavaScript ══════════════════════════════════════════════════════ -->
<script type="text/javascript">

/* ===== ACTION POPOVER ================================================== */
function toggleActionPopover(btn, evt) {
    evt.stopPropagation();
    var pop = btn.nextElementSibling;
    var isOpen = pop.classList.contains('is-open');
    closeAllActionPopovers();
    if (!isOpen) pop.classList.add('is-open');
}
function closeAllActionPopovers() {
    var pops = document.querySelectorAll('.cd-action-popover.is-open');
    for (var i = 0; i < pops.length; i++) pops[i].classList.remove('is-open');
}
document.addEventListener('click', closeAllActionPopovers);

/* ===== SEARCHABLE SELECT WIDGET ======================================== */
function initSearchableSelect(sel) {
    if (!sel || sel.dataset.srchInit) return;
    sel.dataset.srchInit = '1';
    sel.style.display = 'none';

    var wrap  = document.createElement('div');  wrap.className = 'cd-srch';
    var input = document.createElement('input'); input.type = 'text'; input.className = 'cd-srch__input'; input.autocomplete = 'off';
    input.placeholder = sel.options[0] ? sel.options[0].text : '-- Select --';
    var arrow = document.createElement('span'); arrow.className = 'cd-srch__arrow'; arrow.innerHTML = '&#9662;';
    var panel = document.createElement('div');  panel.className = 'cd-srch__panel';
    wrap.appendChild(input); wrap.appendChild(arrow); wrap.appendChild(panel);
    sel.parentNode.insertBefore(wrap, sel);

    var items = [], activeIdx = -1;

    function buildOptions() {
        items = [];
        for (var i = 0; i < sel.options.length; i++) {
            if (!sel.options[i].value) continue;
            items.push({ text: sel.options[i].text, value: sel.options[i].value });
        }
    }
    buildOptions();

    var obs = new MutationObserver(function() { buildOptions(); });
    obs.observe(sel, { childList: true });

    function render(query) {
        var q = (query || '').toLowerCase();
        var html = '', count = 0;
        for (var i = 0; i < items.length; i++) {
            if (q && items[i].text.toLowerCase().indexOf(q) === -1) continue;
            var isSel = (sel.value === items[i].value);
            var cls = 'cd-srch__opt' + (isSel ? ' cd-srch__opt--selected' : '');
            var display = q ? highlightText(items[i].text, q) : escHtml(items[i].text);
            html += '<div class="' + cls + '" data-val="' + escHtml(items[i].value) + '" data-idx="' + count + '">' + display + '</div>';
            count++;
        }
        if (!count) html = '<div class="cd-srch__empty">No matches</div>';
        panel.innerHTML = html;
        activeIdx = -1;
        var opts = panel.querySelectorAll('.cd-srch__opt');
        for (var j = 0; j < opts.length; j++) {
            (function(o) {
                o.addEventListener('mousedown', function(e) { e.preventDefault(); pickOption(o.dataset.val, o.textContent); });
                o.addEventListener('mouseenter', function() { setActive(parseInt(o.dataset.idx)); });
            })(opts[j]);
        }
    }

    function pickOption(val, text) {
        sel.value = val;
        input.value = text;
        input.className = 'cd-srch__input cd-srch__input--has-value';
        closePanel();
        var evt = document.createEvent('HTMLEvents'); evt.initEvent('change', true, false); sel.dispatchEvent(evt);
    }

    function setActive(idx) {
        activeIdx = idx;
        var opts = panel.querySelectorAll('.cd-srch__opt');
        for (var i = 0; i < opts.length; i++) opts[i].classList.toggle('cd-srch__opt--active', i === idx);
        if (idx >= 0 && opts[idx]) opts[idx].scrollIntoView({ block: 'nearest' });
    }

    function openPanel() { render(input.value); panel.classList.add('cd-srch__panel--open'); }
    function closePanel() { panel.classList.remove('cd-srch__panel--open'); activeIdx = -1; }

    input.addEventListener('focus', function() { input.select(); openPanel(); });
    input.addEventListener('input', function() { render(input.value); if (!panel.classList.contains('cd-srch__panel--open')) openPanel(); });
    input.addEventListener('keydown', function(e) {
        var opts = panel.querySelectorAll('.cd-srch__opt');
        if (e.key === 'ArrowDown') { e.preventDefault(); setActive(Math.min(activeIdx + 1, opts.length - 1)); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); setActive(Math.max(activeIdx - 1, 0)); }
        else if (e.key === 'Enter') { e.preventDefault(); if (activeIdx >= 0 && opts[activeIdx]) { opts[activeIdx].dispatchEvent(new MouseEvent('mousedown')); } }
        else if (e.key === 'Escape') { closePanel(); input.blur(); }
    });
    input.addEventListener('blur', function() { setTimeout(closePanel, 160); });

    wrap.syncFromSelect = function() {
        if (sel.value) {
            for (var i = 0; i < items.length; i++) {
                if (items[i].value === sel.value) { input.value = items[i].text; input.className = 'cd-srch__input cd-srch__input--has-value'; return; }
            }
        }
        input.value = ''; input.className = 'cd-srch__input';
    };
    wrap.syncFromSelect();

    wrap.clearSelection = function() { sel.value = ''; input.value = ''; input.className = 'cd-srch__input'; };

    return wrap;
}

function syncSearchable(sel) {
    if (!sel) return;
    var wrap = sel.previousElementSibling;
    if (wrap && wrap.classList && wrap.classList.contains('cd-srch') && wrap.syncFromSelect) wrap.syncFromSelect();
}

function highlightText(text, q) {
    var esc = escHtml(text);
    var qe = q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return esc.replace(new RegExp('(' + qe + ')', 'gi'), '<mark>$1</mark>');
}
function escHtml(s) { var d = document.createElement('div'); d.appendChild(document.createTextNode(s || '')); return d.innerHTML; }

/* ===== SUPERVISOR AUTOCOMPLETE ========================================= */
var SupAC = (function() {
    var input, list, spinner, clear, timer, xhr, activeIdx = -1, results = [], selected = null, bound = false;
    var DEBOUNCE = 250, MIN_CHARS = 1;

    function init() {
        input   = document.getElementById('supAcInput');
        list    = document.getElementById('supAcList');
        spinner = document.getElementById('supAcSpinner');
        clear   = document.getElementById('supAcClear');
        if (!input || bound) return;
        bound = true;

        input.addEventListener('input', onInput);
        input.addEventListener('keydown', onKeyDown);
        input.addEventListener('focus', function() { if (results.length > 0 && !selected) showList(); });
        clear.addEventListener('click', doClear);
        document.addEventListener('click', function(e) {
            if (input && !input.contains(e.target) && !list.contains(e.target)) hideList();
        });
    }

    function onInput() {
        var q = input.value.trim();
        if (selected) deselect();
        if (timer) clearTimeout(timer);
        if (xhr) { xhr.abort(); xhr = null; }
        if (q.length < MIN_CHARS) { hideList(); results = []; return; }
        timer = setTimeout(function() { doSearch(q); }, DEBOUNCE);
    }

    function onKeyDown(e) {
        if (!list.classList.contains('hr-ac__list--visible')) {
            if (e.keyCode === 40 && results.length > 0) { showList(); e.preventDefault(); }
            return;
        }
        if (e.keyCode === 40) { e.preventDefault(); activeIdx = Math.min(activeIdx + 1, results.length - 1); renderActive(); }
        else if (e.keyCode === 38) { e.preventDefault(); activeIdx = Math.max(activeIdx - 1, 0); renderActive(); }
        else if (e.keyCode === 13) { e.preventDefault(); if (activeIdx >= 0 && activeIdx < results.length) selectSup(results[activeIdx]); }
        else if (e.keyCode === 27) { hideList(); }
    }

    function doSearch(q) {
        spinner.classList.add('hr-ac__spinner--visible');
        clear.classList.remove('hr-ac__clear--visible');
        if (xhr) xhr.abort();
        xhr = new XMLHttpRequest();
        xhr.open('GET', 'HREmployees.aspx?ajax=search_emp&q=' + encodeURIComponent(q), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            spinner.classList.remove('hr-ac__spinner--visible');
            if (selected) clear.classList.add('hr-ac__clear--visible');
            if (xhr.status === 200) {
                try {
                    var resp = xhr.responseText.trim();
                    var braceCount = 0, endIdx = 0;
                    for (var i = 0; i < resp.length; i++) {
                        if (resp[i] === '{') braceCount++;
                        if (resp[i] === '}') braceCount--;
                        if (braceCount === 0 && resp[i] === '}') { endIdx = i + 1; break; }
                    }
                    var data = JSON.parse(resp.substring(0, endIdx));
                    results = data.results || [];
                    activeIdx = -1;
                    renderList(q);
                } catch(ex) { results = []; }
            }
        };
        xhr.send();
    }

    function renderList(query) {
        if (results.length === 0) {
            list.innerHTML = '<div class="hr-ac__empty">No employees found for &ldquo;' + escHtml(query) + '&rdquo;</div>';
            showList(); return;
        }
        var html = '';
        for (var i = 0; i < results.length; i++) {
            var r = results[i];
            var initials = getInitials(r.emp_name);
            html += '<div class="hr-ac__item' + (i === activeIdx ? ' hr-ac__item--active' : '') + '" data-idx="' + i + '">' +
                '<div class="hr-ac__avatar">' + escHtml(initials) + '</div>' +
                '<div class="hr-ac__info"><div class="hr-ac__name">' + highlight(r.emp_name, query) + '</div>' +
                '<div class="hr-ac__meta">' + escHtml(r.emp_position || 'Staff') + '</div></div>' +
                '<div class="hr-ac__code">' + highlight(r.EMP_CODE || '', query) + '</div></div>';
        }
        html += '<div class="hr-ac__hint">' + results.length + ' result' + (results.length !== 1 ? 's' : '') + '</div>';
        list.innerHTML = html;
        var items = list.querySelectorAll('.hr-ac__item');
        for (var j = 0; j < items.length; j++) {
            (function(idx) {
                items[idx].addEventListener('click', function() { selectSup(results[idx]); });
                items[idx].addEventListener('mouseenter', function() { activeIdx = idx; renderActive(); });
            })(j);
        }
        showList();
    }

    function renderActive() {
        var items = list.querySelectorAll('.hr-ac__item');
        for (var i = 0; i < items.length; i++) items[i].className = 'hr-ac__item' + (i === activeIdx ? ' hr-ac__item--active' : '');
        if (activeIdx >= 0 && items[activeIdx]) items[activeIdx].scrollIntoView({ block: 'nearest' });
    }

    function selectSup(emp) {
        selected = emp;
        hideList(); results = [];
        input.value = emp.emp_name + ' [' + emp.EMP_CODE + ']';
        input.classList.add('hr-ac__input--selected');
        clear.classList.add('hr-ac__clear--visible');

        var card = document.getElementById('selectedSupCard');
        card.className = 'hr-selected-sup hr-selected-sup--visible';
        document.getElementById('supAvatar').textContent   = getInitials(emp.emp_name);
        document.getElementById('supName').textContent     = emp.emp_name;
        document.getElementById('supPosition').textContent = emp.emp_position || 'Staff';
        document.getElementById('supCode').textContent     = emp.EMP_CODE;

        document.getElementById('<%= hfSupervisorID.ClientID %>').value = emp.empID;
    }

    function deselect() {
        selected = null;
        if (input) input.classList.remove('hr-ac__input--selected');
        if (clear) clear.classList.remove('hr-ac__clear--visible');
        document.getElementById('selectedSupCard').className = 'hr-selected-sup';
        document.getElementById('<%= hfSupervisorID.ClientID %>').value = '';
    }

    function doClear() {
        deselect();
        if (input) { input.value = ''; input.focus(); }
        hideList(); results = [];
    }

    function showList() { list.classList.add('hr-ac__list--visible'); }
    function hideList() { list.classList.remove('hr-ac__list--visible'); activeIdx = -1; }

    function highlight(text, query) {
        if (!text || !query) return escHtml(text || '');
        var words = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').split(/\s+/).filter(function(w) { return w.length > 0; });
        if (words.length === 0) return escHtml(text);
        var re = new RegExp('(' + words.join('|') + ')', 'gi');
        var parts = text.split(re);
        var out = '';
        for (var i = 0; i < parts.length; i++) {
            if (re.test(parts[i])) { re.lastIndex = 0; out += '<mark>' + escHtml(parts[i]) + '</mark>'; }
            else out += escHtml(parts[i]);
        }
        return out;
    }

    function getInitials(name) {
        if (!name) return '?';
        var p = name.trim().split(/\s+/);
        if (p.length >= 2) return (p[0][0] + p[p.length - 1][0]).toUpperCase();
        return p[0][0].toUpperCase();
    }

    function setSelected(empID, empName, empCode, empPosition) {
        selected = { empID: empID, emp_name: empName, EMP_CODE: empCode, emp_position: empPosition };
        if (input) {
            input.value = empName + ' [' + empCode + ']';
            input.classList.add('hr-ac__input--selected');
        }
        if (clear) clear.classList.add('hr-ac__clear--visible');
        var card = document.getElementById('selectedSupCard');
        card.className = 'hr-selected-sup hr-selected-sup--visible';
        document.getElementById('supAvatar').textContent   = getInitials(empName);
        document.getElementById('supName').textContent     = empName;
        document.getElementById('supPosition').textContent = empPosition || 'Staff';
        document.getElementById('supCode').textContent     = empCode;
        document.getElementById('<%= hfSupervisorID.ClientID %>').value = empID;
    }

    return { init: init, clear: doClear, setSelected: setSelected };
})();

/* ===== REVIEWER AUTOCOMPLETE (same pattern as SupAC) =================== */
var RevAC = (function() {
    var input, list, spinner, clear, timer, xhr, activeIdx = -1, results = [], selected = null, bound = false;
    var DEBOUNCE = 250, MIN_CHARS = 1;

    function init() {
        input   = document.getElementById('revAcInput');
        list    = document.getElementById('revAcList');
        spinner = document.getElementById('revAcSpinner');
        clear   = document.getElementById('revAcClear');
        if (!input || bound) return;
        bound = true;
        input.addEventListener('input', onInput);
        input.addEventListener('keydown', onKeyDown);
        input.addEventListener('focus', function() { if (results.length > 0 && !selected) showList(); });
        clear.addEventListener('click', doClear);
        document.addEventListener('click', function(e) {
            if (input && !input.contains(e.target) && !list.contains(e.target)) hideList();
        });
    }

    function onInput() {
        var q = input.value.trim();
        if (selected) deselect();
        if (timer) clearTimeout(timer);
        if (xhr) { xhr.abort(); xhr = null; }
        if (q.length < MIN_CHARS) { hideList(); results = []; return; }
        timer = setTimeout(function() { doSearch(q); }, DEBOUNCE);
    }

    function onKeyDown(e) {
        if (!list.classList.contains('hr-ac__list--visible')) {
            if (e.keyCode === 40 && results.length > 0) { showList(); e.preventDefault(); }
            return;
        }
        if (e.keyCode === 40) { e.preventDefault(); activeIdx = Math.min(activeIdx + 1, results.length - 1); renderActive(); }
        else if (e.keyCode === 38) { e.preventDefault(); activeIdx = Math.max(activeIdx - 1, 0); renderActive(); }
        else if (e.keyCode === 13) { e.preventDefault(); if (activeIdx >= 0 && activeIdx < results.length) selectRev(results[activeIdx]); }
        else if (e.keyCode === 27) { hideList(); }
    }

    function doSearch(q) {
        spinner.classList.add('hr-ac__spinner--visible');
        clear.classList.remove('hr-ac__clear--visible');
        if (xhr) xhr.abort();
        xhr = new XMLHttpRequest();
        xhr.open('GET', 'HREmployees.aspx?ajax=search_emp&q=' + encodeURIComponent(q), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            spinner.classList.remove('hr-ac__spinner--visible');
            if (selected) clear.classList.add('hr-ac__clear--visible');
            if (xhr.status === 200) {
                try {
                    var resp = xhr.responseText.trim();
                    var braceCount = 0, endIdx = 0;
                    for (var i = 0; i < resp.length; i++) {
                        if (resp[i] === '{') braceCount++;
                        if (resp[i] === '}') braceCount--;
                        if (braceCount === 0 && resp[i] === '}') { endIdx = i + 1; break; }
                    }
                    var data = JSON.parse(resp.substring(0, endIdx));
                    results = data.results || [];
                    activeIdx = -1;
                    renderList(q);
                } catch(ex) { results = []; }
            }
        };
        xhr.send();
    }

    function renderList(query) {
        if (results.length === 0) {
            list.innerHTML = '<div class="hr-ac__empty">No employees found for &ldquo;' + escHtml(query) + '&rdquo;</div>';
            showList(); return;
        }
        var html = '';
        for (var i = 0; i < results.length; i++) {
            var r = results[i];
            var initials = getInitials(r.emp_name);
            html += '<div class="hr-ac__item' + (i === activeIdx ? ' hr-ac__item--active' : '') + '" data-idx="' + i + '">' +
                '<div class="hr-ac__avatar">' + escHtml(initials) + '</div>' +
                '<div class="hr-ac__info"><div class="hr-ac__name">' + highlight(r.emp_name, query) + '</div>' +
                '<div class="hr-ac__meta">' + escHtml(r.emp_position || 'Staff') + '</div></div>' +
                '<div class="hr-ac__code">' + highlight(r.EMP_CODE || '', query) + '</div></div>';
        }
        html += '<div class="hr-ac__hint">' + results.length + ' result' + (results.length !== 1 ? 's' : '') + '</div>';
        list.innerHTML = html;
        var items = list.querySelectorAll('.hr-ac__item');
        for (var j = 0; j < items.length; j++) {
            (function(idx) {
                items[idx].addEventListener('click', function() { selectRev(results[idx]); });
                items[idx].addEventListener('mouseenter', function() { activeIdx = idx; renderActive(); });
            })(j);
        }
        showList();
    }

    function renderActive() {
        var items = list.querySelectorAll('.hr-ac__item');
        for (var i = 0; i < items.length; i++) items[i].className = 'hr-ac__item' + (i === activeIdx ? ' hr-ac__item--active' : '');
        if (activeIdx >= 0 && items[activeIdx]) items[activeIdx].scrollIntoView({ block: 'nearest' });
    }

    function selectRev(emp) {
        selected = emp;
        hideList(); results = [];
        input.value = emp.emp_name + ' [' + emp.EMP_CODE + ']';
        input.classList.add('hr-ac__input--selected');
        clear.classList.add('hr-ac__clear--visible');

        var card = document.getElementById('selectedRevCard');
        card.style.display = 'flex';
        card.className = 'hr-selected-sup hr-selected-sup--visible';
        document.getElementById('revAvatar').textContent   = getInitials(emp.emp_name);
        document.getElementById('revName').textContent     = emp.emp_name;
        document.getElementById('revPosition').textContent = emp.emp_position || 'Staff';
        document.getElementById('revCode').textContent     = emp.EMP_CODE;
        document.getElementById('<%= hfReviewerID.ClientID %>').value = emp.empID;
    }

    function deselect() {
        selected = null;
        if (input) input.classList.remove('hr-ac__input--selected');
        if (clear) clear.classList.remove('hr-ac__clear--visible');
        var card = document.getElementById('selectedRevCard');
        if (card) { card.style.display = 'none'; card.className = 'hr-selected-sup'; }
        document.getElementById('<%= hfReviewerID.ClientID %>').value = '';
    }

    function doClear() {
        deselect();
        if (input) { input.value = ''; input.focus(); }
        hideList(); results = [];
    }

    function showList() { list.classList.add('hr-ac__list--visible'); }
    function hideList() { list.classList.remove('hr-ac__list--visible'); activeIdx = -1; }

    /* Reuse SupAC helper functions (highlight, getInitials defined in SupAC scope).
       We need local copies since they're closure-scoped. */
    function highlight(text, query) {
        if (!text || !query) return escHtml(text || '');
        var words = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').split(/\s+/).filter(function(w) { return w.length > 0; });
        if (words.length === 0) return escHtml(text);
        var re = new RegExp('(' + words.join('|') + ')', 'gi');
        var parts = text.split(re);
        var out = '';
        for (var i = 0; i < parts.length; i++) {
            if (re.test(parts[i])) { re.lastIndex = 0; out += '<mark>' + escHtml(parts[i]) + '</mark>'; }
            else out += escHtml(parts[i]);
        }
        return out;
    }
    function getInitials(name) {
        if (!name) return '?';
        var p = name.trim().split(/\s+/);
        if (p.length >= 2) return (p[0][0] + p[p.length - 1][0]).toUpperCase();
        return p[0][0].toUpperCase();
    }

    function setSelected(empID, empName, empCode, empPosition) {
        selected = { empID: empID, emp_name: empName, EMP_CODE: empCode, emp_position: empPosition };
        if (input) {
            input.value = empName + ' [' + empCode + ']';
            input.classList.add('hr-ac__input--selected');
        }
        if (clear) clear.classList.add('hr-ac__clear--visible');
        var card = document.getElementById('selectedRevCard');
        if (card) { card.style.display = 'flex'; card.className = 'hr-selected-sup hr-selected-sup--visible'; }
        document.getElementById('revAvatar').textContent   = getInitials(empName);
        document.getElementById('revName').textContent     = empName;
        document.getElementById('revPosition').textContent = empPosition || 'Staff';
        document.getElementById('revCode').textContent     = empCode;
        document.getElementById('<%= hfReviewerID.ClientID %>').value = empID;
    }

    return { init: init, clear: doClear, setSelected: setSelected };
})();

/* ===== LIGHTBOX ======================================================== */
function openLightbox(src, name, code) {
    var lb = document.getElementById('imgLightbox');
    document.getElementById('lightboxImg').src = src;
    document.getElementById('lightboxCaption').textContent = name + (code ? ' (' + code + ')' : '');
    lb.classList.add('is-open');
}
function closeLightbox() { document.getElementById('imgLightbox').classList.remove('is-open'); }

/* ===== FILTERS (GET-based) ============================================= */
function applyFilters() {
    var q       = document.getElementById('<%= txtSearch.ClientID %>');
    var status  = document.getElementById('<%= ddlFilterStatus.ClientID %>');
    var type    = document.getElementById('<%= ddlFilterType.ClientID %>');
    var dept    = document.getElementById('<%= ddlFilterDept.ClientID %>');
    var station = document.getElementById('<%= ddlFilterStation.ClientID %>');
    var sz      = document.getElementById('<%= ddlPageSize.ClientID %>');
    var params = [];
    if (q       && q.value.trim())       params.push('q='       + encodeURIComponent(q.value.trim()));
    if (status  && status.value)         params.push('status='  + encodeURIComponent(status.value));
    if (type    && type.value)           params.push('type='    + encodeURIComponent(type.value));
    if (dept    && dept.value)           params.push('dept='    + encodeURIComponent(dept.value));
    if (station && station.value)        params.push('station=' + encodeURIComponent(station.value));
    if (sz      && sz.value !== '50')    params.push('sz='      + encodeURIComponent(sz.value));
    // Preserve current sort
    var sp = new URLSearchParams(window.location.search);
    if (sp.get('sort')) params.push('sort=' + encodeURIComponent(sp.get('sort')));
    if (sp.get('dir'))  params.push('dir='  + encodeURIComponent(sp.get('dir')));
    window.location.href = window.location.pathname + (params.length ? '?' + params.join('&') : '');
}
function resetFilters() { window.location.href = window.location.pathname; }

function doSort(col) {
    var sp = new URLSearchParams(window.location.search);
    var curSort = (sp.get('sort') || '').toLowerCase();
    var curDir  = (sp.get('dir')  || 'ASC').toUpperCase();
    var newDir  = (curSort === col && curDir === 'ASC') ? 'DESC' : 'ASC';
    sp.set('sort', col);
    sp.set('dir', newDir);
    sp.delete('page'); // reset to page 1 on sort change
    window.location.href = window.location.pathname + '?' + sp.toString();
}
function filterByStatus(val) {
    var sel = document.getElementById('<%= ddlFilterStatus.ClientID %>');
    if (sel) { sel.value = val; applyFilters(); }
}
function filterByType(val) {
    var sel = document.getElementById('<%= ddlFilterType.ClientID %>');
    if (sel) { sel.value = val; applyFilters(); }
}

/* ===== EMPLOYEE FORM MODAL (Add + Edit shared) ========================= */
var editMode = false;

function resetEmpForm() {
    SupAC.clear();
    RevAC.clear();
    var fields = document.querySelectorAll('#empFormModal .hr-form-input, #empFormModal .hr-form-textarea');
    for (var i = 0; i < fields.length; i++) {
        var f = fields[i];
        if (f.type === 'number') f.value = '0';
        else if (f.type === 'password') f.value = '';
        else f.value = '';
    }
    var selects = document.querySelectorAll('#empFormModal .hr-form-select');
    for (var j = 0; j < selects.length; j++) selects[j].selectedIndex = 0;

    // Reset searchable wrappers
    var ddls = [
        document.getElementById('<%= ddlStation.ClientID %>'),
        document.getElementById('<%= ddlBank.ClientID %>')
    ];
    for (var k = 0; k < ddls.length; k++) {
        if (ddls[k]) {
            ddls[k].value = '';
            var w = ddls[k].previousElementSibling;
            if (w && w.classList && w.classList.contains('cd-srch') && w.clearSelection) w.clearSelection();
        }
    }
    document.getElementById('<%= hdnEditEmpID.ClientID %>').value = '';
    document.getElementById('<%= hfSupervisorID.ClientID %>').value = '';
    document.getElementById('<%= hfReviewerID.ClientID %>').value = '';
    var r = document.getElementById('empFormResult');
    if (r) { r.innerHTML = ''; r.className = 'hr-result'; }
}

function openAddModal() {
    editMode = false;
    SupAC.init();
    RevAC.init();
    resetEmpForm();
    document.getElementById('empFormTitle').textContent = 'New Employee';
    document.getElementById('btnEmpFormSubmit').onclick = function() { submitEmpForm(); };
    document.getElementById('empFormModal').style.display = 'flex';
    // Set entry year default
    var yr = document.getElementById('<%= txtEntryYear.ClientID %>');
    if (yr && !yr.value) yr.value = new Date().getFullYear();
}

function openEditModal(empID) {
    editMode = true;
    SupAC.init();
    RevAC.init();
    resetEmpForm();
    document.getElementById('empFormTitle').textContent = 'Edit Employee';
    document.getElementById('<%= hdnEditEmpID.ClientID %>').value = empID;
    document.getElementById('empFormModal').style.display = 'flex';

    // Fetch employee data via AJAX
    var r = document.getElementById('empFormResult');
    r.innerHTML = '<span style="color:#888;">Loading employee data...</span>';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'HREmployees.aspx?ajax=get_emp&id=' + empID, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) { r.innerHTML = '<span style="color:red;">Failed to load employee data.</span>'; return; }
        try {
            var data = JSON.parse(xhr.responseText);
            if (data.error) { r.innerHTML = '<span style="color:red;">' + escHtml(data.error) + '</span>'; return; }
            r.innerHTML = '';

            // Fill form fields
            setVal('<%= txtEmpName.ClientID %>', data.emp_name);
            setVal('<%= txtEmpEmail.ClientID %>', data.emp_email);
            setVal('<%= txtEmpPhone.ClientID %>', data.emp_phone);
            setVal('<%= txtEmpDOB.ClientID %>', data.emp_birthdate);
            setDdl('<%= ddlGender.ClientID %>', data.gender);
            setDdl('<%= ddlMarital.ClientID %>', data.marital_status);
            setDdl('<%= ddlNationality.ClientID %>', data.emp_nationality);
            setVal('<%= txtReligion.ClientID %>', data.religion);
            setVal('<%= txtTribe.ClientID %>', data.tribe);
            setVal('<%= txtNIN.ClientID %>', data.nin);
            setVal('<%= txtResidence.ClientID %>', data.current_residence);
            setVal('<%= txtAddress.ClientID %>', data.address);
            setDdl('<%= ddlEmpType.ClientID %>', data.EmpType);

            var stDdl = document.getElementById('<%= ddlStation.ClientID %>');
            if (stDdl && data.Entry_Satation) { stDdl.value = data.Entry_Satation; syncSearchable(stDdl); }

            setVal('<%= txtEntryYear.ClientID %>', data.Entry_Year);
            setDdl('<%= ddlEducation.ClientID %>', data.max_education);
            setVal('<%= txtQualifications.ClientID %>', data.emp_qualifications);
            setVal('<%= txtTIN.ClientID %>', data.tin);
            setVal('<%= txtNSSF.ClientID %>', data.nssf_no);

            var bkDdl = document.getElementById('<%= ddlBank.ClientID %>');
            if (bkDdl && data.bankID && data.bankID !== '0') { bkDdl.value = data.bankID; syncSearchable(bkDdl); }

            setVal('<%= txtBankAccount.ClientID %>', data.bankAccount);
            setVal('<%= txtSpouse.ClientID %>', data.spouse_name);
            setVal('<%= txtChildren.ClientID %>', data.no_children || '0');
            setVal('<%= txtFather.ClientID %>', data.father_name);
            setVal('<%= txtMother.ClientID %>', data.mother_name);
            setVal('<%= txtContactPerson.ClientID %>', data.contact_person);
            setVal('<%= txtRelation.ClientID %>', data.relation);
            setVal('<%= txtContactPhone.ClientID %>', data.phone_contacts);
            setVal('<%= txtReferee1.ClientID %>', data.referee_1);
            setVal('<%= txtReferee2.ClientID %>', data.referee_2);
            setVal('<%= txtMedical.ClientID %>', data.medical_background);
            setVal('<%= txtSchooling.ClientID %>', data.schooling_info);
            setVal('<%= txtEmploymentHist.ClientID %>', data.employment_info);

            // Supervisor
            if (data.supervisorID && data.supervisorID !== '0' && data.supervisor_name) {
                SupAC.setSelected(data.supervisorID, data.supervisor_name, data.supervisor_code || '', '');
            }

            // Appraisal fields
            setDdl('<%= ddlEmpStatus.ClientID %>', data.employment_status);
            setVal('<%= txtDateJoined.ClientID %>', data.date_joined);
            setVal('<%= txtProbationEnd.ClientID %>', data.probation_end_date);
            setDdl('<%= ddlAppraised.ClientID %>', data.to_be_appraised);
            setDdl('<%= ddlAppraisalCycle.ClientID %>', data.appraisal_cycle);

            // Reviewer
            if (data.reviewer_id && data.reviewer_id !== '0' && data.reviewer_name) {
                RevAC.setSelected(data.reviewer_id, data.reviewer_name, data.reviewer_code || '', '');
            }
        } catch(ex) {
            r.innerHTML = '<span style="color:red;">Error parsing employee data.</span>';
        }
    };
    xhr.send();
}

function setVal(id, val) { var el = document.getElementById(id); if (el) el.value = val || ''; }
function setDdl(id, val) {
    var el = document.getElementById(id);
    if (!el || !val) return;
    // Try exact match
    for (var i = 0; i < el.options.length; i++) {
        if (el.options[i].value === val || el.options[i].value.toUpperCase() === val.toUpperCase()) {
            el.selectedIndex = i; return;
        }
    }
}

function closeEmpFormModal() { document.getElementById('empFormModal').style.display = 'none'; }

function submitEmpForm() {
    var name  = document.getElementById('<%= txtEmpName.ClientID %>');
    var email = document.getElementById('<%= txtEmpEmail.ClientID %>');
    var phone = document.getElementById('<%= txtEmpPhone.ClientID %>');
    var r     = document.getElementById('empFormResult');

    if (!name || !name.value.trim()) { r.innerHTML = 'Full name is required.'; r.className = 'hr-result hr-result--err'; return; }
    if (!email || !email.value.trim()) { r.innerHTML = 'Email is required.'; r.className = 'hr-result hr-result--err'; return; }
    if (!phone || !phone.value.trim()) { r.innerHTML = 'Phone number is required.'; r.className = 'hr-result hr-result--err'; return; }

    // Email validation
    if (email.value.indexOf('@') === -1) { r.innerHTML = 'Please enter a valid email address.'; r.className = 'hr-result hr-result--err'; return; }

    // Supervisor is required
    var supId = document.getElementById('<%= hfSupervisorID.ClientID %>').value;
    var supMsg = document.getElementById('supRequiredMsg');
    var supGroup = document.getElementById('supAcGroup');
    if (!supId || supId === '0' || supId === '') {
        if (supMsg) { supMsg.style.display = 'block'; }
        if (supGroup) { supGroup.scrollIntoView({ behavior: 'smooth', block: 'center' }); }
        r.innerHTML = 'Supervisor is required. Please select a supervisor before saving.';
        r.className = 'hr-result hr-result--err';
        return;
    } else {
        if (supMsg) supMsg.style.display = 'none';
    }

    if (editMode) {
        document.getElementById('<%= btnEditEmployee.ClientID %>').click();
    } else {
        document.getElementById('<%= btnAddEmployee.ClientID %>').click();
    }
}

/* ===== CHANGE PASSWORD MODAL =========================================== */
function openPasswordModal(empID, empName, username) {
    closeAllActionPopovers();
    document.getElementById('<%= hdnPwdEmpID.ClientID %>').value = empID;
    document.getElementById('pwdUserInfo').innerHTML =
        'Reset login access for <strong>' + escHtml(empName) + '</strong>' +
        (username ? ' (' + escHtml(username) + ')' : '');
    var r = document.getElementById('pwdResult');
    r.innerHTML = '';
    r.className = 'hr-result';
    document.getElementById('pwdTempWrap').style.display = 'none';
    document.getElementById('pwdTempValue').value = '';
    document.getElementById('pwdManualValue').value = '';
    document.getElementById('pwdSubmitBtnText').textContent = 'Set Password';
    document.getElementById('changePwdModal').style.display = 'flex';
}
function closePwdModal() { document.getElementById('changePwdModal').style.display = 'none'; }

function showResetPasswordResult(tempPassword, accountName, isProvisioned, customApplied) {
    var wrap = document.getElementById('pwdTempWrap');
    var value = document.getElementById('pwdTempValue');
    var r = document.getElementById('pwdResult');
    value.value = tempPassword || '';
    wrap.style.display = tempPassword ? 'block' : 'none';
    r.className = 'hr-result hr-result--ok';
    if (customApplied) {
        r.innerHTML = isProvisioned
            ? ('Membership account created and typed password set for <strong>' + escHtml(accountName || '') + '</strong>.')
            : ('Typed password set for <strong>' + escHtml(accountName || '') + '</strong>.');
    } else {
        r.innerHTML = isProvisioned
            ? ('Membership account created and password generated for <strong>' + escHtml(accountName || '') + '</strong>.')
            : ('Password generated for <strong>' + escHtml(accountName || '') + '</strong>.');
    }
}

function copyTempPassword() {
    var value = document.getElementById('pwdTempValue');
    if (!value || !value.value) return;
    value.focus();
    value.select();
    try { document.execCommand('copy'); } catch (e) { }
}

function submitPwdForm() {
    var empID = document.getElementById('<%= hdnPwdEmpID.ClientID %>').value;
    if (!empID) return;
    var manualPwd = document.getElementById('pwdManualValue').value || '';

    var r = document.getElementById('pwdResult');
    r.className = 'hr-result';
    r.innerHTML = 'Updating password...';
    document.getElementById('pwdTempWrap').style.display = 'none';
    document.getElementById('pwdSubmitBtn').disabled = true;
    
    fetch('?ajax=reset_pwd&id=' + encodeURIComponent(empID), {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        },
        body: 'new_password=' + encodeURIComponent(manualPwd)
    })
        .then(function(resp) { return resp.json(); })
        .then(function(data) {
            if (data.error) {
                r.className = 'hr-result hr-result--err';
                r.innerHTML = data.error;
            } else {
                showResetPasswordResult(data.temp_password, data.username, data.provisioned, data.custom_applied);
            }
            document.getElementById('pwdSubmitBtn').disabled = false;
        })
        .catch(function(err) {
            r.className = 'hr-result hr-result--err';
            r.innerHTML = 'Error: ' + err.toString();
            document.getElementById('pwdSubmitBtn').disabled = false;
        });
}

/* ===== DELETE EMPLOYEE ================================================= */
function confirmDelete(empID, empName) {
    closeAllActionPopovers();
    if (!confirm('Are you sure you want to permanently delete "' + empName + '"?\n\nThis action cannot be undone.')) return;
    document.getElementById('<%= hdnDeleteEmpID.ClientID %>').value = empID;
    document.getElementById('<%= btnDeleteEmployee.ClientID %>').click();
}

/* ===== EMPLOYEE PROFILE SIDE PANEL ===================================== */
function openEmployeeProfile(empID) {
    closeAllActionPopovers();
    var overlay = document.getElementById('profileOverlay');
    overlay.classList.add('is-open');

    // Reset tabs
    var tabs = document.querySelectorAll('.ep-tab');
    var panes = document.querySelectorAll('.ep-tab-pane');
    for (var i = 0; i < tabs.length; i++) tabs[i].className = 'ep-tab' + (i === 0 ? ' ep-tab--active' : '');
    for (var j = 0; j < panes.length; j++) panes[j].className = 'ep-tab-pane' + (j === 0 ? ' ep-tab-pane--active' : '');

    document.getElementById('epName').textContent = 'Loading...';
    document.getElementById('epCode').textContent = '';
    document.getElementById('epBadges').innerHTML = '';
    document.getElementById('epPhoto').src = '../staffimages/default.jpg';
    document.getElementById('epDept').textContent = '\u2014';
    document.getElementById('epStation').textContent = '\u2014';
    document.getElementById('epPay').textContent = '\u2014';
    document.getElementById('epStatus').innerHTML = '\u2014';
    document.getElementById('epPane_bio').innerHTML = '<div class="ep-loading"><div class="ep-loading__spinner"></div>Loading profile...</div>';
    var emptyPanes = ['contracts','qualifications','leave','payroll','emergency'];
    for (var k = 0; k < emptyPanes.length; k++)
        document.getElementById('epPane_' + emptyPanes[k]).innerHTML = '';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'HREmployees.aspx?ajax=get_profile&id=' + empID, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) {
            document.getElementById('epPane_bio').innerHTML = '<div class="ep-empty">Failed to load profile.</div>';
            return;
        }
        try {
            var d = JSON.parse(xhr.responseText);
            if (d.error) { document.getElementById('epPane_bio').innerHTML = '<div class="ep-empty">' + escHtml(d.error) + '</div>'; return; }

            document.getElementById('epName').textContent = d.name;
            document.getElementById('epCode').textContent = d.code;
            document.getElementById('epPhoto').src = d.photo || '../staffimages/default.jpg';
            document.getElementById('epBadges').innerHTML = d.statusBadge + (d.type ? ' <span class="hr-badge ' + (d.type === 'Academic' ? 'hr-badge--academic' : 'hr-badge--admin') + '">' + escHtml(d.type) + '</span>' : '');
            document.getElementById('epDept').textContent = d.dept || '\u2014';
            document.getElementById('epStation').textContent = d.station || '\u2014';
            document.getElementById('epPay').textContent = d.pay || '\u2014';
            document.getElementById('epStatus').innerHTML = d.statusBadge || '\u2014';

            document.getElementById('epPane_bio').innerHTML = d.bioHtml || '<div class="ep-empty">No data available.</div>';
            document.getElementById('epPane_contracts').innerHTML = d.contractsHtml || '<div class="ep-empty">No contracts found.</div>';
            document.getElementById('epPane_qualifications').innerHTML = d.qualificationsHtml || '<div class="ep-empty">No qualifications recorded.</div>';
            document.getElementById('epPane_leave').innerHTML = d.leaveHtml || '<div class="ep-empty">No leave records.</div>';
            document.getElementById('epPane_payroll').innerHTML = d.payrollHtml || '<div class="ep-empty">No payroll records.</div>';
            document.getElementById('epPane_emergency').innerHTML = d.emergencyHtml || '<div class="ep-empty">No emergency contacts.</div>';
        } catch(ex) {
            document.getElementById('epPane_bio').innerHTML = '<div class="ep-empty">Error loading profile.</div>';
        }
    };
    xhr.send();
}

function closeProfile() { document.getElementById('profileOverlay').classList.remove('is-open'); }

/* ===== INIT ============================================================ */
(function() {
    // Init searchable selects on form dropdowns
    var searchableIds = ['<%= ddlStation.ClientID %>', '<%= ddlBank.ClientID %>'];
    for (var i = 0; i < searchableIds.length; i++) {
        var sel = document.getElementById(searchableIds[i]);
        if (sel) initSearchableSelect(sel);
    }

    // Profile tab switching
    var tabs = document.querySelectorAll('.ep-tab');
    for (var t = 0; t < tabs.length; t++) {
        tabs[t].addEventListener('click', (function(tab) {
            return function() {
                var allTabs = document.querySelectorAll('.ep-tab');
                var allPanes = document.querySelectorAll('.ep-tab-pane');
                for (var j = 0; j < allTabs.length; j++) allTabs[j].classList.remove('ep-tab--active');
                for (var k = 0; k < allPanes.length; k++) allPanes[k].classList.remove('ep-tab-pane--active');
                tab.classList.add('ep-tab--active');
                var pane = document.getElementById('epPane_' + tab.dataset.tab);
                if (pane) pane.classList.add('ep-tab-pane--active');
            };
        })(tabs[t]));
    }

    // Profile overlay close on backdrop click
    var overlay = document.getElementById('profileOverlay');
    if (overlay) overlay.addEventListener('click', function(e) { if (e.target === overlay) closeProfile(); });

    // Modal backdrop close
    var modals = document.querySelectorAll('.hr-modal-overlay');
    for (var m = 0; m < modals.length; m++) {
        modals[m].addEventListener('click', function(e) {
            if (e.target === this) this.style.display = 'none';
        });
    }

    // Page size change triggers filter
    var sz = document.getElementById('<%= ddlPageSize.ClientID %>');
    if (sz) sz.addEventListener('change', applyFilters);

    // Search on Enter
    var sb = document.getElementById('<%= txtSearch.ClientID %>');
    if (sb) sb.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') { e.preventDefault(); applyFilters(); }
    });

    // Escape closes modals + profile
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeEmpFormModal();
            closePwdModal();
            closeProfile();
            closeLightbox();
        }
    });

    // Initialize SupAC
    SupAC.init();
})();
</script>
</asp:Content>
