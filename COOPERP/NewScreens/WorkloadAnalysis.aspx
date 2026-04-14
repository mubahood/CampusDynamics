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

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

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
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg></div>
        <div><div class="wa-stat__val" id="statAvgCourses">—</div><div class="wa-stat__label">Avg Courses / Lecturer</div></div>
    </div>
    <div class="wa-stat wa-stat--overloaded">
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#c62828" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
        <div><div class="wa-stat__val" id="statOverloaded">—</div><div class="wa-stat__label">Overloaded (&gt;6 courses)</div></div>
    </div>
    <div class="wa-stat wa-stat--unassigned">
        <div class="wa-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></div>
        <div><div class="wa-stat__val" id="statUnassigned">—</div><div class="wa-stat__label">Unassigned Courses</div></div>
    </div>
</div>

<!-- Filter Bar -->
<div class="wa-filters">
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
/* ===== WORKLOAD ANALYSIS — CLIENT-SIDE JS =============================== */

var _allRows = [];      // full dataset from server
var _faculties = [];     // faculty dropdown data
var _programmes = [];    // programme dropdown data
var _details = {};       // lecturer detail breakdown keyed by staffCode

// ── Bootstrap ──────────────────────────────────────────────────────────────
(function () { loadData(); })();

function loadData() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'WorkloadAnalysis.aspx?ajax=data', true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) { showEmpty('Failed to load data.'); return; }
        try {
            var d = JSON.parse(xhr.responseText);
            if (!d.ok) { showEmpty(d.error || 'Unknown error'); return; }
            _allRows     = d.rows     || [];
            _faculties   = d.faculties || [];
            _programmes  = d.programmes || [];
            _details     = d.details  || {};
            populateDropdowns();
            applyFilters();
        } catch (ex) { showEmpty('Error parsing data.'); }
    };
    xhr.send();
}

function populateDropdowns() {
    var fdd = document.getElementById('ddlFaculty');
    for (var i = 0; i < _faculties.length; i++) {
        var o = document.createElement('option');
        o.value = _faculties[i].code;
        o.text  = _faculties[i].name;
        fdd.appendChild(o);
    }
    var pdd = document.getElementById('ddlProgramme');
    for (var j = 0; j < _programmes.length; j++) {
        var o2 = document.createElement('option');
        o2.value = _programmes[j].code;
        o2.text  = _programmes[j].display;
        pdd.appendChild(o2);
    }
}

function applyFilters() {
    var faculty   = document.getElementById('ddlFaculty').value;
    var programme = document.getElementById('ddlProgramme').value;
    var contract  = document.getElementById('ddlContract').value;
    var search    = (document.getElementById('txtSearch').value || '').toLowerCase();

    var filtered = [];
    for (var i = 0; i < _allRows.length; i++) {
        var r = _allRows[i];
        if (faculty && r.faculty !== faculty) continue;
        if (programme && !r.programmes_list.length) continue;
        if (programme) {
            var hasProg = false;
            for (var p = 0; p < r.programmes_list.length; p++) {
                if (r.programmes_list[p] === programme) { hasProg = true; break; }
            }
            if (!hasProg) continue;
        }
        if (contract && r.contractType !== contract) continue;
        if (search) {
            var hay = (r.lecturerName + ' ' + r.empCode + ' ' + r.department).toLowerCase();
            if (hay.indexOf(search) < 0) continue;
        }
        filtered.push(r);
    }

    renderStats(filtered);
    renderGrid(filtered);
}

function renderStats(rows) {
    var totalLecturers = 0, totalCourses = 0, overloaded = 0, unassigned = 0;
    for (var i = 0; i < rows.length; i++) {
        if (rows[i].staffCode === '0') {
            unassigned = rows[i].courseCount;
        } else {
            totalLecturers++;
            totalCourses += rows[i].courseCount;
            if (rows[i].courseCount > 6) overloaded++;
        }
    }
    var avg = totalLecturers > 0 ? (totalCourses / totalLecturers).toFixed(1) : '0';

    document.getElementById('statLecturers').textContent  = totalLecturers;
    document.getElementById('statAvgCourses').textContent  = avg;
    document.getElementById('statOverloaded').textContent  = overloaded;
    document.getElementById('statUnassigned').textContent  = unassigned;

    var sub = document.getElementById('waSubtitle');
    sub.textContent = totalLecturers + ' lecturer(s) with ' + totalCourses + ' total course assignment(s)';
    document.getElementById('gridTitle').textContent = rows.length + ' row(s)';
    document.getElementById('gridCount').textContent = 'Showing ' + rows.length + ' of ' + _allRows.length;
}

