<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="WorkloadAnalysis.aspx.cs" Inherits="COOPERP_NewScreens_WorkloadAnalysis" Title="Workload Analysis - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== WORKLOAD ANALYSIS PAGE (prefix: wa-) ============================= */

/* Stats Row */
.wa-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.wa-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.wa-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.wa-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.wa-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.wa-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.wa-stat--lecturers  { --stat-c:#174DA4; } .wa-stat--lecturers .wa-stat__icon  { background:#e8f0fc; } .wa-stat--lecturers .wa-stat__val  { color:#174DA4; }
.wa-stat--avg        { --stat-c:#2e7d32; } .wa-stat--avg .wa-stat__icon        { background:#e6f4ea; } .wa-stat--avg .wa-stat__val        { color:#2e7d32; }
.wa-stat--overloaded { --stat-c:#c62828; } .wa-stat--overloaded .wa-stat__icon { background:#fce4ec; } .wa-stat--overloaded .wa-stat__val { color:#c62828; }
.wa-stat--unassigned { --stat-c:#e65100; } .wa-stat--unassigned .wa-stat__icon { background:#fce8de; } .wa-stat--unassigned .wa-stat__val { color:#e65100; }

/* Header */
.wa-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.wa-header__left { display: flex; align-items: center; gap: 10px; }
.wa-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.wa-header__icon svg { color: #fff; }
.wa-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.wa-header__sub   { font-size: 10px; color: #888; margin-top: 1px; }

/* Filter bar */
.wa-filters { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; align-items: flex-end; }
.wa-filters__group { display: flex; flex-direction: column; gap: 2px; }
.wa-filters__label { font-size: 9px; font-weight: 600; text-transform: uppercase; letter-spacing: .3px; color: #666; }
.wa-filters select, .wa-filters input[type=text] { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; min-width: 130px; }
.wa-filters select:focus, .wa-filters input:focus { border-color: #174DA4; outline: none; }

/* Card */
.wa-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.wa-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.wa-card__title  { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Table */
.wa-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.wa-table th { background: #f5f7fa; padding: 9px 12px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.wa-table td { padding: 8px 12px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; vertical-align: middle; }
.wa-table tbody tr:hover { background: #f0f4ff; cursor: pointer; }
.wa-table tbody tr.wa-row--expanded { background: #f0f4ff; }

/* Status badges */
.wa-badge { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; border-radius: 2px; }
.wa-badge--normal     { background: #e6f4ea; color: #2e7d32; }
.wa-badge--heavy      { background: #fff3e0; color: #e65100; }
.wa-badge--overloaded { background: #fce4ec; color: #c62828; }
.wa-badge--unassigned { background: #f5f5f5; color: #999; }

/* Expand detail row */
.wa-detail { display: none; }
.wa-detail td { padding: 0; }
.wa-detail--open { display: table-row; }
.wa-detail__inner { padding: 10px 14px 14px 48px; background: #fafbfc; border-left: 3px solid #174DA4; }
.wa-detail__header { font-size: 11px; font-weight: 700; color: #05275C; margin-bottom: 8px; }
.wa-detail__table { width: 100%; border-collapse: collapse; font-size: 10px; margin-bottom: 6px; }
.wa-detail__table th { background: #eef1f5; padding: 5px 10px; text-align: left; font-weight: 600; color: #555; }
.wa-detail__table td { padding: 5px 10px; border-bottom: 1px solid #e8ebef; }
.wa-detail__summary { font-size: 10px; color: #666; margin-top: 4px; }

/* Bars */
.wa-bar-wrap { width: 80px; height: 6px; background: #e8ebef; border-radius: 3px; display: inline-block; vertical-align: middle; margin-right: 4px; }
.wa-bar-fill { height: 6px; border-radius: 3px; display: block; }
.wa-bar-fill--green  { background: #2e7d32; }
.wa-bar-fill--orange { background: #e65100; }
.wa-bar-fill--red    { background: #c62828; }

/* Buttons */
.wa-btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.wa-btn--primary { background: #05275C; color: #fff; } .wa-btn--primary:hover { background: #174DA4; }
.wa-btn--ghost   { background: #fff; border: 1px solid #cdd3de; color: #555; } .wa-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }

/* Search */
.wa-search { position: relative; }
.wa-search input { padding: 6px 10px 6px 28px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; width: 180px; }
.wa-search input:focus { border-color: #174DA4; outline: none; }
.wa-search__icon { position: absolute; left: 8px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }

/* Print */
@media print {
    .wa-filters, .wa-btn, .wa-search { display: none !important; }
    .wa-stat { break-inside: avoid; }
    .wa-table { font-size: 9px; }
    .wa-detail--open { display: table-row !important; }
}

/* Empty / loading */
.wa-empty { text-align: center; padding: 40px 20px; color: #999; font-size: 12px; }
.wa-loading { text-align: center; padding: 30px; font-size: 11px; color: #999; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="wa-header">
    <div class="wa-header__left">
        <div class="wa-header__icon">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6"/><path d="M23 11h-6"/></svg>
        </div>
        <div>
            <div class="wa-header__title">Workload Analysis</div>
            <div class="wa-header__sub" id="waSubtitle">Loading...</div>
        </div>
    </div>
    <div style="display:flex;gap:6px;">
        <button class="wa-btn wa-btn--ghost" onclick="printReport()">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print
        </button>
        <button class="wa-btn wa-btn--ghost" onclick="exportCSV()">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Export CSV
        </button>
    </div>
</div>

<!-- Stats Row -->
<div class="wa-stats">
    <div class="wa-stat wa-stat--lecturers">
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
        <div><div class="wa-stat__val" id="statLecturers">—</div><div class="wa-stat__label">Active Lecturers</div></div>
    </div>
    <div class="wa-stat wa-stat--avg">
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div><div class="wa-stat__val" id="statAvgHours">—</div><div class="wa-stat__label">Avg Hrs / Lecturer</div></div>
    </div>
    <div class="wa-stat wa-stat--overloaded">
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#c62828" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
        <div><div class="wa-stat__val" id="statOverloaded">—</div><div class="wa-stat__label">Overloaded (&gt;18 hrs)</div></div>
    </div>
    <div class="wa-stat wa-stat--unassigned">
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
        <div><div class="wa-stat__val" id="statSessions">—</div><div class="wa-stat__label">Weekly Sessions</div></div>
    </div>
</div>

<!-- Filter Bar -->
<div class="wa-filters">
    <div class="wa-filters__group">
        <span class="wa-filters__label">Semester</span>
        <select id="ddlSemester" onchange="reload()"><option value="0">All semesters</option><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select>
    </div>
    <div class="wa-filters__group">
        <span class="wa-filters__label">Campus</span>
        <select id="ddlCampus" onchange="reload()"><option value="0">All campuses</option></select>
    </div>
    <div class="wa-filters__group">
        <span class="wa-filters__label">Faculty</span>
        <select id="ddlFaculty" onchange="applyFilters()"><option value="">All Faculties</option></select>
    </div>
    <div class="wa-filters__group">
        <span class="wa-filters__label">Programme</span>
        <select id="ddlProgramme" onchange="applyFilters()"><option value="">All Programmes</option></select>
    </div>
    <div class="wa-filters__group">
        <span class="wa-filters__label">Contract Type</span>
        <select id="ddlContract" onchange="applyFilters()">
            <option value="">All</option>
            <option value="FULL TIME">Full Time</option>
            <option value="PART TIME">Part Time</option>
        </select>
    </div>
    <div class="wa-search">
        <svg class="wa-search__icon" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" id="txtSearch" placeholder="Search lecturer..." oninput="applyFilters()" />
    </div>
</div>

<!-- Workload Table Card -->
<div class="wa-card">
    <div class="wa-card__header">
        <div class="wa-card__title">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6"/><path d="M23 11h-6"/></svg>
            Lecturer Workload — <span id="gridTitle">loading...</span>
        </div>
        <span style="font-size:10px;color:#888;" id="gridCount"></span>
    </div>
    <div id="gridContainer">
        <div class="wa-loading">Loading workload data...</div>
    </div>
</div>

<script type="text/javascript">
/* ===== WORKLOAD ANALYSIS — driven by ACTIVE timetable items ============= */
var _allRows = [], _faculties = [], _programmes = [], _campuses = [], _details = {};
var HEAVY = 12, OVER = 18;   // weekly contact-hour thresholds

(function () { loadData(); })();

function scopeQS() {
    var sem = (document.getElementById('ddlSemester') || {}).value || '0';
    var cam = (document.getElementById('ddlCampus') || {}).value || '0';
    return '&sem=' + encodeURIComponent(sem) + '&campus=' + encodeURIComponent(cam);
}
function reload() { document.getElementById('gridContainer').innerHTML = '<div class="wa-loading">Loading workload…</div>'; loadData(); }

function loadData() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'WorkloadAnalysis.aspx?ajax=data' + scopeQS(), true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) { showEmpty('Failed to load data.'); return; }
        try {
            var d = JSON.parse(xhr.responseText);
            if (!d.ok) { showEmpty(d.error || 'Unknown error'); return; }
            _allRows = d.rows || []; _faculties = d.faculties || []; _programmes = d.programmes || [];
            _campuses = d.campuses || []; _details = d.details || {};
            populateDropdowns();
            applyFilters();
        } catch (ex) { showEmpty('Error parsing data.'); }
    };
    xhr.send();
}

function fillSelect(id, items, valKey, txtKey, firstVal, firstTxt, keepValue) {
    var dd = document.getElementById(id); if (!dd) return;
    var prev = keepValue ? dd.value : firstVal;
    dd.innerHTML = '';
    var o0 = document.createElement('option'); o0.value = firstVal; o0.text = firstTxt; dd.appendChild(o0);
    for (var i = 0; i < items.length; i++) {
        var o = document.createElement('option'); o.value = items[i][valKey]; o.text = items[i][txtKey]; dd.appendChild(o);
    }
    dd.value = prev;
}
function populateDropdowns() {
    fillSelect('ddlCampus', _campuses, 'id', 'name', '0', 'All campuses', true);
    fillSelect('ddlFaculty', _faculties, 'code', 'name', '', 'All Faculties', false);
    fillSelect('ddlProgramme', _programmes, 'code', 'display', '', 'All Programmes', false);
}

function matchRow(r, faculty, programme, contract, search) {
    if (faculty) { var fl = r.faculties_list || []; if (fl.indexOf(faculty) < 0) return false; }
    if (programme) { var pl = r.programmes_list || []; if (pl.indexOf(programme) < 0) return false; }
    if (contract && r.contractType !== contract) return false;
    if (search && (r.lecturerName + ' ' + r.empCode + ' ' + r.department).toLowerCase().indexOf(search) < 0) return false;
    return true;
}
function currentFilters() {
    return {
        faculty: document.getElementById('ddlFaculty').value,
        programme: document.getElementById('ddlProgramme').value,
        contract: document.getElementById('ddlContract').value,
        search: (document.getElementById('txtSearch').value || '').toLowerCase()
    };
}
function filteredRows() {
    var f = currentFilters(), out = [];
    for (var i = 0; i < _allRows.length; i++) if (matchRow(_allRows[i], f.faculty, f.programme, f.contract, f.search)) out.push(_allRows[i]);
    return out;
}
function applyFilters() { var rows = filteredRows(); renderStats(rows); renderGrid(rows); }

function renderStats(rows) {
    var lecturers = rows.length, hours = 0, sessions = 0, overloaded = 0;
    for (var i = 0; i < rows.length; i++) {
        hours += rows[i].weeklyHours; sessions += rows[i].sessionCount;
        if (rows[i].weeklyHours > OVER) overloaded++;
    }
    var avg = lecturers > 0 ? (hours / lecturers).toFixed(1) : '0';
    document.getElementById('statLecturers').textContent = lecturers;
    document.getElementById('statAvgHours').textContent = avg;
    document.getElementById('statOverloaded').textContent = overloaded;
    document.getElementById('statSessions').textContent = sessions;

    var semSel = document.getElementById('ddlSemester'), camSel = document.getElementById('ddlCampus');
    var scope = (semSel.value === '0' ? 'All semesters' : 'Semester ' + semSel.value) + ' · ' + (camSel.selectedOptions[0] ? camSel.selectedOptions[0].text : 'All campuses');
    document.getElementById('waSubtitle').textContent = scope + ' · from active timetable · ' + Math.round(hours) + ' contact hrs/week';
    document.getElementById('gridTitle').textContent = lecturers + ' lecturer' + (lecturers === 1 ? '' : 's');
    document.getElementById('gridCount').textContent = 'Showing ' + lecturers + ' of ' + _allRows.length;
}

function loadBand(hrs) {
    if (hrs > OVER) return { cls: 'wa-bar-fill--red', badge: 'wa-badge--overloaded', label: 'Overloaded' };
    if (hrs > HEAVY) return { cls: 'wa-bar-fill--orange', badge: 'wa-badge--heavy', label: 'Heavy' };
    return { cls: 'wa-bar-fill--green', badge: 'wa-badge--normal', label: 'Normal' };
}

function renderGrid(rows) {
    var c = document.getElementById('gridContainer');
    if (!rows.length) { c.innerHTML = '<div class="wa-empty">No timetable sessions found for the selected scope/filters.</div>'; return; }
    var html = '<table class="wa-table"><thead><tr>'
        + '<th style="width:24px;"></th><th>Lecturer</th><th>EMP</th><th>Department</th><th>Contract</th>'
        + '<th style="text-align:center;">Sessions</th><th style="text-align:center;">Hrs/Week</th>'
        + '<th style="text-align:center;">Courses</th><th style="text-align:center;">Progs</th><th>Load</th><th>Status</th>'
        + '</tr></thead><tbody>';
    for (var i = 0; i < rows.length; i++) {
        var r = rows[i], b = loadBand(r.weeklyHours);
        var barPct = Math.min(r.weeklyHours / 24 * 100, 100);
        html += '<tr onclick="toggleDetail(\'' + r.staffCode + '\', this)" title="Click for the session breakdown">'
            + '<td style="text-align:center;color:#999;font-size:10px;">&#9654;</td>'
            + '<td><strong>' + esc(r.lecturerName) + '</strong></td>'
            + '<td>' + esc(r.empCode) + '</td>'
            + '<td>' + esc(r.department) + '</td>'
            + '<td>' + esc(r.contractType || '—') + '</td>'
            + '<td style="text-align:center;font-weight:700;">' + r.sessionCount + '</td>'
            + '<td style="text-align:center;font-weight:700;">' + r.weeklyHours.toFixed(1) + '</td>'
            + '<td style="text-align:center;">' + r.courseCount + '</td>'
            + '<td style="text-align:center;">' + r.programmeCount + '</td>'
            + '<td><span class="wa-bar-wrap"><span class="wa-bar-fill ' + b.cls + '" style="width:' + barPct + '%;"></span></span></td>'
            + '<td><span class="wa-badge ' + b.badge + '">' + b.label + '</span></td>'
            + '</tr>';
        html += '<tr class="wa-detail" id="det_' + r.staffCode + '"><td colspan="11"><div class="wa-detail__inner" id="detInner_' + r.staffCode + '"></div></td></tr>';
    }
    html += '</tbody></table>';
    c.innerHTML = html;
}

function toggleDetail(staffCode, tr) {
    var detRow = document.getElementById('det_' + staffCode); if (!detRow) return;
    var isOpen = detRow.className.indexOf('wa-detail--open') >= 0;
    var allDet = document.querySelectorAll('.wa-detail--open'); for (var i = 0; i < allDet.length; i++) allDet[i].className = 'wa-detail';
    var allExp = document.querySelectorAll('.wa-row--expanded'); for (var j = 0; j < allExp.length; j++) allExp[j].className = '';
    if (isOpen) return;
    detRow.className = 'wa-detail wa-detail--open'; tr.className = 'wa-row--expanded';

    var items = _details[staffCode] || [], inner = document.getElementById('detInner_' + staffCode);
    if (!items.length) { inner.innerHTML = '<div style="color:#999;font-size:10px;">No sessions.</div>'; return; }
    var lecName = ''; for (var k = 0; k < _allRows.length; k++) if (_allRows[k].staffCode === staffCode) { lecName = _allRows[k].lecturerName; break; }

    var h = '<div class="wa-detail__header">' + esc(lecName) + ' — Weekly session breakdown</div>';
    h += '<table class="wa-detail__table"><thead><tr><th>Day</th><th>Time</th><th>Course</th><th>Name</th><th>Programme</th><th>Type</th><th>Room</th><th style="text-align:center;">CU</th></tr></thead><tbody>';
    var totalMin = 0, cu = {};
    for (var m = 0; m < items.length; m++) {
        var s = items[m]; totalMin += s.durationMin || 0; if (s.courseCode) cu[s.courseCode] = s.creditUnit;
        h += '<tr><td><strong>' + esc(s.day || '—') + '</strong></td>'
            + '<td>' + esc(s.startTime) + '–' + esc(s.endTime) + '</td>'
            + '<td><strong>' + esc(s.courseCode) + '</strong></td>'
            + '<td>' + esc(s.courseName) + '</td>'
            + '<td>' + esc(s.progAbbrev) + ' <span style="color:#999;">Yr ' + esc(s.cyear) + '</span></td>'
            + '<td>' + esc(s.sessionType || '') + '</td>'
            + '<td>' + (s.room ? esc(s.room) : '<span style="color:#ccc;">—</span>') + '</td>'
            + '<td style="text-align:center;">' + s.creditUnit + '</td></tr>';
    }
    var totCU = 0; for (var key in cu) if (cu.hasOwnProperty(key)) totCU += cu[key];
    h += '</tbody></table>';
    h += '<div class="wa-detail__summary">' + items.length + ' session(s) · ' + (totalMin / 60).toFixed(1) + ' hrs/week · ' + totCU + ' credit unit(s) across distinct courses</div>';
    inner.innerHTML = h;
}

function showEmpty(msg) { document.getElementById('gridContainer').innerHTML = '<div class="wa-empty">' + esc(msg) + '</div>'; }
function esc(s) { if (s == null) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode('' + s)); return d.innerHTML; }
function printReport() { window.print(); }

function exportCSV() {
    var rows = filteredRows();
    if (!rows.length) { alert('No rows to export.'); return; }
    var csv = 'Lecturer,EMP,Department,Contract,Sessions,WeeklyHours,Courses,Programmes,Credits,Status\n';
    for (var j = 0; j < rows.length; j++) {
        var r = rows[j], st = loadBand(r.weeklyHours).label;
        csv += '"' + (r.lecturerName || '').replace(/"/g, '""') + '","' + (r.empCode || '') + '","'
            + (r.department || '').replace(/"/g, '""') + '","' + (r.contractType || '') + '",'
            + r.sessionCount + ',' + r.weeklyHours.toFixed(1) + ',' + r.courseCount + ',' + r.programmeCount + ',' + r.totalCredits + ',' + st + '\n';
    }
    var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement('a'); link.href = URL.createObjectURL(blob); link.download = 'workload_analysis.csv'; link.click();
}
</script>

</asp:Content>
