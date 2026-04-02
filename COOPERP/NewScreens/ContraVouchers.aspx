<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ContraVouchers.aspx.cs" Inherits="COOPERP_NewScreens_ContraVouchers" Title="Contra Vouchers - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .cv-filter-bar { background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px; display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap; }
        .cv-fg { display: flex; flex-direction: column; gap: 4px; }
        .cv-fg label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .cv-fg input, .cv-fg select { padding: 5px 8px; border: 1px solid #ccc; font-size: 12px; }
        .cv-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: 1px solid #1976d2; color: #fff; background: #1976d2; cursor: pointer; }
        .cv-btn:hover { background: #1565c0; }
        .cv-btn--success { background: #388e3c; border-color: #388e3c; }
        .cv-btn--outline { background: #fff; color: #1976d2; }
        .cv-section { background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px; }
        .cv-section__header { padding: 10px 16px; border-bottom: 1px solid #e0e0e0; font-size: 13px; font-weight: 600; color: #333; display: flex; align-items: center; gap: 8px; }
        .cv-section__header svg { width: 16px; height: 16px; color: #666; }
        .cv-create-form { background: #f8f9fa; border: 1px solid #e0e0e0; padding: 14px 16px; margin-bottom: 16px; }
        .cv-create-form__row { display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap; margin-bottom: 10px; }
        .cv-msg { padding: 8px 14px; margin-bottom: 10px; font-size: 12px; border-left: 3px solid; }
        .cv-msg--success { border-color: #388e3c; background: #e8f5e9; color: #2e7d32; }
        .cv-msg--error { border-color: #d32f2f; background: #ffebee; color: #c62828; }
/* ── Finance Module Nav ── */
.fm-page-header{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:18px 24px;}
.fm-tabs{display:flex;gap:0;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 20px;overflow-x:auto;margin-bottom:16px;}
.fm-tab{padding:10px 16px;font-size:11px;font-weight:500;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;white-space:nowrap;transition:color .15s,border-color .15s;}
.fm-tab:hover{color:#1a237e;}
.fm-tab--active{color:#1a237e;border-bottom-color:#1a237e;font-weight:600;}
@media print{.fm-page-header,.fm-tabs{display:none!important}}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- ======= PAGE HEADER =========================================== -->
<div class="fm-page-header">
    <div><div style="font-size:16px;font-weight:700;">Contra Vouchers</div><div style="font-size:11px;opacity:.75;margin-top:2px;">Inter-account transfers</div></div>
</div>
<div class="fm-tabs">
    <a href="FinanceDashboard.aspx" class="fm-tab">Dashboard</a>
    <a href="GeneralLedger.aspx" class="fm-tab">General Ledger</a>
    <a href="JournalEntries.aspx" class="fm-tab">Journals</a>
    <a href="PaymentVouchers.aspx" class="fm-tab">Payment Vouchers</a>
    <a href="ContraVouchers.aspx" class="fm-tab fm-tab--active">Contra Vouchers</a>
    <a href="BudgetManager.aspx" class="fm-tab">Budget</a>
    <a href="CashBook.aspx" class="fm-tab">Cash Book</a>
    <a href="BankReconciliation.aspx" class="fm-tab">Bank Reco</a>
    <a href="TrialBalance.aspx" class="fm-tab">Trial Balance</a>
    <a href="BalanceSheet.aspx" class="fm-tab">Balance Sheet</a>
    <a href="IncomeStatement.aspx" class="fm-tab">Income Statement</a>
    <a href="FinancialPeriods.aspx" class="fm-tab">Periods</a>
    <a href="FinanceAuditTrail.aspx" class="fm-tab">Audit Trail</a>
</div>

    <asp:Label ID="lblMessage" runat="server" />

    <div class="cv-filter-bar">
        <div class="cv-fg"><label>Start Date</label><asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" /></div>
        <div class="cv-fg"><label>End Date</label><asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" /></div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="cv-btn" OnClick="btnFilter_Click" />
        <asp:Button ID="btnNewContra" runat="server" Text="+ New Contra Voucher" CssClass="cv-btn cv-btn--success" OnClick="btnNewContra_Click" />
    </div>

    <asp:Panel ID="pnlCreate" runat="server" Visible="false">
        <div class="cv-create-form">
            <div style="font-size:13px;font-weight:600;color:#333;margin-bottom:10px;">Create Contra Voucher (Inter-Account Transfer)</div>
            <div class="cv-create-form__row">
                <div class="cv-fg">
                    <label>From Account (Credit)</label>
                    <dx:ASPxComboBox ID="cboFromAccount" runat="server" Width="280" IncrementalFilteringMode="Contains"
                        TextFormatString="{0} - {1}" ValueField="AccountCode" ClientInstanceName="cboFrom">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
                <div class="cv-fg">
                    <label>To Account (Debit)</label>
                    <dx:ASPxComboBox ID="cboToAccount" runat="server" Width="280" IncrementalFilteringMode="Contains"
                        TextFormatString="{0} - {1}" ValueField="AccountCode" ClientInstanceName="cboTo">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
            </div>
            <div class="cv-create-form__row">
                <div class="cv-fg"><label>Amount</label><asp:TextBox ID="txtAmount" runat="server" TextMode="Number" Width="150" /></div>
                <div class="cv-fg"><label>Particulars</label><asp:TextBox ID="txtParticulars" runat="server" MaxLength="350" Width="300" /></div>
                <div class="cv-fg"><label>Date</label><asp:TextBox ID="txtDate" runat="server" TextMode="Date" /></div>
            </div>
            <div style="margin-top:8px;display:flex;gap:8px;">
                <asp:Button ID="btnConfirmCreate" runat="server" Text="Create Contra" CssClass="cv-btn cv-btn--success" OnClick="btnConfirmCreate_Click" />
                <asp:Button ID="btnCancelCreate" runat="server" Text="Cancel" CssClass="cv-btn cv-btn--outline" OnClick="btnCancelCreate_Click" />
            </div>
        </div>
    </asp:Panel>

    <div class="cv-section">
        <div class="cv-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
            Contra Vouchers
        </div>
        <dx:ASPxGridView ID="gvContras" runat="server" Width="100%" KeyFieldName="VoucherNo"
            ClientInstanceName="gvContras" SettingsPager-PageSize="20">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="VoucherNo" Caption="V.No" Width="70" />
                <dx:GridViewDataDateColumn FieldName="voucherDate" Caption="Date" Width="90">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="Teller" Caption="Created By" Width="100" />
                <dx:GridViewDataTextColumn FieldName="PostStatus" Caption="Status" Width="80" />
            </Columns>
            <Settings ShowFilterRow="true" />
            <SettingsPager PageSize="20" />
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
            </Styles>
        </dx:ASPxGridView>
    </div>
</asp:Content>
