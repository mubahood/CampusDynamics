<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesTransactions.aspx.cs" Inherits="COOPERP_NewScreens_FeesTransactions" Title="Fee Transactions - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== FEE TRANSACTIONS ================================================ */

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

/* === Custom Data Table ================================================= */
.ft-table-wrap { overflow: auto; max-height: 560px; border-bottom: 1px solid #e0e5ed; position: relative; }
.ft-table { width: 100%; border-collapse: collapse; min-width: 1200px; font-size: 12px; }
.ft-table thead tr { position: sticky; top: 0; z-index: 10; }
.ft-table thead th { background: #f5f7fa; color: #555; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; font-weight: 600; padding: 9px 12px; border-bottom: 2px solid #e0e5ed; white-space: nowrap; box-shadow: 0 2px 0 #e0e5ed; }
.ft-table tbody tr { border-bottom: 1px solid #f0f2f5; transition: background .08s; }
.ft-table tbody tr:nth-child(even) { background: #f9fafb; }
.ft-table tbody tr:hover, .ft-table tbody tr:nth-child(even):hover { background: #eef2fc; }
.ft-table tbody td { padding: 8px 12px; vertical-align: middle; color: #1a1a2e; font-size: 11px; }
/* Column widths */
.ft-col-id    { width: 62px;  }
.ft-col-regno { width: 135px; white-space: nowrap; }
.ft-col-name  { width: 185px; }
.ft-col-type  { width: 82px;  white-space: nowrap; }
.ft-col-item  { width: 148px; }
.ft-col-amt   { width: 120px; white-space: nowrap; text-align: right; }
.ft-col-detail{ min-width: 160px; }
.ft-col-status{ width: 82px;  white-space: nowrap; }
.ft-col-date  { width: 92px;  white-space: nowrap; }
.ft-col-year  { width: 92px;  white-space: nowrap; }
.ft-col-sem   { width: 46px;  text-align: center; white-space: nowrap; }
.ft-col-action{ width: 44px;  text-align: center; white-space: nowrap; }
td.ft-col-regno { color: #05275C; font-weight: 700; }
td.ft-col-amt   { font-weight: 700; font-variant-numeric: tabular-nums; }
td.ft-col-detail { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 230px; }
/* Pager */
.ft-pager { display: flex; align-items: center; justify-content: space-between; padding: 8px 14px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 11px; color: #666; flex-wrap: wrap; gap: 8px; }
.ft-pager__info strong { color: #05275C; }
.ft-pager__btns { display: flex; gap: 3px; align-items: center; flex-wrap: wrap; }
.ft-pager__btn { min-width: 30px; padding: 4px 8px; font-size: 11px; font-weight: 600; border: 1px solid #e0e5ed; background: #fff; color: #444; cursor: pointer; font-family: inherit; line-height: 1.4; text-align: center; }
.ft-pager__btn:hover:not([disabled]) { border-color: #174DA4; color: #174DA4; background: #eef2fc; }
.ft-pager__btn[disabled] { opacity: .4; cursor: not-allowed; }
.ft-pager__btn--active { background: #05275C !important; color: #fff !important; border-color: #05275C !important; }
.ft-pager__ellipsis { padding: 4px 2px; color: #aaa; font-size: 12px; }

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

/* Row Action Button */
.ft-row-action { width:28px; height:28px; border:1px solid transparent; background:none; color:#666; font-size:18px; line-height:1; cursor:pointer; border-radius:4px; display:inline-flex; align-items:center; justify-content:center; transition:all .15s; }
.ft-row-action:hover { background:#eef1f6; border-color:#d0d5dd; color:#05275C; }

/* Action Popover (position:fixed to avoid clipping) */
.ft-action-pop { position:fixed; z-index:99999; background:#fff; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,.16),0 2px 8px rgba(0,0,0,.08); border:1px solid #e0e5ed; min-width:170px; padding:4px 0; display:none; }
.ft-action-pop--visible { display:block; }
.ft-action-pop__item { display:flex; align-items:center; gap:8px; padding:9px 16px; font-size:13px; color:#333; cursor:pointer; border:none; background:none; width:100%; text-align:left; transition:background .12s; font-family:inherit; }
.ft-action-pop__item:hover { background:#f0f4ff; color:#05275C; }
.ft-action-pop__item--danger { color:#dc3545; }
.ft-action-pop__item--danger:hover { background:#fde8e8; color:#b91c1c; }
.ft-action-pop__sep { height:1px; background:#e5e7eb; margin:4px 0; }

/* Delete Confirmation Modal */
.ft-confirm-overlay { position:fixed; z-index:100000; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.45); display:none; align-items:center; justify-content:center; }
.ft-confirm-overlay--visible { display:flex; }
.ft-confirm { background:#fff; border-radius:10px; box-shadow:0 12px 40px rgba(0,0,0,.2); width:420px; max-width:95vw; overflow:hidden; animation:ftConfirmIn .2s ease; }
@keyframes ftConfirmIn { from { transform:scale(.95); opacity:0; } to { transform:scale(1); opacity:1; } }
.ft-confirm__header { padding:16px 20px; background:#fde8e8; border-bottom:1px solid #fecaca; display:flex; align-items:center; gap:10px; }
.ft-confirm__icon { width:36px; height:36px; background:#dc3545; color:#fff; border-radius:8px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.ft-confirm__title { font-size:15px; font-weight:700; color:#991b1b; }
.ft-confirm__body { padding:20px; font-size:13px; color:#333; line-height:1.6; }
.ft-confirm__detail { background:#f9fafb; border:1px solid #e5e7eb; border-radius:6px; padding:10px 14px; margin-top:10px; }
.ft-confirm__detail dt { font-size:11px; color:#888; text-transform:uppercase; letter-spacing:.5px; margin-top:6px; }
.ft-confirm__detail dt:first-child { margin-top:0; }
.ft-confirm__detail dd { margin:2px 0 0 0; font-weight:600; color:#05275C; }
.ft-confirm__footer { padding:12px 20px; border-top:1px solid #e5e7eb; display:flex; justify-content:flex-end; gap:8px; }
.ft-confirm__btn { padding:8px 18px; border-radius:6px; font-size:13px; font-weight:600; cursor:pointer; border:1px solid transparent; transition:all .15s; font-family:inherit; }
.ft-confirm__btn--cancel { background:#fff; border-color:#d0d5dd; color:#555; }
.ft-confirm__btn--cancel:hover { background:#f5f5f5; }
.ft-confirm__btn--delete { background:#dc3545; color:#fff; }
.ft-confirm__btn--delete:hover { background:#b91c1c; }

/* Responsive */
@media (max-width: 1200px) { .ft-stats { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 800px) { .ft-stats { grid-template-columns: 1fr 1fr; } .ft-stat__val { font-size: 13px; } }
@media (max-width: 500px) { .ft-stats { grid-template-columns: 1fr; } .fs-modal { width: 98vw; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:Button ID="btnExportCsv" runat="server" style="display:none;" OnClick="btnExportCsv_Click" />
<asp:Button ID="btnSearch" runat="server" style="display:none;" OnClick="btnSearch_Click" />
<asp:Button ID="btnReset" runat="server" style="display:none;" OnClick="btnReset_Click" />
<asp:Button ID="btnSaveTransaction" runat="server" style="display:none;" OnClick="btnSaveTransaction_Click" />
<asp:Button ID="btnEditTransaction" runat="server" style="display:none;" OnClick="btnEditTransaction_Click" />
<asp:Button ID="btnDeleteTransaction" runat="server" style="display:none;" OnClick="btnDeleteTransaction_Click" />
<asp:HiddenField ID="hfEditTID" runat="server" />
<asp:HiddenField ID="hfDeleteTID" runat="server" />
<asp:HiddenField ID="hfPageIndex" runat="server" Value="0" />
<asp:Button ID="btnGoToPage" runat="server" style="display:none;" OnClick="btnGoToPage_Click" />

<!-- Toast -->
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div class="fs-toast" id="divToast" runat="server"></div>
</asp:Panel>

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
            <asp:Literal ID="litAcadContext" runat="server" />
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
                    <asp:ListItem Value="" Text="All Students" Selected="True" />
                    <asp:ListItem Value="Active" Text="Active" />
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
            <span style="flex:1;"></span>
            <button type="button" class="ft-btn ft-btn--primary ft-btn--sm" style="align-self:flex-end;" onclick="openAddTxModal();">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                New Transaction
            </button>
            <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnExportCsv.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                Export CSV
            </button>
        </div>
    </div>

    <!-- Data Table (single scroll container — sticky header, consistent H+V scroll) -->
    <div class="ft-table-wrap">
        <table class="ft-table">
            <colgroup>
                <col class="ft-col-id"><col class="ft-col-regno"><col class="ft-col-name">
                <col class="ft-col-type"><col class="ft-col-item"><col class="ft-col-amt">
                <col class="ft-col-detail"><col class="ft-col-status"><col class="ft-col-date">
                <col class="ft-col-year"><col class="ft-col-sem"><col class="ft-col-action">
            </colgroup>
            <thead>
                <tr>
                    <th class="ft-col-id">ID</th>
                    <th class="ft-col-regno">Reg No</th>
                    <th class="ft-col-name">Student</th>
                    <th class="ft-col-type">Type</th>
                    <th class="ft-col-item">Billing Item</th>
                    <th class="ft-col-amt">Amount</th>
                    <th class="ft-col-detail">Description</th>
                    <th class="ft-col-status">Status</th>
                    <th class="ft-col-date">Date</th>
                    <th class="ft-col-year">Year</th>
                    <th class="ft-col-sem">Sem</th>
                    <th class="ft-col-action"></th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptTransactions" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="ft-col-id"><%# Eval("TID") %></td>
                            <td class="ft-col-regno"><%# HttpUtility.HtmlEncode(SafeStr(Eval("regno"))) %></td>
                            <td class="ft-col-name"><%# HttpUtility.HtmlEncode(SafeStr(Eval("student_name"))) %></td>
                            <td class="ft-col-type"><span class='ft-badge <%# GetTypeClass(Eval("trans_type")) %>'><%# HttpUtility.HtmlEncode(SafeStr(Eval("trans_type"))) %></span></td>
                            <td class="ft-col-item"><%# HttpUtility.HtmlEncode(SafeStr(Eval("item_name"))) %></td>
                            <td class="ft-col-amt"><%# FormatAmt(Eval("amount")) %></td>
                            <td class="ft-col-detail" title='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("detail"))) %>'><%# HttpUtility.HtmlEncode(SafeStr(Eval("detail"))) %></td>
                            <td class="ft-col-status"><span class='ft-badge <%# GetStatusClass(Eval("post_status")) %>'><%# HttpUtility.HtmlEncode(SafeStr(Eval("post_status"))) %></span></td>
                            <td class="ft-col-date"><%# FormatDateShort(Eval("trans_date")) %></td>
                            <td class="ft-col-year"><%# HttpUtility.HtmlEncode(SafeStr(Eval("acadyear"))) %></td>
                            <td class="ft-col-sem"><%# Eval("semester") %></td>
                            <td class="ft-col-action">
                                <button type="button" class="ft-row-action"
                                    data-tid='<%# Eval("TID") %>'
                                    data-regno='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("regno"))) %>'
                                    data-name='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("student_name"))) %>'
                                    data-type='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("trans_type"))) %>'
                                    data-itemcode='<%# Eval("item_code") %>'
                                    data-amount='<%# Eval("amount") %>'
                                    data-detail='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("detail"))) %>'
                                    data-status='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("post_status"))) %>'
                                    data-date='<%# FormatDateISO(Eval("trans_date")) %>'
                                    data-year='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("acadyear"))) %>'
                                    data-sem='<%# Eval("semester") %>'
                                    onclick="showRowAction(event,this)">&#8942;</button>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                    <tr><td colspan="12" style="padding:44px 20px;text-align:center;color:#999;font-size:13px;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2" style="display:block;margin:0 auto 8px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        No transactions match your current filters.
                    </td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>

    <!-- Pager -->
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Label ID="lblGridFooter" runat="server" Text="" /></span>
        <asp:Literal ID="litPager" runat="server" />
    </div>
</div>

<!-- Action Popover (position:fixed) -->
<div class="ft-action-pop" id="actionPop">
    <button type="button" class="ft-action-pop__item" onclick="openEditTx()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
        Edit Transaction
    </button>
    <div class="ft-action-pop__sep"></div>
    <button type="button" class="ft-action-pop__item ft-action-pop__item--danger" onclick="confirmDeleteTx()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        Delete Transaction
    </button>
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

/* ==== Row Action Popover ==== */
var _activeRowData = null;

function showRowAction(evt, btn) {
    evt.stopPropagation();
    evt.preventDefault();
    var pop = document.getElementById('actionPop');

    // Collect data from button attributes
    _activeRowData = {
        tid: btn.getAttribute('data-tid'),
        regno: btn.getAttribute('data-regno'),
        name: btn.getAttribute('data-name'),
        type: btn.getAttribute('data-type'),
        itemcode: btn.getAttribute('data-itemcode'),
        amount: btn.getAttribute('data-amount'),
        detail: btn.getAttribute('data-detail'),
        status: btn.getAttribute('data-status'),
        date: btn.getAttribute('data-date'),
        year: btn.getAttribute('data-year'),
        sem: btn.getAttribute('data-sem')
    };

    // Position using fixed coords (avoids clipping by overflow containers)
    var rect = btn.getBoundingClientRect();
    var popH = 94;
    var spaceBelow = window.innerHeight - rect.bottom;

    pop.style.left = Math.max(4, rect.left - 140) + 'px';
    if (spaceBelow < popH + 10) {
        pop.style.top = (rect.top - popH - 4) + 'px';
    } else {
        pop.style.top = (rect.bottom + 4) + 'px';
    }
    pop.classList.add('ft-action-pop--visible');
}

function hideRowAction() {
    var pop = document.getElementById('actionPop');
    if (pop) pop.classList.remove('ft-action-pop--visible');
}

// Close popover on outside click
document.addEventListener('click', function(e) {
    var pop = document.getElementById('actionPop');
    if (pop && pop.classList.contains('ft-action-pop--visible')) {
        if (!pop.contains(e.target) && !e.target.classList.contains('ft-row-action')) {
            hideRowAction();
        }
    }
});
// Close popover on scroll
window.addEventListener('scroll', hideRowAction, true);

/* ==== Edit Transaction ==== */
function openEditTx() {
    hideRowAction();
    if (!_activeRowData) return;
    var d = _activeRowData;

    // TID badge
    document.getElementById('editTidBadge').textContent = '#' + d.tid;

    // Student info (read-only)
    var initials = _getInitials(d.name);
    document.getElementById('editStudentAvatar').textContent = initials;
    document.getElementById('editStudentName').textContent = d.name;
    document.getElementById('editStudentRegno').textContent = d.regno;

    // Hidden field
    document.getElementById('<%= hfEditTID.ClientID %>').value = d.tid;

    // Set dropdowns
    _setSelect('<%= ddlEditTransType.ClientID %>', d.type);
    _setSelect('<%= ddlEditBillItem.ClientID %>', d.itemcode);
    _setSelect('<%= ddlEditAcadYear.ClientID %>', d.year);
    _setSelect('<%= ddlEditSemester.ClientID %>', d.sem);
    _setSelect('<%= ddlEditPostStatus.ClientID %>', d.status);

    // Text fields
    document.getElementById('<%= txtEditAmount.ClientID %>').value = d.amount;
    document.getElementById('<%= txtEditDate.ClientID %>').value = d.date;
    document.getElementById('<%= txtEditDetail.ClientID %>').value = d.detail;

    // Reset save button
    var btn = document.getElementById('btnModalEdit');
    if (btn) {
        btn.disabled = false;
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Update Transaction';
    }

    openModal('modal-edit-tx');
}

function _setSelect(id, val) {
    var sel = document.getElementById(id);
    if (!sel) return;
    for (var i = 0; i < sel.options.length; i++) {
        if (sel.options[i].value == val) { sel.selectedIndex = i; return; }
    }
}

function _getInitials(name) {
    if (!name) return '?';
    var p = name.trim().split(/\s+/);
    if (p.length >= 2) return (p[0][0] + p[p.length-1][0]).toUpperCase();
    return p[0][0].toUpperCase();
}

function validateAndEditTx() {
    var errors = [];
    var amount = document.getElementById('<%= txtEditAmount.ClientID %>').value.trim();
    var transType = document.getElementById('<%= ddlEditTransType.ClientID %>').value;
    var billItem = document.getElementById('<%= ddlEditBillItem.ClientID %>').value;
    var acadYear = document.getElementById('<%= ddlEditAcadYear.ClientID %>').value;
    var semester = document.getElementById('<%= ddlEditSemester.ClientID %>').value;
    var txDate = document.getElementById('<%= txtEditDate.ClientID %>').value.trim();
    var detail = document.getElementById('<%= txtEditDetail.ClientID %>').value.trim();

    if (!transType) errors.push('Transaction Type is required.');
    if (!billItem) errors.push('Billing Item is required.');
    if (!amount || isNaN(parseFloat(amount)) || parseFloat(amount) <= 0) errors.push('Amount must be a positive number.');
    if (!acadYear) errors.push('Academic Year is required.');
    if (!semester) errors.push('Semester is required.');
    if (!txDate) errors.push('Transaction Date is required.');
    if (!detail) errors.push('Description is required.');
    if (detail.length > 250) errors.push('Description must be 250 characters or less.');

    if (errors.length > 0) { alert(errors.join('\n')); return; }

    var btn = document.getElementById('btnModalEdit');
    if (btn) { btn.disabled = true; btn.innerText = 'Saving...'; }

    document.getElementById('<%= btnEditTransaction.ClientID %>').click();
}

/* ==== Delete Transaction ==== */
function confirmDeleteTx() {
    hideRowAction();
    if (!_activeRowData) return;
    var d = _activeRowData;

    document.getElementById('<%= hfDeleteTID.ClientID %>').value = d.tid;

    var dl = document.getElementById('deleteDetail');
    dl.innerHTML = '<dt>Transaction ID</dt><dd>#' + _esc(d.tid) + '</dd>'
        + '<dt>Student</dt><dd>' + _esc(d.name) + ' (' + _esc(d.regno) + ')</dd>'
        + '<dt>Type</dt><dd>' + _esc(d.type) + '</dd>'
        + '<dt>Amount</dt><dd>UGX ' + _fmtNum(d.amount) + '</dd>'
        + '<dt>Date</dt><dd>' + _esc(d.date) + '</dd>';

    var btn = document.getElementById('btnConfirmDelete');
    if (btn) {
        btn.disabled = false;
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg> Delete';
    }

    document.getElementById('deleteConfirm').classList.add('ft-confirm-overlay--visible');
}

function closeDeleteConfirm() {
    document.getElementById('deleteConfirm').classList.remove('ft-confirm-overlay--visible');
}

function doDeleteTx() {
    var btn = document.getElementById('btnConfirmDelete');
    if (btn) { btn.disabled = true; btn.innerText = 'Deleting...'; }
    document.getElementById('<%= btnDeleteTransaction.ClientID %>').click();
}

function _fmtNum(x) { if (!x) return '0'; return parseFloat(x).toLocaleString(); }
function _esc(str) { var d = document.createElement('div'); d.appendChild(document.createTextNode(str || '')); return d.innerHTML; }

/* ==== Pager navigation ==== */
function goToPage(idx) {
    if (idx < 0) return;
    document.getElementById('<%= hfPageIndex.ClientID %>').value = idx;
    document.getElementById('<%= btnGoToPage.ClientID %>').click();
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

<!-- ============= EDIT TRANSACTION MODAL ============= -->
<div id="modal-edit-tx" class="fs-modal-overlay">
<div class="fs-modal">
    <div class="fs-modal__header" style="background:#174DA4;">
        <div class="fs-modal__title" style="color:#fff;">Edit Transaction <span id="editTidBadge" style="font-size:11px;background:rgba(255,255,255,.2);padding:2px 8px;border-radius:10px;margin-left:8px;"></span></div>
        <button type="button" class="fs-modal__close" onclick="closeModal('modal-edit-tx');" style="color:#fff;">&times;</button>
    </div>
    <div class="fs-modal__body" id="editTxForm">

        <!-- Student (Read-only) -->
        <div class="fs-form-row">
            <div class="fs-form-group" style="flex:2;">
                <label class="fs-form-label">Student</label>
                <div id="editStudentInfo" style="display:flex;align-items:center;gap:10px;padding:8px 12px;background:#f0f4ff;border:1px solid #d0d5dd;border-radius:6px;">
                    <div id="editStudentAvatar" style="width:32px;height:32px;background:#05275C;color:#fff;font-size:12px;font-weight:700;display:flex;align-items:center;justify-content:center;border-radius:4px;flex-shrink:0;"></div>
                    <div style="flex:1;min-width:0;">
                        <div id="editStudentName" style="font-size:13px;font-weight:700;color:#05275C;"></div>
                        <div id="editStudentRegno" style="font-size:11px;color:#555;"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Transaction Type + Billing Item -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Transaction Type <span class="req">*</span></label>
                <asp:DropDownList ID="ddlEditTransType" runat="server" CssClass="fs-form-input">
                    <asp:ListItem Value="" Text="-- Select Type --" />
                    <asp:ListItem Value="Bill" Text="Bill" />
                    <asp:ListItem Value="Payment" Text="Payment" />
                </asp:DropDownList>
            </div>
            <div class="fs-form-group">
                <label class="fs-form-label">Billing Item <span class="req">*</span></label>
                <asp:DropDownList ID="ddlEditBillItem" runat="server" CssClass="fs-form-input" />
            </div>
        </div>

        <!-- Amount + Date -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Amount (UGX) <span class="req">*</span></label>
                <asp:TextBox ID="txtEditAmount" runat="server" CssClass="fs-form-input" placeholder="0" />
            </div>
            <div class="fs-form-group">
                <label class="fs-form-label">Transaction Date <span class="req">*</span></label>
                <asp:TextBox ID="txtEditDate" runat="server" CssClass="fs-form-input" />
            </div>
        </div>

        <!-- Academic Year + Semester -->
        <div class="fs-form-row">
            <div class="fs-form-group">
                <label class="fs-form-label">Academic Year <span class="req">*</span></label>
                <asp:DropDownList ID="ddlEditAcadYear" runat="server" CssClass="fs-form-input" />
            </div>
            <div class="fs-form-group">
                <label class="fs-form-label">Semester <span class="req">*</span></label>
                <asp:DropDownList ID="ddlEditSemester" runat="server" CssClass="fs-form-input">
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
                <asp:TextBox ID="txtEditDetail" runat="server" CssClass="fs-form-input" MaxLength="250" />
            </div>
        </div>

        <!-- Post Status -->
        <div class="fs-form-row">
            <div class="fs-form-group" style="max-width:200px;">
                <label class="fs-form-label">Post Status</label>
                <asp:DropDownList ID="ddlEditPostStatus" runat="server" CssClass="fs-form-input">
                    <asp:ListItem Value="Pending" Text="Pending" />
                    <asp:ListItem Value="Posted" Text="Posted" />
                </asp:DropDownList>
            </div>
        </div>

    </div>
    <div class="fs-modal__footer">
        <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-edit-tx');">Cancel</button>
        <button type="button" id="btnModalEdit" class="fs-btn fs-btn--primary" onclick="validateAndEditTx();">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Update Transaction
        </button>
    </div>
</div>
</div>
<!-- ============= /EDIT TRANSACTION MODAL ============= -->

<!-- ============= DELETE CONFIRMATION ============= -->
<div class="ft-confirm-overlay" id="deleteConfirm">
<div class="ft-confirm">
    <div class="ft-confirm__header">
        <div class="ft-confirm__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        </div>
        <div class="ft-confirm__title">Delete Transaction</div>
    </div>
    <div class="ft-confirm__body">
        Are you sure you want to delete this transaction? This action <strong>cannot be undone</strong>.
        <dl class="ft-confirm__detail" id="deleteDetail"></dl>
    </div>
    <div class="ft-confirm__footer">
        <button type="button" class="ft-confirm__btn ft-confirm__btn--cancel" onclick="closeDeleteConfirm()">Cancel</button>
        <button type="button" class="ft-confirm__btn ft-confirm__btn--delete" id="btnConfirmDelete" onclick="doDeleteTx()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
            Delete
        </button>
    </div>
</div>
</div>
<!-- ============= /DELETE CONFIRMATION ============= -->

</asp:Content>
