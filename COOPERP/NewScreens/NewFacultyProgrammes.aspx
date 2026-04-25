<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewFacultyProgrammes.aspx.cs" Inherits="COOPERP_NewScreens_NewFacultyProgrammes" Title="Programmes - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ---- Buttons ---- */
.hr-btn {
    display: inline-flex; align-items: center; gap: 5px; padding: 6px 14px;
    font-size: 12px; font-weight: 600; border: none; cursor: pointer;
    border-radius: 0; line-height: 1.4; text-decoration: none; transition: background .15s;
}
.hr-btn--primary { background: #05275C; color: #fff; }
.hr-btn--primary:hover { background: #041d45; color: #fff; }
.hr-btn--success { background: #16a34a; color: #fff; }
.hr-btn--success:hover { background: #15803d; color: #fff; }
.hr-btn--danger  { background: #dc3545; color: #fff; }
.hr-btn--danger:hover  { background: #b91c2c; color: #fff; }
.hr-btn--outline { background: #fff; color: #05275C; border: 1px solid #05275C; }
.hr-btn--outline:hover { background: #f0f4fa; }
.hr-btn--sm { padding: 4px 10px; font-size: 11px; }
.hr-btn--xs { padding: 2px 7px; font-size: 11px; }

/* ---- Stats strip ---- */
.stats-strip { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin-bottom: 16px; }
.stat-box { background: #fff; border: 1px solid #e0e5ed; padding: 12px; text-align: center; border-left: 4px solid #05275C; }
.stat-box__value { font-size: 18px; font-weight: 700; color: #05275C; line-height: 1.2; }
.stat-box__label { font-size: 11px; color: #666; text-transform: uppercase; letter-spacing: 0.3px; margin-top: 3px; font-weight: 600; }

/* ---- Filter bar ---- */
.filter-bar { background: #fff; border: 1px solid #e0e5ed; padding: 12px; margin-bottom: 16px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.filter-bar__title { font-size: 13px; font-weight: 700; color: #05275C; margin-right: 4px; }
.filter-bar label { font-size: 12px; color: #666; font-weight: 600; margin: 0; }
.filter-bar select, .filter-bar input[type="text"] {
    font-size: 12px; border: 1px solid #cdd3de; padding: 6px 10px; color: #1a1a2e;
    background: #fff; height: 32px; border-radius: 0;
}
.filter-bar input[type="text"]::placeholder { color: #aaa; }
.filter-bar .filter-divider { width: 1px; height: 20px; background: #e0e5ed; }
.filter-bar .btn-filter-clear { padding: 6px 12px; font-size: 12px; }
.filter-bar__spacer { margin-left: auto; }
.hr-btn--addblend {
    background: #05275C;
    color: #fff;
    border: 1px solid #05275C;
    box-shadow: 0 1px 0 rgba(0,0,0,.05);
}
.hr-btn--addblend:hover { background: #041d45; color: #fff; }

/* ---- Card grid ---- */
.fp-card-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 12px; }
.fp-card { background: #fff; border: 1px solid #e0e5ed; border-radius: 2px; overflow: hidden; display: flex; flex-direction: column; transition: box-shadow 0.2s; }
.fp-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.1); }

.fp-card__header { background: #f5f7fa; border-bottom: 1px solid #e0e5ed; padding: 12px; }
.fp-card__title { font-size: 13px; font-weight: 700; color: #05275C; margin: 0; line-height: 1.3; }
.fp-card__subtitle { font-size: 11px; color: #666; margin-top: 3px; }

.fp-card__body { padding: 12px; flex: 1; display: flex; flex-direction: column; gap: 8px; }
.fp-card__row { display: flex; justify-content: space-between; align-items: center; gap: 8px; padding: 4px 0; font-size: 12px; }
.fp-card__row__k { color: #666; font-weight: 600; min-width: 80px; }
.fp-card__row__v { color: #1a1a2e; text-align: right; }
.fp-card__row__v.badge { font-weight: 700; padding: 2px 8px; display: inline-block; }

.fp-card__actions { padding: 10px 12px; border-top: 1px solid #e0e5ed; display: flex; gap: 6px; flex-wrap: wrap; }
.fp-card__actions button { flex: 1; min-width: 90px; padding: 6px 10px; font-size: 11px; font-weight: 600; border: 1px solid #cdd3de; background: #f5f7fa; color: #05275C; cursor: pointer; border-radius: 0; transition: background 0.15s; }
.fp-card__actions button:hover { background: #dce4f0; }
.fp-card__actions button.btn-danger { color: #dc3545; border-color: #f5a5a5; }
.fp-card__actions button.btn-danger:hover { background: #fef5f5; }

/* ---- Badge styles ---- */
.badge-set-yes { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; padding: 3px 8px; font-size: 10px; font-weight: 700; }
.badge-set-no { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; padding: 3px 8px; font-size: 10px; font-weight: 700; }

/* ---- Empty state ---- */
.fp-empty { text-align: center; padding: 40px 20px; color: #999; }
.fp-empty__icon { font-size: 32px; margin-bottom: 8px; opacity: 0.5; }
.fp-empty__text { font-size: 13px; margin-bottom: 12px; }
.fp-empty__hint { font-size: 12px; color: #aaa; }

/* ---- Modal ---- */
.hr-modal-overlay {
    position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 10000;
    display: flex; align-items: center; justify-content: center;
}
.hr-modal { background: #fff; width: 620px; max-width: 96vw; max-height: 92vh; overflow-y: auto; border-radius: 2px; box-shadow: 0 8px 32px rgba(0,0,0,.2); }
.hr-modal--wide { width: 720px; }
.hr-modal-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 14px 20px; background: #05275C; color: #fff;
}
.hr-modal-header h4 { margin: 0; font-size: 14px; font-weight: 700; }
.hr-modal-close { background: none; border: none; color: #fff; font-size: 20px; cursor: pointer; line-height: 1; padding: 0 2px; }
.hr-modal-close:hover { color: #ccd; }
.hr-modal-body { padding: 20px; }
.hr-modal-footer { padding: 14px 20px; border-top: 1px solid #e0e5ed; display: flex; gap: 8px; justify-content: flex-end; }

/* ---- Form ---- */
.hr-form-group { margin-bottom: 14px; }
.hr-form-group label { display: block; font-size: 12px; font-weight: 600; color: #444; margin-bottom: 5px; }
.hr-form-group label .req { color: #dc3545; margin-left: 2px; }
.hr-input, .hr-select {
    width: 100%; padding: 7px 10px; font-size: 13px; border: 1px solid #cdd3de;
    border-radius: 0; background: #fff; color: #1a1a2e; box-sizing: border-box;
}
.hr-input:focus, .hr-select:focus { outline: none; border-color: #174DA4; }
.hr-input[readonly] { background: #f5f7fa; color: #666; }
.hr-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.hr-form-hint { font-size: 11px; color: #888; margin-top: 3px; }

/* ---- Status badge ---- */
.badge {
    display: inline-block; padding: 2px 8px; font-size: 11px; font-weight: 700;
    border-radius: 0; border: 1px solid transparent;
}
.badge-yes   { background: #dcfce7; color: #15803d; border-color: #bbf7d0; }
.badge-no    { background: #fef3c7; color: #b45309; border-color: #fde68a; }
.badge-level { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }

/* ---- Result msg ---- */
.form-result { padding: 8px 12px; font-size: 12px; font-weight: 600; margin-bottom: 12px; display: none; }
.form-result.error   { background: #fef5f5; color: #dc3545; border: 1px solid #fecaca; }
.form-result.success { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }

@media (max-width: 600px) {
    .hr-form-row { grid-template-columns: 1fr; }
    .hr-modal { width: 100%; max-height: 100vh; }
}

/* ---- Programme Courses Modal ---- */
.pc-add-section { background: #f5f7fa; border: 1px solid #e0e5ed; padding: 16px; margin-bottom: 16px; }
.pc-add-title { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; color: #05275C; margin-bottom: 12px; }
.pc-add-row { display: grid; grid-template-columns: 1fr 80px 80px auto; gap: 10px; align-items: end; }
.pc-search-wrap { position: relative; }
.pc-search-dropdown {
    position: absolute; top: 100%; left: 0; right: 0; z-index: 100;
    background: #fff; border: 1px solid #cdd3de; max-height: 200px; overflow-y: auto;
    display: none; box-shadow: 0 4px 12px rgba(0,0,0,.1);
}
.pc-search-dropdown.is-open { display: block; }
.pc-search-item { padding: 7px 10px; font-size: 12px; cursor: pointer; display: flex; gap: 8px; border-bottom: 1px solid #f0f2f5; }
.pc-search-item:hover { background: #f0f4fa; }
.pc-search-item .pc-si-code { font-weight: 700; color: #05275C; min-width: 90px; }
.pc-search-item .pc-si-name { color: #444; }
.pc-selected-course {
    margin-top: 4px; padding: 5px 8px; background: #eef2ff; border: 1px solid #d0d8f0;
    font-size: 12px; display: flex; align-items: center; gap: 6px;
}
.pc-selected-course .pc-sc-code { font-weight: 700; color: #05275C; }
.pc-selected-course .pc-sc-clear {
    background: none; border: none; color: #dc3545; cursor: pointer;
    font-size: 14px; margin-left: auto; padding: 0 4px;
}
.pc-table-wrap { overflow-x: auto; border: 1px solid #e0e5ed; max-height: 340px; overflow-y: auto; }
.pc-table { width: 100%; min-width: 480px; border-collapse: collapse; font-size: 12px; }
.pc-table thead th {
    background: #f5f7fa; border-bottom: 1px solid #e0e5ed; padding: 8px 10px;
    text-align: left; font-weight: 700; font-size: 10px; text-transform: uppercase;
    letter-spacing: .4px; color: #555; position: sticky; top: 0; z-index: 1;
}
.pc-table tbody td { border-bottom: 1px solid #f0f2f5; padding: 7px 10px; vertical-align: middle; }
.pc-table tbody tr:hover { background: #f8fafd; }
.pc-remove-btn {
    background: none; border: none; color: #dc3545; cursor: pointer;
    font-size: 13px; padding: 2px 6px;
}
.pc-remove-btn:hover { color: #b91c2c; background: #fef5f5; }
.pc-count { font-size: 12px; color: #666; margin-bottom: 8px; }
.pc-count strong { color: #05275C; }
.pc-empty { text-align: center; padding: 30px 20px; color: #888; font-size: 13px; }
@media (max-width: 600px) {
    .pc-add-row { grid-template-columns: 1fr 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- Hidden postback infrastructure -->
    <asp:HiddenField ID="hdnEditProgcode" runat="server" />
    <asp:HiddenField ID="hdnModalMode"    runat="server" />   <%-- NEW or EDIT --%>
    <asp:HiddenField ID="hdnStructureCode" runat="server" />
    <asp:Button ID="btnSaveProgramme"  runat="server" style="display:none" OnClick="btnSaveProgramme_Click" />
    <asp:Button ID="btnDeleteProgramme" runat="server" style="display:none" OnClick="btnDeleteProgramme_Click" />
    <asp:Button ID="btnOpenStructure"  runat="server" style="display:none" OnClick="btnOpenStructure_Click" />
    <asp:HiddenField ID="hdnCourseProgcode" runat="server" />
    <asp:HiddenField ID="hdnSelectedCourse" runat="server" />
    <asp:HiddenField ID="hdnDeleteCourseId" runat="server" />
    <asp:Button ID="btnLoadCourses" runat="server" style="display:none" OnClick="btnLoadCourses_Click" UseSubmitBehavior="false" />
    <asp:Button ID="btnDeleteCourse" runat="server" style="display:none" OnClick="btnDeleteCourse_Click" UseSubmitBehavior="false" />

    <!-- Stats strip -->
    <div class="stats-strip">
        <div class="stat-box">
            <div class="stat-box__value" id="statTotalProgs">0</div>
            <div class="stat-box__label">Total Programmes</div>
        </div>
        <div class="stat-box">
            <div class="stat-box__value" id="statFullySet">0</div>
            <div class="stat-box__label">Fully Configured</div>
        </div>
        <div class="stat-box">
            <div class="stat-box__value" id="statFaculties">0</div>
            <div class="stat-box__label">Faculties</div>
        </div>
        <div class="stat-box">
            <div class="stat-box__value" id="statSpecializations">0</div>
            <div class="stat-box__label">Total Specializations</div>
        </div>
    </div>

    <!-- Filter bar -->
    <div class="filter-bar">
        <span class="filter-bar__title">Academic Programmes</span>
        <label>Search/Filter:</label>
        <input type="text" id="fpSearchInput" placeholder="Programme code, name, or faculty..." />
        <select id="fpFilterLevel">
            <option value="">All Levels</option>
            <option value="0">Elementary</option>
            <option value="1">Certificate</option>
            <option value="2">Diploma</option>
            <option value="3">Bachelors Degree</option>
            <option value="4">Post Graduate Diploma</option>
            <option value="5">Masters Degree</option>
            <option value="6">Doctorate</option>
        </select>
        <select id="fpFilterFully">
            <option value="">All Status</option>
            <option value="Yes">Fully Set</option>
            <option value="No">Not Complete</option>
        </select>
        <div class="filter-divider"></div>
        <button type="button" class="hr-btn hr-btn--outline btn-filter-clear" onclick="fpResetFilters()">Clear Filters</button>
        <span class="filter-bar__spacer"></span>
        <button type="button" class="hr-btn hr-btn--addblend" onclick="openProgModal('NEW')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Add New Programme
        </button>
    </div>

    <!-- Card list -->
    <asp:Literal ID="litProgrammesList" runat="server" />

    <!-- ===== Create / Edit Modal ===== -->
    <div id="progModal" class="hr-modal-overlay" style="display:none">
        <div class="hr-modal">
            <div class="hr-modal-header">
                <h4 id="modalTitle">New Programme</h4>
                <button type="button" class="hr-modal-close" onclick="closeProgModal()">&times;</button>
            </div>
            <div class="hr-modal-body">
                <div id="modalResult" class="form-result"></div>

                <div class="hr-form-row">
                    <div class="hr-form-group">
                        <label>Programme Code <span class="req">*</span></label>
                        <asp:TextBox ID="txtProgcode" runat="server" CssClass="hr-input"
                            placeholder="e.g. BSC-CS" MaxLength="20" />
                        <div class="hr-form-hint">Short unique identifier (e.g. BSC-CS, DIPL-ACC)</div>
                    </div>
                    <div class="hr-form-group">
                        <label>Abbreviation</label>
                        <asp:TextBox ID="txtAbbrev" runat="server" CssClass="hr-input"
                            placeholder="e.g. BSc CS" MaxLength="30" />
                    </div>
                </div>

                <div class="hr-form-group">
                    <label>Programme Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtProgname" runat="server" CssClass="hr-input"
                        placeholder="e.g. Bachelor of Science in Computer Science" MaxLength="200" />
                </div>

                <div class="hr-form-row">
                    <div class="hr-form-group">
                        <label>Faculty <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="hr-select" />
                    </div>
                    <div class="hr-form-group">
                        <label>Academic Level <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlLevel" runat="server" CssClass="hr-select">
                            <asp:ListItem Value=""  Text="-- Select Level --" />
                            <asp:ListItem Value="0" Text="Elementary" />
                            <asp:ListItem Value="1" Text="Certificate" />
                            <asp:ListItem Value="2" Text="Diploma" />
                            <asp:ListItem Value="3" Text="Bachelors Degree" />
                            <asp:ListItem Value="4" Text="Post Graduate Diploma" />
                            <asp:ListItem Value="5" Text="Masters Degree" />
                            <asp:ListItem Value="6" Text="Doctorate" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="hr-form-row">
                    <div class="hr-form-group">
                        <label>Duration (Years) <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlDuration" runat="server" CssClass="hr-select">
                            <asp:ListItem Value=""  Text="-- Select --" />
                            <asp:ListItem Value="1" Text="1 Year" />
                            <asp:ListItem Value="2" Text="2 Years" />
                            <asp:ListItem Value="3" Text="3 Years" />
                            <asp:ListItem Value="4" Text="4 Years" />
                            <asp:ListItem Value="5" Text="5 Years" />
                            <asp:ListItem Value="6" Text="6 Years" />
                        </asp:DropDownList>
                    </div>
                    <div class="hr-form-group">
                        <label>Max Duration (Years)</label>
                        <asp:TextBox ID="txtMaxDuration" runat="server" CssClass="hr-input"
                            placeholder="e.g. 6" TextMode="Number" />
                        <div class="hr-form-hint">Maximum years a student can complete the programme</div>
                    </div>
                </div>

                <div class="hr-form-row">
                    <div class="hr-form-group">
                        <label>Study System <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlStudySystem" runat="server" CssClass="hr-select">
                            <asp:ListItem Value=""          Text="-- Select --" />
                            <asp:ListItem Value="FULL TIME"  Text="Full Time" />
                            <asp:ListItem Value="PART TIME"  Text="Part Time" />
                            <asp:ListItem Value="DISTANCE"   Text="Distance Learning" />
                            <asp:ListItem Value="BLENDED"    Text="Blended" />
                        </asp:DropDownList>
                    </div>
                    <div class="hr-form-group">
                        <label>Min. Credit Hours</label>
                        <asp:TextBox ID="txtMinCredit" runat="server" CssClass="hr-input"
                            placeholder="e.g. 120" TextMode="Number" />
                    </div>
                </div>

                <div class="hr-form-group">
                    <label>Fully Set?</label>
                    <asp:DropDownList ID="ddlFullySet" runat="server" CssClass="hr-select" style="width:auto; min-width:160px">
                        <asp:ListItem Value="No"  Text="No — Still being configured" />
                        <asp:ListItem Value="Yes" Text="Yes — Ready for use" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-modal-footer">
                <button type="button" class="hr-btn hr-btn--outline" onclick="closeProgModal()">Cancel</button>
                <asp:Button ID="btnSaveProgModal" runat="server" CssClass="hr-btn hr-btn--primary"
                    Text="Save Programme" OnClick="btnSaveProgramme_Click" />
            </div>
        </div>
    </div>

    <!-- ===== Programme Courses Modal ===== -->
    <div id="courseModal" class="hr-modal-overlay" style="display:none">
        <div class="hr-modal hr-modal--wide">
            <div class="hr-modal-header">
                <h4 id="courseModalTitle">Programme Courses</h4>
                <button type="button" class="hr-modal-close" onclick="closeCourseModal()">&times;</button>
            </div>
            <div class="hr-modal-body">
                <div id="courseModalResult" class="form-result"></div>

                <!-- Add Course Section -->
                <div class="pc-add-section">
                    <div class="pc-add-title">Add New Course</div>
                    <div class="pc-add-row">
                        <div class="hr-form-group pc-search-wrap" style="margin-bottom:0;">
                            <label>Course <span class="req">*</span></label>
                            <input type="text" id="courseSearchInput" class="hr-input"
                                placeholder="Type course code or name..." autocomplete="off" />
                            <div id="courseSearchResults" class="pc-search-dropdown"></div>
                            <div id="courseSelectedDisplay" class="pc-selected-course" style="display:none;"></div>
                        </div>
                        <div class="hr-form-group" style="margin-bottom:0;">
                            <label>Year <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlCourseYear" runat="server" CssClass="hr-select">
                                <asp:ListItem Value="1" Text="1" />
                                <asp:ListItem Value="2" Text="2" />
                                <asp:ListItem Value="3" Text="3" />
                                <asp:ListItem Value="4" Text="4" />
                                <asp:ListItem Value="5" Text="5" />
                                <asp:ListItem Value="6" Text="6" />
                            </asp:DropDownList>
                        </div>
                        <div class="hr-form-group" style="margin-bottom:0;">
                            <label>Sem <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlCourseSem" runat="server" CssClass="hr-select">
                                <asp:ListItem Value="1" Text="1" />
                                <asp:ListItem Value="2" Text="2" />
                            </asp:DropDownList>
                        </div>
                        <div class="hr-form-group" style="margin-bottom:0;align-self:end;">
                            <asp:Button ID="btnSaveCourseModal" runat="server" CssClass="hr-btn hr-btn--success"
                                Text="+ Add" OnClick="btnSaveCourse_Click" UseSubmitBehavior="false" />
                        </div>
                    </div>
                </div>

                <!-- Existing Courses Table -->
                <asp:Literal ID="litCoursesTable" runat="server" />
            </div>
            <div class="hr-modal-footer">
                <button type="button" class="hr-btn hr-btn--outline" onclick="closeCourseModal()">Close</button>
            </div>
        </div>
    </div>

    <!-- Programme Structure Popup -->
    <dx:ASPxPopupControl ID="popStructure" runat="server"
        HeaderText="Programme Structure"
        PopupHorizontalAlign="WindowCenter"
        PopupVerticalAlign="WindowCenter"
        Width="940px" Height="580px"
        Modal="True"
        CloseAction="CloseButton"
        EnableTheming="True" Theme="Glass"
        ClientInstanceName="popStructure">
        <HeaderStyle Font-Bold="True" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server" />
        </ContentCollection>
    </dx:ASPxPopupControl>

    <!-- Faculty data source (for server-side load) -->
    <asp:SqlDataSource ID="dsFaculties" runat="server"
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>"
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name">
    </asp:SqlDataSource>

<!-- ===== JavaScript ===== -->
<script type="text/javascript">
/* ---- Filter functionality ---- */
var _fpAllData = [];

function fpInitialize(data) {
    _fpAllData = data || [];
    document.getElementById('fpSearchInput').addEventListener('input', fpApplyFilters);
    document.getElementById('fpFilterLevel').addEventListener('change', fpApplyFilters);
    document.getElementById('fpFilterFully').addEventListener('change', fpApplyFilters);
    fpUpdateStats();
}

function fpApplyFilters() {
    var searchTerm = document.getElementById('fpSearchInput').value.toLowerCase().trim();
    var levelFilter = document.getElementById('fpFilterLevel').value;
    var fullyFilter = document.getElementById('fpFilterFully').value;
    
    var filtered = _fpAllData.filter(function(p) {
        var matchSearch = !searchTerm || 
            p.code.toLowerCase().indexOf(searchTerm) !== -1 ||
            p.name.toLowerCase().indexOf(searchTerm) !== -1 ||
            p.faculty.toLowerCase().indexOf(searchTerm) !== -1;
        var matchLevel = !levelFilter || p.level.toString() === levelFilter;
        var matchFully = !fullyFilter || p.fully === fullyFilter;
        return matchSearch && matchLevel && matchFully;
    });
    
    fpRenderCards(filtered);
}

function fpRenderCards(programmes) {
    var container = document.querySelector('.fp-card-list');
    if (!container) return;
    
    if (programmes.length === 0) {
        container.innerHTML = '<div class="fp-empty"><div class="fp-empty__icon">📋</div><div class="fp-empty__text">No programmes match your filters</div><div class="fp-empty__hint">Try adjusting your search or filter criteria</div></div>';
        return;
    }
    
    container.innerHTML = programmes.map(function(p) {
        return '<div class="fp-card">' +
            '<div class="fp-card__header">' +
                '<div class="fp-card__title">' + _escH(p.code) + ' — ' + _escH(p.name) + '</div>' +
                '<div class="fp-card__subtitle">' + _escH(p.faculty) + '</div>' +
            '</div>' +
            '<div class="fp-card__body">' +
                '<div class="fp-card__row"><span class="fp-card__row__k">Level:</span><span class="fp-card__row__v">' + _escH(p.level_label) + '</span></div>' +
                '<div class="fp-card__row"><span class="fp-card__row__k">Duration:</span><span class="fp-card__row__v">' + p.duration + ' year(s)</span></div>' +
                '<div class="fp-card__row"><span class="fp-card__row__k">Study System:</span><span class="fp-card__row__v">' + _escH(p.study_system) + '</span></div>' +
                '<div class="fp-card__row"><span class="fp-card__row__k">Specializations:</span><span class="fp-card__row__v"><strong>' + p.spec_count + '</strong></span></div>' +
                '<div class="fp-card__row"><span class="fp-card__row__k">Status:</span><span class="badge ' + (p.fully === 'Yes' ? 'badge-set-yes' : 'badge-set-no') + '">' + p.fully + '</span></div>' +
            '</div>' +
            '<div class="fp-card__actions">' +
                '<button type="button" onclick="editProg(\'' + _escA(p.code) + '\')">✎ Edit</button>' +
                '<button type="button" onclick="openStructure(\'' + _escA(p.code) + '\')">≡ Structure</button>' +
                '<button type="button" onclick="openCourses(\'' + _escA(p.code) + '\')">📖 Courses</button>' +
                '<button type="button" class="btn-danger" onclick="deleteProg(\'' + _escA(p.code) + '\',\'' + _escA(p.name) + '\')">✕ Delete</button>' +
            '</div>' +
        '</div>';
    }).join('');
}

function fpResetFilters() {
    document.getElementById('fpSearchInput').value = '';
    document.getElementById('fpFilterLevel').value = '';
    document.getElementById('fpFilterFully').value = '';
    fpApplyFilters();
}

function fpUpdateStats() {
    var total = _fpAllData.length;
    var fullySet = _fpAllData.filter(function(p) { return p.fully === 'Yes'; }).length;
    var totalSpecs = _fpAllData.reduce(function(sum, p) { return sum + (p.spec_count || 0); }, 0);
    var faculties = new Set(_fpAllData.map(function(p) { return p.faculty; })).size;
    
    document.getElementById('statTotalProgs').textContent = total;
    document.getElementById('statFullySet').textContent = fullySet;
    document.getElementById('statFaculties').textContent = faculties;
    document.getElementById('statSpecializations').textContent = totalSpecs;
}

/* ---- Modal ---- */
function openProgModal(mode, progcode) {
    document.getElementById('modalResult').style.display = 'none';
    document.getElementById('<%= hdnModalMode.ClientID %>').value = mode || 'NEW';
    document.getElementById('<%= hdnEditProgcode.ClientID %>').value = progcode || '';
    document.getElementById('modalTitle').textContent = (mode === 'EDIT') ? 'Edit Programme' : 'New Programme';

    var codeBox = document.getElementById('<%= txtProgcode.ClientID %>');
    if (mode === 'EDIT') {
        codeBox.readOnly = true;
        codeBox.style.background = '#f5f7fa';
        codeBox.style.color = '#666';
    } else {
        codeBox.readOnly = false;
        codeBox.style.background = '';
        codeBox.style.color = '';
    }
    document.getElementById('progModal').style.display = 'flex';
}
function closeProgModal() {
    document.getElementById('progModal').style.display = 'none';
}

function editProg(code) {
    document.getElementById('<%= hdnEditProgcode.ClientID %>').value = code;
    document.getElementById('<%= hdnModalMode.ClientID %>').value = 'LOAD';
    document.getElementById('<%= btnSaveProgramme.ClientID %>').click();
}
function deleteProg(code, name) {
    if (!confirm('Delete programme "' + name + '" (' + code + ')?\n\nThis will also remove all associated specialisations. This cannot be undone.')) return;
    document.getElementById('<%= hdnEditProgcode.ClientID %>').value = code;
    document.getElementById('<%= btnDeleteProgramme.ClientID %>').click();
}
function openStructure(code) {
    document.getElementById('<%= hdnStructureCode.ClientID %>').value = code;
    document.getElementById('<%= btnOpenStructure.ClientID %>').click();
}

/* ---- Toast ---- */
function showToast(msg, type) {
    var t = document.createElement('div');
    t.style.cssText = 'position:fixed;bottom:20px;right:20px;z-index:99999;padding:10px 18px;border-radius:4px;font-size:13px;font-weight:600;color:#fff;box-shadow:0 3px 10px rgba(0,0,0,.2);opacity:1;transition:opacity .4s;';
    t.style.background = type==='success' ? '#16a34a' : type==='danger' ? '#dc3545' : type==='warning' ? '#d97706' : '#174DA4';
    t.textContent = msg;
    document.body.appendChild(t);
    setTimeout(function(){ t.style.opacity='0'; setTimeout(function(){ if(t.parentNode) t.parentNode.removeChild(t); },400); }, 3000);
}

/* ---- Modal close on overlay click / Escape ---- */
document.getElementById('progModal').addEventListener('click', function(e){ if(e.target===this) closeProgModal(); });
document.getElementById('courseModal').addEventListener('click', function(e){ if(e.target===this) closeCourseModal(); });
document.addEventListener('keydown', function(e){
    if(e.key==='Escape'){ closeProgModal(); closeCourseModal(); }
});

/* ---- Programme Courses Modal ---- */
function openCourses(code) {
    document.getElementById('<%= hdnCourseProgcode.ClientID %>').value = code;
    __doPostBack('<%= btnLoadCourses.UniqueID %>', '');
}
function openCourseModal(progcode, progname) {
    document.getElementById('courseModalTitle').textContent = progname + ' [' + progcode + ']';
    document.getElementById('courseModalResult').style.display = 'none';
    document.getElementById('courseModal').style.display = 'flex';
    if (!window._csInit) { initCourseSearch(); window._csInit = true; }
}
function closeCourseModal() {
    document.getElementById('courseModal').style.display = 'none';
    clearCourseSearch();
}

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
            var all = window.__courses || [];
            var m = [];
            for (var i = 0; i < all.length && m.length < 15; i++) {
                if (all[i].c.toLowerCase().indexOf(q) !== -1 || all[i].n.toLowerCase().indexOf(q) !== -1)
                    m.push(all[i]);
            }
            if (m.length === 0) {
                dd.innerHTML = '<div style="padding:8px 10px;font-size:12px;color:#888;">No courses found</div>';
            } else {
                dd.innerHTML = m.map(function(x) {
                    return '<div class="pc-search-item" onclick="selectCourse(\'' + _escA(x.c) + '\',\'' + _escA(x.n) + '\')">' +
                        '<span class="pc-si-code">' + _escH(x.c) + '</span>' +
                        '<span class="pc-si-name">' + _escH(x.n) + '</span></div>';
                }).join('');
            }
            dd.classList.add('is-open');
        }, 150);
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
    d.innerHTML = '<span class="pc-sc-code">' + _escH(code) + '</span> ' + _escH(name) +
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
function removeCourse(id) {
    if (!confirm('Remove this course from the programme structure?')) return;
    document.getElementById('<%= hdnDeleteCourseId.ClientID %>').value = id;
    __doPostBack('<%= btnDeleteCourse.UniqueID %>', '');
}
function _escH(s) { var d=document.createElement('div');d.appendChild(document.createTextNode(s));return d.innerHTML; }
function _escA(s) { return s.replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }
</script>

</asp:Content>
