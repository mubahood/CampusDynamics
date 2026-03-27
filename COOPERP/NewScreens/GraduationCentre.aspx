<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GraduationCentre.aspx.cs" Inherits="COOPERP_NewScreens_GraduationCentre" Title="Graduation Centre - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.8.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style type="text/css">
/* ---- Page Header ---- */
.cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
.cd-page-header__left { display:flex; align-items:center; gap:12px; }
.cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
/* Graduation Centre Module Styles - gc- prefix */
.gc-container { padding: 8px; font-size: 11px; }
.gc-header { margin-bottom: 6px; }
.gc-title { font-size: 14px; font-weight: 600; color: #1a1a2e; margin: 0 0 4px 0; }

/* Compact Inline Stats Bar */
.gc-stats-bar { display: flex; align-items: center; gap: 4px; padding: 4px 8px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 4px; font-size: 10px; margin-bottom: 6px; flex-wrap: wrap; }
.gc-stat { display: flex; align-items: center; gap: 3px; padding: 2px 6px; background: #fff; border-radius: 3px; border: 1px solid #dee2e6; }
.gc-stat-label { color: #6c757d; }
.gc-stat-value { font-weight: 600; color: #495057; }
.gc-stat--primary .gc-stat-value { color: #0d6efd; }
.gc-stat--warning .gc-stat-value { color: #fd7e14; }
.gc-stat--success .gc-stat-value { color: #198754; }
.gc-stat--info .gc-stat-value { color: #0dcaf0; }

/* Filter Toggle Button */
.gc-filter-toggle { margin-left: auto; padding: 3px 8px; font-size: 10px; background: #e7f1ff; border: 1px solid #b6d4fe; border-radius: 3px; color: #0d6efd; cursor: pointer; display: flex; align-items: center; gap: 4px; }
.gc-filter-toggle:hover { background: #cfe2ff; }
.gc-filter-toggle svg { width: 12px; height: 12px; }

/* Collapsible Filter Row */
.gc-filter-row { display: none; padding: 6px 8px; background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; }
.gc-filter-row.show { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.gc-filter-group { display: flex; align-items: center; gap: 3px; }
.gc-filter-group label { font-size: 10px; color: #6c757d; white-space: nowrap; }
.gc-filter-group select { font-size: 10px; padding: 2px 4px; border: 1px solid #ced4da; border-radius: 3px; min-width: 100px; }

/* Batch Actions Bar */
.gc-batch-bar { display: flex; gap: 4px; align-items: center; padding: 4px 8px; background: #fff; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; flex-wrap: wrap; }
.gc-btn { padding: 3px 10px; font-size: 10px; border: 1px solid #dee2e6; border-radius: 3px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; background: #fff; color: #495057; }
.gc-btn:hover { background: #f8f9fa; }
.gc-btn--primary { background: #0d6efd; border-color: #0d6efd; color: #fff; }
.gc-btn--primary:hover { background: #0b5ed7; }
.gc-btn--success { background: #198754; border-color: #198754; color: #fff; }
.gc-btn--success:hover { background: #157347; }
.gc-btn--warning { background: #fd7e14; border-color: #fd7e14; color: #fff; }
.gc-btn--warning:hover { background: #e96e0a; }
.gc-btn--danger { background: #dc3545; border-color: #dc3545; color: #fff; }
.gc-btn--danger:hover { background: #bb2d3b; }

/* Grid Styles */
.gc-grid { font-size: 10px; }
.gc-grid .dxgvHeader { background: linear-gradient(180deg, #f8f9fa 0%, #e9ecef 100%); padding: 4px 6px !important; font-weight: 600; }
.gc-grid .dxgvDataRow td { padding: 3px 6px !important; }
.gc-grid .dxgvDataRow:hover { background-color: #e8f4fc !important; }
.gc-grid .dxgvSelectedRow { background-color: #cce5ff !important; }

/* Status Badge */
.gc-status-badge { display: inline-block; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: 600; text-transform: uppercase; }
.gc-status-badge--completed { background: #d1e7dd; color: #0f5132; }
.gc-status-badge--pending { background: #fff3cd; color: #664d03; }
.gc-status-badge--graduated { background: #cff4fc; color: #055160; }

/* Message Panel */
.gc-message { padding: 6px 10px; border-radius: 4px; font-size: 10px; margin-bottom: 6px; display: none; }
.gc-message.show { display: block; }
.gc-message--success { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
.gc-message--warning { background: #fff3cd; color: #664d03; border: 1px solid #ffecb5; }
.gc-message--error { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }

/* Card */
.gc-card { background: #fff; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; }
.gc-card__body { padding: 6px; }
</style>
<script type="text/javascript">
function toggleFilters() {
    var filterRow = document.querySelector('.gc-filter-row');
    if (filterRow) {
        filterRow.classList.toggle('show');
    }
}
</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="gc-container">
<!-- ======= PAGE HEADER =========================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
        </div>
        <div>
            <div class="cd-page-header__title">Graduation Centre</div>
            <div class="cd-page-header__sub">Process and manage student graduation clearance</div>
        </div>
    </div>
</div>
    <!-- Stats Bar with Filter Toggle -->
    <div class="gc-stats-bar">
        <div class="gc-stat gc-stat--primary">
            <span class="gc-stat-label">Academic Year:</span>
            <span class="gc-stat-value"><asp:Literal ID="litAcadYearDisplay" runat="server" /></span>
        </div>
        <div class="gc-stat">
            <span class="gc-stat-label">Study Year:</span>
            <span class="gc-stat-value"><asp:Literal ID="litStudyYearDisplay" runat="server" /></span>
        </div>
        <div class="gc-stat gc-stat--primary">
            <span class="gc-stat-label">Total Students:</span>
            <span class="gc-stat-value"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="gc-stat gc-stat--success">
            <span class="gc-stat-label">Completed:</span>
            <span class="gc-stat-value"><asp:Literal ID="litCompletedCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="gc-stat gc-stat--info">
            <span class="gc-stat-label">Graduands:</span>
            <span class="gc-stat-value"><asp:Literal ID="litGraduandsCount" runat="server">0</asp:Literal></span>
        </div>
        <button type="button" class="gc-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" /></svg>
            Filters
        </button>
    </div>
    
    <!-- Collapsible Filter Row -->
    <div class="gc-filter-row show">
        <div class="gc-filter-group">
            <label>Faculty:</label>
            <asp:DropDownList ID="ddlFaculty" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged">
                <asp:ListItem Text="-- All Faculties --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="gc-filter-group">
            <label>Programme:</label>
            <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged">
                <asp:ListItem Text="-- All Programmes --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="gc-filter-group">
            <label>Entry Year:</label>
            <asp:DropDownList ID="ddlEntryYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlEntryYear_SelectedIndexChanged">
                <asp:ListItem Text="-- All --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="gc-filter-group">
            <label>Academic Year:</label>
            <asp:DropDownList ID="ddlAcadYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
                <asp:ListItem Text="-- All --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="gc-filter-group">
            <label>Study Year:</label>
            <asp:DropDownList ID="ddlStudyYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
                <asp:ListItem Text="-- All --" Value="" />
                <asp:ListItem Text="1" Value="1" />
                <asp:ListItem Text="2" Value="2" />
                <asp:ListItem Text="3" Value="3" Selected="True" />
                <asp:ListItem Text="4" Value="4" />
                <asp:ListItem Text="5" Value="5" />
            </asp:DropDownList>
        </div>
        <div class="gc-filter-group">
            <label>Status:</label>
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                <asp:ListItem Text="All Students" Value="ALL" Selected="True" />
                <asp:ListItem Text="Graduands Only" Value="GRAD" />
            </asp:DropDownList>
        </div>
    </div>
    
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="gc-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Batch Actions Bar -->
    <div class="gc-card">
        <div class="gc-batch-bar">
            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="gc-btn" OnClick="btnRefresh_Click" />
            <asp:Button ID="btnAddGraduands" runat="server" Text="Add to Graduands" CssClass="gc-btn gc-btn--success" OnClick="btnAddGraduands_Click" OnClientClick="return confirm('Add selected students to graduands list?');" />
            <asp:Button ID="btnRemoveGraduands" runat="server" Text="Remove from Graduands" CssClass="gc-btn gc-btn--danger" OnClick="btnRemoveGraduands_Click" OnClientClick="return confirm('Remove selected students from graduands list?');" />
            <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="gc-btn gc-btn--warning" OnClick="btnExportExcel_Click" />
            <asp:Button ID="btnPrintList" runat="server" Text="Print List" CssClass="gc-btn" OnClick="btnPrintList_Click" />
            <asp:Label ID="lblMessage" runat="server" style="font-size: 11px; font-weight: bold; margin-left: auto;"></asp:Label>
        </div>
        <div class="gc-card__body">
            <dx:ASPxGridView ID="gvGraduands" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="regno" 
                CssClass="gc-grid">
                <SettingsPager PageSize="50" AlwaysShowPager="true" Position="Bottom">
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" AllowSelectByRowClick="true" />
                <Settings ShowFilterRow="true" ShowFilterRowMenu="true" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="30px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="1" Width="100px">
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_name" Caption="Student Name" VisibleIndex="2" Width="180px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme" VisibleIndex="3" Width="150px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="entry_year" Caption="Entry" VisibleIndex="4" Width="50px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="study_year" Caption="Year" VisibleIndex="5" Width="40px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="cgpa" Caption="CGPA" VisibleIndex="6" Width="50px">
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="award_class" Caption="Class" VisibleIndex="7" Width="100px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="completion_status" Caption="Status" VisibleIndex="8" Width="90px">
                        <DataItemTemplate>
                            <%# GetStatusBadge(Eval("completion_status")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gender" Caption="Gender" VisibleIndex="9" Width="50px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="nationality" Caption="Nationality" VisibleIndex="10" Width="80px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="is_graduand" Caption="Graduand" VisibleIndex="11" Width="70px">
                        <DataItemTemplate>
                            <%# GetGraduandBadge(Eval("is_graduand")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header BackColor="#f8f9fa" Font-Bold="true" Font-Size="10px" />
                    <Row Font-Size="10px" />
                    <AlternatingRow BackColor="#fafbfc" />
                </Styles>
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Excel Exporter -->
    <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvGraduands" />
</div>
</asp:Content>
