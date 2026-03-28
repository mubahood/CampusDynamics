<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentsRegistration.aspx.cs" Inherits="COOPERP_NewScreens_StudentsRegistration" Title="Student Registration - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== STUDENT REGISTRATION MODULE ===================================== */

/* -- Page Header ------------------------------------- */
.cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
.cd-page-header__left { display:flex; align-items:center; gap:12px; }
.cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
.cd-page-header__right { display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
.cd-page-header .hr-btn--primary { background:rgba(255,255,255,.15); color:#fff; border:1px solid rgba(255,255,255,.3); }
.cd-page-header .hr-btn--primary:hover { background:rgba(255,255,255,.25); color:#fff; }

/* -- Stats Dashboard ---------------------------------- */
.rg-stats-dashboard {
    margin-bottom: 14px;
    display: flex; flex-direction: column; gap: 10px;
}
.rg-stats-section__header {
    display: flex; align-items: center; gap: 8px;
    font-size: 9px; text-transform: uppercase; letter-spacing: 1px;
    color: #aaa; font-weight: 700; padding: 0 2px 6px;
}
.rg-stats-section__header svg { opacity: .45; flex-shrink: 0; }
.rg-stats-section__line { flex: 1; height: 1px; background: #e8ecf0; }

/* Registration grid: hero (wider) + 7 status cards */
.rg-stats-reg {
    display: grid;
    grid-template-columns: 1.6fr repeat(7, 1fr);
    gap: 8px;
}
/* Billing grid: 2 equal wider cards */
.rg-stats-billing {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
}

/* -- Stat Card --------------------------------------- */
.rg-stat {
    background: #fff; border: 1px solid #e4e8f0;
    padding: 11px 14px; display: flex; align-items: center; gap: 10px;
    border-radius: 4px; cursor: pointer; position: relative; overflow: hidden;
    transition: all .2s cubic-bezier(.4,0,.2,1);
}
.rg-stat::after {
    content: ''; position: absolute;
    left: 0; top: 0; bottom: 0; width: 3px;
    background: var(--stat-accent, #ccc);
    border-radius: 4px 0 0 4px;
    transition: width .2s;
}
.rg-stat:hover {
    border-color: rgba(23,77,164,.12);
}
.rg-stat:hover::after { width: 5px; }
.rg-stat:active { transform: translateY(0); }
.rg-stat__icon { width: 34px; height: 34px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 4px; }
.rg-stat__info { min-width: 0; }
.rg-stat__val  { font-size: 20px; font-weight: 800; line-height: 1.1; font-variant-numeric: tabular-nums; }
.rg-stat__label{ font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; white-space: nowrap; }

/* Hero card (Total) */
.rg-stat--hero {
    background: #05275C;
    border: none; color: #fff;
}
.rg-stat--hero::after { display: none; }
.rg-stat--hero .rg-stat__icon {
    background: rgba(255,255,255,.15); width: 42px; height: 42px; border-radius: 4px;
}
.rg-stat--hero .rg-stat__val  { color: #fff; font-size: 28px; }
.rg-stat--hero .rg-stat__label { color: rgba(255,255,255,.7); font-size: 10px; }
.rg-stat--hero:hover { }

/* Color themes */
.rg-stat--grey   { --stat-accent: #9e9e9e; }
.rg-stat--grey   .rg-stat__icon { background: #f5f5f5; } .rg-stat--grey   .rg-stat__val { color: #555; }
.rg-stat--red    { --stat-accent: #dc3545; }
.rg-stat--red    .rg-stat__icon { background: #fdecea; } .rg-stat--red    .rg-stat__val { color: #dc3545; }
.rg-stat--green  { --stat-accent: #28a745; }
.rg-stat--green  .rg-stat__icon { background: #e6f4ea; } .rg-stat--green  .rg-stat__val { color: #28a745; }
.rg-stat--amber  { --stat-accent: #e67e00; }
.rg-stat--amber  .rg-stat__icon { background: #fff8e1; } .rg-stat--amber  .rg-stat__val { color: #e67e00; }
.rg-stat--blue   { --stat-accent: #174DA4; }
.rg-stat--blue   .rg-stat__icon { background: #e8f0fc; } .rg-stat--blue   .rg-stat__val { color: #174DA4; }
.rg-stat--orange { --stat-accent: #e65100; }
.rg-stat--orange .rg-stat__icon { background: #fff3e0; } .rg-stat--orange .rg-stat__val { color: #e65100; }
.rg-stat--pink   { --stat-accent: #880e4f; }
.rg-stat--pink   .rg-stat__icon { background: #fce4ec; } .rg-stat--pink   .rg-stat__val { color: #880e4f; }
.rg-stat--dark   { --stat-accent: #424242; }
.rg-stat--dark   .rg-stat__icon { background: #eeeeee; } .rg-stat--dark   .rg-stat__val { color: #212121; }
.rg-stat--teal   { --stat-accent: #00897b; }
.rg-stat--teal   .rg-stat__icon { background: #e0f2f1; } .rg-stat--teal   .rg-stat__val { color: #00695c; }
.rg-stat--brown  { --stat-accent: #6d4c41; }
.rg-stat--brown  .rg-stat__icon { background: #efebe9; } .rg-stat--brown  .rg-stat__val { color: #4e342e; }

/* Billing card enhancements */
.rg-stat--billing { padding: 14px 18px; }
.rg-stat--billing .rg-stat__icon { width: 38px; height: 38px; }
.rg-stat--billing .rg-stat__val  { font-size: 22px; }
.rg-stat--billing .rg-stat__label { font-size: 10px; }

/* Billing progress bar inside card */
.rg-billing-progress {
    position: absolute; bottom: 0; left: 0; right: 0;
    height: 3px; background: #eef1f5;
}
.rg-billing-progress__fill {
    height: 100%; border-radius: 0 3px 3px 0;
    background: var(--stat-accent, #00897b);
    transition: width .8s cubic-bezier(.4,0,.2,1);
}

/* Grid billing badges */
.rg-badge--billed    { background: #e0f2f1; color: #00695c; }
.rg-badge--notbilled { background: #fff3cd; color: #856404; }
.rg-billing-amt { font-size: 9px; color: #888; display: block; margin-top: 1px; white-space: nowrap; }

/* -- Card -------------------------------------------- */
.cd-card { background: #fff; border: 1px solid #e4e8f0; border-radius: 4px; overflow: hidden; margin-bottom: 14px; }
.cd-card__header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 10px 16px; border-bottom: 1px solid #e4e8f0; background: #fafbfc;
    flex-wrap: wrap; gap: 6px;
}
.cd-card__title { font-size: 13px; font-weight: 700; color: #1a1a1a; display: flex; align-items: center; gap: 7px; }
.cd-card__meta  { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.06); padding: 3px 12px; border-radius: 0; white-space: nowrap; }

/* -- Filter Bar -------------------------------------- */
.ct-filters { background: #f8f9fb; border-bottom: 1px solid #e4e8f0; padding: 10px 14px; }
.ct-filters__top {
    display: flex; align-items: center; gap: 8px;
    margin-bottom: 8px; flex-wrap: wrap;
}
.ct-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 380px; }
.ct-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.ct-search-box {
    width: 100%; padding: 7px 12px 7px 32px;
    border: 1px solid #dde1e6; border-radius: 0;
    font-size: 12px; background: #fff;
    transition: border-color .15s, box-shadow .15s;
    box-sizing: border-box;
}
.ct-search-box:focus { border-color: #174DA4; box-shadow: 0 0 0 3px rgba(23,77,164,.08); outline: none; }
.ct-search-box::placeholder { color: #aaa; }
.ct-filters__count {
    font-size: 11px; color: #174DA4; font-weight: 600; white-space: nowrap;
    background: rgba(23,77,164,.06); padding: 5px 13px; border-radius: 0;
    margin-left: auto;
}
.ct-filters__row { display: flex; gap: 8px; flex-wrap: wrap; align-items: flex-end; }
.ct-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.ct-filter-grp__label {
    font-size: 9px; color: #999; text-transform: uppercase;
    letter-spacing: .5px; font-weight: 600;
}
.ct-filter-select {
    border: 1px solid #dde1e6; border-radius: 0;
    padding: 6px 10px; font-size: 11px; background: #fff; color: #333;
    transition: border-color .15s, box-shadow .15s;
    cursor: pointer; min-width: 110px;
}
.ct-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 3px rgba(23,77,164,.08); outline: none; }
.ct-filter-sep { width: 1px; height: 32px; background: #e0e4ea; align-self: flex-end; margin: 0 4px; }

/* -- Buttons ----------------------------------------- */
.hr-btn {
    padding: 7px 15px; font-size: 11px; font-weight: 600;
    border: none; cursor: pointer; border-radius: 0;
    display: inline-flex; align-items: center; gap: 6px;
    white-space: nowrap; line-height: 1.4;
    transition: background .15s, transform .1s;
    text-decoration: none;
}
.hr-btn:active { transform: scale(.97); }
.hr-btn--primary { background: #174DA4; color: #fff; }  .hr-btn--primary:hover { background: #0f3a7d; }
.hr-btn--success { background: #28a745; color: #fff; }  .hr-btn--success:hover { background: #218838; }
.hr-btn--danger  { background: #dc3545; color: #fff; }  .hr-btn--danger:hover  { background: #c82333; }
.hr-btn--amber   { background: #e67e00; color: #fff; }  .hr-btn--amber:hover   { background: #b45309; }
.hr-btn--orange  { background: #e65100; color: #fff; }  .hr-btn--orange:hover  { background: #bf360c; }
.hr-btn--ghost   { background: transparent; color: #555; border: 1px solid #dde1e6; } .hr-btn--ghost:hover { border-color: #174DA4; color: #174DA4; background: rgba(23,77,164,.03); }
.hr-btn--outline { background: #fff; color: #174DA4; border: 1px solid #174DA4; } .hr-btn--outline:hover { background: #174DA4; color: #fff; }
.hr-btn--sm      { padding: 5px 12px; font-size: 10px; }

/* -- Batch Toolbar ----------------------------------- */
.rg-batch-bar {
    display: none; align-items: center; gap: 8px; flex-wrap: wrap;
    padding: 8px 14px; background: #fffbe6;
    border-top: 1px solid #e4e8f0; border-bottom: 2px solid #ffc107;
}
.rg-batch-bar.show { display: flex; }
.rg-batch-info { display: flex; align-items: center; gap: 5px; font-size: 11px; color: #6d4c00; white-space: nowrap; }
.rg-batch-info strong { font-size: 13px; font-weight: 700; color: #b45309; }
.rg-batch-sep  { width: 1px; height: 24px; background: #e0c060; margin: 0 2px; flex-shrink: 0; }

/* -- Status Badges ----------------------------------- */
.rg-badge {
    display: inline-block; padding: 3px 9px;
    font-size: 9px; font-weight: 700;
    text-transform: uppercase; letter-spacing: .4px;
    border-radius: 4px; white-space: nowrap;
}
.rg-badge--unreg     { background: #fff3cd; color: #856404; }
.rg-badge--reg       { background: #d4edda; color: #155724; }
.rg-badge--late      { background: #fff0c2; color: #7c4a00; }
.rg-badge--cleared   { background: #cce5ff; color: #004085; }
.rg-badge--discont   { background: #f8d7da; color: #721c24; }
.rg-badge--halted    { background: #ffe0b2; color: #7c4500; }
.rg-badge--dead      { background: #d6d8db; color: #1b1e21; }
.rg-badge--uncleared { background: #fff3cd; color: #856404; }
.rg-badge--printed   { background: #e8f0fc; color: #174DA4; }
.rg-badge--issued    { background: #d4edda; color: #155724; }
.rg-badge--notissued { background: #e9ecef; color: #6c757d; }

/* -- Action Popover ---------------------------------- */
.cd-action-wrapper { position: relative; display: inline-block; }
.cd-action-trigger {
    background: none; border: 1px solid #ddd; border-radius: 0;
    padding: 3px 7px; cursor: pointer; color: #555;
    display: inline-flex; align-items: center;
    transition: border-color .15s, background .15s;
}
.cd-action-trigger:hover { border-color: #174DA4; color: #174DA4; background: #f0f4ff; }
.cd-action-popover {
    display: none; position: absolute; right: 0; top: calc(100% + 4px);
    z-index: 9999; background: #fff; border: 1px solid #e4e8f0;
    border-radius: 0; min-width: 180px;
}
.cd-action-popover.is-open { display: block; }
.cd-action-popover__section {
    padding: 4px 12px 2px;
    font-size: 8px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .6px; color: #aaa;
    border-top: 1px solid #f4f4f4; margin-top: 2px;
}
.cd-action-popover__section:first-child { border-top: none; margin-top: 0; }
.cd-action-popover__menu   { list-style: none; margin: 0; padding: 2px 0; }
.cd-action-popover__item   { margin: 0; }
.cd-action-popover__btn    {
    width: 100%; background: none; border: none; padding: 6px 14px;
    font-size: 11px; color: #333; cursor: pointer;
    display: flex; align-items: center; gap: 8px; text-align: left;
    transition: background .12s;
}
.cd-action-popover__btn:hover            { background: #f0f4ff; color: #174DA4; }
.cd-action-popover__btn--danger:hover    { background: #fdecea; color: #dc3545; }
.cd-action-popover__btn--success:hover   { background: #e6f4ea; color: #28a745; }
.cd-action-popover__btn--amber:hover     { background: #fff8e1; color: #e67e00; }
.cd-action-popover__btn svg { width: 13px; height: 13px; flex-shrink: 0; }
.cd-action-popover__divider { height: 1px; background: #f0f0f0; margin: 3px 0; }
.cd-card,.cd-card__body,.dxgvCSD,.dxgvControl_Glass,.dxgvTable_Glass,.dxgvDataRow_Glass td,td.rg-action-cell { overflow: visible !important; }

/* -- Grid Tweaks ------------------------------------- */
.dxgvControl_Glass { border: none !important; }
.dxgvHeader_Glass td {
    font-size: 10px !important; text-transform: uppercase !important;
    letter-spacing: .4px !important; background: #f5f7fa !important;
    color: #666 !important; border-bottom: 2px solid #e4e8f0 !important;
    padding: 9px 10px !important; font-weight: 600 !important;
}
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td {
    font-size: 11px !important; padding: 8px 10px !important;
    border-bottom: 1px solid #f2f3f5 !important; vertical-align: middle !important;
}
.dxgvDataRow_Glass:hover td,
.dxgvDataRowAlt_Glass:hover td { background: #f0f4ff !important; }
.dxgvPagerBar_Glass { background: #fafbfc !important; border-top: 1px solid #e4e8f0 !important; font-size: 11px !important; padding: 4px 8px !important; }
.dxgvFilterRow_Glass td { background: #fff !important; padding: 5px 8px !important; }

/* Row status tints */
.rg-row-late  td { background: #fffdf0 !important; }
.rg-row-cleared td { background: #f0f7ff !important; }
.rg-row-discont td { background: #fff8f8 !important; }
.rg-row-halted  td { background: #fff9f0 !important; }
.rg-row-dead    td { background: #f8f8f8 !important; }

/* -- Grid Footer ------------------------------------- */
.rg-grid-footer {
    display: flex; justify-content: space-between; align-items: center;
    padding: 8px 14px; background: #fafbfc;
    border-top: 1px solid #e4e8f0; font-size: 11px; color: #666;
    flex-wrap: wrap; gap: 6px;
}
.rg-grid-footer strong { color: #174DA4; }

/* -- Modal ------------------------------------------- */
.hr-modal-overlay {
    display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,.48); z-index: 10000;
    align-items: center; justify-content: center;
    padding: 16px; box-sizing: border-box;
}
.hr-modal-overlay.open { display: flex; }
.hr-modal {
    background: #fff; width: 540px; max-width: 100%;
    max-height: calc(100vh - 32px); overflow: hidden;
    border-radius: 2px; box-shadow: 0 20px 60px rgba(0,0,0,.22);
    display: flex; flex-direction: column;
    animation: rgModalIn .2s ease;
}
@keyframes rgModalIn { from { opacity: 0; transform: translateY(-12px) scale(.98); } to { opacity: 1; transform: none; } }
.hr-modal__header {
    background: #05275C; color: #fff; padding: 13px 18px;
    font-size: 14px; font-weight: 700;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0; border-radius: 0;
}
.hr-modal__close { background: none; border: none; color: rgba(255,255,255,.8); font-size: 22px; cursor: pointer; line-height: 1; padding: 0 2px; }
.hr-modal__close:hover { color: #fff; }
.hr-modal__body  { padding: 16px; flex: 1; overflow-y: auto; }
.hr-modal__footer{
    padding: 10px 16px; border-top: 1px solid #e4e8f0;
    display: flex; justify-content: flex-end; gap: 8px;
    flex-shrink: 0; background: #fafbfc; border-radius: 0;
}
.hr-modal__section {
    font-size: 9px; text-transform: uppercase; letter-spacing: .6px;
    color: #174DA4; font-weight: 700; padding: 6px 0 4px;
    border-bottom: 1px solid #e8ecf4; margin-bottom: 8px; margin-top: 14px;
}
.hr-modal__section:first-child { margin-top: 0; }

/* -- Form -------------------------------------------- */
.hr-form-group  { margin-bottom: 10px; }
.hr-form-label  { display: block; font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #555; font-weight: 600; margin-bottom: 3px; }
.hr-form-label .req { color: #dc3545; margin-left: 2px; }
.hr-form-input, .hr-form-select, .hr-form-textarea {
    width: 100%; padding: 6px 9px; border: 1px solid #ccc;
    border-radius: 0; font-size: 12px; box-sizing: border-box; background: #fff;
    transition: border-color .15s, box-shadow .15s;
}
.hr-form-input:focus, .hr-form-select:focus, .hr-form-textarea:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.hr-form-row  { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.hr-form-hint { font-size: 10px; color: #888; margin-top: 2px; }
.hr-result { margin-top: 8px; font-size: 12px; padding: 7px 11px; display: none; border-radius: 0; }
.hr-result--err { background: #fdecea; color: #b91c1c; border-left: 3px solid #dc3545; display: block; }
.hr-result--ok  { background: #e6f4ea; color: #155724; border-left: 3px solid #28a745; display: block; }

/* -- Student Info Block (in modals) ------------------ */
.rg-student-info {
    background: #f5f7fa; border: 1px solid #e4e8f0; border-radius: 4px;
    padding: 10px 14px; margin-bottom: 12px;
    font-size: 12px; display: flex; gap: 16px; flex-wrap: wrap;
}
.rg-student-info__item { display: flex; flex-direction: column; gap: 1px; }
.rg-student-info__label { font-size: 9px; text-transform: uppercase; letter-spacing: .4px; color: #888; font-weight: 600; }
.rg-student-info__value { font-weight: 700; color: #1a1a2e; font-size: 12px; }

/* -- Toast ------------------------------------------- */
.rg-toast {
    position: fixed; bottom: 24px; right: 24px;
    padding: 11px 18px; border-radius: 0;
    font-size: 12px; font-weight: 600; z-index: 20000;
    transform: translateY(20px); opacity: 0;
    transition: transform .25s, opacity .25s;
    pointer-events: none; max-width: 360px;
    display: flex; align-items: center; gap: 8px;
}
.rg-toast.show { transform: none; opacity: 1; }
.rg-toast--success { background: #28a745; color: #fff; }
.rg-toast--error   { background: #dc3545; color: #fff; }
.rg-toast--info    { background: #174DA4; color: #fff; }

/* -- Responsive -------------------------------------- */
@media (max-width: 1400px) {
    .rg-stats-reg { grid-template-columns: repeat(4, 1fr); }
    .rg-stat--hero { grid-column: span 1; }
}
@media (max-width: 1100px) {
    .rg-stats-reg { grid-template-columns: repeat(4, 1fr); }
}
@media (max-width: 900px)  {
    .rg-stats-reg { grid-template-columns: repeat(3, 1fr); }
    .rg-stats-billing { grid-template-columns: 1fr 1fr; }
    .ct-filters__count { display: none; }
}
@media (max-width: 700px)  {
    .rg-stats-reg { grid-template-columns: 1fr 1fr; }
    .rg-stats-billing { grid-template-columns: 1fr; }
    .cd-page-header { flex-direction: column; align-items: flex-start; }
    .ct-filter-grp { flex: 1 1 140px; }
    .ct-filter-select { min-width: 0; width: 100%; }
    .ct-filter-sep { display: none; }
    .hr-form-row { grid-template-columns: 1fr; }
}
@media (max-width: 480px)  {
    .rg-stats-reg { grid-template-columns: 1fr 1fr; }
    .rg-stats-billing { grid-template-columns: 1fr; }
    .rg-stat--hero { grid-column: span 2; }
    .rg-stat--billing { padding: 12px 14px; }
    .rg-batch-bar .hr-btn { flex: 1 1 auto; justify-content: center; }
    .hr-modal { max-height: 100vh; border-radius: 0; }
    .hr-modal-overlay { padding: 0; align-items: flex-end; }
    .hr-modal__header, .hr-modal__footer { border-radius: 0; }
    .hr-modal__footer { flex-direction: column-reverse; }
    .hr-modal__footer .hr-btn { width: 100%; justify-content: center; }
}
@media print {
    .rg-batch-bar, .ct-filters, .cd-page-header .hr-btn { display: none !important; }
}

/* -- Register All Modal ------------------------------ */
.ra-phase { display: none; }
.ra-summary { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 14px; }
.ra-summary__item {
    flex: 1 1 100px; background: #f5f7fa; border: 1px solid #e4e8f0;
    padding: 10px 14px; text-align: center; min-width: 90px;
}
.ra-summary__val { font-size: 20px; font-weight: 800; color: #05275C; line-height: 1.2; }
.ra-summary__label { font-size: 9px; text-transform: uppercase; letter-spacing: .4px; color: #888; font-weight: 600; margin-top: 2px; }
.ra-breakdown { margin-bottom: 12px; }
.ra-breakdown__title {
    font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #174DA4;
    font-weight: 700; padding-bottom: 4px; border-bottom: 1px solid #e4e8f0; margin-bottom: 6px;
}
.ra-breakdown__row { display: flex; justify-content: space-between; padding: 3px 0; font-size: 11px; border-bottom: 1px solid #f5f5f5; }
.ra-breakdown__label { color: #333; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; padding-right: 8px; }
.ra-breakdown__count { font-weight: 700; color: #05275C; flex-shrink: 0; }
.ra-breakdowns { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
@media (max-width: 600px) { .ra-breakdowns { grid-template-columns: 1fr; } }
.ra-table-wrap { max-height: 240px; overflow-y: auto; border: 1px solid #e4e8f0; }
.ra-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.ra-table th {
    background: #f5f7fa; color: #555; font-size: 9px; text-transform: uppercase;
    letter-spacing: .3px; font-weight: 600; padding: 7px 10px; text-align: left;
    border-bottom: 2px solid #e0e5ed; position: sticky; top: 0; z-index: 1;
}
.ra-table td { padding: 5px 10px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; }
.ra-table tr:hover td { background: #f8f9fb; }
.ra-loading { text-align: center; padding: 40px 20px; color: #888; }
.ra-loading__spinner {
    width: 32px; height: 32px; border: 3px solid #e4e8f0; border-top-color: #174DA4;
    border-radius: 50%; animation: raSpinner .8s linear infinite; margin: 0 auto 12px;
}
@keyframes raSpinner { to { transform: rotate(360deg); } }
.ra-progress-wrap { margin: 16px 0; }
.ra-progress { height: 28px; background: #e9ecef; position: relative; overflow: hidden; }
.ra-progress__fill {
    height: 100%; background: linear-gradient(90deg, #16a34a, #22c55e);
    transition: width .3s ease; position: relative;
}
.ra-progress__fill::after {
    content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,.2), transparent);
    animation: raShimmer 1.5s infinite;
}
@keyframes raShimmer { from { transform: translateX(-100%); } to { transform: translateX(100%); } }
.ra-progress__text {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: 12px; font-weight: 700; color: #1a1a2e; z-index: 1;
}
.ra-live-stats { display: flex; gap: 12px; flex-wrap: wrap; margin: 12px 0; }
.ra-live-stat {
    flex: 1 1 80px; text-align: center; padding: 8px; background: #f5f7fa; border: 1px solid #e4e8f0;
}
.ra-live-stat__val { font-size: 18px; font-weight: 800; color: #05275C; }
.ra-live-stat--ok .ra-live-stat__val { color: #16a34a; }
.ra-live-stat--bill .ra-live-stat__val { color: #174DA4; }
.ra-live-stat--err .ra-live-stat__val { color: #dc3545; }
.ra-live-stat__lbl { font-size: 9px; text-transform: uppercase; letter-spacing: .3px; color: #888; font-weight: 600; margin-top: 2px; }
.ra-log { max-height: 160px; overflow-y: auto; background: #1a1a2e; padding: 10px 12px; font-family: 'Consolas','Monaco',monospace; font-size: 10px; line-height: 1.7; }
.ra-log__entry { color: #a0aec0; }
.ra-log__entry--ok { color: #68d391; }
.ra-log__entry--error { color: #fc8181; }
.ra-log__entry--info { color: #63b3ed; }
.ra-done-wrap { text-align: center; padding: 16px 0 8px; }
.ra-done-icon {
    width: 56px; height: 56px; margin: 0 auto 12px; background: #e6f4ea;
    border-radius: 50%; display: flex; align-items: center; justify-content: center;
}
.ra-done-title { font-size: 16px; font-weight: 700; color: #1a1a2e; margin-bottom: 4px; }
.ra-done-sub { font-size: 12px; color: #666; margin-bottom: 16px; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<%-- Hidden batch action buttons --%>
<asp:HiddenField ID="hdnChangeStatusID" runat="server" />
<asp:Button ID="btnBatchRegister"      runat="server" style="display:none;" OnClick="btnBatchRegister_Click" />
<asp:Button ID="btnBatchLateRegister"  runat="server" style="display:none;" OnClick="btnBatchLateRegister_Click" />
<asp:Button ID="btnBatchClear"         runat="server" style="display:none;" OnClick="btnBatchClear_Click" />
<asp:Button ID="btnBatchUndoReg"       runat="server" style="display:none;" OnClick="btnBatchUndoReg_Click" />
<asp:Button ID="btnBatchUndoClear"     runat="server" style="display:none;" OnClick="btnBatchUndoClear_Click" />
<asp:Button ID="btnBatchDiscontinue"   runat="server" style="display:none;" OnClick="btnBatchDiscontinue_Click" />
<asp:Button ID="btnBatchHalt"          runat="server" style="display:none;" OnClick="btnBatchHalt_Click" />
<asp:Button ID="btnBatchDeadYear"      runat="server" style="display:none;" OnClick="btnBatchDeadYear_Click" />
<asp:Button ID="btnBatchReactivate"    runat="server" style="display:none;" OnClick="btnBatchReactivate_Click" />
<asp:Button ID="btnBatchDelete"        runat="server" style="display:none;" OnClick="btnBatchDelete_Click" />
<asp:Button ID="btnDoAddReg"           runat="server" style="display:none;" OnClick="btnDoAddReg_Click" />
<asp:Button ID="btnDoChangeStatus"     runat="server" style="display:none;" OnClick="btnDoChangeStatus_Click" />
<asp:Button ID="btnExportCsv"          runat="server" style="display:none;" OnClick="btnExportCsv_Click" />
<asp:Button ID="btnReset"              runat="server" style="display:none;" OnClick="btnReset_Click" />
<asp:Button ID="btnRefresh"            runat="server" style="display:none;" OnClick="btnRefresh_Click" />

<!-- ======= PAGE HEADER =============================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                <circle cx="9" cy="7" r="4"></circle>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
        </div>
        <div>
            <div class="cd-page-header__title">Student Registration</div>
            <div class="cd-page-header__sub">Manage student registration status and academic year enrollment</div>
        </div>
    </div>
    <div class="cd-page-header__right">
        <asp:Literal ID="litAcadContext" runat="server" />
        <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="openAddRegModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Add Registration
        </button>
        <button type="button" class="hr-btn hr-btn--sm" style="background:#16a34a;color:#fff;border:none;" onclick="openRegisterAllModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Register All Unregistered
        </button>
        <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="document.getElementById('<%=btnExportCsv.ClientID%>').click()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
            Export CSV
        </button>
    </div>
</div>

<!-- ======= STATS DASHBOARD =========================================== -->
<div class="rg-stats-dashboard">

    <!-- Registration Overview -->
    <div class="rg-stats-section">
        <div class="rg-stats-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
            Registration Overview
            <span class="rg-stats-section__line"></span>
        </div>
        <div class="rg-stats-reg">
            <!-- Hero Total -->
            <div class="rg-stat rg-stat--hero" onclick="clearStatusFilter()" title="Show All">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="rg-stat__label">Total Students</div></div>
            </div>
            <!-- Unregistered -->
            <div class="rg-stat rg-stat--red" onclick="filterByStatus('UNREGISTERED')" title="Filter: Unregistered">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litUnregistered" runat="server" Text="0" /></div><div class="rg-stat__label">Unregistered</div></div>
            </div>
            <!-- Registered -->
            <div class="rg-stat rg-stat--green" onclick="filterByStatus('REGISTERED')" title="Filter: Registered">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litRegistered" runat="server" Text="0" /></div><div class="rg-stat__label">Registered</div></div>
            </div>
            <!-- Late Registered -->
            <div class="rg-stat rg-stat--amber" onclick="filterByStatus('LATE REGISTERED')" title="Filter: Late Registered">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litLateRegistered" runat="server" Text="0" /></div><div class="rg-stat__label">Late Reg.</div></div>
            </div>
            <!-- Cleared -->
            <div class="rg-stat rg-stat--blue" onclick="filterByStatus('CLEARED')" title="Filter: Cleared">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litCleared" runat="server" Text="0" /></div><div class="rg-stat__label">Cleared</div></div>
            </div>
            <!-- Discontinued -->
            <div class="rg-stat rg-stat--pink" onclick="filterByStatus('DISCONTINUED')" title="Filter: Discontinued">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#880e4f" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litDiscontinued" runat="server" Text="0" /></div><div class="rg-stat__label">Discontinued</div></div>
            </div>
            <!-- Halted -->
            <div class="rg-stat rg-stat--orange" onclick="filterByStatus('HALTED')" title="Filter: Halted">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litHalted" runat="server" Text="0" /></div><div class="rg-stat__label">Halted</div></div>
            </div>
            <!-- Dead Year -->
            <div class="rg-stat rg-stat--dark" onclick="filterByStatus('DEAD YEAR')" title="Filter: Dead Year">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#212121" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litDeadYear" runat="server" Text="0" /></div><div class="rg-stat__label">Dead Year</div></div>
            </div>
        </div>
    </div>

    <!-- Billing Overview -->
    <div class="rg-stats-section">
        <div class="rg-stats-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
            Billing Status
            <span class="rg-stats-section__line"></span>
        </div>
        <div class="rg-stats-billing">
            <!-- Billed -->
            <div class="rg-stat rg-stat--teal rg-stat--billing" onclick="filterByBilling('BILLED')" title="Filter: Billed Students">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#00695c" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litBilled" runat="server" Text="0" /></div><div class="rg-stat__label">Billed (Enrolled)</div></div>
                <div class="rg-billing-progress"><div class="rg-billing-progress__fill" id="billedBar" style="width:0%"></div></div>
            </div>
            <!-- Not Billed -->
            <div class="rg-stat rg-stat--brown rg-stat--billing" onclick="filterByBilling('NOT BILLED')" title="Filter: Not Billed Students">
                <div class="rg-stat__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#4e342e" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                </div>
                <div class="rg-stat__info"><div class="rg-stat__val"><asp:Literal ID="litNotBilled" runat="server" Text="0" /></div><div class="rg-stat__label">Not Billed (Enrolled)</div></div>
                <div class="rg-billing-progress"><div class="rg-billing-progress__fill" id="notBilledBar" style="width:0%"></div></div>
            </div>
        </div>
    </div>

</div>

<!-- ======= MAIN CARD ================================================= -->
<div class="cd-card">

    <!-- Filter Bar -->
    <div class="ct-filters">
        <div class="ct-filters__top">
            <div class="ct-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-search-box" placeholder="Search by name, reg no, student number, programme..." AutoPostBack="false" />
            </div>
            <asp:Button ID="btnSearch" runat="server" CssClass="hr-btn hr-btn--primary hr-btn--sm" Text="Search" OnClick="btnSearch_Click" />
            <asp:Label ID="lblRecordCount" runat="server" CssClass="ct-filters__count" Text="0 records" />
        </div>
        <div class="ct-filters__row">
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Academic Year</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Semesters" Selected="True" />
                    <asp:ListItem Value="1" Text="Semester 1" />
                    <asp:ListItem Value="2" Text="Semester 2" />
                    <asp:ListItem Value="3" Text="Semester 3" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Study Year</label>
                <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Years" />
                    <asp:ListItem Value="1" Text="Year 1" />
                    <asp:ListItem Value="2" Text="Year 2" />
                    <asp:ListItem Value="3" Text="Year 3" />
                    <asp:ListItem Value="4" Text="Year 4" />
                    <asp:ListItem Value="5" Text="Year 5" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Reg Status</label>
                <asp:DropDownList ID="ddlRegStatus" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRegStatus_SelectedIndexChanged">
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
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Programme</label>
                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width:160px;">
                    <asp:ListItem Value="" Text="All Programmes" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Exam Clearance</label>
                <asp:DropDownList ID="ddlExamClearance" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlExamClearance_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="UNCLEARED" Text="Uncleared" />
                    <asp:ListItem Value="CLEARED" Text="Cleared" />
                    <asp:ListItem Value="PRINTED" Text="Printed" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">ID Card</label>
                <asp:DropDownList ID="ddlIDCard" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlIDCard_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="NOT ISSUED" Text="Not Issued" />
                    <asp:ListItem Value="ISSUED" Text="Issued" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Residence</label>
                <asp:DropDownList ID="ddlResidence" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlResidence_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="RESIDENT" Text="Resident" />
                    <asp:ListItem Value="NON-RESIDENT" Text="Non-Resident" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Billing</label>
                <asp:DropDownList ID="ddlBilling" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBilling_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="BILLED" Text="Billed" />
                    <asp:ListItem Value="NOT BILLED" Text="Not Billed" />
                </asp:DropDownList>
            </div>
            <div class="ct-filter-sep"></div>
            <div class="ct-filter-grp">
                <label class="ct-filter-grp__label">Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="min-width:80px;">
                    <asp:ListItem Value="25"  Text="25" />
                    <asp:ListItem Value="50"  Text="50" Selected="True" />
                    <asp:ListItem Value="100" Text="100" />
                    <asp:ListItem Value="200" Text="200" />
                    <asp:ListItem Value="500" Text="All (500)" />
                </asp:DropDownList>
            </div>
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
        </div>
    </div>

    <!-- Batch Toolbar -->
    <div class="rg-batch-bar" id="batchBar">
        <div class="rg-batch-info">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
            <strong id="batchSelCount">0</strong>&nbsp;student(s) selected
        </div>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--success hr-btn--sm" onclick="doBatch('register')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Register
        </button>
        <button type="button" class="hr-btn hr-btn--amber hr-btn--sm" onclick="doBatch('late')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            Late Register
        </button>
        <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="doBatch('clear')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            Clear for Exams
        </button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('undoreg')">Undo Reg.</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('undoclear')">Undo Clearance</button>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatch('discontinue')">Discontinue</button>
        <button type="button" class="hr-btn hr-btn--orange hr-btn--sm" onclick="doBatch('halt')">Halt</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('deadyear')">Dead Year</button>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatch('reactivate')">Reactivate</button>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatch('delete')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
            Delete
        </button>
        <div class="rg-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="gvRegistration.UnselectRows(); updateBatchBar();" style="color:#888;">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            Clear Selection
        </button>
    </div>

    <!-- Grid -->
    <dx:ASPxGridView ID="gvRegistration" runat="server" AutoGenerateColumns="False"
        KeyFieldName="ID" Width="100%" ClientInstanceName="gvRegistration"
        OnHtmlDataCellPrepared="gvRegistration_HtmlDataCellPrepared"
        OnHtmlRowPrepared="gvRegistration_HtmlRowPrepared"
        CssClass="reg-grid">
        <ClientSideEvents SelectionChanged="function(s,e){ updateBatchBar(); }" />
        <SettingsBehavior AllowSelectByRowClick="false" AllowSelectSingleRowOnly="false" />
        <SettingsPager PageSize="50" AlwaysShowPager="true" Position="Bottom">
            <PageSizeItemSettings Visible="false" />
        </SettingsPager>
        <Settings ShowFilterRow="false" ShowGroupPanel="false" />
        <Styles>
            <Header Font-Size="10px" Font-Bold="true" BackColor="#f5f7fa" ForeColor="#555" />
            <Row Font-Size="11px" />
            <AlternatingRow Enabled="true" BackColor="#fafbfc" />
            <FilterRow BackColor="#fff" />
        </Styles>
        <Columns>
            <dx:GridViewCommandColumn ShowSelectCheckbox="True" Width="34px" SelectAllCheckboxMode="AllPages">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewCommandColumn>
            <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="115px">
                <HeaderStyle HorizontalAlign="Left" />
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="190px">
                <HeaderStyle HorizontalAlign="Left" />
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="progcode" Caption="Programme" Width="95px">
                <HeaderStyle HorizontalAlign="Left" />
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="acad_year" Caption="Acad. Year" Width="90px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" Font-Size="10px" />
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" Width="50px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
                <DataItemTemplate>
                    <span style="font-size:10px;font-weight:600;color:#174DA4;background:rgba(23,77,164,.08);padding:1px 7px;border-radius:3px;">
                        Sem <%# Eval("semester") %>
                    </span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="studyyear" Caption="Yr" Width="44px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="residence_status" Caption="Res." Width="75px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="regstatus" Caption="Reg Status" Width="120px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
                <DataItemTemplate>
                    <span class='rg-badge rg-badge--<%# GetStatusClass(Eval("regstatus").ToString()) %>'><%# Eval("regstatus") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="examClearance" Caption="Exam Clearance" Width="105px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
                <DataItemTemplate>
                    <span class='rg-badge rg-badge--<%# GetClearanceClass(Eval("examClearance").ToString()) %>'><%# Eval("examClearance") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="id_cardStatus" Caption="ID Card" Width="80px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
                <DataItemTemplate>
                    <span class='rg-badge rg-badge--<%# GetIDCardClass(Eval("id_cardStatus").ToString()) %>'><%# Eval("id_cardStatus") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="billing_status" Caption="Billing" Width="100px">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" />
                <DataItemTemplate>
                    <span class='rg-badge rg-badge--<%# GetBillingClass(Eval("billing_status").ToString()) %>'><%# Eval("billing_status") %></span>
                    <%# Convert.ToDouble(Eval("total_billed") == DBNull.Value ? 0 : Eval("total_billed")) > 0 ? "<span class='rg-billing-amt'>" + Convert.ToDouble(Eval("total_billed")).ToString("N0") + "</span>" : "" %>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="registeredBy" Caption="Reg By" Width="90px">
                <HeaderStyle HorizontalAlign="Left" />
                <CellStyle Font-Size="10px" ForeColor="#888" />
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="examClearanceDate" Caption="Cleared On" Width="90px">
                <HeaderStyle HorizontalAlign="Left" />
                <CellStyle Font-Size="10px" ForeColor="#888" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn VisibleIndex="99" Caption=" " Width="44px"
                Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                <HeaderStyle HorizontalAlign="Center" />
                <CellStyle HorizontalAlign="Center" CssClass="rg-action-cell" />
                <DataItemTemplate>
                    <div class="cd-action-wrapper">
                        <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)" title="Actions">
                            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle>
                            </svg>
                        </button>
                        <div class="cd-action-popover">

                            <%-- -- Registration Actions -- --%>
                            <div class="cd-action-popover__section">Registration</div>
                            <ul class="cd-action-popover__menu">
                                <li class="cd-action-popover__item" style='<%# ShowIf(Eval("regstatus"),"UNREGISTERED") %>'>
                                    <asp:LinkButton ID="btnRegister" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--success"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnRegister_Click"
                                        OnClientClick="return confirm('Register this student?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                        Register
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIf(Eval("regstatus"),"UNREGISTERED") %>'>
                                    <asp:LinkButton ID="btnLateRegister" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--amber"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnLateRegister_Click"
                                        OnClientClick="return confirm('Mark this student as Late Registered?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                        Late Register
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIfIn(Eval("regstatus"),"REGISTERED|LATE REGISTERED") %>'>
                                    <asp:LinkButton ID="btnClear" runat="server" CssClass="cd-action-popover__btn"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnClear_Click"
                                        OnClientClick="return confirm('Clear this student for exams?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                                        Clear for Exams
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIf(Eval("examClearance"),"CLEARED") %>'>
                                    <asp:LinkButton ID="btnUndoClear" runat="server" CssClass="cd-action-popover__btn"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnUndoClear_Click"
                                        OnClientClick="return confirm('Undo exam clearance? Student will revert to Registered.');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                                        Undo Clearance
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIfIn(Eval("regstatus"),"REGISTERED|LATE REGISTERED") %>'>
                                    <asp:LinkButton ID="btnUnregister" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnUnregister_Click"
                                        OnClientClick="return confirm('Undo registration for this student?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                        Undo Registration
                                    </asp:LinkButton>
                                </li>
                            </ul>

                            <%-- -- Special Status -- --%>
                            <div class="cd-action-popover__section" style='<%# ShowIfNotIn(Eval("regstatus"),"DISCONTINUED|DEAD YEAR|HALTED") %>'>Special Status</div>
                            <ul class="cd-action-popover__menu">
                                <li class="cd-action-popover__item" style='<%# ShowIfNotIn(Eval("regstatus"),"DISCONTINUED|DEAD YEAR") %>'>
                                    <asp:LinkButton ID="btnDiscontinue" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnDiscontinue_Click"
                                        OnClientClick="return confirm('Mark this student as Discontinued? This is a significant change.');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                                        Discontinue
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIfNotIn(Eval("regstatus"),"HALTED|DISCONTINUED|DEAD YEAR") %>'>
                                    <asp:LinkButton ID="btnHalt" runat="server" CssClass="cd-action-popover__btn"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnHalt_Click"
                                        OnClientClick="return confirm('Halt registration for this student?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>
                                        Halt
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIfNot(Eval("regstatus"),"DEAD YEAR") %>'>
                                    <asp:LinkButton ID="btnDeadYear" runat="server" CssClass="cd-action-popover__btn"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnDeadYear_Click"
                                        OnClientClick="return confirm('Mark this semester as a Dead Year for this student?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                        Mark Dead Year
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIfIn(Eval("regstatus"),"DISCONTINUED|HALTED|DEAD YEAR") %>'>
                                    <asp:LinkButton ID="btnReactivate" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--success"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnReactivate_Click"
                                        OnClientClick="return confirm('Reactivate this student (reset to Unregistered)?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path></svg>
                                        Reactivate
                                    </asp:LinkButton>
                                </li>
                            </ul>

                            <%-- -- ID Card -- --%>
                            <div class="cd-action-popover__section">ID Card</div>
                            <ul class="cd-action-popover__menu">
                                <li class="cd-action-popover__item" style='<%# ShowIfNot(Eval("id_cardStatus"),"ISSUED") %>'>
                                    <asp:LinkButton ID="btnIssueIDCard" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--success"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnIssueIDCard_Click"
                                        OnClientClick="return confirm('Mark ID card as Issued for this student?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
                                        Issue ID Card
                                    </asp:LinkButton>
                                </li>
                                <li class="cd-action-popover__item" style='<%# ShowIf(Eval("id_cardStatus"),"ISSUED") %>'>
                                    <asp:LinkButton ID="btnRevokeIDCard" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnRevokeIDCard_Click"
                                        OnClientClick="return confirm('Revoke this student\'s ID card?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
                                        Revoke ID Card
                                    </asp:LinkButton>
                                </li>
                            </ul>

                            <%-- -- Change Status (generic) -- --%>
                            <div class="cd-action-popover__divider"></div>
                            <ul class="cd-action-popover__menu">
                                <li class="cd-action-popover__item">
                                    <button type="button" class="cd-action-popover__btn"
                                        onclick="openChangeStatusModal('<%# Eval("ID") %>','<%# JsEncode(Eval("student_name")) %>','<%# JsEncode(Eval("regno")) %>','<%# JsEncode(Eval("regstatus")) %>')">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                        Change Status...
                                    </button>
                                </li>
                            </ul>

                            <%-- -- Delete Registration -- --%>
                            <div class="cd-action-popover__divider"></div>
                            <ul class="cd-action-popover__menu">
                                <li class="cd-action-popover__item">
                                    <asp:LinkButton ID="btnDeleteReg" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--danger"
                                        CommandArgument='<%# Eval("ID") %>' OnClick="btnDeleteReg_Click"
                                        OnClientClick="return confirm('DELETE this registration record permanently?\n\nThis cannot be undone. Continue?');">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                        Delete Registration
                                    </asp:LinkButton>
                                </li>
                            </ul>

                        </div>
                    </div>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
    </dx:ASPxGridView>

    <!-- Grid Footer -->
    <div class="rg-grid-footer">
        <div>
            <strong><asp:Literal ID="litAcadYearDisplay" runat="server" /></strong>
            &nbsp;|&nbsp; Semester <strong><asp:Literal ID="litSemesterDisplay" runat="server" /></strong>
            &nbsp;|&nbsp; <asp:Literal ID="litFooterCount" runat="server" Text="0 records" />
        </div>
        <div style="color:#aaa;font-size:10px;">
            Click a stat card above to quick-filter &nbsp;·&nbsp; Shift+click to multi-select rows
        </div>
    </div>
</div>

<!-- ======= ADD REGISTRATION MODAL =================================== -->
<div class="hr-modal-overlay" id="addRegModal">
    <div class="hr-modal" style="width:500px;">
        <div class="hr-modal__header">
            <span>Add Student to Semester</span>
            <button class="hr-modal__close" onclick="closeModal('addRegModal')" type="button">×</button>
        </div>
        <div class="hr-modal__body">

            <%-- -- Registration Period -- --%>
            <div class="hr-modal__section">Registration Period</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Academic Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddAcadYear" runat="server" CssClass="hr-form-select" />
                    <div class="hr-form-hint">The academic year this record belongs to.</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Semester <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddSemester" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Semester 1" />
                        <asp:ListItem Value="2" Text="Semester 2" />
                        <asp:ListItem Value="3" Text="Semester 3" />
                    </asp:DropDownList>
                    <div class="hr-form-hint">Which semester to enrol into.</div>
                </div>
            </div>

            <%-- -- Student -- --%>
            <div class="hr-modal__section">Student</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Registration Number <span class="req">*</span></label>
                <asp:TextBox ID="txtAddRegNo" runat="server" CssClass="hr-form-input" placeholder="e.g. 2023/HD01/0001U" MaxLength="30" />
                <div class="hr-form-hint">Must match exactly as it appears in student records.</div>
            </div>

            <%-- -- Enrolment Details -- --%>
            <div class="hr-modal__section">Enrolment Details</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Study Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddStudyYear" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="1" Text="Year 1" />
                        <asp:ListItem Value="2" Text="Year 2" />
                        <asp:ListItem Value="3" Text="Year 3" />
                        <asp:ListItem Value="4" Text="Year 4" />
                        <asp:ListItem Value="5" Text="Year 5" />
                    </asp:DropDownList>
                    <div class="hr-form-hint">Year of study in their programme.</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Residence Status</label>
                    <asp:DropDownList ID="ddlAddResidence" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Value="NON RESIDENT" Text="Non-Resident" />
                        <asp:ListItem Value="RESIDENT" Text="Resident (Halls)" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Initial Registration Status</label>
                <asp:DropDownList ID="ddlAddStatus" runat="server" CssClass="hr-form-select">
                    <asp:ListItem Value="REGISTERED"      Text="Registered - mark as already registered" Selected="True" />
                    <asp:ListItem Value="UNREGISTERED"    Text="Unregistered - pending student registration" />
                    <asp:ListItem Value="LATE REGISTERED" Text="Late Registered - registered after deadline" />
                </asp:DropDownList>
            </div>

            <div id="addRegResult" runat="server" class="hr-result" visible="false">
                <asp:Literal ID="litAddRegResult" runat="server" />
            </div>
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

<!-- ======= CHANGE STATUS MODAL ======================================= -->
<div class="hr-modal-overlay" id="changeStatusModal">
    <div class="hr-modal" style="width:460px;">
        <div class="hr-modal__header">
            <span>Change Registration Status</span>
            <button class="hr-modal__close" onclick="closeModal('changeStatusModal')" type="button">×</button>
        </div>
        <div class="hr-modal__body">
            <div class="rg-student-info" id="csStudentInfo">
                <div class="rg-student-info__item">
                    <span class="rg-student-info__label">Student</span>
                    <span class="rg-student-info__value" id="csStudentName">-</span>
                </div>
                <div class="rg-student-info__item">
                    <span class="rg-student-info__label">Reg No</span>
                    <span class="rg-student-info__value" id="csRegNo">-</span>
                </div>
                <div class="rg-student-info__item">
                    <span class="rg-student-info__label">Current Status</span>
                    <span class="rg-student-info__value" id="csCurrentStatus">-</span>
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">New Status <span class="req">*</span></label>
                <asp:DropDownList ID="ddlNewStatus" runat="server" CssClass="hr-form-select">
                    <asp:ListItem Value="UNREGISTERED"   Text="Unregistered" />
                    <asp:ListItem Value="REGISTERED"     Text="Registered" />
                    <asp:ListItem Value="LATE REGISTERED" Text="Late Registered" />
                    <asp:ListItem Value="CLEARED"        Text="Cleared" />
                    <asp:ListItem Value="DISCONTINUED"   Text="Discontinued" />
                    <asp:ListItem Value="HALTED"         Text="Halted" />
                    <asp:ListItem Value="DEAD YEAR"      Text="Dead Year" />
                </asp:DropDownList>
            </div>
            <asp:HiddenField ID="hdnCSID" runat="server" />
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeModal('changeStatusModal')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary" onclick="document.getElementById('<%= btnDoChangeStatus.ClientID %>').click()">
                Save Changes
            </button>
        </div>
    </div>
</div>

<!-- ======= TOAST NOTIFICATION ======================================== -->
<div id="regToast" class="rg-toast">
    <svg id="regToastIcon" xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
    <span id="regToastMsg"></span>
</div>

<!-- ======= REGISTER ALL MODAL ======================================= -->
<div class="hr-modal-overlay" id="registerAllModal">
    <div class="hr-modal" style="width:680px;">
        <div class="hr-modal__header">
            <span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:-2px;margin-right:6px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Register All Unregistered Students
            </span>
            <button class="hr-modal__close" onclick="closeRegisterAllModal()" type="button">&times;</button>
        </div>
        <div class="hr-modal__body" style="padding:16px;">

            <!-- Phase: Loading -->
            <div class="ra-phase" id="raPhase_loading" style="display:block;">
                <div class="ra-loading">
                    <div class="ra-loading__spinner"></div>
                    <div>Loading preview data&hellip;</div>
                </div>
            </div>

            <!-- Phase: Preview -->
            <div class="ra-phase" id="raPhase_preview">
                <div class="ra-summary">
                    <div class="ra-summary__item">
                        <div class="ra-summary__val" id="raTotalCount">0</div>
                        <div class="ra-summary__label">Students to Register</div>
                    </div>
                    <div class="ra-summary__item">
                        <div class="ra-summary__val" id="raAcadYear">-</div>
                        <div class="ra-summary__label">Academic Year</div>
                    </div>
                    <div class="ra-summary__item">
                        <div class="ra-summary__val" id="raSemester">-</div>
                        <div class="ra-summary__label">Semester</div>
                    </div>
                </div>

                <div class="ra-breakdowns">
                    <div class="ra-breakdown">
                        <div class="ra-breakdown__title">By Programme</div>
                        <div id="raProgBreakdown" style="max-height:150px;overflow-y:auto;"></div>
                    </div>
                    <div class="ra-breakdown">
                        <div class="ra-breakdown__title">By Study Year</div>
                        <div id="raYearBreakdown"></div>
                    </div>
                </div>

                <div style="margin-top:14px;">
                    <div style="font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;margin-bottom:6px;">Student Preview</div>
                    <div class="ra-table-wrap">
                        <table class="ra-table">
                            <thead><tr><th>#</th><th>Reg No</th><th>Name</th><th>Programme</th><th>Year</th></tr></thead>
                            <tbody id="raStudentRows"></tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Phase: Processing -->
            <div class="ra-phase" id="raPhase_processing">
                <div style="font-size:13px;font-weight:600;color:#1a1a2e;margin-bottom:10px;">
                    Processing registrations &amp; billing&hellip;
                </div>
                <div class="ra-progress-wrap">
                    <div class="ra-progress">
                        <div class="ra-progress__fill" id="raProgressFill" style="width:0%"></div>
                        <div class="ra-progress__text" id="raProgressText">0%</div>
                    </div>
                </div>
                <div class="ra-live-stats">
                    <div class="ra-live-stat">
                        <div class="ra-live-stat__val" id="raProcessed">0</div>
                        <div class="ra-live-stat__lbl">Processed</div>
                    </div>
                    <div class="ra-live-stat" style="border-bottom:none;">
                        <div class="ra-live-stat__val" style="color:#888;" id="raProcessTotal">0</div>
                        <div class="ra-live-stat__lbl">Total</div>
                    </div>
                    <div class="ra-live-stat ra-live-stat--ok">
                        <div class="ra-live-stat__val" id="raRegCount">0</div>
                        <div class="ra-live-stat__lbl">Registered</div>
                    </div>
                    <div class="ra-live-stat ra-live-stat--bill">
                        <div class="ra-live-stat__val" id="raBillCount">0</div>
                        <div class="ra-live-stat__lbl">Billed</div>
                    </div>
                    <div class="ra-live-stat ra-live-stat--err">
                        <div class="ra-live-stat__val" id="raErrCount">0</div>
                        <div class="ra-live-stat__lbl">Errors</div>
                    </div>
                </div>
                <div class="ra-log" id="raLog"></div>
            </div>

            <!-- Phase: Done -->
            <div class="ra-phase" id="raPhase_done">
                <div class="ra-done-wrap">
                    <div class="ra-done-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    </div>
                    <div class="ra-done-title">Registration Complete</div>
                    <div class="ra-done-sub">All students have been processed successfully.</div>
                </div>
                <div class="ra-live-stats">
                    <div class="ra-live-stat ra-live-stat--ok">
                        <div class="ra-live-stat__val" id="raDoneReg">0</div>
                        <div class="ra-live-stat__lbl">Registered</div>
                    </div>
                    <div class="ra-live-stat ra-live-stat--bill">
                        <div class="ra-live-stat__val" id="raDoneBill">0</div>
                        <div class="ra-live-stat__lbl">Billed</div>
                    </div>
                    <div class="ra-live-stat ra-live-stat--err">
                        <div class="ra-live-stat__val" id="raDoneErr">0</div>
                        <div class="ra-live-stat__lbl">Errors</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hr-modal__footer" id="raFooter">
            <button type="button" class="hr-btn hr-btn--ghost" id="raCancelBtn" onclick="closeRegisterAllModal()">Cancel</button>
            <button type="button" class="hr-btn" id="raConfirmBtn" disabled
                    style="background:#16a34a;color:#fff;border:none;" onclick="startRegisterAll()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Confirm &amp; Register All
            </button>
        </div>
    </div>
</div>

<script type="text/javascript">
// -- Search - Enter key triggers Search button ------------------------
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
});

// -- Action Popover ----------------------------------------------------
function closeAllActionPopovers() {
    document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p) {
        p.classList.remove('is-open');
    });
}
function toggleActionPopover(btn, e) {
    e.stopPropagation();
    var p = btn.nextElementSibling;
    if (!p) return;
    var wasOpen = p.classList.contains('is-open');
    closeAllActionPopovers();
    if (!wasOpen) p.classList.add('is-open');
}
document.addEventListener('click', function() { closeAllActionPopovers(); });

// -- Batch Toolbar --------------------------------------------------
function updateBatchBar() {
    var count = gvRegistration.GetSelectedRowCount();
    var bar   = document.getElementById('batchBar');
    var badge = document.getElementById('batchSelCount');
    if (count > 0) { bar.classList.add('show'); badge.textContent = count; }
    else            { bar.classList.remove('show'); }
}

// -- Batch Actions --------------------------------------------------
var _batchBtnMap = {
    'register'   : '<%= btnBatchRegister.ClientID %>',
    'late'       : '<%= btnBatchLateRegister.ClientID %>',
    'clear'      : '<%= btnBatchClear.ClientID %>',
    'undoreg'    : '<%= btnBatchUndoReg.ClientID %>',
    'undoclear'  : '<%= btnBatchUndoClear.ClientID %>',
    'discontinue': '<%= btnBatchDiscontinue.ClientID %>',
    'halt'       : '<%= btnBatchHalt.ClientID %>',
    'deadyear'   : '<%= btnBatchDeadYear.ClientID %>',
    'reactivate' : '<%= btnBatchReactivate.ClientID %>',
    'delete'     : '<%= btnBatchDelete.ClientID %>'
};
var _batchMsgs = {
    'register'   : 'Register selected students?',
    'late'       : 'Mark selected students as Late Registered?',
    'clear'      : 'Clear selected students for exams?',
    'undoreg'    : 'Undo registration for selected students?',
    'undoclear'  : 'Undo exam clearance for selected students?',
    'discontinue': 'DISCONTINUE selected students? This is significant and cannot be undone easily.',
    'halt'       : 'Halt registration for selected students?',
    'deadyear'   : 'Mark selected students as Dead Year?',
    'reactivate' : 'Reactivate selected students (reset to Unregistered)?',
    'delete'     : 'PERMANENTLY DELETE registration records for selected students? This cannot be undone!'
};
function doBatch(action) {
    var count = gvRegistration.GetSelectedRowCount();
    if (count === 0) { showToast(false, 'Please select at least one student.'); return; }
    var msg = _batchMsgs[action].replace('selected', count + ' selected');
    if (!confirm(msg)) return;
    document.getElementById(_batchBtnMap[action]).click();
}

// -- Stat-card quick filter ------------------------------------------
function filterByStatus(status) {
    var ddl = document.getElementById('<%= ddlRegStatus.ClientID %>');
    if (ddl) { ddl.value = status; __doPostBack('<%= ddlRegStatus.UniqueID %>', ''); }
}
function clearStatusFilter() {
    var ddl = document.getElementById('<%= ddlRegStatus.ClientID %>');
    if (ddl) { ddl.value = ''; __doPostBack('<%= ddlRegStatus.UniqueID %>', ''); }
}
function filterByBilling(status) {
    var ddl = document.getElementById('<%= ddlBilling.ClientID %>');
    if (ddl) { ddl.value = status; __doPostBack('<%= ddlBilling.UniqueID %>', ''); }
}

// -- Modals ---------------------------------------------------------
function openAddRegModal() {
    var err = document.getElementById('<%= addRegResult.ClientID %>');
    if (err) err.style.display = 'none';
    document.getElementById('addRegModal').classList.add('open');
}
function closeModal(id)    { document.getElementById(id).classList.remove('open'); }

function openChangeStatusModal(id, name, regno, status) {
    document.getElementById('csStudentName').textContent    = name;
    document.getElementById('csRegNo').textContent          = regno;
    document.getElementById('csCurrentStatus').textContent  = status;
    document.getElementById('<%= hdnCSID.ClientID %>').value = id;
    var ddl = document.getElementById('<%= ddlNewStatus.ClientID %>');
    if (ddl) ddl.value = status;
    document.getElementById('changeStatusModal').classList.add('open');
}

// Close modal on overlay click
document.addEventListener('click', function(e) {
    ['addRegModal','changeStatusModal','registerAllModal'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el && e.target === el) {
            if (id === 'registerAllModal') { closeRegisterAllModal(); }
            else { closeModal(id); }
        }
    });
});

// -- Toast ----------------------------------------------------------
function showToast(success, message) {
    var toast = document.getElementById('regToast');
    toast.className = 'rg-toast rg-toast--' + (success ? 'success' : 'error');
    document.getElementById('regToastMsg').textContent = message;
    setTimeout(function() { toast.classList.add('show'); }, 10);
    setTimeout(function() { toast.classList.remove('show'); }, 4500);
}

// -- Register All Modal (preview → process → done) -------------------
var _ra = { ids: [], total: 0, processed: 0, registered: 0, billed: 0, errors: 0, running: false };
var RA_BATCH = 15;

function openRegisterAllModal() {
    document.getElementById('registerAllModal').classList.add('open');
    showRaPhase('loading');
    _ra = { ids: [], total: 0, processed: 0, registered: 0, billed: 0, errors: 0, running: false };
    document.getElementById('raConfirmBtn').disabled = true;
    document.getElementById('raConfirmBtn').style.display = '';
    document.getElementById('raCancelBtn').textContent = 'Cancel';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', window.location.pathname + '?action=preview_register_all', true);
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) { raShowError(d.error); return; }
                populateRaPreview(d);
                showRaPhase('preview');
            } catch(e) { raShowError('Failed to parse server response.'); }
        } else { raShowError('Server error (' + xhr.status + '). Please try again.'); }
    };
    xhr.onerror = function() { raShowError('Network error. Check your connection.'); };
    xhr.send();
}

function populateRaPreview(d) {
    _ra.ids = d.ids;
    _ra.total = d.totalCount;
    document.getElementById('raTotalCount').textContent = d.totalCount.toLocaleString();
    document.getElementById('raAcadYear').textContent = d.acadYear;
    document.getElementById('raSemester').textContent = 'Sem ' + d.semester;

    // Programme breakdown
    var ph = '';
    d.byProgramme.forEach(function(p) {
        ph += '<div class="ra-breakdown__row"><span class="ra-breakdown__label">' + raEsc(p.p) + '</span><span class="ra-breakdown__count">' + p.c.toLocaleString() + '</span></div>';
    });
    document.getElementById('raProgBreakdown').innerHTML = ph || '<div style="color:#888;font-size:11px;">None</div>';

    // Year breakdown
    var yh = '';
    d.byYear.sort(function(a,b){return a.y - b.y;}).forEach(function(y) {
        yh += '<div class="ra-breakdown__row"><span class="ra-breakdown__label">Year ' + y.y + '</span><span class="ra-breakdown__count">' + y.c.toLocaleString() + '</span></div>';
    });
    document.getElementById('raYearBreakdown').innerHTML = yh || '<div style="color:#888;font-size:11px;">None</div>';

    // Student table
    var th = '';
    d.students.forEach(function(s, i) {
        th += '<tr><td>' + (i+1) + '</td><td style="font-weight:600;color:#05275C;">' + raEsc(s.r) + '</td><td>' + raEsc(s.n) + '</td><td>' + raEsc(s.p) + '</td><td>Year ' + s.y + '</td></tr>';
    });
    if (d.totalCount > d.students.length) {
        th += '<tr><td colspan="5" style="text-align:center;color:#888;font-style:italic;padding:8px;">… and ' + (d.totalCount - d.students.length).toLocaleString() + ' more students</td></tr>';
    }
    document.getElementById('raStudentRows').innerHTML = th;

    document.getElementById('raConfirmBtn').disabled = (d.totalCount === 0);
}

function startRegisterAll() {
    if (_ra.running || _ra.ids.length === 0) return;
    _ra.running = true;
    _ra.processed = 0; _ra.registered = 0; _ra.billed = 0; _ra.errors = 0;

    showRaPhase('processing');
    document.getElementById('raConfirmBtn').style.display = 'none';
    document.getElementById('raCancelBtn').textContent = 'Close (processing…)';
    document.getElementById('raProcessTotal').textContent = _ra.total.toLocaleString();
    document.getElementById('raProcessed').textContent = '0';
    document.getElementById('raRegCount').textContent = '0';
    document.getElementById('raBillCount').textContent = '0';
    document.getElementById('raErrCount').textContent = '0';
    raProgress(0);
    document.getElementById('raLog').innerHTML = '';
    raLog('info', 'Starting registration of ' + _ra.total.toLocaleString() + ' students in batches of ' + RA_BATCH + '…');
    processRaBatch();
}

function processRaBatch() {
    if (!_ra.running) { raLog('error', 'Processing cancelled.'); return; }
    if (_ra.processed >= _ra.total) { finishRegisterAll(); return; }

    var batch = _ra.ids.slice(_ra.processed, _ra.processed + RA_BATCH);
    var batchNum = Math.floor(_ra.processed / RA_BATCH) + 1;

    var xhr = new XMLHttpRequest();
    xhr.open('POST', window.location.pathname + '?action=register_batch', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) { raLog('error', 'Batch error: ' + d.error); _ra.running = false; showRaDoneBtn(); return; }

                _ra.processed += batch.length;
                _ra.registered += d.registered;
                _ra.billed += d.billed;
                _ra.errors += d.errors;

                document.getElementById('raProcessed').textContent = _ra.processed.toLocaleString();
                document.getElementById('raRegCount').textContent = _ra.registered.toLocaleString();
                document.getElementById('raBillCount').textContent = _ra.billed.toLocaleString();
                document.getElementById('raErrCount').textContent = _ra.errors.toLocaleString();

                var pct = Math.round(_ra.processed / _ra.total * 100);
                raProgress(pct);

                var msg = 'Batch ' + batchNum + ': ' + d.registered + ' registered, ' + d.billed + ' billed';
                if (d.errors > 0) {
                    msg += ', ' + d.errors + ' errors';
                    // Log first error detail
                    for (var ei = 0; ei < d.results.length; ei++) {
                        if (d.results[ei].s === 'error' && d.results[ei].m) {
                            raLog('error', 'ID ' + d.results[ei].id + ': ' + d.results[ei].m);
                            break;
                        }
                    }
                }
                raLog(d.errors > 0 ? 'error' : 'ok', msg);

                setTimeout(processRaBatch, 80);
            } catch(e) { raLog('error', 'Parse error: ' + e.message); _ra.running = false; showRaDoneBtn(); }
        } else { raLog('error', 'Server error (' + xhr.status + ')'); _ra.running = false; showRaDoneBtn(); }
    };
    xhr.onerror = function() { raLog('error', 'Network error.'); _ra.running = false; showRaDoneBtn(); };
    xhr.send(JSON.stringify({ ids: batch }));
}

function finishRegisterAll() {
    _ra.running = false;
    raLog('ok', 'Complete — ' + _ra.registered.toLocaleString() + ' registered, ' + _ra.billed.toLocaleString() + ' billed, ' + _ra.errors + ' errors.');
    raProgress(100);
    showRaPhase('done');
    document.getElementById('raDoneReg').textContent = _ra.registered.toLocaleString();
    document.getElementById('raDoneBill').textContent = _ra.billed.toLocaleString();
    document.getElementById('raDoneErr').textContent = _ra.errors.toLocaleString();
    showRaDoneBtn();
}

function showRaDoneBtn() {
    document.getElementById('raConfirmBtn').style.display = 'none';
    document.getElementById('raCancelBtn').textContent = 'Close & Refresh';
}

function closeRegisterAllModal() {
    if (_ra.running) {
        if (!confirm('Processing is in progress. Stop and close?')) return;
        _ra.running = false;
    }
    document.getElementById('registerAllModal').classList.remove('open');
    // Refresh page if any students were processed
    if (_ra.registered > 0 || _ra.processed > 0) {
        __doPostBack('<%= btnRefresh.UniqueID %>', '');
    }
}

function showRaPhase(phase) {
    ['loading','preview','processing','done'].forEach(function(p) {
        var el = document.getElementById('raPhase_' + p);
        if (el) el.style.display = (p === phase) ? 'block' : 'none';
    });
}

function raShowError(msg) {
    showRaPhase('preview');
    document.getElementById('raTotalCount').textContent = '0';
    document.getElementById('raAcadYear').textContent = '-';
    document.getElementById('raSemester').textContent = '-';
    document.getElementById('raProgBreakdown').innerHTML = '';
    document.getElementById('raYearBreakdown').innerHTML = '';
    document.getElementById('raStudentRows').innerHTML = '<tr><td colspan="5" style="text-align:center;color:#dc3545;padding:16px;">' + raEsc(msg) + '</td></tr>';
    document.getElementById('raConfirmBtn').disabled = true;
}

function raProgress(pct) {
    document.getElementById('raProgressFill').style.width = pct + '%';
    document.getElementById('raProgressText').textContent = pct + '%';
}

function raLog(type, msg) {
    var log = document.getElementById('raLog');
    var el = document.createElement('div');
    el.className = 'ra-log__entry ra-log__entry--' + type;
    var now = new Date();
    el.textContent = now.toLocaleTimeString() + ' — ' + msg;
    log.appendChild(el);
    log.scrollTop = log.scrollHeight;
}

function raEsc(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

// -- Billing progress bars ------------------------------------------
(function initBillingBars() {
    function update() {
        var heroEl = document.querySelector('.rg-stat--hero .rg-stat__val');
        if (!heroEl) return;
        var total = parseInt((heroEl.textContent || '0').replace(/[^0-9]/g, ''), 10) || 0;
        if (total <= 0) return;
        var pairs = [
            { barId: 'billedBar', selector: '.rg-stat--teal .rg-stat__val' },
            { barId: 'notBilledBar', selector: '.rg-stat--brown .rg-stat__val' }
        ];
        for (var i = 0; i < pairs.length; i++) {
            var bar = document.getElementById(pairs[i].barId);
            var valEl = document.querySelector(pairs[i].selector);
            if (bar && valEl) {
                var v = parseInt((valEl.textContent || '0').replace(/[^0-9]/g, ''), 10) || 0;
                bar.style.width = Math.round(v / total * 100) + '%';
            }
        }
    }
    if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', update); }
    else { setTimeout(update, 50); }
    if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() { setTimeout(update, 50); });
    }
})();
</script>

</asp:Content>