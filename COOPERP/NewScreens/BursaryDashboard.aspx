<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BursaryDashboard.aspx.cs" Inherits="COOPERP_NewScreens_BursaryDashboard" Title="Bursary Dashboard - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===================================================================
   BURSARY DASHBOARD — Campus Dynamics ERP
   Prefix: bd- (bursary dashboard)
   =================================================================== */

/* ---- Page Header ---- */
.bd-page-header {
    display:flex; align-items:center; justify-content:space-between;
    background:#05275C; color:#fff; padding:14px 20px;
    border-bottom:3px solid #041d45;
}
.bd-page-header__left { display:flex; align-items:center; gap:12px; }
.bd-page-header__icon {
    width:40px; height:40px; background:rgba(255,255,255,.12);
    border-radius:4px; display:flex; align-items:center; justify-content:center; flex-shrink:0;
}
.bd-page-header__title { font-size:16px; font-weight:700; }
.bd-page-header__sub   { font-size:12px; opacity:.75; margin-top:2px; }
.bd-year-switcher {
    display:flex; align-items:center; gap:8px;
}
.bd-year-switcher label { font-size:11px; opacity:.8; font-weight:600; white-space:nowrap; }
.bd-year-select {
    padding:5px 10px; font-size:12px; font-weight:600;
    background:rgba(255,255,255,.12); color:#fff; border:1px solid rgba(255,255,255,.25);
    cursor:pointer; min-width:110px;
}
.bd-year-select option { color:#1a1a2e; background:#fff; }
.bd-year-select:focus { outline:none; border-color:rgba(255,255,255,.5); }
.bd-print-btn {
    display:inline-flex; align-items:center; gap:5px; padding:6px 14px;
    border:1px solid rgba(255,255,255,.25); background:rgba(255,255,255,.08);
    color:#fff; font-size:11px; font-weight:600; cursor:pointer; transition:background .15s; font-family:inherit;
}
.bd-print-btn:hover { background:rgba(255,255,255,.18); }

/* ---- Tab Navigation ---- */
.bd-tabs { display:flex; gap:2px; background:#f0f2f5; border-bottom:2px solid #e0e5ed; padding:0 20px; }
.bd-tab {
    padding:9px 16px; font-size:12px; font-weight:500; color:#555;
    text-decoration:none; border-bottom:2px solid transparent; margin-bottom:-2px;
    white-space:nowrap; display:flex; align-items:center; gap:5px;
}
.bd-tab:hover { color:#05275C; }
.bd-tab--active { color:#05275C; border-bottom-color:#05275C; font-weight:600; }

/* ---- Content ---- */
.bd-content { padding:16px 20px 24px; }

/* ---- KPI Hero Cards ---- */
.bd-hero { display:grid; grid-template-columns:repeat(5,1fr); gap:12px; margin-bottom:18px; }
.bd-kpi {
    background:#fff; border:1px solid #e0e5ed; padding:16px 18px;
    position:relative; overflow:hidden; transition:border-color .15s;
}
.bd-kpi:hover { border-color:#cdd3de; }
.bd-kpi::before { content:''; position:absolute; left:0; top:0; width:3px; height:100%; }
.bd-kpi--total::before    { background:#174DA4; }
.bd-kpi--amount::before   { background:#00897b; }
.bd-kpi--schemes::before  { background:#6d28d9; }
.bd-kpi--approved::before { background:#16a34a; }
.bd-kpi--pending::before  { background:#d97706; }
.bd-kpi__top { display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:8px; }
.bd-kpi__label { font-size:10px; text-transform:uppercase; letter-spacing:.5px; color:#888; font-weight:700; }
.bd-kpi__icon { width:32px; height:32px; display:flex; align-items:center; justify-content:center; }
.bd-kpi__icon--total    { background:rgba(23,77,164,.07); color:#174DA4; }
.bd-kpi__icon--amount   { background:rgba(0,137,123,.07); color:#00897b; }
.bd-kpi__icon--schemes  { background:rgba(109,40,217,.07); color:#6d28d9; }
.bd-kpi__icon--approved { background:rgba(22,163,74,.07); color:#16a34a; }
.bd-kpi__icon--pending  { background:rgba(217,119,6,.07); color:#d97706; }
.bd-kpi__value { font-size:22px; font-weight:800; line-height:1.1; font-variant-numeric:tabular-nums; }
.bd-kpi__value--blue   { color:#174DA4; }
.bd-kpi__value--teal   { color:#00695c; }
.bd-kpi__value--purple { color:#6d28d9; }
.bd-kpi__value--green  { color:#16a34a; }
.bd-kpi__value--amber  { color:#d97706; }
.bd-kpi__currency { font-size:11px; font-weight:600; color:#999; margin-right:2px; }
.bd-kpi__sub { font-size:10px; color:#aaa; margin-top:6px; display:flex; align-items:center; gap:4px; }
.bd-kpi__trend { font-size:10px; font-weight:700; padding:2px 6px; display:inline-flex; align-items:center; gap:3px; }
.bd-kpi__trend--up   { background:#e6f4ea; color:#16a34a; }
.bd-kpi__trend--down { background:#fef5f5; color:#dc3545; }
.bd-kpi__trend--flat { background:#f0f2f5; color:#888; }

/* ---- Section headers ---- */
.bd-section-hdr {
    display:flex; align-items:center; gap:8px; margin-bottom:12px;
    font-size:10px; text-transform:uppercase; letter-spacing:.8px; color:#888; font-weight:700;
}
.bd-section-hdr__line { flex:1; height:1px; background:#e0e5ed; }

/* ---- Grid layout ---- */
.bd-two-col   { display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:18px; }
.bd-three-col { display:grid; grid-template-columns:1fr 1fr 1fr; gap:14px; margin-bottom:18px; }
.bd-full      { margin-bottom:18px; }

/* ---- Cards ---- */
.bd-card { background:#fff; border:1px solid #e0e5ed; overflow:hidden; }
.bd-card__header { display:flex; align-items:center; justify-content:space-between; padding:11px 16px; border-bottom:1px solid #e0e5ed; background:#f5f7fa; }
.bd-card__title  { font-size:12px; font-weight:600; color:#1a1a2e; display:flex; align-items:center; gap:6px; }
.bd-card__meta   { font-size:11px; color:#888; }
.bd-card__body   { padding:14px 16px; }

/* ---- Chart containers ---- */
.bd-chart-wrap { padding:16px; position:relative; height:240px; }
.bd-chart-wrap.bd-chart-wrap--sm { height:200px; }
.bd-chart-wrap canvas { display:block; width:100% !important; height:100% !important; }

/* ---- Table ---- */
.bd-table { width:100%; border-collapse:collapse; font-size:11px; }
.bd-table thead tr { background:#f5f7fa; }
.bd-table th {
    padding:8px 12px; text-align:left; font-size:10px; font-weight:600;
    text-transform:uppercase; letter-spacing:.4px; color:#555;
    border-bottom:2px solid #e0e5ed; white-space:nowrap;
}
.bd-table th.r, .bd-table td.r { text-align:right; }
.bd-table th.c, .bd-table td.c { text-align:center; }
.bd-table td { padding:9px 12px; border-bottom:1px solid #f0f2f5; color:#1a1a2e; vertical-align:middle; }
.bd-table tbody tr:hover td { background:#f9fafc; }
.bd-table tbody tr:last-child td { border-bottom:none; }
.bd-table__empty { text-align:center; color:#aaa; padding:24px; font-size:12px; }

/* ---- Scheme color dots ---- */
.bd-dot { width:10px; height:10px; border-radius:50%; display:inline-block; flex-shrink:0; }

/* ---- Badges ---- */
.bd-badge { font-size:10px; font-weight:600; padding:3px 8px; text-transform:uppercase; letter-spacing:.3px; display:inline-block; }
.bd-badge--approved { background:#e6f4ea; color:#155724; border:1px solid #c3e6cb; }
.bd-badge--pending  { background:#fff8e1; color:#b45309; border:1px solid #fcd34d; }
.bd-badge--rejected { background:#fef5f5; color:#dc3545; border:1px solid #f5c6cb; }
.bd-badge--active   { background:rgba(23,77,164,.07); color:#05275C; border:1px solid rgba(23,77,164,.18); }

/* ---- Progress bar ---- */
.bd-progress { height:6px; background:#f0f2f5; border-radius:3px; overflow:hidden; min-width:60px; }
.bd-progress__fill { height:100%; border-radius:3px; transition:width .4s ease; }

/* ---- Year badges in trend table ---- */
.bd-year-badge { font-size:11px; font-weight:700; color:#05275C; background:rgba(5,39,92,.07); padding:3px 8px; display:inline-block; }
.bd-year-badge--current { background:#05275C; color:#fff; }

/* ---- Summary highlight row ---- */
.bd-table tbody tr.bd-tr--total td { background:#f0f4ff; font-weight:700; color:#05275C; border-top:2px solid #e0e5ed; }

/* ---- Empty state ---- */
.bd-empty { text-align:center; padding:40px 20px; color:#aaa; }
.bd-empty svg { opacity:.3; margin-bottom:10px; }
.bd-empty p { font-size:13px; }

/* ---- Animation ---- */
@keyframes bdFadeIn { from { opacity:0; transform:translateY(6px); } to { opacity:1; transform:translateY(0); } }
.bd-hero > * { animation:bdFadeIn .35s ease both; }
.bd-hero > *:nth-child(1) { animation-delay:.00s; }
.bd-hero > *:nth-child(2) { animation-delay:.05s; }
.bd-hero > *:nth-child(3) { animation-delay:.10s; }
.bd-hero > *:nth-child(4) { animation-delay:.15s; }
.bd-hero > *:nth-child(5) { animation-delay:.20s; }

/* ---- Responsive ---- */
@media (max-width:1100px) {
    .bd-hero      { grid-template-columns:repeat(3,1fr); }
    .bd-two-col   { grid-template-columns:1fr; }
    .bd-three-col { grid-template-columns:1fr 1fr; }
}
@media (max-width:700px) {
    .bd-hero      { grid-template-columns:repeat(2,1fr); }
    .bd-three-col { grid-template-columns:1fr; }
    .bd-content   { padding:12px; }
    .bd-tabs      { overflow-x:auto; }
    .bd-year-switcher label { display:none; }
}
@media print {
    .bd-tabs, .bd-print-btn, .bd-year-switcher { display:none !important; }
    .bd-page-header { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    .bd-content { padding:10px !important; }
    .bd-hero { grid-template-columns:repeat(5,1fr) !important; }
    .bd-two-col   { grid-template-columns:1fr 1fr !important; }
    .bd-three-col { grid-template-columns:1fr 1fr 1fr !important; }
}
</style>
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ======= PAGE HEADER ================================================ -->
<div class="bd-page-header">
    <div class="bd-page-header__left">
        <div class="bd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
        <div>
            <div class="bd-page-header__title">Bursary &amp; Scholarship Dashboard</div>
            <div class="bd-page-header__sub"><asp:Literal ID="litHeaderSub" runat="server" Text="Loading..." /></div>
        </div>
    </div>
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
        <div class="bd-year-switcher">
            <label>Academic Year:</label>
            <asp:DropDownList ID="ddlYear" runat="server" CssClass="bd-year-select" AutoPostBack="true" OnSelectedIndexChanged="ddlYear_Changed" />
        </div>
        <button type="button" class="bd-print-btn" onclick="window.print()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print
        </button>
    </div>
</div>

<!-- ======= TAB NAVIGATION ============================================= -->
<div class="bd-tabs">
    <span class="bd-tab bd-tab--active">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
        Dashboard
    </span>
    <a class="bd-tab" href="BursarySchemes.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
        Schemes
    </a>
    <a class="bd-tab" href="BursaryBeneficiaries.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        Beneficiaries
    </a>
</div>

<div class="bd-content">

<!-- ======= KPI HERO CARDS ============================================= -->
<div class="bd-hero">
    <!-- Total Beneficiaries -->
    <div class="bd-kpi bd-kpi--total">
        <div class="bd-kpi__top">
            <div class="bd-kpi__label">Beneficiaries</div>
            <div class="bd-kpi__icon bd-kpi__icon--total">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
        </div>
        <div class="bd-kpi__value bd-kpi__value--blue">
            <asp:Literal ID="litKpiTotal" runat="server" Text="0" />
        </div>
        <div class="bd-kpi__sub">
            <asp:Literal ID="litKpiTotalSub" runat="server" Text="this academic year" />
        </div>
    </div>
    <!-- Total Amount -->
    <div class="bd-kpi bd-kpi--amount">
        <div class="bd-kpi__top">
            <div class="bd-kpi__label">Total Awarded</div>
            <div class="bd-kpi__icon bd-kpi__icon--amount">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
            </div>
        </div>
        <div class="bd-kpi__value bd-kpi__value--teal">
            <span class="bd-kpi__currency">UGX</span><asp:Literal ID="litKpiAmount" runat="server" Text="0" />
        </div>
        <div class="bd-kpi__sub">total amount disbursed</div>
    </div>
    <!-- Active Schemes -->
    <div class="bd-kpi bd-kpi--schemes">
        <div class="bd-kpi__top">
            <div class="bd-kpi__label">Active Schemes</div>
            <div class="bd-kpi__icon bd-kpi__icon--schemes">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
            </div>
        </div>
        <div class="bd-kpi__value bd-kpi__value--purple">
            <asp:Literal ID="litKpiSchemes" runat="server" Text="0" />
        </div>
        <div class="bd-kpi__sub">
            <asp:Literal ID="litKpiSchemesUsed" runat="server" Text="0 used this year" />
        </div>
    </div>
    <!-- Average Award -->
    <div class="bd-kpi bd-kpi--approved">
        <div class="bd-kpi__top">
            <div class="bd-kpi__label">Avg Award</div>
            <div class="bd-kpi__icon bd-kpi__icon--approved">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
            </div>
        </div>
        <div class="bd-kpi__value bd-kpi__value--green">
            <span style="font-size:14px;font-weight:600;color:#888;">UGX</span> <asp:Literal ID="litKpiApproved" runat="server" Text="0" />
        </div>
        <div class="bd-kpi__sub">
            <asp:Literal ID="litKpiApprovedPct" runat="server" Text="per beneficiary" />
        </div>
    </div>
    <!-- Fee Transactions -->
    <div class="bd-kpi bd-kpi--pending">
        <div class="bd-kpi__top">
            <div class="bd-kpi__label">Fee Transactions</div>
            <div class="bd-kpi__icon bd-kpi__icon--pending">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            </div>
        </div>
        <div class="bd-kpi__value bd-kpi__value--amber">
            <asp:Literal ID="litKpiPending" runat="server" Text="0" />
        </div>
        <div class="bd-kpi__sub">
            <asp:Literal ID="litKpiPendingSub" runat="server" Text="linked transactions" />
        </div>
    </div>
</div>

<!-- ======= CHARTS ROW 1: Trend + Scheme Breakdown ==================== -->
<div class="bd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
    Charts &amp; Analysis
    <span class="bd-section-hdr__line"></span>
</div>

<div class="bd-two-col">
    <!-- Year-over-Year Trend -->
    <div class="bd-card">
        <div class="bd-card__header">
            <div class="bd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                Year-over-Year Beneficiaries &amp; Amount
            </div>
            <div class="bd-card__meta">all years</div>
        </div>
        <div class="bd-chart-wrap">
            <canvas id="chartTrend"></canvas>
        </div>
    </div>
    <!-- Scheme Breakdown Doughnut -->
    <div class="bd-card">
        <div class="bd-card__header">
            <div class="bd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#6d28d9" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 2a10 10 0 0 1 10 10"/></svg>
                Scheme Breakdown
            </div>
            <div class="bd-card__meta"><asp:Literal ID="litSchemeBreakdownYear" runat="server" /></div>
        </div>
        <div class="bd-chart-wrap">
            <canvas id="chartSchemes"></canvas>
        </div>
    </div>
</div>

<!-- ======= CHARTS ROW 2: Semester + Amount Distribution =============== -->
<div class="bd-three-col">
    <!-- Amount by Scheme Bar -->
    <div class="bd-card" style="grid-column:span 2;">
        <div class="bd-card__header">
            <div class="bd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#00897b" stroke-width="2"><rect x="18" y="3" width="4" height="18"/><rect x="10" y="8" width="4" height="13"/><rect x="2" y="13" width="4" height="8"/></svg>
                Amount Awarded by Scheme (UGX)
            </div>
            <div class="bd-card__meta"><asp:Literal ID="litAmountChartYear" runat="server" /></div>
        </div>
        <div class="bd-chart-wrap bd-chart-wrap--sm">
            <canvas id="chartAmount"></canvas>
        </div>
    </div>
    <!-- Study Year Distribution -->
    <div class="bd-card">
        <div class="bd-card__header">
            <div class="bd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M2 20h.01M7 20v-4"/><path d="M12 20V10"/><path d="M17 20V4"/><path d="M22 20v-8"/></svg>
                By Study Year
            </div>
            <div class="bd-card__meta"><asp:Literal ID="litStudyYearChartYear" runat="server" /></div>
        </div>
        <div class="bd-chart-wrap bd-chart-wrap--sm">
            <canvas id="chartStudyYear"></canvas>
        </div>
    </div>
</div>

<!-- ======= SCHEME DETAILS TABLE ====================================== -->
<div class="bd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
    Scheme Breakdown Details
    <span class="bd-section-hdr__line"></span>
</div>
<div class="bd-card bd-full">
    <div class="bd-card__header">
        <div class="bd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
            Performance by Scheme — <asp:Literal ID="litSchemeTableYear" runat="server" />
        </div>
        <div class="bd-card__meta"><asp:Literal ID="litSchemeTableMeta" runat="server" /></div>
    </div>
    <div style="overflow-x:auto;">
        <table class="bd-table">
            <thead><tr>
                <th></th>
                <th>Scheme Name</th>
                <th class="r">Bursary Amt (UGX)</th>
                <th class="c">Beneficiaries</th>
                <th class="r">Total Awarded (UGX)</th>
                <th class="c">Share %</th>
                <th style="min-width:100px;">Distribution</th>
                <th class="c">Status</th>
            </tr></thead>
            <tbody>
                <asp:Literal ID="litSchemeRows" runat="server" />
            </tbody>
        </table>
    </div>
</div>

<!-- ======= YEAR-OVER-YEAR SUMMARY TABLE ============================== -->
<div class="bd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
    Historical Summary
    <span class="bd-section-hdr__line"></span>
</div>
<div class="bd-two-col">
    <!-- Year Summary -->
    <div class="bd-card">
        <div class="bd-card__header">
            <div class="bd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                Year-over-Year Summary
            </div>
            <div class="bd-card__meta">all recorded years</div>
        </div>
        <div style="overflow-x:auto;">
            <table class="bd-table">
                <thead><tr>
                    <th>Academic Year</th>
                    <th class="c">Beneficiaries</th>
                    <th class="r">Amount (UGX)</th>
                    <th class="c">Approved</th>
                    <th class="c">Avg/Student</th>
                </tr></thead>
                <tbody>
                    <asp:Literal ID="litYearRows" runat="server" />
                </tbody>
            </table>
        </div>
    </div>
    <!-- Recent Beneficiaries -->
    <div class="bd-card">
        <div class="bd-card__header">
            <div class="bd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                Recent Beneficiaries
            </div>
            <div class="bd-card__meta">latest 10 for <asp:Literal ID="litRecentYear" runat="server" /></div>
        </div>
        <div style="overflow-x:auto;">
            <table class="bd-table">
                <thead><tr>
                    <th>Reg No</th>
                    <th>Student Name</th>
                    <th>Scheme</th>
                    <th class="r">Amount</th>
                </tr></thead>
                <tbody>
                    <asp:Literal ID="litRecentRows" runat="server" />
                </tbody>
            </table>
        </div>
    </div>
</div>

</div><!-- /bd-content -->

<script type="text/javascript">
function initBursaryCharts() {
    // Chart color palette
    var COLORS = ['#174DA4','#00897b','#6d28d9','#d97706','#dc3545','#16a34a','#0891b2','#9333ea'];
    var COLORS_BG = COLORS.map(function(c){ return c + '22'; });

    Chart.defaults.font.family = 'inherit';
    Chart.defaults.color = '#555';

    // ---- Trend Chart (Bar + Line combo) ----
    (function() {
        var el = document.getElementById('chartTrend');
        if (!el || typeof _trendData === 'undefined') return;
        var d = _trendData;
        new Chart(el, {
            type: 'bar',
            data: {
                labels: d.years,
                datasets: [
                    {
                        label: 'Beneficiaries',
                        data: d.counts,
                        backgroundColor: '#174DA4cc',
                        borderColor: '#174DA4',
                        borderWidth: 1,
                        yAxisID: 'y',
                        order: 2
                    },
                    {
                        label: 'Amount (UGX M)',
                        data: d.amounts,
                        type: 'line',
                        borderColor: '#00897b',
                        backgroundColor: 'rgba(0,137,123,.08)',
                        pointBackgroundColor: '#00897b',
                        pointRadius: 5,
                        borderWidth: 2,
                        fill: true,
                        tension: 0.3,
                        yAxisID: 'y2',
                        order: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: { position: 'top', labels: { boxWidth: 12, font: { size: 11 } } },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) {
                                if (ctx.datasetIndex === 1) return ' UGX ' + (ctx.raw * 1000000).toLocaleString();
                                return ' ' + ctx.raw + ' beneficiaries';
                            }
                        }
                    }
                },
                scales: {
                    y:  { type:'linear', position:'left',  title:{ display:true, text:'Beneficiaries', font:{size:10} }, ticks:{stepSize:10} },
                    y2: { type:'linear', position:'right', title:{ display:true, text:'Amount (UGX M)', font:{size:10} }, grid:{drawOnChartArea:false} }
                }
            }
        });
    })();

    // ---- Scheme Doughnut ----
    (function() {
        var el = document.getElementById('chartSchemes');
        if (!el || typeof _schemeData === 'undefined') return;
        var d = _schemeData;
        if (!d.labels || d.labels.length === 0) return;
        new Chart(el, {
            type: 'doughnut',
            data: {
                labels: d.labels,
                datasets: [{
                    data: d.counts,
                    backgroundColor: COLORS.slice(0, d.labels.length),
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '60%',
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, font: { size: 11 }, padding: 10 } },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) {
                                var total = ctx.dataset.data.reduce(function(a,b){ return a+b; }, 0);
                                var pct = total > 0 ? Math.round(ctx.raw / total * 100) : 0;
                                return ' ' + ctx.label + ': ' + ctx.raw + ' (' + pct + '%)';
                            }
                        }
                    }
                }
            }
        });
    })();

    // ---- Amount by Scheme Bar ----
    (function() {
        var el = document.getElementById('chartAmount');
        if (!el || typeof _schemeData === 'undefined') return;
        var d = _schemeData;
        if (!d.labels || d.labels.length === 0) return;
        new Chart(el, {
            type: 'bar',
            data: {
                labels: d.labels,
                datasets: [{
                    label: 'Total Awarded (UGX)',
                    data: d.amounts,
                    backgroundColor: COLORS.slice(0, d.labels.length).map(function(c){ return c + 'cc'; }),
                    borderColor: COLORS.slice(0, d.labels.length),
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) { return ' UGX ' + Number(ctx.raw).toLocaleString(); }
                        }
                    }
                },
                scales: {
                    y: { ticks: { callback: function(v){ return 'UGX ' + (v/1000000).toFixed(1)+'M'; } } }
                }
            }
        });
    })();

    // ---- Study Year Bar ----
    (function() {
        var el = document.getElementById('chartStudyYear');
        if (!el || typeof _studyYearData === 'undefined') return;
        var d = _studyYearData;
        if (!d.labels || d.labels.length === 0) return;
        new Chart(el, {
            type: 'bar',
            data: {
                labels: d.labels,
                datasets: [{
                    label: 'Beneficiaries',
                    data: d.counts,
                    backgroundColor: '#d97706cc',
                    borderColor: '#d97706',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { callbacks: { label: function(ctx){ return ' ' + ctx.raw + ' beneficiaries'; } } }
                },
                scales: { y: { ticks: { stepSize: 1 } } }
            }
        });
    })();
}
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initBursaryCharts);
} else {
    setTimeout(initBursaryCharts, 50);
}
</script>
</asp:Content>
