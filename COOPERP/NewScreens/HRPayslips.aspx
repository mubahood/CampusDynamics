<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRPayslips.aspx.cs"
    Inherits="COOPERP_NewScreens_HRPayslips"
    Title="Payslip Review - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== PAGE HEADER ===== */
.pr-page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 18px 22px;
    background: #fff;
    border-bottom: 2px solid #28a745;
    margin-bottom: 18px;
    border-radius: 4px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.07);
}
.pr-page-header__left {
    display: flex;
    align-items: center;
    gap: 12px;
}
.pr-page-header__icon {
    width: 40px;
    height: 40px;
    background: #f0fff4;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.pr-page-header__icon svg {
    width: 22px;
    height: 22px;
    color: #28a745;
}
.pr-page-header__title {
    font-size: 17px;
    font-weight: 700;
    color: #1a1a2e;
    margin: 0 0 2px 0;
    line-height: 1.2;
}
.pr-page-header__sub {
    font-size: 11px;
    color: #666;
    margin: 0;
}

/* ===== STATS CARDS ===== */
.ct-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 16px;
}
.ct-stat-card {
    background: #fff;
    border-radius: 4px;
    padding: 14px 16px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.07);
    border-left: 3px solid #e0e5ed;
}
.ct-stat-card--amber  { border-left-color: #fd7e14; }
.ct-stat-card--pending { border-left-color: #ffc107; }
.ct-stat-card--green  { border-left-color: #28a745; }
.ct-stat-card--red    { border-left-color: #dc3545; }
.ct-stat-card__value {
    font-size: 22px;
    font-weight: 700;
    color: #1a1a2e;
    line-height: 1;
    margin-bottom: 4px;
}
.ct-stat-card--amber  .ct-stat-card__value { color: #fd7e14; }
.ct-stat-card--pending .ct-stat-card__value { color: #e0a800; }
.ct-stat-card--green  .ct-stat-card__value { color: #28a745; }
.ct-stat-card--red    .ct-stat-card__value { color: #dc3545; }
.ct-stat-card__label {
    font-size: 10px;
    color: #888;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}

/* ===== FILTERS ===== */
.ct-filters {
    background: #fff;
    border: 1px solid #e0e5ed;
    border-radius: 4px;
    padding: 12px 14px;
    margin-bottom: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
.ct-filters__row {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}
.ct-filters__row + .ct-filters__row {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px solid #f0f0f0;
}
.ct-filters__label {
    font-size: 10px;
    color: #888;
    white-space: nowrap;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.ct-filters input[type="text"],
.ct-filters select {
    height: 30px;
    border: 1px solid #dde3ee;
    border-radius: 0;
    font-size: 12px;
    padding: 0 8px;
    color: #1a1a2e;
    background: #fff;
    outline: none;
    font-family: inherit;
}
.ct-filters input[type="text"]:focus,
.ct-filters select:focus {
    border-color: #28a745;
    box-shadow: 0 0 0 2px rgba(40,167,69,0.12);
}
.ct-filters__search {
    flex: 1;
    min-width: 160px;
    max-width: 260px;
}
.ct-filter-count-top {
    margin-left: auto;
    font-size: 11px;
    color: #888;
    white-space: nowrap;
}

/* ===== COUNT BAR ===== */
.pr-count-bar {
    font-size: 11px;
    color: #666;
    margin-bottom: 6px;
    padding: 0 2px;
}

/* ===== BATCH TOOLBAR ===== */
.ct-batch-toolbar {
    display: none;
    align-items: center;
    gap: 8px;
    background: #f0fff4;
    border: 1px solid #28a745;
    border-radius: 4px;
    padding: 8px 12px;
    margin-bottom: 10px;
    flex-wrap: wrap;
}
.ct-batch-info {
    font-size: 12px;
    color: #155724;
    font-weight: 600;
}
.ct-batch-sep {
    width: 1px;
    height: 20px;
    background: #28a745;
    opacity: 0.3;
}

/* ===== BUTTONS ===== */
.hr-btn {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 6px 14px;
    font-size: 12px;
    font-family: inherit;
    font-weight: 600;
    border: 1px solid transparent;
    border-radius: 0;
    cursor: pointer;
    white-space: nowrap;
    text-decoration: none;
    line-height: 1.4;
    transition: background 0.15s, border-color 0.15s, color 0.15s;
}
.hr-btn--success {
    background: #28a745;
    border-color: #28a745;
    color: #fff;
}
.hr-btn--success:hover { background: #218838; border-color: #218838; }
.hr-btn--danger {
    background: #dc3545;
    border-color: #dc3545;
    color: #fff;
}
.hr-btn--danger:hover { background: #c82333; border-color: #c82333; }
.hr-btn--ghost {
    background: #fff;
    border-color: #dde3ee;
    color: #555;
}
.hr-btn--ghost:hover { background: #f5f7fa; border-color: #aaa; }
.hr-btn--sm { padding: 4px 10px; font-size: 11px; }
.hr-btn--ghost--sm { padding: 4px 10px; font-size: 11px; background: #fff; border: 1px solid #dde3ee; color: #555; border-radius: 0; cursor: pointer; font-family: inherit; font-weight: 600; white-space: nowrap; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
.hr-btn--ghost--sm:hover { background: #f5f7fa; border-color: #aaa; }
.hr-btn--success--sm { padding: 4px 10px; font-size: 11px; background: #28a745; border: 1px solid #28a745; color: #fff; border-radius: 0; cursor: pointer; font-family: inherit; font-weight: 600; white-space: nowrap; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
.hr-btn--success--sm:hover { background: #218838; border-color: #218838; }
.hr-btn--danger--sm { padding: 4px 10px; font-size: 11px; background: #dc3545; border: 1px solid #dc3545; color: #fff; border-radius: 0; cursor: pointer; font-family: inherit; font-weight: 600; white-space: nowrap; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
.hr-btn--danger--sm:hover { background: #c82333; border-color: #c82333; }

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
.slip-badge--pending  { background: #fff3cd; color: #856404; border: 1px solid #ffc107; }
.slip-badge--approved { background: #d4edda; color: #155724; border: 1px solid #28a745; }
.slip-badge--rejected { background: #f8d7da; color: #721c24; border: 1px solid #dc3545; }

/* ===== GRID ROW COLORS ===== */
.pr-row-settled td { background: #f0fff4 !important; }
.pr-row-cancelled td { background: #fff5f5 !important; }
.pr-row-pending td { background: #fffdf0 !important; }

/* ===== ACTION POPOVER ===== */
.cd-action-wrapper {
    position: relative;
    display: inline-block;
}
.cd-action-btn {
    background: #f5f7fa;
    border: 1px solid #dde3ee;
    border-radius: 0;
    padding: 3px 8px;
    cursor: pointer;
    font-size: 14px;
    line-height: 1;
    color: #444;
    font-family: inherit;
}
.cd-action-btn:hover { background: #e8ecf4; }
.cd-action-popover {
    display: none;
    position: absolute;
    right: 0;
    top: 100%;
    background: #fff;
    border: 1px solid #dde3ee;
    border-radius: 4px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.13);
    min-width: 160px;
    z-index: 9999;
    padding: 4px 0;
}
.cd-action-popover.is-open { display: block; }
.cd-action-popover__item {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 7px 13px;
    font-size: 12px;
    color: #333;
    cursor: pointer;
    white-space: nowrap;
    background: none;
    border: none;
    width: 100%;
    text-align: left;
    font-family: inherit;
}
.cd-action-popover__item:hover { background: #f5f7fa; }
.cd-action-popover__item--success { color: #28a745; }
.cd-action-popover__item--danger  { color: #dc3545; }
.cd-action-popover__divider { height: 1px; background: #f0f0f0; margin: 3px 0; }
.cd-action-popover__item svg { width: 13px; height: 13px; flex-shrink: 0; }

/* ===== MODALS ===== */
.hr-modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
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
.hr-modal__header--success { background: #28a745; color: #fff; }
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
.hr-textarea:focus { border-color: #28a745; box-shadow: 0 0 0 2px rgba(40,167,69,0.12); }

/* ===== PAYSLIP PRINT ===== */
.payslip-print {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 12px;
    color: #1a1a2e;
}
.payslip-print__header {
    text-align: center;
    border-bottom: 2px solid #28a745;
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
    color: #28a745;
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
    background: #f0fff4;
    color: #155724;
    font-weight: 700;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 6px 10px;
    border: 1px solid #c3e6cb;
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
    background: #28a745;
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
    .pr-page-header { flex-direction: column; align-items: flex-start; gap: 10px; }
    .ct-filters__row { flex-direction: column; align-items: flex-start; }
    .ct-filters__search { max-width: 100%; width: 100%; }
}

@media print {
    .pr-page-header, .ct-stats, .ct-filters, .pr-count-bar, .ct-batch-toolbar,
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
    <div class="pr-page-header">
        <div class="pr-page-header__left">
            <div class="pr-page-header__icon">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="#28a745" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
            </div>
            <div>
                <p class="pr-page-header__title">Payslip Review</p>
                <p class="pr-page-header__sub">Review, approve or reject individual employee payslips</p>
            </div>
        </div>
        <div>
            <a href="HRPayroll.aspx" class="hr-btn--ghost--sm">&#8592; Back to Payroll</a>
        </div>
    </div>

    <%-- Alert area --%>
    <asp:Literal ID="litPageAlert" runat="server" />

    <%-- Stats Row --%>
    <div class="ct-stats">
        <div class="ct-stat-card ct-stat-card--amber">
            <div class="ct-stat-card__value"><asp:Literal ID="litTotalPayslips" runat="server" Text="0" /></div>
            <div class="ct-stat-card__label">Total Payslips</div>
        </div>
        <div class="ct-stat-card ct-stat-card--pending">
            <div class="ct-stat-card__value"><asp:Literal ID="litPendingCount" runat="server" Text="0" /></div>
            <div class="ct-stat-card__label">Pending Review</div>
        </div>
        <div class="ct-stat-card ct-stat-card--green">
            <div class="ct-stat-card__value"><asp:Literal ID="litApprovedCount" runat="server" Text="0" /></div>
            <div class="ct-stat-card__label">Approved</div>
        </div>
        <div class="ct-stat-card ct-stat-card--red">
            <div class="ct-stat-card__value"><asp:Literal ID="litRejectedCount" runat="server" Text="0" /></div>
            <div class="ct-stat-card__label">Rejected</div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <div class="ct-filters">
        <div class="ct-filters__row">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-filters__search" placeholder="Search by name or staff code..." />
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--success hr-btn--sm" OnClick="btnSearch_Click" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="hr-btn hr-btn--ghost hr-btn--sm" OnClick="btnReset_Click" />
            <span class="ct-filter-count-top"><asp:Literal ID="litFilterCountTop" runat="server" Text="0" /> record(s)</span>
        </div>
        <div class="ct-filters__row">
            <span class="ct-filters__label">Payroll:</span>
            <asp:DropDownList ID="ddlFilterPayroll" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:160px;" />

            <span class="ct-filters__label">Employee:</span>
            <asp:DropDownList ID="ddlFilterEmployee" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:160px;" />

            <span class="ct-filters__label">Month:</span>
            <asp:DropDownList ID="ddlFilterMonth" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:110px;">
                <asp:ListItem Value="">All Months</asp:ListItem>
                <asp:ListItem Value="JANUARY">JANUARY</asp:ListItem>
                <asp:ListItem Value="FEBRUARY">FEBRUARY</asp:ListItem>
                <asp:ListItem Value="MARCH">MARCH</asp:ListItem>
                <asp:ListItem Value="APRIL">APRIL</asp:ListItem>
                <asp:ListItem Value="MAY">MAY</asp:ListItem>
                <asp:ListItem Value="JUNE">JUNE</asp:ListItem>
                <asp:ListItem Value="JULY">JULY</asp:ListItem>
                <asp:ListItem Value="AUGUST">AUGUST</asp:ListItem>
                <asp:ListItem Value="SEPTEMBER">SEPTEMBER</asp:ListItem>
                <asp:ListItem Value="OCTOBER">OCTOBER</asp:ListItem>
                <asp:ListItem Value="NOVEMBER">NOVEMBER</asp:ListItem>
                <asp:ListItem Value="DECEMBER">DECEMBER</asp:ListItem>
            </asp:DropDownList>

            <span class="ct-filters__label">Year:</span>
            <asp:TextBox ID="txtFilterYear" runat="server" style="width:60px;" MaxLength="4" />

            <span class="ct-filters__label">Status:</span>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:110px;">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem Value="PENDING">PENDING</asp:ListItem>
                <asp:ListItem Value="APPROVED">APPROVED</asp:ListItem>
                <asp:ListItem Value="REJECTED">REJECTED</asp:ListItem>
            </asp:DropDownList>

            <span class="ct-filters__label">Per page:</span>
            <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="width:60px;">
                <asp:ListItem Value="25">25</asp:ListItem>
                <asp:ListItem Value="50">50</asp:ListItem>
                <asp:ListItem Value="100">100</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <%-- Count bar --%>
    <div class="pr-count-bar">
        <span><asp:Literal ID="litFilterCount" runat="server" Text="0" /> record(s) shown</span>
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
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="clearBatchSelection()">Clear</button>
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
                           style="cursor:pointer;accent-color:#28a745;width:14px;height:14px;" />
                </HeaderTemplate>
                <DataItemTemplate>
                    <input type="checkbox" class="ct-row-check" value="<%# Eval("ID") %>" onchange="updateBatchToolbar()" />
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="ID" Visible="false" />
            <dx:GridViewDataTextColumn FieldName="empID" Visible="false" />

            <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff #" Width="68">
                <DataItemTemplate>
                    <span style="font-size:10px;font-weight:700;color:#28a745;font-family:monospace;"><%# Eval("EMP_CODE") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="155">
                <DataItemTemplate>
                    <span style="font-weight:600;color:#1a1a2e;font-size:11px;"><%# Eval("emp_name") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>

            <dx:GridViewDataTextColumn FieldName="payroll_title" Caption="Payroll" Width="130">
                <DataItemTemplate>
                    <span style="font-size:10px;color:#555;"><%# TruncStr(Eval("payroll_title"),25) %></span>
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
            <div class="hr-modal__header hr-modal__header--success">
                <h4 class="hr-modal__title">Payslip Details</h4>
                <button type="button" class="hr-modal__close" onclick="document.getElementById('slipDetailModal').style.display='none';">&times;</button>
            </div>
            <div class="hr-modal__body">
                <asp:Panel ID="pnlSlipDetail" runat="server">
                    <asp:Literal ID="litSlipDetailHtml" runat="server" />
                </asp:Panel>
            </div>
            <div class="hr-modal__footer">
                <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="document.getElementById('slipDetailModal').style.display='none';">Close</button>
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
                <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeRejectModal();">Cancel</button>
                <asp:Button ID="btnConfirmReject" runat="server" Text="Confirm Rejection" CssClass="hr-btn--danger--sm" OnClick="btnConfirmReject_Click" />
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
                <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeBatchRejectModal();">Cancel</button>
                <asp:Button ID="btnConfirmBatchReject" runat="server" Text="Confirm Batch Rejection" CssClass="hr-btn--danger--sm" OnClick="btnConfirmBatchReject_Click" />
            </div>
        </div>
    </div>

    <%-- ===== JavaScript ===== --%>
    <script type="text/javascript">
        var MONTHS_ARR = ['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];

        // Action popovers
        function toggleActionPopover(btn, evt) {
            evt.stopPropagation();
            var pop = btn.nextElementSibling;
            var isOpen = pop.classList.contains('is-open');
            closeAllPopovers();
            if (!isOpen) pop.classList.add('is-open');
        }
        function closeAllPopovers() {
            document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p) {
                p.classList.remove('is-open');
            });
        }
        document.addEventListener('click', closeAllPopovers);

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
