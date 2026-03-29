<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRDeductions.aspx.cs"
    Inherits="COOPERP_NewScreens_HRDeductions"
    Title="Payroll Deduction Records - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* == Payroll Deduction Records - Modern Design System ===== */
.pr-page-header { display: flex !important; align-items: center; justify-content: space-between; padding: 16px 0 14px; margin-bottom: 18px; border-bottom: 2px solid #05275C; flex-wrap: wrap; gap: 12px; }
.pr-page-header__left { display: flex !important; align-items: center; gap: 14px; min-width: 0; }
.pr-page-icon { width: 42px; height: 42px; background: linear-gradient(135deg, #05275C 0%, #041d45 100%); color: #fff; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 4px; box-shadow: 0 2px 6px rgba(5,39,92,0.15); }
.pr-page-title { font-size: 18px; font-weight: 700; color: #1a1a2e; line-height: 1.2; margin: 0; }
.pr-page-sub { font-size: 12px; color: #666; margin-top: 3px; }
.pr-hdr-actions { display: flex !important; gap: 8px; flex-wrap: wrap; align-items: center; }

/* Stats */
.ct-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 18px; }
.ct-stat { background: #fff; border: 1px solid #d0d5dd; padding: 14px 16px; display: flex; align-items: center; gap: 12px; position: relative; overflow: hidden; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); transition: all .15s ease; }
.ct-stat:hover { border-color: #05275C; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
.ct-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.ct-stat__icon { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 18px; border-radius: 3px; }
.ct-stat__val { font-size: 16px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.ct-stat__label { font-size: 10px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 3px; font-weight: 600; }
.ct-stat--amber { --stat-c: #f59e0b; } .ct-stat--amber .ct-stat__icon { background: #fff3e0; } .ct-stat--amber .ct-stat__val { color: #d97706; }
.ct-stat--blue { --stat-c: #16a34a; } .ct-stat--blue .ct-stat__icon { background: #dcfce7; } .ct-stat--blue .ct-stat__val { color: #16a34a; }
.ct-stat--green { --stat-c: #28a745; } .ct-stat--green .ct-stat__icon { background: #dcfce7; } .ct-stat--green .ct-stat__val { color: #28a745; }
.ct-stat--grey { --stat-c: #6c757d; } .ct-stat--grey .ct-stat__icon { background: #f3f4f6; } .ct-stat--grey .ct-stat__val { color: #6c757d; }

/* Filters */
.ct-filters { background: #fff; border: 1px solid #d0d5dd; overflow: hidden; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 14px; }
.ct-filters__top { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; padding: 12px 16px; border-bottom: 1px solid #d0d5dd; background: #f8f9fb; }
.ct-search-wrap { display: flex; align-items: center; gap: 6px; flex: 1 1 250px; min-width: 180px; position: relative; }
.ct-search-icon { position: absolute; left: 10px; pointer-events: none; width: 16px; height: 16px; }
.ct-search-box { height: 36px; padding: 8px 12px 8px 34px; border: 1px solid #d0d5dd; font-size: 12px; color: #333; width: 100%; box-sizing: border-box; border-radius: 3px; transition: all .15s ease; }
.ct-search-box:focus { border-color: #05275C; outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,0.1); background: #fff; }
.ct-search-box::placeholder { color: #999; }
.ct-filters__count { font-size: 11px; color: #999; white-space: nowrap; }
.ct-filters__row { display: flex; align-items: flex-start; gap: 12px; flex-wrap: wrap; padding: 12px 16px; background: #f8f9fb; }
.ct-filter-grp { display: flex; flex-direction: column; gap: 4px; }
.ct-filter-grp__label { font-size: 10px; text-transform: uppercase; letter-spacing: .5px; color: #666; font-weight: 600; }
.ct-filter-select { border: 1px solid #d0d5dd; padding: 7px 10px; font-size: 12px; background: #fff; color: #333; cursor: pointer; min-width: 120px; border-radius: 3px; transition: all .15s ease; }
.ct-filter-select:hover { border-color: #05275C; }
.ct-filter-select:focus { border-color: #05275C; outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,0.1); }
.ct-filter-sep { width: 1px; height: 28px; background: #d0d5dd; margin: 0 4px; flex-shrink: 0; }

/* Buttons */
.hr-btn { display: inline-flex !important; align-items: center; justify-content: center; gap: 6px; padding: 7px 14px; min-height: 36px; font-size: 12px; font-weight: 600; white-space: nowrap; border: 1px solid transparent; border-radius: 3px; cursor: pointer; transition: all .15s ease; text-decoration: none; appearance: none; user-select: none; visibility: visible !important; }
.hr-btn:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 2px 8px rgba(0,0,0,0.12); }
.hr-btn:active:not(:disabled) { transform: translateY(0); }
.hr-btn:focus { box-shadow: 0 0 0 3px rgba(5,39,92,0.15); outline: none; }
.hr-btn:disabled { opacity: .6; cursor: not-allowed; }
.hr-btn--primary { background: #05275C !important; color: #fff !important; border-color: #05275C !important; } .hr-btn--primary:hover:not(:disabled) { background: #041d45 !important; border-color: #041d45 !important; }
.hr-btn--success { background: #16a34a !important; color: #fff !important; border-color: #16a34a !important; } .hr-btn--success:hover:not(:disabled) { background: #15803d !important; border-color: #15803d !important; }
.hr-btn--danger { background: #16a34a !important; color: #fff !important; border-color: #16a34a !important; } .hr-btn--danger:hover:not(:disabled) { background: #15803d !important; border-color: #15803d !important; }
.hr-btn--amber { background: #f59e0b !important; color: #fff !important; border-color: #f59e0b !important; } .hr-btn--amber:hover:not(:disabled) { background: #d97706 !important; border-color: #d97706 !important; }
.hr-btn--ghost { background: transparent !important; border: 1px solid #d0d5dd !important; color: #666 !important; } .hr-btn--ghost:hover:not(:disabled) { background: #f5f7fa !important; border-color: #05275C !important; color: #05275C !important; }
.hr-btn--sm { padding: 6px 10px; font-size: 10px; min-height: 32px; }

/* Batch toolbar */
.ct-batch-toolbar { display: none; align-items: center; gap: 10px; flex-wrap: wrap; padding: 10px 14px; background: linear-gradient(135deg, #dcfce7 0%, #f0fdf4 100%); border-top: 2px solid #16a34a; border-bottom: 2px solid #16a34a; box-shadow: 0 2px 4px rgba(22,163,74,0.1); animation: slideDown .2s ease; }
.ct-batch-info { display: flex; align-items: center; gap: 6px; font-size: 11px; color: #15803d; white-space: nowrap; }
.ct-batch-info strong { font-size: 13px; font-weight: 700; color: #15803d; }
.ct-batch-sep { width: 1px; height: 26px; background: #a3e635; margin: 0 2px; flex-shrink: 0; }
.ct-row-check { cursor: pointer; width: 16px; height: 16px; accent-color: #16a34a; vertical-align: middle; }
.ct-row-check:focus { outline: 2px solid #05275C; outline-offset: 2px; }

/* Action popover */
.cd-action-wrapper { position: relative; display: inline-block; }
.cd-action-trigger { background: none; border: none; cursor: pointer; padding: 6px 8px; color: #666; border-radius: 3px; display: flex; align-items: center; justify-content: center; transition: all .15s ease; width: 32px; height: 32px; }
.cd-action-trigger:hover { background: #f0f0f0; color: #05275C; }
.cd-action-trigger:focus { outline: none; box-shadow: 0 0 0 2px rgba(5,39,92,.15); }
.cd-action-popover { display: none; position: absolute; right: -8px; top: calc(100% + 4px); background: #fff; border: 1px solid #d0d5dd; box-shadow: 0 6px 16px rgba(0,0,0,0.18); z-index: 9999; min-width: 180px; border-radius: 4px; overflow: hidden; }
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

/* Modal */
.hr-modal-overlay { display: none !important; position: fixed !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; background: rgba(0,0,0,.55) !important; z-index: 1000 !important; justify-content: center !important; align-items: flex-start !important; padding: 20px 15px !important; overflow-y: auto !important; box-sizing: border-box !important; animation: fadeIn .2s ease !important; }
.hr-modal-overlay.is-open { display: flex !important; }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.hr-modal { background: #fff !important; border: 1px solid #d0d5dd !important; width: 100% !important; max-width: 560px !important; margin: auto !important; position: relative !important; border-radius: 4px !important; box-shadow: 0 10px 40px rgba(0,0,0,0.15) !important; animation: slideIn .2s ease !important; display: flex !important; flex-direction: column !important; max-height: 90vh !important; }
.hr-modal:before { content: '' !important; }
@keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
.hr-modal--wide { max-width: 680px; }
.hr-modal__header { display: flex !important; align-items: center; justify-content: space-between; padding: 14px 18px; background: #05275C; color: #fff; border-radius: 4px 4px 0 0; }
.hr-modal__title { font-size: 13px; font-weight: 700; display: flex !important; align-items: center; gap: 8px; }
.hr-modal__close { background: none; border: none; font-size: 18px; cursor: pointer; color: rgba(255,255,255,.8); padding: 2px 4px; line-height: 1; transition: all .15s ease; border-radius: 2px; }
.hr-modal__close:hover { color: #fff; background: rgba(255,255,255,.15); }
.hr-modal__close:focus { outline: none; background: rgba(255,255,255,.15); }
.hr-modal__body { display: block !important; padding: 18px; max-height: calc(92vh - 180px); overflow-y: auto; }
.hr-modal__footer { display: flex !important; align-items: center; justify-content: flex-end; gap: 10px; padding: 12px 18px; border-top: 1px solid #e0e0e0; background: #f8f9fa !important; flex-shrink: 0; }

/* Form */
.hr-form-row { display: grid !important; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; width: 100%; box-sizing: border-box; }
.hr-form-row3 { display: grid !important; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-bottom: 12px; width: 100%; box-sizing: border-box; }
.hr-form-group { display: flex !important; flex-direction: column; gap: 4px; min-width: 0; }
.hr-form-group--full { grid-column: span 2 !important; }
.hr-label { font-size: 11px; font-weight: 600; color: #333; display: block; }
.hr-label span { color: #05275C; }
.hr-input, .hr-select { height: 36px; padding: 7px 9px; border: 1px solid #d0d5dd; font-size: 12px; color: #1a1a2e; width: 100%; box-sizing: border-box; border-radius: 3px; transition: all .15s ease; display: block !important; }
.hr-input:focus, .hr-select:focus { outline: none; border-color: #05275C; box-shadow: 0 0 0 2px rgba(5,39,92,0.1); background: #fff; }
.hr-input::placeholder { color: #999; }
.hr-textarea { padding: 8px 9px; border: 1px solid #d0d5dd; font-size: 12px; color: #1a1a2e; width: 100%; box-sizing: border-box; resize: vertical; min-height: 60px; border-radius: 3px; transition: all .15s ease; font-family: inherit; display: block !important; }
.hr-textarea:focus { outline: none; border-color: #dc3545; box-shadow: 0 0 0 2px rgba(220,53,69,0.1); }
.hr-textarea::placeholder { color: #999; }
.hr-hint { font-size: 10px; color: #999; margin-top: 2px; font-weight: 500; }
.hr-result { display: none; padding: 10px 12px; font-size: 11px; font-weight: 600; margin-bottom: 10px; border-left: 3px solid; border-radius: 2px; }
.hr-result--ok { background: #dcfce7; border-color: #28a745; color: #155724; display: block; }
.hr-result--err { background: #fde8e8; border-color: #dc3545; color: #8b1a1a; display: block; }

/* Section label */
.hr-section-label { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: #05275C; border-bottom: 2px solid #d0d5dd; padding-bottom: 6px; margin: 16px 0 12px; }

/* Batch preview */
.batch-preview { margin-top: 14px; padding-top: 14px; border-top: 1px solid #d0d5dd; }
.batch-preview__title { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: #333; margin-bottom: 8px; }
.batch-preview__list { display: flex; flex-wrap: wrap; gap: 6px; max-height: 120px; overflow-y: auto; padding: 2px; }
.batch-preview__item { background: #dcfce7; color: #15803d; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid #bbf7d0; border-radius: 3px; }
.batch-preview__empty { font-size: 11px; color: #999; font-style: italic; }

/* Count bar */
.pr-count-bar { font-size: 11px; color: #888; padding: 10px 14px; background: #f8f9fb; border: 1px solid #d0d5dd; border-top: none; display: flex; align-items: center; justify-content: space-between; }

/* DevExpress overrides */
.dxgvControl_Glass { border: 1px solid #e0e5ed !important; }
.dxgvHeader_Glass td { font-size: 10px !important; text-transform: uppercase !important; letter-spacing: .3px !important; background: #f5f7fa !important; color: #555 !important; border-bottom: 2px solid #e0e5ed !important; padding: 9px 12px !important; font-weight: 600 !important; }
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td { font-size: 11px !important; color: #1a1a2e !important; padding: 8px 12px !important; border-bottom: 1px solid #f0f2f5 !important; vertical-align: middle !important; position: relative !important; }
.dxgvDataRow_Glass:hover td, .dxgvDataRowAlt_Glass:hover td { background: #f8f9fb !important; }
.dxgvFilterRow_Glass td { padding: 4px 6px !important; background: #fff !important; }
.dxgvFilterRow_Glass input { border: 1px solid #e0e5ed !important; font-size: 11px !important; padding: 3px 6px !important; }
.dxgvPagerBar_Glass { background: #f5f7fa !important; border-top: 1px solid #e0e5ed !important; padding: 6px 12px !important; }
.dxgv td { overflow: visible !important; }
.cd-action-wrapper { position: relative !important; z-index: 100; }

/* Badges */
.pr-badge { display: inline-block; padding: 4px 10px; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; border-radius: 3px; }
.pr-badge--pending { background: #fef3c7; color: #92400e; }
.pr-badge--settled { background: #dcfce7; color: #166534; }
.pr-badge--cancelled { background: #e5e7eb; color: #374151; }

/* Responsive */
@media (max-width: 1200px) { .ct-stats { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 900px) { .ct-stats { grid-template-columns: repeat(2, 1fr); } .ct-filters__row { gap: 8px; } .ct-filter-select { min-width: auto; flex: 1; } }
@media (max-width: 768px) { .ct-stats { grid-template-columns: 1fr 1fr; } .pr-page-header__left { flex-wrap: wrap; width: 100%; } .pr-hdr-actions { width: 100%; } .ct-filters__row { gap: 6px; } .ct-filter-select { min-width: auto; flex: 1; } .hr-modal { width: 95vw; } .hr-form-row { gap: 8px; } .hr-btn { min-height: 38px; padding: 8px 12px; } .hr-btn--sm { min-height: 34px; padding: 6px 10px; } }
@media (max-width: 600px) { .ct-stats { grid-template-columns: 1fr; } .pr-page-icon { width: 36px; height: 36px; font-size: 18px; } .pr-page-title { font-size: 15px; } .hr-modal { width: 98vw; border-radius: 8px; } .hr-modal__body { padding: 14px; } .hr-modal__footer { flex-direction: column-reverse; gap: 6px; } .hr-modal__footer .hr-btn { width: 100%; } .ct-filters__top { gap: 6px; } .ct-filters { padding: 8px 10px; } .ct-filter-select { padding: 8px 10px; font-size: 12px; min-width: 100px; } .ct-search-wrap { max-width: 100%; } .hr-form-row { gap: 8px; margin-bottom: 10px; } .hr-form-group { min-width: 100%; } .hr-input, .hr-select, .hr-textarea { padding: 8px 10px; } .hr-label { font-size: 11px; } .hr-btn { min-height: 40px; padding: 10px 14px; font-size: 12px; } .hr-btn--sm { min-height: 36px; padding: 8px 12px; font-size: 11px; } .pr-page-header { gap: 8px; } .ct-batch-toolbar { padding: 6px 10px; gap: 6px; } }

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

/* FORCE DISPLAY FOR ALL BUTTONS AND FORMS */
.hr-btn, .hr-btn--primary, .hr-btn--danger, .hr-btn--ghost, .hr-btn--ghost, .hr-btn--sm { display: inline-flex !important; visibility: visible !important; }
.hr-form-row, .hr-form-row3, .hr-form-group, .hr-label, .hr-input, .hr-select, .hr-textarea { display: block !important; visibility: visible !important; }
.pr-page-header, .pr-hdr-actions { display: flex !important; visibility: visible !important; }
.hr-modal-overlay { position: fixed !important; }
.hr-modal { display: block !important; }

/* ==== AGGRESSIVE MODAL OVERRIDES ======= */
#addDeductionModal { position: fixed !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; background: rgba(0,0,0,.55) !important; z-index: 9999 !important; display: none !important; justify-content: center !important; align-items: flex-start !important; padding: 20px 15px !important; overflow-y: auto !important; box-sizing: border-box !important; pointer-events: auto !important; }
#addDeductionModal.is-open { display: flex !important; pointer-events: auto !important; }
#batchDeductionModal { position: fixed !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; background: rgba(0,0,0,.55) !important; z-index: 9999 !important; display: none !important; justify-content: center !important; align-items: flex-start !important; padding: 20px 15px !important; overflow-y: auto !important; box-sizing: border-box !important; pointer-events: auto !important; }
#batchDeductionModal.is-open { display: flex !important; pointer-events: auto !important; }
/* Grid z-index management */
.dxgvControl_Glass { z-index: 1 !important; }
#addDeductionModal .hr-modal, #batchDeductionModal .hr-modal { background: #ffffff !important; border: 1px solid #d0d5dd !important; border-radius: 4px !important; box-shadow: 0 10px 40px rgba(0,0,0,0.15) !important; display: flex !important; flex-direction: column !important; max-height: 90vh !important; width: 100% !important; max-width: 560px !important; z-index: 10000 !important; position: relative !important; pointer-events: auto !important; }
#batchDeductionModal .hr-modal { max-width: 680px !important; }
#addDeductionModal .hr-modal__header, #batchDeductionModal .hr-modal__header { display: flex !important; align-items: center !important; justify-content: space-between !important; padding: 14px 18px !important; background: #05275C !important; color: #ffffff !important; border-radius: 4px 4px 0 0 !important; border: none !important; pointer-events: auto !important; }
#addDeductionModal .hr-modal__body, #batchDeductionModal .hr-modal__body { display: block !important; padding: 18px !important; max-height: calc(90vh - 140px) !important; overflow-y: auto !important; flex: 1 !important; pointer-events: auto !important; }
#addDeductionModal .hr-modal__footer, #batchDeductionModal .hr-modal__footer { display: flex !important; align-items: center !important; justify-content: flex-end !important; gap: 10px !important; padding: 12px 18px !important; border-top: 1px solid #e0e0e0 !important; background: #f8f9fa !important; flex-shrink: 0 !important; pointer-events: auto !important; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Hidden batch controls -->
<asp:HiddenField ID="hdnBatchIDs" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="hfSelectedEmpID" runat="server" ClientIDMode="Static" />
<asp:Button ID="btnBatchDelete" runat="server" style="display:none;" OnClick="btnBatchDelete_Click" ClientIDMode="Static" />
<asp:Button ID="btnBatchCancel" runat="server" style="display:none;" OnClick="btnBatchCancel_Click" ClientIDMode="Static" />

<!-- -- Page Header -------------------------------------------- -->
<div class="pr-page-header">
    <div class="pr-page-header__left">
        <div class="pr-page-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                 fill="none" stroke="#dc3545" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="16"/>
                <line x1="8" y1="12" x2="16" y2="12"/>
            </svg>
        </div>
        <div>
            <div class="pr-page-title">Payroll Deduction Records</div>
            <div class="pr-page-sub">Salary advances, loan repayments and other ad-hoc deductions scheduled for specific payroll periods</div>
        </div>
    </div>
    <div class="pr-hdr-actions">
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="openBatchModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Create Recurring
        </button>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="openAddModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Add Deduction
        </button>
    </div>
</div>

<!-- -- Stats ------------------------------------------------- -->
<div class="ct-stats">
    <div class="ct-stat ct-stat--amber">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div>
            <div class="ct-stat__val"><asp:Literal ID="litPending" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Pending</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--blue">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
        <div>
            <div class="ct-stat__val" style="font-size:14px;"><asp:Literal ID="litPendingAmt" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Pending Amount (UGX)</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--green">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <div>
            <div class="ct-stat__val"><asp:Literal ID="litSettled" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Settled This Year</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--grey">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6c757d" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div>
            <div class="ct-stat__val"><asp:Literal ID="litCancelled" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Cancelled</div>
        </div>
    </div>
</div>

<!-- -- Filter Bar -------------------------------------------- -->
<div class="ct-filters">
    <div class="ct-filters__top">
        <div class="ct-search-wrap">
            <svg class="ct-search-icon" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#aaa" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-search-box" placeholder="Search by name or staff code…" ClientIDMode="Static" />
        </div>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnSearch_Click" ClientIDMode="Static" />
        <asp:Button ID="btnReset"  runat="server" Text="Reset"  CssClass="hr-btn hr-btn--ghost hr-btn--sm"   OnClick="btnReset_Click" ClientIDMode="Static" />
        <span class="ct-filters__count"><asp:Literal ID="litFilterCountTop" runat="server" Text="0" /> record(s)</span>
    </div>
    <div class="ct-filters__row">
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Employee</span>
            <asp:DropDownList ID="ddlFilterEmployee" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
        </div>
        <div class="ct-filter-sep"></div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Month</span>
            <asp:DropDownList ID="ddlFilterMonth" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Value="">All Months</asp:ListItem>
                <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Year</span>
            <asp:TextBox ID="txtFilterYear" runat="server" CssClass="ct-filter-select" style="width:60px;" ClientIDMode="Static" />
        </div>
        <div class="ct-filter-sep"></div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Status</span>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Value="">All Statuses</asp:ListItem>
                <asp:ListItem Value="PENDING">Pending</asp:ListItem>
                <asp:ListItem Value="SETTLED">Settled</asp:ListItem>
                <asp:ListItem Value="CANCELLED">Cancelled</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="ct-filter-sep"></div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Per Page</span>
            <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="width:65px;">
                <asp:ListItem Value="25" Selected="True">25</asp:ListItem>
                <asp:ListItem Value="50">50</asp:ListItem>
                <asp:ListItem Value="100">100</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>
</div>

<!-- -- Count bar + batch toolbar ---------------------------- -->
<div class="pr-count-bar">
    <span><asp:Literal ID="litFilterCount" runat="server" Text="0" /> record(s) shown</span>
</div>

<div class="ct-batch-toolbar" id="batchToolbar">
    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
    <div class="ct-batch-info"><strong id="batchCount">0</strong> selected</div>
    <div class="ct-batch-sep"></div>
    <button type="button" class="hr-btn hr-btn--amber hr-btn--sm" onclick="doBatchCancel()">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        Mark Cancelled
    </button>
    <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatchDelete()">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
        Delete Selected
    </button>
    <div class="ct-batch-sep"></div>
    <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="clearBatchSelection()">Clear</button>
</div>

<!-- -- Grid ------------------------------------------------- -->
<div style="overflow-x:auto;-webkit-overflow-scrolling:touch;border:1px solid #e0e0e0;">
<dx:ASPxGridView ID="gvDeductions" runat="server" Width="100%" ClientInstanceName="gvDeductions"
    KeyFieldName="id" EnableCallBacks="true" Theme="Glass"
    OnRowUpdating="gvDeductions_RowUpdating"
    OnRowDeleting="gvDeductions_RowDeleting"
    OnHtmlRowCreated="gvDeductions_HtmlRowCreated">
    <SettingsPager PageSize="25" />
    <Settings ShowFilterRow="False" HorizontalScrollBarMode="Hidden" />
    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="False" />
    <SettingsEditing Mode="PopupEditForm" />
    <SettingsPopup>
        <EditForm Width="500" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
    </SettingsPopup>
    <EditFormLayoutProperties ColCount="2">
        <Items>
            <dx:GridViewColumnLayoutItem ColumnName="deduction_type"  ColSpan="2" />
            <dx:GridViewColumnLayoutItem ColumnName="amount"          ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="status"          ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="to_deduct_month" ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="to_deduct_year"  ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="description"     ColSpan="2" />
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
                       style="cursor:pointer;accent-color:#174DA4;width:14px;height:14px;" />
            </HeaderTemplate>
            <DataItemTemplate>
                <input type="checkbox" class="ct-row-check" value="<%# Eval("id") %>" onchange="updateBatchToolbar()" />
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff #" Width="68" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-size:10px;font-weight:700;color:#174DA4;font-family:monospace;"><%# Eval("EMP_CODE") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="155" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-weight:600;color:#1a1a2e;font-size:11px;"><%# Eval("emp_name") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataComboBoxColumn FieldName="deduction_type" Caption="Deduction Type" Width="155">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="Salary Advance"              Value="Salary Advance" />
                    <dx:ListEditItem Text="Loan Repayment (Staff SACCO)" Value="Loan Repayment (Staff SACCO)" />
                    <dx:ListEditItem Text="Loan Repayment (Bank)"       Value="Loan Repayment (Bank)" />
                    <dx:ListEditItem Text="Housing Loan Repayment"      Value="Housing Loan Repayment" />
                    <dx:ListEditItem Text="Court Order / Garnishment"   Value="Court Order / Garnishment" />
                    <dx:ListEditItem Text="Equipment / Asset Recovery"  Value="Equipment / Asset Recovery" />
                    <dx:ListEditItem Text="Overpayment Recovery"        Value="Overpayment Recovery" />
                    <dx:ListEditItem Text="Insurance Premium"           Value="Insurance Premium" />
                    <dx:ListEditItem Text="Welfare Contribution"        Value="Welfare Contribution" />
                    <dx:ListEditItem Text="Other"                       Value="Other" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <span class="pr-type"><%# Eval("deduction_type") %></span>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataSpinEditColumn FieldName="amount" Caption="Amount (UGX)" Width="110">
            <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" MinValue="0" />
            <DataItemTemplate>
                <span class="pr-amount"><%# FormatAmount(Eval("amount")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataSpinEditColumn>

        <dx:GridViewDataComboBoxColumn FieldName="to_deduct_month" Caption="Month" Width="100">
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
                <span class="pr-period"><%# Eval("to_deduct_month") %></span>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataSpinEditColumn FieldName="to_deduct_year" Caption="Year" Width="66">
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

<!-- ============================================================
     MODAL: Add Single Deduction
     ============================================================ -->
<div class="hr-modal-overlay" id="addDeductionModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span class="hr-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Add Deduction Record
            </span>
            <button type="button" class="hr-modal__close" onclick="closeAddModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="addResult" class="hr-result"></div>
            <!-- Employee Autocomplete -->
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-label">Employee <span>*</span></label>
                    <div class="hr-ac">
                        <input type="text" id="acAddInput" class="hr-ac__input" placeholder="Search by name or staff #…" autocomplete="off" />
                        <div id="acAddSpinner" class="hr-ac__spinner"></div>
                        <button type="button" id="acAddClear" class="hr-ac__clear" title="Clear" onclick="DeductionAC.clearAdd()">&times;</button>
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
                <button type="button" class="hr-selected-emp__remove" title="Remove" onclick="DeductionAC.clearAdd()">&times;</button>
            </div>
            
            <div class="hr-section-label">Deduction Details</div>
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Deduction Type <span>*</span></label>
                    <asp:DropDownList ID="ddlAddType" runat="server" CssClass="hr-select">
                        <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                        <asp:ListItem>Salary Advance</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Staff SACCO)</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Bank)</asp:ListItem>
                        <asp:ListItem>Housing Loan Repayment</asp:ListItem>
                        <asp:ListItem>Court Order / Garnishment</asp:ListItem>
                        <asp:ListItem>Equipment / Asset Recovery</asp:ListItem>
                        <asp:ListItem>Overpayment Recovery</asp:ListItem>
                        <asp:ListItem>Insurance Premium</asp:ListItem>
                        <asp:ListItem>Welfare Contribution</asp:ListItem>
                        <asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-label">Amount (UGX) <span>*</span></label>
                    <asp:TextBox ID="txtAddAmount" runat="server" CssClass="hr-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Date Recorded</label>
                    <asp:TextBox ID="txtAddDateRecorded" runat="server" CssClass="hr-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-section-label">Payroll Period</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-label">Month <span>*</span></label>
                    <asp:DropDownList ID="ddlAddMonth" runat="server" CssClass="hr-select">
                        <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                        <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                        <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                        <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                        <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                        <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Year <span>*</span></label>
                    <asp:TextBox ID="txtAddYear" runat="server" CssClass="hr-input" TextMode="Number" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Description / Notes</label>
                    <asp:TextBox ID="txtAddDescription" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="3" />
                </div>
            </div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeAddModal()">Cancel</button>
            <asp:Button ID="btnAddDeduction" runat="server" Text="Save Deduction" CssClass="hr-btn hr-btn--danger hr-btn--sm" OnClick="btnAddDeduction_Click" />
        </div>
    </div>
</div>

<!-- ============================================================
     MODAL: Batch / Recurring Deductions
     ============================================================ -->
<div class="hr-modal-overlay" id="batchDeductionModal">
    <div class="hr-modal hr-modal--wide">
        <div class="hr-modal__header">
            <span class="hr-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Create Recurring Deductions
            </span>
            <button type="button" class="hr-modal__close" onclick="closeBatchModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="batchResult" class="hr-result"></div>
            <!-- Employee Autocomplete -->
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-label">Employee <span>*</span></label>
                    <div class="hr-ac">
                        <input type="text" id="acBatchInput" class="hr-ac__input" placeholder="Search by name or staff #…" autocomplete="off" />
                        <div id="acBatchSpinner" class="hr-ac__spinner"></div>
                        <button type="button" id="acBatchClear" class="hr-ac__clear" title="Clear" onclick="DeductionAC.clearBatch()">&times;</button>
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
                <button type="button" class="hr-selected-emp__remove" title="Remove" onclick="DeductionAC.clearBatch()">&times;</button>
            </div>
            
            <div class="hr-section-label">Deduction Details</div>
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Deduction Type <span>*</span></label>
                    <asp:DropDownList ID="ddlBatchType" runat="server" CssClass="hr-select">
                        <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                        <asp:ListItem>Salary Advance</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Staff SACCO)</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Bank)</asp:ListItem>
                        <asp:ListItem>Housing Loan Repayment</asp:ListItem>
                        <asp:ListItem>Court Order / Garnishment</asp:ListItem>
                        <asp:ListItem>Equipment / Asset Recovery</asp:ListItem>
                        <asp:ListItem>Overpayment Recovery</asp:ListItem>
                        <asp:ListItem>Insurance Premium</asp:ListItem>
                        <asp:ListItem>Welfare Contribution</asp:ListItem>
                        <asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-label">Amount per Instalment (UGX) <span>*</span></label>
                    <asp:TextBox ID="txtBatchAmount" runat="server" CssClass="hr-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Number of Instalments <span>*</span></label>
                    <asp:TextBox ID="txtBatchMonths" runat="server" CssClass="hr-input" TextMode="Number" Text="1" ClientIDMode="Static" />
                    <span class="hr-hint">Max 60 months</span>
                </div>
            </div>
            <div class="hr-section-label">Starting Payroll Period</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-label">Start Month <span>*</span></label>
                    <asp:DropDownList ID="ddlBatchStartMonth" runat="server" CssClass="hr-select" onchange="updateBatchPreview()" ClientIDMode="Static">
                        <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                        <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                        <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                        <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                        <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                        <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Start Year <span>*</span></label>
                    <asp:TextBox ID="txtBatchStartYear" runat="server" CssClass="hr-input" TextMode="Number" onchange="updateBatchPreview()" ClientIDMode="Static" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Description / Notes</label>
                    <asp:TextBox ID="txtBatchDescription" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="2"
                        placeholder="E.g. SACCO Loan - instalment {n} of 12" />
                    <span class="hr-hint">Use <strong>{n}</strong> as a placeholder for instalment number (e.g. 1, 2, 3…)</span>
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
            <asp:Button ID="btnBatchCreate" runat="server" Text="Create Records" CssClass="hr-btn hr-btn--danger hr-btn--sm" OnClick="btnBatchCreate_Click" />
        </div>
    </div>
</div>

<script>
var MONTHS_ARR=['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];

/* -- Action popovers -- */
function toggleActionPopover(btn,evt){evt.stopPropagation();var pop=btn.nextElementSibling;var isOpen=pop.classList.contains('is-open');closeAllPopovers();if(!isOpen)pop.classList.add('is-open');}
function closeAllPopovers(){document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){p.classList.remove('is-open');});}
document.addEventListener('click',closeAllPopovers);

/* Modals - Modals */
function openAddModal(){
    var modal = document.getElementById('addDeductionModal');
    if (modal) modal.classList.add('is-open');
    // Suppress grid interactions
    var grid = document.querySelector('.dxgvControl_Glass');
    if (grid) grid.style.pointerEvents = 'none';
    var r=document.getElementById('addResult');if(r){r.innerHTML='';r.className='hr-result';}
}
function closeAddModal(){
    var modal = document.getElementById('addDeductionModal');
    if (modal) modal.classList.remove('is-open');
    // Re-enable grid interactions
    var grid = document.querySelector('.dxgvControl_Glass');
    if (grid) grid.style.pointerEvents = 'auto';
}
function openBatchModal(){
    var modal = document.getElementById('batchDeductionModal');
    if (modal) modal.classList.add('is-open');
    // Suppress grid interactions
    var grid = document.querySelector('.dxgvControl_Glass');
    if (grid) grid.style.pointerEvents = 'none';
    var r=document.getElementById('batchResult');if(r){r.innerHTML='';r.className='hr-result';}
    updateBatchPreview();
}
function closeBatchModal(){
    var modal = document.getElementById('batchDeductionModal');
    if (modal) modal.classList.remove('is-open');
    // Re-enable grid interactions
    var grid = document.querySelector('.dxgvControl_Glass');
    if (grid) grid.style.pointerEvents = 'auto';
}
document.querySelectorAll('.hr-modal-overlay').forEach(function(o){
    o.addEventListener('click',function(e){if(e.target===o)o.classList.remove('is-open');});
});
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
    if(!confirm('Delete this deduction record? This cannot be undone.'))return;
    var idx=gridFindIndex(gName,key);if(idx>=0)window[gName].DeleteRow(idx);
}

/* -- Batch toolbar -- */
function updateBatchToolbar(){
    var checked=document.querySelectorAll('.ct-row-check:checked');
    var all=document.querySelectorAll('.ct-row-check');
    var tb=document.getElementById('batchToolbar');
    var cnt=document.getElementById('batchCount');
    if(checked.length>0){
        tb.classList.add('toolbar-visible');
        tb.style.display='flex';
        cnt.textContent=checked.length;
    }
    else {
        tb.classList.remove('toolbar-visible');
        tb.style.display='none';
    }
    var chk=document.getElementById('chkSelectAll');
    if(chk){chk.indeterminate=(checked.length>0&&checked.length<all.length);chk.checked=all.length>0&&checked.length===all.length;}
}
function toggleSelectAll(cb){document.querySelectorAll('.ct-row-check').forEach(function(c){c.checked=cb.checked;});updateBatchToolbar();}
function clearBatchSelection(){
    document.querySelectorAll('.ct-row-check').forEach(function(c){c.checked=false;});
    var chk=document.getElementById('chkSelectAll');if(chk){chk.checked=false;chk.indeterminate=false;}
    updateBatchToolbar();
}
function getBatchIDs(){var ids=[];document.querySelectorAll('.ct-row-check:checked').forEach(function(c){ids.push(c.value);});return ids.join(',');}
function doBatchCancel(){
    var n=document.querySelectorAll('.ct-row-check:checked').length;
    if(!n||!confirm('Mark '+n+' deduction(s) as CANCELLED?'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=getBatchIDs();
    document.getElementById('<%= btnBatchCancel.ClientID %>').click();
}
function doBatchDelete(){
    var n=document.querySelectorAll('.ct-row-check:checked').length;
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

/* ===== EMPLOYEE AUTOCOMPLETE ============================================ */
var DeductionAC = (function() {
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
        if (!addInput) return;

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
        xhr.open('GET', 'HRDeductions.aspx?ajax=search_emp&q=' + encodeURIComponent(q), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            onHideSpinner();
            if (xhr.status === 200) {
                try {
                    var response = xhr.responseText.trim();
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
                    onRender();
                } catch(ex) { 
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
        var list = context === 'Add' ? addList : batchList;
        var activeIdx = context === 'Add' ? addActiveIdx : batchActiveIdx;
        if (!list) return;
        if (results.length === 0) {
            list.innerHTML = '<div class="hr-ac__empty"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>No employees found</div>';
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

            var items = list.querySelectorAll('.hr-ac__item');
            for (var j = 0; j < items.length; j++) {
                (function(idx) {
                    items[idx].addEventListener('click', function() { selectCb(idx); });
                    items[idx].addEventListener('mouseenter', function() { activateCb(idx); });
                })(j);
            }
            (context === 'Add' ? showListAdd : showListBatch)();
        } catch(ex) { }
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
            addInput.value = emp.emp_name;
            addInput.classList.add('hr-ac__input--selected');
            hideListAdd();
            document.getElementById('hfSelectedEmpID').value = emp.empID;
            showSelectedEmpAdd(emp);
        } else {
            batchSelected = emp;
            batchInput.value = emp.emp_name;
            batchInput.classList.add('hr-ac__input--selected');
            hideListBatch();
            document.getElementById('hfSelectedEmpID').value = emp.empID;
            showSelectedEmpBatch(emp);
        }
    }

    function showSelectedEmpAdd(e) {
        var card = document.getElementById('selectedEmpCardAdd');
        document.getElementById('empAvatarAdd').textContent = getInitials(e.emp_name);
        document.getElementById('empNameAdd').textContent = e.emp_name;
        document.getElementById('empCodeAdd').textContent = e.EMP_CODE;
        card.classList.add('hr-selected-emp--visible');
    }

    function showSelectedEmpBatch(e) {
        var card = document.getElementById('selectedEmpCardBatch');
        document.getElementById('empAvatarBatch').textContent = getInitials(e.emp_name);
        document.getElementById('empNameBatch').textContent = e.emp_name;
        document.getElementById('empCodeBatch').textContent = e.EMP_CODE;
        card.classList.add('hr-selected-emp--visible');
    }

    function deselectAdd() { addSelected = null; hideListAdd(); }
    function deselectBatch() { batchSelected = null; hideListBatch(); }

    function clearAdd() {
        addInput.value = '';
        addInput.classList.remove('hr-ac__input--selected');
        addSelected = null;
        addResults = [];
        addActiveIdx = -1;
        document.getElementById('hfSelectedEmpID').value = '';
        document.getElementById('selectedEmpCardAdd').classList.remove('hr-selected-emp--visible');
        hideListAdd();
        addInput.focus();
    }

    function clearBatch() {
        batchInput.value = '';
        batchInput.classList.remove('hr-ac__input--selected');
        batchSelected = null;
        batchResults = [];
        batchActiveIdx = -1;
        document.getElementById('hfSelectedEmpID').value = '';
        document.getElementById('selectedEmpCardBatch').classList.remove('hr-selected-emp--visible');
        hideListBatch();
        batchInput.focus();
    }

    function showListAdd() { addList.classList.add('hr-ac__list--visible'); }
    function hideListAdd() { addList.classList.remove('hr-ac__list--visible'); }
    function showListBatch() { batchList.classList.add('hr-ac__list--visible'); }
    function hideListBatch() { batchList.classList.remove('hr-ac__list--visible'); }

    function showSpinnerAdd() { addSpinner.classList.add('hr-ac__spinner--visible'); }
    function hideSpinnerAdd() { addSpinner.classList.remove('hr-ac__spinner--visible'); }
    function showSpinnerBatch() { batchSpinner.classList.add('hr-ac__spinner--visible'); }
    function hideSpinnerBatch() { batchSpinner.classList.remove('hr-ac__spinner--visible'); }

    function getInitials(name) {
        return name ? name.split(' ').map(function(w) { return w[0]; }).join('').substring(0, 2).toUpperCase() : '?';
    }

    function esc(s) { return String(s).replace(/[&<>"']/g, function(c) { return '&#' + c.charCodeAt(0) + ';'; }); }

    function highlight(text, query) {
        if (!query || !text) return text;
        var regex = new RegExp('(' + query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
        return text.replace(regex, '<mark>$1</mark>');
    }

    return {
        init: init,
        clearAdd: clearAdd,
        clearBatch: clearBatch
    };
})();

// Initialize autocomplete when DOM ready
(function(){
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { DeductionAC.init(); });
    } else {
        DeductionAC.init();
    }
})();

/* -- Single row cancel (reuses batch cancel handler) -- */
function singleCancel(id){
    closeAllPopovers();
    if(!confirm('Mark this deduction as CANCELLED?'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=id;
    document.getElementById('<%= btnBatchCancel.ClientID %>').click();
}

/* -- Search on Enter -- */
(function(){
    var sb=document.getElementById('<%= txtSearch.ClientID %>');
    if(sb)sb.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();document.getElementById('<%= btnSearch.ClientID %>').click();}});
    var yr=document.getElementById('<%= txtFilterYear.ClientID %>');
    if(yr)yr.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();document.getElementById('<%= btnSearch.ClientID %>').click();}});
})();
</script>
</asp:Content>