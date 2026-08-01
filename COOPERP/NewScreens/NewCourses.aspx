<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewCourses.aspx.cs" Inherits="COOPERP_NewScreens_NewCourses" Title="Courses - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ---- Buttons ---- */
.hr-btn { display:inline-flex; align-items:center; gap:5px; padding:6px 14px; font-size:12px; font-weight:600; border:none; cursor:pointer; border-radius:0; line-height:1.4; text-decoration:none; transition:background .15s; }
.hr-btn--primary { background:#05275C; color:#fff; }
.hr-btn--primary:hover { background:#041d45; color:#fff; }
.hr-btn--outline { background:#fff; color:#05275C; border:1px solid #05275C; }
.hr-btn--outline:hover { background:#f0f4fa; }

/* ---- Stats strip ---- */
.stats-strip { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:12px; margin-bottom:16px; }
.stat-box { background:#fff; border:1px solid #e0e5ed; padding:12px; text-align:center; border-left:4px solid #05275C; }
.stat-box--active { border-left-color:#16a34a; }
.stat-box--inactive { border-left-color:#dc3545; }
.stat-box__value { font-size:18px; font-weight:700; color:#05275C; line-height:1.2; }
.stat-box--active .stat-box__value { color:#16a34a; }
.stat-box--inactive .stat-box__value { color:#dc3545; }
.stat-box__label { font-size:11px; color:#666; text-transform:uppercase; letter-spacing:.3px; margin-top:3px; font-weight:600; }

/* ---- Filter bar ---- */
.filter-bar { background:#fff; border:1px solid #e0e5ed; padding:12px; margin-bottom:16px; display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
.filter-bar__title { font-size:13px; font-weight:700; color:#05275C; margin-right:4px; }
.filter-bar label { font-size:12px; color:#666; font-weight:600; margin:0; }
.filter-bar select, .filter-bar input[type="text"] { font-size:12px; border:1px solid #cdd3de; padding:6px 10px; color:#1a1a2e; background:#fff; height:32px; border-radius:0; }
.filter-bar input[type="text"] { min-width:240px; }
.filter-bar input[type="text"]::placeholder { color:#aaa; }
.filter-bar .filter-divider { width:1px; height:20px; background:#e0e5ed; }
.filter-bar__spacer { margin-left:auto; }

/* ---- Courses list ---- */
.cb-list-wrap { background:#fff; border:1px solid #e0e5ed; overflow-x:auto; }
.cb-list { width:100%; border-collapse:collapse; font-size:12px; }
.cb-list thead th { background:#f5f7fa; border-bottom:1px solid #e0e5ed; padding:9px 12px; text-align:left; font-weight:700; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#555; white-space:nowrap; }
.cb-list tbody td { border-bottom:1px solid #eef1f5; padding:8px 12px; vertical-align:middle; color:#1a1a2e; }
.cb-list tbody tr:hover { background:#f8fafd; }
.cb-list tbody tr:last-child td { border-bottom:none; }
.cb-code { font-weight:700; color:#05275C; }
.cb-name { font-weight:600; color:#1a1a2e; line-height:1.3; }
.cb-sub { font-size:10px; color:#94a3b8; margin-top:1px; }
.cb-center { text-align:center; }
.cb-actions { white-space:nowrap; text-align:right; }
.cb-act { padding:3px 9px; font-size:11px; font-weight:600; border:1px solid #cdd3de; background:#fff; color:#05275C; cursor:pointer; border-radius:0; margin-left:4px; transition:background .15s; }
.cb-act:hover { background:#eef2f8; }
.cb-act--danger { color:#dc3545; border-color:#f0b8bd; }
.cb-act--danger:hover { background:#fef5f5; }
.cb-loading, .cb-empty-row { text-align:center; padding:28px 16px; color:#94a3b8; font-size:12px; }

/* ---- Badges ---- */
.badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:700; border-radius:0; border:1px solid transparent; }
.badge-active   { background:#dcfce7; color:#15803d; border-color:#bbf7d0; }
.badge-inactive { background:#f1f5f9; color:#64748b; border-color:#e2e8f0; }
.badge-core     { background:#eff6ff; color:#1d4ed8; border-color:#bfdbfe; }
.badge-optional { background:#fef3c7; color:#b45309; border-color:#fde68a; }

/* ---- Pager ---- */
.cb-pager { display:flex; align-items:center; gap:10px; padding:10px 12px; background:#fff; border:1px solid #e0e5ed; border-top:none; flex-wrap:wrap; font-size:12px; color:#64748b; }
.cb-pager__info { font-weight:600; }
.cb-pager__spacer { margin-left:auto; }
.cb-pager button { padding:4px 10px; font-size:12px; font-weight:600; border:1px solid #cdd3de; background:#fff; color:#05275C; cursor:pointer; border-radius:0; }
.cb-pager button:hover:not(:disabled) { background:#eef2f8; }
.cb-pager button:disabled { color:#cbd5e1; cursor:default; }
.cb-pager select { font-size:12px; border:1px solid #cdd3de; padding:3px 6px; height:28px; border-radius:0; }

/* ---- Modal ---- */
.hr-modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:10000; display:flex; align-items:center; justify-content:center; }
.hr-modal { background:#fff; width:640px; max-width:96vw; max-height:92vh; overflow-y:auto; border-radius:2px; box-shadow:0 8px 32px rgba(0,0,0,.2); }
.hr-modal-header { display:flex; align-items:center; justify-content:space-between; padding:14px 20px; background:#05275C; color:#fff; }
.hr-modal-header h4 { margin:0; font-size:14px; font-weight:700; }
.hr-modal-close { background:none; border:none; color:#fff; font-size:20px; cursor:pointer; line-height:1; padding:0 2px; }
.hr-modal-close:hover { color:#ccd; }
.hr-modal-body { padding:20px; }
.hr-modal-footer { padding:14px 20px; border-top:1px solid #e0e5ed; display:flex; gap:8px; justify-content:flex-end; }

/* ---- Form ---- */
.hr-form-group { margin-bottom:14px; }
.hr-form-group label { display:block; font-size:12px; font-weight:600; color:#444; margin-bottom:5px; }
.hr-form-group label .req { color:#dc3545; margin-left:2px; }
.hr-input, .hr-select, .hr-textarea { width:100%; padding:7px 10px; font-size:13px; border:1px solid #cdd3de; border-radius:0; background:#fff; color:#1a1a2e; box-sizing:border-box; }
.hr-input:focus, .hr-select:focus, .hr-textarea:focus { outline:none; border-color:#174DA4; }
.hr-input[readonly] { background:#f5f7fa; color:#666; }
.hr-textarea { resize:vertical; min-height:60px; font-family:inherit; }
.hr-form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
.hr-form-row--3 { grid-template-columns:1fr 1fr 1fr; }
.hr-form-hint { font-size:11px; color:#888; margin-top:3px; }
.form-result { padding:8px 12px; font-size:12px; font-weight:600; margin-bottom:12px; display:none; }
.form-result.error   { background:#fef5f5; color:#dc3545; border:1px solid #fecaca; }
.form-result.success { background:#f0fdf4; color:#15803d; border:1px solid #bbf7d0; }

@media (max-width:600px) {
    .hr-form-row, .hr-form-row--3 { grid-template-columns:1fr; }
    .hr-modal { width:100%; max-height:100vh; }
    .filter-bar input[type="text"] { min-width:0; flex:1; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- Hidden postback infrastructure -->
    <asp:HiddenField ID="hdnEditCourseId" runat="server" />
    <asp:HiddenField ID="hdnModalMode"   runat="server" />  <%-- NEW or EDIT --%>
    <asp:Button ID="btnSaveCourse"   runat="server" style="display:none" OnClick="btnSaveCourse_Click" />
    <asp:Button ID="btnDeleteCourse" runat="server" style="display:none" OnClick="btnDeleteCourse_Click" />

    <!-- Stats strip -->
    <div class="stats-strip">
        <div class="stat-box">
            <div class="stat-box__value" id="statTotal">0</div>
            <div class="stat-box__label">Total Courses</div>
        </div>
        <div class="stat-box stat-box--active">
            <div class="stat-box__value" id="statActive">0</div>
            <div class="stat-box__label">Active</div>
        </div>
        <div class="stat-box stat-box--inactive">
            <div class="stat-box__value" id="statInactive">0</div>
            <div class="stat-box__label">Inactive</div>
        </div>
        <div class="stat-box">
            <div class="stat-box__value" id="statCredits">0</div>
            <div class="stat-box__label">Total Credit Units</div>
        </div>
    </div>

    <!-- Filter bar -->
    <div class="filter-bar">
        <span class="filter-bar__title">Course Bank</span>
        <input type="text" id="cbSearch" placeholder="Search by code or course name…" />
        <select id="cbFilterType">
            <option value="">All Types</option>
            <option value="Core">Core</option>
            <option value="Optional">Optional</option>
        </select>
        <select id="cbFilterStatus">
            <option value="">All Status</option>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
        </select>
        <div class="filter-divider"></div>
        <button type="button" class="hr-btn hr-btn--outline" onclick="cbResetFilters()">Clear</button>
        <span class="filter-bar__spacer"></span>
        <button type="button" class="hr-btn hr-btn--primary" onclick="openCourseModal('NEW')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Add Course
        </button>
    </div>

    <!-- Courses list (loaded via GET) -->
    <div class="cb-list-wrap">
        <table class="cb-list">
            <thead>
                <tr>
                    <th style="width:120px;">Code</th>
                    <th>Course Name</th>
                    <th style="width:64px;text-align:center;">Credits</th>
                    <th style="width:70px;text-align:center;">Contact</th>
                    <th style="width:70px;text-align:center;">Lecture</th>
                    <th style="width:78px;text-align:center;">Practical</th>
                    <th style="width:90px;text-align:center;">Type</th>
                    <th style="width:90px;text-align:center;">Status</th>
                    <th style="width:140px;text-align:right;">Actions</th>
                </tr>
            </thead>
            <tbody id="cbListBody">
                <tr><td colspan="9" class="cb-loading">Loading courses…</td></tr>
            </tbody>
        </table>
    </div>
    <div class="cb-pager">
        <span class="cb-pager__info" id="cbPagerInfo">—</span>
        <span class="cb-pager__spacer"></span>
        <label>Rows:</label>
        <select id="cbPageSize" onchange="cbSetPageSize(this.value)">
            <option value="25">25</option>
            <option value="50" selected="selected">50</option>
            <option value="100">100</option>
            <option value="200">200</option>
        </select>
        <button type="button" id="cbPrev" onclick="cbGoPage(-1)">&laquo; Prev</button>
        <span id="cbPageLabel">1 / 1</span>
        <button type="button" id="cbNext" onclick="cbGoPage(1)">Next &raquo;</button>
    </div>

    <!-- ===== Create / Edit Modal ===== -->
    <div id="courseModal" class="hr-modal-overlay" style="display:none">
        <div class="hr-modal">
            <div class="hr-modal-header">
                <h4 id="cbModalTitle">New Course</h4>
                <button type="button" class="hr-modal-close" onclick="closeCourseModal()">&times;</button>
            </div>
            <div class="hr-modal-body">
                <div id="cbModalResult" class="form-result"></div>

                <div class="hr-form-row">
                    <div class="hr-form-group">
                        <label>Course Code <span class="req">*</span></label>
                        <asp:TextBox ID="txtCourseId" runat="server" CssClass="hr-input" MaxLength="25" placeholder="e.g. CSC1101" />
                        <div class="hr-form-hint">Unique identifier. Cannot be changed after creation.</div>
                    </div>
                    <div class="hr-form-group">
                        <label>Credit Units</label>
                        <asp:TextBox ID="txtCredit" runat="server" CssClass="hr-input" TextMode="Number" placeholder="e.g. 3" />
                    </div>
                </div>

                <div class="hr-form-group">
                    <label>Course Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtCourseName" runat="server" CssClass="hr-input" MaxLength="250" placeholder="e.g. Introduction to Computer Science" />
                </div>

                <div class="hr-form-row hr-form-row--3">
                    <div class="hr-form-group">
                        <label>Contact Hours</label>
                        <asp:TextBox ID="txtContact" runat="server" CssClass="hr-input" TextMode="Number" placeholder="0" />
                    </div>
                    <div class="hr-form-group">
                        <label>Lecture Hours</label>
                        <asp:TextBox ID="txtLecture" runat="server" CssClass="hr-input" TextMode="Number" placeholder="0" />
                    </div>
                    <div class="hr-form-group">
                        <label>Practical Hours</label>
                        <asp:TextBox ID="txtPractical" runat="server" CssClass="hr-input" TextMode="Number" placeholder="0" />
                    </div>
                </div>

                <div class="hr-form-row">
                    <div class="hr-form-group">
                        <label>Course Type</label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="hr-select">
                            <asp:ListItem Value="Core" Text="Core" />
                            <asp:ListItem Value="Optional" Text="Optional" />
                        </asp:DropDownList>
                    </div>
                    <div class="hr-form-group">
                        <label>Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="hr-select">
                            <asp:ListItem Value="Active" Text="Active" />
                            <asp:ListItem Value="Inactive" Text="Inactive" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="hr-form-group">
                    <label>Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="3" placeholder="Optional course description…" />
                </div>
            </div>
            <div class="hr-modal-footer">
                <button type="button" class="hr-btn hr-btn--outline" onclick="closeCourseModal()">Cancel</button>
                <button type="button" class="hr-btn hr-btn--primary" onclick="saveCourse()">Save Course</button>
            </div>
        </div>
    </div>

<!-- ===== JavaScript ===== -->
<script type="text/javascript">
var _cbAll = [];        // full dataset
var _cbFiltered = [];   // after filters
var _cbPage = 1;
var _cbPageSize = 50;

function cbInit() {
    document.getElementById('cbSearch').addEventListener('input', cbApplyFilters);
    document.getElementById('cbFilterType').addEventListener('change', cbApplyFilters);
    document.getElementById('cbFilterStatus').addEventListener('change', cbApplyFilters);
    cbLoad();
}

/* ---- Load listing via GET ---- */
function cbLoad() {
    var body = document.getElementById('cbListBody');
    if (body) body.innerHTML = '<tr><td colspan="9" class="cb-loading">Loading courses…</td></tr>';
    fetch(location.pathname + '?act=list', { credentials: 'same-origin', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (data && data.error) {
                if (body) body.innerHTML = '<tr><td colspan="9" class="cb-empty-row" style="color:#dc2626">Error: ' + _esc(data.error) + '</td></tr>';
                return;
            }
            _cbAll = data || [];
            cbUpdateStats();
            _cbPage = 1;
            cbApplyFilters();
        })
        .catch(function () {
            if (body) body.innerHTML = '<tr><td colspan="9" class="cb-empty-row" style="color:#dc2626">Failed to load courses. Please refresh.</td></tr>';
        });
}

function _isActive(c) { return (c.stat || '').toLowerCase() === 'active'; }

function cbApplyFilters() {
    var q = document.getElementById('cbSearch').value.toLowerCase().trim();
    var ft = document.getElementById('cbFilterType').value;
    var fs = document.getElementById('cbFilterStatus').value;

    _cbFiltered = _cbAll.filter(function (c) {
        var mq = !q || (c.code && c.code.toLowerCase().indexOf(q) !== -1) || (c.name && c.name.toLowerCase().indexOf(q) !== -1);
        var mt = !ft || (c.type || '') === ft;
        var ms = !fs || (fs === 'Active' ? _isActive(c) : !_isActive(c));
        return mq && mt && ms;
    });
    _cbPage = 1;
    cbRender();
}

function cbRender() {
    var body = document.getElementById('cbListBody');
    if (!body) return;

    var n = _cbFiltered.length;
    var pages = Math.max(1, Math.ceil(n / _cbPageSize));
    if (_cbPage > pages) _cbPage = pages;
    var start = (_cbPage - 1) * _cbPageSize;
    var slice = _cbFiltered.slice(start, start + _cbPageSize);

    if (!n) {
        body.innerHTML = '<tr><td colspan="9" class="cb-empty-row">No courses match your filters.</td></tr>';
    } else {
        body.innerHTML = slice.map(function (c) {
            var active = _isActive(c);
            var type = c.type || '';
            return '<tr>' +
                '<td><span class="cb-code">' + _esc(c.code) + '</span></td>' +
                '<td><div class="cb-name">' + _esc(c.name || '') + '</div></td>' +
                '<td class="cb-center">' + _num(c.credit) + '</td>' +
                '<td class="cb-center">' + _num(c.contact) + '</td>' +
                '<td class="cb-center">' + _num(c.lecture) + '</td>' +
                '<td class="cb-center">' + _num(c.practical) + '</td>' +
                '<td class="cb-center">' + (type ? '<span class="badge ' + (type === 'Core' ? 'badge-core' : 'badge-optional') + '">' + _esc(type) + '</span>' : '<span class="cb-sub">—</span>') + '</td>' +
                '<td class="cb-center"><span class="badge ' + (active ? 'badge-active' : 'badge-inactive') + '">' + (active ? 'Active' : 'Inactive') + '</span></td>' +
                '<td class="cb-actions">' +
                    '<button type="button" class="cb-act" onclick="editCourse(\'' + _escA(c.code) + '\')">Edit</button>' +
                    '<button type="button" class="cb-act cb-act--danger" onclick="deleteCourse(\'' + _escA(c.code) + '\',\'' + _escA(c.name || '') + '\')">Delete</button>' +
                '</td>' +
            '</tr>';
        }).join('');
    }

    // pager
    document.getElementById('cbPageLabel').textContent = _cbPage + ' / ' + pages;
    document.getElementById('cbPrev').disabled = (_cbPage <= 1);
    document.getElementById('cbNext').disabled = (_cbPage >= pages);
    var from = n ? (start + 1) : 0;
    var to = Math.min(start + _cbPageSize, n);
    document.getElementById('cbPagerInfo').textContent = 'Showing ' + from.toLocaleString() + '–' + to.toLocaleString() + ' of ' + n.toLocaleString() + (n !== _cbAll.length ? ' (filtered from ' + _cbAll.length.toLocaleString() + ')' : '');
}

function cbGoPage(d) { _cbPage += d; cbRender(); }
function cbSetPageSize(v) { _cbPageSize = parseInt(v, 10) || 50; _cbPage = 1; cbRender(); }

function cbResetFilters() {
    document.getElementById('cbSearch').value = '';
    document.getElementById('cbFilterType').value = '';
    document.getElementById('cbFilterStatus').value = '';
    cbApplyFilters();
}

function cbUpdateStats() {
    var total = _cbAll.length;
    var active = _cbAll.filter(_isActive).length;
    var credits = _cbAll.reduce(function (s, c) { return s + (parseFloat(c.credit) || 0); }, 0);
    document.getElementById('statTotal').textContent = total.toLocaleString();
    document.getElementById('statActive').textContent = active.toLocaleString();
    document.getElementById('statInactive').textContent = (total - active).toLocaleString();
    document.getElementById('statCredits').textContent = credits.toLocaleString(undefined, { maximumFractionDigits: 1 });
}

/* ---- Modal ---- */
function _cbFind(code) {
    for (var i = 0; i < _cbAll.length; i++) if (_cbAll[i].code === code) return _cbAll[i];
    return null;
}

function openCourseModal(mode, course) {
    document.getElementById('cbModalResult').style.display = 'none';
    document.getElementById('<%= hdnModalMode.ClientID %>').value = mode;
    document.getElementById('cbModalTitle').textContent = (mode === 'EDIT') ? 'Edit Course' : 'New Course';

    var idBox = document.getElementById('<%= txtCourseId.ClientID %>');
    var setV = function (id, v) { var el = document.getElementById(id); if (el) el.value = (v == null ? '' : v); };

    if (mode === 'EDIT' && course) {
        document.getElementById('<%= hdnEditCourseId.ClientID %>').value = course.code;
        setV('<%= txtCourseId.ClientID %>', course.code);
        setV('<%= txtCourseName.ClientID %>', course.name);
        setV('<%= txtCredit.ClientID %>', course.credit);
        setV('<%= txtContact.ClientID %>', course.contact);
        setV('<%= txtLecture.ClientID %>', course.lecture);
        setV('<%= txtPractical.ClientID %>', course.practical);
        setV('<%= txtDescription.ClientID %>', course.description);
        document.getElementById('<%= ddlType.ClientID %>').value = (course.type === 'Optional') ? 'Optional' : 'Core';
        document.getElementById('<%= ddlStatus.ClientID %>').value = _isActive(course) ? 'Active' : 'Inactive';
        idBox.readOnly = true; idBox.style.background = '#f5f7fa'; idBox.style.color = '#666';
    } else {
        document.getElementById('<%= hdnEditCourseId.ClientID %>').value = '';
        setV('<%= txtCourseId.ClientID %>', ''); setV('<%= txtCourseName.ClientID %>', '');
        setV('<%= txtCredit.ClientID %>', ''); setV('<%= txtContact.ClientID %>', '');
        setV('<%= txtLecture.ClientID %>', ''); setV('<%= txtPractical.ClientID %>', '');
        setV('<%= txtDescription.ClientID %>', '');
        document.getElementById('<%= ddlType.ClientID %>').value = 'Core';
        document.getElementById('<%= ddlStatus.ClientID %>').value = 'Active';
        idBox.readOnly = false; idBox.style.background = ''; idBox.style.color = '';
    }
    document.getElementById('courseModal').style.display = 'flex';
}

function editCourse(code) {
    var c = _cbFind(code);
    if (c) openCourseModal('EDIT', c);
}

function closeCourseModal() { document.getElementById('courseModal').style.display = 'none'; }

function saveCourse() {
    var code = document.getElementById('<%= txtCourseId.ClientID %>').value.trim();
    var name = document.getElementById('<%= txtCourseName.ClientID %>').value.trim();
    if (!code) { cbModalError('Course Code is required.'); return; }
    if (!name) { cbModalError('Course Name is required.'); return; }
    document.getElementById('<%= btnSaveCourse.ClientID %>').click();
}

function cbModalError(msg) {
    var el = document.getElementById('cbModalResult');
    el.className = 'form-result error'; el.textContent = msg; el.style.display = 'block';
}

function deleteCourse(code, name) {
    if (!confirm('Delete course "' + name + '" (' + code + ')?\n\nThis cannot be undone.')) return;
    document.getElementById('<%= hdnEditCourseId.ClientID %>').value = code;
    document.getElementById('<%= btnDeleteCourse.ClientID %>').click();
}

/* ---- Toast ---- */
function cbToast(msg, type) {
    var t = document.createElement('div');
    t.textContent = msg;
    t.style.cssText = 'position:fixed;top:20px;right:20px;z-index:11000;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;border-radius:0;box-shadow:0 4px 16px rgba(0,0,0,.2);background:' + (type === 'error' ? '#dc3545' : '#16a34a') + ';';
    document.body.appendChild(t);
    setTimeout(function () { t.style.transition = 'opacity .4s'; t.style.opacity = '0'; setTimeout(function () { t.remove(); }, 400); }, 2600);
}

/* ---- helpers ---- */
function _esc(s) { var d = document.createElement('div'); d.appendChild(document.createTextNode(s == null ? '' : s)); return d.innerHTML; }
function _escA(s) { return (s == null ? '' : String(s)).replace(/\\/g, '\\\\').replace(/'/g, "\\'"); }
function _num(v) { var n = parseFloat(v); if (isNaN(n)) return '<span class="cb-sub">—</span>'; return (n % 1 === 0) ? n.toString() : n.toFixed(1); }

/* ---- Boot (script is after all referenced markup, so run now) ---- */
cbInit();
</script>

</asp:Content>
