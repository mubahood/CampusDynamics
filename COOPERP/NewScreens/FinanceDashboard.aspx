<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FinanceDashboard.aspx.cs" Inherits="COOPERP_NewScreens_FinanceDashboard" Title="Finance Dashboard - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
/* =====================================================================
   FINANCE DASHBOARD — Redesigned 2026-03-28
   Prefix: fn- (finance dashboard) | fm- (page header/nav) | fs- (shared)
   Benchmark: FeesStructure.aspx / FeesManagement.aspx
   ===================================================================== */

/* ---- Page header ---- */
.fm-page-header {
    display: flex; align-items: center; justify-content: space-between;
    background: linear-gradient(135deg,#1a237e 0%,#283593 100%); color: #fff;
    padding: 14px 20px;
}
.fm-page-header__left { display: flex; align-items: center; gap: 12px; }
.fm-page-header__icon {
    width: 40px; height: 40px; background: rgba(255,255,255,.12);
    border-radius: 4px; display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.fm-page-header__title { font-size: 16px; font-weight: 700; }
.fm-page-header__sub   { font-size: 12px; opacity: .75; margin-top: 2px; }

/* ---- Tab navigation ---- */
.fm-tabs { display: flex; gap: 2px; background: #f0f2f5; border-bottom: 2px solid #e0e5ed; padding: 0 20px; }
.fm-tab {
    padding: 9px 16px; font-size: 12px; font-weight: 500; color: #555;
    text-decoration: none; border-bottom: 2px solid transparent; margin-bottom: -2px;
    white-space: nowrap; display: flex; align-items: center; gap: 5px;
}
.fm-tab:hover { color: #1a237e; }
.fm-tab--active { color: #1a237e; border-bottom-color: #1a237e; font-weight: 600; }

/* ---- Content wrapper ---- */
.fn-content { padding: 16px 20px 20px; }

/* ---- KPI Hero Cards ---- */
.fn-hero { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 18px; }
.fn-kpi {
    background: #fff; border: 1px solid #e0e5ed; padding: 16px 18px;
    position: relative; overflow: hidden; transition: border-color .15s;
}
.fn-kpi:hover { border-color: #cdd3de; }
.fn-kpi::before {
    content: ''; position: absolute; left: 0; top: 0; width: 3px; height: 100%;
}
.fn-kpi--debit::before   { background: #174DA4; }
.fn-kpi--credit::before  { background: #16a34a; }
.fn-kpi--pending::before { background: #d97706; }
.fn-kpi--accounts::before { background: #05275C; }
.fn-kpi__top { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 8px; }
.fn-kpi__label {
    font-size: 10px; text-transform: uppercase; letter-spacing: .5px;
    color: #888; font-weight: 700;
}
.fn-kpi__icon {
    width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
}
.fn-kpi__icon--debit   { background: rgba(23,77,164,.07); color: #174DA4; }
.fn-kpi__icon--credit  { background: rgba(22,163,74,.07); color: #16a34a; }
.fn-kpi__icon--pending { background: rgba(217,119,6,.07); color: #d97706; }
.fn-kpi__icon--accounts { background: rgba(5,39,92,.07); color: #05275C; }
.fn-kpi__value {
    font-size: 22px; font-weight: 800; line-height: 1.1;
    font-variant-numeric: tabular-nums;
}
.fn-kpi__value--blue  { color: #174DA4; }
.fn-kpi__value--green { color: #16a34a; }
.fn-kpi__value--amber { color: #d97706; }
.fn-kpi__value--navy  { color: #05275C; }
.fn-kpi__sub {
    font-size: 10px; color: #aaa; margin-top: 6px;
    display: flex; align-items: center; gap: 4px;
}
.fn-kpi__currency { font-size: 11px; font-weight: 600; color: #999; margin-right: 2px; }

/* ---- Section headers ---- */
.fn-section-hdr {
    display: flex; align-items: center; gap: 8px; margin-bottom: 12px;
    font-size: 10px; text-transform: uppercase; letter-spacing: .8px;
    color: #888; font-weight: 700;
}
.fn-section-hdr__line { flex: 1; height: 1px; background: #e0e5ed; }

/* ---- Two-column layout ---- */
.fn-two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }

/* ---- Shared card/table ---- */
.fs-card         { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 16px; }
.fs-card__header { display: flex; align-items: center; justify-content: space-between; padding: 11px 16px; border-bottom: 1px solid #e0e5ed; background: #f5f7fa; }
.fs-card__title  { font-size: 12px; font-weight: 600; color: #1a1a2e; display: flex; align-items: center; gap: 6px; }
.fs-card__meta   { font-size: 11px; color: #888; }
.fs-table          { width: 100%; border-collapse: collapse; font-size: 11px; }
.fs-table thead tr { background: #f5f7fa; }
.fs-table th {
    padding: 8px 12px; text-align: left; font-size: 10px; font-weight: 600;
    text-transform: uppercase; letter-spacing: .4px; color: #555;
    border-bottom: 2px solid #e0e5ed; white-space: nowrap;
}
.fs-table td { padding: 9px 12px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; vertical-align: middle; }
.fs-table tbody tr:hover td { background: #f9fafc; }
.fs-table tbody tr:last-child td { border-bottom: none; }

/* ---- Badges ---- */
.fs-badge            { font-size: 10px; font-weight: 600; padding: 3px 7px; text-transform: uppercase; letter-spacing: .3px; display: inline-block; }
.fs-badge--green     { background: #e6f4ea; color: #155724; border: 1px solid #c3e6cb; }
.fs-badge--amber     { background: #fff8e1; color: #b45309; border: 1px solid #fcd34d; }
.fs-badge--red       { background: #fef5f5; color: #dc3545; border: 1px solid #f5c6cb; }
.fs-badge--primary   { background: rgba(5,39,92,.08); color: #05275C; border: 1px solid rgba(5,39,92,.2); }
.fs-code {
    font-family: Consolas, "Courier New", monospace; font-size: 11px; font-weight: 600;
    background: rgba(23,77,164,.07); border: 1px solid rgba(23,77,164,.15);
    color: #174DA4; padding: 2px 6px;
}

/* ---- Alert bars ---- */
.fn-alert { padding: 10px 14px; border-left: 3px solid; margin-bottom: 8px; font-size: 12px; display: flex; align-items: center; gap: 8px; }
.fn-alert--warning { border-color: #d97706; background: #fffbeb; color: #92400e; }
.fn-alert--info    { border-color: #174DA4; background: #eff6ff; color: #05275C; }
.fn-alert--danger  { border-color: #dc3545; background: #fef5f5; color: #991b1b; }
.fn-alert strong   { font-weight: 700; }
.fn-alert svg      { flex-shrink: 0; }

/* ---- Period row ---- */
.fn-period-row {
    display: flex; align-items: center; justify-content: space-between;
    padding: 8px 0; border-bottom: 1px solid #f0f2f5;
}
.fn-period-row:last-child { border-bottom: none; }
.fn-period-row__year { font-size: 12px; font-weight: 600; color: #1a1a2e; }
.fn-period-row__dates { font-size: 11px; color: #888; }

/* ---- Entrance animation ---- */
@keyframes fnFadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
.fn-hero > * { animation: fnFadeIn .35s ease both; }
.fn-hero > *:nth-child(2) { animation-delay: .05s; }
.fn-hero > *:nth-child(3) { animation-delay: .1s; }
.fn-hero > *:nth-child(4) { animation-delay: .15s; }

/* ---- Print button ---- */
.fn-print-btn {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 6px 14px; border: 1px solid rgba(255,255,255,.25);
    background: rgba(255,255,255,.08); color: #fff;
    font-size: 11px; font-weight: 600; cursor: pointer;
    border-radius: 0; transition: background .15s; font-family: inherit;
}
.fn-print-btn:hover { background: rgba(255,255,255,.18); }

/* ---- Responsive ---- */
@media (max-width: 1000px) {
    .fn-hero    { grid-template-columns: repeat(2,1fr); }
    .fn-two-col { grid-template-columns: 1fr; }
}
@media (max-width: 700px) {
    .fn-content  { padding: 12px; }
    .fn-hero     { grid-template-columns: 1fr; }
    .fm-tabs     { overflow-x: auto; }
    .fm-tab      { padding: 8px 12px; font-size: 11px; }
}
@media print {
    .fm-tabs, .fn-print-btn { display: none !important; }
    .fm-page-header { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .fn-content { padding: 10px !important; }
    .fn-hero { grid-template-columns: repeat(4,1fr) !important; }
    .fn-two-col { grid-template-columns: 1fr 1fr !important; }
}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- ======= PAGE HEADER =========================================== -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Finance Dashboard</div>
            <div class="fm-page-header__sub">General ledger overview &amp; journal activity</div>
        </div>
    </div>
    <div style="display:flex;align-items:center;gap:10px;">
        <asp:Literal ID="litPeriodBadge" runat="server" />
        <button type="button" class="fn-print-btn" onclick="window.print();" title="Print">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print
        </button>
    </div>
</div>

<!-- ======= TAB NAVIGATION ======================================== -->
<div class="fm-tabs">
    <a class="fm-tab fm-tab--active" href="FinanceDashboard.aspx">Dashboard</a>
    <a class="fm-tab" href="GeneralLedger.aspx">General Ledger</a>
    <a class="fm-tab" href="JournalEntries.aspx">Journals</a>
    <a class="fm-tab" href="PaymentVouchers.aspx">Payment Vouchers</a>
    <a class="fm-tab" href="ContraVouchers.aspx">Contra Vouchers</a>
    <a class="fm-tab" href="BudgetManager.aspx">Budget</a>
    <a class="fm-tab" href="CashBook.aspx">Cash Book</a>
    <a class="fm-tab" href="BankReconciliation.aspx">Bank Reco</a>
    <a class="fm-tab" href="TrialBalance.aspx">Trial Balance</a>
    <a class="fm-tab" href="BalanceSheet.aspx">Balance Sheet</a>
    <a class="fm-tab" href="IncomeStatement.aspx">Income Statement</a>
    <a class="fm-tab" href="FinancialPeriods.aspx">Periods</a>
    <a class="fm-tab" href="FinanceAuditTrail.aspx">Audit Trail</a>
</div>

<div class="fn-content">

<!-- ======= HERO KPI CARDS ======================================== -->
<div class="fn-hero">
    <!-- Total Debits -->
    <div class="fn-kpi fn-kpi--debit">
        <div class="fn-kpi__top">
            <div class="fn-kpi__label">Total Debits</div>
            <div class="fn-kpi__icon fn-kpi__icon--debit">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
            </div>
        </div>
        <div class="fn-kpi__value fn-kpi__value--blue"><span class="fn-kpi__currency">UGX</span><asp:Label ID="lblTotalDR" runat="server" Text="0" /></div>
        <div class="fn-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
            current open period
        </div>
    </div>
    <!-- Total Credits -->
    <div class="fn-kpi fn-kpi--credit">
        <div class="fn-kpi__top">
            <div class="fn-kpi__label">Total Credits</div>
            <div class="fn-kpi__icon fn-kpi__icon--credit">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/><polyline points="17 18 23 18 23 12"/></svg>
            </div>
        </div>
        <div class="fn-kpi__value fn-kpi__value--green"><span class="fn-kpi__currency">UGX</span><asp:Label ID="lblTotalCR" runat="server" Text="0" /></div>
        <div class="fn-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
            current open period
        </div>
    </div>
    <!-- Unposted Journals -->
    <div class="fn-kpi fn-kpi--pending">
        <div class="fn-kpi__top">
            <div class="fn-kpi__label">Unposted Journals</div>
            <div class="fn-kpi__icon fn-kpi__icon--pending">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
        </div>
        <div class="fn-kpi__value fn-kpi__value--amber"><asp:Label ID="lblUnpostedJournals" runat="server" Text="0" /></div>
        <div class="fn-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
            pending approval &amp; posting
        </div>
    </div>
    <!-- Chart of Accounts -->
    <div class="fn-kpi fn-kpi--accounts">
        <div class="fn-kpi__top">
            <div class="fn-kpi__label">Chart of Accounts</div>
            <div class="fn-kpi__icon fn-kpi__icon--accounts">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            </div>
        </div>
        <div class="fn-kpi__value fn-kpi__value--navy"><asp:Label ID="lblTotalAccounts" runat="server" Text="0" /></div>
        <div class="fn-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            sub-accounts in ledger
        </div>
    </div>
</div>

<!-- ======= PERIOD STATUS & ALERTS ================================ -->
<div class="fn-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
    System Status
    <span class="fn-section-hdr__line"></span>
</div>
<div class="fn-two-col">
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Financial Periods
            </div>
            <div class="fs-card__meta">last 5 periods</div>
        </div>
        <div style="padding:14px 16px;">
            <asp:Label ID="lblCurrentPeriod" runat="server" Text="" />
            <asp:Repeater ID="rptPeriods" runat="server">
                <ItemTemplate>
                    <div class="fn-period-row">
                        <div class="fn-period-row__year"><%# Eval("finacial_Year") %></div>
                        <div class="fn-period-row__dates"><%# Eval("start_date", "{0:dd MMM yyyy}") %> &mdash; <%# Eval("end_date", "{0:dd MMM yyyy}") %></div>
                        <span class='fs-badge <%# Eval("status").ToString() == "Open" ? "fs-badge--green" : "fs-badge--red" %>'><%# Eval("status") %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                Alerts &amp; Notices
            </div>
        </div>
        <div style="padding:14px 16px;">
            <asp:Panel ID="pnlAlerts" runat="server">
                <asp:Literal ID="litAlerts" runat="server" />
            </asp:Panel>
        </div>
    </div>
</div>

<!-- ======= RECENT JOURNALS ======================================= -->
<div class="fn-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
    Recent Journal Activity
    <span class="fn-section-hdr__line"></span>
</div>
<div class="fs-card">
    <div class="fs-card__header">
        <div class="fs-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            Last 20 Journals
        </div>
        <div class="fs-card__meta"><asp:Literal ID="litJournalCount" runat="server" Text="" /></div>
    </div>
    <div style="overflow-x:auto;">
        <table class="fs-table">
            <thead><tr>
                <th>J.No</th><th>Type</th><th>Date</th><th>Reference</th>
                <th>Particulars</th><th>Voucher</th>
                <th style="text-align:right">Total DR</th>
                <th style="text-align:right">Total CR</th>
                <th>Created By</th><th>Status</th>
            </tr></thead>
            <tbody><asp:Literal ID="litRecentJournalRows" runat="server" /></tbody>
        </table>
    </div>
</div>

</div><!-- /fn-content -->
</asp:Content>
