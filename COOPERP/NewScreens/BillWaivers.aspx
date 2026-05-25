<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BillWaivers.aspx.cs" Inherits="COOPERP_NewScreens_BillWaivers" Title="Bill Waivers - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== BILL WAIVERS (prefix: bw-) ====================================== */

/* Stats Row */
.bw-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.bw-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.bw-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.bw-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.bw-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.bw-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.bw-stat--total { --stat-c: #174DA4; } .bw-stat--total .bw-stat__icon { background: #e8f0fc; } .bw-stat--total .bw-stat__val { color: #174DA4; }
.bw-stat--active { --stat-c: #2e7d32; } .bw-stat--active .bw-stat__icon { background: #e6f4ea; } .bw-stat--active .bw-stat__val { color: #2e7d32; }
.bw-stat--reversed { --stat-c: #c62828; } .bw-stat--reversed .bw-stat__icon { background: #fde8e8; } .bw-stat--reversed .bw-stat__val { color: #c62828; }
.bw-stat--amount { --stat-c: #00897b; } .bw-stat--amount .bw-stat__icon { background: #e0f2f1; } .bw-stat--amount .bw-stat__val { color: #00695c; }

/* Page Header */
.bw-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.bw-header__left { display: flex; align-items: center; gap: 10px; }
.bw-header__actions { display: flex; align-items: center; gap: 8px; }
.bw-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.bw-header__icon svg { color: #fff; }
.bw-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.bw-header__sub { font-size: 10px; color: #888; margin-top: 1px; }

/* Card */
.bw-card { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 14px; }
.bw-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.bw-card__title { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Table */
.bw-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.bw-table th { background: #f5f7fa; padding: 9px 12px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.bw-table td { padding: 8px 12px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; vertical-align: middle; }
.bw-table--right { text-align: right !important; }
.bw-row--alt { background: #fafbfc; }
.bw-table tbody tr:hover { background: #f0f4ff; }
.bw-link { color: #174DA4; text-decoration: none; font-weight: 600; }
.bw-link:hover { text-decoration: underline; }

/* Buttons */
.bw-btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.bw-btn--primary { background: #05275C; color: #fff; } .bw-btn--primary:hover { background: #174DA4; }
.bw-btn--success { background: #2e7d32; color: #fff; } .bw-btn--success:hover { background: #388e3c; }
.bw-btn--danger { background: #c62828; color: #fff; } .bw-btn--danger:hover { background: #d32f2f; }
.bw-btn--ghost { background: #fff; border: 1px solid #cdd3de; color: #555; } .bw-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.bw-btn:disabled { opacity: .5; cursor: not-allowed; }

/* Badges (reuse existing fs- badges) */
.fs-badge--green { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; background: #e6f4ea; color: #1b5e20; border: 1px solid #c8e6c9; }
.fs-badge--red { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; background: #fde8e8; color: #c62828; border: 1px solid #f5c6cb; }
.fs-badge--amber { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; background: #fff8e1; color: #e65100; border: 1px solid #ffecb3; }
.fs-badge--blue { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; background: #e8f0fc; color: #174DA4; border: 1px solid #bbdefb; }
.fs-code { font-family: 'Consolas','Courier New',monospace; font-size: 11px; background: #f5f7fa; padding: 1px 5px; border: 1px solid #e0e5ed; color: #05275C; }

/* Toast */
.bw-toast { display: none; padding: 9px 14px; font-size: 12px; font-weight: 600; margin-bottom: 12px; border: 1px solid transparent; }
.bw-toast--success { display: block; background: #e6f4ea; color: #155724; border-color: #c3e6cb; }
.bw-toast--error { display: block; background: #fde8e8; color: #c62828; border-color: #f5c6cb; }

/* ===== WIZARD MODAL ===================================================== */
.bw-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9998; }
.bw-overlay--visible { display: flex; align-items: center; justify-content: center; }
.bw-modal { background: #fff; width: 1180px; max-width: 97vw; max-height: 93vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.bw-modal__header { background: #05275C; padding: 12px 18px; display: flex; align-items: center; justify-content: space-between; }
.bw-modal__title { font-size: 13px; font-weight: 700; color: #fff; display: flex; align-items: center; gap: 8px; }
.bw-modal__close { width: 24px; height: 24px; border: none; background: rgba(255,255,255,.15); cursor: pointer; color: #fff; font-size: 16px; line-height: 1; display: flex; align-items: center; justify-content: center; }
.bw-modal__close:hover { background: rgba(255,255,255,.3); }
.bw-modal__body { padding: 0; }
.bw-modal__footer { padding: 11px 18px; border-top: 1px solid #e0e5ed; display: flex; gap: 8px; justify-content: flex-end; background: #f8f9fb; }

/* Wizard Steps Indicator */
.bw-steps { display: flex; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; padding: 0; }
.bw-step { flex: 1; text-align: center; padding: 10px 6px; font-size: 10px; font-weight: 600; color: #999; text-transform: uppercase; letter-spacing: .3px; border-bottom: 2px solid transparent; transition: all .2s; position: relative; display: flex; align-items: center; justify-content: center; gap: 5px; }
.bw-step--active { color: #05275C; border-bottom-color: #05275C; background: #fff; }
.bw-step--done { color: #2e7d32; border-bottom-color: #2e7d32; }
.bw-step__num { display: inline-flex; width: 18px; height: 18px; align-items: center; justify-content: center; font-size: 9px; font-weight: 700; border: 1.5px solid currentColor; }
.bw-step--done .bw-step__num { background: #2e7d32; color: #fff; border-color: #2e7d32; }
.bw-step--active .bw-step__num { background: #05275C; color: #fff; border-color: #05275C; }

/* Wizard Panels */
.bw-panel { display: none; padding: 18px; }
.bw-panel--active { display: block; }

/* Student Search (inside wizard) */
.bw-search-wrap { position: relative; margin-bottom: 12px; }
.bw-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.bw-search-input { width: 100%; padding: 9px 12px 9px 34px; border: 1px solid #cdd3de; font-size: 12px; box-sizing: border-box; }
.bw-search-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }
.bw-ac-list { display: none; position: absolute; left: 0; right: 0; top: 100%; background: #fff; border: 1px solid #cdd3de; border-top: none; z-index: 100; max-height: 200px; overflow-y: auto; box-shadow: 0 6px 16px rgba(0,0,0,.1); }
.bw-ac-list--visible { display: block; }
.bw-ac-item { padding: 8px 12px; cursor: pointer; font-size: 11px; border-bottom: 1px solid #f0f2f5; display: flex; justify-content: space-between; align-items: center; }
.bw-ac-item:hover { background: #f0f4ff; }
.bw-ac-item__name { font-weight: 600; color: #05275C; }
.bw-ac-item__meta { font-size: 10px; color: #888; }

/* Student Info Card (selected student) */
.bw-student-card { display: none; background: #f0f4ff; border: 1px solid #d0daf0; padding: 10px 14px; margin-bottom: 12px; font-size: 12px; }
.bw-student-card--visible { display: flex; align-items: center; justify-content: space-between; }
.bw-student-card__name { font-weight: 700; color: #05275C; font-size: 13px; }
.bw-student-card__detail { color: #555; margin-top: 2px; font-size: 11px; }
.bw-student-card__remove { padding: 3px 8px; font-size: 10px; background: transparent; border: 1px solid #c62828; color: #c62828; cursor: pointer; }
.bw-student-card__remove:hover { background: #fde8e8; }

/* Bill Selection Table */
.bw-bills-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.bw-bills-table th { background: #f5f7fa; padding: 10px 14px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.bw-bills-table td { padding: 11px 14px; border-bottom: 1px solid #eef0f4; vertical-align: middle; }
.bw-bills-table tr:hover:not(.bw-bill--waived) { background: #f0f4ff; }
.bw-bills-table tr.bw-bill--selected { background: #e8f0fc; box-shadow: inset 3px 0 0 #174DA4; }
.bw-bills-table tr.bw-bill--waived { background: #f9f9f9; opacity: .65; }
.bw-bill-check { width: 16px; height: 16px; cursor: pointer; accent-color: #05275C; }
.bw-bills-total { display: flex; align-items: center; justify-content: space-between; padding: 11px 14px; color: #05275C; border-top: 2px solid #e0e5ed; background: #f5f7fa; }
.bw-bills-total__count { font-size: 11px; color: #666; }
.bw-bills-total__sum { font-size: 13px; font-weight: 700; }
.bw-amt-input { width: 130px; padding: 5px 8px; font-size: 12px; font-weight: 600; border: 1px solid #b0bec5; text-align: right; background: #fff; color: #333; transition: all .2s; }
.bw-amt-input:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.15); outline: none; }
.bw-amt-input:disabled { background: #eee; color: #bbb; border-color: #ddd; font-weight: 400; cursor: not-allowed; }
.bw-amt-input:not(:disabled) { background: #fffff0; border-color: #174DA4; box-shadow: 0 0 0 1px rgba(23,77,164,.08); }
.bw-amt-input.bw-amt--error { border-color: #c62828 !important; background: #fff5f5 !important; box-shadow: 0 0 0 2px rgba(198,40,40,.12); }
.bw-amt-input.bw-amt--partial { border-color: #e67e22 !important; background: #fffcf5 !important; box-shadow: 0 0 0 1px rgba(230,126,34,.12); }
.bw-amt-hint { display: block; font-size: 9px; color: #888; margin-top: 2px; text-align: right; line-height: 1.2; }
/* Balance strip above bill list */
.bw-balance-strip { background: #f0f4ff; border-bottom: 1px solid #d0daf0; padding: 9px 14px; font-size: 11px; color: #444; display: flex; align-items: center; gap: 8px; }
.bw-balance-strip__label { color: #666; font-weight: 700; text-transform: uppercase; font-size: 9px; letter-spacing: .4px; }
/* Rich bill row content */
.bw-bill-item { display: flex; flex-direction: column; gap: 5px; }
.bw-bill-item__name { font-size: 12px; font-weight: 700; color: #1a1a2e; line-height: 1.2; }
.bw-bill-item__meta { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; margin-top: 1px; }
.bw-bill-item__tid { font-family: "Courier New", Courier, monospace; background: #f0f2f5; border: 1px solid #e0e5ed; padding: 1px 5px; color: #555; font-size: 9px; white-space: nowrap; }
.bw-bill-item__date { font-size: 10px; color: #888; }
.bw-bill-period { display: flex; flex-direction: column; gap: 4px; }
.bw-bill-period__year { font-size: 12px; font-weight: 700; color: #05275C; }
.bw-bill-period__sem { font-size: 10px; color: #555; background: #f5f7fa; border: 1px solid #e0e5ed; padding: 2px 7px; display: inline-block; white-space: nowrap; }
.bw-bill-period__studyyr { font-size: 9px; color: #777; font-style: italic; margin-top: 1px; }
.bw-bill-amount { font-size: 13px; font-weight: 700; color: #1a1a2e; white-space: nowrap; }
.bw-waive-cell { display: flex; flex-direction: column; align-items: flex-end; gap: 2px; }
.bw-fee-badge { display: inline-block; padding: 2px 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; }
.bw-fee-badge--tuition { background: #e8f0fe; color: #1a56db; }
.bw-fee-badge--function { background: #fef3c7; color: #92400e; }
.bw-fee-badge--other { background: #f0fdf4; color: #166534; }
/* Reason chips */
.bw-reason-chips { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 8px; }
.bw-reason-chip { padding: 5px 11px; font-size: 10px; font-weight: 600; border: 1.5px solid #c0cce8; background: #f5f7fa; color: #374B70; cursor: pointer; transition: all .15s; white-space: nowrap; }
.bw-reason-chip:hover { border-color: #174DA4; background: #e8f0fe; color: #174DA4; }
.bw-reason-chip--active { border-color: #05275C; background: #05275C; color: #fff; }

/* Empty Bills */
.bw-empty { padding: 24px; text-align: center; color: #888; font-size: 12px; }

/* Category Selection (radio cards) */
.bw-cats { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 14px; }
.bw-cat { border: 1.5px solid #e0e5ed; padding: 12px 14px; cursor: pointer; transition: all .15s; display: flex; align-items: flex-start; gap: 10px; }
.bw-cat:hover { border-color: #174DA4; background: #f8f9fb; }
.bw-cat--selected { border-color: #05275C; background: #e8f0fc; }
.bw-cat input[type=radio] { margin-top: 2px; accent-color: #05275C; }
.bw-cat__label { font-size: 12px; font-weight: 600; color: #05275C; }
.bw-cat__desc { font-size: 10px; color: #888; margin-top: 2px; }

/* Reason textarea */
.bw-reason-area { width: 100%; min-height: 80px; border: 1px solid #cdd3de; padding: 9px 12px; font-size: 12px; font-family: inherit; box-sizing: border-box; resize: vertical; }
.bw-reason-area:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }

/* Validation error highlight */
.bw-field--error { border-color: #c62828 !important; background: #fff5f5 !important; }

/* Summary */
.bw-summary { font-size: 12px; }
.bw-summary__row { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #f0f2f5; }
.bw-summary__label { color: #666; }
.bw-summary__val { font-weight: 600; color: #05275C; }
.bw-summary__total { font-size: 15px; font-weight: 700; padding: 10px 0; border-top: 2px solid #05275C; margin-top: 6px; }
.bw-summary__total .bw-summary__val { color: #2e7d32; font-size: 15px; }
.bw-summary__items { margin: 10px 0; }
.bw-summary__item { display: flex; justify-content: space-between; padding: 4px 8px; font-size: 11px; background: #f8f9fb; border: 1px solid #e0e5ed; margin-bottom: 3px; }
.bw-summary__warning { background: #fff8e1; border: 1px solid #ffecb3; padding: 8px 12px; font-size: 11px; color: #e65100; margin-top: 10px; display: flex; align-items: center; gap: 8px; }

/* Success Panel */
.bw-success { text-align: center; padding: 24px; }
.bw-success__icon { color: #2e7d32; margin-bottom: 10px; }
.bw-success__title { font-size: 16px; font-weight: 700; color: #2e7d32; margin-bottom: 4px; }
.bw-success__msg { font-size: 12px; color: #555; margin-bottom: 12px; }
.bw-success__detail { font-size: 11px; background: #f8f9fb; border: 1px solid #e0e5ed; padding: 10px; text-align: left; display: inline-block; }

/* Form Labels */
.bw-label { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #666; font-weight: 700; margin-bottom: 4px; display: block; }
.bw-label .req { color: #dc3545; }

/* Loading Spinner */
.bw-spinner { display: inline-block; width: 14px; height: 14px; border: 2px solid #ddd; border-top-color: #05275C; border-radius: 50%; animation: bwSpin .6s linear infinite; }
@keyframes bwSpin { to { transform: rotate(360deg); } }

/* Responsive */
@media (max-width: 700px) {
    .bw-stats { grid-template-columns: repeat(2, 1fr); }
    .bw-modal { width: 98vw; }
    .bw-cats { grid-template-columns: 1fr; }
    .bw-fix-grid { grid-template-columns: 1fr; }
    .bw-fix-target { grid-template-columns: 1fr; }
}

/* Action Buttons (inline in table rows) */
.bw-btn-action { width: 28px; height: 28px; border: 1px solid #e0e5ed; background: #fff; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; transition: all .15s; vertical-align: middle; padding: 0; }
.bw-btn-action:hover { border-color: #174DA4; background: #f0f4ff; }
.bw-btn-action--view { color: #174DA4; }
.bw-btn-action--reverse { color: #c62828; }
.bw-btn-action--reverse:hover { border-color: #c62828; background: #fde8e8; }

/* Detail Modal */
.bw-detail-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9999; }
.bw-detail-overlay--visible { display: flex; align-items: center; justify-content: center; }
.bw-detail-modal { background: #fff; width: 640px; max-width: 96vw; max-height: 90vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.bw-detail__section { padding: 14px 18px; border-bottom: 1px solid #f0f2f5; }
.bw-detail__section:last-child { border-bottom: none; }
.bw-detail__grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.bw-detail__field { margin-bottom: 4px; }
.bw-detail__label { font-size: 9px; text-transform: uppercase; letter-spacing: .4px; color: #888; font-weight: 600; }
.bw-detail__value { font-size: 12px; font-weight: 600; color: #1a1a2e; margin-top: 1px; }
.bw-detail__value--lg { font-size: 18px; color: #2e7d32; }

/* Balance Fix Modal */
.bw-fix-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9999; }
.bw-fix-overlay--visible { display: flex; align-items: center; justify-content: center; }
.bw-fix-modal { background: #fff; width: 920px; max-width: 97vw; max-height: 94vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.bw-fix-body { padding: 14px 16px; }
.bw-fix-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.bw-fix-card { border: 1px solid #e0e5ed; background: #f8f9fb; padding: 9px 11px; }
.bw-fix-card__label { font-size: 9px; color: #888; text-transform: uppercase; letter-spacing: .3px; font-weight: 700; }
.bw-fix-card__val { margin-top: 4px; font-size: 14px; font-weight: 700; color: #05275C; }
.bw-fix-target { display: flex; gap: 8px; align-items: end; flex-wrap: wrap; }
.bw-fix-signs { display: flex; gap: 6px; flex: 0 0 auto; }
.bw-fix-sign { display: flex; align-items: center; justify-content: center; gap: 5px; border: 1px solid #cdd3de; background: #fff; min-height: 39px; min-width: 44px; font-size: 12px; font-weight: 700; color: #555; cursor: pointer; padding: 0 8px; }
.bw-fix-sign input { accent-color: #05275C; }
.bw-fix-sign--active { border-color: #05275C; background: #e8f0fc; color: #05275C; }
.bw-fix-amt { width: 180px; max-width: 100%; }
#bwFixSignZeroBtn { min-width: 72px; }
.bw-fix-impact { margin-top: 10px; padding: 9px 11px; border: 1px solid #d0daf0; background: #f0f4ff; }
.bw-fix-impact--credit { border-color: #c8e6c9; background: #e8f5e9; }
.bw-fix-impact--debit { border-color: #ffe0b2; background: #fff8e1; }
.bw-fix-impact__title { font-size: 11px; font-weight: 700; color: #05275C; margin-bottom: 4px; }
.bw-fix-impact__line { font-size: 12px; color: #1a1a2e; }
.bw-fix-suggest { display: flex; flex-wrap: wrap; gap: 6px; margin: 6px 0 8px; }
.bw-fix-suggest__btn { border: 1px solid #d7dfeb; background: #f8f9fb; color: #4a5568; padding: 4px 8px; font-size: 10px; font-weight: 600; cursor: pointer; }
.bw-fix-suggest__btn:hover { border-color: #174DA4; color: #174DA4; background: #eef4ff; }
.bw-fix-reason { min-height: 58px; }

/* Reverse Confirmation Modal */
.bw-reverse-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9999; }
.bw-reverse-overlay--visible { display: flex; align-items: center; justify-content: center; }
.bw-reverse-modal { background: #fff; width: 520px; max-width: 96vw; max-height: 90vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.bw-reverse__summary { background: #fde8e8; border: 1px solid #f5c6cb; padding: 12px 14px; font-size: 12px; margin-bottom: 14px; }
.bw-reverse__summary strong { color: #c62828; }

/* Filter Bar */
.bw-filter-bar { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; padding: 9px 14px; background: #f5f7fa; border-bottom: 1px solid #e0e5ed; }
.bw-filter-input { height: 30px; padding: 0 10px; border: 1px solid #cdd3de; font-size: 11px; font-family: inherit; background: #fff; color: #1a1a2e; box-sizing: border-box; }
.bw-filter-input:focus { border-color: #174DA4; outline: none; }
.bw-filter-select { height: 30px; padding: 0 8px; border: 1px solid #cdd3de; font-size: 11px; font-family: inherit; background: #fff; color: #1a1a2e; }
.bw-filter-select:focus { border-color: #174DA4; outline: none; }
.bw-filter-btn { height: 30px; padding: 0 12px; font-size: 11px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
.bw-filter-btn--primary { background: #05275C; color: #fff; border: none; }
.bw-filter-btn--primary:hover { background: #174DA4; }
.bw-filter-btn--reset { background: #fff; border: 1px solid #cdd3de; color: #555; }
.bw-filter-btn--reset:hover { border-color: #c62828; color: #c62828; }
.bw-filter-sep { width: 1px; height: 20px; background: #e0e5ed; margin: 0 2px; flex-shrink: 0; }
.bw-page-size { height: 30px; padding: 0 8px; border: 1px solid #cdd3de; font-size: 11px; font-family: inherit; background: #fff; color: #1a1a2e; }
.bw-result-info { font-size: 11px; color: #666; }

/* Pagination */
.bw-pagination { display: flex; align-items: center; justify-content: space-between; padding: 9px 14px; border-top: 1px solid #e0e5ed; background: #f5f7fa; flex-wrap: wrap; gap: 8px; }
.bw-pagination__info { font-size: 11px; color: #666; }
.bw-pagination__pages { display: flex; gap: 3px; align-items: center; flex-wrap: wrap; }
.bw-page-btn { min-width: 28px; height: 28px; padding: 0 6px; border: 1px solid #e0e5ed; background: #fff; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; color: #555; font-family: inherit; transition: all .12s; }
.bw-page-btn:hover:not(:disabled) { border-color: #174DA4; color: #174DA4; background: #f0f4ff; }
.bw-page-btn--active { background: #05275C; color: #fff !important; border-color: #05275C; font-weight: 700; }
.bw-page-btn:disabled { opacity: .4; cursor: not-allowed; }
.bw-page-ellipsis { padding: 0 4px; color: #999; font-size: 11px; line-height: 28px; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══ PAGE HEADER ═══════════════════════════════════════════════════════ -->
<div class="bw-header">
    <div class="bw-header__left">
        <div class="bw-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
        </div>
        <div>
            <div class="bw-header__title">Bill Waivers</div>
            <div class="bw-header__sub">Waive specific bills from student accounts with documented reasons</div>
        </div>
    </div>
    <div class="bw-header__actions">
        <button type="button" class="bw-btn bw-btn--primary" onclick="openWizard()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            New Waiver
        </button>
        <button type="button" class="bw-btn bw-btn--success" onclick="openBalanceFix()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 1v22"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
            Balance Fix
        </button>
    </div>
</div>

<!-- ═══ TOAST ═════════════════════════════════════════════════════════════ -->
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div id="divToast" runat="server" class="bw-toast"></div>
</asp:Panel>

<!-- ═══ STATS ═════════════════════════════════════════════════════════════ -->
<div class="bw-stats">
    <asp:Literal ID="litStats" runat="server" />
</div>

<!-- ═══ HISTORY CARD ═════════════════════════════════════════════════════ -->
<div class="bw-card">
    <div class="bw-card__header">
        <div class="bw-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            Waiver History
        </div>
        <div class="bw-result-info"><asp:Literal ID="litResultInfo" runat="server" /></div>
    </div>

    <!-- Filter Bar -->
    <div class="bw-filter-bar">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" style="flex-shrink:0;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="bw-filter-input" placeholder="Student name or reg. no." Width="185px" />
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="bw-filter-select">
            <asp:ListItem Value="">All Status</asp:ListItem>
            <asp:ListItem Value="Active">Active</asp:ListItem>
            <asp:ListItem Value="Reversed">Reversed</asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="bw-filter-select">
            <asp:ListItem Value="">All Categories</asp:ListItem>
            <asp:ListItem Value="Bursary Waiver">Bursary Waiver</asp:ListItem>
            <asp:ListItem Value="Scholarship">Scholarship</asp:ListItem>
            <asp:ListItem Value="Double Billing">Double Billing</asp:ListItem>
            <asp:ListItem Value="Wrong Billing">Wrong Billing</asp:ListItem>
            <asp:ListItem Value="Balance Fix">Balance Fix</asp:ListItem>
            <asp:ListItem Value="Other">Other</asp:ListItem>
        </asp:DropDownList>
        <asp:TextBox ID="txtDateFrom" runat="server" CssClass="bw-filter-input" Width="118px" placeholder="From (YYYY-MM-DD)" />
        <span style="font-size:10px;color:#aaa;flex-shrink:0;">to</span>
        <asp:TextBox ID="txtDateTo" runat="server" CssClass="bw-filter-input" Width="118px" placeholder="To (YYYY-MM-DD)" />
        <div class="bw-filter-sep"></div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="bw-filter-btn bw-filter-btn--primary" OnClick="btnFilter_Click" CausesValidation="false" />
        <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="bw-filter-btn bw-filter-btn--reset" OnClick="btnReset_Click" CausesValidation="false" />
        <div class="bw-filter-sep"></div>
        <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="bw-page-size" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
            <asp:ListItem Value="25">25 / page</asp:ListItem>
            <asp:ListItem Value="50">50 / page</asp:ListItem>
            <asp:ListItem Value="100">100 / page</asp:ListItem>
        </asp:DropDownList>
    </div>

    <asp:HiddenField ID="hidPage" runat="server" Value="1" />
    <asp:Button ID="btnPageNav" runat="server" OnClick="btnPageNav_Click" Style="display:none;" CausesValidation="false" />

    <div style="overflow-x:auto;">
        <asp:Literal ID="litHistory" runat="server" />
    </div>
    <asp:Literal ID="litPagination" runat="server" />
</div>

<!-- ═══ WIZARD MODAL ═════════════════════════════════════════════════════ -->
<div id="bwOverlay" class="bw-overlay">
    <div class="bw-modal">
        <div class="bw-modal__header">
            <div class="bw-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
                New Bill Waiver
            </div>
            <button type="button" class="bw-modal__close" onclick="closeWizard()">&times;</button>
        </div>

        <!-- Step Indicators -->
        <div class="bw-steps">
            <div class="bw-step bw-step--active" id="stepTab1"><span class="bw-step__num">1</span> Select Student</div>
            <div class="bw-step" id="stepTab2"><span class="bw-step__num">2</span> Select Bills</div>
            <div class="bw-step" id="stepTab3"><span class="bw-step__num">3</span> Reason</div>
            <div class="bw-step" id="stepTab4"><span class="bw-step__num">4</span> Confirm</div>
        </div>

        <!-- Step 1: Select Student -->
        <div class="bw-panel bw-panel--active" id="panel1">
            <div class="bw-label">Search Student <span class="req">*</span></div>
            <div class="bw-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="bwSearch" class="bw-search-input" placeholder="Type registration number or student name..." autocomplete="off" />
                <div id="bwAcList" class="bw-ac-list"></div>
            </div>
            <div id="bwStudentCard" class="bw-student-card">
                <div>
                    <div class="bw-student-card__name" id="bwStudName"></div>
                    <div class="bw-student-card__detail" id="bwStudDetail"></div>
                </div>
                <button type="button" class="bw-student-card__remove" onclick="clearStudent()">Change</button>
            </div>
            <div id="bwStep1Error" style="display:none;font-size:11px;color:#c62828;margin-top:6px;"></div>
        </div>

        <!-- Step 2: Select Bills -->
        <div class="bw-panel" id="panel2">
            <div id="bwBillsLoading" style="text-align:center;padding:20px;"><span class="bw-spinner"></span> Loading bills...</div>
            <div id="bwBillsContent" style="display:none;overflow-x:auto;"></div>
            <div id="bwStep2Error" style="display:none;font-size:11px;color:#c62828;margin-top:6px;"></div>
        </div>

        <!-- Step 3: Category & Reason -->
        <div class="bw-panel" id="panel3">
            <div class="bw-label" style="margin-bottom:8px;">Waiver Category <span class="req">*</span></div>
            <div class="bw-cats" id="bwCats">
                <label class="bw-cat">
                    <input type="radio" name="bwCat" value="Bursary Waiver" />
                    <div>
                        <div class="bw-cat__label">Bursary Waiver</div>
                        <div class="bw-cat__desc">Student is on bursary — bill covered by sponsor</div>
                    </div>
                </label>
                <label class="bw-cat">
                    <input type="radio" name="bwCat" value="Double Billing" />
                    <div>
                        <div class="bw-cat__label">Double Billing</div>
                        <div class="bw-cat__desc">Student was billed two or more times for same item</div>
                    </div>
                </label>
                <label class="bw-cat">
                    <input type="radio" name="bwCat" value="Wrong Billing" />
                    <div>
                        <div class="bw-cat__label">Wrong Billing</div>
                        <div class="bw-cat__desc">Billed for a semester they didn't register for or attend</div>
                    </div>
                </label>
                <label class="bw-cat">
                    <input type="radio" name="bwCat" value="Other" />
                    <div>
                        <div class="bw-cat__label">Other</div>
                        <div class="bw-cat__desc">Specify in the reason field below</div>
                    </div>
                </label>
            </div>

            <div class="bw-label">Reason / Explanation <span class="req">*</span></div>
            <div class="bw-reason-chips" id="bwReasonChips">
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Student is on a full bursary / sponsorship and all tuition fees are covered by the sponsoring organisation.')">Bursary / Sponsorship</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Scholarship award — student has been granted a scholarship that covers these fees in full or in part.')">Scholarship Award</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Double billing error — student was charged more than once for the same item in the same semester.')">Double Billing</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Wrong billing — student was billed for a semester, programme, or fee item that does not apply to them.')">Wrong Billing</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Wrong programme billing — student was billed under an incorrect programme or study level, resulting in an erroneous charge.')">Wrong Programme Billing</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Fee structure error — the incorrect fee rate or item was applied due to a system or administrative error.')">Fee Structure Error</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Student did not register for this semester and was incorrectly billed. No academic activities were undertaken.')">Did Not Register</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Student withdrew before semester commencement and is not liable for these fees per institutional policy.')">Withdrew Before Semester</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Student was on approved leave of absence for this period and should not have been billed.')">Leave of Absence</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Medical or compassionate grounds — waiver approved by administration following review of supporting documentation.')">Medical / Compassionate</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Staff or staff dependent benefit entitlement — fees waived in accordance with the institutional staff benefits policy.')">Staff Benefit</button>
                <button type="button" class="bw-reason-chip" onclick="applyReasonChip(this, 'Government / district sponsorship — student fees are fully covered by a government bursary or district scholarship scheme.')">Government Sponsorship</button>
            </div>
            <textarea id="bwReason" class="bw-reason-area" placeholder="Provide a detailed explanation for this waiver, or select a quick reason above..." maxlength="500"></textarea>
            <div style="font-size:9px;color:#999;text-align:right;margin-top:2px;"><span id="bwReasonCount">0</span>/500</div>
            <div id="bwStep3Error" style="display:none;font-size:11px;color:#c62828;margin-top:6px;"></div>
        </div>

        <!-- Step 4: Summary & Confirm -->
        <div class="bw-panel" id="panel4">
            <div id="bwSummary" class="bw-summary"></div>
        </div>

        <!-- Step 5: Success (hidden until done) -->
        <div class="bw-panel" id="panel5">
            <div id="bwSuccess" class="bw-success"></div>
        </div>

        <!-- Footer Buttons -->
        <div class="bw-modal__footer">
            <button type="button" id="btnWizPrev" class="bw-btn bw-btn--ghost" onclick="wizardPrev()" style="display:none;">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                Back
            </button>
            <button type="button" id="btnWizNext" class="bw-btn bw-btn--primary" onclick="wizardNext()">
                Next
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
            </button>
            <button type="button" id="btnWizApply" class="bw-btn bw-btn--success" onclick="applyWaiver()" style="display:none;">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                Confirm &amp; Apply Waiver
            </button>
            <button type="button" id="btnWizClose" class="bw-btn bw-btn--ghost" onclick="closeWizard()" style="display:none;">Close</button>
        </div>
    </div>
</div>

<!-- ═══ BALANCE FIX MODAL ══════════════════════════════════════════════════════ -->
<div id="bwFixOverlay" class="bw-fix-overlay">
    <div class="bw-fix-modal">
        <div class="bw-modal__header">
            <div class="bw-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 1v22"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                Student Balance Fix
            </div>
            <button type="button" class="bw-modal__close" onclick="closeBalanceFix()">&times;</button>
        </div>
        <div class="bw-fix-body">
            <div class="bw-label">Search Student <span class="req">*</span></div>
            <div class="bw-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="bwFixSearch" class="bw-search-input" placeholder="Type registration number or student name..." autocomplete="off" />
                <div id="bwFixAcList" class="bw-ac-list"></div>
            </div>
            <div id="bwFixStudentCard" class="bw-student-card" style="margin-bottom:10px;">
                <div>
                    <div class="bw-student-card__name" id="bwFixStudName"></div>
                    <div class="bw-student-card__detail" id="bwFixStudDetail"></div>
                </div>
                <button type="button" class="bw-student-card__remove" onclick="clearFixStudent()">Change</button>
            </div>

            <div class="bw-fix-grid">
                <div class="bw-fix-card">
                    <div class="bw-fix-card__label">Current Balance</div>
                    <div class="bw-fix-card__val" id="bwFixCurrentBal">UGX 0</div>
                </div>
                <div>
                    <label class="bw-label" style="margin-bottom:6px;">Target Balance <span class="req">*</span></label>
                    <!-- Sign toggle: Outstanding (student owes) | Zero only. Credit not permitted. -->
                    <div style="display:flex;gap:6px;margin-bottom:8px;">
                        <button type="button" id="bwSignOutstanding" onclick="setFixSign('positive')"
                            style="flex:1;padding:7px 4px;font-size:11px;font-weight:700;border:2px solid #dc3545;background:#fef2f2;color:#dc3545;cursor:pointer;transition:all .15s;"
                            title="Student will STILL OWE money (positive balance)">&#9650; Outstanding</button>
                        <button type="button" id="bwSignZero" onclick="setFixSign('zero')"
                            style="flex:1;padding:7px 4px;font-size:11px;font-weight:700;border:2px solid #cdd3de;background:#fff;color:#555;cursor:pointer;transition:all .15s;"
                            title="Set balance exactly to zero (fully cleared)">&#9679; Nil / Zero</button>
                    </div>
                    <div class="bw-fix-target">
                        <input type="text" id="bwFixTarget" class="bw-search-input bw-fix-amt" style="padding-left:12px;" placeholder="Enter amount" inputmode="numeric" pattern="[0-9]*" autocomplete="off" />
                    </div>
                </div>
            </div>

            <div id="bwFixImpact" class="bw-fix-impact" style="display:none;">
                <div class="bw-fix-impact__title" id="bwFixImpactTitle"></div>
                <div class="bw-fix-impact__line" id="bwFixImpactLine"></div>
            </div>

            <div class="bw-label" style="margin-top:10px;">Reason <span class="req">*</span></div>
            <div class="bw-fix-suggest">
                <button type="button" class="bw-fix-suggest__btn" onclick="pickFixReason(this)">Correct carried-forward balance</button>
                <button type="button" class="bw-fix-suggest__btn" onclick="pickFixReason(this)">Resolve billing mismatch after reconciliation</button>
                <button type="button" class="bw-fix-suggest__btn" onclick="pickFixReason(this)">Align account with approved finance review</button>
                <button type="button" class="bw-fix-suggest__btn" onclick="pickFixReason(this)">Correct manual posting error on student account</button>
                <button type="button" class="bw-fix-suggest__btn" onclick="pickFixReason(this)">Adjust account to confirmed outstanding balance</button>
            </div>
            <textarea id="bwFixReason" class="bw-reason-area bw-fix-reason" placeholder="Why is this balance correction required?" maxlength="500"></textarea>
            <div style="font-size:9px;color:#999;text-align:right;margin-top:2px;"><span id="bwFixReasonCount">0</span>/500</div>
            <div id="bwFixError" style="display:none;font-size:11px;color:#c62828;margin-top:6px;"></div>
        </div>
        <div class="bw-modal__footer">
            <button type="button" class="bw-btn bw-btn--ghost" onclick="closeBalanceFix()">Cancel</button>
            <button type="button" id="btnApplyFix" class="bw-btn bw-btn--success" onclick="applyBalanceFix()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                Confirm Balance Fix
            </button>
        </div>
    </div>
</div>
<!-- ═══ DETAIL MODAL ═════════════════════════════════════════════════════════════ -->
<div id="bwDetailOverlay" class="bw-detail-overlay">
    <div class="bw-detail-modal">
        <div class="bw-modal__header">
            <div class="bw-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                Waiver Details
            </div>
            <button type="button" class="bw-modal__close" onclick="closeDetail()">&times;</button>
        </div>
        <div id="bwDetailBody" style="min-height:100px;">
            <div style="padding:30px;text-align:center;"><span class="bw-spinner"></span> Loading...</div>
        </div>
        <div class="bw-modal__footer">
            <button type="button" class="bw-btn bw-btn--ghost" onclick="closeDetail()">Close</button>
        </div>
    </div>
</div>

<!-- ═══ REVERSE CONFIRMATION MODAL ═══════════════════════════════════════════════ -->
<div id="bwReverseOverlay" class="bw-reverse-overlay">
    <div class="bw-reverse-modal">
        <div class="bw-modal__header" style="background:#c62828;">
            <div class="bw-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>
                Reverse Waiver
            </div>
            <button type="button" class="bw-modal__close" onclick="closeReverse()">&times;</button>
        </div>
        <div style="padding:18px;">
            <div id="bwReverseSummary" class="bw-reverse__summary"></div>
            <div class="bw-label">Reason for Reversal <span class="req">*</span></div>
            <textarea id="bwReverseReason" class="bw-reason-area" placeholder="Explain why this waiver is being reversed..." maxlength="500"></textarea>
            <div style="font-size:9px;color:#999;text-align:right;margin-top:2px;"><span id="bwRevReasonCount">0</span>/500</div>
            <div id="bwReverseError" style="display:none;font-size:11px;color:#c62828;margin-top:6px;"></div>
            <div class="bw-summary__warning" style="margin-top:12px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                <span id="bwReverseWarnText">This will <strong>reverse the waiver</strong> and re-bill the student. A debit entry will be created for the full waiver amount. This action is logged and auditable.</span>
            </div>
        </div>
        <div class="bw-modal__footer">
            <button type="button" class="bw-btn bw-btn--ghost" onclick="closeReverse()">Cancel</button>
            <button type="button" id="btnConfirmReverse" class="bw-btn bw-btn--danger" onclick="submitReversal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>
                Confirm Reversal
            </button>
        </div>
    </div>
</div>
<!-- ═══ JAVASCRIPT ═══════════════════════════════════════════════════════ -->
<script type="text/javascript">
(function () {
    'use strict';

    // ── State ─────────────────────────────────────────────────────────
    var _step = 1;
    var _student = null;   // { regno, name, programme, session, status }
    var _bills = [];       // loaded from server
    var _selectedTIDs = {}; // { tid: amount }
    var _category = '';
    var _reason = '';
    var _searchTimer = null;
    var _fixStudent = null;
    var _fixCurrentBalance = 0;
    var _fixSearchTimer = null;

    // Resolve the page URL for AJAX
    var _pageUrl = window.location.pathname;

    // ── Wizard Open / Close ───────────────────────────────────────────
    window.openWizard = function () {
        _step = 1;
        _student = null;
        _bills = [];
        _selectedTIDs = {};
        _category = '';
        _reason = '';
        document.getElementById('bwSearch').value = '';
        document.getElementById('bwStudentCard').className = 'bw-student-card';
        document.getElementById('bwAcList').className = 'bw-ac-list';
        var cats = document.querySelectorAll('input[name="bwCat"]');
        for (var i = 0; i < cats.length; i++) cats[i].checked = false;
        var catLabels = document.querySelectorAll('.bw-cat');
        for (var j = 0; j < catLabels.length; j++) catLabels[j].className = 'bw-cat';
        document.getElementById('bwReason').value = '';
        hideError(1); hideError(2); hideError(3);
        updateStepUI();
        document.getElementById('bwOverlay').className = 'bw-overlay bw-overlay--visible';
    };

    window.closeWizard = function () {
        document.getElementById('bwOverlay').className = 'bw-overlay';
    };

    // ── Step Navigation ───────────────────────────────────────────────
    window.wizardNext = function () {
        if (!validateStep(_step)) return;
        if (_step === 1) {
            // Moving to Step 2 — load bills
            _step = 2;
            updateStepUI();
            loadBills();
        } else if (_step === 2) {
            _step = 3;
            updateStepUI();
        } else if (_step === 3) {
            // Save category & reason, build summary
            var catEl = document.querySelector('input[name="bwCat"]:checked');
            _category = catEl ? catEl.value : '';
            _reason = document.getElementById('bwReason').value.trim();
            _step = 4;
            updateStepUI();
            buildSummary();
        }
    };

    window.wizardPrev = function () {
        if (_step > 1 && _step <= 4) {
            _step--;
            updateStepUI();
        }
    };

    function updateStepUI() {
        // Panels
        for (var i = 1; i <= 5; i++) {
            var p = document.getElementById('panel' + i);
            if (p) p.className = (i === _step) ? 'bw-panel bw-panel--active' : 'bw-panel';
        }
        // Step tabs
        for (var s = 1; s <= 4; s++) {
            var tab = document.getElementById('stepTab' + s);
            if (!tab) continue;
            if (s < _step) tab.className = 'bw-step bw-step--done';
            else if (s === _step) tab.className = 'bw-step bw-step--active';
            else tab.className = 'bw-step';
        }
        // Buttons
        var btnPrev = document.getElementById('btnWizPrev');
        var btnNext = document.getElementById('btnWizNext');
        var btnApply = document.getElementById('btnWizApply');
        var btnClose = document.getElementById('btnWizClose');
        btnPrev.style.display = (_step > 1 && _step <= 4) ? '' : 'none';
        btnNext.style.display = (_step >= 1 && _step <= 3) ? '' : 'none';
        btnApply.style.display = (_step === 4) ? '' : 'none';
        btnClose.style.display = (_step === 5) ? '' : 'none';
        if (_step === 5) btnPrev.style.display = 'none';
    }

    // ── Validation ────────────────────────────────────────────────────
    function validateStep(step) {
        if (step === 1) {
            if (!_student) { showError(1, 'Please search and select a student first.'); return false; }
            hideError(1);
            return true;
        }
        if (step === 2) {
            syncAmountsFromDOM();
            var count = 0, hasInvalid = false;
            for (var t in _selectedTIDs) {
                if (!_selectedTIDs.hasOwnProperty(t)) continue;
                count++;
                var inp = document.getElementById('bwAmt_' + t);
                var maxAmt = inp ? parseFloat(inp.getAttribute('data-max')) : 0;
                var val = _selectedTIDs[t];
                if (val <= 0 || val > maxAmt) {
                    hasInvalid = true;
                    if (inp) inp.classList.add('bw-amt--error');
                }
            }
            if (count === 0) { showError(2, 'Please select at least one bill to waive.'); return false; }
            if (hasInvalid) { showError(2, 'One or more waive amounts are invalid. Each amount must be between 1 and the bill amount.'); return false; }
            hideError(2);
            return true;
        }
        if (step === 3) {
            var catEl = document.querySelector('input[name="bwCat"]:checked');
            if (!catEl) { showError(3, 'Please select a waiver category.'); return false; }
            var reason = document.getElementById('bwReason').value.trim();
            if (!reason || reason.length < 5) { showError(3, 'Please provide a reason (at least 5 characters).'); document.getElementById('bwReason').classList.add('bw-field--error'); return false; }
            document.getElementById('bwReason').classList.remove('bw-field--error');
            hideError(3);
            return true;
        }
        return true;
    }

    function showError(step, msg) {
        var el = document.getElementById('bwStep' + step + 'Error');
        if (el) { el.style.display = 'block'; el.textContent = msg; }
    }
    function hideError(step) {
        var el = document.getElementById('bwStep' + step + 'Error');
        if (el) el.style.display = 'none';
    }

    // ── Student Search ────────────────────────────────────────────────
    var searchBox = document.getElementById('bwSearch');
    if (searchBox) {
        searchBox.addEventListener('input', function () {
            clearTimeout(_searchTimer);
            var q = this.value.trim();
            if (q.length < 2) { hideAC(); return; }
            _searchTimer = setTimeout(function () { doSearch(q); }, 250);
        });
        searchBox.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') hideAC();
        });
    }

    function doSearch(q) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', _pageUrl + '?ajax=search&q=' + encodeURIComponent(q), true);
        xhr.onload = function () {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    renderAC(data.results || []);
                } catch (e) { hideAC(); }
            }
        };
        xhr.send();
    }

    function renderAC(results) {
        var list = document.getElementById('bwAcList');
        if (!results.length) { list.innerHTML = '<div class="bw-ac-item" style="color:#999;cursor:default;">No students found</div>'; list.className = 'bw-ac-list bw-ac-list--visible'; return; }
        var html = '';
        for (var i = 0; i < results.length; i++) {
            var r = results[i];
            html += '<div class="bw-ac-item" data-idx="' + i + '" onclick="selectStudent(' + i + ')">' +
                '<div><span class="bw-ac-item__name">' + esc(r.name) + '</span> <span style="color:#999;font-size:10px;">(' + esc(r.regno) + ')</span></div>' +
                '<span class="bw-ac-item__meta">' + esc(r.programme) + ' &middot; ' + esc(r.status) + '</span></div>';
        }
        list.innerHTML = html;
        list.className = 'bw-ac-list bw-ac-list--visible';
        list._data = results;
    }

    function hideAC() {
        document.getElementById('bwAcList').className = 'bw-ac-list';
    }

    window.selectStudent = function (idx) {
        var list = document.getElementById('bwAcList');
        var data = list._data;
        if (!data || !data[idx]) return;
        _student = data[idx];
        document.getElementById('bwStudName').textContent = _student.name + ' (' + _student.regno + ')';
        document.getElementById('bwStudDetail').textContent = _student.programme + ' \u2022 ' + _student.session + ' \u2022 ' + _student.status;
        document.getElementById('bwStudentCard').className = 'bw-student-card bw-student-card--visible';
        document.getElementById('bwSearch').value = '';
        hideAC();
        hideError(1);
    };

    window.clearStudent = function () {
        _student = null;
        document.getElementById('bwStudentCard').className = 'bw-student-card';
        document.getElementById('bwSearch').value = '';
        document.getElementById('bwSearch').focus();
    };

    // ── Balance Fix Modal ────────────────────────────────────────────
    // Credit (negative) target is NOT permitted. A student always owes the school or is cleared.
    // Allowed signs: 'positive' (outstanding) or 'zero' (fully cleared).
    var _fixSign = 'positive';

    window.setFixSign = function (sign) {
        // Guard: silently coerce any attempt to set 'negative' -> 'positive'
        if (sign === 'negative') sign = 'positive';
        _fixSign = sign;
        var styles = {
            positive: { id: 'bwSignOutstanding', border: '#dc3545', bg: '#fef2f2', color: '#dc3545' },
            zero:     { id: 'bwSignZero',        border: '#174DA4', bg: '#e8f0fc', color: '#174DA4' }
        };
        ['positive','zero'].forEach(function(s) {
            var btn = document.getElementById(styles[s].id);
            if (!btn) return;
            if (s === sign) {
                btn.style.borderColor = styles[s].border;
                btn.style.background  = styles[s].bg;
                btn.style.color       = styles[s].color;
            } else {
                btn.style.borderColor = '#cdd3de';
                btn.style.background  = '#fff';
                btn.style.color       = '#555';
            }
        });
        if (sign === 'zero') {
            document.getElementById('bwFixTarget').value = '0';
            document.getElementById('bwFixTarget').disabled = true;
        } else {
            document.getElementById('bwFixTarget').disabled = false;
            if (document.getElementById('bwFixTarget').value === '0')
                document.getElementById('bwFixTarget').value = '';
        }
        computeFixImpact();
        hideFixError();
    };

    window.openBalanceFix = function () {
        _fixStudent = null;
        _fixCurrentBalance = 0;
        document.getElementById('bwFixSearch').value = '';
        document.getElementById('bwFixAcList').className = 'bw-ac-list';
        document.getElementById('bwFixStudentCard').className = 'bw-student-card';
        document.getElementById('bwFixCurrentBal').textContent = 'UGX 0';
        document.getElementById('bwFixTarget').value = '';
        document.getElementById('bwFixTarget').disabled = false;
        document.getElementById('bwFixReason').value = '';
        document.getElementById('bwFixReasonCount').textContent = '0';
        document.getElementById('bwFixImpact').style.display = 'none';
        setFixSign('positive'); // default: outstanding
        hideFixError();
        var btn = document.getElementById('btnApplyFix');
        btn.disabled = false;
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Confirm Balance Fix';
        document.getElementById('bwFixOverlay').className = 'bw-fix-overlay bw-fix-overlay--visible';
    };

    window.closeBalanceFix = function () {
        document.getElementById('bwFixOverlay').className = 'bw-fix-overlay';
    };

    function showFixError(msg) {
        var el = document.getElementById('bwFixError');
        el.textContent = msg || '';
        el.style.display = msg ? 'block' : 'none';
    }

    function hideFixError() {
        document.getElementById('bwFixError').style.display = 'none';
    }

    var fixSearchBox = document.getElementById('bwFixSearch');
    if (fixSearchBox) {
        fixSearchBox.addEventListener('input', function () {
            clearTimeout(_fixSearchTimer);
            var q = this.value.trim();
            if (q.length < 2) {
                document.getElementById('bwFixAcList').className = 'bw-ac-list';
                return;
            }
            _fixSearchTimer = setTimeout(function () {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', _pageUrl + '?ajax=search&q=' + encodeURIComponent(q), true);
                xhr.onload = function () {
                    if (xhr.status !== 200) return;
                    try {
                        var data = JSON.parse(xhr.responseText);
                        renderFixAC(data.results || []);
                    } catch (e) { }
                };
                xhr.send();
            }, 250);
        });
    }

    function renderFixAC(results) {
        var list = document.getElementById('bwFixAcList');
        if (!results.length) {
            list.innerHTML = '<div class="bw-ac-item" style="color:#999;cursor:default;">No students found</div>';
            list.className = 'bw-ac-list bw-ac-list--visible';
            return;
        }
        var html = '';
        for (var i = 0; i < results.length; i++) {
            var r = results[i];
            html += '<div class="bw-ac-item" onclick="selectFixStudent(' + i + ')">' +
                '<div><span class="bw-ac-item__name">' + esc(r.name) + '</span> <span style="color:#999;font-size:10px;">(' + esc(r.regno) + ')</span></div>' +
                '<span class="bw-ac-item__meta">' + esc(r.programme) + ' &middot; ' + esc(r.status) + '</span></div>';
        }
        list.innerHTML = html;
        list.className = 'bw-ac-list bw-ac-list--visible';
        list._data = results;
    }

    window.selectFixStudent = function (idx) {
        var list = document.getElementById('bwFixAcList');
        var data = list._data;
        if (!data || !data[idx]) return;
        _fixStudent = data[idx];
        document.getElementById('bwFixStudName').textContent = _fixStudent.name + ' (' + _fixStudent.regno + ')';
        document.getElementById('bwFixStudDetail').textContent = _fixStudent.programme + ' • ' + _fixStudent.session + ' • ' + _fixStudent.status;
        document.getElementById('bwFixStudentCard').className = 'bw-student-card bw-student-card--visible';
        document.getElementById('bwFixSearch').value = '';
        document.getElementById('bwFixAcList').className = 'bw-ac-list';
        loadFixBalance();
        hideFixError();
    };

    window.clearFixStudent = function () {
        _fixStudent = null;
        _fixCurrentBalance = 0;
        document.getElementById('bwFixStudentCard').className = 'bw-student-card';
        document.getElementById('bwFixCurrentBal').textContent = 'UGX 0';
        document.getElementById('bwFixImpact').style.display = 'none';
        document.getElementById('bwFixSearch').focus();
    };

    function loadFixBalance() {
        if (!_fixStudent) return;
        document.getElementById('bwFixCurrentBal').textContent = 'Loading...';
        var xhr = new XMLHttpRequest();
        xhr.open('GET', _pageUrl + '?ajax=balance&regno=' + encodeURIComponent(_fixStudent.regno), true);
        xhr.onload = function () {
            try {
                var data = JSON.parse(xhr.responseText);
                if (!data.ok) throw new Error(data.error || 'Failed to load balance');
                _fixCurrentBalance = parseFloat(data.current_balance || '0');

                // Show current balance with clear color + credit/outstanding label
                var balEl = document.getElementById('bwFixCurrentBal');
                if (_fixCurrentBalance < -0.01) {
                    // Student is in credit (data error / legacy posting). Show clearly; target must be outstanding or zero.
                    balEl.innerHTML = '<span style="color:#e67e00;font-weight:800;">- UGX ' + formatNum(Math.abs(_fixCurrentBalance)) + '</span>' +
                        '<div style="font-size:10px;color:#e67e00;font-weight:600;margin-top:2px;">&#9888; Erroneously in credit &mdash; fix to outstanding or zero</div>';
                    setFixSign('positive');
                } else if (_fixCurrentBalance > 0.01) {
                    balEl.innerHTML = '<span style="color:#dc3545;font-weight:800;">UGX ' + formatNum(_fixCurrentBalance) + '</span>' +
                        '<div style="font-size:10px;color:#dc3545;font-weight:600;margin-top:2px;">&#9650; Outstanding balance (owes)</div>';
                    // Auto-select Outstanding sign
                    setFixSign('positive');
                } else {
                    balEl.innerHTML = '<span style="color:#555;font-weight:800;">UGX 0</span>' +
                        '<div style="font-size:10px;color:#555;font-weight:600;margin-top:2px;">&#9679; Cleared</div>';
                    setFixSign('positive');
                }
                computeFixImpact();
            } catch (e) {
                document.getElementById('bwFixCurrentBal').textContent = 'Error';
                showFixError(e.message || 'Failed to load current balance.');
            }
        };
        xhr.onerror = function () {
            document.getElementById('bwFixCurrentBal').textContent = 'Error';
            showFixError('Network error while loading student balance.');
        };
        xhr.send();
    }

    function parsePositiveIntegerMagnitude(val) {
        var raw = (val || '').replace(/[^0-9]/g, '');
        if (raw === '') return NaN;
        var n = parseInt(raw, 10);
        if (isNaN(n)) return NaN;
        return Math.abs(n);
    }

    function normalizeFixTargetInput() {
        var el = document.getElementById('bwFixTarget');
        if (!el) return;
        var raw = (el.value || '').replace(/[^0-9]/g, '');
        if (raw === '') {
            el.value = '';
            return;
        }
        var n = parseInt(raw, 10);
        if (isNaN(n)) {
            el.value = '';
            return;
        }
        el.value = formatNum(Math.abs(n));
    }

    function formatSignedMoney(n) {
        var num = Number(n || 0);
        if (num > 0) return 'UGX ' + formatNum(num);
        if (num < 0) return '- UGX ' + formatNum(Math.abs(num));
        return 'UGX 0';
    }

    function computeFixImpact() {
        var magnitude = parsePositiveIntegerMagnitude(document.getElementById('bwFixTarget').value);
        var impact = document.getElementById('bwFixImpact');
        var title = document.getElementById('bwFixImpactTitle');
        var line = document.getElementById('bwFixImpactLine');

        if (isNaN(magnitude) || !_fixStudent) {
            impact.style.display = 'none';
            return null;
        }

        // Target is always positive (outstanding) or zero. Credit targets are not permitted.
        var target = (_fixSign === 'zero') ? 0 : Math.abs(magnitude);

        var delta = _fixCurrentBalance - target;
        var amount = Math.abs(delta);
        impact.className = 'bw-fix-impact';

        if (amount < 0.01) {
            title.textContent = 'No adjustment needed';
            line.textContent = 'Current balance ' + formatSignedMoney(_fixCurrentBalance) + ' already equals target balance ' + formatSignedMoney(target) + '.';
            impact.style.display = '';
            return { target: target, delta: delta, amount: amount, action: 'NONE' };
        }

        if (delta > 0) {
            impact.className = 'bw-fix-impact bw-fix-impact--credit';
            title.textContent = 'Credit Adjustment (Payment Transaction)';
            line.textContent = 'System will post a credit entry of UGX ' + formatNum(amount) + ' to move balance from ' + formatSignedMoney(_fixCurrentBalance) + ' to ' + formatSignedMoney(target) + '.';
            impact.style.display = '';
            return { target: target, delta: delta, amount: amount, action: 'CR' };
        }

        impact.className = 'bw-fix-impact bw-fix-impact--debit';
        title.textContent = 'Debit Adjustment (Bill Transaction)';
        line.textContent = 'System will post DR of UGX ' + formatNum(amount) + ' to move balance from ' + formatSignedMoney(_fixCurrentBalance) + ' to ' + formatSignedMoney(target) + '.';
        impact.style.display = '';
        return { target: target, delta: delta, amount: amount, action: 'DR' };
    }

    document.getElementById('bwFixTarget').addEventListener('input', function () {
        normalizeFixTargetInput();
        computeFixImpact();
        hideFixError();
    });

    document.getElementById('bwFixTarget').addEventListener('blur', function () {
        normalizeFixTargetInput();
        computeFixImpact();
    });

    document.getElementById('bwFixReason').addEventListener('input', function () {
        document.getElementById('bwFixReasonCount').textContent = this.value.length;
        if (this.value.trim().length >= 5) this.classList.remove('bw-field--error');
    });

    window.pickFixReason = function (btn) {
        var txt = btn.textContent || btn.innerText || '';
        var area = document.getElementById('bwFixReason');
        area.value = txt;
        document.getElementById('bwFixReasonCount').textContent = txt.length;
        area.classList.remove('bw-field--error');
        area.focus();
        hideFixError();
    };

    window.applyBalanceFix = function () {
        hideFixError();
        if (!_fixStudent) {
            showFixError('Please search and select a student account first.');
            return;
        }

        var impact = computeFixImpact();
        var reason = document.getElementById('bwFixReason').value.trim();
        if (!impact || isNaN(impact.target)) {
            showFixError('Please enter a valid whole-number amount.');
            return;
        }
        if (impact.amount < 0.01) {
            showFixError('No adjustment is required: current balance already equals the target balance.');
            return;
        }
        if (!reason || reason.length < 5) {
            document.getElementById('bwFixReason').classList.add('bw-field--error');
            showFixError('Please provide a reason (at least 5 characters).');
            return;
        }

        var btn = document.getElementById('btnApplyFix');
        btn.disabled = true;
        btn.innerHTML = '<span class="bw-spinner"></span> Posting...';

        var payload = JSON.stringify({
            regno: _fixStudent.regno,
            target_balance: Math.abs(impact.target),
            target_balance_sign: '+', // always outstanding or zero; credit targets disallowed
            reason: reason
        });

        var xhr = new XMLHttpRequest();
        xhr.open('POST', _pageUrl + '?ajax=apply_fix', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onload = function () {
            try {
                var resp = JSON.parse(xhr.responseText);
                if (resp.ok) {
                    alert((resp.message || 'Balance fix posted.') + '\nTransaction TID: ' + resp.tracking_tid + '\nGL TID: ' + resp.gl_tid);
                    window.location.reload();
                    return;
                }
                showFixError(resp.error || 'Failed to apply balance fix.');
            } catch (e) {
                showFixError('Failed to parse server response.');
            }
            btn.disabled = false;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Confirm Balance Fix';
        };
        xhr.onerror = function () {
            showFixError('Network error. Please try again.');
            btn.disabled = false;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Confirm Balance Fix';
        };
        xhr.send(payload);
    };

    // ── Load Bills ────────────────────────────────────────────────────
    var _studentBalance = null; // current outstanding balance from fin_ledger
    function loadBills() {
        if (!_student) return;
        var loading = document.getElementById('bwBillsLoading');
        var content = document.getElementById('bwBillsContent');
        loading.style.display = '';
        content.style.display = 'none';
        _selectedTIDs = {};
        _studentBalance = null;

        var xhr = new XMLHttpRequest();
        xhr.open('GET', _pageUrl + '?ajax=bills&regno=' + encodeURIComponent(_student.regno), true);
        xhr.onload = function () {
            loading.style.display = 'none';
            content.style.display = '';
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.error) { content.innerHTML = '<div class="bw-empty" style="color:#c62828;">' + esc(data.error) + '</div>'; return; }
                _bills = data.bills || [];
                _studentBalance = (data.current_balance !== undefined) ? parseFloat(data.current_balance) : null;
                renderBills();
            } catch (e) {
                content.innerHTML = '<div class="bw-empty" style="color:#c62828;">Failed to load bills.</div>';
            }
        };
        xhr.onerror = function () {
            loading.style.display = 'none';
            content.style.display = '';
            content.innerHTML = '<div class="bw-empty" style="color:#c62828;">Network error. Please try again.</div>';
        };
        xhr.send();
    }

    function renderBills() {
        var content = document.getElementById('bwBillsContent');
        if (!_bills.length) {
            content.innerHTML = '<div class="bw-empty">No posted bills found for this student. Only DR (Bill) transactions with status “Posted” can be waived.</div>';
            return;
        }

        var html = '';

        // ── Balance strip ──
        if (_studentBalance !== null) {
            var balAbs = Math.abs(_studentBalance);
            var balFmt = 'UGX ' + formatNum(balAbs);
            var balLabel, balColor;
            if (_studentBalance > 0)      { balLabel = 'Outstanding Balance'; balColor = '#c62828'; }
            else if (_studentBalance < 0) { balLabel = 'Credit Balance';      balColor = '#2e7d32'; }
            else                          { balLabel = 'Balance';              balColor = '#05275C'; balFmt = 'UGX 0'; }
            html += '<div class="bw-balance-strip">';
            html += '<span class="bw-balance-strip__label">' + balLabel + '</span>';
            html += '<strong style="color:' + balColor + ';font-size:12px;">' + balFmt + '</strong>';
            html += '</div>';
        }

        // ── Table ──
        html += '<table class="bw-bills-table"><thead><tr>';
        html += '<th style="width:40px;text-align:center;"><input type="checkbox" id="bwCheckAll" onclick="toggleAllBills(this)" class="bw-bill-check" title="Select all" /></th>';
        html += '<th>Fee Item</th>';
        html += '<th style="min-width:140px;">Academic Period</th>';
        html += '<th class="bw-table--right" style="min-width:110px;">Bill Amount</th>';
        html += '<th class="bw-table--right" style="min-width:170px;">Waive Amount</th>';
        html += '<th style="min-width:75px;">Status</th>';
        html += '</tr></thead><tbody>';

        for (var i = 0; i < _bills.length; i++) {
            var b = _bills[i];
            var waived = b.already_waived;
            html += '<tr class="' + (waived ? 'bw-bill--waived' : '') + '" data-tid="' + b.tid + '">';

            // ── Checkbox ──
            if (waived) {
                html += '<td style="text-align:center;"><input type="checkbox" disabled class="bw-bill-check" title="Already waived" /></td>';
            } else {
                html += '<td style="text-align:center;"><input type="checkbox" class="bw-bill-check" data-tid="' + b.tid + '" data-amt="' + b.amount + '" onchange="toggleBill(this)" /></td>';
            }

            // ── Fee Item cell ──
            var nm = b.item_name || 'Unknown';
            var nmLow = nm.toLowerCase();
            var badgeClass = nmLow.indexOf('tuition') >= 0 ? 'bw-fee-badge--tuition' :
                             nmLow.indexOf('function') >= 0 ? 'bw-fee-badge--function' : 'bw-fee-badge--other';
            // Short badge label: first meaningful word
            var badgeWord = nm.split(' ')[0];
            html += '<td>';
            html += '<div class="bw-bill-item">';
            html += '<div class="bw-bill-item__name">' + esc(nm) + '</div>';
            html += '<div class="bw-bill-item__meta">';
            html += '<span class="bw-fee-badge ' + badgeClass + '">' + esc(badgeWord) + '</span>';
            var tidLabel = (b.source === 'ledger') ? ('GL TID ' + b.gl_tid) : ('TID ' + b.tid);
            html += '<span class="bw-bill-item__tid">' + tidLabel + '</span>';
            html += '<span class="bw-bill-item__date">Billed: ' + esc(b.date) + '</span>';
            html += '</div>';
            html += '</div>';
            html += '</td>';

            // ── Academic Period ──
            html += '<td>';
            html += '<div class="bw-bill-period">';
            html += '<div class="bw-bill-period__year">' + esc(b.acadyear) + '</div>';
            html += '<div class="bw-bill-period__sem">Semester ' + b.semester + '</div>';
            if (b.studyyear && b.studyyear > 0) html += '<div class="bw-bill-period__studyyr">Year ' + b.studyyear + '</div>';
            html += '</div>';
            html += '</td>';

            // ── Bill Amount ──
            html += '<td class="bw-table--right">';
            html += '<div class="bw-bill-amount">UGX ' + formatNum(b.amount) + '</div>';
            html += '</td>';

            // ── Waive Amount ──
            if (waived) {
                html += '<td class="bw-table--right"><span style="color:#999;font-size:10px;font-style:italic;">Already waived</span></td>';
            } else {
                html += '<td class="bw-table--right">';
                html += '<div class="bw-waive-cell">';
                html += '<input type="text" class="bw-amt-input" id="bwAmt_' + b.tid + '" data-tid="' + b.tid + '" data-max="' + b.amount + '" value="' + formatNum(b.amount) + '" disabled oninput="onAmtInput(this)" onblur="onAmtBlur(this)" title="Tick the checkbox then edit to enter a partial waive amount" />';
                html += '<span class="bw-amt-hint" id="bwAmtHint_' + b.tid + '"></span>';
                html += '</div>';
                html += '</td>';
            }

            // ── Status ──
            html += '<td>' + (waived ? '<span class="fs-badge--amber">Waived</span>' : '<span class="fs-badge--green">Active</span>') + '</td>';
            html += '</tr>';
        }

        html += '</tbody></table>';
        html += '<div class="bw-bills-total" id="bwBillsTotal">';
        html += '<span class="bw-bills-total__count">Selected: <span id="bwSelCount">0</span> bill(s)</span>';
        html += '<span class="bw-bills-total__sum">Total to Waive: <strong>UGX <span id="bwSelTotal">0</span></strong></span>';
        html += '</div>';
        content.innerHTML = html;
    }

    window.toggleBill = function (el) {
        var tid = el.getAttribute('data-tid');
        var fullAmt = parseFloat(el.getAttribute('data-amt'));
        var row = el.closest('tr');
        var amtInput = document.getElementById('bwAmt_' + tid);
        var hint = document.getElementById('bwAmtHint_' + tid);
        if (el.checked) {
            // Enable the amount input and set to full amount by default
            if (amtInput) {
                amtInput.disabled = false;
                amtInput.value = formatNum(fullAmt);
                amtInput.classList.remove('bw-amt--error', 'bw-amt--partial');
            }
            if (hint) hint.textContent = 'Full amount — edit to customise';
            _selectedTIDs[tid] = fullAmt;
            if (row) row.classList.add('bw-bill--selected');
        } else {
            // Disable and reset the amount input
            if (amtInput) {
                amtInput.disabled = true;
                amtInput.value = formatNum(fullAmt);
                amtInput.classList.remove('bw-amt--error', 'bw-amt--partial');
            }
            if (hint) hint.textContent = '';
            delete _selectedTIDs[tid];
            if (row) row.classList.remove('bw-bill--selected');
        }
        updateSelectionTotal();
        hideError(2);
    };

    /* Handle custom amount typing */
    window.onAmtInput = function (inp) {
        var tid = inp.getAttribute('data-tid');
        var maxAmt = parseFloat(inp.getAttribute('data-max'));
        var hint = document.getElementById('bwAmtHint_' + tid);
        // Strip non-numeric chars except dot
        var raw = inp.value.replace(/[^0-9.]/g, '');
        var val = parseFloat(raw);
        inp.classList.remove('bw-amt--error', 'bw-amt--partial');
        if (isNaN(val) || val <= 0) {
            inp.classList.add('bw-amt--error');
            if (hint) hint.textContent = 'Enter amount > 0';
            _selectedTIDs[tid] = 0; // temp invalid — validation will catch
        } else if (val > maxAmt) {
            inp.classList.add('bw-amt--error');
            if (hint) hint.textContent = 'Exceeds bill (' + formatNum(maxAmt) + ')';
            _selectedTIDs[tid] = 0;
        } else {
            if (val < maxAmt) {
                inp.classList.add('bw-amt--partial');
                if (hint) hint.textContent = 'Partial: ' + Math.round(val / maxAmt * 100) + '% of bill';
            } else {
                if (hint) hint.textContent = 'Full amount';
            }
            _selectedTIDs[tid] = val;
        }
        updateSelectionTotal();
    };

    window.onAmtBlur = function (inp) {
        var tid = inp.getAttribute('data-tid');
        var maxAmt = parseFloat(inp.getAttribute('data-max'));
        var hint = document.getElementById('bwAmtHint_' + tid);
        var raw = inp.value.replace(/[^0-9.]/g, '');
        var val = parseFloat(raw);
        inp.classList.remove('bw-amt--error', 'bw-amt--partial');
        if (isNaN(val) || val <= 0) {
            val = maxAmt; // reset to full on invalid
        } else if (val > maxAmt) {
            val = maxAmt; // cap at max
        }
        inp.value = formatNum(val);
        if (val < maxAmt) {
            inp.classList.add('bw-amt--partial');
            if (hint) hint.textContent = 'Partial: ' + Math.round(val / maxAmt * 100) + '% of bill';
        } else {
            if (hint) hint.textContent = 'Full amount';
        }
        _selectedTIDs[tid] = val;
        updateSelectionTotal();
    };

    window.toggleAllBills = function (el) {
        var boxes = document.querySelectorAll('.bw-bills-table .bw-bill-check[data-tid]');
        for (var i = 0; i < boxes.length; i++) {
            boxes[i].checked = el.checked;
            var ev = new Event('change', { bubbles: true });
            boxes[i].dispatchEvent(ev);
        }
    };

    function updateSelectionTotal() {
        var count = 0, total = 0;
        for (var t in _selectedTIDs) {
            if (_selectedTIDs.hasOwnProperty(t)) { count++; total += _selectedTIDs[t]; }
        }
        var cntEl = document.getElementById('bwSelCount');
        var totEl = document.getElementById('bwSelTotal');
        if (cntEl) cntEl.textContent = count;
        if (totEl) totEl.textContent = formatNum(total);
    }

    /* Re-read every enabled waive-amount input back into _selectedTIDs.
       This guarantees the JS map is in sync with whatever the user typed,
       even if oninput/onblur didn't fire (focus still in the input, etc.). */
    function syncAmountsFromDOM() {
        var inputs = document.querySelectorAll('.bw-amt-input:not(:disabled)');
        for (var i = 0; i < inputs.length; i++) {
            var inp = inputs[i];
            var tid = inp.getAttribute('data-tid');
            if (!tid || !_selectedTIDs.hasOwnProperty(tid)) continue;
            var maxAmt = parseFloat(inp.getAttribute('data-max'));
            var raw = inp.value.replace(/[^0-9.]/g, '');
            var val = parseFloat(raw);
            if (isNaN(val) || val <= 0) val = 0;
            if (val > maxAmt) val = maxAmt;
            _selectedTIDs[tid] = val;
        }
    }

    // ── Category Radio Card Highlighting ──────────────────────────────
    document.getElementById('bwCats').addEventListener('change', function (e) {
        if (e.target.name !== 'bwCat') return;
        var labels = document.querySelectorAll('.bw-cat');
        for (var i = 0; i < labels.length; i++) labels[i].className = 'bw-cat';
        var parent = e.target.closest('.bw-cat');
        if (parent) parent.className = 'bw-cat bw-cat--selected';
        hideError(3);
    });

    // Reason quick-fill chips
    window.applyReasonChip = function (btn, text) {
        var ta = document.getElementById('bwReason');
        ta.value = text;
        document.getElementById('bwReasonCount').textContent = text.length;
        ta.classList.remove('bw-field--error');
        // Toggle active state on chips
        var chips = document.querySelectorAll('#bwReasonChips .bw-reason-chip');
        for (var i = 0; i < chips.length; i++) chips[i].classList.remove('bw-reason-chip--active');
        btn.classList.add('bw-reason-chip--active');
        ta.focus();
    };

    // Reason char counter
    document.getElementById('bwReason').addEventListener('input', function () {
        document.getElementById('bwReasonCount').textContent = this.value.length;
        if (this.value.trim().length >= 5) this.classList.remove('bw-field--error');
        // Clear chip active state when user types manually
        var chips = document.querySelectorAll('#bwReasonChips .bw-reason-chip');
        for (var i = 0; i < chips.length; i++) chips[i].classList.remove('bw-reason-chip--active');
    });

    // ── Build Summary (Step 4) ────────────────────────────────────────
    function buildSummary() {
        syncAmountsFromDOM();
        var html = '';

        // Student
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Student</span><span class="bw-summary__val">' + esc(_student.name) + ' (' + esc(_student.regno) + ')</span></div>';
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Programme</span><span class="bw-summary__val">' + esc(_student.programme) + '</span></div>';
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Category</span><span class="bw-summary__val">' + esc(_category) + '</span></div>';
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Reason</span><span class="bw-summary__val">' + esc(_reason) + '</span></div>';

        // Items
        html += '<div class="bw-label" style="margin-top:12px;">Bills to be waived:</div>';
        html += '<div class="bw-summary__items">';
        html += '<div class="bw-summary__item" style="font-weight:600;font-size:10px;text-transform:uppercase;color:#555;border-bottom:2px solid #e0e5ed;padding-bottom:4px;"><span>Bill</span><span style="display:flex;gap:30px;"><span style="min-width:100px;text-align:right;">Bill Amount</span><span style="min-width:100px;text-align:right;">Waive Amount</span></span></div>';
        var total = 0;
        var items = [];
        for (var tid in _selectedTIDs) {
            if (!_selectedTIDs.hasOwnProperty(tid)) continue;
            var amt = _selectedTIDs[tid];
            total += amt;
            // Find bill detail
            var detail = 'TID ' + tid;
            var fullAmt = amt;
            for (var b = 0; b < _bills.length; b++) {
                if (String(_bills[b].tid) === String(tid)) {
                    detail = _bills[b].item_name + ' — ' + _bills[b].date;
                    fullAmt = _bills[b].amount;
                    items.push({ tid: parseInt(tid), amount: amt });
                    break;
                }
            }
            var isPartial = (amt < fullAmt);
            var partialTag = isPartial ? ' <span style="font-size:9px;background:#fff3e0;color:#e65100;padding:1px 5px;border-radius:3px;font-weight:600;">PARTIAL</span>' : '';
            var tidDisp = (parseInt(tid) < 0) ? ('GL TID ' + Math.abs(parseInt(tid))) : ('TID ' + tid);
            html += '<div class="bw-summary__item"><span>' + tidDisp + ' — ' + esc(detail) + partialTag + '</span><span style="display:flex;gap:30px;"><span style="min-width:100px;text-align:right;color:#888;">UGX ' + formatNum(fullAmt) + '</span><span style="min-width:100px;text-align:right;font-weight:700;">UGX ' + formatNum(amt) + '</span></span></div>';
        }
        html += '</div>';

        // Total
        html += '<div class="bw-summary__total bw-summary__row"><span class="bw-summary__label">Total Credit to Student</span><span class="bw-summary__val">UGX ' + formatNum(total) + '</span></div>';

        // Standard warning
        html += '<div class="bw-summary__warning">';
        html += '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        html += '<span>This will create a <strong>credit of UGX ' + formatNum(total) + '</strong> on the student\'s fee account. This action will be logged and is auditable. Please verify all details before confirming.</span>';
        html += '</div>';

        document.getElementById('bwSummary').innerHTML = html;

        var applyBtn = document.getElementById('btnWizApply');
        if (applyBtn) {
            applyBtn.disabled = false;
            applyBtn.title = '';
        }
    }

    // ── Apply Waiver ──────────────────────────────────────────────────
    window.applyWaiver = function () {
        syncAmountsFromDOM();
        var btn = document.getElementById('btnWizApply');
        btn.disabled = true;
        btn.innerHTML = '<span class="bw-spinner"></span> Applying...';

        // Build items array
        var items = [];
        for (var tid in _selectedTIDs) {
            if (_selectedTIDs.hasOwnProperty(tid)) {
                items.push({ tid: parseInt(tid), amount: _selectedTIDs[tid] });
            }
        }

        // Get acadyear from first selected bill that has one (ledger-only entries may not have acadyear)
        var acadyear = '', semester = 1;
        for (var b = 0; b < _bills.length; b++) {
            if (_selectedTIDs[String(_bills[b].tid)] && _bills[b].acadyear) {
                acadyear = _bills[b].acadyear;
                semester = _bills[b].semester || 1;
                break;
            }
        }

        var payload = JSON.stringify({
            regno: _student.regno,
            category: _category,
            reason: _reason,
            acadyear: acadyear,
            semester: semester,
            items: items
        });

        var xhr = new XMLHttpRequest();
        xhr.open('POST', _pageUrl + '?ajax=apply', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onload = function () {
            try {
                var resp = JSON.parse(xhr.responseText);
                if (resp.ok) {
                    showSuccess(resp);
                } else {
                    btn.disabled = false;
                    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Confirm &amp; Apply Waiver';
                    alert('Error: ' + (resp.error || 'Unknown error'));
                }
            } catch (e) {
                btn.disabled = false;
                btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Confirm &amp; Apply Waiver';
                alert('Failed to parse server response.');
            }
        };
        xhr.onerror = function () {
            btn.disabled = false;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Confirm &amp; Apply Waiver';
            alert('Network error. Please try again.');
        };
        xhr.send(payload);
    };

    function showSuccess(resp) {
        _step = 5;
        updateStepUI();

        var html = '<div class="bw-success__icon">';
        html += '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>';
        html += '</div>';
        html += '<div class="bw-success__title">Waiver Applied Successfully</div>';
        html += '<div class="bw-success__msg">' + esc(resp.message || '') + '</div>';
        html += '<div class="bw-success__detail">';
        html += '<div><strong>Waiver ID:</strong> #' + resp.waiver_id + '</div>';
        html += '<div><strong>Credit TID:</strong> ' + resp.credit_tid + '</div>';
        html += '<div><strong>GL Entry TID:</strong> ' + resp.gl_tid + '</div>';
        html += '<div><strong>Amount:</strong> UGX ' + formatNum(resp.total) + '</div>';
        html += '</div>';

        document.getElementById('bwSuccess').innerHTML = html;
    }

    // ── Utilities ─────────────────────────────────────────────────────
    function esc(s) {
        if (!s) return '';
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(s));
        return d.innerHTML.replace(/"/g, '&quot;');
    }

    function formatNum(n) {
        if (n == null) return '0';
        return Number(n).toLocaleString('en-US', { maximumFractionDigits: 0 });
    }

    // ── View Waiver Detail ──────────────────────────────────────────────────────
    window.viewWaiver = function (id) {
        var overlay = document.getElementById('bwDetailOverlay');
        var body = document.getElementById('bwDetailBody');
        body.innerHTML = '<div style="padding:30px;text-align:center;"><span class="bw-spinner"></span> Loading...</div>';
        overlay.className = 'bw-detail-overlay bw-detail-overlay--visible';

        var xhr = new XMLHttpRequest();
        xhr.open('GET', _pageUrl + '?ajax=detail&id=' + id, true);
        xhr.onload = function () {
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) { body.innerHTML = '<div style="padding:18px;color:#c62828;">' + esc(d.error) + '</div>'; return; }
                renderDetail(d);
            } catch (e) {
                body.innerHTML = '<div style="padding:18px;color:#c62828;">Failed to load waiver details.</div>';
            }
        };
        xhr.onerror = function () {
            body.innerHTML = '<div style="padding:18px;color:#c62828;">Network error.</div>';
        };
        xhr.send();
    };

    window.closeDetail = function () {
        document.getElementById('bwDetailOverlay').className = 'bw-detail-overlay';
    };

    function renderDetail(d) {
        var statusBadge = d.status === 'Active'
            ? '<span class="fs-badge--green">' + esc(d.status) + '</span>'
            : '<span class="fs-badge--red">' + esc(d.status) + '</span>';

        var html = '<div class="bw-detail__section">';
        html += '<div class="bw-detail__grid">';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Waiver ID</div><div class="bw-detail__value"><span class="fs-code">#' + d.waiver_id + '</span> ' + statusBadge + '</div></div>';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Total Amount</div><div class="bw-detail__value bw-detail__value--lg">UGX ' + formatNum(d.total_amount) + '</div></div>';
        html += '</div></div>';

        html += '<div class="bw-detail__section"><div class="bw-detail__grid">';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Student</div><div class="bw-detail__value">' + esc(d.student_name) + '</div></div>';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Registration No</div><div class="bw-detail__value"><span class="fs-code">' + esc(d.regno) + '</span></div></div>';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Programme</div><div class="bw-detail__value">' + esc(d.programme) + '</div></div>';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Academic Year</div><div class="bw-detail__value">' + esc(d.acadyear) + ' / Sem ' + d.semester + '</div></div>';
        html += '</div></div>';

        html += '<div class="bw-detail__section"><div class="bw-detail__grid">';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Category</div><div class="bw-detail__value">' + esc(d.waiver_category) + '</div></div>';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Transaction TID</div><div class="bw-detail__value"><a href="FeesTransactions.aspx?tid=' + d.credit_tid + '" class="bw-link">' + d.credit_tid + '</a></div></div>';
        if (d.waiver_category === 'Balance Fix') {
            html += '<div class="bw-detail__field"><div class="bw-detail__label">Previous Balance</div><div class="bw-detail__value">UGX ' + formatNum(d.fix_previous_balance || 0) + '</div></div>';
            html += '<div class="bw-detail__field"><div class="bw-detail__label">Target Balance</div><div class="bw-detail__value">UGX ' + formatNum(d.fix_target_balance || 0) + '</div></div>';
            html += '<div class="bw-detail__field"><div class="bw-detail__label">Adjustment Type</div><div class="bw-detail__value">' + (d.fix_transaction_type === 'CR' ? 'Credit (Payment)' : 'Debit (Bill)') + '</div></div>';
        }
        html += '<div class="bw-detail__field" style="grid-column:1/-1;"><div class="bw-detail__label">Reason</div><div class="bw-detail__value" style="font-weight:400;white-space:pre-wrap;">' + esc(d.waiver_reason) + '</div></div>';
        html += '</div></div>';

        html += '<div class="bw-detail__section"><div class="bw-detail__grid">';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Created By</div><div class="bw-detail__value">' + esc(d.created_by) + '</div></div>';
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Created At</div><div class="bw-detail__value">' + esc(d.created_at) + '</div></div>';
        if (d.reversed_by) {
            html += '<div class="bw-detail__field"><div class="bw-detail__label">Reversed By</div><div class="bw-detail__value" style="color:#c62828;">' + esc(d.reversed_by) + '</div></div>';
            html += '<div class="bw-detail__field"><div class="bw-detail__label">Reversed At</div><div class="bw-detail__value" style="color:#c62828;">' + esc(d.reversed_at) + '</div></div>';
        }
        html += '</div></div>';

        if (d.items && d.items.length > 0) {
            html += '<div class="bw-detail__section">';
            html += '<div class="bw-label" style="margin-bottom:6px;">Waived Bills (' + d.items.length + ')</div>';
            html += '<table class="bw-bills-table"><thead><tr><th>TID</th><th>Detail</th><th class="bw-table--right">Bill Amount</th><th class="bw-table--right">Waived Amount</th></tr></thead><tbody>';
            for (var i = 0; i < d.items.length; i++) {
                var it = d.items[i];
                html += '<tr><td><span class="fs-code">' + it.original_tid + '</span></td>';
                html += '<td>' + esc(it.bill_detail) + '</td>';
                html += '<td class="bw-table--right">UGX ' + formatNum(it.bill_amount) + '</td>';
                html += '<td class="bw-table--right"><strong>UGX ' + formatNum(it.waived_amount) + '</strong></td></tr>';
            }
            html += '</tbody></table></div>';
        }

        document.getElementById('bwDetailBody').innerHTML = html;
    }

    // ── Reverse Waiver ────────────────────────────────────────────────────────
    var _reverseWaiverId = 0;

    window.openReverse = function (id) {
        _reverseWaiverId = id;
        document.getElementById('bwReverseReason').value = '';
        document.getElementById('bwRevReasonCount').textContent = '0';
        document.getElementById('bwReverseError').style.display = 'none';
        var btn = document.getElementById('btnConfirmReverse');
        btn.disabled = false;
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg> Confirm Reversal';

        var summDiv = document.getElementById('bwReverseSummary');
        var warnText = document.getElementById('bwReverseWarnText');
        summDiv.innerHTML = '<span class="bw-spinner"></span> Loading waiver details...';
        warnText.innerHTML = 'This will <strong>reverse the waiver</strong> and re-bill the student. A debit entry will be created for the full waiver amount. This action is logged and auditable.';
        var overlay = document.getElementById('bwReverseOverlay');
        overlay.className = 'bw-reverse-overlay bw-reverse-overlay--visible';

        var xhr = new XMLHttpRequest();
        xhr.open('GET', _pageUrl + '?ajax=detail&id=' + id, true);
        xhr.onload = function () {
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) { summDiv.innerHTML = '<span style="color:#c62828;">' + esc(d.error) + '</span>'; return; }
                summDiv.innerHTML = '<strong>Waiver #' + d.waiver_id + '</strong> \u2014 ' + esc(d.student_name) + ' (' + esc(d.regno) + ')<br>' +
                    'Category: <strong>' + esc(d.waiver_category) + '</strong> &middot; Amount: <strong>UGX ' + formatNum(d.total_amount) + '</strong><br>' +
                    '<span style="font-size:11px;color:#555;">' + esc(d.waiver_reason) + '</span>';
                if (d.waiver_category === 'Balance Fix') {
                    warnText.innerHTML = 'This will <strong>reverse the balance fix</strong> by deleting the linked Fees Transaction and GL entry, then marking the fix as reversed. No new debit entry will be created.';
                }
            } catch (e) {
                summDiv.innerHTML = '<span style="color:#c62828;">Failed to load details.</span>';
            }
        };
        xhr.send();
    };

    window.closeReverse = function () {
        document.getElementById('bwReverseOverlay').className = 'bw-reverse-overlay';
        _reverseWaiverId = 0;
    };

    document.getElementById('bwReverseReason').addEventListener('input', function () {
        document.getElementById('bwRevReasonCount').textContent = this.value.length;
    });

    window.submitReversal = function () {
        var reason = document.getElementById('bwReverseReason').value.trim();
        var errEl = document.getElementById('bwReverseError');
        if (!reason || reason.length < 5) {
            errEl.textContent = 'Please provide a reason for reversal (at least 5 characters).';
            errEl.style.display = 'block';
            document.getElementById('bwReverseReason').classList.add('bw-field--error');
            return;
        }
        errEl.style.display = 'none';
        document.getElementById('bwReverseReason').classList.remove('bw-field--error');

        var btn = document.getElementById('btnConfirmReverse');
        btn.disabled = true;
        btn.innerHTML = '<span class="bw-spinner"></span> Reversing...';

        var payload = JSON.stringify({ waiver_id: _reverseWaiverId, reason: reason });
        var xhr = new XMLHttpRequest();
        xhr.open('POST', _pageUrl + '?ajax=reverse', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onload = function () {
            try {
                var resp = JSON.parse(xhr.responseText);
                if (resp.ok) {
                    closeReverse();
                    alert(resp.message || 'Waiver reversed successfully.');
                    window.location.reload();
                } else {
                    btn.disabled = false;
                    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg> Confirm Reversal';
                    errEl.textContent = resp.error || 'Unknown error';
                    errEl.style.display = 'block';
                }
            } catch (e) {
                btn.disabled = false;
                btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg> Confirm Reversal';
                errEl.textContent = 'Failed to parse server response.';
                errEl.style.display = 'block';
            }
        };
        xhr.onerror = function () {
            btn.disabled = false;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg> Confirm Reversal';
            errEl.textContent = 'Network error. Please try again.';
            errEl.style.display = 'block';
        };
        xhr.send(payload);
    };

    // ── Pagination Navigation ─────────────────────────────────────────
    window.bwGoPage = function (n) {
        var hid = document.getElementById('<%= hidPage.ClientID %>');
        var nav = document.getElementById('<%= btnPageNav.ClientID %>');
        if (hid && nav) { hid.value = n; nav.click(); }
    };

})();
</script>
</asp:Content>
