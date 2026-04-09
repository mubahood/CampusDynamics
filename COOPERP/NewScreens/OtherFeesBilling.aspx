<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="OtherFeesBilling.aspx.cs"
    Inherits="COOPERP_NewScreens_OtherFeesBilling"
    Title="Other Fees Billing - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>
/* ── Page layout ── */
.ofb-page { padding: 18px 24px; max-width: 1200px; }
.ofb-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; flex-wrap: wrap; gap: 10px; }
.ofb-header__title { font-size: 18px; font-weight: 800; color: #05275C; letter-spacing: -.3px; }
.ofb-header__sub { font-size: 11px; color: #888; margin-top: 2px; }
.ofb-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; font-size: 12px; font-weight: 700; border: none; cursor: pointer; transition: all .15s; }
.ofb-btn--primary { background: #174DA4; color: #fff; }
.ofb-btn--primary:hover { background: #0d3b82; }
.ofb-btn--ghost { background: transparent; color: #555; border: 1px solid #ddd; }
.ofb-btn--ghost:hover { background: #f5f5f5; }
.ofb-btn--sm { padding: 5px 10px; font-size: 11px; }
.ofb-btn--danger { background: #c62828; color: #fff; }
.ofb-btn--danger:hover { background: #a31f1f; }
.ofb-btn--success { background: #2e7d32; color: #fff; }
.ofb-btn--success:hover { background: #1b5e20; }

/* ── Jobs history table ── */
.ofb-jobs { margin-top: 6px; }
.ofb-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.ofb-table th { background: #f5f7fa; color: #05275C; font-weight: 700; padding: 8px 10px; text-align: left; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.ofb-table td { padding: 7px 10px; border-bottom: 1px solid #f0f0f0; color: #333; }
.ofb-table tr:hover td { background: #f8faff; }
.ofb-badge { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; letter-spacing: .3px; text-transform: uppercase; }
.ofb-badge--completed { background: #e6f4ea; color: #2e7d32; }
.ofb-badge--partial { background: #fff3e0; color: #e65100; }
.ofb-badge--failed { background: #fde8e8; color: #c62828; }
.ofb-badge--processing { background: #e8f0fc; color: #174DA4; }
.ofb-empty { text-align: center; padding: 40px; color: #aaa; font-size: 12px; }

/* ── Modal ── */
.ofb-modal-overlay { display: none; position: fixed; inset: 0; background: rgba(5,39,92,.45); z-index: 9000; align-items: flex-start; justify-content: center; padding-top: 40px; overflow-y: auto; }
.ofb-modal-overlay.active { display: flex; }
.ofb-modal { background: #fff; width: 720px; max-width: 96vw; box-shadow: 0 12px 40px rgba(0,0,0,.25); max-height: 90vh; display: flex; flex-direction: column; }
.ofb-modal__header { padding: 14px 18px; background: #05275C; color: #fff; display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.ofb-modal__title { font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.ofb-modal__close { background: none; border: none; color: rgba(255,255,255,.7); font-size: 20px; cursor: pointer; line-height: 1; }
.ofb-modal__close:hover { color: #fff; }
.ofb-modal__body { flex: 1; overflow-y: auto; padding: 18px; }

/* ── Wizard steps ── */
.wz-steps { display: flex; gap: 2px; padding: 0 18px 14px; border-bottom: 1px solid #eee; background: #fafbfc; }
.wz-step { flex: 1; text-align: center; padding: 10px 6px 8px; font-size: 10px; font-weight: 700; color: #aaa; position: relative; cursor: default; letter-spacing: .3px; }
.wz-step__num { display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 50%; background: #e0e5ed; color: #888; font-size: 11px; font-weight: 800; margin-right: 4px; }
.wz-step--active { color: #174DA4; }
.wz-step--active .wz-step__num { background: #174DA4; color: #fff; }
.wz-step--done { color: #2e7d32; }
.wz-step--done .wz-step__num { background: #2e7d32; color: #fff; }
.wz-panel { display: none; }
.wz-panel--active { display: block; }

/* ── Form elements ── */
.ofb-form-row { display: flex; gap: 12px; margin-bottom: 10px; flex-wrap: wrap; }
.ofb-form-group { flex: 1; min-width: 180px; }
.ofb-form-label { display: block; font-size: 11px; font-weight: 700; color: #05275C; margin-bottom: 3px; }
.ofb-form-input { width: 100%; padding: 7px 10px; font-size: 12px; border: 1px solid #d0d5dd; background: #fff; color: #333; box-sizing: border-box; outline: none; transition: border .15s; }
.ofb-form-input:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }
.ofb-form-textarea { width: 100%; padding: 7px 10px; font-size: 12px; border: 1px solid #d0d5dd; min-height: 60px; resize: vertical; box-sizing: border-box; font-family: inherit; }
.req { color: #c62828; }

/* ── Tabs ── */
.ofb-tabs { display: flex; gap: 0; border-bottom: 2px solid #e0e5ed; margin-bottom: 12px; }
.ofb-tab { padding: 8px 16px; font-size: 11px; font-weight: 700; color: #888; cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all .15s; }
.ofb-tab:hover { color: #05275C; }
.ofb-tab--active { color: #174DA4; border-bottom-color: #174DA4; }
.ofb-tab-content { display: none; }
.ofb-tab-content--active { display: block; }

/* ── Autocomplete ── */
.ofb-ac { position: relative; }
.ofb-ac__list { position: absolute; top: 100%; left: 0; right: 0; max-height: 200px; overflow-y: auto; background: #fff; border: 1px solid #d0d5dd; box-shadow: 0 6px 20px rgba(0,0,0,.12); z-index: 100; display: none; }
.ofb-ac__list--visible { display: block; }
.ofb-ac__item { padding: 8px 12px; cursor: pointer; font-size: 11px; }
.ofb-ac__item:hover { background: #f0f4ff; }
.ofb-ac__name { font-weight: 700; color: #05275C; }
.ofb-ac__sub { font-size: 10px; color: #888; }

/* ── Pick list (shared between Programme & Condition) ── */
.ofb-pick { margin-top: 10px; border: 1px solid #e0e5ed; max-height: 250px; overflow-y: auto; }
.ofb-pick__row { display: flex; align-items: center; padding: 6px 10px; border-bottom: 1px solid #f0f0f0; font-size: 11px; gap: 8px; cursor: pointer; }
.ofb-pick__row:hover { background: #f8faff; }
.ofb-pick__row input[type=checkbox]:checked ~ span { font-weight: 600; color: #05275C; }
.ofb-pick__row input[type=checkbox] { flex-shrink: 0; }
.ofb-pick__header { display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f7fa; border-bottom: 1px solid #e0e5ed; }

/* ── Selected students panel ── */
.ofb-sel { margin-top: 14px; border: 1px solid #d0daf0; background: #f8faff; }
.ofb-sel__header { display: flex; align-items: center; justify-content: space-between; padding: 8px 12px; background: #eef2ff; border-bottom: 1px solid #d0daf0; }
.ofb-sel__title { font-size: 12px; font-weight: 700; color: #05275C; }
.ofb-sel__count { display: inline-flex; align-items: center; justify-content: center; min-width: 20px; height: 20px; background: #174DA4; color: #fff; font-size: 10px; font-weight: 800; padding: 0 6px; margin-left: 6px; }
.ofb-sel__list { max-height: 180px; overflow-y: auto; padding: 4px; }
.ofb-sel__chip { display: inline-flex; align-items: center; gap: 4px; padding: 3px 8px; margin: 2px; background: #fff; border: 1px solid #d0d5dd; font-size: 10px; color: #333; }
.ofb-sel__chip-x { cursor: pointer; color: #c62828; font-weight: 700; margin-left: 4px; }
.ofb-sel__chip-x:hover { color: #a00; }

/* ── Review table ── */
.ofb-review-table { width: 100%; border-collapse: collapse; font-size: 12px; }
.ofb-review-table tr { border-bottom: 1px solid #f0f0f0; }
.ofb-review-table td { padding: 8px 0; }
.ofb-review-table td:first-child { color: #888; width: 40%; }
.ofb-review-table td:last-child { font-weight: 600; color: #222; }

/* ── Results ── */
.ofb-result-card { text-align: center; padding: 20px; }
.ofb-result-card__icon { width: 48px; height: 48px; margin: 0 auto 12px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.ofb-result-card__icon--ok { background: #e6f4ea; }
.ofb-result-card__icon--warn { background: #fff3e0; }
.ofb-result-card__icon--err { background: #fde8e8; }
.ofb-result-stats { display: flex; gap: 12px; justify-content: center; margin: 14px 0; }
.ofb-result-stat { text-align: center; padding: 10px 18px; background: #f5f7fa; border: 1px solid #e0e5ed; min-width: 80px; }
.ofb-result-stat__num { font-size: 20px; font-weight: 800; color: #05275C; }
.ofb-result-stat__label { font-size: 9px; color: #888; text-transform: uppercase; letter-spacing: .3px; margin-top: 2px; }

/* ── Footer ── */
.wz-footer { display: flex; justify-content: space-between; align-items: center; padding: 12px 18px; border-top: 1px solid #eee; background: #fafbfc; flex-shrink: 0; }
.wz-footer__right { display: flex; gap: 8px; }

/* ── Spinner ── */
.ofb-spinner { display: inline-block; width: 14px; height: 14px; border: 2px solid #ddd; border-top-color: #174DA4; border-radius: 50%; animation: ofbSpin .6s linear infinite; vertical-align: middle; }
@keyframes ofbSpin { to { transform: rotate(360deg); } }

/* ── Detail modal table ── */
.ofb-detail-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.ofb-detail-table th { background: #f5f7fa; padding: 6px 8px; text-align: left; font-weight: 700; color: #05275C; border-bottom: 1px solid #e0e5ed; }
.ofb-detail-table td { padding: 5px 8px; border-bottom: 1px solid #f0f0f0; }
</style>

<div class="ofb-page">
    <!-- Page Header -->
    <div class="ofb-header">
        <div>
            <div class="ofb-header__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" style="vertical-align:-3px;margin-right:4px;">
                    <rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/>
                </svg>
                Other Fees Billing
            </div>
            <div class="ofb-header__sub">Create batch bills for miscellaneous fees &mdash; library, retake, ID card, exam, etc.</div>
        </div>
        <div>
            <button type="button" class="ofb-btn ofb-btn--primary" onclick="openBillingWizard()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                New Batch Bill
            </button>
        </div>
    </div>

    <!-- Jobs History -->
    <div class="ofb-jobs" id="ofbJobsContainer">
        <div class="ofb-empty"><span class="ofb-spinner"></span> Loading billing history&hellip;</div>
    </div>
</div>

<!-- ============================================================ -->
<!-- BILLING WIZARD MODAL                                          -->
<!-- ============================================================ -->
<div id="modal-billing-wizard" class="ofb-modal-overlay" onclick="if(event.target===this)closeBillingWizard()">
    <div class="ofb-modal">
        <div class="ofb-modal__header">
            <div class="ofb-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                New Batch Bill
            </div>
            <button type="button" class="ofb-modal__close" onclick="closeBillingWizard()">&times;</button>
        </div>

        <!-- Step Indicators -->
        <div class="wz-steps" id="wzSteps">
            <div class="wz-step wz-step--active" data-step="1"><span class="wz-step__num">1</span>Bill Item</div>
            <div class="wz-step" data-step="2"><span class="wz-step__num">2</span>Students</div>
            <div class="wz-step" data-step="3"><span class="wz-step__num">3</span>Review</div>
            <div class="wz-step" data-step="4"><span class="wz-step__num">4</span>Results</div>
        </div>

        <div class="ofb-modal__body">

        <!-- ═══════════════════════ STEP 1: Bill Item Specification ═══════════════════════ -->
        <div class="wz-panel wz-panel--active" id="wzPanel1">
            <div style="margin-bottom:14px;">
                <div style="font-size:13px;font-weight:700;color:#05275C;margin-bottom:3px;">Bill Item Specification</div>
                <div style="font-size:11px;color:#888;">Select the fee item, amount, and academic period for this batch bill.</div>
            </div>
            <div class="ofb-form-row">
                <div class="ofb-form-group" style="flex:2;">
                    <label class="ofb-form-label">Billing Item <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlBillItem" runat="server" CssClass="ofb-form-input" />
                </div>
                <div class="ofb-form-group">
                    <label class="ofb-form-label">Amount (UGX) <span class="req">*</span></label>
                    <input type="number" id="txtBillAmount" class="ofb-form-input" min="0" step="1" placeholder="e.g. 50000" />
                </div>
            </div>
            <div class="ofb-form-row">
                <div class="ofb-form-group">
                    <label class="ofb-form-label">Academic Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlBillAcadYear" runat="server" CssClass="ofb-form-input" />
                </div>
                <div class="ofb-form-group">
                    <label class="ofb-form-label">Semester <span class="req">*</span></label>
                    <select id="ddlBillSemester" class="ofb-form-input">
                        <option value="1">Semester 1</option>
                        <option value="2">Semester 2</option>
                        <option value="3">Semester 3</option>
                    </select>
                </div>
            </div>
            <div class="ofb-form-row">
                <div class="ofb-form-group" style="flex:1;">
                    <label class="ofb-form-label">Description / Notes</label>
                    <textarea id="txtBillDetail" class="ofb-form-textarea" placeholder="Optional — defaults to the billing item name"></textarea>
                </div>
            </div>
        </div>

        <!-- ═══════════════════════ STEP 2: Student Selection ═══════════════════════ -->
        <div class="wz-panel" id="wzPanel2">
            <div style="margin-bottom:10px;">
                <div style="font-size:13px;font-weight:700;color:#05275C;margin-bottom:3px;">Select Students</div>
                <div style="font-size:11px;color:#888;">Add students using any method below. Students accumulate in the billing list.</div>
            </div>

            <!-- Tabs -->
            <div class="ofb-tabs">
                <div class="ofb-tab ofb-tab--active" onclick="switchTab(this,'tabIndividual')">Individual</div>
                <div class="ofb-tab" onclick="switchTab(this,'tabProgramme')">By Programme</div>
                <div class="ofb-tab" onclick="switchTab(this,'tabCondition')">By Condition</div>
            </div>

            <!-- Tab A: Individual -->
            <div id="tabIndividual" class="ofb-tab-content ofb-tab-content--active">
                <div class="ofb-form-group">
                    <label class="ofb-form-label">Search Student</label>
                    <div class="ofb-ac">
                        <input type="text" id="txtSearchStudent" class="ofb-form-input" placeholder="Type reg number or name..." autocomplete="off" />
                        <div id="acList" class="ofb-ac__list"></div>
                    </div>
                </div>
            </div>

            <!-- Tab B: By Programme -->
            <div id="tabProgramme" class="ofb-tab-content">
                <div class="ofb-form-row">
                    <div class="ofb-form-group" style="flex:2;">
                        <label class="ofb-form-label">Programme</label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="ofb-form-input" />
                    </div>
                    <div class="ofb-form-group">
                        <label class="ofb-form-label">Year of Study</label>
                        <select id="ddlStudyYear" class="ofb-form-input">
                            <option value="0">All Years</option>
                            <option value="1">Year 1</option>
                            <option value="2">Year 2</option>
                            <option value="3">Year 3</option>
                        </select>
                    </div>
                    <div class="ofb-form-group">
                        <label class="ofb-form-label">Session</label>
                        <select id="ddlSession" class="ofb-form-input">
                            <option value="">All Sessions</option>
                            <option value="DAY">Day</option>
                            <option value="EVENING">Evening</option>
                            <option value="WEEKEND">Weekend</option>
                        </select>
                    </div>
                </div>
                <button type="button" class="ofb-btn ofb-btn--primary ofb-btn--sm" onclick="loadByProgramme()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    Load Students
                </button>
                <div id="pickProgramme"></div>
            </div>

            <!-- Tab C: By Condition -->
            <div id="tabCondition" class="ofb-tab-content">
                <div class="ofb-form-row">
                    <div class="ofb-form-group" style="flex:2;">
                        <label class="ofb-form-label">Condition Type</label>
                        <select id="ddlCondition" class="ofb-form-input" onchange="onConditionChange()">
                            <option value="">-- Select Condition --</option>
                            <option value="balance">Outstanding Balance Above...</option>
                            <option value="nopayment">No Payments Between...</option>
                            <option value="retakes">Failed Courses (F Grade) in...</option>
                        </select>
                    </div>
                </div>
                <!-- Dynamic fields -->
                <div id="condFields" style="display:none;"></div>
                <div id="pickCondition"></div>
            </div>

            <!-- ── Selected Students Panel (always visible) ── -->
            <div class="ofb-sel" id="ofbSelPanel" style="display:none;">
                <div class="ofb-sel__header">
                    <div>
                        <span class="ofb-sel__title">Selected for Billing</span>
                        <span class="ofb-sel__count" id="ofbSelCount">0</span>
                    </div>
                    <button type="button" class="ofb-btn ofb-btn--ghost ofb-btn--sm" onclick="clearAllStudents()" style="font-size:10px;">Clear All</button>
                </div>
                <div class="ofb-sel__list" id="ofbSelList"></div>
            </div>
        </div>

        <!-- ═══════════════════════ STEP 3: Review & Confirm ═══════════════════════ -->
        <div class="wz-panel" id="wzPanel3">
            <div style="margin-bottom:14px;">
                <div style="font-size:13px;font-weight:700;color:#05275C;margin-bottom:3px;">Review &amp; Confirm</div>
                <div style="font-size:11px;color:#888;">Please review the billing details before submitting.</div>
            </div>

            <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;padding:12px 14px;background:#f0f4ff;border:1px solid #d0daf0;">
                <div style="width:40px;height:40px;background:#174DA4;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                </div>
                <div>
                    <div style="font-size:14px;font-weight:700;color:#05275C;" id="wzRevItemName">—</div>
                    <div style="font-size:11px;color:#666;" id="wzRevItemSub">—</div>
                </div>
            </div>

            <table class="ofb-review-table">
                <tr><td>Billing Item</td><td id="wzRevItem">—</td></tr>
                <tr><td>Amount per Student</td><td id="wzRevAmount" style="color:#c62828;">—</td></tr>
                <tr><td>Academic Year</td><td id="wzRevYear">—</td></tr>
                <tr><td>Semester</td><td id="wzRevSem">—</td></tr>
                <tr><td>Description</td><td id="wzRevDetail">—</td></tr>
                <tr><td>Students to Bill</td><td id="wzRevCount" style="font-size:14px;">—</td></tr>
                <tr style="border-top:2px solid #e0e5ed;"><td style="font-weight:700;color:#05275C;">Total Billing Amount</td><td id="wzRevTotal" style="font-size:16px;color:#c62828;font-weight:800;">—</td></tr>
            </table>

            <div style="margin-top:14px;padding:10px 12px;background:#fff3e0;border:1px solid #ffcc80;font-size:11px;color:#e65100;">
                <strong>Important:</strong> This action will create bill entries in each student's ledger. Please verify the details are correct before proceeding.
            </div>
        </div>

        <!-- ═══════════════════════ STEP 4: Results ═══════════════════════ -->
        <div class="wz-panel" id="wzPanel4">
            <div id="wzResultLoading" style="text-align:center;padding:40px;">
                <span class="ofb-spinner" style="width:24px;height:24px;border-width:3px;"></span>
                <div style="margin-top:12px;font-size:13px;color:#174DA4;font-weight:700;">Processing batch billing&hellip;</div>
                <div style="font-size:11px;color:#888;margin-top:4px;" id="wzResultMsg">Please wait, do not close this window.</div>
            </div>
            <div id="wzResultDone" style="display:none;"></div>
        </div>

        </div><!-- end modal body -->

        <!-- Footer -->
        <div class="wz-footer" id="wzFooter">
            <div>
                <button type="button" class="ofb-btn ofb-btn--ghost" id="wzBtnPrev" onclick="wzPrev()" style="display:none;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                    Previous
                </button>
            </div>
            <div class="wz-footer__right">
                <button type="button" class="ofb-btn ofb-btn--ghost" onclick="closeBillingWizard()">Cancel</button>
                <button type="button" class="ofb-btn ofb-btn--primary" id="wzBtnNext" onclick="wzNext()">
                    Next
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
                </button>
                <button type="button" class="ofb-btn ofb-btn--success" id="wzBtnSubmit" onclick="wzSubmit()" style="display:none;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    Submit Batch Bill
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ============================================================ -->
<!-- JOB DETAIL MODAL                                              -->
<!-- ============================================================ -->
<div id="modal-job-detail" class="ofb-modal-overlay" onclick="if(event.target===this)closeDetailModal()">
    <div class="ofb-modal" style="width:620px;">
        <div class="ofb-modal__header">
            <div class="ofb-modal__title" id="detailTitle">Job Details</div>
            <button type="button" class="ofb-modal__close" onclick="closeDetailModal()">&times;</button>
        </div>
        <div class="ofb-modal__body" id="detailBody">
            <div style="text-align:center;padding:30px;"><span class="ofb-spinner"></span> Loading&hellip;</div>
        </div>
    </div>
</div>

<!-- ============================================================ -->
<!-- JAVASCRIPT                                                     -->
<!-- ============================================================ -->
<script type="text/javascript">
// ===== UTILITY =====
function esc(s) { var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }
function fmt(n) { return Number(n).toLocaleString(); }

// ===== WIZARD STATE =====
var _wz = {
    step: 1,
    // Step 1
    itemCode: 0, itemName: '', itemAcct: '', amount: 0,
    acadYear: '', semester: 0, detail: '',
    // Step 2
    students: [],       // [{regno, name, progcode}]
    studentMap: {},     // regno -> true (dedup)
    selectionMode: ''   // last mode used
};

// ===== MODAL OPEN/CLOSE =====
function openBillingWizard() {
    wzReset();
    document.getElementById('modal-billing-wizard').classList.add('active');
}
function closeBillingWizard() {
    document.getElementById('modal-billing-wizard').classList.remove('active');
}
function openDetailModal() { document.getElementById('modal-job-detail').classList.add('active'); }
function closeDetailModal() { document.getElementById('modal-job-detail').classList.remove('active'); }

// ===== WIZARD NAVIGATION =====
function wzGoTo(step) {
    _wz.step = step;
    var panels = document.querySelectorAll('.wz-panel');
    var steps  = document.querySelectorAll('.wz-step');
    for (var i = 0; i < panels.length; i++) panels[i].classList.remove('wz-panel--active');
    for (var i = 0; i < steps.length; i++) {
        steps[i].classList.remove('wz-step--active', 'wz-step--done');
        var sn = parseInt(steps[i].getAttribute('data-step'));
        if (sn < step) steps[i].classList.add('wz-step--done');
        if (sn === step) steps[i].classList.add('wz-step--active');
    }
    document.getElementById('wzPanel' + step).classList.add('wz-panel--active');
    // Buttons
    document.getElementById('wzBtnPrev').style.display = step > 1 && step < 4 ? '' : 'none';
    document.getElementById('wzBtnNext').style.display = step < 3 ? '' : 'none';
    document.getElementById('wzBtnSubmit').style.display = step === 3 ? '' : 'none';
    document.getElementById('wzFooter').style.display = step === 4 ? 'none' : '';
    // Step-entry hooks
    if (step === 3) populateReview();
}
function wzNext() { if (wzValidate(_wz.step)) wzGoTo(_wz.step + 1); }
function wzPrev() { wzGoTo(_wz.step - 1); }

function wzReset() {
    _wz.step = 1;
    _wz.itemCode = 0; _wz.itemName = ''; _wz.itemAcct = ''; _wz.amount = 0;
    _wz.acadYear = ''; _wz.semester = 0; _wz.detail = '';
    _wz.students = []; _wz.studentMap = {}; _wz.selectionMode = '';
    // Reset inputs
    document.getElementById('<%= ddlBillItem.ClientID %>').selectedIndex = 0;
    document.getElementById('txtBillAmount').value = '';
    document.getElementById('<%= ddlBillAcadYear.ClientID %>').selectedIndex = 0;
    document.getElementById('ddlBillSemester').selectedIndex = 0;
    document.getElementById('txtBillDetail').value = '';
    document.getElementById('txtSearchStudent').value = '';
    document.getElementById('acList').classList.remove('ofb-ac__list--visible');
    renderSelectedStudents();
    // Reset pick areas
    document.getElementById('pickProgramme').innerHTML = '';
    document.getElementById('pickCondition').innerHTML = '';
    document.getElementById('condFields').style.display = 'none';
    document.getElementById('ddlCondition').selectedIndex = 0;
    // Reset results
    document.getElementById('wzResultLoading').style.display = '';
    document.getElementById('wzResultDone').style.display = 'none';
    wzGoTo(1);
}

// ===== STEP VALIDATION =====
function wzValidate(step) {
    if (step === 1) {
        var ddlItem = document.getElementById('<%= ddlBillItem.ClientID %>');
        var amtInput = document.getElementById('txtBillAmount');
        var ddlYear = document.getElementById('<%= ddlBillAcadYear.ClientID %>');
        var ddlSem = document.getElementById('ddlBillSemester');
        if (!ddlItem.value) { alert('Please select a billing item.'); ddlItem.focus(); return false; }
        var amt = parseFloat(amtInput.value);
        if (!amt || amt <= 0) { alert('Please enter a valid amount.'); amtInput.focus(); return false; }
        if (!ddlYear.value) { alert('Please select an academic year.'); return false; }
        // Save to state
        _wz.itemCode = parseInt(ddlItem.value);
        _wz.itemName = ddlItem.options[ddlItem.selectedIndex].text;
        _wz.amount = amt;
        _wz.acadYear = ddlYear.value;
        _wz.semester = parseInt(ddlSem.value);
        _wz.detail = document.getElementById('txtBillDetail').value.trim();
        // Find account code from _billItems
        for (var i = 0; i < _billItems.length; i++) {
            if (_billItems[i].code === _wz.itemCode) { _wz.itemAcct = _billItems[i].acct; break; }
        }
        return true;
    }
    if (step === 2) {
        // Auto-collect any checked (but not yet added) students from pick lists
        autoCollectChecked();
        if (_wz.students.length === 0) { alert('Please select at least one student.\nUse the checkboxes to select students, then proceed.'); return false; }
        return true;
    }
    return true;
}

// ===== STEP 1: nothing extra (dropdowns are server-rendered) =====

// ===== STEP 2 TAB SWITCHING =====
function switchTab(tab, contentId) {
    var tabs = document.querySelectorAll('.ofb-tab');
    var contents = document.querySelectorAll('.ofb-tab-content');
    for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('ofb-tab--active');
    for (var i = 0; i < contents.length; i++) contents[i].classList.remove('ofb-tab-content--active');
    tab.classList.add('ofb-tab--active');
    document.getElementById(contentId).classList.add('ofb-tab-content--active');
}

// ===== STEP 2A: Individual Search Autocomplete =====
var _acTimer = null;
(function () {
    var inp = document.getElementById('txtSearchStudent');
    var list = document.getElementById('acList');
    if (!inp) return;
    inp.addEventListener('input', function () {
        clearTimeout(_acTimer);
        var v = inp.value.trim();
        if (v.length < 2) { list.classList.remove('ofb-ac__list--visible'); return; }
        _acTimer = setTimeout(function () {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'OtherFeesBilling.aspx?ajax=search&q=' + encodeURIComponent(v), true);
            xhr.onload = function () {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.length === 0) { list.innerHTML = '<div class="ofb-ac__item" style="color:#aaa;">No results found</div>'; list.classList.add('ofb-ac__list--visible'); return; }
                        var html = '';
                        for (var i = 0; i < data.length; i++) {
                            var s = data[i];
                            var alr = _wz.studentMap[s.regno] ? ' style="opacity:.4;"' : '';
                            html += '<div class="ofb-ac__item" data-reg="' + esc(s.regno) + '" data-name="' + esc(s.name) + '" data-prog="' + esc(s.progcode) + '"' + alr + '>'
                                + '<div class="ofb-ac__name">' + esc(s.name) + '</div>'
                                + '<div class="ofb-ac__sub">' + esc(s.regno) + ' &mdash; ' + esc(s.programme) + '</div></div>';
                        }
                        list.innerHTML = html;
                        list.classList.add('ofb-ac__list--visible');
                    } catch (e) {}
                }
            };
            xhr.send();
        }, 250);
    });
    list.addEventListener('click', function (e) {
        var item = e.target.closest('.ofb-ac__item');
        if (!item || !item.getAttribute('data-reg')) return;
        addStudent(item.getAttribute('data-reg'), item.getAttribute('data-name'), item.getAttribute('data-prog'));
        inp.value = '';
        list.classList.remove('ofb-ac__list--visible');
        _wz.selectionMode = 'INDIVIDUAL';
    });
    document.addEventListener('click', function (ev) { if (!inp.contains(ev.target) && !list.contains(ev.target)) list.classList.remove('ofb-ac__list--visible'); });
})();

// ===== STEP 2B: By Programme =====
function loadByProgramme() {
    var prog = document.getElementById('<%= ddlProgramme.ClientID %>').value;
    var yr = document.getElementById('ddlStudyYear').value;
    var sess = document.getElementById('ddlSession').value;
    if (!_wz.acadYear || !_wz.semester) { alert('Please complete Step 1 first (academic year and semester are needed).'); return; }
    var container = document.getElementById('pickProgramme');
    container.innerHTML = '<div style="padding:12px;text-align:center;color:#aaa;"><span class="ofb-spinner"></span> Loading students&hellip;</div>';
    var url = 'OtherFeesBilling.aspx?ajax=loadstudents&mode=programme'
        + '&year=' + encodeURIComponent(_wz.acadYear)
        + '&sem=' + _wz.semester
        + '&prog=' + encodeURIComponent(prog)
        + '&yr=' + yr
        + '&sess=' + encodeURIComponent(sess);
    console.log('[OFB] loadByProgramme URL:', url);
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.onload = function () {
        console.log('[OFB] loadByProgramme response:', xhr.status, xhr.responseText.substring(0, 500));
        renderPickList(container, xhr, 'PROGRAMME');
    };
    xhr.onerror = function () { container.innerHTML = '<div style="padding:12px;color:#c62828;">Network error. Please check your connection.</div>'; };
    xhr.send();
}

// ===== STEP 2C: By Condition =====
function onConditionChange() {
    var type = document.getElementById('ddlCondition').value;
    var cf = document.getElementById('condFields');
    if (!type) { cf.style.display = 'none'; return; }
    cf.style.display = 'block';
    var html = '';
    if (type === 'balance') {
        html = '<div class="ofb-form-row"><div class="ofb-form-group">'
            + '<label class="ofb-form-label">Minimum Outstanding Balance (UGX) <span class="req">*</span></label>'
            + '<input type="number" id="condThreshold" class="ofb-form-input" min="0" step="1" placeholder="e.g. 500000" />'
            + '</div></div>'
            + '<button type="button" class="ofb-btn ofb-btn--primary ofb-btn--sm" onclick="loadByCondition(\'balance\')" style="margin-top:6px;">'
            + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>'
            + ' Find Students</button>';
    } else if (type === 'nopayment') {
        html = '<div class="ofb-form-row">'
            + '<div class="ofb-form-group"><label class="ofb-form-label">From Date <span class="req">*</span></label><input type="date" id="condDateFrom" class="ofb-form-input" /></div>'
            + '<div class="ofb-form-group"><label class="ofb-form-label">To Date <span class="req">*</span></label><input type="date" id="condDateTo" class="ofb-form-input" /></div>'
            + '</div>'
            + '<button type="button" class="ofb-btn ofb-btn--primary ofb-btn--sm" onclick="loadByCondition(\'nopayment\')" style="margin-top:6px;">'
            + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>'
            + ' Find Students</button>';
    } else if (type === 'retakes') {
        // Build year options from the billing academic year dropdown
        var ddlYear = document.getElementById('<%= ddlBillAcadYear.ClientID %>');
        var opts = '';
        for (var i = 0; i < ddlYear.options.length; i++) {
            if (ddlYear.options[i].value) opts += '<option value="' + ddlYear.options[i].value + '">' + ddlYear.options[i].text + '</option>';
        }
        html = '<div class="ofb-form-row">'
            + '<div class="ofb-form-group"><label class="ofb-form-label">Results Year <span class="req">*</span></label><select id="condResYear" class="ofb-form-input">' + opts + '</select></div>'
            + '<div class="ofb-form-group"><label class="ofb-form-label">Results Semester <span class="req">*</span></label><select id="condResSem" class="ofb-form-input"><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select></div>'
            + '</div>'
            + '<button type="button" class="ofb-btn ofb-btn--primary ofb-btn--sm" onclick="loadByCondition(\'retakes\')" style="margin-top:6px;">'
            + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>'
            + ' Find Students</button>';
    }
    cf.innerHTML = html;
}

function loadByCondition(type) {
    if (!_wz.acadYear || !_wz.semester) { alert('Please complete Step 1 first (academic year and semester are needed).'); return; }
    var container = document.getElementById('pickCondition');
    container.innerHTML = '<div style="padding:12px;text-align:center;color:#aaa;"><span class="ofb-spinner"></span> Searching&hellip;</div>';
    var url = 'OtherFeesBilling.aspx?ajax=loadstudents&mode=' + type
        + '&year=' + encodeURIComponent(_wz.acadYear)
        + '&sem=' + _wz.semester;
    if (type === 'balance') {
        var th = document.getElementById('condThreshold');
        if (!th || !th.value || parseFloat(th.value) <= 0) { alert('Please enter a minimum balance.'); container.innerHTML = ''; return; }
        url += '&threshold=' + th.value;
    } else if (type === 'nopayment') {
        var from = document.getElementById('condDateFrom');
        var to = document.getElementById('condDateTo');
        if (!from || !from.value || !to || !to.value) { alert('Please enter both dates.'); container.innerHTML = ''; return; }
        url += '&from=' + from.value + '&to=' + to.value;
    } else if (type === 'retakes') {
        var ry = document.getElementById('condResYear');
        var rs = document.getElementById('condResSem');
        if (!ry || !ry.value) { alert('Please select a results year.'); container.innerHTML = ''; return; }
        url += '&res_year=' + encodeURIComponent(ry.value) + '&res_sem=' + rs.value;
    }
    console.log('[OFB] loadByCondition URL:', url);
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.onload = function () {
        console.log('[OFB] loadByCondition response:', xhr.status, xhr.responseText.substring(0, 500));
        renderPickList(container, xhr, 'CONDITION');
    };
    xhr.onerror = function () { container.innerHTML = '<div style="padding:12px;color:#c62828;">Network error. Please check your connection.</div>'; };
    xhr.send();
}

// ===== Pick List Renderer (shared) =====
function renderPickList(container, xhr, mode) {
    if (xhr.status !== 200) { container.innerHTML = '<div style="padding:12px;color:#c62828;">Request failed (HTTP ' + xhr.status + ').</div>'; return; }
    try {
        var resp = JSON.parse(xhr.responseText);
        // Handle error response (server exception)
        if (resp.error) { container.innerHTML = '<div style="padding:12px;color:#c62828;font-size:11px;"><strong>Server Error:</strong> ' + esc(resp.error) + '</div>'; return; }

        // New format: {"students":[...],"total_reg":N,"params":{...}}
        var data = resp.students || resp; // backward-compat: if plain array, use as-is
        if (!Array.isArray(data)) data = [];
        var totalReg = typeof resp.total_reg !== 'undefined' ? resp.total_reg : -1;
        var params = resp.params || {};

        console.log('[OFB] renderPickList:', { mode: mode, count: data.length, totalReg: totalReg, params: params });

        if (data.length === 0) {
            var msg = '';
            if (totalReg === 0) {
                msg = '<strong>No registered students found</strong> for <em>' + esc(_wz.acadYear) + ' Semester ' + _wz.semester + '</em>.'
                    + '<br/>Please verify that the academic year and semester selected in Step 1 have student registrations with status REGISTERED, CLEARED, or LATE REGISTERED.';
            } else if (totalReg > 0) {
                msg = '<strong>' + totalReg + '</strong> registered student(s) exist for <em>' + esc(_wz.acadYear) + ' Semester ' + _wz.semester + '</em>, '
                    + 'but none match your additional filters. Try selecting <em>All Programmes / All Years / All Sessions</em> to broaden the search.';
            } else {
                msg = 'No students found matching the criteria for <em>' + esc(_wz.acadYear) + ' Semester ' + _wz.semester + '</em>.';
            }
            container.innerHTML = '<div style="padding:14px;color:#888;font-size:11px;line-height:1.6;">'
                + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#aaa" stroke-width="2" style="vertical-align:-2px;margin-right:4px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>'
                + msg + '</div>';
            return;
        }
        var html = '<div class="ofb-pick__header">'
            + '<span style="font-size:11px;font-weight:700;color:#05275C;">' + data.length + ' student' + (data.length !== 1 ? 's' : '') + ' found</span>'
            + '<span>'
            + '<button type="button" class="ofb-btn ofb-btn--ghost ofb-btn--sm" onclick="pickToggleAll(this)" style="margin-right:4px;">Select All</button>'
            + '<button type="button" class="ofb-btn ofb-btn--primary ofb-btn--sm" onclick="pickAddSelected(this,\'' + mode + '\')">Add Selected</button>'
            + '</span></div>';
        html += '<div class="ofb-pick">';
        for (var i = 0; i < data.length; i++) {
            var s = data[i];
            var checked = _wz.studentMap[s.regno] ? ' checked disabled' : '';
            var extra = '';
            if (s.balance !== undefined) extra = ' &mdash; Bal: UGX ' + fmt(s.balance);
            if (s.year !== undefined) extra = ' &mdash; Yr ' + s.year;
            html += '<div class="ofb-pick__row">'
                + '<input type="checkbox" data-reg="' + esc(s.regno) + '" data-name="' + esc(s.name) + '" data-prog="' + esc(s.progcode) + '"' + checked + ' />'
                + '<span style="flex:1;">' + esc(s.name) + ' <span style="color:#888;font-size:10px;">(' + esc(s.regno) + ' &mdash; ' + esc(s.progcode) + extra + ')</span></span>'
                + '</div>';
        }
        html += '</div>';
        container.innerHTML = html;
    } catch (e) {
        console.error('[OFB] renderPickList parse error:', e, xhr.responseText.substring(0, 500));
        container.innerHTML = '<div style="padding:12px;color:#c62828;font-size:11px;"><strong>Failed to parse response.</strong><br/>Check the browser console (F12) for details.</div>';
    }
}

function pickToggleAll(btn) {
    var pick = btn.closest('.ofb-pick__header').nextElementSibling;
    var cbs = pick.querySelectorAll('input[type=checkbox]:not(:disabled)');
    var allChecked = true;
    for (var i = 0; i < cbs.length; i++) { if (!cbs[i].checked) { allChecked = false; break; } }
    for (var i = 0; i < cbs.length; i++) cbs[i].checked = !allChecked;
    btn.textContent = allChecked ? 'Select All' : 'Deselect All';
}

// Row click toggles checkbox
(function () {
    document.addEventListener('click', function (e) {
        var row = e.target.closest('.ofb-pick__row');
        if (!row) return;
        // Don't double-toggle if user clicked directly on the checkbox
        var cb = row.querySelector('input[type=checkbox]');
        if (!cb || cb.disabled) return;
        if (e.target !== cb) cb.checked = !cb.checked;
    });
})();

function pickAddSelected(btn, mode) {
    var pick = btn.closest('.ofb-pick__header').nextElementSibling;
    var cbs = pick.querySelectorAll('input[type=checkbox]:checked:not(:disabled)');
    var count = 0;
    for (var i = 0; i < cbs.length; i++) {
        var reg = cbs[i].getAttribute('data-reg');
        var name = cbs[i].getAttribute('data-name');
        var prog = cbs[i].getAttribute('data-prog');
        if (!_wz.studentMap[reg]) {
            _wz.students.push({ regno: reg, name: name, progcode: prog });
            _wz.studentMap[reg] = true;
            count++;
        }
        cbs[i].checked = true;
        cbs[i].disabled = true;
    }
    _wz.selectionMode = mode;
    renderSelectedStudents();
    if (count > 0) alert(count + ' student' + (count !== 1 ? 's' : '') + ' added to billing list.');
}

// ===== Auto-collect checked students from all pick lists =====
function autoCollectChecked() {
    var picks = document.querySelectorAll('.ofb-pick');
    var count = 0;
    for (var p = 0; p < picks.length; p++) {
        var cbs = picks[p].querySelectorAll('input[type=checkbox]:checked:not(:disabled)');
        for (var i = 0; i < cbs.length; i++) {
            var reg = cbs[i].getAttribute('data-reg');
            var name = cbs[i].getAttribute('data-name');
            var prog = cbs[i].getAttribute('data-prog');
            if (reg && !_wz.studentMap[reg]) {
                _wz.students.push({ regno: reg, name: name, progcode: prog });
                _wz.studentMap[reg] = true;
                count++;
            }
            cbs[i].checked = true;
            cbs[i].disabled = true;
        }
    }
    if (count > 0) {
        _wz.selectionMode = 'MIXED';
        renderSelectedStudents();
    }
}

// ===== Student Management =====
function addStudent(regno, name, progcode) {
    if (_wz.studentMap[regno]) return;
    _wz.students.push({ regno: regno, name: name, progcode: progcode });
    _wz.studentMap[regno] = true;
    renderSelectedStudents();
}

function removeStudent(regno) {
    _wz.students = _wz.students.filter(function (s) { return s.regno !== regno; });
    delete _wz.studentMap[regno];
    renderSelectedStudents();
    // Re-enable checkbox in pick lists if present
    var cbs = document.querySelectorAll('.ofb-pick input[data-reg="' + regno + '"]');
    for (var i = 0; i < cbs.length; i++) { cbs[i].disabled = false; cbs[i].checked = false; }
}

function clearAllStudents() {
    _wz.students = [];
    _wz.studentMap = {};
    renderSelectedStudents();
    // Re-enable all pick list checkboxes
    var cbs = document.querySelectorAll('.ofb-pick input[type=checkbox]');
    for (var i = 0; i < cbs.length; i++) { cbs[i].disabled = false; cbs[i].checked = false; }
}

function renderSelectedStudents() {
    var panel = document.getElementById('ofbSelPanel');
    var countEl = document.getElementById('ofbSelCount');
    var listEl = document.getElementById('ofbSelList');
    countEl.textContent = _wz.students.length;
    if (_wz.students.length === 0) {
        panel.style.display = 'none';
        return;
    }
    panel.style.display = '';
    var html = '';
    for (var i = 0; i < _wz.students.length; i++) {
        var s = _wz.students[i];
        html += '<span class="ofb-sel__chip">'
            + esc(s.name) + ' <span style="color:#888;">(' + esc(s.regno) + ')</span>'
            + '<span class="ofb-sel__chip-x" onclick="removeStudent(\'' + esc(s.regno) + '\')">&times;</span>'
            + '</span>';
    }
    listEl.innerHTML = html;
}

// ===== STEP 3: REVIEW =====
function populateReview() {
    document.getElementById('wzRevItemName').textContent = _wz.itemName;
    document.getElementById('wzRevItemSub').textContent = _wz.acadYear + ', Semester ' + _wz.semester;
    document.getElementById('wzRevItem').textContent = _wz.itemName;
    document.getElementById('wzRevAmount').textContent = 'UGX ' + fmt(_wz.amount);
    document.getElementById('wzRevYear').textContent = _wz.acadYear;
    document.getElementById('wzRevSem').textContent = 'Semester ' + _wz.semester;
    document.getElementById('wzRevDetail').textContent = _wz.detail || _wz.itemName;
    document.getElementById('wzRevCount').textContent = _wz.students.length + ' student' + (_wz.students.length !== 1 ? 's' : '');
    document.getElementById('wzRevTotal').textContent = 'UGX ' + fmt(_wz.amount * _wz.students.length);
}

// ===== STEP 4: SUBMIT =====
function wzSubmit() {
    if (!confirm('You are about to bill ' + _wz.students.length + ' student' + (_wz.students.length !== 1 ? 's' : '') + ' for UGX ' + fmt(_wz.amount) + ' each (' + _wz.itemName + ').\n\nTotal: UGX ' + fmt(_wz.amount * _wz.students.length) + '\n\nProceed?')) return;
    wzGoTo(4);
    document.getElementById('wzResultLoading').style.display = '';
    document.getElementById('wzResultDone').style.display = 'none';
    document.getElementById('wzResultMsg').textContent = 'Billing ' + _wz.students.length + ' students, please wait...';

    var regnos = _wz.students.map(function (s) { return s.regno; }).join(',');
    var params = 'item_code=' + _wz.itemCode
        + '&amount=' + _wz.amount
        + '&acad_year=' + encodeURIComponent(_wz.acadYear)
        + '&semester=' + _wz.semester
        + '&detail=' + encodeURIComponent(_wz.detail || _wz.itemName)
        + '&mode=' + encodeURIComponent(_wz.selectionMode || 'MIXED')
        + '&criteria='
        + '&students=' + encodeURIComponent(regnos);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'OtherFeesBilling.aspx?ajax=submit', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function () {
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) {
                    showResults(false, 0, 0, 0, 0, 0, '', d.error);
                } else {
                    showResults(true, d.total, d.billed, d.skipped, d.failed, d.total_amount, d.job_ref, '');
                }
            } catch (e) { showResults(false, 0, 0, 0, 0, 0, '', 'Unexpected response from server.'); }
        } else {
            showResults(false, 0, 0, 0, 0, 0, '', 'Server error (HTTP ' + xhr.status + ')');
        }
    };
    xhr.onerror = function () { showResults(false, 0, 0, 0, 0, 0, '', 'Network error. Please check your connection.'); };
    xhr.send(params);
}

function showResults(success, total, billed, skipped, failed, totalAmt, jobRef, errorMsg) {
    document.getElementById('wzResultLoading').style.display = 'none';
    var el = document.getElementById('wzResultDone');
    el.style.display = '';

    if (!success) {
        el.innerHTML = '<div class="ofb-result-card">'
            + '<div class="ofb-result-card__icon ofb-result-card__icon--err"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#c62828" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></div>'
            + '<div style="font-size:15px;font-weight:700;color:#c62828;">Batch Billing Failed</div>'
            + '<div style="font-size:12px;color:#666;margin-top:6px;">' + esc(errorMsg) + '</div>'
            + '<button type="button" class="ofb-btn ofb-btn--ghost" onclick="closeBillingWizard()" style="margin-top:14px;">Close</button></div>';
        return;
    }

    var iconCls = failed === 0 ? 'ofb-result-card__icon--ok' : 'ofb-result-card__icon--warn';
    var iconSvg = failed === 0
        ? '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>'
        : '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
    var title = failed === 0 ? 'Batch Billing Complete!' : 'Batch Billing Completed with Issues';
    var color = failed === 0 ? '#2e7d32' : '#e65100';

    el.innerHTML = '<div class="ofb-result-card">'
        + '<div class="ofb-result-card__icon ' + iconCls + '">' + iconSvg + '</div>'
        + '<div style="font-size:15px;font-weight:700;color:' + color + ';">' + title + '</div>'
        + '<div style="font-size:11px;color:#888;margin-top:4px;">Job Reference: <strong>' + esc(jobRef) + '</strong></div>'
        + '<div class="ofb-result-stats">'
        + '<div class="ofb-result-stat"><div class="ofb-result-stat__num">' + total + '</div><div class="ofb-result-stat__label">Total</div></div>'
        + '<div class="ofb-result-stat"><div class="ofb-result-stat__num" style="color:#2e7d32;">' + billed + '</div><div class="ofb-result-stat__label">Billed</div></div>'
        + (skipped > 0 ? '<div class="ofb-result-stat"><div class="ofb-result-stat__num" style="color:#e65100;">' + skipped + '</div><div class="ofb-result-stat__label">Skipped</div></div>' : '')
        + (failed > 0 ? '<div class="ofb-result-stat"><div class="ofb-result-stat__num" style="color:#c62828;">' + failed + '</div><div class="ofb-result-stat__label">Failed</div></div>' : '')
        + '</div>'
        + '<div style="font-size:12px;color:#05275C;font-weight:700;margin-top:4px;">Total Amount Billed: UGX ' + fmt(totalAmt) + '</div>'
        + '<div style="margin-top:14px;display:flex;gap:8px;justify-content:center;">'
        + '<button type="button" class="ofb-btn ofb-btn--ghost" onclick="closeBillingWizard();loadJobs();">Close</button>'
        + '<button type="button" class="ofb-btn ofb-btn--primary" onclick="wzReset();">New Batch Bill</button>'
        + '</div></div>';
}

// ===== JOBS HISTORY =====
function loadJobs() {
    var container = document.getElementById('ofbJobsContainer');
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'OtherFeesBilling.aspx?ajax=jobs', true);
    xhr.onload = function () {
        if (xhr.status !== 200) { container.innerHTML = '<div class="ofb-empty">Failed to load history.</div>'; return; }
        try {
            var jobs = JSON.parse(xhr.responseText);
            if (jobs.length === 0) {
                container.innerHTML = '<div class="ofb-empty">No batch billing jobs yet. Click <strong>New Batch Bill</strong> to get started.</div>';
                return;
            }
            var html = '<table class="ofb-table"><thead><tr>'
                + '<th>Ref</th><th>Bill Item</th><th>Amount</th><th>Year</th><th>Sem</th>'
                + '<th>Students</th><th>Billed</th><th>Status</th><th>Date</th><th>By</th><th></th>'
                + '</tr></thead><tbody>';
            for (var i = 0; i < jobs.length; i++) {
                var j = jobs[i];
                var cls = 'ofb-badge--' + j.status.toLowerCase();
                html += '<tr>'
                    + '<td style="font-weight:700;color:#174DA4;">' + esc(j.ref) + '</td>'
                    + '<td>' + esc(j.item) + '</td>'
                    + '<td>UGX ' + fmt(j.amount) + '</td>'
                    + '<td>' + esc(j.year) + '</td>'
                    + '<td>' + j.sem + '</td>'
                    + '<td>' + j.total + '</td>'
                    + '<td>' + j.success + (j.skip > 0 ? '/<span style="color:#e65100;">' + j.skip + ' skip</span>' : '') + (j.fail > 0 ? '/<span style="color:#c62828;">' + j.fail + ' fail</span>' : '') + '</td>'
                    + '<td><span class="ofb-badge ' + cls + '">' + esc(j.status) + '</span></td>'
                    + '<td style="white-space:nowrap;">' + esc(j.date) + '</td>'
                    + '<td>' + esc(j.user) + '</td>'
                    + '<td><button type="button" class="ofb-btn ofb-btn--ghost ofb-btn--sm" onclick="viewJobDetail(' + j.id + ',\'' + esc(j.ref) + '\')">View</button></td>'
                    + '</tr>';
            }
            html += '</tbody></table>';
            container.innerHTML = html;
        } catch (e) { container.innerHTML = '<div class="ofb-empty">Failed to parse history.</div>'; }
    };
    xhr.send();
}

// ===== JOB DETAIL (View modal) =====
function viewJobDetail(jobId, jobRef) {
    document.getElementById('detailTitle').textContent = 'Job ' + jobRef + ' — Details';
    document.getElementById('detailBody').innerHTML = '<div style="text-align:center;padding:30px;"><span class="ofb-spinner"></span> Loading&hellip;</div>';
    openDetailModal();
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'OtherFeesBilling.aspx?ajax=jobdetail&id=' + jobId, true);
    xhr.onload = function () {
        if (xhr.status !== 200) { document.getElementById('detailBody').innerHTML = '<div style="color:#c62828;">Failed to load.</div>'; return; }
        try {
            var d = JSON.parse(xhr.responseText);
            if (d.error) { document.getElementById('detailBody').innerHTML = '<div style="color:#c62828;">' + esc(d.error) + '</div>'; return; }
            var items = d.items;
            if (items.length === 0) { document.getElementById('detailBody').innerHTML = '<div style="color:#aaa;">No records found.</div>'; return; }
            var html = '<table class="ofb-detail-table"><thead><tr><th>Reg No</th><th>Student</th><th>Amount</th><th>TID</th><th>Status</th><th>Notes</th></tr></thead><tbody>';
            for (var i = 0; i < items.length; i++) {
                var it = items[i];
                var scls = it.status === 'SUCCESS' ? 'color:#2e7d32' : (it.status === 'SKIPPED' ? 'color:#e65100' : 'color:#c62828');
                html += '<tr>'
                    + '<td style="font-weight:700;">' + esc(it.regno) + '</td>'
                    + '<td>' + esc(it.name) + '</td>'
                    + '<td>UGX ' + fmt(it.amount) + '</td>'
                    + '<td>' + (it.tid ? '<a href="FeesTransactions.aspx?tid=' + it.tid + '" target="_blank" style="color:#174DA4;font-weight:700;">#' + it.tid + '</a>' : '—') + '</td>'
                    + '<td style="' + scls + ';font-weight:700;">' + esc(it.status) + '</td>'
                    + '<td style="font-size:10px;color:#888;">' + esc(it.error) + '</td>'
                    + '</tr>';
            }
            html += '</tbody></table>';
            document.getElementById('detailBody').innerHTML = html;
        } catch (e) { document.getElementById('detailBody').innerHTML = '<div style="color:#c62828;">Parse error.</div>'; }
    };
    xhr.send();
}

// ===== INIT on page load =====
loadJobs();
</script>

</asp:Content>
