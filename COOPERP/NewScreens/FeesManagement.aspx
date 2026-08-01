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

/* ---- Bursary section ---- */
.fd-bursary-kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:14px;}
@media(max-width:900px){.fd-bursary-kpis{grid-template-columns:repeat(2,1fr);}}
.fd-bursary-kpi{background:#fff;border:1px solid #e0e5ed;padding:14px 16px;position:relative;overflow:hidden;}
.fd-bursary-kpi::before{content:'';position:absolute;left:0;top:0;width:3px;height:100%;}
.fd-bursary-kpi--credited::before{background:#1d4ed8;}
.fd-bursary-kpi--coverage::before{background:#15803d;}
.fd-bursary-kpi--schemes::before{background:#7c3aed;}
.fd-bursary-kpi--beneficiaries::before{background:#0891b2;}
.fd-bursary-kpi__icon{width:28px;height:28px;display:flex;align-items:center;justify-content:center;margin-bottom:8px;}
.fd-bursary-kpi__label{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#888;font-weight:700;margin-bottom:4px;}
.fd-bursary-kpi__val{font-size:20px;font-weight:800;color:#1a1a2e;line-height:1.1;margin-bottom:4px;font-variant-numeric:tabular-nums;}
.fd-bursary-kpi__sub{font-size:10px;color:#aaa;line-height:1.4;}

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
/* ---- Recent Transactions (rtx) ---- */
.rtx__bar { display:flex; align-items:center; flex-wrap:wrap; gap:8px; padding:10px 12px; border-bottom:1px solid #e0e5ed; }
.rtx__chips { display:flex; gap:4px; }
.rtx-chip { padding:5px 12px; font-size:12px; font-weight:600; border:1px solid #cdd5e1; background:#fff; color:#334155; cursor:pointer; border-radius:0; }
.rtx-chip.is-active { background:#05275C; color:#fff; border-color:#05275C; }
.rtx-chip:hover { border-color:#174DA4; }
.rtx__refresh { font-size:14px; line-height:1; padding:5px 10px; }
.rtx__search { flex:1 1 200px; min-width:150px; padding:6px 10px; font-size:12px; border:1px solid #cdd5e1; border-radius:0; }
.rtx__sel { padding:6px 8px; font-size:12px; border:1px solid #cdd5e1; background:#fff; border-radius:0; }
.rtx__auto { font-size:11px; color:#555; display:inline-flex; align-items:center; gap:4px; cursor:pointer; }
.rtx__updated { font-size:11px; color:#94a3b8; margin-left:auto; }
.rtx__wrap { overflow-x:auto; max-height:520px; overflow-y:auto; }
.rtx__tbl { width:100%; }
.rtx__tbl tbody tr:nth-child(even) { background:#f6f8fb; }
.rtx-click { cursor:pointer; }
.rtx-click:hover { background:#e8f0fd !important; }
.rtx-when { white-space:nowrap; font-size:11px; color:#475569; }
.rtx-reg { font-weight:600; color:#05275C; white-space:nowrap; }
.rtx-prog { font-size:11px; color:#64748b; max-width:180px; }
.rtx-item { font-size:12px; }
.rtx-det { display:block; font-size:10px; color:#94a3b8; margin-top:1px; max-width:260px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.rtx-b { display:inline-block; padding:1px 7px; font-size:10px; font-weight:600; border-radius:2px; background:#eef1f6; color:#475569; }
.rtx-b--pay { background:#e7f6ec; color:#15803d; }
.rtx-b--bill { background:#eaf1fc; color:#174DA4; }
.rtx-empty { text-align:center; color:#aaa; padding:26px; font-size:12px; }
.rtx-ovl { display:none; position:fixed; inset:0; background:rgba(10,20,40,.5); z-index:10000; align-items:center; justify-content:center; padding:20px; }
.rtx-ovl.open { display:flex; }
.rtx-modal { background:#fff; width:560px; max-width:96vw; max-height:88vh; display:flex; flex-direction:column; border-radius:2px; box-shadow:0 16px 48px rgba(0,0,0,.28); }
.rtx-modal__hd { display:flex; align-items:center; justify-content:space-between; padding:12px 16px; border-bottom:1px solid #e0e5ed; }
.rtx-modal__hd h3 { margin:0; font-size:14px; color:#05275C; }
.rtx-modal__x { background:none; border:none; font-size:22px; line-height:1; color:#888; cursor:pointer; }
.rtx-modal__x:hover { color:#dc3545; }
.rtx-modal__bd { padding:14px 16px; overflow-y:auto; }
.rtx-sec { margin-bottom:14px; }
.rtx-sec__t { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; color:#05275C; margin-bottom:6px; display:flex; align-items:center; justify-content:space-between; gap:10px; }
.rtx-kv { display:grid; grid-template-columns:130px 1fr; gap:4px 10px; font-size:12px; }
.rtx-k { color:#64748b; }
.rtx-v { color:#1a1a2e; font-weight:500; word-break:break-word; }
.rtx-lnk { font-size:11px; font-weight:600; color:#174DA4; text-decoration:none; }
.rtx-lnk:hover { text-decoration:underline; }
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
    Recent Transactions
    <span class="fd-section-hdr__line"></span>
</div>
<div class="fs-card rtx">
    <div class="rtx__bar">
        <div class="rtx__chips">
            <button type="button" class="rtx-chip is-active" data-type="all" onclick="rtxType('all',this)">All</button>
            <button type="button" class="rtx-chip" data-type="payment" onclick="rtxType('payment',this)">Payments</button>
            <button type="button" class="rtx-chip" data-type="bill" onclick="rtxType('bill',this)">Bills</button>
        </div>
        <input type="text" id="rtxQ" class="rtx__search" placeholder="Search reg no, name or detail…" onkeydown="if(event.key==='Enter')rtxLoad();" />
        <select id="rtxScope" class="rtx__sel" onchange="rtxLoad()" title="Scope">
            <option value="all">All years</option>
            <option value="year">Selected year</option>
        </select>
        <select id="rtxLimit" class="rtx__sel" onchange="rtxLoad()" title="Rows">
            <option value="25">25</option>
            <option value="50" selected="selected">50</option>
            <option value="100">100</option>
            <option value="200">200</option>
        </select>
        <button type="button" class="rtx-chip rtx__refresh" onclick="rtxLoad()" title="Refresh">&#8635;</button>
        <label class="rtx__auto"><input type="checkbox" id="rtxAuto" onchange="rtxToggleAuto()" /> Live</label>
        <span class="rtx__updated" id="rtxUpdated"></span>
    </div>
    <div class="rtx__wrap">
        <table class="fs-table rtx__tbl">
            <thead><tr>
                <th>When</th><th>Reg No</th><th>Student</th><th>Programme</th>
                <th>Item / detail</th><th style="text-align:right">Amount</th><th>Type</th>
            </tr></thead>
            <tbody id="rtxRows"><tr><td colspan="7" class="rtx-empty">Loading&hellip;</td></tr></tbody>
        </table>
    </div>
</div>

<!-- legacy "Latest" literals kept (hidden) so the server-side dashboard snapshot stays intact -->
<div style="display:none;">
    <asp:Literal ID="litLatestPayRows" runat="server" />
    <asp:Literal ID="litLatestBillRows" runat="server" />
</div>

<!-- transaction detail modal -->
<div class="rtx-ovl" id="rtxOvl" onclick="if(event.target===this)rtxClose()">
    <div class="rtx-modal">
        <div class="rtx-modal__hd"><h3 id="rtxTitle">Transaction</h3><button type="button" class="rtx-modal__x" onclick="rtxClose()">&times;</button></div>
        <div class="rtx-modal__bd" id="rtxBody"></div>
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

<!-- ======= BURSARY SCHEMES & BENEFICIARIES ====================== -->
<div class="fd-section-hdr" style="margin-top:4px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#1d4ed8" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
    Bursary Schemes &amp; Beneficiaries
    <span class="fd-section-hdr__line"></span>
</div>
<asp:Literal ID="litBursarySection" runat="server" />

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

/* ============ Recent Transactions (dynamic + clickable) ============ */
var _rtx = { type:'all', auto:null };
function _rq(id){ return document.getElementById(id); }
function rtxEsc(s){ s=(s==null?'':''+s); return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function rtxMoney(n){ n=Number(n)||0; return 'UGX '+n.toLocaleString('en-US',{maximumFractionDigits:0}); }
function rtxYear(){ var d=document.getElementById('<%= ddlAcadYear.ClientID %>'); return d?d.value:''; }
function rtxType(t, el){ _rtx.type=t; var c=el.parentNode.children; for(var i=0;i<c.length;i++) c[i].classList.remove('is-active'); el.classList.add('is-active'); rtxLoad(); }
function rtxToggleAuto(){ if(_rtx.auto){ clearInterval(_rtx.auto); _rtx.auto=null; } if(_rq('rtxAuto').checked){ _rtx.auto=setInterval(rtxLoad,20000); rtxLoad(); } }
function rtxLoad(){
    var tb=_rq('rtxRows'); if(!tb) return;
    var url='FeesManagement.aspx?act=recenttx'
        +'&type='+encodeURIComponent(_rtx.type)
        +'&q='+encodeURIComponent(_rq('rtxQ').value)
        +'&scope='+encodeURIComponent(_rq('rtxScope').value)
        +'&limit='+encodeURIComponent(_rq('rtxLimit').value)
        +'&year='+encodeURIComponent(rtxYear());
    fetch(url,{credentials:'same-origin',headers:{'X-Requested-With':'XMLHttpRequest'}})
      .then(function(r){return r.json();})
      .then(function(d){
          if(!d.ok){ tb.innerHTML='<tr><td colspan="7" class="rtx-empty">Failed to load transactions.</td></tr>'; return; }
          if(!d.rows.length){ tb.innerHTML='<tr><td colspan="7" class="rtx-empty">No transactions match your filters.</td></tr>'; }
          else {
              tb.innerHTML=d.rows.map(function(x){
                  var badge = x.type==='Payment' ? '<span class="rtx-b rtx-b--pay">Payment</span>'
                            : x.type==='Bill' ? '<span class="rtx-b rtx-b--bill">Bill</span>'
                            : '<span class="rtx-b">'+rtxEsc(x.type||'—')+'</span>';
                  var col = x.type==='Payment' ? '#15803d' : '#174DA4';
                  var det = x.detail ? '<span class="rtx-det" title="'+rtxEsc(x.detail)+'">'+rtxEsc(x.detail)+'</span>' : '';
                  return '<tr class="rtx-click" title="Click for full details" onclick="rtxDetail('+x.tid+')">'
                      +'<td class="rtx-when">'+rtxEsc(x.date)+'</td>'
                      +'<td class="rtx-reg">'+rtxEsc(x.regno)+'</td>'
                      +'<td>'+rtxEsc(x.name||'—')+'</td>'
                      +'<td class="rtx-prog">'+rtxEsc(x.prog||'—')+'</td>'
                      +'<td class="rtx-item">'+rtxEsc(x.item)+det+'</td>'
                      +'<td style="text-align:right;font-weight:600;color:'+col+'">'+rtxMoney(x.amount)+'</td>'
                      +'<td>'+badge+'</td></tr>';
              }).join('');
          }
          var u=_rq('rtxUpdated'); if(u) u.textContent='Updated '+new Date().toLocaleTimeString()+' · '+(d.count||0)+' shown';
      })
      .catch(function(){ tb.innerHTML='<tr><td colspan="7" class="rtx-empty">Network error — try Refresh.</td></tr>'; });
}
function rtxKv(k,v){ return '<div class="rtx-k">'+rtxEsc(k)+'</div><div class="rtx-v">'+(v==null||v===''?'—':rtxEsc(v))+'</div>'; }
function rtxDetail(tid){
    _rq('rtxTitle').textContent='Transaction #'+tid;
    _rq('rtxBody').innerHTML='<div class="rtx-empty">Loading…</div>';
    _rq('rtxOvl').classList.add('open');
    fetch('FeesManagement.aspx?act=txdetail&tid='+tid,{credentials:'same-origin',headers:{'X-Requested-With':'XMLHttpRequest'}})
      .then(function(r){return r.json();})
      .then(function(d){
          if(!d.ok||!d.txn){ _rq('rtxBody').innerHTML='<div class="rtx-empty">'+rtxEsc((d&&d.message)||'Not found.')+'</div>'; return; }
          var t=d.txn, s=d.student, b=d.balance, l=d.links;
          var h='';
          h+='<div class="rtx-sec"><div class="rtx-sec__t"><span>Transaction</span></div><div class="rtx-kv">';
          h+=rtxKv('Type',t.type)+rtxKv('Amount',rtxMoney(t.amount))+rtxKv('Date',t.date)+rtxKv('Item',t.item)+rtxKv('Detail',t.detail)+rtxKv('Period',t.year+'  ·  Sem '+t.sem)+rtxKv('Status',t.status);
          h+='</div></div>';
          if(s){ h+='<div class="rtx-sec"><div class="rtx-sec__t"><span>Student</span>'+(l?'<a class="rtx-lnk" href="'+rtxEsc(l.profile)+'" target="_blank" rel="noopener">Open profile ↗</a>':'')+'</div><div class="rtx-kv">';
              h+=rtxKv('Reg No',t.regno)+rtxKv('Name',s.name)+rtxKv('Programme',s.programme)+rtxKv('Status',s.status)+rtxKv('Gender',s.gender)+rtxKv('Phone',s.phone)+rtxKv('Email',s.email)+rtxKv('Entry year',s.entryyear);
              h+='</div></div>'; }
          if(b){ h+='<div class="rtx-sec"><div class="rtx-sec__t"><span>Account</span>'+(l?'<a class="rtx-lnk" href="'+rtxEsc(l.ledger)+'" target="_blank" rel="noopener">Open ledger ↗</a>':'')+'</div><div class="rtx-kv">';
              h+=rtxKv('Total billed',rtxMoney(b.billed))+rtxKv('Total paid',rtxMoney(b.paid))+rtxKv('Balance',rtxMoney(b.balance));
              h+='</div></div>'; }
          _rq('rtxBody').innerHTML=h;
      })
      .catch(function(){ _rq('rtxBody').innerHTML='<div class="rtx-empty">Failed to load detail.</div>'; });
}
function rtxClose(){ _rq('rtxOvl').classList.remove('open'); }
document.addEventListener('keydown', function(e){ if(e.key==='Escape') rtxClose(); });
rtxLoad();
</script>

</asp:Content>
