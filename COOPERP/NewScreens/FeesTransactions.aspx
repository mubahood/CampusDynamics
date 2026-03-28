<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesTransactions.aspx.cs" Inherits="COOPERP_NewScreens_FeesTransactions" Title="Fee Transactions - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== FEE TRANSACTIONS ================================================ */

.fm-page-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 0 12px; margin-bottom: 16px; border-bottom: 2px solid #174DA4; flex-wrap: wrap; gap: 10px; }
.fm-page-header__left { display: flex; align-items: center; gap: 12px; min-width: 0; }
.fm-page-header__icon { width: 40px; height: 40px; background: #05275C; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.fm-page-header__title { font-size: 17px; font-weight: 700; color: #05275C; line-height: 1.2; }
.fm-page-header__sub   { font-size: 12px; color: #666; margin-top: 2px; }

/* Tabs */
.fm-tabs { display: flex; gap: 0; border-bottom: 2px solid #e0e5ed; margin-bottom: 14px; overflow-x: auto; }
.fm-tab { padding: 9px 18px; font-size: 12px; font-weight: 600; color: #666; cursor: pointer; border: none; background: none; border-bottom: 2px solid transparent; margin-bottom: -2px; white-space: nowrap; display: flex; align-items: center; gap: 6px; transition: color .15s; text-decoration: none; }
.fm-tab:hover { color: #174DA4; }
.fm-tab--active { color: #174DA4; border-bottom-color: #174DA4; font-weight: 700; }

/* Stats Row */
.ft-stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 14px; }
.ft-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.ft-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.ft-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ft-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; word-break: break-word; overflow-wrap: break-word; }
.ft-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.ft-stat--bills   { --stat-c: #00897b; } .ft-stat--bills   .ft-stat__icon { background: #e0f2f1; } .ft-stat--bills .ft-stat__val { color: #00695c; }
.ft-stat--pays    { --stat-c: #2e7d32; } .ft-stat--pays    .ft-stat__icon { background: #e6f4ea; } .ft-stat--pays .ft-stat__val { color: #2e7d32; }
.ft-stat--total   { --stat-c: #174DA4; } .ft-stat--total   .ft-stat__icon { background: #e8f0fc; } .ft-stat--total .ft-stat__val { color: #174DA4; }
.ft-stat--bamt    { --stat-c: #e65100; } .ft-stat--bamt    .ft-stat__icon { background: #fff3e0; } .ft-stat--bamt .ft-stat__val { color: #e65100; }
.ft-stat--pamt    { --stat-c: #2e7d32; } .ft-stat--pamt    .ft-stat__icon { background: #e6f4ea; } .ft-stat--pamt .ft-stat__val { color: #2e7d32; }

/* Filters Card */
.ft-card { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 14px; }
.ft-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 6px; }
.ft-card__title { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }
.ft-card__meta { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.07); padding: 2px 8px; border: 1px solid rgba(23,77,164,.15); }

.ft-filters { background: #f8f9fb; border-bottom: 1px solid #e0e5ed; padding: 10px 14px; }
.ft-filters__top { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; }
.ft-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 380px; }
.ft-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.ft-search-box { width: 100%; padding: 7px 12px 7px 32px; border: 1px solid #e0e5ed; font-size: 12px; background: #fff; box-sizing: border-box; }
.ft-search-box:focus { border-color: #174DA4; outline: none; }
.ft-filters__row { display: flex; gap: 8px; flex-wrap: wrap; align-items: flex-end; }
.ft-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.ft-filter-grp__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #999; font-weight: 600; }
.ft-filter-select { border: 1px solid #e0e5ed; padding: 6px 10px; font-size: 11px; background: #fff; color: #333; cursor: pointer; min-width: 110px; }
.ft-filter-select:focus { border-color: #174DA4; outline: none; }

/* Buttons */
.ft-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.ft-btn--primary { background: #05275C; color: #fff; } .ft-btn--primary:hover { background: #174DA4; }
.ft-btn--ghost { background: transparent; border: 1px solid #e0e5ed; color: #555; } .ft-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.ft-btn--sm { padding: 5px 11px; font-size: 10px; }

/* Grid Footer */
.ft-grid-footer { display: flex; justify-content: space-between; align-items: center; padding: 8px 14px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 11px; color: #666; flex-wrap: wrap; gap: 6px; }
.ft-grid-footer strong { color: #05275C; }

/* Badges */
.ft-badge { display: inline-block; padding: 3px 9px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; }
.ft-badge--bill { background: #fff3cd; color: #856404; }
.ft-badge--pay  { background: #d4edda; color: #155724; }
.ft-badge--posted { background: #e8f0fc; color: #174DA4; }
.ft-badge--pending { background: #f8d7da; color: #721c24; }

/* DevExpress Grid overrides */
.dxgvControl_Glass { border: 1px solid #e0e5ed !important; }
.dxgvHeader_Glass td { font-size: 10px !important; text-transform: uppercase !important; letter-spacing: .3px !important; background: #f5f7fa !important; color: #555 !important; border-bottom: 2px solid #e0e5ed !important; padding: 9px 12px !important; font-weight: 600 !important; }
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td { font-size: 11px !important; color: #1a1a2e !important; padding: 8px 12px !important; border-bottom: 1px solid #f0f2f5 !important; vertical-align: middle !important; }
.dxgvDataRow_Glass:hover td, .dxgvDataRowAlt_Glass:hover td { background: #f8f9fb !important; }
.dxgvFilterRow_Glass td { padding: 4px 6px !important; background: #fff !important; }
.dxgvFilterRow_Glass input { border: 1px solid #e0e5ed !important; font-size: 11px !important; padding: 3px 6px !important; }
.dxgvPagerBar_Glass { background: #f5f7fa !important; border-top: 1px solid #e0e5ed !important; padding: 6px 12px !important; }

/* ===== MODAL (from FeesStructure design system) ========================= */
.fs-modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9998; }
.fs-modal-overlay--visible { display: flex; align-items: center; justify-content: center; }
.fs-modal { background: #fff; width: 560px; max-width: 96vw; max-height: 92vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.fs-modal__header { background: #05275C; padding: 12px 18px; display: flex; align-items: center; justify-content: space-between; }
.fs-modal__title  { font-size: 13px; font-weight: 700; color: #fff; }
.fs-modal__close  { width: 24px; height: 24px; border: none; background: rgba(255,255,255,.15); cursor: pointer; color: #fff; font-size: 16px; line-height: 1; display: flex; align-items: center; justify-content: center; }
.fs-modal__close:hover { background: rgba(255,255,255,.3); }
.fs-modal__body   { padding: 16px 18px; }
.fs-modal__footer { padding: 11px 18px; border-top: 1px solid #e0e5ed; display: flex; gap: 8px; justify-content: flex-end; background: #f8f9fb; }

/* Form controls */
.fs-form-row { display: flex; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
.fs-form-group { display: flex; flex-direction: column; gap: 3px; flex: 1; min-width: 130px; }
.fs-form-label { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #666; font-weight: 700; }
.fs-form-input { border: 1px solid #cdd3de; padding: 6px 9px; font-size: 12px; color: #1a1a2e; background: #fff; width: 100%; box-sizing: border-box; }
.fs-form-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }
.fs-form-input:disabled, .fs-form-input[readonly] { background: #f5f7fa; color: #888; cursor: not-allowed; }

/* Buttons (modal) */
.fs-btn { padding: 5px 13px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: background .15s; line-height: 1.5; }
.fs-btn--primary { background: #05275C; color: #fff; } .fs-btn--primary:hover { background: #041d45; }
.fs-btn--ghost   { background: #fff; color: #444; border: 1px solid #cdd3de; } .fs-btn--ghost:hover { border-color: #05275C; color: #05275C; }

/* Toast */
.fs-toast { display: none; padding: 9px 14px; font-size: 12px; font-weight: 600; margin-bottom: 12px; border: 1px solid transparent; }
.fs-toast--success { display: block; background: #e6f4ea; color: #155724; border-color: #c3e6cb; }
.fs-toast--error   { display: block; background: #fde8e8; color: #c62828; border-color: #f5c6cb; }

/* Student lookup info card */
.ft-student-info { display: none; background: #f0f4ff; border: 1px solid #d0daf0; padding: 10px 14px; margin-bottom: 10px; font-size: 12px; }
.ft-student-info--visible { display: block; }
.ft-student-info--error { background: #fde8e8; border-color: #f5c6cb; color: #c62828; }
.ft-student-info__name { font-weight: 700; color: #05275C; font-size: 13px; }
.ft-student-info__detail { color: #555; margin-top: 2px; }

/* Required asterisk */
.fs-form-label .req { color: #dc3545; }

/* ===== STUDENT AUTOCOMPLETE ============================================ */
.ft-ac { position: relative; flex: 1; }
.ft-ac__input { width: 100%; border: 1px solid #cdd3de; padding: 7px 32px 7px 9px; font-size: 12px; color: #1a1a2e; background: #fff; box-sizing: border-box; }
.ft-ac__input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }
.ft-ac__input--selected { border-color: #16a34a; background: #f0fdf4; }
.ft-ac__spinner { display: none; position: absolute; right: 9px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px; border: 2px solid #e0e5ed; border-top-color: #174DA4; animation: ftSpin .6s linear infinite; }
.ft-ac__spinner--visible { display: block; }
@keyframes ftSpin { to { transform: translateY(-50%) rotate(360deg); } }
.ft-ac__clear { display: none; position: absolute; right: 9px; top: 50%; transform: translateY(-50%); width: 18px; height: 18px; border: none; background: #e0e5ed; color: #666; font-size: 12px; line-height: 1; cursor: pointer; align-items: center; justify-content: center; }
.ft-ac__clear--visible { display: flex; }
.ft-ac__clear:hover { background: #dc3545; color: #fff; }
.ft-ac__list { display: none; position: absolute; left: 0; right: 0; top: 100%; z-index: 9999; background: #fff; border: 1px solid #174DA4; border-top: none; max-height: 260px; overflow-y: auto; box-shadow: 0 8px 24px rgba(0,0,0,.15); }
.ft-ac__list--visible { display: block; }
.ft-ac__item { padding: 8px 12px; cursor: pointer; border-bottom: 1px solid #f0f2f5; display: flex; align-items: center; gap: 10px; transition: background .1s; }
.ft-ac__item:last-child { border-bottom: none; }
.ft-ac__item:hover, .ft-ac__item--active { background: #e8f0fc; }
.ft-ac__item--active { background: #dbeafe; }
.ft-ac__avatar { width: 32px; height: 32px; background: #05275C; color: #fff; font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; letter-spacing: .5px; }
.ft-ac__info { flex: 1; min-width: 0; }
.ft-ac__name { font-size: 12px; font-weight: 700; color: #1a1a2e; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.ft-ac__name mark { background: #fff3cd; color: #1a1a2e; padding: 0 1px; font-weight: 700; }
.ft-ac__meta { font-size: 10px; color: #888; margin-top: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.ft-ac__meta mark { background: #fff3cd; color: #888; padding: 0 1px; }
.ft-ac__regno { font-size: 10px; font-weight: 600; color: #174DA4; white-space: nowrap; text-align: right; }
.ft-ac__regno mark { background: #fff3cd; color: #174DA4; padding: 0 1px; font-weight: 700; }
.ft-ac__empty { padding: 14px 12px; text-align: center; font-size: 11px; color: #888; }
.ft-ac__hint { padding: 6px 12px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 9px; color: #999; text-align: center; }
.ft-ac__status { font-size: 9px; font-weight: 600; padding: 1px 6px; text-transform: uppercase; letter-spacing: .3px; display: inline-block; margin-top: 2px; }
.ft-ac__status--active { background: #dcfce7; color: #16a34a; }
.ft-ac__status--admitted { background: #dbeafe; color: #174DA4; }
.ft-ac__status--other { background: #f3f4f6; color: #888; }

/* Selected student card */
.ft-selected-student { display: none; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 10px 14px; margin-bottom: 10px; }
.ft-selected-student--visible { display: flex; align-items: center; gap: 12px; }
.ft-selected-student__avatar { width: 38px; height: 38px; background: #05275C; color: #fff; font-size: 13px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ft-selected-student__info { flex: 1; min-width: 0; }
.ft-selected-student__name { font-size: 13px; font-weight: 700; color: #05275C; }
.ft-selected-student__detail { font-size: 11px; color: #555; margin-top: 2px; }
.ft-selected-student__detail span { display: inline-block; margin-right: 12px; }
.ft-selected-student__regno { font-size: 11px; font-weight: 700; color: #16a34a; background: #dcfce7; padding: 2px 8px; white-space: nowrap; }
.ft-selected-student__remove { width: 22px; height: 22px; border: 1px solid #e0e5ed; background: #fff; color: #888; font-size: 14px; cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ft-selected-student__remove:hover { border-color: #dc3545; color: #dc3545; background: #fde8e8; }

/* Responsive */
@media (max-width: 1200px) { .ft-stats { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 800px) { .ft-stats { grid-template-columns: 1fr 1fr; } .ft-stat__val { font-size: 13px; } }
@media (max-width: 500px) { .ft-stats { grid-template-columns: 1fr; } .fm-tabs .fm-tab { padding: 8px 12px; font-size: 11px; } .fs-modal { width: 98vw; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:Button ID="btnExportCsv" runat="server" style="display:none;" OnClick="btnExportCsv_Click" />
<asp:Button ID="btnSearch" runat="server" style="display:none;" OnClick="btnSearch_Click" />
<asp:Button ID="btnReset" runat="server" style="display:none;" OnClick="btnReset_Click" />
<asp:Button ID="btnSaveTransaction" runat="server" style="display:none;" OnClick="btnSaveTransaction_Click" />

<!-- Toast -->
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div class="fs-toast" id="divToast" runat="server"></div>
</asp:Panel>

<!-- Page Header -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Fee Transactions</div>
            <div class="fm-page-header__sub">Student billings, payments, receipts &amp; transaction tracking</div>
        </div>
    </div>
    <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
        <asp:Literal ID="litAcadContext" runat="server" />
        <button type="button" class="ft-btn ft-btn--primary ft-btn--sm" onclick="openAddTxModal();">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            New Transaction
        </button>
        <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" onclick="document.getElementById('<%= btnExportCsv.ClientID %>').click()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
            Export CSV
        </button>
    </div>
</div>

<!-- Tab Nav -->
<div class="fm-tabs">
    <a class="fm-tab" href="FeesManagement.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
        Dashboard
    </a>
    <a class="fm-tab fm-tab--active" href="FeesTransactions.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        Transactions
    </a>
    <a class="fm-tab" href="FeesStructure.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
        Fee Structure &amp; Settings
    </a>
    <a class="fm-tab" href="FeesRegistration.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        Registration
    </a>
</div>

<!-- Stats -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--total">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litTotalTx" runat="server" Text="0" /></div><div class="ft-stat__label">Total Transactions</div></div>
    </div>
    <div class="ft-stat ft-stat--bills">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00695c" stroke-width="2"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litBillTx" runat="server" Text="0" /></div><div class="ft-stat__label">Bills</div></div>
    </div>
    <div class="ft-stat ft-stat--pays">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litPayTx" runat="server" Text="0" /></div><div class="ft-stat__label">Payments</div></div>
    </div>
    <div class="ft-stat ft-stat--bamt">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litBillAmt" runat="server" Text="0" /></div><div class="ft-stat__label">Total Billed</div></div>
    </div>
    <div class="ft-stat ft-stat--pamt">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litPayAmt" runat="server" Text="0" /></div><div class="ft-stat__label">Total Paid</div></div>
    </div>
</div>

<!-- Main Grid Card -->
<div class="ft-card">
    <!-- Filters -->
    <div class="ft-filters">
        <div class="ft-filters__top">
            <div class="ft-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="ft-search-box" placeholder="Search by reg no, student name, description..." AutoPostBack="false" />
            </div>
            <button type="button" class="ft-btn ft-btn--primary ft-btn--sm" onclick="document.getElementById('<%= btnSearch.ClientID %>').click()">Search</button>
            <asp:Label ID="lblRecordCount" runat="server" CssClass="ft-card__meta" Text="0 records" />
        </div>
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Academic Year</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Semesters" />
                    <asp:ListItem Value="1" Text="Semester 1" />
                    <asp:ListItem Value="2" Text="Semester 2" />
                    <asp:ListItem Value="3" Text="Semester 3" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Type</label>
                <asp:DropDownList ID="ddlTransType" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTransType_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Types" />
                    <asp:ListItem Value="Bill" Text="Bills" />
                    <asp:ListItem Value="Payment" Text="Payments" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Billing Item</label>
                <asp:DropDownList ID="ddlBillItem" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBillItem_SelectedIndexChanged" style="min-width:160px;" />
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Post Status</label>
                <asp:DropDownList ID="ddlPostStatus" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPostStatus_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="Posted" Text="Posted" />
                    <asp:ListItem Value="Pending" Text="Pending" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Student Status</label>
                <asp:DropDownList ID="ddlStudStatus" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudStatus_SelectedIndexChanged">
                    <asp:ListItem Value="Active" Text="Active" Selected="True" />
                    <asp:ListItem Value="" Text="All Students" />
                    <asp:ListItem Value="ADMITTED" Text="Admitted" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="min-width:80px;">
                    <asp:ListItem Value="50" Text="50" Selected="True" />
                    <asp:ListItem Value="100" Text="100" />
                    <asp:ListItem Value="200" Text="200" />
                    <asp:ListItem Value="500" Text="500" />
                </asp:DropDownList>
            </div>
            <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
        </div>
    </div>

    <!-- Grid -->
    <div style="overflow-x:auto;">
    <dx:ASPxGridView ID="gvTransactions" runat="server" ClientInstanceName="gvTransactions"
        Width="100%" KeyFieldName="TID"
        AutoGenerateColumns="False"
        EnableCallBacks="true"
        Theme="Glass"
        Settings-VerticalScrollBarMode="Visible"
        Settings-VerticalScrollableHeight="520"
        SettingsPager-Mode="ShowPager"
        SettingsPager-PageSize="50"
        OnPageIndexChanged="gvTransactions_PageIndexChanged">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="TID" Caption="ID" Width="60px" />
            <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="130px">
                <CellStyle ForeColor="#05275C" Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student" Width="180px" />
            <dx:GridViewDataTextColumn FieldName="trans_type" Caption="Type" Width="80px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span class='ft-badge <%# GetTypeClass(Eval("trans_type")) %>'><%# Eval("trans_type") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="item_name" Caption="Billing Item" Width="140px" />
            <dx:GridViewDataTextColumn FieldName="amount" Caption="Amount" Width="110px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span style="font-weight:700;font-variant-numeric:tabular-nums;"><%# FormatAmt(Eval("amount")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="detail" Caption="Description" Width="180px" />
            <dx:GridViewDataTextColumn FieldName="post_status" Caption="Status" Width="80px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span class='ft-badge <%# GetStatusClass(Eval("post_status")) %>'><%# Eval("post_status") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="trans_date" Caption="Date" Width="100px" />
            <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Year" Width="90px" />
            <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" Width="50px" />
        </Columns>
        <SettingsBehavior AllowSort="true" AllowDragDrop="false" />
    </dx:ASPxGridView>
    </div>

    <!-- Footer -->
    <div class="ft-grid-footer">
        <asp:Label ID="lblGridFooter" runat="server" Text="Showing 0 transactions" />
    </div>
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function() {
    var tb = document.getElementById('<%= txtSearch.ClientID %>');
    if (tb) {
        tb.addEventListener('keydown', function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                document.getElementById('<%= btnSearch.ClientID %>').click();
            }
        });
    }
    /* Initialize student autocomplete */
    StudentAC.init();
});

/* ==== Modal helpers ==== */
function openModal(id) {
    var el = document.getElementById(id);
    if (el) el.className = 'fs-modal-overlay fs-modal-overlay--visible';
}
function closeModal(id) {
    var el = document.getElementById(id);
    if (el) el.className = 'fs-modal-overlay';
}

/* ==== Add Transaction Modal ==== */
/* ================================================================
   STUDENT AUTOCOMPLETE ENGINE
   - Searches by name, reg number, or student number
   - Debounced XHR with abort on new keystroke
   - Keyboard navigation (Up/Down/Enter/Escape)
   - Highlights matching text
   - Shows rich student cards
   ================================================================ */
var StudentAC = (function() {
    var input, list, spinner, clearBtn, hfRegNo, card;
    var timer = null, xhr = null, activeIdx = -1, results = [], selectedStudent = null;
    var DEBOUNCE = 250, MIN_CHARS = 2;

    function init() {
        input   = document.getElementById('acInput');
        list    = document.getElementById('acList');
        spinner = document.getElementById('acSpinner');
        clearBtn= document.getElementById('acClear');
        hfRegNo = document.getElementById('<%= hfSelectedRegNo.ClientID %>');
        card    = document.getElementById('selectedStudentCard');
        if (!input) return;

        input.addEventListener('input', onInput);
        input.addEventListener('keydown', onKeyDown);
        input.addEventListener('focus', function() { if (results.length > 0 && !selectedStudent) showList(); });
        document.addEventListener('click', function(e) {
            if (!input.contains(e.target) && !list.contains(e.target)) hideList();
        });
        clearBtn.addEventListener('click', clearSelection);
    }

    function onInput() {
        var q = input.value.trim();
        if (selectedStudent) {
            /* User is editing after selection — deselect */
            deselectStudent();
        }
        if (timer) clearTimeout(timer);
        if (xhr) { xhr.abort(); xhr = null; }
        if (q.length < MIN_CHARS) { hideList(); results = []; return; }
        timer = setTimeout(function() { doSearch(q); }, DEBOUNCE);
    }

    function onKeyDown(e) {
        if (!list.classList.contains('ft-ac__list--visible')) {
            if (e.keyCode === 40 && results.length > 0) { showList(); e.preventDefault(); }
            return;
        }
        if (e.keyCode === 40) { /* Down */
            e.preventDefault(); activeIdx = Math.min(activeIdx + 1, results.length - 1); renderActive();
        } else if (e.keyCode === 38) { /* Up */
            e.preventDefault(); activeIdx = Math.max(activeIdx - 1, 0); renderActive();
        } else if (e.keyCode === 13) { /* Enter */
            e.preventDefault();
            if (activeIdx >= 0 && activeIdx < results.length) selectStudent(results[activeIdx]);
        } else if (e.keyCode === 27) { /* Escape */
            hideList();
        }
    }

    function doSearch(q) {
        showSpinner();
        if (xhr) xhr.abort();
        xhr = new XMLHttpRequest();
        xhr.open('GET', 'FeesTransactions.aspx?ajax=search&q=' + encodeURIComponent(q), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            hideSpinner();
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    results = data.results || [];
                    activeIdx = -1;
                    renderList(q);
                } catch(ex) { results = []; hideList(); }
            }
        };
        xhr.send();
    }

    function statusClass(s) { var u = (s||'').toUpperCase(); if (u === 'ACTIVE') return 'ft-ac__status--active'; if (u === 'ADMITTED') return 'ft-ac__status--admitted'; return 'ft-ac__status--other'; }
    function renderList(query) {
        if (results.length === 0) {
            list.innerHTML = '<div class="ft-ac__empty">'
                + '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>'
                + 'No students found for &ldquo;' + esc(query) + '&rdquo;</div>';
            showList(); return;
        }
        var html = '';
        for (var i = 0; i < results.length; i++) {
            var r = results[i];
            var initials = getInitials(r.name);
            html += '<div class="ft-ac__item' + (i === activeIdx ? ' ft-ac__item--active' : '') + '" data-idx="' + i + '">'
                + '<div class="ft-ac__avatar">' + esc(initials) + '</div>'
                + '<div class="ft-ac__info">'
                + '<div class="ft-ac__name">' + highlight(r.name, query) + '</div>'
                + '<div class="ft-ac__meta">' + highlight(r.programme, query) + ' &middot; ' + esc(r.session) + '</div>'
                + '</div>'
                + '<div style="text-align:right;"><div class="ft-ac__regno">' + highlight(r.regno, query) + '</div>'
                + '<span class="ft-ac__status ' + statusClass(r.status) + '">' + esc(r.status) + '</span></div>'
                + '</div>';
        }
        html += '<div class="ft-ac__hint">' + results.length + (results.length >= 15 ? '+' : '') + ' result' + (results.length !== 1 ? 's' : '') + ' &mdash; type more to refine</div>';
        list.innerHTML = html;

        /* Attach click handlers */
        var items = list.querySelectorAll('.ft-ac__item');
        for (var j = 0; j < items.length; j++) {
            (function(idx) {
                items[idx].addEventListener('click', function() { selectStudent(results[idx]); });
                items[idx].addEventListener('mouseenter', function() { activeIdx = idx; renderActive(); });
            })(j);
        }
        showList();
    }

    function renderActive() {
        var items = list.querySelectorAll('.ft-ac__item');
        for (var i = 0; i < items.length; i++) {
            items[i].className = 'ft-ac__item' + (i === activeIdx ? ' ft-ac__item--active' : '');
        }
        if (activeIdx >= 0 && items[activeIdx]) {
            items[activeIdx].scrollIntoView({ block: 'nearest' });
        }
    }

    function selectStudent(student) {
        selectedStudent = student;
        hideList();
        results = [];
        input.value = student.name + ' (' + student.regno + ')';
        input.classList.add('ft-ac__input--selected');
        hfRegNo.value = student.regno;
        clearBtn.classList.add('ft-ac__clear--visible');

        /* Show selected card */
        var initials = getInitials(student.name);
        card.innerHTML = '<div class="ft-selected-student__avatar">' + esc(initials) + '</div>'
            + '<div class="ft-selected-student__info">'
            + '<div class="ft-selected-student__name">' + esc(student.name) + '</div>'
            + '<div class="ft-selected-student__detail">'
            + '<span>' + esc(student.programme) + '</span>'
            + '<span>' + esc(student.session) + '</span>'
            + (student.studno ? '<span>No: ' + esc(student.studno) + '</span>' : '')
            + '<span class="ft-ac__status ' + statusClass(student.status) + '">' + esc(student.status) + '</span>'
            + '</div></div>'
            + '<div class="ft-selected-student__regno">' + esc(student.regno) + '</div>'
            + '<button type="button" class="ft-selected-student__remove" title="Remove" onclick="StudentAC.clear();">&times;</button>';
        card.className = 'ft-selected-student ft-selected-student--visible';
    }

    function deselectStudent() {
        selectedStudent = null;
        hfRegNo.value = '';
        input.classList.remove('ft-ac__input--selected');
        clearBtn.classList.remove('ft-ac__clear--visible');
        card.className = 'ft-selected-student';
        card.innerHTML = '';
    }

    function clearSelection() {
        deselectStudent();
        input.value = '';
        input.focus();
        hideList();
        results = [];
    }

    function showList()  { list.classList.add('ft-ac__list--visible'); }
    function hideList()  { list.classList.remove('ft-ac__list--visible'); activeIdx = -1; }
    function showSpinner(){ spinner.classList.add('ft-ac__spinner--visible'); clearBtn.classList.remove('ft-ac__clear--visible'); }
    function hideSpinner(){ spinner.classList.remove('ft-ac__spinner--visible'); if (selectedStudent) clearBtn.classList.add('ft-ac__clear--visible'); }

    function highlight(text, query) {
        if (!text || !query) return esc(text || '');
        /* Split query into words and highlight each */
        var words = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').split(/\s+/).filter(function(w) { return w.length > 0; });
        if (words.length === 0) return esc(text);
        var re = new RegExp('(' + words.join('|') + ')', 'gi');
        /* Escape first, then wrap matches */
        var parts = text.split(re);
        var out = '';
        for (var i = 0; i < parts.length; i++) {
            if (re.test(parts[i])) { re.lastIndex = 0; out += '<mark>' + esc(parts[i]) + '</mark>'; }
            else { out += esc(parts[i]); }
        }
        return out;
    }

    function esc(str) {
        var d = document.createElement('div'); d.appendChild(document.createTextNode(str || '')); return d.innerHTML;
    }

    function getInitials(name) {
        if (!name) return '?';
        var p = name.trim().split(/\s+/);
        if (p.length >= 2) return (p[0][0] + p[p.length-1][0]).toUpperCase();
        return p[0][0].toUpperCase();
    }

    function getSelectedRegNo() { return selectedStudent ? selectedStudent.regno : ''; }
    function isStudentSelected() { return !!selectedStudent; }

    return { init: init, clear: clearSelection, getRegNo: getSelectedRegNo, isSelected: isStudentSelected, select: selectStudent };
})();

function openAddTxModal() {
    /* Reset form fields */
    var f = document.getElementById('addTxForm');
    if (f) {
        var inputs = f.querySelectorAll('input[type="text"], input[type="number"]');
        for (var i = 0; i < inputs.length; i++) inputs[i].value = '';
    }
    /* Set date to today */
    var dtField = document.getElementById('<%= txtTxDate.ClientID %>');
    if (dtField) {
        var now = new Date();
        var m = ('0' + (now.getMonth() + 1)).slice(-2);
        var d = ('0' + now.getDate()).slice(-2);
        dtField.value = now.getFullYear() + '-' + m + '-' + d;
    }
    /* Reset student autocomplete */
    StudentAC.clear();
    /* Reset selects to defaults */
    var ddlType = document.getElementById('<%= ddlTxTransType.ClientID %>');
    if (ddlType) ddlType.selectedIndex = 0;
    var ddlStatus = document.getElementById('<%= ddlTxPostStatus.ClientID %>');
    if (ddlStatus) ddlStatus.selectedIndex = 0;
    /* Default academic year & semester from filters */
    var filterYear = document.getElementById('<%= ddlAcadYear.ClientID %>');
    var txYear = document.getElementById('<%= ddlTxAcadYear.ClientID %>');
    if (filterYear && txYear && filterYear.value) {
        for (var j = 0; j < txYear.options.length; j++) {
            if (txYear.options[j].value === filterYear.value) { txYear.selectedIndex = j; break; }
        }
    }
    var filterSem = document.getElementById('<%= ddlSemester.ClientID %>');
    var txSem = document.getElementById('<%= ddlTxSemester.ClientID %>');
    if (filterSem && txSem && filterSem.value) {
        for (var k = 0; k < txSem.options.length; k++) {
            if (txSem.options[k].value === filterSem.value) { txSem.selectedIndex = k; break; }
        }
    }
    /* Clear amount */
    var amt = document.getElementById('<%= txtTxAmount.ClientID %>');
    if (amt) amt.value = '';
    /* Clear detail */
    var det = document.getElementById('<%= txtTxDetail.ClientID %>');
    if (det) det.value = '';
    /* Open */
    openModal('modal-add-tx');
    /* Focus search after modal opens */
    setTimeout(function() { var inp = document.getElementById('acInput'); if (inp) inp.focus(); }, 150);
}

function autoFillDetail() {
    var ddlType = document.getElementById('<%= ddlTxTransType.ClientID %>');
    var ddlItem = document.getElementById('<%= ddlTxBillItem.ClientID %>');
    var det = document.getElementById('<%= txtTxDetail.ClientID %>');
    if (!ddlType || !ddlItem || !det) return;
    var typeTxt = ddlType.options[ddlType.selectedIndex] ? ddlType.options[ddlType.selectedIndex].text : '';
    var itemTxt = ddlItem.options[ddlItem.selectedIndex] ? ddlItem.options[ddlItem.selectedIndex].text : '';
    if (typeTxt && itemTxt && itemTxt !== '-- Select Item --') {
        det.value = typeTxt + ' - ' + itemTxt;
    }
}

function validateAndSaveTx() {
    var errors = [];
    var regno = StudentAC.getRegNo();
    var amount = document.getElementById('<%= txtTxAmount.ClientID %>').value.trim();
    var transType = document.getElementById('<%= ddlTxTransType.ClientID %>').value;
    var billItem = document.getElementById('<%= ddlTxBillItem.ClientID %>').value;
    var acadYear = document.getElementById('<%= ddlTxAcadYear.ClientID %>').value;
    var semester = document.getElementById('<%= ddlTxSemester.ClientID %>').value;
    var txDate = document.getElementById('<%= txtTxDate.ClientID %>').value.trim();
    var detail = document.getElementById('<%= txtTxDetail.ClientID %>').value.trim();

    if (!regno) errors.push('Please select a student from the search results.');
    if (!transType) errors.push('Transaction Type is required.');
    if (!billItem) errors.push('Billing Item is required.');
    if (!amount || isNaN(parseFloat(amount)) || parseFloat(amount) <= 0) errors.push('Amount must be a positive number.');
    if (!acadYear) errors.push('Academic Year is required.');
    if (!semester) errors.push('Semester is required.');
    if (!txDate) errors.push('Transaction Date is required.');
    if (!detail) errors.push('Description is required.');
    if (detail.length > 250) errors.push('Description must be 250 characters or less.');

    /* Write regno to hidden field before submit */
    var hf = document.getElementById('<%= hfSelectedRegNo.ClientID %>');
    if (hf) hf.value = regno;

    if (errors.length > 0) {
        alert(errors.join('\n'));
        return;
    }

    /* Prevent double-click */
    var saveBtn = document.getElementById('btnModalSave');
    if (saveBtn) { saveBtn.disabled = true; saveBtn.innerText = 'Saving...'; }

    document.getElementById('<%= btnSaveTransaction.ClientID %>').click();
}
</script>

<!-- ============= ADD TRANSACTION MODAL ============= -->
<div id="modal-add-tx" class="fs-modal-overlay">
<div class="fs-modal">
    <div class="fs-modal__header">
        <div class="fs-modal__title">New Fee Transaction</div>
        <button type="button" class="fs-modal__close" onclick="closeModal('modal-add-tx');">&times;</button>
    </div>
    <div class="fs-modal__body" id="addTxForm">

        <!-- Student Search (autocomplete) -->
        <div class="fs-form-row">
            <div class="fs-form-group" style="flex:2;">
                <label class="fs-form-label">Student <span class="req">*</span></label>
                <div class="ft-ac" id="acWrap">
                    <input type="text" id="acInput" class="ft-ac__input" autocomplete="off" spellcheck="false"
                           placeholder="Type name, reg number or student number..." maxlength="80" />
                    <div class="ft-ac__spinner" id="acSpinner"></div>
                    <button type="button" class="ft-ac__clear" id="acClear" title="Clear selection">&times;</button>
                    <div class="ft-ac__list" id="acList"></div>
                </div>
                <asp:HiddenField ID="hfSelectedRegNo" runat="server" />
            </div>
        </div>

        <!-- Selected Student Card -->
        <div class="ft-selected-student" id="selectedStudentCard"></div>

        <!-- Transaction Type + Billing Item -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Transaction Type <span class="req">*</span></label>
                <asp:DropDownList ID="ddlTxTransType" runat="server" CssClass="fs-form-input" onchange="autoFillDetail();">
                    <asp:ListItem Value="" Text="-- Select Type --" />
                    <asp:ListItem Value="Bill" Text="Bill" />
                    <asp:ListItem Value="Payment" Text="Payment" />
                </asp:DropDownList>
            </div>
            <div class="fs-form-group">
                <label class="fs-form-label">Billing Item <span class="req">*</span></label>
                <asp:DropDownList ID="ddlTxBillItem" runat="server" CssClass="fs-form-input" onchange="autoFillDetail();" />
            </div>
        </div>

        <!-- Amount + Date -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Amount (UGX) <span class="req">*</span></label>
                <asp:TextBox ID="txtTxAmount" runat="server" CssClass="fs-form-input" placeholder="0" />
            </div>
            <div class="fs-form-group">
                <label class="fs-form-label">Transaction Date <span class="req">*</span></label>
                <asp:TextBox ID="txtTxDate" runat="server" CssClass="fs-form-input" />
            </div>
        </div>

        <!-- Academic Year + Semester -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Academic Year <span class="req">*</span></label>
                <asp:DropDownList ID="ddlTxAcadYear" runat="server" CssClass="fs-form-input" />
            </div>
            <div class="fs-form-group">
                <label class="fs-form-label">Semester <span class="req">*</span></label>
                <asp:DropDownList ID="ddlTxSemester" runat="server" CssClass="fs-form-input">
                    <asp:ListItem Value="" Text="-- Select --" />
                    <asp:ListItem Value="1" Text="Semester 1" />
                    <asp:ListItem Value="2" Text="Semester 2" />
                    <asp:ListItem Value="3" Text="Semester 3" />
                </asp:DropDownList>
            </div>
        </div>

        <!-- Description -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Description <span class="req">*</span></label>
                <asp:TextBox ID="txtTxDetail" runat="server" CssClass="fs-form-input" MaxLength="250" placeholder="Auto-filled or type a description" />
            </div>
        </div>

        <!-- Post Status -->
        <div class="fs-form-row">
            <div class="fs-form-group" style="max-width:200px;">
                <label class="fs-form-label">Post Status</label>
                <asp:DropDownList ID="ddlTxPostStatus" runat="server" CssClass="fs-form-input">
                    <asp:ListItem Value="Pending" Text="Pending" Selected="True" />
                    <asp:ListItem Value="Posted" Text="Posted" />
                </asp:DropDownList>
            </div>
        </div>

    </div>
    <div class="fs-modal__footer">
        <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-add-tx');">Cancel</button>
        <button type="button" id="btnModalSave" class="fs-btn fs-btn--primary" onclick="validateAndSaveTx();">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Save Transaction
        </button>
    </div>
</div>
</div>
<!-- ============= /ADD TRANSACTION MODAL ============= -->

</asp:Content>
