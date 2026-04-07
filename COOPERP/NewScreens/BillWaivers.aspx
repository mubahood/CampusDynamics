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
.bw-modal { background: #fff; width: 720px; max-width: 96vw; max-height: 92vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
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
.bw-bills-table th { background: #f5f7fa; padding: 8px 10px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; }
.bw-bills-table td { padding: 7px 10px; border-bottom: 1px solid #f0f2f5; vertical-align: middle; }
.bw-bills-table tr:hover { background: #f0f4ff; }
.bw-bills-table tr.bw-bill--selected { background: #e8f0fc; }
.bw-bills-table tr.bw-bill--waived { background: #f5f5f5; opacity: .6; }
.bw-bill-check { width: 16px; height: 16px; cursor: pointer; accent-color: #05275C; }
.bw-bills-total { text-align: right; padding: 10px; font-weight: 700; font-size: 12px; color: #05275C; border-top: 2px solid #e0e5ed; background: #f5f7fa; }

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

/* Reverse Confirmation Modal */
.bw-reverse-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9999; }
.bw-reverse-overlay--visible { display: flex; align-items: center; justify-content: center; }
.bw-reverse-modal { background: #fff; width: 520px; max-width: 96vw; max-height: 90vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.bw-reverse__summary { background: #fde8e8; border: 1px solid #f5c6cb; padding: 12px 14px; font-size: 12px; margin-bottom: 14px; }
.bw-reverse__summary strong { color: #c62828; }
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
    <button type="button" class="bw-btn bw-btn--primary" onclick="openWizard()">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        New Waiver
    </button>
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
    </div>
    <div style="overflow-x:auto;">
        <asp:Literal ID="litHistory" runat="server" />
    </div>
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
            <div id="bwBillsContent" style="display:none;"></div>
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
            <textarea id="bwReason" class="bw-reason-area" placeholder="Provide a detailed explanation for this waiver..." maxlength="500"></textarea>
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
                <span>This will <strong>reverse the waiver</strong> and re-bill the student. A debit entry will be created for the full waiver amount. This action is logged and auditable.</span>
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
        document.getElementById('bwReasonCount').textContent = '0';
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
            var count = 0;
            for (var t in _selectedTIDs) { if (_selectedTIDs.hasOwnProperty(t)) count++; }
            if (count === 0) { showError(2, 'Please select at least one bill to waive.'); return false; }
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

    // ── Load Bills ────────────────────────────────────────────────────
    function loadBills() {
        if (!_student) return;
        var loading = document.getElementById('bwBillsLoading');
        var content = document.getElementById('bwBillsContent');
        loading.style.display = '';
        content.style.display = 'none';
        _selectedTIDs = {};

        var xhr = new XMLHttpRequest();
        xhr.open('GET', _pageUrl + '?ajax=bills&regno=' + encodeURIComponent(_student.regno), true);
        xhr.onload = function () {
            loading.style.display = 'none';
            content.style.display = '';
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.error) { content.innerHTML = '<div class="bw-empty" style="color:#c62828;">' + esc(data.error) + '</div>'; return; }
                _bills = data.bills || [];
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
            content.innerHTML = '<div class="bw-empty">No posted bills found for this student. Only DR (Bill) transactions with status "Posted" can be waived.</div>';
            return;
        }

        var html = '<table class="bw-bills-table"><thead><tr><th style="width:30px;"><input type="checkbox" id="bwCheckAll" onclick="toggleAllBills(this)" class="bw-bill-check" /></th><th>TID</th><th>Date</th><th>Item</th><th>Detail</th><th>Year</th><th>Sem</th><th class="bw-table--right">Amount</th><th>Status</th></tr></thead><tbody>';

        for (var i = 0; i < _bills.length; i++) {
            var b = _bills[i];
            var waived = b.already_waived;
            var rowClass = waived ? ' class="bw-bill--waived"' : '';
            html += '<tr' + rowClass + ' data-tid="' + b.tid + '">';
            if (waived) {
                html += '<td><input type="checkbox" disabled class="bw-bill-check" title="Already waived" /></td>';
            } else {
                html += '<td><input type="checkbox" class="bw-bill-check" data-tid="' + b.tid + '" data-amt="' + b.amount + '" onchange="toggleBill(this)" /></td>';
            }
            html += '<td><span class="fs-code">' + b.tid + '</span></td>';
            html += '<td>' + esc(b.date) + '</td>';
            html += '<td><strong>' + esc(b.item_name) + '</strong></td>';
            html += '<td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="' + esc(b.detail) + '">' + esc(b.detail) + '</td>';
            html += '<td>' + esc(b.acadyear) + '</td>';
            html += '<td style="text-align:center;">' + b.semester + '</td>';
            html += '<td class="bw-table--right"><strong>UGX ' + formatNum(b.amount) + '</strong></td>';
            html += '<td>' + (waived ? '<span class="fs-badge--amber">Waived</span>' : '<span class="fs-badge--green">Active</span>') + '</td>';
            html += '</tr>';
        }

        html += '</tbody></table>';
        html += '<div class="bw-bills-total" id="bwBillsTotal">Selected: <span id="bwSelCount">0</span> bills &mdash; Total: <strong>UGX <span id="bwSelTotal">0</span></strong></div>';
        content.innerHTML = html;
    }

    window.toggleBill = function (el) {
        var tid = el.getAttribute('data-tid');
        var amt = parseFloat(el.getAttribute('data-amt'));
        var row = el.closest('tr');
        if (el.checked) {
            _selectedTIDs[tid] = amt;
            if (row) row.classList.add('bw-bill--selected');
        } else {
            delete _selectedTIDs[tid];
            if (row) row.classList.remove('bw-bill--selected');
        }
        updateSelectionTotal();
        hideError(2);
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

    // ── Category Radio Card Highlighting ──────────────────────────────
    document.getElementById('bwCats').addEventListener('change', function (e) {
        if (e.target.name !== 'bwCat') return;
        var labels = document.querySelectorAll('.bw-cat');
        for (var i = 0; i < labels.length; i++) labels[i].className = 'bw-cat';
        var parent = e.target.closest('.bw-cat');
        if (parent) parent.className = 'bw-cat bw-cat--selected';
        hideError(3);
    });

    // Reason char counter
    document.getElementById('bwReason').addEventListener('input', function () {
        document.getElementById('bwReasonCount').textContent = this.value.length;
        if (this.value.trim().length >= 5) this.classList.remove('bw-field--error');
    });

    // ── Build Summary (Step 4) ────────────────────────────────────────
    function buildSummary() {
        var html = '';

        // Student
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Student</span><span class="bw-summary__val">' + esc(_student.name) + ' (' + esc(_student.regno) + ')</span></div>';
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Programme</span><span class="bw-summary__val">' + esc(_student.programme) + '</span></div>';
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Category</span><span class="bw-summary__val">' + esc(_category) + '</span></div>';
        html += '<div class="bw-summary__row"><span class="bw-summary__label">Reason</span><span class="bw-summary__val">' + esc(_reason) + '</span></div>';

        // Items
        html += '<div class="bw-label" style="margin-top:12px;">Bills to be waived:</div>';
        html += '<div class="bw-summary__items">';
        var total = 0;
        var items = [];
        for (var tid in _selectedTIDs) {
            if (!_selectedTIDs.hasOwnProperty(tid)) continue;
            var amt = _selectedTIDs[tid];
            total += amt;
            // Find bill detail
            var detail = 'TID ' + tid;
            for (var b = 0; b < _bills.length; b++) {
                if (String(_bills[b].tid) === String(tid)) {
                    detail = _bills[b].item_name + ' — ' + _bills[b].date;
                    items.push({ tid: parseInt(tid), amount: amt });
                    break;
                }
            }
            html += '<div class="bw-summary__item"><span>TID ' + tid + ' — ' + esc(detail) + '</span><span>UGX ' + formatNum(amt) + '</span></div>';
        }
        html += '</div>';

        // Total
        html += '<div class="bw-summary__total bw-summary__row"><span class="bw-summary__label">Total Credit to Student</span><span class="bw-summary__val">UGX ' + formatNum(total) + '</span></div>';

        // Warning
        html += '<div class="bw-summary__warning">';
        html += '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        html += '<span>This will create a <strong>credit of UGX ' + formatNum(total) + '</strong> on the student\'s fee account. This action will be logged and is auditable. Please verify all details before confirming.</span>';
        html += '</div>';

        document.getElementById('bwSummary').innerHTML = html;
    }

    // ── Apply Waiver ──────────────────────────────────────────────────
    window.applyWaiver = function () {
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

        // Get acadyear and semester from first selected bill
        var acadyear = '', semester = 1;
        for (var b = 0; b < _bills.length; b++) {
            if (_selectedTIDs[String(_bills[b].tid)]) {
                acadyear = _bills[b].acadyear;
                semester = _bills[b].semester;
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
        html += '<div class="bw-detail__field"><div class="bw-detail__label">Credit TID</div><div class="bw-detail__value"><a href="FeesTransactions.aspx?tid=' + d.credit_tid + '" class="bw-link">' + d.credit_tid + '</a></div></div>';
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
        summDiv.innerHTML = '<span class="bw-spinner"></span> Loading waiver details...';
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

})();
</script>
</asp:Content>