function renderGrid(rows) {
    var c = document.getElementById('gridContainer');
    if (!rows.length) { c.innerHTML = '<div class="wa-empty">No workload data found for the selected filters.</div>'; return; }

    var html = '<table class="wa-table"><thead><tr>'
        + '<th style="width:28px;"></th>'
        + '<th>Lecturer</th>'
        + '<th>EMP Code</th>'
        + '<th>Department</th>'
        + '<th>Contract</th>'
        + '<th style="text-align:center;">Courses</th>'
        + '<th style="text-align:center;">Contact Hrs</th>'
        + '<th>Programmes</th>'
        + '<th>Load</th>'
        + '<th>Status</th>'
        + '</tr></thead><tbody>';

    for (var i = 0; i < rows.length; i++) {
        var r = rows[i];
        var statusClass = 'wa-badge--normal', statusLabel = 'Normal';
        if (r.staffCode === '0') {
            statusClass = 'wa-badge--unassigned'; statusLabel = 'Unassigned';
        } else if (r.courseCount > 6) {
            statusClass = 'wa-badge--overloaded'; statusLabel = 'Overloaded';
        } else if (r.courseCount > 4) {
            statusClass = 'wa-badge--heavy'; statusLabel = 'Heavy';
        }

        var barPct = Math.min(r.courseCount * 14, 100);
        var barCls = barPct > 84 ? 'wa-bar-fill--red' : (barPct > 56 ? 'wa-bar-fill--orange' : 'wa-bar-fill--green');

        html += '<tr onclick="toggleDetail(\'' + r.staffCode + '\', this)" title="Click to expand">'
            + '<td style="text-align:center;color:#999;font-size:10px;">&#9654;</td>'
            + '<td><strong>' + esc(r.lecturerName) + '</strong></td>'
            + '<td>' + esc(r.empCode) + '</td>'
            + '<td>' + esc(r.department) + '</td>'
            + '<td>' + esc(r.contractType || '—') + '</td>'
            + '<td style="text-align:center;font-weight:700;">' + r.courseCount + '</td>'
            + '<td style="text-align:center;">' + r.scheduledHours.toFixed(1) + ' hrs</td>'
            + '<td>' + r.programmeCount + '</td>'
            + '<td><span class="wa-bar-wrap"><span class="wa-bar-fill ' + barCls + '" style="width:' + barPct + '%;"></span></span></td>'
            + '<td><span class="wa-badge ' + statusClass + '">' + statusLabel + '</span></td>'
            + '</tr>';

        // Detail expansion row (hidden initially)
        html += '<tr class="wa-detail" id="det_' + r.staffCode + '"><td colspan="10">'
            + '<div class="wa-detail__inner" id="detInner_' + r.staffCode + '">Loading...</div>'
            + '</td></tr>';
    }

    html += '</tbody></table>';
    c.innerHTML = html;
}

