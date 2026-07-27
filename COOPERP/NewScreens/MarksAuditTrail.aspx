<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksAuditTrail.aspx.cs" Inherits="COOPERP_NewScreens_MarksAuditTrail" Title="Marks Audit Trail - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== MARKS AUDIT TRAIL — mat- design system ==================== */

/* ── Shared Nav (em- = Exams Module) ── */
.em-hdr{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:12px 20px}
.em-hdr__title{font-size:15px;font-weight:700}
.em-hdr__sub{font-size:10px;opacity:.7;margin-top:1px}
.em-hdr__actions{display:flex;gap:6px;align-items:center}
.em-tabs{display:flex;gap:0;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 16px;overflow-x:auto;margin-bottom:12px}
.em-tab{padding:9px 14px;font-size:11px;font-weight:500;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;white-space:nowrap;transition:color .15s,border-color .15s}
.em-tab:hover{color:#1a237e}
.em-tab--active{color:#1a237e;border-bottom-color:#1a237e;font-weight:600}

/* ── Stats Row — redesigned with icons + trends ── */
.mat-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.mat-stat{background:#fff;border:1px solid #e0e5ed;padding:14px 16px;position:relative;overflow:hidden;transition:border-color .2s,box-shadow .2s}
.mat-stat:hover{border-color:#c5cae9;box-shadow:0 2px 8px rgba(26,35,126,.08)}
.mat-stat::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--c,#ccc)}
.mat-stat__top{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:6px}
.mat-stat__icon{width:36px;height:36px;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:var(--bg,#f5f5f5)}
.mat-stat__icon svg{width:18px;height:18px;fill:var(--c,#888)}
.mat-stat__label{font-size:10px;text-transform:uppercase;letter-spacing:.6px;color:#888;font-weight:600}
.mat-stat__val{font-size:22px;font-weight:800;line-height:1.2;font-variant-numeric:tabular-nums;color:var(--c,#333);margin-top:2px}
.mat-stat__foot{margin-top:4px;min-height:16px}
.mat-trend{font-size:10px;font-weight:600;letter-spacing:.2px}
.mat-trend--up{color:#2e7d32}
.mat-trend--down{color:#c62828}
.mat-trend--flat{color:#90a4ae}
.mat-sub{font-size:10px;color:#90a4ae;font-weight:500}

.mat-stat--total{--c:#1a237e;--bg:rgba(26,35,126,.07)}
.mat-stat--today{--c:#2e7d32;--bg:rgba(46,125,50,.07)}
.mat-stat--week{--c:#d97706;--bg:rgba(217,119,6,.07)}
.mat-stat--month{--c:#0277bd;--bg:rgba(2,119,189,.07)}
.mat-stat--critical{--c:#c62828;--bg:rgba(198,40,40,.07)}
.mat-stat--users{--c:#6a1b9a;--bg:rgba(106,27,154,.07)}
.mat-stat--top{--c:#00838f;--bg:rgba(0,131,143,.07)}
.mat-stat--avg{--c:#4e342e;--bg:rgba(78,52,46,.07)}

/* ── Quick-Filter Chips ── */
.mat-qf{display:flex;gap:6px;margin-bottom:12px;flex-wrap:wrap;align-items:center}
.mat-qf__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600;margin-right:4px}
.mat-chip{padding:5px 12px;font-size:10px;font-weight:600;border:1px solid #e0e5ed;cursor:pointer;background:#fff;color:#555;transition:all .15s;display:inline-flex;align-items:center;gap:4px;font-family:inherit}
.mat-chip:hover{border-color:#c5cae9;background:#f5f7fa;color:#1a237e}
.mat-chip--active{background:#1a237e;color:#fff;border-color:#1a237e}
.mat-chip--active:hover{background:#283593}
.mat-chip__cnt{background:rgba(255,255,255,.2);padding:1px 5px;font-size:9px;border-radius:8px}

/* ── Card System ── */
.mat-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:12px}
.mat-card__hdr{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.mat-card__title{font-size:12px;font-weight:700;color:#1a237e;display:flex;align-items:center;gap:6px}
.mat-card__title svg{width:14px;height:14px;fill:#1a237e;opacity:.7}
.mat-card__meta{font-size:10px;color:#1a237e;font-weight:600;background:rgba(26,35,126,.07);padding:2px 8px;border:1px solid rgba(26,35,126,.15)}

/* ── Filters (collapsible) ── */
.mat-filtbar{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px;display:none}
.mat-filtbar.show{display:block}
.mat-filtbar__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.mat-fg{display:flex;flex-direction:column;gap:3px}
.mat-fg__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.mat-fg select,.mat-fg input[type=text]{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;font-family:inherit;min-width:110px}
.mat-fg select:focus,.mat-fg input:focus{border-color:#1a237e;outline:none}

/* ── Buttons ── */
.mat-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.mat-btn--primary{background:#1a237e;color:#fff}.mat-btn--primary:hover{background:#283593}
.mat-btn--success{background:#16a34a;color:#fff}.mat-btn--success:hover{background:#15803d}
.mat-btn--ghost{background:transparent;color:#1a237e;border:1px solid #e0e5ed}.mat-btn--ghost:hover{background:#f5f7fa}
.mat-btn--sm{padding:4px 10px;font-size:10px}
.mat-btn--filter{padding:4px 10px;font-size:10px;background:#e8eaf6;border:1px solid #c5cae9;color:#1a237e;cursor:pointer}
.mat-btn--filter:hover{background:#c5cae9}
.mat-btn--filter.active{background:#1a237e;color:#fff;border-color:#1a237e}

/* ── Grid overrides ── */
.mat-grid .dxgvHeader td{background:#f5f7fa!important;font-size:10px!important;font-weight:600!important;text-transform:uppercase!important;letter-spacing:.3px;padding:9px 8px!important;color:#555!important;border-bottom:2px solid #1a237e!important;white-space:nowrap}
.mat-grid .dxgvDataRow td{font-size:11px!important;padding:7px 8px!important;border-bottom:1px solid #f0f2f5!important;vertical-align:middle!important;color:#1a1a2e}
.mat-grid .dxgvDataRow:hover td{background:#eef2fc!important}
.mat-grid .dxgvFocusedRow td{background:#c5cae9!important}
.mat-grid .dxgvDataRow:nth-child(even) td{background:#f9fafb!important}
.mat-grid .dxgvDataRow:nth-child(even):hover td{background:#eef2fc!important}

/* ── Badges — refined with icons ── */
.mat-badge{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px}
.mat-badge::before{content:'';width:6px;height:6px;border-radius:50%;flex-shrink:0}
.mat-badge--capture{background:#e3f2fd;color:#0d47a1;border:1px solid #90caf9}.mat-badge--capture::before{background:#1565c0}
.mat-badge--edit{background:#fff8e1;color:#e65100;border:1px solid #ffcc02}.mat-badge--edit::before{background:#e65100}
.mat-badge--cancel{background:#fef5f5;color:#991b1b;border:1px solid #f5c6cb}.mat-badge--cancel::before{background:#c62828}
.mat-badge--autopass{background:#e6f4ea;color:#155724;border:1px solid #c3e6cb}.mat-badge--autopass::before{background:#2e7d32}
.mat-badge--mgmt{background:#f3e5f5;color:#4a148c;border:1px solid #ce93d8}.mat-badge--mgmt::before{background:#6a1b9a}

/* ── Severity dots — refined ── */
.mat-sev{display:inline-flex;align-items:center;gap:4px;font-size:10px;font-weight:600}
.mat-sev__dot{width:7px;height:7px;border-radius:50%;animation:none}
.mat-sev--critical .mat-sev__dot{background:#d32f2f;box-shadow:0 0 0 2px rgba(211,47,47,.2)}.mat-sev--critical{color:#d32f2f}
.mat-sev--high .mat-sev__dot{background:#f57c00;box-shadow:0 0 0 2px rgba(245,124,0,.2)}.mat-sev--high{color:#f57c00}
.mat-sev--normal .mat-sev__dot{background:#388e3c;box-shadow:0 0 0 2px rgba(56,142,60,.2)}.mat-sev--normal{color:#388e3c}

/* ── User highlight ── */
.mat-user{font-weight:700;color:#1a237e}

/* ── Two Column Layout ── */
.mat-cols{display:grid;grid-template-columns:1fr 300px;gap:12px}

/* ── Sidebar panels — improved ── */
.mat-side{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:10px;transition:border-color .2s}
.mat-side:hover{border-color:#c5cae9}
.mat-side__hdr{padding:10px 14px;background:#f8f9fb;border-bottom:1px solid #e0e5ed;font-size:11px;font-weight:700;color:#1a237e;display:flex;align-items:center;gap:6px}
.mat-side__hdr svg{width:14px;height:14px;fill:#1a237e;opacity:.6}
.mat-side__body{padding:0}
.mat-side-tbl{width:100%;border-collapse:collapse}
.mat-side-tbl th{font-size:9px;text-transform:uppercase;color:#999;font-weight:600;padding:7px 10px;text-align:left;border-bottom:1px solid #e0e5ed;letter-spacing:.3px;background:#fafbfc}
.mat-side-tbl td{font-size:11px;padding:7px 10px;border-bottom:1px solid #f5f5f5}
.mat-side-tbl tr:hover td{background:#f5f7fa}
.mat-rank{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;font-size:9px;font-weight:800;color:#fff}
.mat-rank--1{background:linear-gradient(135deg,#f59e0b,#d97706)}.mat-rank--2{background:linear-gradient(135deg,#94a3b8,#64748b)}.mat-rank--3{background:linear-gradient(135deg,#d4a574,#a1887f)}.mat-rank--other{background:#e2e8f0;color:#546e7a}
.mat-bar{height:6px;border-radius:3px;background:#e3e8ef;overflow:hidden}
.mat-bar__fill{height:100%;border-radius:3px;background:linear-gradient(90deg,#1a237e,#3949ab);transition:width .6s ease}

/* ── Action Breakdown — improved with mini bar ── */
.mat-act-row{display:flex;justify-content:space-between;align-items:center;padding:8px 12px;border-bottom:1px solid #f5f5f5;font-size:11px;transition:background .15s}
.mat-act-row:last-child{border-bottom:none}
.mat-act-row:hover{background:#f8f9fb}
.mat-act-left{display:flex;align-items:center;gap:6px}
.mat-act-dot{width:8px;height:8px;display:inline-block;flex-shrink:0}
.mat-act-cnt{font-weight:700;color:#263238;font-variant-numeric:tabular-nums}

/* ── Recent Activity — timeline style ── */
.mat-recent{padding:8px 12px;border-bottom:1px solid #f0f0f0;position:relative;transition:background .15s}
.mat-recent:last-child{border-bottom:none}
.mat-recent:hover{background:#f8f9fb}
.mat-recent__top{display:flex;justify-content:space-between;align-items:center}
.mat-recent__time{color:#90a4ae;font-size:9px;font-weight:600;background:#f5f5f5;padding:1px 6px;letter-spacing:.2px}
.mat-recent__desc{color:#555;margin-top:3px;font-size:10px;line-height:1.4}
.mat-recent__badge{display:inline-block;font-size:8px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;padding:1px 5px;margin-top:3px}

/* ── Alert ── */
.mat-alert{padding:8px 14px;margin-bottom:10px;font-size:11px;border-left:3px solid;display:flex;align-items:center;gap:6px}
.mat-alert--error{border-color:#dc3545;background:#fef5f5;color:#991b1b}
.mat-alert--info{border-color:#174DA4;background:#e8f0fc;color:#0d47a1}

/* ── Page hero header ── */
.mat-hero{background:linear-gradient(135deg,#05275C 0%,#174DA4 100%);color:#fff;padding:16px 20px;margin-bottom:14px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;border-radius:2px}
.mat-hero__l{display:flex;align-items:center;gap:14px;min-width:0}
.mat-hero__ic{width:44px;height:44px;border-radius:10px;background:rgba(255,255,255,.15);display:flex;align-items:center;justify-content:center;flex-shrink:0}
.mat-hero__ic svg{width:24px;height:24px;fill:#fff}
.mat-hero__t{font-size:18px;font-weight:800;line-height:1.15;display:flex;align-items:center;gap:9px;flex-wrap:wrap;margin:0}
.mat-hero__tag{font-size:9px;font-weight:800;letter-spacing:.6px;text-transform:uppercase;background:#16a34a;color:#fff;padding:3px 9px;border-radius:10px}
.mat-hero__s{font-size:11.5px;opacity:.88;margin-top:4px;max-width:660px;line-height:1.5}
.mat-hero__r{display:flex;gap:20px;flex-wrap:wrap}
.mat-hero__kv .n{font-size:19px;font-weight:800;line-height:1;font-variant-numeric:tabular-nums}
.mat-hero__kv .l{font-size:9px;text-transform:uppercase;letter-spacing:.4px;opacity:.82;margin-top:3px}
/* grid horizontal-scroll wrapper — keeps the fixed DX table from clipping on small screens */
.mat-gridwrap{width:100%;overflow-x:auto;-webkit-overflow-scrolling:touch}
/* legend under the grid */
.mat-legend{display:flex;gap:16px;flex-wrap:wrap;align-items:center;padding:9px 14px;background:#f8f9fb;border-top:1px solid #eef2f7;font-size:10px;color:#64748b}
.mat-legend__grp{display:inline-flex;align-items:center;gap:8px;flex-wrap:wrap}
.mat-legend__grp>b{color:#334155;font-weight:700}
.mat-legend__i{display:inline-flex;align-items:center;gap:4px}
.mat-legend__dot{width:8px;height:8px;border-radius:50%;display:inline-block}

/* ── Responsive ── */
@media(max-width:1200px){.mat-cols{grid-template-columns:1fr}.mat-stats{grid-template-columns:repeat(2,1fr)}}
@media(max-width:900px){.mat-hero__r{width:100%;justify-content:flex-start;gap:26px}}
@media(max-width:768px){.mat-stats{grid-template-columns:1fr}.mat-hero{padding:14px}.mat-hero__t{font-size:16px}.mat-hero__ic{display:none}.mat-filtbar__row{gap:6px}.mat-fg select,.mat-fg input[type=text]{min-width:0;width:100%}.mat-fg{flex:1 1 130px}}
@media print{.em-hdr,.em-tabs,.mat-qf,.mat-hero__r,.mat-card__hdr .mat-btn,.mat-card__hdr .mat-btn--filter{display:none!important}.mat-hero{background:#05275C!important;-webkit-print-color-adjust:exact;print-color-adjust:exact}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Hero Header ── -->
<div class="mat-hero">
    <div class="mat-hero__l">
        <div class="mat-hero__ic"><svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/></svg></div>
        <div>
            <h1 class="mat-hero__t">Marks Audit Trail <span class="mat-hero__tag">Advanced</span></h1>
            <div class="mat-hero__s">Forensic record of every marks operation &mdash; captures, edits (old &rarr; new values), approvals &amp; cancellations, auto-pass and mark-request decisions &mdash; with the who, when, where (IP) and full detail. Read-only &amp; exportable.</div>
        </div>
    </div>
    <div class="mat-hero__r">
        <div class="mat-hero__kv"><div class="n"><asp:Literal ID="litHeroTotal" runat="server">0</asp:Literal></div><div class="l">Total events</div></div>
        <div class="mat-hero__kv"><div class="n"><asp:Literal ID="litHeroWindow" runat="server">30</asp:Literal></div><div class="l">Day window</div></div>
    </div>
</div>

<!-- ── Stats — 2x4 grid with icons, trends, sub-values ── -->
<div class="mat-stats">
    <!-- Total Actions -->
    <div class="mat-stat mat-stat--total">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg></div>
            <div class="mat-stat__label">Total Actions</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litTotal" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><span class="mat-sub">all time</span></div>
    </div>
    <!-- Today -->
    <div class="mat-stat mat-stat--today">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/></svg></div>
            <div class="mat-stat__label">Today</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litToday" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><asp:Literal ID="litTodayTrend" runat="server" /></div>
    </div>
    <!-- This Week -->
    <div class="mat-stat mat-stat--week">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/></svg></div>
            <div class="mat-stat__label">This Week</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litWeek" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><asp:Literal ID="litWeekTrend" runat="server" /></div>
    </div>
    <!-- This Month -->
    <div class="mat-stat mat-stat--month">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11zM9 10H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2z"/></svg></div>
            <div class="mat-stat__label">This Month</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litMonth" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><span class="mat-sub">since 1st</span></div>
    </div>
    <!-- Critical Actions -->
    <div class="mat-stat mat-stat--critical">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/></svg></div>
            <div class="mat-stat__label">Critical Actions</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litCritical" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><span class="mat-sub" style="color:#c62828"><asp:Literal ID="litCriticalToday" runat="server">0 today</asp:Literal></span></div>
    </div>
    <!-- Unique Users -->
    <div class="mat-stat mat-stat--users">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg></div>
            <div class="mat-stat__label">Unique Users</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litUniqueUsers" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><span class="mat-sub"><asp:Literal ID="litActiveToday" runat="server">0 active today</asp:Literal></span></div>
    </div>
    <!-- Most Active -->
    <div class="mat-stat mat-stat--top">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M5 16c0 3.87 3.13 7 7 7s7-3.13 7-7v-4H5v4zM16.12 4.37l2.1-2.1-.82-.83-2.3 2.31C14.16 3.28 13.12 3 12 3s-2.16.28-3.09.75L6.6 1.44l-.82.83 2.1 2.1C6.14 5.64 5 7.68 5 10v1h14v-1c0-2.32-1.14-4.36-2.88-5.63zM9 9c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm6 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/></svg></div>
            <div class="mat-stat__label">Most Active (30d)</div>
        </div>
        <div class="mat-stat__val" style="font-size:14px"><asp:Literal ID="litTopUser" runat="server">—</asp:Literal></div>
        <div class="mat-stat__foot"><span class="mat-sub"><asp:Literal ID="litTopUserCount" runat="server">no data</asp:Literal></span></div>
    </div>
    <!-- Avg / Day -->
    <div class="mat-stat mat-stat--avg">
        <div class="mat-stat__top">
            <div class="mat-stat__icon"><svg viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg></div>
            <div class="mat-stat__label">Avg / Day (30d)</div>
        </div>
        <div class="mat-stat__val"><asp:Literal ID="litAvgDay" runat="server">0</asp:Literal></div>
        <div class="mat-stat__foot"><span class="mat-sub">actions per day</span></div>
    </div>
</div>

<!-- ── Quick-Filter Chips ── -->
<div class="mat-qf">
    <span class="mat-qf__label">Quick View:</span>
    <button type="button" class="mat-chip mat-chip--active" id="qfAll" onclick="applyQuickFilter('all')">All Activity</button>
    <button type="button" class="mat-chip" id="qfCaptures" onclick="applyQuickFilter('captures')">Captures</button>
    <button type="button" class="mat-chip" id="qfEdits" onclick="applyQuickFilter('edits')">Mark Edits</button>
    <button type="button" class="mat-chip" id="qfCancels" onclick="applyQuickFilter('cancels')">Cancellations</button>
    <button type="button" class="mat-chip" id="qfAuto" onclick="applyQuickFilter('auto')">Auto Pass</button>
</div>

<!-- ── Alert ── -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="mat-alert mat-alert--info">
    <asp:Literal ID="litMsg" runat="server" />
</asp:Panel>

<!-- ── Main Content: Two-Column ── -->
<div class="mat-cols">
    <!-- LEFT: Grid Card -->
    <div class="mat-card">
        <div class="mat-card__hdr">
            <span class="mat-card__title"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13zM6 20V4h5v7h7v9H6z"/></svg> Activity Log</span>
            <div style="display:flex;gap:6px;align-items:center">
                <span class="mat-card__meta"><asp:Literal ID="litRowCount" runat="server">0</asp:Literal> entries</span>
                <button type="button" class="mat-btn--filter active" id="btnToggleFilter" onclick="toggleFilters()">&#9776; Filters</button>
                <asp:Button ID="btnExportCsv" runat="server" Text="&#8681; Export" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnExportCsv_Click" />
            </div>
        </div>
        <div class="mat-filtbar show" id="matFilterBar">
            <div class="mat-filtbar__row">
                <div class="mat-fg">
                    <span class="mat-fg__label">From</span>
                    <dx:ASPxDateEdit ID="dtFrom" runat="server" Width="120px" DisplayFormatString="dd-MMM-yyyy" />
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">To</span>
                    <dx:ASPxDateEdit ID="dtTo" runat="server" Width="120px" DisplayFormatString="dd-MMM-yyyy" />
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">Action Type</span>
                    <asp:DropDownList ID="ddlAction" runat="server">
                        <asp:ListItem Value="" Text="All Actions" />
                        <asp:ListItem Value="Capture Results" Text="Old System Capture" />
                        <asp:ListItem Value="Results Capture" Text="Faculty Capture" />
                        <asp:ListItem Value="Faculty Exam Results Editor" Text="Marks Edit" />
                        <asp:ListItem Value="Results Approval Cancel" Text="Approval Cancel" />
                        <asp:ListItem Value="Results Management" Text="Results Management" />
                        <asp:ListItem Value="Results Auto Pass" Text="Auto Pass" />
                    </asp:DropDownList>
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">User</span>
                    <asp:DropDownList ID="ddlUser" runat="server" />
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">Student / Teacher / Course</span>
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="e.g. MRU2024, staff name, EMP001..." />
                </div>
                <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="mat-btn mat-btn--primary mat-btn--sm" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="mat-btn mat-btn--ghost mat-btn--sm" OnClick="btnClear_Click" />
            </div>
        </div>
        <div class="mat-gridwrap">
        <dx:ASPxGridView ID="gvLog" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="logid" CssClass="mat-grid" ClientInstanceName="gvLog">
            <SettingsPager PageSize="100" AlwaysShowPager="true">
                <Summary Visible="true" Text="Page {0} of {1} ({2} items)" />
                <PageSizeItemSettings Visible="true" Items="50, 100, 200, 500" />
            </SettingsPager>
            <SettingsBehavior AllowFocusedRow="true" />
            <Settings ShowFilterRow="true" />
            <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
            <Columns>
                <dx:GridViewDataDateColumn FieldName="access_date" Caption="Date / Time" VisibleIndex="0" Width="130px">
                    <PropertiesDateEdit DisplayFormatString="dd-MMM-yy HH:mm" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="teacher_name" Caption="Teacher" VisibleIndex="1" Width="180px">
                    <DataItemTemplate><%# FormatTeacher(Eval("user_id"), Eval("teacher_code"), Eval("teacher_name"), Eval("teacher_dept"), Eval("teacher_type"), Eval("teacher_email")) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="user_id" Caption="Username" VisibleIndex="2" Width="100px">
                    <DataItemTemplate><span class="mat-user"><%# Eval("user_id") %></span></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="page_function" Caption="Action" VisibleIndex="3" Width="115px">
                    <DataItemTemplate><%# GetActionBadge(Eval("page_function")) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="page_function" Caption="" VisibleIndex="4" Width="65px">
                    <DataItemTemplate><%# GetSeverityDot(Eval("page_function")) %></DataItemTemplate>
                    <CellStyle HorizontalAlign="Center" />
                    <Settings AllowAutoFilter="False" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="student_regno" Caption="Student" VisibleIndex="5" Width="140px">
                    <DataItemTemplate><%# FormatStudent(Eval("student_regno"), Eval("student_name")) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="par" Caption="Details" VisibleIndex="6">
                    <DataItemTemplate><%# ShortenDetails(Eval("par"), Eval("page_function")) %></DataItemTemplate>
                    <CellStyle Wrap="True" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="ip_address" Caption="IP Address" VisibleIndex="7" Width="110px">
                    <DataItemTemplate><%# FormatIP(Eval("ip_address")) %></DataItemTemplate>
                    <Settings AllowAutoFilter="True" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="teacher_dept" Caption="Department" VisibleIndex="8" Width="120px" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="teacher_code" Caption="Staff Code" VisibleIndex="9" Width="90px" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="teacher_email" Caption="Email" VisibleIndex="10" Width="140px" Visible="false" />
            </Columns>
        </dx:ASPxGridView>
        </div>
        <div class="mat-legend">
            <span class="mat-legend__grp"><b>Severity:</b>
                <span class="mat-legend__i"><span class="mat-legend__dot" style="background:#d32f2f"></span>Critical</span>
                <span class="mat-legend__i"><span class="mat-legend__dot" style="background:#f57c00"></span>High</span>
                <span class="mat-legend__i"><span class="mat-legend__dot" style="background:#388e3c"></span>Normal</span>
            </span>
            <span class="mat-legend__grp"><b>Tip:</b> click a column header to sort, use the header filter row to narrow, or the Filters bar for date / user / search. Rows scroll horizontally on small screens.</span>
        </div>
        <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvLog" />
    </div>

    <!-- RIGHT: Sidebar -->
    <div>
        <div class="mat-side">
            <div class="mat-side__hdr"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg> Top Users (30 Days)</div>
            <div class="mat-side__body">
                <table class="mat-side-tbl">
                    <thead><tr><th>#</th><th>User</th><th>Actions</th><th style="width:60px">Volume</th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptTopUsers" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class='<%# GetRankClass(Container.ItemIndex) %>'><%# Container.ItemIndex + 1 %></span></td>
                                    <td style="font-weight:600;color:#333"><%# Eval("user_id") %></td>
                                    <td style="font-weight:700;font-variant-numeric:tabular-nums"><%# Eval("cnt") %></td>
                                    <td><div class="mat-bar"><div class="mat-bar__fill" style='width:<%# Eval("pct") %>%'></div></div></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mat-side">
            <div class="mat-side__hdr"><svg viewBox="0 0 24 24"><path d="M5 9.2h3V19H5zM10.6 5h2.8v14h-2.8zm5.6 8H19v6h-2.8z"/></svg> Action Breakdown</div>
            <div class="mat-side__body">
                <asp:Repeater ID="rptBreakdown" runat="server">
                    <ItemTemplate>
                        <div class="mat-act-row">
                            <span class="mat-act-left"><span class="mat-act-dot" style='background:<%# Eval("color") %>'></span><%# Eval("label") %></span>
                            <span class="mat-act-cnt"><%# Eval("cnt") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="mat-side">
            <div class="mat-side__hdr"><svg viewBox="0 0 24 24"><path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg> Latest Activity</div>
            <div class="mat-side__body">
                <asp:Repeater ID="rptRecent" runat="server">
                    <ItemTemplate>
                        <div class="mat-recent">
                            <div class="mat-recent__top">
                                <span class="mat-user" style="font-size:11px"><%# Eval("user_id") %></span>
                                <span class="mat-recent__time"><%# Eval("time_ago") %></span>
                            </div>
                            <div class="mat-recent__desc"><%# Eval("summary") %></div>
                            <span class="mat-recent__badge" style='background:<%# Eval("badge_bg") %>;color:<%# Eval("badge_fg") %>'><%# Eval("badge_text") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
function toggleFilters(){var b=document.getElementById('matFilterBar'),t=document.getElementById('btnToggleFilter');if(b.classList.contains('show')){b.classList.remove('show');t.classList.remove('active');}else{b.classList.add('show');t.classList.add('active');}}

/* Quick-filter chips: apply column filter on the DevExpress grid */
function applyQuickFilter(mode){
    var chips=document.querySelectorAll('.mat-chip');
    for(var i=0;i<chips.length;i++) chips[i].className='mat-chip';
    var btn=document.getElementById('qf'+mode.charAt(0).toUpperCase()+mode.slice(1));
    if(!btn){btn=document.getElementById('qfAll');}
    btn.className='mat-chip mat-chip--active';

    /* Use DevExpress client API to set filter on page_function column (index 2) */
    if(typeof gvLog==='undefined') return;
    try{
        if(mode==='all'){
            gvLog.AutoFilterByColumn(2,'');
        }else if(mode==='captures'){
            gvLog.AutoFilterByColumn(2,'Capture');
        }else if(mode==='edits'){
            gvLog.AutoFilterByColumn(2,'Editor');
        }else if(mode==='cancels'){
            gvLog.AutoFilterByColumn(2,'Cancel');
        }else if(mode==='auto'){
            gvLog.AutoFilterByColumn(2,'Auto Pass');
        }
    }catch(ex){}
}
</script>

</asp:Content>
