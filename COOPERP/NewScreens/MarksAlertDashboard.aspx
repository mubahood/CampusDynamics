<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksAlertDashboard.aspx.cs" Inherits="COOPERP_NewScreens_MarksAlertDashboard" Title="Operational Alerts - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== MARKS ALERT DASHBOARD (prefix: mad-) ============================ */

/* Layout */
.mad-header { background: linear-gradient(135deg, #37474f 0%, #546e7a 100%); color: #fff; padding: 16px 20px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; }
.mad-title { font-size: 16px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.mad-subtitle { font-size: 11px; opacity: .8; margin-top: 2px; }
.mad-period { display: flex; gap: 0; }
.mad-period__btn { padding: 6px 16px; font-size: 11px; font-weight: 600; border: 1px solid rgba(255,255,255,.25); background: transparent; color: rgba(255,255,255,.7); cursor: pointer; transition: all .15s; }
.mad-period__btn:first-child { border-radius: 3px 0 0 3px; }
.mad-period__btn:last-child { border-radius: 0 3px 3px 0; }
.mad-period__btn--active { background: rgba(255,255,255,.2); color: #fff; border-color: rgba(255,255,255,.5); }
.mad-period__btn:hover { background: rgba(255,255,255,.15); }

/* Stats Cards */
.mad-stats { display: grid; grid-template-columns: repeat(6, 1fr); gap: 0; border: 1px solid #e0e5ed; }
.mad-stat { padding: 16px; text-align: center; border-right: 1px solid #e0e5ed; background: #fff; }
.mad-stat:last-child { border-right: none; }
.mad-stat__val { font-size: 24px; font-weight: 800; line-height: 1.2; }
.mad-stat__label { font-size: 10px; color: #888; text-transform: uppercase; letter-spacing: .4px; margin-top: 4px; }
.mad-stat__val--total { color: #174DA4; }
.mad-stat__val--success { color: #2e7d32; }
.mad-stat__val--error { color: #c62828; }
.mad-stat__val--auth { color: #e65100; }
.mad-stat__val--lock { color: #6a1b9a; }
.mad-stat__val--speed { color: #00695c; }

/* Trend Section */
.mad-section { margin-top: 12px; border: 1px solid #e0e5ed; background: #fff; }
.mad-section__head { padding: 10px 16px; border-bottom: 1px solid #e0e5ed; font-size: 11px; font-weight: 700; color: #333; text-transform: uppercase; letter-spacing: .4px; display: flex; align-items: center; justify-content: space-between; }
.mad-section__head span { font-weight: 400; color: #888; text-transform: none; letter-spacing: 0; }
.mad-trend { padding: 12px 16px; }
.mad-trend__row { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; font-size: 10px; }
.mad-trend__label { width: 60px; text-align: right; color: #888; flex-shrink: 0; }
.mad-trend__bar-wrap { flex: 1; height: 18px; background: #f4f6f9; border-radius: 2px; position: relative; overflow: hidden; display: flex; }
.mad-trend__bar { height: 100%; background: #174DA4; transition: width .3s; }
.mad-trend__bar--err { background: #c62828; }
.mad-trend__count { width: 50px; text-align: right; font-weight: 600; color: #333; flex-shrink: 0; }
.mad-trend__empty { padding: 20px; text-align: center; color: #aaa; font-size: 11px; }

/* Top Errors */
.mad-errors { padding: 10px 16px; }
.mad-errors__row { display: flex; align-items: center; justify-content: space-between; padding: 4px 0; border-bottom: 1px solid #f0f0f0; font-size: 11px; }
.mad-errors__row:last-child { border-bottom: none; }
.mad-errors__page { font-weight: 600; color: #333; }
.mad-errors__cnt { background: #fde8e8; color: #c62828; padding: 1px 8px; border-radius: 10px; font-size: 10px; font-weight: 700; }

/* Filters */
.mad-filters { display: flex; gap: 8px; padding: 10px 16px; border-bottom: 1px solid #e0e5ed; flex-wrap: wrap; align-items: center; background: #f8f9fb; }
.mad-filters select, .mad-filters input { padding: 5px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; }
.mad-filters__btn { padding: 5px 14px; font-size: 11px; font-weight: 600; background: #174DA4; color: #fff; border: none; cursor: pointer; }
.mad-filters__btn:hover { background: #0d3b82; }

/* Log Table */
.mad-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.mad-table th { background: #f0f2f5; padding: 8px 10px; text-align: left; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; color: #555; border-bottom: 2px solid #d1d5db; position: sticky; top: 0; z-index: 1; }
.mad-table td { padding: 6px 10px; border-bottom: 1px solid #eee; vertical-align: middle; }
.mad-table tr:hover td { background: #f8f9fb; }
.mad-outcome { display: inline-block; padding: 1px 8px; font-size: 9px; font-weight: 700; border-radius: 2px; text-transform: uppercase; }
.mad-outcome--success { background: #e6f4ea; color: #2e7d32; }
.mad-outcome--error, .mad-outcome--system_error { background: #fde8e8; color: #c62828; }
.mad-outcome--auth_fail { background: #fff3e0; color: #e65100; }
.mad-outcome--locked { background: #f3e5f5; color: #6a1b9a; }
.mad-outcome--validation_fail { background: #e3f2fd; color: #1565c0; }
.mad-outcome--skipped { background: #f0f0f0; color: #666; }

/* Paging */
.mad-paging { display: flex; align-items: center; justify-content: space-between; padding: 8px 16px; font-size: 11px; border-top: 1px solid #e0e5ed; background: #f8f9fb; }
.mad-paging__btn { padding: 4px 12px; font-size: 10px; font-weight: 600; background: #fff; border: 1px solid #cdd3de; cursor: pointer; }
.mad-paging__btn:disabled { opacity: .4; cursor: not-allowed; }
.mad-paging__btn:hover:not(:disabled) { background: #f4f6f9; }

/* Loading */
.mad-loading { text-align: center; padding: 40px; font-size: 12px; color: #888; }
.mad-loading span { display: inline-block; animation: mad-spin 1s linear infinite; }
@keyframes mad-spin { to { transform: rotate(360deg); } }

/* Responsive */
@media (max-width: 900px) { .mad-stats { grid-template-columns: repeat(3, 1fr); } .mad-stat { border-bottom: 1px solid #e0e5ed; } }
@media (max-width: 600px) {
    .mad-stats { grid-template-columns: repeat(2, 1fr); }
    .mad-header { flex-direction: column; align-items: flex-start; }
    .mad-filters { flex-direction: column; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Loading -->
<div id="madLoading" class="mad-loading"><span>&#9696;</span> Loading operational data&hellip;</div>

<!-- Header -->
<div id="madHeader" class="mad-header" style="display:none;">
    <div>
        <div class="mad-title">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            Operational Alerts
        </div>
        <div class="mad-subtitle">Marks module health monitoring &amp; action log</div>
    </div>
    <div class="mad-period" id="madPeriod">
        <button class="mad-period__btn mad-period__btn--active" data-days="1" onclick="MAD.setPeriod(1)">Today</button>
        <button class="mad-period__btn" data-days="7" onclick="MAD.setPeriod(7)">7 Days</button>
        <button class="mad-period__btn" data-days="30" onclick="MAD.setPeriod(30)">30 Days</button>
    </div>
</div>

<!-- Stats Cards -->
<div id="madStats" class="mad-stats" style="display:none;">
    <div class="mad-stat">
        <div class="mad-stat__val mad-stat__val--total" id="madTotalActions">0</div>
        <div class="mad-stat__label">Total Actions</div>
    </div>
    <div class="mad-stat">
        <div class="mad-stat__val mad-stat__val--success" id="madSuccesses">0</div>
        <div class="mad-stat__label">Successful</div>
    </div>
    <div class="mad-stat">
        <div class="mad-stat__val mad-stat__val--error" id="madErrors">0</div>
        <div class="mad-stat__label">Errors</div>
    </div>
    <div class="mad-stat">
        <div class="mad-stat__val mad-stat__val--auth" id="madAuthFails">0</div>
        <div class="mad-stat__label">Auth Failures</div>
    </div>
    <div class="mad-stat">
        <div class="mad-stat__val mad-stat__val--lock" id="madLockConflicts">0</div>
        <div class="mad-stat__label">Lock Conflicts</div>
    </div>
    <div class="mad-stat">
        <div class="mad-stat__val mad-stat__val--speed" id="madAvgDuration">0</div>
        <div class="mad-stat__label">Avg Response (ms)</div>
    </div>
</div>

<!-- Trend + Top Errors: Side by Side -->
<div style="display:grid; grid-template-columns: 2fr 1fr; gap: 0;" id="madTrendWrap" class="mad-section" style="display:none;">
    <div>
        <div class="mad-section__head">Activity Trend <span id="madTrendType"></span></div>
        <div class="mad-trend" id="madTrendBody">
            <div class="mad-trend__empty">No data yet</div>
        </div>
    </div>
    <div style="border-left: 1px solid #e0e5ed;">
        <div class="mad-section__head">Top Error Sources</div>
        <div class="mad-errors" id="madErrorSources">
            <div class="mad-trend__empty">No errors</div>
        </div>
    </div>
</div>

<!-- Log Table Section -->
<div id="madLogSection" class="mad-section" style="display:none;">
    <div class="mad-section__head">
        Action Log
        <span id="madLogCount"></span>
    </div>
    <div class="mad-filters" id="madFilters">
        <select id="madFPage"><option value="">All Pages</option></select>
        <select id="madFAction"><option value="">All Actions</option></select>
        <select id="madFOutcome"><option value="">All Outcomes</option></select>
        <input type="text" id="madFUser" placeholder="Username..." style="width:140px;" />
        <button class="mad-filters__btn" onclick="MAD.loadLogs(1)">
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            Filter
        </button>
    </div>
    <div style="overflow-x:auto;">
        <table class="mad-table">
            <thead>
                <tr>
                    <th>Time</th>
                    <th>Page</th>
                    <th>Action</th>
                    <th>User</th>
                    <th>IP</th>
                    <th>Duration</th>
                    <th>Outcome</th>
                    <th>Corr ID</th>
                </tr>
            </thead>
            <tbody id="madLogBody"></tbody>
        </table>
    </div>
    <div class="mad-paging" id="madPaging" style="display:none;">
        <span id="madPageInfo"></span>
        <div>
            <button class="mad-paging__btn" id="madPrevBtn" onclick="MAD.prevPage()" disabled>&laquo; Prev</button>
            <button class="mad-paging__btn" id="madNextBtn" onclick="MAD.nextPage()">Next &raquo;</button>
        </div>
    </div>
</div>

<script type="text/javascript">
var MAD = (function () {
    'use strict';

    var state = {
        days: 1,
        logPage: 1,
        logTotal: 0,
        logPageSize: 50
    };

    function el(id) { return document.getElementById(id); }
    function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }

    // ── Init ───────────────────────────────────────────────────────
    function init() {
        el('madLoading').style.display = 'none';
        el('madHeader').style.display = '';
        el('madStats').style.display = '';
        el('madTrendWrap').style.display = '';
        el('madLogSection').style.display = '';

        loadSummary();
        loadLogs(1);
    }

    // ── Period Selector ────────────────────────────────────────────
    function setPeriod(days) {
        state.days = days;
        var btns = el('madPeriod').getElementsByTagName('button');
        for (var i = 0; i < btns.length; i++) {
            btns[i].className = 'mad-period__btn' + (parseInt(btns[i].getAttribute('data-days'), 10) === days ? ' mad-period__btn--active' : '');
        }
        loadSummary();
        loadLogs(1);
    }

    // ── Load Summary ───────────────────────────────────────────────
    function loadSummary() {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '?ajax=summary&days=' + state.days, true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) return;
                renderSummary(d);
            } catch (ex) { }
        };
        xhr.send();
    }

    function renderSummary(d) {
        el('madTotalActions').textContent = _fmt(d.total_actions || 0);
        el('madSuccesses').textContent = _fmt(d.successes || 0);
        el('madErrors').textContent = _fmt(d.errors || 0);
        el('madAuthFails').textContent = _fmt(d.auth_failures || 0);
        el('madLockConflicts').textContent = _fmt(d.lock_conflicts || 0);
        el('madAvgDuration').textContent = (d.avg_duration || 0) + 'ms';

        // Trend
        renderTrend(d.trend || [], d.trend_type);

        // Top error pages
        renderErrorSources(d.top_error_pages || []);
    }

    function renderTrend(data, type) {
        var container = el('madTrendBody');
        el('madTrendType').textContent = type === 'hourly' ? '(Last 24 hours)' : '(Daily)';

        if (!data.length) {
            container.innerHTML = '<div class="mad-trend__empty">No activity in this period</div>';
            return;
        }

        var maxN = 0;
        for (var i = 0; i < data.length; i++) {
            if (data[i].n > maxN) maxN = data[i].n;
        }
        if (maxN === 0) maxN = 1;

        var html = '';
        for (var i = 0; i < data.length; i++) {
            var d = data[i];
            var okW = Math.round(((d.n - d.e) / maxN) * 100);
            var errW = Math.round((d.e / maxN) * 100);
            html += '<div class="mad-trend__row">';
            html += '<div class="mad-trend__label">' + esc(d.t) + '</div>';
            html += '<div class="mad-trend__bar-wrap">';
            if (okW > 0) html += '<div class="mad-trend__bar" style="width:' + okW + '%"></div>';
            if (errW > 0) html += '<div class="mad-trend__bar mad-trend__bar--err" style="width:' + errW + '%"></div>';
            html += '</div>';
            html += '<div class="mad-trend__count">' + d.n + '</div>';
            html += '</div>';
        }
        container.innerHTML = html;
    }

    function renderErrorSources(pages) {
        var container = el('madErrorSources');
        if (!pages.length) {
            container.innerHTML = '<div class="mad-trend__empty">No errors in this period</div>';
            return;
        }
        var html = '';
        for (var i = 0; i < pages.length; i++) {
            html += '<div class="mad-errors__row">';
            html += '<span class="mad-errors__page">' + esc(pages[i].page) + '</span>';
            html += '<span class="mad-errors__cnt">' + pages[i].count + '</span>';
            html += '</div>';
        }
        container.innerHTML = html;
    }

    // ── Load Logs ──────────────────────────────────────────────────
    function loadLogs(pg) {
        state.logPage = pg;
        var url = '?ajax=logs&days=' + state.days + '&page=' + pg;
        var fp = el('madFPage').value; if (fp) url += '&fpage=' + encodeURIComponent(fp);
        var fa = el('madFAction').value; if (fa) url += '&faction=' + encodeURIComponent(fa);
        var fo = el('madFOutcome').value; if (fo) url += '&foutcome=' + encodeURIComponent(fo);
        var fu = el('madFUser').value.trim(); if (fu) url += '&fuser=' + encodeURIComponent(fu);

        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            try {
                var d = JSON.parse(xhr.responseText);
                if (d.error) { el('madLogBody').innerHTML = '<tr><td colspan="8" style="color:#c62828;padding:14px;">' + esc(d.error) + '</td></tr>'; return; }
                state.logTotal = d.total;
                state.logPageSize = d.pageSize;
                renderLogs(d.rows || []);
                renderPaging(d.total, d.page, d.pageSize);
                if (d.filter_options && pg === 1) populateFilters(d.filter_options);
            } catch (ex) {
                el('madLogBody').innerHTML = '<tr><td colspan="8" style="color:#c62828;padding:14px;">Failed to load logs</td></tr>';
            }
        };
        xhr.send();
    }

    function renderLogs(rows) {
        var body = el('madLogBody');
        if (!rows.length) {
            body.innerHTML = '<tr><td colspan="8" style="padding:20px;text-align:center;color:#aaa;">No log entries match the current filters.</td></tr>';
            return;
        }
        var html = '';
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            html += '<tr>';
            html += '<td style="white-space:nowrap;font-size:10px;">' + esc(r.time) + '</td>';
            html += '<td>' + esc(r.page) + '</td>';
            html += '<td>' + esc(r.action) + '</td>';
            html += '<td>' + esc(r.user) + '</td>';
            html += '<td style="font-size:10px;color:#888;">' + esc(r.ip) + '</td>';
            html += '<td style="text-align:right;">' + r.ms + '<span style="color:#aaa;font-size:9px;">ms</span></td>';
            html += '<td><span class="mad-outcome mad-outcome--' + esc(r.outcome) + '">' + esc(r.outcome) + '</span></td>';
            html += '<td style="font-size:10px;color:#888;">' + esc(r.corr) + '</td>';
            html += '</tr>';
        }
        body.innerHTML = html;
    }

    function renderPaging(total, pg, pageSize) {
        var paging = el('madPaging');
        if (total <= pageSize) { paging.style.display = 'none'; return; }
        paging.style.display = '';
        var totalPages = Math.ceil(total / pageSize);
        el('madPageInfo').textContent = 'Page ' + pg + ' of ' + totalPages + ' (' + _fmt(total) + ' entries)';
        el('madPrevBtn').disabled = (pg <= 1);
        el('madNextBtn').disabled = (pg >= totalPages);
    }

    function prevPage() { if (state.logPage > 1) loadLogs(state.logPage - 1); }
    function nextPage() {
        var totalPages = Math.ceil(state.logTotal / state.logPageSize);
        if (state.logPage < totalPages) loadLogs(state.logPage + 1);
    }

    function populateFilters(opts) {
        _fillSelect('madFPage', opts.pages || [], 'All Pages');
        _fillSelect('madFAction', opts.actions || [], 'All Actions');
        _fillSelect('madFOutcome', opts.outcomes || [], 'All Outcomes');
    }

    function _fillSelect(id, vals, defaultLabel) {
        var sel = el(id);
        var current = sel.value;
        sel.innerHTML = '<option value="">' + defaultLabel + '</option>';
        for (var i = 0; i < vals.length; i++) {
            var opt = document.createElement('option');
            opt.value = vals[i];
            opt.textContent = vals[i];
            sel.appendChild(opt);
        }
        sel.value = current;
    }

    // ── Helpers ────────────────────────────────────────────────────
    function _fmt(n) {
        if (n === null || n === undefined) return '0';
        return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    // ── Boot ──────────────────────────────────────────────────────
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // ── Public API ────────────────────────────────────────────────
    return {
        setPeriod: setPeriod,
        loadLogs: loadLogs,
        prevPage: prevPage,
        nextPage: nextPage
    };
})();
</script>
</asp:Content>
