<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentsRegistration.aspx.cs" Inherits="COOPERP_NewScreens_StudentsRegistration" Title="Student Registration - Campus Dynamics" %>

<%-- Student semester-registration register: lists every student-semester registration instance with admin editability. --%>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== STUDENT REGISTRATION MODULE ===================================== */

/* -- Page Header ------------------------------------- */
.cd-page-header { background:#fff; padding:10px 14px; margin-bottom:10px; border:1px solid #e4e8f0; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px; }
.cd-page-header__left { display:flex; align-items:center; gap:11px; }
.cd-page-header__icon { width:34px; height:34px; background:#05275C; display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:15px; font-weight:700; color:#1a1a1a; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:11px; color:#6b7280; margin-top:1px; }
.cd-page-header__right { display:flex; gap:7px; align-items:center; flex-wrap:wrap; }

/* -- Compact stats strip ----------------------------- */
.rg-stats {
    display:grid; grid-template-columns:1.5fr repeat(9, 1fr); gap:6px; margin-bottom:10px;
}
.rg-stat {
    background:#fff; border:1px solid #e4e8f0; padding:8px 10px;
    display:flex; flex-direction:column; gap:1px; border-radius:4px; cursor:pointer;
    position:relative; overflow:hidden; transition:border-color .15s, box-shadow .15s, transform .1s;
}
.rg-stat::after { content:''; position:absolute; left:0; top:0; bottom:0; width:3px; background:var(--c,#ccc); }
.rg-stat:hover { border-color:rgba(23,77,164,.35); box-shadow:0 2px 8px rgba(5,39,92,.07); }
.rg-stat:active { transform:scale(.985); }
.rg-stat.is-active { border-color:var(--c); box-shadow:0 0 0 2px var(--c) inset; }
.rg-stat__val { font-size:18px; font-weight:800; line-height:1.05; color:var(--c,#333); font-variant-numeric:tabular-nums; }
.rg-stat__label { font-size:8.5px; text-transform:uppercase; letter-spacing:.4px; color:#8a93a0; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
/* Hero */
.rg-stat--hero { background:#05275C; border-color:#05275C; padding:9px 13px; }
.rg-stat--hero::after { display:none; }
.rg-stat--hero .rg-stat__val { color:#fff; font-size:24px; }
.rg-stat--hero .rg-stat__label { color:rgba(255,255,255,.65); font-size:9px; }
.rg-stat--hero:hover { box-shadow:0 2px 10px rgba(5,39,92,.25); }
/* Colors */
.rg-stat--grey  { --c:#6b7280; }  .rg-stat--red   { --c:#dc3545; }
.rg-stat--green { --c:#16a34a; }  .rg-stat--amber { --c:#e67e00; }
.rg-stat--blue  { --c:#174DA4; }  .rg-stat--pink  { --c:#9d174d; }
.rg-stat--orange{ --c:#e65100; }  .rg-stat--dark  { --c:#374151; }
.rg-stat--teal  { --c:#0f766e; }  .rg-stat--brown { --c:#8a5a44; }
.rg-stat__bar { position:absolute; bottom:0; left:0; right:0; height:2px; background:#eef1f5; }
.rg-stat__bar span { display:block; height:100%; background:var(--c); width:0; transition:width .8s cubic-bezier(.4,0,.2,1); }

/* -- Card -------------------------------------------- */
.cd-card { background:#fff; border:1px solid #e4e8f0; border-radius:4px; overflow:visible; margin-bottom:14px; }

/* -- Toolbar / Filters ------------------------------- */
.sr-toolbar { padding:9px 12px; border-bottom:1px solid #eef1f5; display:flex; gap:8px; align-items:center; flex-wrap:wrap; background:#fafbfc; }
.sr-search { position:relative; flex:1; min-width:220px; max-width:420px; }
.sr-search svg { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:#9aa3af; pointer-events:none; }
.sr-search input { width:100%; padding:7px 12px 7px 32px; border:1px solid #dde1e6; font-size:12px; background:#fff; box-sizing:border-box; }
.sr-search input:focus { border-color:#174DA4; box-shadow:0 0 0 3px rgba(23,77,164,.08); outline:none; }
.sr-fld { display:flex; flex-direction:column; gap:2px; }
.sr-fld__lbl { font-size:8.5px; text-transform:uppercase; letter-spacing:.5px; color:#9aa3af; font-weight:700; }
.sr-sel { border:1px solid #dde1e6; padding:6px 9px; font-size:11px; background:#fff; color:#333; cursor:pointer; min-width:96px; }
.sr-sel:focus { border-color:#174DA4; box-shadow:0 0 0 3px rgba(23,77,164,.08); outline:none; }
.sr-spacer { flex:1; }
.sr-count { font-size:11px; color:#174DA4; font-weight:700; white-space:nowrap; background:rgba(23,77,164,.07); padding:5px 12px; }
.sr-morebtn { position:relative; }
.sr-morebtn .sr-badge { position:absolute; top:-6px; right:-6px; background:#dc3545; color:#fff; font-size:9px; font-weight:700; min-width:15px; height:15px; line-height:15px; text-align:center; border-radius:8px; padding:0 3px; }

/* Advanced filter panel */
.sr-adv { display:none; padding:10px 12px; border-bottom:1px solid #eef1f5; background:#fff; gap:8px; flex-wrap:wrap; align-items:flex-end; }
.sr-adv.open { display:flex; }

/* Active filter chips */
.sr-chips { display:none; padding:7px 12px; border-bottom:1px solid #eef1f5; gap:6px; flex-wrap:wrap; align-items:center; background:#fff; }
.sr-chips.show { display:flex; }
.sr-chips__lbl { font-size:9px; text-transform:uppercase; letter-spacing:.5px; color:#9aa3af; font-weight:700; }
.sr-chip { display:inline-flex; align-items:center; gap:5px; background:#eef3fb; border:1px solid #d4e0f2; color:#174DA4; font-size:10.5px; font-weight:600; padding:3px 5px 3px 9px; border-radius:12px; }
.sr-chip b { font-weight:700; }
.sr-chip__x { cursor:pointer; width:15px; height:15px; line-height:14px; text-align:center; border-radius:50%; color:#5b7cb5; font-size:13px; }
.sr-chip__x:hover { background:#d4e0f2; color:#0f3a7d; }
.sr-chip--clear { background:none; border:none; color:#dc3545; cursor:pointer; font-size:10.5px; font-weight:700; text-transform:uppercase; letter-spacing:.3px; padding:3px 6px; }
.sr-chip--clear:hover { text-decoration:underline; }

/* Searchable combo (programme) */
.sr-combo { position:relative; }
.sr-combo::after { content:'\25BE'; position:absolute; right:8px; top:8px; font-size:9px; color:#9aa3af; pointer-events:none; }
.sr-combo input { width:100%; padding:6px 22px 6px 9px; border:1px solid #dde1e6; font-size:11px; background:#fff; box-sizing:border-box; cursor:text; }
.sr-combo input:focus { border-color:#174DA4; box-shadow:0 0 0 3px rgba(23,77,164,.08); outline:none; }
.sr-combo__menu { position:absolute; top:calc(100% + 2px); left:0; min-width:100%; width:max-content; max-width:360px; z-index:60; background:#fff; border:1px solid #cdd8e6; box-shadow:0 6px 20px rgba(5,39,92,.14); max-height:280px; overflow-y:auto; display:none; }
.sr-combo__menu.show { display:block; }
.sr-combo__opt { padding:6px 10px; font-size:11px; color:#1a1a2e; cursor:pointer; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.sr-combo__opt:hover, .sr-combo__opt.active { background:#eef4ff; color:#05275C; }
.sr-combo__opt--none { color:#9aa3af; cursor:default; font-style:italic; }

/* -- Buttons ----------------------------------------- */
.hr-btn { padding:7px 14px; font-size:11px; font-weight:600; border:none; cursor:pointer; border-radius:0; display:inline-flex; align-items:center; gap:6px; white-space:nowrap; line-height:1.4; transition:background .15s, transform .1s; text-decoration:none; }
.hr-btn:active { transform:scale(.97); }
.hr-btn--primary { background:#174DA4; color:#fff; }  .hr-btn--primary:hover { background:#0f3a7d; }
.hr-btn--success { background:#16a34a; color:#fff; }  .hr-btn--success:hover { background:#138a3e; }
.hr-btn--danger  { background:#dc3545; color:#fff; }  .hr-btn--danger:hover  { background:#c82333; }
.hr-btn--amber   { background:#e67e00; color:#fff; }  .hr-btn--amber:hover   { background:#b45309; }
.hr-btn--orange  { background:#e65100; color:#fff; }  .hr-btn--orange:hover  { background:#bf360c; }
.hr-btn--ghost   { background:#fff; color:#555; border:1px solid #dde1e6; } .hr-btn--ghost:hover { border-color:#174DA4; color:#174DA4; background:rgba(23,77,164,.03); }
.hr-btn--sm      { padding:5px 11px; font-size:10px; }

/* -- Batch Toolbar ----------------------------------- */
.rg-batch-bar { display:none; align-items:center; gap:7px; flex-wrap:wrap; padding:8px 12px; background:#fffbe6; border-bottom:2px solid #ffc107; }
.rg-batch-bar.show { display:flex; }
.rg-batch-info { display:flex; align-items:center; gap:5px; font-size:11px; color:#6d4c00; white-space:nowrap; }
.rg-batch-info strong { font-size:13px; font-weight:700; color:#b45309; }
.rg-batch-sep { width:1px; height:22px; background:#e0c060; margin:0 2px; flex-shrink:0; }

/* -- Status Badges ----------------------------------- */
.rg-badge { display:inline-block; padding:2px 8px; font-size:9px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; border-radius:4px; white-space:nowrap; }
.rg-badge--unreg     { background:#fff3cd; color:#856404; }
.rg-badge--reg       { background:#d4edda; color:#155724; }
.rg-badge--late      { background:#fff0c2; color:#7c4a00; }
.rg-badge--cleared   { background:#cce5ff; color:#004085; }
.rg-badge--discont   { background:#f8d7da; color:#721c24; }
.rg-badge--halted    { background:#ffe0b2; color:#7c4500; }
.rg-badge--dead      { background:#d6d8db; color:#1b1e21; }
.rg-badge--uncleared { background:#fff3cd; color:#856404; }
.rg-badge--printed   { background:#e8f0fc; color:#174DA4; }
.rg-badge--issued    { background:#d4edda; color:#155724; }
.rg-badge--notissued { background:#e9ecef; color:#6c757d; }
.rg-badge--billed    { background:#d1f0ec; color:#0f766e; }
.rg-badge--notbilled { background:#fff3cd; color:#856404; }
.rg-billing-amt { font-size:9px; color:#8a93a0; display:block; margin-top:1px; white-space:nowrap; }

/* -- Row primary edit button ------------------------- */
.sr-edit-btn { background:#fff; border:1px solid #dde1e6; color:#174DA4; padding:4px 9px; font-size:10px; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; gap:5px; transition:background .12s, border-color .12s; }
.sr-edit-btn:hover { background:#174DA4; color:#fff; border-color:#174DA4; }
.sr-edit-btn svg { width:12px; height:12px; }

/* -- Action Popover ---------------------------------- */
.cd-action-wrapper { position:relative; display:inline-block; }
.cd-action-trigger { background:none; border:1px solid #dde1e6; padding:4px 6px; cursor:pointer; color:#555; display:inline-flex; align-items:center; transition:border-color .15s, background .15s; }
.cd-action-trigger:hover { border-color:#174DA4; color:#174DA4; background:#f0f4ff; }
.cd-action-popover { display:none; position:absolute; right:0; top:calc(100% + 4px); z-index:9999; background:#fff; border:1px solid #e4e8f0; box-shadow:0 8px 28px rgba(5,39,92,.16); min-width:184px; }
.cd-action-popover.is-open { display:block; }
.cd-action-popover.flip-up { top:auto; bottom:calc(100% + 4px); }
.cd-action-popover__section { padding:5px 12px 2px; font-size:8px; font-weight:700; text-transform:uppercase; letter-spacing:.6px; color:#aaa; border-top:1px solid #f4f4f4; margin-top:2px; }
.cd-action-popover__section:first-child { border-top:none; margin-top:0; }
.cd-action-popover__menu { list-style:none; margin:0; padding:2px 0; }
.cd-action-popover__item { margin:0; }
.cd-action-popover__btn { width:100%; background:none; border:none; padding:6px 14px; font-size:11px; color:#333; cursor:pointer; display:flex; align-items:center; gap:8px; text-align:left; transition:background .12s; }
.cd-action-popover__btn:hover { background:#f0f4ff; color:#174DA4; }
.cd-action-popover__btn--danger:hover { background:#fdecea; color:#dc3545; }
.cd-action-popover__btn--success:hover { background:#e6f4ea; color:#16a34a; }
.cd-action-popover__btn svg { width:13px; height:13px; flex-shrink:0; }
.cd-action-popover__divider { height:1px; background:#f0f0f0; margin:3px 0; }
td.rg-action-cell { overflow:visible !important; }

/* -- Table ------------------------------------------- */
.sr-table-wrap { overflow-x:auto; overflow-y:visible; }
.sr-table { width:100%; border-collapse:collapse; }
.sr-table thead th { font-size:9.5px; text-transform:uppercase; letter-spacing:.4px; background:#f5f7fa; color:#667; border-bottom:2px solid #e4e8f0; padding:9px 10px; font-weight:700; white-space:nowrap; position:sticky; top:0; z-index:2; }
.sr-table thead th.th-chk { width:34px; text-align:center; }
.sr-table tbody tr { border-bottom:1px solid #f2f3f5; transition:background .1s; }
.sr-table tbody tr:hover td { background:#f0f4ff; }
.sr-table tbody td { font-size:11px; padding:7px 10px; vertical-align:middle; }
.sr-table tbody td.td-chk { text-align:center; width:34px; }
.sr-chk, .sr-chk-all { cursor:pointer; width:14px; height:14px; accent-color:#174DA4; }
.sr-row--late td { background:#fffdf0; }
.sr-row--cleared td { background:#f0f7ff; }
.sr-row--discont td { background:#fff8f8; }
.sr-row--halted td { background:#fff9f0; }
.sr-row--dead td { background:#f8f8f8; }
.sr-name { font-weight:600; color:#1a1a2e; line-height:1.25; }
.sr-reg { font-size:10px; color:#174DA4; font-weight:600; margin-top:1px; }
.sr-sem-pill { font-size:10px; font-weight:600; color:#174DA4; background:rgba(23,77,164,.08); padding:1px 7px; }
.sr-nodata { text-align:center; padding:48px 24px; color:#888; font-size:12px; border-top:1px solid #f0f2f5; }
.sr-nodata svg { margin-bottom:8px; }

/* -- Grid Footer ------------------------------------- */
.rg-grid-footer { display:flex; justify-content:space-between; align-items:center; padding:8px 14px; background:#fafbfc; border-top:1px solid #e4e8f0; font-size:11px; color:#666; flex-wrap:wrap; gap:6px; }
.rg-grid-footer strong { color:#174DA4; }
.rg-pager { display:flex; align-items:center; gap:4px; flex-wrap:wrap; }
.rg-pager a, .rg-pager span { min-width:24px; height:24px; padding:0 7px; display:inline-flex; align-items:center; justify-content:center; border:1px solid #dde3ea; background:#fff; color:#334155; text-decoration:none; font-size:11px; border-radius:3px; }
.rg-pager a:hover { border-color:#174DA4; color:#174DA4; }
.rg-pager .is-active { background:#174DA4; color:#fff; border-color:#174DA4; }
.rg-pager .is-disabled { opacity:.5; pointer-events:none; }

/* -- Modal ------------------------------------------- */
.hr-modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.48); z-index:10000; align-items:center; justify-content:center; padding:16px; box-sizing:border-box; }
.hr-modal-overlay.open { display:flex; }
.hr-modal { background:#fff; width:540px; max-width:100%; max-height:calc(100vh - 32px); overflow:hidden; border-radius:2px; box-shadow:0 20px 60px rgba(0,0,0,.22); display:flex; flex-direction:column; animation:rgModalIn .2s ease; }
@keyframes rgModalIn { from { opacity:0; transform:translateY(-12px) scale(.98); } to { opacity:1; transform:none; } }
.hr-modal__header { background:#05275C; color:#fff; padding:13px 18px; font-size:14px; font-weight:700; display:flex; align-items:center; justify-content:space-between; flex-shrink:0; }
.hr-modal__close { background:none; border:none; color:rgba(255,255,255,.8); font-size:22px; cursor:pointer; line-height:1; padding:0 2px; }
.hr-modal__close:hover { color:#fff; }
.hr-modal__body { padding:16px; flex:1; overflow-y:auto; }
.hr-modal__footer { padding:10px 16px; border-top:1px solid #e4e8f0; display:flex; justify-content:flex-end; gap:8px; flex-shrink:0; background:#fafbfc; }
.hr-modal__section { font-size:9px; text-transform:uppercase; letter-spacing:.6px; color:#174DA4; font-weight:700; padding:6px 0 4px; border-bottom:1px solid #e8ecf4; margin-bottom:8px; margin-top:14px; }
.hr-modal__section:first-child { margin-top:0; }

/* -- Form -------------------------------------------- */
.hr-form-group { margin-bottom:10px; }
.hr-form-label { display:block; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#555; font-weight:600; margin-bottom:3px; }
.hr-form-label .req { color:#dc3545; margin-left:2px; }
.hr-form-input, .hr-form-select { width:100%; padding:7px 9px; border:1px solid #ccc; border-radius:0; font-size:12px; box-sizing:border-box; background:#fff; transition:border-color .15s, box-shadow .15s; }
.hr-form-input:focus, .hr-form-select:focus { border-color:#174DA4; box-shadow:0 0 0 2px rgba(23,77,164,.10); outline:none; }
.hr-form-row { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.hr-form-row--3 { grid-template-columns:1fr 1fr 1fr; }
.hr-form-hint { font-size:10px; color:#888; margin-top:2px; }
.hr-result { margin-top:8px; font-size:12px; padding:7px 11px; display:none; border-radius:0; }
.hr-result--err { background:#fdecea; color:#b91c1c; border-left:3px solid #dc3545; display:block; }
.hr-result--ok { background:#e6f4ea; color:#155724; border-left:3px solid #16a34a; display:block; }

/* Student info block (modals) */
.rg-student-info { background:#f5f7fa; border:1px solid #e4e8f0; border-radius:4px; padding:10px 14px; margin-bottom:12px; font-size:12px; display:flex; gap:18px; flex-wrap:wrap; }
.rg-student-info__item { display:flex; flex-direction:column; gap:1px; }
.rg-student-info__label { font-size:9px; text-transform:uppercase; letter-spacing:.4px; color:#888; font-weight:600; }
.rg-student-info__value { font-weight:700; color:#1a1a2e; font-size:12px; }

/* -- Toast ------------------------------------------- */
.rg-toast { position:fixed; bottom:24px; right:24px; padding:11px 18px; border-radius:0; font-size:12px; font-weight:600; z-index:20000; transform:translateY(20px); opacity:0; transition:transform .25s, opacity .25s; pointer-events:none; max-width:380px; display:flex; align-items:center; gap:8px; }
.rg-toast.show { transform:none; opacity:1; }
.rg-toast--success { background:#16a34a; color:#fff; }
.rg-toast--error { background:#dc3545; color:#fff; }

/* -- Responsive -------------------------------------- */
@media (max-width:1400px) { .rg-stats { grid-template-columns:1.5fr repeat(4,1fr); } }
@media (max-width:1000px) { .rg-stats { grid-template-columns:repeat(4,1fr); } .rg-stat--hero { grid-column:span 2; } }
@media (max-width:700px) {
    .rg-stats { grid-template-columns:repeat(2,1fr); }
    .rg-stat--hero { grid-column:span 2; }
    .cd-page-header { flex-direction:column; align-items:flex-start; }
    .sr-fld, .sr-fld .sr-sel, .sr-combo { width:100%; }
    .hr-form-row, .hr-form-row--3 { grid-template-columns:1fr; }
}
@media print { .rg-batch-bar, .sr-toolbar, .sr-adv, .sr-chips, .cd-page-header__right, .rg-action-cell, .th-act, .th-chk, .td-chk { display:none !important; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- Hidden postback triggers --%>
<asp:HiddenField ID="hdnBatchIds" runat="server" />
<asp:Button ID="btnBatchClear"       runat="server" style="display:none;" OnClick="btnBatchClear_Click" />
<asp:Button ID="btnBatchUndoReg"     runat="server" style="display:none;" OnClick="btnBatchUndoReg_Click" />
<asp:Button ID="btnBatchUndoClear"   runat="server" style="display:none;" OnClick="btnBatchUndoClear_Click" />
<asp:Button ID="btnBatchDiscontinue" runat="server" style="display:none;" OnClick="btnBatchDiscontinue_Click" />
<asp:Button ID="btnBatchHalt"        runat="server" style="display:none;" OnClick="btnBatchHalt_Click" />
<asp:Button ID="btnBatchDeadYear"    runat="server" style="display:none;" OnClick="btnBatchDeadYear_Click" />
<asp:Button ID="btnBatchReactivate"  runat="server" style="display:none;" OnClick="btnBatchReactivate_Click" />
<asp:Button ID="btnBatchDelete"      runat="server" style="display:none;" OnClick="btnBatchDelete_Click" />
<asp:Button ID="btnDoAddReg"         runat="server" style="display:none;" OnClick="btnDoAddReg_Click" />
<asp:Button ID="btnDoEditReg"        runat="server" style="display:none;" OnClick="btnDoEditReg_Click" />
<asp:Button ID="btnExportCsv"        runat="server" style="display:none;" OnClick="btnExportCsv_Click" />
<asp:Button ID="btnReset"            runat="server" style="display:none;" OnClick="btnReset_Click" />
<asp:Button ID="btnRefresh"          runat="server" style="display:none;" OnClick="btnRefresh_Click" />

<!-- ======= PAGE HEADER =============================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
        </div>
        <div>
            <div class="cd-page-header__title">Student Registration</div>
            <div class="cd-page-header__sub">All student &middot; semester registration records, with admin editing</div>
        </div>
    </div>
    <div class="cd-page-header__right">
        <asp:Literal ID="litAcadContext" runat="server" />
        <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="openAddRegModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Add Registration
        </button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="document.getElementById('<%=btnExportCsv.ClientID%>').click()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
            Export CSV
        </button>
    </div>
</div>

<!-- ======= STATS STRIP =============================================== -->
<div class="rg-stats">
    <div class="rg-stat rg-stat--hero" onclick="clearStatusFilter()" title="Show all records">
        <div class="rg-stat__val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
        <div class="rg-stat__label">Total Registrations</div>
    </div>
    <div class="rg-stat rg-stat--red" data-status="UNREGISTERED" onclick="filterByStatus('UNREGISTERED')" title="Filter: Unregistered">
        <div class="rg-stat__val"><asp:Literal ID="litUnregistered" runat="server" Text="0" /></div><div class="rg-stat__label">Unregistered</div>
    </div>
    <div class="rg-stat rg-stat--green" data-status="REGISTERED" onclick="filterByStatus('REGISTERED')" title="Filter: Registered">
        <div class="rg-stat__val"><asp:Literal ID="litRegistered" runat="server" Text="0" /></div><div class="rg-stat__label">Registered</div>
    </div>
    <div class="rg-stat rg-stat--amber" data-status="LATE REGISTERED" onclick="filterByStatus('LATE REGISTERED')" title="Filter: Late Registered">
        <div class="rg-stat__val"><asp:Literal ID="litLateRegistered" runat="server" Text="0" /></div><div class="rg-stat__label">Late Reg.</div>
    </div>
    <div class="rg-stat rg-stat--blue" data-status="CLEARED" onclick="filterByStatus('CLEARED')" title="Filter: Cleared">
        <div class="rg-stat__val"><asp:Literal ID="litCleared" runat="server" Text="0" /></div><div class="rg-stat__label">Cleared</div>
    </div>
    <div class="rg-stat rg-stat--pink" data-status="DISCONTINUED" onclick="filterByStatus('DISCONTINUED')" title="Filter: Discontinued">
        <div class="rg-stat__val"><asp:Literal ID="litDiscontinued" runat="server" Text="0" /></div><div class="rg-stat__label">Discontinued</div>
    </div>
    <div class="rg-stat rg-stat--orange" data-status="HALTED" onclick="filterByStatus('HALTED')" title="Filter: Halted">
        <div class="rg-stat__val"><asp:Literal ID="litHalted" runat="server" Text="0" /></div><div class="rg-stat__label">Halted</div>
    </div>
    <div class="rg-stat rg-stat--dark" data-status="DEAD YEAR" onclick="filterByStatus('DEAD YEAR')" title="Filter: Dead Year">
        <div class="rg-stat__val"><asp:Literal ID="litDeadYear" runat="server" Text="0" /></div><div class="rg-stat__label">Dead Year</div>
    </div>
    <div class="rg-stat rg-stat--teal" data-billing="BILLED" onclick="filterByBilling('BILLED')" title="Filter: Billed (enrolled)">
        <div class="rg-stat__val"><asp:Literal ID="litBilled" runat="server" Text="0" /></div><div class="rg-stat__label">Billed</div>
        <div class="rg-stat__bar"><span id="billedBar"></span></div>
    </div>
    <div class="rg-stat rg-stat--brown" data-billing="NOT BILLED" onclick="filterByBilling('NOT BILLED')" title="Filter: Not billed (enrolled)">
        <div class="rg-stat__val"><asp:Literal ID="litNotBilled" runat="server" Text="0" /></div><div class="rg-stat__label">Not Billed</div>
        <div class="rg-stat__bar"><span id="notBilledBar"></span></div>
    </div>
</div>

<!-- ======= MAIN CARD ================================================= -->
<div class="cd-card">

    <!-- Toolbar -->
    <div class="sr-toolbar">
        <div class="sr-search">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <asp:TextBox ID="txtSearch" runat="server" AutoPostBack="false" placeholder="Search name, reg no, programme..." aria-label="Search students" />
        </div>
        <asp:Button ID="btnSearch" runat="server" CssClass="hr-btn hr-btn--primary hr-btn--sm" Text="Search" OnClientClick="cdApplyFilters(1); return false;" />
        <div class="sr-fld">
            <span class="sr-fld__lbl">Academic Year</span>
            <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="sr-sel" AutoPostBack="false" />
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">Semester</span>
            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All Semesters" Selected="True" />
                <asp:ListItem Value="1" Text="Semester 1" />
                <asp:ListItem Value="2" Text="Semester 2" />
                <asp:ListItem Value="3" Text="Semester 3" />
            </asp:DropDownList>
        </div>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm sr-morebtn" onclick="toggleAdvFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
            <span>Filters</span>
            <span class="sr-badge" id="advCount" style="display:none;">0</span>
        </button>
        <div class="sr-spacer"></div>
        <asp:Label ID="lblRecordCount" runat="server" CssClass="sr-count" Text="0 items" />
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="cdResetFilters()" title="Reset all filters">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
            Reset
        </button>
    </div>

    <!-- Advanced filters (collapsible) -->
    <div class="sr-adv" id="advPanel">
        <div class="sr-fld">
            <span class="sr-fld__lbl">Study Year</span>
            <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All Years" />
                <asp:ListItem Value="1" Text="Year 1" /><asp:ListItem Value="2" Text="Year 2" />
                <asp:ListItem Value="3" Text="Year 3" /><asp:ListItem Value="4" Text="Year 4" />
                <asp:ListItem Value="5" Text="Year 5" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">Reg Status</span>
            <asp:DropDownList ID="ddlRegStatus" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All Statuses" />
                <asp:ListItem Value="UNREGISTERED" Text="Unregistered" />
                <asp:ListItem Value="REGISTERED" Text="Registered" />
                <asp:ListItem Value="LATE REGISTERED" Text="Late Registered" />
                <asp:ListItem Value="CLEARED" Text="Cleared" />
                <asp:ListItem Value="DISCONTINUED" Text="Discontinued" />
                <asp:ListItem Value="HALTED" Text="Halted" />
                <asp:ListItem Value="DEAD YEAR" Text="Dead Year" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld" style="min-width:200px;">
            <span class="sr-fld__lbl">Programme</span>
            <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="sr-sel" AutoPostBack="false" style="min-width:200px;">
                <asp:ListItem Value="" Text="All Programmes" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">Exam Clearance</span>
            <asp:DropDownList ID="ddlExamClearance" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All" />
                <asp:ListItem Value="UNCLEARED" Text="Uncleared" />
                <asp:ListItem Value="CLEARED" Text="Cleared" />
                <asp:ListItem Value="PRINTED" Text="Printed" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">ID Card</span>
            <asp:DropDownList ID="ddlIDCard" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All" />
                <asp:ListItem Value="NOT ISSUED" Text="Not Issued" />
                <asp:ListItem Value="ISSUED" Text="Issued" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">Residence</span>
            <asp:DropDownList ID="ddlResidence" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All" />
                <asp:ListItem Value="RESIDENT" Text="Resident" />
                <asp:ListItem Value="NON-RESIDENT" Text="Non-Resident" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">Billing</span>
            <asp:DropDownList ID="ddlBilling" runat="server" CssClass="sr-sel" AutoPostBack="false">
                <asp:ListItem Value="" Text="All" />
                <asp:ListItem Value="BILLED" Text="Billed" />
                <asp:ListItem Value="NOT BILLED" Text="Not Billed" />
            </asp:DropDownList>
        </div>
        <div class="sr-fld">
            <span class="sr-fld__lbl">Per Page</span>
            <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="sr-sel" AutoPostBack="false" style="min-width:74px;">
                <asp:ListItem Value="25" Text="25" />
                <asp:ListItem Value="50" Text="50" Selected="True" />
                <asp:ListItem Value="100" Text="100" />
                <asp:ListItem Value="200" Text="200" />
                <asp:ListItem Value="500" Text="500" />
            </asp:DropDownList>
        </div>
    </div>

    <!-- Active filter chips -->
    <div class="sr-chips" id="filterChips"></div>

    <!-- Batch Toolbar -->
    <div class="rg-batch-bar" id="batchBar" role="toolbar" aria-label="Batch actions">
        <div class="rg-batch-info">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
            <strong id="batchSelCount">0</strong>&nbsp;selected
        </div>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="doBatch('clear')">Clear for Exams</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('undoreg')">Undo Reg.</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('undoclear')">Undo Clearance</button>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatch('discontinue')">Discontinue</button>
        <button type="button" class="hr-btn hr-btn--orange hr-btn--sm" onclick="doBatch('halt')">Halt</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('deadyear')">Dead Year</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('reactivate')">Reactivate</button>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatch('delete')">Delete</button>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="srClearSelection()" style="color:#888;">Clear Selection</button>
    </div>

    <!-- Grid -->
    <div class="sr-table-wrap">
        <table class="sr-table" role="grid" aria-label="Student registrations">
            <thead>
                <tr>
                    <th class="th-chk" scope="col"><input type="checkbox" id="chkSelAll" class="sr-chk-all" onclick="srSelectAll(this)" aria-label="Select all" /></th>
                    <th scope="col">Student</th>
                    <th scope="col">Programme</th>
                    <th scope="col" style="text-align:center;">Acad Year</th>
                    <th scope="col" style="text-align:center;">Sem</th>
                    <th scope="col" style="text-align:center;">Yr</th>
                    <th scope="col" style="text-align:center;">Res.</th>
                    <th scope="col" style="text-align:center;">Reg Status</th>
                    <th scope="col" style="text-align:center;">Exam Clr</th>
                    <th scope="col" style="text-align:center;">ID Card</th>
                    <th scope="col" style="text-align:center;">Billing</th>
                    <th scope="col">Reg By</th>
                    <th scope="col" class="th-act" style="text-align:right;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptRegistrations" runat="server">
                    <ItemTemplate>
                        <tr data-id='<%# Eval("ID") %>'
                            data-regno='<%# Server.HtmlEncode((Eval("regno") ?? "").ToString()) %>'
                            data-name='<%# Server.HtmlEncode((Eval("student_name") ?? "").ToString()) %>'
                            data-ay='<%# Server.HtmlEncode((Eval("acad_year") ?? "").ToString()) %>'
                            data-sem='<%# Eval("semester") %>'
                            data-sy='<%# Eval("studyyear") %>'
                            data-rs='<%# Server.HtmlEncode((Eval("regstatus") ?? "").ToString()) %>'
                            data-res='<%# Server.HtmlEncode((Eval("residence_status") ?? "").ToString()) %>'
                            data-idc='<%# Server.HtmlEncode((Eval("id_cardStatus") ?? "").ToString()) %>'
                            data-ec='<%# Server.HtmlEncode((Eval("examClearance") ?? "").ToString()) %>'
                            data-ecdate='<%# Server.HtmlEncode((Eval("examClearanceDateRaw") ?? "").ToString()) %>'
                            data-prog='<%# Server.HtmlEncode((Eval("progcode") ?? "").ToString()) %>'
                            class='<%# GetRowClass(Eval("regstatus").ToString()) %>'>
                            <td class="td-chk"><input type="checkbox" class="sr-chk" value='<%# Eval("ID") %>' onclick="srRowCheck(this)" aria-label="Select row" /></td>
                            <td>
                                <div class="sr-name"><%# Server.HtmlEncode((Eval("student_name") ?? "").ToString().Trim() != "" ? Eval("student_name").ToString() : "—") %></div>
                                <div class="sr-reg"><%# Server.HtmlEncode((Eval("regno") ?? "").ToString()) %></div>
                            </td>
                            <td title='<%# Server.HtmlEncode((Eval("progname") ?? "").ToString()) %>'><span style="font-size:11px;"><%# Server.HtmlEncode((Eval("progcode") ?? "").ToString()) %></span></td>
                            <td style="font-size:10px;text-align:center;white-space:nowrap;"><%# Eval("acad_year") %></td>
                            <td style="text-align:center;"><span class="sr-sem-pill">Sem <%# Eval("semester") %></span></td>
                            <td style="text-align:center;font-weight:600;"><%# Eval("studyyear") %></td>
                            <td style="text-align:center;font-size:10px;color:#555;white-space:nowrap;"><%# Server.HtmlEncode((Eval("residence_status") ?? "").ToString()) %></td>
                            <td style="text-align:center;"><span class='rg-badge rg-badge--<%# GetStatusClass(Eval("regstatus").ToString()) %>'><%# Eval("regstatus") %></span></td>
                            <td style="text-align:center;"><span class='rg-badge rg-badge--<%# GetClearanceClass(Eval("examClearance").ToString()) %>'><%# Eval("examClearance") %></span></td>
                            <td style="text-align:center;"><span class='rg-badge rg-badge--<%# GetIDCardClass(Eval("id_cardStatus").ToString()) %>'><%# Eval("id_cardStatus") %></span></td>
                            <td style="text-align:center;">
                                <span class='rg-badge rg-badge--<%# GetBillingClass(Eval("billing_status").ToString()) %>'><%# Eval("billing_status") %></span>
                                <%# Convert.ToDouble(Eval("total_billed") == DBNull.Value ? 0 : Eval("total_billed")) > 0 ? "<span class='rg-billing-amt'>" + Convert.ToDouble(Eval("total_billed")).ToString("N0") + "</span>" : "" %>
                            </td>
                            <td style="font-size:10px;color:#888;"><%# Server.HtmlEncode((Eval("registeredBy") ?? "").ToString()) %></td>
                            <td class="rg-action-cell" style="text-align:right;white-space:nowrap;">
                                <button type="button" class="sr-edit-btn" onclick="openEditModal(this)" title="Edit this registration record">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    Edit
                                </button>
                                <div class="cd-action-wrapper">
                                    <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)" title="More actions" aria-haspopup="true">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                    </button>
                                    <div class="cd-action-popover" role="menu">
                                        <div class="cd-action-popover__section">Exam Clearance</div>
                                        <ul class="cd-action-popover__menu">
                                            <li class="cd-action-popover__item" style='<%# ShowIfIn(Eval("regstatus"),"REGISTERED|LATE REGISTERED") %>'>
                                                <asp:LinkButton ID="btnClear" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--success"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnClear_Click"
                                                    OnClientClick="return confirm('Clear this student for exams?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                                                    Clear for Exams
                                                </asp:LinkButton>
                                            </li>
                                            <li class="cd-action-popover__item" style='<%# ShowIf(Eval("examClearance"),"CLEARED") %>'>
                                                <asp:LinkButton ID="btnUndoClear" runat="server" CssClass="cd-action-popover__btn"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnUndoClear_Click"
                                                    OnClientClick="return confirm('Undo exam clearance? Student reverts to Registered.');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                                                    Undo Clearance
                                                </asp:LinkButton>
                                            </li>
                                            <li class="cd-action-popover__item" style='<%# ShowIfIn(Eval("regstatus"),"REGISTERED|LATE REGISTERED") %>'>
                                                <asp:LinkButton ID="btnUnregister" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnUnregister_Click"
                                                    OnClientClick="return confirm('Undo registration for this student?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                                    Undo Registration
                                                </asp:LinkButton>
                                            </li>
                                        </ul>
                                        <div class="cd-action-popover__section" style='<%# ShowIfNotIn(Eval("regstatus"),"DISCONTINUED|DEAD YEAR|HALTED") %>'>Special Status</div>
                                        <ul class="cd-action-popover__menu">
                                            <li class="cd-action-popover__item" style='<%# ShowIfNotIn(Eval("regstatus"),"DISCONTINUED|DEAD YEAR") %>'>
                                                <asp:LinkButton ID="btnDiscontinue" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnDiscontinue_Click"
                                                    OnClientClick="return confirm('Mark this student as Discontinued?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                                                    Discontinue
                                                </asp:LinkButton>
                                            </li>
                                            <li class="cd-action-popover__item" style='<%# ShowIfNotIn(Eval("regstatus"),"HALTED|DISCONTINUED|DEAD YEAR") %>'>
                                                <asp:LinkButton ID="btnHalt" runat="server" CssClass="cd-action-popover__btn"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnHalt_Click"
                                                    OnClientClick="return confirm('Halt registration for this student?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>
                                                    Halt
                                                </asp:LinkButton>
                                            </li>
                                            <li class="cd-action-popover__item" style='<%# ShowIfNot(Eval("regstatus"),"DEAD YEAR") %>'>
                                                <asp:LinkButton ID="btnDeadYear" runat="server" CssClass="cd-action-popover__btn"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnDeadYear_Click"
                                                    OnClientClick="return confirm('Mark this semester as a Dead Year for this student?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                                    Mark Dead Year
                                                </asp:LinkButton>
                                            </li>
                                            <li class="cd-action-popover__item" style='<%# ShowIfIn(Eval("regstatus"),"DISCONTINUED|HALTED|DEAD YEAR") %>'>
                                                <asp:LinkButton ID="btnReactivate" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--success"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnReactivate_Click"
                                                    OnClientClick="return confirm('Reactivate this student (reset to Unregistered)?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path></svg>
                                                    Reactivate
                                                </asp:LinkButton>
                                            </li>
                                        </ul>
                                        <div class="cd-action-popover__section">ID Card</div>
                                        <ul class="cd-action-popover__menu">
                                            <li class="cd-action-popover__item" style='<%# ShowIfNot(Eval("id_cardStatus"),"ISSUED") %>'>
                                                <asp:LinkButton ID="btnIssueIDCard" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--success"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnIssueIDCard_Click"
                                                    OnClientClick="return confirm('Mark ID card as Issued?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
                                                    Issue ID Card
                                                </asp:LinkButton>
                                            </li>
                                            <li class="cd-action-popover__item" style='<%# ShowIf(Eval("id_cardStatus"),"ISSUED") %>'>
                                                <asp:LinkButton ID="btnRevokeIDCard" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                                    CommandArgument='<%# Eval("ID") %>' OnClick="btnRevokeIDCard_Click"
                                                    OnClientClick="return confirm('Revoke this student&#39;s ID card?');" role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
                                                    Revoke ID Card
                                                </asp:LinkButton>
                                            </li>
                                        </ul>
                                        <div class="cd-action-popover__divider"></div>
                                        <ul class="cd-action-popover__menu">
                                            <li class="cd-action-popover__item">
                                                <button type="button" class="cd-action-popover__btn cd-action-popover__btn--danger"
                                                    data-id='<%# Eval("ID") %>'
                                                    data-regno='<%# HttpUtility.HtmlAttributeEncode((Eval("regno") ?? "").ToString()) %>'
                                                    data-acad='<%# HttpUtility.HtmlAttributeEncode((Eval("acad_year") ?? "").ToString()) %>'
                                                    data-sem='<%# HttpUtility.HtmlAttributeEncode((Eval("semester") ?? "").ToString()) %>'
                                                    data-sy='<%# HttpUtility.HtmlAttributeEncode((Eval("studyyear") ?? "").ToString()) %>'
                                                    data-name='<%# HttpUtility.HtmlAttributeEncode((Eval("student_name") ?? "").ToString()) %>'
                                                    onclick='openDeleteRegModal(this); return false;' role="menuitem">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                                    Delete Registration
                                                </button>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
    <asp:Panel ID="pnlNoData" runat="server" Visible="false">
        <div class="sr-nodata" role="status">
            <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            <div>No registration records match the current filters.</div>
            <div style="font-size:11px;color:#aaa;margin-top:4px;">Try adjusting your filters or search term.</div>
        </div>
    </asp:Panel>

    <!-- Grid Footer -->
    <div class="rg-grid-footer">
        <div>
            <strong><asp:Literal ID="litAcadYearDisplay" runat="server" /></strong>
            &nbsp;|&nbsp; Semester <strong><asp:Literal ID="litSemesterDisplay" runat="server" /></strong>
            &nbsp;|&nbsp; <asp:Literal ID="litFooterCount" runat="server" Text="0 items" />
        </div>
        <div class="rg-pager"><asp:Literal ID="litPager" runat="server" /></div>
    </div>
</div>

<!-- ======= ADD REGISTRATION MODAL =================================== -->
<div class="hr-modal-overlay" id="addRegModal">
    <div class="hr-modal" style="width:520px;">
        <div class="hr-modal__header">
            <span>Add Registration Record</span>
            <button class="hr-modal__close" onclick="closeModal('addRegModal')" type="button">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="hr-modal__section">Registration Period</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Academic Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddAcadYear" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Semester <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddSemester" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Semester 1" /><asp:ListItem Value="2" Text="Semester 2" /><asp:ListItem Value="3" Text="Semester 3" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-modal__section">Student</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Registration Number <span class="req">*</span></label>
                <asp:TextBox ID="txtAddRegNo" runat="server" CssClass="hr-form-input" placeholder="e.g. 2023/HD01/0001U" MaxLength="30" />
                <div class="hr-form-hint">Must match exactly as it appears in student records.</div>
            </div>
            <div class="hr-modal__section">Enrolment Details</div>
            <div class="hr-form-row--3" style="display:grid;gap:10px;">
                <div class="hr-form-group">
                    <label class="hr-form-label">Study Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddStudyYear" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Year 1" /><asp:ListItem Value="2" Text="Year 2" /><asp:ListItem Value="3" Text="Year 3" /><asp:ListItem Value="4" Text="Year 4" /><asp:ListItem Value="5" Text="Year 5" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Residence</label>
                    <asp:DropDownList ID="ddlAddResidence" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="NON-RESIDENT" Text="Non-Resident" /><asp:ListItem Value="RESIDENT" Text="Resident (Halls)" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Initial Status</label>
                    <asp:DropDownList ID="ddlAddStatus" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="UNREGISTERED" Text="Unregistered" Selected="True" />
                        <asp:ListItem Value="REGISTERED" Text="Registered (auto-bill)" />
                        <asp:ListItem Value="LATE REGISTERED" Text="Late Registered (auto-bill)" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-hint">Setting <b>Registered</b> / <b>Late Registered</b> will auto-bill the student for this period.</div>
            <div id="addRegResult" runat="server" class="hr-result" visible="false"><asp:Literal ID="litAddRegResult" runat="server" /></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeModal('addRegModal')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary" onclick="document.getElementById('<%= btnDoAddReg.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Add Registration
            </button>
        </div>
    </div>
</div>

<!-- ======= EDIT REGISTRATION MODAL ================================== -->
<div class="hr-modal-overlay" id="editRegModal">
    <div class="hr-modal" style="width:560px;">
        <div class="hr-modal__header">
            <span>Edit Registration Record</span>
            <button class="hr-modal__close" onclick="closeModal('editRegModal')" type="button">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="rg-student-info">
                <div class="rg-student-info__item"><span class="rg-student-info__label">Student</span><span class="rg-student-info__value" id="edStudentName">-</span></div>
                <div class="rg-student-info__item"><span class="rg-student-info__label">Reg No</span><span class="rg-student-info__value" id="edRegNo">-</span></div>
                <div class="rg-student-info__item"><span class="rg-student-info__label">Programme</span><span class="rg-student-info__value" id="edProg">-</span></div>
            </div>

            <div class="hr-modal__section">Registration Period</div>
            <div class="hr-form-row--3" style="display:grid;gap:10px;">
                <div class="hr-form-group">
                    <label class="hr-form-label">Academic Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditAcadYear" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Semester <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditSemester" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Semester 1" /><asp:ListItem Value="2" Text="Semester 2" /><asp:ListItem Value="3" Text="Semester 3" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Study Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditStudyYear" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Year 1" /><asp:ListItem Value="2" Text="Year 2" /><asp:ListItem Value="3" Text="Year 3" /><asp:ListItem Value="4" Text="Year 4" /><asp:ListItem Value="5" Text="Year 5" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-hint">Changing year / semester moves this record to a different period. Duplicates for the same student + period are blocked.</div>

            <div class="hr-modal__section">Status &amp; Flags</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Registration Status</label>
                    <asp:DropDownList ID="ddlEditRegStatus" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="UNREGISTERED" Text="Unregistered" />
                        <asp:ListItem Value="REGISTERED" Text="Registered" />
                        <asp:ListItem Value="LATE REGISTERED" Text="Late Registered" />
                        <asp:ListItem Value="CLEARED" Text="Cleared" />
                        <asp:ListItem Value="DISCONTINUED" Text="Discontinued" />
                        <asp:ListItem Value="HALTED" Text="Halted" />
                        <asp:ListItem Value="DEAD YEAR" Text="Dead Year" />
                    </asp:DropDownList>
                    <div class="hr-form-hint">Registered / Late / Cleared auto-bills if not yet billed.</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Residence</label>
                    <asp:DropDownList ID="ddlEditResidence" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="RESIDENT" Text="Resident" /><asp:ListItem Value="NON-RESIDENT" Text="Non-Resident" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row--3" style="display:grid;gap:10px;">
                <div class="hr-form-group">
                    <label class="hr-form-label">Exam Clearance</label>
                    <asp:DropDownList ID="ddlEditExamClearance" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="UNCLEARED" Text="Uncleared" /><asp:ListItem Value="CLEARED" Text="Cleared" /><asp:ListItem Value="PRINTED" Text="Printed" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Clearance Date</label>
                    <input type="date" id="txtEditClearanceDate" class="hr-form-input" />
                    <div class="hr-form-hint">Used when clearance = Cleared/Printed.</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">ID Card</label>
                    <asp:DropDownList ID="ddlEditIDCard" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="NOT ISSUED" Text="Not Issued" /><asp:ListItem Value="ISSUED" Text="Issued" />
                    </asp:DropDownList>
                </div>
            </div>

            <asp:HiddenField ID="hdnEditID" runat="server" />
            <asp:HiddenField ID="hdnEditClearanceDate" runat="server" />
            <div id="editResult" runat="server" class="hr-result" visible="false"><asp:Literal ID="litEditResult" runat="server" /></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeModal('editRegModal')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary" onclick="submitEdit()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Save Changes
            </button>
        </div>
    </div>
</div>

<!-- ======= DELETE REGISTRATION MODAL (summary + optional courses/billings) ======= -->
<div class="hr-modal-overlay" id="delRegModal">
    <div class="hr-modal" style="width:580px;">
        <div class="hr-modal__header" style="background:#b42318;">
            <span>Delete Semester Registration</span>
            <button class="hr-modal__close" onclick="closeModal('delRegModal')" type="button">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="drStudent" style="background:#fef3f2;border:1px solid #fbc9c4;padding:10px 12px;margin-bottom:12px;">
                <div id="drName" style="font-size:13px;font-weight:700;color:#7a271a;"></div>
                <div id="drSitting" style="font-size:11px;color:#912018;margin-top:2px;"></div>
            </div>
            <div id="drLoading" style="padding:14px;text-align:center;color:#888;font-size:12px;">Loading summary&hellip;</div>
            <div id="drContent" style="display:none;">
                <div class="hr-modal__section">What will be removed</div>
                <div style="display:flex;align-items:flex-start;gap:9px;padding:8px 10px;background:#f8fafc;border:1px solid #e4e8f0;margin-bottom:8px;">
                    <input type="checkbox" checked disabled style="margin-top:2px;" />
                    <div style="font-size:11.5px;"><b>The semester registration record</b> — always removed.</div>
                </div>
                <label style="display:flex;align-items:flex-start;gap:9px;padding:8px 10px;border:1px solid #e4e8f0;margin-bottom:8px;cursor:pointer;">
                    <input type="checkbox" id="drCourses" style="margin-top:2px;" onchange="drUpdateBtn()" />
                    <div style="font-size:11.5px;">Also delete <b><span id="drCourseCount">0</span> course registration(s)</b> for this semester
                        <div id="drCourseDetail" style="font-size:10px;color:#666;margin-top:3px;"></div>
                        <div id="drCourseWarn" style="display:none;font-size:10px;color:#b42318;font-weight:600;margin-top:3px;"></div>
                    </div>
                </label>
                <label style="display:flex;align-items:flex-start;gap:9px;padding:8px 10px;border:1px solid #e4e8f0;margin-bottom:8px;cursor:pointer;">
                    <input type="checkbox" id="drBillings" style="margin-top:2px;" onchange="drUpdateBtn()" />
                    <div style="font-size:11.5px;">Also delete this semester's <b>fee bills &amp; payments</b>
                        <div id="drBillDetail" style="font-size:10px;color:#666;margin-top:3px;"></div>
                    </div>
                </label>
                <div style="font-size:10px;color:#8a6d00;background:#fff8e1;border:1px solid #ffe0a3;padding:7px 10px;">
                    Every deleted row is backed up to <code>*_regdel_bak</code> tables first, so it can be recovered if needed.
                </div>
            </div>
            <div id="drStatus" style="display:none;padding:8px 10px;font-size:11px;margin-top:10px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--sm" onclick="closeModal('delRegModal')">Cancel</button>
            <button type="button" id="drConfirm" class="hr-btn hr-btn--danger hr-btn--sm" onclick="submitDeleteReg()" disabled>Delete Registration</button>
        </div>
    </div>
</div>

<!-- ======= TOAST ===================================================== -->
<div id="regToast" class="rg-toast" role="alert" aria-live="assertive">
    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
    <span id="regToastMsg"></span>
</div>

<script type="text/javascript">
// ===== Filter control IDs =====
var SR = {
    q   : '<%= txtSearch.ClientID %>',
    ay  : '<%= ddlAcadYear.ClientID %>',
    sem : '<%= ddlSemester.ClientID %>',
    sy  : '<%= ddlStudyYear.ClientID %>',
    rs  : '<%= ddlRegStatus.ClientID %>',
    prog: '<%= ddlProgramme.ClientID %>',
    ec  : '<%= ddlExamClearance.ClientID %>',
    idc : '<%= ddlIDCard.ClientID %>',
    res : '<%= ddlResidence.ClientID %>',
    bill: '<%= ddlBilling.ClientID %>',
    per : '<%= ddlPageSize.ClientID %>'
};
function byId(id){ return document.getElementById(id); }

// ===== Apply / reset filters =====
function cdApplyFilters(page){
    var q = new URLSearchParams();
    function put(name, id){ var el = byId(id); if(!el) return; var v=(el.value||'').trim(); if(v!=='') q.set(name, v); }
    put('q', SR.q);  put('ay', SR.ay);  put('sem', SR.sem); put('sy', SR.sy);
    put('rs', SR.rs); put('prog', SR.prog); put('ec', SR.ec); put('idc', SR.idc);
    put('res', SR.res); put('bill', SR.bill); put('per', SR.per);
    q.set('page', (page && page>0 ? page : 1).toString());
    window.location = window.location.pathname + '?' + q.toString();
}
function cdResetFilters(){ window.location = window.location.pathname; }

// ===== Advanced filter panel + chips =====
var ADV_KEYS = [
    { id:SR.sy,   label:'Study Year' },
    { id:SR.rs,   label:'Reg Status' },
    { id:SR.prog, label:'Programme' },
    { id:SR.ec,   label:'Exam Clearance' },
    { id:SR.idc,  label:'ID Card' },
    { id:SR.res,  label:'Residence' },
    { id:SR.bill, label:'Billing' }
];
function selText(el){ return (el && el.selectedIndex>=0) ? el.options[el.selectedIndex].text : ''; }
function toggleAdvFilters(){ byId('advPanel').classList.toggle('open'); }
function buildChips(){
    var wrap = byId('filterChips'); var html=''; var n=0;
    ADV_KEYS.forEach(function(k){
        var el = byId(k.id); if(!el || !el.value) return; n++;
        html += '<span class="sr-chip"><b>'+k.label+':</b> '+escHtml(selText(el))+'<span class="sr-chip__x" title="Remove" onclick="clearFilter(\''+k.id+'\')">&times;</span></span>';
    });
    // semester (primary but worth showing when set)
    var sem = byId(SR.sem);
    if(sem && sem.value){ html = '<span class="sr-chip"><b>Semester:</b> '+escHtml(selText(sem))+'<span class="sr-chip__x" title="Remove" onclick="clearFilter(\''+SR.sem+'\')">&times;</span></span>' + html; }
    var search = byId(SR.q);
    if(search && search.value.trim()!==''){ html = '<span class="sr-chip"><b>Search:</b> '+escHtml(search.value.trim())+'<span class="sr-chip__x" title="Remove" onclick="clearFilter(\''+SR.q+'\')">&times;</span></span>' + html; }
    var badge = byId('advCount');
    if(n>0){ badge.textContent = n; badge.style.display=''; } else { badge.style.display='none'; }
    if(html){ html += '<button type="button" class="sr-chip--clear" onclick="cdResetFilters()">Clear all</button>'; wrap.innerHTML = '<span class="sr-chips__lbl">Active</span>'+html; wrap.classList.add('show'); }
    else { wrap.classList.remove('show'); wrap.innerHTML=''; }
    if(n>0) byId('advPanel').classList.add('open');
}
function clearFilter(id){ var el=byId(id); if(!el) return; el.value=''; cdApplyFilters(1); }

// ===== Stat-card quick filters =====
function filterByStatus(status){ var el=byId(SR.rs); if(el){ el.value=status; cdApplyFilters(1); } }
function clearStatusFilter(){ var el=byId(SR.rs); if(el){ el.value=''; cdApplyFilters(1); } }
function filterByBilling(status){ var el=byId(SR.bill); if(el){ el.value=status; cdApplyFilters(1); } }

// ===== Action popover =====
function closeAllActionPopovers(){ document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){ p.classList.remove('is-open'); p.classList.remove('flip-up'); }); }
function toggleActionPopover(btn, e){
    e.stopPropagation();
    var p = btn.nextElementSibling; if(!p) return;
    var wasOpen = p.classList.contains('is-open');
    closeAllActionPopovers();
    if(!wasOpen){
        p.classList.add('is-open');
        var r = p.getBoundingClientRect();
        if(r.bottom > window.innerHeight - 8) p.classList.add('flip-up');
    }
}
document.addEventListener('click', function(){ closeAllActionPopovers(); });

// ===== Selection / batch =====
function srGetCheckedIds(){ var ids=[]; document.querySelectorAll('.sr-chk:checked').forEach(function(cb){ ids.push(cb.value); }); return ids; }
function srGetCount(){ return document.querySelectorAll('.sr-chk:checked').length; }
function srSelectAll(master){ document.querySelectorAll('.sr-chk').forEach(function(cb){ cb.checked = master.checked; }); updateBatchBar(); }
function srRowCheck(){
    var total = document.querySelectorAll('.sr-chk').length, chk = srGetCount();
    var mc = byId('chkSelAll'); if(mc){ mc.checked = (total>0 && chk===total); mc.indeterminate = (chk>0 && chk<total); }
    updateBatchBar();
}
function srClearSelection(){ document.querySelectorAll('.sr-chk').forEach(function(cb){ cb.checked=false; }); var mc=byId('chkSelAll'); if(mc){ mc.checked=false; mc.indeterminate=false; } updateBatchBar(); }
function updateBatchBar(){ var c=srGetCount(), bar=byId('batchBar'); if(c>0){ bar.classList.add('show'); byId('batchSelCount').textContent=c; } else { bar.classList.remove('show'); } }

var _batchBtnMap = {
    'clear':'<%= btnBatchClear.ClientID %>', 'undoreg':'<%= btnBatchUndoReg.ClientID %>', 'undoclear':'<%= btnBatchUndoClear.ClientID %>',
    'discontinue':'<%= btnBatchDiscontinue.ClientID %>', 'halt':'<%= btnBatchHalt.ClientID %>', 'deadyear':'<%= btnBatchDeadYear.ClientID %>',
    'reactivate':'<%= btnBatchReactivate.ClientID %>', 'delete':'<%= btnBatchDelete.ClientID %>'
};
var _batchMsgs = {
    'clear':'Clear selected students for exams?', 'undoreg':'Undo registration for selected students?', 'undoclear':'Undo exam clearance for selected students?',
    'discontinue':'DISCONTINUE selected students?', 'halt':'Halt registration for selected students?', 'deadyear':'Mark selected students as Dead Year?',
    'reactivate':'Reactivate selected students (reset to Unregistered)?', 'delete':'PERMANENTLY DELETE registration records for selected students? This cannot be undone!'
};
function doBatch(action){
    var ids = srGetCheckedIds();
    if(ids.length===0){ showToast(false,'Please select at least one student.'); return; }
    var msg = (_batchMsgs[action]||'Apply action?').replace('selected', ids.length+' selected');
    if(!confirm(msg)) return;
    byId('<%= hdnBatchIds.ClientID %>').value = ids.join(',');
    byId(_batchBtnMap[action]).click();
}

// ===== Modals =====
function closeModal(id){ byId(id).classList.remove('open'); }
function openAddRegModal(){ var err=byId('<%= addRegResult.ClientID %>'); if(err) err.style.display='none'; byId('addRegModal').classList.add('open'); }

/* ===== Delete Semester Registration (summary + optional courses/billings) ===== */
var _drId = 0;
function _drMoney(n){ n = Number(n)||0; return 'UGX ' + n.toLocaleString('en-US'); }
function _drStatus(msg, isErr){ var el=byId('drStatus'); el.style.display='block'; el.innerText=msg; el.style.background=isErr?'#fdecea':'#e6f4ea'; el.style.color=isErr?'#b42318':'#166534'; el.style.border='1px solid '+(isErr?'#f5c6cb':'#bbf7d0'); }
function drUpdateBtn(){ byId('drConfirm').disabled = false; }
function openDeleteRegModal(btn){
    if (typeof closeAllActionPopovers==='function') closeAllActionPopovers();
    var d = btn.dataset; _drId = parseInt(d.id,10)||0;
    if (!_drId) { alert('Missing registration id.'); return; }
    byId('drName').innerText = d.name || '(student)';
    byId('drSitting').innerText = (d.regno||'') + '  ·  ' + (d.acad||'') + '  ·  Year ' + (d.sy||'-') + ' Semester ' + (d.sem||'-');
    byId('drContent').style.display='none';
    byId('drLoading').style.display='block';
    byId('drStatus').style.display='none';
    byId('drCourses').checked=false; byId('drBillings').checked=false;
    byId('drConfirm').disabled=false; byId('drConfirm').innerText='Delete Registration';
    byId('delRegModal').classList.add('open');
    var xhr = new XMLHttpRequest();
    xhr.open('GET', window.location.pathname + '?ajax=delreg_summary&id=' + _drId, true);
    xhr.onreadystatechange = function(){
        if (xhr.readyState!==4) return;
        var r=null; try{ r=JSON.parse(xhr.responseText); }catch(e){}
        byId('drLoading').style.display='none';
        if (!r || !r.success) { _drStatus((r&&r.message)||'Could not load summary.', true); return; }
        var c=r.courses||{}, b=r.billings||{};
        byId('drCourseCount').innerText = c.count||0;
        byId('drCourseDetail').innerText = (c.count? (c.sample||[]).join(', ') + ((c.count>(c.sample||[]).length)?' …':'') : 'No course registrations for this semester.');
        var cw = byId('drCourseWarn');
        if (c.withMarks>0){ cw.style.display='block'; cw.innerText='⚠ '+c.withMarks+' of these already have marks captured/published — deleting loses those marks (recoverable from backup).'; }
        else cw.style.display='none';
        byId('drBillDetail').innerHTML = (b.sftCount? ('<b>'+(b.bills||0)+'</b> bill(s) ('+_drMoney(b.billAmt)+') · <b>'+(b.pays||0)+'</b> payment(s) ('+_drMoney(b.payAmt)+') · '+(b.glCount||0)+' GL entry(ies)') : 'No fee bills/payments recorded for this semester.');
        if (!c.count) { byId('drCourses').disabled=true; }
        if (!b.sftCount && !b.glCount) { byId('drBillings').disabled=true; }
        byId('drContent').style.display='block';
    };
    xhr.send();
}
function submitDeleteReg(){
    if (!_drId) return;
    var dc = byId('drCourses').checked, db = byId('drBillings').checked;
    var extra = (dc?'\n • its course registrations':'') + (db?'\n • its fee bills & payments':'');
    if (!confirm('Permanently delete this semester registration' + (extra? ' plus:'+extra : '') + '?\n\n(Backed up first — recoverable if needed.)')) return;
    var btn=byId('drConfirm'); btn.disabled=true; var o=btn.innerText; btn.innerText='Deleting…';
    var xhr=new XMLHttpRequest();
    xhr.open('POST', window.location.pathname + '?ajax=delreg_execute', true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if (xhr.readyState!==4) return;
        var r=null; try{ r=JSON.parse(xhr.responseText); }catch(e){}
        if (r && r.success){ _drStatus(r.message + ' Refreshing…', false); setTimeout(function(){ window.location.reload(); }, 800); }
        else { _drStatus((r&&r.message)||'Delete failed.', true); btn.disabled=false; btn.innerText=o; }
    };
    xhr.send('id=' + _drId + '&courses=' + (dc?'1':'0') + '&billings=' + (db?'1':'0'));
}

function setSelectEnsure(sel, value, label){
    if(!sel) return;
    value = (value==null) ? '' : String(value);
    var found=false;
    for(var i=0;i<sel.options.length;i++){ if(sel.options[i].value===value){ found=true; break; } }
    if(!found && value!==''){ sel.add(new Option(label||value, value)); }
    sel.value = value;
}
function openEditModal(btn){
    closeAllActionPopovers();
    var tr = btn.closest('tr'); if(!tr) return;
    function d(k){ return tr.getAttribute(k) || ''; }
    byId('edStudentName').textContent = d('data-name') || '—';
    byId('edRegNo').textContent       = d('data-regno');
    byId('edProg').textContent        = d('data-prog') || '—';
    byId('<%= hdnEditID.ClientID %>').value = d('data-id');
    setSelectEnsure(byId('<%= ddlEditAcadYear.ClientID %>'), d('data-ay'), d('data-ay'));
    setSelectEnsure(byId('<%= ddlEditSemester.ClientID %>'), d('data-sem'), 'Semester '+d('data-sem'));
    setSelectEnsure(byId('<%= ddlEditStudyYear.ClientID %>'), d('data-sy'), 'Year '+d('data-sy'));
    var rs = d('data-rs') || 'UNREGISTERED';
    setSelectEnsure(byId('<%= ddlEditRegStatus.ClientID %>'), rs, rs);
    var res = (d('data-res')==='RESIDENT') ? 'RESIDENT' : 'NON-RESIDENT';
    byId('<%= ddlEditResidence.ClientID %>').value = res;
    var ec = d('data-ec') || 'UNCLEARED';
    setSelectEnsure(byId('<%= ddlEditExamClearance.ClientID %>'), ec, ec);
    var idc = (d('data-idc')==='ISSUED') ? 'ISSUED' : 'NOT ISSUED';
    byId('<%= ddlEditIDCard.ClientID %>').value = idc;
    byId('txtEditClearanceDate').value = d('data-ecdate');
    var er = byId('<%= editResult.ClientID %>'); if(er) er.style.display='none';
    byId('editRegModal').classList.add('open');
}
function submitEdit(){
    byId('<%= hdnEditClearanceDate.ClientID %>').value = byId('txtEditClearanceDate').value || '';
    byId('<%= btnDoEditReg.ClientID %>').click();
}

// Close modal on overlay click
document.addEventListener('click', function(e){
    ['addRegModal','editRegModal'].forEach(function(id){ var el=byId(id); if(el && e.target===el) closeModal(id); });
});
document.addEventListener('keydown', function(e){
    if(e.key==='Escape'){ ['addRegModal','editRegModal'].forEach(function(id){ var el=byId(id); if(el && el.classList.contains('open')) closeModal(id); }); }
});

// ===== Toast =====
function showToast(success, message){
    var t=byId('regToast'); t.className='rg-toast rg-toast--'+(success?'success':'error');
    byId('regToastMsg').textContent=message;
    setTimeout(function(){ t.classList.add('show'); },10);
    setTimeout(function(){ t.classList.remove('show'); },4500);
}

// ===== Searchable combo (programme) =====
function enhanceSearchableSelect(sel, placeholder){
    if(!sel || sel.getAttribute('data-combo')==='1') return;
    sel.setAttribute('data-combo','1'); sel.style.display='none';
    var combo=document.createElement('div'); combo.className='sr-combo';
    var input=document.createElement('input'); input.type='text'; input.placeholder=placeholder||'Search...'; input.autocomplete='off';
    var menu=document.createElement('div'); menu.className='sr-combo__menu';
    combo.appendChild(input); combo.appendChild(menu);
    sel.parentNode.insertBefore(combo, sel.nextSibling);
    var items=[], activeIdx=-1;
    function curLabel(){ var o=sel.options[sel.selectedIndex]; return o?o.text:''; }
    function syncInput(){ input.value=curLabel(); }
    function isOpen(){ return menu.className.indexOf('show')!==-1; }
    function build(f){
        menu.innerHTML=''; items=[]; activeIdx=-1; f=(f||'').toLowerCase();
        for(var i=0;i<sel.options.length;i++){
            var o=sel.options[i], t=o.text||'';
            if(f && t.toLowerCase().indexOf(f)===-1) continue;
            var d=document.createElement('div'); d.className='sr-combo__opt'; d.textContent=t; d.setAttribute('data-idx',i);
            if(i===sel.selectedIndex) d.className+=' active';
            d.onmousedown=function(ev){ ev.preventDefault(); choose(parseInt(this.getAttribute('data-idx'),10)); };
            menu.appendChild(d); items.push(d);
        }
        if(!items.length){ var n=document.createElement('div'); n.className='sr-combo__opt sr-combo__opt--none'; n.textContent='No matches'; menu.appendChild(n); }
    }
    function open(){ build(''); menu.className='sr-combo__menu show'; try{ input.select(); }catch(e){} }
    function close(){ menu.className='sr-combo__menu'; syncInput(); }
    function choose(idx){ sel.selectedIndex=idx; syncInput(); menu.className='sr-combo__menu'; try{ sel.dispatchEvent(new Event('change')); }catch(e){ try{ var ev=document.createEvent('HTMLEvents'); ev.initEvent('change',true,false); sel.dispatchEvent(ev); }catch(e2){} } }
    function setActive(n){ if(!items.length) return; activeIdx=(n+items.length)%items.length; for(var i=0;i<items.length;i++){ items[i].className=(i===activeIdx)?'sr-combo__opt active':'sr-combo__opt'; } try{ items[activeIdx].scrollIntoView(false); }catch(e){} }
    syncInput();
    input.onfocus=open;
    input.onclick=function(){ if(!isOpen()) open(); };
    input.oninput=function(){ build(input.value); menu.className='sr-combo__menu show'; };
    input.onkeydown=function(e){
        var k=e.key;
        if(k==='ArrowDown'||k==='Down'){ e.preventDefault(); if(!isOpen()) open(); setActive(activeIdx+1); }
        else if(k==='ArrowUp'||k==='Up'){ e.preventDefault(); setActive(activeIdx-1); }
        else if(k==='Enter'){ if(isOpen() && items.length){ e.preventDefault(); e.stopPropagation(); var i=activeIdx>=0?activeIdx:0; choose(parseInt(items[i].getAttribute('data-idx'),10)); } }
        else if(k==='Escape'||k==='Esc'){ if(isOpen()){ e.stopPropagation(); close(); } }
    };
    document.addEventListener('mousedown', function(e){ if(!combo.contains(e.target)) close(); });
}

function escHtml(s){ var d=document.createElement('div'); d.textContent=(s==null?'':s); return d.innerHTML; }

// ===== Billing bars =====
function updateBillingBars(){
    var heroEl = document.querySelector('.rg-stat--hero .rg-stat__val'); if(!heroEl) return;
    var total = parseInt((heroEl.textContent||'0').replace(/[^0-9]/g,''),10)||0; if(total<=0) return;
    [['billedBar','.rg-stat--teal .rg-stat__val'],['notBilledBar','.rg-stat--brown .rg-stat__val']].forEach(function(p){
        var bar=byId(p[0]), v=document.querySelector(p[1]); if(bar && v){ var n=parseInt((v.textContent||'0').replace(/[^0-9]/g,''),10)||0; bar.style.width=Math.round(n/total*100)+'%'; }
    });
}

// ===== Init =====
document.addEventListener('DOMContentLoaded', function(){
    var tb = byId(SR.q);
    if(tb) tb.addEventListener('keydown', function(e){ if(e.keyCode===13){ e.preventDefault(); cdApplyFilters(1); } });
    [SR.ay, SR.sem, SR.sy, SR.rs, SR.prog, SR.ec, SR.idc, SR.res, SR.bill, SR.per].forEach(function(id){
        var el = byId(id); if(el) el.addEventListener('change', function(){ cdApplyFilters(1); });
    });
    // highlight active stat cards
    var rsVal = (byId(SR.rs)||{}).value || '';
    var billVal = (byId(SR.bill)||{}).value || '';
    document.querySelectorAll('.rg-stat[data-status]').forEach(function(c){ if(c.getAttribute('data-status')===rsVal && rsVal!=='') c.classList.add('is-active'); });
    document.querySelectorAll('.rg-stat[data-billing]').forEach(function(c){ if(c.getAttribute('data-billing')===billVal && billVal!=='') c.classList.add('is-active'); });
    enhanceSearchableSelect(byId(SR.prog), 'Type programme...');
    buildChips();
    updateBillingBars();
});
</script>
</asp:Content>
