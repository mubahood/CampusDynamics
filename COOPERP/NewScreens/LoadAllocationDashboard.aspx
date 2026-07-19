<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LoadAllocationDashboard.aspx.cs" Inherits="COOPERP_NewScreens_LoadAllocationDashboard" Title="Load Allocation Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== LOAD ALLOCATION DASHBOARD (prefix: ld-) ========================== */

/* Header */
.ld-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.ld-header__left { display: flex; align-items: center; gap: 10px; }
.ld-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.ld-header__icon svg { color: #fff; }
.ld-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.ld-header__sub   { font-size: 10px; color: #888; margin-top: 1px; }

/* Stats Row (4 cards) */
.ld-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.ld-stat { background: #fff; border: 1px solid #e0e5ed; padding: 14px; display: flex; align-items: center; gap: 12px; position: relative; overflow: hidden; }
.ld-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.ld-stat__icon { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 4px; }
.ld-stat__val { font-size: 18px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.ld-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.ld-stat__trend { font-size: 9px; font-weight: 600; margin-top: 2px; }
.ld-stat__trend--up   { color: #2e7d32; } .ld-stat__trend--up::before   { content: '\25B2 '; }
.ld-stat__trend--down { color: #c62828; } .ld-stat__trend--down::before { content: '\25BC '; }
.ld-stat__trend--flat { color: #999; }
.ld-stat--total     { --stat-c:#174DA4; } .ld-stat--total .ld-stat__icon     { background:#e8f0fc; }
.ld-stat--scheduled { --stat-c:#2e7d32; } .ld-stat--scheduled .ld-stat__icon { background:#e6f4ea; }
.ld-stat--unsched   { --stat-c:#e65100; } .ld-stat--unsched .ld-stat__icon   { background:#fce8de; }
.ld-stat--lecturers { --stat-c:#6a1b9a; } .ld-stat--lecturers .ld-stat__icon { background:#f3e5f5; }

/* Quick Actions */
.ld-actions { display: flex; gap: 8px; margin-bottom: 14px; flex-wrap: wrap; }
.ld-action { display: flex; align-items: center; gap: 6px; padding: 8px 14px; background: #fff; border: 1px solid #e0e5ed; font-size: 11px; font-weight: 600; color: #05275C; cursor: pointer; transition: all .15s; text-decoration: none; }
.ld-action:hover { border-color: #174DA4; background: #f0f4ff; }
.ld-action svg { flex-shrink: 0; }

/* Two-column layout */
.ld-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px; }
@media (max-width: 900px) { .ld-row { grid-template-columns: 1fr; } }

/* Card */
.ld-card { background: #fff; border: 1px solid #e0e5ed; }
.ld-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.ld-card__title  { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }
.ld-card__body   { padding: 0; }

/* Alerts list */
.ld-alerts { list-style: none; margin: 0; padding: 0; }
.ld-alerts li { display: flex; align-items: flex-start; gap: 8px; padding: 10px 14px; border-bottom: 1px solid #f0f2f5; font-size: 11px; color: #333; }
.ld-alerts li:last-child { border-bottom: none; }
.ld-alerts__icon { flex-shrink: 0; margin-top: 1px; }
.ld-alerts__icon--warn { color: #e65100; }
.ld-alerts__icon--danger { color: #c62828; }
.ld-alerts__icon--info { color: #174DA4; }

/* Coverage table */
.ld-cov-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.ld-cov-table th { background: #f5f7fa; padding: 8px 12px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.ld-cov-table td { padding: 7px 12px; border-bottom: 1px solid #f0f2f5; }
.ld-cov-table tbody tr:hover { background: #f0f4ff; }

/* Coverage bar */
.ld-cov-bar { display: inline-block; width: 60px; height: 6px; background: #e8ebef; border-radius: 3px; vertical-align: middle; position: relative; margin-right: 4px; }
.ld-cov-bar__fill { height: 6px; border-radius: 3px; display: block; }
.ld-cov-bar__fill--green  { background: #2e7d32; }
.ld-cov-bar__fill--orange { background: #e65100; }
.ld-cov-bar__fill--red    { background: #c62828; }

/* Activity log */
.ld-activity { list-style: none; margin: 0; padding: 0; }
.ld-activity li { display: flex; gap: 10px; padding: 8px 14px; border-bottom: 1px solid #f0f2f5; font-size: 10px; color: #555; align-items: flex-start; }
.ld-activity li:last-child { border-bottom: none; }
.ld-activity__time  { color: #999; white-space: nowrap; min-width: 80px; }
.ld-activity__badge { display: inline-block; padding: 1px 6px; font-size: 9px; font-weight: 600; border-radius: 2px; }
.ld-activity__badge--created { background: #e6f4ea; color: #2e7d32; }
.ld-activity__badge--updated { background: #e3f2fd; color: #1565c0; }

/* Empty */
.ld-empty { text-align: center; padding: 30px 20px; color: #999; font-size: 11px; }

/* Loading */
.ld-loading { text-align: center; padding: 30px; font-size: 11px; color: #999; }

/* Print */
@media print {
    .ld-actions { display: none !important; }
    .ld-stat { break-inside: avoid; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="ld-header">
    <div class="ld-header__left">
        <div class="ld-header__icon">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
        </div>
        <div>
            <div class="ld-header__title">Load Allocation Dashboard</div>
            <div class="ld-header__sub" id="ldSubtitle">Loading...</div>
        </div>
    </div>
</div>

<!-- Stats Row -->
<div class="ld-stats">
    <div class="ld-stat ld-stat--total">
        <div class="ld-stat__icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg></div>
        <div>
            <div class="ld-stat__val" id="statTotal">—</div>
            <div class="ld-stat__label">Total Allocations</div>
            <div class="ld-stat__trend" id="trendTotal"></div>
        </div>
    </div>
    <div class="ld-stat ld-stat--scheduled">
        <div class="ld-stat__icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
        <div>
            <div class="ld-stat__val" id="statScheduled">—</div>
            <div class="ld-stat__label">Scheduled</div>
            <div class="ld-stat__trend" id="trendScheduled"></div>
        </div>
    </div>
    <div class="ld-stat ld-stat--unsched">
        <div class="ld-stat__icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
        <div>
            <div class="ld-stat__val" id="statUnscheduled">—</div>
            <div class="ld-stat__label">Unscheduled</div>
            <div class="ld-stat__trend" id="trendUnscheduled"></div>
        </div>
    </div>
    <div class="ld-stat ld-stat--lecturers">
        <div class="ld-stat__icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6a1b9a" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
        <div>
            <div class="ld-stat__val" id="statLecturers">—</div>
            <div class="ld-stat__label">Active Lecturers</div>
            <div class="ld-stat__trend" id="trendLecturers"></div>
        </div>
    </div>
</div>

<!-- Quick Actions -->
<div class="ld-actions">
    <a class="ld-action" href="LoadAllocations.aspx">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
        Manage Allocations
    </a>
    <a class="ld-action" href="TimetableCalendar.aspx">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        View Timetable
    </a>
    <a class="ld-action" href="WorkloadAnalysis.aspx">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6"/><path d="M23 11h-6"/></svg>
        Workload Report
    </a>
    <a class="ld-action" href="LectureRooms.aspx">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        Lecture Rooms
    </a>
</div>

<!-- Two-column layout: Alerts + Coverage -->
<div class="ld-row">
    <!-- Alerts Panel -->
    <div class="ld-card">
        <div class="ld-card__header">
            <div class="ld-card__title">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                Alerts &amp; Warnings
            </div>
        </div>
        <div class="ld-card__body" id="alertsContainer">
            <div class="ld-loading">Loading alerts...</div>
        </div>
    </div>

    <!-- Programme Coverage -->
    <div class="ld-card">
        <div class="ld-card__header">
            <div class="ld-card__title">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                Programme Coverage
            </div>
        </div>
        <div class="ld-card__body" id="coverageContainer">
            <div class="ld-loading">Loading coverage...</div>
        </div>
    </div>
</div>

<!-- Recent Activity -->
<div class="ld-card">
    <div class="ld-card__header">
        <div class="ld-card__title">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            Recent Activity
        </div>
    </div>
    <div class="ld-card__body" id="activityContainer">
        <div class="ld-loading">Loading activity...</div>
    </div>
</div>

<script type="text/javascript">
/* ===== LOAD ALLOCATION DASHBOARD — CLIENT-SIDE JS ======================= */

(function () { loadDashboard(); })();

function loadDashboard() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'LoadAllocationDashboard.aspx?ajax=dashboard', true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) return;
        try {
            var d = JSON.parse(xhr.responseText);
            if (!d.ok) return;
            renderStats(d);
            renderAlerts(d.alerts || []);
            renderCoverage(d.coverage || []);
            renderActivity(d.activity || []);
            document.getElementById('ldSubtitle').textContent = d.acadYear + ' \u2014 Semester ' + d.semester + ' \u2014 ' + d.campusName;
        } catch (ex) { }
    };
    xhr.send();
}

function renderStats(d) {
    setText('statTotal',       d.totalAllocations);
    setText('statScheduled',   d.scheduledCount);
    setText('statUnscheduled', d.unscheduledCount);
    setText('statLecturers',   d.lecturerCount);

    setTrend('trendTotal',       d.prevTotal,       d.totalAllocations);
    setTrend('trendScheduled',   d.prevScheduled,   d.scheduledCount);
    setTrend('trendUnscheduled', d.prevUnscheduled, d.unscheduledCount, true);
    setTrend('trendLecturers',   d.prevLecturers,   d.lecturerCount);
}

function setText(id, val) { document.getElementById(id).textContent = val || 0; }

function setTrend(id, prev, curr, invertColor) {
    var el = document.getElementById(id);
    if (!prev || prev === 0) { el.className = 'ld-stat__trend ld-stat__trend--flat'; el.textContent = 'N/A prev semester'; return; }
    var diff = curr - prev;
    var pct  = Math.round(Math.abs(diff / prev) * 100);
    if (diff > 0) {
        el.className = 'ld-stat__trend ld-stat__trend--' + (invertColor ? 'down' : 'up');
        el.textContent = pct + '% vs prev semester';
    } else if (diff < 0) {
        el.className = 'ld-stat__trend ld-stat__trend--' + (invertColor ? 'up' : 'down');
        el.textContent = pct + '% vs prev semester';
    } else {
        el.className = 'ld-stat__trend ld-stat__trend--flat';
        el.textContent = 'Same as prev semester';
    }
}

function renderAlerts(alerts) {
    var c = document.getElementById('alertsContainer');
    if (!alerts.length) { c.innerHTML = '<div class="ld-empty">No alerts — everything looks good!</div>'; return; }

    var html = '<ul class="ld-alerts">';
    for (var i = 0; i < alerts.length; i++) {
        var a = alerts[i];
        var iconCls = a.severity === 'danger' ? 'ld-alerts__icon--danger' : (a.severity === 'info' ? 'ld-alerts__icon--info' : 'ld-alerts__icon--warn');
        html += '<li>'
            + '<span class="ld-alerts__icon ' + iconCls + '">'
            + '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>'
            + '</span>'
            + '<span>' + esc(a.message) + '</span>'
            + '</li>';
    }
    html += '</ul>';
    c.innerHTML = html;
}

function renderCoverage(items) {
    var c = document.getElementById('coverageContainer');
    if (!items.length) { c.innerHTML = '<div class="ld-empty">No programme data available.</div>'; return; }

    var html = '<table class="ld-cov-table"><thead><tr>'
        + '<th>Programme</th><th style="text-align:center;">Allocated</th><th style="text-align:center;">Scheduled</th>'
        + '<th style="text-align:center;">Total Courses</th><th>Coverage</th>'
        + '</tr></thead><tbody>';

    for (var i = 0; i < items.length; i++) {
        var r = items[i];
        var allocPct = r.totalCourses > 0 ? Math.round((r.allocated / r.totalCourses) * 100) : 0;
        var schedPct = r.allocated > 0 ? Math.round((r.scheduled / r.allocated) * 100) : 0;
        var barCls = allocPct >= 90 ? 'ld-cov-bar__fill--green' : (allocPct >= 50 ? 'ld-cov-bar__fill--orange' : 'ld-cov-bar__fill--red');

        html += '<tr>'
            + '<td><strong>' + esc(r.progAbbrev) + '</strong></td>'
            + '<td style="text-align:center;">' + r.allocated + '</td>'
            + '<td style="text-align:center;">' + r.scheduled + '</td>'
            + '<td style="text-align:center;">' + r.totalCourses + '</td>'
            + '<td>'
            + '<span class="ld-cov-bar"><span class="ld-cov-bar__fill ' + barCls + '" style="width:' + allocPct + '%;"></span></span>'
            + allocPct + '% / ' + schedPct + '%'
            + '</td></tr>';
    }
    html += '</tbody></table>';
    c.innerHTML = html;
}

function renderActivity(items) {
    var c = document.getElementById('activityContainer');
    if (!items.length) { c.innerHTML = '<div class="ld-empty">No recent activity recorded.</div>'; return; }

    var html = '<ul class="ld-activity">';
    for (var i = 0; i < items.length; i++) {
        var a = items[i];
        var badgeCls = a.action === 'Created' ? 'ld-activity__badge--created' : 'ld-activity__badge--updated';
        html += '<li>'
            + '<span class="ld-activity__time">' + esc(a.timeAgo) + '</span>'
            + '<span class="ld-activity__badge ' + badgeCls + '">' + esc(a.action) + '</span>'
            + '<span>' + esc(a.user) + ' — ' + esc(a.details) + '</span>'
            + '</li>';
    }
    html += '</ul>';
    c.innerHTML = html;
}

function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }
</script>

</asp:Content>
