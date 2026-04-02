<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="PaymentVouchers.aspx.cs" Inherits="COOPERP_NewScreens_PaymentVouchers" Title="Payment Vouchers - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== PAYMENT VOUCHERS — ft- design system ====================== */
.ft-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--total{--stat-c:#05275C}.ft-stat--total .ft-stat__icon{background:#e8f0fc}.ft-stat--total .ft-stat__val{color:#05275C}
.ft-stat--new{--stat-c:#d97706}.ft-stat--new .ft-stat__icon{background:#fffbeb}.ft-stat--new .ft-stat__val{color:#d97706}
.ft-stat--approved{--stat-c:#16a34a}.ft-stat--approved .ft-stat__icon{background:#e6f4ea}.ft-stat--approved .ft-stat__val{color:#16a34a}
.ft-stat--amount{--stat-c:#174DA4}.ft-stat--amount .ft-stat__icon{background:#e8f0fc}.ft-stat--amount .ft-stat__val{color:#174DA4}

.ft-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:14px}
.ft-card__header{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.ft-card__title{font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:2px 8px;border:1px solid rgba(23,77,164,.15)}
.ft-filters{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px}
.ft-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-input,.ft-filter-select{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;font-family:inherit;min-width:110px}
.ft-filter-input:focus,.ft-filter-select:focus{border-color:#174DA4;outline:none}

.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}
.ft-btn--success{background:#16a34a;color:#fff}.ft-btn--success:hover{background:#15803d}
.ft-btn--ghost{background:transparent;color:#05275C;border:1px solid #e0e5ed}.ft-btn--ghost:hover{background:#f5f7fa}
.ft-btn--sm{padding:4px 10px;font-size:10px}

.ft-table-wrap{overflow:auto;max-height:400px;position:relative}
.ft-table{width:100%;border-collapse:collapse;min-width:600px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:9px 12px;border-bottom:2px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s;cursor:pointer}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:8px 12px;vertical-align:middle;color:#1a1a2e;font-size:11px}
.ft-table--detail tbody tr{cursor:default}
.ft-badge{font-size:10px;font-weight:600;padding:2px 7px;text-transform:uppercase;letter-spacing:.3px;display:inline-block}
.ft-badge--green{background:#e6f4ea;color:#155724;border:1px solid #c3e6cb}
.ft-badge--amber{background:#fffbeb;color:#92400e;border:1px solid #fcd34d}
.ft-badge--red{background:#fef5f5;color:#991b1b;border:1px solid #f5c6cb}

.ft-nodata{padding:30px 20px;text-align:center;color:#999;font-size:13px}
.ft-pager{display:flex;align-items:center;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666}

/* Create form inside card */
.ft-form{padding:14px;background:#fafbfc}
.ft-form__row{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;margin-bottom:10px}
.ft-form__actions{display:flex;gap:8px;margin-top:8px}

/* Alert messages */
.ft-alert{padding:8px 14px;margin-bottom:10px;font-size:12px;border-left:3px solid;display:flex;align-items:center;gap:6px}
.ft-alert--success{border-color:#16a34a;background:#e6f4ea;color:#155724}
.ft-alert--error{border-color:#dc3545;background:#fef5f5;color:#991b1b}

/* Detail info bar */
.ft-detail-bar{padding:10px 14px;background:#e8f0fc;border-bottom:1px solid #e0e5ed;display:flex;align-items:center;gap:14px;font-size:12px}
.ft-detail-bar strong{color:#05275C}

@media(max-width:900px){.ft-stats{grid-template-columns:repeat(2,1fr)}}
@media(max-width:500px){.ft-stats{grid-template-columns:1fr}.ft-filters__row{flex-direction:column}.ft-form__row{flex-direction:column}}
@media print{.fm-page-header,.fm-tabs{display:none!important}}
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
    <div><div style="font-size:16px;font-weight:700;">Payment Vouchers</div><div style="font-size:11px;opacity:.75;margin-top:2px;">Create &amp; approve payment vouchers</div></div>
</div>
<div class="fm-tabs">
    <a href="FinanceDashboard.aspx" class="fm-tab">Dashboard</a>
    <a href="GeneralLedger.aspx" class="fm-tab">General Ledger</a>
    <a href="JournalEntries.aspx" class="fm-tab">Journals</a>
    <a href="PaymentVouchers.aspx" class="fm-tab fm-tab--active">Payment Vouchers</a>
    <a href="ContraVouchers.aspx" class="fm-tab">Contra Vouchers</a>
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

<!-- Stats Row -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--total">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div><div class="ft-stat__label">Total Vouchers</div></div>
    </div>
    <div class="ft-stat ft-stat--new">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litStatNew" runat="server" Text="0" /></div><div class="ft-stat__label">Pending</div></div>
    </div>
    <div class="ft-stat ft-stat--approved">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litStatApproved" runat="server" Text="0" /></div><div class="ft-stat__label">Approved</div></div>
    </div>
    <div class="ft-stat ft-stat--amount">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litStatAmount" runat="server" Text="UGX 0" /></div><div class="ft-stat__label">Total Amount</div></div>
    </div>
</div>

<!-- Filter Card -->
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
            Payment Vouchers
        </div>
        <asp:Button ID="btnNewVoucher" runat="server" Text="+ New Payment Voucher" CssClass="ft-btn ft-btn--success" OnClick="btnNewVoucher_Click" />
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
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Voucher Type</span>
                <asp:DropDownList ID="ddlVoucherType" runat="server" CssClass="ft-filter-select">
                    <asp:ListItem Text="All" Value="" />
                    <asp:ListItem Text="Payment" Value="Payment" />
                    <asp:ListItem Text="Receipt" Value="Receipt" />
                </asp:DropDownList>
            </div>
            <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="ft-btn ft-btn--primary" OnClick="btnFilter_Click" />
        </div>
    </div>

    <!-- Create Voucher Form -->
    <asp:Panel ID="pnlCreate" runat="server" Visible="false">
        <div class="ft-form">
            <div style="font-size:12px;font-weight:700;color:#05275C;margin-bottom:10px;display:flex;align-items:center;gap:6px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                Create Payment Voucher
            </div>
            <div class="ft-form__row">
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Debit Account (Expense/Asset)</span>
                    <asp:DropDownList ID="ddlDRAccount" runat="server" CssClass="ft-filter-select" style="min-width:260px" />
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Credit Account (Bank/Cash)</span>
                    <asp:DropDownList ID="ddlCRAccount" runat="server" CssClass="ft-filter-select" style="min-width:260px" />
                </div>
            </div>
            <div class="ft-form__row">
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Amount</span>
                    <asp:TextBox ID="txtAmount" runat="server" TextMode="Number" CssClass="ft-filter-input" style="width:140px" />
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">DR Particulars</span>
                    <asp:TextBox ID="txtDRParticulars" runat="server" MaxLength="350" CssClass="ft-filter-input" style="width:200px" />
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">CR Particulars</span>
                    <asp:TextBox ID="txtCRParticulars" runat="server" MaxLength="350" CssClass="ft-filter-input" style="width:200px" />
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Date</span>
                    <asp:TextBox ID="txtVoucherDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
                </div>
            </div>
            <div class="ft-form__actions">
                <asp:Button ID="btnConfirmCreate" runat="server" Text="Create & Post Voucher" CssClass="ft-btn ft-btn--success" OnClick="btnConfirmCreate_Click" />
                <asp:Button ID="btnCancelCreate" runat="server" Text="Cancel" CssClass="ft-btn ft-btn--ghost" OnClick="btnCancelCreate_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- Vouchers Table -->
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th style="width:70px">V.No</th><th>Type</th><th>Date</th><th>Created By</th><th>Status</th><th style="width:60px"></th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptVouchers" runat="server" OnItemCommand="rptVouchers_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td style="font-weight:700;color:#05275C;"><%# Eval("VoucherNo") %></td>
                            <td><%# Eval("Vouchertype") %></td>
                            <td style="white-space:nowrap;"><%# Eval("voucherDate", "{0:dd MMM yyyy}") %></td>
                            <td><%# Eval("Teller") %></td>
                            <td>
                                <span class='ft-badge <%# Eval("PostStatus").ToString()=="Approved" ? "ft-badge--green" : Eval("PostStatus").ToString()=="New" ? "ft-badge--amber" : "ft-badge--red" %>'>
                                    <%# Eval("PostStatus") %>
                                </span>
                            </td>
                            <td>
                                <asp:LinkButton ID="lnkView" runat="server" CommandName="ViewVoucher" CommandArgument='<%# Eval("VoucherNo") %>'
                                    CssClass="ft-btn ft-btn--primary ft-btn--sm" CausesValidation="false">View</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoVouchers" runat="server" Visible="false">
                    <tr><td colspan="6" class="ft-nodata">No vouchers found for the selected period.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span><asp:Literal ID="litVoucherCount" runat="server" /></span>
    </div>
</div>

<!-- Voucher Detail -->
<asp:Panel ID="pnlDetail" runat="server" Visible="false">
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            Voucher Detail
        </div>
    </div>
    <div class="ft-detail-bar">
        <span>Voucher #<strong><asp:Label ID="lblVoucherNo" runat="server" /></strong></span>
        <span>Status: <asp:Label ID="lblVoucherStatus" runat="server" /></span>
    </div>
    <div class="ft-table-wrap">
        <table class="ft-table ft-table--detail">
            <thead>
                <tr>
                    <th>Account</th><th>Type</th><th>DR/CR</th><th style="text-align:right">Amount</th><th>Particulars</th><th>Date</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptVoucherTrans" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td style="font-weight:600;color:#05275C;"><%# Eval("accountcode") %></td>
                            <td><%# Eval("account_type") %></td>
                            <td>
                                <span class='ft-badge <%# Eval("transactionType").ToString()=="DR" ? "ft-badge--amber" : "ft-badge--green" %>'>
                                    <%# Eval("transactionType") %>
                                </span>
                            </td>
                            <td style="text-align:right;font-family:Consolas,monospace;font-weight:600;"><%# Eval("transaction_amount", "{0:N0}") %></td>
                            <td><%# Eval("particulars") %></td>
                            <td style="white-space:nowrap;"><%# Eval("transactionDate", "{0:dd MMM yyyy}") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
    <div style="padding:10px 14px;display:flex;gap:8px;background:#f8f9fb;border-top:1px solid #e0e5ed;">
        <asp:Button ID="btnApproveVoucher" runat="server" Text="Approve Voucher" CssClass="ft-btn ft-btn--success" OnClick="btnApproveVoucher_Click" />
        <asp:Button ID="btnCloseDetail" runat="server" Text="Close" CssClass="ft-btn ft-btn--ghost" OnClick="btnCloseDetail_Click" />
    </div>
</div>
</asp:Panel>

</asp:Content>
