<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="DeanApproval.aspx.cs" Inherits="COOPERP_NewScreens_DeanApproval" Title="Dean Approval Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
/* ===== DEAN APPROVAL (prefix: da-) ====================================== */

/* Page Header */
.da-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; flex-wrap: wrap; gap: 8px; }
.da-title { font-size: 16px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 8px; }
.da-title__icon { display: flex; align-items: center; }
.da-subtitle { font-size: 11px; color: #888; margin-top: 2px; }

/* Stats Row */
.da-stats { display: flex; flex-wrap: wrap; gap: 0; background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.da-stat { flex: 1; min-width: 120px; padding: 12px 16px; text-align: center; border-right: 1px solid #e0e5ed; }
.da-stat:last-child { border-right: none; }
.da-stat__val { font-size: 22px; font-weight: 700; color: #222; }
.da-stat__val--pending { color: #e65100; }
.da-stat__val--approved { color: #2e7d32; }
.da-stat__val--rejected { color: #c62828; }
.da-stat__val--total { color: #174DA4; }
.da-stat__val--turnaround { color: #00695c; }
.da-stat__val--reviewed { color: #6a1b9a; }
.da-stat__label { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #888; margin-top: 2px; }

/* Bulk Action Bar (Batch 12) */
.da-bulk-bar { display: none; padding: 8px 14px; background: #e3f2fd; border: 1px solid #90caf9; margin-bottom: 14px; align-items: center; gap: 12px; }
.da-bulk-bar--visible { display: flex; }
.da-bulk-bar__count { font-size: 12px; font-weight: 700; color: #1565c0; }
.da-bulk-bar__btn { padding: 6px 16px; font-size: 11px; font-weight: 600; background: #2e7d32; color: #fff; border: none; cursor: pointer; }
.da-bulk-bar__btn:hover { background: #1b5e20; }
.da-bulk-bar__clear { padding: 6px 12px; font-size: 11px; background: transparent; color: #1565c0; border: 1px solid #90caf9; cursor: pointer; }
.da-table .da-check-col { width: 30px; text-align: center; }
.da-table .da-check-col input { cursor: pointer; }

/* Filters */
.da-filters { display: flex; flex-wrap: wrap; gap: 8px; padding: 10px 14px; background: #f8f9fb; border: 1px solid #e0e5ed; margin-bottom: 14px; align-items: center; }
.da-filters select, .da-filters input { padding: 6px 10px; border: 1px solid #d1d5db; font-size: 11px; background: #fff; }
.da-filters select:focus, .da-filters input:focus { outline: none; border-color: #174DA4; }
.da-filters__btn { padding: 6px 16px; background: #174DA4; color: #fff; border: none; font-size: 11px; font-weight: 600; cursor: pointer; }
.da-filters__btn:hover { opacity: .85; }
.da-filters label { font-size: 10px; font-weight: 600; color: #555; text-transform: uppercase; }

/* Queue Table */
.da-table-wrap { background: #fff; border: 1px solid #e0e5ed; overflow-x: auto; margin-bottom: 14px; }
.da-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.da-table thead th { background: #f0f2f5; color: #05275C; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; padding: 9px 12px; border-bottom: 2px solid #d1d5db; white-space: nowrap; text-align: left; }
.da-table tbody tr { border-bottom: 1px solid #eee; transition: background .1s; }
.da-table tbody tr:hover { background: #f6f8fc; }
.da-table tbody td { padding: 8px 12px; vertical-align: middle; }
.da-table__empty { text-align: center; padding: 40px; color: #999; font-size: 12px; }

/* Status Badges */
.da-badge { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; border-radius: 2px; }
.da-badge--submitted { background: #fff3e0; color: #e65100; }
.da-badge--draft { background: #f0f0f0; color: #888; }
.da-badge--approved { background: #e6f4ea; color: #2e7d32; }
.da-badge--provisional { background: #e3f2fd; color: #1565c0; }
.da-badge--published { background: #e8f0fc; color: #174DA4; }

/* Student Progress */
.da-progress { display: flex; align-items: center; gap: 6px; }
.da-progress__bar { width: 60px; height: 6px; background: #e0e0e0; border-radius: 3px; overflow: hidden; }
.da-progress__fill { height: 100%; border-radius: 3px; transition: width .3s; }
.da-progress__fill--ok { background: #2e7d32; }
.da-progress__fill--partial { background: #e65100; }
.da-progress__text { font-size: 10px; color: #555; white-space: nowrap; }

/* Action Buttons */
.da-action { padding: 4px 10px; font-size: 10px; font-weight: 600; border: none; cursor: pointer; margin-right: 4px; transition: opacity .15s; }
.da-action:hover { opacity: .85; }
.da-action--review { background: #174DA4; color: #fff; }
.da-action--approve { background: #2e7d32; color: #fff; }
.da-action--reject { background: #c62828; color: #fff; }

/* Review Modal */
.da-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 1000; align-items: flex-start; justify-content: center; padding-top: 40px; overflow-y: auto; }
.da-overlay.active { display: flex; }
.da-review { background: #fff; width: 92vw; max-width: 1100px; max-height: 85vh; overflow-y: auto; box-shadow: 0 8px 32px rgba(0,0,0,.25); }
.da-review__head { background: linear-gradient(135deg, #05275C 0%, #174DA4 100%); color: #fff; padding: 14px 18px; display: flex; align-items: center; justify-content: space-between; position: sticky; top: 0; z-index: 2; }
.da-review__title { font-size: 14px; font-weight: 700; }
.da-review__sub { font-size: 10px; opacity: .8; margin-top: 2px; }
.da-review__close { background: none; border: none; color: #fff; cursor: pointer; font-size: 18px; opacity: .7; }
.da-review__close:hover { opacity: 1; }
.da-review__info { display: flex; flex-wrap: wrap; gap: 0; border-bottom: 1px solid #e0e5ed; }
.da-review__item { padding: 8px 16px; font-size: 11px; color: #555; border-right: 1px solid #e0e5ed; }
.da-review__item:last-child { border-right: none; }
.da-review__item strong { font-weight: 700; color: #222; }
.da-review__body { padding: 0; }

/* Review Sheet Table */
.da-sheet { width: 100%; border-collapse: collapse; font-size: 11px; }
.da-sheet thead th { background: #f8f9fb; color: #05275C; font-size: 10px; font-weight: 700; text-transform: uppercase; padding: 8px 10px; border-bottom: 2px solid #e0e5ed; text-align: center; white-space: nowrap; position: sticky; top: 62px; z-index: 1; }
.da-sheet thead th:first-child, .da-sheet thead th:nth-child(2) { text-align: left; }
.da-sheet tbody tr { border-bottom: 1px solid #f0f0f0; }
.da-sheet tbody tr:hover { background: #f6f8fc; }
.da-sheet tbody td { padding: 5px 8px; text-align: center; }
.da-sheet tbody td:first-child { text-align: center; color: #999; width: 35px; }
.da-sheet tbody td:nth-child(2) { text-align: left; }
.da-sheet__name { font-weight: 600; color: #222; }
.da-sheet__regno { font-size: 9px; color: #888; }
.da-sheet__total { font-weight: 700; font-size: 13px; }
.da-sheet__total--pass { color: #2e7d32; }
.da-sheet__total--fail { color: #c62828; }
.da-sheet__grade { font-weight: 700; font-size: 12px; padding: 2px 6px; display: inline-block; min-width: 24px; }
.da-sheet__wt { font-size: 10px; color: #888; }
.da-sheet__missing { color: #e65100; font-size: 10px; }

/* Review Footer / Actions */
.da-review__foot { padding: 14px 18px; border-top: 1px solid #e0e5ed; display: flex; align-items: center; justify-content: space-between; gap: 10px; background: #f8f9fb; position: sticky; bottom: 0; z-index: 2; }
.da-review__summary { font-size: 11px; color: #555; }
.da-review__summary strong { color: #222; }
.da-review__actions { display: flex; gap: 8px; }
.da-review__btn { padding: 8px 18px; font-size: 11px; font-weight: 700; border: none; cursor: pointer; }
.da-review__btn:hover { opacity: .85; }
.da-review__btn--approve { background: #2e7d32; color: #fff; }
.da-review__btn--reject { background: #c62828; color: #fff; }
.da-review__btn--close { background: #f0f0f0; color: #555; border: 1px solid #d1d5db; }
.da-review__btn:disabled { opacity: .4; cursor: not-allowed; }

/* Reject Modal */
.da-reject-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 1100; align-items: center; justify-content: center; }
.da-reject-overlay.active { display: flex; }
.da-reject { background: #fff; width: 440px; max-width: 95vw; box-shadow: 0 8px 32px rgba(0,0,0,.2); }
.da-reject__head { background: #c62828; color: #fff; padding: 12px 16px; font-size: 13px; font-weight: 700; display: flex; align-items: center; justify-content: space-between; }
.da-reject__close { background: none; border: none; color: #fff; cursor: pointer; font-size: 16px; }
.da-reject__body { padding: 16px; }
.da-reject__label { font-size: 11px; font-weight: 600; color: #555; margin-bottom: 6px; }
.da-reject__input { width: 100%; padding: 8px 10px; border: 1px solid #d1d5db; font-size: 12px; min-height: 80px; resize: vertical; font-family: inherit; }
.da-reject__input:focus { outline: none; border-color: #c62828; }
.da-reject__hint { font-size: 10px; color: #999; margin-top: 4px; }
.da-reject__foot { padding: 12px 16px; border-top: 1px solid #e0e5ed; display: flex; justify-content: flex-end; gap: 8px; }
.da-reject__btn { padding: 7px 16px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; }
.da-reject__btn--cancel { background: #f0f0f0; color: #555; }
.da-reject__btn--confirm { background: #c62828; color: #fff; }
.da-reject__btn:disabled { opacity: .4; cursor: not-allowed; }

/* Toast */
.da-toast { position: fixed; bottom: 24px; right: 24px; padding: 10px 18px; font-size: 12px; font-weight: 600; color: #fff; z-index: 2000; transform: translateY(80px); opacity: 0; transition: transform .25s, opacity .25s; pointer-events: none; }
.da-toast.show { transform: translateY(0); opacity: 1; }
.da-toast--ok { background: #2e7d32; }
.da-toast--err { background: #c62828; }
.da-toast--warn { background: #e65100; }

/* Loading */
.da-loading { text-align: center; padding: 40px; font-size: 12px; color: #888; }
.da-loading span { display: inline-block; animation: da-spin 1s linear infinite; }
@keyframes da-spin { to { transform: rotate(360deg); } }

/* Responsive */
@media (max-width: 768px) {
    .da-stats { flex-direction: column; }
    .da-stat { border-right: none; border-bottom: 1px solid #e0e5ed; }
    .da-filters { flex-direction: column; }
    .da-review { width: 98vw; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Loading -->
<div id="daLoading" class="da-loading"><span>&#9696;</span> Loading approval queue&hellip;</div>

<!-- Header -->
<div id="daHeader" class="da-header" style="display:none;">
    <div>
        <div class="da-title">
            <span class="da-title__icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
            Dean Approval Dashboard
        </div>
        <div class="da-subtitle" id="daSubtitle"></div>
    </div>
</div>

<!-- Stats Row -->
<div id="daStats" class="da-stats" style="display:none;">
    <div class="da-stat">
        <div class="da-stat__val da-stat__val--pending" id="daStatPending">0</div>
        <div class="da-stat__label">Pending Review</div>
    </div>
    <div class="da-stat">
        <div class="da-stat__val da-stat__val--approved" id="daStatApproved">0</div>
        <div class="da-stat__label">Approved</div>
    </div>
    <div class="da-stat">
        <div class="da-stat__val da-stat__val--rejected" id="daStatRejected">0</div>
        <div class="da-stat__label">Rejected</div>
    </div>
    <div class="da-stat">
        <div class="da-stat__val da-stat__val--total" id="daStatTotal">0</div>
        <div class="da-stat__label">Total Sheets</div>
    </div>
    <div class="da-stat">
        <div class="da-stat__val da-stat__val--reviewed" id="daStatReviewedToday">0</div>
        <div class="da-stat__label">Reviewed Today</div>
    </div>
    <div class="da-stat">
        <div class="da-stat__val da-stat__val--turnaround" id="daStatTurnaround">—</div>
        <div class="da-stat__label">Avg Turnaround</div>
    </div>
</div>

<!-- Filters -->
<div id="daFilters" class="da-filters" style="display:none;">
    <label>Programme</label>
    <select id="daProg"><option value="">All Programmes</option></select>
    <label>Year</label>
    <select id="daYear"><option value="">All Years</option></select>
    <label>Semester</label>
    <select id="daSem"><option value="">All</option><option value="1">Sem 1</option><option value="2">Sem 2</option></select>
    <label>Status</label>
    <select id="daStatus">
        <option value="">All Statuses</option>
        <option value="SUBMITTED" selected>Submitted (Pending)</option>
        <option value="DRAFT">Draft</option>
        <option value="DEAN_APPROVED">Approved</option>
        <option value="PROVISIONAL_PUBLISHED">Provisional</option>
        <option value="FINAL_PUBLISHED">Published</option>
    </select>
    <input type="text" id="daSearch" placeholder="Search course or teacher..." style="width:180px;" />
    <button class="da-filters__btn" onclick="DA.loadQueue()">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        Filter
    </button>
</div>

<!-- Bulk Action Bar (Batch 12) -->
<div class="da-bulk-bar" id="daBulkBar">
    <span class="da-bulk-bar__count" id="daBulkCount">0 selected</span>
    <button class="da-bulk-bar__btn" onclick="DA.bulkApprove()">&#10003; Bulk Approve Selected</button>
    <button class="da-bulk-bar__clear" onclick="DA.clearSelection()">Clear Selection</button>
</div>

<!-- Queue Table -->
<div id="daTableWrap" class="da-table-wrap" style="display:none;">
    <table class="da-table" id="daTable">
        <thead>
            <tr>
                <th class="da-check-col"><input type="checkbox" id="daCheckAll" onchange="DA.toggleAll(this.checked)" title="Select all submitted sheets" /></th>
                <th>Course</th>
                <th>Programme</th>
                <th>Year / Sem</th>
                <th>Teacher</th>
                <th>Students</th>
                <th>Status</th>
                <th>Submitted</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody id="daBody"></tbody>
    </table>
</div>

<!-- Review Modal -->
<div class="da-overlay" id="daReviewOverlay">
    <div class="da-review">
        <div class="da-review__head">
            <div>
                <div class="da-review__title" id="daRevTitle"></div>
                <div class="da-review__sub" id="daRevSub"></div>
            </div>
            <button class="da-review__close" onclick="DA.hideReview()">&times;</button>
        </div>
        <div class="da-review__info" id="daRevInfo"></div>
        <div class="da-review__body">
            <div id="daRevLoading" class="da-loading"><span>&#9696;</span> Loading marks&hellip;</div>
            <table class="da-sheet" id="daRevTable" style="display:none;">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>CW Ent</th>
                        <th>CW Wt</th>
                        <th id="daRevThTest" style="display:none;">Test Ent</th>
                        <th id="daRevThTestWt" style="display:none;">Test Wt</th>
                        <th>Exam Ent</th>
                        <th>Exam Wt</th>
                        <th>Total</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody id="daRevBody"></tbody>
            </table>
        </div>
        <div class="da-review__foot" id="daRevFoot" style="display:none;">
            <div class="da-review__summary" id="daRevSummary"></div>
            <div class="da-review__actions">
                <button class="da-review__btn da-review__btn--close" onclick="DA.hideReview()">Close</button>
                <button class="da-review__btn da-review__btn--reject" id="daRevRejectBtn" onclick="DA.showReject()">Reject with Reason</button>
                <button class="da-review__btn da-review__btn--approve" id="daRevApproveBtn" onclick="DA.approveSheet()">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;"><polyline points="20 6 9 17 4 12"/></svg>
                    Approve Sheet
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Reject Modal -->
<div class="da-reject-overlay" id="daRejectOverlay">
    <div class="da-reject">
        <div class="da-reject__head">
            <span>Reject Mark Sheet</span>
            <button class="da-reject__close" onclick="DA.hideReject()">&times;</button>
        </div>
        <div class="da-reject__body">
            <div class="da-reject__label">Course: <strong id="daRejectCourse"></strong></div>
            <div class="da-reject__label" style="margin-top:10px;">Reason for Rejection <span style="color:#c62828;">*</span></div>
            <textarea class="da-reject__input" id="daRejectReason" placeholder="Explain why The marks are being rejected. The teacher will see this reason."></textarea>
            <div class="da-reject__hint">This reason will be visible to the teacher on their mark entry page.</div>
        </div>
        <div class="da-reject__foot">
            <button class="da-reject__btn da-reject__btn--cancel" onclick="DA.hideReject()">Cancel</button>
            <button class="da-reject__btn da-reject__btn--confirm" id="daRejectConfirmBtn" onclick="DA.confirmReject()">Confirm Rejection</button>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="da-toast" id="daToast"></div>

<script>
var DA = (function () {
    'use strict';

    // ── State ──────────────────────────────────────────────────────
    var state = {
        queue: [],
        reviewContext: null,  // { courseId, progId, acadyear, semester, studyYear, campusId, studSession }
        reviewData: null
    };

    // ── Init ───────────────────────────────────────────────────────
    function init() {
        loadDropdowns();
        loadStats();
    }

    // ── Load Dropdowns ─────────────────────────────────────────────
    function loadDropdowns() {
        ajax('dropdowns', {}, function (data) {
            if (data.error) { showError(data.error); return; }

            var progSel = el('daProg');
            if (data.programmes) {
                for (var i = 0; i < data.programmes.length; i++) {
                    var o = document.createElement('option');
                    o.value = data.programmes[i].code;
                    o.textContent = data.programmes[i].code + ' — ' + data.programmes[i].name;
                    progSel.appendChild(o);
                }
            }

            var yearSel = el('daYear');
            if (data.years) {
                for (var j = 0; j < data.years.length; j++) {
                    var o2 = document.createElement('option');
                    o2.value = data.years[j];
                    o2.textContent = data.years[j];
                    yearSel.appendChild(o2);
                }
            }

            el('daSubtitle').textContent = 'Review and approve submitted mark sheets';

            // Show UI
            el('daLoading').style.display = 'none';
            el('daHeader').style.display = '';
            el('daStats').style.display = '';
            el('daFilters').style.display = '';
            el('daTableWrap').style.display = '';

            // Initial load
            loadQueue();
        });
    }

    // ── Load Queue ─────────────────────────────────────────────────
    function loadQueue() {
        var params = {
            prog: el('daProg').value,
            year: el('daYear').value,
            sem: el('daSem').value,
            status: el('daStatus').value,
            search: el('daSearch').value
        };

        ajax('queue', params, function (data) {
            if (data.error) { toast(data.error, 'err'); return; }

            state.queue = data.items || [];

            // Update stats
            el('daStatPending').textContent = data.pendingCount || 0;
            el('daStatApproved').textContent = data.approvedCount || 0;
            el('daStatRejected').textContent = data.rejectedCount || 0;
            el('daStatTotal').textContent = data.totalCount || 0;

            renderQueue();
        });
    }

    // ── Render Queue ───────────────────────────────────────────────
    function renderQueue() {
        var body = el('daBody');
        body.innerHTML = '';
        state.selected = {};
        _updateBulkBar();
        if (el('daCheckAll')) el('daCheckAll').checked = false;

        if (state.queue.length === 0) {
            var tr = document.createElement('tr');
            var td = document.createElement('td');
            td.colSpan = 9;
            td.className = 'da-table__empty';
            td.textContent = 'No sheets match the current filters.';
            tr.appendChild(td);
            body.appendChild(tr);
            return;
        }

        for (var i = 0; i < state.queue.length; i++) {
            var item = state.queue[i];
            var tr = document.createElement('tr');

            // Checkbox (only for SUBMITTED)
            var td0 = document.createElement('td');
            td0.className = 'da-check-col';
            if (item.status === 'SUBMITTED') {
                td0.innerHTML = '<input type="checkbox" data-idx="' + i + '" onchange="DA.toggleItem(' + i + ', this.checked)" />';
            }
            tr.appendChild(td0);

            // Course
            var td1 = document.createElement('td');
            td1.innerHTML = '<strong>' + esc(item.courseId) + '</strong><br><span style="color:#888;font-size:10px;">' + esc(item.courseName) + '</span>';
            tr.appendChild(td1);

            // Programme
            var td2 = document.createElement('td');
            td2.innerHTML = '<span style="font-size:10px;">' + esc(item.progName) + '</span>';
            tr.appendChild(td2);

            // Year/Sem
            var td3 = document.createElement('td');
            td3.textContent = 'Y' + item.studyYear + ' S' + item.semester + ' ' + item.acadyear;
            tr.appendChild(td3);

            // Teacher
            var td4 = document.createElement('td');
            td4.textContent = item.teacherName || item.submittedBy || '—';
            tr.appendChild(td4);

            // Students (progress bar)
            var td5 = document.createElement('td');
            var pct = item.totalStudents > 0 ? Math.round(item.marksEntered / item.totalStudents * 100) : 0;
            var pctClass = pct >= 95 ? 'ok' : 'partial';
            td5.innerHTML = '<div class="da-progress"><div class="da-progress__bar"><div class="da-progress__fill da-progress__fill--' + pctClass + '" style="width:' + pct + '%"></div></div><span class="da-progress__text">' + item.marksEntered + '/' + item.totalStudents + '</span></div>';
            tr.appendChild(td5);

            // Status
            var td6 = document.createElement('td');
            td6.innerHTML = '<span class="da-badge da-badge--' + badgeClass(item.status) + '">' + esc(statusLabel(item.status)) + '</span>';
            tr.appendChild(td6);

            // Submitted At
            var td7 = document.createElement('td');
            td7.innerHTML = item.submittedAt ? '<span style="font-size:10px;">' + esc(item.submittedAt) + '</span>' : '<span style="color:#ccc;">—</span>';
            tr.appendChild(td7);

            // Actions
            var td8 = document.createElement('td');
            td8.style.whiteSpace = 'nowrap';
            td8.innerHTML = '<button class="da-action da-action--review" data-idx="' + i + '" onclick="DA.reviewSheet(' + i + ')">Review</button>';
            if (item.status === 'SUBMITTED') {
                td8.innerHTML += '<button class="da-action da-action--approve" data-idx="' + i + '" onclick="DA.quickApprove(' + i + ')">Approve</button>';
            }
            tr.appendChild(td8);

            body.appendChild(tr);
        }
    }

    // ── Review Sheet ───────────────────────────────────────────────
    function reviewSheet(idx) {
        var item = state.queue[idx];
        if (!item) return;

        state.reviewContext = {
            courseId: item.courseId,
            progId: item.progId,
            acadyear: item.acadyear,
            semester: item.semester,
            studyYear: item.studyYear,
            campusId: item.campusId,
            studSession: item.studSession,
            status: item.status
        };

        // Show modal
        el('daRevTitle').textContent = item.courseId + ' — ' + item.courseName;
        el('daRevSub').textContent = item.progName + ' | Year ' + item.studyYear + ' | Sem ' + item.semester + ' | ' + item.acadyear;
        el('daRevTable').style.display = 'none';
        el('daRevLoading').style.display = '';
        el('daRevFoot').style.display = 'none';
        el('daReviewOverlay').className = 'da-overlay active';

        // Load sheet data
        ajax('review', {
            course: item.courseId, prog: item.progId, year: item.acadyear,
            sem: item.semester, sy: item.studyYear, campus: item.campusId,
            session: item.studSession
        }, function (data) {
            if (data.error) { toast(data.error, 'err'); hideReview(); return; }

            state.reviewData = data;
            renderReview(data);
        });
    }

    // ── Render Review ──────────────────────────────────────────────
    function renderReview(data) {
        // Info bar
        var info = el('daRevInfo');
        info.innerHTML = '';
        info.innerHTML += '<div class="da-review__item">CW Ratio <strong>' + data.cwRatio + '%</strong></div>';
        info.innerHTML += '<div class="da-review__item">Test Ratio <strong>' + data.testRatio + '%</strong></div>';
        info.innerHTML += '<div class="da-review__item">Exam Ratio <strong>' + data.examRatio + '%</strong></div>';
        info.innerHTML += '<div class="da-review__item">Teacher <strong>' + esc(data.submittedBy || '—') + '</strong></div>';
        info.innerHTML += '<div class="da-review__item">Students <strong>' + data.marksEntered + '/' + data.totalStudents + '</strong></div>';
        info.innerHTML += '<div class="da-review__item">Status <strong>' + esc(statusLabel(data.status || 'SUBMITTED')) + '</strong></div>';

        // Show/hide test columns
        var showTest = data.testRatio > 0;
        el('daRevThTest').style.display = showTest ? '' : 'none';
        el('daRevThTestWt').style.display = showTest ? '' : 'none';

        // Render rows
        var body = el('daRevBody');
        body.innerHTML = '';
        var rows = data.rows || [];
        var totalSum = 0, entered = 0, passCount = 0;

        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var tr = document.createElement('tr');

            var hasMark = r.cwEntered > 0 || r.testEntered > 0 || r.examEntered > 0;
            if (hasMark) {
                entered++;
                totalSum += r.totalMark;
                if (r.totalMark >= 50) passCount++;
            }

            // #
            var td0 = document.createElement('td');
            td0.textContent = (i + 1);
            tr.appendChild(td0);

            // Student
            var td1 = document.createElement('td');
            td1.innerHTML = '<span class="da-sheet__name">' + esc(r.studentName) + '</span><br><span class="da-sheet__regno">' + esc(r.regno) + '</span>';
            tr.appendChild(td1);

            // CW Entered + Weighted
            var tdCw = document.createElement('td');
            tdCw.textContent = hasMark || r.cwEntered > 0 ? r.cwEntered : '';
            tr.appendChild(tdCw);
            var tdCwWt = document.createElement('td');
            tdCwWt.className = 'da-sheet__wt';
            tdCwWt.textContent = r.cwMark;
            tr.appendChild(tdCwWt);

            // Test Entered + Weighted (conditional)
            if (showTest) {
                var tdTest = document.createElement('td');
                tdTest.textContent = hasMark || r.testEntered > 0 ? r.testEntered : '';
                tr.appendChild(tdTest);
                var tdTestWt = document.createElement('td');
                tdTestWt.className = 'da-sheet__wt';
                tdTestWt.textContent = r.testMark;
                tr.appendChild(tdTestWt);
            }

            // Exam Entered + Weighted
            var tdExam = document.createElement('td');
            tdExam.textContent = hasMark || r.examEntered > 0 ? r.examEntered : '';
            tr.appendChild(tdExam);
            var tdExamWt = document.createElement('td');
            tdExamWt.className = 'da-sheet__wt';
            tdExamWt.textContent = r.examMark;
            tr.appendChild(tdExamWt);

            // Total
            var tdTotal = document.createElement('td');
            if (hasMark) {
                tdTotal.textContent = r.totalMark;
                tdTotal.className = 'da-sheet__total ' + (r.totalMark >= 50 ? 'da-sheet__total--pass' : 'da-sheet__total--fail');
            } else {
                tdTotal.innerHTML = '<span class="da-sheet__missing">—</span>';
            }
            tr.appendChild(tdTotal);

            // Grade
            var tdGrade = document.createElement('td');
            tdGrade.innerHTML = '<span class="da-sheet__grade">' + esc(r.grade || '—') + '</span>';
            tr.appendChild(tdGrade);

            body.appendChild(tr);
        }

        // Summary
        var avg = entered > 0 ? (totalSum / entered).toFixed(1) : '—';
        var passRate = entered > 0 ? Math.round(passCount / entered * 100) + '%' : '—';
        el('daRevSummary').innerHTML = '<strong>' + entered + '</strong> marks entered of <strong>' + rows.length + '</strong> students | Average: <strong>' + avg + '</strong> | Pass Rate: <strong>' + passRate + '</strong>';

        // Show/hide action buttons based on status
        var isSubmitted = state.reviewContext && state.reviewContext.status === 'SUBMITTED';
        el('daRevApproveBtn').style.display = isSubmitted ? '' : 'none';
        el('daRevRejectBtn').style.display = isSubmitted ? '' : 'none';

        el('daRevLoading').style.display = 'none';
        el('daRevTable').style.display = '';
        el('daRevFoot').style.display = '';
    }

    // ── Approve Sheet ──────────────────────────────────────────────
    function approveSheet() {
        if (!state.reviewContext) return;
        if (!confirm('Approve this mark sheet? This action is in the audit trail.')) return;

        el('daRevApproveBtn').disabled = true;
        var ctx = state.reviewContext;

        ajax('approve', {
            course: ctx.courseId, prog: ctx.progId, year: ctx.acadyear,
            sem: ctx.semester, sy: ctx.studyYear, campus: ctx.campusId,
            session: ctx.studSession
        }, function (data) {
            el('daRevApproveBtn').disabled = false;
            if (data.error) { toast(data.error, 'err'); return; }

            toast('Sheet approved successfully!', 'ok');
            hideReview();
            loadQueue(); // Refresh queue
        });
    }

    // ── Quick Approve (from queue row) ─────────────────────────────
    function quickApprove(idx) {
        var item = state.queue[idx];
        if (!item) return;
        if (!confirm('Approve ' + item.courseId + ' mark sheet for ' + item.progId + '?')) return;

        ajax('approve', {
            course: item.courseId, prog: item.progId, year: item.acadyear,
            sem: item.semester, sy: item.studyYear, campus: item.campusId,
            session: item.studSession
        }, function (data) {
            if (data.error) { toast(data.error, 'err'); return; }
            toast(item.courseId + ' approved!', 'ok');
            loadQueue();
        });
    }

    // ── Reject Flow ────────────────────────────────────────────────
    function showReject() {
        if (!state.reviewContext) return;
        el('daRejectCourse').textContent = state.reviewContext.courseId;
        el('daRejectReason').value = '';
        el('daRejectOverlay').className = 'da-reject-overlay active';
    }

    function hideReject() {
        el('daRejectOverlay').className = 'da-reject-overlay';
    }

    function confirmReject() {
        var reason = el('daRejectReason').value.trim();
        if (!reason) { toast('A reason is required for rejection.', 'warn'); return; }
        if (!state.reviewContext) return;

        el('daRejectConfirmBtn').disabled = true;
        var ctx = state.reviewContext;

        ajax('reject', {
            course: ctx.courseId, prog: ctx.progId, year: ctx.acadyear,
            sem: ctx.semester, sy: ctx.studyYear, campus: ctx.campusId,
            session: ctx.studSession, reason: reason
        }, function (data) {
            el('daRejectConfirmBtn').disabled = false;
            hideReject();
            if (data.error) { toast(data.error, 'err'); return; }

            toast('Sheet rejected. Teacher will be notified.', 'ok');
            hideReview();
            loadQueue();
        });
    }

    // ── Show/Hide Review Modal ─────────────────────────────────────
    function hideReview() {
        el('daReviewOverlay').className = 'da-overlay';
        state.reviewContext = null;
        state.reviewData = null;
    }

    // ── Stats Loading (Batch 12) ───────────────────────────────────
    function loadStats() {
        ajax('stats', {}, function (d) {
            if (d.error) return;
            if (d.reviewed_today !== undefined) el('daStatReviewedToday').textContent = d.reviewed_today;
            if (d.avg_turnaround_hours !== undefined && d.avg_turnaround_hours !== null) {
                el('daStatTurnaround').textContent = d.avg_turnaround_hours + 'h';
            } else {
                el('daStatTurnaround').textContent = '\u2014';
            }
        });
    }

    // ── Bulk Approve (Batch 12) ────────────────────────────────────
    function toggleAll(checked) {
        var cbs = document.querySelectorAll('#daBody input[type="checkbox"]');
        for (var i = 0; i < cbs.length; i++) {
            cbs[i].checked = checked;
            var idx = parseInt(cbs[i].getAttribute('data-idx'), 10);
            if (checked) { state.selected[idx] = true; } else { delete state.selected[idx]; }
        }
        _updateBulkBar();
    }

    function toggleItem(idx, checked) {
        if (checked) { state.selected[idx] = true; } else { delete state.selected[idx]; }
        _updateBulkBar();
    }

    function clearSelection() {
        state.selected = {};
        if (el('daCheckAll')) el('daCheckAll').checked = false;
        var cbs = document.querySelectorAll('#daBody input[type="checkbox"]');
        for (var c = 0; c < cbs.length; c++) { cbs[c].checked = false; }
        _updateBulkBar();
    }

    function _updateBulkBar() {
        var keys = [];
        for (var k in state.selected) { if (state.selected.hasOwnProperty(k)) keys.push(k); }
        var count = keys.length;
        var bar = el('daBulkBar');
        if (count > 0) {
            bar.className = 'da-bulk-bar da-bulk-bar--visible';
            el('daBulkCount').textContent = count + ' selected';
        } else {
            bar.className = 'da-bulk-bar';
        }
    }

    function bulkApprove() {
        var items = [];
        for (var k in state.selected) {
            if (!state.selected.hasOwnProperty(k)) continue;
            var idx = parseInt(k, 10);
            var item = state.queue[idx];
            if (!item) continue;
            items.push({ course_code: item.course_code, programme: item.programme_code, year: item.academic_year, semester: item.semester });
        }
        if (items.length === 0) { toast('No sheets selected.', 'warn'); return; }
        if (!confirm('Approve ' + items.length + ' selected sheet(s)?')) return;

        el('daBulkBar').className = 'da-bulk-bar';
        toast('Processing bulk approval...', 'ok');

        ajax('bulk_approve', { bulkItems: JSON.stringify(items) }, function (d) {
            if (d.error) { toast(d.error, 'err'); return; }
            toast('Approved: ' + (d.approved || 0) + ', Failed: ' + (d.failed || 0), d.failed > 0 ? 'warn' : 'ok');
            clearSelection();
            loadQueue();
            loadStats();
        });
    }

    // ── Helper: Status Label ───────────────────────────────────────
    function statusLabel(s) {
        if (s === 'DRAFT') return 'Draft';
        if (s === 'SUBMITTED') return 'Submitted';
        if (s === 'DEAN_APPROVED') return 'Approved';
        if (s === 'PROVISIONAL_PUBLISHED') return 'Provisional';
        if (s === 'FINAL_PUBLISHED') return 'Published';
        return s || 'Unknown';
    }

    function badgeClass(s) {
        if (s === 'DRAFT') return 'draft';
        if (s === 'SUBMITTED') return 'submitted';
        if (s === 'DEAN_APPROVED') return 'approved';
        if (s === 'PROVISIONAL_PUBLISHED') return 'provisional';
        if (s === 'FINAL_PUBLISHED') return 'published';
        return 'draft';
    }

    // ── Utilities ──────────────────────────────────────────────────
    function el(id) { return document.getElementById(id); }
    function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

    function showError(msg) {
        el('daLoading').innerHTML = '<div style="color:#c62828;">' + esc(msg) + '</div>';
    }

    function toast(msg, type) {
        var t = el('daToast');
        t.textContent = msg;
        t.className = 'da-toast da-toast--' + (type || 'ok') + ' show';
        setTimeout(function () { t.className = 'da-toast'; }, 3500);
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

    // ── Public API ─────────────────────────────────────────────────
    return {
        loadQueue: loadQueue,
        reviewSheet: reviewSheet,
        approveSheet: approveSheet,
        quickApprove: quickApprove,
        showReject: showReject,
        hideReject: hideReject,
        confirmReject: confirmReject,
        hideReview: hideReview,
        bulkApprove: bulkApprove,
        toggleAll: toggleAll,
        toggleItem: toggleItem,
        clearSelection: clearSelection
    };
})();
</script>
</asp:Content>