function toggleDetail(staffCode, tr) {
    var detRow = document.getElementById('det_' + staffCode);
    if (!detRow) return;
    var isOpen = detRow.className.indexOf('wa-detail--open') >= 0;
    // Close all
    var allDet = document.querySelectorAll('.wa-detail--open');
    for (var i = 0; i < allDet.length; i++) allDet[i].className = 'wa-detail';
    var allExp = document.querySelectorAll('.wa-row--expanded');
    for (var j = 0; j < allExp.length; j++) allExp[j].className = '';

    if (isOpen) return; // was open, now closed

    detRow.className = 'wa-detail wa-detail--open';
    tr.className = 'wa-row--expanded';

    // Render detail from pre-fetched data
    var courses = _details[staffCode] || [];
    var inner = document.getElementById('detInner_' + staffCode);
    if (!courses.length) {
        inner.innerHTML = '<div style="color:#999;font-size:10px;">No course details available.</div>';
        return;
    }

    var lecName = '';
    for (var k = 0; k < _allRows.length; k++) {
        if (_allRows[k].staffCode === staffCode) { lecName = _allRows[k].lecturerName; break; }
    }

    var h = '<div class="wa-detail__header">' + esc(lecName) + ' — Course Breakdown</div>';
    h += '<table class="wa-detail__table"><thead><tr><th>Course</th><th>Name</th><th>Programme</th><th>Day</th><th>Time</th><th>CU</th></tr></thead><tbody>';

    var totalCU = 0, totalHrs = 0, schedCount = 0;
    for (var m = 0; m < courses.length; m++) {
        var c = courses[m];
        totalCU += c.creditUnit;
        var timeTxt = '—';
        if (c.day && c.day !== '-') {
            timeTxt = c.startTime + '–' + c.endTime;
            schedCount++;
            // compute hours
            var parts1 = (c.startTime || '').split(':'), parts2 = (c.endTime || '').split(':');
            if (parts1.length === 2 && parts2.length === 2) {
                totalHrs += ((parseInt(parts2[0],10)*60+parseInt(parts2[1],10)) - (parseInt(parts1[0],10)*60+parseInt(parts1[1],10))) / 60;
            }
        }
        h += '<tr><td><strong>' + esc(c.courseCode) + '</strong></td>'
            + '<td>' + esc(c.courseName) + '</td>'
            + '<td>' + esc(c.progAbbrev) + ' Yr ' + c.cyear + '</td>'
            + '<td>' + (c.day && c.day !== '-' ? esc(c.day) : '<span style="color:#ccc;">—</span>') + '</td>'
            + '<td>' + timeTxt + '</td>'
            + '<td style="text-align:center;">' + c.creditUnit + '</td>'
            + '</tr>';
    }
    h += '</tbody></table>';
    h += '<div class="wa-detail__summary">Total: ' + courses.length + ' course(s) | '
        + totalCU + ' Credit Units | ' + totalHrs.toFixed(1) + ' Scheduled Hours | '
        + schedCount + ' of ' + courses.length + ' scheduled</div>';

    inner.innerHTML = h;
}

function showEmpty(msg) {
    document.getElementById('gridContainer').innerHTML = '<div class="wa-empty">' + esc(msg) + '</div>';
}

function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }

function printReport() { window.print(); }

function exportCSV() {
    var faculty   = document.getElementById('ddlFaculty').value;
    var programme = document.getElementById('ddlProgramme').value;
    var contract  = document.getElementById('ddlContract').value;
    var search    = (document.getElementById('txtSearch').value || '').toLowerCase();

    var rows = [];
    for (var i = 0; i < _allRows.length; i++) {
        var r = _allRows[i];
        if (faculty && r.faculty !== faculty) continue;
        if (programme) {
            var has = false;
            for (var p = 0; p < r.programmes_list.length; p++) { if (r.programmes_list[p] === programme) { has = true; break; } }
            if (!has) continue;
        }
        if (contract && r.contractType !== contract) continue;
        if (search && (r.lecturerName + ' ' + r.empCode + ' ' + r.department).toLowerCase().indexOf(search) < 0) continue;
        rows.push(r);
    }

    var csv = 'Lecturer,EMP Code,Department,Contract,Courses,Contact Hrs,Programmes,Status\n';
    for (var j = 0; j < rows.length; j++) {
        var r2 = rows[j];
        var st = r2.staffCode === '0' ? 'Unassigned' : (r2.courseCount > 6 ? 'Overloaded' : (r2.courseCount > 4 ? 'Heavy' : 'Normal'));
        csv += '"' + (r2.lecturerName||'').replace(/"/g,'""') + '",'
            + '"' + (r2.empCode||'') + '",'
            + '"' + (r2.department||'').replace(/"/g,'""') + '",'
            + '"' + (r2.contractType||'') + '",'
            + r2.courseCount + ','
            + r2.scheduledHours.toFixed(1) + ','
            + r2.programmeCount + ','
            + st + '\n';
    }

    var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'workload_analysis.csv';
    link.click();
}
</script>

</asp:Content>
