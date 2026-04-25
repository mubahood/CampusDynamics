<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="PortalOnboarding.aspx.cs"
    Inherits="COOPERP_NewScreens_PortalOnboarding"
    Title="Portal Onboarding Status - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Summary cards ───────────────────────────── */
.po-summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:10px;padding:14px 16px;border-bottom:1px solid #e0e5ed;background:#fafbfc;}
.po-card{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;flex-direction:column;gap:2px;}
.po-card__label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#888;}
.po-card__value{font-size:20px;font-weight:800;letter-spacing:-.5px;line-height:1.2;}
.po-card__sub{font-size:10px;color:#999;margin-top:2px;}
.po-card--active .po-card__value{color:#16a34a;}
.po-card--alumni .po-card__value{color:#174DA4;}
.po-card--email .po-card__value{color:#0d6efd;}
.po-card--semreg .po-card__value{color:#f59e0b;}

/* ── Filter bar ──────────────────────────────── */
.po-filters{background:#f8f9fa;border-bottom:1px solid #e0e5ed;padding:8px 12px;}
.po-filters__top{display:flex;align-items:center;gap:8px;margin-bottom:6px;}
.po-search-wrap{position:relative;flex:1;max-width:360px;}
.po-search-wrap__icon{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#999;pointer-events:none;}
.po-search-input{width:100%;border:1px solid #ddd;padding:6px 10px 6px 30px;font-size:12px;background:#fff;font-family:inherit;}
.po-search-input:focus{border-color:#174DA4;outline:none;}
.po-btn-search{border:none;background:#174DA4;color:#fff;padding:6px 14px;font-size:11px;font-weight:600;cursor:pointer;}
.po-btn-reset{border:1px solid #ddd;background:#fff;color:#666;padding:6px 12px;font-size:11px;cursor:pointer;}
.po-btn-new{border:none;background:#16a34a;color:#fff;padding:6px 14px;font-size:11px;font-weight:700;cursor:pointer;}
.po-btn-new:hover{background:#138a3e;}
.po-btn-backfill{border:1px solid #f59e0b;background:#fff7ed;color:#9a3412;padding:6px 12px;font-size:11px;font-weight:700;cursor:pointer;}
.po-btn-backfill:hover{background:#ffedd5;}
.po-filters__count{font-size:11px;color:#174DA4;font-weight:600;margin-left:auto;background:rgba(23,77,164,.07);padding:4px 10px;}
.po-filters__row{display:flex;gap:6px;flex-wrap:wrap;align-items:center;}
.po-filter-grp{display:flex;align-items:center;gap:3px;}
.po-filter-grp__label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.3px;font-weight:600;}
.po-filter-select{border:1px solid #ddd;padding:4px 6px;font-size:11px;min-width:120px;background:#fff;color:#333;font-family:inherit;}
.po-filter-sep{width:1px;height:20px;background:#ddd;margin:0 2px;}

/* ── Table ───────────────────────────────────── */
.po-table-wrap{overflow-x:auto;}
.po-table{width:100%;border-collapse:collapse;font-size:11px;}
.po-table th{background:#f5f7fa;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#666;padding:8px 10px;text-align:left;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.po-table td{padding:7px 10px;border-bottom:1px solid #f0f0f0;color:#333;vertical-align:middle;}
.po-table tr:hover td{background:#f8faff;}
.po-table .po-col-num{width:36px;color:#999;text-align:center;}
.po-table .po-col-regno{font-weight:600;color:#05275C;white-space:nowrap;}

/* ── Badges ──────────────────────────────────── */
.po-badge{display:inline-flex;align-items:center;gap:4px;font-size:10px;font-weight:600;padding:3px 8px;white-space:nowrap;}
.po-badge--active{background:#e8f5e9;color:#2e7d32;}
.po-badge--alumni{background:#e3f2fd;color:#0d47a1;}
.po-yes{color:#16a34a;font-weight:700;font-size:10px;}
.po-no{color:#dc3545;font-size:10px;}

/* ── Pagination ──────────────────────────────── */
.po-pager{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;border-top:1px solid #e0e5ed;font-size:11px;color:#666;background:#fafbfc;}
.po-pager__info{font-weight:500;}
.po-pager__nav{display:flex;gap:4px;}
.po-pager__btn{border:1px solid #ddd;background:#fff;padding:4px 10px;font-size:11px;cursor:pointer;color:#333;font-family:inherit;text-decoration:none;}
.po-pager__btn:hover{background:#f0f4ff;border-color:#174DA4;}

/* ── Edit modal ──────────────────────────────── */
.po-modal-bg{display:none;position:fixed;inset:0;z-index:9000;background:rgba(0,0,0,.45);align-items:center;justify-content:center;}
.po-modal{background:#fff;width:460px;max-width:95vw;border-radius:2px;box-shadow:0 12px 40px rgba(0,0,0,.18);overflow:hidden;}
.po-modal__hdr{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;background:#05275C;color:#fff;}
.po-modal__hdr h3{margin:0;font-size:14px;font-weight:700;}
.po-modal__close{background:none;border:none;color:rgba(255,255,255,.7);font-size:20px;cursor:pointer;line-height:1;padding:0 4px;}
.po-modal__close:hover{color:#fff;}
.po-modal__body{padding:16px;}
.po-modal__row{margin-bottom:12px;}
.po-modal__row label{display:block;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#666;margin-bottom:3px;}
.po-modal__row .po-readonly{font-size:12px;font-weight:600;color:#05275C;padding:6px 0;}
.po-modal__input{width:100%;border:1px solid #ddd;padding:7px 10px;font-size:12px;font-family:inherit;background:#fff;}
.po-modal__input:focus{border-color:#174DA4;outline:none;}
.po-modal__select{width:100%;border:1px solid #ddd;padding:7px 10px;font-size:12px;font-family:inherit;background:#fff;}
.po-modal__foot{display:flex;align-items:center;justify-content:flex-end;gap:8px;padding:12px 16px;border-top:1px solid #e0e5ed;background:#fafbfc;}
.po-modal__btn{padding:7px 18px;font-size:12px;font-weight:600;border:none;cursor:pointer;font-family:inherit;}
.po-modal__btn--save{background:#16a34a;color:#fff;}
.po-modal__btn--save:hover{background:#138a3e;}
.po-modal__btn--cancel{background:#fff;color:#666;border:1px solid #ddd;}
.po-modal__btn--cancel:hover{background:#f5f5f5;}
.po-modal__btn--danger{background:#dc3545;color:#fff;margin-right:auto;}
.po-modal__btn--danger:hover{background:#c82333;}
.po-toast{display:none;padding:8px 12px;font-size:11px;font-weight:600;margin-bottom:10px;}
.po-toast--success{display:block;background:#e8f5e9;color:#2e7d32;border:1px solid #c8e6c9;}
.po-toast--error{display:block;background:#fdecea;color:#c62828;border:1px solid #f5c6cb;}

/* ── Edit link in table ──────────────────────── */
.po-edit-link{font-size:10px;color:#174DA4;cursor:pointer;font-weight:600;text-decoration:none;border:1px solid #174DA4;padding:2px 8px;display:inline-block;}
.po-edit-link:hover{background:#174DA4;color:#fff;}

@media(max-width:768px){
    .po-summary{grid-template-columns:repeat(2,1fr);gap:8px;padding:10px;}
    .po-filters__row{flex-direction:column;align-items:stretch;}
    .po-filter-sep{display:none;}
    .po-modal{width:98vw;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="cd-card">

    <!-- ── Page Header ─────────────────────────── -->
    <div style="padding:10px 16px;border-bottom:1px solid #e0e5ed;background:#fff;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">
        <h2 style="margin:0;font-size:16px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:8px;">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            Portal Onboarding Status
        </h2>
        <span style="font-size:11px;color:#888;">Students who have verified their enrollment on the portal</span>
    </div>

    <!-- ── Summary Cards ───────────────────────── -->
    <div class="po-summary">
        <div class="po-card po-card--active">
            <span class="po-card__label">Active Students</span>
            <span class="po-card__value"><asp:Literal ID="litActiveCount" runat="server" Text="0" /></span>
            <span class="po-card__sub">Confirmed as active</span>
        </div>
        <div class="po-card po-card--alumni">
            <span class="po-card__label">Alumni</span>
            <span class="po-card__value"><asp:Literal ID="litAlumniCount" runat="server" Text="0" /></span>
            <span class="po-card__sub">Confirmed as alumni</span>
        </div>
        <div class="po-card po-card--email">
            <span class="po-card__label">Email Verified</span>
            <span class="po-card__value"><asp:Literal ID="litEmailCount" runat="server" Text="0" /></span>
            <span class="po-card__sub">Have verified MRU email</span>
        </div>
        <div class="po-card po-card--email">
            <span class="po-card__label">Lecturers Email Verified</span>
            <span class="po-card__value"><asp:Literal ID="litLecturerEmailCount" runat="server" Text="0" /></span>
            <span class="po-card__sub">Lecturers who completed email verification</span>
        </div>
        <div class="po-card po-card--semreg">
            <span class="po-card__label">Semester Registered</span>
            <span class="po-card__value"><asp:Literal ID="litSemRegCount" runat="server" Text="0" /></span>
            <span class="po-card__sub">Current year registration</span>
        </div>
    </div>

    <!-- ── Filter Bar ──────────────────────────── -->
    <div class="po-filters">
        <div class="po-filters__top">
            <div class="po-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="po-search-wrap__icon"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="po-search-input" placeholder="Search by name, reg no, email..." />
            </div>
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="po-btn-search" OnClick="btnSearch_Click" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="po-btn-reset" OnClick="btnReset_Click" CausesValidation="false" />
            <button type="button" class="po-btn-new" onclick="openCreateModal();">Create New</button>
            <asp:Button ID="btnRunBackfill" runat="server" Text="Run Backfill"
                CssClass="po-btn-backfill" OnClick="btnRunBackfill_Click" CausesValidation="false"
                OnClientClick="return confirm('Run one-time backfill now? This will set user type and normalize verified usernames to university email where safe.');" />
            <span class="po-filters__count"><asp:Literal ID="litCount" runat="server" Text="0 records" /></span>
        </div>
        <div class="po-filters__row">
            <div class="po-filter-grp">
                <span class="po-filter-grp__label">Status:</span>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="po-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="" Text="All Verified" />
                    <asp:ListItem Value="ACTIVE STUDENT" Text="Active Students" />
                    <asp:ListItem Value="ALUMNI" Text="Alumni" />
                    <asp:ListItem Value="LECTURER" Text="Lecturers (Email Verified)" />
                </asp:DropDownList>
            </div>
            <div class="po-filter-sep"></div>
            <div class="po-filter-grp">
                <span class="po-filter-grp__label">User Type:</span>
                <asp:DropDownList ID="ddlUserType" runat="server" CssClass="po-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="STUDENT" Text="Students" />
                    <asp:ListItem Value="LECTURER" Text="Lecturers" />
                </asp:DropDownList>
            </div>
            <div class="po-filter-sep"></div>
            <div class="po-filter-grp">
                <span class="po-filter-grp__label">Email:</span>
                <asp:DropDownList ID="ddlEmail" runat="server" CssClass="po-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="YES" Text="Verified" />
                    <asp:ListItem Value="NO" Text="Not Verified" />
                </asp:DropDownList>
            </div>
            <div class="po-filter-sep"></div>
            <div class="po-filter-grp">
                <span class="po-filter-grp__label">Sem. Reg:</span>
                <asp:DropDownList ID="ddlSemReg" runat="server" CssClass="po-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="YES" Text="Registered" />
                    <asp:ListItem Value="NO" Text="Not Registered" />
                </asp:DropDownList>
            </div>
            <div class="po-filter-sep"></div>
            <div class="po-filter-grp">
                <span class="po-filter-grp__label">Programme:</span>
                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="po-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="min-width:180px;">
                    <asp:ListItem Value="" Text="All Programmes" />
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- ── Data Table ──────────────────────────── -->
    <div class="po-table-wrap">
        <table class="po-table">
            <thead>
                <tr>
                    <th class="po-col-num">#</th>
                    <th>Reg No</th>
                    <th>Name</th>
                    <th>User Type</th>
                    <th>Programme</th>
                    <th>Status</th>
                    <th style="text-align:center;">Email Verified</th>
                    <th>Verified Email</th>
                    <th style="text-align:center;">Sem Reg</th>
                    <th>Last Activity</th>
                    <th style="text-align:center;">Action</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptStudents" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="po-col-num"><%# Container.ItemIndex + 1 + (CurrentPage * PageSize) %></td>
                            <td class="po-col-regno"><%# Eval("regno") %></td>
                            <td><%# Eval("student_name") %></td>
                            <td><%# GetUserTypeBadge(Eval("user_type").ToString()) %></td>
                            <td style="font-size:10px;"><%# Eval("progname") %></td>
                            <td><%# GetStatusBadge(Eval("verification_status").ToString()) %></td>
                            <td style="text-align:center;"><%# GetYesNo(Eval("verified_email_addr").ToString() != "") %></td>
                            <td style="font-size:10px;color:#666;"><%# Eval("verified_email_addr") %></td>
                            <td style="text-align:center;"><%# GetYesNo(Eval("has_sem_reg").ToString() == "1") %></td>
                            <td style="font-size:10px;color:#888;white-space:nowrap;"><%# Eval("last_activity") %></td>
                            <td style="text-align:center;"><%# GetEditLink(Eval("regno").ToString()) %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoData" runat="server" Visible="false">
                    <tr><td colspan="11" style="text-align:center;padding:40px 20px;color:#999;font-size:13px;">No records found matching your filters.</td></tr>
                </asp:Panel>
            </tbody>
        </table>
    </div>

    <!-- ── Pagination ──────────────────────────── -->
    <asp:Panel ID="pnlPager" runat="server" CssClass="po-pager">
        <span class="po-pager__info">
            Page <asp:Literal ID="litPage" runat="server" Text="1" /> of <asp:Literal ID="litTotalPages" runat="server" Text="1" />
            &mdash; <asp:Literal ID="litTotal" runat="server" Text="0" /> records
        </span>
        <div class="po-pager__nav">
            <asp:LinkButton ID="lnkFirst" runat="server" CssClass="po-pager__btn" OnClick="lnkFirst_Click" CausesValidation="false">&laquo; First</asp:LinkButton>
            <asp:LinkButton ID="lnkPrev" runat="server" CssClass="po-pager__btn" OnClick="lnkPrev_Click" CausesValidation="false">&lsaquo; Prev</asp:LinkButton>
            <asp:LinkButton ID="lnkNext" runat="server" CssClass="po-pager__btn" OnClick="lnkNext_Click" CausesValidation="false">Next &rsaquo;</asp:LinkButton>
            <asp:LinkButton ID="lnkLast" runat="server" CssClass="po-pager__btn" OnClick="lnkLast_Click" CausesValidation="false">Last &raquo;</asp:LinkButton>
        </div>
    </asp:Panel>
</div>

<!-- ── Hidden fields for edit ────────────────── -->
<asp:HiddenField ID="hdnEditRegno" runat="server" />
<asp:HiddenField ID="hdnModalMode" runat="server" />

<!-- ── Edit Modal ────────────────────────────── -->
<div id="editModal" class="po-modal-bg">
    <div class="po-modal">
        <div class="po-modal__hdr">
            <h3 id="editModalTitle">Edit Student Portal Info</h3>
            <button type="button" class="po-modal__close" onclick="closeEditModal();">&times;</button>
        </div>
        <div class="po-modal__body">
            <div id="modalResult" class="po-toast"></div>
            <div class="po-modal__row" id="rowCreateRegno" style="display:none;">
                <label>Registration Number / Username</label>
                <input type="text" id="createRegnoInput" class="po-modal__input" placeholder="e.g. 24/U/1234 or user@mru.ac.ug" />
            </div>
            <div class="po-modal__row" id="rowReadRegno">
                <label>Registration Number</label>
                <div class="po-readonly" id="lblEditRegno"></div>
            </div>
            <div class="po-modal__row" id="rowReadName">
                <label>Student Name</label>
                <div class="po-readonly" id="lblEditName"></div>
            </div>
            <div class="po-modal__row" id="rowReadProg">
                <label>Programme</label>
                <div class="po-readonly" id="lblEditProg" style="font-size:11px;"></div>
            </div>
            <div class="po-modal__row">
                <label>User Type</label>
                <asp:DropDownList ID="ddlEditUserType" runat="server" CssClass="po-modal__select">
                    <asp:ListItem Value="STUDENT" Text="Student" />
                    <asp:ListItem Value="LECTURER" Text="Lecturer" />
                </asp:DropDownList>
            </div>
            <div class="po-modal__row">
                <label>Verification Status</label>
                <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="po-modal__select">
                    <asp:ListItem Value="" Text="— Not Verified —" />
                    <asp:ListItem Value="ACTIVE STUDENT" Text="Active Student" />
                    <asp:ListItem Value="ALUMNI" Text="Alumni" />
                </asp:DropDownList>
            </div>
            <div class="po-modal__row">
                <label>Verified Email</label>
                <div style="display:flex;gap:8px;align-items:center;">
                    <asp:TextBox ID="txtEditEmail" runat="server" CssClass="po-modal__input" placeholder="student@mru.ac.ug" />
                    <button type="button" id="btnFetchEmail" class="po-modal__btn po-modal__btn--cancel" style="white-space:nowrap;" onclick="fetchEmailForModal(false);">Fetch Email</button>
                </div>
                <div id="emailFetchHint" style="display:none;margin-top:6px;font-size:10px;color:#666;"></div>
            </div>
        </div>
        <div class="po-modal__foot">
            <asp:Button ID="btnResetVerification" runat="server" Text="Reset Verification"
                CssClass="po-modal__btn po-modal__btn--danger" OnClick="btnResetVerification_Click"
                OnClientClick="return confirm('This will clear the student\'s verification status and email. They will need to re-verify on the portal. Continue?');" />
            <asp:Button ID="btnDeleteRecord" runat="server" Text="Delete Record"
                CssClass="po-modal__btn po-modal__btn--danger" OnClick="btnDeleteRecord_Click"
                OnClientClick="return confirm('This will permanently delete this portal onboarding record and login profile. Continue?');" />
            <button type="button" class="po-modal__btn po-modal__btn--cancel" onclick="closeEditModal();">Cancel</button>
            <button type="button" id="btnSaveEditAjax" class="po-modal__btn po-modal__btn--save" onclick="submitPortalOnboardingAjax();">Save Changes</button>
            <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes"
                CssClass="po-modal__btn po-modal__btn--save" OnClick="btnSaveEdit_Click"
                Style="display:none;" CausesValidation="false" UseSubmitBehavior="false" />
        </div>
    </div>
</div>

<script type="text/javascript">
function showModalInlineError(msg) {
    var r = document.getElementById('modalResult');
    if (!r) return;
    r.className = 'po-toast po-toast--error';
    r.style.display = 'block';
    r.textContent = msg || 'Validation failed.';
}

function hideModalInlineError() {
    var r = document.getElementById('modalResult');
    if (!r) return;
    r.className = 'po-toast';
    r.style.display = 'none';
    r.textContent = '';
}

function fetchEmailForModal(triggerSubmit) {
    if (triggerSubmit === undefined) triggerSubmit = false;

    var mode = (document.getElementById('<%= hdnModalMode.ClientID %>').value || '').toUpperCase();
    var regno = '';

    if (mode === 'CREATE') regno = (document.getElementById('createRegnoInput').value || '').trim();
    else regno = (document.getElementById('<%= hdnEditRegno.ClientID %>').value || '').trim();

    if (!regno) {
        showModalInlineError('Registration Number / Username is required.');
        return false;
    }

    hideModalInlineError();

    var saveBtn = document.getElementById('btnSaveEditAjax');
    var fetchBtn = document.getElementById('btnFetchEmail');
    var hint = document.getElementById('emailFetchHint');
    var emailInput = document.getElementById('<%= txtEditEmail.ClientID %>');
    var userType = document.getElementById('<%= ddlEditUserType.ClientID %>').value || 'STUDENT';
    if (triggerSubmit && saveBtn) saveBtn.disabled = true;
    if (fetchBtn) fetchBtn.disabled = true;
    if (hint) {
        hint.style.display = 'block';
        hint.style.color = '#666';
        hint.textContent = 'Fetching best email...';
    }

    fetch('PortalOnboarding.aspx?ajax=resolve_email&regno=' + encodeURIComponent(regno) + '&userType=' + encodeURIComponent(userType), {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
    })
    .then(function (resp) { return resp.json(); })
    .then(function (data) {
        if (data && data.error) {
            throw new Error(data.error);
        }

        var fetchedEmail = (data && data.email ? String(data.email).trim() : '');
        var fetchedSource = (data && data.source ? String(data.source) : '');
        var currentEmail = (emailInput && emailInput.value ? emailInput.value.trim() : '');

        if (!currentEmail && fetchedEmail && emailInput) {
            emailInput.value = fetchedEmail;
            currentEmail = fetchedEmail;
        }

        if (hint) {
            hint.style.display = 'block';
            if (currentEmail) {
                hint.style.color = '#2e7d32';
                hint.textContent = fetchedSource ? ('Email ready (' + fetchedSource + ')') : 'Email ready';
            } else {
                hint.style.color = '#c62828';
                hint.textContent = 'No email found automatically.';
            }
        }

        if (!currentEmail || currentEmail.indexOf('@') < 1) {
            showModalInlineError('Could not verify a valid email. Enter a valid email, then save again.');
            if (saveBtn) saveBtn.disabled = false;
            if (fetchBtn) fetchBtn.disabled = false;
            return;
        }

        if (!triggerSubmit) {
            if (saveBtn) saveBtn.disabled = false;
            if (fetchBtn) fetchBtn.disabled = false;
            return;
        }

        submitPortalOnboardingAjaxWithEmail(currentEmail);
        if (saveBtn) saveBtn.disabled = false;
        if (fetchBtn) fetchBtn.disabled = false;
    })
    .catch(function (err) {
        showModalInlineError('Email verification check failed: ' + (err && err.message ? err.message : err));
        if (saveBtn) saveBtn.disabled = false;
        if (fetchBtn) fetchBtn.disabled = false;
        if (hint) {
            hint.style.display = 'block';
            hint.style.color = '#c62828';
            hint.textContent = 'Fetch failed.';
        }
    });
}

function getCurrentPortalMode() {
    return (document.getElementById('<%= hdnModalMode.ClientID %>').value || '').toUpperCase();
}

function getCurrentPortalRegno() {
    var mode = getCurrentPortalMode();
    if (mode === 'CREATE') return (document.getElementById('createRegnoInput').value || '').trim();
    return (document.getElementById('<%= hdnEditRegno.ClientID %>').value || '').trim();
}

function submitPortalOnboardingAjax() {
    fetchEmailForModal(true);
}

function submitPortalOnboardingAjaxWithEmail(finalEmail) {
    var mode = getCurrentPortalMode();
    if (mode === 'LOAD') {
        showModalInlineError('Record is still loading. Please wait and try again.');
        return;
    }

    var regno = getCurrentPortalRegno();
    var status = document.getElementById('<%= ddlEditStatus.ClientID %>').value || '';
    var userType = document.getElementById('<%= ddlEditUserType.ClientID %>').value || 'STUDENT';
    var saveBtn = document.getElementById('btnSaveEditAjax');

    if (!regno) {
        showModalInlineError('Registration Number / Username is required.');
        return;
    }

    if (!finalEmail || finalEmail.indexOf('@') < 1) {
        showModalInlineError('A valid email is required before saving.');
        return;
    }

    if (saveBtn) saveBtn.disabled = true;

    var body =
        'mode=' + encodeURIComponent(mode) +
        '&regno=' + encodeURIComponent(regno) +
        '&status=' + encodeURIComponent(status) +
        '&email=' + encodeURIComponent(finalEmail) +
        '&userType=' + encodeURIComponent(userType);

    fetch('PortalOnboarding.aspx?ajax=save_onboarding', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', 'Accept': 'application/json' },
        body: body
    })
    .then(function (resp) { return resp.json(); })
    .then(function (data) {
        if (data && data.error) throw new Error(data.error);

        closeEditModal();
        showPoToast((data && data.message) ? data.message : 'Saved successfully.', 'success');
        setTimeout(function () { window.location.reload(); }, 400);
    })
    .catch(function (err) {
        showModalInlineError('Save failed: ' + (err && err.message ? err.message : err));
        if (saveBtn) saveBtn.disabled = false;
    });
}

function configureModalForCreate() {
    document.getElementById('editModalTitle').textContent = 'Create Portal Onboarding Record';
    document.getElementById('rowCreateRegno').style.display = 'block';
    document.getElementById('rowReadRegno').style.display = 'none';
    document.getElementById('rowReadName').style.display = 'none';
    document.getElementById('rowReadProg').style.display = 'none';
    document.getElementById('<%= btnResetVerification.ClientID %>').style.display = 'none';
    document.getElementById('<%= btnDeleteRecord.ClientID %>').style.display = 'none';
}

function configureModalForEdit() {
    document.getElementById('editModalTitle').textContent = 'Edit Student Portal Info';
    document.getElementById('rowCreateRegno').style.display = 'none';
    document.getElementById('rowReadRegno').style.display = 'block';
    document.getElementById('rowReadName').style.display = 'block';
    document.getElementById('rowReadProg').style.display = 'block';
    document.getElementById('<%= btnResetVerification.ClientID %>').style.display = '';
    document.getElementById('<%= btnDeleteRecord.ClientID %>').style.display = '';
}

function openCreateModal() {
    document.getElementById('<%= hdnEditRegno.ClientID %>').value = '';
    document.getElementById('<%= hdnModalMode.ClientID %>').value = 'CREATE';
    configureModalForCreate();
    document.getElementById('createRegnoInput').value = '';
    document.getElementById('lblEditRegno').textContent = '';
    document.getElementById('lblEditName').textContent = '';
    document.getElementById('lblEditProg').textContent = '';
    document.getElementById('<%= ddlEditUserType.ClientID %>').value = 'STUDENT';
    document.getElementById('<%= ddlEditStatus.ClientID %>').value = 'ACTIVE STUDENT';
    document.getElementById('<%= txtEditEmail.ClientID %>').value = '';
    var hint = document.getElementById('emailFetchHint');
    if (hint) { hint.style.display = 'none'; hint.textContent = ''; }
    var r = document.getElementById('modalResult');
    r.className = 'po-toast';
    r.style.display = 'none';
    r.textContent = '';
    showEditModal();
}

function openEditModal(regno) {
    document.getElementById('<%= hdnEditRegno.ClientID %>').value = regno;
    document.getElementById('<%= hdnModalMode.ClientID %>').value = 'LOAD';
    configureModalForEdit();
    __doPostBack('<%= btnSaveEdit.UniqueID %>', '');
}

document.addEventListener('DOMContentLoaded', function () {
    var regInput = document.getElementById('createRegnoInput');
    if (regInput) {
        regInput.addEventListener('blur', function () {
            var mode = (document.getElementById('<%= hdnModalMode.ClientID %>').value || '').toUpperCase();
            if (mode === 'CREATE') fetchEmailForModal(false);
        });
    }

    var userTypeSel = document.getElementById('<%= ddlEditUserType.ClientID %>');
    if (userTypeSel) {
        userTypeSel.addEventListener('change', function () {
            fetchEmailForModal(false);
        });
    }
});

function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
}
function showEditModal() {
    document.getElementById('editModal').style.display = 'flex';
}
function showPoToast(msg, type) {
    var el = document.createElement('div');
    el.style.cssText = 'position:fixed;top:12px;right:12px;z-index:9999;padding:10px 18px;font-size:12px;font-weight:600;max-width:400px;box-shadow:0 4px 16px rgba(0,0,0,.15);';
    if (type === 'success') {
        el.style.background = '#e8f5e9'; el.style.color = '#2e7d32'; el.style.border = '1px solid #c8e6c9';
    } else {
        el.style.background = '#fdecea'; el.style.color = '#c62828'; el.style.border = '1px solid #f5c6cb';
    }
    el.textContent = msg;
    document.body.appendChild(el);
    setTimeout(function() { el.style.opacity = '0'; el.style.transition = 'opacity .3s'; }, 3000);
    setTimeout(function() { if (el.parentNode) el.parentNode.removeChild(el); }, 3500);
}
</script>
</asp:Content>
