<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ExamResultsInfo.aspx.cs" Inherits="COOPERP_NewScreens_ExamResultsInfo" Title="Exam Results Info - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Stats Bar - Compact Inline */
        .er-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .er-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 12px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            font-size: 11px;
        }
        .er-stat-item__label { color: #666; }
        .er-stat-item__value { font-weight: 700; color: #174DA4; }
        .er-stat-item--pending .er-stat-item__value { color: #dc3545; }
        .er-stat-item--approved .er-stat-item__value { color: #28a745; }
        .er-stat-item--pass .er-stat-item__value { color: #28a745; }
        .er-stat-item--fail .er-stat-item__value { color: #dc3545; }
        
        /* Filter Toggle & Row */
        .er-filter-toggle {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            font-size: 11px;
            font-weight: 500;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            color: #495057;
        }
        .er-filter-toggle:hover { background: #f8f9fa; }
        .er-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .er-filter-toggle svg { width: 12px; height: 12px; }
        
        .er-filter-row {
            display: none;
            gap: 10px;
            padding: 12px 15px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .er-filter-row.show { display: flex; }
        .er-filter-row__label {
            font-size: 10px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
        }
        .er-filter-select {
            border: 1px solid #ddd;
            padding: 6px 10px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
            border-radius: 4px;
        }
        .er-filter-select:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.1); }
        
        /* Status Badges */
        .er-status-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-radius: 3px;
        }
        .er-status-badge--pending { background: #fff3cd; color: #856404; }
        .er-status-badge--approved { background: #d4edda; color: #155724; }
        .er-status-badge--pass { background: #d4edda; color: #155724; }
        .er-status-badge--fail { background: #f8d7da; color: #721c24; }
        .er-status-badge--regular { background: #cce5ff; color: #004085; }
        .er-status-badge--retake { background: #f8d7da; color: #721c24; }
        .er-status-badge--special { background: #e2e3e5; color: #383d41; }
        .er-status-badge--supplementary { background: #fff3cd; color: #856404; }
        
        /* Card Styles */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .cd-card__body { padding: 0; }
        
        /* Grid Styling - Improved */
        .er-grid { border-collapse: collapse; }
        .er-grid .dxgvHeader td,
        .er-grid .dxgvHeader_Glass td {
            background: linear-gradient(to bottom, #f8f9fa, #e9ecef) !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            color: #495057 !important;
            border-bottom: 2px solid #174DA4 !important;
        }
        .er-grid .dxgvDataRow td,
        .er-grid .dxgvDataRow_Glass td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .er-grid .dxgvDataRow:hover td,
        .er-grid .dxgvDataRow_Glass:hover td {
            background: #e3f2fd !important;
        }
        .er-grid .dxgvSelectedRow td,
        .er-grid .dxgvSelectedRow_Glass td {
            background: #cce5ff !important;
        }
        .er-grid .dxgvFocusedRow td,
        .er-grid .dxgvFocusedRow_Glass td {
            background: #b8daff !important;
        }
        
        /* Mark cells styling */
        .er-mark-cell { 
            display: inline-block;
            min-width: 30px;
            text-align: center; 
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 3px;
        }
        .er-mark-cell--pass { color: #155724; background: #d4edda; }
        .er-mark-cell--fail { color: #721c24; background: #f8d7da; }
        
        /* Batch Actions Bar */
        .er-batch-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 12px;
            background: linear-gradient(to bottom, #f8f9fa, #e9ecef);
            border-bottom: 1px solid #e0e0e0;
            gap: 10px;
            border-radius: 6px 6px 0 0;
        }
        .er-batch-actions {
            display: flex;
            gap: 6px;
            align-items: center;
        }
        .er-batch-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 6px 12px;
            font-size: 11px;
            font-weight: 500;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            color: #495057;
            transition: all 0.15s ease;
        }
        .er-batch-btn:hover { background: #e9ecef; }
        .er-batch-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .er-batch-btn--primary:hover { background: #0d3a7d; }
        .er-batch-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .er-batch-btn--success:hover { background: #218838; }
        .er-batch-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; }
        .er-batch-btn--danger:hover { background: #c82333; }
        .er-batch-btn svg { width: 12px; height: 12px; }
        .er-batch-btn:disabled { opacity: 0.6; cursor: not-allowed; }
        
        /* Message Box */
        .er-message {
            padding: 10px 14px;
            font-size: 11px;
            margin-bottom: 10px;
            display: none;
            border-radius: 4px;
        }
        .er-message.show { display: block; }
        .er-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .er-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .er-message--info { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
        .er-message--warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        
        /* Ratios Panel */
        .er-ratios-panel {
            padding: 10px 14px;
            background: #e3f2fd;
            border: 1px solid #90caf9;
            border-radius: 4px;
            margin-bottom: 10px;
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            align-items: center;
        }
        .er-ratios-panel__title {
            font-size: 11px;
            font-weight: 600;
            color: #174DA4;
        }
        .er-ratio-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
        }
        .er-ratio-item__label { color: #666; }
        .er-ratio-item__value { font-weight: 700; color: #174DA4; }
        
        /* Search Bar */
        .er-search-bar {
            display: flex;
            gap: 6px;
            align-items: center;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .er-search-input {
            border: 1px solid #ddd;
            padding: 7px 12px;
            font-size: 12px;
            min-width: 280px;
            border-radius: 4px;
            background: #fff;
        }
        .er-search-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.15); }
        .er-search-input::placeholder { color: #aaa; }
        .er-search-hint {
            font-size: 10px;
            color: #888;
            margin-left: 4px;
        }
        
        /* Delete confirmation row */
        .er-delete-link {
            color: #dc3545;
            font-size: 10px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }
        .er-delete-link:hover { color: #a71d2a; text-decoration: underline; }
        
        /* Print Styles */
        @media print {
            .er-batch-bar, .er-filter-row, .er-search-bar { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar -->
    <div class="er-stats-bar">
        <div class="er-stat-item">
            <span class="er-stat-item__label">Academic Year:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litAcadYearDisplay" runat="server">2024/2025</asp:Literal></span>
        </div>
        <div class="er-stat-item">
            <span class="er-stat-item__label">Semester:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litSemesterDisplay" runat="server">1</asp:Literal></span>
        </div>
        <div class="er-stat-item">
            <span class="er-stat-item__label">Total Students:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="er-stat-item er-stat-item--pending">
            <span class="er-stat-item__label">Pending:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litPendingCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="er-stat-item er-stat-item--approved">
            <span class="er-stat-item__label">Approved:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litApprovedCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="er-stat-item er-stat-item--pass">
            <span class="er-stat-item__label">Pass:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litPassCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="er-stat-item er-stat-item--fail">
            <span class="er-stat-item__label">Fail:</span>
            <span class="er-stat-item__value"><asp:Literal ID="litFailCount" runat="server">0</asp:Literal></span>
        </div>
        
        <button type="button" class="er-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
            <span>Filters</span>
        </button>
    </div>
    
    <!-- Search Bar -->
    <div class="er-search-bar">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="er-search-input" placeholder="Search by student name or registration number..." />
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="er-batch-btn er-batch-btn--primary" OnClick="btnSearch_Click" />
        <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="er-batch-btn" OnClick="btnClearSearch_Click" />
        <span class="er-search-hint">Searches across all programmes &amp; courses</span>
    </div>
    
    <!-- Filter Row -->
    <div class="er-filter-row" id="filterRow">
        <span class="er-filter-row__label">Campus:</span>
        <asp:DropDownList ID="ddlCampus" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCampus_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="er-filter-row__label">Academic Year:</span>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="er-filter-row__label">Programme:</span>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" Width="250px"></asp:DropDownList>
        
        <span class="er-filter-row__label">Study Year:</span>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="1" Text="Year 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Year 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Year 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Year 4"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="er-filter-row__label">Semester:</span>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="1" Text="Sem 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Sem 2"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="er-filter-row__label">Entry Year:</span>
        <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlEntryYear_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="er-filter-row__label">Intake:</span>
        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlIntake_SelectedIndexChanged">
            <asp:ListItem Value="-" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="JANUARY" Text="January"></asp:ListItem>
            <asp:ListItem Value="FEBRUARY" Text="February"></asp:ListItem>
            <asp:ListItem Value="MARCH" Text="March"></asp:ListItem>
            <asp:ListItem Value="AUGUST" Text="August"></asp:ListItem>
            <asp:ListItem Value="SEPTEMBER" Text="September"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="er-filter-row__label">Session:</span>
        <asp:DropDownList ID="ddlSession" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="DAY" Text="Day"></asp:ListItem>
            <asp:ListItem Value="EVENING" Text="Evening"></asp:ListItem>
            <asp:ListItem Value="WEEKEND" Text="Weekend"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="er-filter-row__label">Course:</span>
        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" Width="300px"></asp:DropDownList>
        
        <span class="er-filter-row__label">Exam Status:</span>
        <asp:DropDownList ID="ddlExamStatus" runat="server" CssClass="er-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlExamStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="REGULAR" Text="Regular"></asp:ListItem>
            <asp:ListItem Value="SUPPLEMENTARY" Text="Supplementary"></asp:ListItem>
            <asp:ListItem Value="RETAKE" Text="Retake"></asp:ListItem>
            <asp:ListItem Value="SPECIAL" Text="Special"></asp:ListItem>
        </asp:DropDownList>
    </div>
    
    <!-- Mark Ratios Panel -->
    <asp:Panel ID="pnlRatios" runat="server" CssClass="er-ratios-panel" Visible="false">
        <span class="er-ratios-panel__title">Mark Ratios:</span>
        <span class="er-ratio-item">
            <span class="er-ratio-item__label">Coursework:</span>
            <span class="er-ratio-item__value"><asp:Literal ID="litCWRatio" runat="server">30</asp:Literal>%</span>
        </span>
        <span class="er-ratio-item">
            <span class="er-ratio-item__label">Test:</span>
            <span class="er-ratio-item__value"><asp:Literal ID="litTestRatio" runat="server">0</asp:Literal>%</span>
        </span>
        <span class="er-ratio-item">
            <span class="er-ratio-item__label">Exam:</span>
            <span class="er-ratio-item__value"><asp:Literal ID="litExamRatio" runat="server">70</asp:Literal>%</span>
        </span>
    </asp:Panel>
    
    <!-- Message Display -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="er-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Batch Actions & Grid -->
    <div class="cd-card">
        <div class="er-batch-bar">
            <div class="er-batch-actions">
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="er-batch-btn er-batch-btn--primary" OnClick="btnRefresh_Click" />
                <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="er-batch-btn er-batch-btn--success" OnClick="btnApprove_Click" OnClientClick="return confirm('Approve results for selected students?');" Enabled="false" />
                <asp:Button ID="btnCancelApproval" runat="server" Text="Cancel" CssClass="er-batch-btn er-batch-btn--danger" OnClick="btnCancelApproval_Click" OnClientClick="return confirm('Cancel approval for selected students?');" Enabled="false" />
                <asp:Button ID="btnPrintSheet" runat="server" Text="Print" CssClass="er-batch-btn" OnClick="btnPrintSheet_Click" />
                <asp:Button ID="btnExportExcel" runat="server" Text="Excel" CssClass="er-batch-btn" OnClick="btnExportExcel_Click" />
                <asp:Button ID="btnDeleteSelected" runat="server" Text="Delete Selected" CssClass="er-batch-btn er-batch-btn--danger" OnClick="btnDeleteSelected_Click" OnClientClick="return confirm('Are you sure you want to delete the selected results? This cannot be undone.');" />
            </div>
            <asp:Label ID="lblMessage" runat="server" CssClass="er-message" style="margin-left: 20px; font-weight: bold;"></asp:Label>
        </div>
        <div class="cd-card__body">
            <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="ID" 
                CssClass="er-grid" OnBatchUpdate="gvResults_BatchUpdate" OnRowUpdating="gvResults_RowUpdating"
                OnRowDeleting="gvResults_RowDeleting">
                <SettingsPager PageSize="500" AlwaysShowPager="true" Position="Bottom">
                </SettingsPager>
                <SettingsEditing Mode="Batch">
                    <BatchEditSettings StartEditAction="Click" EditMode="Cell" />
                </SettingsEditing>
                <SettingsBehavior AllowFocusedRow="true" ConfirmDelete="true" />
                <Settings ShowFilterRow="false" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="60px"
                        ShowDeleteButton="true">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" VisibleIndex="1" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="2" Width="110px" ReadOnly="true">
                        <Settings AllowAutoFilter="true" />
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_name" Caption="Student Name" VisibleIndex="3" Width="180px" ReadOnly="true">
                        <CellStyle Font-Bold="false" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course" VisibleIndex="4" Width="200px" ReadOnly="true">
                        <CellStyle Font-Size="10px" ForeColor="#555" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_id" Caption="Code" VisibleIndex="5" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Acad Year" VisibleIndex="6" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="7" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="cw_mark_entered" Caption="CW" VisibleIndex="8" Width="55px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="100" NumberType="Integer" DisplayFormatString="{0:0}">
                        </PropertiesSpinEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="exam_mark_entered" Caption="Exam" VisibleIndex="9" Width="55px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="100" NumberType="Integer" DisplayFormatString="{0:0}">
                        </PropertiesSpinEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataTextColumn FieldName="total_mark" Caption="Total" VisibleIndex="10" Width="55px" ReadOnly="true">
                        <DataItemTemplate>
                            <%# GetMarkCellHtml(Eval("total_mark")) %>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="grade" Caption="Grade" VisibleIndex="11" Width="45px" ReadOnly="true">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gradept" Caption="GP" VisibleIndex="12" Width="40px" ReadOnly="true">
                        <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                        </PropertiesTextEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="exam_status" Caption="Status" VisibleIndex="13" Width="90px" ReadOnly="true">
                        <DataItemTemplate>
                            <%# GetExamStatusBadge(Eval("exam_status")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="approved_by" Caption="Approved" VisibleIndex="14" Width="85px" ReadOnly="true">
                        <DataItemTemplate>
                            <%# GetApprovalStatusBadge(Eval("approved_by")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progid" Caption="Prog" VisibleIndex="15" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_session" Caption="Session" VisibleIndex="16" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="cyear" Caption="Year" VisibleIndex="17" Visible="false">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header BackColor="#f8f9fa" Font-Bold="true" Font-Size="10px" />
                    <Row Font-Size="11px" />
                    <AlternatingRow BackColor="#fafafa" />
                    <BatchEditModifiedCell BackColor="#fff3cd" />
                </Styles>
            </dx:ASPxGridView>
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvResults">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Loading Panel -->
    <dx:ASPxLoadingPanel ID="lpLoading" runat="server" ClientInstanceName="lpLoading" Modal="true" Text="Processing...">
    </dx:ASPxLoadingPanel>
    
    <script type="text/javascript">
        function toggleFilters() {
            var filterRow = document.getElementById('filterRow');
            var toggleBtn = document.querySelector('.er-filter-toggle');
            if (filterRow.classList.contains('show')) {
                filterRow.classList.remove('show');
                toggleBtn.classList.remove('active');
            } else {
                filterRow.classList.add('show');
                toggleBtn.classList.add('active');
            }
        }
        
        // Show filters by default on load
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('filterRow').classList.add('show');
            document.querySelector('.er-filter-toggle').classList.add('active');
        });
    </script>
</asp:Content>
