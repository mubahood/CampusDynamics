<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TrialBalance.aspx.cs" Inherits="COOPERP_NewScreens_TrialBalance" Title="Trial Balance - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .tb-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .tb-filter-group { display: flex; flex-direction: column; gap: 4px; }
        .tb-filter-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .tb-filter-group input {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .tb-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .tb-btn:hover { background: #1565c0; }
        .tb-btn-print {
            padding: 6px 16px; background: #388e3c; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .tb-btn-print:hover { background: #2e7d32; }

        .tb-summary-bar {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 16px; margin-top: 12px;
            display: flex; gap: 24px; flex-wrap: wrap; font-size: 13px;
        }
        .tb-summary-item { display: flex; gap: 6px; align-items: center; }
        .tb-summary-label { font-weight: 600; color: #555; }
        .tb-summary-value { font-weight: 700; color: #1565c0; }
        .tb-balanced { color: #2e7d32 !important; }
        .tb-unbalanced { color: #c62828 !important; }

        .tb-status-banner {
            padding: 10px 16px; margin-bottom: 12px; font-size: 14px; font-weight: 600;
            text-align: center; border-radius: 4px;
        }
        .tb-status-ok { background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; }
        .tb-status-err { background: #fce4ec; border: 1px solid #ef9a9a; color: #c62828; }

        .tb-report-header {
            text-align: center; margin-bottom: 16px; padding: 12px;
            background: #fff; border: 1px solid #e0e0e0;
        }
        .tb-report-header h2 { margin: 0 0 4px 0; font-size: 18px; color: #333; }
        .tb-report-header p { margin: 0; font-size: 12px; color: #666; }

        @media print {
            .tb-filter-bar, .tb-btn, .tb-btn-print, .cd-sidebar, .cd-topbar, .fm-page-header, .fm-tabs { display: none !important; }
            .tb-report-header { border: none; }
        }
/* ── Finance Module Nav ── */
.fm-page-header{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:18px 24px;}
.fm-tabs{display:flex;gap:0;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 20px;overflow-x:auto;margin-bottom:16px;}
.fm-tab{padding:10px 16px;font-size:11px;font-weight:500;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;white-space:nowrap;transition:color .15s,border-color .15s;}
.fm-tab:hover{color:#1a237e;}
.fm-tab--active{color:#1a237e;border-bottom-color:#1a237e;font-weight:600;}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- ======= PAGE HEADER =========================================== -->
<div class="fm-page-header">
    <div><div style="font-size:16px;font-weight:700;">Trial Balance</div><div style="font-size:11px;opacity:.75;margin-top:2px;">Debits &amp; credits verification</div></div>
</div>
<div class="fm-tabs">
    <a href="FinanceDashboard.aspx" class="fm-tab">Dashboard</a>
    <a href="GeneralLedger.aspx" class="fm-tab">General Ledger</a>
    <a href="JournalEntries.aspx" class="fm-tab">Journals</a>
    <a href="PaymentVouchers.aspx" class="fm-tab">Payment Vouchers</a>
    <a href="ContraVouchers.aspx" class="fm-tab">Contra Vouchers</a>
    <a href="BudgetManager.aspx" class="fm-tab">Budget</a>
    <a href="CashBook.aspx" class="fm-tab">Cash Book</a>
    <a href="BankReconciliation.aspx" class="fm-tab">Bank Reco</a>
    <a href="TrialBalance.aspx" class="fm-tab fm-tab--active">Trial Balance</a>
    <a href="BalanceSheet.aspx" class="fm-tab">Balance Sheet</a>
    <a href="IncomeStatement.aspx" class="fm-tab">Income Statement</a>
    <a href="FinancialPeriods.aspx" class="fm-tab">Periods</a>
    <a href="FinanceAuditTrail.aspx" class="fm-tab">Audit Trail</a>
</div>

    <!-- Filter Bar -->
    <div class="tb-filter-bar">
        <div class="tb-filter-group">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="tb-filter-group">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="tb-btn" OnClick="btnGenerate_Click" />
        <button type="button" class="tb-btn-print" onclick="window.print();">&#128424; Print</button>
    </div>

    <!-- Error / info banner -->
    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="tb-status-banner tb-status-err">
        <asp:Literal ID="litError" runat="server" />
    </asp:Panel>

    <!-- Report Header (visible after generation) -->
    <asp:Panel ID="pnlReport" runat="server" Visible="false">
        <div class="tb-report-header">
            <h2>Trial Balance</h2>
            <p>
                Period: <asp:Literal ID="litPeriodStart" runat="server" /> to <asp:Literal ID="litPeriodEnd" runat="server" />
                &nbsp;|&nbsp; Generated: <asp:Literal ID="litGenDate" runat="server" />
            </p>
        </div>

        <!-- Balance Status Banner -->
        <asp:Panel ID="pnlBalanceStatus" runat="server" CssClass="tb-status-banner tb-status-ok">
            <asp:Literal ID="litBalanceStatus" runat="server" />
        </asp:Panel>

        <!-- Trial Balance Grid -->
        <dx:ASPxGridView ID="gridTrialBalance" runat="server" Width="100%" KeyFieldName="accountcode"
            ClientInstanceName="gridTrialBalance"
            Settings-ShowGroupPanel="false" Settings-ShowFilterRow="true"
            SettingsPager-PageSize="50"
            SettingsBehavior-AllowFocusedRow="true">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="accountcode" Caption="Account Code" Width="120" />
                <dx:GridViewDataTextColumn FieldName="accountname" Caption="Account Name" Width="250" />
                <dx:GridViewDataTextColumn FieldName="category" Caption="Category" Width="150" />
                <dx:GridViewDataTextColumn FieldName="subcategory" Caption="Sub-Category" Width="150" />
                <dx:GridViewDataTextColumn FieldName="DRBalance" Caption="Debit (DR)" Width="130">
                    <PropertiesTextEdit DisplayFormatString="N2" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="CRBalance" Caption="Credit (CR)" Width="130">
                    <PropertiesTextEdit DisplayFormatString="N2" />
                </dx:GridViewDataTextColumn>
            </Columns>
            <TotalSummary>
                <dx:ASPxSummaryItem FieldName="DRBalance" SummaryType="Sum" DisplayFormat="N2" />
                <dx:ASPxSummaryItem FieldName="CRBalance" SummaryType="Sum" DisplayFormat="N2" />
            </TotalSummary>
            <Settings ShowFooter="true" />
            <SettingsText EmptyDataRow="No data for the selected period." />
        </dx:ASPxGridView>

        <!-- Summary Bar -->
        <div class="tb-summary-bar">
            <div class="tb-summary-item">
                <span class="tb-summary-label">Total Debits:</span>
                <span class="tb-summary-value"><asp:Literal ID="litTotalDR" runat="server" /></span>
            </div>
            <div class="tb-summary-item">
                <span class="tb-summary-label">Total Credits:</span>
                <span class="tb-summary-value"><asp:Literal ID="litTotalCR" runat="server" /></span>
            </div>
            <div class="tb-summary-item">
                <span class="tb-summary-label">Difference:</span>
                <span id="spanDiff" runat="server" class="tb-summary-value"><asp:Literal ID="litDifference" runat="server" /></span>
            </div>
            <div class="tb-summary-item">
                <span class="tb-summary-label">Accounts:</span>
                <span class="tb-summary-value"><asp:Literal ID="litAccountCount" runat="server" /></span>
            </div>
        </div>
    </asp:Panel>
</asp:Content>
