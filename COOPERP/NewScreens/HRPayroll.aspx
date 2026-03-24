<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRPayroll.aspx.cs"
    Inherits="COOPERP_NewScreens_HRPayroll"
    Title="Payroll Management - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Page header ─────────────────────────────────────────── */
.pr-page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 0 12px 0;
    margin-bottom: 16px;
    border-bottom: 2px solid #174DA4;
}
.pr-page-header .ph-left {
    display: flex;
    align-items: center;
    gap: 12px;
}
.pr-page-header .ph-icon {
    flex-shrink: 0;
    width: 38px;
    height: 38px;
}
.pr-page-header .ph-title {
    font-size: 17px;
    font-weight: 700;
    color: #05275C;
    line-height: 1.2;
    margin: 0;
}
.pr-page-header .ph-sub {
    font-size: 12px;
    color: #666;
    margin: 2px 0 0 0;
}
.pr-page-header .ph-actions {
    display: flex;
    gap: 8px;
    align-items: center;
}

/* ── Stats cards ─────────────────────────────────────────── */
.ct-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 16px;
}
.ct-stat-card {
    background: #fff;
    border: 1px solid #e0e5ed;
    border-radius: 4px;
    padding: 14px 16px;
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.ct-stat-card .sc-label {
    font-size: 11px;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.ct-stat-card .sc-value {
    font-size: 22px;
    font-weight: 700;
    line-height: 1.1;
}
.ct-stat-card.amber  .sc-value { color: #d97706; }
.ct-stat-card.blue   .sc-value { color: #174DA4; }
.ct-stat-card.green  .sc-value { color: #16a34a; }
.ct-stat-card.grey   .sc-value { color: #6b7280; }

/* ── Filter bar ──────────────────────────────────────────── */
.ct-filters {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 12px;
    flex-wrap: wrap;
}
.ct-filters label {
    font-size: 12px;
    color: #444;
    font-weight: 600;
}
.ct-filters select,
.ct-filters input[type="text"] {
    font-size: 12px;
    border: 1px solid #cdd3de;
    padding: 5px 8px;
    border-radius: 0;
    color: #1a1a2e;
    background: #fff;
    height: 30px;
}
.ct-filters .filter-count {
    margin-left: auto;
    font-size: 12px;
    color: #666;
}

/* ── Batch toolbar ───────────────────────────────────────── */
.ct-batch-toolbar {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 10px;
    padding: 8px 10px;
    background: #f0f4fa;
    border: 1px solid #dae0ec;
    border-radius: 4px;
}

/* ── Buttons ─────────────────────────────────────────────── */
.hr-btn {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 6px 14px;
    font-size: 12px;
    font-weight: 600;
    border: none;
    cursor: pointer;
    border-radius: 0;
    line-height: 1.4;
    text-decoration: none;
    transition: background 0.15s;
}
.hr-btn--primary  { background: #05275C; color: #fff; }
.hr-btn--primary:hover  { background: #041d45; color: #fff; }
.hr-btn--success  { background: #16a34a; color: #fff; }
.hr-btn--success:hover  { background: #15803d; color: #fff; }
.hr-btn--amber    { background: #d97706; color: #fff; }
.hr-btn--amber:hover    { background: #b45309; color: #fff; }
.hr-btn--danger   { background: #dc3545; color: #fff; }
.hr-btn--danger:hover   { background: #b91c2c; color: #fff; }
.hr-btn--outline  { background: #fff; color: #05275C; border: 1px solid #05275C; }
.hr-btn--outline:hover  { background: #f0f4fa; }
.hr-btn--sm { padding: 4px 10px; font-size: 11px; }

/* ── Status badges ───────────────────────────────────────── */
.ps-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.02em;
}
.ps-badge--pending   { background: #fef3c7; color: #92400e; }
.ps-badge--processed { background: #dcfce7; color: #14532d; }
.ps-badge--cancelled { background: #f3f4f6; color: #4b5563; }

/* ── Target type badge ───────────────────────────────────── */
.pr-target-badge {
    display: inline-block;
    padding: 2px 7px;
    font-size: 10px;
    font-weight: 600;
    border-radius: 3px;
    text-transform: uppercase;
    letter-spacing: 0.03em;
}
.pr-target-badge--all        { background: #dbeafe; color: #1e3a8a; }
.pr-target-badge--department { background: #f3e8ff; color: #581c87; }
.pr-target-badge--employee   { background: #fce7f3; color: #831843; }

/* ── Action popover ──────────────────────────────────────── */
.cd-action-wrapper {
    position: relative;
    display: inline-block;
}
.cd-action-btn {
    background: #f0f4fa;
    border: 1px solid #cdd3de;
    border-radius: 3px;
    padding: 3px 8px;
    cursor: pointer;
    font-size: 14px;
    color: #444;
    line-height: 1;
}
.cd-action-btn:hover { background: #dce4f0; }
.cd-action-popover {
    display: none;
    position: absolute;
    right: 0;
    top: calc(100% + 3px);
    background: #fff;
    border: 1px solid #cdd3de;
    border-radius: 4px;
    min-width: 170px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.12);
    z-index: 200;
    overflow: hidden;
}
.cd-action-popover.is-open { display: block; }
.cd-action-popover a,
.cd-action-popover button {
    display: flex;
    align-items: center;
    gap: 7px;
    width: 100%;
    padding: 8px 12px;
    font-size: 12px;
    color: #1a1a2e;
    background: none;
    border: none;
    cursor: pointer;
    text-align: left;
    text-decoration: none;
    border-bottom: 1px solid #f0f0f0;
}
.cd-action-popover a:last-child,
.cd-action-popover button:last-child { border-bottom: none; }
.cd-action-popover a:hover,
.cd-action-popover button:hover { background: #f5f7fa; }
.cd-action-popover .pop-danger { color: #dc3545; }
.cd-action-popover .pop-danger:hover { background: #fef5f5; }

/* ── Modal overlay / modal ───────────────────────────────── */
.hr-modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(5,39,92,0.45);
    z-index: 1000;
    align-items: center;
    justify-content: center;
}
.hr-modal {
    background: #fff;
    border-radius: 4px;
    width: 560px;
    max-width: 96vw;
    max-height: 92vh;
    overflow-y: auto;
    box-shadow: 0 8px 32px rgba(0,0,0,0.22);
    display: flex;
    flex-direction: column;
}
.hr-modal--wide { width: 700px; }
.hr-modal-header {
    background: #174DA4;
    color: #fff;
    padding: 14px 18px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-radius: 4px 4px 0 0;
}
.hr-modal-header h4 {
    margin: 0;
    font-size: 14px;
    font-weight: 700;
}
.hr-modal-close {
    background: none;
    border: none;
    color: rgba(255,255,255,0.8);
    font-size: 20px;
    cursor: pointer;
    line-height: 1;
    padding: 0 2px;
}
.hr-modal-close:hover { color: #fff; }
.hr-modal-body {
    padding: 18px;
    flex: 1;
}
.hr-modal-footer {
    padding: 12px 18px;
    border-top: 1px solid #e0e5ed;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
}

/* ── Form fields inside modal ────────────────────────────── */
.hr-form-group {
    margin-bottom: 14px;
}
.hr-form-group label {
    display: block;
    font-size: 12px;
    font-weight: 600;
    color: #333;
    margin-bottom: 4px;
}
.hr-input,
.hr-select,
.hr-textarea {
    width: 100%;
    border: 1px solid #cdd3de;
    padding: 6px 9px;
    font-size: 12px;
    color: #1a1a2e;
    background: #fff;
    border-radius: 0;
    box-sizing: border-box;
}
.hr-input:focus,
.hr-select:focus,
.hr-textarea:focus {
    outline: none;
    border-color: #174DA4;
    box-shadow: 0 0 0 2px rgba(23,77,164,0.12);
}
.hr-textarea { resize: vertical; }
.hr-form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}
.hr-form-hint {
    font-size: 11px;
    color: #888;
    margin-top: 3px;
}

/* ── Payroll details panel ───────────────────────────────── */
.pr-details-panel {
    margin-top: 18px;
    background: #fff;
    border: 1px solid #e0e5ed;
    border-radius: 4px;
    overflow: hidden;
}
.pr-details-header {
    background: #05275C;
    color: #fff;
    padding: 12px 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.pr-details-header h3 {
    margin: 0;
    font-size: 14px;
    font-weight: 700;
}
.pr-details-body {
    padding: 16px;
}
.pr-details-actions {
    display: flex;
    gap: 8px;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 14px;
}

/* ── Summary grid inside details ─────────────────────────── */
.ps-summary-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    margin-bottom: 16px;
}
.ps-detail-card {
    background: #fff;
    border: 1px solid #e0e5ed;
    border-radius: 4px;
    padding: 10px 14px;
    border-top: 3px solid #174DA4;
}
.ps-detail-card.stripe-green  { border-top-color: #16a34a; }
.ps-detail-card.stripe-amber  { border-top-color: #d97706; }
.ps-detail-card.stripe-red    { border-top-color: #dc3545; }
.ps-detail-card.stripe-purple { border-top-color: #7c3aed; }
.ps-detail-card.stripe-grey   { border-top-color: #6b7280; }
.ps-detail-card .dc-label {
    font-size: 10px;
    color: #888;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    margin-bottom: 4px;
}
.ps-detail-card .dc-value {
    font-size: 15px;
    font-weight: 700;
    color: #05275C;
}

/* ── Alert area ──────────────────────────────────────────── */
.ps-alert {
    padding: 10px 14px;
    border-radius: 3px;
    font-size: 12px;
    margin-bottom: 12px;
    border-left: 3px solid;
}
.ps-alert--info    { background: #eff6ff; border-color: #174DA4; color: #1e3a8a; }
.ps-alert--success { background: #f0fdf4; border-color: #16a34a; color: #14532d; }
.ps-alert--danger  { background: #fef5f5; border-color: #dc3545; color: #7f1d1d; }

/* ── Progress / generate state ───────────────────────────── */
.pr-generating {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    color: #174DA4;
    padding: 10px 0;
}
.pr-spinner {
    width: 18px;
    height: 18px;
    border: 2px solid #dbeafe;
    border-top-color: #174DA4;
    border-radius: 50%;
    animation: pr-spin 0.7s linear infinite;
    flex-shrink: 0;
}
@keyframes pr-spin { to { transform: rotate(360deg); } }

/* ── Modal result areas ──────────────────────────────────── */
#addResult,
#processResult {
    margin-top: 10px;
    font-size: 12px;
    min-height: 0;
}

/* ── Grid currency/centre helpers ────────────────────────── */
.col-currency {
    font-weight: 700;
    color: #16a34a;
    text-align: right;
    display: block;
}
.col-centre {
    text-align: center;
    display: block;
}
.col-small {
    font-size: 11px;
    color: #555;
}

/* ── Period display cells ────────────────────────────────── */
.pr-period { font-weight: 600; color: #05275C; }
.pr-period__year { font-size: 11px; color: #888; }

/* ── Target badge short-form aliases (used in code) ─────── */
.pr-target-badge--dept { background: #f3e8ff; color: #581c87; }
.pr-target-badge--emp  { background: #fce7f3; color: #831843; }

/* ── Details grid row status colors ─────────────────────── */
tr.ps-row--approved td { background: #f0fdf4 !important; }
tr.ps-row--rejected td { background: #fef5f5 !important; }

/* ── Responsive ──────────────────────────────────────────── */
@media (max-width: 900px) {
    .ct-stats { grid-template-columns: repeat(2,1fr); }
    .ps-summary-grid { grid-template-columns: repeat(2,1fr); }
}
@media (max-width: 600px) {
    .ct-stats { grid-template-columns: 1fr; }
    .ps-summary-grid { grid-template-columns: 1fr; }
    .hr-form-row { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Hidden postback infrastructure -->
<asp:HiddenField ID="hdnSelectedPayrollID" runat="server" />
<asp:HiddenField ID="hdnGeneratePayrollID" runat="server" />
<asp:HiddenField ID="hdnActionPayrollID"   runat="server" />
<asp:HiddenField ID="hdnActionType"        runat="server" />
<asp:Button ID="btnViewPayroll" runat="server" style="display:none" OnClick="btnViewPayroll_Click" />
<asp:Button ID="btnGenPayroll"  runat="server" style="display:none" OnClick="btnGenPayroll_Click" />
<asp:Button ID="btnDoAction"    runat="server" style="display:none" OnClick="btnDoAction_Click" />

<!-- ── Page header ──────────────────────────────────────── -->
<div class="pr-page-header">
    <div class="ph-left">
        <svg class="ph-icon" viewBox="0 0 38 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="4" y="7" width="30" height="24" rx="2" stroke="#174DA4" stroke-width="1.8" fill="none"/>
            <line x1="4" y1="13" x2="34" y2="13" stroke="#174DA4" stroke-width="1.5"/>
            <line x1="10" y1="19" x2="18" y2="19" stroke="#174DA4" stroke-width="1.4" stroke-linecap="round"/>
            <line x1="10" y1="23" x2="22" y2="23" stroke="#174DA4" stroke-width="1.4" stroke-linecap="round"/>
            <line x1="10" y1="27" x2="16" y2="27" stroke="#174DA4" stroke-width="1.4" stroke-linecap="round"/>
            <circle cx="27" cy="24" r="5.5" fill="#174DA4" fill-opacity="0.12" stroke="#174DA4" stroke-width="1.5"/>
            <line x1="27" y1="21.5" x2="27" y2="26.5" stroke="#174DA4" stroke-width="1.4" stroke-linecap="round"/>
            <line x1="24.5" y1="24" x2="29.5" y2="24" stroke="#174DA4" stroke-width="1.4" stroke-linecap="round"/>
        </svg>
        <div>
            <p class="ph-title">Payroll Management</p>
            <p class="ph-sub">Create and manage monthly payroll runs for all or selected employees</p>
        </div>
    </div>
    <div class="ph-actions">
        <button type="button" class="hr-btn hr-btn--primary" onclick="openCreateModal()">
            <svg width="13" height="13" viewBox="0 0 13 13" fill="none"><line x1="6.5" y1="1" x2="6.5" y2="12" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><line x1="1" y1="6.5" x2="12" y2="6.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
            Create Payroll
        </button>
    </div>
</div>

<!-- ── Stats ────────────────────────────────────────────── -->
<div class="ct-stats">
    <div class="ct-stat-card amber">
        <span class="sc-label">Total Payrolls (Year)</span>
        <span class="sc-value"><asp:Literal ID="litTotalPayrolls" runat="server" Text="0" /></span>
    </div>
    <div class="ct-stat-card blue">
        <span class="sc-label">Total Gross (UGX)</span>
        <span class="sc-value" style="font-size:13px"><asp:Literal ID="litTotalGross" runat="server" Text="0" /></span>
    </div>
    <div class="ct-stat-card green">
        <span class="sc-label">Total Net (UGX)</span>
        <span class="sc-value" style="font-size:13px"><asp:Literal ID="litTotalNet" runat="server" Text="0" /></span>
    </div>
    <div class="ct-stat-card grey">
        <span class="sc-label">Processed This Year</span>
        <span class="sc-value"><asp:Literal ID="litProcessed" runat="server" Text="0" /></span>
    </div>
</div>

<!-- ── Filter bar ───────────────────────────────────────── -->
<div class="ct-filters">
    <label>Year:</label>
    <asp:DropDownList ID="ddlPayrollYear" runat="server" CssClass="hr-select"
        AutoPostBack="true" OnSelectedIndexChanged="ddlPayrollYear_Changed"
        style="width:90px;" />

    <label>Status:</label>
    <asp:DropDownList ID="ddlPayrollStatus" runat="server" CssClass="hr-select"
        AutoPostBack="true" OnSelectedIndexChanged="ddlPayrollStatus_Changed"
        style="width:130px;">
        <asp:ListItem Value="" Text="All Statuses" />
        <asp:ListItem Value="PENDING"   Text="Pending" />
        <asp:ListItem Value="PROCESSED" Text="Processed" />
        <asp:ListItem Value="CANCELLED" Text="Cancelled" />
    </asp:DropDownList>

    <asp:Button ID="btnRefresh" runat="server" Text="Refresh"
        CssClass="hr-btn hr-btn--outline" OnClick="btnRefresh_Click" />

    <span class="filter-count"><asp:Literal ID="litFilterCount" runat="server" /></span>
</div>

<!-- ── Main payrolls grid ────────────────────────────────── -->
<dx:ASPxGridView ID="gvPayrolls" runat="server"
    KeyFieldName="ID"
    EnableCallBacks="false"
    Theme="Glass"
    OnRowDeleting="gvPayrolls_RowDeleting"
    Width="100%">
    <SettingsPager PageSize="20" />
    <Settings ShowFilterRow="false" />
    <Columns>
        <dx:GridViewDataTextColumn FieldName="ID" Visible="false" />

        <dx:GridViewDataTextColumn FieldName="payroll_title" Caption="Payroll Title" Width="200">
            <DataItemTemplate>
                <strong><%# Eval("payroll_title") %></strong>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="period_display" Caption="Period" Width="110">
            <DataItemTemplate>
                <%# GetPeriodHtml(Eval("payroll_month"), Eval("payroll_year")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="target_type" Caption="Target" Width="90">
            <DataItemTemplate>
                <%# GetTargetBadge(Eval("target_type")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="staff_count" Caption="Staff" Width="60">
            <DataItemTemplate>
                <span class="col-centre"><%# Eval("staff_count") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="total_amount" Caption="Total Net (UGX)" Width="130">
            <DataItemTemplate>
                <span class="col-currency"><%# FormatCurrency(Eval("total_amount")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="payroll_status" Caption="Status" Width="100">
            <DataItemTemplate>
                <%# GetStatusBadge(Eval("payroll_status")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="prepared_by" Caption="Prepared By" Width="110">
            <DataItemTemplate>
                <span class="col-small"><%# Eval("prepared_by") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="payroll_date" Caption="Created" Width="80">
            <DataItemTemplate>
                <span class="col-small"><%# FormatDate(Eval("payroll_date")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn Caption="" Width="42">
            <DataItemTemplate>
                <%# GetPayrollActionHtml(Eval("ID"), Eval("payroll_status")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>
    </Columns>
</dx:ASPxGridView>

<!-- ── Payroll details panel ─────────────────────────────── -->
<asp:Panel ID="pnlPayrollDetails" runat="server" Visible="false" CssClass="pr-details-panel">
    <div class="pr-details-header">
        <h3>
            <asp:Literal ID="litPayrollTitle" runat="server" Text="Payroll Details" />
            &nbsp;<asp:Literal ID="litPayrollStatusBadge" runat="server" />
        </h3>
        <asp:Button ID="btnCloseDetails" runat="server" Text="&#x2715; Close"
            CssClass="hr-btn hr-btn--outline hr-btn--sm"
            style="background:rgba(255,255,255,0.15);color:#fff;border-color:rgba(255,255,255,0.4);"
            OnClick="btnCloseDetails_Click" />
    </div>
    <div class="pr-details-body">

        <!-- Alert area -->
        <asp:Literal ID="litAlert" runat="server" />

        <!-- Summary cards -->
        <div class="ps-summary-grid">
            <div class="ps-detail-card">
                <div class="dc-label">Basic Pay</div>
                <div class="dc-value"><asp:Literal ID="litDetBasic" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-green">
                <div class="dc-label">Total Allowances</div>
                <div class="dc-value"><asp:Literal ID="litDetAllowances" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-green">
                <div class="dc-label">Gross Salary</div>
                <div class="dc-value"><asp:Literal ID="litDetGross" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-amber">
                <div class="dc-label">PAYE</div>
                <div class="dc-value"><asp:Literal ID="litDetPAYE" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-amber">
                <div class="dc-label">NSSF</div>
                <div class="dc-value"><asp:Literal ID="litDetNSSF" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-purple">
                <div class="dc-label">Kabaka Contribution</div>
                <div class="dc-value"><asp:Literal ID="litDetKabaka" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-amber">
                <div class="dc-label">Local Tax</div>
                <div class="dc-value"><asp:Literal ID="litDetLocalTax" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-red">
                <div class="dc-label">Other Deductions</div>
                <div class="dc-value"><asp:Literal ID="litDetOtherDed" runat="server" Text="0" /></div>
            </div>
            <div class="ps-detail-card stripe-green">
                <div class="dc-label">Net Salary</div>
                <div class="dc-value"><asp:Literal ID="litDetNet" runat="server" Text="0" /></div>
            </div>
        </div>

        <!-- Action buttons -->
        <div class="pr-details-actions">
            <asp:Button ID="btnApprovePayroll" runat="server" Text="Approve &amp; Lock Payroll"
                CssClass="hr-btn hr-btn--success"
                OnClick="btnApprovePayroll_Click" />
            <asp:Button ID="btnCancelPayroll" runat="server" Text="Cancel Payroll"
                CssClass="hr-btn hr-btn--amber"
                OnClick="btnCancelPayroll_Click" />
            <asp:HyperLink ID="lnkViewPayslips" runat="server"
                CssClass="hr-btn hr-btn--outline"
                Text="View Payslips &rarr;" />
        </div>

        <asp:Literal ID="litUnapprovedInfo" runat="server" />

        <!-- Payroll details grid -->
        <dx:ASPxGridView ID="gvPayrollDetails" runat="server"
            KeyFieldName="ID"
            EnableCallBacks="false"
            Theme="Glass"
            OnRowUpdating="gvPayrollDetails_RowUpdating"
            OnHtmlRowCreated="gvPayrollDetails_HtmlRowCreated"
            Width="100%">
            <SettingsEditing Mode="PopupEditForm" />
            <Columns>
                <dx:GridViewDataTextColumn FieldName="ID"     Visible="false" />
                <dx:GridViewDataTextColumn FieldName="status" Visible="false" />

                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Emp Code" Width="60">
                    <EditFormSettings Visible="false" />
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="160">
                    <EditFormSettings Visible="false" />
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataSpinEditColumn FieldName="basic_pay" Caption="Basic Pay" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataSpinEditColumn FieldName="total_allowances" Caption="Allowances" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataSpinEditColumn FieldName="gross_pay" Caption="Gross Pay" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                    <EditFormSettings Visible="false" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataSpinEditColumn FieldName="paye" Caption="PAYE" Width="80">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataSpinEditColumn FieldName="nssf" Caption="NSSF" Width="75">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataSpinEditColumn FieldName="total_deductions" Caption="Total Ded." Width="85">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                    <EditFormSettings Visible="false" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataSpinEditColumn FieldName="net_pay" Caption="Net Pay" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" />
                </dx:GridViewDataSpinEditColumn>
            </Columns>
            <TotalSummary>
                <dx:ASPxSummaryItem FieldName="basic_pay"        SummaryType="Sum" DisplayFormat="N0" />
                <dx:ASPxSummaryItem FieldName="total_allowances" SummaryType="Sum" DisplayFormat="N0" />
                <dx:ASPxSummaryItem FieldName="gross_pay"        SummaryType="Sum" DisplayFormat="N0" />
                <dx:ASPxSummaryItem FieldName="paye"             SummaryType="Sum" DisplayFormat="N0" />
                <dx:ASPxSummaryItem FieldName="nssf"             SummaryType="Sum" DisplayFormat="N0" />
                <dx:ASPxSummaryItem FieldName="total_deductions" SummaryType="Sum" DisplayFormat="N0" />
                <dx:ASPxSummaryItem FieldName="net_pay"          SummaryType="Sum" DisplayFormat="N0" />
            </TotalSummary>
        </dx:ASPxGridView>

    </div>
</asp:Panel>

<!-- ══════════════════════════════════════════════════════════
     CREATE PAYROLL MODAL
     ══════════════════════════════════════════════════════════ -->
<div class="hr-modal-overlay" id="createPayrollModal">
    <div class="hr-modal">
        <div class="hr-modal-header">
            <h4>Create Payroll Run</h4>
            <button type="button" class="hr-modal-close" onclick="closeCreateModal()">&times;</button>
        </div>
        <div class="hr-modal-body">

            <div class="hr-form-group">
                <label>Payroll Title <span style="color:#dc3545">*</span></label>
                <asp:TextBox ID="txtPayrollTitle" runat="server" CssClass="hr-input"
                    placeholder="e.g. January 2026 Payroll" MaxLength="200" />
                <div class="hr-form-hint">Auto-filled when you pick a month and year</div>
            </div>

            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label>Month <span style="color:#dc3545">*</span></label>
                    <asp:DropDownList ID="ddlPayrollMonth" runat="server" CssClass="hr-select"
                        onchange="autoTitle()">
                        <asp:ListItem Value=""   Text="-- Select Month --" />
                        <asp:ListItem Value="1"  Text="January" />
                        <asp:ListItem Value="2"  Text="February" />
                        <asp:ListItem Value="3"  Text="March" />
                        <asp:ListItem Value="4"  Text="April" />
                        <asp:ListItem Value="5"  Text="May" />
                        <asp:ListItem Value="6"  Text="June" />
                        <asp:ListItem Value="7"  Text="July" />
                        <asp:ListItem Value="8"  Text="August" />
                        <asp:ListItem Value="9"  Text="September" />
                        <asp:ListItem Value="10" Text="October" />
                        <asp:ListItem Value="11" Text="November" />
                        <asp:ListItem Value="12" Text="December" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label>Year <span style="color:#dc3545">*</span></label>
                    <asp:TextBox ID="txtPayrollYear" runat="server" CssClass="hr-input"
                        TextMode="Number" MaxLength="4"
                        onchange="autoTitle()" onkeyup="autoTitle()" />
                </div>
            </div>

            <div class="hr-form-group">
                <label>Target Type <span style="color:#dc3545">*</span></label>
                <asp:DropDownList ID="ddlTargetType" runat="server" CssClass="hr-select"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlTargetType_Changed">
                    <asp:ListItem Value="ALL"        Text="All Active Employees" />
                    <asp:ListItem Value="DEPARTMENT" Text="Specific Departments" />
                    <asp:ListItem Value="EMPLOYEE"   Text="Specific Employees" />
                </asp:DropDownList>
            </div>

            <asp:Panel ID="pnlTargetDept" runat="server" Visible="false" CssClass="hr-form-group">
                <label>Select Departments</label>
                <asp:ListBox ID="lstTargetDepts" runat="server"
                    SelectionMode="Multiple" Height="120"
                    CssClass="hr-input" style="height:120px;" />
                <div class="hr-form-hint">Hold Ctrl to select multiple</div>
            </asp:Panel>

            <asp:Panel ID="pnlTargetEmp" runat="server" Visible="false" CssClass="hr-form-group">
                <label>Select Employees</label>
                <asp:ListBox ID="lstTargetEmps" runat="server"
                    SelectionMode="Multiple" Height="120"
                    CssClass="hr-input" style="height:120px;" />
                <div class="hr-form-hint">Hold Ctrl to select multiple</div>
            </asp:Panel>

            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label>Include Deductions</label>
                    <asp:DropDownList ID="ddlIncludeDeductions" runat="server" CssClass="hr-select">
                        <asp:ListItem Value="YES" Text="YES — Include" />
                        <asp:ListItem Value="NO"  Text="NO — Exclude" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label>Include Allowances</label>
                    <asp:DropDownList ID="ddlIncludeAllowances" runat="server" CssClass="hr-select">
                        <asp:ListItem Value="YES" Text="YES — Include" />
                        <asp:ListItem Value="NO"  Text="NO — Exclude" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="hr-form-group">
                <label>Comments / Notes</label>
                <asp:TextBox ID="txtPayrollComments" runat="server" CssClass="hr-textarea"
                    TextMode="MultiLine" Rows="2"
                    placeholder="Optional notes for this payroll run" />
            </div>

            <div id="addResult"></div>

        </div>
        <div class="hr-modal-footer">
            <button type="button" class="hr-btn hr-btn--outline" onclick="closeCreateModal()">Cancel</button>
            <asp:Button ID="btnCreatePayroll" runat="server"
                Text="Create Payroll"
                CssClass="hr-btn hr-btn--primary"
                OnClick="btnCreatePayroll_Click" />
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════
     PROCESS CONFIRMATION MODAL
     ══════════════════════════════════════════════════════════ -->
<div class="hr-modal-overlay" id="processConfirmModal">
    <div class="hr-modal">
        <div class="hr-modal-header">
            <h4>Generate Payslips</h4>
            <button type="button" class="hr-modal-close" onclick="closeProcessModal()">&times;</button>
        </div>
        <div class="hr-modal-body">

            <asp:Literal ID="litProcessConfirmBody" runat="server" />

            <div id="processResult"></div>

        </div>
        <div class="hr-modal-footer">
            <button type="button" class="hr-btn hr-btn--outline" onclick="closeProcessModal()">Cancel</button>
            <asp:Button ID="btnConfirmProcess" runat="server"
                Text="Confirm &amp; Generate"
                CssClass="hr-btn hr-btn--primary"
                OnClick="btnConfirmProcess_Click" />
        </div>
    </div>
</div>

<!-- ── JavaScript ────────────────────────────────────────── -->
<script type="text/javascript">
// Modal helpers
function openCreateModal(){
    document.getElementById('createPayrollModal').style.display='flex';
    autoTitle();
}
function closeCreateModal(){document.getElementById('createPayrollModal').style.display='none';}
function openProcessModal(id){
    document.getElementById('<%= hdnGeneratePayrollID.ClientID %>').value=id;
    document.getElementById('<%= btnGenPayroll.ClientID %>').click();
}
function closeProcessModal(){document.getElementById('processConfirmModal').style.display='none';}

// Action popovers
function toggleActionPopover(btn,evt){
    evt.stopPropagation();
    var pop=btn.nextElementSibling;
    var isOpen=pop.classList.contains('is-open');
    closeAllPopovers();
    if(!isOpen) pop.classList.add('is-open');
}
function closeAllPopovers(){
    document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){
        p.classList.remove('is-open');
    });
}
document.addEventListener('click',closeAllPopovers);

// View payroll details
function viewPayrollDetails(id){
    document.getElementById('<%= hdnSelectedPayrollID.ClientID %>').value=id;
    document.getElementById('<%= btnViewPayroll.ClientID %>').click();
}

// Payroll actions
function doAction(id, type){
    closeAllPopovers();
    var msg = type==='APPROVE'    ? 'Approve and permanently lock this payroll?'
            : type==='CANCEL'     ? 'Cancel this payroll? This cannot be undone.'
            : type==='DELETE'     ? 'Permanently delete this payroll and all its payslips?'
            : type==='REGENERATE' ? 'Re-generate payslips? Existing unapproved payslips will be deleted.'
            : '';
    if(msg && !confirm(msg)) return;
    document.getElementById('<%= hdnActionPayrollID.ClientID %>').value=id;
    document.getElementById('<%= hdnActionType.ClientID %>').value=type;
    document.getElementById('<%= btnDoAction.ClientID %>').click();
}

// Auto-generate title when month/year changes
function autoTitle(){
    var mn=document.getElementById('<%= ddlPayrollMonth.ClientID %>');
    var yr=document.getElementById('<%= txtPayrollYear.ClientID %>');
    var tt=document.getElementById('<%= txtPayrollTitle.ClientID %>');
    if(!mn||!yr||!tt||tt.value) return;
    var months=['','January','February','March','April','May','June',
                'July','August','September','October','November','December'];
    var m=parseInt(mn.value)||0; var y=yr.value||'';
    if(m&&y) tt.value=months[m]+' '+y+' Payroll';
}

// Close modals on overlay click / Escape
document.querySelectorAll('.hr-modal-overlay').forEach(function(o){
    o.addEventListener('click',function(e){if(e.target===o){o.style.display='none';}});
});
document.addEventListener('keydown',function(e){
    if(e.key==='Escape'){closeCreateModal();closeProcessModal();}
});
</script>

</asp:Content>
