<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewProgrammeCourses.aspx.cs" Inherits="COOPERP_NewScreens_NewProgrammeCourses" Title="Programme Courses - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ---- Page header ---- */
.cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
.cd-page-header__left { display:flex; align-items:center; gap:12px; }
.cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
.cd-page-header__right { display:flex; gap:8px; align-items:center; }
.cd-page-header .hr-btn--primary { background:rgba(255,255,255,.15); color:#fff; border:1px solid rgba(255,255,255,.3); }
.cd-page-header .hr-btn--primary:hover { background:rgba(255,255,255,.25); color:#fff; }

/* ---- Card ---- */
.cd-card { background:#fff; border:1px solid #e0e5ed; margin-bottom:16px; }
.cd-card__body { padding:16px; }
.cd-p-0 { padding:0 !important; }

/* ---- DX Grid design-system overrides (Glass theme) ---- */
.fs-grid-wrap { overflow-x:auto; -webkit-overflow-scrolling:touch; }
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass td,
.dxgvHeader_Glass th {
    font-size:10px !important; text-transform:uppercase !important;
    letter-spacing:.4px !important; background:#f5f7fa !important;
    color:#666 !important; font-weight:700 !important;
    border-bottom:2px solid #e0e5ed !important; padding:8px 10px !important;
}
.dxgvDataRow_Glass td,
.dxgvDataRowAlt_Glass td {
    font-size:11px !important; padding:6px 10px !important;
    border-bottom:1px solid #f0f2f5 !important; vertical-align:middle !important;
    color:#333 !important;
}
.dxgvDataRow_Glass:hover td,
.dxgvDataRowAlt_Glass:hover td { background:#f5f8ff !important; }
.dxgvFilterRow_Glass td {
    padding:4px 6px !important; background:#fafbfc !important;
    border-bottom:1px solid #e0e5ed !important;
}
.dxgvFilterRow_Glass input[type="text"] {
    font-size:11px !important; padding:4px 6px !important;
    border:1px solid #ddd !important; border-radius:0 !important;
    width:100% !important; box-sizing:border-box !important;
}
.dxgvPagerBar_Glass {
    background:#fafbfc !important; border-top:1px solid #e0e5ed !important;
    padding:6px 10px !important;
}
.dxgvPagerBar_Glass td { font-size:11px !important; }
.dxgvPagerBar_Glass .dxp-current {
    background:#05275C !important; color:#fff !important;
    padding:2px 8px !important; font-weight:700 !important;
}
.dxgvPagerBar_Glass .dxp-lead,
.dxgvPagerBar_Glass .dxp-num,
.dxgvPagerBar_Glass a { color:#05275C !important; }
.dxgvGroupPanel_Glass { display:none !important; }
.dxgvEmptyDataRow_Glass td {
    padding:30px 20px !important; text-align:center !important;
    font-size:13px !important; color:#888 !important;
}

/* ---- Buttons ---- */
.hr-btn {
    display:inline-flex; align-items:center; gap:5px; padding:6px 14px;
    font-size:12px; font-weight:600; border:none; cursor:pointer;
    border-radius:0; line-height:1.4; text-decoration:none; transition:background .15s;
}
.hr-btn--primary { background:#05275C; color:#fff; }
.hr-btn--primary:hover { background:#041d45; color:#fff; }
.hr-btn--success { background:#16a34a; color:#fff; }
.hr-btn--success:hover { background:#15803d; color:#fff; }
.hr-btn--danger  { background:#dc3545; color:#fff; }
.hr-btn--danger:hover  { background:#b91c2c; color:#fff; }
.hr-btn--outline { background:#fff; color:#05275C; border:1px solid #05275C; }
.hr-btn--outline:hover { background:#f0f4fa; }
.hr-btn--sm { padding:4px 10px; font-size:11px; }

/* ---- Action popover ---- */
.cd-action-wrapper { position:relative; display:inline-block; }
.cd-action-btn {
    background:#f0f4fa; border:1px solid #cdd3de; color:#05275C;
    padding:3px 8px; border-radius:0; cursor:pointer; font-size:12px; font-weight:700;
}
.cd-action-btn:hover { background:#dce4f0; }
.cd-action-popover {
    display:none; position:absolute; right:0; top:100%; z-index:9999;
    background:#fff; border:1px solid #cdd3de; min-width:130px; padding:4px 0;
}
.cd-action-popover.is-open { display:block !important; }
.cd-action-popover button {
    display:block; width:100%; text-align:left; padding:7px 14px;
    font-size:12px; background:none; border:none; cursor:pointer; color:#1a1a2e;
    border-bottom:1px solid #f0f0f0;
}
.cd-action-popover button:last-child { border-bottom:none; }
.cd-action-popover button:hover { background:#f5f7fa; }
.cd-action-popover .pop-danger { color:#dc3545; }
.cd-action-popover .pop-danger:hover { background:#fef5f5; }

/* ---- Modal ---- */
.hr-modal-overlay {
    position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:10000;
    display:flex; align-items:center; justify-content:center;
}
.hr-modal { background:#fff; width:560px; max-width:96vw; max-height:92vh; overflow-y:auto; border-radius:2px; box-shadow:0 8px 32px rgba(0,0,0,.2); }
.hr-modal-header {
    display:flex; align-items:center; justify-content:space-between;
    padding:14px 20px; background:#05275C; color:#fff;
}
.hr-modal-header h4 { margin:0; font-size:14px; font-weight:700; }
.hr-modal-close { background:none; border:none; color:#fff; font-size:20px; cursor:pointer; line-height:1; padding:0 2px; }
.hr-modal-close:hover { color:#ccd; }
.hr-modal-body { padding:20px; }
.hr-modal-footer { padding:14px 20px; border-top:1px solid #e0e5ed; display:flex; gap:8px; justify-content:flex-end; }

/* ---- Form ---- */
.hr-form-group { margin-bottom:14px; }
.hr-form-group label { display:block; font-size:12px; font-weight:600; color:#444; margin-bottom:5px; }
.hr-form-group label .req { color:#dc3545; margin-left:2px; }
.hr-input, .hr-select {
    width:100%; padding:7px 10px; font-size:13px; border:1px solid #cdd3de;
    border-radius:0; background:#fff; color:#1a1a2e; box-sizing:border-box;
}
.hr-input:focus, .hr-select:focus { outline:none; border-color:#174DA4; }
.hr-form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
.hr-form-row-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:14px; }

/* ---- Result msg ---- */
.form-result { padding:8px 12px; font-size:12px; font-weight:600; margin-bottom:12px; display:none; }
.form-result.error   { background:#fef5f5; color:#dc3545; border:1px solid #fecaca; }
.form-result.success { background:#f0fdf4; color:#15803d; border:1px solid #bbf7d0; }

/* ---- Status badges ---- */
.badge-core { display:inline-block; background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; padding:2px 8px; font-size:11px; font-weight:700; }
.badge-elective { display:inline-block; background:#fefce8; color:#a16207; border:1px solid #fde68a; padding:2px 8px; font-size:11px; font-weight:700; }

/* ---- Course search ---- */
.pc-search-wrap { position:relative; }
.pc-search-dropdown {
    position:absolute; top:100%; left:0; right:0; z-index:100;
    background:#fff; border:1px solid #cdd3de; max-height:200px; overflow-y:auto;
    display:none; box-shadow:0 4px 12px rgba(0,0,0,.1);
}
.pc-search-dropdown.is-open { display:block; }
.pc-search-item { padding:7px 10px; font-size:12px; cursor:pointer; display:flex; gap:8px; border-bottom:1px solid #f0f2f5; }
.pc-search-item:hover { background:#f0f4fa; }
.pc-search-item .pc-si-code { font-weight:700; color:#05275C; min-width:90px; }
.pc-search-item .pc-si-name { color:#444; }
.pc-selected-course {
    margin-top:4px; padding:5px 8px; background:#eef2ff; border:1px solid #d0d8f0;
    font-size:12px; display:flex; align-items:center; gap:6px;
}
.pc-selected-course .pc-sc-code { font-weight:700; color:#05275C; }
.pc-selected-course .pc-sc-clear {
    background:none; border:none; color:#dc3545; cursor:pointer;
    font-size:14px; margin-left:auto; padding:0 4px;
}

/* ---- Searchable dropdown ---- */
.sd-wrap { position:relative; }
.sd-toggle {
    width:100%; padding:7px 10px; font-size:13px; border:1px solid #cdd3de;
    border-radius:0; background:#fff; color:#1a1a2e; box-sizing:border-box;
    display:flex; align-items:center; justify-content:space-between; cursor:pointer;
    min-height:34px; user-select:none;
}
.sd-toggle:hover { border-color:#174DA4; }
.sd-toggle-text { flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.sd-toggle-text.placeholder { color:#999; }
.sd-toggle-arrow { font-size:10px; color:#888; margin-left:8px; flex-shrink:0; }
.sd-panel {
    position:absolute; top:100%; left:0; right:0; z-index:200;
    background:#fff; border:1px solid #cdd3de; border-top:none;
    box-shadow:0 4px 12px rgba(0,0,0,.12); display:none;
}
.sd-panel.is-open { display:block; }
.sd-search {
    width:100%; padding:8px 10px; font-size:12px; border:none;
    border-bottom:1px solid #e0e5ed; box-sizing:border-box; outline:none;
}
.sd-list { max-height:200px; overflow-y:auto; }
.sd-item {
    padding:7px 10px; font-size:12px; cursor:pointer;
    border-bottom:1px solid #f5f5f5; color:#1a1a2e;
}
.sd-item:hover { background:#f0f4fa; }
.sd-item.is-sel { background:#eef2ff; font-weight:600; }
.sd-empty { padding:8px 10px; font-size:12px; color:#888; font-style:italic; }

@media (max-width:600px) {
    .hr-form-row, .hr-form-row-3 { grid-template-columns:1fr; }
    .hr-modal { width:100%; max-height:100vh; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- Hidden postback infrastructure -->
    <asp:HiddenField ID="hdnEditId"         runat="server" />
    <asp:HiddenField ID="hdnModalMode"      runat="server" />
    <asp:HiddenField ID="hdnSelectedCourse"  runat="server" />
    <asp:Button ID="btnSave"     runat="server" style="display:none" OnClick="btnSave_Click" UseSubmitBehavior="false" />
    <asp:Button ID="btnDelete"   runat="server" style="display:none" OnClick="btnDelete_Click" UseSubmitBehavior="false" />
    <asp:Button ID="btnLoadEdit" runat="server" style="display:none" OnClick="btnLoadEdit_Click" UseSubmitBehavior="false" />

    <!-- Page header -->
    <div class="cd-page-header">
        <div class="cd-page-header__left">
            <div class="cd-page-header__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            </div>
            <div>
                <div class="cd-page-header__title">Programme Courses</div>
                <div class="cd-page-header__sub">Define and manage courses assigned to each programme</div>
            </div>
        </div>
        <div class="cd-page-header__right">
            <button type="button" class="hr-btn hr-btn--primary" onclick="openModal('NEW')">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Add New
            </button>
        </div>
    </div>

    <!-- Grid -->
    <div class="cd-card">
        <div class="cd-card__body cd-p-0">
         <div class="fs-grid-wrap">
            <dx:ASPxGridView ID="gvMain" runat="server" AutoGenerateColumns="False"
                KeyFieldName="ID" Width="100%"
                EnableTheming="True" Theme="Glass"
                ClientInstanceName="gvMain"
                EnableCallBacks="true">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="False" AllowFocusedRow="False" />
                <SettingsDataSecurity AllowEdit="False" AllowDelete="False" AllowInsert="False" />
                <SettingsPager PageSize="25" Mode="ShowPager" />
                <Columns>
                    <dx:GridViewDataTextColumn VisibleIndex="0" Caption=" " Width="42px" UnboundType="String"
                        Settings-AllowAutoFilter="False" Settings-AllowSort="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-btn"
                                    onclick="toggleActionPopover(this,event)">&#9660;</button>
                                <div class="cd-action-popover">
                                    <button type="button" onclick="editRow('<%# Eval("ID") %>')">&#9998; Edit</button>
                                    <button type="button" class="pop-danger" onclick="deleteRow('<%# Eval("ID") %>','<%# HttpUtility.JavaScriptStringEncode(Eval("course_code").ToString()) %>')">&#128465; Delete</button>
                                </div>
                            </div>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progname"    VisibleIndex="1" Caption="Programme" />
                    <dx:GridViewDataTextColumn FieldName="spec_name"   VisibleIndex="2" Caption="Specialisation" Width="140px" />
                    <dx:GridViewDataTextColumn FieldName="course_code" VisibleIndex="3" Caption="Code" Width="100px">
                        <CellStyle Font-Bold="True" ForeColor="#05275C" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="courseName"  VisibleIndex="4" Caption="Course Name" />
                    <dx:GridViewDataTextColumn FieldName="study_year"  VisibleIndex="5" Caption="Year" Width="50px">
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="semester"    VisibleIndex="6" Caption="Sem" Width="45px">
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_type" VisibleIndex="7" Caption="Type" Width="80px"
                        Settings-AllowAutoFilter="True">
                        <DataItemTemplate>
                            <span class='<%# Eval("course_type") != null && Eval("course_type").ToString().ToUpper() == "ELECTIVE" ? "badge-elective" : "badge-core" %>'>
                                <%# Eval("course_type") != null && Eval("course_type").ToString() != "" ? Eval("course_type") : "CORE" %>
                            </span>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="CreditUnit"  VisibleIndex="8" Caption="CU" Width="40px"
                        Settings-AllowAutoFilter="False">
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                </Columns>
            </dx:ASPxGridView>
         </div>
        </div>
    </div>

    <!-- ===== Add / Edit Modal ===== -->
    <div id="pcModal" class="hr-modal-overlay" style="display:none">
        <div class="hr-modal">
            <div class="hr-modal-header">
                <h4 id="modalTitle">Add Programme Course</h4>
                <button type="button" class="hr-modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="hr-modal-body">
                <div id="modalResult" class="form-result"></div>

                <!-- Programme (searchable) -->
                <div class="hr-form-group">
                    <label>Programme <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="hr-select" style="display:none">
                    </asp:DropDownList>
                    <div class="sd-wrap" id="sdProgWrap">
                        <div class="sd-toggle" id="sdProgToggle">
                            <span class="sd-toggle-text placeholder" id="sdProgText">-- Select Programme --</span>
                            <span class="sd-toggle-arrow">&#9662;</span>
                        </div>
                        <div class="sd-panel" id="sdProgPanel">
                            <input type="text" class="sd-search" id="sdProgSearch" placeholder="Search programmes..." autocomplete="off" />
                            <div class="sd-list" id="sdProgList"></div>
                        </div>
                    </div>
                </div>

                <!-- Specialisation (searchable, cascaded from programme) -->
                <div class="hr-form-group">
                    <label>Specialisation <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlSpecialisation" runat="server" CssClass="hr-select" style="display:none">
                    </asp:DropDownList>
                    <div class="sd-wrap" id="sdSpecWrap">
                        <div class="sd-toggle" id="sdSpecToggle">
                            <span class="sd-toggle-text placeholder" id="sdSpecText">-- Select Specialisation --</span>
                            <span class="sd-toggle-arrow">&#9662;</span>
                        </div>
                        <div class="sd-panel" id="sdSpecPanel">
                            <input type="text" class="sd-search" id="sdSpecSearch" placeholder="Search specialisations..." autocomplete="off" />
                            <div class="sd-list" id="sdSpecList"></div>
                        </div>
                    </div>
                </div>

                <!-- Course (search autocomplete) -->
                <div class="hr-form-group pc-search-wrap">
                    <label>Course <span class="req">*</span></label>
                    <input type="text" id="courseSearchInput" class="hr-input"
                        placeholder="Type course code or name to search..." autocomplete="off" />
                    <div id="courseSearchResults" class="pc-search-dropdown"></div>
                    <div id="courseSelectedDisplay" class="pc-selected-course" style="display:none;"></div>
                </div>

                <!-- Year / Semester / Type -->
                <div class="hr-form-row-3">
                    <div class="hr-form-group">
                        <label>Study Year <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlYear" runat="server" CssClass="hr-select">
                            <asp:ListItem Value="1" Text="Year 1" />
                            <asp:ListItem Value="2" Text="Year 2" />
                            <asp:ListItem Value="3" Text="Year 3" />
                            <asp:ListItem Value="4" Text="Year 4" />
                            <asp:ListItem Value="5" Text="Year 5" />
                            <asp:ListItem Value="6" Text="Year 6" />
                        </asp:DropDownList>
                    </div>
                    <div class="hr-form-group">
                        <label>Semester <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="hr-select">
                            <asp:ListItem Value="1" Text="Semester 1" />
                            <asp:ListItem Value="2" Text="Semester 2" />
                        </asp:DropDownList>
                    </div>
                    <div class="hr-form-group">
                        <label>Course Type</label>
                        <asp:DropDownList ID="ddlCourseType" runat="server" CssClass="hr-select">
                            <asp:ListItem Value="CORE" Text="Core" />
                            <asp:ListItem Value="ELECTIVE" Text="Elective" />
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="hr-modal-footer">
                <button type="button" class="hr-btn hr-btn--outline" onclick="closeModal()">Cancel</button>
                <button type="button" class="hr-btn hr-btn--primary" onclick="saveRecord()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                    Save
                </button>
            </div>
        </div>
    </div>

<!-- ===== JavaScript ===== -->
<script type="text/javascript">

/* ---- Reference data (emitted from server) ---- */
var __allProgs = <%= BuildProgrammesJson() %>;
var __allSpecs = <%= BuildSpecsJson() %>;
var __allCourses = <%= BuildCoursesJson() %>;

/* ---- Action popover ---- */
function toggleActionPopover(btn, evt) {
    evt.stopPropagation();
    var pop = btn.nextElementSibling;
    var isOpen = pop.classList.contains('is-open');
    closeAllActionPopovers();
    if (!isOpen) pop.classList.add('is-open');
}
function closeAllActionPopovers() {
    document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){ p.classList.remove('is-open'); });
}
document.addEventListener('click', closeAllActionPopovers);

/* ---- Modal ---- */
function openModal(mode, editId) {
    closeAllActionPopovers();
    document.getElementById('modalResult').style.display = 'none';
    document.getElementById('<%= hdnModalMode.ClientID %>').value = mode || 'NEW';
    document.getElementById('<%= hdnEditId.ClientID %>').value = editId || '';

    if (mode === 'NEW') {
        document.getElementById('modalTitle').textContent = 'Add Programme Course';
        sdReset('prog');
        sdSetData('spec', []);
        clearCourseSelection();
        clearCourseSearch();
        document.getElementById('<%= ddlYear.ClientID %>').value = '1';
        document.getElementById('<%= ddlSemester.ClientID %>').value = '1';
        document.getElementById('<%= ddlCourseType.ClientID %>').value = 'CORE';
    } else if (mode === 'EDIT') {
        document.getElementById('modalTitle').textContent = 'Edit Programme Course';
    }

    document.getElementById('pcModal').style.display = 'flex';
    if (!window._csInit) { initCourseSearch(); window._csInit = true; }
}

function closeModal() {
    document.getElementById('pcModal').style.display = 'none';
    clearCourseSearch();
}

function editRow(id) {
    closeAllActionPopovers();
    document.getElementById('<%= hdnEditId.ClientID %>').value = id;
    document.getElementById('<%= hdnModalMode.ClientID %>').value = 'LOAD';
    __doPostBack('<%= btnLoadEdit.UniqueID %>', '');
}

function deleteRow(id, courseCode) {
    closeAllActionPopovers();
    if (!confirm('Delete course "' + courseCode + '" from this programme?\n\nThis cannot be undone.')) return;
    document.getElementById('<%= hdnEditId.ClientID %>').value = id;
    __doPostBack('<%= btnDelete.UniqueID %>', '');
}

function saveRecord() {
    var prog = document.getElementById('<%= ddlProgramme.ClientID %>').value;
    var spec = document.getElementById('<%= ddlSpecialisation.ClientID %>').value;
    var course = document.getElementById('<%= hdnSelectedCourse.ClientID %>').value;

    if (!prog) { showModalError('Please select a Programme.'); return; }
    if (!spec) { showModalError('Please select a Specialisation.'); return; }
    if (!course) { showModalError('Please search and select a Course.'); return; }

    __doPostBack('<%= btnSave.UniqueID %>', '');
}

function showModalError(msg) {
    var r = document.getElementById('modalResult');
    r.className = 'form-result error';
    r.style.display = 'block';
    r.textContent = msg;
}

/* ---- Searchable Dropdown System ---- */
var SD = {};

function sdInit(key, cfg) {
    SD[key] = {
        toggle: document.getElementById(cfg.toggleId),
        panel: document.getElementById(cfg.panelId),
        search: document.getElementById(cfg.searchId),
        list: document.getElementById(cfg.listId),
        select: document.getElementById(cfg.selectId),
        data: cfg.data || [],
        placeholder: cfg.placeholder || '-- Select --',
        onChange: cfg.onChange || null,
        value: '', text: ''
    };
    var d = SD[key];
    d.toggle.addEventListener('click', function(e) { e.stopPropagation(); sdTogglePanel(key); });
    d.panel.addEventListener('click', function(e) { e.stopPropagation(); });
    d.search.addEventListener('input', function() { sdRender(key); });
    sdRender(key);
    sdUpdateDisplay(key);
}

function sdTogglePanel(key) {
    var d = SD[key];
    var isOpen = d.panel.classList.contains('is-open');
    sdCloseAll();
    if (!isOpen) {
        d.panel.classList.add('is-open');
        d.search.value = '';
        sdRender(key);
        d.search.focus();
    }
}

function sdCloseAll() {
    for (var k in SD) SD[k].panel.classList.remove('is-open');
}

function sdRender(key) {
    var d = SD[key];
    var q = d.search.value.toLowerCase().trim();
    var items = d.data;
    if (q) {
        items = items.filter(function(it) {
            return it.t.toLowerCase().indexOf(q) !== -1 || (it.v && it.v.toLowerCase().indexOf(q) !== -1);
        });
    }
    if (items.length === 0) {
        d.list.innerHTML = '<div class="sd-empty">No matches found</div>';
        return;
    }
    var html = '';
    for (var i = 0; i < items.length; i++) {
        var sel = items[i].v === d.value ? ' is-sel' : '';
        html += '<div class="sd-item' + sel + '" onclick="sdSelect(\'' + key + '\',\'' + escA(items[i].v) + '\',\'' + escA(items[i].t) + '\')">' + escH(items[i].t) + '</div>';
    }
    d.list.innerHTML = html;
}

function sdSelect(key, value, text) {
    var d = SD[key];
    d.value = value;
    d.text = text;
    d.select.value = value;
    d.panel.classList.remove('is-open');
    sdUpdateDisplay(key);
    if (d.onChange) d.onChange(value);
}

function sdUpdateDisplay(key) {
    var d = SD[key];
    var span = d.toggle.querySelector('.sd-toggle-text');
    if (d.value && d.text) {
        span.textContent = d.text;
        span.classList.remove('placeholder');
    } else {
        span.textContent = d.placeholder;
        span.classList.add('placeholder');
    }
}

function sdSetData(key, data) {
    var d = SD[key];
    d.data = data;
    d.value = '';
    d.text = '';
    d.select.selectedIndex = 0;
    sdUpdateDisplay(key);
}

function sdSetValue(key, value) {
    var d = SD[key];
    var item = null;
    for (var i = 0; i < d.data.length; i++) {
        if (d.data[i].v === value) { item = d.data[i]; break; }
    }
    if (item) {
        d.value = item.v;
        d.text = item.t;
        d.select.value = item.v;
    } else {
        d.value = value;
        d.text = '';
        d.select.value = value;
    }
    sdUpdateDisplay(key);
}

function sdReset(key) {
    var d = SD[key];
    d.value = '';
    d.text = '';
    d.select.selectedIndex = 0;
    sdUpdateDisplay(key);
}

function getSpecsForProg(progcode) {
    if (!progcode) return [];
    return __allSpecs.filter(function(s) { return s.p === progcode; })
        .map(function(s) { return { v: s.id, t: s.n }; });
}

document.addEventListener('click', sdCloseAll);

/* ---- Course Search Autocomplete ---- */
var _csTimer;
function initCourseSearch() {
    var inp = document.getElementById('courseSearchInput');
    var dd = document.getElementById('courseSearchResults');
    if (!inp || !dd) return;
    inp.addEventListener('input', function() {
        clearTimeout(_csTimer);
        var q = this.value.toLowerCase().trim();
        if (q.length < 2) { dd.classList.remove('is-open'); dd.innerHTML = ''; return; }
        _csTimer = setTimeout(function() {
            var all = __allCourses || [];
            var m = [];
            for (var i = 0; i < all.length && m.length < 20; i++) {
                if (all[i].c.toLowerCase().indexOf(q) !== -1 || all[i].n.toLowerCase().indexOf(q) !== -1)
                    m.push(all[i]);
            }
            if (m.length === 0) {
                dd.innerHTML = '<div style="padding:8px 10px;font-size:12px;color:#888;">No courses found</div>';
            } else {
                dd.innerHTML = m.map(function(x) {
                    return '<div class="pc-search-item" onclick="selectCourse(\'' + escA(x.c) + '\',\'' + escA(x.n) + '\')">' +
                        '<span class="pc-si-code">' + escH(x.c) + '</span>' +
                        '<span class="pc-si-name">' + escH(x.n) + '</span></div>';
                }).join('');
            }
            dd.classList.add('is-open');
        }, 120);
    });
    document.addEventListener('click', function(e) {
        if (!inp.contains(e.target) && !dd.contains(e.target)) dd.classList.remove('is-open');
    });
}

function selectCourse(code, name) {
    document.getElementById('<%= hdnSelectedCourse.ClientID %>').value = code;
    document.getElementById('courseSearchInput').value = '';
    document.getElementById('courseSearchResults').classList.remove('is-open');
    var d = document.getElementById('courseSelectedDisplay');
    d.innerHTML = '<span class="pc-sc-code">' + escH(code) + '</span> ' + escH(name) +
        '<button type="button" class="pc-sc-clear" onclick="clearCourseSelection()" title="Clear">&times;</button>';
    d.style.display = 'flex';
}

function clearCourseSelection() {
    document.getElementById('<%= hdnSelectedCourse.ClientID %>').value = '';
    document.getElementById('courseSelectedDisplay').style.display = 'none';
}

function clearCourseSearch() {
    var inp = document.getElementById('courseSearchInput');
    if (inp) inp.value = '';
    var dd = document.getElementById('courseSearchResults');
    if (dd) { dd.innerHTML = ''; dd.classList.remove('is-open'); }
    clearCourseSelection();
}

/* ---- Toast ---- */
function showToast(msg, type) {
    var t = document.createElement('div');
    t.style.cssText = 'position:fixed;bottom:20px;right:20px;z-index:99999;padding:10px 18px;border-radius:4px;font-size:13px;font-weight:600;color:#fff;box-shadow:0 3px 10px rgba(0,0,0,.2);opacity:1;transition:opacity .4s;';
    t.style.background = type==='success' ? '#16a34a' : type==='danger' ? '#dc3545' : type==='warning' ? '#d97706' : '#174DA4';
    t.textContent = msg;
    document.body.appendChild(t);
    setTimeout(function(){ t.style.opacity='0'; setTimeout(function(){ if(t.parentNode) t.parentNode.removeChild(t); },400); },3000);
}

/* ---- Helpers ---- */
function escH(s) { var d=document.createElement('div');d.appendChild(document.createTextNode(s));return d.innerHTML; }
function escA(s) { return s.replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }

/* ---- Close on overlay click / Escape ---- */
document.getElementById('pcModal').addEventListener('click', function(e){ if(e.target===this) closeModal(); });
document.addEventListener('keydown', function(e){
    if(e.key==='Escape') {
        var anyOpen = false;
        for (var k in SD) { if (SD[k].panel.classList.contains('is-open')) { anyOpen = true; break; } }
        if (anyOpen) sdCloseAll();
        else closeModal();
    }
});

/* ---- Initialize Searchable Dropdowns ---- */
sdInit('prog', {
    toggleId: 'sdProgToggle', panelId: 'sdProgPanel',
    searchId: 'sdProgSearch', listId: 'sdProgList',
    selectId: '<%= ddlProgramme.ClientID %>',
    data: __allProgs,
    placeholder: '-- Select Programme --',
    onChange: function(val) {
        var specs = getSpecsForProg(val);
        sdSetData('spec', specs);
        if (specs.length === 1) sdSetValue('spec', specs[0].v);
    }
});

sdInit('spec', {
    toggleId: 'sdSpecToggle', panelId: 'sdSpecPanel',
    searchId: 'sdSpecSearch', listId: 'sdSpecList',
    selectId: '<%= ddlSpecialisation.ClientID %>',
    data: [],
    placeholder: '-- Select Specialisation --'
});
</script>

</asp:Content>