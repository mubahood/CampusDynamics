<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GeneralLedger.aspx.cs" Inherits="COOPERP_NewScreens_GeneralLedger" Title="General Ledger - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== GENERAL LEDGER - ft- design system ========================== */

/* Stats Row */
.ft-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums;word-break:break-word;overflow-wrap:break-word}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--dr{--stat-c:#174DA4}.ft-stat--dr .ft-stat__icon{background:#e8f0fc}.ft-stat--dr .ft-stat__val{color:#174DA4}
.ft-stat--cr{--stat-c:#2e7d32}.ft-stat--cr .ft-stat__icon{background:#e6f4ea}.ft-stat--cr .ft-stat__val{color:#2e7d32}
.ft-stat--net{--stat-c:#e65100}.ft-stat--net .ft-stat__icon{background:#fff3e0}.ft-stat--net .ft-stat__val{color:#e65100}
.ft-stat--count{--stat-c:#05275C}.ft-stat--count .ft-stat__icon{background:#e8f0fc}.ft-stat--count .ft-stat__val{color:#05275C}

/* Card / Filters */
.ft-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:14px}
.ft-card__header{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.ft-card__title{font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:2px 8px;border:1px solid rgba(23,77,164,.15)}
.ft-filters{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px}
.ft-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-select,.ft-filter-input{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;cursor:pointer;min-width:110px;font-family:inherit}
.ft-filter-select:focus,.ft-filter-input:focus{border-color:#174DA4;outline:none}

/* Buttons */
.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}
.ft-btn--ghost{background:transparent;border:1px solid #e0e5ed;color:#555}.ft-btn--ghost:hover{border-color:#174DA4;color:#174DA4}
.ft-btn--sm{padding:5px 11px;font-size:10px}

/* Badges */
.ft-badge{display:inline-block;padding:3px 9px;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.3px}
.ft-badge--dr{background:#e8f0fc;color:#174DA4}
.ft-badge--cr{background:#e6f4ea;color:#2e7d32}

/* Data Table */
.ft-table-wrap{overflow:auto;max-height:560px;border-bottom:1px solid #e0e5ed;position:relative}
.ft-table{width:100%;border-collapse:collapse;min-width:1000px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:9px 12px;border-bottom:2px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:8px 12px;vertical-align:middle;color:#1a1a2e;font-size:11px}
.ft-col-id{width:60px}.ft-col-date{width:92px;white-space:nowrap}.ft-col-acc{width:100px;color:#05275C;font-weight:700}
.ft-col-acctype{width:90px}.ft-col-part{min-width:180px}.ft-col-drcr{width:50px;text-align:center}
.ft-col-amt{width:120px;text-align:right;font-weight:700;font-variant-numeric:tabular-nums}
.ft-col-voucher{width:80px}.ft-col-user{width:100px}
td.ft-col-part{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:260px}

/* Totals Bar */
.ft-totals{display:flex;align-items:center;gap:16px;padding:7px 14px;background:linear-gradient(90deg,#f0f4fc 0%,#f8f9fb 100%);border-top:1px solid #e0e5ed;font-size:11px}
.ft-totals__label{font-weight:700;color:#555;text-transform:uppercase;letter-spacing:.6px;font-size:9px;margin-right:2px}
.ft-totals__pills{display:flex;gap:8px;flex-wrap:wrap;align-items:center}
.ft-totals__pill{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;font-weight:600;font-variant-numeric:tabular-nums;line-height:1.5;white-space:nowrap}
.ft-totals__pill--dr{background:#e8f0fc;color:#174DA4;border:1px solid #c5d5f0}
.ft-totals__pill--cr{background:#e6f4ea;color:#2e7d32;border:1px solid #c8e6c9}
.ft-totals__pill--net{background:#fff3e0;color:#e65100;border:1px solid #ffcc80}

/* Pager */
.ft-pager{display:flex;align-items:center;justify-content:space-between;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666;flex-wrap:wrap;gap:8px}
.ft-pager__info strong{color:#05275C}
.ft-pager__btns{display:flex;gap:3px;align-items:center;flex-wrap:wrap}
.ft-pager__btn{min-width:30px;padding:4px 8px;font-size:11px;font-weight:600;border:1px solid #e0e5ed;background:#fff;color:#444;cursor:pointer;font-family:inherit;line-height:1.4;text-align:center}
.ft-pager__btn:hover:not([disabled]){border-color:#174DA4;color:#174DA4;background:#eef2fc}
.ft-pager__btn[disabled]{opacity:.4;cursor:not-allowed}
.ft-pager__btn--active{background:#05275C!important;color:#fff!important;border-color:#05275C!important}
.ft-pager__ellipsis{padding:4px 2px;color:#aaa;font-size:12px}

/* No Data */
.ft-nodata{padding:44px 20px;text-align:center;color:#999;font-size:13px}
.ft-nodata svg{display:block;margin:0 auto 8px}

/* Responsive */
@media(max-width:768px){.ft-stats{grid-template-columns:repeat(2,1fr)}.ft-filters__row{flex-direction:column}}
@media print{.ft-filters,.ft-btn,.ft-pager,.fm-page-header,.fm-tabs{display:none!important}.ft-table-wrap{max-height:none!important;overflow:visible!important}}
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
    <div><div style="font-size:16px;font-weight:700;">General Ledger</div><div style="font-size:11px;opacity:.75;margin-top:2px;">Complete transaction register</div></div>
</div>
<div class="fm-tabs">
    <a href="FinanceDashboard.aspx" class="fm-tab">Dashboard</a>
    <a href="GeneralLedger.aspx" class="fm-tab fm-tab--active">General Ledger</a>
    <a href="JournalEntries.aspx" class="fm-tab">Journals</a>
    <a href="PaymentVouchers.aspx" class="fm-tab">Payment Vouchers</a>
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

<asp:HiddenField ID="hfPageIndex" runat="server" Value="0" />

<!-- Stats Row -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--dr">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litSumDR" runat="server" Text="UGX 0" /></div><div class="ft-stat__label">Total Debits</div></div>
    </div>
    <div class="ft-stat ft-stat--cr">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/><polyline points="17 18 23 18 23 12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litSumCR" runat="server" Text="UGX 0" /></div><div class="ft-stat__label">Total Credits</div></div>
    </div>
    <div class="ft-stat ft-stat--net">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litNetBalance" runat="server" Text="UGX 0" /></div><div class="ft-stat__label">Net Balance (DR-CR)</div></div>
    </div>
    <div class="ft-stat ft-stat--count">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litRecordCount" runat="server" Text="0" /></div><div class="ft-stat__label">Total Records</div></div>
    </div>
</div>

<!-- Filter + Data Card -->
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
            General Ledger
        </div>
        <asp:Literal ID="litPeriodBadge" runat="server" />
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
                <span class="ft-filter-grp__label">Account</span>
                <asp:DropDownList ID="ddlAccount" runat="server" CssClass="ft-filter-select" style="min-width:220px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Type</span>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="ft-filter-select">
                    <asp:ListItem Text="All Types" Value="" />
                    <asp:ListItem Text="DR - Debit" Value="DR" />
                    <asp:ListItem Text="CR - Credit" Value="CR" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Per Page</span>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="min-width:70px;">
                    <asp:ListItem Text="30" Value="30" />
                    <asp:ListItem Text="50" Value="50" Selected="True" />
                    <asp:ListItem Text="100" Value="100" />
                    <asp:ListItem Text="200" Value="200" />
                </asp:DropDownList>
            </div>
            <asp:Button ID="btnFilter" runat="server" Text="Load Ledger" CssClass="ft-btn ft-btn--primary" OnClick="btnFilter_Click" />
            <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" onclick="window.print();" title="Print">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                Print
            </button>
        </div>
    </div>

    <!-- Data Table -->
    <div class="ft-table-wrap">
        <table class="ft-table">
            <colgroup>
                <col class="ft-col-id"><col class="ft-col-date"><col class="ft-col-acc">
                <col class="ft-col-acctype"><col class="ft-col-part"><col class="ft-col-drcr">
                <col class="ft-col-amt"><col class="ft-col-voucher"><col class="ft-col-user">
            </colgroup>
            <thead>
                <tr>
                    <th>ID</th><th>Date</th><th>Account</th><th>Acc Type</th>
                    <th>Particulars</th><th>DR/CR</th><th style="text-align:right">Amount</th>
                    <th>Voucher</th><th>User</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptLedger" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("TID") %></td>
                            <td class="ft-col-date"><%# Eval("transactionDate", "{0:dd MMM yyyy}") %></td>
                            <td class="ft-col-acc"><%# Eval("accountcode") %></td>
                            <td><%# Eval("account_type") %></td>
                            <td class="ft-col-part" title='<%# Eval("particulars") %>'><%# Eval("particulars") %></td>
                            <td style="text-align:center"><span class='ft-badge <%# Eval("transactionType").ToString()=="DR" ? "ft-badge--dr" : "ft-badge--cr" %>'><%# Eval("transactionType") %></span></td>
                            <td style="text-align:right;font-weight:700;font-variant-numeric:tabular-nums;"><%# Eval("transaction_amount", "{0:N0}") %></td>
                            <td><%# Eval("voucherNo") %></td>
                            <td><%# Eval("teller") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                    <tr><td colspan="9" class="ft-nodata">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        No ledger entries match your current filters.
                    </td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>

    <!-- Totals Bar -->
    <div class="ft-totals">
        <span class="ft-totals__label">Totals</span>
        <div class="ft-totals__pills">
            <span class="ft-totals__pill ft-totals__pill--dr">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/></svg>
                DR: <asp:Literal ID="litTotalBarDR" runat="server" />
            </span>
            <span class="ft-totals__pill ft-totals__pill--cr">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/></svg>
                CR: <asp:Literal ID="litTotalBarCR" runat="server" />
            </span>
            <asp:Literal ID="litTotalBarNet" runat="server" />
        </div>
    </div>

    <!-- Pager -->
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Label ID="lblGridFooter" runat="server" Text="" /></span>
        <asp:Literal ID="litPager" runat="server" />
    </div>
</div>

<script>
function goPage(idx){
    document.getElementById('<%= hfPageIndex.ClientID %>').value=idx;
    __doPostBack('<%= btnFilter.UniqueID %>','');
}
</script>
</asp:Content>
