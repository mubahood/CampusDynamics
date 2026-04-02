<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsUpdates.aspx.cs" Inherits="COOPERP_NewScreens_ResultsUpdates" Title="Results Updates - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style>
/* ===== RESULTS UPDATES — em-/mat- design system ================ */

/* ── Shared Exam Module Nav ── */
.em-hdr{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:12px 20px}
.em-hdr__title{font-size:15px;font-weight:700}
.em-hdr__sub{font-size:10px;opacity:.7;margin-top:1px}
.em-hdr__actions{display:flex;gap:6px;align-items:center}
.em-tabs{display:flex;gap:0;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 16px;overflow-x:auto;margin-bottom:12px}
.em-tab{padding:9px 14px;font-size:11px;font-weight:500;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;white-space:nowrap;transition:color .15s,border-color .15s}
.em-tab:hover{color:#1a237e}
.em-tab--active{color:#1a237e;border-bottom-color:#1a237e;font-weight:600}

/* ── Stats Row ── */
.mat-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:12px}
.mat-stat{background:#fff;border:1px solid #e0e5ed;padding:10px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.mat-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--c,#ccc)}
.mat-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.mat-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.mat-stat--total{--c:#1a237e}.mat-stat--total .mat-stat__val{color:#1a237e}
.mat-stat--pending{--c:#e65100}.mat-stat--pending .mat-stat__val{color:#e65100}
.mat-stat--approved{--c:#2e7d32}.mat-stat--approved .mat-stat__val{color:#2e7d32}
.mat-stat--year{--c:#6a1b9a}.mat-stat--year .mat-stat__val{color:#6a1b9a}
.mat-stat--sem{--c:#00838f}.mat-stat--sem .mat-stat__val{color:#00838f}

/* ── Card ── */
.mat-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:12px}
.mat-card__hdr{padding:8px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.mat-card__title{font-size:12px;font-weight:700;color:#1a237e;display:flex;align-items:center;gap:6px}
.mat-card__meta{font-size:10px;color:#1a237e;font-weight:600;background:rgba(26,35,126,.07);padding:2px 8px;border:1px solid rgba(26,35,126,.15)}

/* ── Filters (collapsible) ── */
.mat-filtbar{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px;display:none}
.mat-filtbar.show{display:block}
.mat-filtbar__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.mat-fg{display:flex;flex-direction:column;gap:3px}
.mat-fg__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.mat-fg select,.mat-fg input[type="text"]{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;min-width:120px;font-family:inherit}
.mat-fg select:focus,.mat-fg input[type="text"]:focus{border-color:#1a237e;outline:none}

/* ── Buttons ── */
.mat-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;font-family:inherit}
.mat-btn--primary{background:#1a237e;color:#fff}.mat-btn--primary:hover{background:#283593}
.mat-btn--success{background:#16a34a;color:#fff}.mat-btn--success:hover{background:#15803d}
.mat-btn--warning{background:#e65100;color:#fff}.mat-btn--warning:hover{background:#bf360c}
.mat-btn--danger{background:#dc3545;color:#fff}.mat-btn--danger:hover{background:#c82333}
.mat-btn--ghost{background:transparent;color:#555;border:1px solid #e0e5ed}.mat-btn--ghost:hover{background:#f5f7fa}
.mat-btn--sm{padding:4px 10px;font-size:10px}
.mat-btn--filter{padding:4px 10px;font-size:10px;background:#e8eaf6;border:1px solid #c5cae9;color:#1a237e;cursor:pointer}
.mat-btn--filter:hover{background:#c5cae9}
.mat-btn--filter.active{background:#1a237e;color:#fff;border-color:#1a237e}

/* ── Search row ── */
.mat-search{display:flex;gap:6px;align-items:center;padding:6px 14px;border-bottom:1px solid #e0e5ed}
.mat-search__input{flex:1;max-width:300px;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;font-family:inherit}
.mat-search__input:focus{border-color:#1a237e;outline:none}
.mat-search__msg{font-size:10px;color:#888;margin-left:8px}

/* ── Batch bar ── */
.mat-selbar{display:flex;align-items:center;gap:6px;padding:6px 14px;background:#263238;flex-wrap:wrap}
.mat-selbar .mat-btn--ghost{color:#fff;border-color:rgba(255,255,255,.25)}

/* ── Grid ── */
.mat-grid .dxgvHeader td{background:#f5f7fa!important;font-size:10px!important;font-weight:600!important;text-transform:uppercase!important;letter-spacing:.3px;padding:9px 8px!important;color:#555!important;border-bottom:2px solid #1a237e!important;white-space:nowrap}
.mat-grid .dxgvDataRow td{font-size:11px!important;padding:7px 8px!important;border-bottom:1px solid #f0f2f5!important;vertical-align:middle!important;color:#1a1a2e}
.mat-grid .dxgvDataRow:hover td{background:#eef2fc!important}
.mat-grid .dxgvDataRow:nth-child(even) td{background:#f9fafb!important}
.mat-grid .dxgvDataRow:nth-child(even):hover td{background:#eef2fc!important}
.mat-grid .dxgvSelectedRow td{background:#e8eaf6!important}
.mat-grid .dxgvFocusedRow td{background:#c5cae9!important}

/* ── Status badges ── */
.mat-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px}
.mat-badge--approved{background:#e6f4ea;color:#155724;border:1px solid #c3e6cb}
.mat-badge--pending{background:#fff8e1;color:#e65100;border:1px solid #ffe0b2}
.mat-badge--updated{background:#e8f0fc;color:#0d47a1;border:1px solid #90caf9}

/* ── Edit Panel (inline) ── */
.mat-edit{background:#f8f9fb;border:1px solid #e0e5ed;padding:12px 14px;margin-bottom:12px;display:none}
.mat-edit.show{display:block}
.mat-edit__title{font-size:12px;font-weight:700;color:#1a237e;margin-bottom:10px;display:flex;align-items:center;gap:6px}
.mat-edit__grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:8px;margin-bottom:10px}
.mat-edit__field{display:flex;flex-direction:column;gap:3px}
.mat-edit__field label{font-size:9px;color:#999;text-transform:uppercase;letter-spacing:.5px;font-weight:600}
.mat-edit__field input,.mat-edit__field select{border:1px solid #e0e5ed;padding:5px 8px;font-size:11px;font-family:inherit}
.mat-edit__field input:focus,.mat-edit__field select:focus{border-color:#1a237e;outline:none}
.mat-edit__field input[readonly]{background:#f0f2f5;color:#888}
.mat-edit__actions{display:flex;gap:6px;padding-top:8px;border-top:1px solid #e0e5ed}

/* ── Alert ── */
.mat-alert{padding:8px 14px;margin-bottom:10px;font-size:11px;border-left:3px solid;display:flex;align-items:center;gap:6px}
.mat-alert--error{border-color:#dc3545;background:#fef5f5;color:#991b1b}
.mat-alert--success{border-color:#16a34a;background:#e6f4ea;color:#155724}
.mat-alert--warning{border-color:#d97706;background:#fffbeb;color:#92400e}

/* ── Modal (Summary Report) ── */
.mat-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:9998;align-items:center;justify-content:center}
.mat-modal-bg.show{display:flex}
.mat-modal{background:#fff;width:480px;max-width:96vw;max-height:92vh;overflow-y:auto;box-shadow:0 12px 40px rgba(0,0,0,.18)}
.mat-modal__hdr{background:#1a237e;padding:10px 16px;display:flex;align-items:center;justify-content:space-between}
.mat-modal__title{font-size:13px;font-weight:700;color:#fff}
.mat-modal__close{border:none;background:rgba(255,255,255,.15);color:#fff;font-size:16px;cursor:pointer;width:24px;height:24px;display:flex;align-items:center;justify-content:center}
.mat-modal__body{padding:16px}
.mat-modal__footer{padding:10px 16px;border-top:1px solid #e0e5ed;display:flex;gap:8px;justify-content:flex-end;background:#f8f9fb}
.mat-modal__desc{font-size:11px;color:#888;margin-bottom:14px}

/* ── Preview grid (inside modal) ── */
.mat-prev{margin-top:14px;padding:12px;background:#f8f9fb;border:1px solid #e0e5ed}
.mat-prev__title{font-size:11px;font-weight:700;color:#1a237e;margin-bottom:10px}
.mat-prev__grid{display:grid;grid-template-columns:repeat(2,1fr);gap:8px}
.mat-prev__stat{text-align:center;padding:8px;background:#fff;border:1px solid #e0e5ed}
.mat-prev__stat-val{font-size:18px;font-weight:700;font-variant-numeric:tabular-nums}
.mat-prev__stat-lbl{font-size:9px;color:#888;text-transform:uppercase;margin-top:2px}
.mat-prev__total{margin-top:10px;padding-top:10px;border-top:1px solid #e0e5ed;text-align:center;font-size:13px;font-weight:700;color:#1a237e}

/* ── Marks mono ── */
.mat-mono{font-family:Consolas,monospace;font-variant-numeric:tabular-nums}

/* ── Responsive ── */
@media(max-width:1200px){.mat-stats{grid-template-columns:repeat(3,1fr)}}
@media(max-width:768px){.mat-stats{grid-template-columns:1fr}}
@media print{.em-hdr,.em-tabs,.mat-selbar{display:none!important}}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

<!-- ── Header + Tabs ── -->
<div class="em-hdr">
    <div><div class="em-hdr__title">Results Updates</div><div class="em-hdr__sub">Track and manage batch result updates and corrections</div></div>
    <div class="em-hdr__actions">
        <button type="button" class="mat-btn mat-btn--primary mat-btn--sm" onclick="openSummaryReportModal()">Summary Report</button>
        <asp:Button ID="btnExportExcel" runat="server" Text="Export" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnExportExcel_Click" />
    </div>
</div>
<div class="em-tabs">
    <a href="ExamResultsInfo.aspx" class="em-tab">Exam Results</a>
    <a href="ResultsRelease.aspx" class="em-tab">Results Release</a>
    <a href="ResultsUpdates.aspx" class="em-tab em-tab--active">Updates</a>
    <a href="ResultsHoldList.aspx" class="em-tab">Hold List</a>
    <a href="ResultsAuditLog.aspx" class="em-tab">Audit Log</a>
    <a href="MarksAuditTrail.aspx" class="em-tab">Marks Trail</a>
    <a href="ResultsAnalytics.aspx" class="em-tab">Analytics</a>
</div>

<!-- ── Stats ── -->
<div class="mat-stats">
    <div class="mat-stat mat-stat--year"><div><div class="mat-stat__val"><asp:Literal ID="litAcadYearDisplay" runat="server">—</asp:Literal></div><div class="mat-stat__label">Academic Year</div></div></div>
    <div class="mat-stat mat-stat--sem"><div><div class="mat-stat__val"><asp:Literal ID="litSemesterDisplay" runat="server">—</asp:Literal></div><div class="mat-stat__label">Semester</div></div></div>
    <div class="mat-stat mat-stat--total"><div><div class="mat-stat__val"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal></div><div class="mat-stat__label">Total Records</div></div></div>
    <div class="mat-stat mat-stat--pending"><div><div class="mat-stat__val"><asp:Literal ID="litPendingCount" runat="server">0</asp:Literal></div><div class="mat-stat__label">Pending</div></div></div>
    <div class="mat-stat mat-stat--approved"><div><div class="mat-stat__val"><asp:Literal ID="litApprovedCount" runat="server">0</asp:Literal></div><div class="mat-stat__label">Approved</div></div></div>
</div>

<!-- ── Alert ── -->
<asp:Panel ID="pnlMessage" runat="server" CssClass="mat-alert mat-alert--error" Visible="false">
    <asp:Literal ID="litMessage" runat="server" />
</asp:Panel>

<!-- ── Edit Panel ── -->
<asp:Panel ID="pnlEdit" runat="server" CssClass="mat-edit" Visible="false">
    <div class="mat-edit__title">Edit Result — <asp:Literal ID="litStudentName" runat="server" /></div>
    <asp:HiddenField ID="hfResultID" runat="server" />
    <div class="mat-edit__grid">
        <div class="mat-edit__field"><label>Reg No</label><asp:TextBox ID="txtRegNo" runat="server" ReadOnly="true" /></div>
        <div class="mat-edit__field"><label>Course</label><asp:TextBox ID="txtCourse" runat="server" ReadOnly="true" /></div>
        <div class="mat-edit__field"><label>Coursework (CA)</label><asp:TextBox ID="txtCoursework" runat="server" /></div>
        <div class="mat-edit__field"><label>Exam</label><asp:TextBox ID="txtExam" runat="server" /></div>
        <div class="mat-edit__field"><label>Total</label><asp:TextBox ID="txtTotal" runat="server" ReadOnly="true" /></div>
        <div class="mat-edit__field"><label>Grade</label><asp:TextBox ID="txtGrade" runat="server" ReadOnly="true" /></div>
        <div class="mat-edit__field"><label>Remark</label>
            <asp:DropDownList ID="ddlRemark" runat="server">
                <asp:ListItem Text="Normal" Value="" />
                <asp:ListItem Text="Retake" Value="RETAKE" />
                <asp:ListItem Text="Supplementary" Value="SUPP" />
                <asp:ListItem Text="Special" Value="SPECIAL" />
            </asp:DropDownList>
        </div>
        <div class="mat-edit__field"><label>Reason</label><asp:TextBox ID="txtReason" runat="server" /></div>
    </div>
    <div class="mat-edit__actions">
        <asp:Button ID="btnSaveUpdate" runat="server" Text="Save" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnSaveUpdate_Click" />
        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="mat-btn mat-btn--ghost mat-btn--sm" OnClick="btnCancelEdit_Click" />
    </div>
</asp:Panel>

<!-- ── Main Card ── -->
<div class="mat-card">
    <div class="mat-card__hdr">
        <span class="mat-card__title">Exam Results</span>
        <div style="display:flex;gap:6px;align-items:center">
            <button type="button" class="mat-btn--filter" id="btnToggleFilter" onclick="toggleFilters()">Filters</button>
        </div>
    </div>
    <!-- Collapsible Filters -->
    <div class="mat-filtbar" id="matFilterBar">
        <div class="mat-filtbar__row">
            <div class="mat-fg">
                <span class="mat-fg__label">Faculty</span>
                <asp:DropDownList ID="ddlFaculty" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged">
                    <asp:ListItem Text="All" Value="" />
                </asp:DropDownList>
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Programme</span>
                <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged">
                    <asp:ListItem Text="All" Value="" />
                </asp:DropDownList>
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Academic Year</span>
                <asp:DropDownList ID="ddlAcadYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
                    <asp:ListItem Text="All" Value="" />
                </asp:DropDownList>
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Semester</span>
                <asp:DropDownList ID="ddlSemester" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                    <asp:ListItem Text="All" Value="" />
                    <asp:ListItem Text="Sem 1" Value="1" />
                    <asp:ListItem Text="Sem 2" Value="2" />
                </asp:DropDownList>
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Course</span>
                <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged">
                    <asp:ListItem Text="All" Value="" />
                </asp:DropDownList>
            </div>
        </div>
    </div>
    <!-- Search -->
    <div class="mat-search">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="mat-search__input" placeholder="Search by Reg No or Name..." />
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="mat-btn mat-btn--primary mat-btn--sm" OnClick="btnSearch_Click" />
        <asp:Label ID="lblMessage" runat="server" CssClass="mat-search__msg" />
    </div>
    <!-- Batch Actions -->
    <div class="mat-selbar">
        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="mat-btn mat-btn--ghost mat-btn--sm" OnClick="btnRefresh_Click" />
        <asp:Button ID="btnEditSelected" runat="server" Text="Edit" CssClass="mat-btn mat-btn--primary mat-btn--sm" OnClick="btnEditSelected_Click" />
        <asp:Button ID="btnApproveSelected" runat="server" Text="Approve" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnApproveSelected_Click" />
        <asp:Button ID="btnRevertSelected" runat="server" Text="Revert" CssClass="mat-btn mat-btn--warning mat-btn--sm" OnClick="btnRevertSelected_Click" />
    </div>
    <!-- Grid -->
    <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" CssClass="mat-grid"
        KeyFieldName="ID" AutoGenerateColumns="False" EnableCallBacks="true"
        OnCustomColumnDisplayText="gvResults_CustomColumnDisplayText">
        <SettingsBehavior AllowSelectByRowClick="true" AllowSelectSingleRowOnly="false" />
        <SettingsPager PageSize="50" AlwaysShowPager="true">
            <Summary Visible="true" Text="Page {0} of {1} ({2} records)" />
            <PageSizeItemSettings Visible="true" Items="25, 50, 100, 200" />
        </SettingsPager>
        <Settings ShowFilterRow="true" />
        <Columns>
            <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="32px" />
            <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Visible="false" />
            <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="1" Width="105px">
                <Settings AutoFilterCondition="Contains" />
                <CellStyle Font-Bold="true" ForeColor="#1a237e" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Name" VisibleIndex="2" Width="150px">
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="course_id" Caption="Course" VisibleIndex="3" Width="80px">
                <CellStyle Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course Name" VisibleIndex="4" Width="140px" />
            <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme" VisibleIndex="5" Width="120px" />
            <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Year" VisibleIndex="6" Width="70px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="7" Width="36px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="ca_mark" Caption="CA" VisibleIndex="8" Width="42px">
                <CellStyle HorizontalAlign="Center" CssClass="mat-mono" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="exam_mark" Caption="Exam" VisibleIndex="9" Width="42px">
                <CellStyle HorizontalAlign="Center" CssClass="mat-mono" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="total_mark" Caption="Total" VisibleIndex="10" Width="42px">
                <CellStyle HorizontalAlign="Center" Font-Bold="true" CssClass="mat-mono" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="grade" Caption="Grade" VisibleIndex="11" Width="42px">
                <CellStyle HorizontalAlign="Center" Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="gpa" Caption="GPA" VisibleIndex="12" Width="38px">
                <CellStyle HorizontalAlign="Center" CssClass="mat-mono" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="approved_by" Caption="Status" VisibleIndex="13" Width="82px">
                <DataItemTemplate><%# GetStatusBadge(Eval("approved_by")) %></DataItemTemplate>
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataDateColumn FieldName="date_modified" Caption="Modified" VisibleIndex="14" Width="90px">
                <PropertiesDateEdit DisplayFormatString="dd-MMM-yy HH:mm" />
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataDateColumn>
        </Columns>
    </dx:ASPxGridView>
    <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvResults" />
</div>

<!-- ══ Summary Report Modal ══ -->
<div id="summaryReportModal" class="mat-modal-bg">
<div class="mat-modal">
    <div class="mat-modal__hdr">
        <span class="mat-modal__title">Student Performance Summary</span>
        <button type="button" class="mat-modal__close" onclick="closeSummaryReportModal()">&times;</button>
    </div>
    <div class="mat-modal__body">
        <div class="mat-modal__desc">Generate a PDF showing student performance by CGPA classification (VC's List, Dean's List, 2nd Lower, Pass).</div>
        <div class="mat-fg" style="margin-bottom:10px">
            <span class="mat-fg__label">Programme <span style="color:#dc3545">*</span></span>
            <select id="ddlReportProgramme" style="width:100%;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px">
                <option value="">-- Select Programme --</option>
            </select>
        </div>
        <div class="mat-fg" style="margin-bottom:10px">
            <span class="mat-fg__label">Academic Year <span style="color:#dc3545">*</span></span>
            <select id="ddlReportAcadYear" style="width:100%;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px">
                <option value="">-- Select Academic Year --</option>
            </select>
        </div>
        <div class="mat-fg" style="margin-bottom:10px">
            <span class="mat-fg__label">Semester <span style="color:#dc3545">*</span></span>
            <select id="ddlReportSemester" style="width:100%;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px">
                <option value="">-- Select --</option>
                <option value="1">Semester 1</option>
                <option value="2">Semester 2</option>
            </select>
        </div>
        <div class="mat-fg" style="margin-bottom:14px">
            <span class="mat-fg__label">Year of Study</span>
            <select id="ddlReportStudyYear" style="width:100%;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px">
                <option value="">All Years</option>
                <option value="1">Year 1</option><option value="2">Year 2</option><option value="3">Year 3</option><option value="4">Year 4</option><option value="5">Year 5</option>
            </select>
        </div>
        <button type="button" class="mat-btn mat-btn--primary" style="width:100%" onclick="previewSummaryReportStudents()">Preview Students</button>
        <!-- Preview -->
        <div id="summaryPreviewSection" class="mat-prev" style="display:none">
            <div class="mat-prev__title">Performance Distribution</div>
            <div id="summaryPreviewContent"></div>
        </div>
    </div>
    <div class="mat-modal__footer">
        <button type="button" class="mat-btn mat-btn--ghost mat-btn--sm" onclick="closeSummaryReportModal()">Cancel</button>
        <button type="button" id="btnExportSummaryReport" class="mat-btn mat-btn--success mat-btn--sm" onclick="exportSummaryReportPdf()" disabled>Export PDF</button>
    </div>
</div>
</div>

<script>
function toggleFilters(){var b=document.getElementById('matFilterBar'),t=document.getElementById('btnToggleFilter');if(b.classList.contains('show')){b.classList.remove('show');t.classList.remove('active');}else{b.classList.add('show');t.classList.add('active');}}

/* Summary Report */
function openSummaryReportModal(){resetSummaryReportForm();document.getElementById('summaryReportModal').classList.add('show');loadReportProgrammes();loadReportAcademicYears();}
function closeSummaryReportModal(){document.getElementById('summaryReportModal').classList.remove('show');resetSummaryReportForm();}
function resetSummaryReportForm(){document.getElementById('ddlReportProgramme').value='';document.getElementById('ddlReportAcadYear').value='';document.getElementById('ddlReportSemester').value='';document.getElementById('ddlReportStudyYear').value='';document.getElementById('summaryPreviewSection').style.display='none';document.getElementById('btnExportSummaryReport').disabled=true;}
function loadReportProgrammes(){var x=new XMLHttpRequest();x.open('GET','ResultsUpdates.aspx?action=GetProgrammes',true);x.onreadystatechange=function(){if(x.readyState===4&&x.status===200){try{var d=JSON.parse(x.responseText),s=document.getElementById('ddlReportProgramme');s.innerHTML='<option value="">-- Select Programme --</option>';for(var i=0;i<d.length;i++){var o=document.createElement('option');o.value=d[i].code;o.text=d[i].name;s.appendChild(o);}}catch(e){}}};x.send();}
function loadReportAcademicYears(){var x=new XMLHttpRequest();x.open('GET','ResultsUpdates.aspx?action=GetAcademicYears',true);x.onreadystatechange=function(){if(x.readyState===4&&x.status===200){try{var d=JSON.parse(x.responseText),s=document.getElementById('ddlReportAcadYear');s.innerHTML='<option value="">-- Select Academic Year --</option>';for(var i=0;i<d.length;i++){var o=document.createElement('option');o.value=d[i];o.text=d[i];s.appendChild(o);}}catch(e){}}};x.send();}
function previewSummaryReportStudents(){
    var p=document.getElementById('ddlReportProgramme').value,y=document.getElementById('ddlReportAcadYear').value,s=document.getElementById('ddlReportSemester').value,sy=document.getElementById('ddlReportStudyYear').value;
    if(!p||!y||!s){alert('Please select Programme, Academic Year, and Semester');return;}
    document.getElementById('summaryPreviewSection').style.display='block';
    document.getElementById('summaryPreviewContent').innerHTML='<div style="text-align:center;color:#888;font-size:11px">Loading...</div>';
    var q='action=PreviewSummaryReportStudents&programme='+encodeURIComponent(p)+'&acadYear='+encodeURIComponent(y)+'&semester='+encodeURIComponent(s);
    if(sy)q+='&studyYear='+encodeURIComponent(sy);
    var x=new XMLHttpRequest();x.open('GET','ResultsUpdates.aspx?'+q,true);
    x.onreadystatechange=function(){if(x.readyState===4&&x.status===200){try{var d=JSON.parse(x.responseText);
        var h='<div class="mat-prev__grid">';
        h+='<div class="mat-prev__stat"><div class="mat-prev__stat-val" style="color:#1a237e">'+d.vcList+'</div><div class="mat-prev__stat-lbl">VC\'s List</div></div>';
        h+='<div class="mat-prev__stat"><div class="mat-prev__stat-val" style="color:#2e7d32">'+d.deansList+'</div><div class="mat-prev__stat-lbl">Dean\'s List</div></div>';
        h+='<div class="mat-prev__stat"><div class="mat-prev__stat-val" style="color:#e65100">'+d.secondLower+'</div><div class="mat-prev__stat-lbl">2nd Lower</div></div>';
        h+='<div class="mat-prev__stat"><div class="mat-prev__stat-val" style="color:#dc3545">'+d.pass+'</div><div class="mat-prev__stat-lbl">Pass</div></div>';
        h+='</div><div class="mat-prev__total">'+d.total+' total students</div>';
        document.getElementById('summaryPreviewContent').innerHTML=h;
        document.getElementById('btnExportSummaryReport').disabled=(d.total===0);
    }catch(e){document.getElementById('summaryPreviewContent').innerHTML='<div style="color:#dc3545;font-size:11px">Error loading preview</div>';}}};x.send();
}
function exportSummaryReportPdf(){
    var p=document.getElementById('ddlReportProgramme').value,y=document.getElementById('ddlReportAcadYear').value,s=document.getElementById('ddlReportSemester').value,sy=document.getElementById('ddlReportStudyYear').value;
    if(!p||!y||!s){alert('Please select Programme, Academic Year, and Semester');return;}
    var q='action=ExportSummaryReport&programme='+encodeURIComponent(p)+'&acadYear='+encodeURIComponent(y)+'&semester='+encodeURIComponent(s);
    if(sy)q+='&studyYear='+encodeURIComponent(sy);
    window.open('ResultsUpdates.aspx?'+q,'_blank');
}
</script>
</asp:Content>
