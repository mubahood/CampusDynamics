<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="CommunicationAnalytics.aspx.cs" Inherits="COOPERP_NewScreens_CommunicationAnalytics" Title="Communication Analytics - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== COMMUNICATION ANALYTICS PAGE (prefix: ca-) ======================= */

/* Stats Row */
.ca-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.ca-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.ca-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.ca-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ca-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; }
.ca-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.ca-stat--reads    { --stat-c:#174DA4; } .ca-stat--reads .ca-stat__icon    { background:#e8f0fc; } .ca-stat--reads .ca-stat__val    { color:#174DA4; }
.ca-stat--confirmed{ --stat-c:#2e7d32; } .ca-stat--confirmed .ca-stat__icon{ background:#e6f4ea; } .ca-stat--confirmed .ca-stat__val{ color:#2e7d32; }
.ca-stat--students { --stat-c:#1565c0; } .ca-stat--students .ca-stat__icon { background:#e3f2fd; } .ca-stat--students .ca-stat__val { color:#1565c0; }
.ca-stat--staff    { --stat-c:#c62828; } .ca-stat--staff .ca-stat__icon   { background:#fce4ec; } .ca-stat--staff .ca-stat__val   { color:#c62828; }

/* Header */
.ca-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.ca-header__left { display: flex; align-items: center; gap: 10px; }
.ca-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.ca-header__icon svg { color: #fff; }
.ca-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.ca-header__sub   { font-size: 10px; color: #888; margin-top: 1px; }

/* Buttons */
.ca-btn { padding: 7px 14px; font-size: 11px; font-weight: 600; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 5px; }
.ca-btn--ghost { background: transparent; color: #555; border: 1px solid #cdd3de; }
.ca-btn--ghost:hover { background: #f5f7fa; }
.ca-btn--primary { background: #05275C; color: #fff; }
.ca-btn--primary:hover { background: #0a3a7a; }

/* Filters */
.ca-filters { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; align-items: flex-end; }
.ca-filters__group { display: flex; flex-direction: column; gap: 2px; }
.ca-filters__label { font-size: 9px; font-weight: 600; text-transform: uppercase; letter-spacing: .3px; color: #666; }
.ca-filters select { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; min-width: 200px; }

/* Card */
.ca-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.ca-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.ca-card__title  { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Table */
.ca-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.ca-table th { background:#f5f7fa; padding:9px 12px; text-align:left; font-size:10px; text-transform:uppercase; letter-spacing:.3px; color:#555; font-weight:600; border-bottom:2px solid #e0e5ed; white-space:nowrap; }
.ca-table td { padding:8px 12px; border-bottom:1px solid #f0f2f5; color:#1a1a2e; vertical-align:middle; }
.ca-table tbody tr:hover { background:#f0f4ff; }

/* Badges */
.ca-badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; }
.ca-badge--student  { background:#e3f2fd; color:#1565c0; }
.ca-badge--staff    { background:#fce4ec; color:#c62828; }
.ca-badge--yes      { background:#e6f4ea; color:#2e7d32; }
.ca-badge--no       { background:#f5f5f5; color:#888; }

/* Progress bar */
.ca-progress { width: 120px; height: 8px; background: #e0e5ed; display: inline-block; vertical-align: middle; margin-right: 8px; }
.ca-progress__fill { height: 100%; background: #2e7d32; transition: width .3s; }

/* Summary card */
.ca-summary { display:grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 14px; }
.ca-summary__item { background:#fff; border:1px solid #e0e5ed; padding:14px; text-align:center; }
.ca-summary__item h4 { font-size:11px; color:#888; margin:0 0 4px; text-transform:uppercase; letter-spacing:.3px; }
.ca-summary__item p { font-size:20px; font-weight:700; margin:0; color:#05275C; }

.ca-spinner { text-align:center; padding:30px; color:#888; font-size:11px; }
.ca-empty { text-align:center; padding:40px 20px; color:#888; }
.ca-empty__title { font-size:14px; font-weight:600; margin-bottom:4px; }

@media (max-width:600px) { .ca-stats { grid-template-columns: repeat(2, 1fr); } .ca-summary { grid-template-columns: 1fr; } }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Header -->
<div class="ca-header">
    <div class="ca-header__left">
        <div class="ca-header__icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
        <div>
            <div class="ca-header__title">Communication Analytics</div>
            <div class="ca-header__sub">Track who has read and confirmed each communication</div>
        </div>
    </div>
</div>

<!-- Communication selector -->
<div class="ca-filters">
    <div class="ca-filters__group">
        <div class="ca-filters__label">Select Communication</div>
        <select id="caCommSelect" onchange="caLoadDetail()">
            <option value="">-- Select a communication --</option>
        </select>
    </div>
    <div class="ca-filters__group">
        <div class="ca-filters__label">Filter Readers</div>
        <select id="caReaderFilter" onchange="caFilterReaders()">
            <option value="">All Readers</option>
            <option value="confirmed">Confirmed Only</option>
            <option value="unconfirmed">Not Confirmed</option>
            <option value="STUDENT">Students Only</option>
            <option value="STAFF">Staff Only</option>
        </select>
    </div>
    <button type="button" class="ca-btn ca-btn--ghost" onclick="caExport()" style="align-self:flex-end;">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Export CSV
    </button>
</div>

<!-- Stats (loaded per communication) -->
<div class="ca-stats" id="caStats" style="display:none;">
    <div class="ca-stat ca-stat--reads"><div class="ca-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></div><div><div class="ca-stat__val" id="csReads">0</div><div class="ca-stat__label">Total Reads</div></div></div>
    <div class="ca-stat ca-stat--confirmed"><div class="ca-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></div><div><div class="ca-stat__val" id="csConfirmed">0</div><div class="ca-stat__label">Confirmed</div></div></div>
    <div class="ca-stat ca-stat--students"><div class="ca-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div><div><div class="ca-stat__val" id="csStudents">0</div><div class="ca-stat__label">Student Reads</div></div></div>
    <div class="ca-stat ca-stat--staff"><div class="ca-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div><div><div class="ca-stat__val" id="csStaff">0</div><div class="ca-stat__label">Staff Reads</div></div></div>
</div>

<!-- Readers Table -->
<div class="ca-card" id="caDetailCard" style="display:none;">
    <div class="ca-card__header">
        <div class="ca-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Reader Details
            <span id="caReaderCount" style="font-weight:400; color:#888;"></span>
        </div>
    </div>
    <div id="caTableWrap">
        <div class="ca-spinner">Select a communication above</div>
    </div>
</div>

<script type="text/javascript">
(function () {
    var PAGE = window.location.pathname;
    var allReaders = [];

    function qs(sel) { return document.querySelector(sel); }
    function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }
    function fmtDate(d) {
        if (!d) return '-';
        var dt = new Date(d);
        if (isNaN(dt.getTime())) return d;
        return ('0' + dt.getDate()).slice(-2) + '/' + ('0' + (dt.getMonth()+1)).slice(-2) + '/' + dt.getFullYear() + ' ' + ('0' + dt.getHours()).slice(-2) + ':' + ('0' + dt.getMinutes()).slice(-2);
    }

    function ajax(action, body, cb) {
        var url = PAGE + '?ajax=' + action;
        var xhr = new XMLHttpRequest();
        if (body) { xhr.open('POST', url, true); xhr.setRequestHeader('Content-Type','application/json'); }
        else { xhr.open('GET', url, true); }
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            if (xhr.status === 200) { try { cb(JSON.parse(xhr.responseText)); } catch(e) { cb({ok:false,error:'Parse error'}); } }
            else { cb({ok:false,error:'HTTP '+xhr.status}); }
        };
        xhr.send(body ? JSON.stringify(body) : null);
    }

    // Load communication dropdown
    function loadCommList() {
        ajax('commlist', null, function (r) {
            if (!r.ok) return;
            var sel = qs('#caCommSelect');
            sel.innerHTML = '<option value="">-- Select a communication --</option>';
            for (var i = 0; i < r.rows.length; i++) {
                var c = r.rows[i];
                var opt = document.createElement('option');
                opt.value = c.ID;
                opt.textContent = c.title + ' [' + c.status + '] (' + c.readCount + ' reads)';
                sel.appendChild(opt);
            }
        });
    }

    window.caLoadDetail = function () {
        var id = qs('#caCommSelect').value;
        if (!id) {
            qs('#caStats').style.display = 'none';
            qs('#caDetailCard').style.display = 'none';
            return;
        }
        qs('#caStats').style.display = '';
        qs('#caDetailCard').style.display = '';
        qs('#caTableWrap').innerHTML = '<div class="ca-spinner">Loading reader data...</div>';

        ajax('readdetails&id=' + id, null, function (r) {
            if (!r.ok) { qs('#caTableWrap').innerHTML = '<div class="ca-empty"><div class="ca-empty__title">' + esc(r.error) + '</div></div>'; return; }
            // Update stats
            qs('#csReads').textContent = r.readCount || 0;
            qs('#csConfirmed').textContent = r.confirmedCount || 0;
            qs('#csStudents').textContent = r.studentCount || 0;
            qs('#csStaff').textContent = r.staffCount || 0;

            allReaders = r.readers || [];
            qs('#caReaderFilter').value = '';
            renderReaders(allReaders);
        });
    };

    window.caFilterReaders = function () {
        var f = qs('#caReaderFilter').value;
        if (!f) { renderReaders(allReaders); return; }
        var filtered = allReaders.filter(function (r) {
            if (f === 'confirmed') return !!r.confirmed_at;
            if (f === 'unconfirmed') return !r.confirmed_at;
            return r.user_type === f;
        });
        renderReaders(filtered);
    };

    function renderReaders(readers) {
        if (!readers || readers.length === 0) {
            qs('#caTableWrap').innerHTML = '<div class="ca-empty"><div class="ca-empty__title">No readers found</div></div>';
            qs('#caReaderCount').textContent = '';
            return;
        }
        qs('#caReaderCount').textContent = '(' + readers.length + ')';
        var h = '<table class="ca-table"><thead><tr><th>#</th><th>User</th><th>ID</th><th>Type</th><th>Read At</th><th>Confirmed</th><th>Confirmation Text</th></tr></thead><tbody>';
        for (var i = 0; i < readers.length; i++) {
            var r = readers[i];
            h += '<tr>' +
                '<td>' + (i + 1) + '</td>' +
                '<td>' + esc(r.user_name) + '</td>' +
                '<td>' + esc(r.user_id) + '</td>' +
                '<td><span class="ca-badge ca-badge--' + (r.user_type === 'STAFF' ? 'staff' : 'student') + '">' + esc(r.user_type) + '</span></td>' +
                '<td>' + fmtDate(r.read_at) + '</td>' +
                '<td>' + (r.confirmed_at ? '<span class="ca-badge ca-badge--yes">&#10003; ' + fmtDate(r.confirmed_at) + '</span>' : '<span class="ca-badge ca-badge--no">Not confirmed</span>') + '</td>' +
                '<td>' + esc(r.confirmation_text || '') + '</td>' +
                '</tr>';
        }
        h += '</tbody></table>';
        qs('#caTableWrap').innerHTML = h;
    }

    window.caExport = function () {
        var id = qs('#caCommSelect').value;
        if (!id) { alert('Select a communication first'); return; }
        window.location.href = PAGE + '?ajax=exportcsv&id=' + id;
    };

    loadCommList();
})();
</script>

</asp:Content>
