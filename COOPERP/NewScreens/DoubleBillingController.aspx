<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DoubleBillingController.aspx.cs"
    Inherits="COOPERP_NewScreens_DoubleBillingController"
    MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    Title="Double Billing Controller - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== DOUBLE BILLING CONTROLLER (prefix: dbc-) ======================== */

/* Stats Row */
.dbc-stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 14px; }
.dbc-stat { background: #fff; border: 1px solid #e0e5ed; padding: 11px 13px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.dbc-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--sc, #ccc); }
.dbc-stat__icon { width: 30px; height: 30px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.dbc-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.dbc-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.dbc-stat--students { --sc: #174DA4; } .dbc-stat--students .dbc-stat__icon { background: #e8f0fc; } .dbc-stat--students .dbc-stat__val { color: #174DA4; }
.dbc-stat--affected { --sc: #c62828; } .dbc-stat--affected .dbc-stat__icon { background: #fde8e8; } .dbc-stat--affected .dbc-stat__val { color: #c62828; }
.dbc-stat--dups     { --sc: #e65100; } .dbc-stat--dups .dbc-stat__icon     { background: #fff8e1; } .dbc-stat--dups .dbc-stat__val     { color: #e65100; }
.dbc-stat--amount   { --sc: #2e7d32; } .dbc-stat--amount .dbc-stat__icon   { background: #e6f4ea; } .dbc-stat--amount .dbc-stat__val   { color: #2e7d32; }
.dbc-stat--index    { --sc: #00897b; } .dbc-stat--index .dbc-stat__icon    { background: #e0f2f1; } .dbc-stat--index .dbc-stat__val    { color: #00897b; }

/* Page Header */
.dbc-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; flex-wrap: wrap; gap: 8px; }
.dbc-header__left { display: flex; align-items: center; gap: 10px; }
.dbc-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.dbc-header__icon svg { color: #fff; }
.dbc-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.dbc-header__sub { font-size: 10px; color: #888; margin-top: 1px; }
.dbc-header__actions { display: flex; gap: 6px; flex-wrap: wrap; }

/* Card */
.dbc-card { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 14px; }
.dbc-card__head { padding: 9px 13px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.dbc-card__title { font-size: 11px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Toolbar / inputs */
.dbc-input { height: 30px; padding: 0 9px; border: 1px solid #cdd3de; font-size: 11px; background: #fff; color: #333; }
.dbc-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.1); }
.dbc-select { height: 30px; padding: 0 7px; border: 1px solid #cdd3de; font-size: 11px; background: #fff; color: #444; }

/* Buttons */
.dbc-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; line-height: 1.2; }
.dbc-btn--primary { background: #05275C; color: #fff; } .dbc-btn--primary:hover { background: #174DA4; }
.dbc-btn--danger  { background: #c62828; color: #fff; } .dbc-btn--danger:hover  { background: #d32f2f; }
.dbc-btn--success { background: #2e7d32; color: #fff; } .dbc-btn--success:hover { background: #388e3c; }
.dbc-btn--ghost   { background: #fff; border: 1px solid #cdd3de; color: #555; } .dbc-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.dbc-btn:disabled { opacity: .45; cursor: not-allowed; }

/* Progress */
.dbc-progress-wrap { padding: 10px 13px; border-bottom: 1px solid #f0f2f5; display: none; }
.dbc-progress-wrap.active { display: block; }
.dbc-progress-bar { width: 100%; height: 5px; background: #e8ecf2; overflow: hidden; }
.dbc-progress-fill { height: 100%; background: #174DA4; width: 0; transition: width .25s ease; }
.dbc-progress-row { display: flex; align-items: center; justify-content: space-between; margin-top: 5px; }
.dbc-progress-label { font-size: 10px; color: #555; }
.dbc-progress-pct   { font-size: 10px; font-weight: 700; color: #174DA4; }

/* Notice */
.dbc-notice { padding: 8px 13px; font-size: 11px; font-weight: 600; border: 1px solid transparent; display: none; }
.dbc-notice.visible { display: flex; align-items: flex-start; gap: 7px; }
.dbc-notice--info    { background: #e8f0fc; color: #174DA4; border-color: #bbdefb; }
.dbc-notice--warn    { background: #fff8e1; color: #e65100; border-color: #ffecb3; }
.dbc-notice--success { background: #e6f4ea; color: #155724; border-color: #c3e6cb; }
.dbc-notice--err     { background: #fde8e8; color: #c62828; border-color: #f5c6cb; }

/* Log console */
.dbc-log { max-height: 160px; overflow-y: auto; background: #0f172a; border-top: 1px solid #e0e5ed; padding: 8px 12px; font-family: 'Consolas','Courier New',monospace; font-size: 11px; color: #94a3b8; display: none; }
.dbc-log.active { display: block; }
.dbc-log-line { padding: 2px 0; border-bottom: 1px solid #1e293b; }
.dbc-log-line:last-child { border-bottom: none; }
.log-ok { color: #4ade80; } .log-err { color: #f87171; } .log-info { color: #60a5fa; }

/* Table */
.dbc-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.dbc-table th { background: #f5f7fa; padding: 8px 11px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.dbc-table td { padding: 7px 11px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; vertical-align: middle; }
.dbc-table td.r { text-align: right; } .dbc-table td.c { text-align: center; }
.dbc-table tbody tr:hover td { background: #f0f4ff; }
.dbc-table tr:last-child td { border-bottom: none; }

/* Badges */
.badge { display: inline-block; padding: 2px 7px; font-size: 10px; font-weight: 600; }
.badge--detected { background: #fff8e1; color: #e65100; border: 1px solid #ffecb3; }
.badge--fixed    { background: #e6f4ea; color: #155724; border: 1px solid #c3e6cb; }
.badge--clean    { background: #e8f0fc; color: #174DA4; border: 1px solid #bbdefb; }
.badge--error    { background: #fde8e8; color: #c62828; border: 1px solid #f5c6cb; }

/* Method pills */
.meth-pills { display: flex; gap: 3px; flex-wrap: wrap; }
.meth { display: inline-block; padding: 1px 5px; font-size: 10px; font-weight: 700; background: #ede9fe; color: #5b21b6; border: 1px solid #ddd6fe; }

/* Row buttons */
.row-btn { padding: 3px 9px; font-size: 10px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 3px; transition: background .15s; }
.row-btn--details { background: #e8f0fc; color: #174DA4; border: 1px solid #bbdefb; }
.row-btn--details:hover { background: #d0e4fb; }
.row-btn--fix { background: #e6f4ea; color: #2e7d32; border: 1px solid #c3e6cb; }
.row-btn--fix:hover { background: #c8e6c9; }
.row-btn:disabled { opacity: .4; cursor: not-allowed; }
.fs-code { font-family: 'Consolas','Courier New',monospace; font-size: 10px; background: #f5f7fa; padding: 1px 4px; border: 1px solid #e0e5ed; color: #05275C; }

/* Empty state */
.dbc-empty { text-align: center; padding: 30px 16px; color: #aaa; }
.dbc-empty__icon { font-size: 2rem; margin-bottom: 8px; }
.dbc-empty__text { font-size: 11px; }

/* Pagination */
.dbc-pager { display: flex; align-items: center; gap: 5px; padding: 8px 13px; border-top: 1px solid #f0f2f5; flex-wrap: wrap; }
.dbc-pager__info { font-size: 10px; color: #888; margin-right: auto; }
.pager-btn { width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center; border: 1px solid #e0e5ed; background: #fff; cursor: pointer; font-size: 11px; color: #555; }
.pager-btn:hover { background: #f0f4ff; }
.pager-btn.active { background: #05275C; color: #fff; border-color: #05275C; }
.pager-btn:disabled { opacity: .4; cursor: not-allowed; }

/* Modal */
.dbc-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9998; display: none; align-items: center; justify-content: center; padding: 16px; }
.dbc-overlay.open { display: flex; }
.dbc-modal { background: #fff; max-width: 920px; width: 100%; max-height: 90vh; display: flex; flex-direction: column; box-shadow: 0 12px 40px rgba(0,0,0,.2); }
.dbc-modal__head { background: #05275C; padding: 11px 16px; display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.dbc-modal__head h3 { margin: 0; font-size: 13px; font-weight: 700; color: #fff; }
.dbc-modal__close { background: rgba(255,255,255,.15); border: none; cursor: pointer; color: #fff; width: 24px; height: 24px; font-size: 15px; line-height: 1; display: flex; align-items: center; justify-content: center; }
.dbc-modal__close:hover { background: rgba(255,255,255,.3); }
.dbc-modal__body { flex: 1; overflow-y: auto; padding: 14px; }
.dbc-modal__foot { display: flex; justify-content: flex-end; gap: 7px; padding: 10px 14px; border-top: 1px solid #e0e5ed; background: #f8f9fb; flex-shrink: 0; }
.dbc-modal-stats { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 12px; }
.dbc-modal-stat { background: #f5f7fa; border: 1px solid #e0e5ed; padding: 8px 12px; min-width: 120px; }
.dbc-modal-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .4px; color: #888; }
.dbc-modal-stat__val { font-size: 14px; font-weight: 700; color: #05275C; margin-top: 2px; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="dbc-header">
    <div class="dbc-header__left">
        <div class="dbc-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
        </div>
        <div>
            <div class="dbc-header__title">Double Billing Controller</div>
            <div class="dbc-header__sub">Detect and remove duplicate fee entries from student ledgers</div>
        </div>
    </div>
    <div class="dbc-header__actions">
        <button class="dbc-btn dbc-btn--ghost" onclick="refreshSummary()" id="btnRefresh">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline>
                <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
            </svg>
            Refresh Stats
        </button>
        <button class="dbc-btn dbc-btn--primary" onclick="runFullScan()" id="btnScan">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            Scan Active Students
        </button>
        <button class="dbc-btn dbc-btn--danger" onclick="fixAllAffected()" id="btnFixAll" style="display:none">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
            Fix All Affected
        </button>
    </div>
</div>

<!-- Stats Cards -->
<div class="dbc-stats">
    <div class="dbc-stat dbc-stat--students">
        <div class="dbc-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
        </div>
        <div><div class="dbc-stat__val" id="statStudents">--</div><div class="dbc-stat__label">Student Accts</div></div>
    </div>
    <div class="dbc-stat dbc-stat--affected">
        <div class="dbc-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#c62828" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                <line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line>
            </svg>
        </div>
        <div><div class="dbc-stat__val" id="statAffected">--</div><div class="dbc-stat__label">Affected Accts</div></div>
    </div>
    <div class="dbc-stat dbc-stat--dups">
        <div class="dbc-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
            </svg>
        </div>
        <div><div class="dbc-stat__val" id="statDups">--</div><div class="dbc-stat__label">Duplicate Entries</div></div>
    </div>
    <div class="dbc-stat dbc-stat--amount">
        <div class="dbc-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="12" y1="1" x2="12" y2="23"></line>
                <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
            </svg>
        </div>
        <div><div class="dbc-stat__val" id="statAmt">--</div><div class="dbc-stat__label">Overbilled Amt</div></div>
    </div>
    <div class="dbc-stat dbc-stat--index">
        <div class="dbc-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00897b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
            </svg>
        </div>
        <div><div class="dbc-stat__val" id="statIndex" style="font-size:12px">Checking...</div><div class="dbc-stat__label">UNIQUE Index</div></div>
    </div>
</div>

<!-- Main Card -->
<div class="dbc-card">
    <div class="dbc-card__head">
        <div class="dbc-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line>
                <line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line>
            </svg>
            Detected Cases
        </div>
        <div style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
            <input type="text" class="dbc-input" id="txtSearch" placeholder="Filter reg no / name..." oninput="applyFilter()" style="width:170px" />
            <select class="dbc-select" id="ddlStatus" onchange="applyFilter()">
                <option value="">All Statuses</option>
                <option value="Detected">Detected</option>
                <option value="Fixed">Fixed</option>
                <option value="Clean">Clean</option>
            </select>
            <button class="dbc-btn dbc-btn--ghost" onclick="loadCasesFromDb()">Load Saved</button>
        </div>
    </div>

    <!-- Progress -->
    <div class="dbc-progress-wrap" id="progressWrap">
        <div class="dbc-progress-bar"><div class="dbc-progress-fill" id="progressFill"></div></div>
        <div class="dbc-progress-row">
            <span class="dbc-progress-label" id="progressLabel">Processing...</span>
            <span class="dbc-progress-pct" id="progressPct">0%</span>
        </div>
    </div>

    <!-- Notice -->
    <div class="dbc-notice" id="noticeBar"></div>

    <!-- Table -->
    <div style="overflow-x:auto">
        <table class="dbc-table" id="casesTable">
            <thead>
                <tr>
                    <th>Reg No</th><th>Student Name</th>
                    <th class="r">Dups</th><th class="r">DR Overbilled</th>
                    <th>Methods</th><th class="c">Status</th>
                    <th>Last Scanned</th><th class="c">Actions</th>
                </tr>
            </thead>
            <tbody id="casesBody">
                <tr><td colspan="8">
                    <div class="dbc-empty">
                        <div class="dbc-empty__icon">&#128269;</div>
                        <div class="dbc-empty__text">Click <strong>Scan Active Students</strong> to detect duplicate billing entries.</div>
                    </div>
                </td></tr>
            </tbody>
        </table>
    </div>
    <div class="dbc-pager" id="pagerBar" style="display:none">
        <span class="dbc-pager__info" id="pagerInfo"></span>
        <button class="pager-btn" id="btnPrev" onclick="changePage(-1)">&#8592;</button>
        <span id="pagerPages" style="font-size:10px;color:#555"></span>
        <button class="pager-btn" id="btnNext" onclick="changePage(1)">&#8594;</button>
    </div>
    <div class="dbc-log" id="logConsole"></div>
</div>

<!-- Details Modal -->
<div class="dbc-overlay" id="detailsOverlay" onclick="if(event.target===this)closeDetails()">
    <div class="dbc-modal">
        <div class="dbc-modal__head">
            <h3 id="detailsTitle">Duplicate Transactions</h3>
            <button class="dbc-modal__close" onclick="closeDetails()">&#x2715;</button>
        </div>
        <div class="dbc-modal__body">
            <div class="dbc-modal-stats" id="detailsStats"></div>
            <div id="detailsNotice"></div>
            <div style="overflow-x:auto" id="detailsTableWrap">
                <table class="dbc-table">
                    <thead>
                        <tr>
                            <th>TID</th><th>Type</th><th class="r">Amount</th><th>Particulars</th>
                            <th>Folio</th><th>Tracking Ref</th><th>Teller</th><th>Date</th>
                        </tr>
                    </thead>
                    <tbody id="detailsBody"></tbody>
                </table>
            </div>
        </div>
        <div class="dbc-modal__foot">
            <button class="dbc-btn dbc-btn--ghost" onclick="closeDetails()">Close</button>
            <button class="dbc-btn dbc-btn--danger" id="btnModalFix" onclick="fixFromModal()" style="display:none">Fix This Account</button>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    var _allRows    = [];
    var _filtered   = [];
    var _pageIndex  = 0;
    var _pageSize   = 50;
    var _busy       = false;
    var _modalRegno = null;

    // Batched scan state
    var BATCH_SIZE  = 50;
    var _scanTotal  = 0;
    var _scanOffset = 0;
    var _scanFound  = 0;

    // Fix-all state
    var _fixQueue = [];
    var _fixIndex = 0;
    var _fixTotal = 0;

    var BASE = window.location.pathname;

    function xhr(url, cb) {
        var req = new XMLHttpRequest();
        req.open('GET', url, true);
        req.timeout = 90000;
        req.onload  = function () {
            try { cb(null, JSON.parse(req.responseText)); }
            catch (e) { cb('Parse error: ' + req.responseText.substring(0, 200)); }
        };
        req.onerror   = function () { cb('Network error'); };
        req.ontimeout = function () { cb('Request timed out'); };
        req.send();
    }

    function fmt(n) { return n == null ? '0' : Number(n).toLocaleString('en-UG'); }

    function esc(s) {
        return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
                              .replace(/"/g,'&quot;').replace(/'/g,'&#039;');
    }

    function notice(html, type, persist) {
        var el = document.getElementById('noticeBar');
        el.className = 'dbc-notice visible dbc-notice--' + (type || 'info');
        el.innerHTML = html;
        if (!persist) setTimeout(function () { el.className = 'dbc-notice'; }, 8000);
    }

    function clearNotice() { document.getElementById('noticeBar').className = 'dbc-notice'; }

    function log(msg, cls) {
        var el = document.getElementById('logConsole');
        el.classList.add('active');
        var ts = new Date().toLocaleTimeString();
        el.innerHTML += '<div class="dbc-log-line ' + (cls || '') + '">[' + ts + '] ' + msg + '</div>';
        el.scrollTop = el.scrollHeight;
    }

    function setProgress(pct, label) {
        var wrap = document.getElementById('progressWrap');
        if (pct < 0) { wrap.classList.remove('active'); return; }
        wrap.classList.add('active');
        document.getElementById('progressFill').style.width = Math.min(100, pct) + '%';
        document.getElementById('progressLabel').textContent = label || '';
        document.getElementById('progressPct').textContent = Math.round(Math.min(100, pct)) + '%';
    }

    function setBusy(busy) {
        _busy = busy;
        document.getElementById('btnScan').disabled    = busy;
        document.getElementById('btnRefresh').disabled = busy;
        var fb = document.getElementById('btnFixAll');
        if (fb) fb.disabled = busy;
    }

    // Summary Stats
    function refreshSummary() {
        xhr(BASE + '?ajax=summary', function (err, d) {
            if (err || !d || !d.ok) return;
            document.getElementById('statStudents').textContent = fmt(d.totalStudents);
            document.getElementById('statAffected').textContent = fmt(d.affectedCount) + (d.fixedCount > 0 ? ' (' + d.fixedCount + ' fixed)' : '');
            document.getElementById('statDups').textContent = fmt(d.grandTotalDups);
            document.getElementById('statAmt').textContent  = 'UGX ' + fmt(d.grandTotalAmount);
            var idxEl = document.getElementById('statIndex');
            idxEl.textContent = d.uniqueIndexActive ? '\u2714 Active' : '\u2718 Missing!';
            idxEl.style.color = d.uniqueIndexActive ? '#00897b' : '#c62828';
        });
    }

    // =========================================================
    // BATCHED FULL SCAN
    // =========================================================
    function runFullScan() {
        if (_busy) return;
        clearNotice();
        document.getElementById('logConsole').innerHTML = '';
        document.getElementById('logConsole').classList.remove('active');
        document.getElementById('btnFixAll').style.display = 'none';
        setBusy(true);
        setProgress(1, 'Initialising scan...');
        log('Querying active student list...', 'log-info');

        xhr(BASE + '?ajax=scan_init', function (err, d) {
            if (err || !d || !d.ok) {
                setProgress(-1); setBusy(false);
                notice('Scan failed: ' + (err || (d && d.error) || 'Unknown'), 'err', true);
                log('Init failed: ' + (err || (d && d.error)), 'log-err');
                return;
            }
            _scanTotal = d.total; _scanOffset = 0; _scanFound = 0; _allRows = [];
            if (_scanTotal === 0) {
                setProgress(-1); setBusy(false);
                notice('No student accounts found.', 'warn', true); return;
            }
            log('Found ' + fmt(_scanTotal) + ' student accounts. Scanning in batches of ' + BATCH_SIZE + '...', 'log-info');
            setProgress(1, 'Starting scan — 0 / ' + fmt(_scanTotal) + ' scanned');
            setTimeout(scanNextBatch, 10);
        });
    }

    function scanNextBatch() {
        if (_scanOffset >= _scanTotal) { onScanComplete(); return; }
        var url = BASE + '?ajax=scan_batch&offset=' + _scanOffset + '&size=' + BATCH_SIZE + '&_t=' + Date.now();
        xhr(url, function (err, d) {
            if (err || !d || !d.ok) {
                log('Batch error at offset ' + _scanOffset + ': ' + (err || (d && d.error)), 'log-err');
                _scanOffset += BATCH_SIZE;
            } else {
                var affected = d.affected || [];
                for (var i = 0; i < affected.length; i++) {
                    var a = affected[i];
                    _allRows.push({ regno: a.regno, name: a.name,
                        dupCount: a.dupCount, dupAmount: a.dupAmount,
                        m1: a.m1, m2: a.m2, m3: a.m3, m4: a.m4,
                        status: 'Detected', lastScanned: new Date().toLocaleString() });
                    _scanFound++;
                }
                _scanOffset += d.scanned;
                if (affected.length > 0) {
                    log('[' + fmt(_scanOffset) + '/' + fmt(_scanTotal) + '] Batch found ' + affected.length + ' affected (total: ' + _scanFound + ')', 'log-ok');
                    applyFilter();
                    document.getElementById('btnFixAll').style.display = '';
                }
            }
            var pct = Math.min(98, Math.round((_scanOffset / _scanTotal) * 100));
            setProgress(pct, fmt(_scanOffset) + ' / ' + fmt(_scanTotal) + ' scanned \u2014 ' + _scanFound + ' affected');
            if (_scanOffset >= _scanTotal || (d && d.done)) { onScanComplete(); }
            else { setTimeout(scanNextBatch, 0); }
        });
    }

    function onScanComplete() {
        setProgress(100, 'Scan complete \u2014 ' + _scanFound + ' affected account(s).');
        setBusy(false);
        setTimeout(function () { setProgress(-1); }, 4000);
        if (_scanFound > 0) {
            notice('<strong>' + fmt(_scanFound) + '</strong> account(s) have duplicate billing. Use <em>Fix All Affected</em> or fix individually.', 'warn', true);
            document.getElementById('btnFixAll').style.display = '';
        } else {
            notice('\u2714 Scan complete \u2014 no duplicate billing across ' + fmt(_scanTotal) + ' student accounts.', 'success', true);
            document.getElementById('btnFixAll').style.display = 'none';
        }
        log('Scan finished. ' + fmt(_scanTotal) + ' checked, ' + _scanFound + ' affected.', 'log-ok');
        refreshSummary(); applyFilter();
    }

    // Load saved cases from DB
    function loadCasesFromDb() {
        clearNotice();
        log('Loading persisted case log...', 'log-info');
        xhr(BASE + '?ajax=load_cases&_t=' + Date.now(), function (err, d) {
            if (err || !d || !d.ok) {
                notice('Could not load cases: ' + (err || (d && d.error)), 'err', true); return;
            }
            _allRows = (d.cases || []).map(function (c) {
                return { regno: c.regno, name: c.name,
                         dupCount: c.dupCount, dupAmount: c.dupAmount,
                         m1: c.m1, m2: c.m2, m3: c.m3, m4: c.m4,
                         status: c.status, lastScanned: c.lastScanned };
            });
            applyFilter(); refreshSummary();
            log('Loaded ' + _allRows.length + ' case(s) from database.', 'log-ok');
            if (_allRows.some(function (r) { return r.status === 'Detected'; }))
                document.getElementById('btnFixAll').style.display = '';
        });
    }

    // Table rendering
    function applyFilter() {
        var q = (document.getElementById('txtSearch').value || '').toLowerCase();
        var st = document.getElementById('ddlStatus').value;
        _filtered = _allRows.filter(function (r) {
            return (!q || r.regno.toLowerCase().indexOf(q) >= 0 || (r.name||'').toLowerCase().indexOf(q) >= 0)
                && (!st || r.status === st);
        });
        _pageIndex = 0; renderPage();
    }

    function renderPage() {
        var body = document.getElementById('casesBody');
        var pager = document.getElementById('pagerBar');
        if (_filtered.length === 0) {
            body.innerHTML = '<tr><td colspan="8"><div class="dbc-empty"><div class="dbc-empty__icon">&#x2705;</div><div class="dbc-empty__text">No cases match the current filter.</div></div></td></tr>';
            pager.style.display = 'none'; return;
        }
        var tp = Math.ceil(_filtered.length / _pageSize);
        if (_pageIndex >= tp) _pageIndex = tp - 1;
        var s = _pageIndex * _pageSize;
        var pg = _filtered.slice(s, s + _pageSize);
        var html = '';
        for (var i = 0; i < pg.length; i++) {
            var r = pg[i]; var idx = s + i;
            var mp = [];
            if (r.m1 > 0) mp.push('<span class="meth">M1&times;' + r.m1 + '</span>');
            if (r.m2 > 0) mp.push('<span class="meth">M2&times;' + r.m2 + '</span>');
            if (r.m3 > 0) mp.push('<span class="meth">M3&times;' + r.m3 + '</span>');
            if (r.m4 > 0) mp.push('<span class="meth">M4&times;' + r.m4 + '</span>');
            var bc = r.status === 'Fixed' ? 'fixed' : r.status === 'Clean' ? 'clean' : r.status === 'Error' ? 'error' : 'detected';
            var fb = r.status !== 'Fixed'
                ? '<button class="row-btn row-btn--fix" onclick="fixOne(\'' + esc(r.regno) + '\',' + idx + ')">Fix</button>'
                : '<span style="font-size:10px;color:#2e7d32;font-weight:600">&#x2714; Fixed</span>';
            html += '<tr id="row-' + idx + '"><td><span class="fs-code">' + esc(r.regno) + '</span></td>' +
                '<td>' + esc(r.name||'') + '</td>' +
                '<td class="r"><strong>' + fmt(r.dupCount) + '</strong></td>' +
                '<td class="r" style="color:#c62828;font-weight:600">UGX ' + fmt(r.dupAmount) + '</td>' +
                '<td><div class="meth-pills">' + (mp.join('') || '<span style="color:#aaa;font-size:10px">--</span>') + '</div></td>' +
                '<td class="c"><span class="badge badge--' + bc + '">' + esc(r.status||'Detected') + '</span></td>' +
                '<td style="font-size:10px;color:#888">' + esc(r.lastScanned||'--') + '</td>' +
                '<td class="c" style="white-space:nowrap">' +
                '<button class="row-btn row-btn--details" onclick="showDetails(\'' + esc(r.regno) + '\',\'' + esc(r.name||'') + '\')">Details</button> ' +
                fb + '</td></tr>';
        }
        body.innerHTML = html;
        pager.style.display = _filtered.length > _pageSize ? '' : 'none';
        document.getElementById('pagerInfo').textContent = 'Showing ' + (s+1) + '\u2013' + Math.min(s+_pageSize,_filtered.length) + ' of ' + _filtered.length;
        document.getElementById('pagerPages').textContent = (_pageIndex+1) + ' / ' + tp;
        document.getElementById('btnPrev').disabled = _pageIndex === 0;
        document.getElementById('btnNext').disabled = _pageIndex >= tp-1;
    }

    function changePage(d) { _pageIndex += d; renderPage(); window.scrollTo(0,0); }

    // Fix One
    function fixOne(regno, rowIndex) {
        if (!confirm('Fix duplicate billing for ' + regno + '?\n\nDuplicate entries will be deleted and archived to fin_deleted_ledger. This cannot be easily undone.')) return;
        var row = document.getElementById('row-' + rowIndex);
        if (row) { var c = row.querySelectorAll('td'); if (c[7]) c[7].innerHTML = '<span style="font-size:10px;color:#888">Fixing...</span>'; }
        log('Fixing ' + regno + '...', 'log-info');
        xhr(BASE + '?ajax=fix_one&regno=' + encodeURIComponent(regno) + '&_t=' + Date.now(), function (err, d) {
            if (err || !d || !d.ok) {
                log('Error fixing ' + regno + ': ' + (err || (d && d.error)), 'log-err');
                if (row) { var c2 = row.querySelectorAll('td'); if (c2[7]) c2[7].innerHTML = '<span style="font-size:10px;color:#c62828">Error</span>'; }
                return;
            }
            log('Fixed ' + regno + ' \u2014 deleted ' + d.deleted + ' entries. Balance: ' + d.balBefore + ' \u2192 ' + d.balAfter, 'log-ok');
            var r = null;
            for (var i=0; i<_allRows.length; i++) { if (_allRows[i].regno === regno) { r = _allRows[i]; break; } }
            if (r) { r.status = 'Fixed'; r.dupCount = 0; }
            renderPage(); refreshSummary();
        });
    }

    // Fix All
    function fixAllAffected() {
        var toFix = _allRows.filter(function (r) { return r.status !== 'Fixed'; });
        if (toFix.length === 0) { notice('All affected accounts are already fixed.', 'success'); return; }
        if (!confirm('Fix ALL ' + toFix.length + ' affected account(s)?\n\nAll duplicate entries will be deleted and archived.')) return;
        document.getElementById('btnFixAll').style.display = 'none';
        document.getElementById('logConsole').innerHTML = '';
        document.getElementById('logConsole').classList.add('active');
        _fixQueue = toFix.slice(); _fixIndex = 0; _fixTotal = _fixQueue.length;
        setBusy(true); setProgress(0, '0 / ' + _fixTotal + ' fixed');
        log('Batch fix started \u2014 ' + _fixTotal + ' account(s)...', 'log-info');
        fixNextInQueue();
    }

    function fixNextInQueue() {
        if (_fixIndex >= _fixQueue.length) {
            setProgress(100, 'All done!'); setBusy(false);
            setTimeout(function () { setProgress(-1); }, 4000);
            log('Batch fix complete. ' + _fixTotal + ' account(s) processed.', 'log-ok');
            notice('\u2714 Batch fix complete \u2014 ' + _fixTotal + ' account(s) processed.', 'success', true);
            refreshSummary(); renderPage(); return;
        }
        var r = _fixQueue[_fixIndex];
        setProgress(Math.round((_fixIndex/_fixTotal)*100), (_fixIndex+1)+'/'+_fixTotal+' \u2014 '+r.regno);
        log('['+(_fixIndex+1)+'/'+_fixTotal+'] Fixing '+r.regno+'...', 'log-info');
        xhr(BASE + '?ajax=fix_one&regno=' + encodeURIComponent(r.regno) + '&_t=' + Date.now(), function (err, d) {
            if (err || !d || !d.ok) { log('Error: '+r.regno+' \u2014 '+(err||(d&&d.error)), 'log-err'); }
            else { r.status = 'Fixed'; r.dupCount = 0; log('OK: '+r.regno+' deleted='+d.deleted+' bal '+d.balBefore+' \u2192 '+d.balAfter, 'log-ok'); }
            _fixIndex++; setTimeout(fixNextInQueue, 120);
        });
    }

    // Details Modal
    function showDetails(regno, name) {
        _modalRegno = regno;
        document.getElementById('detailsTitle').textContent = 'Duplicates: ' + regno + (name ? ' \u2014 '+name : '');
        document.getElementById('detailsStats').innerHTML   = '<em style="font-size:11px;color:#888">Loading...</em>';
        document.getElementById('detailsNotice').innerHTML  = '';
        document.getElementById('detailsBody').innerHTML    = '';
        document.getElementById('detailsTableWrap').style.display = 'none';
        document.getElementById('btnModalFix').style.display = 'none';
        document.getElementById('detailsOverlay').classList.add('open');

        xhr(BASE + '?ajax=details&regno=' + encodeURIComponent(regno) + '&_t=' + Date.now(), function (err, d) {
            if (err || !d || !d.ok) {
                document.getElementById('detailsStats').innerHTML = '<div class="dbc-notice visible dbc-notice--err">Error: '+esc(err||(d&&d.error))+'</div>'; return;
            }
            document.getElementById('detailsStats').innerHTML =
                '<div class="dbc-modal-stat"><div class="dbc-modal-stat__label">Duplicates</div><div class="dbc-modal-stat__val" style="color:#c62828">'+d.dupCount+'</div></div>' +
                '<div class="dbc-modal-stat"><div class="dbc-modal-stat__label">Overbilled DR</div><div class="dbc-modal-stat__val" style="color:#c62828">UGX '+fmt(d.dupDrAmount)+'</div></div>' +
                '<div class="dbc-modal-stat"><div class="dbc-modal-stat__label">Balance</div><div class="dbc-modal-stat__val">'+esc(d.balance)+'</div></div>';

            if (!d.transactions || d.transactions.length === 0) {
                document.getElementById('detailsNotice').innerHTML = '<div class="dbc-notice visible dbc-notice--success">\u2714 No duplicate entries found now. May have been fixed already.</div>'; return;
            }
            var rows = '';
            for (var i=0; i<d.transactions.length; i++) {
                var t = d.transactions[i];
                var tc = t.type === 'DR' ? '#c62828' : '#2e7d32';
                rows += '<tr><td><span class="fs-code">'+t.tid+'</span></td>' +
                    '<td><strong style="color:'+tc+'">'+esc(t.type)+'</strong></td>' +
                    '<td class="r">UGX '+fmt(t.amount)+'</td>' +
                    '<td style="max-width:200px;word-break:break-word;font-size:10px">'+esc(t.particulars)+'</td>' +
                    '<td><span class="fs-code">'+esc(t.folio)+'</span></td>' +
                    '<td class="c">'+(t.trackingRef||'--')+'</td>' +
                    '<td>'+esc(t.teller)+'</td><td style="white-space:nowrap">'+esc(t.date)+'</td></tr>';
            }
            document.getElementById('detailsBody').innerHTML = rows;
            document.getElementById('detailsTableWrap').style.display = '';
            document.getElementById('btnModalFix').style.display = '';
        });
    }

    function closeDetails() { document.getElementById('detailsOverlay').classList.remove('open'); _modalRegno = null; }

    function fixFromModal() {
        if (!_modalRegno) return;
        var regno = _modalRegno; closeDetails();
        var idx = -1;
        for (var i=0;i<_allRows.length;i++) { if (_allRows[i].regno===regno) { idx=i; break; } }
        if (idx >= 0) fixOne(regno, idx);
    }

    // Init
    refreshSummary();
    window.runFullScan     = runFullScan;
    window.loadCasesFromDb = loadCasesFromDb;
    window.applyFilter     = applyFilter;
    window.changePage      = changePage;
    window.fixOne          = fixOne;
    window.fixAllAffected  = fixAllAffected;
    window.showDetails     = showDetails;
    window.closeDetails    = closeDetails;
    window.fixFromModal    = fixFromModal;
    window.refreshSummary  = refreshSummary;
}());
</script>
</asp:Content>