<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRPayslips.aspx.cs"
    Inherits="COOPERP_NewScreens_HRPayslips"
    Title="Payslip Review - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== PAGE HEADER (navy design system) ===== */
.ps-page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 0 12px 0;
    margin-bottom: 16px;
    border-bottom: 2px solid #174DA4;
}
.ps-page-header .ph-left { display: flex; align-items: center; gap: 12px; }
.ps-page-header .ph-icon { flex-shrink: 0; width: 38px; height: 38px; }
.ps-page-header .ph-title { font-size: 17px; font-weight: 700; color: #05275C; line-height: 1.2; margin: 0; }
.ps-page-header .ph-sub { font-size: 12px; color: #666; margin: 2px 0 0 0; }
.ps-page-header .ph-actions { display: flex; gap: 8px; align-items: center; }

/* ===== STATS CARDS ===== */
.ct-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 16px; }
.ct-stat-card {
    background: #fff; border: 1px solid #e0e5ed; border-radius: 4px;
    padding: 14px 16px; display: flex; flex-direction: column; gap: 4px;
}
.ct-stat-card .sc-label { font-size: 11px; color: #666; text-transform: uppercase; letter-spacing: 0.04em; }
.ct-stat-card .sc-value { font-size: 22px; font-weight: 700; line-height: 1.1; }
.ct-stat-card.amber .sc-value { color: #d97706; }
.ct-stat-card.blue  .sc-value { color: #174DA4; }
.ct-stat-card.green .sc-value { color: #16a34a; }
.ct-stat-card.red   .sc-value { color: #dc3545; }

/* ===== FILTER BAR ===== */
.ct-filters {
    display: flex; align-items: center; gap: 10px;
    margin-bottom: 12px; flex-wrap: wrap;
}
.ct-filters label { font-size: 12px; color: #444; font-weight: 600; }
.ct-filters select,
.ct-filters input[type="text"] {
    font-size: 12px; border: 1px solid #cdd3de; padding: 5px 8px;
    border-radius: 0; color: #1a1a2e; background: #fff; height: 30px;
    outline: none; font-family: inherit;
}
.ct-filters select:focus,
.ct-filters input[type="text"]:focus {
    border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.12);
}
.ct-filters .filter-count { margin-left: auto; font-size: 12px; color: #666; }

/* ===== BATCH TOOLBAR ===== */
.ct-batch-toolbar {
    display: none; align-items: center; gap: 8px; margin-bottom: 10px;
    padding: 8px 10px; background: #f0f4fa; border: 1px solid #dae0ec; border-radius: 4px;
}
.ct-batch-info { font-size: 12px; color: #05275C; font-weight: 600; }
.ct-batch-sep { width: 1px; height: 20px; background: #174DA4; opacity: 0.2; }

/* ===== BUTTONS ===== */
.hr-btn {
    display: inline-flex; align-items: center; gap: 5px; padding: 6px 14px;
    font-size: 12px; font-weight: 600; border: none; cursor: pointer;
    border-radius: 0; line-height: 1.4; text-decoration: none;
    transition: background 0.15s; font-family: inherit; white-space: nowrap;
}
.hr-btn--primary { background: #05275C; color: #fff; }
.hr-btn--primary:hover { background: #041d45; }
.hr-btn--success { background: #16a34a; color: #fff; }
.hr-btn--success:hover { background: #15803d; }
.hr-btn--danger { background: #dc3545; color: #fff; }
.hr-btn--danger:hover { background: #b91c2c; }
.hr-btn--outline { background: #fff; color: #05275C; border: 1px solid #cdd3de; }
.hr-btn--outline:hover { background: #f0f4fa; }
.hr-btn--sm { padding: 4px 10px; font-size: 11px; }

/* ===== ALERT ===== */
.hr-alert {
    padding: 10px 14px;
    border-radius: 4px;
    font-size: 12px;
    margin-bottom: 12px;
    border-left: 3px solid transparent;
}
.hr-alert--success { background: #d4edda; border-color: #28a745; color: #155724; }
.hr-alert--warning { background: #fff3cd; border-color: #ffc107; color: #856404; }
.hr-alert--danger  { background: #f8d7da; border-color: #dc3545; color: #721c24; }
.hr-alert--info    { background: #d1ecf1; border-color: #17a2b8; color: #0c5460; }

/* ===== STATUS BADGES ===== */
.slip-badge {
    display: inline-block;
    font-size: 9px;
    font-weight: 700;
    padding: 2px 7px;
    border-radius: 10px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    white-space: nowrap;
}
.slip-badge--pending  { background: #fef3c7; color: #92400e; }
.slip-badge--approved { background: #dcfce7; color: #14532d; }
.slip-badge--rejected { background: #f8d7da; color: #721c24; }

/* ===== GRID ROW COLORS ===== */
.pr-row-settled td   { background: #f8fdf9 !important; }
.pr-row-cancelled td { background: #fef8f8 !important; }
.pr-row-pending td   { background: #fffdf5 !important; }

/* ===== ACTION POPOVER (position:fixed to avoid table row clipping) ===== */
.cd-action-wrapper { position: relative; display: inline-block; }
.cd-action-btn {
    background: #f0f4fa; border: 1px solid #cdd3de; border-radius: 3px;
    padding: 3px 8px; cursor: pointer; font-size: 14px; color: #444; line-height: 1;
}
.cd-action-btn:hover { background: #dce4f0; }
.cd-action-popover {
    position: fixed !important; z-index: 99999 !important; display: none !important;
    background: #fff !important; border: 1px solid #e0e5ed !important;
    border-radius: 6px !important; box-shadow: 0 8px 28px rgba(0,0,0,0.15) !important;
    min-width: 180px !important; right: auto !important; top: auto !important;
    bottom: auto !important; left: auto !important; margin: 0 !important; padding: 4px 0 !important;
}
.cd-action-popover.is-open { display: block !important; }
.cd-action-popover__item {
    display: flex; align-items: center; gap: 7px; width: 100%; padding: 8px 14px;
    font-size: 12px; color: #1a1a2e; background: none; border: none; cursor: pointer;
    text-align: left; font-family: inherit; white-space: nowrap; border-bottom: 1px solid #f0f0f0;
}
.cd-action-popover__item:last-child { border-bottom: none; }
.cd-action-popover__item:hover { background: #f5f7fa; }
.cd-action-popover__item--success { color: #16a34a; }
.cd-action-popover__item--danger  { color: #dc3545; }
.cd-action-popover__divider { height: 1px; background: #f0f0f0; margin: 2px 0; }
.cd-action-popover__item svg { width: 13px; height: 13px; flex-shrink: 0; }

/* ===== MODALS ===== */
.hr-modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(5,39,92,0.45);
    z-index: 10000;
    align-items: center;
    justify-content: center;
}
.hr-modal {
    background: #fff;
    border-radius: 4px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.22);
    width: 96%;
    max-width: 680px;
    max-height: 88vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}
.hr-modal--lg { max-width: 820px; }
.hr-modal__header {
    padding: 14px 18px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #e0e5ed;
}
.hr-modal__header--primary { background: #05275C; color: #fff; }
.hr-modal__header--danger  { background: #dc3545; color: #fff; }
.hr-modal__title { font-size: 14px; font-weight: 700; margin: 0; }
.hr-modal__close {
    background: none;
    border: none;
    font-size: 18px;
    cursor: pointer;
    color: inherit;
    opacity: 0.8;
    line-height: 1;
    padding: 0 2px;
}
.hr-modal__close:hover { opacity: 1; }
.hr-modal__body {
    padding: 18px;
    overflow-y: auto;
    flex: 1;
}
.hr-modal__footer {
    padding: 12px 18px;
    border-top: 1px solid #e0e5ed;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    background: #f9fafc;
}
.hr-textarea {
    width: 100%;
    border: 1px solid #dde3ee;
    border-radius: 0;
    padding: 8px 10px;
    font-size: 12px;
    font-family: inherit;
    color: #1a1a2e;
    resize: vertical;
    outline: none;
    box-sizing: border-box;
}
.hr-textarea:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }

/* ===== PAYSLIP PRINT ===== */
.payslip-print {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 12px;
    color: #1a1a2e;
}
.payslip-print__header {
    text-align: center;
    border-bottom: 2px solid #174DA4;
    padding-bottom: 12px;
    margin-bottom: 14px;
}
.payslip-print__header h2 {
    font-size: 16px;
    font-weight: 700;
    color: #05275C;
    margin: 0 0 3px 0;
}
.payslip-print__header h3 {
    font-size: 13px;
    font-weight: 600;
    color: #174DA4;
    margin: 0 0 10px 0;
    letter-spacing: 0.06em;
    text-transform: uppercase;
}
.payslip-emp-info {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 3px 20px;
    text-align: left;
    font-size: 11px;
    max-width: 500px;
    margin: 0 auto;
}
.payslip-emp-info div { color: #444; }
.payslip-emp-info strong { color: #1a1a2e; }
.payslip-print__table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
}
.payslip-print__table thead th {
    background: #f0f4fa;
    color: #05275C;
    font-weight: 700;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 6px 10px;
    border: 1px solid #dae0ec;
}
.payslip-print__table thead th.right { text-align: right; }
.payslip-print__table td {
    padding: 5px 10px;
    border-bottom: 1px solid #f0f0f0;
    color: #333;
}
.payslip-print__table td.right { text-align: right; font-variant-numeric: tabular-nums; }
.payslip-print__table tr.subtotal td {
    background: #f8f9fa;
    border-top: 1px solid #dee2e6;
    border-bottom: 2px solid #dee2e6;
    font-weight: 700;
    color: #1a1a2e;
}
.payslip-print__net {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #05275C;
    color: #fff;
    padding: 12px 16px;
    margin-top: 14px;
    border-radius: 0;
    font-size: 14px;
}
.payslip-print__net span { font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; }
.payslip-print__net strong { font-size: 17px; font-variant-numeric: tabular-nums; }
.payslip-print__footer {
    margin-top: 12px;
    font-size: 11px;
    color: #888;
    padding-top: 8px;
    border-top: 1px solid #eee;
    text-align: center;
}

/* ===== DEVEXPRESS OVERRIDES (Glass) ===== */
.dxgvHeader_Glass td {
    background: #05275C !important;
    color: #fff !important;
    font-size: 10px !important;
    font-weight: 700 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.04em !important;
    border-right: 1px solid #0d3a7a !important;
}
.dxgvDataRow_Glass td,
.dxgvFocusedRow_Glass td {
    font-size: 11px;
    border-bottom: 1px solid #f0f0f0 !important;
    vertical-align: middle;
    padding: 6px 8px !important;
}
.dxgvFocusedRow_Glass td { background: #eaf4ff !important; }
.dxgvFooter_Glass td {
    background: #f8f9fa !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    color: #1a1a2e !important;
    border-top: 2px solid #dee2e6 !important;
}
table.dxgvTable_Glass { border-collapse: collapse; width: 100%; }

/* ===== RESPONSIVE ===== */
@media (max-width: 900px) {
    .ct-stats { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 600px) {
    .ct-stats { grid-template-columns: 1fr; }
    .ps-page-header { flex-direction: column; align-items: flex-start; gap: 10px; }
    .ct-filters { flex-direction: column; align-items: stretch; }
}

@media print {
    .ps-page-header, .ct-stats, .ct-filters, .ct-batch-toolbar,
    .dxgvTable_Glass, .hr-modal__header, .hr-modal__footer,
    #batchToolbar { display: none !important; }
    .hr-modal-overlay { position: static !important; background: none !important; display: block !important; }
    .hr-modal { box-shadow: none !important; max-height: none !important; }
    .hr-modal__body { overflow: visible !important; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <%-- Hidden batch/action controls --%>
    <asp:HiddenField ID="hdnBatchIDs" runat="server" />
    <asp:HiddenField ID="hdnBatchAction" runat="server" />
    <asp:HiddenField ID="hdnSlipActionID" runat="server" />
    <asp:HiddenField ID="hdnSlipActionType" runat="server" />
    <asp:HiddenField ID="hdnViewSlipID" runat="server" />
    <asp:Button ID="btnBatchExecute" runat="server" style="display:none" OnClick="btnBatchExecute_Click" />
    <asp:Button ID="btnExecuteSlipAction" runat="server" style="display:none" OnClick="btnExecuteSlipAction_Click" />
    <asp:Button ID="btnLoadSlipDetail" runat="server" style="display:none" OnClick="btnLoadSlipDetail_Click" />

    <%-- Page Header --%>
    <div class="ps-page-header">
        <div class="ph-left">
            <svg class="ph-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="#174DA4" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <div>
                <p class="ph-title">Employee Payslips</p>
                <p class="ph-sub">View and manage individual payslips</p>
            </div>
        </div>
        <div class="ph-actions">
            <a href="HRPayroll.aspx" class="hr-btn hr-btn--outline hr-btn--sm">&#8592; Back to Payroll</a>
        </div>
    </div>

    <%-- Alert area --%>
    <asp:Literal ID="litPageAlert" runat="server" />

    <%-- Stats Row --%>
    <div class="ct-stats">
        <div class="ct-stat-card amber">
            <div class="sc-label">Total Payslips</div>
            <div class="sc-value"><asp:Literal ID="litTotalPayslips" runat="server" Text="0" /></div>
        </div>
        <div class="ct-stat-card blue">
            <div class="sc-label">Pending Review</div>
            <div class="sc-value"><asp:Literal ID="litPendingCount" runat="server" Text="0" /></div>
        </div>
        <div class="ct-stat-card green">
            <div class="sc-label">Approved</div>
            <div class="sc-value"><asp:Literal ID="litApprovedCount" runat="server" Text="0" /></div>
        </div>
        <div class="ct-stat-card red">
            <div class="sc-label">Rejected</div>
            <div class="sc-value"><asp:Literal ID="litRejectedCount" runat="server" Text="0" /></div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <div class="ct-filters">
        <asp:TextBox ID="txtSearch" runat="server" placeholder="Search employee..." style="min-width:180px;" />
        <asp:Button ID="btnSearch" runat="server" Text="Go" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnSearch_Click" />

        <label>Payroll:</label>
        <asp:DropDownList ID="ddlFilterPayroll" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:140px;" />

        <label>Status:</label>
        <asp:DropDownList ID="ddlFilterStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:100px;">
            <asp:ListItem Value="">All</asp:ListItem>
            <asp:ListItem Value="PENDING">Pending</asp:ListItem>
            <asp:ListItem Value="APPROVED">Approved</asp:ListItem>
            <asp:ListItem Value="REJECTED">Rejected</asp:ListItem>
        </asp:DropDownList>

        <label>Month:</label>
        <asp:DropDownList ID="ddlFilterMonth" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:100px;">
            <asp:ListItem Value="">All</asp:ListItem>
            <asp:ListItem Value="JANUARY">Jan</asp:ListItem>
            <asp:ListItem Value="FEBRUARY">Feb</asp:ListItem>
            <asp:ListItem Value="MARCH">Mar</asp:ListItem>
            <asp:ListItem Value="APRIL">Apr</asp:ListItem>
            <asp:ListItem Value="MAY">May</asp:ListItem>
            <asp:ListItem Value="JUNE">Jun</asp:ListItem>
            <asp:ListItem Value="JULY">Jul</asp:ListItem>
            <asp:ListItem Value="AUGUST">Aug</asp:ListItem>
            <asp:ListItem Value="SEPTEMBER">Sep</asp:ListItem>
            <asp:ListItem Value="OCTOBER">Oct</asp:ListItem>
            <asp:ListItem Value="NOVEMBER">Nov</asp:ListItem>
            <asp:ListItem Value="DECEMBER">Dec</asp:ListItem>
        </asp:DropDownList>

        <label>Year:</label>
        <asp:TextBox ID="txtFilterYear" runat="server" style="width:55px;" MaxLength="4" />

        <label>Employee:</label>
        <asp:DropDownList ID="ddlFilterEmployee" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:140px;" />

        <label>Show:</label>
        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="width:55px;">
            <asp:ListItem Value="25">25</asp:ListItem>
            <asp:ListItem Value="50">50</asp:ListItem>
            <asp:ListItem Value="100">100</asp:ListItem>
        </asp:DropDownList>

        <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="hr-btn hr-btn--outline hr-btn--sm" OnClick="btnReset_Click" />
        <span class="filter-count"><asp:Literal ID="litFilterCount" runat="server" Text="0" /> records</span>
    </div>

    <%-- Batch Toolbar --%>
    <div class="ct-batch-toolbar" id="batchToolbar">
        <div class="ct-batch-info"><strong id="batchCount">0</strong> selected</div>
        <div class="ct-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--success hr-btn--sm" onclick="doBatchApprove()">
            &#10003; Approve Selected
        </button>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="openBatchRejectModal()">
            Reject Selected
        </button>
        <div class="ct-batch-sep"></div>
        <button type="button" class="hr-btn hr-btn--outline hr-btn--sm" onclick="clearBatchSelection()">Clear</button>
    </div>

    <%-- Main Grid --%>
    <dx:ASPxGridView ID="gvPayslips" runat="server" Width="100%" ClientInstanceName="gvPayslips"
        KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
        OnHtmlRowCreated="gvPayslips_HtmlRowCreated">
        <SettingsPager PageSize="25" />
        <Settings ShowFilterRow="False" HorizontalScrollBarMode="Hidden" />
        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="False" />
        <TotalSummary>
            <dx:ASPxSummaryItem FieldName="basic_pay" SummaryType="Sum" DisplayFormat="UGX {0:N0}" />
            <dx:ASPxSummaryItem FieldName="total_allowances" SummaryType="Sum" DisplayFormat="UGX {0:N0}" />
            <dx:ASPxSummaryItem FieldName="total_deductions" SummaryType="Sum" DisplayFormat="UGX {0:N0}" />
            <dx:ASPxSummaryItem FieldName="net_salary" SummaryType="Sum" DisplayFormat="UGX {0:N0}" />
        </TotalSummary>
        <Columns>
            <%-- Checkbox column --%>
            <dx:GridViewDataTextColumn Caption="" Width="34" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                <HeaderTemplate>
                    <input type="checkbox" id="chkSelectAll" onclick="toggleSelectAll(this)"
                           style="cursor:pointer;accent-color:#174DA4;width:14px;height:14px;" />
                </HeaderTemplate>
                <DataItemTemplate>
                    <input type="checkbox" class="ct-row-check" value="<%# Eval("ID") %>" onchange="updateBatchToolbar()" />
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="ID" Visible="false" />
            <dx:GridViewDataTextColumn FieldName="empID" Visible="false" />

            <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff #" Width="68">
                <DataItemTemplate>
                    <span style="font-size:10px;font-weight:700;color:#174DA4;font-family:monospace;"><%# Eval("EMP_CODE") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="180">
                <DataItemTemplate>
                    <span style="font-weight:600;color:#1a1a2e;font-size:11px;"><%# Eval("emp_name") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="payroll_month_name" Caption="Period" Width="95">
                <DataItemTemplate>
                    <span style="font-size:11px;font-weight:600;"><%# Eval("payroll_month_name") %> <%# Eval("payroll_year") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="basic_pay" Caption="Basic Pay" Width="100">
                <DataItemTemplate>
                    <span style="font-size:11px;"><%# FormatCurrency(Eval("basic_pay")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="total_allowances" Caption="Allowances" Width="100">
                <DataItemTemplate>
                    <span style="font-size:11px;color:#28a745;"><%# FormatCurrency(Eval("total_allowances")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="total_deductions" Caption="Deductions" Width="100">
                <DataItemTemplate>
                    <span style="font-size:11px;color:#dc3545;"><%# FormatCurrency(Eval("total_deductions")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="net_salary" Caption="Net Pay (UGX)" Width="115">
                <DataItemTemplate>
                    <span style="font-size:12px;font-weight:700;color:#174DA4;"><%# FormatCurrency(Eval("net_salary")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="status" Caption="Status" Width="100">
                <DataItemTemplate>
                    <%# GetPayslipStatusBadge(Eval("status")) %>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="date_generated" Caption="Generated" Width="80">
                <DataItemTemplate>
                    <span style="font-size:10px;color:#888;"><%# FormatDate(Eval("date_generated")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <%-- Actions column --%>
            <dx:GridViewDataTextColumn Caption="" Width="42" Settings-AllowAutoFilter="False" Settings-AllowSort="False">
                <DataItemTemplate>
                    <%# GetPayslipActionHtml(Eval("ID"), Eval("status")) %>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
    </dx:ASPxGridView>

    <%-- ===== Payslip Detail View Modal ===== --%>
    <div class="hr-modal-overlay" id="slipDetailModal">
        <div class="hr-modal hr-modal--lg">
            <div class="hr-modal__header hr-modal__header--primary">
                <h4 class="hr-modal__title">Payslip Details</h4>
                <button type="button" class="hr-modal__close" onclick="document.getElementById('slipDetailModal').style.display='none';">&times;</button>
            </div>
            <div class="hr-modal__body">
                <asp:Panel ID="pnlSlipDetail" runat="server">
                    <asp:Literal ID="litSlipDetailHtml" runat="server" />
                </asp:Panel>
            </div>
            <div class="hr-modal__footer">
                <button type="button" class="hr-btn hr-btn--outline hr-btn--sm" onclick="document.getElementById('slipDetailModal').style.display='none';">Close</button>
                <button type="button" class="hr-btn hr-btn--success hr-btn--sm" onclick="window.print()">Print</button>
            </div>
        </div>
    </div>

    <%-- ===== Reject Reason Modal ===== --%>
    <div class="hr-modal-overlay" id="rejectReasonModal">
        <div class="hr-modal">
            <div class="hr-modal__header hr-modal__header--danger">
                <h4 class="hr-modal__title">Reject Payslip &mdash; Provide Reason</h4>
                <button type="button" class="hr-modal__close" onclick="closeRejectModal();">&times;</button>
            </div>
            <div class="hr-modal__body">
                <p style="font-size:12px;color:#555;margin:0 0 10px 0;">Please provide a reason for rejecting this payslip. The reason will be recorded for audit purposes.</p>
                <asp:TextBox ID="txtRejectReason" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="3" placeholder="Enter reason for rejection..." />
            </div>
            <div class="hr-modal__footer">
                <button type="button" class="hr-btn hr-btn--outline hr-btn--sm" onclick="closeRejectModal();">Cancel</button>
                <asp:Button ID="btnConfirmReject" runat="server" Text="Confirm Rejection" CssClass="hr-btn hr-btn--danger hr-btn--sm" OnClick="btnConfirmReject_Click" />
            </div>
        </div>
    </div>

    <%-- ===== Batch Reject Modal ===== --%>
    <div class="hr-modal-overlay" id="batchRejectModal">
        <div class="hr-modal">
            <div class="hr-modal__header hr-modal__header--danger">
                <h4 class="hr-modal__title">Reject Selected Payslips</h4>
                <button type="button" class="hr-modal__close" onclick="closeBatchRejectModal();">&times;</button>
            </div>
            <div class="hr-modal__body">
                <p style="font-size:12px;color:#555;margin:0 0 10px 0;">You are about to reject the selected payslips. Please provide a reason that will apply to all selected payslips.</p>
                <asp:TextBox ID="txtBatchRejectReason" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="2" placeholder="Reason for rejection..." />
            </div>
            <div class="hr-modal__footer">
                <button type="button" class="hr-btn hr-btn--outline hr-btn--sm" onclick="closeBatchRejectModal();">Cancel</button>
                <asp:Button ID="btnConfirmBatchReject" runat="server" Text="Confirm Batch Rejection" CssClass="hr-btn hr-btn--danger hr-btn--sm" OnClick="btnConfirmBatchReject_Click" />
            </div>
        </div>
    </div>

    <%-- ===== JavaScript ===== --%>
    <script type="text/javascript">
        var MONTHS_ARR = ['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];

        // Action popovers (position:fixed to float above table rows)
        function toggleActionPopover(btn, evt) {
            evt.stopPropagation();
            var pop = btn.nextElementSibling;
            var isOpen = pop.classList.contains('is-open');
            closeAllPopovers();
            if (!isOpen) {
                pop.classList.add('is-open');
                var rect = btn.getBoundingClientRect();
                var popH = pop.offsetHeight || 200;
                var spaceBelow = window.innerHeight - rect.bottom;
                if (spaceBelow < popH + 8) {
                    pop.style.top = (rect.top - popH - 4) + 'px';
                } else {
                    pop.style.top = (rect.bottom + 4) + 'px';
                }
                var popW = pop.offsetWidth || 180;
                var leftPos = rect.right - popW;
                if (leftPos < 8) leftPos = 8;
                pop.style.left = leftPos + 'px';
            }
        }
        function closeAllPopovers() {
            document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p) {
                p.classList.remove('is-open');
                p.style.top = '';
                p.style.left = '';
            });
        }
        document.addEventListener('click', closeAllPopovers);
        window.addEventListener('scroll', closeAllPopovers, true);

        // Batch toolbar
        function updateBatchToolbar() {
            var checked = document.querySelectorAll('.ct-row-check:checked');
            var all = document.querySelectorAll('.ct-row-check');
            var tb = document.getElementById('batchToolbar');
            var cnt = document.getElementById('batchCount');
            if (checked.length > 0) { tb.style.display = 'flex'; cnt.textContent = checked.length; }
            else tb.style.display = 'none';
            var chk = document.getElementById('chkSelectAll');
            if (chk) {
                chk.indeterminate = (checked.length > 0 && checked.length < all.length);
                chk.checked = all.length > 0 && checked.length === all.length;
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

        // Single approve / reject
        function approveSlip(id) {
            closeAllPopovers();
            if (!confirm('Approve this payslip?')) return;
            document.getElementById('<%= hdnSlipActionID.ClientID %>').value = id;
            document.getElementById('<%= hdnSlipActionType.ClientID %>').value = 'APPROVE';
            document.getElementById('<%= btnExecuteSlipAction.ClientID %>').click();
        }
        function openRejectModal(id) {
            closeAllPopovers();
            document.getElementById('<%= hdnSlipActionID.ClientID %>').value = id;
            document.getElementById('<%= hdnSlipActionType.ClientID %>').value = 'REJECT';
            document.getElementById('rejectReasonModal').style.display = 'flex';
        }
        function closeRejectModal() {
            document.getElementById('rejectReasonModal').style.display = 'none';
        }
        function viewSlip(id) {
            closeAllPopovers();
            document.getElementById('<%= hdnViewSlipID.ClientID %>').value = id;
            document.getElementById('<%= btnLoadSlipDetail.ClientID %>').click();
        }

        // Batch actions
        function doBatchApprove() {
            var n = document.querySelectorAll('.ct-row-check:checked').length;
            if (!n || !confirm('Approve ' + n + ' payslip(s)?')) return;
            document.getElementById('<%= hdnBatchIDs.ClientID %>').value = getBatchIDs();
            document.getElementById('<%= hdnBatchAction.ClientID %>').value = 'APPROVE';
            document.getElementById('<%= btnBatchExecute.ClientID %>').click();
        }
        function openBatchRejectModal() {
            var n = document.querySelectorAll('.ct-row-check:checked').length;
            if (!n) { alert('No payslips selected.'); return; }
            document.getElementById('batchRejectModal').style.display = 'flex';
        }
        function closeBatchRejectModal() {
            document.getElementById('batchRejectModal').style.display = 'none';
        }

        // Modal overlay close on outside click
        document.querySelectorAll('.hr-modal-overlay').forEach(function(o) {
            o.addEventListener('click', function(e) { if (e.target === o) o.style.display = 'none'; });
        });
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') { closeRejectModal(); closeBatchRejectModal(); }
        });

        // Search on Enter
        (function() {
            var sb = document.getElementById('<%= txtSearch.ClientID %>');
            if (sb) sb.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') { e.preventDefault(); document.getElementById('<%= btnSearch.ClientID %>').click(); }
            });
            var yr = document.getElementById('<%= txtFilterYear.ClientID %>');
            if (yr) yr.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') { e.preventDefault(); document.getElementById('<%= btnSearch.ClientID %>').click(); }
            });
        })();
    </script>

</asp:Content>
