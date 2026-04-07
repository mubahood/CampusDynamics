<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AssignmentManager.aspx.cs" Inherits="COOPERP_NewScreens_AssignmentManager" Title="Teaching Assignments - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
/* ===== ASSIGNMENT MANAGER (prefix: am-) ================================= */

/* Stats Row */
.am-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.am-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.am-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.am-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.am-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.am-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.am-stat--total { --stat-c: #174DA4; } .am-stat--total .am-stat__icon { background: #e8f0fc; } .am-stat--total .am-stat__val { color: #174DA4; }
.am-stat--active { --stat-c: #2e7d32; } .am-stat--active .am-stat__icon { background: #e6f4ea; } .am-stat--active .am-stat__val { color: #2e7d32; }
.am-stat--inactive { --stat-c: #c62828; } .am-stat--inactive .am-stat__icon { background: #fde8e8; } .am-stat--inactive .am-stat__val { color: #c62828; }
.am-stat--courses { --stat-c: #00897b; } .am-stat--courses .am-stat__icon { background: #e0f2f1; } .am-stat--courses .am-stat__val { color: #00695c; }

/* Page Header */
.am-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.am-header__left { display: flex; align-items: center; gap: 10px; }
.am-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.am-header__icon svg { color: #fff; }
.am-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.am-header__sub { font-size: 10px; color: #888; margin-top: 1px; }

/* Filters */
.am-filters { display: flex; gap: 8px; margin-bottom: 14px; flex-wrap: wrap; align-items: center; }
.am-filters select, .am-filters input { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; min-width: 140px; }
.am-filters select:focus, .am-filters input:focus { border-color: #174DA4; outline: none; }

/* Card */
.am-card { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 14px; }
.am-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.am-card__title { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }

/* Table */
.am-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.am-table th { background: #f5f7fa; padding: 9px 12px; text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; color: #555; font-weight: 600; border-bottom: 2px solid #e0e5ed; white-space: nowrap; }
.am-table td { padding: 8px 12px; border-bottom: 1px solid #f0f2f5; color: #1a1a2e; vertical-align: middle; }
.am-table tbody tr:hover { background: #f0f4ff; }
.am-row--alt { background: #fafbfc; }

/* Buttons */
.am-btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.am-btn--primary { background: #05275C; color: #fff; } .am-btn--primary:hover { background: #174DA4; }
.am-btn--success { background: #2e7d32; color: #fff; } .am-btn--success:hover { background: #388e3c; }
.am-btn--danger { background: #c62828; color: #fff; } .am-btn--danger:hover { background: #d32f2f; }
.am-btn--ghost { background: #fff; border: 1px solid #cdd3de; color: #555; } .am-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.am-btn:disabled { opacity: .5; cursor: not-allowed; }
.am-btn--sm { padding: 4px 10px; font-size: 10px; }

/* Badges */
.am-badge { display: inline-block; padding: 2px 8px; font-size: 10px; font-weight: 600; letter-spacing: .3px; }
.am-badge--active { background: #e6f4ea; color: #2e7d32; }
.am-badge--inactive { background: #fde8e8; color: #c62828; }

/* Modal */
.am-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,.35); z-index: 9000; }
.am-modal { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #fff; border: 1px solid #cdd3de; width: 520px; max-height: 90vh; overflow-y: auto; z-index: 9001; box-shadow: 0 12px 40px rgba(0,0,0,.15); }
.am-modal__header { padding: 12px 16px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; }
.am-modal__title { font-size: 13px; font-weight: 700; color: #05275C; }
.am-modal__close { background: none; border: none; cursor: pointer; padding: 4px; color: #888; } .am-modal__close:hover { color: #c62828; }
.am-modal__body { padding: 16px; }
.am-modal__footer { padding: 12px 16px; border-top: 1px solid #e0e5ed; background: #f8f9fb; display: flex; justify-content: flex-end; gap: 8px; }

/* Form */
.am-form-group { margin-bottom: 12px; }
.am-form-group label { display: block; font-size: 10px; font-weight: 600; color: #555; text-transform: uppercase; letter-spacing: .3px; margin-bottom: 4px; }
.am-form-group select, .am-form-group input, .am-form-group textarea { width: 100%; padding: 7px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; box-sizing: border-box; }
.am-form-group select:focus, .am-form-group input:focus, .am-form-group textarea:focus { border-color: #174DA4; outline: none; }

/* Toast */
.am-toast { position: fixed; bottom: 20px; right: 20px; padding: 10px 18px; font-size: 12px; font-weight: 600; color: #fff; z-index: 10000; display: none; box-shadow: 0 4px 12px rgba(0,0,0,.15); }
.am-toast--ok { background: #2e7d32; }
.am-toast--err { background: #c62828; }

/* Responsive */
@media (max-width: 768px) {
    .am-stats { grid-template-columns: repeat(2, 1fr); }
    .am-modal { width: 95%; }
    .am-filters { flex-direction: column; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="am-header">
    <div class="am-header__left">
        <div class="am-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        </div>
        <div>
            <div class="am-header__title">Teaching Assignment Manager</div>
            <div class="am-header__sub">Assign teachers to courses for marks entry authorization</div>
        </div>
    </div>
    <div>
        <button type="button" class="am-btn am-btn--primary" onclick="openNewAssignment()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            New Assignment
        </button>
        <button type="button" class="am-btn am-btn--ghost" onclick="runBackfill()" title="Populate from existing marksheet ownership data">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path></svg>
            Backfill from Legacy
        </button>
    </div>
</div>

<!-- Stats -->
<div class="am-stats" id="amStats"></div>

<!-- Filters -->
<div class="am-filters">
    <select id="ddlAmProg" onchange="loadAssignments()"><option value="">-- Programme --</option></select>
    <select id="ddlAmYear" onchange="loadAssignments()"><option value="">-- Academic Year --</option></select>
    <select id="ddlAmSem" onchange="loadAssignments()">
        <option value="">-- Semester --</option>
        <option value="1">Semester 1</option>
        <option value="2">Semester 2</option>
    </select>
    <select id="ddlAmStatus" onchange="filterTable()">
        <option value="">All</option>
        <option value="active" selected="selected">Active</option>
        <option value="inactive">Inactive</option>
    </select>
</div>

<!-- Assignments Table -->
<div class="am-card">
    <div class="am-card__header">
        <div class="am-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
            Current Assignments
        </div>
        <span id="spnCount" style="font-size:10px;color:#888;"></span>
    </div>
    <div style="overflow-x:auto;">
        <table class="am-table" id="tblAssignments">
            <thead>
                <tr>
                    <th>Teacher</th>
                    <th>Course</th>
                    <th>Programme</th>
                    <th>Year</th>
                    <th>Campus</th>
                    <th>Session</th>
                    <th>Status</th>
                    <th>Assigned By</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="tbdAssignments">
                <tr><td colspan="10" style="text-align:center;color:#888;padding:30px;">Select a programme and academic year to load assignments.</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- New Assignment Modal -->
<div class="am-overlay" id="amOverlay" onclick="closeModal()"></div>
<div class="am-modal" id="amModal" style="display:none;">
    <div class="am-modal__header">
        <div class="am-modal__title" id="amModalTitle">New Teaching Assignment</div>
        <button type="button" class="am-modal__close" onclick="closeModal()">&times;</button>
    </div>
    <div class="am-modal__body">
        <div class="am-form-group">
            <label>Teacher</label>
            <select id="ddlTeacher"><option value="">-- Select Teacher --</option></select>
        </div>
        <div class="am-form-group">
            <label>Course</label>
            <select id="ddlCourse"><option value="">-- Select Course --</option></select>
        </div>
        <div class="am-form-group">
            <label>Programme</label>
            <select id="ddlProg2"><option value="">-- Select Programme --</option></select>
        </div>
        <div class="am-form-group">
            <label>Academic Year</label>
            <select id="ddlYear2"><option value="">-- Select --</option></select>
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
            <div class="am-form-group">
                <label>Semester</label>
                <select id="ddlSem2">
                    <option value="1">Semester 1</option>
                    <option value="2">Semester 2</option>
                </select>
            </div>
            <div class="am-form-group">
                <label>Study Year</label>
                <select id="ddlStudyYear2">
                    <option value="1">Year 1</option>
                    <option value="2">Year 2</option>
                    <option value="3">Year 3</option>
                    <option value="4">Year 4</option>
                    <option value="5">Year 5</option>
                </select>
            </div>
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
            <div class="am-form-group">
                <label>Campus</label>
                <select id="ddlCampus2"><option value="">-- Select --</option></select>
            </div>
            <div class="am-form-group">
                <label>Session</label>
                <select id="ddlSession2">
                    <option value="Day">Day</option>
                    <option value="Evening">Evening</option>
                    <option value="Weekend">Weekend</option>
                </select>
            </div>
        </div>
        <div class="am-form-group">
            <label>Notes (Optional)</label>
            <textarea id="txtNotes" rows="2" placeholder="Optional notes about this assignment..."></textarea>
        </div>
    </div>
    <div class="am-modal__footer">
        <button type="button" class="am-btn am-btn--ghost" onclick="closeModal()">Cancel</button>
        <button type="button" class="am-btn am-btn--success" id="btnSaveAssignment" onclick="saveAssignment()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Save Assignment
        </button>
    </div>
</div>

<!-- Toast -->
<div class="am-toast" id="amToast"></div>

<script type="text/javascript">
// ═══════════════════════════════════════════════════════════════════════
// Assignment Manager — Client-Side Logic
// ═══════════════════════════════════════════════════════════════════════

var AM_BASE = window.location.pathname;
var amData = [];

// ─── Initialization ────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function() {
    loadDropdowns();
});

function loadDropdowns() {
    ajax('dropdowns', null, function(d) {
        fillSelect('ddlAmProg', d.programmes, 'progcode', 'progname');
        fillSelect('ddlProg2', d.programmes, 'progcode', 'progname');
        fillSelect('ddlAmYear', d.years, 'val', 'val');
        fillSelect('ddlYear2', d.years, 'val', 'val');
        fillSelect('ddlTeacher', d.teachers, 'username', 'display');
        fillSelect('ddlCourse', d.courses, 'code', 'display');
        fillSelect('ddlCampus2', d.campuses, 'id', 'name');
    });
}

function fillSelect(id, items, valKey, textKey) {
    var sel = document.getElementById(id);
    var first = sel.options[0].text;
    sel.innerHTML = '<option value="">' + first + '</option>';
    if (!items) return;
    for (var i = 0; i < items.length; i++) {
        var o = document.createElement('option');
        o.value = items[i][valKey];
        o.textContent = items[i][textKey];
        sel.appendChild(o);
    }
}

// ─── Load Assignments ──────────────────────────────────────────────
function loadAssignments() {
    var prog = document.getElementById('ddlAmProg').value;
    var year = document.getElementById('ddlAmYear').value;
    var sem = document.getElementById('ddlAmSem').value;
    if (!prog || !year || !sem) return;

    ajax('list&prog=' + encodeURIComponent(prog) + '&year=' + encodeURIComponent(year) + '&sem=' + sem, null, function(d) {
        amData = d.assignments || [];
        renderStats(d.stats);
        filterTable();
    });
}

function renderStats(s) {
    if (!s) return;
    var h = '';
    h += '<div class="am-stat am-stat--total"><div class="am-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg></div><div><div class="am-stat__val">' + s.total + '</div><div class="am-stat__label">Total Assignments</div></div></div>';
    h += '<div class="am-stat am-stat--active"><div class="am-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg></div><div><div class="am-stat__val">' + s.active + '</div><div class="am-stat__label">Active</div></div></div>';
    h += '<div class="am-stat am-stat--inactive"><div class="am-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></div><div><div class="am-stat__val">' + s.inactive + '</div><div class="am-stat__label">Inactive</div></div></div>';
    h += '<div class="am-stat am-stat--courses"><div class="am-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg></div><div><div class="am-stat__val">' + s.courses + '</div><div class="am-stat__label">Distinct Courses</div></div></div>';
    document.getElementById('amStats').innerHTML = h;
}

function filterTable() {
    var status = document.getElementById('ddlAmStatus').value;
    var filtered = [];
    for (var i = 0; i < amData.length; i++) {
        if (status === 'active' && !amData[i].is_active) continue;
        if (status === 'inactive' && amData[i].is_active) continue;
        filtered.push(amData[i]);
    }
    renderTable(filtered);
}

function renderTable(items) {
    var tbody = document.getElementById('tbdAssignments');
    document.getElementById('spnCount').textContent = items.length + ' record(s)';
    if (items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;color:#888;padding:30px;">No assignments found.</td></tr>';
        return;
    }
    var h = '';
    for (var i = 0; i < items.length; i++) {
        var r = items[i];
        var cls = (i % 2 === 1) ? ' class="am-row--alt"' : '';
        var badge = r.is_active ? '<span class="am-badge am-badge--active">Active</span>' : '<span class="am-badge am-badge--inactive">Inactive</span>';
        var actions = r.is_active
            ? '<button type="button" class="am-btn am-btn--danger am-btn--sm" onclick="deactivate(' + r.id + ')">Deactivate</button>'
            : '<button type="button" class="am-btn am-btn--success am-btn--sm" onclick="reactivate(' + r.id + ')">Reactivate</button>';
        h += '<tr' + cls + '>';
        h += '<td><strong>' + esc(r.teacher_name) + '</strong><br/><span style="font-size:9px;color:#888;">' + esc(r.teacher_username) + '</span></td>';
        h += '<td>' + esc(r.course_id) + '<br/><span style="font-size:9px;color:#888;">' + esc(r.course_name) + '</span></td>';
        h += '<td>' + esc(r.prog_name) + '</td>';
        h += '<td>Y' + r.study_year + '</td>';
        h += '<td>' + esc(r.campus_name) + '</td>';
        h += '<td>' + esc(r.stud_session) + '</td>';
        h += '<td>' + badge + '</td>';
        h += '<td>' + esc(r.assigned_by) + '</td>';
        h += '<td>' + esc(r.assigned_at) + '</td>';
        h += '<td>' + actions + '</td>';
        h += '</tr>';
    }
    tbody.innerHTML = h;
}

// ─── Modal ─────────────────────────────────────────────────────────
function openNewAssignment() {
    document.getElementById('amModal').style.display = '';
    document.getElementById('amOverlay').style.display = '';
    document.getElementById('amModalTitle').textContent = 'New Teaching Assignment';
}
function closeModal() {
    document.getElementById('amModal').style.display = 'none';
    document.getElementById('amOverlay').style.display = 'none';
}

// ─── Save Assignment ───────────────────────────────────────────────
function saveAssignment() {
    var payload = {
        teacher: document.getElementById('ddlTeacher').value,
        course: document.getElementById('ddlCourse').value,
        prog: document.getElementById('ddlProg2').value,
        acadyear: document.getElementById('ddlYear2').value,
        semester: parseInt(document.getElementById('ddlSem2').value, 10),
        study_year: parseInt(document.getElementById('ddlStudyYear2').value, 10),
        campus: parseInt(document.getElementById('ddlCampus2').value, 10),
        session: document.getElementById('ddlSession2').value,
        notes: document.getElementById('txtNotes').value
    };
    if (!payload.teacher || !payload.course || !payload.prog || !payload.acadyear) {
        showToast('Please fill in all required fields.', true);
        return;
    }
    document.getElementById('btnSaveAssignment').disabled = true;
    ajaxPost('create', payload, function(d) {
        document.getElementById('btnSaveAssignment').disabled = false;
        if (d.ok) {
            showToast('Assignment created successfully.');
            closeModal();
            loadAssignments();
        } else {
            showToast(d.error || 'Failed to create assignment.', true);
        }
    });
}

// ─── Deactivate / Reactivate ───────────────────────────────────────
function deactivate(id) {
    if (!confirm('Deactivate this assignment? The teacher will lose marks entry access for this course.')) return;
    ajaxPost('deactivate', { id: id }, function(d) {
        if (d.ok) { showToast('Assignment deactivated.'); loadAssignments(); }
        else { showToast(d.error || 'Failed.', true); }
    });
}
function reactivate(id) {
    ajaxPost('reactivate', { id: id }, function(d) {
        if (d.ok) { showToast('Assignment reactivated.'); loadAssignments(); }
        else { showToast(d.error || 'Failed.', true); }
    });
}

// ─── Backfill ──────────────────────────────────────────────────────
function runBackfill() {
    if (!confirm('This will populate teaching assignments from existing marksheet ownership data. Proceed?')) return;
    ajax('backfill', null, function(d) {
        if (d.ok) {
            showToast('Backfill complete: ' + d.count + ' assignment(s) created.');
            loadAssignments();
        } else {
            showToast(d.error || 'Backfill failed.', true);
        }
    });
}

// ─── AJAX Helpers ──────────────────────────────────────────────────
function ajax(action, data, cb) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', AM_BASE + '?ajax=' + action, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            try { cb(JSON.parse(xhr.responseText)); }
            catch(e) { cb({ error: 'Parse error' }); }
        }
    };
    xhr.send();
}
function ajaxPost(action, data, cb) {
    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var xhr = new XMLHttpRequest();
    xhr.open('POST', AM_BASE + '?ajax=' + action, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    if (csrfMeta) xhr.setRequestHeader('X-CSRF-Token', csrfMeta.getAttribute('content'));
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            try { cb(JSON.parse(xhr.responseText)); }
            catch(e) { cb({ error: 'Parse error' }); }
        }
    };
    xhr.send(JSON.stringify(data));
}

function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.appendChild(document.createTextNode(s)); return d.innerHTML; }

function showToast(msg, isErr) {
    var t = document.getElementById('amToast');
    t.textContent = msg;
    t.className = 'am-toast ' + (isErr ? 'am-toast--err' : 'am-toast--ok');
    t.style.display = 'block';
    setTimeout(function() { t.style.display = 'none'; }, 4000);
}
</script>

</asp:Content>
