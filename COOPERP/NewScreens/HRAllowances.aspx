<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRAllowances.aspx.cs"
    Inherits="COOPERP_NewScreens_HRAllowances"
    Title="Payroll Allowance Records - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== HR ALLOWANCES (Modern Design System) ========================= */

.hr-page-header { display: flex; align-items: center; justify-content: space-between; padding: 16px 0 14px; margin-bottom: 18px; border-bottom: 2px solid #05275C; flex-wrap: wrap; gap: 12px; }
.hr-page-header__left { display: flex; align-items: center; gap: 14px; min-width: 0; }
.hr-page-header__icon { width: 42px; height: 42px; background: linear-gradient(135deg, #05275C 0%, #041d45 100%); color: #fff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 4px; box-shadow: 0 2px 6px rgba(5,39,92,0.15); }
.hr-page-header__title { font-size: 18px; font-weight: 700; color: #05275C; line-height: 1.2; margin: 0; }
.hr-page-header__sub { font-size: 12px; color: #666; margin-top: 3px; }
.hr-page-actions { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }

/* Stats */
.hr-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 18px; }
.hr-stat { background: #fff; border: 1px solid #d0d5dd; padding: 14px 16px; display: flex; align-items: center; gap: 12px; position: relative; overflow: hidden; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); transition: all .15s ease; }
.hr-stat:hover { border-color: #05275C; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
.hr-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.hr-stat__icon { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 18px; }
.hr-stat__val { font-size: 16px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.hr-stat__label { font-size: 10px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 3px; font-weight: 600; }
.hr-stat--pending  { --stat-c: #f59e0b; } .hr-stat--pending  .hr-stat__icon { background: #fff3e0; border-radius: 3px; } .hr-stat--pending .hr-stat__val { color: #d97706; }
.hr-stat--amount   { --stat-c: #16a34a; } .hr-stat--amount   .hr-stat__icon { background: #dcfce7; border-radius: 3px; } .hr-stat--amount .hr-stat__val { color: #16a34a; }
.hr-stat--settled  { --stat-c: #05275C; } .hr-stat--settled  .hr-stat__icon { background: #e8f0fc; border-radius: 3px; } .hr-stat--settled .hr-stat__val { color: #05275C; }
.hr-stat--cancelled{ --stat-c: #6b7280; } .hr-stat--cancelled .hr-stat__icon { background: #f3f4f6; border-radius: 3px; } .hr-stat--cancelled .hr-stat__val { color: #6b7280; }

/* Filters Card */
.hr-card { background: #fff; border: 1px solid #d0d5dd; overflow: hidden; margin-bottom: 16px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
.hr-card__header { padding: 12px 16px; border-bottom: 1px solid #d0d5dd; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px; }
.hr-card__title { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; text-transform: uppercase; letter-spacing: .4px; }
.hr-card__meta { font-size: 10px; color: #05275C; font-weight: 600; background: rgba(5,39,92,.08); padding: 3px 10px; border: 1px solid rgba(5,39,92,.15); border-radius: 3px; }

.hr-filters { background: #f8f9fb; border-bottom: 1px solid #d0d5dd; padding: 12px 16px; }
.hr-filters__top { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; }
.hr-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 400px; }
.hr-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; width: 16px; height: 16px; }
.hr-search-box { width: 100%; padding: 8px 12px 8px 34px; border: 1px solid #d0d5dd; font-size: 12px; background: #fff; box-sizing: border-box; border-radius: 3px; transition: all .15s ease; }
.hr-search-box:focus { border-color: #05275C; outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,.1); background: #fff; }
.hr-search-box::placeholder { color: #999; }
.hr-filters__row { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-start; }
.hr-filter-grp { display: flex; flex-direction: column; gap: 4px; }
.hr-filter-grp__label { font-size: 10px; text-transform: uppercase; letter-spacing: .5px; color: #666; font-weight: 600; }
.hr-filter-select { border: 1px solid #d0d5dd; padding: 7px 10px; font-size: 12px; background: #fff; color: #333; cursor: pointer; min-width: 120px; border-radius: 3px; transition: all .15s ease; }
.hr-filter-select:hover { border-color: #05275C; }
.hr-filter-select:focus { border-color: #05275C; outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,.1); }

/* Buttons */
.hr-btn { padding: 7px 14px; font-size: 11px; font-weight: 600; border: 1px solid transparent; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 6px; white-space: nowrap; transition: all .15s ease; border-radius: 3px; min-height: 36px; text-decoration: none; user-select: none; }
.hr-btn:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 2px 8px rgba(0,0,0,0.12); }
.hr-btn:active:not(:disabled) { transform: translateY(0); }
.hr-btn:focus { box-shadow: 0 0 0 3px rgba(5,39,92,0.15); outline: none; }
.hr-btn:disabled { opacity: .6; cursor: not-allowed; }
.hr-btn--primary { background: #05275C; color: #fff; border-color: #05275C; } .hr-btn--primary:hover:not(:disabled) { background: #041d45; border-color: #041d45; }
.hr-btn--success { background: #16a34a; color: #fff; border-color: #16a34a; } .hr-btn--success:hover:not(:disabled) { background: #15803d; border-color: #15803d; }
.hr-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; } .hr-btn--danger:hover:not(:disabled) { background: #c82333; border-color: #c82333; }
.hr-btn--ghost { background: transparent; border: 1px solid #d0d5dd; color: #666; } .hr-btn--ghost:hover:not(:disabled) { background: #f5f7fa; border-color: #05275C; color: #05275C; }
.hr-btn--sm { padding: 6px 10px; font-size: 10px; min-height: 32px; }
.hr-btn--lg { padding: 10px 18px; font-size: 12px; min-height: 40px; }

/* Grid Footer */
.hr-grid-footer { display: flex; justify-content: space-between; align-items: center; padding: 8px 14px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 11px; color: #666; flex-wrap: wrap; gap: 6px; }
.hr-grid-footer strong { color: #05275C; }

/* Badges */
.hr-badge { display: inline-block; padding: 4px 10px; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; border-radius: 3px; }
.hr-badge--pending { background: #fef3c7; color: #92400e; }
.hr-badge--settled { background: #dcfce7; color: #166534; }
.hr-badge--cancelled { background: #e5e7eb; color: #374151; }

/* DevExpress Grid overrides */
.dxgvControl_Glass { border: 1px solid #e0e5ed !important; }
.dxgvHeader_Glass td { font-size: 10px !important; text-transform: uppercase !important; letter-spacing: .3px !important; background: #f5f7fa !important; color: #555 !important; border-bottom: 2px solid #e0e5ed !important; padding: 9px 12px !important; font-weight: 600 !important; }
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td { font-size: 11px !important; color: #1a1a2e !important; padding: 8px 12px !important; border-bottom: 1px solid #f0f2f5 !important; vertical-align: middle !important; position: relative !important; }
.dxgvDataRow_Glass:hover td, .dxgvDataRowAlt_Glass:hover td { background: #f8f9fb !important; }
.dxgvFilterRow_Glass td { padding: 4px 6px !important; background: #fff !important; }
.dxgvFilterRow_Glass input { border: 1px solid #e0e5ed !important; font-size: 11px !important; padding: 3px 6px !important; }
.dxgvPagerBar_Glass { background: #f5f7fa !important; border-top: 1px solid #e0e5ed !important; padding: 6px 12px !important; }
.dxgv td { overflow: visible !important; }
.cd-action-wrapper { position: relative !important; z-index: 100; }

/* ===== MODAL (Modern Design System) ================================ */
.hr-modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,.55); z-index: 1000; justify-content: center; align-items: flex-start; padding: 20px 15px; overflow-y: auto; box-sizing: border-box; animation: fadeIn .2s ease; }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.hr-modal { background: #fff; border: 1px solid #d0d5dd; width: 100%; max-width: 560px; margin: auto; position: relative; border-radius: 4px; box-shadow: 0 10px 40px rgba(0,0,0,0.15); animation: slideIn .2s ease; }
@keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
.hr-modal--wide { max-width: 680px; }
.hr-modal__header { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; background: #05275C; color: #fff; border-radius: 4px 4px 0 0; }
.hr-modal__title { font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.hr-modal__close { background: none; border: none; font-size: 18px; cursor: pointer; color: rgba(255,255,255,.8); padding: 2px 4px; line-height: 1; transition: all .15s ease; border-radius: 2px; }
.hr-modal__close:hover { color: #fff; background: rgba(255,255,255,.15); }
.hr-modal__close:focus { outline: none; background: rgba(255,255,255,.15); }
.hr-modal__body { padding: 18px; max-height: calc(92vh - 120px); overflow-y: auto; }
.hr-modal__footer { display: flex; align-items: center; justify-content: flex-end; gap: 10px; padding: 12px 18px; border-top: 1px solid #e0e0e0; background: #f8f9fa; }
/* Section label */
.hr-section-label { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: #05275C; border-bottom: 2px solid #d0d5dd; padding-bottom: 6px; margin: 16px 0 12px; }

/* ===== EMPLOYEE AUTOCOMPLETE ====================================== */
.hr-ac { position: relative; flex: 1; }
.hr-ac__input { width: 100%; border: 1px solid #d0d5dd; padding: 8px 32px 8px 10px; font-size: 12px; color: #1a1a2e; background: #fff; box-sizing: border-box; border-radius: 3px; transition: all .15s ease; }
.hr-ac__input:focus { border-color: #05275C; outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,0.1); background: #fff; }
.hr-ac__input--selected { border-color: #16a34a; background: #f0fdf4; }
.hr-ac__spinner { display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px; border: 2px solid #e0e5ed; border-top-color: #05275C; animation: hrSpin .6s linear infinite; }
.hr-ac__spinner--visible { display: block; }
@keyframes hrSpin { to { transform: translateY(-50%) rotate(360deg); } }
.hr-ac__clear { display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); width: 18px; height: 18px; border: none; background: #dc3545; color: #fff; font-size: 13px; line-height: 1; cursor: pointer; align-items: center; justify-content: center; border-radius: 2px; transition: all .15s ease; }
.hr-ac__clear--visible { display: flex; }
.hr-ac__clear:hover { background: #c82333; }
.hr-ac__list { display: none; position: absolute; left: 0; right: 0; top: calc(100% + 2px); z-index: 9999; background: #fff; border: 1px solid #05275C; border-radius: 3px; max-height: 280px; overflow-y: auto; box-shadow: 0 10px 30px rgba(0,0,0,0.18); }
.hr-ac__list--visible { display: block; }
.hr-ac__item { padding: 10px 12px; cursor: pointer; border-bottom: 1px solid #f0f2f5; display: flex; align-items: center; gap: 10px; transition: background .1s ease; }
.hr-ac__item:last-child { border-bottom: none; }
.hr-ac__item:hover { background: #e8f0fc; }
.hr-ac__item--active { background: #dbeafe; border-left: 2px solid #05275C; padding-left: 10px; }
.hr-ac__avatar { width: 36px; height: 36px; background: #05275C; color: #fff; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; letter-spacing: .5px; border-radius: 2px; }
.hr-ac__info { flex: 1; min-width: 0; }
.hr-ac__name { font-size: 12px; font-weight: 700; color: #1a1a2e; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.hr-ac__name mark { background: #fff3cd; color: #1a1a2e; padding: 0 2px; font-weight: 700; border-radius: 1px; }
.hr-ac__meta { font-size: 10px; color: #888; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.hr-ac__meta mark { background: #fff3cd; color: #888; padding: 0 2px; }
.hr-ac__code { font-size: 10px; font-weight: 600; color: #05275C; white-space: nowrap; text-align: right; }
.hr-ac__code mark { background: #fff3cd; color: #05275C; padding: 0 2px; font-weight: 700; }
.hr-ac__empty { padding: 16px 12px; text-align: center; font-size: 12px; color: #999; }
.hr-ac__hint { padding: 6px 12px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 9px; color: #999; text-align: center; }

/* Selected employee card */
.hr-selected-emp { display: none; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 3px; padding: 12px 14px; margin-bottom: 14px; }
.hr-selected-emp--visible { display: flex; align-items: center; gap: 12px; animation: slideDown .2s ease; }
@keyframes slideDown { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
.hr-selected-emp__avatar { width: 40px; height: 40px; background: #05275C; color: #fff; font-size: 13px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 3px; }
.hr-selected-emp__info { flex: 1; min-width: 0; }
.hr-selected-emp__name { font-size: 13px; font-weight: 700; color: #05275C; line-height: 1.2; }
.hr-selected-emp__detail { font-size: 11px; color: #555; margin-top: 2px; }
.hr-selected-emp__code { font-size: 11px; font-weight: 700; color: #16a34a; background: #dcfce7; padding: 2px 8px; white-space: nowrap; border-radius: 2px; }
.hr-selected-emp__remove { width: 24px; height: 24px; border: 1px solid #bbf7d0; background: #fff; color: #888; font-size: 14px; cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 2px; transition: all .15s ease; }
.hr-selected-emp__remove:hover { border-color: #dc3545; color: #dc3545; background: #fde8e8; }

/* Batch preview */
.batch-preview { margin-top: 14px; padding-top: 14px; border-top: 1px solid #d0d5dd; }
.batch-preview__title { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: #333; margin-bottom: 8px; }
.batch-preview__list { display: flex; flex-wrap: wrap; gap: 6px; max-height: 120px; overflow-y: auto; padding: 2px; }
.batch-preview__item { background: #dcfce7; color: #15803d; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid #bbf7d0; border-radius: 3px; }
.batch-preview__empty { font-size: 11px; color: #999; font-style: italic; }

/* Batch toolbar */
.hr-batch-toolbar { display: none; align-items: center; gap: 10px; flex-wrap: wrap; padding: 10px 14px; background: linear-gradient(135deg, #dcfce7 0%, #f0fdf4 100%); border-top: 2px solid #16a34a; border-bottom: 2px solid #16a34a; box-shadow: 0 2px 4px rgba(22,163,74,0.1); animation: slideDown .2s ease; }
.hr-batch-info { display: flex; align-items: center; gap: 6px; font-size: 11px; color: #15803d; white-space: nowrap; }
.hr-batch-info strong { font-size: 13px; font-weight: 700; color: #15803d; }
.hr-batch-sep { width: 1px; height: 26px; background: #a3e635; margin: 0 2px; flex-shrink: 0; }
.hr-row-check { cursor: pointer; width: 16px; height: 16px; accent-color: #16a34a; vertical-align: middle; }
.hr-row-check:focus { outline: 2px solid #05275C; outline-offset: 2px; }

/* Action popover */
.cd-action-wrapper { position: relative; display: inline-block; }
.cd-action-trigger { background: none; border: none; cursor: pointer; padding: 6px 8px; color: #666; border-radius: 3px; display: flex; align-items: center; justify-content: center; transition: all .15s ease; width: 32px; height: 32px; }
.cd-action-trigger:hover { background: #f0f0f0; color: #05275C; }
.cd-action-trigger:focus { outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,.15); }
.cd-action-popover { display: none; position: absolute; right: -8px; top: calc(100% + 4px); background: #fff; border: 1px solid #d0d5dd; box-shadow: 0 6px 16px rgba(0,0,0,.15); z-index: 9999; min-width: 180px; border-radius: 4px; overflow: hidden; }
.cd-action-popover.is-open { display: block; animation: popoverSlide .2s ease; }
@keyframes popoverSlide { from { opacity: 0; transform: translateY(-4px); } to { opacity: 1; transform: translateY(0); } }
.cd-action-popover__menu { list-style: none; margin: 0; padding: 6px 0; }
.cd-action-popover__item { margin: 0; }
.cd-action-popover__btn { display: flex; align-items: center; gap: 8px; padding: 10px 14px; font-size: 12px; font-weight: 500; width: 100%; background: none; border: none; cursor: pointer; color: #333; text-align: left; white-space: nowrap; transition: all .15s ease; }
.cd-action-popover__btn:hover { background: #f5f7fa; color: #05275C; }
.cd-action-popover__btn:disabled { cursor: not-allowed; opacity: .6; }
.cd-action-popover__btn--danger { color: #dc3545; }
.cd-action-popover__btn--danger:hover { background: #fde8e8; color: #c82333; }
.cd-action-popover__btn--warning { color: #f59e0b; }
.cd-action-popover__btn--warning:hover { background: #fef3c7; color: #d97706; }
.cd-action-popover__divider { height: 1px; background: #e0e0e0; margin: 4px 0; }

/* Responsive */
@media (max-width: 1200px) { 
  .hr-stats { grid-template-columns: repeat(2, 1fr); } 
}
@media (max-width: 900px) { 
  .hr-stats { grid-template-columns: repeat(2, 1fr); } 
  .hr-form-row { flex-wrap: wrap; }
  .hr-form-group { min-width: 100%; }
  .hr-page-header { flex-direction: column; align-items: flex-start; }
}
@media (max-width: 768px) {
  .hr-stats { grid-template-columns: 1fr 1fr; }
  .hr-page-header__left { flex-wrap: wrap; width: 100%; }
  .hr-page-actions { width: 100%; }
  .hr-filters__row { gap: 6px; }
  .hr-filter-select { min-width: auto; flex: 1; }
  .hr-search-wrap { max-width: 100%; }
  .hr-modal { width: 95vw; }
  .hr-form-row { gap: 8px; }
  .hr-btn { min-height: 38px; padding: 8px 12px; }
  .hr-btn--sm { min-height: 34px; padding: 6px 10px; }
}
@media (max-width: 600px) {
  .hr-stats { grid-template-columns: 1fr; }
  .hr-page-header__left { gap: 8px; }
  .hr-page-header__icon { width: 36px; height: 36px; font-size: 18px; }
  .hr-page-header__title { font-size: 15px; }
  .hr-modal { width: 98vw; border-radius: 8px; }
  .hr-modal__body { padding: 14px; }
  .hr-modal__footer { flex-direction: column-reverse; gap: 6px; }
  .hr-modal__footer .hr-btn { width: 100%; }
  .hr-filters__top { gap: 6px; }
  .hr-filters { padding: 8px 10px; }
  .hr-filter-select { padding: 8px 10px; font-size: 12px; min-width: 100px; }
  .hr-search-wrap { max-width: 100%; }
  .hr-form-row { gap: 8px; margin-bottom: 10px; }
  .hr-form-group { min-width: 100%; }
  .hr-input, .hr-select, .hr-textarea { padding: 8px 10px; }
  .hr-label { font-size: 11px; }
  .hr-btn { min-height: 40px; padding: 10px 14px; font-size: 12px; }
  .hr-btn--sm { min-height: 36px; padding: 8px 12px; font-size: 11px; }
  .hr-page-header { gap: 8px; }
  .hr-stat__val { font-size: 13px; }
  .hr-stat { padding: 10px 12px; gap: 8px; }
  .hr-batch-toolbar { padding: 6px 10px; gap: 6px; }
  .hr-card__header { padding: 8px 10px; }
}

/* Row coloring */
.pr-row-pending td{background:#f0fff4 !important;}
.pr-row-settled td{background:#f6fff6 !important;}
.pr-row-cancelled td{background:#f7f7f7 !important;opacity:.75;}

/* Status badges */
.pr-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border-radius:0;text-transform:uppercase;letter-spacing:.3px;}
.pr-badge--pending{background:#d4edda;color:#155724;}
.pr-badge--settled{background:#c3e6cb;color:#155724;}
.pr-badge--cancelled{background:#e2e3e5;color:#383d41;}

/* Type badge - green scheme */
.pr-type{display:inline-block;padding:1px 7px;font-size:10px;font-weight:600;background:#f0fff4;color:#155724;border:1px solid #c3e6cb;}

/* Period */
.pr-period{font-size:11px;font-weight:700;color:#333;}
.pr-period__year{font-size:10px;color:#888;}

/* Payroll ref */
.pr-payref{font-size:10px;color:#28a745;font-style:italic;}

/* Amount */
.pr-amount{font-size:12px;font-weight:700;color:#28a745;}

/* Action popover */
.cd-action-wrapper{position:relative;display:inline-block;}
.cd-action-trigger{background:none;border:none;cursor:pointer;padding:6px 8px;color:#666;border-radius:3px;display:flex;align-items:center;justify-content:center;transition:all .15s ease;width:32px;height:32px;}
.cd-action-trigger:hover{background:#f0f0f0;color:#05275C;}
.cd-action-trigger:focus{outline:none;box-shadow:0 0 0 2px rgba(5,39,92,.15);}
.cd-action-popover{display:none;position:absolute;right:-8px;top:calc(100% + 4px);background:#fff;border:1px solid #d0d5dd;box-shadow:0 6px 16px rgba(0,0,0,.15);z-index:9999;min-width:180px;border-radius:4px;overflow:hidden;}
.cd-action-popover.is-open{display:block;animation:popoverSlide .2s ease;}
@keyframes popoverSlide{from{opacity:0;transform:translateY(-4px);}to{opacity:1;transform:translateY(0);}}
.cd-action-popover__menu{list-style:none;margin:0;padding:6px 0;}
.cd-action-popover__item{margin:0;}
.cd-action-popover__btn{display:flex;align-items:center;gap:8px;padding:10px 14px;font-size:12px;font-weight:500;width:100%;background:none;border:none;cursor:pointer;color:#333;text-align:left;white-space:nowrap;transition:all .15s ease;}
.cd-action-popover__btn:hover{background:#f5f7fa;color:#05275C;}
.cd-action-popover__btn:disabled{cursor:not-allowed;opacity:.6;}
.cd-action-popover__btn--danger{color:#dc3545;}
.cd-action-popover__btn--danger:hover{background:#fde8e8;color:#c82333;}
.cd-action-popover__btn--warning{color:#f59e0b;}
.cd-action-popover__btn--warning:hover{background:#fef3c7;color:#d97706;}
.cd-action-popover__divider{height:1px;background:#e0e0e0;margin:4px 0;}

/* Modal */
.hr-modal-overlay{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.55);z-index:1000;justify-content:center;align-items:flex-start;padding:20px 15px;overflow-y:auto;box-sizing:border-box;animation:fadeIn .2s ease;}
@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}
.hr-modal{background:#fff;border:1px solid #d0d5dd;width:100%;max-width:560px;margin:auto;position:relative;border-radius:4px;box-shadow:0 10px 40px rgba(0,0,0,0.15);animation:slideIn .2s ease;}
@keyframes slideIn{from{transform:translateY(-20px);opacity:0;}to{transform:translateY(0);opacity:1;}}
.hr-modal--wide{max-width:680px;}
.hr-modal__header{display:flex;align-items:center;justify-content:space-between;padding:14px 18px;background:#05275C;color:#fff;border-radius:4px 4px 0 0;}
.hr-modal__title{font-size:13px;font-weight:700;display:flex;align-items:center;gap:8px;}
.hr-modal__close{background:none;border:none;font-size:18px;cursor:pointer;color:rgba(255,255,255,.8);padding:2px 4px;line-height:1;transition:all .15s ease;border-radius:2px;}
.hr-modal__close:hover{color:#fff;background:rgba(255,255,255,.15);}
.hr-modal__close:focus{outline:none;background:rgba(255,255,255,.15);}
.hr-modal__body{padding:18px;max-height:calc(92vh - 120px);overflow-y:auto;}
.hr-modal__footer{display:flex;align-items:center;justify-content:flex-end;gap:10px;padding:12px 18px;border-top:1px solid #e0e0e0;background:#f8f9fa;}

/* Form */
.hr-form-row{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;}
.hr-form-row3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:12px;}
.hr-form-group{display:flex;flex-direction:column;gap:4px;}
.hr-form-group--full{grid-column:span 2;}
.hr-label{font-size:11px;font-weight:600;color:#333;}
.hr-label span{color:#dc3545;}
.hr-input,.hr-select{height:36px;padding:7px 9px;border:1px solid #d0d5dd;font-size:12px;color:#1a1a2e;width:100%;box-sizing:border-box;border-radius:3px;transition:all .15s ease;}
.hr-input:focus,.hr-select:focus{outline:none;border-color:#05275C;box-shadow:0 0 0 2px rgba(5,39,92,0.1);background:#fff;}
.hr-input::placeholder{color:#999;}
.hr-textarea{padding:8px 9px;border:1px solid #d0d5dd;font-size:12px;color:#1a1a2e;width:100%;box-sizing:border-box;resize:vertical;min-height:60px;border-radius:3px;transition:all .15s ease;font-family:inherit;}
.hr-textarea:focus{outline:none;border-color:#05275C;box-shadow:0 0 0 2px rgba(5,39,92,0.1);}
.hr-textarea::placeholder{color:#999;}
.hr-hint{font-size:10px;color:#999;margin-top:2px;font-weight:500;}
.hr-result{display:none;padding:10px 12px;font-size:11px;font-weight:600;margin-bottom:10px;border-left:3px solid;border-radius:2px;}
.hr-result--ok{background:#d4edda;border-color:#28a745;color:#155724;display:block;}
.hr-result--err{background:#f8d7da;border-color:#dc3545;color:#721c24;display:block;}

/* Section label */
.hr-section-label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#05275C;border-bottom:2px solid #d0d5dd;padding-bottom:6px;margin:16px 0 12px;}

/* Batch preview */
.batch-preview{margin-top:14px;padding-top:14px;border-top:1px solid #d0d5dd;}
.batch-preview__title{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#333;margin-bottom:8px;}
.batch-preview__list{display:flex;flex-wrap:wrap;gap:6px;max-height:120px;overflow-y:auto;padding:2px;}
.batch-preview__item{background:#dcfce7;color:#15803d;font-size:11px;font-weight:600;padding:4px 10px;border:1px solid #bbf7d0;border-radius:3px;}
.batch-preview__empty{font-size:11px;color:#999;font-style:italic;}

/* Count bar */
.pr-count-bar{font-size:11px;color:#888;padding:5px 14px;background:#fafbfc;border:1px solid #e0e0e0;border-top:none;border-bottom:none;display:flex;align-items:center;justify-content:space-between;}

/* DevExpress overrides */
.dxgvControl_Glass{border:none !important;}
.dxgvHeader_Glass td{font-size:10px !important;text-transform:uppercase !important;letter-spacing:.3px !important;background:#f5f7fa !important;color:#555 !important;}
.dxgvDataRow_Glass td,.dxgvDataRowAlt_Glass td{font-size:11px !important;padding:5px 8px !important;}

@media(max-width:900px){.ct-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:560px){.hr-form-row,.hr-form-row3{grid-template-columns:1fr;}.hr-form-group--full{grid-column:span 1;}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Hidden batch controls -->
<asp:HiddenField ID="hdnBatchIDs" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="hfSelectedEmpID" runat="server" ClientIDMode="Static" />
<asp:Button ID="btnBatchDelete" runat="server" ClientIDMode="Static" style="display:none;" OnClick="btnBatchDelete_Click" />
<asp:Button ID="btnBatchCancel" runat="server" ClientIDMode="Static" style="display:none;" OnClick="btnBatchCancel_Click" />

<!-- Page Header -->
<div class="hr-page-header">
    <div class="hr-page-header__left">
        <div class="hr-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M2 11h20M2 19h20M4 7l8-4 8 4M4 15l8-4 8 4"/></svg>
        </div>
        <div>
            <div class="hr-page-header__title">Payroll Allowance Records</div>
            <div class="hr-page-header__sub">Transport, housing, bonuses &amp; other allowances for employees</div>
        </div>
    </div>
    <div class="hr-page-actions">
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="openBatchModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Recurring
        </button>
        <button type="button" class="hr-btn hr-btn--success hr-btn--sm" onclick="openAddModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Add Allowance
        </button>
    </div>
</div>

<!-- Stats -->
<div class="hr-stats">
    <div class="hr-stat hr-stat--pending">
        <div class="hr-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div><div class="hr-stat__val"><asp:Literal ID="litPending" runat="server" Text="0" /></div><div class="hr-stat__label">Pending</div></div>
    </div>
    <div class="hr-stat hr-stat--amount">
        <div class="hr-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg></div>
        <div><div class="hr-stat__val"><asp:Literal ID="litPendingAmt" runat="server" Text="0" /></div><div class="hr-stat__label">Pending Amount</div></div>
    </div>
    <div class="hr-stat hr-stat--settled">
        <div class="hr-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></div>
        <div><div class="hr-stat__val"><asp:Literal ID="litSettled" runat="server" Text="0" /></div><div class="hr-stat__label">Settled This Year</div></div>
    </div>
    <div class="hr-stat hr-stat--cancelled">
        <div class="hr-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6b7280" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg></div>
        <div><div class="hr-stat__val"><asp:Literal ID="litCancelled" runat="server" Text="0" /></div><div class="hr-stat__label">Cancelled</div></div>
    </div>
</div>

<!-- Filters Card -->
<div class="hr-card">
    <div class="hr-filters">
        <div class="hr-filters__top">
            <div class="hr-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="hr-search-box" placeholder="Search by name or staff code…" AutoPostBack="false" />
            </div>
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="document.getElementById('<%= btnSearch.ClientID %>').click()">Search</button>
            <asp:Button ID="btnSearch" runat="server" Text="Search" style="display:none;" OnClick="btnSearch_Click" />
            <asp:Label ID="lblRecordCount" runat="server" CssClass="hr-card__meta" Text="0 records" />
        </div>
        <div class="hr-filters__row">
            <div class="hr-filter-grp">
                <label class="hr-filter-grp__label">Month</label>
                <asp:DropDownList ID="ddlFilterMonth" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="">All Months</asp:ListItem>
                    <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                    <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                    <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                    <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                    <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                    <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="hr-filter-grp">
                <label class="hr-filter-grp__label">Year</label>
                <asp:TextBox ID="txtFilterYear" runat="server" CssClass="hr-filter-select" style="width:80px;" />
            </div>
            <div class="hr-filter-grp">
                <label class="hr-filter-grp__label">Status</label>
                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="">All Statuses</asp:ListItem>
                    <asp:ListItem Value="PENDING">Pending</asp:ListItem>
                    <asp:ListItem Value="SETTLED">Settled</asp:ListItem>
                    <asp:ListItem Value="CANCELLED">Cancelled</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="hr-filter-grp">
                <label class="hr-filter-grp__label">Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="width:80px;">
                    <asp:ListItem Value="25" Selected="True">25</asp:ListItem>
                    <asp:ListItem Value="50">50</asp:ListItem>
                    <asp:ListItem Value="100">100</asp:ListItem>
                </asp:DropDownList>
            </div>
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
            <asp:Button ID="btnReset" runat="server" Text="Reset" style="display:none;" OnClick="btnReset_Click" />
        </div>
    </div>

    <!-- Grid Footer Info -->
    <div class="hr-grid-footer">
        <span><strong><asp:Literal ID="litFilterCount" runat="server" Text="0" /></strong> record(s) shown</span>
    </div>

<!-- Grid -->
<div style="overflow-x:auto;">
<dx:ASPxGridView ID="gvAllowances" runat="server" Width="100%" ClientInstanceName="gvAllowances"
    KeyFieldName="id" EnableCallBacks="true" Theme="Glass"
    OnRowUpdating="gvAllowances_RowUpdating"
    OnRowDeleting="gvAllowances_RowDeleting"
    OnHtmlRowCreated="gvAllowances_HtmlRowCreated">
    <SettingsPager PageSize="25" />
    <Settings ShowFilterRow="False" HorizontalScrollBarMode="Hidden" />
    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="False" />
    <SettingsEditing Mode="PopupEditForm" />
    <SettingsPopup>
        <EditForm Width="500" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
    </SettingsPopup>
    <EditFormLayoutProperties ColCount="2">
        <Items>
            <dx:GridViewColumnLayoutItem ColumnName="allowance_type" ColSpan="2" />
            <dx:GridViewColumnLayoutItem ColumnName="amount"         ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="status"         ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="to_add_month"   ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="to_add_year"    ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="description"    ColSpan="2" />
            <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right" />
        </Items>
    </EditFormLayoutProperties>
    <Columns>
        <dx:GridViewDataTextColumn FieldName="id" Visible="false" />
        <dx:GridViewDataTextColumn FieldName="empID" Visible="false" EditFormSettings-Visible="False" />
        <dx:GridViewDataTextColumn FieldName="payroll_id" Visible="false" EditFormSettings-Visible="False" />

        <dx:GridViewDataTextColumn Caption="" Width="34" Settings-AllowSort="False" Settings-AllowAutoFilter="False" EditFormSettings-Visible="False">
            <HeaderTemplate>
                <input type="checkbox" id="chkSelectAll" onclick="toggleSelectAll(this)"
                       title="Select / deselect all"
                       style="cursor:pointer;accent-color:#16a34a;width:14px;height:14px;" />
            </HeaderTemplate>
            <DataItemTemplate>
                <input type="checkbox" class="hr-row-check" value="<%# Eval("id") %>" onchange="updateBatchToolbar()" />
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff #" Width="68" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-size:10px;font-weight:700;color:#16a34a;font-family:monospace;"><%# Eval("EMP_CODE") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="155" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-weight:600;color:#1a1a2e;font-size:11px;"><%# Eval("emp_name") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataComboBoxColumn FieldName="allowance_type" Caption="Allowance Type" Width="155">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="Transport Allowance"     Value="Transport Allowance" />
                    <dx:ListEditItem Text="Housing Allowance"       Value="Housing Allowance" />
                    <dx:ListEditItem Text="Acting Allowance"        Value="Acting Allowance" />
                    <dx:ListEditItem Text="Hardship Allowance"      Value="Hardship Allowance" />
                    <dx:ListEditItem Text="Annual Bonus"            Value="Annual Bonus" />
                    <dx:ListEditItem Text="Performance Bonus"       Value="Performance Bonus" />
                    <dx:ListEditItem Text="Responsibility Allowance" Value="Responsibility Allowance" />
                    <dx:ListEditItem Text="Uniform / Clothing"      Value="Uniform / Clothing" />
                    <dx:ListEditItem Text="Meal Allowance"          Value="Meal Allowance" />
                    <dx:ListEditItem Text="Overtime Pay"            Value="Overtime Pay" />
                    <dx:ListEditItem Text="Other"                   Value="Other" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <span style="font-size:10px;font-weight:600;background:#f0fdf4;color:#15803d;padding:2px 7px;"><%# Eval("allowance_type") %></span>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataSpinEditColumn FieldName="amount" Caption="Amount (UGX)" Width="110">
            <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" MinValue="0" />
            <DataItemTemplate>
                <span style="font-size:12px;font-weight:700;color:#16a34a;"><%# FormatAmount(Eval("amount")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataSpinEditColumn>

        <dx:GridViewDataComboBoxColumn FieldName="to_add_month" Caption="Month" Width="100">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="JANUARY"   Value="JANUARY" />
                    <dx:ListEditItem Text="FEBRUARY"  Value="FEBRUARY" />
                    <dx:ListEditItem Text="MARCH"     Value="MARCH" />
                    <dx:ListEditItem Text="APRIL"     Value="APRIL" />
                    <dx:ListEditItem Text="MAY"       Value="MAY" />
                    <dx:ListEditItem Text="JUNE"      Value="JUNE" />
                    <dx:ListEditItem Text="JULY"      Value="JULY" />
                    <dx:ListEditItem Text="AUGUST"    Value="AUGUST" />
                    <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                    <dx:ListEditItem Text="OCTOBER"   Value="OCTOBER" />
                    <dx:ListEditItem Text="NOVEMBER"  Value="NOVEMBER" />
                    <dx:ListEditItem Text="DECEMBER"  Value="DECEMBER" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <span style="font-size:11px;font-weight:700;color:#333;"><%# Eval("to_add_month") %></span>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataSpinEditColumn FieldName="to_add_year" Caption="Year" Width="66">
            <PropertiesSpinEdit DisplayFormatString="0" NumberType="Integer" MinValue="2020" MaxValue="2099" />
        </dx:GridViewDataSpinEditColumn>

        <dx:GridViewDataComboBoxColumn FieldName="status" Caption="Status" Width="105">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="PENDING"   Value="PENDING" />
                    <dx:ListEditItem Text="CANCELLED" Value="CANCELLED" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <%# GetStatusBadge(Eval("status")) %>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataMemoColumn FieldName="description" Caption="Description" Width="160">
            <PropertiesMemoEdit Rows="3" />
            <DataItemTemplate>
                <span style="font-size:10px;color:#555;" title="<%# Eval("description") %>">
                    <%# TruncStr(Eval("description"), 40) %>
                </span>
            </DataItemTemplate>
        </dx:GridViewDataMemoColumn>

        <dx:GridViewDataTextColumn FieldName="payroll_title" Caption="Payroll Ref" Width="105" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <%# GetPayrollRef(Eval("payroll_title"), Eval("payment_date")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="date_recorded" Caption="Recorded" Width="80" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-size:10px;color:#888;"><%# FormatDate(Eval("date_recorded")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn Caption="" Width="80" EditFormSettings-Visible="False" Settings-AllowAutoFilter="False" Settings-AllowSort="False">
            <DataItemTemplate>
                <%# GetActionHtml(Eval("id"), Eval("status")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>
    </Columns>
</dx:ASPxGridView>
</div>

<!-- Batch toolbar -->
<div class="hr-batch-toolbar" id="batchToolbar">
    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
    <div class="hr-batch-info"><strong id="batchCount">0</strong> selected</div>
    <div class="hr-batch-sep"></div>
    <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatchCancel()">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        Cancel
    </button>
    <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="doBatchDelete()" style="color:#dc3545;">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
        Delete
    </button>
    <div class="hr-batch-sep"></div>
    <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="clearBatchSelection()">Clear</button>
</div>
</div>

<!-- MODAL: Add Single Allowance -->
<div class="hr-modal-overlay" id="addAllowanceModal" onclick="if(event.target===this) closeAddModal()">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span class="hr-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Add Allowance Record
            </span>
            <button type="button" class="hr-modal__close" onclick="closeAddModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="addResult" class="hr-result"></div>
            <div class="hr-section-label">Employee &amp; Allowance</div>
            
            <!-- Employee Autocomplete -->
            <div class="hr-form-row" style="margin-bottom: 0;">
                <div class="hr-form-group" style="flex: 1;">
                    <label class="hr-form-label">Employee <span class="req">*</span></label>
                    <div class="hr-ac">
                        <input type="text" id="acAddInput" class="hr-ac__input" placeholder="Search by name or staff #…" autocomplete="off" />
                        <div id="acAddSpinner" class="hr-ac__spinner"></div>
                        <button type="button" id="acAddClear" class="hr-ac__clear" title="Clear" onclick="EmployeeAC.clearAdd()">&times;</button>
                        <div id="acAddList" class="hr-ac__list"></div>
                    </div>
                </div>
            </div>
            
            <!-- Selected Employee Card -->
            <div id="selectedEmpCardAdd" class="hr-selected-emp">
                <div class="hr-selected-emp__avatar" id="empAvatarAdd">?</div>
                <div class="hr-selected-emp__info" id="empInfoAdd">
                    <div class="hr-selected-emp__name" id="empNameAdd"></div>
                    <div class="hr-selected-emp__detail" id="empDetailAdd">Staff Code: <span id="empCodeAdd"></span></div>
                </div>
                <button type="button" class="hr-selected-emp__remove" title="Remove" onclick="EmployeeAC.clearAdd()">&times;</button>
            </div>
            
            <div class="hr-form-row">
                <div class="hr-form-group" style="flex: 1;">
                    <label class="hr-form-label">Allowance Type <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddType" runat="server" CssClass="hr-form-input">
                        <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                        <asp:ListItem>Transport Allowance</asp:ListItem>
                        <asp:ListItem>Housing Allowance</asp:ListItem>
                        <asp:ListItem>Acting Allowance</asp:ListItem>
                        <asp:ListItem>Hardship Allowance</asp:ListItem>
                        <asp:ListItem>Annual Bonus</asp:ListItem>
                        <asp:ListItem>Performance Bonus</asp:ListItem>
                        <asp:ListItem>Responsibility Allowance</asp:ListItem>
                        <asp:ListItem>Uniform / Clothing</asp:ListItem>
                        <asp:ListItem>Meal Allowance</asp:ListItem>
                        <asp:ListItem>Overtime Pay</asp:ListItem>
                        <asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Amount (UGX) <span class="req">*</span></label>
                    <asp:TextBox ID="txtAddAmount" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Date Recorded</label>
                    <asp:TextBox ID="txtAddDateRecorded" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
            </div>
            
            <div class="hr-section-label">Payroll Period</div>
            
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Month <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddMonth" runat="server" CssClass="hr-form-input">
                        <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                        <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                        <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                        <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                        <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                        <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Year <span class="req">*</span></label>
                    <asp:TextBox ID="txtAddYear" runat="server" CssClass="hr-form-input" TextMode="Number" />
                </div>
            </div>
            
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Description / Notes</label>
                    <asp:TextBox ID="txtAddDescription" runat="server" CssClass="hr-form-textarea" TextMode="MultiLine" Rows="3" />
                </div>
            </div>
        </div>
        
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeAddModal()">Cancel</button>
            <asp:Button ID="btnAddAllowance" runat="server" Text="Save Allowance" CssClass="hr-btn hr-btn--success hr-btn--sm" OnClick="btnAddAllowance_Click" OnClientClick="return validateAddForm();" />
        </div>
    </div>
</div>

<!-- MODAL: Batch / Recurring Allowances -->
<div class="hr-modal-overlay" id="batchAllowanceModal" onclick="if(event.target===this) closeBatchModal()">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span class="hr-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Create Recurring Allowances
            </span>
            <button type="button" class="hr-modal__close" onclick="closeBatchModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="batchResult" class="hr-result"></div>
            <div class="hr-section-label">Employee &amp; Allowance</div>
            
            <!-- Employee Autocomplete -->
            <div class="hr-form-row" style="margin-bottom: 0;">
                <div class="hr-form-group" style="flex: 1;">
                    <label class="hr-form-label">Employee <span class="req">*</span></label>
                    <div class="hr-ac">
                        <input type="text" id="acBatchInput" class="hr-ac__input" placeholder="Search by name or staff #…" autocomplete="off" />
                        <div id="acBatchSpinner" class="hr-ac__spinner"></div>
                        <button type="button" id="acBatchClear" class="hr-ac__clear" title="Clear" onclick="EmployeeAC.clearBatch()">&times;</button>
                        <div id="acBatchList" class="hr-ac__list"></div>
                    </div>
                </div>
            </div>
            
            <!-- Selected Employee Card -->
            <div id="selectedEmpCardBatch" class="hr-selected-emp">
                <div class="hr-selected-emp__avatar" id="empAvatarBatch">?</div>
                <div class="hr-selected-emp__info" id="empInfoBatch">
                    <div class="hr-selected-emp__name" id="empNameBatch"></div>
                    <div class="hr-selected-emp__detail" id="empDetailBatch">Staff Code: <span id="empCodeBatch"></span></div>
                </div>
                <button type="button" class="hr-selected-emp__remove" title="Remove" onclick="EmployeeAC.clearBatch()">&times;</button>
            </div>
            
            <div class="hr-form-row">
                <div class="hr-form-group" style="flex: 1;">
                    <label class="hr-form-label">Allowance Type <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlBatchType" runat="server" CssClass="hr-form-input">
                        <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                        <asp:ListItem>Transport Allowance</asp:ListItem>
                        <asp:ListItem>Housing Allowance</asp:ListItem>
                        <asp:ListItem>Acting Allowance</asp:ListItem>
                        <asp:ListItem>Hardship Allowance</asp:ListItem>
                        <asp:ListItem>Annual Bonus</asp:ListItem>
                        <asp:ListItem>Performance Bonus</asp:ListItem>
                        <asp:ListItem>Responsibility Allowance</asp:ListItem>
                        <asp:ListItem>Uniform / Clothing</asp:ListItem>
                        <asp:ListItem>Meal Allowance</asp:ListItem>
                        <asp:ListItem>Overtime Pay</asp:ListItem>
                        <asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Amount per Month (UGX) <span class="req">*</span></label>
                    <asp:TextBox ID="txtBatchAmount" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Number of Months <span class="req">*</span></label>
                    <asp:TextBox ID="txtBatchMonths" runat="server" CssClass="hr-form-input" TextMode="Number" Text="1" />
                    <span class="hr-hint">Max 60 months</span>
                </div>
            </div>
            
            <div class="hr-section-label">Starting Payroll Period</div>
            
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Month <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlBatchStartMonth" runat="server" CssClass="hr-form-input" onchange="updateBatchPreview()">
                        <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                        <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                        <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                        <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                        <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                        <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Year <span class="req">*</span></label>
                    <asp:TextBox ID="txtBatchStartYear" runat="server" CssClass="hr-form-input" TextMode="Number" onchange="updateBatchPreview()" />
                </div>
            </div>
            
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Description / Notes</label>
                    <asp:TextBox ID="txtBatchDescription" runat="server" CssClass="hr-form-textarea" TextMode="MultiLine" Rows="2"
                        placeholder="E.g. Monthly transport - {n} of 12" />
                    <span class="hr-hint">Use <strong>{n}</strong> as a placeholder for month number (e.g. 1, 2, 3…)</span>
                </div>
            </div>
            
            <div class="batch-preview">
                <div class="batch-preview__title">Preview - months to be created:</div>
                <div id="batchPreviewList" class="batch-preview__list">
                    <span class="batch-preview__empty">Fill in the fields above to preview</span>
                </div>
            </div>
        </div>
        
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeBatchModal()">Cancel</button>
            <asp:Button ID="btnBatchCreate" runat="server" Text="Create Records" CssClass="hr-btn hr-btn--success hr-btn--sm" OnClick="btnBatchCreate_Click" OnClientClick="return validateBatchForm();" />
        </div>
    </div>
</div>

<script>
var MONTHS_ARR=['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];

/* ===== EMPLOYEE AUTOCOMPLETE ============================================ */
var EmployeeAC = (function() {
    var addInput, addList, addSpinner, addClear, batchInput, batchList, batchSpinner, batchClear;
    var addTimer = null, batchTimer = null, addXhr = null, batchXhr = null;
    var addActiveIdx = -1, batchActiveIdx = -1, addResults = [], batchResults = [];
    var addSelected = null, batchSelected = null;
    var DEBOUNCE = 250, MIN_CHARS = 1;

    function init() {
        addInput = document.getElementById('acAddInput');
        addList = document.getElementById('acAddList');
        addSpinner = document.getElementById('acAddSpinner');
        addClear = document.getElementById('acAddClear');
        batchInput = document.getElementById('acBatchInput');
        batchList = document.getElementById('acBatchList');
        batchSpinner = document.getElementById('acBatchSpinner');
        batchClear = document.getElementById('acBatchClear');
        console.log('EmployeeAC.init() - Elements found:', { 
            addInput: !!addInput, addList: !!addList, addSpinner: !!addSpinner, addClear: !!addClear,
            batchInput: !!batchInput, batchList: !!batchList, batchSpinner: !!batchSpinner, batchClear: !!batchClear
        }); // DEBUG
        if (!addInput) { console.warn('addInput not found'); return; }

        addInput.addEventListener('input', function() { onInputAdd(); });
        addInput.addEventListener('keydown', function(e) { onKeyDownAdd(e); });
        addInput.addEventListener('focus', function() { if (addResults.length > 0 && !addSelected) showListAdd(); });
        document.addEventListener('click', function(e) {
            if (addInput && !addInput.contains(e.target) && !addList.contains(e.target)) hideListAdd();
            if (batchInput && !batchInput.contains(e.target) && !batchList.contains(e.target)) hideListBatch();
        });
        addClear.addEventListener('click', clearAdd);
        batchClear.addEventListener('click', clearBatch);

        batchInput.addEventListener('input', function() { onInputBatch(); });
        batchInput.addEventListener('keydown', function(e) { onKeyDownBatch(e); });
        batchInput.addEventListener('focus', function() { if (batchResults.length > 0 && !batchSelected) showListBatch(); });
        batchClear.addEventListener('click', clearBatch);
    }

    function onInputAdd() {
        var q = addInput.value.trim();
        if (addSelected) deselectAdd();
        if (addTimer) clearTimeout(addTimer);
        if (addXhr) { addXhr.abort(); addXhr = null; }
        if (q.length < MIN_CHARS) { hideListAdd(); addResults = []; return; }
        addTimer = setTimeout(function() { doSearchAdd(q); }, DEBOUNCE);
    }

    function onKeyDownAdd(e) {
        if (!addList.classList.contains('hr-ac__list--visible')) {
            if (e.keyCode === 40 && addResults.length > 0) { showListAdd(); e.preventDefault(); }
            return;
        }
        if (e.keyCode === 40) { e.preventDefault(); addActiveIdx = Math.min(addActiveIdx + 1, addResults.length - 1); renderActiveAdd(); }
        else if (e.keyCode === 38) { e.preventDefault(); addActiveIdx = Math.max(addActiveIdx - 1, 0); renderActiveAdd(); }
        else if (e.keyCode === 13) { e.preventDefault(); if (addActiveIdx >= 0 && addActiveIdx < addResults.length) selectAdd(addResults[addActiveIdx]); }
        else if (e.keyCode === 27) { hideListAdd(); }
    }

    function onInputBatch() {
        var q = batchInput.value.trim();
        if (batchSelected) deselectBatch();
        if (batchTimer) clearTimeout(batchTimer);
        if (batchXhr) { batchXhr.abort(); batchXhr = null; }
        if (q.length < MIN_CHARS) { hideListBatch(); batchResults = []; return; }
        batchTimer = setTimeout(function() { doSearchBatch(q); }, DEBOUNCE);
    }

    function onKeyDownBatch(e) {
        if (!batchList.classList.contains('hr-ac__list--visible')) {
            if (e.keyCode === 40 && batchResults.length > 0) { showListBatch(); e.preventDefault(); }
            return;
        }
        if (e.keyCode === 40) { e.preventDefault(); batchActiveIdx = Math.min(batchActiveIdx + 1, batchResults.length - 1); renderActiveBatch(); }
        else if (e.keyCode === 38) { e.preventDefault(); batchActiveIdx = Math.max(batchActiveIdx - 1, 0); renderActiveBatch(); }
        else if (e.keyCode === 13) { e.preventDefault(); if (batchActiveIdx >= 0 && batchActiveIdx < batchResults.length) selectBatch(batchResults[batchActiveIdx]); }
        else if (e.keyCode === 27) { hideListBatch(); }
    }

    function doSearchAdd(q) { doSearch(q, 'Add', function(r) { renderListAdd(q); }, function() { hideSpinnerAdd(); }, function(x) { addXhr = x; }, function() { showSpinnerAdd(); }); }
    function doSearchBatch(q) { doSearch(q, 'Batch', function(r) { renderListBatch(q); }, function() { hideSpinnerBatch(); }, function(x) { batchXhr = x; }, function() { showSpinnerBatch(); }); }

    function doSearch(q, context, onRender, onHideSpinner, setXhr, onShowSpinner) {
        onShowSpinner();
        var ctx = context === 'Add';
        if (ctx && addXhr) addXhr.abort();
        if (!ctx && batchXhr) batchXhr.abort();
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'HRAllowances.aspx?ajax=search_emp&q=' + encodeURIComponent(q), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            onHideSpinner();
            if (xhr.status === 200) {
                try {
                    // Clean response: trim and take only first JSON object
                    var response = xhr.responseText.trim();
                    // Find the end of the first JSON object
                    var braceCount = 0, endIdx = 0;
                    for (var i = 0; i < response.length; i++) {
                        if (response[i] === '{') braceCount++;
                        if (response[i] === '}') braceCount--;
                        if (braceCount === 0 && response[i] === '}') { endIdx = i + 1; break; }
                    }
                    var cleanResponse = response.substring(0, endIdx);
                    var data = JSON.parse(cleanResponse);
                    if (ctx) { addResults = data.results || []; addActiveIdx = -1; }
                    else { batchResults = data.results || []; batchActiveIdx = -1; }
                    console.log(context + ' search results:', data.results); // DEBUG
                    onRender();
                } catch(ex) { 
                    console.error(context + ' search error:', ex, xhr.responseText); // DEBUG
                    if (ctx) addResults = []; 
                    else batchResults = []; 
                }
            }
        };
        setXhr(xhr);
        xhr.send();
    }

    function renderListAdd(query) { renderList(query, 'Add', addResults, function(i) { selectAdd(addResults[i]); }, function(i) { addActiveIdx = i; renderActiveAdd(); }); }
    function renderListBatch(query) { renderList(query, 'Batch', batchResults, function(i) { selectBatch(batchResults[i]); }, function(i) { batchActiveIdx = i; renderActiveBatch(); }); }

    function renderList(query, context, results, selectCb, activateCb) {
        console.log('renderList called:', { context, resultCount: results.length }); // DEBUG
        var list = context === 'Add' ? addList : batchList;
        var activeIdx = context === 'Add' ? addActiveIdx : batchActiveIdx;
        if (!list) { console.error('List element not found for context:', context); return; } // DEBUG
        if (results.length === 0) {
            list.innerHTML = '<div class="hr-ac__empty">' +
                '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>' +
                'No employees found for &ldquo;' + esc(query) + '&rdquo;</div>';
            (context === 'Add' ? showListAdd : showListBatch)(); return;
        }
        try {
            var html = '';
            for (var i = 0; i < results.length; i++) {
                var r = results[i];
                var initials = getInitials(r.emp_name);
                html += '<div class="hr-ac__item' + (i === activeIdx ? ' hr-ac__item--active' : '') + '" data-idx="' + i + '">' +
                    '<div class="hr-ac__avatar">' + esc(initials) + '</div>' +
                    '<div class="hr-ac__info">' +
                    '<div class="hr-ac__name">' + highlight(r.emp_name, query) + '</div>' +
                    '<div class="hr-ac__meta">' + (r.emp_position || 'Staff') + '</div>' +
                    '</div>' +
                    '<div class="hr-ac__code">' + highlight(r.EMP_CODE || '', query) + '</div>' +
                    '</div>';
            }
            html += '<div class="hr-ac__hint">' + results.length + ' result' + (results.length !== 1 ? 's' : '') + '</div>';
            list.innerHTML = html;
            console.log('HTML rendered into list'); // DEBUG

            var items = list.querySelectorAll('.hr-ac__item');
            console.log('Found items:', items.length); // DEBUG
            for (var j = 0; j < items.length; j++) {
                (function(idx) {
                    items[idx].addEventListener('click', function() { selectCb(idx); });
                    items[idx].addEventListener('mouseenter', function() { activateCb(idx); });
                })(j);
            }
            (context === 'Add' ? showListAdd : showListBatch)();
            console.log('List displayed'); // DEBUG
        } catch(ex) {
            console.error('Error in renderList:', ex, ex.stack); // DEBUG
        }
    }

    function renderActiveAdd() { renderActive(addList, addActiveIdx); }
    function renderActiveBatch() { renderActive(batchList, batchActiveIdx); }

    function renderActive(list, activeIdx) {
        var items = list.querySelectorAll('.hr-ac__item');
        for (var i = 0; i < items.length; i++) items[i].className = 'hr-ac__item' + (i === activeIdx ? ' hr-ac__item--active' : '');
        if (activeIdx >= 0 && items[activeIdx]) items[activeIdx].scrollIntoView({ block: 'nearest' });
    }

    function selectAdd(e) { selectEmployee(e, 'Add'); }
    function selectBatch(e) { selectEmployee(e, 'Batch'); }

    function selectEmployee(emp, context) {
        if (context === 'Add') {
            addSelected = emp;
            hideListAdd();
            addResults = [];
            addInput.value = emp.emp_name + ' [' + emp.EMP_CODE + ']';
            addInput.classList.add('hr-ac__input--selected');
            addClear.classList.add('hr-ac__clear--visible');
            var initials = getInitials(emp.emp_name);
            document.getElementById('selectedEmpCardAdd').className = 'hr-selected-emp hr-selected-emp--visible';
            document.getElementById('empAvatarAdd').textContent = esc(initials);
            document.getElementById('empNameAdd').textContent = esc(emp.emp_name);
            document.getElementById('empCodeAdd').textContent = esc(emp.EMP_CODE || '');
            document.getElementById('hfSelectedEmpID').value = emp.empID;
        } else {
            batchSelected = emp;
            hideListBatch();
            batchResults = [];
            batchInput.value = emp.emp_name + ' [' + emp.EMP_CODE + ']';
            batchInput.classList.add('hr-ac__input--selected');
            batchClear.classList.add('hr-ac__clear--visible');
            var initials = getInitials(emp.emp_name);
            document.getElementById('selectedEmpCardBatch').className = 'hr-selected-emp hr-selected-emp--visible';
            document.getElementById('empAvatarBatch').textContent = esc(initials);
            document.getElementById('empNameBatch').textContent = esc(emp.emp_name);
            document.getElementById('empCodeBatch').textContent = esc(emp.EMP_CODE || '');
            document.getElementById('hfSelectedEmpID').value = emp.empID;
        }
    }

    function deselectAdd() { addSelected = null; addInput.classList.remove('hr-ac__input--selected'); addClear.classList.remove('hr-ac__clear--visible'); document.getElementById('selectedEmpCardAdd').className = 'hr-selected-emp'; }
    function deselectBatch() { batchSelected = null; batchInput.classList.remove('hr-ac__input--selected'); batchClear.classList.remove('hr-ac__clear--visible'); document.getElementById('selectedEmpCardBatch').className = 'hr-selected-emp'; }

    function clearAdd() { deselectAdd(); addInput.value = ''; addInput.focus(); hideListAdd(); addResults = []; }
    function clearBatch() { deselectBatch(); batchInput.value = ''; batchInput.focus(); hideListBatch(); batchResults = []; }

    function showListAdd() { addList.classList.add('hr-ac__list--visible'); }
    function hideListAdd() { addList.classList.remove('hr-ac__list--visible'); addActiveIdx = -1; }
    function showListBatch() { batchList.classList.add('hr-ac__list--visible'); }
    function hideListBatch() { batchList.classList.remove('hr-ac__list--visible'); batchActiveIdx = -1; }
    function showSpinnerAdd() { addSpinner.classList.add('hr-ac__spinner--visible'); addClear.classList.remove('hr-ac__clear--visible'); }
    function hideSpinnerAdd() { addSpinner.classList.remove('hr-ac__spinner--visible'); if (addSelected) addClear.classList.add('hr-ac__clear--visible'); }
    function showSpinnerBatch() { batchSpinner.classList.add('hr-ac__spinner--visible'); batchClear.classList.remove('hr-ac__clear--visible'); }
    function hideSpinnerBatch() { batchSpinner.classList.remove('hr-ac__spinner--visible'); if (batchSelected) batchClear.classList.add('hr-ac__clear--visible'); }

    function highlight(text, query) {
        if (!text || !query) return esc(text || '');
        var words = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').split(/\s+/).filter(function(w) { return w.length > 0; });
        if (words.length === 0) return esc(text);
        var re = new RegExp('(' + words.join('|') + ')', 'gi');
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

    return { init: init, clearAdd: clearAdd, clearBatch: clearBatch };
})();

/* -- Action popovers -- */
function toggleActionPopover(btn,evt){evt.stopPropagation();var pop=btn.nextElementSibling;var isOpen=pop.classList.contains('is-open');closeAllPopovers();if(!isOpen)pop.classList.add('is-open');}
function closeAllPopovers(){document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){p.classList.remove('is-open');});}
document.addEventListener('click',closeAllPopovers);

/* -- Modals -- */
function openAddModal(){
    var m = document.getElementById('addAllowanceModal');
    m.style.display='flex';
    var r=document.getElementById('addResult');r.innerHTML='';r.className='hr-result';
    EmployeeAC.init();
    document.getElementById('acAddInput').focus();
}
function closeAddModal(){document.getElementById('addAllowanceModal').style.display='none';}
function openBatchModal(){
    var m = document.getElementById('batchAllowanceModal');
    m.style.display='flex';
    var r=document.getElementById('batchResult');r.innerHTML='';r.className='hr-result';
    EmployeeAC.init();
    document.getElementById('acBatchInput').focus();
    updateBatchPreview();
}
function closeBatchModal(){document.getElementById('batchAllowanceModal').style.display='none';}
document.addEventListener('keydown',function(e){
    if(e.key==='Escape'){closeAddModal();closeBatchModal();}
});

/* -- Grid helpers (DX v16.1) -- */
function gridFindIndex(gName,key){
    var g=window[gName];var c=g.GetVisibleRowsOnPage();
    for(var i=0;i<c;i++)if(String(g.GetRowKey(i))===String(key))return i;
    return -1;
}
function gridEdit(gName,key){closeAllPopovers();var idx=gridFindIndex(gName,key);if(idx>=0)window[gName].StartEditRow(idx);}
function gridDelete(gName,key){
    closeAllPopovers();
    if(!confirm('Delete this allowance record? This cannot be undone.'))return;
    var idx=gridFindIndex(gName,key);if(idx>=0)window[gName].DeleteRow(idx);
}

/* -- Single row cancel -- */
function singleCancel(id){
    closeAllPopovers();
    if(!confirm('Mark this allowance as CANCELLED?'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=id;
    document.getElementById('<%= btnBatchCancel.ClientID %>').click();
}

/* -- Batch toolbar -- */
function updateBatchToolbar(){
    var checked=document.querySelectorAll('.hr-row-check:checked');
    var all=document.querySelectorAll('.hr-row-check');
    var tb=document.getElementById('batchToolbar');
    var cnt=document.getElementById('batchCount');
    if(checked.length>0){tb.style.display='flex';cnt.textContent=checked.length;}
    else tb.style.display='none';
    var chk=document.getElementById('chkSelectAll');
    if(chk){chk.indeterminate=(checked.length>0&&checked.length<all.length);chk.checked=all.length>0&&checked.length===all.length;}
}
function toggleSelectAll(cb){document.querySelectorAll('.hr-row-check').forEach(function(c){c.checked=cb.checked;});updateBatchToolbar();}
function clearBatchSelection(){
    document.querySelectorAll('.hr-row-check').forEach(function(c){c.checked=false;});
    var chk=document.getElementById('chkSelectAll');if(chk){chk.checked=false;chk.indeterminate=false;}
    updateBatchToolbar();
}
function getBatchIDs(){var ids=[];document.querySelectorAll('.hr-row-check:checked').forEach(function(c){ids.push(c.value);});return ids.join(',');}
function doBatchCancel(){
    var n=document.querySelectorAll('.hr-row-check:checked').length;
    if(!n||!confirm('Mark '+n+' allowance(s) as CANCELLED?'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=getBatchIDs();
    document.getElementById('<%= btnBatchCancel.ClientID %>').click();
}
function doBatchDelete(){
    var n=document.querySelectorAll('.hr-row-check:checked').length;
    if(!n||!confirm('Permanently delete '+n+' record(s)? This cannot be undone.'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=getBatchIDs();
    document.getElementById('<%= btnBatchDelete.ClientID %>').click();
}

/* -- Batch preview -- */
function updateBatchPreview(){
    var pv=document.getElementById('batchPreviewList');if(!pv)return;
    var selEl=document.getElementById('<%= ddlBatchStartMonth.ClientID %>');
    var yrEl=document.getElementById('<%= txtBatchStartYear.ClientID %>');
    var numEl=document.getElementById('<%= txtBatchMonths.ClientID %>');
    if(!selEl||!yrEl||!numEl){return;}
    var startMon=MONTHS_ARR.indexOf(selEl.value);
    var startYr=parseInt(yrEl.value,10);
    var num=parseInt(numEl.value,10);
    if(startMon<0||isNaN(startYr)||isNaN(num)||num<1){pv.innerHTML='<span class="batch-preview__empty">Fill in all fields above</span>';return;}
    num=Math.min(num,60);
    var html='';
    for(var i=0;i<num;i++){
        var m=(startMon+i)%12;var y=startYr+Math.floor((startMon+i)/12);
        html+='<span class="batch-preview__item">'+MONTHS_ARR[m]+' '+y+'</span>';
    }
    pv.innerHTML=html;
}
(function(){
    var n=document.getElementById('<%= txtBatchMonths.ClientID %>');
    if(n)n.addEventListener('input',updateBatchPreview);
})();

/* -- Search on Enter -- */
(function(){
    var sb=document.getElementById('<%= txtSearch.ClientID %>');
    if(sb)sb.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();document.getElementById('<%= btnSearch.ClientID %>').click();}});
    var yr=document.getElementById('<%= txtFilterYear.ClientID %>');
    if(yr)yr.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();document.getElementById('<%= btnSearch.ClientID %>').click();}});
})();

/* -- Form Validation -- */
function validateAddForm() {
    var empID = document.getElementById('hfSelectedEmpID').value;
    var type = document.getElementById('<%= ddlAddType.ClientID %>').value;
    var amount = document.getElementById('<%= txtAddAmount.ClientID %>').value;
    var month = document.getElementById('<%= ddlAddMonth.ClientID %>').value;
    var year = document.getElementById('<%= txtAddYear.ClientID %>').value;
    
    var resultEl = document.getElementById('addResult');
    resultEl.innerHTML = '';
    resultEl.className = 'hr-result';
    
    if (!empID || empID.trim() === '') {
        resultEl.innerHTML = 'Please select an employee.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!type || type.trim() === '') {
        resultEl.innerHTML = 'Please select an allowance type.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!amount || parseFloat(amount) <= 0) {
        resultEl.innerHTML = 'Please enter a valid amount greater than 0.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!year || isNaN(year) || year < 2020 || year > 2099) {
        resultEl.innerHTML = 'Please enter a valid year (2020-2099).';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!month || month.trim() === '') {
        resultEl.innerHTML = 'Please select a valid month.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    
    return true;
}

function validateBatchForm() {
    var empID = document.getElementById('hfSelectedEmpID').value;
    var type = document.getElementById('<%= ddlBatchType.ClientID %>').value;
    var amount = document.getElementById('<%= txtBatchAmount.ClientID %>').value;
    var months = document.getElementById('<%= txtBatchMonths.ClientID %>').value;
    var startMonth = document.getElementById('<%= ddlBatchStartMonth.ClientID %>').value;
    var startYear = document.getElementById('<%= txtBatchStartYear.ClientID %>').value;
    
    var resultEl = document.getElementById('batchResult');
    resultEl.innerHTML = '';
    resultEl.className = 'hr-result';
    
    if (!empID || empID.trim() === '') {
        resultEl.innerHTML = 'Please select an employee.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!type || type.trim() === '') {
        resultEl.innerHTML = 'Please select an allowance type.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!amount || parseFloat(amount) <= 0) {
        resultEl.innerHTML = 'Please enter a valid amount greater than 0.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!months || isNaN(months) || parseInt(months) < 1 || parseInt(months) > 60) {
        resultEl.innerHTML = 'Please enter a valid number of months (1-60).';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!startMonth || startMonth.trim() === '') {
        resultEl.innerHTML = 'Please select a start month.';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    if (!startYear || isNaN(startYear) || startYear < 2020 || startYear > 2099) {
        resultEl.innerHTML = 'Please enter a valid start year (2020-2099).';
        resultEl.className = 'hr-result hr-result--err';
        return false;
    }
    
    return true;
}

/* -- Initialize on document ready -- */
document.addEventListener('DOMContentLoaded', function() {
    EmployeeAC.init();
});
</script>
</asp:Content>