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
        
        /* Quick Edit Modal */
        .qe-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.45);
            z-index: 10000;
            justify-content: center;
            align-items: flex-start;
            padding-top: 40px;
        }
        .qe-overlay.show { display: flex; }
        .qe-modal {
            background: #fff;
            width: 640px;
            max-width: 95vw;
            max-height: calc(100vh - 80px);
            overflow-y: auto;
            border: 1px solid #ccc;
            box-shadow: 0 8px 32px rgba(0,0,0,0.18);
        }
        .qe-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 16px;
            background: #174DA4;
            color: #fff;
        }
        .qe-header__title {
            font-size: 13px;
            font-weight: 600;
        }
        .qe-header__close {
            background: none; border: none; color: #fff;
            font-size: 18px; cursor: pointer; padding: 0 4px;
            line-height: 1;
        }
        .qe-header__close:hover { opacity: 0.7; }
        .qe-body { padding: 12px 16px; }
        .qe-section {
            margin-bottom: 12px;
        }
        .qe-section__title {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            color: #174DA4;
            letter-spacing: 0.5px;
            border-bottom: 1px solid #e0e0e0;
            padding-bottom: 4px;
            margin-bottom: 8px;
        }
        .qe-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 6px 14px;
        }
        .qe-field {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .qe-field--full { grid-column: 1 / -1; }
        .qe-label {
            font-size: 10px;
            font-weight: 600;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .qe-input, .qe-select {
            border: 1px solid #ddd;
            padding: 5px 8px;
            font-size: 12px;
            background: #fff;
            width: 100%;
            box-sizing: border-box;
        }
        .qe-input:focus, .qe-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .qe-input[readonly] {
            background: #f5f5f5;
            color: #666;
        }
        .qe-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 16px;
            border-top: 1px solid #e0e0e0;
            background: #f8f9fa;
        }
        .qe-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 6px 14px;
            font-size: 11px;
            font-weight: 600;
            border: 1px solid #ddd;
            background: #fff;
            cursor: pointer;
        }
        .qe-btn:hover { background: #e9ecef; }
        .qe-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .qe-btn--primary:hover { background: #0d3a7d; }
        .qe-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .qe-btn--success:hover { background: #218838; }
        .qe-btn--link { background:none; border:none; color:#174DA4; text-decoration:underline; padding:6px 4px; }
        .qe-btn--link:hover { color:#0d3a7d; }
        .qe-msg {
            padding: 6px 10px;
            font-size: 11px;
            margin-bottom: 8px;
            display: none;
        }
        .qe-msg.show { display: block; }
        .qe-msg--ok { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .qe-msg--err { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .qe-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
        }
        .qe-status-badge--active { background: #d4edda; color: #155724; }
        .qe-status-badge--inactive { background: #f8d7da; color: #721c24; }
        .qe-status-badge--deferred { background: #fff3cd; color: #856404; }

        .cr-query-pager {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
            padding: 10px;
            border-top: 1px solid #e0e0e0;
            background: #fff;
            font-size: 11px;
        }
        .cr-query-pager a,
        .cr-query-pager span {
            display: inline-block;
            min-width: 24px;
            text-align: center;
            padding: 4px 8px;
            border: 1px solid #ddd;
            color: #495057;
            text-decoration: none;
            background: #fff;
        }
        .cr-query-pager a:hover {
            background: #f1f3f5;
        }
        .cr-query-pager .active {
            background: #174DA4;
            border-color: #174DA4;
            color: #fff;
            font-weight: 600;
        }
        .cr-query-pager .meta {
            border: none;
            background: transparent;
            padding: 0 4px;
            min-width: auto;
            color: #666;
        }

        .cr-table-wrap { overflow-x: auto; }

        .cr-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.45);
            z-index: 9500;
            align-items: center;
            justify-content: center;
            padding: 16px;
        }
        .cr-modal-overlay.show { display: flex; }
        .cr-modal {
            background: #fff;
            border: 1px solid #d8dde6;
            width: 100%;
            max-width: 520px;
        }
        .cr-modal__head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 12px;
            border-bottom: 1px solid #e6ebf2;
            background: #f8fafc;
        }
        .cr-modal__title { font-size: 12px; font-weight: 700; color: #05275C; }
        .cr-modal__close {
            border: none;
            background: transparent;
            font-size: 18px;
            line-height: 1;
            cursor: pointer;
            color: #4b5563;
        }
        .cr-modal__body { padding: 12px; }
        .cr-modal__foot {
            display: flex;
            justify-content: flex-end;
            gap: 8px;
            padding: 10px 12px;
            border-top: 1px solid #e6ebf2;
            background: #f8fafc;
        }

        @media (max-width: 900px) {
            .cr-batch-bar { flex-direction: column; align-items: stretch; }
            .cr-batch-actions { flex-wrap: wrap; }
            .cr-batch-btn { width: 100%; justify-content: center; }
            .cr-filter-row { flex-direction: column; align-items: stretch; }
            .cr-filter-select { width: 100% !important; min-width: 100%; }
        }

        /* Print Styles */
        @media print {
            .cr-batch-bar, .cr-filter-row, .cr-retake-panel, .qe-overlay { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:UpdatePanel ID="upCourseReg" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
    <!-- Stats Bar -->
    <div class="cr-stats-bar">
        <div class="cr-stat-item">
            <span class="cr-stat-item__label">Academic Year:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litAcadYearDisplay" runat="server">2024/2025</asp:Literal></span>
        </div>
        <div class="cr-stat-item">
            <span class="cr-stat-item__label">Semester:</span>
            <span class="cr-stat-item__value"><asp:Literal ID="litSemesterDisplay" runat="server">Yr 1, Sem 1</asp:Literal></span>
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
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="cr-filter-select"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Programme:</span>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="cr-filter-select" Width="250px"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Study Year:</span>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="cr-filter-select">
            <asp:ListItem Value="1" Text="Year 1" Selected="True"></asp:ListItem>
            <asp:ListItem Value="2" Text="Year 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Year 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Year 4"></asp:ListItem>
            <asp:ListItem Value="5" Text="Year 5"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="cr-filter-row__label">Semester:</span>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="cr-filter-select">
            <asp:ListItem Value="1" Text="Sem 1" Selected="True"></asp:ListItem>
            <asp:ListItem Value="2" Text="Sem 2"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="cr-filter-row__label">Entry Year:</span>
        <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="cr-filter-select"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Intake:</span>
        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="cr-filter-select">
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
        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="cr-filter-select" Width="300px"></asp:DropDownList>
        
        <span class="cr-filter-row__label">Status:</span>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="cr-filter-select">
            <asp:ListItem Value="Pending" Text="Pending"></asp:ListItem>
            <asp:ListItem Value="Registered" Text="Registered" Selected="True"></asp:ListItem>
        </asp:DropDownList>

        <span class="cr-filter-row__label">Student:</span>
        <asp:TextBox ID="txtStudentFilter" runat="server" CssClass="cr-filter-select" Width="220px" placeholder="Reg No or Name"></asp:TextBox>
        <button type="button" class="cr-batch-btn" onclick="applyFiltersGet()">Apply</button>
    </div>
    
    <!-- Message Display -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="cr-message" Visible="false" aria-live="polite" role="status">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Retake Panel -->
    <div class="cr-modal-overlay" id="retakeModalOverlay" role="dialog" aria-modal="true" aria-labelledby="retakeModalTitle">
        <div class="cr-modal">
            <div class="cr-modal__head">
                <span class="cr-modal__title" id="retakeModalTitle">Add New Record</span>
                <button type="button" class="cr-modal__close" onclick="closeRetakeModal()" aria-label="Close">&times;</button>
            </div>
            <div class="cr-modal__body">
                <div class="cr-retake-row">
                    <span class="cr-filter-row__label">Reg No:</span>
                    <asp:TextBox ID="txtRetakeRegNo" runat="server" CssClass="cr-retake-input" placeholder="Enter Student Reg No"></asp:TextBox>
                </div>
                <div class="cr-retake-row" style="margin-top:8px;">
                    <span class="cr-filter-row__label">Record Type:</span>
                    <asp:DropDownList ID="ddlNewRecordType" runat="server" CssClass="cr-filter-select" Width="220px">
                        <asp:ListItem Value="REGULAR" Text="Regular Course Registration" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="RETAKE" Text="Retake Course Registration"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="cr-modal__foot">
                <button type="button" class="cr-batch-btn" onclick="closeRetakeModal()">Cancel</button>
                <asp:Button ID="btnAddRetake" runat="server" Text="Add Record" CssClass="cr-batch-btn cr-batch-btn--primary" OnClick="btnAddRetake_Click" OnClientClick="return validateAddRecordForm();" />
            </div>
        </div>
    </div>
    
    <!-- Batch Actions & Grid -->
    <div class="cd-card">
        <div class="cr-batch-bar">
            <div class="cr-batch-actions">
                <asp:Button ID="btnRegisterSelected" runat="server" Text="Register Selected" CssClass="cr-batch-btn cr-batch-btn--success" OnClick="btnRegisterSelected_Click" OnClientClick="return validateBatchAction('register');" />
                <asp:Button ID="btnRemoveSelected" runat="server" Text="Remove Selected" CssClass="cr-batch-btn cr-batch-btn--danger" OnClick="btnRemoveSelected_Click" OnClientClick="return validateBatchAction('remove');" Visible="false" />
                <button type="button" class="cr-batch-btn" onclick="openRetakeModal()">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add New Record
                </button>
            </div>
            <div>
                <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="cr-batch-btn" OnClick="btnExportExcel_Click" />
            </div>
        </div>
        <div class="cd-card__body cr-table-wrap">
            <dx:ASPxGridView ID="gvCourseReg" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="regno" 
            CssClass="cr-grid" ClientInstanceName="gvCourseReg" OnCustomCallback="gvCourseReg_CustomCallback">
                <SettingsPager PageSize="50" Visible="false" Mode="ShowAllRecords">
                </SettingsPager>
            <SettingsBehavior AllowFocusedRow="true" ConfirmDelete="true" AllowSort="true" />
            <Settings ShowFilterRow="true" ShowFilterRowMenu="true" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="30px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="1" Width="120px">
                        <Settings AllowAutoFilter="true" />
                        <DataItemTemplate>
                            <a href="javascript:void(0)" onclick="openQuickEdit('<%# Container.Text %>')" title="Quick Edit" style="color:#174DA4;text-decoration:underline;cursor:pointer;"><%# Container.Text %></a>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_name" Caption="Student Name" VisibleIndex="2">
                        <Settings AllowAutoFilter="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="spec_name" Caption="Specialisation" VisibleIndex="3" Width="200px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_code" Caption="Course" VisibleIndex="4" Width="110px" />
                    <dx:GridViewDataTextColumn FieldName="acad_year" Caption="Acad Year" VisibleIndex="5" Width="90px" />
                    <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="6" Width="50px" />
                    <dx:GridViewDataTextColumn FieldName="entryyear" Caption="Entry Year" VisibleIndex="7" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="intake" Caption="Intake" VisibleIndex="8" Width="90px" />
                    <dx:GridViewDataTextColumn FieldName="reg_status" Caption="Reg Status" VisibleIndex="9" Width="100px" />
                    <dx:GridViewDataTextColumn FieldName="course_status" Caption="Course Status" VisibleIndex="10" Width="110px">
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
            <asp:Literal ID="litQueryPager" runat="server"></asp:Literal>
        </div>
    </div>
    
    <!-- Loading Panel -->
    <dx:ASPxLoadingPanel ID="lpLoading" runat="server" ClientInstanceName="lpLoading" Modal="true" Text="Processing...">
    </dx:ASPxLoadingPanel>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExportExcel" />
            <asp:PostBackTrigger ControlID="btnPrintResults" />
        </Triggers>
    </asp:UpdatePanel>

    <!-- === Quick Edit Modal === -->
    <div class="qe-overlay" id="qeOverlay">
        <div class="qe-modal">
            <div class="qe-header">
                <span class="qe-header__title" id="qeTitle">Quick Edit Student</span>
                <button type="button" class="qe-header__close" onclick="closeQuickEdit()">&times;</button>
            </div>
            <div class="qe-body">
                <div class="qe-msg" id="qeMsg"></div>

                <asp:HiddenField ID="hfQeRegNo" runat="server" />
                <asp:Button ID="btnQeLoad" runat="server" OnClick="btnQeLoad_Click" style="display:none" />

                <!-- Personal Information -->
                <div class="qe-section">
                    <div class="qe-section__title">Personal Information</div>
                    <div class="qe-grid">
                        <div class="qe-field">
                            <span class="qe-label">Reg No</span>
                            <input type="text" id="qeRegNo" class="qe-input" readonly />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Entry No</span>
                            <input type="text" id="qeEntryNo" class="qe-input" readonly />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">First Name</span>
                            <asp:TextBox ID="txtQeFirstName" runat="server" CssClass="qe-input" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Other Names</span>
                            <asp:TextBox ID="txtQeOtherName" runat="server" CssClass="qe-input" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Gender</span>
                            <asp:DropDownList ID="ddlQeGender" runat="server" CssClass="qe-select">
                                <asp:ListItem Value="MALE" Text="Male" />
                                <asp:ListItem Value="FEMALE" Text="Female" />
                                <asp:ListItem Value="OTHER" Text="Other" />
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Date of Birth</span>
                            <asp:TextBox ID="txtQeDOB" runat="server" CssClass="qe-input" TextMode="Date" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">NIN (National ID)</span>
                            <asp:TextBox ID="txtQeNIN" runat="server" CssClass="qe-input" MaxLength="30" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Phone</span>
                            <asp:TextBox ID="txtQePhone" runat="server" CssClass="qe-input" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Email</span>
                            <asp:TextBox ID="txtQeEmail" runat="server" CssClass="qe-input" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Nationality</span>
                            <asp:TextBox ID="txtQeNationality" runat="server" CssClass="qe-input" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">District</span>
                            <asp:TextBox ID="txtQeDistrict" runat="server" CssClass="qe-input" />
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Religion</span>
                            <asp:DropDownList ID="ddlQeReligion" runat="server" CssClass="qe-select">
                                <asp:ListItem Value="-" Text="--" />
                                <asp:ListItem Value="CATHOLIC" Text="Catholic" />
                                <asp:ListItem Value="PROTESTANT" Text="Protestant" />
                                <asp:ListItem Value="MUSLIM" Text="Muslim" />
                                <asp:ListItem Value="SDA" Text="SDA" />
                                <asp:ListItem Value="ORTHODOX" Text="Orthodox" />
                                <asp:ListItem Value="PENTECOSTAL" Text="Pentecostal" />
                                <asp:ListItem Value="OTHER" Text="Other" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <!-- Academic Information -->
                <div class="qe-section">
                    <div class="qe-section__title">Academic Information</div>
                    <div class="qe-grid">
                        <div class="qe-field">
                            <span class="qe-label">Session</span>
                            <asp:DropDownList ID="ddlQeSession" runat="server" CssClass="qe-select">
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Campus</span>
                            <asp:DropDownList ID="ddlQeCampus" runat="server" CssClass="qe-select">
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Entry Year</span>
                            <asp:DropDownList ID="ddlQeEntryYear" runat="server" CssClass="qe-select">
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Entry Method</span>
                            <asp:DropDownList ID="ddlQeEntryMethod" runat="server" CssClass="qe-select">
                                <asp:ListItem Value="DIRECT" Text="Direct" />
                                <asp:ListItem Value="MATURE" Text="Mature" />
                                <asp:ListItem Value="DIPLOMA" Text="Diploma" />
                                <asp:ListItem Value="TRANSFER" Text="Transfer" />
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Intake</span>
                            <asp:DropDownList ID="ddlQeIntakeEdit" runat="server" CssClass="qe-select">
                                <asp:ListItem Value="AUGUST" Text="August" />
                                <asp:ListItem Value="JANUARY" Text="January" />
                                <asp:ListItem Value="FEBRUARY" Text="February" />
                                <asp:ListItem Value="MARCH" Text="March" />
                                <asp:ListItem Value="APRIL" Text="April" />
                                <asp:ListItem Value="MAY" Text="May" />
                                <asp:ListItem Value="JUNE" Text="June" />
                                <asp:ListItem Value="JULY" Text="July" />
                                <asp:ListItem Value="SEPTEMBER" Text="September" />
                                <asp:ListItem Value="OCTOBER" Text="October" />
                                <asp:ListItem Value="NOVEMBER" Text="November" />
                                <asp:ListItem Value="DECEMBER" Text="December" />
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Billing System</span>
                            <asp:DropDownList ID="ddlQeBilling" runat="server" CssClass="qe-select">
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <!-- Status -->
                <div class="qe-section">
                    <div class="qe-section__title">Status</div>
                    <div class="qe-grid">
                        <div class="qe-field">
                            <span class="qe-label">Student Status</span>
                            <asp:DropDownList ID="ddlQeStatus" runat="server" CssClass="qe-select">
                                <asp:ListItem Value="ACTIVE" Text="Active" />
                                <asp:ListItem Value="INACTIVE" Text="Inactive" />
                                <asp:ListItem Value="DEFERRED" Text="Deferred" />
                                <asp:ListItem Value="SUSPENDED" Text="Suspended" />
                                <asp:ListItem Value="EXPELLED" Text="Expelled" />
                                <asp:ListItem Value="GRADUATED" Text="Graduated" />
                                <asp:ListItem Value="DEAD" Text="Dead" />
                            </asp:DropDownList>
                        </div>
                        <div class="qe-field">
                            <span class="qe-label">Admission Status</span>
                            <asp:DropDownList ID="ddlQeNewStatus" runat="server" CssClass="qe-select">
                                <asp:ListItem Value="ADMITTED" Text="Admitted" />
                                <asp:ListItem Value="REGISTERED" Text="Registered" />
                                <asp:ListItem Value="GRADUATED" Text="Graduated" />
                                <asp:ListItem Value="DROPPED" Text="Dropped" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

            </div>
            <div class="qe-footer">
                <div style="display:flex; gap:6px;">
                    <asp:Button ID="btnQeFullEdit" runat="server" Text="Open Full Edit" CssClass="qe-btn qe-btn--link"
                        OnClientClick="openFullEdit(); return false;" />
                    <button type="button" class="qe-btn qe-btn--link" style="color:#28a745;" onclick="printResults()">Print Results</button>
                </div>
                <div style="display:flex; gap:6px;">
                    <button type="button" class="qe-btn" onclick="closeQuickEdit()">Cancel</button>
                    <asp:Button ID="btnQeSave" runat="server" Text="Save Changes" CssClass="qe-btn qe-btn--success"
                        OnClick="btnQeSave_Click" OnClientClick="return validateQuickEdit();" />
                </div>
            </div>
            <asp:Button ID="btnPrintResults" runat="server" OnClick="btnPrintResults_Click" style="display:none" />
        </div>
    </div>
    
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
        
        function openRetakeModal() {
            var modal = document.getElementById('retakeModalOverlay');
            if (!modal) return;
            modal.classList.add('show');
            var input = document.getElementById('<%= txtRetakeRegNo.ClientID %>');
            if (input) input.focus();
        }

        function closeRetakeModal() {
            var modal = document.getElementById('retakeModalOverlay');
            if (!modal) return;
            modal.classList.remove('show');
        }

        function validateAddRecordForm() {
            var regInput = document.getElementById('<%= txtRetakeRegNo.ClientID %>');
            if (!regInput || !regInput.value.trim()) {
                alert('Please enter a student registration number.');
                return false;
            }

            var course = document.getElementById('<%= ddlCourse.ClientID %>');
            if (!course || !course.value) {
                alert('Please select a course first.');
                return false;
            }

            return true;
        }

        function validateBatchAction(actionType) {
            var course = document.getElementById('<%= ddlCourse.ClientID %>');
            if (!course || !course.value) {
                alert('Please select a course first.');
                return false;
            }

            if (typeof gvCourseReg !== 'undefined' && gvCourseReg.GetSelectedRowCount && gvCourseReg.GetSelectedRowCount() <= 0) {
                alert('Select at least one student.');
                return false;
            }

            if (actionType === 'register') {
                return confirm('Register selected students for this course?');
            }
            return confirm('Remove registration for selected students?');
        }

        function applyFiltersGet() {
            var params = new URLSearchParams(window.location.search);
            params.set('page', '1');

            var acad = document.getElementById('<%= ddlAcadYear.ClientID %>').value;
            var prog = document.getElementById('<%= ddlProgramme.ClientID %>').value;
            var yr = document.getElementById('<%= ddlStudyYear.ClientID %>').value;
            var sem = document.getElementById('<%= ddlSemester.ClientID %>').value;
            var entyr = document.getElementById('<%= ddlEntryYear.ClientID %>').value;
            var intake = document.getElementById('<%= ddlIntake.ClientID %>').value;
            var course = document.getElementById('<%= ddlCourse.ClientID %>').value;
            var status = document.getElementById('<%= ddlStatus.ClientID %>').value;
            var student = document.getElementById('<%= txtStudentFilter.ClientID %>').value.trim();

            setOrRemove(params, 'acad', acad);
            setOrRemove(params, 'prog', prog);
            setOrRemove(params, 'yr', yr);
            setOrRemove(params, 'sem', sem);
            setOrRemove(params, 'entyr', entyr && entyr !== '-' ? entyr : '');
            setOrRemove(params, 'intake', intake && intake !== '-' ? intake : '');
            setOrRemove(params, 'course', course);
            setOrRemove(params, 'status', status);
            setOrRemove(params, 'student', student);

            window.location.href = window.location.pathname + '?' + params.toString();
        }

        function setOrRemove(params, key, value) {
            if (value && value.length > 0) {
                params.set(key, value);
            } else {
                params.delete(key);
            }
        }

        function wireGetFilters() {
            var ids = [
                '<%= ddlAcadYear.ClientID %>',
                '<%= ddlProgramme.ClientID %>',
                '<%= ddlStudyYear.ClientID %>',
                '<%= ddlSemester.ClientID %>',
                '<%= ddlEntryYear.ClientID %>',
                '<%= ddlIntake.ClientID %>',
                '<%= ddlCourse.ClientID %>',
                '<%= ddlStatus.ClientID %>'
            ];
            for (var i = 0; i < ids.length; i++) {
                var el = document.getElementById(ids[i]);
                if (el) el.addEventListener('change', applyFiltersGet);
            }

            var student = document.getElementById('<%= txtStudentFilter.ClientID %>');
            if (student) {
                student.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        applyFiltersGet();
                    }
                });
            }
        }

        document.addEventListener('DOMContentLoaded', wireGetFilters);

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeRetakeModal();
        });

        document.addEventListener('click', function (e) {
            var modal = document.getElementById('retakeModalOverlay');
            if (modal && e.target === modal) closeRetakeModal();
        });
        
        // Filters are hidden by default; user toggles when needed.

        // === Quick Edit Modal =================================
        function openQuickEdit(regno) {
            if (!regno) return;
            document.getElementById('qeMsg').className = 'qe-msg';
            document.getElementById('qeMsg').innerHTML = '';
            // Set hidden field for server-side
            document.getElementById('<%= hfQeRegNo.ClientID %>').value = regno;
            // Fire callback to load student data
            document.getElementById('<%= btnQeLoad.ClientID %>').click();
        }

        function showQuickEditModal() {
            document.getElementById('qeOverlay').classList.add('show');
        }

        function closeQuickEdit() {
            document.getElementById('qeOverlay').classList.remove('show');
        }

        function validateQuickEdit() {
            var fn = document.getElementById('<%= txtQeFirstName.ClientID %>');
            if (!fn || !fn.value.trim()) {
                qeShowMsg('First Name is required.', 'err');
                return false;
            }
            var ph = document.getElementById('<%= txtQePhone.ClientID %>');
            if (!ph || !ph.value.trim()) {
                qeShowMsg('Phone number is required.', 'err');
                return false;
            }
            var sess = document.getElementById('<%= ddlQeSession.ClientID %>');
            if (!sess || !sess.value) {
                qeShowMsg('Please select a Study Session.', 'err');
                return false;
            }
            // Email format (optional field)
            var em = document.getElementById('<%= txtQeEmail.ClientID %>');
            if (em && em.value.trim()) {
                var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!re.test(em.value.trim())) {
                    qeShowMsg('Invalid email address format.', 'err');
                    return false;
                }
            }
            // Disable save button to prevent double-click
            var btn = document.getElementById('<%= btnQeSave.ClientID %>');
            if (btn) { btn.disabled = true; btn.value = 'Saving...'; }
            return true;
        }

        function qeShowMsg(msg, type) {
            var el = document.getElementById('qeMsg');
            el.className = 'qe-msg show qe-msg--' + type;
            el.innerHTML = msg;
            // Re-enable save button after server response
            var btn = document.getElementById('<%= btnQeSave.ClientID %>');
            if (btn) { btn.disabled = false; btn.value = 'Save Changes'; }
        }

        function openFullEdit() {
            var rn = document.getElementById('<%= hfQeRegNo.ClientID %>').value;
            if (rn) {
                var url = 'NewStudentRegistration.aspx?edit=' + encodeURIComponent(rn);
                window.open(url, 'FullEdit', 'width=1100,height=750,scrollbars=yes,resizable=yes');
            }
        }

        function printResults() {
            var rn = document.getElementById('<%= hfQeRegNo.ClientID %>').value;
            if (!rn) return;
            document.getElementById('<%= btnPrintResults.ClientID %>').click();
        }

        // Wire up grid row double-click for quick edit
        function onGridFocusedRowChanged(s, e) {
            var key = s.GetFocusedRowKey();
            if (key) openQuickEdit(key);
        }
    </script>
</asp:Content>
