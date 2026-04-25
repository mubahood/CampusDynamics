<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="FeeAccessPolicy.aspx.cs"
    Inherits="COOPERP_NewScreens_FeeAccessPolicy"
    Title="Fee Access Policy - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===============================================================
   FEE ACCESS POLICY — fap- prefix
   Design system: primary #05275C, accent #174DA4, 0 border-radius
   Single-page layout with cascading rule sections
   =============================================================== */

/* -- Page header ----------------------------------------------- */
.fap-page-header {
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 8px;
    padding: 14px 18px; background: #fff;
    border-bottom: 2px solid #174DA4; margin-bottom: 18px;
}
.fap-page-header__left { display: flex; align-items: center; gap: 10px; }
.fap-page-header__icon {
    width: 36px; height: 36px; background: #eef2fb; border-radius: 6px;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.fap-page-title { font-size: 16px; font-weight: 700; color: #1a1a2e; }
.fap-page-sub   { font-size: 11px; color: #666; margin-top: 1px; }
.fap-page-header__right { display: flex; align-items: center; gap: 8px; }

/* -- Last-updated banner ---------------------------------------- */
.fap-updated-bar {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 14px; background: #e8f0fe;
    border-left: 3px solid #174DA4; margin-bottom: 14px;
    font-size: 11px; color: #174DA4;
}

/* -- Result banner --------------------------------------------- */
.fap-result {
    display: none; padding: 10px 14px;
    font-size: 12px; font-weight: 600; border-left: 4px solid;
    margin: 0 0 14px; align-items: center; gap: 8px;
}
.fap-result--ok  { display: flex; background: #d4edda; border-color: #28a745; color: #155724; }
.fap-result--err { display: flex; background: #f8d7da; border-color: #dc3545; color: #721c24; }

/* -- Section card ----------------------------------------------- */
.fap-card {
    background: #fff; border: 1px solid #e0e0e0;
    border-top: 3px solid #174DA4; margin-bottom: 18px;
}
.fap-card--rules  { border-top-color: #7c3aed; }
.fap-card--preview { border-top-color: #16a34a; }
.fap-card__header {
    display: flex; align-items: center; gap: 9px;
    padding: 10px 16px; background: #fafbfc;
    border-bottom: 1px solid #e0e0e0;
}
.fap-card__title { font-size: 13px; font-weight: 700; color: #1a1a2e; }
.fap-card__desc  { font-size: 11px; color: #888; margin-left: auto; }
.fap-card__body  { padding: 16px; }

/* -- Section anchor line ---------------------------------------- */
.fap-section-label {
    display: flex; align-items: center; gap: 10px;
    margin: 22px 0 10px; padding: 0 2px;
    font-size: 11px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .6px; color: #7c3aed;
}
.fap-section-label:first-child { margin-top: 0; }
.fap-section-label::after {
    content: ''; flex: 1; height: 1px; background: #d0d5dd;
}

/* -- Form grid ------------------------------------------------- */
.fap-form-grid  { display: grid; grid-template-columns: repeat(3,1fr); gap: 14px; }
.fap-form-grid2 { display: grid; grid-template-columns: repeat(2,1fr); gap: 14px; }
.fap-form-group { display: flex; flex-direction: column; gap: 4px; }
.fap-form-group.fap-span2 { grid-column: span 2; }
.fap-form-group.fap-span3 { grid-column: span 3; }
.fap-label {
    font-size: 11px; font-weight: 600; color: #333;
    display: flex; align-items: center; gap: 5px;
}
.fap-hint { font-size: 10px; color: #999; margin-top: 2px; }
.fap-input, .fap-select {
    height: 32px; padding: 0 9px;
    border: 1px solid #d0d5dd; border-radius: 0;
    font-size: 12px; color: #1a1a2e; background: #fff;
    transition: border-color .15s;
    width: 100%; box-sizing: border-box;
}
.fap-textarea {
    padding: 7px 9px; border: 1px solid #d0d5dd; border-radius: 0;
    font-size: 12px; color: #1a1a2e; background: #fff;
    width: 100%; box-sizing: border-box; resize: vertical;
    font-family: inherit;
}
.fap-input:focus, .fap-select:focus, .fap-textarea:focus {
    outline: none; border-color: #174DA4;
    box-shadow: 0 0 0 2px rgba(23,77,164,.12);
}
.fap-input--amount { text-align: right; }
.fap-input-wrap { display: flex; align-items: center; gap: 4px; }
.fap-suffix { font-size: 11px; color: #888; white-space: nowrap; padding: 0 4px; }

/* -- Cascade: rule detail fields slide open -------------------- */
.fap-rule-fields {
    overflow: hidden; max-height: 0; opacity: 0;
    transition: max-height .3s ease, opacity .25s ease, margin .25s ease;
    margin-top: 0;
}
.fap-rule-fields--open {
    max-height: 400px; opacity: 1; margin-top: 10px;
}

/* -- Notice ---------------------------------------------------- */
.fap-notice {
    display: flex; align-items: flex-start; gap: 8px;
    padding: 9px 12px; background: #e8f0fe;
    border-left: 3px solid #174DA4;
    font-size: 11px; color: #174DA4; margin-bottom: 14px;
    line-height: 1.5;
}

/* -- Preview stats --------------------------------------------- */
.fap-preview-stats {
    display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; margin: 14px 0;
}
.fap-stat {
    padding: 14px; border: 1px solid #e0e5ed; text-align: center; position: relative;
    overflow: hidden;
}
.fap-stat::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; }
.fap-stat--total::before { background: #174DA4; }
.fap-stat--pass::before  { background: #16a34a; }
.fap-stat--fail::before  { background: #dc3545; }
.fap-stat__val { font-size: 22px; font-weight: 700; color: #1a1a2e; }
.fap-stat--pass .fap-stat__val { color: #16a34a; }
.fap-stat--fail .fap-stat__val { color: #dc3545; }
.fap-stat__label {
    font-size: 10px; text-transform: uppercase; letter-spacing: .4px;
    color: #888; font-weight: 600; margin-top: 4px;
}

/* -- Tags ------------------------------------------------------ */
.fap-tag { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 700; }
.fap-tag--on  { background: #d4edda; color: #155724; }
.fap-tag--off { background: #f0f0f0; color: #888; }

/* -- Toggle switch (radio-based) -------------------------------- */
.fap-toggle { display: flex; gap: 0; border: 1px solid #d0d5dd; width: fit-content; }
.fap-toggle__input { display: none; }
.fap-toggle__label {
    display: flex; align-items: center; gap: 6px;
    padding: 7px 16px; font-size: 12px; font-weight: 600;
    cursor: pointer; background: #fff; color: #555;
    transition: background .15s, color .15s;
    user-select: none; border-right: 1px solid #d0d5dd;
}
.fap-toggle__label:last-child { border-right: none; }
.fap-toggle__input:checked + .fap-toggle__label--on {
    background: #16a34a; color: #fff;
}
.fap-toggle__input:checked + .fap-toggle__label--off {
    background: #dc3545; color: #fff;
}
.fap-toggle__dot {
    width: 8px; height: 8px; border-radius: 50%;
    border: 2px solid currentColor; flex-shrink: 0;
}
.fap-toggle__input:checked + .fap-toggle__label .fap-toggle__dot {
    background: currentColor;
}

/* -- Buttons --------------------------------------------------- */
.fap-actions {
    display: flex; align-items: center; justify-content: flex-end;
    gap: 10px; padding: 14px 0; margin-top: 4px;
}
.fap-actions--split { justify-content: space-between; }
.fap-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 0 22px; height: 36px; font-size: 12px; font-weight: 600;
    border: none; cursor: pointer; border-radius: 0; white-space: nowrap;
    transition: background .15s, opacity .15s; font-family: inherit;
}
.fap-btn:disabled { opacity: .6; cursor: not-allowed; }
.fap-btn--primary { background: #174DA4; color: #fff; }
.fap-btn--primary:hover { background: #0f3a7d; }
.fap-btn--success { background: #16a34a; color: #fff; }
.fap-btn--success:hover { background: #138a3e; }
.fap-btn--ghost { background: #f5f5f5; color: #333; border: 1px solid #d0d5dd; }
.fap-btn--ghost:hover { background: #ebebeb; }

/* -- Responsive ------------------------------------------------ */
@media (max-width: 900px) {
    .fap-form-grid { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 520px) {
    .fap-form-grid, .fap-form-grid2 { grid-template-columns: 1fr; }
    .fap-form-group.fap-span2, .fap-form-group.fap-span3 { grid-column: span 1; }
    .fap-preview-stats { grid-template-columns: 1fr; }
    .fap-page-header { flex-direction: column; align-items: flex-start; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══════════════ PAGE HEADER ═══════════════ -->
<div class="fap-page-header">
    <div class="fap-page-header__left">
        <div class="fap-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                 fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
            </svg>
        </div>
        <div>
            <div class="fap-page-title">Fee Access Policy</div>
            <div class="fap-page-sub">Configure the criteria that determine whether students are granted university access</div>
        </div>
    </div>
    <div class="fap-page-header__right">
        <asp:Button ID="btnPreview" runat="server" Text="Preview Impact"
            CssClass="fap-btn fap-btn--success" OnClick="btnPreview_Click" CausesValidation="false" />
    </div>
</div>

<!-- Last Updated Banner -->
<asp:Panel ID="pnlLastUpdated" runat="server" Visible="false" CssClass="fap-updated-bar">
    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
         fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <asp:Literal ID="litLastUpdated" runat="server" />
</asp:Panel>

<!-- Result Banner -->
<div id="divResult" class="fap-result" runat="server">
    <asp:Literal ID="litResult" runat="server" />
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!--  SECTION 1 — General Settings                      -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="fap-card">
    <div class="fap-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2"><circle cx="12" cy="12" r="3"/>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9c.26.604.852.997 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
        </svg>
        <span class="fap-card__title">General Settings</span>
        <span class="fap-card__desc">Master toggle and general configuration</span>
    </div>
    <div class="fap-card__body">
        <div class="fap-form-grid">
            <div class="fap-form-group">
                <label class="fap-label">Policy Status</label>
                <asp:Literal ID="litActiveToggle" runat="server" />
                <span class="fap-hint">When enabled, students are evaluated against these criteria</span>
            </div>
            <div class="fap-form-group">
                <label class="fap-label">Combination Logic</label>
                <asp:DropDownList ID="ddlLogic" runat="server" CssClass="fap-select">
                    <asp:ListItem Value="ALL" Selected="True">ALL rules must pass</asp:ListItem>
                    <asp:ListItem Value="ANY">ANY one rule passing is enough</asp:ListItem>
                </asp:DropDownList>
                <span class="fap-hint">How enabled rules are combined to determine access</span>
            </div>
            <div class="fap-form-group">
                <label class="fap-label">Policy Title</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="fap-input" Text="Fee Access Policy"
                    placeholder="e.g. Semester 1 Access Policy" />
            </div>
        </div>
        <div style="margin-top:14px;">
            <div class="fap-form-group">
                <label class="fap-label">Notes</label>
                <asp:TextBox ID="txtNotes" runat="server" CssClass="fap-textarea" TextMode="MultiLine"
                    Rows="2" placeholder="Optional notes about this policy configuration..." />
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!--  SECTION 2 — Access Rules (cascading sub-fields)   -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="fap-card fap-card--rules">
    <div class="fap-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#7c3aed" stroke-width="2"><polyline points="9 11 12 14 22 4"/>
            <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        <span class="fap-card__title">Access Rules</span>
        <span class="fap-card__desc">Enable rules and set thresholds &mdash; sub-fields appear when a rule is turned on</span>
    </div>
    <div class="fap-card__body">

        <!-- ─── Balance Threshold ─── -->
        <div class="fap-section-label">Balance Threshold</div>
        <div class="fap-form-grid2">
            <div class="fap-form-group">
                <label class="fap-label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                    Enable Balance Rule
                </label>
                <asp:DropDownList ID="ddlBalOn" runat="server" CssClass="fap-select fap-cascade"
                    data-target="fapBalFields">
                    <asp:ListItem Value="no" Selected="True">No</asp:ListItem>
                    <asp:ListItem Value="yes">Yes</asp:ListItem>
                </asp:DropDownList>
                <span class="fap-hint">Deny access to students with balances above a threshold</span>
            </div>
        </div>
        <div id="fapBalFields" class="fap-rule-fields">
            <div class="fap-form-grid2">
                <div class="fap-form-group">
                    <label class="fap-label">Maximum Allowed Balance (UGX)</label>
                    <asp:TextBox ID="txtBalMax" runat="server" CssClass="fap-input fap-input--amount"
                        Text="0" placeholder="e.g. 500000" />
                    <span class="fap-hint">Students with balance above this are denied</span>
                </div>
            </div>
        </div>

        <!-- ─── Payment Window ─── -->
        <div class="fap-section-label">Payment Window</div>
        <div class="fap-form-grid2">
            <div class="fap-form-group">
                <label class="fap-label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
                        <line x1="3" y1="10" x2="21" y2="10"/></svg>
                    Enable Payment Window Rule
                </label>
                <asp:DropDownList ID="ddlWinOn" runat="server" CssClass="fap-select fap-cascade"
                    data-target="fapWinFields">
                    <asp:ListItem Value="no" Selected="True">No</asp:ListItem>
                    <asp:ListItem Value="yes">Yes</asp:ListItem>
                </asp:DropDownList>
                <span class="fap-hint">Require a minimum payment within a date range</span>
            </div>
        </div>
        <div id="fapWinFields" class="fap-rule-fields">
            <div class="fap-form-grid">
                <div class="fap-form-group">
                    <label class="fap-label">Minimum Payment (UGX)</label>
                    <asp:TextBox ID="txtWinAmt" runat="server" CssClass="fap-input fap-input--amount"
                        Text="0" placeholder="e.g. 200000" />
                </div>
                <div class="fap-form-group">
                    <label class="fap-label">Window Start</label>
                    <asp:TextBox ID="txtWinStart" runat="server" CssClass="fap-input" TextMode="Date" />
                </div>
                <div class="fap-form-group">
                    <label class="fap-label">Window End</label>
                    <asp:TextBox ID="txtWinEnd" runat="server" CssClass="fap-input" TextMode="Date" />
                </div>
            </div>
        </div>

        <!-- ─── Percentage Paid ─── -->
        <div class="fap-section-label">Percentage Paid</div>
        <div class="fap-form-grid2">
            <div class="fap-form-group">
                <label class="fap-label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="5" x2="5" y2="19"/>
                        <circle cx="6.5" cy="6.5" r="2.5"/><circle cx="17.5" cy="17.5" r="2.5"/></svg>
                    Enable Percentage Rule
                </label>
                <asp:DropDownList ID="ddlPctOn" runat="server" CssClass="fap-select fap-cascade"
                    data-target="fapPctFields">
                    <asp:ListItem Value="no" Selected="True">No</asp:ListItem>
                    <asp:ListItem Value="yes">Yes</asp:ListItem>
                </asp:DropDownList>
                <span class="fap-hint">Require a minimum percentage of total fees to be paid</span>
            </div>
        </div>
        <div id="fapPctFields" class="fap-rule-fields">
            <div class="fap-form-grid2">
                <div class="fap-form-group">
                    <label class="fap-label">Minimum Percentage</label>
                    <div class="fap-input-wrap">
                        <asp:TextBox ID="txtPctMin" runat="server" CssClass="fap-input" style="width:100px;text-align:right;"
                            Text="0" placeholder="e.g. 60" />
                        <span class="fap-suffix">%</span>
                    </div>
                    <span class="fap-hint">e.g. 60 means student must have paid at least 60%</span>
                </div>
            </div>
        </div>

        <!-- ─── Bursary Exemption ─── -->
        <div class="fap-section-label">Bursary / Scholarship Exemption</div>
        <div class="fap-form-grid2">
            <div class="fap-form-group">
                <label class="fap-label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                        <polyline points="22 4 12 14.01 9 11.01"/></svg>
                    Enable Bursary Exemption
                </label>
                <asp:DropDownList ID="ddlBurOn" runat="server" CssClass="fap-select fap-cascade"
                    data-target="fapBurFields">
                    <asp:ListItem Value="no" Selected="True">No</asp:ListItem>
                    <asp:ListItem Value="yes">Yes &mdash; exempt bursary holders</asp:ListItem>
                </asp:DropDownList>
                <span class="fap-hint">Auto-exempt students whose bursary covers the minimum</span>
            </div>
        </div>
        <div id="fapBurFields" class="fap-rule-fields">
            <div class="fap-form-grid2">
                <div class="fap-form-group">
                    <label class="fap-label">Min Bursary Coverage</label>
                    <div class="fap-input-wrap">
                        <asp:TextBox ID="txtBurMin" runat="server" CssClass="fap-input" style="width:100px;text-align:right;"
                            Text="0" placeholder="e.g. 80" />
                        <span class="fap-suffix">%</span>
                    </div>
                    <span class="fap-hint">Minimum scholarship coverage needed for exemption</span>
                </div>
            </div>
        </div>

        <!-- ─── Registration Required ─── -->
        <div class="fap-section-label">Registration Requirement</div>
        <div class="fap-form-grid2">
            <div class="fap-form-group">
                <label class="fap-label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/>
                        <line x1="23" y1="11" x2="17" y2="11"/></svg>
                    Require Current-Semester Registration
                </label>
                <asp:DropDownList ID="ddlRegOn" runat="server" CssClass="fap-select">
                    <asp:ListItem Value="no" Selected="True">No</asp:ListItem>
                    <asp:ListItem Value="yes">Yes &mdash; must be registered</asp:ListItem>
                </asp:DropDownList>
                <span class="fap-hint">Checks that the student is registered for the current semester</span>
            </div>
        </div>

    </div>
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!--  SAVE BAR                                           -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="fap-actions fap-actions--split">
    <asp:Button ID="btnSave" runat="server" Text="Save All Settings"
        CssClass="fap-btn fap-btn--primary" OnClick="btnSave_Click" />
    <asp:Button ID="btnPreviewBottom" runat="server" Text="Preview Impact"
        CssClass="fap-btn fap-btn--success" OnClick="btnPreview_Click" CausesValidation="false" />
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!--  PREVIEW RESULTS (shown after preview click)       -->
<!-- ═══════════════════════════════════════════════════ -->
<asp:Panel ID="pnlPreviewResult" runat="server" Visible="false">
    <div class="fap-card fap-card--preview">
        <div class="fap-card__header">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                 fill="none" stroke="#16a34a" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            <span class="fap-card__title">Preview Impact</span>
            <span class="fap-card__desc">How this policy would affect students with current data</span>
        </div>
        <div class="fap-card__body">
            <asp:Literal ID="litPreview" runat="server" />
        </div>
    </div>
</asp:Panel>

<!-- ═══════════════════════════════════════════════════ -->
<!--  CASCADE JS — show/hide rule sub-fields            -->
<!-- ═══════════════════════════════════════════════════ -->
<script type="text/javascript">
(function () {
    function initCascades() {
        var toggles = document.querySelectorAll('.fap-cascade');
        for (var i = 0; i < toggles.length; i++) {
            (function (ddl) {
                var targetId = ddl.getAttribute('data-target');
                if (!targetId) return;
                var panel = document.getElementById(targetId);
                if (!panel) return;
                function sync() {
                    if (ddl.value === 'yes') panel.classList.add('fap-rule-fields--open');
                    else panel.classList.remove('fap-rule-fields--open');
                }
                sync();
                ddl.addEventListener('change', sync);
            })(toggles[i]);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () { initCascades(); });
    } else {
        initCascades();
    }
})();
</script>

</asp:Content>
