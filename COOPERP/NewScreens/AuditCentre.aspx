<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AuditCentre.aspx.cs" Inherits="COOPERP_NewScreens_AuditCentre" Title="Mark Change Audit Centre - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
/* ===== AUDIT CENTRE (prefix: ac-) ======================================= */

/* Page Header */
.ac-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; flex-wrap: wrap; gap: 8px; }
.ac-title { font-size: 16px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 8px; }
.ac-subtitle { font-size: 11px; color: #888; margin-top: 2px; }

/* Stats Row */
.ac-stats { display: flex; flex-wrap: wrap; gap: 0; background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.ac-stat { flex: 1; min-width: 100px; padding: 10px 14px; text-align: center; border-right: 1px solid #e0e5ed; }
.ac-stat:last-child { border-right: none; }
.ac-stat__val { font-size: 18px; font-weight: 700; color: #222; }
.ac-stat__val--total { color: #174DA4; }
.ac-stat__val--update { color: #e65100; }
.ac-stat__val--approve { color: #2e7d32; }
.ac-stat__val--import { color: #1565c0; }
.ac-stat__val--submit { color: #7b1fa2; }
.ac-stat__val--reject { color: #c62828; }
.ac-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .3px; color: #888; margin-top: 2px; }

/* Filters */
.ac-filters { display: flex; flex-wrap: wrap; gap: 8px; padding: 10px 14px; background: #f8f9fb; border: 1px solid #e0e5ed; margin-bottom: 14px; align-items: flex-end; }
.ac-filters__group { display: flex; flex-direction: column; gap: 3px; }
.ac-filters label { font-size: 9px; font-weight: 600; color: #888; text-transform: uppercase; letter-spacing: .3px; }
.ac-filters input, .ac-filters select { padding: 5px 8px; border: 1px solid #d1d5db; font-size: 11px; background: #fff; }
.ac-filters input:focus, .ac-filters select:focus { outline: none; border-color: #174DA4; }
.ac-filters__btn { padding: 6px 16px; background: #174DA4; color: #fff; border: none; font-size: 11px; font-weight: 600; cursor: pointer; align-self: flex-end; }
.ac-filters__btn:hover { opacity: .85; }
.ac-filters__btn--export { background: #2e7d32; margin-left: auto; }

/* Audit Table */
.ac-table-wrap { background: #fff; border: 1px solid #e0e5ed; overflow-x: auto; margin-bottom: 14px; }
.ac-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.ac-table thead th { background: #f0f2f5; color: #05275C; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; padding: 8px 10px; border-bottom: 2px solid #d1d5db; white-space: nowrap; text-align: left; }
.ac-table tbody tr { border-bottom: 1px solid #eee; transition: background .1s; cursor: pointer; }
.ac-table tbody tr:hover { background: #f6f8fc; }
.ac-table tbody tr.ac-row--expanded { background: #e8f0fc; }
.ac-table tbody td { padding: 6px 10px; vertical-align: middle; }
.ac-table__empty { text-align: center; padding: 40px; color: #999; font-size: 12px; }

/* Action Badges */
.ac-action { display: inline-block; padding: 2px 7px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; border-radius: 2px; }
.ac-action--UPDATE  { background: #fff3e0; color: #e65100; }
.ac-action--INSERT  { background: #e8f5e9; color: #2e7d32; }
.ac-action--DELETE  { background: #fde8e8; color: #c62828; }
.ac-action--APPROVE { background: #e6f4ea; color: #2e7d32; }
.ac-action--REJECT  { background: #fce4ec; color: #c62828; }
.ac-action--IMPORT  { background: #e3f2fd; color: #1565c0; }
.ac-action--SUBMIT  { background: #f3e5f5; color: #7b1fa2; }
.ac-action--UNLOCK  { background: #fff8e1; color: #f57f17; }
.ac-action--REVERT  { background: #efebe9; color: #795548; }

/* Change Summary Cell */
.ac-change { font-size: 10px; }
.ac-change__old { color: #c62828; text-decoration: line-through; }
.ac-change__new { color: #2e7d32; font-weight: 600; }
.ac-change__arrow { color: #888; margin: 0 2px; }

/* Drilldown Panel */
.ac-drilldown { display: none; }
.ac-drilldown.active { display: table-row; }
.ac-drilldown td { padding: 0; }
.ac-timeline { background: #f8f9fb; border-left: 3px solid #174DA4; margin: 8px 12px 8px 30px; padding: 0; }
.ac-timeline__head { padding: 8px 12px; font-size: 11px; font-weight: 700; color: #05275C; border-bottom: 1px solid #e0e5ed; display: flex; align-items: center; justify-content: space-between; }
.ac-timeline__close { background: none; border: none; cursor: pointer; color: #888; font-size: 14px; }
.ac-timeline__body { padding: 8px 12px; }
.ac-timeline__item { display: flex; align-items: flex-start; gap: 10px; padding: 6px 0; border-bottom: 1px solid #f0f0f0; font-size: 10px; }
.ac-timeline__item:last-child { border-bottom: none; }
.ac-timeline__date { color: #888; white-space: nowrap; min-width: 110px; }
.ac-timeline__user { font-weight: 600; color: #174DA4; min-width: 80px; }
.ac-timeline__detail { flex: 1; color: #555; }
.ac-timeline__reason { font-style: italic; color: #e65100; margin-top: 2px; }
.ac-timeline__loading { text-align: center; padding: 12px; color: #888; font-size: 11px; }

/* Pagination */
.ac-paging { display: flex; align-items: center; justify-content: center; gap: 8px; padding: 10px; font-size: 11px; color: #555; }
.ac-paging__btn { padding: 4px 12px; border: 1px solid #d1d5db; background: #fff; cursor: pointer; font-size: 11px; }
.ac-paging__btn:hover { background: #f0f2f5; }
.ac-paging__btn:disabled { opacity: .4; cursor: not-allowed; }
.ac-paging__info { font-weight: 600; }

/* Toast */
.ac-toast { position: fixed; bottom: 24px; right: 24px; padding: 10px 18px; font-size: 12px; font-weight: 600; color: #fff; z-index: 2000; transform: translateY(80px); opacity: 0; transition: transform .25s, opacity .25s; pointer-events: none; }
.ac-toast.show { transform: translateY(0); opacity: 1; }
.ac-toast--ok { background: #2e7d32; }
.ac-toast--err { background: #c62828; }
.ac-toast--warn { background: #e65100; }

/* Loading */
.ac-loading { text-align: center; padding: 40px; font-size: 12px; color: #888; }
.ac-loading span { display: inline-block; animation: ac-spin 1s linear infinite; }
@keyframes ac-spin { to { transform: rotate(360deg); } }

/* Responsive */
@media (max-width: 768px) {
    .ac-stats { flex-direction: column; }
    .ac-stat { border-right: none; border-bottom: 1px solid #e0e5ed; }
    .ac-filters { flex-direction: column; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Loading -->
<div id="acLoading" class="ac-loading"><span>&#9696;</span> Loading audit centre&hellip;</div>

<!-- Header -->
<div id="acHeader" class="ac-header" style="display:none;">
    <div>
        <div class="ac-title">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            Mark Change Audit Centre
        </div>
        <div class="ac-subtitle">Structured audit trail for all mark-changing events</div>
    </div>
</div>

<!-- Stats Row -->
<div id="acStats" class="ac-stats" style="display:none;">
    <div class="ac-stat"><div class="ac-stat__val ac-stat__val--total" id="acStatTotal">0</div><div class="ac-stat__label">Total Events</div></div>
    <div class="ac-stat"><div class="ac-stat__val ac-stat__val--update" id="acStatUpdates">0</div><div class="ac-stat__label">Updates</div></div>
    <div class="ac-stat"><div class="ac-stat__val ac-stat__val--approve" id="acStatApprovals">0</div><div class="ac-stat__label">Approvals</div></div>
    <div class="ac-stat"><div class="ac-stat__val ac-stat__val--reject" id="acStatRejections">0</div><div class="ac-stat__label">Rejections</div></div>
    <div class="ac-stat"><div class="ac-stat__val ac-stat__val--import" id="acStatImports">0</div><div class="ac-stat__label">Imports</div></div>
    <div class="ac-stat"><div class="ac-stat__val ac-stat__val--submit" id="acStatSubmits">0</div><div class="ac-stat__label">Submissions</div></div>
</div>

<!-- Filters -->
<div id="acFilters" class="ac-filters" style="display:none;">
    <div class="ac-filters__group">
        <label>Date From</label>
        <input type="date" id="acDateFrom" />
    </div>
    <div class="ac-filters__group">
        <label>Date To</label>
        <input type="date" id="acDateTo" />
    </div>
    <div class="ac-filters__group">
        <label>User</label>
        <select id="acUser"><option value="">All Users</option></select>
    </div>
    <div class="ac-filters__group">
        <label>Course</label>
        <input type="text" id="acCourse" placeholder="Course code..." style="width:100px;" />
    </div>
    <div class="ac-filters__group">
        <label>Student</label>
        <input type="text" id="acStudent" placeholder="Reg no..." style="width:100px;" />
    </div>
    <div class="ac-filters__group">
        <label>Action</label>
        <select id="acAction">
            <option value="">All Actions</option>
            <option value="UPDATE">Update</option>
            <option value="INSERT">Insert</option>
            <option value="DELETE">Delete</option>
            <option value="APPROVE">Approve</option>
            <option value="REJECT">Reject</option>
            <option value="IMPORT">Import</option>
            <option value="SUBMIT">Submit</option>
            <option value="UNLOCK">Unlock</option>
            <option value="REVERT">Revert</option>
        </select>
    </div>
    <button class="ac-filters__btn" onclick="AC.search()">Search</button>
    <button class="ac-filters__btn ac-filters__btn--export" onclick="AC.exportCSV()">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Export CSV
    </button>
</div>

<!-- Audit Table -->
<div id="acTableWrap" class="ac-table-wrap" style="display:none;">
    <table class="ac-table" id="acTable">
        <thead>
            <tr>
                <th>Date/Time</th>
                <th>User</th>
                <th>Action</th>
                <th>Course</th>
                <th>Student</th>
                <th>Change Summary</th>
                <th>Reason</th>
            </tr>
        </thead>
        <tbody id="acBody"></tbody>
    </table>
</div>

<!-- Pagination -->
<div id="acPaging" class="ac-paging" style="display:none;">
    <button class="ac-paging__btn" id="acPrevBtn" onclick="AC.prevPage()" disabled>&laquo; Previous</button>
    <span class="ac-paging__info" id="acPageInfo">Page 1</span>
    <button class="ac-paging__btn" id="acNextBtn" onclick="AC.nextPage()">Next &raquo;</button>
</div>

<!-- Toast -->
<div class="ac-toast" id="acToast"></div>

<script>
var AC = (function () {
    'use strict';

    var PAGE_SIZE = 50;

    var state = {
        items: [],
        page: 1,
        totalPages: 1,
        expandedIdx: -1
    };

    // ── Init ───────────────────────────────────────────────────────
    function init() {
        // Set default date range: last 30 days
        var now = new Date();
        var from = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        el('acDateFrom').value = fmtDate(from);
        el('acDateTo').value = fmtDate(now);

        loadDropdowns();
    }

    function loadDropdowns() {
        ajax('dropdowns', {}, function (data) {
            if (data.error) { showError(data.error); return; }

            var userSel = el('acUser');
            if (data.users) {
                for (var i = 0; i < data.users.length; i++) {
                    var o = document.createElement('option');
                    o.value = data.users[i];
                    o.textContent = data.users[i];
                    userSel.appendChild(o);
                }
            }

            // Show UI
            el('acLoading').style.display = 'none';
            el('acHeader').style.display = '';
            el('acStats').style.display = '';
            el('acFilters').style.display = '';
            el('acTableWrap').style.display = '';
            el('acPaging').style.display = '';

            search();
        });
    }

    // ── Search ─────────────────────────────────────────────────────
    function search() {
        state.page = 1;
        loadData();
    }

    function loadData() {
        var params = {
            dateFrom: el('acDateFrom').value,
            dateTo: el('acDateTo').value,
            user: el('acUser').value,
            course: el('acCourse').value,
            student: el('acStudent').value,
            action: el('acAction').value,
            page: state.page,
            pageSize: PAGE_SIZE
        };

        ajax('search', params, function (data) {
            if (data.error) { toast(data.error, 'err'); return; }

            state.items = data.items || [];
            state.totalPages = Math.ceil((data.totalCount || 0) / PAGE_SIZE) || 1;
            state.expandedIdx = -1;

            // Update stats
            if (data.summary) {
                el('acStatTotal').textContent = data.summary.total || 0;
                el('acStatUpdates').textContent = data.summary.updates || 0;
                el('acStatApprovals').textContent = data.summary.approvals || 0;
                el('acStatRejections').textContent = data.summary.rejections || 0;
                el('acStatImports').textContent = data.summary.imports || 0;
                el('acStatSubmits').textContent = data.summary.submissions || 0;
            }

            renderTable();
            updatePaging();
        });
    }

    // ── Render Table ───────────────────────────────────────────────
    function renderTable() {
        var body = el('acBody');
        body.innerHTML = '';

        if (state.items.length === 0) {
            var tr = document.createElement('tr');
            var td = document.createElement('td');
            td.colSpan = 7;
            td.className = 'ac-table__empty';
            td.textContent = 'No audit entries match the current filters.';
            tr.appendChild(td);
            body.appendChild(tr);
            return;
        }

        for (var i = 0; i < state.items.length; i++) {
            var item = state.items[i];
            var tr = document.createElement('tr');
            tr.setAttribute('data-idx', i);
            tr.onclick = (function (idx) { return function () { toggleDrilldown(idx); }; })(i);

            // Date/Time
            var td0 = document.createElement('td');
            td0.innerHTML = '<span style="white-space:nowrap;">' + esc(item.changeDate || '') + '</span>';
            tr.appendChild(td0);

            // User
            var td1 = document.createElement('td');
            td1.innerHTML = '<strong>' + esc(item.changedBy || '') + '</strong>';
            if (item.ipAddress) td1.innerHTML += '<br><span style="font-size:9px;color:#999;">' + esc(item.ipAddress) + '</span>';
            tr.appendChild(td1);

            // Action
            var td2 = document.createElement('td');
            var actionClass = item.actionType || 'UPDATE';
            td2.innerHTML = '<span class="ac-action ac-action--' + esc(actionClass) + '">' + esc(item.actionTypeExt || item.actionType || '') + '</span>';
            tr.appendChild(td2);

            // Course
            var td3 = document.createElement('td');
            td3.textContent = item.courseId || '';
            tr.appendChild(td3);

            // Student
            var td4 = document.createElement('td');
            td4.textContent = item.studentId || '';
            tr.appendChild(td4);

            // Change Summary
            var td5 = document.createElement('td');
            td5.innerHTML = buildChangeSummary(item);
            tr.appendChild(td5);

            // Reason
            var td6 = document.createElement('td');
            td6.innerHTML = item.changeReason ? '<span style="font-size:10px;color:#e65100;">' + esc(item.changeReason) + '</span>' : '<span style="color:#ccc;">—</span>';
            tr.appendChild(td6);

            body.appendChild(tr);
        }
    }

    // ── Build Change Summary ───────────────────────────────────────
    function buildChangeSummary(item) {
        var parts = [];
        if (item.oldCwEntered != null || item.newCwEntered != null) {
            parts.push('CW: ' + fmtChange(item.oldCwEntered, item.newCwEntered));
        }
        if (item.oldTestEntered != null || item.newTestEntered != null) {
            parts.push('Test: ' + fmtChange(item.oldTestEntered, item.newTestEntered));
        }
        if (item.oldExamEntered != null || item.newExamEntered != null) {
            parts.push('Exam: ' + fmtChange(item.oldExamEntered, item.newExamEntered));
        }
        if (parts.length === 0 && (item.actionType === 'APPROVE' || item.actionType === 'SUBMIT' || item.actionType === 'REJECT' || item.actionType === 'REVERT' || item.actionType === 'UNLOCK')) {
            return '<span class="ac-change" style="color:#888;font-size:10px;">' + esc(item.actionTypeExt || item.actionType || '') + ' action</span>';
        }
        return '<span class="ac-change">' + parts.join(' &nbsp; ') + '</span>';
    }

    function fmtChange(oldVal, newVal) {
        if (oldVal == null && newVal != null) return '<span class="ac-change__new">' + newVal + '</span>';
        if (oldVal != null && newVal == null) return '<span class="ac-change__old">' + oldVal + '</span>';
        if (oldVal != null && newVal != null && oldVal !== newVal) {
            return '<span class="ac-change__old">' + oldVal + '</span><span class="ac-change__arrow">&rarr;</span><span class="ac-change__new">' + newVal + '</span>';
        }
        if (newVal != null) return '' + newVal;
        return '';
    }

    // ── Drilldown (Student Timeline) ───────────────────────────────
    function toggleDrilldown(idx) {
        var body = el('acBody');

        // Close existing drilldown
        var existing = body.querySelector('.ac-drilldown.active');
        if (existing) {
            existing.parentNode.removeChild(existing);
            if (state.expandedIdx === idx) { state.expandedIdx = -1; return; }
        }

        state.expandedIdx = idx;
        var item = state.items[idx];
        if (!item || !item.studentId || !item.courseId) return;

        // Create drilldown row
        var ddRow = document.createElement('tr');
        ddRow.className = 'ac-drilldown active';
        var ddTd = document.createElement('td');
        ddTd.colSpan = 7;
        ddTd.innerHTML = '<div class="ac-timeline"><div class="ac-timeline__head"><span>Timeline: ' + esc(item.studentId) + ' &mdash; ' + esc(item.courseId) + '</span><button class="ac-timeline__close" onclick="event.stopPropagation(); AC.closeDrilldown()">&times;</button></div><div class="ac-timeline__body" id="acTimeline"><div class="ac-timeline__loading">Loading timeline&hellip;</div></div></div>';
        ddRow.onclick = function (e) { e.stopPropagation(); };
        ddTd.onclick = function (e) { e.stopPropagation(); };
        ddRow.appendChild(ddTd);

        // Insert after the clicked row
        var rows = body.getElementsByTagName('tr');
        var targetRow = rows[idx];
        if (targetRow && targetRow.nextSibling) {
            body.insertBefore(ddRow, targetRow.nextSibling);
        } else {
            body.appendChild(ddRow);
        }

        // Highlight source row
        for (var r = 0; r < rows.length; r++) {
            rows[r].className = rows[r].className.replace(' ac-row--expanded', '');
        }
        if (targetRow) targetRow.className += ' ac-row--expanded';

        // Load timeline
        ajax('drilldown', {
            student: item.studentId, course: item.courseId,
            prog: item.progId || '', year: item.acadYear || '', sem: item.semester || 0
        }, function (data) {
            var container = document.getElementById('acTimeline');
            if (!container) return;
            if (data.error) { container.innerHTML = '<div style="color:#c62828;">' + esc(data.error) + '</div>'; return; }

            var entries = data.entries || [];
            if (entries.length === 0) { container.innerHTML = '<div style="color:#999;padding:8px;">No audit entries for this student/course.</div>'; return; }

            var html = '';
            for (var i = 0; i < entries.length; i++) {
                var e = entries[i];
                html += '<div class="ac-timeline__item">';
                html += '<span class="ac-timeline__date">' + esc(e.changeDate || '') + '</span>';
                html += '<span class="ac-timeline__user">' + esc(e.changedBy || '') + '</span>';
                html += '<span class="ac-action ac-action--' + esc(e.actionType || 'UPDATE') + '" style="margin-right:6px;">' + esc(e.actionTypeExt || e.actionType || '') + '</span>';
                html += '<span class="ac-timeline__detail">' + buildChangeSummary(e) + '</span>';
                html += '</div>';
                if (e.changeReason) {
                    html += '<div class="ac-timeline__reason" style="margin-left:200px;">Reason: ' + esc(e.changeReason) + '</div>';
                }
            }
            container.innerHTML = html;
        });
    }

    function closeDrilldown() {
        var body = el('acBody');
        var existing = body.querySelector('.ac-drilldown.active');
        if (existing) existing.parentNode.removeChild(existing);
        state.expandedIdx = -1;
        // Remove highlights
        var rows = body.getElementsByTagName('tr');
        for (var r = 0; r < rows.length; r++) {
            rows[r].className = rows[r].className.replace(' ac-row--expanded', '');
        }
    }

    // ── Pagination ─────────────────────────────────────────────────
    function prevPage() { if (state.page > 1) { state.page--; loadData(); } }
    function nextPage() { if (state.page < state.totalPages) { state.page++; loadData(); } }

    function updatePaging() {
        el('acPageInfo').textContent = 'Page ' + state.page + ' of ' + state.totalPages;
        el('acPrevBtn').disabled = state.page <= 1;
        el('acNextBtn').disabled = state.page >= state.totalPages;
    }

    // ── Export CSV ─────────────────────────────────────────────────
    function exportCSV() {
        var params = {
            dateFrom: el('acDateFrom').value,
            dateTo: el('acDateTo').value,
            user: el('acUser').value,
            course: el('acCourse').value,
            student: el('acStudent').value,
            action: el('acAction').value
        };

        var qs = [];
        qs.push('ajax=export');
        for (var k in params) {
            if (params.hasOwnProperty(k) && params[k]) {
                qs.push(encodeURIComponent(k) + '=' + encodeURIComponent(params[k]));
            }
        }
        window.location.href = '?' + qs.join('&');
    }

    // ── Utilities ──────────────────────────────────────────────────
    function el(id) { return document.getElementById(id); }
    function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

    function fmtDate(d) {
        var y = d.getFullYear();
        var m = d.getMonth() + 1;
        var dd = d.getDate();
        return y + '-' + (m < 10 ? '0' : '') + m + '-' + (dd < 10 ? '0' : '') + dd;
    }

    function showError(msg) {
        el('acLoading').innerHTML = '<div style="color:#c62828;">' + esc(msg) + '</div>';
    }

    function toast(msg, type) {
        var t = el('acToast');
        t.textContent = msg;
        t.className = 'ac-toast ac-toast--' + (type || 'ok') + ' show';
        setTimeout(function () { t.className = 'ac-toast'; }, 3500);
    }

    function ajax(action, params, cb) {
        var url = '?ajax=' + action;
        var csrfMeta = document.querySelector('meta[name="csrf-token"]');
        if (csrfMeta) { params = params || {}; params['__csrf'] = csrfMeta.getAttribute('content'); }
        var body = [];
        for (var k in params) {
            if (params.hasOwnProperty(k)) {
                body.push(encodeURIComponent(k) + '=' + encodeURIComponent(params[k]));
            }
        }
        var xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            try { var data = JSON.parse(xhr.responseText); cb(data); }
            catch (ex) { cb({ error: 'Invalid server response.' }); }
        };
        xhr.send(body.join('&'));
    }

    // ── Boot ───────────────────────────────────────────────────────
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    return {
        search: search,
        prevPage: prevPage,
        nextPage: nextPage,
        exportCSV: exportCSV,
        closeDrilldown: closeDrilldown
    };
})();
</script>
</asp:Content>
