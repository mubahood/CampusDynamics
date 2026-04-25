<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AppraisalView.aspx.cs" Inherits="COOPERP_NewScreens_AppraisalView" Title="View Appraisals - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== APPRAISAL VIEW / RECORDS ===== */
*,*::before,*::after{box-sizing:border-box;}
:root{--brand:#174DA4;--brand-light:#e8eef8;--brand-dark:#0f3670;--success:#28a745;--danger:#dc3545;--warning:#ffc107;--info:#17a2b8;--grey:#6c757d;--grey-light:#f4f5f7;--border:#dee2e6;--radius:6px;--shadow:0 1px 3px rgba(0,0,0,.08);}

/* ── Page header ── */
.pa-page-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.pa-page-header__icon{width:44px;height:44px;border-radius:10px;background:var(--brand);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.pa-page-header__title{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.pa-page-header__sub{font-size:12px;color:#888;margin-top:1px;}
.pa-page-header__actions{margin-left:auto;display:flex;gap:8px;align-items:center;}

/* ── Filter bar ── */
.pa-filter-bar{display:flex;flex-wrap:wrap;gap:8px;align-items:center;padding:12px 16px;margin-bottom:0;background:#f8f9fa;border-bottom:1px solid #e0e5ed;}
.pa-filter-bar input,.pa-filter-bar select{font-size:12px;padding:6px 10px;border:1px solid var(--border);border-radius:var(--radius);background:#fff;color:#333;}
.pa-filter-bar input:focus,.pa-filter-bar select:focus{outline:none;border-color:var(--brand);box-shadow:0 0 0 2px rgba(23,77,164,.15);}
.pa-filter-bar input[type=text]{min-width:200px;}
.pa-filter-bar__count{margin-left:auto;font-size:11px;color:#888;}

/* ── Card ── */
.cd-card{background:#fff;border:1px solid #e0e5ed;border-radius:var(--radius);overflow:hidden;margin-bottom:16px;}

/* ── Table ── */
.pa-table{width:100%;border-collapse:collapse;font-size:12px;}
.pa-table th{text-align:left;padding:8px 10px;border-bottom:2px solid #e0e5ed;color:#666;font-weight:600;text-transform:uppercase;font-size:10px;letter-spacing:.3px;background:#fafbfc;}
.pa-table td{padding:8px 10px;border-bottom:1px solid #f5f7fa;color:#333;vertical-align:middle;}
.pa-table tr:last-child td{border-bottom:none;}
.pa-table tr:hover td{background:#f4f8ff;}
.pa-num{text-align:right;font-variant-numeric:tabular-nums;}
.pa-col-num{width:40px;text-align:center;color:#999;font-size:11px;}
.pa-empty-state{text-align:center;padding:40px 20px;color:#999;}
.pa-empty-state svg{color:#ddd;margin-bottom:8px;}
.pa-empty-state p{margin:8px 0 0;font-size:13px;}

/* ── Record badge ── */
.pa-rec-badge{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
.pa-rec-badge--pending{background:#e2e3e5;color:#383d41;}
.pa-rec-badge--emp-prog{background:#cff4fc;color:#055160;}
.pa-rec-badge--emp-done{background:#cce5ff;color:#004085;}
.pa-rec-badge--sup-prog{background:#fff3cd;color:#856404;}
.pa-rec-badge--completed{background:#d4edda;color:#155724;}
.pa-rec-badge--returned{background:#fff3cd;color:#856404;border:1px solid #ffc107;}
.pa-rec-badge--cancelled{background:#f8d7da;color:#721c24;}

/* ── Pager ── */
.pa-pager{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;border-top:1px solid #e0e5ed;font-size:12px;color:#888;flex-wrap:wrap;gap:8px;}
.pa-pager__nav{display:flex;gap:4px;}
.pa-pager__btn{display:inline-flex;align-items:center;justify-content:center;min-width:30px;height:30px;padding:0 8px;border:1px solid var(--border);border-radius:var(--radius);font-size:12px;color:#555;text-decoration:none;transition:all .15s ease;}
.pa-pager__btn:hover{border-color:var(--brand);color:var(--brand);background:var(--brand-light);}
.pa-pager__btn--active{background:var(--brand);color:#fff;border-color:var(--brand);}
.pa-pager__btn--disabled{color:#ccc;cursor:default;pointer-events:none;}

/* ── Buttons ── */
.hr-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;font-size:12px;font-weight:600;border:none;border-radius:var(--radius);cursor:pointer;transition:all .15s ease;text-decoration:none;}
.hr-btn--primary{background:var(--brand);color:#fff;}
.hr-btn--primary:hover{background:var(--brand-dark);}
.hr-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.hr-btn--outline:hover{border-color:var(--brand);color:var(--brand);}
.hr-btn--sm{padding:4px 10px;font-size:11px;}

/* ══════════════════════════════════════════════════════
   DETAIL VIEW
   ══════════════════════════════════════════════════════ */
.pa-detail-back{margin-bottom:14px;}
.pa-detail-back a{display:inline-flex;align-items:center;gap:6px;font-size:12px;font-weight:600;color:var(--brand);text-decoration:none;}
.pa-detail-back a:hover{text-decoration:underline;}

.pa-detail-header{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;background:#f8f9fa;border-bottom:1px solid #e0e5ed;flex-wrap:wrap;gap:10px;}
.pa-detail-header__name{font-size:18px;font-weight:700;color:#1a1a2e;margin:0;}
.pa-detail-header__meta{font-size:12px;color:#888;margin-top:2px;}

.pa-detail-section{background:#fff;border:1px solid #e0e5ed;border-radius:var(--radius);margin-bottom:14px;overflow:hidden;}
.pa-detail-section__hdr{padding:10px 16px;background:#fafbfc;border-bottom:1px solid #e0e5ed;font-size:12px;font-weight:700;color:#333;text-transform:uppercase;letter-spacing:.3px;}
.pa-detail-section__body{padding:14px 16px;}
.pa-detail-section--score{border-left:3px solid var(--brand);}
.pa-detail-empty{color:#999;font-size:13px;font-style:italic;margin:0;}

.pa-detail-table{font-size:12px;}
.pa-detail-table th{font-size:10px;}
.pa-cat-row td{background:#f4f5f7 !important;font-size:11px;border-bottom:1px solid #e0e5ed !important;}

/* ── Info grid (bio data) ── */
.pa-info-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:10px 20px;}
@media(max-width:700px){.pa-info-grid{grid-template-columns:1fr;}}
.pa-info-item{display:flex;flex-direction:column;gap:2px;}
.pa-info-label{font-size:10px;text-transform:uppercase;letter-spacing:.3px;color:#888;font-weight:600;}
.pa-info-val{font-size:13px;color:#1a1a2e;}

/* ── Score grid ── */
.pa-score-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:14px;}
@media(max-width:900px){.pa-score-grid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:500px){.pa-score-grid{grid-template-columns:1fr;}}
.pa-score-item{background:#f8f9fa;border:1px solid #e0e5ed;border-radius:var(--radius);padding:10px 14px;text-align:center;}
.pa-score-item--final{background:var(--brand-light);border-color:var(--brand);}
.pa-score-item--class{background:#d4edda;border-color:#28a745;}
.pa-score-label{display:block;font-size:10px;text-transform:uppercase;letter-spacing:.3px;color:#888;margin-bottom:4px;}
.pa-score-val{display:block;font-size:20px;font-weight:700;color:#1a1a2e;}
.pa-score-item--final .pa-score-val{color:var(--brand);}
.pa-score-item--class .pa-score-val{color:#155724;}

/* ── Comment blocks (Section E) ── */
.pa-comment-block{margin-bottom:12px;padding-bottom:12px;border-bottom:1px solid #f0f1f3;}
.pa-comment-block:last-child{border-bottom:none;margin-bottom:0;padding-bottom:0;}
.pa-comment-block__q{font-size:12px;font-weight:600;color:#333;margin-bottom:4px;}
.pa-comment-block__a{font-size:13px;color:#555;line-height:1.5;}

/* ── Timestamps ── */
.pa-timestamps{display:flex;gap:24px;font-size:11px;color:#888;padding-top:10px;border-top:1px solid #e0e5ed;}

/* ── Alert ── */
.pa-alert--error{padding:12px 16px;background:#f8d7da;color:#721c24;border-radius:var(--radius);margin-bottom:14px;font-size:13px;}
.pa-alert--info{padding:12px 16px;background:#cce5ff;color:#004085;border-radius:var(--radius);margin-bottom:14px;font-size:13px;}

/* ── Admin action bar ── */
.pa-actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:14px;padding-top:14px;border-top:1px solid #e0e5ed;}

/* ── Action button variants ── */
.hr-btn--danger{background:var(--danger);color:#fff;}
.hr-btn--danger:hover{background:#b02a37;}
.hr-btn--warning{background:var(--warning);color:#333;}
.hr-btn--warning:hover{background:#e0a800;}
.hr-btn--success{background:var(--success);color:#fff;}
.hr-btn--success:hover{background:#218838;}

/* ── Modal ── */
.pa-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;}
.pa-modal-overlay.is-open{display:flex;}
.pa-modal{background:#fff;width:480px;max-width:92vw;border-radius:var(--radius);box-shadow:0 8px 32px rgba(0,0,0,.18);overflow:hidden;}
.pa-modal__head{padding:14px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;}
.pa-modal__title{font-size:14px;font-weight:700;color:#333;}
.pa-modal__close{background:none;border:none;font-size:20px;cursor:pointer;color:#999;padding:0 4px;line-height:1;}
.pa-modal__close:hover{color:#333;}
.pa-modal__body{padding:18px;font-size:13px;color:#333;line-height:1.5;}
.pa-modal__body textarea{width:100%;border:1px solid var(--border);border-radius:var(--radius);padding:8px 10px;font-size:12px;font-family:inherit;resize:vertical;box-sizing:border-box;min-height:80px;margin-top:8px;}
.pa-modal__body textarea:focus{outline:none;border-color:var(--brand);}
.pa-modal__foot{padding:12px 18px;border-top:1px solid var(--border);display:flex;justify-content:flex-end;gap:8px;}

/* ── Toast ── */
.pa-toast{position:fixed;bottom:24px;right:24px;padding:12px 20px;font-size:13px;font-weight:600;color:#fff;z-index:999;border-radius:var(--radius);opacity:0;transform:translateY(12px);transition:all .3s ease;pointer-events:none;max-width:360px;box-shadow:0 4px 16px rgba(0,0,0,.15);}
.pa-toast.is-visible{opacity:1;transform:translateY(0);}
.pa-toast--ok{background:var(--success);}
.pa-toast--err{background:var(--danger);}

/* ── Print ── */
@media print{
    .pa-page-header__actions,.pa-detail-back,.cd-sidebar,.pa-filter-bar,.pa-pager,.pa-actions,.pa-modal-overlay{display:none !important;}
    .pa-detail-section{break-inside:avoid;}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ══════════════════════════════════════════════════════
     LIST VIEW  (default when no ?rid=)
     ══════════════════════════════════════════════════════ -->
<asp:Panel ID="pnlList" runat="server">

<div class="pa-page-header">
    <div class="pa-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
    </div>
    <div>
        <div class="pa-page-header__title">Appraisal Records</div>
        <div class="pa-page-header__sub">View and review individual staff appraisals</div>
    </div>
    <div class="pa-page-header__actions">
        <a href="AppraisalDashboard.aspx" class="hr-btn hr-btn--outline">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
            Dashboard
        </a>
    </div>
</div>

<!-- Filter + Grid Card -->
<div class="cd-card">
    <div class="pa-filter-bar">
        <input type="text" id="txtSearch" placeholder="Search employee name or code..." onkeyup="debounceFilter()" />
        <select id="selStatus" onchange="applyFilter()">
            <option value="">All Statuses</option>
            <option value="PENDING">Pending</option>
            <option value="EMPLOYEE_IN_PROGRESS">Employee In Progress</option>
            <option value="EMPLOYEE_SUBMITTED">Employee Submitted</option>
            <option value="SUPERVISOR_IN_PROGRESS">Supervisor In Progress</option>
            <option value="COMPLETED">Completed</option>
            <option value="RETURNED">Returned</option>
            <option value="CANCELLED">Cancelled</option>
        </select>
        <select id="selCategory" onchange="applyFilter()">
            <option value="">All Categories</option>
            <option value="ACADEMIC">Academic</option>
            <option value="ADMINISTRATIVE">Administrative</option>
            <option value="SUPPORT">Support</option>
        </select>
        <select id="selSession" onchange="applyFilter()">
            <asp:Literal ID="litSessionOptions" runat="server" />
        </select>
        <span class="pa-filter-bar__count"><asp:Literal ID="litTotalCount" runat="server" Text="0" /> records</span>
    </div>
    <table class="pa-table">
        <thead>
            <tr>
                <th style="width:40px;">#</th>
                <th>Employee</th>
                <th>Department</th>
                <th>Category</th>
                <th>Session</th>
                <th>Reviewer</th>
                <th>Status</th>
                <th style="text-align:right;">Score</th>
                <th>Classification</th>
            </tr>
        </thead>
        <tbody>
            <asp:Literal ID="litGridBody" runat="server" />
        </tbody>
    </table>
    <div class="pa-pager">
        <span><asp:Literal ID="litPagerInfo" runat="server" /></span>
        <div class="pa-pager__nav">
            <asp:Literal ID="litPager" runat="server" />
        </div>
    </div>
</div>

</asp:Panel>

<!-- ══════════════════════════════════════════════════════
     DETAIL VIEW  (when ?rid= is present)
     ══════════════════════════════════════════════════════ -->
<asp:Panel ID="pnlDetail" runat="server" Visible="false">

<div class="pa-detail-back">
    <a href="AppraisalView.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        Back to Records List
    </a>
</div>

<div class="pa-page-header">
    <div class="pa-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M9 15l2 2 4-4"/></svg>
    </div>
    <div>
        <div class="pa-page-header__title">Appraisal Detail</div>
        <div class="pa-page-header__sub">Complete view of individual performance appraisal</div>
    </div>
    <div class="pa-page-header__actions">
        <button type="button" class="hr-btn hr-btn--outline" onclick="window.print()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
            Print
        </button>
    </div>
</div>

<asp:Literal ID="litDetailContent" runat="server" />

</asp:Panel>

<!-- ── Admin Action Modal ── -->
<div class="pa-modal-overlay" id="adminModal">
    <div class="pa-modal">
        <div class="pa-modal__head">
            <span class="pa-modal__title" id="adminModalTitle">Action</span>
            <button type="button" class="pa-modal__close" onclick="closeAdminModal()">&times;</button>
        </div>
        <div class="pa-modal__body" id="adminModalBody"></div>
        <div class="pa-modal__foot" id="adminModalFoot"></div>
    </div>
</div>

<!-- Toast -->
<div class="pa-toast" id="paToast"></div>

<script type="text/javascript">
// ── Filter logic ──
var _filterTimer = null;
function debounceFilter() {
    if (_filterTimer) clearTimeout(_filterTimer);
    _filterTimer = setTimeout(function () { applyFilter(); }, 400);
}
function applyFilter() {
    var q = (document.getElementById('txtSearch') || {}).value || '';
    var st = (document.getElementById('selStatus') || {}).value || '';
    var cat = (document.getElementById('selCategory') || {}).value || '';
    var sid = (document.getElementById('selSession') || {}).value || '';
    var url = 'AppraisalView.aspx?';
    if (q) url += 'q=' + encodeURIComponent(q) + '&';
    if (st) url += 'status=' + encodeURIComponent(st) + '&';
    if (cat) url += 'cat=' + encodeURIComponent(cat) + '&';
    if (sid && sid !== '0') url += 'sid=' + sid + '&';
    window.location.href = url.replace(/&$/, '');
}

// ── Restore filter values from URL ──
(function () {
    var params = new URLSearchParams(window.location.search);
    var q = params.get('q') || '';
    var st = params.get('status') || '';
    var cat = params.get('cat') || '';
    var sid = params.get('sid') || '';
    var el;
    el = document.getElementById('txtSearch'); if (el) el.value = q;
    el = document.getElementById('selStatus'); if (el) el.value = st;
    el = document.getElementById('selCategory'); if (el) el.value = cat;
    el = document.getElementById('selSession'); if (el) el.value = sid;
})();

// ═══════════════════════════════════════════════════════
//  ADMIN ACTIONS (Detail view)
// ═══════════════════════════════════════════════════════
var _adminBusy = false;

function openAdminModal(title, bodyHtml, footHtml) {
    document.getElementById('adminModalTitle').textContent = title;
    document.getElementById('adminModalBody').innerHTML = bodyHtml;
    document.getElementById('adminModalFoot').innerHTML = footHtml;
    document.getElementById('adminModal').classList.add('is-open');
}
function closeAdminModal() {
    document.getElementById('adminModal').classList.remove('is-open');
}

function adminReturnToEmployee(rid) {
    openAdminModal('Return to Employee',
        '<p>This will return the appraisal to the employee for revision. Please provide a reason:</p>' +
        '<textarea id="adminReturnComment" placeholder="Reason for returning..." maxlength="1000"></textarea>',
        '<button type="button" class="hr-btn hr-btn--outline" onclick="closeAdminModal()">Cancel</button>' +
        '<button type="button" class="hr-btn hr-btn--warning" id="btnAdminReturn" onclick="confirmAdminReturn(' + rid + ')">Return</button>'
    );
}

function confirmAdminReturn(rid) {
    if (_adminBusy) return;
    var comment = (document.getElementById('adminReturnComment') || {}).value || '';
    if (!comment.trim()) { showPaToast('Please provide a reason', 'err'); return; }
    _adminBusy = true;
    var btn = document.getElementById('btnAdminReturn');
    if (btn) { btn.disabled = true; btn.textContent = 'Returning...'; }

    adminAjax('admin_return', { rid: rid, comment: comment.trim() }, function (res) {
        _adminBusy = false;
        closeAdminModal();
        if (res.ok) {
            showPaToast(res.message || 'Returned', 'ok');
            setTimeout(function () { location.reload(); }, 1500);
        } else {
            showPaToast(res.error || 'Failed', 'err');
        }
    });
}

function adminCancel(rid) {
    openAdminModal('Cancel Appraisal',
        '<p>Are you sure you want to cancel this appraisal record? This will prevent any further action on it.</p>' +
        '<textarea id="adminCancelComment" placeholder="Reason for cancellation (optional)..." maxlength="1000"></textarea>',
        '<button type="button" class="hr-btn hr-btn--outline" onclick="closeAdminModal()">Cancel</button>' +
        '<button type="button" class="hr-btn hr-btn--danger" id="btnAdminCancel" onclick="confirmAdminCancel(' + rid + ')">Confirm Cancel</button>'
    );
}

function confirmAdminCancel(rid) {
    if (_adminBusy) return;
    _adminBusy = true;
    var comment = (document.getElementById('adminCancelComment') || {}).value || '';
    var btn = document.getElementById('btnAdminCancel');
    if (btn) { btn.disabled = true; btn.textContent = 'Cancelling...'; }

    adminAjax('admin_cancel', { rid: rid, comment: comment.trim() }, function (res) {
        _adminBusy = false;
        closeAdminModal();
        if (res.ok) {
            showPaToast(res.message || 'Cancelled', 'ok');
            setTimeout(function () { location.reload(); }, 1500);
        } else {
            showPaToast(res.error || 'Failed', 'err');
        }
    });
}

function adminReopen(rid) {
    if (_adminBusy) return;
    if (!confirm('Re-open this appraisal? It will be set back to Supervisor In Progress status.')) return;
    _adminBusy = true;

    adminAjax('admin_reopen', { rid: rid }, function (res) {
        _adminBusy = false;
        if (res.ok) {
            showPaToast(res.message || 'Re-opened', 'ok');
            setTimeout(function () { location.reload(); }, 1500);
        } else {
            showPaToast(res.error || 'Failed', 'err');
        }
    });
}

function adminAjax(action, data, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'AppraisalView.aspx?ajax=' + action, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status === 200) {
            try { callback(JSON.parse(xhr.responseText)); }
            catch (e) { callback({ ok: false, error: 'Invalid response' }); }
        } else {
            callback({ ok: false, error: 'Server error (HTTP ' + xhr.status + ')' });
        }
    };
    xhr.send(JSON.stringify(data));
}

function showPaToast(msg, type) {
    var toast = document.getElementById('paToast');
    if (!toast) return;
    toast.textContent = msg;
    toast.className = 'pa-toast pa-toast--' + (type || 'ok') + ' is-visible';
    clearTimeout(toast._timer);
    toast._timer = setTimeout(function () {
        toast.classList.remove('is-visible');
    }, 3500);
}
</script>

</asp:Content>
