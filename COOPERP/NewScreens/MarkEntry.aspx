<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarkEntry.aspx.cs" Inherits="COOPERP_NewScreens_MarkEntry" Title="Mark Entry - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
/* ===== MARK ENTRY (prefix: me-) ======================================== */

/* Context Bar */
.me-ctx { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 12px; }
.me-ctx__top { background: linear-gradient(135deg, #05275C 0%, #174DA4 100%); color: #fff; padding: 14px 18px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px; }
.me-ctx__course { font-size: 14px; font-weight: 700; }
.me-ctx__sub { font-size: 10px; opacity: .8; margin-top: 2px; }
.me-ctx__status { padding: 3px 10px; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; border-radius: 2px; }
.me-ctx__status--draft       { background: rgba(255,255,255,.2); color: #fff; }
.me-ctx__status--submitted   { background: #e3f2fd; color: #1565c0; }
.me-ctx__status--approved    { background: #e6f4ea; color: #2e7d32; }
.me-ctx__status--provisional { background: #fff3e0; color: #e65100; }
.me-ctx__status--published   { background: #e8f0fc; color: #174DA4; }

/* Info Strip */
.me-info { display: flex; flex-wrap: wrap; gap: 0; border-bottom: 1px solid #e0e5ed; }
.me-info__item { padding: 8px 16px; font-size: 11px; color: #555; border-right: 1px solid #e0e5ed; display: flex; align-items: center; gap: 6px; }
.me-info__item:last-child { border-right: none; }
.me-info__val { font-weight: 700; color: #222; }

/* Lock Alerts */
.me-locks { margin: 0 0 12px; }
.me-lock { padding: 8px 14px; font-size: 11px; display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.me-lock--hard { background: #fde8e8; color: #c62828; border-left: 3px solid #c62828; }
.me-lock--soft { background: #fff3e0; color: #e65100; border-left: 3px solid #e65100; }
.me-lock__icon { flex-shrink: 0; }

/* Rejection Banner */
.me-rejection { background: #fce4ec; border-left: 3px solid #c62828; padding: 10px 14px; margin-bottom: 12px; font-size: 11px; color: #c62828; }
.me-rejection strong { font-weight: 700; }

/* Toolbar */
.me-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 10px 16px; background: #f8f9fb; border: 1px solid #e0e5ed; margin-bottom: 12px; flex-wrap: wrap; }
.me-toolbar__left { display: flex; align-items: center; gap: 8px; }
.me-toolbar__right { display: flex; align-items: center; gap: 8px; }
.me-toolbar__search { padding: 5px 10px; border: 1px solid #d1d5db; font-size: 11px; width: 180px; background: #fff; }
.me-toolbar__search:focus { outline: none; border-color: #174DA4; }
.me-toolbar__btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: flex; align-items: center; gap: 5px; transition: opacity .15s; }
.me-toolbar__btn:hover { opacity: .85; }
.me-toolbar__btn--save { background: #2e7d32; color: #fff; }
.me-toolbar__btn--submit { background: #174DA4; color: #fff; }
.me-toolbar__btn--back { background: #f0f0f0; color: #555; border: 1px solid #d1d5db; }
.me-toolbar__btn:disabled { opacity: .4; cursor: not-allowed; }
.me-toolbar__saved { font-size: 10px; color: #888; display: flex; align-items: center; gap: 4px; }
.me-toolbar__saved--ok { color: #2e7d32; }
.me-toolbar__dirty { font-size: 10px; color: #e65100; font-weight: 600; display: none; }

/* Mark Table */
.me-table-wrap { background: #fff; border: 1px solid #e0e5ed; overflow-x: auto; margin-bottom: 12px; }
.me-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.me-table thead th { background: #f0f2f5; color: #05275C; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; padding: 8px 10px; border-bottom: 2px solid #d1d5db; position: sticky; top: 0; z-index: 2; white-space: nowrap; text-align: center; }
.me-table thead th:first-child, .me-table thead th:nth-child(2) { text-align: left; }
.me-table tbody tr { border-bottom: 1px solid #eee; transition: background .1s; }
.me-table tbody tr:hover { background: #f6f8fc; }
.me-table tbody tr.me-row--dirty { background: #fffde7; }
.me-table tbody tr.me-row--missing { border-left: 3px solid #ff9800; }
.me-table tbody tr.me-row--approved { background: #f1f8e9; }
.me-table tbody tr.me-row--error { background: #fde8e8; }
.me-table tbody td { padding: 5px 8px; vertical-align: middle; text-align: center; }
.me-table tbody td:first-child { text-align: center; color: #999; width: 35px; font-size: 10px; }
.me-table tbody td:nth-child(2) { text-align: left; }

/* Student Info Cell */
.me-student { display: flex; flex-direction: column; }
.me-student__name { font-weight: 600; color: #222; font-size: 11px; }
.me-student__regno { font-size: 9px; color: #888; }

/* Mark Input Fields */
.me-input { width: 60px; padding: 4px 6px; border: 1px solid #d1d5db; text-align: center; font-size: 12px; font-weight: 600; font-variant-numeric: tabular-nums; background: #fff; transition: border-color .15s, background .15s; }
.me-input:focus { outline: none; border-color: #174DA4; background: #e8f0fc; box-shadow: 0 0 0 2px rgba(23,77,164,.15); }
.me-input:disabled { background: #f0f0f0; color: #999; cursor: not-allowed; border-color: #e0e0e0; }
.me-input--invalid { border-color: #c62828 !important; background: #fde8e8 !important; }
.me-input--warn { border-color: #e65100 !important; background: #fff3e0 !important; }

/* Computed Columns */
.me-weighted { font-size: 10px; color: #888; font-variant-numeric: tabular-nums; }
.me-total { font-weight: 700; font-size: 13px; font-variant-numeric: tabular-nums; }
.me-total--pass { color: #2e7d32; }
.me-total--fail { color: #c62828; }
.me-total--none { color: #ccc; }
.me-grade { font-weight: 700; font-size: 12px; padding: 2px 6px; display: inline-block; min-width: 24px; text-align: center; }
.me-grade--A, .me-grade--A-plus { background: #e6f4ea; color: #2e7d32; }
.me-grade--B, .me-grade--B-plus { background: #e3f2fd; color: #1565c0; }
.me-grade--C, .me-grade--C-plus { background: #fff3e0; color: #e65100; }
.me-grade--D, .me-grade--D-plus { background: #fff8e1; color: #f57f17; }
.me-grade--F { background: #fde8e8; color: #c62828; }
.me-approved { font-size: 9px; color: #2e7d32; font-weight: 600; }

/* Keyboard Help */
.me-keyboard { background: #f8f9fb; border: 1px solid #e0e5ed; padding: 8px 14px; font-size: 10px; color: #888; display: flex; align-items: center; gap: 16px; margin-bottom: 12px; }
.me-keyboard kbd { display: inline-block; padding: 1px 5px; background: #fff; border: 1px solid #d1d5db; font-size: 10px; font-family: monospace; border-radius: 2px; }

/* Summary Bar */
.me-summary { display: flex; flex-wrap: wrap; gap: 0; background: #f0f2f5; border: 1px solid #e0e5ed; margin-bottom: 12px; }
.me-summary__item { padding: 8px 16px; font-size: 11px; border-right: 1px solid #d1d5db; }
.me-summary__item:last-child { border-right: none; }
.me-summary__label { color: #888; font-size: 9px; text-transform: uppercase; }
.me-summary__val { font-weight: 700; color: #222; }
.me-summary__val--ok { color: #2e7d32; }
.me-summary__val--warn { color: #e65100; }
.me-summary__val--bad { color: #c62828; }

/* Submit Modal */
.me-modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 1000; align-items: center; justify-content: center; }
.me-modal-overlay.active { display: flex; }
.me-modal { background: #fff; width: 480px; max-width: 95vw; max-height: 85vh; overflow-y: auto; box-shadow: 0 8px 32px rgba(0,0,0,.2); }
.me-modal__head { background: #05275C; color: #fff; padding: 14px 18px; font-size: 13px; font-weight: 700; display: flex; align-items: center; justify-content: space-between; }
.me-modal__close { background: none; border: none; color: #fff; cursor: pointer; font-size: 16px; opacity: .7; }
.me-modal__close:hover { opacity: 1; }
.me-modal__body { padding: 18px; }
.me-modal__row { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #f0f0f0; font-size: 12px; }
.me-modal__row:last-child { border-bottom: none; }
.me-modal__rlabel { color: #888; }
.me-modal__rval { font-weight: 700; color: #222; }
.me-modal__warn { background: #fff3e0; padding: 8px 12px; margin: 10px 0; font-size: 11px; color: #e65100; border-left: 3px solid #e65100; }
.me-modal__confirm { display: flex; align-items: center; gap: 6px; margin: 12px 0; font-size: 11px; }
.me-modal__confirm input[type=checkbox] { margin: 0; }
.me-modal__foot { padding: 12px 18px; border-top: 1px solid #e0e5ed; display: flex; justify-content: flex-end; gap: 8px; }
.me-modal__btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; }
.me-modal__btn--cancel { background: #f0f0f0; color: #555; }
.me-modal__btn--submit { background: #174DA4; color: #fff; }
.me-modal__btn:disabled { opacity: .4; cursor: not-allowed; }

/* Toast */
.me-toast { position: fixed; bottom: 24px; right: 24px; padding: 10px 18px; font-size: 12px; font-weight: 600; color: #fff; z-index: 2000; transform: translateY(80px); opacity: 0; transition: transform .25s, opacity .25s; pointer-events: none; }
.me-toast.show { transform: translateY(0); opacity: 1; }
.me-toast--ok { background: #2e7d32; }
.me-toast--err { background: #c62828; }
.me-toast--warn { background: #e65100; }

/* Loading */
.me-loading { text-align: center; padding: 40px; font-size: 12px; color: #888; }
.me-loading span { display: inline-block; animation: me-spin 1s linear infinite; }
@keyframes me-spin { to { transform: rotate(360deg); } }

/* CSV Import (E-05) */
.me-toolbar__btn--import { background: #1565c0; color: #fff; }
.me-import-modal { width: 700px; max-width: 95vw; }
.me-import__info { font-size: 11px; color: #555; margin-bottom: 12px; }
.me-import__info a { color: #174DA4; font-weight: 600; text-decoration: underline; }
.me-import__zone { border: 2px dashed #d1d5db; padding: 24px; text-align: center; margin-bottom: 12px; transition: border-color .2s; }
.me-import__zone:hover { border-color: #174DA4; }
.me-import__zone svg { margin-bottom: 6px; }
.me-import__hint { font-size: 9px; color: #999; margin-top: 4px; }
.me-import__summary { font-size: 11px; margin-bottom: 8px; padding: 6px 10px; background: #f8f9fb; border: 1px solid #e0e5ed; }
.me-import__preview-wrap { max-height: 300px; overflow-y: auto; border: 1px solid #e0e5ed; }
.me-import__table { width: 100%; border-collapse: collapse; font-size: 11px; }
.me-import__table thead th { background: #f0f2f5; padding: 6px 8px; font-size: 10px; font-weight: 700; text-transform: uppercase; border-bottom: 1px solid #d1d5db; text-align: center; position: sticky; top: 0; }
.me-import__table thead th:nth-child(2), .me-import__table thead th:nth-child(3) { text-align: left; }
.me-import__table tbody td { padding: 4px 8px; border-bottom: 1px solid #eee; text-align: center; }
.me-import__table tbody td:nth-child(2), .me-import__table tbody td:nth-child(3) { text-align: left; }
.me-import__badge { display: inline-block; padding: 1px 6px; font-size: 9px; font-weight: 700; border-radius: 2px; }
.me-import__badge--ok { background: #e6f4ea; color: #2e7d32; }
.me-import__badge--warn { background: #fff3e0; color: #e65100; }
.me-import__badge--error { background: #fde8e8; color: #c62828; }

/* Responsive */
@media (max-width: 768px) {
    .me-ctx__top { flex-direction: column; align-items: flex-start; }
    .me-info { flex-direction: column; }
    .me-info__item { border-right: none; border-bottom: 1px solid #e0e5ed; }
    .me-toolbar { flex-direction: column; align-items: stretch; }
    .me-toolbar__left, .me-toolbar__right { justify-content: center; }
    .me-input { width: 50px; }
    .me-summary { flex-direction: column; }
    .me-summary__item { border-right: none; border-bottom: 1px solid #d1d5db; }
}

/* Archive Banner (E-11) */
.me-archive-banner { background: linear-gradient(135deg, #37474f, #546e7a); color: #fff; padding: 12px 18px; margin-bottom: 12px; display: flex; align-items: center; gap: 10px; font-size: 12px; border-left: 4px solid #90a4ae; }
.me-archive-banner__icon { font-size: 18px; flex-shrink: 0; }
.me-archive-banner__text { font-weight: 700; letter-spacing: .3px; }
.me-archive-banner__sub { font-size: 10px; opacity: .8; font-weight: 400; margin-top: 2px; }

/* Unlock Request Button (F-03) */
.me-lock__unlock-btn { margin-left: auto; padding: 3px 10px; font-size: 10px; font-weight: 600; background: #fff; color: #174DA4; border: 1px solid #174DA4; cursor: pointer; transition: background .15s; }
.me-lock__unlock-btn:hover { background: #e8f0fc; }

/* Unlock Request Modal (F-03) */
.me-unlock-modal { width: 420px; }
.me-unlock__field { margin-bottom: 12px; }
.me-unlock__label { display: block; font-size: 11px; font-weight: 600; color: #333; margin-bottom: 4px; }
.me-unlock__select { width: 100%; padding: 6px 10px; border: 1px solid #d1d5db; font-size: 12px; background: #fff; }
.me-unlock__textarea { width: 100%; padding: 6px 10px; border: 1px solid #d1d5db; font-size: 12px; min-height: 80px; resize: vertical; font-family: inherit; }
.me-unlock__hint { font-size: 9px; color: #999; margin-top: 2px; }

/* Grade Distribution Bars (E-06) */
.me-dist { margin: 12px 0; }
.me-dist__title { font-size: 11px; font-weight: 700; color: #333; margin-bottom: 6px; }
.me-dist__bar-row { display: flex; align-items: center; gap: 6px; margin-bottom: 3px; font-size: 11px; }
.me-dist__bar-label { width: 28px; font-weight: 600; text-align: right; color: #555; }
.me-dist__bar-track { flex: 1; height: 16px; background: #f0f0f0; border-radius: 2px; overflow: hidden; position: relative; }
.me-dist__bar-fill { height: 100%; border-radius: 2px; transition: width .3s; }
.me-dist__bar-fill--A { background: #2e7d32; }
.me-dist__bar-fill--B { background: #1565c0; }
.me-dist__bar-fill--C { background: #e65100; }
.me-dist__bar-fill--D { background: #f57f17; }
.me-dist__bar-fill--F { background: #c62828; }
.me-dist__bar-count { width: 30px; font-size: 10px; color: #888; }

/* Missing Students List (E-06) */
.me-missing { margin: 10px 0; max-height: 120px; overflow-y: auto; border: 1px solid #f0f0f0; }
.me-missing__title { font-size: 11px; font-weight: 700; color: #c62828; margin-bottom: 4px; }
.me-missing__item { padding: 3px 8px; font-size: 10px; border-bottom: 1px solid #f8f8f8; display: flex; justify-content: space-between; }
.me-missing__item:nth-child(even) { background: #fafafa; }
.me-missing__name { color: #333; }
.me-missing__regno { color: #888; font-family: monospace; }

/* Reconciliation Panel (B-06) */
.me-reconcile { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 12px; display: none; }
.me-reconcile__head { display: flex; align-items: center; justify-content: space-between; padding: 10px 16px; background: #f0f2f5; border-bottom: 1px solid #e0e5ed; }
.me-reconcile__title { font-size: 12px; font-weight: 700; color: #05275C; }
.me-reconcile__close { background: none; border: none; cursor: pointer; font-size: 14px; color: #888; }
.me-reconcile__close:hover { color: #333; }
.me-reconcile__stats { display: flex; gap: 0; border-bottom: 1px solid #e0e5ed; }
.me-reconcile__stat { flex: 1; padding: 10px 14px; border-right: 1px solid #e0e5ed; text-align: center; }
.me-reconcile__stat:last-child { border-right: none; }
.me-reconcile__stat-val { font-size: 18px; font-weight: 700; }
.me-reconcile__stat-val--ok { color: #2e7d32; }
.me-reconcile__stat-val--warn { color: #e65100; }
.me-reconcile__stat-val--bad { color: #c62828; }
.me-reconcile__stat-label { font-size: 9px; color: #888; text-transform: uppercase; }
.me-reconcile__section { padding: 10px 16px; }
.me-reconcile__section-title { font-size: 11px; font-weight: 700; margin-bottom: 6px; }
.me-reconcile__section-title--missing { color: #c62828; }
.me-reconcile__section-title--extra { color: #e65100; }
.me-reconcile__list { max-height: 180px; overflow-y: auto; border: 1px solid #f0f0f0; }
.me-reconcile__row { display: flex; justify-content: space-between; padding: 4px 8px; font-size: 11px; border-bottom: 1px solid #f8f8f8; }
.me-reconcile__row:nth-child(even) { background: #fafafa; }
.me-reconcile__row-name { color: #333; }
.me-reconcile__row-regno { color: #888; font-family: monospace; font-size: 10px; }
.me-reconcile__row-status { font-size: 9px; padding: 1px 5px; font-weight: 600; }
.me-reconcile__ok { background: #e6f4ea; padding: 10px 16px; font-size: 11px; color: #2e7d32; text-align: center; }
.me-toolbar__btn--reconcile { background: #f0f0ff; color: #174DA4; border: 1px solid #d1d5db; }
.me-toolbar__btn--sync { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }
.me-toolbar__btn--export { background: #e8eaf6; color: #283593; border: 1px solid #c5cae9; }
.me-toolbar__btn--print { background: #f5f5f5; color: #333; border: 1px solid #d1d5db; }
.me-toolbar__btn--sync:disabled { opacity: .4; cursor: not-allowed; }

/* Print Stylesheet (Batch 12) */
@media print {
    /* Hide non-printable elements */
    .cd-sidebar, .cd-topbar, .me-toolbar, .me-keyboard, .me-archive-banner,
    .me-modal-overlay, .me-reconcile, .me-toast, .me-loading, .me-rejection,
    .me-dist, .me-missing, .me-unlock-modal, #meSubmitOverlay,
    #meImportOverlay, #meUnlockOverlay, #meReconcilePanel, #meSummary { display: none !important; }

    /* Reset layout */
    body, .cd-app, .cd-main, .cd-content { margin: 0 !important; padding: 0 !important; width: 100% !important; max-width: 100% !important; }
    .me-ctx { border: none !important; margin: 0 0 8px !important; }
    .me-ctx__top { background: #fff !important; color: #000 !important; padding: 0 !important; }
    .me-ctx__course { font-size: 16pt !important; color: #000 !important; }
    .me-ctx__sub { font-size: 10pt !important; color: #333 !important; }
    .me-ctx__status { display: none !important; }
    .me-info { border: none !important; }
    .me-info__item { font-size: 9pt !important; border-color: #ccc !important; }

    /* Print header (visible only in print) */
    .me-print-header { display: block !important; text-align: center; margin-bottom: 8px; border-bottom: 2px solid #000; padding-bottom: 6px; }
    .me-print-header__inst { font-size: 14pt; font-weight: 700; }
    .me-print-header__sub { font-size: 10pt; color: #333; margin-top: 2px; }

    /* Table print styling */
    .me-table-wrap { border: none !important; overflow: visible !important; }
    .me-table { font-size: 9pt !important; }
    .me-table thead th { background: #f0f0f0 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; font-size: 8pt !important; padding: 4px 6px !important; border: 1px solid #999 !important; }
    .me-table tbody td { padding: 3px 6px !important; border: 1px solid #ccc !important; }
    .me-table tbody tr:hover { background: transparent !important; }
    .me-table tbody tr.me-row--dirty { background: transparent !important; }
    .me-table tbody tr.me-row--approved { background: transparent !important; }
    .me-input { border: none !important; background: transparent !important; text-align: center; font-size: 9pt !important; }

    /* Signature lines (visible only in print) */
    .me-print-sig { display: flex !important; justify-content: space-between; margin-top: 40px; gap: 60px; }
    .me-print-sig__block { flex: 1; text-align: center; font-size: 10pt; }
    .me-print-sig__line { border-top: 1px solid #000; margin-top: 30px; padding-top: 4px; }

    @page { size: landscape; margin: 10mm; }
}

/* Hidden print elements (only visible during print) */
.me-print-header { display: none; }
.me-print-sig { display: none; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Loading -->
<div id="meLoading" class="me-loading"><span>&#9696;</span> Loading mark sheet&hellip;</div>

<!-- Context Bar -->
<div id="meCtx" class="me-ctx" style="display:none;">
    <div class="me-ctx__top">
        <div>
            <div class="me-ctx__course" id="meCourseName"></div>
            <div class="me-ctx__sub" id="meCourseContext"></div>
        </div>
        <div class="me-ctx__status" id="meStatus"></div>
    </div>
    <div class="me-info">
        <div class="me-info__item">CW Ratio <span class="me-info__val" id="meCwRatio">0</span>%</div>
        <div class="me-info__item">Test Ratio <span class="me-info__val" id="meTestRatio">0</span>%</div>
        <div class="me-info__item">Exam Ratio <span class="me-info__val" id="meExamRatio">0</span>%</div>
        <div class="me-info__item">Expected <span class="me-info__val" id="meExpected">—</span></div>
        <div class="me-info__item">Entered <span class="me-info__val" id="meEntered">—</span></div>
        <div class="me-info__item">Missing <span class="me-info__val" id="meMissing">—</span></div>
    </div>
</div>

<!-- Lock Banners -->
<div id="meLocks" class="me-locks"></div>

<!-- Archive Banner (E-11) -->
<div id="meArchiveBanner" class="me-archive-banner" style="display:none;">
    <span class="me-archive-banner__icon">&#128451;</span>
    <div>
        <div class="me-archive-banner__text">ARCHIVED &mdash; Read Only</div>
        <div class="me-archive-banner__sub">This academic year has been completed. Marks are locked and cannot be modified.</div>
    </div>
</div>

<!-- Rejection Banner -->
<div id="meRejection" class="me-rejection" style="display:none;"></div>

<!-- Toolbar -->
<div id="meToolbar" class="me-toolbar" style="display:none;">
    <div class="me-toolbar__left">
        <button class="me-toolbar__btn me-toolbar__btn--back" onclick="ME.goBack()" title="Back to Dashboard">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
            Dashboard
        </button>
        <input type="text" class="me-toolbar__search" id="meSearch" placeholder="Search student..." oninput="ME.filterRows(this.value)" />
    </div>
    <div class="me-toolbar__right">
        <span class="me-toolbar__dirty" id="meDirtyLabel">&#9679; Unsaved changes</span>
        <span class="me-toolbar__saved" id="meSavedLabel"></span>
        <button class="me-toolbar__btn me-toolbar__btn--save" id="meSaveBtn" onclick="ME.saveMarks()" disabled>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/></svg>
            Save (Ctrl+S)
        </button>
        <button class="me-toolbar__btn me-toolbar__btn--import" id="meImportBtn" onclick="ME.showImportModal()">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            Import CSV
        </button>
        <button class="me-toolbar__btn me-toolbar__btn--reconcile" id="meReconcileBtn" onclick="ME.showReconcile()" title="Compare registered students vs marksheet">
            &#128269; Reconcile
        </button>
        <button class="me-toolbar__btn me-toolbar__btn--sync" id="meSyncBtn" onclick="ME.syncSheet()" title="Add missing registered students to marksheet">
            &#8635; Sync Sheet
        </button>
        <button class="me-toolbar__btn me-toolbar__btn--export" id="meExportBtn" onclick="ME.exportCsv()" title="Download mark sheet as CSV">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Export CSV
        </button>
        <button class="me-toolbar__btn me-toolbar__btn--print" id="mePrintBtn" onclick="ME.printSheet()" title="Print mark sheet">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 01-2-2v-5a2 2 0 012-2h16a2 2 0 012 2v5a2 2 0 01-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print
        </button>
        <button class="me-toolbar__btn me-toolbar__btn--submit" id="meSubmitBtn" onclick="ME.showSubmitModal()" disabled>
            Submit for Review &#9654;
        </button>
    </div>
</div>

<!-- Keyboard Help -->
<div id="meKbHelp" class="me-keyboard" style="display:none;">
    <kbd>Tab</kbd> Next cell &nbsp;
    <kbd>Shift+Tab</kbd> Prev cell &nbsp;
    <kbd>Enter</kbd> / <kbd>&#8595;</kbd> Next row &nbsp;
    <kbd>&#8593;</kbd> Prev row &nbsp;
    <kbd>Ctrl+S</kbd> Save &nbsp;
    <kbd>Esc</kbd> Cancel edit
</div>

<!-- Reconciliation Panel (B-06) -->
<div id="meReconcilePanel" class="me-reconcile" style="display:none;">
    <div class="me-reconcile__head">
        <span class="me-reconcile__title">&#128269; Registration Reconciliation</span>
        <button class="me-reconcile__close" onclick="ME.hideReconcile()">&times;</button>
    </div>
    <div id="meReconcileBody"></div>
</div>

<!-- Print Header (Batch 12 — visible only when printing) -->
<div class="me-print-header">
    <div class="me-print-header__inst">Mutesa I Royal University</div>
    <div class="me-print-header__sub">Mark Sheet</div>
</div>

<!-- Mark Table -->
<div id="meTableWrap" class="me-table-wrap" style="display:none;">
    <table class="me-table" id="meTable">
        <thead>
            <tr>
                <th>#</th>
                <th>Student</th>
                <th>CW Entered<br/><span id="meThCwMax" style="font-weight:400;font-size:9px;color:#888;"></span></th>
                <th>CW Wt</th>
                <th id="meThTest" style="display:none;">Test Entered<br/><span id="meThTestMax" style="font-weight:400;font-size:9px;color:#888;"></span></th>
                <th id="meThTestWt" style="display:none;">Test Wt</th>
                <th>Exam Entered<br/><span id="meThExamMax" style="font-weight:400;font-size:9px;color:#888;"></span></th>
                <th>Exam Wt</th>
                <th>Total</th>
                <th>Grade</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody id="meBody"></tbody>
    </table>
</div>

<!-- Summary Bar -->
<div id="meSummary" class="me-summary" style="display:none;">
    <div class="me-summary__item"><div class="me-summary__label">Total Students</div><div class="me-summary__val" id="meSumTotal">0</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Marks Entered</div><div class="me-summary__val" id="meSumEntered">0</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Average</div><div class="me-summary__val" id="meSumAvg">—</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Pass Rate</div><div class="me-summary__val" id="meSumPass">—</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Highest</div><div class="me-summary__val" id="meSumHigh">—</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Lowest</div><div class="me-summary__val" id="meSumLow">—</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Grade A</div><div class="me-summary__val" id="meSumA">0</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Grade B</div><div class="me-summary__val" id="meSumB">0</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Grade C</div><div class="me-summary__val" id="meSumC">0</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Grade D</div><div class="me-summary__val" id="meSumD">0</div></div>
    <div class="me-summary__item"><div class="me-summary__label">Grade F</div><div class="me-summary__val me-summary__val--bad" id="meSumF">0</div></div>
</div>

<!-- Print Signature Lines (Batch 12 — visible only when printing) -->
<div class="me-print-sig">
    <div class="me-print-sig__block">
        <div class="me-print-sig__line">Lecturer Signature &amp; Date</div>
    </div>
    <div class="me-print-sig__block">
        <div class="me-print-sig__line">Head of Department</div>
    </div>
    <div class="me-print-sig__block">
        <div class="me-print-sig__line">Dean of Faculty</div>
    </div>
</div>

<!-- Submit Modal -->
<div class="me-modal-overlay" id="meSubmitOverlay">
    <div class="me-modal">
        <div class="me-modal__head">
            <span>Submit Marks for Review</span>
            <button class="me-modal__close" onclick="ME.hideSubmitModal()">&times;</button>
        </div>
        <div class="me-modal__body" id="meSubmitBody">
            <!-- Populated by JS -->
        </div>
        <div class="me-modal__foot">
            <button class="me-modal__btn me-modal__btn--cancel" onclick="ME.hideSubmitModal()">Cancel</button>
            <button class="me-modal__btn me-modal__btn--submit" id="meConfirmSubmitBtn" onclick="ME.confirmSubmit()" disabled>Submit for Review</button>
        </div>
    </div>
</div>

<!-- Import CSV Modal (E-05) -->
<div class="me-modal-overlay" id="meImportOverlay">
    <div class="me-modal me-import-modal">
        <div class="me-modal__head">
            <span>Import Marks from CSV</span>
            <button class="me-modal__close" onclick="ME.hideImportModal()">&times;</button>
        </div>
        <div class="me-modal__body">
            <div class="me-import__info">
                Download the <a href="javascript:void(0)" onclick="ME.downloadTemplate()">CSV template</a> with student registration numbers pre-filled,
                enter the marks, then upload the completed file.
            </div>
            <div class="me-import__zone" id="meImportZone">
                <input type="file" id="meImportFile" accept=".csv" onchange="ME.handleCSVFile(this)" style="display:none;" />
                <div onclick="document.getElementById('meImportFile').click()" style="cursor:pointer;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#888" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <div style="font-size:12px;color:#555;margin-top:4px;">Click to select a CSV file</div>
                    <div class="me-import__hint">Format: RegNo, CW Mark, Test Mark, Exam Mark</div>
                </div>
            </div>
            <div id="meImportPreview" style="display:none;">
                <div class="me-import__summary" id="meImportSummary"></div>
                <div class="me-import__preview-wrap">
                    <table class="me-import__table" id="meImportTable">
                        <thead><tr><th>#</th><th>Reg No</th><th>Name</th><th>CW</th><th>Test</th><th>Exam</th><th>Status</th></tr></thead>
                        <tbody id="meImportBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="me-modal__foot">
            <button class="me-modal__btn me-modal__btn--cancel" onclick="ME.hideImportModal()">Cancel</button>
            <button class="me-modal__btn me-modal__btn--submit" id="meImportCommitBtn" onclick="ME.commitImport()" disabled>Import Marks</button>
        </div>
    </div>
</div>

<!-- Unlock Request Modal (F-03) -->
<div class="me-modal-overlay" id="meUnlockOverlay">
    <div class="me-modal me-unlock-modal">
        <div class="me-modal__head">
            <span>Request Deadline Unlock</span>
            <button class="me-modal__close" onclick="ME.hideUnlockModal()">&times;</button>
        </div>
        <div class="me-modal__body">
            <div class="me-unlock__field">
                <label class="me-unlock__label">Deadline Type</label>
                <select class="me-unlock__select" id="meUnlockType"></select>
            </div>
            <div class="me-unlock__field">
                <label class="me-unlock__label">Reason for Unlock Request</label>
                <textarea class="me-unlock__textarea" id="meUnlockReason" placeholder="Explain why you need the deadline extended (minimum 10 characters)..."></textarea>
                <div class="me-unlock__hint">Your request will be reviewed by the Dean or Registrar.</div>
            </div>
        </div>
        <div class="me-modal__foot">
            <button class="me-modal__btn me-modal__btn--cancel" onclick="ME.hideUnlockModal()">Cancel</button>
            <button class="me-modal__btn me-modal__btn--submit" id="meUnlockSubmitBtn" onclick="ME.submitUnlockRequest()">Submit Request</button>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="me-toast" id="meToast"></div>

<script>
var ME = (function () {
    'use strict';

    // ── State ──────────────────────────────────────────────────────
    var state = {
        courseId: '', progId: '', acadyear: '', semester: 0,
        studyYear: 0, campusId: 0, studSession: '',
        cwRatio: 0, testRatio: 0, examRatio: 0,
        rows: [],           // original row data from server
        dirtyRows: {},      // rowId -> { cwEntered, testEntered, examEntered }
        gradingScale: [],   // [ { grade, minMark, maxMark } ]
        lockState: null,
        isEditable: false,
        isHistorical: false,    // E-11: archived year read-only
        isCwLocked: false,
        isExamLocked: false,
        lastSaved: null,
        autosaveTimer: null,
        AUTOSAVE_INTERVAL: 120000  // 2 minutes
    };

    // ── Init ───────────────────────────────────────────────────────
    function init() {
        // Parse query string for context
        var qs = parseQS();
        state.courseId = qs.course || '';
        state.progId = qs.prog || '';
        state.acadyear = qs.year || '';
        state.semester = parseInt(qs.sem || '0', 10);
        state.studyYear = parseInt(qs.sy || '1', 10);
        state.campusId = parseInt(qs.campus || '1', 10);
        state.studSession = qs.session || 'Day';

        if (!state.courseId || !state.progId || !state.acadyear) {
            showError('Missing required parameters. Please access this page from the Teacher Dashboard.');
            return;
        }

        loadSheet();
        setupKeyboard();
    }

    // ── Load Sheet Data ────────────────────────────────────────────
    function loadSheet() {
        ajax('load', {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId,
            session: state.studSession
        }, function (data) {
            if (data.error) { showError(data.error); return; }

            // Store ratios and context
            state.cwRatio = data.cwRatio || 0;
            state.testRatio = data.testRatio || 0;
            state.examRatio = data.examRatio || 0;
            state.rows = data.rows || [];
            state.gradingScale = data.gradingScale || [];
            state.lockState = data.lockState || {};

            // Determine editability
            state.isHistorical = data.isHistorical || false;
            state.isEditable = !state.lockState.isFullyLocked && !state.isHistorical;
            state.isCwLocked = state.lockState.isCwLocked || false;
            state.isExamLocked = state.lockState.isExamLocked || false;

            renderContext(data);
            renderArchiveBanner();
            renderLocks(data.lockState);
            renderRejection(data.rejectReason);
            renderTable();
            updateSummary();

            // Show UI
            el('meLoading').style.display = 'none';
            el('meCtx').style.display = '';
            el('meToolbar').style.display = state.isHistorical ? 'none' : '';
            el('meKbHelp').style.display = state.isHistorical ? 'none' : '';
            el('meTableWrap').style.display = '';
            el('meSummary').style.display = '';

            // Enable buttons based on state
            updateButtons();

            // Start autosave timer (E-04) — not for archived years
            if (!state.isHistorical) { startAutosave(); }
        });
    }

    // ── Render Context Bar ─────────────────────────────────────────
    function renderContext(d) {
        el('meCourseName').textContent = d.courseCode + ' — ' + d.courseName;
        el('meCourseContext').textContent = d.progName + ' | Year ' + state.studyYear
            + ' | Sem ' + state.semester + ' | ' + state.acadyear + ' | ' + state.studSession;

        var statusEl = el('meStatus');
        statusEl.textContent = d.statusLabel || 'Draft';
        statusEl.className = 'me-ctx__status me-ctx__status--' + (d.statusClass || 'draft');

        el('meCwRatio').textContent = state.cwRatio;
        el('meTestRatio').textContent = state.testRatio;
        el('meExamRatio').textContent = state.examRatio;
        el('meExpected').textContent = d.expectedStudents >= 0 ? d.expectedStudents : '—';
        el('meEntered').textContent = d.marksEntered || '0';
        el('meMissing').textContent = d.missingMarks >= 0 ? d.missingMarks : '—';

        // Show/hide test columns
        var showTest = state.testRatio > 0;
        el('meThTest').style.display = showTest ? '' : 'none';
        el('meThTestWt').style.display = showTest ? '' : 'none';

        // Column max hints
        el('meThCwMax').textContent = state.cwRatio > 0 ? '(max 100)' : '';
        el('meThTestMax').textContent = state.testRatio > 0 ? '(max 100)' : '';
        el('meThExamMax').textContent = state.examRatio > 0 ? '(max 100)' : '';
    }

    // ── Render Archive Banner (E-11) ─────────────────────────────
    function renderArchiveBanner() {
        var banner = el('meArchiveBanner');
        if (state.isHistorical) {
            banner.style.display = '';
        } else {
            banner.style.display = 'none';
        }
    }

    // ── Render Lock Banners ────────────────────────────────────────
    function renderLocks(ls) {
        var c = el('meLocks');
        c.innerHTML = '';
        if (!ls || !ls.locks || ls.locks.length === 0) return;
        if (state.isHistorical) return; // E-11: skip lock banners for archived years

        for (var i = 0; i < ls.locks.length; i++) {
            var lk = ls.locks[i];
            var div = document.createElement('div');
            div.className = 'me-lock me-lock--' + (lk.isSoft ? 'soft' : 'hard');
            div.innerHTML = '<span class="me-lock__icon">' + (lk.isSoft ? '&#9888;' : '&#128274;') + '</span> ' + esc(lk.message);
            c.appendChild(div);
        }

        // F-03: Add unlock request button if eligible
        if (ls.canRequestUnlock && !state.isHistorical) {
            var unlockDiv = document.createElement('div');
            unlockDiv.className = 'me-lock me-lock--soft';
            unlockDiv.innerHTML = '<span class="me-lock__icon">&#128275;</span> Deadline has passed but you may request a temporary unlock.'
                + ' <button class="me-lock__unlock-btn" onclick="ME.showUnlockModal()">Request Unlock</button>';
            c.appendChild(unlockDiv);
        }
    }

    // ── Render Rejection Banner ────────────────────────────────────
    function renderRejection(reason) {
        var el_ = el('meRejection');
        if (!reason) { el_.style.display = 'none'; return; }
        el_.style.display = '';
        el_.innerHTML = '<strong>Rejected by Dean:</strong> ' + esc(reason) + ' — Please correct and re-submit.';
    }

    // ── Render Mark Table ──────────────────────────────────────────
    function renderTable() {
        var body = el('meBody');
        body.innerHTML = '';
        var showTest = state.testRatio > 0;

        for (var i = 0; i < state.rows.length; i++) {
            var r = state.rows[i];
            var tr = document.createElement('tr');
            tr.setAttribute('data-id', r.id);
            tr.setAttribute('data-idx', i);

            var hasMark = r.cwEntered > 0 || r.testEntered > 0 || r.examEntered > 0;
            if (!hasMark) tr.className = 'me-row--missing';
            if (r.isApproved) tr.className = (tr.className || '') + ' me-row--approved';

            // Compute weighted marks and grade
            var comp = computeRow(r.cwEntered, r.testEntered, r.examEntered);

            // #
            var td0 = document.createElement('td');
            td0.textContent = (i + 1);
            tr.appendChild(td0);

            // Student
            var td1 = document.createElement('td');
            td1.innerHTML = '<div class="me-student"><span class="me-student__name">' + esc(r.studentName) + '</span><span class="me-student__regno">' + esc(r.regno) + '</span></div>';
            tr.appendChild(td1);

            // CW Entered
            tr.appendChild(createInputCell(r.id, 'cw', r.cwEntered, !state.isEditable || state.isCwLocked || r.isApproved, i));

            // CW Weighted
            var tdCwWt = document.createElement('td');
            tdCwWt.className = 'me-weighted';
            tdCwWt.id = 'wt_cw_' + r.id;
            tdCwWt.textContent = comp.cwWt;
            tr.appendChild(tdCwWt);

            // Test Entered (conditionally visible)
            if (showTest) {
                tr.appendChild(createInputCell(r.id, 'test', r.testEntered, !state.isEditable || state.isExamLocked || r.isApproved, i));
                var tdTestWt = document.createElement('td');
                tdTestWt.className = 'me-weighted';
                tdTestWt.id = 'wt_test_' + r.id;
                tdTestWt.textContent = comp.testWt;
                tr.appendChild(tdTestWt);
            }

            // Exam Entered
            tr.appendChild(createInputCell(r.id, 'exam', r.examEntered, !state.isEditable || state.isExamLocked || r.isApproved, i));

            // Exam Weighted
            var tdExamWt = document.createElement('td');
            tdExamWt.className = 'me-weighted';
            tdExamWt.id = 'wt_exam_' + r.id;
            tdExamWt.textContent = comp.examWt;
            tr.appendChild(tdExamWt);

            // Total
            var tdTotal = document.createElement('td');
            tdTotal.id = 'total_' + r.id;
            tdTotal.className = 'me-total';
            if (comp.total >= 0) {
                tdTotal.textContent = comp.total;
                tdTotal.className += comp.total >= 50 ? ' me-total--pass' : ' me-total--fail';
            } else {
                tdTotal.textContent = '—';
                tdTotal.className += ' me-total--none';
            }
            tr.appendChild(tdTotal);

            // Grade
            var tdGrade = document.createElement('td');
            var grd = comp.total >= 0 ? lookupGrade(comp.total) : '—';
            tdGrade.innerHTML = '<span class="me-grade me-grade--' + grd.replace('+', '-plus') + '" id="grade_' + r.id + '">' + grd + '</span>';
            tr.appendChild(tdGrade);

            // Status
            var tdStatus = document.createElement('td');
            if (r.isApproved) {
                tdStatus.innerHTML = '<span class="me-approved">&#10003; ' + esc(r.approvedBy) + '</span>';
            } else if (!hasMark) {
                tdStatus.innerHTML = '<span style="color:#999;font-size:10px;">No marks</span>';
            } else {
                tdStatus.innerHTML = '<span style="color:#888;font-size:10px;">Pending</span>';
            }
            tr.appendChild(tdStatus);

            body.appendChild(tr);
        }
    }

    // ── Create Input Cell ──────────────────────────────────────────
    function createInputCell(rowId, component, value, disabled, rowIdx) {
        var td = document.createElement('td');
        var inp = document.createElement('input');
        inp.type = 'text';
        inp.className = 'me-input';
        inp.value = value > 0 ? value : '';
        inp.disabled = disabled;
        inp.setAttribute('data-rid', rowId);
        inp.setAttribute('data-comp', component);
        inp.setAttribute('data-row', rowIdx);
        inp.setAttribute('autocomplete', 'off');

        inp.addEventListener('input', function () { onMarkInput(this); });
        inp.addEventListener('focus', function () { this.select(); });
        inp.addEventListener('keydown', function (e) { onCellKeydown(e, this); });

        td.appendChild(inp);
        return td;
    }

    // ═════════════════════════════════════════════════════════════════
    // REAL-TIME GRADE CALCULATION (E-03)
    // ═════════════════════════════════════════════════════════════════

    function onMarkInput(inp) {
        var rid = parseInt(inp.getAttribute('data-rid'), 10);
        var comp = inp.getAttribute('data-comp');
        var val = parseInt(inp.value, 10);

        // Validate numeric
        if (inp.value !== '' && (isNaN(val) || val < 0)) {
            inp.className = 'me-input me-input--invalid';
            return;
        }

        // Validate max (100)
        if (val > 100) {
            inp.className = 'me-input me-input--warn';
        } else {
            inp.className = 'me-input';
        }

        if (isNaN(val)) val = 0;

        // Mark row dirty
        if (!state.dirtyRows[rid]) {
            var orig = findRow(rid);
            state.dirtyRows[rid] = {
                cwEntered: orig ? orig.cwEntered : 0,
                testEntered: orig ? orig.testEntered : 0,
                examEntered: orig ? orig.examEntered : 0
            };
        }
        state.dirtyRows[rid][comp + 'Entered'] = val;

        // Get current values for this row
        var d = state.dirtyRows[rid];
        var comp_vals = computeRow(d.cwEntered, d.testEntered, d.examEntered);

        // Update weighted cells
        var cwWtEl = document.getElementById('wt_cw_' + rid);
        if (cwWtEl) cwWtEl.textContent = comp_vals.cwWt;
        var testWtEl = document.getElementById('wt_test_' + rid);
        if (testWtEl) testWtEl.textContent = comp_vals.testWt;
        var examWtEl = document.getElementById('wt_exam_' + rid);
        if (examWtEl) examWtEl.textContent = comp_vals.examWt;

        // Update total
        var totalEl = document.getElementById('total_' + rid);
        if (totalEl) {
            if (comp_vals.total >= 0) {
                totalEl.textContent = comp_vals.total;
                totalEl.className = 'me-total ' + (comp_vals.total >= 50 ? 'me-total--pass' : 'me-total--fail');
            } else {
                totalEl.textContent = '—';
                totalEl.className = 'me-total me-total--none';
            }
        }

        // Update grade
        var gradeEl = document.getElementById('grade_' + rid);
        if (gradeEl) {
            var g = comp_vals.total >= 0 ? lookupGrade(comp_vals.total) : '—';
            gradeEl.textContent = g;
            gradeEl.className = 'me-grade me-grade--' + g.replace('+', '-plus');
        }

        // Mark row dirty in UI
        var tr = inp.closest('tr');
        if (tr && tr.className.indexOf('me-row--dirty') < 0) {
            tr.className = (tr.className || '') + ' me-row--dirty';
        }

        // Show dirty indicator
        el('meDirtyLabel').style.display = '';
        el('meSaveBtn').disabled = false;
        updateSummary();
    }

    // ── Compute Row (real-time) ────────────────────────────────────
    function computeRow(cwEnt, testEnt, examEnt) {
        var cwWt = state.cwRatio > 0 ? Math.round(cwEnt * state.cwRatio / 100) : 0;
        var testWt = state.testRatio > 0 ? Math.round(testEnt * state.testRatio / 100) : 0;
        var examWt = state.examRatio > 0 ? Math.round(examEnt * state.examRatio / 100) : 0;
        var total = cwWt + testWt + examWt;

        var hasMark = cwEnt > 0 || testEnt > 0 || examEnt > 0;
        return {
            cwWt: cwWt,
            testWt: testWt,
            examWt: examWt,
            total: hasMark ? total : -1
        };
    }

    // ── Grade Lookup ───────────────────────────────────────────────
    function lookupGrade(total) {
        for (var i = 0; i < state.gradingScale.length; i++) {
            var g = state.gradingScale[i];
            if (total >= g.minMark && total <= g.maxMark) return g.grade;
        }
        return 'F';
    }

    // ── Update Summary Bar ─────────────────────────────────────────
    function updateSummary() {
        var total = state.rows.length;
        var entered = 0, sum = 0, passCount = 0;
        var high = -1, low = 999;
        var grades = { A: 0, B: 0, C: 0, D: 0, F: 0 };

        for (var i = 0; i < state.rows.length; i++) {
            var r = state.rows[i];
            var d = state.dirtyRows[r.id] || { cwEntered: r.cwEntered, testEntered: r.testEntered, examEntered: r.examEntered };
            var hasMark = d.cwEntered > 0 || d.testEntered > 0 || d.examEntered > 0;
            if (!hasMark) continue;

            entered++;
            var c = computeRow(d.cwEntered, d.testEntered, d.examEntered);
            if (c.total < 0) continue;
            sum += c.total;
            if (c.total >= 50) passCount++;
            if (c.total > high) high = c.total;
            if (c.total < low) low = c.total;

            var g = lookupGrade(c.total);
            if (g.indexOf('A') === 0) grades.A++;
            else if (g.indexOf('B') === 0) grades.B++;
            else if (g.indexOf('C') === 0) grades.C++;
            else if (g.indexOf('D') === 0) grades.D++;
            else grades.F++;
        }

        el('meSumTotal').textContent = total;
        el('meSumEntered').textContent = entered;
        el('meSumAvg').textContent = entered > 0 ? (sum / entered).toFixed(1) : '—';
        el('meSumPass').textContent = entered > 0 ? Math.round(passCount / entered * 100) + '%' : '—';
        el('meSumHigh').textContent = high >= 0 ? high : '—';
        el('meSumLow').textContent = low < 999 ? low : '—';
        el('meSumA').textContent = grades.A;
        el('meSumB').textContent = grades.B;
        el('meSumC').textContent = grades.C;
        el('meSumD').textContent = grades.D;
        el('meSumF').textContent = grades.F;

        // Update info bar
        el('meEntered').textContent = entered;
        el('meMissing').textContent = total - entered;
    }

    // ═════════════════════════════════════════════════════════════════
    // KEYBOARD NAVIGATION
    // ═════════════════════════════════════════════════════════════════

    function setupKeyboard() {
        document.addEventListener('keydown', function (e) {
            if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                e.preventDefault();
                if (!el('meSaveBtn').disabled) saveMarks();
            }
        });
    }

    function onCellKeydown(e, inp) {
        var rid = parseInt(inp.getAttribute('data-rid'), 10);
        var comp = inp.getAttribute('data-comp');
        var rowIdx = parseInt(inp.getAttribute('data-row'), 10);

        if (e.key === 'Enter' || e.key === 'ArrowDown') {
            e.preventDefault();
            focusCell(rowIdx + 1, comp);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            focusCell(rowIdx - 1, comp);
        } else if (e.key === 'Escape') {
            inp.blur();
        }
    }

    function focusCell(rowIdx, comp) {
        if (rowIdx < 0 || rowIdx >= state.rows.length) return;
        var selector = 'input[data-row="' + rowIdx + '"][data-comp="' + comp + '"]';
        var next = document.querySelector(selector);
        if (next && !next.disabled) {
            next.focus();
            next.select();
        }
    }

    // ═════════════════════════════════════════════════════════════════
    // AUTOSAVE (E-04)
    // ═════════════════════════════════════════════════════════════════

    function startAutosave() {
        stopAutosave();
        if (!state.isEditable) return;
        state.autosaveTimer = setInterval(function () {
            if (Object.keys(state.dirtyRows).length > 0) {
                saveMarks(true);
            }
        }, state.AUTOSAVE_INTERVAL);
    }

    function stopAutosave() {
        if (state.autosaveTimer) {
            clearInterval(state.autosaveTimer);
            state.autosaveTimer = null;
        }
    }

    // ═════════════════════════════════════════════════════════════════
    // SAVE MARKS
    // ═════════════════════════════════════════════════════════════════

    function saveMarks(isAutosave) {
        var keys = Object.keys(state.dirtyRows);
        if (keys.length === 0) {
            if (!isAutosave) toast('No changes to save.', 'warn');
            return;
        }

        var inputs = [];
        for (var i = 0; i < keys.length; i++) {
            var rid = parseInt(keys[i], 10);
            var d = state.dirtyRows[rid];
            var orig = findRow(rid);

            // Validate
            if (d.cwEntered > 100 || d.testEntered > 100 || d.examEntered > 100) {
                toast('Row ' + (orig ? orig.studentName : rid) + ': marks cannot exceed 100.', 'err');
                return;
            }
            if (d.cwEntered < 0 || d.testEntered < 0 || d.examEntered < 0) {
                toast('Marks cannot be negative.', 'err');
                return;
            }

            inputs.push({
                rowId: rid,
                regno: orig ? orig.regno : '',
                cwEntered: d.cwEntered,
                testEntered: d.testEntered,
                examEntered: d.examEntered
            });
        }

        el('meSaveBtn').disabled = true;

        ajax('save', {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId,
            session: state.studSession, inputs: JSON.stringify(inputs)
        }, function (data) {
            if (data.error) {
                toast(data.error, 'err');
                el('meSaveBtn').disabled = false;
                return;
            }

            // Update local row data with saved values
            for (var k in state.dirtyRows) {
                if (!state.dirtyRows.hasOwnProperty(k)) continue;
                var rid = parseInt(k, 10);
                var d = state.dirtyRows[rid];
                var orig = findRow(rid);
                if (orig) {
                    orig.cwEntered = d.cwEntered;
                    orig.testEntered = d.testEntered;
                    orig.examEntered = d.examEntered;
                    // Recompute weighted
                    var c = computeRow(d.cwEntered, d.testEntered, d.examEntered);
                    orig.cwMark = c.cwWt;
                    orig.testMark = c.testWt;
                    orig.examMark = c.examWt;
                    orig.totalMark = c.total >= 0 ? c.total : 0;
                }
            }
            state.dirtyRows = {};
            state.lastSaved = new Date();

            // Clear dirty indicators
            var dirtyRows = document.querySelectorAll('.me-row--dirty');
            for (var j = 0; j < dirtyRows.length; j++) {
                dirtyRows[j].className = dirtyRows[j].className.replace('me-row--dirty', '').trim();
            }
            el('meDirtyLabel').style.display = 'none';
            el('meSaveBtn').disabled = true;

            var msg = (isAutosave ? 'Auto-saved ' : 'Saved ') + (data.savedCount || 0) + ' row(s).';
            if (data.errors && data.errors.length > 0) {
                msg += ' ' + data.errors.length + ' error(s).';
                toast(msg, 'warn');
            } else {
                toast(msg, 'ok');
            }

            el('meSavedLabel').textContent = '\u2713 ' + (isAutosave ? 'Auto-saved' : 'Saved') + ' at ' + formatTime(state.lastSaved);
            el('meSavedLabel').className = 'me-toolbar__saved me-toolbar__saved--ok';

            // Reset autosave timer after successful save
            if (isAutosave) startAutosave();
        });
    }

    // ═════════════════════════════════════════════════════════════════
    // CSV IMPORT (E-05)
    // ═════════════════════════════════════════════════════════════════

    var importData = [];

    function showImportModal() {
        if (!state.isEditable) { toast('Mark entry is currently locked.', 'warn'); return; }
        importData = [];
        el('meImportPreview').style.display = 'none';
        el('meImportSummary').textContent = '';
        el('meImportBody').innerHTML = '';
        el('meImportCommitBtn').disabled = true;
        el('meImportFile').value = '';
        el('meImportOverlay').className = 'me-modal-overlay active';
    }

    function hideImportModal() {
        el('meImportOverlay').className = 'me-modal-overlay';
        importData = [];
    }

    function downloadTemplate() {
        var header = 'RegNo,CW Mark,Test Mark,Exam Mark';
        var lines = [header];
        for (var i = 0; i < state.rows.length; i++) {
            lines.push(state.rows[i].regno + ',,,');
        }
        var csv = lines.join('\n');
        var blob = new Blob([csv], { type: 'text/csv' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = state.courseId + '_marks_template.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }

    function handleCSVFile(inp) {
        if (!inp.files || !inp.files[0]) return;
        var file = inp.files[0];
        if (file.name.indexOf('.csv') < 0) { toast('Please select a .csv file.', 'err'); return; }
        var reader = new FileReader();
        reader.onload = function (ev) { parseCSVAndPreview(ev.target.result); };
        reader.readAsText(file);
    }

    function parseCSVAndPreview(csvText) {
        var lines = csvText.split(/\r?\n/).filter(function (l) { return l.trim() !== ''; });
        if (lines.length < 2) { toast('CSV file appears empty or has no data rows.', 'err'); return; }

        var rows = [];
        var errors = 0, warnings = 0, matched = 0;

        for (var i = 1; i < lines.length; i++) {
            var cols = lines[i].split(',');
            if (cols.length < 2) continue;

            var regno = (cols[0] || '').trim();
            var cw = parseFloat((cols[1] || '').trim());
            var test = parseFloat((cols[2] || '').trim());
            var exam = parseFloat((cols[3] || '').trim());
            if (isNaN(cw)) cw = -1;
            if (isNaN(test)) test = -1;
            if (isNaN(exam)) exam = -1;

            // Find student in current sheet
            var found = null;
            for (var j = 0; j < state.rows.length; j++) {
                if (state.rows[j].regno === regno) { found = state.rows[j]; break; }
            }

            var status = 'ok', statusMsg = 'OK';
            if (!found) { status = 'error'; statusMsg = 'Not in sheet'; errors++; }
            else if (cw > 100 || test > 100 || exam > 100) { status = 'error'; statusMsg = 'Mark > 100'; errors++; }
            else if (cw < 0 && test < 0 && exam < 0) { status = 'warn'; statusMsg = 'No marks'; warnings++; }
            else { matched++; }

            rows.push({
                regno: regno, name: found ? found.studentName : '(unknown)',
                rowId: found ? found.id : -1,
                cw: cw >= 0 ? cw : '', test: test >= 0 ? test : '', exam: exam >= 0 ? exam : '',
                status: status, statusMsg: statusMsg
            });
        }

        importData = rows;
        renderImportPreview(rows, matched, errors, warnings);
    }

    function renderImportPreview(rows, matched, errors, warnings) {
        el('meImportSummary').innerHTML =
            '<strong>' + rows.length + '</strong> rows &mdash; '
            + '<span style="color:#2e7d32;">' + matched + ' matched</span>, '
            + '<span style="color:#e65100;">' + warnings + ' warnings</span>, '
            + '<span style="color:#c62828;">' + errors + ' errors</span>';

        var body = el('meImportBody');
        body.innerHTML = '';
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var tr = document.createElement('tr');
            if (r.status === 'error') tr.className = 'me-row--error';
            else if (r.status === 'warn') tr.style.background = '#fff3e0';

            var cells = [(i + 1), r.regno, r.name,
                r.cw !== '' ? r.cw : '\u2014', r.test !== '' ? r.test : '\u2014',
                r.exam !== '' ? r.exam : '\u2014'];
            for (var c = 0; c < cells.length; c++) {
                var td = document.createElement('td');
                td.textContent = cells[c];
                tr.appendChild(td);
            }

            var tdSt = document.createElement('td');
            tdSt.innerHTML = '<span class="me-import__badge me-import__badge--' + r.status + '">' + esc(r.statusMsg) + '</span>';
            tr.appendChild(tdSt);
            body.appendChild(tr);
        }

        el('meImportPreview').style.display = '';
        el('meImportCommitBtn').disabled = matched === 0;
    }

    function commitImport() {
        var inputs = [];
        for (var i = 0; i < importData.length; i++) {
            var r = importData[i];
            if (r.status === 'error' || r.rowId < 0) continue;
            if (r.cw === '' && r.test === '' && r.exam === '') continue;
            inputs.push({
                rowId: r.rowId, regno: r.regno,
                cwEntered: r.cw !== '' ? parseFloat(r.cw) : 0,
                testEntered: r.test !== '' ? parseFloat(r.test) : 0,
                examEntered: r.exam !== '' ? parseFloat(r.exam) : 0
            });
        }
        if (inputs.length === 0) { toast('No valid rows to import.', 'warn'); return; }

        el('meImportCommitBtn').disabled = true;

        ajax('import', {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId,
            session: state.studSession, inputs: JSON.stringify(inputs)
        }, function (data) {
            if (data.error) { toast(data.error, 'err'); el('meImportCommitBtn').disabled = false; return; }
            hideImportModal();
            toast('Imported ' + (data.savedCount || 0) + ' row(s) successfully.', 'ok');
            // Reload to reflect imported data
            setTimeout(function () { loadSheet(); }, 800);
        });
    }

    // ═════════════════════════════════════════════════════════════════
    // SUBMIT FOR REVIEW
    // ═════════════════════════════════════════════════════════════════

    function showSubmitModal() {
        // Ensure no unsaved changes
        if (Object.keys(state.dirtyRows).length > 0) {
            toast('Please save your changes before submitting.', 'warn');
            return;
        }

        ajax('submit_preview', {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId,
            session: state.studSession
        }, function (data) {
            if (data.error) { toast(data.error, 'err'); return; }

            var body = el('meSubmitBody');
            var html = '';
            html += '<div class="me-modal__row"><span class="me-modal__rlabel">Course</span><span class="me-modal__rval">' + esc(state.courseId) + '</span></div>';
            html += '<div class="me-modal__row"><span class="me-modal__rlabel">Total Students</span><span class="me-modal__rval">' + data.totalStudents + '</span></div>';
            html += '<div class="me-modal__row"><span class="me-modal__rlabel">Marks Entered</span><span class="me-modal__rval">' + data.marksEntered + '</span></div>';
            html += '<div class="me-modal__row"><span class="me-modal__rlabel">Missing</span><span class="me-modal__rval">' + data.missingMarks + '</span></div>';
            html += '<div class="me-modal__row"><span class="me-modal__rlabel">Average Mark</span><span class="me-modal__rval">' + data.averageMark + '</span></div>';
            html += '<div class="me-modal__row"><span class="me-modal__rlabel">Pass Rate</span><span class="me-modal__rval">' + data.passRate + '%</span></div>';

            // E-06: Grade Distribution Bars (computed from client-side data)
            var dist = computeGradeDistribution();
            var maxCount = Math.max(dist.A, dist.B, dist.C, dist.D, dist.F, 1);
            html += '<div class="me-dist"><div class="me-dist__title">Grade Distribution</div>';
            var grades = ['A', 'B', 'C', 'D', 'F'];
            for (var g = 0; g < grades.length; g++) {
                var grade = grades[g];
                var cnt = dist[grade] || 0;
                var pct = Math.round((cnt / maxCount) * 100);
                html += '<div class="me-dist__bar-row">'
                    + '<span class="me-dist__bar-label">' + grade + '</span>'
                    + '<div class="me-dist__bar-track"><div class="me-dist__bar-fill me-dist__bar-fill--' + grade + '" style="width:' + pct + '%"></div></div>'
                    + '<span class="me-dist__bar-count">' + cnt + '</span></div>';
            }
            html += '</div>';

            // E-06: Missing Students List
            var missing = getMissingStudents();
            if (missing.length > 0) {
                html += '<div class="me-missing__title">&#9888; ' + missing.length + ' Students With No Marks</div>';
                html += '<div class="me-missing">';
                for (var m = 0; m < missing.length; m++) {
                    html += '<div class="me-missing__item"><span class="me-missing__name">' + esc(missing[m].name) + '</span><span class="me-missing__regno">' + esc(missing[m].regno) + '</span></div>';
                }
                html += '</div>';
            }

            if (data.warnings && data.warnings.length > 0) {
                for (var i = 0; i < data.warnings.length; i++) {
                    html += '<div class="me-modal__warn">' + esc(data.warnings[i]) + '</div>';
                }
            }

            html += '<div class="me-modal__confirm"><input type="checkbox" id="meConfirmCheck" onchange="ME.toggleConfirmBtn()"><label for="meConfirmCheck">I confirm all marks are correct and ready for Dean review.</label></div>';

            body.innerHTML = html;
            el('meConfirmSubmitBtn').disabled = true;
            el('meSubmitOverlay').className = 'me-modal-overlay active';
        });
    }

    function hideSubmitModal() {
        el('meSubmitOverlay').className = 'me-modal-overlay';
    }

    function toggleConfirmBtn() {
        var chk = document.getElementById('meConfirmCheck');
        el('meConfirmSubmitBtn').disabled = !chk || !chk.checked;
    }

    function confirmSubmit() {
        el('meConfirmSubmitBtn').disabled = true;

        ajax('submit', {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId,
            session: state.studSession, force: 'true'
        }, function (data) {
            hideSubmitModal();
            if (data.error) { toast(data.error, 'err'); return; }

            if (data.success) {
                toast('Marks submitted for Dean review!', 'ok');
                // Reload to reflect new status
                setTimeout(function () { loadSheet(); }, 1200);
            } else if (data.requiresConfirmation) {
                toast('Additional confirmation needed.', 'warn');
            }
        });
    }

    // ═════════════════════════════════════════════════════════════════
    // E-06: SUBMISSION SUMMARY HELPERS
    // ═════════════════════════════════════════════════════════════════

    function computeGradeDistribution() {
        var dist = { A: 0, B: 0, C: 0, D: 0, F: 0 };
        for (var i = 0; i < state.rows.length; i++) {
            var r = state.rows[i];
            if (r.cwEntered === 0 && r.testEntered === 0 && r.examEntered === 0) continue;
            var g = (r.grade || '').toUpperCase();
            if (g.indexOf('A') === 0) dist.A++;
            else if (g.indexOf('B') === 0) dist.B++;
            else if (g.indexOf('C') === 0) dist.C++;
            else if (g.indexOf('D') === 0) dist.D++;
            else if (g === 'F' || g === 'FAIL') dist.F++;
        }
        return dist;
    }

    function getMissingStudents() {
        var missing = [];
        for (var i = 0; i < state.rows.length; i++) {
            var r = state.rows[i];
            if (r.cwEntered === 0 && r.testEntered === 0 && r.examEntered === 0) {
                missing.push({ name: r.studentName, regno: r.regno });
            }
        }
        return missing;
    }

    // ═════════════════════════════════════════════════════════════════
    // F-03: UNLOCK REQUEST
    // ═════════════════════════════════════════════════════════════════

    function showUnlockModal() {
        var sel = el('meUnlockType');
        sel.innerHTML = '';
        // Offer only the deadline types that are actually locked
        if (state.isCwLocked) {
            sel.innerHTML += '<option value="COURSEWORK">Coursework Deadline</option>';
        }
        if (state.isExamLocked) {
            sel.innerHTML += '<option value="EXAM">Exam Deadline</option>';
        }
        if (state.lockState && state.lockState.isSubmitLocked) {
            sel.innerHTML += '<option value="SUBMISSION">Submission Deadline</option>';
        }
        // Fallback if none matched but canRequestUnlock is true
        if (sel.options.length === 0) {
            sel.innerHTML = '<option value="COURSEWORK">Coursework Deadline</option>'
                + '<option value="EXAM">Exam Deadline</option>'
                + '<option value="SUBMISSION">Submission Deadline</option>';
        }
        el('meUnlockReason').value = '';
        el('meUnlockSubmitBtn').disabled = false;
        el('meUnlockOverlay').className = 'me-modal-overlay active';
    }

    function hideUnlockModal() {
        el('meUnlockOverlay').className = 'me-modal-overlay';
    }

    function submitUnlockRequest() {
        var dtype = el('meUnlockType').value;
        var reason = el('meUnlockReason').value.trim();
        if (reason.length < 10) {
            toast('Please provide a detailed reason (at least 10 characters).', 'warn');
            return;
        }
        el('meUnlockSubmitBtn').disabled = true;

        ajax('request_unlock', {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, deadline_type: dtype, reason: reason
        }, function (data) {
            if (data.error) {
                toast(data.error, 'err');
                el('meUnlockSubmitBtn').disabled = false;
                return;
            }
            hideUnlockModal();
            toast('Unlock request submitted! You will be notified when it is reviewed.', 'ok');
        });
    }

    // ═════════════════════════════════════════════════════════════════
    // FILTER / SEARCH
    // ═════════════════════════════════════════════════════════════════

    function filterRows(query) {
        query = (query || '').toLowerCase();
        var rows = el('meBody').getElementsByTagName('tr');
        for (var i = 0; i < rows.length; i++) {
            var text = rows[i].textContent.toLowerCase();
            rows[i].style.display = query === '' || text.indexOf(query) >= 0 ? '' : 'none';
        }
    }

    // ═════════════════════════════════════════════════════════════════
    // NAVIGATION
    // ═════════════════════════════════════════════════════════════════

    function goBack() {
        stopAutosave();
        if (Object.keys(state.dirtyRows).length > 0) {
            if (!confirm('You have unsaved changes. Leave without saving?')) return;
        }
        window.location.href = 'TeacherDashboard.aspx';
    }

    // ═════════════════════════════════════════════════════════════════
    // BUTTON STATE
    // ═════════════════════════════════════════════════════════════════

    function updateButtons() {
        el('meSaveBtn').disabled = Object.keys(state.dirtyRows).length === 0;

        var canSubmit = state.isEditable && !state.lockState.isSubmitLocked
            && state.lockState.currentStatus === 'DRAFT';
        el('meSubmitBtn').disabled = !canSubmit;
    }

    // ═════════════════════════════════════════════════════════════════
    // HELPERS
    // ═════════════════════════════════════════════════════════════════

    function findRow(id) {
        for (var i = 0; i < state.rows.length; i++) {
            if (state.rows[i].id === id) return state.rows[i];
        }
        return null;
    }

    function el(id) { return document.getElementById(id); }

    function esc(s) {
        if (!s) return '';
        var d = document.createElement('div');
        d.textContent = s;
        return d.innerHTML;
    }

    function parseQS() {
        var q = {}, p = window.location.search.substring(1).split('&');
        for (var i = 0; i < p.length; i++) {
            var kv = p[i].split('=');
            if (kv.length === 2) q[decodeURIComponent(kv[0])] = decodeURIComponent(kv[1]);
        }
        return q;
    }

    function formatTime(d) {
        var h = d.getHours(), m = d.getMinutes();
        return (h < 10 ? '0' : '') + h + ':' + (m < 10 ? '0' : '') + m;
    }

    function toast(msg, type) {
        var t = el('meToast');
        t.textContent = msg;
        t.className = 'me-toast me-toast--' + (type || 'ok') + ' show';
        setTimeout(function () { t.className = 'me-toast'; }, 3500);
    }

    function showError(msg) {
        el('meLoading').innerHTML = '<div style="color:#c62828;">' + esc(msg) + '</div>';
    }

    function ajax(action, params, cb) {
        var url = '?ajax=' + action;
        var csrfMeta = document.querySelector('meta[name="csrf-token"]');
        if (csrfMeta) { params = params || {}; params['__csrf'] = csrfMeta.getAttribute('content'); }
        var body = [];
        for (var k in params) {
            if (params.hasOwnProperty(k)) {
                body.push(encodeURIComponent(k) + '=' + encodeURIComponent(params[k]));
            }
        }

        var xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            try {
                var data = JSON.parse(xhr.responseText);
                cb(data);
            } catch (ex) {
                cb({ error: 'Invalid server response.' });
            }
        };
        xhr.send(body.join('&'));
    }

    // ── Boot ───────────────────────────────────────────────────────
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // ── Sheet Sync (H-04) ─────────────────────────────────────────
    function syncSheet() {
        if (!state.courseId) { alert('Please load a mark sheet first.'); return; }
        if (!confirm('Sync sheet?\n\nThis will add any missing registered students to the marksheet with zero marks.\nExisting rows will NOT be affected.')) return;

        var btn = el('meSyncBtn');
        btn.disabled = true;
        btn.innerHTML = '&#8635; Syncing\u2026';

        var params = {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId, session: state.studSession
        };
        ajax('sync', params, function (d) {
            btn.disabled = false;
            btn.innerHTML = '&#8635; Sync Sheet';
            if (d.error) { alert('Sync failed: ' + d.error); return; }
            var msg = 'Sync complete.\n\n' +
                'Added: ' + d.added + ' student(s)\n' +
                'Already existed: ' + d.existing + '\n' +
                'Total in sheet: ' + d.total;
            alert(msg);
            if (d.added > 0) {
                // Reload the sheet to show new rows
                loadSheet();
            }
        });
    }

    // ── Reconciliation (B-06) ──────────────────────────────────────
    function showReconcile() {
        var panel = el('meReconcilePanel');
        var body = el('meReconcileBody');
        body.innerHTML = '<div style="padding:20px;text-align:center;color:#888;">Loading reconciliation&hellip;</div>';
        panel.style.display = 'block';

        var params = {
            course: state.courseId, prog: state.progId, year: state.acadyear,
            sem: state.semester, sy: state.studyYear, campus: state.campusId, session: state.studSession
        };
        ajax('reconcile', params, function (d) {
            if (d.error) { body.innerHTML = '<div style="padding:14px;color:#c62828;">' + esc(d.error) + '</div>'; return; }
            _renderReconcile(d, body);
        });
    }

    function hideReconcile() {
        el('meReconcilePanel').style.display = 'none';
    }

    function _renderReconcile(d, container) {
        var html = '';
        // Stats row
        html += '<div class="me-reconcile__stats">';
        html += '<div class="me-reconcile__stat"><div class="me-reconcile__stat-val">' + (d.registered || 0) + '</div><div class="me-reconcile__stat-label">Registered</div></div>';
        html += '<div class="me-reconcile__stat"><div class="me-reconcile__stat-val">' + (d.in_sheet || 0) + '</div><div class="me-reconcile__stat-label">In Sheet</div></div>';
        html += '<div class="me-reconcile__stat"><div class="me-reconcile__stat-val me-reconcile__stat-val--ok">' + (d.matched || []).length + '</div><div class="me-reconcile__stat-label">Matched</div></div>';
        html += '<div class="me-reconcile__stat"><div class="me-reconcile__stat-val me-reconcile__stat-val--bad">' + (d.missing || []).length + '</div><div class="me-reconcile__stat-label">Missing</div></div>';
        html += '<div class="me-reconcile__stat"><div class="me-reconcile__stat-val me-reconcile__stat-val--warn">' + (d.extra || []).length + '</div><div class="me-reconcile__stat-label">Extra</div></div>';
        html += '</div>';

        if ((d.missing || []).length === 0 && (d.extra || []).length === 0) {
            html += '<div class="me-reconcile__ok">&#10004; All registered students are present in the marksheet. No discrepancies found.</div>';
        }

        if ((d.missing || []).length > 0) {
            html += '<div class="me-reconcile__section">';
            html += '<div class="me-reconcile__section-title me-reconcile__section-title--missing">&#9888; Missing from Marksheet (' + d.missing.length + ' students registered but not in sheet)</div>';
            html += '<div class="me-reconcile__list">';
            for (var i = 0; i < d.missing.length; i++) {
                html += '<div class="me-reconcile__row"><span class="me-reconcile__row-name">' + esc(d.missing[i].name) + '</span><span class="me-reconcile__row-regno">' + esc(d.missing[i].regno) + '</span></div>';
            }
            html += '</div></div>';
        }

        if ((d.extra || []).length > 0) {
            html += '<div class="me-reconcile__section">';
            html += '<div class="me-reconcile__section-title me-reconcile__section-title--extra">&#9888; Extra in Marksheet (' + d.extra.length + ' students in sheet but not registered)</div>';
            html += '<div class="me-reconcile__list">';
            for (var j = 0; j < d.extra.length; j++) {
                html += '<div class="me-reconcile__row"><span class="me-reconcile__row-name">' + esc(d.extra[j].name) + '</span><span class="me-reconcile__row-regno">' + esc(d.extra[j].regno) + '</span></div>';
            }
            html += '</div></div>';
        }

        container.innerHTML = html;
    }

    // ── Print Sheet (Batch 12) ────────────────────────────────────
    function printSheet() {
        if (!state.courseId) { alert('Please load a mark sheet first.'); return; }
        window.print();
    }

    // ── Export CSV (Batch 11) ─────────────────────────────────────
    function exportCsv() {
        if (!state.courseId) { alert('Please load a mark sheet first.'); return; }
        var url = '?ajax=export_csv' +
            '&course='   + encodeURIComponent(state.courseId) +
            '&prog='     + encodeURIComponent(state.progId) +
            '&year='     + encodeURIComponent(state.acadyear) +
            '&sem='      + encodeURIComponent(state.semester) +
            '&sy='       + encodeURIComponent(state.studyYear) +
            '&campus='   + encodeURIComponent(state.campusId) +
            '&session='  + encodeURIComponent(state.studSession);
        window.open(url, '_blank');
    }

    // ── Public API ─────────────────────────────────────────────────
    return {
        saveMarks: saveMarks,
        showSubmitModal: showSubmitModal,
        hideSubmitModal: hideSubmitModal,
        confirmSubmit: confirmSubmit,
        toggleConfirmBtn: toggleConfirmBtn,
        filterRows: filterRows,
        goBack: goBack,
        showImportModal: showImportModal,
        hideImportModal: hideImportModal,
        handleCSVFile: handleCSVFile,
        downloadTemplate: downloadTemplate,
        commitImport: commitImport,
        showUnlockModal: showUnlockModal,
        hideUnlockModal: hideUnlockModal,
        submitUnlockRequest: submitUnlockRequest,
        showReconcile: showReconcile,
        hideReconcile: hideReconcile,
        syncSheet: syncSheet,
        exportCsv: exportCsv,
        printSheet: printSheet
    };
})();
</script>
</asp:Content>
