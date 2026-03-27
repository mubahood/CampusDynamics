<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FeesStructurePrint.aspx.cs" Inherits="COOPERP_NewScreens_FeesStructurePrint" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Fee Structure — <asp:Literal ID="litTitleInst" runat="server" Text="Fee Structure" /></title>
<style>
/* ===== PRINT-READY FEE STRUCTURE DOCUMENT ===== */
@page {
    size: A4 landscape;
    margin: 12mm 14mm 14mm 14mm;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 10px; color: #1a1a2e; line-height: 1.4;
    background: #fff;
}

/* ── Cover / Header ─────────────────────────── */
.doc-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px; margin-bottom: 4px;
    border-bottom: 3px solid #05275C;
    background: linear-gradient(135deg, #f8f9fb 0%, #eef2fa 100%);
    page-break-inside: avoid;
}
.doc-header__left { display: flex; align-items: center; gap: 16px; }
.doc-header__logo { width: 72px; height: 72px; object-fit: contain; }
.doc-header__text { display: flex; flex-direction: column; gap: 2px; }
.doc-header__uni { font-size: 18px; font-weight: 800; color: #05275C; letter-spacing: -.3px; text-transform: uppercase; }
.doc-header__motto { font-size: 9px; color: #666; font-style: italic; letter-spacing: .3px; }
.doc-header__title { font-size: 15px; font-weight: 700; color: #174DA4; margin-top: 4px; }
.doc-header__right { text-align: right; display: flex; flex-direction: column; gap: 3px; }
.doc-header__meta { font-size: 9px; color: #555; }
.doc-header__meta strong { color: #05275C; }
.doc-header__badge {
    display: inline-block; padding: 3px 10px; font-size: 9px; font-weight: 700;
    background: #05275C; color: #fff; text-transform: uppercase; letter-spacing: .5px;
    margin-top: 4px;
}

/* ── Summary stripe ─────────────────────────── */
.doc-summary {
    display: flex; gap: 0; margin-bottom: 10px;
    border: 1px solid #e0e5ed; page-break-inside: avoid;
}
.doc-summary__item {
    flex: 1; padding: 8px 12px; text-align: center;
    border-right: 1px solid #e0e5ed; background: #f8f9fb;
}
.doc-summary__item:last-child { border-right: none; }
.doc-summary__val { font-size: 16px; font-weight: 800; color: #05275C; }
.doc-summary__val--green { color: #155724; }
.doc-summary__val--amber { color: #b45309; }
.doc-summary__label { font-size: 8px; text-transform: uppercase; letter-spacing: .4px; color: #888; font-weight: 700; margin-top: 1px; }

/* ── Faculty section ────────────────────────── */
.fac-section { margin-bottom: 12px; page-break-inside: avoid; }
.fac-header {
    padding: 7px 12px; background: #05275C; color: #fff;
    display: flex; align-items: center; justify-content: space-between;
    page-break-after: avoid;
}
.fac-header__name { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; }
.fac-header__count { font-size: 9px; opacity: .8; }

/* ── Programme table ────────────────────────── */
.fee-table { width: 100%; border-collapse: collapse; font-size: 9px; border: 1px solid #d0d5de; }
.fee-table th {
    background: #f5f7fa; font-size: 7.5px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .3px; color: #555; padding: 5px 6px; text-align: center;
    border: 1px solid #d0d5de; white-space: nowrap;
}
.fee-table th.th-prog { text-align: left; min-width: 160px; }
.fee-table th.th-group { background: #eef2fa; color: #05275C; font-size: 8px; border-bottom: 2px solid #174DA4; }
.fee-table td {
    padding: 4px 6px; border: 1px solid #e4e8ef; vertical-align: middle;
    text-align: right; font-variant-numeric: tabular-nums;
}
.fee-table td.td-prog { text-align: left; font-weight: 600; color: #1a1a2e; font-size: 9px; }
.fee-table td.td-code { text-align: left; font-family: Consolas, monospace; font-size: 8px; color: #174DA4; font-weight: 700; }
.fee-table td.td-total { font-weight: 800; color: #05275C; background: rgba(5,39,92,.03); }
.fee-table td.td-yr-total { font-weight: 700; color: #174DA4; background: rgba(23,77,164,.04); }
.fee-table tr:hover td { background: #f9fbff; }
.fee-table tr.row-inactive td { color: #999; background: #fafafa; }
.fee-table .status-active { color: #155724; font-weight: 700; font-size: 8px; }
.fee-table .status-inactive { color: #dc3545; font-weight: 700; font-size: 8px; }
.fee-table .na { color: #ccc; font-size: 8px; }

/* ── Faculty subtotal row ───────────────────── */
.fee-table tr.fac-subtotal td {
    background: #eef2fa; font-weight: 800; color: #05275C;
    border-top: 2px solid #174DA4; font-size: 9px;
}

/* ── Footer ─────────────────────────────────── */
.doc-footer {
    margin-top: 14px; padding: 10px 16px;
    border-top: 2px solid #05275C;
    display: flex; justify-content: space-between; align-items: center;
    font-size: 8px; color: #888;
    page-break-inside: avoid;
}
.doc-footer__left { line-height: 1.6; }
.doc-footer__right { text-align: right; }
.doc-footer__note {
    margin-top: 6px; padding: 6px 10px; background: #fffbe6;
    border: 1px solid #ffe58f; font-size: 8px; color: #7c6a00;
    page-break-inside: avoid;
}

/* ── Print controls (hidden when printing) ─── */
.print-controls {
    position: fixed; top: 0; left: 0; right: 0; z-index: 9999;
    background: #05275C; padding: 8px 20px;
    display: flex; align-items: center; justify-content: space-between;
    box-shadow: 0 2px 12px rgba(0,0,0,.2);
}
.print-controls__info { color: rgba(255,255,255,.8); font-size: 12px; }
.print-controls__info strong { color: #fff; }
.print-controls__btns { display: flex; gap: 8px; }
.print-controls__btn {
    padding: 6px 18px; font-size: 12px; font-weight: 700; border: none; cursor: pointer;
    display: inline-flex; align-items: center; gap: 6px;
}
.print-controls__btn--print { background: #fff; color: #05275C; }
.print-controls__btn--print:hover { background: #eee; }
.print-controls__btn--close { background: rgba(255,255,255,.15); color: #fff; border: 1px solid rgba(255,255,255,.3); }
.print-controls__btn--close:hover { background: rgba(255,255,255,.25); }

@media print {
    .print-controls { display: none !important; }
    body { padding-top: 0 !important; }
    .fac-section { page-break-inside: avoid; }
}
@media screen {
    body { padding-top: 50px; max-width: 1200px; margin: 0 auto; padding-left: 16px; padding-right: 16px; }
}
</style>
</head>
<body>

<!-- Print controls bar (visible on screen only) -->
<div class="print-controls">
    <div class="print-controls__info">
        <strong><asp:Literal ID="litBarInst" runat="server" /> — Fee Structure Report</strong> &mdash; <asp:Literal ID="litPrintDate" runat="server" />
    </div>
    <div class="print-controls__btns">
        <button class="print-controls__btn print-controls__btn--print" onclick="window.print();">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9V2h12v7"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print / Save as PDF
        </button>
        <button class="print-controls__btn print-controls__btn--close" onclick="window.close();">Close</button>
    </div>
</div>

<!-- ── Document Header / Letterhead ──────────── -->
<div class="doc-header">
    <div class="doc-header__left">
        <asp:Image ID="imgLogo" runat="server" CssClass="doc-header__logo" Visible="false" />
        <div class="doc-header__text">
            <div class="doc-header__uni"><asp:Literal ID="litInstitution" runat="server" /></div>
            <div class="doc-header__motto"><asp:Literal ID="litMotto" runat="server" /></div>
            <div class="doc-header__title">Complete Fee Structure Report</div>
        </div>
    </div>
    <div class="doc-header__right">
        <div class="doc-header__meta"><strong>Date:</strong> <asp:Literal ID="litDocDate" runat="server" /></div>
        <div class="doc-header__meta"><strong>Academic Year:</strong> <asp:Literal ID="litAcadYear" runat="server" /></div>
        <div class="doc-header__meta"><strong>Currency:</strong> Uganda Shillings (UGX)</div>
        <div class="doc-header__meta"><strong>Generated by:</strong> <asp:Literal ID="litGenBy" runat="server" /></div>
        <span class="doc-header__badge">Official Document</span>
    </div>
</div>

<!-- ── Summary stripe ────────────────────────── -->
<div class="doc-summary">
    <div class="doc-summary__item">
        <div class="doc-summary__val"><asp:Literal ID="litSumTotal" runat="server" Text="0" /></div>
        <div class="doc-summary__label">Total Programmes</div>
    </div>
    <div class="doc-summary__item">
        <div class="doc-summary__val doc-summary__val--green"><asp:Literal ID="litSumActive" runat="server" Text="0" /></div>
        <div class="doc-summary__label">Active Structures</div>
    </div>
    <div class="doc-summary__item">
        <div class="doc-summary__val doc-summary__val--amber"><asp:Literal ID="litSumInactive" runat="server" Text="0" /></div>
        <div class="doc-summary__label">Inactive</div>
    </div>
    <div class="doc-summary__item">
        <div class="doc-summary__val"><asp:Literal ID="litSumFaculties" runat="server" Text="0" /></div>
        <div class="doc-summary__label">Faculties</div>
    </div>
</div>

<!-- ── Fee structure tables (rendered from code-behind) ── -->
<asp:Literal ID="litBody" runat="server" />

<!-- ── Footer ────────────────────────────────── -->
<div class="doc-footer__note">
    <strong>Note:</strong> All amounts are in Uganda Shillings (UGX). Fee structures marked as &ldquo;Active&rdquo; are the current billing rates.
    Inactive structures are retained for reference but are not used for billing. Semester 3 fees apply only for programmes
    that run trimester systems. Amounts are per semester. Contact the Finance Office for queries.
</div>
<div class="doc-footer">
    <div class="doc-footer__left">
        <asp:Literal ID="litFootInst" runat="server" />
        <br /><asp:Literal ID="litFootContact" runat="server" />
    </div>
    <div class="doc-footer__right">
        Campus Dynamics EMIS &bull; Generated: <asp:Literal ID="litFootDate" runat="server" />
        <br />This is a system-generated document.
    </div>
</div>

</body>
</html>