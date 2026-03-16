<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AcademicResults.aspx.cs" Inherits="COOPERP_NewScreens_AcademicResults" Title="Academic Results Manager - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Stats Bar */
        .ar-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .ar-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 12px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            font-size: 11px;
        }
        .ar-stat-item__label { color: #666; }
        .ar-stat-item__value { font-weight: 700; color: #174DA4; }
        .ar-stat-item--pass .ar-stat-item__value { color: #28a745; }
        .ar-stat-item--fail .ar-stat-item__value { color: #dc3545; }
        .ar-stat-item--retake .ar-stat-item__value { color: #fd7e14; }
        
        /* Search Bar */
        .ar-search-bar {
            display: flex;
            gap: 6px;
            align-items: center;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .ar-search-input {
            border: 1px solid #ddd;
            padding: 7px 12px;
            font-size: 12px;
            min-width: 300px;
            border-radius: 4px;
            background: #fff;
        }
        .ar-search-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.15); }
        .ar-search-input::placeholder { color: #aaa; }
        .ar-search-hint {
            font-size: 10px;
            color: #888;
            margin-left: 4px;
        }
        
        /* Filter Toggle & Row */
        .ar-filter-toggle {
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
        .ar-filter-toggle:hover { background: #f8f9fa; }
        .ar-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .ar-filter-toggle svg { width: 12px; height: 12px; }

        .ar-filter-row {
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
        .ar-filter-row.show { display: flex; }
        .ar-filter-row__label {
            font-size: 10px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
        }
        .ar-filter-select {
            border: 1px solid #ddd;
            padding: 6px 10px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
            border-radius: 4px;
        }
        .ar-filter-select:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.1); }
        
        /* Status Badges */
        .ar-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-radius: 3px;
        }
        .ar-badge--first { background: #d4edda; color: #155724; }
        .ar-badge--upper { background: #cce5ff; color: #004085; }
        .ar-badge--lower { background: #fff3cd; color: #856404; }
        .ar-badge--pass { background: #e2e3e5; color: #383d41; }
        .ar-badge--fail { background: #f8d7da; color: #721c24; }
        .ar-badge--retake { background: #f8d7da; color: #721c24; }
        
        /* Mark cells */
        .ar-mark-cell { 
            display: inline-block;
            min-width: 30px;
            text-align: center; 
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 3px;
        }
        .ar-mark-cell--pass { color: #155724; background: #d4edda; }
        .ar-mark-cell--fail { color: #721c24; background: #f8d7da; }
        
        /* Grade badge */
        .ar-grade { 
            display: inline-block;
            min-width: 24px;
            text-align: center;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 11px;
        }
        .ar-grade--a { background: #d4edda; color: #155724; }
        .ar-grade--b { background: #cce5ff; color: #004085; }
        .ar-grade--c { background: #fff3cd; color: #856404; }
        .ar-grade--d { background: #e2e3e5; color: #383d41; }
        .ar-grade--e, .ar-grade--f { background: #f8d7da; color: #721c24; }
        
        /* Card */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .cd-card__body { padding: 0; }
        
        /* Action Bar */
        .ar-action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 12px;
            background: linear-gradient(to bottom, #f8f9fa, #e9ecef);
            border-bottom: 1px solid #e0e0e0;
            gap: 10px;
            border-radius: 6px 6px 0 0;
        }
        .ar-actions {
            display: flex;
            gap: 6px;
            align-items: center;
        }
        .ar-btn {
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
        .ar-btn:hover { background: #e9ecef; }
        .ar-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .ar-btn--primary:hover { background: #0d3a7d; }
        .ar-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .ar-btn--success:hover { background: #218838; }
        .ar-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; }
        .ar-btn--danger:hover { background: #c82333; }
        .ar-btn svg { width: 12px; height: 12px; }
        
        /* Grid */
        .ar-grid { border-collapse: collapse; }
        .ar-grid .dxgvHeader td,
        .ar-grid .dxgvHeader_Glass td {
            background: linear-gradient(to bottom, #f8f9fa, #e9ecef) !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            color: #495057 !important;
            border-bottom: 2px solid #174DA4 !important;
        }
        .ar-grid .dxgvDataRow td,
        .ar-grid .dxgvDataRow_Glass td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .ar-grid .dxgvDataRow:hover td,
        .ar-grid .dxgvDataRow_Glass:hover td {
            background: #e3f2fd !important;
        }
        .ar-grid .dxgvSelectedRow td,
        .ar-grid .dxgvSelectedRow_Glass td {
            background: #cce5ff !important;
        }
        
        /* Message Box */
        .ar-message {
            padding: 10px 14px;
            font-size: 11px;
            margin-bottom: 10px;
            display: none;
            border-radius: 4px;
        }
        .ar-message.show { display: block; }
        .ar-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .ar-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .ar-message--info { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
        .ar-message--warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        
        /* Print */
        @media print {
            .ar-action-bar, .ar-filter-row, .ar-search-bar { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar -->
    <div class="ar-stats-bar">
        <div class="ar-stat-item">
            <span class="ar-stat-item__label">Total Results:</span>
            <span class="ar-stat-item__value"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ar-stat-item">
            <span class="ar-stat-item__label">Students:</span>
            <span class="ar-stat-item__value"><asp:Literal ID="litStudentCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ar-stat-item ar-stat-item--pass">
            <span class="ar-stat-item__label">Pass:</span>
            <span class="ar-stat-item__value"><asp:Literal ID="litPassCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ar-stat-item ar-stat-item--fail">
            <span class="ar-stat-item__label">Fail:</span>
            <span class="ar-stat-item__value"><asp:Literal ID="litFailCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ar-stat-item ar-stat-item--retake">
            <span class="ar-stat-item__label">Retake:</span>
            <span class="ar-stat-item__value"><asp:Literal ID="litRetakeCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ar-stat-item">
            <span class="ar-stat-item__label">Avg Score:</span>
            <span class="ar-stat-item__value"><asp:Literal ID="litAvgScore" runat="server">0.0</asp:Literal></span>
        </div>
        
        <button type="button" class="ar-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
            <span>Filters</span>
        </button>
    </div>
    
    <!-- Search Bar -->
    <div class="ar-search-bar">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="ar-search-input" placeholder="Search by student name or registration number..." />
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="ar-btn ar-btn--primary" OnClick="btnSearch_Click" />
        <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="ar-btn" OnClick="btnClearSearch_Click" />
        <span class="ar-search-hint">Searches across all programmes &amp; academic years</span>
    </div>
    
    <!-- Filter Row -->
    <div class="ar-filter-row" id="filterRow">
        <span class="ar-filter-row__label">Programme:</span>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" Width="250px"></asp:DropDownList>
        
        <span class="ar-filter-row__label">Academic Year:</span>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed"></asp:DropDownList>
        
        <span class="ar-filter-row__label">Study Year:</span>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="1" Text="Year 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Year 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Year 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Year 4"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="ar-filter-row__label">Semester:</span>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="1" Text="Sem 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Sem 2"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="ar-filter-row__label">Course:</span>
        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" Width="300px"></asp:DropDownList>
        
        <span class="ar-filter-row__label">Grade:</span>
        <asp:DropDownList ID="ddlGrade" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="A" Text="A"></asp:ListItem>
            <asp:ListItem Value="A-" Text="A-"></asp:ListItem>
            <asp:ListItem Value="B+" Text="B+"></asp:ListItem>
            <asp:ListItem Value="B" Text="B"></asp:ListItem>
            <asp:ListItem Value="B-" Text="B-"></asp:ListItem>
            <asp:ListItem Value="C+" Text="C+"></asp:ListItem>
            <asp:ListItem Value="C" Text="C"></asp:ListItem>
            <asp:ListItem Value="C-" Text="C-"></asp:ListItem>
            <asp:ListItem Value="D" Text="D"></asp:ListItem>
            <asp:ListItem Value="E" Text="E / Fail"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="ar-filter-row__label">Comment:</span>
        <asp:DropDownList ID="ddlComment" runat="server" CssClass="ar-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="NP" Text="Normal Pass (NP)"></asp:ListItem>
            <asp:ListItem Value="RT" Text="Retake (RT)"></asp:ListItem>
            <asp:ListItem Value="PP" Text="Probationary Pass (PP)"></asp:ListItem>
            <asp:ListItem Value="SP" Text="Supplementary (SP)"></asp:ListItem>
        </asp:DropDownList>
    </div>
    
    <!-- Message -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="ar-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Grid -->
    <div class="cd-card">
        <div class="ar-action-bar">
            <div class="ar-actions">
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="ar-btn ar-btn--primary" OnClick="btnRefresh_Click" />
                <asp:Button ID="btnDeleteSelected" runat="server" Text="Delete Selected" CssClass="ar-btn ar-btn--danger" OnClick="btnDeleteSelected_Click" OnClientClick="return confirm('Are you sure you want to delete the selected results? This cannot be undone.');" />
                <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="ar-btn" OnClick="btnExportExcel_Click" />
            </div>
            <asp:Label ID="lblMessage" runat="server" CssClass="ar-message" style="margin-left: 20px; font-weight: bold;"></asp:Label>
        </div>
        <div class="cd-card__body">
            <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="ID" 
                CssClass="ar-grid" OnRowUpdating="gvResults_RowUpdating" OnRowDeleting="gvResults_RowDeleting"
                OnBatchUpdate="gvResults_BatchUpdate">
                <SettingsPager PageSize="200" AlwaysShowPager="true" Position="Bottom">
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
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="2" Width="120px" ReadOnly="true">
                        <Settings AllowAutoFilter="true" />
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_name" Caption="Student Name" VisibleIndex="3" Width="180px" ReadOnly="true">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="courseid" Caption="Course Code" VisibleIndex="4" Width="100px" ReadOnly="true">
                        <CellStyle Font-Size="10px" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="coursename" Caption="Course Name" VisibleIndex="5" Width="200px" ReadOnly="true">
                        <CellStyle Font-Size="10px" ForeColor="#555" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="acad" Caption="Acad Year" VisibleIndex="6" Width="90px" ReadOnly="true">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="studyyear" Caption="Yr" VisibleIndex="7" Width="35px" ReadOnly="true">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="8" Width="35px" ReadOnly="true">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="CreditUnits" Caption="CU" VisibleIndex="9" Width="40px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="20" NumberType="Integer" DisplayFormatString="{0:0}">
                        </PropertiesSpinEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="score" Caption="Score" VisibleIndex="10" Width="55px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="100" NumberType="Integer" DisplayFormatString="{0:0}">
                        </PropertiesSpinEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataTextColumn FieldName="grade" Caption="Grade" VisibleIndex="11" Width="50px" ReadOnly="true">
                        <DataItemTemplate>
                            <%# GetGradeBadge(Eval("grade")) %>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gradept" Caption="GP" VisibleIndex="12" Width="40px" ReadOnly="true">
                        <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                        </PropertiesTextEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gpa" Caption="GPA" VisibleIndex="13" Width="45px" ReadOnly="true">
                        <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                        </PropertiesTextEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="result_comment" Caption="Comment" VisibleIndex="14" Width="65px" ReadOnly="true">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Font-Size="10px" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progcode" Caption="Programme" VisibleIndex="15" Visible="false">
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
    
    <dx:ASPxLoadingPanel ID="lpLoading" runat="server" ClientInstanceName="lpLoading" Modal="true" Text="Processing...">
    </dx:ASPxLoadingPanel>
    
    <script type="text/javascript">
        function toggleFilters() {
            var filterRow = document.getElementById('filterRow');
            var toggleBtn = document.querySelector('.ar-filter-toggle');
            if (filterRow.classList.contains('show')) {
                filterRow.classList.remove('show');
                toggleBtn.classList.remove('active');
            } else {
                filterRow.classList.add('show');
                toggleBtn.classList.add('active');
            }
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('filterRow').classList.add('show');
            document.querySelector('.ar-filter-toggle').classList.add('active');
        });
    </script>
</asp:Content>
