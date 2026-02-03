<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="CourseRegistration.aspx.cs" Inherits="COOPERP_NewScreens_CourseRegistration" Title="Course Registration - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Stats Bar - Compact Inline */
        .cr-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .cr-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .cr-stat-item__label { color: #666; }
        .cr-stat-item__value { font-weight: 700; color: #174DA4; }
        .cr-stat-item--pending .cr-stat-item__value { color: #dc3545; }
        .cr-stat-item--registered .cr-stat-item__value { color: #28a745; }
        .cr-stat-item--retake .cr-stat-item__value { color: #fd7e14; }
        
        /* Filter Toggle & Row */
        .cr-filter-toggle {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 500;
            background: #fff;
            border: 1px solid #ddd;
            cursor: pointer;
            color: #495057;
        }
        .cr-filter-toggle:hover { background: #f8f9fa; }
        .cr-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .cr-filter-toggle svg { width: 12px; height: 12px; }
        
        .cr-filter-row {
            display: none;
            gap: 8px;
            padding: 8px 10px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .cr-filter-row.show { display: flex; }
        .cr-filter-row__label {
            font-size: 10px;
            color: #666;
            font-weight: 500;
        }
        .cr-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .cr-filter-select:focus { border-color: #174DA4; outline: none; }
        
        /* Status Badges */
        .cr-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .cr-status-badge--pending { background: #fff3cd; color: #856404; }
        .cr-status-badge--registered { background: #d4edda; color: #155724; }
        .cr-status-badge--regular { background: #cce5ff; color: #004085; }
        .cr-status-badge--retake { background: #f8d7da; color: #721c24; }
        
        /* Card Styles */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .cd-card__body { padding: 0; }
        
        /* Grid Styling */
        .cr-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .cr-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .cr-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Batch Actions Bar */
        .cr-batch-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 10px;
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
            gap: 10px;
        }
        .cr-batch-actions {
            display: flex;
            gap: 6px;
            align-items: center;
        }
        .cr-batch-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 500;
            background: #fff;
            border: 1px solid #ddd;
            cursor: pointer;
            color: #495057;
        }
        .cr-batch-btn:hover { background: #e9ecef; }
        .cr-batch-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .cr-batch-btn--primary:hover { background: #0d3a7d; }
        .cr-batch-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .cr-batch-btn--success:hover { background: #218838; }
        .cr-batch-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; }
        .cr-batch-btn--danger:hover { background: #c82333; }
        .cr-batch-btn svg { width: 12px; height: 12px; }
        
        /* Retake Panel */
        .cr-retake-panel {
            display: none;
            padding: 10px;
            background: #fff8e1;
            border: 1px solid #ffe082;
            margin-bottom: 10px;
        }
        .cr-retake-panel.show { display: block; }
        .cr-retake-panel__title {
            font-size: 11px;
            font-weight: 600;
            color: #856404;
            margin-bottom: 8px;
        }
        .cr-retake-row {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }
        .cr-retake-input {
            border: 1px solid #ddd;
            padding: 4px 8px;
            font-size: 11px;
            min-width: 150px;
        }
        
        /* Message Box */
        .cr-message {
            padding: 8px 12px;
            font-size: 11px;
            margin-bottom: 10px;
            display: none;
        }
        .cr-message.show { display: block; }
        .cr-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .cr-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .cr-message--info { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
        
        /* Print Styles */
        @media print {
            .cr-batch-bar, .cr-filter-row, .cr-retake-panel { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar -->
    <div class="cr-stats-bar">
        <div class="cr-stat-item">
            <span class="cr-stat-item__label">Academic Year:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litAcadYearDisplay" runat="server">2024/2025</asp:Literal></span>
        </div>
        <div class="cr-stat-item">
            <span class="cr-stat-item__label">Semester:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litSemesterDisplay" runat="server">1</asp:Literal></span>
        </div>
        <div class="cr-stat-item cr-stat-item--pending">
            <span class="cr-stat-item__label">Pending:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litPendingCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="cr-stat-item cr-stat-item--registered">
            <span class="cr-stat-item__label">Registered:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litRegisteredCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="cr-stat-item cr-stat-item--retake">
            <span class="cr-stat-item__label">Retakes:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litRetakeCount" runat="server">0</asp:Literal></span>
        </div>
        
        <button type="button" class="cr-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
            <span>Filters</span>
        </button>
    </div>
    
    <!-- Filter Row -->
    <div class="cr-filter-row" id="filterRow">
        <span class="cr-filter-row__label">Academic Year:</span>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Programme:</span>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" Width="250px"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Study Year:</span>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
            <asp:ListItem Value="1" Text="Year 1" Selected="True"></asp:ListItem>
            <asp:ListItem Value="2" Text="Year 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Year 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Year 4"></asp:ListItem>
            <asp:ListItem Value="5" Text="Year 5"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="cr-filter-row__label">Semester:</span>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="1" Text="Sem 1" Selected="True"></asp:ListItem>
            <asp:ListItem Value="2" Text="Sem 2"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="cr-filter-row__label">Entry Year:</span>
        <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlEntryYear_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Intake:</span>
        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlIntake_SelectedIndexChanged">
            <asp:ListItem Value="-" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="JANUARY" Text="January"></asp:ListItem>
            <asp:ListItem Value="FEBRUARY" Text="February"></asp:ListItem>
            <asp:ListItem Value="MARCH" Text="March"></asp:ListItem>
            <asp:ListItem Value="APRIL" Text="April"></asp:ListItem>
            <asp:ListItem Value="MAY" Text="May"></asp:ListItem>
            <asp:ListItem Value="JUNE" Text="June"></asp:ListItem>
            <asp:ListItem Value="JULY" Text="July"></asp:ListItem>
            <asp:ListItem Value="AUGUST" Text="August"></asp:ListItem>
            <asp:ListItem Value="SEPTEMBER" Text="September"></asp:ListItem>
            <asp:ListItem Value="OCTOBER" Text="October"></asp:ListItem>
            <asp:ListItem Value="NOVEMBER" Text="November"></asp:ListItem>
            <asp:ListItem Value="DECEMBER" Text="December"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="cr-filter-row__label">Course:</span>
        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" Width="300px"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Status:</span>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="cr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
            <asp:ListItem Value="Pending" Text="Pending" Selected="True"></asp:ListItem>
            <asp:ListItem Value="Registered" Text="Registered"></asp:ListItem>
        </asp:DropDownList>
    </div>
    
    <!-- Message Display -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="cr-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Retake Panel -->
    <div class="cr-retake-panel" id="retakePanel">
        <div class="cr-retake-panel__title">Add Retake Case</div>
        <div class="cr-retake-row">
            <span class="cr-filter-row__label">Reg No:</span>
            <asp:TextBox ID="txtRetakeRegNo" runat="server" CssClass="cr-retake-input" placeholder="Enter Student Reg No"></asp:TextBox>
            
            <asp:Button ID="btnAddRetake" runat="server" Text="Add Retake" CssClass="cr-batch-btn cr-batch-btn--primary" OnClick="btnAddRetake_Click" />
            <button type="button" class="cr-batch-btn" onclick="toggleRetakePanel()">Cancel</button>
        </div>
    </div>
    
    <!-- Batch Actions & Grid -->
    <div class="cd-card">
        <div class="cr-batch-bar">
            <div class="cr-batch-actions">
                <asp:Button ID="btnRegisterSelected" runat="server" Text="Register Selected" CssClass="cr-batch-btn cr-batch-btn--success" OnClick="btnRegisterSelected_Click" OnClientClick="return confirm('Register selected students for this course?');" />
                <asp:Button ID="btnRemoveSelected" runat="server" Text="Remove Selected" CssClass="cr-batch-btn cr-batch-btn--danger" OnClick="btnRemoveSelected_Click" OnClientClick="return confirm('Remove registration for selected students?');" Visible="false" />
                <button type="button" class="cr-batch-btn" onclick="toggleRetakePanel()">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add Retake
                </button>
            </div>
            <div>
                <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="cr-batch-btn" OnClick="btnExportExcel_Click" />
            </div>
        </div>
        <div class="cd-card__body">
            <dx:ASPxGridView ID="gvCourseReg" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="regno" 
                CssClass="cr-grid" OnCustomCallback="gvCourseReg_CustomCallback">
                <SettingsPager PageSize="50" AlwaysShowPager="true" Position="TopAndBottom">
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" ConfirmDelete="true" />
                <Settings ShowFilterRow="false" ShowFilterRowMenu="false" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="30px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="1" Width="120px">
                        <Settings AllowAutoFilter="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_name" Caption="Student Name" VisibleIndex="2">
                        <Settings AllowAutoFilter="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="spec" Caption="Specialisation" VisibleIndex="3" Width="200px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_status" Caption="Course Status" VisibleIndex="4" Width="100px">
                        <DataItemTemplate>
                            <%# GetCourseStatusBadge(Eval("course_status")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header BackColor="#f8f9fa" Font-Bold="true" Font-Size="10px" />
                    <Row Font-Size="11px" />
                    <AlternatingRow BackColor="#fafafa" />
                </Styles>
            </dx:ASPxGridView>
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvCourseReg">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Loading Panel -->
    <dx:ASPxLoadingPanel ID="lpLoading" runat="server" ClientInstanceName="lpLoading" Modal="true" Text="Processing...">
    </dx:ASPxLoadingPanel>
    
    <script type="text/javascript">
        function toggleFilters() {
            var filterRow = document.getElementById('filterRow');
            var toggleBtn = document.querySelector('.cr-filter-toggle');
            if (filterRow.classList.contains('show')) {
                filterRow.classList.remove('show');
                toggleBtn.classList.remove('active');
            } else {
                filterRow.classList.add('show');
                toggleBtn.classList.add('active');
            }
        }
        
        function toggleRetakePanel() {
            var panel = document.getElementById('retakePanel');
            if (panel.classList.contains('show')) {
                panel.classList.remove('show');
            } else {
                panel.classList.add('show');
            }
        }
        
        // Show filters by default on load
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('filterRow').classList.add('show');
            document.querySelector('.cr-filter-toggle').classList.add('active');
        });
    </script>
</asp:Content>
