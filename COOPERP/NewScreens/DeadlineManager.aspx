<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="DeadlineManager.aspx.cs" Inherits="COOPERP_NewScreens_DeadlineManager" Title="Deadline Manager - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
/* ===== DEADLINE MANAGER (prefix: dm-) ================================= */

/* Stats Row */
.dm-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.dm-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.dm-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.dm-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.dm-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.dm-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.dm-stat--total   { --stat-c: #174DA4; } .dm-stat--total .dm-stat__icon   { background: #e8f0fc; } .dm-stat--total .dm-stat__val   { color: #174DA4; }
.dm-stat--active  { --stat-c: #2e7d32; } .dm-stat--active .dm-stat__icon  { background: #e6f4ea; } .dm-stat--active .dm-stat__val  { color: #2e7d32; }
.dm-stat--expired { --stat-c: #c62828; } .dm-stat--expired .dm-stat__icon { background: #fde8e8; } .dm-stat--expired .dm-stat__val { color: #c62828; }
.dm-stat--pending { --stat-c: #e65100; } .dm-stat--pending .dm-stat__icon { background: #fff3e0; } .dm-stat--pending .dm-stat__val { color: #e65100; }

/* Page Header */
.dm-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.dm-header__left { display: flex; align-items: center; gap: 10px; }
.dm-header__icon { width: 36px; height: 36px; background: #05275C; display: flex; align-items: center; justify-content: center; }
.dm-header__icon svg { color: #fff; }
.dm-header__title { font-size: 15px; font-weight: 700; color: #05275C; }
.dm-header__sub { font-size: 10px; color: #888; margin-top: 1px; }

/* Tabs */
.dm-tabs { display: flex; gap: 2px; margin-bottom: 14px; border-bottom: 2px solid #e0e5ed; }
.dm-tab { padding: 8px 18px; font-size: 11px; font-weight: 600; cursor: pointer; color: #666; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all .15s; }
.dm-tab:hover { color: #333; }
.dm-tab--active { color: #174DA4; border-bottom-color: #174DA4; }

/* Filters */
.dm-filters { display: flex; gap: 8px; margin-bottom: 14px; flex-wrap: wrap; align-items: center; }
.dm-filters select, .dm-filters input { padding: 6px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; min-width: 140px; }
.dm-filters select:focus, .dm-filters input:focus { border-color: #174DA4; outline: none; }

/* Table */
.dm-table { width: 100%; border-collapse: collapse; font-size: 11px; background: #fff; }
.dm-table th { background: #f4f6f9; padding: 8px 10px; text-align: left; font-weight: 600; color: #555; text-transform: uppercase; font-size: 9px; letter-spacing: .5px; border-bottom: 2px solid #e0e5ed; }
.dm-table td { padding: 8px 10px; border-bottom: 1px solid #eff1f4; vertical-align: middle; }
.dm-table tr:hover { background: #f8faff; }

/* Badge */
.dm-badge { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; }
.dm-badge--active   { background: #e6f4ea; color: #2e7d32; }
.dm-badge--expired  { background: #fde8e8; color: #c62828; }
.dm-badge--inactive { background: #f0f0f0; color: #888; }
.dm-badge--pending  { background: #fff3e0; color: #e65100; }
.dm-badge--approved { background: #e6f4ea; color: #2e7d32; }
.dm-badge--rejected { background: #fde8e8; color: #c62828; }

/* Countdown */
.dm-countdown { font-weight: 700; font-variant-numeric: tabular-nums; }
.dm-countdown--ok    { color: #2e7d32; }
.dm-countdown--warn  { color: #e65100; }
.dm-countdown--over  { color: #c62828; }

/* Buttons */
.dm-btn { padding: 5px 12px; font-size: 10px; font-weight: 600; cursor: pointer; border: none; transition: background .15s; }
.dm-btn--primary { background: #174DA4; color: #fff; }
.dm-btn--primary:hover { background: #0d3b82; }
.dm-btn--success { background: #2e7d32; color: #fff; }
.dm-btn--success:hover { background: #1b5e20; }
.dm-btn--danger { background: #c62828; color: #fff; }
.dm-btn--danger:hover { background: #b71c1c; }
.dm-btn--outline { background: transparent; border: 1px solid #cdd3de; color: #555; }
.dm-btn--outline:hover { background: #f4f6f9; }
.dm-btn--sm { padding: 3px 8px; font-size: 9px; }

/* Modal */
.dm-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.35); z-index: 1000; justify-content: center; align-items: center; }
.dm-overlay--visible { display: flex; }
.dm-modal { background: #fff; width: 480px; max-height: 85vh; overflow-y: auto; box-shadow: 0 12px 32px rgba(0,0,0,.2); }
.dm-modal__head { padding: 14px 18px; border-bottom: 1px solid #e0e5ed; font-weight: 700; font-size: 13px; color: #05275C; display: flex; justify-content: space-between; align-items: center; }
.dm-modal__close { background: none; border: none; font-size: 18px; cursor: pointer; color: #888; }
.dm-modal__body { padding: 16px 18px; }
.dm-modal__foot { padding: 12px 18px; border-top: 1px solid #e0e5ed; display: flex; justify-content: flex-end; gap: 8px; }

/* Form */
.dm-form-group { margin-bottom: 12px; }
.dm-form-group label { display: block; font-size: 10px; font-weight: 600; color: #555; margin-bottom: 4px; text-transform: uppercase; letter-spacing: .3px; }
.dm-form-group input, .dm-form-group select, .dm-form-group textarea { width: 100%; padding: 7px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; box-sizing: border-box; }
.dm-form-group textarea { min-height: 60px; resize: vertical; }

/* Toast */
.dm-toast { position: fixed; bottom: 20px; right: 20px; padding: 10px 18px; font-size: 11px; font-weight: 600; color: #fff; z-index: 2000; transform: translateY(40px); opacity: 0; transition: all .25s; }
.dm-toast--show { transform: translateY(0); opacity: 1; }
.dm-toast--ok { background: #2e7d32; }
.dm-toast--err { background: #c62828; }

/* Unlock card */
.dm-unlock-card { background: #fff; border: 1px solid #e0e5ed; padding: 14px; margin-bottom: 10px; }
.dm-unlock-card__header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.dm-unlock-card__title { font-weight: 700; font-size: 12px; color: #333; }
.dm-unlock-card__meta { font-size: 10px; color: #888; }
.dm-unlock-card__reason { font-size: 11px; color: #444; margin-bottom: 8px; padding: 8px; background: #f9fafc; border-left: 3px solid #174DA4; }
.dm-unlock-card__actions { display: flex; gap: 6px; }

/* Responsive */
@media (max-width: 768px) {
    .dm-stats { grid-template-columns: repeat(2, 1fr); }
    .dm-filters { flex-direction: column; }
    .dm-modal { width: 95%; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Header -->
<div class="dm-header">
    <div class="dm-header__left">
        <div class="dm-header__icon">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><path d="M8 14h.01M12 14h.01M16 14h.01M8 18h.01M12 18h.01"/></svg>
        </div>
        <div>
            <div class="dm-header__title">Deadline Manager</div>
            <div class="dm-header__sub">Manage coursework, exam &amp; submission deadlines and unlock requests</div>
        </div>
    </div>
    <div>
        <button class="dm-btn dm-btn--primary" onclick="DM.showAddModal()">
            <svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16" style="vertical-align:-1px; margin-right:4px;"><path d="M8 1a1 1 0 0 1 1 1v5h5a1 1 0 1 1 0 2H9v5a1 1 0 1 1-2 0V9H2a1 1 0 0 1 0-2h5V2a1 1 0 0 1 1-1z"/></svg>New Deadline
        </button>
    </div>
</div>

<!-- Stats -->
<div class="dm-stats">
    <div class="dm-stat dm-stat--total">
        <div class="dm-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M3 2a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1H3Z"/></svg></div>
        <div><div class="dm-stat__val" id="stat-total">0</div><div class="dm-stat__label">Total Deadlines</div></div>
    </div>
    <div class="dm-stat dm-stat--active">
        <div class="dm-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M6.5 11.5 3 8l1-1 2.5 2.5L12 4l1 1-6.5 6.5Z"/></svg></div>
        <div><div class="dm-stat__val" id="stat-active">0</div><div class="dm-stat__label">Active</div></div>
    </div>
    <div class="dm-stat dm-stat--expired">
        <div class="dm-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a7 7 0 1 0 0 14A7 7 0 0 0 8 1Zm0 3v5h4"/></svg></div>
        <div><div class="dm-stat__val" id="stat-expired">0</div><div class="dm-stat__label">Expired</div></div>
    </div>
    <div class="dm-stat dm-stat--pending">
        <div class="dm-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a7 7 0 1 0 0 14A7 7 0 0 0 8 1Zm1 4v4H5"/></svg></div>
        <div><div class="dm-stat__val" id="stat-unlock">0</div><div class="dm-stat__label">Pending Unlocks</div></div>
    </div>
</div>

<!-- Tabs -->
<div class="dm-tabs">
    <div class="dm-tab dm-tab--active" data-tab="deadlines" onclick="DM.switchTab('deadlines', this)">Deadlines</div>
    <div class="dm-tab" data-tab="unlocks" onclick="DM.switchTab('unlocks', this)">Unlock Requests</div>
</div>

<!-- Filters -->
<div class="dm-filters" id="dm-filters">
    <select id="dm-campus"><option value="">Loading campuses...</option></select>
    <select id="dm-year"><option value="">Loading years...</option></select>
    <select id="dm-semester">
        <option value="">Semester</option>
        <option value="1">Semester 1</option>
        <option value="2">Semester 2</option>
        <option value="3">Semester 3</option>
    </select>
    <select id="dm-session">
        <option value="Day">Day</option>
        <option value="Evening">Evening</option>
        <option value="Weekend">Weekend</option>
        <option value="Online">Online</option>
    </select>
    <button class="dm-btn dm-btn--primary" onclick="DM.loadDeadlines()">Load</button>
</div>

<!-- Deadlines Tab -->
<div id="tab-deadlines">
    <table class="dm-table" id="dm-deadline-table">
        <thead>
            <tr>
                <th>Activity</th>
                <th>Type</th>
                <th>Deadline</th>
                <th>Countdown</th>
                <th>Status</th>
                <th style="width:100px">Actions</th>
            </tr>
        </thead>
        <tbody id="dm-deadline-body">
            <tr><td colspan="6" style="text-align:center; padding:30px; color:#888;">Select campus, year, semester &amp; session to load deadlines</td></tr>
        </tbody>
    </table>
</div>

<!-- Unlock Requests Tab -->
<div id="tab-unlocks" style="display:none;">
    <div id="dm-unlock-list">
        <div style="text-align:center; padding:30px; color:#888;">Loading unlock requests...</div>
    </div>
</div>

<!-- Add/Edit Deadline Modal -->
<div class="dm-overlay" id="dm-add-modal">
    <div class="dm-modal">
        <div class="dm-modal__head">
            <span id="dm-modal-title">New Deadline</span>
            <button class="dm-modal__close" onclick="DM.hideModal()">&times;</button>
        </div>
        <div class="dm-modal__body">
            <div class="dm-form-group">
                <label>Activity Name</label>
                <input type="text" id="md-activity" placeholder="e.g. Coursework Submission Deadline" />
            </div>
            <div class="dm-form-group">
                <label>Deadline Type</label>
                <select id="md-type">
                    <option value="COURSEWORK">Coursework</option>
                    <option value="EXAM">Exam</option>
                    <option value="SUBMISSION">Submission</option>
                    <option value="OTHER">Other</option>
                </select>
            </div>
            <div class="dm-form-group">
                <label>Deadline Date &amp; Time</label>
                <input type="datetime-local" id="md-deadline" />
            </div>
            <div class="dm-form-group">
                <label>Campus</label>
                <select id="md-campus"></select>
            </div>
            <div class="dm-form-group">
                <label>Academic Year</label>
                <select id="md-year"></select>
            </div>
            <div class="dm-form-group">
                <label>Semester</label>
                <select id="md-semester">
                    <option value="1">Semester 1</option>
                    <option value="2">Semester 2</option>
                    <option value="3">Semester 3</option>
                </select>
            </div>
            <div class="dm-form-group">
                <label>Session</label>
                <select id="md-session">
                    <option value="Day">Day</option>
                    <option value="Evening">Evening</option>
                    <option value="Weekend">Weekend</option>
                    <option value="Online">Online</option>
                </select>
            </div>
        </div>
        <div class="dm-modal__foot">
            <button class="dm-btn dm-btn--outline" onclick="DM.hideModal()">Cancel</button>
            <button class="dm-btn dm-btn--primary" id="dm-save-btn" onclick="DM.saveDeadline()">Save Deadline</button>
        </div>
    </div>
</div>

<!-- Unlock Review Modal -->
<div class="dm-overlay" id="dm-review-modal">
    <div class="dm-modal">
        <div class="dm-modal__head">
            <span>Review Unlock Request</span>
            <button class="dm-modal__close" onclick="DM.hideReviewModal()">&times;</button>
        </div>
        <div class="dm-modal__body">
            <div id="dm-review-details" style="margin-bottom:12px;"></div>
            <div class="dm-form-group">
                <label>Review Notes</label>
                <textarea id="rv-notes" placeholder="Add notes for the requester (optional)"></textarea>
            </div>
            <div class="dm-form-group">
                <label>Unlock Window (hours)</label>
                <input type="number" id="rv-hours" value="48" min="1" max="720" />
            </div>
            <input type="hidden" id="rv-id" />
        </div>
        <div class="dm-modal__foot">
            <button class="dm-btn dm-btn--danger" onclick="DM.reviewUnlock('REJECTED')">Reject</button>
            <button class="dm-btn dm-btn--success" onclick="DM.reviewUnlock('APPROVED')">Approve</button>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="dm-toast" id="dm-toast"></div>

<script>
var DM = (function () {
    var _dropdowns = null;
    var _currentTab = 'deadlines';
    var _editId = null;
    var _csrfToken = (function() { var m = document.querySelector('meta[name="csrf-token"]'); return m ? m.getAttribute('content') : ''; })();

    function init() {
        _loadDropdowns();
        loadUnlockRequests();
    }

    /* ─── Dropdowns ─────────────────────────────────────────────── */
    function _loadDropdowns() {
        fetch('DeadlineManager.aspx?ajax=dropdowns')
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.error) { toast(d.error, true); return; }
                _dropdowns = d;
                _fillSelect('dm-campus', d.campuses, 'id', 'name', 'Campus');
                _fillSelect('dm-year', d.years, 'val', 'val', 'Academic Year');
                _fillSelect('md-campus', d.campuses, 'id', 'name', '');
                _fillSelect('md-year', d.years, 'val', 'val', '');
            })
            .catch(function (e) { toast('Failed to load dropdowns: ' + e.message, true); });
    }

    function _fillSelect(elId, items, valKey, textKey, placeholder) {
        var el = document.getElementById(elId);
        if (!el) return;
        el.innerHTML = '';
        if (placeholder) el.innerHTML = '<option value="">' + placeholder + '</option>';
        for (var i = 0; i < items.length; i++) {
            el.innerHTML += '<option value="' + items[i][valKey] + '">' + _esc(items[i][textKey]) + '</option>';
        }
    }

    /* ─── Deadlines ─────────────────────────────────────────────── */
    function loadDeadlines() {
        var campus = document.getElementById('dm-campus').value;
        var year = document.getElementById('dm-year').value;
        var sem = document.getElementById('dm-semester').value;
        var sess = document.getElementById('dm-session').value;
        if (!campus || !year || !sem) { toast('Please select campus, year and semester.', true); return; }

        var body = document.getElementById('dm-deadline-body');
        body.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:20px;color:#888;">Loading...</td></tr>';

        fetch('DeadlineManager.aspx?ajax=list&campus=' + campus + '&year=' + encodeURIComponent(year) + '&sem=' + sem + '&sess=' + encodeURIComponent(sess))
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.error) { toast(d.error, true); return; }
                _renderDeadlines(d.deadlines || []);
                _updateStats(d.stats);
            })
            .catch(function (e) { toast('Failed to load: ' + e.message, true); });
    }

    function _renderDeadlines(rows) {
        var body = document.getElementById('dm-deadline-body');
        if (!rows.length) {
            body.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:30px;color:#888;">No deadlines found for this context. Click "New Deadline" to add one.</td></tr>';
            return;
        }
        var html = '';
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var badge = r.is_expired ? 'expired' : (r.is_active ? 'active' : 'inactive');
            var badgeText = r.is_expired ? 'Expired' : (r.is_active ? 'Active' : 'Inactive');
            var cdClass = r.days_remaining < 0 ? 'over' : (r.days_remaining <= 7 ? 'warn' : 'ok');
            var cdText = r.days_remaining < 0
                ? Math.abs(r.days_remaining) + ' days overdue'
                : (r.days_remaining === 0 ? 'Today!' : r.days_remaining + ' days left');

            html += '<tr>';
            html += '<td><strong>' + _esc(r.activity) + '</strong></td>';
            html += '<td><span class="dm-badge dm-badge--' + (r.type === 'EXAM' ? 'expired' : 'active') + '">' + _esc(r.type) + '</span></td>';
            html += '<td>' + _esc(r.deadline_display) + '</td>';
            html += '<td><span class="dm-countdown dm-countdown--' + cdClass + '">' + cdText + '</span></td>';
            html += '<td><span class="dm-badge dm-badge--' + badge + '">' + badgeText + '</span></td>';
            html += '<td>';
            if (r.is_active) {
                html += '<button class="dm-btn dm-btn--danger dm-btn--sm" onclick="DM.toggleDeadline(' + r.id + ',0)">Disable</button> ';
            } else {
                html += '<button class="dm-btn dm-btn--success dm-btn--sm" onclick="DM.toggleDeadline(' + r.id + ',1)">Enable</button> ';
            }
            html += '<button class="dm-btn dm-btn--outline dm-btn--sm" onclick="DM.editDeadline(' + r.id + ')">Edit</button>';
            html += '</td></tr>';
        }
        body.innerHTML = html;
    }

    function _updateStats(stats) {
        if (!stats) return;
        document.getElementById('stat-total').textContent = stats.total || 0;
        document.getElementById('stat-active').textContent = stats.active || 0;
        document.getElementById('stat-expired').textContent = stats.expired || 0;
    }

    /* ─── Toggle Deadline ────────────────────────────────────────── */
    function toggleDeadline(id, newState) {
        fetch('DeadlineManager.aspx?ajax=toggle', {
            method: 'POST', headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
            body: JSON.stringify({ id: id, is_active: newState })
        })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.ok) { toast(newState ? 'Deadline enabled.' : 'Deadline disabled.'); loadDeadlines(); }
                else { toast(d.error || 'Toggle failed.', true); }
            })
            .catch(function (e) { toast('Error: ' + e.message, true); });
    }

    /* ─── Edit Deadline ──────────────────────────────────────────── */
    function editDeadline(id) {
        fetch('DeadlineManager.aspx?ajax=get&id=' + id)
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.error) { toast(d.error, true); return; }
                _editId = d.id;
                document.getElementById('dm-modal-title').textContent = 'Edit Deadline';
                document.getElementById('md-activity').value = d.activity || '';
                document.getElementById('md-type').value = d.type || 'COURSEWORK';
                document.getElementById('md-deadline').value = d.deadline_input || '';
                document.getElementById('md-campus').value = (d.campus_id || '').toString();
                document.getElementById('md-year').value = d.acadyear || '';
                document.getElementById('md-semester').value = (d.semester || '').toString();
                document.getElementById('md-session').value = d.session || 'Day';
                document.getElementById('dm-add-modal').classList.add('dm-overlay--visible');
            })
            .catch(function (e) { toast('Error: ' + e.message, true); });
    }

    /* ─── Add/Save Modal ─────────────────────────────────────────── */
    function showAddModal() {
        _editId = null;
        document.getElementById('dm-modal-title').textContent = 'New Deadline';
        document.getElementById('md-activity').value = '';
        document.getElementById('md-type').value = 'COURSEWORK';
        document.getElementById('md-deadline').value = '';
        // Pre-fill from filter dropdowns if available
        var campus = document.getElementById('dm-campus').value;
        var year = document.getElementById('dm-year').value;
        var sem = document.getElementById('dm-semester').value;
        var sess = document.getElementById('dm-session').value;
        if (campus) document.getElementById('md-campus').value = campus;
        if (year) document.getElementById('md-year').value = year;
        if (sem) document.getElementById('md-semester').value = sem;
        if (sess) document.getElementById('md-session').value = sess;
        document.getElementById('dm-add-modal').classList.add('dm-overlay--visible');
    }

    function hideModal() {
        document.getElementById('dm-add-modal').classList.remove('dm-overlay--visible');
        _editId = null;
    }

    function saveDeadline() {
        var payload = {
            id: _editId,
            activity: document.getElementById('md-activity').value.trim(),
            type: document.getElementById('md-type').value,
            deadline: document.getElementById('md-deadline').value,
            campus: document.getElementById('md-campus').value,
            acadyear: document.getElementById('md-year').value,
            semester: document.getElementById('md-semester').value,
            session: document.getElementById('md-session').value
        };
        if (!payload.activity) { toast('Activity name is required.', true); return; }
        if (!payload.deadline) { toast('Deadline date is required.', true); return; }
        if (!payload.campus || !payload.acadyear || !payload.semester) { toast('Campus, year and semester are required.', true); return; }

        fetch('DeadlineManager.aspx?ajax=save', {
            method: 'POST', headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
            body: JSON.stringify(payload)
        })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.ok) {
                    toast(_editId ? 'Deadline updated.' : 'Deadline created.');
                    hideModal();
                    loadDeadlines();
                } else { toast(d.error || 'Save failed.', true); }
            })
            .catch(function (e) { toast('Error: ' + e.message, true); });
    }

    /* ─── Unlock Requests ────────────────────────────────────────── */
    function loadUnlockRequests() {
        fetch('DeadlineManager.aspx?ajax=unlocks')
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.error) { toast(d.error, true); return; }
                _renderUnlocks(d.requests || []);
                document.getElementById('stat-unlock').textContent = (d.requests || []).length;
            })
            .catch(function (e) { toast('Error loading unlocks: ' + e.message, true); });
    }

    function _renderUnlocks(requests) {
        var container = document.getElementById('dm-unlock-list');
        if (!requests.length) {
            container.innerHTML = '<div style="text-align:center; padding:30px; color:#888;">No pending unlock requests.</div>';
            return;
        }
        var html = '';
        for (var i = 0; i < requests.length; i++) {
            var r = requests[i];
            html += '<div class="dm-unlock-card">';
            html += '<div class="dm-unlock-card__header">';
            html += '<div class="dm-unlock-card__title">' + _esc(r.requested_by) + ' &mdash; ' + _esc(r.deadline_type) + '</div>';
            html += '<div class="dm-unlock-card__meta">' + _esc(r.created_at) + '</div>';
            html += '</div>';
            html += '<div style="font-size:10px;color:#666;margin-bottom:6px;">';
            html += _esc(r.course_name) + ' | ' + _esc(r.prog_name) + ' | ' + _esc(r.acadyear) + ' Sem ' + r.semester;
            html += '</div>';
            html += '<div class="dm-unlock-card__reason">' + _esc(r.reason) + '</div>';
            html += '<div class="dm-unlock-card__actions">';
            html += '<button class="dm-btn dm-btn--success dm-btn--sm" onclick="DM.showReview(' + r.id + ')">Review</button>';
            html += '</div></div>';
        }
        container.innerHTML = html;
    }

    function showReview(id) {
        document.getElementById('rv-id').value = id;
        document.getElementById('rv-notes').value = '';
        document.getElementById('rv-hours').value = '48';
        document.getElementById('dm-review-modal').classList.add('dm-overlay--visible');
    }

    function hideReviewModal() {
        document.getElementById('dm-review-modal').classList.remove('dm-overlay--visible');
    }

    function reviewUnlock(decision) {
        var id = document.getElementById('rv-id').value;
        var notes = document.getElementById('rv-notes').value.trim();
        var hours = parseInt(document.getElementById('rv-hours').value) || 48;

        fetch('DeadlineManager.aspx?ajax=review', {
            method: 'POST', headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
            body: JSON.stringify({ id: parseInt(id), decision: decision, notes: notes, hours: hours })
        })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.ok) {
                    toast('Request ' + decision.toLowerCase() + '.');
                    hideReviewModal();
                    loadUnlockRequests();
                } else { toast(d.error || 'Review failed.', true); }
            })
            .catch(function (e) { toast('Error: ' + e.message, true); });
    }

    /* ─── Tabs ──────────────────────────────────────────────────── */
    function switchTab(tab, el) {
        _currentTab = tab;
        var tabs = document.querySelectorAll('.dm-tab');
        for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('dm-tab--active');
        el.classList.add('dm-tab--active');
        document.getElementById('tab-deadlines').style.display = tab === 'deadlines' ? '' : 'none';
        document.getElementById('tab-unlocks').style.display = tab === 'unlocks' ? '' : 'none';
        if (tab === 'unlocks') loadUnlockRequests();
    }

    /* ─── Helpers ───────────────────────────────────────────────── */
    function toast(msg, isErr) {
        var el = document.getElementById('dm-toast');
        el.textContent = msg;
        el.className = 'dm-toast dm-toast--show ' + (isErr ? 'dm-toast--err' : 'dm-toast--ok');
        setTimeout(function () { el.className = 'dm-toast'; }, 3000);
    }

    function _esc(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; }

    /* ─── Init ──────────────────────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', init);

    return {
        loadDeadlines: loadDeadlines,
        toggleDeadline: toggleDeadline,
        editDeadline: editDeadline,
        showAddModal: showAddModal,
        hideModal: hideModal,
        saveDeadline: saveDeadline,
        loadUnlockRequests: loadUnlockRequests,
        showReview: showReview,
        hideReviewModal: hideReviewModal,
        reviewUnlock: reviewUnlock,
        switchTab: switchTab
    };
})();
</script>

</asp:Content>
