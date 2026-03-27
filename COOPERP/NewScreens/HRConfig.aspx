<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRConfig.aspx.cs"
    Inherits="COOPERP_NewScreens_HRConfig"
    Title="HR System Configuration - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===============================================================
   HR SYSTEM CONFIGURATION - page styles
   Follows the NewScreens design system (primary #174DA4, 13 px base)
   =============================================================== */

/* -- Page header ----------------------------------------------- */
.hrc-page-header {
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 8px;
    padding: 14px 18px; background: #fff;
    border-bottom: 2px solid #174DA4; margin-bottom: 18px;
}
.hrc-page-header__left { display: flex; align-items: center; gap: 10px; }
.hrc-page-header__icon {
    width: 36px; height: 36px; background: #eef2fb; border-radius: 6px;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.hrc-page-title   { font-size: 16px; font-weight: 700; color: #1a1a2e; }
.hrc-page-sub     { font-size: 11px; color: #666; margin-top: 1px; }

/* -- Last-updated banner ---------------------------------------- */
.hrc-updated-bar {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 14px; background: #e8f0fe;
    border-left: 3px solid #174DA4; margin-bottom: 14px;
    font-size: 11px; color: #174DA4;
}

/* -- Section card ----------------------------------------------- */
.hrc-card {
    background: #fff; border: 1px solid #e0e0e0;
    border-top: 3px solid #174DA4; margin-bottom: 18px;
}
.hrc-card__header {
    display: flex; align-items: center; gap: 9px;
    padding: 10px 16px; background: #fafbfc;
    border-bottom: 1px solid #e0e0e0;
}
.hrc-card__title { font-size: 13px; font-weight: 700; color: #1a1a2e; }
.hrc-card__desc  { font-size: 11px; color: #888; margin-left: auto; }
.hrc-card__body  { padding: 16px; }

/* -- Info notice ----------------------------------------------- */
.hrc-notice {
    display: flex; align-items: flex-start; gap: 8px;
    padding: 9px 12px; background: #fffbea;
    border-left: 3px solid #f0b429; border-radius: 0;
    font-size: 11px; color: #7a4f00; margin-bottom: 14px;
    line-height: 1.5;
}

/* -- PAYE bracket table ----------------------------------------- */
.hrc-bracket-table { width: 100%; border-collapse: collapse; }
.hrc-bracket-table th {
    font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px;
    color: #888; padding: 6px 10px; border-bottom: 2px solid #e0e0e0;
    background: #fafbfc; text-align: left;
}
.hrc-bracket-table td { padding: 7px 8px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
.hrc-bracket-table tr:last-child td { border-bottom: none; }
.hrc-bracket-table tr:hover td { background: #f9fbff; }

.hrc-bracket-num {
    display: inline-flex; align-items: center; justify-content: center;
    width: 22px; height: 22px; background: #174DA4; color: #fff;
    font-size: 10px; font-weight: 700; border-radius: 50%;
}
.hrc-bracket-num--top { background: #dc3545; }
.hrc-rate-badge {
    display: inline-block; padding: 2px 8px;
    font-size: 11px; font-weight: 700; color: #155724; background: #d4edda;
}
.hrc-rate-badge--zero { color: #383d41; background: #e2e3e5; }

/* -- Form grid ------------------------------------------------- */
.hrc-form-grid   { display: grid; grid-template-columns: repeat(3,1fr); gap: 14px; }
.hrc-form-grid2  { display: grid; grid-template-columns: repeat(2,1fr); gap: 14px; }
.hrc-form-grid4  { display: grid; grid-template-columns: repeat(4,1fr); gap: 14px; }
.hrc-form-group  { display: flex; flex-direction: column; gap: 4px; }
.hrc-form-group.hrc-span2 { grid-column: span 2; }

.hrc-label {
    font-size: 11px; font-weight: 600; color: #333;
    display: flex; align-items: center; gap: 5px;
}
.hrc-label span.hrc-req { color: #dc3545; font-size: 12px; }
.hrc-hint { font-size: 10px; color: #999; margin-top: 2px; }

.hrc-input, .hrc-select {
    height: 32px; padding: 0 9px;
    border: 1px solid #d0d5dd; border-radius: 0;
    font-size: 12px; color: #1a1a2e; background: #fff;
    transition: border-color .15s;
    width: 100%; box-sizing: border-box;
}
.hrc-input:focus, .hrc-select:focus {
    outline: none; border-color: #174DA4;
    box-shadow: 0 0 0 2px rgba(23,77,164,.12);
}
.hrc-input:disabled, .hrc-input[readonly] {
    background: #f5f5f5; color: #999; cursor: default;
}
.hrc-input--rate { width: 90px; text-align: right; }
.hrc-input--amount { text-align: right; }

/* -- Toggle row (Yes/No + rate) -------------------------------- */
.hrc-toggle-row  { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.hrc-toggle-row .hrc-form-group { flex-shrink: 0; }

/* -- Buttons --------------------------------------------------- */
.hrc-actions {
    display: flex; align-items: center; justify-content: flex-end;
    gap: 10px; padding: 14px 18px;
    background: #fff; border-top: 1px solid #e0e0e0;
    position: sticky; bottom: 0; z-index: 20;
    box-shadow: 0 -2px 8px rgba(0,0,0,.07);
}
.hrc-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 0 18px; height: 34px; font-size: 12px; font-weight: 600;
    border: none; cursor: pointer; border-radius: 0; white-space: nowrap;
    transition: background .15s, opacity .15s;
}
.hrc-btn:disabled { opacity: .6; cursor: not-allowed; }
.hrc-btn--primary { background: #174DA4; color: #fff; }
.hrc-btn--primary:hover { background: #0f3a7d; }
.hrc-btn--ghost   { background: #f5f5f5; color: #333; border: 1px solid #d0d5dd; }
.hrc-btn--ghost:hover { background: #ebebeb; }
.hrc-btn--danger  { background: #dc3545; color: #fff; }

/* -- Result message ------------------------------------------- */
.hrc-result {
    display: none; padding: 10px 14px;
    font-size: 12px; font-weight: 600; border-left: 4px solid;
    margin: 0 18px 14px; align-items: center; gap: 8px;
}
.hrc-result--ok  { display: flex; background: #d4edda; border-color: #28a745; color: #155724; }
.hrc-result--err { display: flex; background: #f8d7da; border-color: #dc3545; color: #721c24; }

/* -- Misc ------------------------------------------------------ */
.hrc-suffix { font-size: 11px; color: #888; white-space: nowrap; align-self: center; padding: 0 4px; }
.hrc-input-wrap { display: flex; align-items: center; gap: 4px; }

@media (max-width: 800px) {
    .hrc-form-grid  { grid-template-columns: 1fr 1fr; }
    .hrc-form-grid4 { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 520px) {
    .hrc-form-grid, .hrc-form-grid2, .hrc-form-grid4 { grid-template-columns: 1fr; }
    .hrc-form-group.hrc-span2 { grid-column: span 1; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- -- Page Header ----------------------------------------------- -->
<div class="hrc-page-header">
    <div class="hrc-page-header__left">
        <div class="hrc-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                 fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
            </svg>
        </div>
        <div>
            <div class="hrc-page-title">HR System Configuration</div>
            <div class="hrc-page-sub">Tax brackets, statutory rates, leave policies and working-time defaults for Uganda</div>
        </div>
    </div>
</div>

<!-- -- Last Updated Banner -------------------------------------- -->
<asp:Panel ID="pnlLastUpdated" runat="server" Visible="false" CssClass="hrc-updated-bar">
    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
         fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <span><asp:Literal ID="litLastUpdated" runat="server" /></span>
</asp:Panel>

<!-- -- Result ---------------------------------------------------- -->
<div id="divResult" class="hrc-result" runat="server">
    <asp:Literal ID="litResult" runat="server" />
</div>

<!-- ===========================================================
     SECTION 1 - PAYE TAX BRACKETS
     =========================================================== -->
<div class="hrc-card">
    <div class="hrc-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/>
            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        <span class="hrc-card__title">PAYE Tax Brackets</span>
        <span class="hrc-card__desc">Monthly taxable income ranges &amp; rates - Uganda URA (Pay As You Earn)</span>
    </div>
    <div class="hrc-card__body">
        <div class="hrc-notice">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;margin-top:1px">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            All amounts are in <strong>Uganda Shillings (UGX)</strong> per month. Brackets are applied progressively.
            Bracket 5 has no upper limit (the "To" field is disabled). Tax in each bracket = (income in bracket) x rate %.
        </div>

        <table class="hrc-bracket-table">
            <thead>
                <tr>
                    <th style="width:40px">#</th>
                    <th>From (UGX)</th>
                    <th>To (UGX)</th>
                    <th style="width:110px">Rate (%)</th>
                    <th style="width:90px">Preview</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><span class="hrc-bracket-num">1</span></td>
                    <td>
                        <asp:TextBox ID="txtPayeB1Min" runat="server" Text="0" CssClass="hrc-input hrc-input--amount"
                            ReadOnly="true" ToolTip="Always 0" />
                    </td>
                    <td>
                        <asp:TextBox ID="txtPayeB1Max" runat="server" Text="235000" CssClass="hrc-input hrc-input--amount" />
                    </td>
                    <td>
                        <div class="hrc-input-wrap">
                            <asp:TextBox ID="txtPayeB1Rate" runat="server" Text="0" CssClass="hrc-input hrc-input--rate" />
                            <span class="hrc-suffix">%</span>
                        </div>
                    </td>
                    <td><span class="hrc-rate-badge hrc-rate-badge--zero" id="pvB1">0%</span></td>
                </tr>
                <tr>
                    <td><span class="hrc-bracket-num">2</span></td>
                    <td>
                        <asp:TextBox ID="txtPayeB2Min" runat="server" Text="235001" CssClass="hrc-input hrc-input--amount"
                            ReadOnly="true" ToolTip="Auto: B1 Max + 1" />
                    </td>
                    <td>
                        <asp:TextBox ID="txtPayeB2Max" runat="server" Text="335000" CssClass="hrc-input hrc-input--amount" />
                    </td>
                    <td>
                        <div class="hrc-input-wrap">
                            <asp:TextBox ID="txtPayeB2Rate" runat="server" Text="10" CssClass="hrc-input hrc-input--rate" />
                            <span class="hrc-suffix">%</span>
                        </div>
                    </td>
                    <td><span class="hrc-rate-badge" id="pvB2">10%</span></td>
                </tr>
                <tr>
                    <td><span class="hrc-bracket-num">3</span></td>
                    <td>
                        <asp:TextBox ID="txtPayeB3Min" runat="server" Text="335001" CssClass="hrc-input hrc-input--amount"
                            ReadOnly="true" ToolTip="Auto: B2 Max + 1" />
                    </td>
                    <td>
                        <asp:TextBox ID="txtPayeB3Max" runat="server" Text="410000" CssClass="hrc-input hrc-input--amount" />
                    </td>
                    <td>
                        <div class="hrc-input-wrap">
                            <asp:TextBox ID="txtPayeB3Rate" runat="server" Text="20" CssClass="hrc-input hrc-input--rate" />
                            <span class="hrc-suffix">%</span>
                        </div>
                    </td>
                    <td><span class="hrc-rate-badge" id="pvB3">20%</span></td>
                </tr>
                <tr>
                    <td><span class="hrc-bracket-num">4</span></td>
                    <td>
                        <asp:TextBox ID="txtPayeB4Min" runat="server" Text="410001" CssClass="hrc-input hrc-input--amount"
                            ReadOnly="true" ToolTip="Auto: B3 Max + 1" />
                    </td>
                    <td>
                        <asp:TextBox ID="txtPayeB4Max" runat="server" Text="10000000" CssClass="hrc-input hrc-input--amount" />
                    </td>
                    <td>
                        <div class="hrc-input-wrap">
                            <asp:TextBox ID="txtPayeB4Rate" runat="server" Text="30" CssClass="hrc-input hrc-input--rate" />
                            <span class="hrc-suffix">%</span>
                        </div>
                    </td>
                    <td><span class="hrc-rate-badge" id="pvB4">30%</span></td>
                </tr>
                <tr style="background:#fff8f8">
                    <td><span class="hrc-bracket-num hrc-bracket-num--top">5</span></td>
                    <td>
                        <asp:TextBox ID="txtPayeB5Min" runat="server" Text="10000001" CssClass="hrc-input hrc-input--amount"
                            ReadOnly="true" ToolTip="Auto: B4 Max + 1" />
                    </td>
                    <td>
                        <asp:TextBox ID="txtPayeB5Max" runat="server" Text="" CssClass="hrc-input hrc-input--amount"
                            ReadOnly="true" ToolTip="Top bracket - no upper limit" placeholder="(no limit)" />
                    </td>
                    <td>
                        <div class="hrc-input-wrap">
                            <asp:TextBox ID="txtPayeB5Rate" runat="server" Text="40" CssClass="hrc-input hrc-input--rate" />
                            <span class="hrc-suffix">%</span>
                        </div>
                    </td>
                    <td><span class="hrc-rate-badge hrc-bracket-num--top" id="pvB5"
                              style="background:#f8d7da;color:#721c24">40%</span></td>
                </tr>
            </tbody>
        </table>
        <p style="font-size:10px;color:#aaa;margin:8px 0 0;padding-left:2px">
            * "From" values for brackets 2-5 are automatically set to (previous bracket Max + 1) on save.
        </p>
    </div>
</div>

<!-- ===========================================================
     SECTION 2 - STATUTORY CONTRIBUTIONS
     =========================================================== -->
<div class="hrc-card">
    <div class="hrc-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        <span class="hrc-card__title">Statutory &amp; Kingdom Contributions</span>
        <span class="hrc-card__desc">NSSF and Kabaka/Kingdom tithe rates</span>
    </div>
    <div class="hrc-card__body">
        <div class="hrc-form-grid">
            <div class="hrc-form-group">
                <label class="hrc-label">Employee NSSF Rate <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtNssfEmployee" runat="server" Text="5" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">% of basic pay</span>
                </div>
                <span class="hrc-hint">Deducted from employee's gross pay each month</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Employer NSSF Rate <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtNssfEmployer" runat="server" Text="10" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">% of basic pay</span>
                </div>
                <span class="hrc-hint">Institution's contribution - not deducted from salary (for reporting only)</span>
            </div>
            <div class="hrc-form-group">
                <!-- spacer -->
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Charge Kabaka Contribution?</label>
                <asp:DropDownList ID="ddlChargeKabaka" runat="server" CssClass="hrc-select">
                    <asp:ListItem Value="Yes">Yes - deduct Kabaka tithe</asp:ListItem>
                    <asp:ListItem Value="No">No - do not deduct</asp:ListItem>
                </asp:DropDownList>
                <span class="hrc-hint">Buganda Kingdom tithe (applies to Baganda employees)</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Kabaka Contribution Rate <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtKabakaRate" runat="server" Text="1" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">% of basic pay</span>
                </div>
                <span class="hrc-hint">Applied when "Charge Kabaka" is Yes</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 3 - LOCAL SERVICE TAX
     =========================================================== -->
<div class="hrc-card">
    <div class="hrc-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/></svg>
        <span class="hrc-card__title">Local Service Tax (LST)</span>
        <span class="hrc-card__desc">District / municipality local tax on employment income</span>
    </div>
    <div class="hrc-card__body">
        <div class="hrc-form-grid2">
            <div class="hrc-form-group">
                <label class="hrc-label">Charge Local Service Tax?</label>
                <asp:DropDownList ID="ddlChargeLocalTax" runat="server" CssClass="hrc-select">
                    <asp:ListItem Value="No">No - do not charge LST</asp:ListItem>
                    <asp:ListItem Value="Yes">Yes - deduct local service tax</asp:ListItem>
                </asp:DropDownList>
                <span class="hrc-hint">Uganda LST is levied by local governments on employment income</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Local Tax Rate <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtLocalTaxRate" runat="server" Text="1" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">% of basic pay</span>
                </div>
                <span class="hrc-hint">Applied when "Charge Local Service Tax" is Yes</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 4 - LEAVE ENTITLEMENTS
     =========================================================== -->
<div class="hrc-card">
    <div class="hrc-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span class="hrc-card__title">Default Leave Entitlements</span>
        <span class="hrc-card__desc">Calendar days per year - used when allocating leave for new employees</span>
    </div>
    <div class="hrc-card__body">
        <div class="hrc-form-grid4">
            <div class="hrc-form-group">
                <label class="hrc-label">Annual Leave <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtAnnualLeave" runat="server" Text="30" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">days</span>
                </div>
                <span class="hrc-hint">Uganda Employment Act: min 21 days</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Maternity Leave <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtMaternityLeave" runat="server" Text="60" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">days</span>
                </div>
                <span class="hrc-hint">Uganda Employment Act: min 60 days</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Paternity Leave <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtPaternityLeave" runat="server" Text="4" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">days</span>
                </div>
                <span class="hrc-hint">Uganda Employment Act: min 4 days</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Sick Leave <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtSickLeave" runat="server" Text="30" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">days</span>
                </div>
                <span class="hrc-hint">Per year with full pay</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 5 - EMPLOYMENT POLICIES
     =========================================================== -->
<div class="hrc-card">
    <div class="hrc-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/></svg>
        <span class="hrc-card__title">Employment Policies</span>
        <span class="hrc-card__desc">Financial year, probation, overtime and gratuity defaults</span>
    </div>
    <div class="hrc-card__body">
        <div class="hrc-form-grid">
            <div class="hrc-form-group">
                <label class="hrc-label">Financial Year Start Month <span class="hrc-req">*</span></label>
                <asp:DropDownList ID="ddlFYStartMonth" runat="server" CssClass="hrc-select">
                    <asp:ListItem Value="1">January</asp:ListItem>
                    <asp:ListItem Value="2">February</asp:ListItem>
                    <asp:ListItem Value="3">March</asp:ListItem>
                    <asp:ListItem Value="4">April</asp:ListItem>
                    <asp:ListItem Value="5">May</asp:ListItem>
                    <asp:ListItem Value="6">June</asp:ListItem>
                    <asp:ListItem Value="7" Selected="True">July (Uganda Govt)</asp:ListItem>
                    <asp:ListItem Value="8">August</asp:ListItem>
                    <asp:ListItem Value="9">September</asp:ListItem>
                    <asp:ListItem Value="10">October</asp:ListItem>
                    <asp:ListItem Value="11">November</asp:ListItem>
                    <asp:ListItem Value="12">December</asp:ListItem>
                </asp:DropDownList>
                <span class="hrc-hint">Uganda government fiscal year begins in July</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Probation Period <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtProbation" runat="server" Text="3" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">months</span>
                </div>
                <span class="hrc-hint">Uganda Employment Act: max 6 months</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Notice Period <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtNotice" runat="server" Text="30" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">days</span>
                </div>
                <span class="hrc-hint">For resignation / termination</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Overtime Rate Multiplier <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtOvertime" runat="server" Text="1.5" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">x hourly rate</span>
                </div>
                <span class="hrc-hint">E.g. 1.5 = time-and-a-half. Uganda Employment Act min = 1.5</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Gratuity Rate <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtGratuity" runat="server" Text="5" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">% of annual gross</span>
                </div>
                <span class="hrc-hint">End-of-service / retirement benefit calculation base</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 6 - WORKING HOURS
     =========================================================== -->
<div class="hrc-card">
    <div class="hrc-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2">
            <circle cx="12" cy="12" r="10"/>
            <polyline points="12 6 12 12 16 14"/></svg>
        <span class="hrc-card__title">Working Hours &amp; Days</span>
        <span class="hrc-card__desc">Used for overtime calculations and daily rate conversions</span>
    </div>
    <div class="hrc-card__body">
        <div class="hrc-form-grid2">
            <div class="hrc-form-group">
                <label class="hrc-label">Working Days Per Month <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtWorkingDays" runat="server" Text="22" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">days / month</span>
                </div>
                <span class="hrc-hint">Average working days excluding weekends (typically 22)</span>
            </div>
            <div class="hrc-form-group">
                <label class="hrc-label">Working Hours Per Day <span class="hrc-req">*</span></label>
                <div class="hrc-input-wrap">
                    <asp:TextBox ID="txtWorkingHours" runat="server" Text="8" CssClass="hrc-input hrc-input--rate" />
                    <span class="hrc-suffix">hrs / day</span>
                </div>
                <span class="hrc-hint">Standard working hours per day (Uganda Employment Act: max 8 hours)</span>
            </div>
        </div>
    </div>
</div>

<!-- -- Sticky Save Bar ------------------------------------------- -->
<div class="hrc-actions">
    <asp:Button ID="btnReset" runat="server" Text="Reset to Defaults" CssClass="hrc-btn hrc-btn--ghost"
        OnClick="btnReset_Click"
        OnClientClick="return confirm('Reset ALL settings to factory defaults? This cannot be undone.');" />
    <asp:Button ID="btnSave" runat="server" Text="Save Configuration" CssClass="hrc-btn hrc-btn--primary"
        OnClick="btnSave_Click" />
</div>

<script>
// -- Live PAYE bracket preview --------------------------------
(function () {
    var rateFields = [
        { rateId: '<%= txtPayeB1Rate.ClientID %>', pvId: 'pvB1', zero: true },
        { rateId: '<%= txtPayeB2Rate.ClientID %>', pvId: 'pvB2', zero: false },
        { rateId: '<%= txtPayeB3Rate.ClientID %>', pvId: 'pvB3', zero: false },
        { rateId: '<%= txtPayeB4Rate.ClientID %>', pvId: 'pvB4', zero: false },
        { rateId: '<%= txtPayeB5Rate.ClientID %>', pvId: 'pvB5', zero: false }
    ];
    rateFields.forEach(function (f) {
        var inp = document.getElementById(f.rateId);
        var pv  = document.getElementById(f.pvId);
        if (!inp || !pv) return;
        function upd() {
            var v = parseFloat(inp.value);
            pv.textContent = isNaN(v) ? '?' : v.toFixed(0) + '%';
        }
        inp.addEventListener('input', upd);
        inp.addEventListener('change', upd);
    });

    // Auto-cascade "From" values
    var maxIds  = ['<%= txtPayeB1Max.ClientID %>', '<%= txtPayeB2Max.ClientID %>',
                   '<%= txtPayeB3Max.ClientID %>', '<%= txtPayeB4Max.ClientID %>'];
    var minIds  = ['<%= txtPayeB2Min.ClientID %>', '<%= txtPayeB3Min.ClientID %>',
                   '<%= txtPayeB4Min.ClientID %>', '<%= txtPayeB5Min.ClientID %>'];
    maxIds.forEach(function (mxId, i) {
        var mx = document.getElementById(mxId);
        var mn = document.getElementById(minIds[i]);
        if (!mx || !mn) return;
        mx.addEventListener('change', function () {
            var v = parseInt(mx.value.replace(/,/g, ''), 10);
            if (!isNaN(v)) mn.value = (v + 1).toString();
        });
    });
})();
</script>

</asp:Content>