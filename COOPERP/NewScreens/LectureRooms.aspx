<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LectureRooms.aspx.cs" Inherits="COOPERP_NewScreens_LectureRooms" Title="Lecture Rooms - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== LECTURE ROOMS PAGE (prefix: lr-) ================================= */

/* Stats Row */
.lr-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.lr-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.lr-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.lr-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.lr-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.lr-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.lr-stat--total   { --stat-c: #174DA4; } .lr-stat--total .lr-stat__icon   { background: #e8f0fc; } .lr-stat--total .lr-stat__val   { color: #174DA4; }
.lr-stat--cap     { --stat-c: #00897b; } .lr-stat--cap .lr-stat__icon     { background: #e0f2f1; } .lr-stat--cap .lr-stat__val     { color: #00695c; }
.lr-stat--campus1 { --stat-c: #1565c0; } .lr-stat--campus1 .lr-stat__icon { background: #e3f2fd; } .lr-stat--campus1 .lr-stat__val { color: #1565c0; }
.lr-stat--campus2 { --stat-c: #6a1b9a; } .lr-stat--campus2 .lr-stat__icon { background: #f3e5f5; } .lr-stat--campus2 .lr-stat__val { color: #6a1b9a; }

/* Page header */
.lr-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.lr-header__left { display: flex; align-items: center; gap: 10px; }
.lr-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.lr-header__icon svg { color: #fff; }
.lr-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.lr-header__sub   { font-size: 10px; color: #888; margin-top: 1px; }

/* Toolbar / filters */
.lr-toolbar { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; align-items: center; }
.lr-toolbar select, .lr-toolbar input[type=text] { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; }
.lr-toolbar select:focus, .lr-toolbar input:focus { border-color: #174DA4; outline: none; }

/* Card wrapper */
.lr-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.lr-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.lr-card__title  { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Table */
.lr-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.lr-table th { background: #f5f7fa; padding: 9px 12px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.lr-table td { padding: 8px 12px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; vertical-align: middle; }
.lr-table tbody tr:hover { background: #f0f4ff; }
.lr-cap-bar { display: inline-block; height: 6px; background: #174DA4; border-radius: 2px; vertical-align: middle; margin-right: 4px; }

/* Buttons */
.lr-btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.lr-btn--primary { background: #05275C; color: #fff; } .lr-btn--primary:hover { background: #174DA4; }
.lr-btn--ghost   { background: #fff; border: 1px solid #cdd3de; color: #555; } .lr-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.lr-btn--danger  { background: #c62828; color: #fff; } .lr-btn--danger:hover  { background: #d32f2f; }
.lr-btn--warning { background: #e65100; color: #fff; } .lr-btn--warning:hover { background: #bf360c; }
.lr-btn--sm { padding: 4px 10px; font-size: 10px; }
.lr-btn:disabled { opacity: .5; cursor: not-allowed; }

/* Modal */
.lr-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,.35); z-index: 9000; }
.lr-modal   { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #fff; border: 1px solid #cdd3de; width: 460px; max-height: 90vh; overflow-y: auto; z-index: 9001; box-shadow: 0 12px 40px rgba(0,0,0,.15); display: none; }
.lr-modal__header { padding: 12px 16px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.lr-modal__title  { font-size: 13px; font-weight: 700; color: #05275C; }
.lr-modal__close  { background: none; border: none; cursor: pointer; padding: 4px; font-size: 18px; color: #888; line-height: 1; } .lr-modal__close:hover { color: #c62828; }
.lr-modal__body   { padding: 16px; }
.lr-modal__footer { padding: 12px 16px; border-top: 1px solid #e0e5ed; background: #f8f9fb; display: flex; justify-content: flex-end; gap: 8px; }

/* Delete confirm modal */
.lr-del-modal { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #fff; border: 1px solid #cdd3de; width: 400px; z-index: 9002; box-shadow: 0 12px 40px rgba(0,0,0,.2); display: none; }
.lr-del-modal__header { padding: 12px 16px; border-bottom: 1px solid #e0e5ed; background: #fff3f3; }
.lr-del-modal__title  { font-size: 13px; font-weight: 700; color: #c62828; }
.lr-del-modal__body   { padding: 16px; font-size: 12px; color: #333; }
.lr-del-modal__footer { padding: 12px 16px; border-top: 1px solid #e0e5ed; display: flex; justify-content: flex-end; gap: 8px; }

/* Form */
.lr-form-group { margin-bottom: 12px; }
.lr-form-group label { display: block; font-size: 10px; font-weight: 600; color: #555; text-transform: uppercase; letter-spacing: .3px; margin-bottom: 4px; }
.lr-form-group input, .lr-form-group select { width: 100%; padding: 7px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; box-sizing: border-box; }
.lr-form-group input:focus, .lr-form-group select:focus { border-color: #174DA4; outline: none; }
.lr-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.lr-form-err  { font-size: 10px; color: #c62828; margin-top: 3px; display: none; }

/* Toast */
.lr-toast { position: fixed; bottom: 20px; right: 20px; padding: 10px 18px; font-size: 12px; font-weight: 600; color: #fff; z-index: 10000; display: none; box-shadow: 0 4px 12px rgba(0,0,0,.15); min-width: 220px; }
.lr-toast--ok  { background: #2e7d32; }
.lr-toast--err { background: #c62828; }

/* Empty / loading states */
.lr-empty   { text-align: center; color: #999; padding: 30px; font-size: 12px; }
.lr-loading { text-align: center; color: #174DA4; padding: 20px; font-size: 11px; }

/* Campus badge */
.lr-campus { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; }
.lr-campus--1 { background: #e3f2fd; color: #1565c0; }
.lr-campus--2 { background: #f3e5f5; color: #6a1b9a; }
.lr-campus--0 { background: #f1f3f4; color: #555; }

@media (max-width: 768px) {
    .lr-stats { grid-template-columns: repeat(2, 1fr); }
    .lr-modal, .lr-del-modal { width: 95%; }
    .lr-form-row { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="lr-header">
    <div class="lr-header__left">
        <div class="lr-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
        </div>
        <div>
            <div class="lr-header__title">Lecture Rooms</div>
            <div class="lr-header__sub">Manage rooms and their seating capacities across all campuses</div>
        </div>
    </div>
    <div>
        <button type="button" class="lr-btn lr-btn--primary" onclick="openAdd()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Add Room
        </button>
    </div>
</div>

<!-- Stats -->
<div class="lr-stats" id="lrStats">
    <div class="lr-stat lr-stat--total">
        <div class="lr-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path></svg>
        </div>
        <div><div class="lr-stat__val" id="statTotal">—</div><div class="lr-stat__label">Total Rooms</div></div>
    </div>
    <div class="lr-stat lr-stat--cap">
        <div class="lr-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00897b" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
        </div>
        <div><div class="lr-stat__val" id="statCap">—</div><div class="lr-stat__label">Total Seats</div></div>
    </div>
    <div class="lr-stat lr-stat--campus1">
        <div class="lr-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1565c0" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
        </div>
        <div><div class="lr-stat__val" id="statC1">—</div><div class="lr-stat__label">Kakeeka Rooms</div></div>
    </div>
    <div class="lr-stat lr-stat--campus2">
        <div class="lr-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6a1b9a" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
        </div>
        <div><div class="lr-stat__val" id="statC2">—</div><div class="lr-stat__label">Kirumba Rooms</div></div>
    </div>
</div>

<!-- Toolbar -->
<div class="lr-toolbar">
    <input type="text" id="txtSearch" placeholder="Search by room name…" oninput="filterTable()" style="min-width:180px;" />
    <select id="ddlFilterCampus" onchange="filterTable()">
        <option value="">All Campuses</option>
    </select>
    <span id="spnCount" style="font-size:10px;color:#888;margin-left:4px;"></span>
</div>

<!-- Rooms Table -->
<div class="lr-card">
    <div class="lr-card__header">
        <div class="lr-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
            Room Inventory
        </div>
        <span style="font-size:10px;color:#888;">Click a row's actions to edit or delete</span>
    </div>
    <div style="overflow-x:auto;">
        <table class="lr-table" id="tblRooms">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Room Name</th>
                    <th>Campus</th>
                    <th>Capacity</th>
                    <th>Used (Current Sem)</th>
                    <th style="width:110px;">Actions</th>
                </tr>
            </thead>
            <tbody id="tbdRooms">
                <tr><td colspan="6" class="lr-loading">Loading rooms…</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── Add / Edit Modal ─────────────────────────────────────────────── -->
<div class="lr-overlay" id="lrOverlay" onclick="closeModal()"></div>
<div class="lr-modal" id="lrModal">
    <div class="lr-modal__header">
        <div class="lr-modal__title" id="lrModalTitle">Add Lecture Room</div>
        <button type="button" class="lr-modal__close" onclick="closeModal()">&times;</button>
    </div>
    <div class="lr-modal__body">
        <input type="hidden" id="hdnEditId" value="" />
        <div class="lr-form-group">
            <label>Room Name <span style="color:#c62828">*</span></label>
            <input type="text" id="txtRoomName" maxlength="65" placeholder="e.g. CHWA 1, LAB 3, MAIN HALL" />
            <div class="lr-form-err" id="errName">Room name is required.</div>
        </div>
        <div class="lr-form-row">
            <div class="lr-form-group">
                <label>Capacity (seats) <span style="color:#c62828">*</span></label>
                <input type="number" id="txtCapacity" min="1" max="2000" placeholder="e.g. 120" />
                <div class="lr-form-err" id="errCap">Capacity must be a positive number.</div>
            </div>
            <div class="lr-form-group">
                <label>Campus <span style="color:#c62828">*</span></label>
                <select id="ddlCampus">
                    <option value="">-- Select Campus --</option>
                </select>
                <div class="lr-form-err" id="errCampus">Campus is required.</div>
            </div>
        </div>
    </div>
    <div class="lr-modal__footer">
        <button type="button" class="lr-btn lr-btn--ghost" onclick="closeModal()">Cancel</button>
        <button type="button" class="lr-btn lr-btn--primary" id="btnSave" onclick="saveRoom()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Save Room
        </button>
    </div>
</div>

<!-- ── Delete Confirm Modal ─────────────────────────────────────────── -->
<div class="lr-del-modal" id="lrDelModal">
    <div class="lr-del-modal__header">
        <div class="lr-del-modal__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>
            Confirm Deletion
        </div>
    </div>
    <div class="lr-del-modal__body" id="lrDelMsg">Are you sure you want to delete this room?</div>
    <div class="lr-del-modal__footer">
        <button type="button" class="lr-btn lr-btn--ghost" onclick="closeDelModal()">Cancel</button>
        <button type="button" class="lr-btn lr-btn--danger" id="btnConfirmDel" onclick="confirmDelete()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>
            Delete Room
        </button>
    </div>
</div>

<!-- ── Toast ──────────────────────────────────────────────────────── -->
<div class="lr-toast" id="lrToast"></div>

<script>
(function () {
    'use strict';

    // ─── State ────────────────────────────────────────────────────────
    var BASE    = window.location.pathname;   // this page's URL
    var allRows = [];                         // full room list kept in memory
    var campuses = [];                        // campus list for dropdowns
    var deleteId = 0;                         // ID pending deletion
    var toastTimer = null;

    // ─── Init ─────────────────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', function () {
        loadDropdowns();
        loadRooms();
    });

    // ─── AJAX helper ──────────────────────────────────────────────────
    function ajax(action, data, cb) {
        var xhr  = new XMLHttpRequest();
        var url  = BASE + '?ajax=' + action;
        var body = data ? JSON.stringify(data) : null;
        xhr.open(body ? 'POST' : 'GET', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                try { cb(JSON.parse(xhr.responseText)); }
                catch (e) { cb({ error: 'Parse error: ' + e.message }); }
            }
        };
        xhr.send(body);
    }

    // ─── Load campuses + populate filter dropdown ──────────────────
    function loadDropdowns() {
        ajax('campuses', null, function (d) {
            if (!d.ok || !d.campuses) return;
            campuses = d.campuses;
            var ddl1 = document.getElementById('ddlFilterCampus');
            var ddl2 = document.getElementById('ddlCampus');
            campuses.forEach(function (c) {
                if (c.id == 0) return; // skip "ALL"
                var o1 = document.createElement('option');
                o1.value = c.id; o1.textContent = c.name;
                ddl1.appendChild(o1);
                var o2 = document.createElement('option');
                o2.value = c.id; o2.textContent = c.name;
                ddl2.appendChild(o2);
            });
        });
    }

    // ─── Load rooms list ──────────────────────────────────────────────
    function loadRooms() {
        document.getElementById('tbdRooms').innerHTML =
            '<tr><td colspan="6" class="lr-loading">Loading\u2026</td></tr>';
        ajax('list', null, function (d) {
            if (d.error) {
                document.getElementById('tbdRooms').innerHTML =
                    '<tr><td colspan="6" class="lr-empty">Error loading rooms: ' + esc(d.error) + '</td></tr>';
                return;
            }
            allRows = d.rooms || [];
            updateStats(d.stats || {});
            filterTable();
        });
    }

    // ─── Update stats cards ────────────────────────────────────────
    function updateStats(s) {
        setText('statTotal', s.total || 0);
        setText('statCap',   s.totalCap || 0);
        setText('statC1',    s.campus1 || 0);
        setText('statC2',    s.campus2 || 0);
    }

    // ─── Filter + render table ─────────────────────────────────────
    window.filterTable = function () {
        var q  = (document.getElementById('txtSearch').value || '').toLowerCase();
        var ca = document.getElementById('ddlFilterCampus').value;
        var filtered = allRows.filter(function (r) {
            var nameOk   = !q  || r.name.toLowerCase().indexOf(q) >= 0;
            var campusOk = !ca || String(r.campusId) === String(ca);
            return nameOk && campusOk;
        });
        renderTable(filtered);
        document.getElementById('spnCount').textContent =
            filtered.length + ' room' + (filtered.length !== 1 ? 's' : '');
    };

    function renderTable(rows) {
        var tb = document.getElementById('tbdRooms');
        if (!rows.length) {
            tb.innerHTML = '<tr><td colspan="6" class="lr-empty">No rooms found.</td></tr>';
            return;
        }
        var html = '';
        for (var i = 0; i < rows.length; i++) {
            var r        = rows[i];
            var capBar   = r.capacity > 0
                ? '<span class="lr-cap-bar" style="width:' + Math.min(r.capacity / 4, 60) + 'px"></span>' : '';
            var capText  = r.capacity > 0 ? r.capacity : '<span style="color:#aaa">—</span>';
            var campusCls = 'lr-campus lr-campus--' + r.campusId;
            var usedText  = r.usedCount > 0
                ? '<span style="color:#174DA4;font-weight:600;">' + r.usedCount + ' allocation' + (r.usedCount !== 1 ? 's' : '') + '</span>'
                : '<span style="color:#aaa;">—</span>';
            html += '<tr data-id="'  + r.id       + '"'
                  + '    data-campus="' + r.campusId + '">';
            html += '<td style="color:#888;font-size:10px;">' + (i + 1) + '</td>';
            html += '<td style="font-weight:600;">' + esc(r.name) + '</td>';
            html += '<td><span class="' + campusCls + '">' + esc(r.campusName) + '</span></td>';
            html += '<td>' + capBar + capText + '</td>';
            html += '<td>' + usedText + '</td>';
            html += '<td>';
            html += '<button class="lr-btn lr-btn--ghost lr-btn--sm" onclick="openEdit(' + r.id + ')" title="Edit room">'
                  + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>'
                  + '</button> ';
            html += '<button class="lr-btn lr-btn--danger lr-btn--sm" onclick="openDelete(' + r.id + ',\'' + esc(r.name) + '\',' + r.usedCount + ')" title="Delete room">'
                  + '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>'
                  + '</button>';
            html += '</td></tr>';
        }
        tb.innerHTML = html;
    }

    // ─── Open Add modal ────────────────────────────────────────────
    window.openAdd = function () {
        document.getElementById('lrModalTitle').textContent = 'Add Lecture Room';
        document.getElementById('hdnEditId').value   = '';
        document.getElementById('txtRoomName').value = '';
        document.getElementById('txtCapacity').value = '';
        document.getElementById('ddlCampus').value   = '';
        clearErrors();
        showModal();
    };

    // ─── Open Edit modal ───────────────────────────────────────────
    window.openEdit = function (id) {
        var r = allRows.filter(function (x) { return x.id === id; })[0];
        if (!r) { showToast('Room data not found. Please refresh.', true); return; }
        document.getElementById('lrModalTitle').textContent = 'Edit Room';
        document.getElementById('hdnEditId').value   = r.id;
        document.getElementById('txtRoomName').value = r.name;
        document.getElementById('txtCapacity').value = r.capacity > 0 ? r.capacity : '';
        document.getElementById('ddlCampus').value   = r.campusId;
        clearErrors();
        showModal();
    };

    // ─── Save (create or update) ───────────────────────────────────
    window.saveRoom = function () {
        var name     = document.getElementById('txtRoomName').value.trim();
        var capacity = parseInt(document.getElementById('txtCapacity').value, 10);
        var campusId = document.getElementById('ddlCampus').value;
        var editId   = document.getElementById('hdnEditId').value;
        var valid    = true;
        clearErrors();
        if (!name)             { show('errName');  valid = false; }
        if (!capacity || capacity < 1) { show('errCap'); valid = false; }
        if (!campusId)         { show('errCampus'); valid = false; }
        if (!valid) return;

        var btn = document.getElementById('btnSave');
        btn.disabled = true;

        var action = editId ? 'update' : 'create';
        var data   = { name: name, capacity: capacity, campusId: parseInt(campusId, 10), id: editId ? parseInt(editId, 10) : 0 };

        ajax(action, data, function (d) {
            btn.disabled = false;
            if (d.ok) {
                closeModal();
                showToast(editId ? 'Room updated successfully.' : 'Room added successfully.');
                loadRooms();
            } else {
                showToast(d.error || 'Save failed. Please try again.', true);
            }
        });
    };

    // ─── Open Delete confirm ───────────────────────────────────────
    window.openDelete = function (id, name, usedCount) {
        deleteId = id;
        var msg;
        if (usedCount > 0) {
            msg = '<strong>' + esc(name) + '</strong> is currently assigned in <strong>'
                + usedCount + ' allocation' + (usedCount !== 1 ? 's' : '')
                + '</strong> this semester.<br><br>'
                + '<span style="color:#c62828;">Deleting it will leave those allocations without a room.</span><br><br>'
                + 'Are you sure you want to proceed?';
        } else {
            msg = 'Are you sure you want to delete <strong>' + esc(name) + '</strong>?<br><br>'
                + 'This cannot be undone.';
        }
        document.getElementById('lrDelMsg').innerHTML = msg;
        document.getElementById('lrDelModal').style.display = 'block';
        document.getElementById('lrOverlay').style.display  = 'block';
    };

    window.closeDelModal = function () {
        deleteId = 0;
        document.getElementById('lrDelModal').style.display = 'none';
        document.getElementById('lrOverlay').style.display  = 'none';
    };

    window.confirmDelete = function () {
        if (!deleteId) return;
        var btn = document.getElementById('btnConfirmDel');
        btn.disabled = true;
        ajax('delete', { id: deleteId }, function (d) {
            btn.disabled = false;
            closeDelModal();
            if (d.ok) {
                showToast('Room deleted.');
                loadRooms();
            } else {
                showToast(d.error || 'Delete failed.', true);
            }
        });
    };

    // ─── Modal helpers ─────────────────────────────────────────────
    function showModal() {
        document.getElementById('lrModal').style.display   = 'block';
        document.getElementById('lrOverlay').style.display = 'block';
        document.getElementById('txtRoomName').focus();
    }
    window.closeModal = function () {
        document.getElementById('lrModal').style.display    = 'none';
        document.getElementById('lrDelModal').style.display = 'none';
        document.getElementById('lrOverlay').style.display  = 'none';
    };

    function clearErrors() {
        ['errName', 'errCap', 'errCampus'].forEach(function (id) {
            document.getElementById(id).style.display = 'none';
        });
    }
    function show(id) { document.getElementById(id).style.display = 'block'; }

    // ─── Toast ─────────────────────────────────────────────────────
    window.showToast = function (msg, isErr) {
        var t = document.getElementById('lrToast');
        t.textContent = msg;
        t.className   = 'lr-toast ' + (isErr ? 'lr-toast--err' : 'lr-toast--ok');
        t.style.display = 'block';
        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { t.style.display = 'none'; }, 4000);
    };

    // ─── Utilities ─────────────────────────────────────────────────
    function setText(id, val) {
        var el = document.getElementById(id);
        if (el) el.textContent = val;
    }

    function esc(s) {
        if (!s) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

}());
</script>

</asp:Content>
