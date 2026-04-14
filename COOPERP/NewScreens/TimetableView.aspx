<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TimetableView.aspx.cs" Inherits="COOPERP_NewScreens_TimetableView" Title="Timetable View - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== TIMETABLE VIEW PAGE (prefix: tv-) ================================ */

/* Header */
.tv-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.tv-header__left { display: flex; align-items: center; gap: 10px; }
.tv-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.tv-header__icon svg { color: #fff; }
.tv-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.tv-header__sub   { font-size: 10px; color: #888; margin-top: 1px; }

/* Stats Row */
.tv-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.tv-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.tv-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.tv-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.tv-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.tv-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.tv-stat--total    { --stat-c:#174DA4; } .tv-stat--total .tv-stat__icon    { background:#e8f0fc; } .tv-stat--total .tv-stat__val    { color:#174DA4; }
.tv-stat--sched    { --stat-c:#2e7d32; } .tv-stat--sched .tv-stat__icon    { background:#e6f4ea; } .tv-stat--sched .tv-stat__val    { color:#2e7d32; }
.tv-stat--unsched  { --stat-c:#e65100; } .tv-stat--unsched .tv-stat__icon  { background:#fce8de; } .tv-stat--unsched .tv-stat__val  { color:#e65100; }
.tv-stat--rooms    { --stat-c:#6a1b9a; } .tv-stat--rooms .tv-stat__icon    { background:#f3e5f5; } .tv-stat--rooms .tv-stat__val    { color:#6a1b9a; }

/* Filter bar */
.tv-filters { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; align-items: flex-end; }
.tv-filters__group { display: flex; flex-direction: column; gap: 2px; }
.tv-filters__label { font-size: 9px; font-weight: 600; text-transform: uppercase; letter-spacing: .3px; color: #666; }
.tv-filters select { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; min-width: 130px; }
.tv-filters select:focus { border-color: #174DA4; outline: none; }

/* Buttons */
.tv-btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.tv-btn--primary { background: #05275C; color: #fff; } .tv-btn--primary:hover { background: #174DA4; }
.tv-btn--ghost   { background: #fff; border: 1px solid #cdd3de; color: #555; } .tv-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.tv-btn--active  { background: #174DA4; color: #fff; border: 1px solid #174DA4; }

/* View mode tabs */
.tv-tabs { display: flex; gap: 0; margin-bottom: 12px; border: 1px solid #cdd3de; width: fit-content; }
.tv-tabs__btn { padding: 6px 14px; font-size: 10px; font-weight: 600; border: none; cursor: pointer; background: #fff; color: #555; border-right: 1px solid #cdd3de; }
.tv-tabs__btn:last-child { border-right: none; }
.tv-tabs__btn--active { background: #174DA4; color: #fff; }

/* Warning banner */
.tv-warn { background: #fff3e0; border: 1px solid #ffe0b2; padding: 8px 14px; font-size: 11px; color: #e65100; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
.tv-warn svg { flex-shrink: 0; }

/* Card wrapper */
.tv-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.tv-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.tv-card__title  { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* ===== TIMETABLE GRID ===== */
.tv-grid { width: 100%; border-collapse: collapse; table-layout: fixed; }
.tv-grid th { background: #05275C; color: #fff; padding: 8px 6px; text-align: center; font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: .3px; }
.tv-grid th.tv-grid__time-col { width: 60px; background: #03193d; }
.tv-grid td { border: 1px solid #e8ebef; padding: 0; height: 24px; vertical-align: top; position: relative; }
.tv-grid td.tv-grid__time { background: #f8f9fb; text-align: right; padding: 3px 6px; font-size: 9px; color: #888; font-weight: 600; font-variant-numeric: tabular-nums; border-right: 2px solid #e0e5ed; }

/* Lecture blocks */
.tv-block { position: absolute; left: 2px; right: 2px; top: 1px; border-radius: 3px; padding: 4px 6px; overflow: hidden; z-index: 1; cursor: pointer; border-left: 3px solid rgba(0,0,0,.15); transition: box-shadow .15s; }
.tv-block:hover { box-shadow: 0 2px 8px rgba(0,0,0,.18); z-index: 5; }
.tv-block__course { font-size: 10px; font-weight: 700; color: #fff; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tv-block__lecturer { font-size: 9px; color: rgba(255,255,255,.85); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tv-block__room { font-size: 8px; color: rgba(255,255,255,.7); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tv-block__time { font-size: 8px; color: rgba(255,255,255,.6); }

/* Block color palette */
.tv-color-0 { background: #1565c0; } .tv-color-1 { background: #2e7d32; } .tv-color-2 { background: #6a1b9a; }
.tv-color-3 { background: #c62828; } .tv-color-4 { background: #00838f; } .tv-color-5 { background: #4e342e; }
.tv-color-6 { background: #ef6c00; } .tv-color-7 { background: #283593; } .tv-color-8 { background: #558b2f; }
.tv-color-9 { background: #ad1457; } .tv-color-10 { background: #00695c; } .tv-color-11 { background: #37474f; }

/* Compact mode */
.tv-grid--compact .tv-block__lecturer, .tv-grid--compact .tv-block__room, .tv-grid--compact .tv-block__time { display: none; }
.tv-grid--compact .tv-block { padding: 2px 4px; }
.tv-grid--compact .tv-block__course { font-size: 9px; }

/* Unscheduled list */
.tv-unsched-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.tv-unsched-table th { background: #f5f7fa; padding: 8px 12px; text-align: left; font-size: 10px; text-transform: uppercase; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; }
.tv-unsched-table td { padding: 7px 12px; border-bottom: 1px solid #f0f2f5; }
.tv-unsched-table tbody tr:hover { background: #f0f4ff; }

/* Tooltip */
.tv-tooltip { display: none; position: fixed; background: #1a1a2e; color: #fff; padding: 8px 12px; border-radius: 4px; font-size: 10px; z-index: 999; max-width: 220px; box-shadow: 0 4px 12px rgba(0,0,0,.3); }
.tv-tooltip__row { margin-bottom: 3px; }
.tv-tooltip__label { color: rgba(255,255,255,.6); }

/* Empty / loading */
.tv-empty { text-align: center; padding: 40px 20px; color: #999; font-size: 12px; }
.tv-loading { text-align: center; padding: 30px; font-size: 11px; color: #999; }

/* Print */
@media print {
    .tv-filters, .tv-btn, .tv-tabs, .tv-warn, .tv-tooltip { display: none !important; }
    .tv-grid th { background: #333 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .tv-block { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .tv-grid { font-size: 8px; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<!-- Page Header -->
<div class="tv-header">
    <div class="tv-header__left">
        <div class="tv-header__icon">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        </div>
        <div>
            <div class="tv-header__title">Timetable View</div>
            <div class="tv-header__sub" id="tvSubtitle">Loading...</div>
        </div>
    </div>
    <div style="display:flex;gap:6px;">
        <button class="tv-btn tv-btn--ghost" onclick="window.print()">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print
        </button>
    </div>
</div>

<!-- Stats Row -->
<div class="tv-stats">
    <div class="tv-stat tv-stat--total">
        <div class="tv-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg></div>
        <div><div class="tv-stat__val" id="statTotal">—</div><div class="tv-stat__label">Total Allocations</div></div>
    </div>
    <div class="tv-stat tv-stat--sched">
        <div class="tv-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
        <div><div class="tv-stat__val" id="statScheduled">—</div><div class="tv-stat__label">Scheduled</div></div>
    </div>
    <div class="tv-stat tv-stat--unsched">
        <div class="tv-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
        <div><div class="tv-stat__val" id="statUnscheduled">—</div><div class="tv-stat__label">Unscheduled</div></div>
    </div>
    <div class="tv-stat tv-stat--rooms">
        <div class="tv-stat__icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6a1b9a" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
        <div><div class="tv-stat__val" id="statRooms">—</div><div class="tv-stat__label">Rooms Used</div></div>
    </div>
</div>

<!-- Filter Bar -->
<div class="tv-filters">
    <div class="tv-filters__group">
        <span class="tv-filters__label">View Mode</span>
        <select id="ddlViewMode" onchange="onViewModeChange()">
            <option value="programme" selected>By Programme</option>
            <option value="lecturer">By Lecturer</option>
            <option value="room">By Room</option>
        </select>
    </div>
    <div class="tv-filters__group" id="grpProgramme">
        <span class="tv-filters__label">Programme</span>
        <select id="ddlProgramme" onchange="onFilterChange()"><option value="">Select...</option></select>
    </div>
    <div class="tv-filters__group" id="grpStudyYear">
        <span class="tv-filters__label">Study Year</span>
        <select id="ddlStudyYear" onchange="onFilterChange()">
            <option value="">All</option>
            <option value="1">Year 1</option>
            <option value="2">Year 2</option>
            <option value="3">Year 3</option>
            <option value="4">Year 4</option>
            <option value="5">Year 5</option>
        </select>
    </div>
    <div class="tv-filters__group" id="grpEntryYear" style="display:none;">
        <span class="tv-filters__label">Entry Year</span>
        <select id="ddlEntryYear" onchange="onFilterChange()"><option value="">All</option></select>
    </div>
    <div class="tv-filters__group" id="grpSession" style="display:none;">
        <span class="tv-filters__label">Session</span>
        <select id="ddlSession" onchange="onFilterChange()">
            <option value="">All</option>
            <option value="DAY">Day</option>
            <option value="WEEKEND">Weekend</option>
            <option value="EVENING">Evening</option>
        </select>
    </div>
    <div class="tv-filters__group" id="grpLecturer" style="display:none;">
        <span class="tv-filters__label">Lecturer</span>
        <select id="ddlLecturer" onchange="onFilterChange()"><option value="">Select...</option></select>
    </div>
    <div class="tv-filters__group" id="grpRoom" style="display:none;">
        <span class="tv-filters__label">Room</span>
        <select id="ddlRoom" onchange="onFilterChange()"><option value="">Select...</option></select>
    </div>
    <div class="tv-filters__group">
        <span class="tv-filters__label">Display</span>
        <select id="ddlDisplay" onchange="onDisplayChange()">
            <option value="detailed">Detailed</option>
            <option value="compact">Compact</option>
        </select>
    </div>
</div>

<!-- Warning banner (shown when many are unscheduled) -->
<div class="tv-warn" id="warnBanner" style="display:none;">
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    <span id="warnText"></span>
</div>

<!-- Timetable Grid Card -->
<div class="tv-card">
    <div class="tv-card__header">
        <div class="tv-card__title">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            Weekly Timetable — <span id="gridTitle">select a filter</span>
        </div>
    </div>
    <div id="gridContainer" style="overflow-x:auto;">
        <div class="tv-loading">Select a programme, lecturer, or room to view the timetable.</div>
    </div>
</div>

<!-- Unscheduled Courses Card -->
<div class="tv-card" id="unschedCard" style="display:none;">
    <div class="tv-card__header">
        <div class="tv-card__title">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Unscheduled Allocations — <span id="unschedCount">0</span>
        </div>
    </div>
    <div id="unschedContainer"></div>
</div>

<!-- Tooltip element -->
<div class="tv-tooltip" id="tooltip"></div>

<script type="text/javascript">
/* ===== TIMETABLE VIEW — CLIENT-SIDE JS ================================== */

var _data = null;         // full dataset from server
var DAYS = ['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'];
var DAY_LABELS = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
var START_HOUR = 7, END_HOUR = 20;
var SLOT_MINUTES = 30;
var SLOT_HEIGHT = 24;     // px per 30-min slot (matches CSS td height)
var _colorMap = {};
var _colorIdx = 0;

// ── Bootstrap ──────────────────────────────────────────────────────────────
(function () { loadDropdowns(); })();

function loadDropdowns() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'TimetableView.aspx?ajax=dropdowns', true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) return;
        try {
            var d = JSON.parse(xhr.responseText);
            if (!d.ok) return;
            populateSelect('ddlProgramme', d.programmes, 'code', 'display');
            populateSelect('ddlLecturer', d.lecturers, 'id', 'display');
            populateSelect('ddlRoom', d.rooms, 'id', 'display');
            document.getElementById('tvSubtitle').textContent = d.acadYear + ' — Semester ' + d.semester;
        } catch (ex) { }
    };
    xhr.send();
}

function populateSelect(id, items, valKey, textKey) {
    var sel = document.getElementById(id);
    for (var i = 0; i < items.length; i++) {
        var o = document.createElement('option');
        o.value = items[i][valKey];
        o.text  = items[i][textKey];
        sel.appendChild(o);
    }
}

function onViewModeChange() {
    var mode = document.getElementById('ddlViewMode').value;
    document.getElementById('grpProgramme').style.display  = (mode === 'programme') ? '' : 'none';
    document.getElementById('grpStudyYear').style.display   = (mode === 'programme') ? '' : 'none';
    document.getElementById('grpEntryYear').style.display   = (mode === 'programme') ? '' : 'none';
    document.getElementById('grpSession').style.display     = (mode === 'programme') ? '' : 'none';
    document.getElementById('grpLecturer').style.display    = (mode === 'lecturer')  ? '' : 'none';
    document.getElementById('grpRoom').style.display        = (mode === 'room')      ? '' : 'none';
    onFilterChange();
}

function onFilterChange() {
    var mode = document.getElementById('ddlViewMode').value;
    var qs = 'ajax=timetable&mode=' + mode;

    if (mode === 'programme') {
        var prog = document.getElementById('ddlProgramme').value;
        if (!prog) { showPlaceholder(); return; }
        qs += '&prog=' + encodeURIComponent(prog);
        var yr = document.getElementById('ddlStudyYear').value;
        if (yr) qs += '&yr=' + yr;
        var ey = document.getElementById('ddlEntryYear').value;
        if (ey) qs += '&entry=' + encodeURIComponent(ey);
        var sess = document.getElementById('ddlSession').value;
        if (sess) qs += '&sess=' + encodeURIComponent(sess);
    } else if (mode === 'lecturer') {
        var lec = document.getElementById('ddlLecturer').value;
        if (!lec) { showPlaceholder(); return; }
        qs += '&staff=' + encodeURIComponent(lec);
    } else if (mode === 'room') {
        var rm = document.getElementById('ddlRoom').value;
        if (!rm) { showPlaceholder(); return; }
        qs += '&room=' + encodeURIComponent(rm);
    }

    document.getElementById('gridContainer').innerHTML = '<div class="tv-loading">Loading timetable...</div>';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'TimetableView.aspx?' + qs, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200) { showError('Failed to load timetable.'); return; }
        try {
            var d = JSON.parse(xhr.responseText);
            if (!d.ok) { showError(d.error || 'Unknown error'); return; }
            _data = d;
            renderAll();
        } catch (ex) { showError('Error parsing data: ' + ex.message); }
    };
    xhr.send();
}

function onDisplayChange() {
    var grid = document.querySelector('.tv-grid');
    if (!grid) return;
    var compact = document.getElementById('ddlDisplay').value === 'compact';
    if (compact) grid.className = 'tv-grid tv-grid--compact';
    else grid.className = 'tv-grid';
}

function renderAll() {
    if (!_data) return;

    // Stats
    document.getElementById('statTotal').textContent = _data.totalAllocations || 0;
    document.getElementById('statScheduled').textContent = _data.scheduledCount || 0;
    document.getElementById('statUnscheduled').textContent = _data.unscheduledCount || 0;
    document.getElementById('statRooms').textContent = _data.roomCount || 0;
    document.getElementById('gridTitle').textContent = _data.title || '';

    // Warning banner
    var totalA = _data.totalAllocations || 0;
    var schedA = _data.scheduledCount || 0;
    var unschedA = _data.unscheduledCount || 0;
    var warnBanner = document.getElementById('warnBanner');
    if (unschedA > 0 && totalA > 0) {
        var pct = Math.round((unschedA / totalA) * 100);
        document.getElementById('warnText').textContent = schedA + ' of ' + totalA + ' allocations have a schedule (' + pct + '% unscheduled). Unscheduled courses are listed below.';
        warnBanner.style.display = '';
    } else {
        warnBanner.style.display = 'none';
    }

    // Timetable grid
    renderGrid(_data.scheduled || []);

    // Unscheduled list
    renderUnscheduled(_data.unscheduled || []);

    onDisplayChange();
}

function renderGrid(items) {
    var container = document.getElementById('gridContainer');
    if (!items.length) {
        container.innerHTML = '<div class="tv-empty">No scheduled lectures found for the selected filters.</div>';
        return;
    }

    // Reset color map
    _colorMap = {}; _colorIdx = 0;

    // Build slot map: slots[dayIdx][slotIdx] = [{item, rowspan}]
    var totalSlots = (END_HOUR - START_HOUR) * (60 / SLOT_MINUTES);
    var slots = [];
    for (var d = 0; d < DAYS.length; d++) {
        slots[d] = [];
        for (var s = 0; s < totalSlots; s++) slots[d][s] = [];
    }

    // Populate
    for (var i = 0; i < items.length; i++) {
        var it = items[i];
        var dayIdx = -1;
        for (var dd = 0; dd < DAYS.length; dd++) {
            if (DAYS[dd] === (it.day || '').toUpperCase()) { dayIdx = dd; break; }
        }
        if (dayIdx < 0) continue;

        var startSlot = timeToSlot(it.startTime);
        var endSlot   = timeToSlot(it.endTime);
        if (startSlot < 0 || endSlot <= startSlot) continue;

        var span = endSlot - startSlot;
        slots[dayIdx][startSlot].push({ item: it, rowspan: span });
    }

    // Render HTML table
    var html = '<table class="tv-grid"><thead><tr><th class="tv-grid__time-col">Time</th>';
    for (var dh = 0; dh < DAYS.length; dh++) html += '<th>' + DAY_LABELS[dh] + '</th>';
    html += '</tr></thead><tbody>';

    // Track which cells are "occupied" by a rowspan
    var occupied = [];
    for (var od = 0; od < DAYS.length; od++) {
        occupied[od] = [];
        for (var os = 0; os < totalSlots; os++) occupied[od][os] = false;
    }

    for (var si = 0; si < totalSlots; si++) {
        var timeLabel = slotToTime(si);
        html += '<tr><td class="tv-grid__time">' + timeLabel + '</td>';

        for (var di = 0; di < DAYS.length; di++) {
            if (occupied[di][si]) continue; // skip — part of a rowspan above

            var cellItems = slots[di][si];
            if (cellItems.length > 0) {
                // Use the max rowspan from all items in this cell
                var maxSpan = 1;
                for (var ci = 0; ci < cellItems.length; ci++) {
                    if (cellItems[ci].rowspan > maxSpan) maxSpan = cellItems[ci].rowspan;
                }

                html += '<td rowspan="' + maxSpan + '" style="position:relative;height:' + (maxSpan * SLOT_HEIGHT) + 'px;">';

                // Render each block
                var blockWidth = cellItems.length > 1 ? Math.floor(95 / cellItems.length) : 96;
                for (var bi = 0; bi < cellItems.length; bi++) {
                    var b = cellItems[bi].item;
                    var colorClass = getColor(b.courseCode);
                    var leftPct = cellItems.length > 1 ? (bi * blockWidth + 1) + '%' : '2px';
                    var widthPct = cellItems.length > 1 ? blockWidth + '%' : 'calc(100% - 4px)';
                    var heightPx = (cellItems[bi].rowspan * SLOT_HEIGHT - 3) + 'px';

                    html += '<div class="tv-block ' + colorClass + '" '
                        + 'style="left:' + leftPct + ';width:' + widthPct + ';height:' + heightPx + ';" '
                        + 'onmouseover="showTip(event,this)" onmouseout="hideTip()" '
                        + 'data-course="' + esc(b.courseCode) + '" '
                        + 'data-name="' + esc(b.courseName) + '" '
                        + 'data-lecturer="' + esc(b.lecturerName) + '" '
                        + 'data-room="' + esc(b.roomName) + '" '
                        + 'data-time="' + esc(b.startTime) + ' – ' + esc(b.endTime) + '" '
                        + 'data-prog="' + esc(b.progAbbrev) + ' Yr ' + b.cyear + '">'
                        + '<div class="tv-block__course">' + esc(b.courseCode) + '</div>'
                        + '<div class="tv-block__lecturer">' + esc(b.lecturerName) + '</div>'
                        + '<div class="tv-block__room">' + esc(b.roomName) + '</div>'
                        + '</div>';
                }

                html += '</td>';

                // Mark occupied cells below
                for (var oc = si + 1; oc < si + maxSpan && oc < totalSlots; oc++) {
                    occupied[di][oc] = true;
                }
            } else {
                html += '<td></td>';
            }
        }
        html += '</tr>';
    }

    html += '</tbody></table>';
    container.innerHTML = html;
}

function renderUnscheduled(items) {
    var card = document.getElementById('unschedCard');
    var container = document.getElementById('unschedContainer');
    document.getElementById('unschedCount').textContent = items.length;

    if (!items.length) { card.style.display = 'none'; return; }
    card.style.display = '';

    var html = '<table class="tv-unsched-table"><thead><tr>'
        + '<th>Course</th><th>Name</th><th>Lecturer</th><th>Programme</th><th>Year</th><th>Session</th>'
        + '</tr></thead><tbody>';

    for (var i = 0; i < items.length; i++) {
        var u = items[i];
        html += '<tr><td><strong>' + esc(u.courseCode) + '</strong></td>'
            + '<td>' + esc(u.courseName) + '</td>'
            + '<td>' + esc(u.lecturerName) + '</td>'
            + '<td>' + esc(u.progAbbrev) + '</td>'
            + '<td>' + u.cyear + '</td>'
            + '<td>' + esc(u.session) + '</td></tr>';
    }
    html += '</tbody></table>';
    container.innerHTML = html;
}

// ── Helpers ────────────────────────────────────────────────────────────────

function timeToSlot(t) {
    if (!t) return -1;
    var parts = t.split(':');
    if (parts.length < 2) return -1;
    var h = parseInt(parts[0], 10), m = parseInt(parts[1], 10);
    return Math.floor(((h * 60 + m) - (START_HOUR * 60)) / SLOT_MINUTES);
}

function slotToTime(s) {
    var totalMin = START_HOUR * 60 + s * SLOT_MINUTES;
    var h = Math.floor(totalMin / 60), m = totalMin % 60;
    return (h < 10 ? '0' : '') + h + ':' + (m < 10 ? '0' : '') + m;
}

function getColor(courseCode) {
    if (!courseCode) return 'tv-color-0';
    if (typeof _colorMap[courseCode] === 'undefined') {
        _colorMap[courseCode] = 'tv-color-' + (_colorIdx % 12);
        _colorIdx++;
    }
    return _colorMap[courseCode];
}

function showTip(evt, el) {
    var tip = document.getElementById('tooltip');
    tip.innerHTML =
        '<div class="tv-tooltip__row"><span class="tv-tooltip__label">Course:</span> ' + (el.getAttribute('data-course')||'') + ' — ' + (el.getAttribute('data-name')||'') + '</div>'
        + '<div class="tv-tooltip__row"><span class="tv-tooltip__label">Lecturer:</span> ' + (el.getAttribute('data-lecturer')||'') + '</div>'
        + '<div class="tv-tooltip__row"><span class="tv-tooltip__label">Room:</span> ' + (el.getAttribute('data-room')||'') + '</div>'
        + '<div class="tv-tooltip__row"><span class="tv-tooltip__label">Time:</span> ' + (el.getAttribute('data-time')||'') + '</div>'
        + '<div class="tv-tooltip__row"><span class="tv-tooltip__label">Programme:</span> ' + (el.getAttribute('data-prog')||'') + '</div>';
    tip.style.display = 'block';
    tip.style.left = (evt.clientX + 12) + 'px';
    tip.style.top  = (evt.clientY + 12) + 'px';
}

function hideTip() { document.getElementById('tooltip').style.display = 'none'; }

function showPlaceholder() {
    document.getElementById('gridContainer').innerHTML = '<div class="tv-loading">Select a programme, lecturer, or room to view the timetable.</div>';
    document.getElementById('unschedCard').style.display = 'none';
    document.getElementById('warnBanner').style.display = 'none';
}

function showError(msg) {
    document.getElementById('gridContainer').innerHTML = '<div class="tv-empty">' + esc(msg) + '</div>';
}

function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }
</script>

</asp:Content>
