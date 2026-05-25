<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesManagement.aspx.cs" Inherits="COOPERP_NewScreens_FeesManagement" Title="Fees Dashboard - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* =====================================================================
   FEES DASHBOARD — Redesigned 2026-03-26
   Prefix: fd- (fees dashboard) | fm- (page header/nav) | fs- (shared)
   Scoped: ENROLLED students only (registered & active)
   Benchmark: FeesStructure.aspx
   ===================================================================== */

/* ---- Searchable select widget ---- */
.cd-srch-wrap  { position: relative; display: block; }
.cd-srch-input { width: 100%; box-sizing: border-box; cursor: text; }
.cd-srch-panel {
    display: none; position: absolute; top: 100%; left: 0; right: 0; z-index: 600;
    background: #fff; border: 1px solid #cdd3de;
    max-height: 220px; overflow-y: auto;
    box-shadow: 0 4px 12px rgba(0,0,0,.12);
}
.cd-srch-item {
    padding: 6px 10px; font-size: 11px; color: #333;
    cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.cd-srch-item:hover, .cd-srch-item--hover { background: #f0f4fc; color: #05275C; }
.cd-srch-item--sel     { background: rgba(5,39,92,.06); color: #05275C; font-weight: 600; }
.cd-srch-item--empty   { color: #aaa; font-style: italic; cursor: default; }
.cd-srch-item--placeholder { color: #888; }

/* ---- Content wrapper ---- */
.fd-content { padding: 16px 20px 20px; }

/* ---- Filter bar ---- */
.fd-filter-bar {
    display: flex; flex-wrap: wrap; align-items: center; gap: 12px;
    background: #fff; padding: 10px 14px; border: 1px solid #e0e5ed;
    margin-bottom: 16px;
}
.fd-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.fd-filter-grp__label {
    font-size: 10px; font-weight: 600; text-transform: uppercase;
    letter-spacing: .4px; color: #555;
}
.fs-filter-select {
    padding: 6px 8px; border: 1px solid #cdd3de; font-size: 12px;
    border-radius: 0; min-width: 170px; background: #fff; color: #333;
}
.fs-filter-select:focus { border-color: #174DA4; outline: none; }
.fd-filter-note {
    margin-left: auto; font-size: 10px; color: #16a34a; font-weight: 600;
    display: flex; align-items: center; gap: 5px;
    background: #e6f4ea; padding: 5px 10px; border: 1px solid #c3e6cb;
}
.fd-filter-note svg { flex-shrink: 0; }

/* ---- KPI Hero Cards ---- */
.fd-hero { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 18px; }
.fd-kpi {
    background: #fff; border: 1px solid #e0e5ed; padding: 16px 18px;
    position: relative; overflow: hidden; transition: border-color .15s;
}
.fd-kpi:hover { border-color: #cdd3de; }
.fd-kpi::before {
    content: ''; position: absolute; left: 0; top: 0; width: 3px; height: 100%;
}
.fd-kpi--enrolled::before { background: #05275C; }
.fd-kpi--billed::before   { background: #174DA4; }
.fd-kpi--paid::before      { background: #16a34a; }
.fd-kpi--balance::before   { background: #c62828; }
.fd-kpi__top { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 8px; }
.fd-kpi__label {
    font-size: 10px; text-transform: uppercase; letter-spacing: .5px;
    color: #888; font-weight: 700;
}
.fd-kpi__icon {
    width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
}
.fd-kpi__icon--enrolled { background: rgba(5,39,92,.07); color: #05275C; }
.fd-kpi__icon--billed   { background: rgba(23,77,164,.07); color: #174DA4; }
.fd-kpi__icon--paid     { background: rgba(22,163,74,.07); color: #16a34a; }
.fd-kpi__icon--balance  { background: rgba(198,40,40,.07); color: #c62828; }
.fd-kpi__value {
    font-size: 22px; font-weight: 800; line-height: 1.1;
    font-variant-numeric: tabular-nums;
}
.fd-kpi__value--navy  { color: #05275C; }
.fd-kpi__value--blue  { color: #174DA4; }
.fd-kpi__value--green { color: #16a34a; }
.fd-kpi__value--red   { color: #c62828; }
.fd-kpi__sub {
    font-size: 10px; color: #aaa; margin-top: 6px;
    display: flex; align-items: center; gap: 4px;
}
.fd-kpi__sub svg { flex-shrink: 0; }
.fd-kpi__currency { font-size: 11px; font-weight: 600; color: #999; margin-right: 2px; }

/* ---- Section headers ---- */
.fd-section-hdr {
    display: flex; align-items: center; gap: 8px; margin-bottom: 12px;
    font-size: 10px; text-transform: uppercase; letter-spacing: .8px;
    color: #888; font-weight: 700;
}
.fd-section-hdr__line { flex: 1; height: 1px; background: #e0e5ed; }

/* ---- Chart panels ---- */
.fd-chart-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }
.fd-chart-panel {
    background: #fff; border: 1px solid #e0e5ed; overflow: hidden;
}
.fd-chart-panel__header {
    padding: 11px 16px; border-bottom: 1px solid #e0e5ed; background: #f5f7fa;
    display: flex; align-items: center; justify-content: space-between;
}
.fd-chart-panel__title {
    font-size: 12px; font-weight: 600; color: #1a1a2e;
    display: flex; align-items: center; gap: 6px;
}
.fd-chart-panel__title svg { flex-shrink: 0; }
.fd-chart-panel__meta { font-size: 10px; color: #888; }
.fd-chart-panel__body { padding: 16px; }

/* ---- Donut + Revenue layout ---- */
.fd-donut-layout { display: grid; grid-template-columns: 280px 1fr; gap: 14px; margin-bottom: 18px; }
.fd-donut-wrap {
    background: #fff; border: 1px solid #e0e5ed; padding: 20px;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
}
.fd-donut-title {
    font-size: 12px; font-weight: 600; color: #1a1a2e; margin-bottom: 16px;
    text-transform: uppercase; letter-spacing: .5px;
}
.fd-donut-canvas { display: block; margin: 0 auto; }
.fd-donut-legend { display: flex; gap: 18px; margin-top: 16px; justify-content: center; }
.fd-donut-legend__item { display: flex; align-items: center; gap: 5px; font-size: 10px; color: #555; font-weight: 600; }
.fd-donut-legend__dot { width: 8px; height: 8px; flex-shrink: 0; }
.fd-donut-legend__dot--paid { background: #16a34a; }
.fd-donut-legend__dot--bal  { background: #e0e0e0; }

/* ---- Horizontal bars (fee type breakdown) ---- */
.fd-hbar-list { display: flex; flex-direction: column; gap: 14px; }
.fd-hbar-row { display: grid; grid-template-columns: 90px 1fr 110px; gap: 10px; align-items: center; }
.fd-hbar-label { font-size: 11px; font-weight: 600; color: #555; text-align: right; }
.fd-hbar-track { height: 22px; background: #f0f2f5; overflow: hidden; position: relative; }
.fd-hbar-fill {
    height: 100%; transition: width .6s ease;
    display: flex; align-items: center; padding-left: 6px; min-width: 2px;
}
.fd-hbar-fill--navy { background: #05275C; }
.fd-hbar-fill--blue { background: #174DA4; }
.fd-hbar-fill--amber { background: #d97706; }
.fd-hbar-pct { font-size: 9px; color: #fff; font-weight: 700; white-space: nowrap; }
.fd-hbar-value { font-size: 11px; font-weight: 700; color: #1a1a2e; text-align: right; font-variant-numeric: tabular-nums; }

/* ---- Semester detail cards ---- */
.fd-sem-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; margin-bottom: 18px; }
.fd-sem-card {
    border: 1px solid #e0e5ed; padding: 14px; background: #fff;
    transition: border-color .15s;
}
.fd-sem-card:hover { border-color: #cdd3de; }
.fd-sem-card__head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; }
.fd-sem-card__title { font-size: 12px; font-weight: 600; color: #1a1a2e; }
.fd-sem-card__badge {
    font-size: 10px; font-weight: 600; padding: 3px 7px;
    text-transform: uppercase; letter-spacing: .3px;
}
.fd-sem-card__badge--ok   { background: #e6f4ea; color: #155724; border: 1px solid #c3e6cb; }
.fd-sem-card__badge--warn { background: #fff8e1; color: #b45309; border: 1px solid #fcd34d; }
.fd-sem-card__badge--red  { background: #fef5f5; color: #dc3545; border: 1px solid #f5c6cb; }
.fd-row { display: flex; justify-content: space-between; align-items: center; padding: 5px 0; font-size: 11px; border-bottom: 1px solid #f0f2f5; }
.fd-row:last-of-type { border-bottom: none; }
.fd-row__label { color: #888; }
.fd-row__val   { font-weight: 600; color: #1a1a2e; font-variant-numeric: tabular-nums; }
.fd-row__val--green { color: #155724; }
.fd-row__val--red   { color: #dc3545; }
.fd-row__val--amber { color: #b45309; }
.fd-progress { height: 5px; background: #e8e8e8; margin-top: 10px; overflow: hidden; }
.fd-progress__fill { height: 100%; transition: width .6s ease; }
.fd-progress__fill--green { background: #16a34a; }
.fd-progress__fill--amber { background: #d97706; }
.fd-progress__fill--red   { background: #dc3545; }
.fd-progress-label { font-size: 9px; color: #888; margin-top: 3px; text-align: right; font-weight: 600; }

/* ---- Shared table/card classes ---- */
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
.fs-table td { padding: 9px 12px; border-bottom: 1px solid #e0e5ed; color: #1a1a2e; vertical-align: middle; }
.fs-table tbody tr:hover td { background: #f9fafc; }
.fs-table tbody tr:last-child td { border-bottom: none; }
.fs-code {
    font-family: Consolas, "Courier New", monospace; font-size: 11px; font-weight: 600;
    background: rgba(23,77,164,.07); border: 1px solid rgba(23,77,164,.15);
    color: #174DA4; padding: 2px 6px;
}
.fs-badge            { font-size: 10px; font-weight: 600; padding: 3px 7px; text-transform: uppercase; letter-spacing: .3px; }
.fs-badge--green     { background: #e6f4ea; color: #155724; border: 1px solid #c3e6cb; }
.fs-badge--amber     { background: #fff8e1; color: #b45309; border: 1px solid #fcd34d; }
.fs-badge--red       { background: #fef5f5; color: #dc3545; border: 1px solid #f5c6cb; }
.fs-badge--primary   { background: rgba(5,39,92,.08); color: #05275C; border: 1px solid rgba(5,39,92,.2); }

/* ---- Programme revenue inline bar ---- */
.fd-prog-bar { height: 6px; background: #f0f2f5; overflow: hidden; min-width: 80px; }
.fd-prog-bar__fill { height: 100%; background: #174DA4; transition: width .6s ease; }

/* ---- Anomaly cards ---- */
.fd-anomaly-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; padding: 14px; }
.fd-anomaly {
    border: 1px solid #e0e5ed; padding: 14px; background: #fff;
    border-left: 4px solid #e0e5ed;
}
.fd-anomaly--ok     { border-left-color: #16a34a; }
.fd-anomaly--warn   { border-left-color: #d97706; }
.fd-anomaly--danger { border-left-color: #dc3545; }
.fd-anomaly__icon {
    width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
    border: 1px solid #e0e5ed; margin-bottom: 10px;
}
.fd-anomaly--ok     .fd-anomaly__icon { background: #e6f4ea; border-color: #c3e6cb; }
.fd-anomaly--warn   .fd-anomaly__icon { background: #fff8e1; border-color: #fcd34d; }
.fd-anomaly--danger .fd-anomaly__icon { background: #fef5f5; border-color: #f5c6cb; }
.fd-anomaly__label { font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: .4px; color: #888; margin-bottom: 4px; }
.fd-anomaly__val   { font-size: 20px; font-weight: 700; color: #1a1a2e; line-height: 1; margin-bottom: 4px; }
.fd-anomaly--ok     .fd-anomaly__val { color: #155724; }
.fd-anomaly--warn   .fd-anomaly__val { color: #b45309; }
.fd-anomaly--danger .fd-anomaly__val { color: #dc3545; }
.fd-anomaly__hint { font-size: 11px; color: #888; line-height: 1.5; }

/* ---- Latest transactions two-column ---- */
.fd-latest-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }

/* ---- Entrance animation ---- */
@keyframes fdFadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
.fd-hero > * { animation: fdFadeIn .35s ease both; }
.fd-hero > *:nth-child(2) { animation-delay: .05s; }
.fd-hero > *:nth-child(3) { animation-delay: .1s; }
.fd-hero > *:nth-child(4) { animation-delay: .15s; }

/* ---- Responsive ---- */
@media (max-width: 1200px) {
    .fd-donut-layout { grid-template-columns: 1fr; }
}
@media (max-width: 1000px) {
    .fd-hero      { grid-template-columns: repeat(2,1fr); }
    .fd-chart-row { grid-template-columns: 1fr; }
    .fd-sem-grid  { grid-template-columns: 1fr 1fr; }
    .fd-latest-row { grid-template-columns: 1fr; }
}
@media (max-width: 700px) {
    .fd-content      { padding: 12px; }
    .fd-hero         { grid-template-columns: 1fr; }
    .fd-sem-grid     { grid-template-columns: 1fr; }
    .fd-anomaly-grid { grid-template-columns: 1fr; }
    .fd-hbar-row     { grid-template-columns: 70px 1fr 80px; }
    .fd-donut-layout { grid-template-columns: 1fr; }
}

/* ---- YoY Trend indicators ---- */
.fd-kpi__trend {
    display: flex; align-items: center; gap: 4px;
    font-size: 10px; font-weight: 600; margin-top: 4px;
}
.fd-trend--up   { color: #16a34a; }
.fd-trend--down { color: #dc3545; }
.fd-trend--flat { color: #999; }

/* ---- Print / Export button ---- */
.fd-print-btn {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 6px 14px; border: 1px solid rgba(255,255,255,.25);
    background: rgba(255,255,255,.08); color: #fff;
    font-size: 11px; font-weight: 600; cursor: pointer;
    border-radius: 0; transition: background .15s;
    font-family: inherit;
}
.fd-print-btn:hover { background: rgba(255,255,255,.18); }

/* ---- Cash / Credit Breakdown Row ---- */
.fd-credits-row {
    display: grid; grid-template-columns: repeat(4,1fr); gap: 10px; margin-bottom: 18px;
}
.fd-credit-card {
    background: #fff; border: 1px solid #e0e5ed; padding: 14px 16px;
    border-top: 3px solid #e0e5ed;
}
.fd-credit-card--cash    { border-top-color: #16a34a; }
.fd-credit-card--bursary { border-top-color: #2563eb; }
.fd-credit-card--waiver  { border-top-color: #d97706; }
.fd-credit-card--net     { border-top-color: #05275C; }
.fd-credit-card__icon {
    width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;
    background: #f5f7fa; border: 1px solid #e0e5ed; margin-bottom: 8px;
}
.fd-credit-card--cash    .fd-credit-card__icon { background: rgba(22,163,74,.08);  border-color: rgba(22,163,74,.2); }
.fd-credit-card--bursary .fd-credit-card__icon { background: rgba(37,99,235,.08);  border-color: rgba(37,99,235,.2); }
.fd-credit-card--waiver  .fd-credit-card__icon { background: rgba(217,119,6,.08);  border-color: rgba(217,119,6,.2); }
.fd-credit-card--net     .fd-credit-card__icon { background: rgba(5,39,92,.08);    border-color: rgba(5,39,92,.2);   }
.fd-credit-card__label {
    font-size: 10px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .4px; color: #666; margin-bottom: 4px;
}
.fd-credit-card__value {
    font-size: 15px; font-weight: 800; color: #1a1a2e; line-height: 1.2;
    font-variant-numeric: tabular-nums; margin-bottom: 4px;
}
.fd-credit-card--cash    .fd-credit-card__value { color: #15803d; }
.fd-credit-card--bursary .fd-credit-card__value { color: #1d4ed8; }
.fd-credit-card--waiver  .fd-credit-card__value { color: #b45309; }
.fd-credit-card--net     .fd-credit-card__value { color: #05275C; }
.fd-credit-card__sub { font-size: 10px; color: #aaa; line-height: 1.4; }
@media (max-width:1000px) { .fd-credits-row { grid-template-columns: repeat(2,1fr); } }
@media (max-width:600px)  { .fd-credits-row { grid-template-columns: 1fr; } }

/* ---- Print media ---- */
@media print {
    .fd-print-btn, .cd-srch-wrap, .fd-filter-note { display: none !important; }
    .fd-content { padding: 10px !important; }
    .fd-kpi, .fd-chart-panel, .fs-card, .fd-sem-card, .fd-anomaly { break-inside: avoid; }
    .fd-hero { grid-template-columns: repeat(4,1fr) !important; }
    .fd-chart-row { grid-template-columns: 1fr 1fr !important; }
    .fd-sem-grid { grid-template-columns: repeat(3,1fr) !important; }
    canvas { max-width: 100% !important; }
}
</style>
</asp:Content>


<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="fd-content">

<!-- ======= FILTER BAR ============================================ -->
<div class="fd-filter-bar">
    <div class="fd-filter-grp">
        <label class="fd-filter-grp__label">Academic Year</label>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="fs-filter-select"
            AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
    </div>
    <div class="fd-filter-grp">
        <label class="fd-filter-grp__label">Semester</label>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="fs-filter-select"
            AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Text="All Semesters" Value="" />
            <asp:ListItem Text="Semester 1" Value="1" />
            <asp:ListItem Text="Semester 2" Value="2" />
        </asp:DropDownList>
    </div>
    <div class="fd-filter-note">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        Enrolled students only (registered &amp; active)
    </div>
    <span style="flex:1;"></span>
    <asp:Literal ID="litAcadContext" runat="server" />
    <button type="button" class="fd-print-btn" onclick="window.print();" title="Print Dashboard Report" style="background:#05275C;color:#fff;border:1px solid #05275C;">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
        Print
    </button>
</div>

<!-- ======= HERO KPI CARDS ======================================== -->
<div class="fd-hero">
    <!-- Enrolled Students -->
    <div class="fd-kpi fd-kpi--enrolled">
        <div class="fd-kpi__top">
            <div class="fd-kpi__label">Enrolled Students</div>
            <div class="fd-kpi__icon fd-kpi__icon--enrolled">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
        </div>
        <div class="fd-kpi__value fd-kpi__value--navy"><asp:Literal ID="litStatEnrolled" runat="server" Text="0" /></div>
        <div class="fd-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
            registered &amp; active in selected year
        </div>
        <asp:Literal ID="litTrendEnrolled" runat="server" />
    </div>
    <!-- Total Billed -->
    <div class="fd-kpi fd-kpi--billed">
        <div class="fd-kpi__top">
            <div class="fd-kpi__label">Total Billed</div>
            <div class="fd-kpi__icon fd-kpi__icon--billed">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"/></svg>
            </div>
        </div>
        <div class="fd-kpi__value fd-kpi__value--blue"><asp:Literal ID="litStatBilled" runat="server" Text="UGX 0" /></div>
        <div class="fd-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"/></svg>
            <asp:Literal ID="litStatBillCount" runat="server" Text="0 invoices" />
        </div>
        <asp:Literal ID="litTrendBilled" runat="server" />
    </div>
    <!-- Total Paid -->
    <div class="fd-kpi fd-kpi--paid">
        <div class="fd-kpi__top">
            <div class="fd-kpi__label">Cash Received</div>
            <div class="fd-kpi__icon fd-kpi__icon--paid">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
        </div>
        <div class="fd-kpi__value fd-kpi__value--green"><asp:Literal ID="litStatPaid" runat="server" Text="UGX 0" /></div>
        <div class="fd-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            <asp:Literal ID="litStatPayCount" runat="server" Text="0 cash payments" />
        </div>
        <asp:Literal ID="litTrendPaid" runat="server" />
    </div>
    <!-- Outstanding Balance -->
    <div class="fd-kpi fd-kpi--balance">
        <div class="fd-kpi__top">
            <div class="fd-kpi__label">Outstanding Balance</div>
            <div class="fd-kpi__icon fd-kpi__icon--balance">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
        </div>
        <div class="fd-kpi__value fd-kpi__value--red"><asp:Literal ID="litStatBalance" runat="server" Text="UGX 0" /></div>
        <div class="fd-kpi__sub">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            <asp:Literal ID="litStatCollRate" runat="server" Text="0% collection rate" />
        </div>
        <asp:Literal ID="litTrendBalance" runat="server" />
    </div>
</div>

<!-- ======= CASH vs NON-CASH CREDIT BREAKDOWN ==================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
    Income Breakdown &mdash; Cash vs Non-Cash Credits
    <span class="fd-section-hdr__line"></span>
</div>
<asp:Literal ID="litCashBreakdown" runat="server" />

<!-- ======= COLLECTION & REVENUE ANALYTICS ======================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
    Collection &amp; Revenue Analytics
    <span class="fd-section-hdr__line"></span>
</div>

<div class="fd-donut-layout">
    <!-- LEFT: Collection Donut -->
    <div class="fd-donut-wrap">
        <div class="fd-donut-title">Cash Collection Rate</div>
        <canvas id="cvDonut" class="fd-donut-canvas" width="180" height="180"></canvas>
        <div class="fd-donut-legend">
            <div class="fd-donut-legend__item"><span class="fd-donut-legend__dot fd-donut-legend__dot--paid"></span>Cash Received</div>
            <div class="fd-donut-legend__item"><span class="fd-donut-legend__dot fd-donut-legend__dot--bal"></span>Outstanding</div>
        </div>
        <div style="margin-top:10px;font-size:10px;color:#aaa;text-align:center;line-height:1.4;">Bursaries &amp; waivers excluded<br>from cash rate calculation</div>
    </div>
    <!-- RIGHT: Revenue by Fee Type -->
    <div class="fd-chart-panel">
        <div class="fd-chart-panel__header">
            <div class="fd-chart-panel__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                Revenue by Fee Type
            </div>
            <div class="fd-chart-panel__meta">enrolled students only</div>
        </div>
        <div class="fd-chart-panel__body">
            <div class="fd-hbar-list">
                <asp:Literal ID="litFeeTypeBars" runat="server" />
            </div>
        </div>
    </div>
</div>

<!-- ======= CHARTS ROW ============================================ -->
<div class="fd-chart-row">
    <!-- Monthly Payments -->
    <div class="fd-chart-panel">
        <div class="fd-chart-panel__header">
            <div class="fd-chart-panel__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                Monthly Cash vs Non-Cash vs Billing
            </div>
            <div class="fd-chart-panel__meta">past 12 months &mdash; stacked: cash (green) + non-cash credits (amber)</div>
        </div>
        <div class="fd-chart-panel__body">
            <div style="position:relative;width:100%;"><canvas id="cvMonthly"></canvas></div>
        </div>
    </div>
    <!-- Daily Payments (Past 30 Days) -->
    <div class="fd-chart-panel">
        <div class="fd-chart-panel__header">
            <div class="fd-chart-panel__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                Daily Cash Received (Past 30 Days)
            </div>
            <div class="fd-chart-panel__meta">cash only &mdash; mobile money &amp; bank deposits</div>
        </div>
        <div class="fd-chart-panel__body">
            <div style="position:relative;width:100%;"><canvas id="cvDaily"></canvas></div>
        </div>
    </div>
</div>

<!-- ======= PAYMENT CHANNELS ====================================== -->
<div class="fd-chart-row" style="grid-template-columns:1fr 1fr;">
    <div class="fd-chart-panel">
        <div class="fd-chart-panel__header">
            <div class="fd-chart-panel__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                Payment Channels
            </div>
            <div class="fd-chart-panel__meta">cash receipts only &mdash; excludes bursaries &amp; waivers</div>
        </div>
        <div class="fd-chart-panel__body">
            <div style="position:relative;width:100%;"><canvas id="cvChannel"></canvas></div>
        </div>
    </div>
    <div class="fd-chart-panel">
        <div class="fd-chart-panel__header">
            <div class="fd-chart-panel__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                Non-Cash Credits Composition
            </div>
            <div class="fd-chart-panel__meta">bursaries, waivers &amp; adjustments</div>
        </div>
        <div class="fd-chart-panel__body">
            <div style="position:relative;width:100%;"><canvas id="cvNonCash"></canvas></div>
        </div>
    </div>
</div>

<!-- ======= SEMESTER BREAKDOWN ==================================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
    Semester Breakdown
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fd-sem-grid">
    <asp:Literal ID="litSemesterCards" runat="server" />
</div>

<!-- ======= PROGRAMME REVENUE ===================================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
    Top Programmes by Revenue
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fs-card">
    <div class="fs-card__header">
        <div class="fs-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            Programme Revenue
        </div>
        <div class="fs-card__meta"><asp:Literal ID="litProgCount" runat="server" Text="0 programmes" /></div>
    </div>
    <div style="overflow-x:auto;">
        <table class="fs-table">
            <thead><tr>
                <th>Programme</th>
                <th style="text-align:right">Students</th>
                <th style="text-align:right">Total Billed</th>
                <th style="text-align:right">Total Paid</th>
                <th style="min-width:100px;">Collection</th>
                <th style="text-align:right">Rate</th>
            </tr></thead>
            <tbody><asp:Literal ID="litProgRows" runat="server" /></tbody>
        </table>
    </div>
</div>

<!-- ======= TOP DEBTORS ========================================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    Top 15 Outstanding Balances (Enrolled)
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fs-card">
    <div style="overflow-x:auto;">
        <table class="fs-table">
            <thead><tr>
                <th>Reg No</th><th>Student Name</th><th>Programme</th>
                <th style="text-align:right">Billed</th>
                <th style="text-align:right">Paid</th>
                <th style="text-align:right">Balance</th>
            </tr></thead>
            <tbody><asp:Literal ID="litDebtorRows" runat="server" /></tbody>
        </table>
    </div>
</div>

<!-- ======= LATEST TRANSACTIONS ==================================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
    Latest Transactions
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fd-latest-row">
    <!-- Latest 20 Payments -->
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                Latest 20 Payments
            </div>
            <div class="fs-card__meta" style="color:#16a34a;">income</div>
        </div>
        <div style="overflow-x:auto; max-height:420px; overflow-y:auto;">
            <table class="fs-table">
                <thead><tr>
                    <th>Reg No</th><th>Student</th><th>Item</th>
                    <th style="text-align:right">Amount</th><th>Date</th>
                </tr></thead>
                <tbody><asp:Literal ID="litLatestPayRows" runat="server" /></tbody>
            </table>
        </div>
    </div>
    <!-- Latest 20 Billings -->
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"/></svg>
                Latest 20 Billings
            </div>
            <div class="fs-card__meta" style="color:#174DA4;">invoices</div>
        </div>
        <div style="overflow-x:auto; max-height:420px; overflow-y:auto;">
            <table class="fs-table">
                <thead><tr>
                    <th>Reg No</th><th>Student</th><th>Item</th>
                    <th style="text-align:right">Amount</th><th>Date</th>
                </tr></thead>
                <tbody><asp:Literal ID="litLatestBillRows" runat="server" /></tbody>
            </table>
        </div>
    </div>
</div>

<!-- ======= DATA INTEGRITY ======================================== -->
<div class="fd-section-hdr">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    Data Integrity &amp; Anomalies
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fs-card">
    <div class="fd-anomaly-grid">
        <asp:Literal ID="litAnomalyCards" runat="server" />
    </div>
</div>

<!-- ======= PAID BUT UNREGISTERED ================================ -->
<asp:Panel ID="pnlPaidUnregistered" runat="server" Visible="false">
<div class="fd-section-hdr" style="margin-top:4px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    Paid in Last 30 Days &mdash; Not Yet Registered
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fs-card">
    <div class="fs-card__header">
        <div class="fs-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
            Students with Payments but No Registration
        </div>
        <div class="fs-card__meta"><asp:Literal ID="litPaidUnregCount" runat="server" Text="0 students" /></div>
    </div>
    <div style="overflow-x:auto; max-height:400px; overflow-y:auto;">
        <table class="fs-table">
            <thead><tr>
                <th>Reg No</th><th>Student Name</th><th>Programme</th>
                <th style="text-align:right">Total Paid (30d)</th><th>Status</th><th>Last Payment</th>
            </tr></thead>
            <tbody><asp:Literal ID="litPaidUnregRows" runat="server" /></tbody>
        </table>
    </div>
</div>
</asp:Panel>

</div><!-- /fd-content -->

<!-- Hidden fields for chart data -->
<asp:HiddenField ID="hfDonutPaid" runat="server" Value="0" />
<asp:HiddenField ID="hfDonutBal" runat="server" Value="0" />
<asp:HiddenField ID="hfMonthLabels" runat="server" Value="" />
<asp:HiddenField ID="hfMonthValues" runat="server" Value="" />
<asp:HiddenField ID="hfMonthBillValues" runat="server" Value="" />
<asp:HiddenField ID="hfDailyLabels" runat="server" Value="" />
<asp:HiddenField ID="hfDailyValues" runat="server" Value="" />
<asp:HiddenField ID="hfMonthNonCash" runat="server" Value="" />
<asp:HiddenField ID="hfChannelLabels" runat="server" Value="" />
<asp:HiddenField ID="hfChannelValues" runat="server" Value="" />
<asp:HiddenField ID="hfDonutBursary" runat="server" Value="0" />

<!-- Chart.js v4 via CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
// ============================================================
// FEES DASHBOARD — Chart.js Interactive Charts & Searchable Select
// ============================================================
(function () {
    'use strict';

    // ---- Hidden field IDs (resolved server-side) ----
    var hfDonutPaidId  = '<%= hfDonutPaid.ClientID %>';
    var hfDonutBalId   = '<%= hfDonutBal.ClientID %>';
    var hfMonthLabId   = '<%= hfMonthLabels.ClientID %>';
    var hfMonthValId   = '<%= hfMonthValues.ClientID %>';
    var hfMonthBillId  = '<%= hfMonthBillValues.ClientID %>';
    var hfMonthNCId    = '<%= hfMonthNonCash.ClientID %>';
    var hfDailyLabId   = '<%= hfDailyLabels.ClientID %>';
    var hfDailyValId   = '<%= hfDailyValues.ClientID %>';
    var hfChLabId      = '<%= hfChannelLabels.ClientID %>';
    var hfChValId      = '<%= hfChannelValues.ClientID %>';

    // ---- Helpers ----
    function getVal(id) { var el = document.getElementById(id); return el ? el.value : ''; }
    function parseNums(csv) {
        if (!csv) return [];
        var arr = csv.split(','), out = [];
        for (var i = 0; i < arr.length; i++) out.push(parseFloat(arr[i]) || 0);
        return out;
    }
    function parseLabels(csv) { return csv ? csv.split(',') : []; }
    function fmtUGX(v) {
        return 'UGX ' + v.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }
    function fmtAxis(v) {
        if (v >= 1e9) return (v / 1e9).toFixed(1) + 'B';
        if (v >= 1e6) return (v / 1e6).toFixed(1) + 'M';
        if (v >= 1e3) return (v / 1e3).toFixed(0) + 'K';
        return v.toFixed(0);
    }
    var FONT = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';

    // Global Chart.js defaults
    if (typeof Chart !== 'undefined') {
        Chart.defaults.font.family = FONT;
        Chart.defaults.font.size = 11;
        Chart.defaults.animation.duration = 800;
        Chart.defaults.animation.easing = 'easeOutQuart';
    }

    // ============================================================
    // DONUT CHART — Collection Rate (Chart.js Doughnut)
    // ============================================================
    function initDonut() {
        var canvas = document.getElementById('cvDonut');
        if (!canvas || typeof Chart === 'undefined') return;
        var paid = parseFloat(getVal(hfDonutPaidId)) || 0;
        var bal  = parseFloat(getVal(hfDonutBalId)) || 0;
        var total = paid + bal;
        var pct = total > 0 ? Math.round(paid / total * 100) : 0;

        // Center text plugin
        var centerTextPlugin = {
            id: 'centerText',
            afterDraw: function (chart) {
                var ctx = chart.ctx;
                var w = chart.width, h = chart.height;
                ctx.save();
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.font = 'bold 28px ' + FONT;
                ctx.fillStyle = '#1a1a2e';
                ctx.fillText(pct + '%', w / 2, h / 2 - 6);
                ctx.font = '600 9px ' + FONT;
                ctx.fillStyle = '#888';
                ctx.fillText('COLLECTED', w / 2, h / 2 + 14);
                ctx.restore();
            }
        };

        new Chart(canvas, {
            type: 'doughnut',
            data: {
                labels: ['Paid', 'Outstanding'],
                datasets: [{
                    data: total > 0 ? [paid, bal] : [0, 1],
                    backgroundColor: total > 0 ? ['#16a34a', '#e8e8e8'] : ['#e8e8e8', '#e8e8e8'],
                    hoverBackgroundColor: total > 0 ? ['#15803d', '#d0d0d0'] : ['#e8e8e8', '#e8e8e8'],
                    borderWidth: 0,
                    borderRadius: 0
                }]
            },
            options: {
                cutout: '72%',
                responsive: false,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        enabled: total > 0,
                        backgroundColor: '#1a1a2e',
                        titleFont: { weight: '600', size: 11 },
                        bodyFont: { size: 11 },
                        padding: 10,
                        cornerRadius: 2,
                        callbacks: {
                            label: function (ctx) {
                                return ctx.label + ': ' + fmtUGX(ctx.parsed);
                            }
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    duration: 1000
                }
            },
            plugins: [centerTextPlugin]
        });
    }

    // ============================================================
    // STACKED BAR + LINE — Monthly Cash / Non-Cash / Billing (past 12 months)
    // ============================================================
    function initMonthly() {
        var canvas = document.getElementById('cvMonthly');
        if (!canvas || typeof Chart === 'undefined') return;
        var labels    = parseLabels(getVal(hfMonthLabId));
        var cashVals  = parseNums(getVal(hfMonthValId));
        var ncVals    = parseNums(getVal(hfMonthNCId));
        var billVals  = parseNums(getVal(hfMonthBillId));

        new Chart(canvas, {
            type: 'bar',
            data: {
                labels: labels.length > 0 ? labels : ['No data'],
                datasets: [
                    {
                        label: 'Cash Received',
                        type: 'bar',
                        data: cashVals.length > 0 ? cashVals : [0],
                        backgroundColor: 'rgba(22,163,74,0.80)',
                        hoverBackgroundColor: '#15803d',
                        borderWidth: 0,
                        stack: 'credits',
                        maxBarThickness: 40,
                        order: 3
                    },
                    {
                        label: 'Non-Cash Credits',
                        type: 'bar',
                        data: ncVals.length > 0 ? ncVals : [0],
                        backgroundColor: 'rgba(217,119,6,0.70)',
                        hoverBackgroundColor: '#b45309',
                        borderWidth: 0,
                        stack: 'credits',
                        maxBarThickness: 40,
                        order: 2
                    },
                    {
                        label: 'Billed',
                        type: 'line',
                        data: billVals.length > 0 ? billVals : [0],
                        borderColor: '#05275C',
                        backgroundColor: 'rgba(5,39,92,0.06)',
                        borderWidth: 2,
                        pointBackgroundColor: '#05275C',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 1.5,
                        pointRadius: 3,
                        pointHoverRadius: 5,
                        tension: 0.3,
                        fill: false,
                        order: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                layout: { padding: { top: 5 } },
                scales: {
                    x: {
                        stacked: true,
                        grid: { display: false },
                        ticks: { color: '#888', font: { size: 9, weight: '500' }, maxRotation: 45, minRotation: 45 },
                        border: { color: '#e0e5ed' }
                    },
                    y: {
                        stacked: false,
                        beginAtZero: true,
                        grid: { color: '#f0f2f5', drawBorder: false },
                        ticks: {
                            color: '#aaa', font: { size: 9 },
                            callback: function (v) { return fmtAxis(v); },
                            maxTicksLimit: 6
                        },
                        border: { display: false }
                    }
                },
                plugins: {
                    legend: {
                        display: true, position: 'top', align: 'start',
                        labels: { boxWidth: 10, boxHeight: 10, padding: 14, font: { size: 10, weight: '600' }, color: '#555' }
                    },
                    tooltip: {
                        backgroundColor: '#1a1a2e',
                        titleFont: { weight: '600', size: 11 },
                        bodyFont: { size: 11 },
                        padding: 10, cornerRadius: 2,
                        callbacks: {
                            label: function (ctx) { return ctx.dataset.label + ': ' + fmtUGX(ctx.parsed.y); }
                        }
                    }
                },
                animation: { duration: 900, easing: 'easeOutQuart' },
                interaction: { intersect: false, mode: 'index' }
            }
        });

        canvas.parentElement.style.height = '280px';
    }

    // ============================================================
    // DAILY PAYMENTS (PAST 30 DAYS) — Bar Chart
    // ============================================================
    function initDaily() {
        var canvas = document.getElementById('cvDaily');
        if (!canvas || typeof Chart === 'undefined') return;
        var labels = parseLabels(getVal(hfDailyLabId));
        var values = parseNums(getVal(hfDailyValId));

        new Chart(canvas, {
            type: 'bar',
            data: {
                labels: labels.length > 0 ? labels : ['No data'],
                datasets: [
                    {
                        label: 'Daily Payments',
                        data: values.length > 0 ? values : [0],
                        backgroundColor: '#16a34a',
                        hoverBackgroundColor: '#15803d',
                        borderWidth: 0,
                        borderRadius: 0,
                        maxBarThickness: 32
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                layout: { padding: { top: 5 } },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#888', font: { size: 9, weight: '500' } },
                        border: { display: false }
                    },
                    y: {
                        beginAtZero: true,
                        grid: { color: '#f0f2f5', drawBorder: false },
                        ticks: {
                            color: '#aaa',
                            font: { size: 9 },
                            callback: function (v) { return fmtAxis(v); },
                            maxTicksLimit: 6
                        },
                        border: { display: false }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        align: 'start',
                        labels: {
                            boxWidth: 10,
                            boxHeight: 10,
                            padding: 14,
                            font: { size: 10, weight: '600' },
                            color: '#555',
                            usePointStyle: false
                        }
                    },
                    tooltip: {
                        backgroundColor: '#1a1a2e',
                        titleFont: { weight: '600', size: 11 },
                        bodyFont: { size: 11 },
                        padding: 10,
                        cornerRadius: 2,
                        callbacks: {
                            label: function (ctx) {
                                return ctx.dataset.label + ': ' + fmtUGX(ctx.parsed.y);
                            }
                        }
                    }
                },
                animation: {
                    duration: 900,
                    easing: 'easeOutQuart'
                },
                interaction: {
                    intersect: false,
                    mode: 'index'
                }
            }
        });

        // Set fixed height on container
        canvas.parentElement.style.height = '280px';
    }

    // ============================================================
    // SEARCHABLE SELECT WIDGET
    // ============================================================
    function initSearchable(sel) {
        if (!sel || sel.dataset.srchInit) return;
        sel.dataset.srchInit = '1';

        var wrap = document.createElement('div');
        wrap.className = 'cd-srch-wrap';
        sel.parentNode.insertBefore(wrap, sel);
        wrap.appendChild(sel);
        sel.style.display = 'none';

        var input = document.createElement('input');
        input.type = 'text';
        input.className = 'fs-filter-select cd-srch-input';
        input.autocomplete = 'off';
        input.spellcheck = false;

        var panel = document.createElement('div');
        panel.className = 'cd-srch-panel';

        wrap.appendChild(input);
        wrap.appendChild(panel);

        function syncDisplay() {
            var idx = sel.selectedIndex;
            var opt = (idx >= 0) ? sel.options[idx] : null;
            if (opt && opt.value !== '') {
                input.value = opt.text;
                input.placeholder = '';
            } else {
                input.value = '';
                input.placeholder = opt ? opt.text : '\u2014 select \u2014';
            }
        }
        syncDisplay();

        function buildList(filter) {
            panel.innerHTML = '';
            var q = (filter || '').toLowerCase().trim();
            var opts = sel.options;
            var added = 0;
            for (var i = 0; i < opts.length; i++) {
                var o = opts[i];
                if (q && o.text.toLowerCase().indexOf(q) < 0 && o.value.toLowerCase().indexOf(q) < 0) continue;
                var el = document.createElement('div');
                el.className = 'cd-srch-item';
                if (o.value === '') el.className += ' cd-srch-item--placeholder';
                if (o.value === sel.value) el.className += ' cd-srch-item--sel';
                el.textContent = o.text;
                el.dataset.v = o.value;
                el.addEventListener('mousedown', function (e) {
                    e.preventDefault();
                    choose(this.dataset.v);
                });
                panel.appendChild(el);
                added++;
            }
            if (added === 0) {
                var em = document.createElement('div');
                em.className = 'cd-srch-item cd-srch-item--empty';
                em.textContent = 'No matches';
                panel.appendChild(em);
            }
            panel.style.display = 'block';
        }

        function choose(val) {
            sel.value = val;
            syncDisplay();
            panel.style.display = 'none';
            var ev = document.createEvent('Event');
            ev.initEvent('change', true, true);
            sel.dispatchEvent(ev);
        }

        function openPanel() { buildList(input.value); }
        function closePanel() { panel.style.display = 'none'; }

        input.addEventListener('focus', openPanel);
        input.addEventListener('input', function () { buildList(this.value); });
        input.addEventListener('blur',  function () { setTimeout(closePanel, 180); });
        input.addEventListener('keydown', function (e) {
            var items = panel.querySelectorAll('.cd-srch-item:not(.cd-srch-item--empty)');
            var active = panel.querySelector('.cd-srch-item--hover');
            if (e.key === 'ArrowDown' || e.keyCode === 40) {
                e.preventDefault();
                var next = active ? active.nextElementSibling : items[0];
                if (active) active.classList.remove('cd-srch-item--hover');
                if (next && next.className.indexOf('cd-srch-item--empty') < 0) {
                    next.classList.add('cd-srch-item--hover');
                    next.scrollIntoView({ block: 'nearest' });
                }
            } else if (e.key === 'ArrowUp' || e.keyCode === 38) {
                e.preventDefault();
                var prev = active ? active.previousElementSibling : items[items.length - 1];
                if (active) active.classList.remove('cd-srch-item--hover');
                if (prev && prev.className.indexOf('cd-srch-item--empty') < 0) {
                    prev.classList.add('cd-srch-item--hover');
                    prev.scrollIntoView({ block: 'nearest' });
                }
            } else if (e.key === 'Enter' || e.keyCode === 13) {
                e.preventDefault();
                if (active) choose(active.dataset.v);
            } else if (e.key === 'Escape' || e.keyCode === 27) {
                closePanel();
            }
        });
    }

    // ============================================================
    // PAYMENT CHANNEL BAR CHART (horizontal)
    // ============================================================
    function initChannel() {
        var canvas = document.getElementById('cvChannel');
        if (!canvas || typeof Chart === 'undefined') return;
        var labels = parseLabels(getVal(hfChLabId));
        var values = parseNums(getVal(hfChValId));
        if (!labels.length) { canvas.parentElement.innerHTML = '<div style="padding:30px;text-align:center;color:#aaa;font-size:11px;">No data</div>'; return; }

        var colors = ['#16a34a', '#174DA4', '#d97706', '#6b7280'];
        new Chart(canvas, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Amount Received',
                    data: values,
                    backgroundColor: colors.slice(0, values.length),
                    hoverBackgroundColor: colors.slice(0, values.length),
                    borderWidth: 0, borderRadius: 0, maxBarThickness: 42
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true, maintainAspectRatio: false,
                layout: { padding: { right: 10 } },
                scales: {
                    x: {
                        beginAtZero: true,
                        grid: { color: '#f0f2f5', drawBorder: false },
                        ticks: { color: '#aaa', font: { size: 9 }, callback: function(v){ return fmtAxis(v); } },
                        border: { display: false }
                    },
                    y: { grid: { display: false }, ticks: { color: '#555', font: { size: 11, weight: '600' } }, border: { display: false } }
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1a1a2e', titleFont: { weight: '600', size: 11 },
                        bodyFont: { size: 11 }, padding: 10, cornerRadius: 2,
                        callbacks: { label: function(ctx){ return 'Received: ' + fmtUGX(ctx.parsed.x); } }
                    }
                },
                animation: { duration: 900, easing: 'easeOutQuart' }
            }
        });
        canvas.parentElement.style.height = '200px';
    }

    // ============================================================
    // NON-CASH CREDITS DONUT (Bursaries vs Waivers)
    // ============================================================
    function initNonCash() {
        var canvas = document.getElementById('cvNonCash');
        if (!canvas || typeof Chart === 'undefined') return;
        var ncVals   = parseNums(getVal(hfMonthNCId));
        var cashVals = parseNums(getVal(hfMonthValId));
        var ncTotal  = 0; var cashTotal = 0;
        for (var i = 0; i < ncVals.length; i++)   ncTotal   += ncVals[i];
        for (var i = 0; i < cashVals.length; i++)  cashTotal += cashVals[i];
        var grandTotal = cashTotal + ncTotal;
        var cashPct = grandTotal > 0 ? Math.round(cashTotal / grandTotal * 100) : 0;

        var centerPlugin = {
            id: 'ncCenter',
            afterDraw: function(chart) {
                var ctx = chart.ctx, w = chart.width, h = chart.height;
                ctx.save();
                ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
                ctx.font = 'bold 22px ' + FONT;
                ctx.fillStyle = '#16a34a';
                ctx.fillText(cashPct + '%', w/2, h/2 - 8);
                ctx.font = '600 9px ' + FONT;
                ctx.fillStyle = '#888';
                ctx.fillText('CASH', w/2, h/2 + 10);
                ctx.restore();
            }
        };

        new Chart(canvas, {
            type: 'doughnut',
            data: {
                labels: ['Cash Received', 'Non-Cash Credits'],
                datasets: [{
                    data: grandTotal > 0 ? [cashTotal, ncTotal] : [1, 0],
                    backgroundColor: grandTotal > 0 ? ['#16a34a', '#d97706'] : ['#e8e8e8', '#e8e8e8'],
                    borderWidth: 0
                }]
            },
            options: {
                cutout: '72%', responsive: true, maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true, position: 'bottom',
                        labels: { boxWidth: 10, boxHeight: 10, padding: 12, font: { size: 10, weight: '600' }, color: '#555' }
                    },
                    tooltip: {
                        backgroundColor: '#1a1a2e', titleFont: { weight: '600', size: 11 }, bodyFont: { size: 11 }, padding: 10, cornerRadius: 2,
                        callbacks: { label: function(ctx){ return ctx.label + ': ' + fmtUGX(ctx.parsed); } }
                    }
                }
            },
            plugins: [centerPlugin]
        });
        canvas.parentElement.style.height = '220px';
    }

    // ============================================================
    // INIT ALL
    // ============================================================
    function initAll() {
        initDonut();
        initMonthly();
        initDaily();
        initChannel();
        initNonCash();
        var sels = document.querySelectorAll('select.fs-filter-select');
        for (var i = 0; i < sels.length; i++) initSearchable(sels[i]);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initAll);
    } else {
        // Slight delay to ensure layout is ready for Chart.js responsive sizing
        setTimeout(initAll, 50);
    }
}());
</script>

</asp:Content>
