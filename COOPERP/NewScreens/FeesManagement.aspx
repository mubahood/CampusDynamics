<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesManagement.aspx.cs" Inherits="COOPERP_NewScreens_FeesManagement" Title="Fees Management Dashboard - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== FEES MANAGEMENT DASHBOARD ======================================= */

/* ── Page Header ─────────────────────────────────── */
.fm-page-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 14px 0 12px; margin-bottom: 16px;
    border-bottom: 2px solid #174DA4;
    flex-wrap: wrap; gap: 10px;
}
.fm-page-header__left { display: flex; align-items: center; gap: 12px; min-width: 0; }
.fm-page-header__icon {
    width: 42px; height: 42px;
    background: linear-gradient(135deg, #00695c 0%, #00897b 100%);
    display: flex; align-items: center; justify-content: center;
    border-radius: 10px; flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(0,105,92,.2);
}
.fm-page-header__title { font-size: 18px; font-weight: 800; color: #1a1a2e; margin: 0; line-height: 1.2; letter-spacing: -.2px; }
.fm-page-header__sub   { font-size: 11px; color: #999; margin-top: 2px; }

/* ── Tab Navigation ──────────────────────────────── */
.fm-tabs {
    display: flex; gap: 0; border-bottom: 2px solid #e4e8f0;
    margin-bottom: 16px; overflow-x: auto;
}
.fm-tab {
    padding: 10px 20px; font-size: 12px; font-weight: 600;
    color: #777; cursor: pointer; border: none; background: none;
    border-bottom: 2px solid transparent; margin-bottom: -2px;
    white-space: nowrap; display: flex; align-items: center; gap: 6px;
    transition: all .15s;
}
.fm-tab:hover { color: #174DA4; background: rgba(23,77,164,.03); }
.fm-tab--active {
    color: #174DA4; border-bottom-color: #174DA4;
    font-weight: 700;
}
.fm-tab__badge {
    font-size: 9px; font-weight: 700; background: rgba(23,77,164,.08);
    color: #174DA4; padding: 2px 7px; border-radius: 10px;
}

/* ── Stats Dashboard ─────────────────────────────── */
.fm-hero-row {
    display: grid; grid-template-columns: repeat(4, 1fr);
    gap: 12px; margin-bottom: 16px;
}
.fm-hero {
    background: #fff; border: 1px solid #e4e8f0;
    padding: 18px 20px; border-radius: 10px;
    position: relative; overflow: hidden;
    transition: all .2s cubic-bezier(.4,0,.2,1);
}
.fm-hero::after {
    content: ''; position: absolute;
    left: 0; top: 0; bottom: 0; width: 4px;
    background: var(--hero-accent, #ccc);
    border-radius: 10px 0 0 10px;
}
.fm-hero:hover { box-shadow: 0 4px 20px rgba(0,0,0,.06); transform: translateY(-2px); }
.fm-hero__label { font-size: 10px; text-transform: uppercase; letter-spacing: .6px; color: #999; font-weight: 600; margin-bottom: 6px; }
.fm-hero__val { font-size: 26px; font-weight: 800; line-height: 1.1; font-variant-numeric: tabular-nums; }
.fm-hero__sub { font-size: 11px; color: #888; margin-top: 4px; display: flex; align-items: center; gap: 4px; }
.fm-hero__sub svg { width: 12px; height: 12px; }
.fm-hero--billed   { --hero-accent: #00897b; } .fm-hero--billed   .fm-hero__val { color: #00695c; }
.fm-hero--paid     { --hero-accent: #2e7d32; } .fm-hero--paid     .fm-hero__val { color: #2e7d32; }
.fm-hero--balance  { --hero-accent: #e65100; } .fm-hero--balance  .fm-hero__val { color: #e65100; }
.fm-hero--students { --hero-accent: #174DA4; } .fm-hero--students .fm-hero__val { color: #174DA4; }

/* ── Semester Drill-down  ────────────────────────── */
.fm-section { margin-bottom: 16px; }
.fm-section__header {
    display: flex; align-items: center; gap: 8px; margin-bottom: 10px;
    font-size: 10px; text-transform: uppercase; letter-spacing: .8px;
    color: #aaa; font-weight: 700;
}
.fm-section__line { flex: 1; height: 1px; background: #eef0f4; }

.fm-breakdown-grid {
    display: grid; grid-template-columns: repeat(3, 1fr);
    gap: 10px;
}
.fm-semester-card {
    background: #fff; border: 1px solid #e4e8f0; border-radius: 10px;
    padding: 16px 18px; transition: box-shadow .2s;
}
.fm-semester-card:hover { box-shadow: 0 3px 14px rgba(0,0,0,.05); }
.fm-semester-card__head {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 10px;
}
.fm-semester-card__title { font-size: 12px; font-weight: 700; color: #1a1a2e; }
.fm-semester-card__badge { font-size: 9px; font-weight: 700; padding: 2px 8px; border-radius: 4px; }
.fm-semester-card__badge--ok { background: #e6f4ea; color: #155724; }
.fm-semester-card__badge--warn { background: #fff3cd; color: #856404; }
.fm-row { display: flex; justify-content: space-between; align-items: center; padding: 5px 0; font-size: 11px; }
.fm-row__label { color: #888; }
.fm-row__val { font-weight: 700; color: #333; font-variant-numeric: tabular-nums; }
.fm-row__val--green { color: #2e7d32; }
.fm-row__val--red   { color: #dc3545; }
.fm-row__val--amber { color: #e65100; }

/* Progress bar */
.fm-progress { height: 6px; background: #eef1f5; border-radius: 3px; margin-top: 8px; overflow: hidden; }
.fm-progress__fill { height: 100%; border-radius: 3px; transition: width .8s cubic-bezier(.4,0,.2,1); }
.fm-progress__fill--green { background: linear-gradient(90deg, #66bb6a, #2e7d32); }
.fm-progress__fill--amber { background: linear-gradient(90deg, #ffb74d, #e65100); }
.fm-progress__fill--red   { background: linear-gradient(90deg, #ef5350, #c62828); }
.fm-progress-label { font-size: 9px; color: #999; margin-top: 3px; text-align: right; font-weight: 600; }

/* ── Billing Items Table ─────────────────────────── */
.fm-table-card {
    background: #fff; border: 1px solid #e4e8f0;
    border-radius: 10px; overflow: hidden;
    box-shadow: 0 1px 4px rgba(0,0,0,.03);
}
.fm-table-card__header {
    padding: 12px 16px; border-bottom: 1px solid #e4e8f0; background: #fafbfc;
    display: flex; align-items: center; justify-content: space-between;
}
.fm-table-card__title { font-size: 13px; font-weight: 700; color: #1a1a2e; display: flex; align-items: center; gap: 6px; }
.fm-table-card__meta { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.06); padding: 3px 10px; border-radius: 10px; }

.fm-table { width: 100%; border-collapse: collapse; }
.fm-table th {
    font-size: 10px; text-transform: uppercase; letter-spacing: .4px;
    color: #888; font-weight: 600; padding: 10px 14px; text-align: left;
    border-bottom: 2px solid #e8ecf2; background: #f8f9fb;
}
.fm-table td {
    font-size: 11px; padding: 9px 14px; color: #333;
    border-bottom: 1px solid #f2f3f5; vertical-align: middle;
}
.fm-table tbody tr:hover td { background: #f5f8ff; }
.fm-table .fm-code { font-family: 'Courier New', monospace; font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.06); padding: 2px 6px; border-radius: 3px; }

/* ── Year Trend Table ────────────────────────────── */
.fm-trend-grid {
    display: grid; grid-template-columns: 1fr 1fr;
    gap: 14px;
}

/* ── Filter Bar ──────────────────────────────────── */
.fm-filter-bar {
    display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap;
    padding: 10px 0; margin-bottom: 8px;
}
.fm-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.fm-filter-grp__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #999; font-weight: 600; }
.fm-filter-select {
    border: 1px solid #dde1e6; border-radius: 8px;
    padding: 6px 10px; font-size: 11px; background: #fff; color: #333;
    cursor: pointer; min-width: 130px;
    transition: border-color .15s, box-shadow .15s;
}
.fm-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 3px rgba(23,77,164,.08); outline: none; }

/* ── Responsive ──────────────────────────────────── */
@media (max-width: 1100px) {
    .fm-hero-row { grid-template-columns: repeat(2, 1fr); }
    .fm-breakdown-grid { grid-template-columns: 1fr 1fr; }
    .fm-trend-grid { grid-template-columns: 1fr; }
}
@media (max-width: 700px) {
    .fm-hero-row { grid-template-columns: 1fr; }
    .fm-breakdown-grid { grid-template-columns: 1fr; }
    .fm-tabs { gap: 0; }
    .fm-tab { padding: 8px 14px; font-size: 11px; }
    .fm-anomaly-row { grid-template-columns: 1fr; }
}

/* ── Anomaly Alerts ──────────────────────────────── */
.fm-anomaly-row {
    display: grid; grid-template-columns: repeat(3, 1fr);
    gap: 12px; margin-bottom: 16px;
}
.fm-anomaly {
    background: #fff; border: 1px solid #e4e8f0;
    padding: 16px 18px; border-radius: 10px;
    position: relative; overflow: hidden;
    transition: all .2s cubic-bezier(.4,0,.2,1);
}
.fm-anomaly::after {
    content: ''; position: absolute;
    left: 0; top: 0; bottom: 0; width: 4px;
    border-radius: 10px 0 0 10px;
}
.fm-anomaly:hover { box-shadow: 0 4px 20px rgba(0,0,0,.06); transform: translateY(-2px); }
.fm-anomaly__icon { width: 36px; height: 36px; border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px; }
.fm-anomaly__label { font-size: 10px; text-transform: uppercase; letter-spacing: .6px; color: #999; font-weight: 600; margin-bottom: 4px; }
.fm-anomaly__val { font-size: 22px; font-weight: 800; line-height: 1.1; margin-bottom: 4px; }
.fm-anomaly__hint { font-size: 10px; color: #999; line-height: 1.4; }
.fm-anomaly--warn    { border-color: #ffe0b2; } .fm-anomaly--warn::after { background: #e65100; }
.fm-anomaly--warn .fm-anomaly__val { color: #e65100; }
.fm-anomaly--warn .fm-anomaly__icon { background: #fff3e0; }
.fm-anomaly--danger  { border-color: #ffcdd2; } .fm-anomaly--danger::after { background: #dc3545; }
.fm-anomaly--danger .fm-anomaly__val { color: #dc3545; }
.fm-anomaly--danger .fm-anomaly__icon { background: #ffebee; }
.fm-anomaly--ok      { border-color: #c8e6c9; } .fm-anomaly--ok::after { background: #2e7d32; }
.fm-anomaly--ok .fm-anomaly__val { color: #2e7d32; }
.fm-anomaly--ok .fm-anomaly__icon { background: #e8f5e9; }

/* ── Paid but Unregistered Table ─────────────────── */
.fm-paid-unreg-badge {
    display: inline-block; font-size: 9px; font-weight: 700;
    padding: 2px 8px; border-radius: 4px;
}
.fm-paid-unreg-badge--unreg { background: #ffebee; color: #dc3545; }
.fm-paid-unreg-badge--other { background: #fff3e0; color: #e65100; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══════ PAGE HEADER ═══════════════════════════════════════════════ -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Fees Management</div>
            <div class="fm-page-header__sub">Billing, payments, fee structures &amp; student account overview</div>
        </div>
    </div>
    <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
        <asp:Literal ID="litAcadContext" runat="server" />
    </div>
</div>

<!-- ═══════ TAB NAVIGATION ═══════════════════════════════════════════ -->
<div class="fm-tabs">
    <a class="fm-tab fm-tab--active" href="FeesManagement.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
        Dashboard
    </a>
    <a class="fm-tab" href="FeesTransactions.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        Transactions
    </a>
    <a class="fm-tab" href="FeesStructure.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
        Fee Structure &amp; Settings
    </a>
    <a class="fm-tab" href="FeesRegistration.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        Registration
    </a>
</div>

<!-- ═══════ FILTERS ═══════════════════════════════════════════════════ -->
<div class="fm-filter-bar">
    <div class="fm-filter-grp">
        <label class="fm-filter-grp__label">Academic Year</label>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="fm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
    </div>
    <div class="fm-filter-grp">
        <label class="fm-filter-grp__label">Billing System</label>
        <asp:DropDownList ID="ddlBillingSystem" runat="server" CssClass="fm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBillingSystem_SelectedIndexChanged">
            <asp:ListItem Value="" Text="All Systems" />
        </asp:DropDownList>
    </div>
</div>

<!-- ═══════ HERO STATS ═══════════════════════════════════════════════ -->
<div class="fm-hero-row">
    <div class="fm-hero fm-hero--billed">
        <div class="fm-hero__label">Total Billed</div>
        <div class="fm-hero__val"><asp:Literal ID="litTotalBilled" runat="server" Text="0" /></div>
        <div class="fm-hero__sub">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"></path></svg>
            <asp:Literal ID="litBillCount" runat="server" Text="0 invoices" />
        </div>
    </div>
    <div class="fm-hero fm-hero--paid">
        <div class="fm-hero__label">Total Paid</div>
        <div class="fm-hero__val"><asp:Literal ID="litTotalPaid" runat="server" Text="0" /></div>
        <div class="fm-hero__sub">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            <asp:Literal ID="litPayCount" runat="server" Text="0 payments" />
        </div>
    </div>
    <div class="fm-hero fm-hero--balance">
        <div class="fm-hero__label">Outstanding Balance</div>
        <div class="fm-hero__val"><asp:Literal ID="litBalance" runat="server" Text="0" /></div>
        <div class="fm-hero__sub">
            <asp:Literal ID="litCollectionRate" runat="server" Text="0% collection rate" />
        </div>
    </div>
    <div class="fm-hero fm-hero--students">
        <div class="fm-hero__label">Students Billed</div>
        <div class="fm-hero__val"><asp:Literal ID="litStudentsBilled" runat="server" Text="0" /></div>
        <div class="fm-hero__sub">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
            <asp:Literal ID="litStudentsUnbilled" runat="server" Text="0 not billed" />
        </div>
    </div>
</div>

<!-- ═══════ SEMESTER BREAKDOWN ═══════════════════════════════════════ -->
<div class="fm-section">
    <div class="fm-section__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
        Semester Breakdown
        <span class="fm-section__line"></span>
    </div>
    <div class="fm-breakdown-grid">
        <asp:Literal ID="litSemesterCards" runat="server" />
    </div>
</div>

<!-- ═══════ TABLES ROW ═══════════════════════════════════════════════ -->
<div class="fm-trend-grid">
    <!-- Billing Items Summary -->
    <div class="fm-table-card">
        <div class="fm-table-card__header">
            <div class="fm-table-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                Billing Items Revenue
            </div>
            <div class="fm-table-card__meta"><asp:Literal ID="litItemCount" runat="server" Text="0 items" /></div>
        </div>
        <div style="overflow-x:auto;">
            <table class="fm-table">
                <thead><tr><th>Item</th><th>Account</th><th style="text-align:right">Billed</th><th style="text-align:right">Paid</th></tr></thead>
                <tbody>
                    <asp:Literal ID="litItemRows" runat="server" />
                </tbody>
            </table>
        </div>
    </div>

    <!-- Year Trend -->
    <div class="fm-table-card">
        <div class="fm-table-card__header">
            <div class="fm-table-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                Year-over-Year Trend
            </div>
        </div>
        <div style="overflow-x:auto;">
            <table class="fm-table">
                <thead><tr><th>Academic Year</th><th style="text-align:right">Billed</th><th style="text-align:right">Paid</th><th style="text-align:right">Collection %</th></tr></thead>
                <tbody>
                    <asp:Literal ID="litYearRows" runat="server" />
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ═══════ TOP DEBTORS ═════════════════════════════════════════════ -->
<div class="fm-section" style="margin-top:16px;">
    <div class="fm-section__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        Top 15 Outstanding Balances
        <span class="fm-section__line"></span>
    </div>
    <div class="fm-table-card">
        <div style="overflow-x:auto;">
            <table class="fm-table">
                <thead><tr><th>Reg No</th><th>Student Name</th><th>Programme</th><th style="text-align:right">Billed</th><th style="text-align:right">Paid</th><th style="text-align:right">Balance</th></tr></thead>
                <tbody>
                    <asp:Literal ID="litDebtorRows" runat="server" />
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ═══════ BILLING ANOMALIES ═══════════════════════════════════════ -->
<div class="fm-section" style="margin-top:16px;">
    <div class="fm-section__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
        Billing Anomalies &amp; Data Integrity
        <span class="fm-section__line"></span>
    </div>
    <div class="fm-anomaly-row">
        <asp:Literal ID="litAnomalyCards" runat="server" />
    </div>
</div>

<!-- ═══════ PAID BUT UNREGISTERED ═══════════════════════════════════ -->
<asp:Panel ID="pnlPaidUnregistered" runat="server" Visible="false">
<div class="fm-section" style="margin-top:16px;">
    <div class="fm-section__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        Paid in Last 30 Days but Not Registered (Current Semester)
        <span class="fm-section__line"></span>
    </div>
    <div class="fm-table-card">
        <div class="fm-table-card__header">
            <div class="fm-table-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="23" y1="11" x2="17" y2="11"></line></svg>
                Students with Payments but No Registration
            </div>
            <div class="fm-table-card__meta"><asp:Literal ID="litPaidUnregCount" runat="server" Text="0 students" /></div>
        </div>
        <div style="overflow-x:auto; max-height:400px; overflow-y:auto;">
            <table class="fm-table">
                <thead><tr>
                    <th>Reg No</th><th>Student Name</th><th>Programme</th>
                    <th style="text-align:right">Total Paid (30d)</th><th>Status</th><th>Last Payment</th>
                </tr></thead>
                <tbody>
                    <asp:Literal ID="litPaidUnregRows" runat="server" />
                </tbody>
            </table>
        </div>
    </div>
</div>
</asp:Panel>

</asp:Content>
