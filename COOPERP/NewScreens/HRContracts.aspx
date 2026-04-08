<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HRContracts.aspx.cs" Inherits="COOPERP_NewScreens_HRContracts" Title="Contract Management - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== CONTRACT MANAGEMENT - RESPONSIVE ===== */

/* -- Page Header --------------------------------------- */
.ct-page-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 12px 0 10px; margin-bottom: 14px;
    border-bottom: 2px solid #174DA4;
    flex-wrap: wrap; gap: 8px;
}
.ct-page-header__left { display: flex; align-items: center; gap: 10px; min-width: 0; }
.ct-page-header__icon {
    width: 36px; height: 36px; background: #174DA4;
    display: flex; align-items: center; justify-content: center;
    border-radius: 6px; flex-shrink: 0;
}
.ct-page-header__title { font-size: 16px; font-weight: 700; color: #1a1a2e; margin: 0; line-height: 1.2; }
.ct-page-header__sub   { font-size: 11px; color: #888; margin-top: 1px; }

/* -- Stats Row ----------------------------------------- */
.ct-stats {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 8px; margin-bottom: 12px;
}
.ct-stat {
    background: #fff; border: 1px solid #e4e8f0;
    padding: 10px 14px; display: flex; align-items: center; gap: 10px;
    border-radius: 6px;
    transition: box-shadow .15s, transform .15s;
    cursor: default;
}
.ct-stat:hover { box-shadow: 0 3px 12px rgba(23,77,164,.10); transform: translateY(-1px); }
.ct-stat__icon { width: 34px; height: 34px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 6px; }
.ct-stat__body { min-width: 0; }
.ct-stat__val  { font-size: 20px; font-weight: 700; line-height: 1.1; }
.ct-stat__label{ font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 1px; white-space: nowrap; }
.ct-stat--blue  .ct-stat__icon { background: #e8f0fc; } .ct-stat--blue  .ct-stat__val { color: #174DA4; }
.ct-stat--green .ct-stat__icon { background: #e6f4ea; } .ct-stat--green .ct-stat__val { color: #28a745; }
.ct-stat--red   .ct-stat__icon { background: #fdecea; } .ct-stat--red   .ct-stat__val { color: #dc3545; }
.ct-stat--amber .ct-stat__icon { background: #fff8e1; } .ct-stat--amber .ct-stat__val { color: #e67e00; }
.ct-stat--grey  .ct-stat__icon { background: #f0f0f0; } .ct-stat--grey  .ct-stat__val { color: #555; }

/* -- Expiry Banner ------------------------------------- */
.ct-banner {
    display: flex; align-items: center; gap: 10px;
    background: #fff8e1; border: 1px solid #ffe082; border-left: 4px solid #ffc107;
    padding: 9px 14px; font-size: 11px; color: #6d4c00;
    margin-bottom: 10px; border-radius: 0 6px 6px 0;
}
.ct-banner svg { flex-shrink: 0; }
.ct-banner strong { color: #b45309; }
.ct-banner a { color: #174DA4; font-weight: 600; text-decoration: none; margin-left: 6px; }
.ct-banner a:hover { text-decoration: underline; }

/* -- Card ---------------------------------------------- */
.cd-card { background: #fff; border: 1px solid #e4e8f0; margin-bottom: 12px; border-radius: 6px; overflow: hidden; }
.cd-card__header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 9px 14px; border-bottom: 1px solid #e4e8f0; background: #fafbfc;
    flex-wrap: wrap; gap: 6px;
}
.cd-card__title { font-size: 13px; font-weight: 700; color: #1a1a1a; display: flex; align-items: center; gap: 7px; }
.cd-card__meta  { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.08); padding: 3px 10px; border-radius: 10px; white-space: nowrap; }

/* -- Filter Bar ---------------------------------------- */
.ct-filters { background: #f8f9fa; border-bottom: 1px solid #e4e8f0; padding: 8px 12px; }
.ct-filters__top {
    display: flex; align-items: center; gap: 6px;
    margin-bottom: 7px; flex-wrap: wrap;
}
.ct-search-wrap { position: relative; flex: 1; min-width: 160px; max-width: 320px; }
.ct-search-wrap svg { position: absolute; left: 9px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.ct-search-box {
    width: 100%; padding: 6px 10px 6px 30px;
    border: 1px solid #ddd; border-radius: 6px;
    font-size: 12px; background: #fff;
    transition: border-color .15s, box-shadow .15s;
    box-sizing: border-box;
}
.ct-search-box:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.ct-search-box::placeholder { color: #aaa; }
.ct-filters__count {
    font-size: 11px; color: #174DA4; font-weight: 600; white-space: nowrap;
    background: rgba(23,77,164,.08); padding: 4px 11px; border-radius: 10px;
    margin-left: auto;
}
.ct-filters__row { display: flex; gap: 8px; flex-wrap: wrap; align-items: flex-end; }
.ct-filter-grp { display: flex; flex-direction: column; gap: 2px; }
.ct-filter-grp__label {
    font-size: 9px; color: #888; text-transform: uppercase;
    letter-spacing: .4px; font-weight: 600;
}
.ct-filter-select {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    transition: border-color .15s, box-shadow .15s;
    cursor: pointer; min-width: 110px;
}
.ct-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.ct-filter-sep { width: 1px; height: 32px; background: #e0e0e0; align-self: flex-end; margin: 0 2px; }

/* -- Buttons ------------------------------------------- */
.hr-btn {
    padding: 6px 13px; font-size: 11px; font-weight: 600;
    border: none; cursor: pointer; border-radius: 6px;
    display: inline-flex; align-items: center; gap: 5px;
    white-space: nowrap; line-height: 1.4;
    transition: background .15s, box-shadow .15s, transform .1s;
}
.hr-btn:active { transform: scale(.97); }
.hr-btn--primary { background: #174DA4; color: #fff; }  .hr-btn--primary:hover { background: #0f3a7d; box-shadow: 0 2px 8px rgba(23,77,164,.25); }
.hr-btn--success { background: #28a745; color: #fff; }  .hr-btn--success:hover { background: #218838; }
.hr-btn--danger  { background: #dc3545; color: #fff; }  .hr-btn--danger:hover  { background: #c82333; }
.hr-btn--outline { background: #fff; color: #174DA4; border: 1px solid #174DA4; } .hr-btn--outline:hover { background: #174DA4; color: #fff; }
.hr-btn--ghost   { background: transparent; color: #555; border: 1px solid #ddd; } .hr-btn--ghost:hover { border-color: #174DA4; color: #174DA4; background: rgba(23,77,164,.04); }
.hr-btn--amber   { background: #e67e00; color: #fff; }  .hr-btn--amber:hover  { background: #b45309; }
.hr-btn--sm      { padding: 5px 11px; font-size: 10px; }

/* -- Badges -------------------------------------------- */
.hr-badge { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; border-radius: 3px; }
.hr-badge--valid      { background: #d4edda; color: #155724; }
.hr-badge--expired    { background: #f8d7da; color: #721c24; }
.hr-badge--terminated { background: #e2e3e5; color: #383d41; }
.hr-badge--resigned   { background: #fff3cd; color: #856404; }
.hr-badge--none       { background: #e9ecef; color: #6c757d; }

/* -- Contract type badge ------------------------------- */
.ct-type { display: inline-block; padding: 2px 7px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; border-radius: 3px; }
.ct-type--full     { background: #e8f0fc; color: #174DA4; }
.ct-type--part     { background: #fff3cd; color: #856404; }
.ct-type--contract { background: #e2e3e5; color: #383d41; }
.ct-type--temp     { background: #fce8f0; color: #9b1d5a; }

/* -- Days remaining pill ------------------------------- */
.ct-days { display: inline-flex; align-items: center; gap: 3px; padding: 2px 7px; font-size: 10px; font-weight: 700; border-radius: 3px; }
.ct-days--ok     { background: #d4edda; color: #155724; }
.ct-days--warn   { background: #fff3cd; color: #856404; }
.ct-days--urgent { background: #f8d7da; color: #721c24; }
.ct-days--over   { background: #dc3545; color: #fff; }
.ct-days--na     { color: #bbb; font-size: 10px; }

/* -- Row colouring ------------------------------------- */
.ct-row-valid    td { background: #fff    !important; }
.ct-row-expiring td { background: #fffdf0 !important; }
.ct-row-expired  td { background: #fff6f6 !important; }
.ct-row-other    td { background: #fafafa !important; }

/* -- Batch Toolbar ------------------------------------- */
.ct-batch-toolbar {
    display: none; align-items: center; gap: 8px; flex-wrap: wrap;
    padding: 8px 14px; background: #fffbe6;
    border-top: 1px solid #ffe082; border-bottom: 2px solid #ffc107;
}
.ct-batch-info  { display: flex; align-items: center; gap: 5px; font-size: 11px; color: #6d4c00; white-space: nowrap; }
.ct-batch-info strong { font-size: 13px; font-weight: 700; color: #b45309; }
.ct-batch-sep   { width: 1px; height: 24px; background: #e0c060; margin: 0 2px; flex-shrink: 0; }
.ct-batch-status-wrap { display: flex; align-items: center; gap: 5px; }
.ct-row-check   { cursor: pointer; width: 14px; height: 14px; accent-color: #174DA4; vertical-align: middle; }

/* -- Action popover ------------------------------------ */
.cd-action-wrapper { position: relative; display: inline-block; }
.cd-action-trigger {
    background: none; border: 1px solid #ddd; border-radius: 5px;
    padding: 3px 7px; cursor: pointer; color: #555;
    display: inline-flex; align-items: center;
    transition: border-color .15s, background .15s;
}
.cd-action-trigger:hover { border-color: #174DA4; color: #174DA4; background: #f0f4ff; }
.cd-action-popover {
    display: none; position: absolute; right: 0; top: calc(100% + 2px);
    z-index: 9999; background: #fff; border: 1px solid #e4e8f0;
    border-radius: 6px; box-shadow: 0 6px 20px rgba(0,0,0,.13); min-width: 170px;
}
.cd-action-popover.is-open { display: block; }
.cd-action-popover__menu   { list-style: none; margin: 0; padding: 4px 0; }
.cd-action-popover__item   { margin: 0; }
.cd-action-popover__btn    {
    width: 100%; background: none; border: none; padding: 7px 14px;
    font-size: 11px; color: #333; cursor: pointer;
    display: flex; align-items: center; gap: 8px; text-align: left;
    transition: background .12s;
}
.cd-action-popover__btn:hover                 { background: #f0f4ff; color: #174DA4; }
.cd-action-popover__btn--danger:hover         { background: #fdecea; color: #dc3545; }
.cd-action-popover__btn--success:hover        { background: #e6f4ea; color: #28a745; }
.cd-action-popover__divider                   { height: 1px; background: #f0f0f0; margin: 3px 0; }

/* -- Modal --------------------------------------------- */
.hr-modal-overlay {
    display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,.48); z-index: 10000;
    align-items: center; justify-content: center;
    padding: 16px; box-sizing: border-box;
}
.hr-modal {
    background: #fff; width: 600px; max-width: 100%;
    max-height: calc(100vh - 32px); overflow: hidden;
    border-radius: 8px;
    box-shadow: 0 16px 48px rgba(0,0,0,.25);
    display: flex; flex-direction: column;
    animation: modalIn .18s ease;
}
@keyframes modalIn { from { opacity: 0; transform: translateY(-12px) scale(.98); } to { opacity: 1; transform: none; } }
.hr-modal__header {
    background: #174DA4; color: #fff; padding: 11px 16px;
    font-size: 13px; font-weight: 700;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0; border-radius: 8px 8px 0 0;
}
.hr-modal__close { background: none; border: none; color: rgba(255,255,255,.8); font-size: 22px; cursor: pointer; line-height: 1; padding: 0 2px; transition: color .15s; }
.hr-modal__close:hover { color: #fff; }
.hr-modal__body  { padding: 16px; flex: 1; overflow-y: auto; }
.hr-modal__footer{
    padding: 10px 16px; border-top: 1px solid #e4e8f0;
    display: flex; justify-content: flex-end; gap: 8px;
    flex-shrink: 0; background: #fafbfc; border-radius: 0 0 8px 8px;
}
.hr-modal__section {
    font-size: 9px; text-transform: uppercase; letter-spacing: .6px;
    color: #174DA4; font-weight: 700; padding: 6px 0 4px;
    border-bottom: 1px solid #e8ecf4; margin-bottom: 8px; margin-top: 14px;
}
.hr-modal__section:first-child { margin-top: 0; }

/* -- Form ---------------------------------------------- */
.hr-form-group  { margin-bottom: 10px; }
.hr-form-label  { display: block; font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #555; font-weight: 600; margin-bottom: 3px; }
.hr-form-label .req { color: #dc3545; margin-left: 2px; }
.hr-form-input,
.hr-form-select,
.hr-form-textarea {
    width: 100%; padding: 6px 9px; border: 1px solid #ccc;
    border-radius: 5px; font-size: 12px; box-sizing: border-box; background: #fff;
    transition: border-color .15s, box-shadow .15s;
}
.hr-form-input:focus,
.hr-form-select:focus,
.hr-form-textarea:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.hr-form-row  { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.hr-form-row3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.hr-form-hint { font-size: 10px; color: #888; margin-top: 2px; }
.hr-result      { margin-top: 8px; font-size: 12px; padding: 7px 11px; display: none; border-radius: 5px; }
.hr-result--err { background: #fdecea; color: #b91c1c; border-left: 3px solid #dc3545; display: block; }
.hr-result--ok  { background: #e6f4ea; color: #155724; border-left: 3px solid #28a745; display: block; }

/* -- Radio group --------------------------------------- */
.ct-radio-group  { display: flex; gap: 16px; padding: 4px 0; }
.ct-radio-option { display: flex; align-items: center; gap: 6px; font-size: 12px; cursor: pointer; }
.ct-radio-option input[type=radio] { cursor: pointer; accent-color: #174DA4; width: 14px; height: 14px; }

/* -- Data Table ---------------------------------------- */
.ct-grid { width: 100%; border-collapse: collapse; font-size: 11px; }
.ct-grid th {
    padding: 7px 9px; border-bottom: 2px solid #e4e8f0;
    font-size: 9px; text-transform: uppercase; letter-spacing: .4px;
    color: #555; font-weight: 700; background: #f5f7fa; white-space: nowrap;
}
.ct-grid td {
    padding: 7px 9px; border-bottom: 1px solid #f0f2f5;
    vertical-align: middle; color: #333;
}
.ct-grid tr:hover td { background: #f3f6ff !important; }
.ct-grid .ct-col-chk  { width: 30px; text-align: center; }
.ct-grid .ct-col-num  { width: 36px; color: #bbb; font-size: 10px; text-align: right; }
.ct-grid .ct-col-date { white-space: nowrap; }
.ct-grid .ct-col-days { white-space: nowrap; text-align: center; }
.ct-grid .ct-col-pay  { white-space: nowrap; }
.ct-grid .ct-col-actions { width: 40px; text-align: center; }
.ct-emp-code  { font-size: 10px; font-weight: 700; color: #174DA4; font-family: monospace; }
.ct-emp-name  { font-weight: 600; color: #1a1a1a; }
.ct-scale-name{ font-size: 9px; color: #888; }

/* -- Grid footer bar ----------------------------------- */
.ct-grid-footer {
    display: flex; align-items: center; justify-content: space-between;
    padding: 8px 13px; border-top: 1px solid #e4e8f0;
    background: #fafbfc; flex-wrap: wrap; gap: 6px;
}
.ct-pager-info { font-size: 11px; color: #555; }

/* -- Pagination ---------------------------------------- */
.ct-pager { display: flex; align-items: center; gap: 3px; flex-wrap: wrap; }
.ct-pager__item {
    display: inline-flex; align-items: center; justify-content: center;
    min-width: 28px; height: 26px; padding: 0 6px;
    border: 1px solid #e0e5ed; background: #fff; color: #333;
    font-size: 11px; text-decoration: none; cursor: pointer;
    border-radius: 4px; transition: background .12s, border-color .12s;
}
.ct-pager__item:hover              { background: #eef2fb; border-color: #174DA4; color: #174DA4; }
.ct-pager__item--active            { background: #174DA4; color: #fff; border-color: #174DA4; cursor: default; }
.ct-pager__item--disabled          { color: #ccc; cursor: not-allowed; background: #f9f9f9; }
.ct-pager__ellipsis                { color: #aaa; font-size: 11px; padding: 0 2px; }

/* -- RESPONSIVE ---------------------------------------- */
@media (max-width: 1100px) {
    .ct-stats { grid-template-columns: repeat(3, 1fr); }
    .ct-stat:last-child { grid-column: span 3; }
}
@media (max-width: 900px) {
    .ct-stats { grid-template-columns: repeat(3, 1fr); }
    .ct-stat:last-child { grid-column: auto; }
    .ct-filters__count { display: none; }
}
@media (max-width: 700px) {
    .ct-stats { grid-template-columns: 1fr 1fr; }
    .ct-stat:nth-child(5) { grid-column: span 2; }
    .ct-page-header { flex-direction: column; align-items: flex-start; }
    .ct-page-header .hr-btn { align-self: flex-start; }
    .ct-filters__top { flex-wrap: wrap; }
    .ct-search-wrap { max-width: 100%; min-width: 0; flex: 1 1 200px; }
    .ct-filter-grp { flex: 1 1 140px; }
    .ct-filter-select { min-width: 0; width: 100%; }
    .ct-filter-sep { display: none; }
    .ct-batch-toolbar { justify-content: flex-start; }
    .hr-form-row { grid-template-columns: 1fr; }
    .hr-form-row3 { grid-template-columns: 1fr; }
    .hr-modal { max-height: 100vh; border-radius: 0; }
    .hr-modal-overlay { padding: 0; align-items: flex-end; }
    .hr-modal__header { border-radius: 0; }
    .hr-modal__footer { border-radius: 0; }
}
@media (max-width: 480px) {
    .ct-stats { grid-template-columns: 1fr 1fr; }
    .ct-stat:nth-child(5) { grid-column: span 2; }
    .ct-stat__val { font-size: 16px; }
    .ct-batch-toolbar .hr-btn { flex: 1 1 auto; justify-content: center; }
    .hr-modal__footer { flex-direction: column-reverse; }
    .hr-modal__footer .hr-btn { width: 100%; justify-content: center; }
}

/* -- Employee Autocomplete ----------------------------- */
.hr-ac { position: relative; }
.hr-ac__input { width: 100%; border: 1px solid #ccc; padding: 7px 32px 7px 10px; font-size: 12px; color: #1a1a2e; background: #fff; box-sizing: border-box; border-radius: 5px; transition: border-color .15s, box-shadow .15s; }
.hr-ac__input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.10); }
.hr-ac__input--selected { border-color: #28a745; background: #f0fdf4; }
.hr-ac__spinner { display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px; border: 2px solid #e0e5ed; border-top-color: #174DA4; border-radius: 50%; animation: hrSpin .6s linear infinite; }
.hr-ac__spinner--visible { display: block; }
@keyframes hrSpin { to { transform: translateY(-50%) rotate(360deg); } }
.hr-ac__clear { display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); width: 18px; height: 18px; border: none; background: #dc3545; color: #fff; font-size: 13px; line-height: 1; cursor: pointer; align-items: center; justify-content: center; border-radius: 3px; transition: background .15s; }
.hr-ac__clear--visible { display: flex; }
.hr-ac__clear:hover { background: #c82333; }
.hr-ac__list { display: none; position: absolute; left: 0; right: 0; top: calc(100% + 2px); z-index: 9999; background: #fff; border: 1px solid #174DA4; border-radius: 5px; max-height: 260px; overflow-y: auto; box-shadow: 0 10px 30px rgba(0,0,0,.18); }
.hr-ac__list--visible { display: block; }
.hr-ac__item { padding: 9px 12px; cursor: pointer; border-bottom: 1px solid #f0f2f5; display: flex; align-items: center; gap: 10px; transition: background .1s; }
.hr-ac__item:last-child { border-bottom: none; }
.hr-ac__item:hover { background: #e8f0fc; }
.hr-ac__item--active { background: #dbeafe; border-left: 2px solid #174DA4; padding-left: 10px; }
.hr-ac__avatar { width: 34px; height: 34px; background: #174DA4; color: #fff; font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; letter-spacing: .5px; border-radius: 4px; }
.hr-ac__info { flex: 1; min-width: 0; }
.hr-ac__name { font-size: 12px; font-weight: 700; color: #1a1a2e; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.hr-ac__name mark { background: #fff3cd; color: #1a1a2e; padding: 0 2px; font-weight: 700; border-radius: 1px; }
.hr-ac__meta { font-size: 10px; color: #888; margin-top: 1px; }
.hr-ac__code { font-size: 10px; font-weight: 600; color: #174DA4; white-space: nowrap; }
.hr-ac__code mark { background: #fff3cd; color: #174DA4; padding: 0 2px; font-weight: 700; }
.hr-ac__empty { padding: 14px 12px; text-align: center; font-size: 12px; color: #999; }
.hr-ac__hint { padding: 5px 12px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 9px; color: #999; text-align: center; }

/* Selected employee card */
.hr-selected-emp { display: none; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 5px; padding: 10px 12px; margin-top: 6px; }
.hr-selected-emp--visible { display: flex; align-items: center; gap: 10px; animation: empSlide .2s ease; }
@keyframes empSlide { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: translateY(0); } }
.hr-selected-emp__avatar { width: 36px; height: 36px; background: #174DA4; color: #fff; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 4px; }
.hr-selected-emp__info { flex: 1; min-width: 0; }
.hr-selected-emp__name { font-size: 12px; font-weight: 700; color: #174DA4; line-height: 1.2; }
.hr-selected-emp__detail { font-size: 10px; color: #555; margin-top: 1px; }
.hr-selected-emp__code { font-size: 10px; font-weight: 700; color: #28a745; background: #dcfce7; padding: 2px 8px; white-space: nowrap; border-radius: 3px; }

/* -- Searchable Select Wrapper ------------------------- */
.cd-srch { position: relative; }
.cd-srch__input { width: 100%; padding: 6px 28px 6px 9px; border: 1px solid #ccc; border-radius: 5px; font-size: 12px; box-sizing: border-box; background: #fff; transition: border-color .15s, box-shadow .15s; }
.cd-srch__input:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.cd-srch__input--has-value { font-weight: 600; color: #1a1a2e; }
.cd-srch__arrow { position: absolute; right: 8px; top: 50%; transform: translateY(-50%); pointer-events: none; color: #999; font-size: 10px; }
.cd-srch__panel { display: none; position: absolute; left: 0; right: 0; top: calc(100% + 2px); z-index: 9999; background: #fff; border: 1px solid #174DA4; border-radius: 5px; max-height: 220px; overflow-y: auto; box-shadow: 0 8px 24px rgba(0,0,0,.15); }
.cd-srch__panel--open { display: block; }
.cd-srch__opt { padding: 7px 10px; cursor: pointer; font-size: 12px; color: #333; transition: background .1s; border-bottom: 1px solid #f5f5f5; }
.cd-srch__opt:last-child { border-bottom: none; }
.cd-srch__opt:hover, .cd-srch__opt--active { background: #e8f0fc; color: #174DA4; }
.cd-srch__opt--selected { font-weight: 700; color: #174DA4; background: #f0f4ff; }
.cd-srch__opt mark { background: #fff3cd; padding: 0 1px; border-radius: 1px; }
.cd-srch__empty { padding: 12px 10px; font-size: 11px; color: #999; text-align: center; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Hidden server-side controls -->
<asp:HiddenField ID="hdnBatchIDs"       runat="server" />
<asp:HiddenField ID="hdnBatchStatus"    runat="server" />
<asp:HiddenField ID="hdnRenewContractID" runat="server" />
<asp:HiddenField ID="hdnRenewEmpID"      runat="server" />
<asp:HiddenField ID="hdnEditContractID"  runat="server" />
<asp:HiddenField ID="hdnDeleteContractID" runat="server" />
<asp:HiddenField ID="hfSelectedEmpID"     runat="server" />
<asp:Button ID="btnBatchDelete"     runat="server" style="display:none;" OnClick="btnBatchDelete_Click" />
<asp:Button ID="btnBatchExpire"     runat="server" style="display:none;" OnClick="btnBatchExpire_Click" />
<asp:Button ID="btnBatchStatus"     runat="server" style="display:none;" OnClick="btnBatchStatus_Click" />
<asp:Button ID="btnUpdateContract"  runat="server" style="display:none;" OnClick="btnUpdateContract_Click" />
<asp:Button ID="btnDeleteContract"  runat="server" style="display:none;" OnClick="btnDeleteContract_Click" />

<!-- Page Header -->
<div class="ct-page-header">
    <div class="ct-page-header__left">
        <div class="ct-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <div>
            <div class="ct-page-header__title">Employment Contracts</div>
            <div class="ct-page-header__sub">Manage staff contracts, pay scales and contract status</div>
        </div>
    </div>
    <button type="button" class="hr-btn hr-btn--primary" onclick="openAddModal()">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        New Contract
    </button>
</div>

<!-- Stats -->
<div class="ct-stats">
    <div class="ct-stat ct-stat--blue">
        <div class="ct-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Total Contracts</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--green">
        <div class="ct-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litStatValid" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Valid</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--amber">
        <div class="ct-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litStatExpiring" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Expiring (90d)</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--red">
        <div class="ct-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litStatExpired" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Expired</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--grey">
        <div class="ct-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#555" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg></div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litStatNoContract" runat="server" Text="0" /></div>
            <div class="ct-stat__label">No Contract</div>
        </div>
    </div>
</div>

<!-- Expiry Banner (rendered by server) -->
<asp:Literal ID="litExpiryBanner" runat="server" />

<!-- Contracts Grid Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            Contract Records
        </div>
        <span class="cd-card__meta"><asp:Literal ID="litTotalCount" runat="server" Text="0" /> record(s)</span>
    </div>

    <!-- Filter bar (GET-based, no PostBack) -->
    <div class="ct-filters">
        <div class="ct-filters__top">
            <div class="ct-search-wrap">
                <svg class="ct-search-wrap__icon" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-search-box" placeholder="Search by name or staff code..." />
            </div>
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="applyFilters()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                Search
            </button>
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="resetFilters()">Reset</button>
        </div>
        <div class="ct-filters__row">
            <div class="ct-filter-grp">
                <span class="ct-filter-grp__label">Status</span>
                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="ct-filter-select" />
            </div>
            <div class="ct-filter-grp">
                <span class="ct-filter-grp__label">Type</span>
                <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="ct-filter-select" />
            </div>
            <div class="ct-filter-grp">
                <span class="ct-filter-grp__label">Department</span>
                <asp:DropDownList ID="ddlFilterDept" runat="server" CssClass="ct-filter-select" />
            </div>
            <div class="ct-filter-grp">
                <span class="ct-filter-grp__label">Position</span>
                <asp:DropDownList ID="ddlFilterJob" runat="server" CssClass="ct-filter-select" />
            </div>
            <div class="ct-filter-sep"></div>
            <div class="ct-filter-grp">
                <span class="ct-filter-grp__label">Per Page</span>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ct-filter-select" style="min-width:90px;" />
            </div>
        </div>
    </div>
    <!-- Batch toolbar -->
    <div class="ct-batch-toolbar" id="batchToolbar">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        <div class="ct-batch-info"><strong id="batchCount">0</strong> selected</div>
        <div class="ct-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--amber hr-btn--sm" onclick="doBatchExpire()">
            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            Mark Expired
        </button>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatchDelete()">
            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
            Delete Selected
        </button>
        <div class="ct-batch-sep"></div>
        <div class="ct-batch-status-wrap">
            <select id="ddlBatchStatus" class="ct-filter-select" style="height:28px;font-size:11px;padding:0 6px;border:1px solid #d0b060;border-radius:3px;background:#fff;">
                <option value="">-- Set Status --</option>
                <option value="VALID">VALID</option>
                <option value="EXPIRED">EXPIRED</option>
                <option value="TERMINATED">TERMINATED</option>
                <option value="RESIGNED">RESIGNED</option>
            </select>
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="doBatchStatus()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                Apply Status
            </button>
        </div>
        <div class="ct-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="clearBatchSelection()">Clear</button>
    </div>

    <!-- Contracts table -->
    <div style="overflow-x:auto;-webkit-overflow-scrolling:touch;">
        <table class="ct-grid">
            <thead>
                <tr>
                    <th class="ct-col-chk"><input type="checkbox" id="chkSelectAll" onclick="toggleSelectAll(this)" title="Select/deselect all" style="cursor:pointer;accent-color:#174DA4;width:14px;height:14px;" /></th>
                    <th class="ct-col-num">#</th>
                    <th>Employee</th>
                    <th>Department</th>
                    <th>Position</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Start</th>
                    <th>End</th>
                    <th class="ct-col-days">Days Left</th>
                    <th class="ct-col-pay">Pay</th>
                    <th class="ct-col-actions"></th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litGridBody" runat="server" />
            </tbody>
        </table>
    </div>
    <!-- Grid footer -->
    <div class="ct-grid-footer">
        <div class="ct-pager-info"><asp:Literal ID="litPagerInfo" runat="server" /></div>
        <asp:Literal ID="litPager" runat="server" />
    </div>
</div><!-- end cd-card -->
<!-- ===== ADD CONTRACT MODAL ===== -->
<div class="hr-modal-overlay" id="addModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:5px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
                Create New Contract
            </span>
            <button type="button" class="hr-modal__close" onclick="closeAddModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="hr-modal__section">Employee</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Employee <span class="req">*</span></label>
                <div class="hr-ac" id="acEmpWrap">
                    <input type="text" class="hr-ac__input" id="acEmpInput" placeholder="Type name or staff code..." autocomplete="off" />
                    <div class="hr-ac__spinner" id="acEmpSpinner"></div>
                    <button type="button" class="hr-ac__clear" id="acEmpClear">&times;</button>
                    <div class="hr-ac__list" id="acEmpList"></div>
                </div>
                <div class="hr-selected-emp" id="selectedEmpCard">
                    <div class="hr-selected-emp__avatar" id="empAvatar"></div>
                    <div class="hr-selected-emp__info">
                        <div class="hr-selected-emp__name" id="empName"></div>
                        <div class="hr-selected-emp__detail" id="empPosition"></div>
                    </div>
                    <span class="hr-selected-emp__code" id="empCode"></span>
                </div>
            </div>

            <div class="hr-modal__section">Contract Details</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Contract Type <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlContractType" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="FULL TIME"   Value="FULL TIME"   Selected="True" />
                        <asp:ListItem Text="PART TIME"   Value="PART TIME" />
                        <asp:ListItem Text="CONTRACT"    Value="CONTRACT" />
                        <asp:ListItem Text="TEMPORARY"   Value="TEMPORARY" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtContractStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">End Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtContractEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                    <div class="hr-form-hint" id="contractDurationHint"></div>
                </div>
            </div>

            <div class="hr-modal__section">Position &amp; Department</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Position <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlContractJob" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Department <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlContractDept" runat="server" CssClass="hr-form-select" />
                </div>
            </div>

            <div class="hr-modal__section">Compensation</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Pay Scale <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlContractScale" runat="server" CssClass="hr-form-select" />
                    <div class="hr-form-hint">Select the employee pay scale</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Fixed Amount</label>
                    <asp:TextBox ID="txtContractFixed" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                    <div class="hr-form-hint">Applied only when no pay scale is selected</div>
                </div>
            </div>

            <div class="hr-modal__section">Notes</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Comments</label>
                <asp:TextBox ID="txtContractComment" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" placeholder="Optional notes..." />
            </div>

            <div id="addResult" class="hr-result"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeAddModal()">Cancel</button>
            <asp:Button ID="btnAddContract" runat="server" Text="Create Contract" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnAddContract_Click"
                OnClientClick="return validateAddModal();" />
        </div>
    </div>
</div>

<!-- ===== RENEW CONTRACT MODAL ===== -->
<div class="hr-modal-overlay" id="renewModal">
    <div class="hr-modal" style="width:500px;">
        <div class="hr-modal__header">
            <span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:5px;"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
                Renew Contract
            </span>
            <button type="button" class="hr-modal__close" onclick="closeRenewModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="renewEmpInfo" style="background:#f0f4ff;border-left:3px solid #174DA4;padding:9px 13px;font-size:12px;margin-bottom:14px;color:#1a1a1a;border-radius:0 5px 5px 0;"></div>

            <div class="hr-modal__section">Contract Type</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Type <span class="req">*</span></label>
                <asp:DropDownList ID="ddlRenewType" runat="server" CssClass="hr-form-select">
                    <asp:ListItem Text="FULL TIME"  Value="FULL TIME" />
                    <asp:ListItem Text="PART TIME"  Value="PART TIME" />
                    <asp:ListItem Text="CONTRACT"   Value="CONTRACT" />
                    <asp:ListItem Text="TEMPORARY"  Value="TEMPORARY" />
                </asp:DropDownList>
            </div>

            <div class="hr-modal__section">New Contract Period</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtRenewStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">End Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtRenewEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                    <div class="hr-form-hint" id="renewDurationHint"></div>
                </div>
            </div>
            <div id="renewResult" class="hr-result"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeRenewModal()">Cancel</button>
            <asp:Button ID="btnRenewContract" runat="server" Text="Renew Contract" CssClass="hr-btn hr-btn--success hr-btn--sm" OnClick="btnRenewContract_Click" />
        </div>
    </div>
</div>

<!-- ===== EDIT CONTRACT MODAL ===== -->
<div class="hr-modal-overlay" id="editModal">
    <div class="hr-modal" style="width:580px;">
        <div class="hr-modal__header">
            <span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:5px;"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                Edit Contract
            </span>
            <button type="button" class="hr-modal__close" onclick="closeEditModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="editEmpInfo" style="background:#f0f4ff;border-left:3px solid #174DA4;padding:9px 13px;font-size:12px;margin-bottom:14px;color:#1a1a1a;border-radius:0 5px 5px 0;"></div>

            <div class="hr-modal__section">Contract Details</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Type <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditType" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="FULL TIME"  Value="FULL TIME" />
                        <asp:ListItem Text="PART TIME"  Value="PART TIME" />
                        <asp:ListItem Text="CONTRACT"   Value="CONTRACT" />
                        <asp:ListItem Text="TEMPORARY"  Value="TEMPORARY" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Status <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="VALID"      Value="VALID" />
                        <asp:ListItem Text="EXPIRED"    Value="EXPIRED" />
                        <asp:ListItem Text="TERMINATED" Value="TERMINATED" />
                        <asp:ListItem Text="RESIGNED"   Value="RESIGNED" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtEditStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">End Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtEditEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                    <div class="hr-form-hint" id="editDurationHint"></div>
                </div>
            </div>

            <div class="hr-modal__section">Position &amp; Department</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Position <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditJob" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Department <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditDept" runat="server" CssClass="hr-form-select" />
                </div>
            </div>

            <div class="hr-modal__section">Compensation</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Pay Scale <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditScale" runat="server" CssClass="hr-form-select" />
                    <div class="hr-form-hint">Leave blank to use fixed amount</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Fixed Amount</label>
                    <asp:TextBox ID="txtEditFixed" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                </div>
            </div>

            <div class="hr-modal__section">Notes</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Comments</label>
                <asp:TextBox ID="txtEditComment" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" placeholder="Optional notes..." />
            </div>

            <div id="editResult" class="hr-result"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeEditModal()">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="submitEditModal()">Save Changes</button>
        </div>
    </div>
</div>

<script type="text/javascript">
/* ---- Action popover ---- */
function toggleActionPopover(btn, evt) {
    evt.stopPropagation();
    var pop = btn.nextElementSibling;
    var isOpen = pop.classList.contains('is-open');
    closeAllActionPopovers();
    if (!isOpen) pop.classList.add('is-open');
}
function closeAllActionPopovers() {
    document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){ p.classList.remove('is-open'); });
}
document.addEventListener('click', closeAllActionPopovers);

/* ===== SEARCHABLE SELECT WIDGET ========================================= */
/* Wraps a native <select> with a text input for filtering options client-side */
function initSearchableSelect(sel) {
    if (!sel || sel.dataset.srchInit) return;
    sel.dataset.srchInit = '1';
    sel.style.display = 'none';

    var wrap   = document.createElement('div');  wrap.className = 'cd-srch';
    var input  = document.createElement('input'); input.type = 'text'; input.className = 'cd-srch__input'; input.autocomplete = 'off';
    input.placeholder = sel.options[0] ? sel.options[0].text : '-- Select --';
    var arrow  = document.createElement('span'); arrow.className = 'cd-srch__arrow'; arrow.innerHTML = '&#9662;';
    var panel  = document.createElement('div');  panel.className = 'cd-srch__panel';
    wrap.appendChild(input); wrap.appendChild(arrow); wrap.appendChild(panel);
    sel.parentNode.insertBefore(wrap, sel);

    var items = [], activeIdx = -1;

    function buildOptions() {
        items = [];
        for (var i = 0; i < sel.options.length; i++) {
            if (!sel.options[i].value) continue; // skip placeholder
            items.push({ text: sel.options[i].text, value: sel.options[i].value });
        }
    }
    buildOptions();

    // Observe in case the select gets repopulated
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
        // Fire change event on underlying select
        var evt = document.createEvent('HTMLEvents'); evt.initEvent('change', true, false); sel.dispatchEvent(evt);
    }

    function setActive(idx) {
        activeIdx = idx;
        var opts = panel.querySelectorAll('.cd-srch__opt');
        for (var i = 0; i < opts.length; i++) {
            opts[i].classList.toggle('cd-srch__opt--active', i === idx);
        }
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

    // Sync: if the select already has a value, show it
    wrap.syncFromSelect = function() {
        if (sel.value) {
            for (var i = 0; i < items.length; i++) {
                if (items[i].value === sel.value) { input.value = items[i].text; input.className = 'cd-srch__input cd-srch__input--has-value'; return; }
            }
        }
        input.value = ''; input.className = 'cd-srch__input';
    };
    wrap.syncFromSelect();

    // Expose clear
    wrap.clearSelection = function() { sel.value = ''; input.value = ''; input.className = 'cd-srch__input'; };

    return wrap;
}

function highlightText(text, q) {
    var esc = escHtml(text);
    var qe = q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return esc.replace(new RegExp('(' + qe + ')', 'gi'), '<mark>$1</mark>');
}
function escHtml(s) { var d = document.createElement('div'); d.appendChild(document.createTextNode(s || '')); return d.innerHTML; }

/* ===== EMPLOYEE AUTOCOMPLETE ============================================ */
var EmpAC = (function() {
    var input, list, spinner, clear, timer, xhr, activeIdx = -1, results = [], selected = null;
    var DEBOUNCE = 250, MIN_CHARS = 1, bound = false;

    function init() {
        input   = document.getElementById('acEmpInput');
        list    = document.getElementById('acEmpList');
        spinner = document.getElementById('acEmpSpinner');
        clear   = document.getElementById('acEmpClear');
        if (!input) return;
        if (bound) return; // only bind listeners once
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
        else if (e.keyCode === 13) { e.preventDefault(); if (activeIdx >= 0 && activeIdx < results.length) selectEmp(results[activeIdx]); }
        else if (e.keyCode === 27) { hideList(); }
    }

    function doSearch(q) {
        spinner.classList.add('hr-ac__spinner--visible');
        clear.classList.remove('hr-ac__clear--visible');
        if (xhr) xhr.abort();
        xhr = new XMLHttpRequest();
        xhr.open('GET', 'HRContracts.aspx?ajax=search_emp&q=' + encodeURIComponent(q), true);
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
                '<div class="hr-ac__info">' +
                '<div class="hr-ac__name">' + highlight(r.emp_name, query) + '</div>' +
                '<div class="hr-ac__meta">' + escHtml(r.emp_position || 'Staff') + '</div>' +
                '</div>' +
                '<div class="hr-ac__code">' + highlight(r.EMP_CODE || '', query) + '</div>' +
                '</div>';
        }
        html += '<div class="hr-ac__hint">' + results.length + ' result' + (results.length !== 1 ? 's' : '') + '</div>';
        list.innerHTML = html;
        var items = list.querySelectorAll('.hr-ac__item');
        for (var j = 0; j < items.length; j++) {
            (function(idx) {
                items[idx].addEventListener('click', function() { selectEmp(results[idx]); });
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

    function selectEmp(emp) {
        selected = emp;
        hideList();
        results = [];
        input.value = emp.emp_name + ' [' + emp.EMP_CODE + ']';
        input.classList.add('hr-ac__input--selected');
        clear.classList.add('hr-ac__clear--visible');

        // Show selected card
        var card = document.getElementById('selectedEmpCard');
        card.className = 'hr-selected-emp hr-selected-emp--visible';
        document.getElementById('empAvatar').textContent   = getInitials(emp.emp_name);
        document.getElementById('empName').textContent     = emp.emp_name;
        document.getElementById('empPosition').textContent = emp.emp_position || 'Staff';
        document.getElementById('empCode').textContent     = emp.EMP_CODE;

        // Set hidden field
        document.getElementById('<%= hfSelectedEmpID.ClientID %>').value = emp.empID;

        // Auto-fill from defaults
        if (typeof employeeDefaults !== 'undefined') {
            var data = employeeDefaults[emp.empID];
            if (data) {
                var jSel = document.getElementById('<%= ddlContractJob.ClientID %>');
                var dSel = document.getElementById('<%= ddlContractDept.ClientID %>');
                var sSel = document.getElementById('<%= ddlContractScale.ClientID %>');
                if (data.j && jSel) { jSel.value = data.j; syncSearchable(jSel); }
                if (data.d && dSel) { dSel.value = data.d; syncSearchable(dSel); }
                if (data.s && sSel) { sSel.value = data.s; syncSearchable(sSel); }
            }
        }
    }

    function deselect() {
        selected = null;
        input.classList.remove('hr-ac__input--selected');
        clear.classList.remove('hr-ac__clear--visible');
        document.getElementById('selectedEmpCard').className = 'hr-selected-emp';
        document.getElementById('<%= hfSelectedEmpID.ClientID %>').value = '';
    }

    function doClear() {
        deselect();
        input.value = '';
        input.focus();
        hideList();
        results = [];
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
            else { out += escHtml(parts[i]); }
        }
        return out;
    }

    function getInitials(name) {
        if (!name) return '?';
        var p = name.trim().split(/\s+/);
        if (p.length >= 2) return (p[0][0] + p[p.length - 1][0]).toUpperCase();
        return p[0][0].toUpperCase();
    }

    return { init: init, clear: doClear };
})();

/* Helper to sync a searchable-select wrapper after programmatic value change */
function syncSearchable(sel) {
    if (!sel) return;
    var wrap = sel.previousElementSibling;
    // The wrapper is the div.cd-srch we inserted before the select
    if (wrap && wrap.classList && wrap.classList.contains('cd-srch') && wrap.syncFromSelect) {
        wrap.syncFromSelect();
    }
}

/* ---- GET-based filter navigation ---- */
function applyFilters() {
    var q      = document.getElementById('<%= txtSearch.ClientID %>');
    var status = document.getElementById('<%= ddlFilterStatus.ClientID %>');
    var type   = document.getElementById('<%= ddlFilterType.ClientID %>');
    var dept   = document.getElementById('<%= ddlFilterDept.ClientID %>');
    var job    = document.getElementById('<%= ddlFilterJob.ClientID %>');
    var sz     = document.getElementById('<%= ddlPageSize.ClientID %>');
    var params = [];
    if (q      && q.value.trim())      params.push('q='      + encodeURIComponent(q.value.trim()));
    if (status && status.value)        params.push('status=' + encodeURIComponent(status.value));
    if (type   && type.value)          params.push('type='   + encodeURIComponent(type.value));
    if (dept   && dept.value)          params.push('dept='   + encodeURIComponent(dept.value));
    if (job    && job.value)           params.push('job='    + encodeURIComponent(job.value));
    if (sz     && sz.value !== '50')   params.push('sz='     + encodeURIComponent(sz.value));
    window.location.href = window.location.pathname + (params.length ? '?' + params.join('&') : '');
}
function resetFilters() {
    window.location.href = window.location.pathname;
}
function filterByStatus(val) {
    var sel = document.getElementById('<%= ddlFilterStatus.ClientID %>');
    if (sel) { sel.value = val; applyFilters(); }
}

/* ---- Add contract modal ---- */
function validateAddModal() {
    var hf    = document.getElementById('<%= hfSelectedEmpID.ClientID %>');
    var job   = document.getElementById('<%= ddlContractJob.ClientID %>');
    var dept  = document.getElementById('<%= ddlContractDept.ClientID %>');
    var scale = document.getElementById('<%= ddlContractScale.ClientID %>');
    var start = document.getElementById('<%= txtContractStart.ClientID %>');
    var end   = document.getElementById('<%= txtContractEnd.ClientID %>');
    var r     = document.getElementById('addResult');
    if (!hf || !hf.value) {
        r.innerHTML = 'Please search and select an employee.'; r.className = 'hr-result hr-result--err'; return false;
    }
    if (job && !job.value) {
        r.innerHTML = 'Please select a job title.'; r.className = 'hr-result hr-result--err'; return false;
    }
    if (dept && !dept.value) {
        r.innerHTML = 'Please select a department.'; r.className = 'hr-result hr-result--err'; return false;
    }
    if (scale && !scale.value) {
        r.innerHTML = 'Please select a pay scale.'; r.className = 'hr-result hr-result--err'; return false;
    }
    if (!start || !start.value || !end || !end.value) {
        r.innerHTML = 'Please provide both start and end dates.'; r.className = 'hr-result hr-result--err'; return false;
    }
    if (new Date(end.value) <= new Date(start.value)) {
        r.innerHTML = 'End date must be after start date.'; r.className = 'hr-result hr-result--err'; return false;
    }
    return true;
}
function resetAddForm() {
    // Clear employee autocomplete
    EmpAC.clear();
    // Reset searchable selects
    var addDropdowns = [
        document.getElementById('<%= ddlContractJob.ClientID %>'),
        document.getElementById('<%= ddlContractDept.ClientID %>'),
        document.getElementById('<%= ddlContractScale.ClientID %>')
    ];
    for (var i = 0; i < addDropdowns.length; i++) {
        var s = addDropdowns[i];
        if (!s) continue;
        s.value = '';
        var w = s.previousElementSibling;
        if (w && w.classList && w.classList.contains('cd-srch') && w.clearSelection) w.clearSelection();
    }
    // Reset other fields
    var el;
    el = document.getElementById('<%= ddlContractType.ClientID %>'); if (el) el.selectedIndex = 0;
    el = document.getElementById('<%= txtContractStart.ClientID %>'); if (el) el.value = '';
    el = document.getElementById('<%= txtContractEnd.ClientID %>');   if (el) el.value = '';
    el = document.getElementById('<%= txtContractFixed.ClientID %>'); if (el) el.value = '0';
    el = document.getElementById('<%= txtContractComment.ClientID %>'); if (el) el.value = '';
    // Clear duration hint
    var hint = document.getElementById('contractDurationHint'); if (hint) hint.innerHTML = '';
}
function openAddModal() {
    var r = document.getElementById('addResult');
    r.innerHTML = ''; r.className = 'hr-result';
    EmpAC.init();          // bind listeners first (guarded — runs once)
    resetAddForm();        // now safe to call EmpAC.clear()
    document.getElementById('addModal').style.display = 'flex';
    setTimeout(function() { var inp = document.getElementById('acEmpInput'); if (inp) inp.focus(); }, 100);
}
function closeAddModal() { document.getElementById('addModal').style.display = 'none'; }

/* ---- Edit contract modal ---- */
function openEditModal(cid, jobID, deptID, scaleID, type, status, startDt, endDt, fixedAmt, comment, empName) {
    closeAllActionPopovers();
    document.getElementById('<%= hdnEditContractID.ClientID %>').value = cid;
    var empInfo = document.getElementById('editEmpInfo');
    if (empInfo) empInfo.innerHTML = '<strong>' + (empName || 'Contract #' + cid) + '</strong>';
    var el;
    el = document.getElementById('<%= ddlEditType.ClientID %>');    if (el) el.value = type    || '';
    el = document.getElementById('<%= ddlEditStatus.ClientID %>');  if (el) el.value = status  || '';
    el = document.getElementById('<%= ddlEditJob.ClientID %>');     if (el) { el.value = jobID || ''; syncSearchable(el); }
    el = document.getElementById('<%= ddlEditDept.ClientID %>');    if (el) { el.value = deptID || ''; syncSearchable(el); }
    el = document.getElementById('<%= ddlEditScale.ClientID %>');   if (el) { el.value = scaleID || ''; syncSearchable(el); }
    el = document.getElementById('<%= txtEditStart.ClientID %>');   if (el) el.value = startDt || '';
    el = document.getElementById('<%= txtEditEnd.ClientID %>');     if (el) el.value = endDt   || '';
    el = document.getElementById('<%= txtEditFixed.ClientID %>');   if (el) el.value = fixedAmt || '0';
    el = document.getElementById('<%= txtEditComment.ClientID %>'); if (el) el.value = comment || '';
    var r = document.getElementById('editResult');
    r.innerHTML = ''; r.className = 'hr-result';
    document.getElementById('editModal').style.display = 'flex';
}
function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }
function submitEditModal() {
    var job   = document.getElementById('<%= ddlEditJob.ClientID %>');
    var dept  = document.getElementById('<%= ddlEditDept.ClientID %>');
    var scale = document.getElementById('<%= ddlEditScale.ClientID %>');
    var start = document.getElementById('<%= txtEditStart.ClientID %>');
    var end   = document.getElementById('<%= txtEditEnd.ClientID %>');
    var r     = document.getElementById('editResult');
    if (job && !job.value) {
        r.innerHTML = 'Please select a job title.'; r.className = 'hr-result hr-result--err'; return;
    }
    if (dept && !dept.value) {
        r.innerHTML = 'Please select a department.'; r.className = 'hr-result hr-result--err'; return;
    }
    if (scale && !scale.value) {
        r.innerHTML = 'Please select a pay scale.'; r.className = 'hr-result hr-result--err'; return;
    }
    if (!start || !start.value || !end || !end.value) {
        r.innerHTML = 'Please provide both start and end dates.'; r.className = 'hr-result hr-result--err'; return;
    }
    if (new Date(end.value) <= new Date(start.value)) {
        r.innerHTML = 'End date must be after start date.'; r.className = 'hr-result hr-result--err'; return;
    }
    document.getElementById('<%= btnUpdateContract.ClientID %>').click();
}

/* ---- Renew modal ---- */
function openRenewModal(contractID, empID, empName, endDate, contractType) {
    closeAllActionPopovers();
    document.getElementById('<%= hdnRenewContractID.ClientID %>').value = contractID;
    document.getElementById('<%= hdnRenewEmpID.ClientID %>').value      = empID;
    document.getElementById('renewEmpInfo').innerHTML =
        '<strong>' + empName + '</strong>' +
        '<br/><span style="font-size:10px;color:#666;">Previous contract ended: ' + (endDate || '-') + '</span>';
    document.getElementById('<%= txtRenewStart.ClientID %>').value = '';
    document.getElementById('<%= txtRenewEnd.ClientID %>').value   = '';
    document.getElementById('renewDurationHint').innerHTML = '';
    var typeEl = document.getElementById('<%= ddlRenewType.ClientID %>');
    if (typeEl && contractType) typeEl.value = contractType;
    var r = document.getElementById('renewResult');
    r.innerHTML = ''; r.className = 'hr-result';
    document.getElementById('renewModal').style.display = 'flex';
}
function closeRenewModal() { document.getElementById('renewModal').style.display = 'none'; }

/* ---- Delete confirmation ---- */
function confirmDelete(cid, empName) {
    closeAllActionPopovers();
    if (!confirm('Delete the contract for "' + empName + '"?\nThis cannot be undone.')) return;
    document.getElementById('<%= hdnDeleteContractID.ClientID %>').value = cid;
    document.getElementById('<%= btnDeleteContract.ClientID %>').click();
}

/* ---- Batch operations ---- */
function updateBatchToolbar() {
    var checked = document.querySelectorAll('.ct-row-check:checked');
    var all     = document.querySelectorAll('.ct-row-check');
    var toolbar = document.getElementById('batchToolbar');
    var countEl = document.getElementById('batchCount');
    if (checked.length > 0) {
        toolbar.style.display = 'flex';
        countEl.textContent   = checked.length;
    } else {
        toolbar.style.display = 'none';
    }
    var chk = document.getElementById('chkSelectAll');
    if (chk) {
        chk.indeterminate = (checked.length > 0 && checked.length < all.length);
        chk.checked       = all.length > 0 && checked.length === all.length;
    }
}
function toggleSelectAll(cb) {
    document.querySelectorAll('.ct-row-check').forEach(function(c) { c.checked = cb.checked; });
    updateBatchToolbar();
}
function clearBatchSelection() {
    document.querySelectorAll('.ct-row-check').forEach(function(c) { c.checked = false; });
    var chk = document.getElementById('chkSelectAll');
    if (chk) { chk.checked = false; chk.indeterminate = false; }
    updateBatchToolbar();
}
function getBatchIDs() {
    var ids = [];
    document.querySelectorAll('.ct-row-check:checked').forEach(function(c) { ids.push(c.value); });
    return ids.join(',');
}
function doBatchExpire() {
    var n = document.querySelectorAll('.ct-row-check:checked').length;
    if (!n || !confirm('Mark ' + n + ' contract(s) as Expired?')) return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value = getBatchIDs();
    document.getElementById('<%= btnBatchExpire.ClientID %>').click();
}
function doBatchDelete() {
    var n = document.querySelectorAll('.ct-row-check:checked').length;
    if (!n || !confirm('Permanently delete ' + n + ' contract(s)? This cannot be undone.')) return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value = getBatchIDs();
    document.getElementById('<%= btnBatchDelete.ClientID %>').click();
}
function doBatchStatus() {
    var sel = document.getElementById('ddlBatchStatus');
    var status = sel ? sel.value : '';
    if (!status) { alert('Please select a status to apply.'); return; }
    var n = document.querySelectorAll('.ct-row-check:checked').length;
    if (!n) { alert('No contracts selected.'); return; }
    if (!confirm('Set ' + n + ' contract(s) to "' + status + '"?')) return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value    = getBatchIDs();
    document.getElementById('<%= hdnBatchStatus.ClientID %>').value = status;
    document.getElementById('<%= btnBatchStatus.ClientID %>').click();
}

/* ---- Duration hints ---- */
function updateDuration(startId, endId, hintId) {
    var s = document.getElementById(startId);
    var e = document.getElementById(endId);
    var h = document.getElementById(hintId);
    if (!s || !e || !h) return;
    function calc() {
        if (!s.value || !e.value) { h.innerHTML = ''; return; }
        var days = Math.round((new Date(e.value) - new Date(s.value)) / 86400000);
        if (days < 0) { h.innerHTML = '<span style="color:#dc3545;">End must be after start</span>'; return; }
        var months = Math.floor(days / 30);
        h.innerHTML = '<span style="color:#555;">' + (months > 0 ? months + ' month(s) / ' + days + ' days' : days + ' day(s)') + '</span>';
    }
    s.addEventListener('change', calc);
    e.addEventListener('change', calc);
}
updateDuration('<%= txtContractStart.ClientID %>', '<%= txtContractEnd.ClientID %>', 'contractDurationHint');
updateDuration('<%= txtRenewStart.ClientID %>',    '<%= txtRenewEnd.ClientID %>',    'renewDurationHint');
updateDuration('<%= txtEditStart.ClientID %>',     '<%= txtEditEnd.ClientID %>',     'editDurationHint');

/* ---- Initialize searchable selects on all modal dropdowns ---- */
(function() {
    // Add modal: Job, Department, Scale
    var addJob   = document.getElementById('<%= ddlContractJob.ClientID %>');
    var addDept  = document.getElementById('<%= ddlContractDept.ClientID %>');
    var addScale = document.getElementById('<%= ddlContractScale.ClientID %>');
    if (addJob)   initSearchableSelect(addJob);
    if (addDept)  initSearchableSelect(addDept);
    if (addScale) initSearchableSelect(addScale);

    // Edit modal: Job, Department, Scale
    var editJob   = document.getElementById('<%= ddlEditJob.ClientID %>');
    var editDept  = document.getElementById('<%= ddlEditDept.ClientID %>');
    var editScale = document.getElementById('<%= ddlEditScale.ClientID %>');
    if (editJob)   initSearchableSelect(editJob);
    if (editDept)  initSearchableSelect(editDept);
    if (editScale) initSearchableSelect(editScale);
})();

/* ---- Close overlay on backdrop click ---- */
document.querySelectorAll('.hr-modal-overlay').forEach(function(overlay) {
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) overlay.style.display = 'none';
    });
});

/* ---- Page-size change triggers filter ---- */
(function() {
    var sz = document.getElementById('<%= ddlPageSize.ClientID %>');
    if (sz) sz.addEventListener('change', applyFilters);
})();

/* ---- Search on Enter ---- */
(function() {
    var sb = document.getElementById('<%= txtSearch.ClientID %>');
    if (sb) sb.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') { e.preventDefault(); applyFilters(); }
    });
})();

/* ---- Escape closes modals ---- */
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeAddModal();
        closeRenewModal();
        closeEditModal();
    }
});
</script>
</asp:Content>