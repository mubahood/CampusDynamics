<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="IncomeStatement.aspx.cs" Inherits="COOPERP_NewScreens_IncomeStatement" Title="Income Statement - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== INCOME STATEMENT — ft- design system ====================== */
.ft-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--inc{--stat-c:#16a34a}.ft-stat--inc .ft-stat__icon{background:#e6f4ea}.ft-stat--inc .ft-stat__val{color:#16a34a}
.ft-stat--exp{--stat-c:#e65100}.ft-stat--exp .ft-stat__icon{background:#fff3e0}.ft-stat--exp .ft-stat__val{color:#e65100}
.ft-stat--net{--stat-c:#05275C}.ft-stat--net .ft-stat__icon{background:#e8f0fc}.ft-stat--net .ft-stat__val{color:#05275C}

.ft-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:14px}
.ft-card__header{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.ft-card__title{font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:2px 8px;border:1px solid rgba(23,77,164,.15)}
.ft-filters{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px}
.ft-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-input{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;font-family:inherit}
.ft-filter-input:focus{border-color:#174DA4;outline:none}

.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}
.ft-btn--ghost{background:transparent;color:#05275C;border:1px solid #e0e5ed}.ft-btn--ghost:hover{background:#f5f7fa}

.ft-report-hdr{text-align:center;padding:16px 14px;border-bottom:1px solid #e0e5ed}
.ft-report-hdr__doc{font-size:13px;font-weight:700;color:#174DA4;margin-bottom:2px}
.ft-report-hdr__title{font-size:18px;font-weight:800;color:#05275C;margin:0 0 4px}
.ft-report-hdr__sub{font-size:11px;color:#888;margin:0}

.ft-section{margin-bottom:14px}
.ft-section-hdr{background:#f5f7fa;border:1px solid #e0e5ed;border-bottom:none;padding:8px 14px;font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-section-hdr--inc{border-left:3px solid #16a34a}
.ft-section-hdr--exp{border-left:3px solid #e65100}

.ft-table{width:100%;border-collapse:collapse;font-size:12px;border:1px solid #e0e5ed}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:8px 12px;border-bottom:2px solid #e0e5ed;text-align:left}
.ft-table tbody td{padding:7px 12px;border-bottom:1px solid #f0f2f5;color:#1a1a2e;font-size:11px}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover{background:#eef2fc}
.ft-amount{text-align:right;font-family:Consolas,"Courier New",monospace;font-variant-numeric:tabular-nums}
.ft-subtotal{background:#e8f0fc!important;font-weight:700}
.ft-subtotal td{border-top:2px solid #174DA4!important}

.ft-net-row{background:#05275C!important}
.ft-net-row td{color:#fff!important;font-weight:700;font-size:13px;padding:10px 12px!important;border:none!important}
.ft-net-positive{color:#4ade80}
.ft-net-negative{color:#fca5a5}

.ft-totals{display:flex;gap:20px;flex-wrap:wrap;padding:10px 14px;background:#f8f9fb;border:1px solid #e0e5ed;font-size:12px}
.ft-totals__item{display:flex;gap:6px;align-items:center}
.ft-totals__label{font-weight:600;color:#555}
.ft-totals__value{font-weight:700;color:#05275C}

@media print{.ft-filters,.ft-btn,.ft-stats,.cd-sidebar,.cd-topbar,.fm-page-header,.fm-tabs{display:none!important}.ft-card{border:none;box-shadow:none}}
@media(max-width:768px){.ft-stats{grid-template-columns:1fr}.ft-filters__row{flex-direction:column}}
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
    <div><div style="font-size:16px;font-weight:700;">Income Statement</div><div style="font-size:11px;opacity:.75;margin-top:2px;">Revenue &amp; expense report</div></div>
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
    <a href="TrialBalance.aspx" class="fm-tab">Trial Balance</a>
    <a href="BalanceSheet.aspx" class="fm-tab">Balance Sheet</a>
    <a href="IncomeStatement.aspx" class="fm-tab fm-tab--active">Income Statement</a>
    <a href="FinancialPeriods.aspx" class="fm-tab">Periods</a>
    <a href="FinanceAuditTrail.aspx" class="fm-tab">Audit Trail</a>
</div>

<!-- Filter Card -->
<div class="ft-card" style="margin-bottom:14px">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
            Income Statement
        </div>
    </div>
    <div class="ft-filters">
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Start Date</span>
                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">End Date</span>
                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
            </div>
            <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="ft-btn ft-btn--primary" OnClick="btnGenerate_Click" />
            <button type="button" class="ft-btn ft-btn--ghost" onclick="window.print();">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                Print
            </button>
        </div>
    </div>
</div>

<!-- Error / info banner -->
<asp:Panel ID="pnlError" runat="server" Visible="false"
     style="padding:10px 16px;margin-bottom:14px;background:#fce4ec;border:1px solid #ef9a9a;color:#c62828;font-size:13px;font-weight:600;">
    <asp:Literal ID="litError" runat="server" />
</asp:Panel>

<!-- Report Content -->
<asp:Panel ID="pnlReport" runat="server" Visible="false">

<!-- Stats Row -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--inc">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/><polyline points="17 18 23 18 23 12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litSumIncome" runat="server" /></div><div class="ft-stat__label">Total Income</div></div>
    </div>
    <div class="ft-stat ft-stat--exp">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litSumExpense" runat="server" /></div><div class="ft-stat__label">Total Expenses</div></div>
    </div>
    <div class="ft-stat ft-stat--net">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
        <div><div class="ft-stat__val"><span id="spanNetResult" runat="server"><asp:Literal ID="litSumNet" runat="server" /></span></div><div class="ft-stat__label">Net Result</div></div>
    </div>
</div>

<!-- Report Header -->
<div class="ft-card">
    <div class="ft-report-hdr">
        <div class="ft-report-hdr__doc"><asp:Literal ID="litDocHeader" runat="server" /></div>
        <h2 class="ft-report-hdr__title">Income Statement</h2>
        <p class="ft-report-hdr__sub">
            Period: <asp:Literal ID="litPeriodStart" runat="server" /> to <asp:Literal ID="litPeriodEnd" runat="server" />
            &nbsp;|&nbsp; Generated: <asp:Literal ID="litGenDate" runat="server" />
        </p>
    </div>

    <!-- Income Section -->
    <div class="ft-section">
        <div class="ft-section-hdr ft-section-hdr--inc">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/></svg>
            Revenue / Income
        </div>
        <asp:Repeater ID="rptIncome" runat="server" OnItemDataBound="rptIncome_ItemDataBound">
            <HeaderTemplate>
                <table class="ft-table">
                    <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="font-weight:600;color:#05275C;"><%# Eval("accountcode") %></td>
                    <td><%# Eval("accountname") %></td>
                    <td class="ft-amount"><%# Eval("Amount", "{0:N2}") %></td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                    <tr class="ft-subtotal">
                        <td colspan="2">Total Income</td>
                        <td class="ft-amount"><asp:Literal ID="litTotalIncome" runat="server" /></td>
                    </tr>
                    </tbody>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <!-- Expense Section -->
    <div class="ft-section">
        <div class="ft-section-hdr ft-section-hdr--exp">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/></svg>
            Expenses
        </div>
        <asp:Repeater ID="rptExpense" runat="server" OnItemDataBound="rptExpense_ItemDataBound">
            <HeaderTemplate>
                <table class="ft-table">
                    <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="font-weight:600;color:#05275C;"><%# Eval("accountcode") %></td>
                    <td><%# Eval("accountname") %></td>
                    <td class="ft-amount"><%# Eval("Amount", "{0:N2}") %></td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                    <tr class="ft-subtotal">
                        <td colspan="2">Total Expenses</td>
                        <td class="ft-amount"><asp:Literal ID="litTotalExpense" runat="server" /></td>
                    </tr>
                    </tbody>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <!-- Net Income -->
    <table class="ft-table" style="margin-bottom:0">
        <tr class="ft-net-row">
            <td colspan="2">Net Income (Loss)</td>
            <td class="ft-amount"><asp:Literal ID="litNetIncome" runat="server" /></td>
        </tr>
    </table>
</div>

<!-- Totals Bar -->
<div class="ft-totals">
    <div class="ft-totals__item"><span class="ft-totals__label">Total Income:</span><span class="ft-totals__value" style="color:#16a34a"><asp:Literal ID="litBarIncome" runat="server" /></span></div>
    <div class="ft-totals__item"><span class="ft-totals__label">Total Expenses:</span><span class="ft-totals__value" style="color:#e65100"><asp:Literal ID="litBarExpense" runat="server" /></span></div>
    <div class="ft-totals__item"><span class="ft-totals__label">Net Result:</span><span class="ft-totals__value"><asp:Literal ID="litBarNet" runat="server" /></span></div>
</div>

</asp:Panel>
</asp:Content>
