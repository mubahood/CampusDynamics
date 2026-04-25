<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ProvisionalMarksReleaseController.aspx.cs" Inherits="COOPERP_NewScreens_ProvisionalMarksReleaseController" Title="Provisional Marks Release Controller - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.rl-hero { background:#05275C; color:#fff; padding:16px 18px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; }
.rl-hero__title { font-size:17px; font-weight:800; margin:0 0 4px; }
.rl-hero__sub { font-size:12px; opacity:.82; margin:0; }
.rl-hero__actions { display:flex; gap:8px; flex-wrap:wrap; }
.rl-stats { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-bottom:16px; }
.rl-stat { background:#fff; border:1px solid #e0e5ed; padding:14px; }
.rl-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; font-weight:700; }
.rl-stat__value { font-size:22px; color:#05275C; font-weight:800; margin-top:8px; }
.rl-card { background:#fff; border:1px solid #e0e5ed; margin-bottom:16px; }
.rl-card__head { display:flex; justify-content:space-between; align-items:center; gap:10px; padding:12px 14px; border-bottom:2px solid #e0e5ed; background:#f8fafc; flex-wrap:wrap; }
.rl-card__title { font-size:12px; font-weight:800; color:#05275C; text-transform:uppercase; letter-spacing:.4px; }
.rl-btn { display:inline-flex; align-items:center; gap:6px; padding:8px 12px; border:1px solid #d2dae6; background:#fff; color:#05275C; text-decoration:none; font-size:12px; font-weight:700; cursor:pointer; }
.rl-btn:hover { background:#f5f8ff; border-color:#174DA4; color:#174DA4; }
.rl-btn--primary { background:#05275C; border-color:#05275C; color:#fff; }
.rl-btn--primary:hover { background:#174DA4; border-color:#174DA4; color:#fff; }
.rl-btn--warning { background:#b45309; border-color:#b45309; color:#fff; }
.rl-btn--warning:hover { background:#d97706; border-color:#d97706; color:#fff; }
.rl-btn--success { background:#2e7d32; border-color:#2e7d32; color:#fff; }
.rl-btn--success:hover { background:#1b5e20; border-color:#1b5e20; color:#fff; }
.rl-btn--sm { padding:5px 10px; font-size:11px; }
.rl-btn:disabled { opacity:.45; cursor:not-allowed; }
.rl-filters { padding:12px 14px; border-bottom:1px solid #e8edf3; background:#f8fafc; }
.rl-filter-grid { display:flex; flex-wrap:wrap; gap:10px; align-items:flex-end; }
.rl-fg { display:flex; flex-direction:column; gap:4px; min-width:130px; }
.rl-fg--wide { min-width:240px; flex:1; }
.rl-fg label { font-size:10px; text-transform:uppercase; letter-spacing:.35px; color:#6b7280; font-weight:700; }
.rl-input,.rl-select { border:1px solid #cfd8e3; background:#fff; color:#1a1a2e; font-size:11px; padding:7px 8px; height:32px; }
.rl-meta { display:flex; justify-content:space-between; align-items:center; gap:8px; padding:8px 14px; border-bottom:1px solid #eef1f5; font-size:11px; color:#4b5563; background:#fff; }
.rl-meta strong { color:#05275C; }
.rl-table-wrap { overflow-x:auto; }
.rl-table { width:100%; border-collapse:collapse; }
.rl-table th { background:#f8fafc; border-bottom:2px solid #e0e5ed; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; padding:9px 10px; text-align:left; white-space:nowrap; }
.rl-table td { border-bottom:1px solid #eef2f6; font-size:12px; color:#1f2937; padding:9px 10px; vertical-align:middle; }
.rl-table tbody tr:hover td { background:#f9fbff; }
.rl-code { font-family:Consolas,"Courier New",monospace; font-size:11px; color:#174DA4; font-weight:700; white-space:nowrap; }
.rl-center { text-align:center; }
.rl-muted { color:#6b7280; font-size:11px; }
.rl-pill { display:inline-block; padding:3px 8px; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.35px; }
.rl-pill--pending { background:#fde8e8; color:#b42318; }
.rl-pill--approved { background:#e6f4ea; color:#2e7d32; }
.rl-pill--rejected { background:#fff4e5; color:#b45309; }
.rl-actions { display:flex; gap:5px; align-items:center; justify-content:center; }
.rl-empty { padding:28px; text-align:center; font-size:12px; color:#6b7280; }
.rl-pager { display:flex; justify-content:space-between; align-items:center; gap:8px; padding:10px 14px; border-top:1px solid #e0e5ed; background:#f8fafc; flex-wrap:wrap; font-size:11px; color:#4b5563; }
.rl-pager__links { display:flex; gap:4px; flex-wrap:wrap; }
.rl-pager__links a,.rl-pager__links span { border:1px solid #d4dbe8; background:#fff; color:#334155; font-size:11px; text-decoration:none; padding:4px 9px; }
.rl-pager__links .active { background:#05275C; border-color:#05275C; color:#fff; }
.pm-toast { position:fixed; bottom:20px; right:20px; background:#1f2937; color:#fff; font-size:12px; font-weight:600; padding:10px 16px; border-radius:2px; z-index:9999; display:none; }
.pm-toast.show { display:block; }
.pm-toast.ok { background:#2e7d32; }
.pm-toast.err { background:#c62828; }
.pm-tools { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.pm-tool { border:1px solid #e0e5ed; background:#fff; padding:12px; }
.pm-tool__title { font-size:11px; font-weight:800; text-transform:uppercase; color:#05275C; letter-spacing:.35px; margin-bottom:10px; }
.pm-pill { display:inline-block; padding:2px 7px; font-size:9px; font-weight:800; text-transform:uppercase; letter-spacing:.3px; }
.pm-pill--ok { background:#e6f4ea; color:#2e7d32; }
.pm-pill--warn { background:#fff4e5; color:#b45309; }
.pm-quickbar { padding:8px 14px; border-bottom:1px solid #eef1f5; background:#fff; display:flex; justify-content:space-between; gap:8px; flex-wrap:wrap; }
.pm-quickcount { font-size:11px; color:#64748b; font-weight:700; }
.pm-note { font-size:10px; color:#64748b; }
@media (max-width:980px) { .rl-stats { grid-template-columns:repeat(2,minmax(0,1fr)); } .pm-tools { grid-template-columns:1fr; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div id="pmToast" class="pm-toast"></div>

<div class="rl-hero">
    <div>
        <h1 class="rl-hero__title">Provisional Marks Release Controller</h1>
        <p class="rl-hero__sub">Admin release panel for marks not yet released to final results.</p>
    </div>
    <div class="rl-hero__actions">
        <button type="button" class="rl-btn rl-btn--success rl-btn--sm" onclick="publishSelected()">Release Selected</button>
    </div>
</div>

<div class="rl-stats">
    <div class="rl-stat"><div class="rl-stat__label">Unreleased Records</div><div class="rl-stat__value"><asp:Literal ID="litUnreleased" runat="server">0</asp:Literal></div></div>
    <div class="rl-stat"><div class="rl-stat__label">Ready to Release</div><div class="rl-stat__value"><asp:Literal ID="litApprovedReady" runat="server">0</asp:Literal></div></div>
    <div class="rl-stat"><div class="rl-stat__label">Pending / Rejected</div><div class="rl-stat__value"><asp:Literal ID="litNeedsAttention" runat="server">0</asp:Literal></div></div>
    <div class="rl-stat"><div class="rl-stat__label">Published</div><div class="rl-stat__value"><asp:Literal ID="litPublished" runat="server">0</asp:Literal></div></div>
</div>

<div class="rl-card">
    <div class="rl-card__head"><span class="rl-card__title">Release Actions</span></div>
    <div style="padding:12px 14px;">
        <div class="pm-tools">
            <div class="pm-tool">
                <div class="pm-tool__title">Batch Release (Current Filter)</div>
                <div class="rl-muted" style="margin-bottom:8px;">Releases all rows matching current filter selection below.</div>
                <button type="button" class="rl-btn rl-btn--primary rl-btn--sm" onclick="publishFiltered()">Release Filtered Batch</button>
            </div>
            <div class="pm-tool">
                <div class="pm-tool__title">Specific Release</div>
                <div class="rl-filter-grid">
                    <div class="rl-fg"><label>Reg No</label><input type="text" id="spRegno" class="rl-input" placeholder="e.g. 22/U/001" /></div>
                    <div class="rl-fg"><label>Course</label><input type="text" id="spCourse" class="rl-input" placeholder="Course code" /></div>
                    <div class="rl-fg"><label>Year</label><input type="text" id="spYear" class="rl-input" placeholder="2025/2026" /></div>
                    <div class="rl-fg"><label>Semester</label><input type="text" id="spSem" class="rl-input" placeholder="1" /></div>
                </div>
                <div style="margin-top:8px;"><button type="button" class="rl-btn rl-btn--primary rl-btn--sm" onclick="publishSpecific()">Release Specific</button></div>
            </div>
            <div class="rl-action-box">
                <div class="rl-action-box__label">Repair Published Record</div>
                <div class="rl-action-box__desc">Fix missing study-year / grade-point for an already-published student (run if StudentResults shows blank rows).</div>
                <div class="rl-fg-row">
                    <div class="rl-fg"><label>Reg No</label><input type="text" id="rpRegno" class="rl-input" placeholder="e.g. MRU2027000002" /></div>
                </div>
                <div style="margin-top:8px;"><button type="button" class="rl-btn rl-btn--warning rl-btn--sm" onclick="repairRecord()">Repair</button></div>
            </div>
        </div>
    </div>
</div>

<div class="rl-card">
    <div class="rl-card__head">
        <span class="rl-card__title">Unreleased Provisional Marks</span>
        <div style="display:flex;gap:8px;align-items:center;">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="rl-input" placeholder="Search regno / course…" style="width:180px;" onkeydown="if(event.key==='Enter')applyFilters();" />
        </div>
    </div>
    <div class="rl-filters">
        <div class="rl-filter-grid">
            <div class="rl-fg">
                <label>Academic Year</label>
                <asp:DropDownList ID="ddlYear" runat="server" CssClass="rl-select" />
            </div>
            <div class="rl-fg">
                <label>Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="">All</asp:ListItem>
                    <asp:ListItem Value="1">1</asp:ListItem>
                    <asp:ListItem Value="2">2</asp:ListItem>
                    <asp:ListItem Value="3">3</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="">All Unreleased</asp:ListItem>
                    <asp:ListItem Value="ready">Ready (Approved + Complete)</asp:ListItem>
                    <asp:ListItem Value="incomplete">Incomplete Marks</asp:ListItem>
                    <asp:ListItem Value="approved">Approved</asp:ListItem>
                    <asp:ListItem Value="pending">Pending</asp:ListItem>
                    <asp:ListItem Value="rejected">Rejected</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg rl-fg--wide">
                <label>Programme</label>
                <asp:DropDownList ID="ddlProg" runat="server" CssClass="rl-select" />
            </div>
            <div class="rl-fg">
                <label>Rows / Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="rl-select">
                    <asp:ListItem Value="25">25</asp:ListItem>
                    <asp:ListItem Value="50" Selected="True">50</asp:ListItem>
                    <asp:ListItem Value="100">100</asp:ListItem>
                    <asp:ListItem Value="200">200</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rl-fg" style="justify-content:flex-end;">
                <button type="button" class="rl-btn rl-btn--primary rl-btn--sm" onclick="applyFilters()">Apply</button>
            </div>
        </div>
    </div>

    <div class="pm-quickbar">
        <div style="display:flex;gap:8px;align-items:end;flex-wrap:wrap;">
            <div class="rl-fg" style="min-width:260px;">
                <label>Quick Search (this page)</label>
                <input type="text" id="pmQuickSearch" class="rl-input" placeholder="Find by reg no, course, staff, comment..." />
            </div>
            <button type="button" class="rl-btn rl-btn--sm" onclick="clearQuickSearch()">Clear</button>
        </div>
        <div class="pm-quickcount" id="pmSelectedCount">0 selected</div>
    </div>

    <div class="rl-meta">
        <span>Showing <strong><asp:Literal ID="litFrom" runat="server">0</asp:Literal></strong> – <strong><asp:Literal ID="litTo" runat="server">0</asp:Literal></strong> of <strong><asp:Literal ID="litTotal" runat="server">0</asp:Literal></strong> records</span>
        <span class="rl-muted">Page <asp:Literal ID="litPage" runat="server">1</asp:Literal> of <asp:Literal ID="litPageCount" runat="server">1</asp:Literal></span>
    </div>

    <div class="rl-table-wrap">
        <table class="rl-table">
            <thead>
                <tr>
                    <th class="rl-center" style="width:36px;"><input type="checkbox" id="chkAll" onclick="toggleAll(this)" /></th>
                    <th class="rl-center" style="width:40px;">SN</th>
                    <th>Reg No</th>
                    <th>Course</th>
                    <th style="text-align:center;">Year / Sem</th>
                    <th style="text-align:center;">CW</th>
                    <th style="text-align:center;">Exam</th>
                    <th style="text-align:center;">Total</th>
                    <th style="text-align:center;">Completion</th>
                    <th style="text-align:center;">Status</th>
                    <th>Submitted By</th>
                    <th>Reviewed By / Date</th>
                    <th>Review Comment</th>
                    <th style="text-align:center;">Action</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litRows" runat="server" />
            </tbody>
        </table>
    </div>

    <div class="rl-pager">
        <span><asp:Literal ID="litTotal2" runat="server">0</asp:Literal> total records</span>
        <div class="rl-pager__links"><asp:Literal ID="litPager" runat="server" /></div>
    </div>
</div>

<script>
function applyFilters() {
    var year   = document.getElementById('<%= ddlYear.ClientID %>').value;
    var sem    = document.getElementById('<%= ddlSemester.ClientID %>').value;
    var status = document.getElementById('<%= ddlStatus.ClientID %>').value;
    var prog   = document.getElementById('<%= ddlProg.ClientID %>').value;
    var size   = document.getElementById('<%= ddlPageSize.ClientID %>').value;
    var q      = document.getElementById('<%= txtSearch.ClientID %>').value;
    window.location.href = 'ProvisionalMarksReleaseController.aspx?pg=1&year=' + encodeURIComponent(year) + '&sem=' + encodeURIComponent(sem) + '&status=' + encodeURIComponent(status) + '&prog=' + encodeURIComponent(prog) + '&size=' + encodeURIComponent(size) + '&q=' + encodeURIComponent(q);
}

function toggleAll(sender) {
    var rows = document.querySelectorAll('.pm-row-check:not([disabled])');
    for (var i = 0; i < rows.length; i++) rows[i].checked = sender.checked;
    updateSelectedCount();
}

function getSelectedIds() {
    var ids = [];
    var rows = document.querySelectorAll('.pm-row-check:checked:not([disabled])');
    for (var i = 0; i < rows.length; i++) {
        var value = parseInt(rows[i].getAttribute('data-id'), 10);
        if (!isNaN(value) && value > 0) ids.push(value);
    }
    return ids;
}

function publishSingle(id) {
    publishIds([id], '1 record');
}

function publishSelected() {
    var ids = getSelectedIds();
    if (!ids.length) { showToast('Select at least one row to release.', 'err'); return; }
    publishIds(ids, ids.length + ' selected records');
}

function publishIds(ids, label) {
    if (!confirm('Release ' + label + ' to final results?')) return;
    callWebMethod('PublishSelectedMarks', { ids: ids }, function (d) {
        if (d.success) {
            showToast('Released: ' + d.released + ', skipped: ' + d.skipped + '.', 'ok');
            setTimeout(function(){ location.reload(); }, 1000);
        } else {
            showToast(d.message || 'Release failed.', 'err');
        }
    });
}

function publishFiltered() {
    var year   = document.getElementById('<%= ddlYear.ClientID %>').value;
    var sem    = document.getElementById('<%= ddlSemester.ClientID %>').value;
    var status = document.getElementById('<%= ddlStatus.ClientID %>').value;
    var prog   = document.getElementById('<%= ddlProg.ClientID %>').value;
    var size   = document.getElementById('<%= ddlPageSize.ClientID %>').value;
    var q      = document.getElementById('<%= txtSearch.ClientID %>').value;

    if (!confirm('Release all rows under current filter?')) return;

    callWebMethod('PublishBatchByFilter', { year: year, sem: sem, status: status, prog: prog, size: size, q: q }, function (d) {
        if (d.success) {
            showToast('Batch released: ' + d.released + ', skipped: ' + d.skipped + '.', 'ok');
            setTimeout(function(){ location.reload(); }, 1000);
        } else {
            showToast(d.message || 'Batch release failed.', 'err');
        }
    });
}

function publishSpecific() {
    var regno = (document.getElementById('spRegno').value || '').trim();
    var courseID = (document.getElementById('spCourse').value || '').trim();
    var acadYear = (document.getElementById('spYear').value || '').trim();
    var semester = (document.getElementById('spSem').value || '').trim();

    if (!regno || !courseID || !acadYear || !semester) {
        showToast('Reg No, Course, Year and Semester are required.', 'err');
        return;
    }

    callWebMethod('PublishSpecificRecord', { regno: regno, courseID: courseID, acadYear: acadYear, semester: semester }, function (d) {
        if (d.success) {
            showToast('Specific record released.', 'ok');
            setTimeout(function(){ location.reload(); }, 1000);
        } else {
            showToast(d.message || 'Specific release failed.', 'err');
        }
    });
}

function repairRecord() {
    var regno = (document.getElementById('rpRegno').value || '').trim();
    if (!regno) { showToast('Reg No is required.', 'err'); return; }
    callWebMethod('RepairReleasedMarks', { regno: regno }, function (d) {
        if (d.success) {
            showToast('Repaired ' + d.repaired + ' record(s) for ' + regno + '.', 'ok');
        } else {
            showToast(d.message || 'Repair failed.', 'err');
        }
    });
}

function showToast(msg, type) {
    var t = document.getElementById('pmToast');
    t.textContent = msg;
    t.className = 'pm-toast show ' + (type || '');
    setTimeout(function(){ t.className = 'pm-toast'; }, 3000);
}

function updateSelectedCount() {
    var count = document.querySelectorAll('.pm-row-check:checked:not([disabled])').length;
    var el = document.getElementById('pmSelectedCount');
    if (el) el.textContent = count + ' selected';
}

function applyQuickSearch() {
    var term = (document.getElementById('pmQuickSearch').value || '').toLowerCase().trim();
    var rows = document.querySelectorAll('tbody tr[data-search]');
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        var txt = (row.getAttribute('data-search') || '').toLowerCase();
        row.style.display = (!term || txt.indexOf(term) >= 0) ? '' : 'none';
    }
}

function clearQuickSearch() {
    var q = document.getElementById('pmQuickSearch');
    if (q) q.value = '';
    applyQuickSearch();
}

function callWebMethod(method, params, cb) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'ProvisionalMarksReleaseController.aspx/' + method, true);
    xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
    xhr.onload = function() {
        try {
            var outer = JSON.parse(xhr.responseText);
            var inner = typeof outer.d === 'string' ? JSON.parse(outer.d) : outer.d;
            cb(inner);
        } catch (e) { cb({ success: false, message: 'Parse error.' }); }
    };
    xhr.onerror = function() { cb({ success: false, message: 'Network error.' }); };
    xhr.send(JSON.stringify(params));
}

document.addEventListener('DOMContentLoaded', function () {
    var quick = document.getElementById('pmQuickSearch');
    if (quick) quick.addEventListener('input', applyQuickSearch);
    var checks = document.querySelectorAll('.pm-row-check');
    for (var i = 0; i < checks.length; i++) checks[i].addEventListener('change', updateSelectedCount);
    updateSelectedCount();
});
</script>
</asp:Content>
