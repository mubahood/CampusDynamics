<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsRelease.aspx.cs" Inherits="COOPERP_NewScreens_ResultsRelease" Title="Results Release - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Stats Bar - Compact Inline */
        .rr-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .rr-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 12px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            font-size: 11px;
        }
        .rr-stat-item__label { color: #666; }
        .rr-stat-item__value { font-weight: 700; color: #174DA4; }
        .rr-stat-item--pending .rr-stat-item__value { color: #dc3545; }
        .rr-stat-item--released .rr-stat-item__value { color: #28a745; }
        .rr-stat-item--total .rr-stat-item__value { color: #007bff; }
        
        /* Filter Toggle & Row */
        .rr-filter-toggle {
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
        .rr-filter-toggle:hover { background: #f8f9fa; }
        .rr-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .rr-filter-toggle svg { width: 12px; height: 12px; }
        
        .rr-filter-row {
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
        .rr-filter-row.show { display: flex; }
        .rr-filter-row__label {
            font-size: 10px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
        }
        .rr-filter-select {
            border: 1px solid #ddd;
            padding: 6px 10px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
            border-radius: 4px;
        }
        .rr-filter-select:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.1); }
        
        /* Status Badges */
        .rr-status-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-radius: 3px;
        }
        .rr-status-badge--pending { background: #fff3cd; color: #856404; }
        .rr-status-badge--released { background: #d4edda; color: #155724; }
        .rr-status-badge--held { background: #f8d7da; color: #721c24; }
        
        /* Card Styles */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .cd-card__body { padding: 0; }
        
        /* Grid Styling */
        .rr-grid { border-collapse: collapse; }
        .rr-grid .dxgvHeader td,
        .rr-grid .dxgvHeader_Glass td {
            background: linear-gradient(to bottom, #f8f9fa, #e9ecef) !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            color: #495057 !important;
            border-bottom: 2px solid #174DA4 !important;
        }
        .rr-grid .dxgvDataRow td,
        .rr-grid .dxgvDataRow_Glass td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .rr-grid .dxgvDataRow:hover td,
        .rr-grid .dxgvDataRow_Glass:hover td {
            background: #e3f2fd !important;
        }
        .rr-grid .dxgvSelectedRow td,
        .rr-grid .dxgvSelectedRow_Glass td {
            background: #cce5ff !important;
        }
        
        /* Batch Actions Bar */
        .rr-batch-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 12px;
            background: linear-gradient(to bottom, #f8f9fa, #e9ecef);
            border-bottom: 1px solid #e0e0e0;
            gap: 10px;
            border-radius: 6px 6px 0 0;
        }
        .rr-batch-actions {
            display: flex;
            gap: 6px;
            align-items: center;
        }
        .rr-batch-btn {
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
        .rr-batch-btn:hover { background: #e9ecef; }
        .rr-batch-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .rr-batch-btn--primary:hover { background: #0d3a7d; }
        .rr-batch-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .rr-batch-btn--success:hover { background: #218838; }
        .rr-batch-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; }
        .rr-batch-btn--danger:hover { background: #c82333; }
        .rr-batch-btn--warning { background: #ffc107; color: #212529; border-color: #ffc107; }
        .rr-batch-btn--warning:hover { background: #e0a800; }
        .rr-batch-btn svg { width: 12px; height: 12px; }
        .rr-batch-btn:disabled { opacity: 0.6; cursor: not-allowed; }
        
        /* Message Box */
        .rr-message {
            padding: 10px 14px;
            font-size: 11px;
            margin-bottom: 10px;
            display: none;
            border-radius: 4px;
        }
        .rr-message.show { display: block; }
        .rr-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .rr-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .rr-message--info { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
        .rr-message--warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        
        /* Print Styles */
        @media print {
            .rr-batch-bar, .rr-filter-row { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar -->
    <div class="rr-stats-bar">
        <div class="rr-stat-item">
            <span class="rr-stat-item__label">Academic Year:</span>
            <span class="rr-stat-item__value"><asp:Literal ID="litAcadYearDisplay" runat="server">2024/2025</asp:Literal></span>
        </div>
        <div class="rr-stat-item">
            <span class="rr-stat-item__label">Semester:</span>
            <span class="rr-stat-item__value"><asp:Literal ID="litSemesterDisplay" runat="server">1</asp:Literal></span>
        </div>
        <div class="rr-stat-item rr-stat-item--total">
            <span class="rr-stat-item__label">Total Courses:</span>
            <span class="rr-stat-item__value"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="rr-stat-item rr-stat-item--pending">
            <span class="rr-stat-item__label">Pending Release:</span>
            <span class="rr-stat-item__value"><asp:Literal ID="litPendingCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="rr-stat-item rr-stat-item--released">
            <span class="rr-stat-item__label">Released:</span>
            <span class="rr-stat-item__value"><asp:Literal ID="litReleasedCount" runat="server">0</asp:Literal></span>
        </div>
        
        <button type="button" class="rr-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
            <span>Filters</span>
        </button>
    </div>
    
    <!-- Filter Row -->
    <div class="rr-filter-row" id="filterRow">
        <span class="rr-filter-row__label">Faculty:</span>
        <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="rr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged" Width="200px"></asp:DropDownList>
        
        <span class="rr-filter-row__label">Programme:</span>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="rr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" Width="200px"></asp:DropDownList>
        
        <span class="rr-filter-row__label">Academic Year:</span>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="rr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="rr-filter-row__label">Semester:</span>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="rr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="1" Text="Sem 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Sem 2"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="rr-filter-row__label">Status:</span>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="rr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --" Selected="True"></asp:ListItem>
            <asp:ListItem Value="PENDING" Text="Pending"></asp:ListItem>
            <asp:ListItem Value="RELEASED" Text="Released"></asp:ListItem>
            <asp:ListItem Value="HELD" Text="Held"></asp:ListItem>
        </asp:DropDownList>
    </div>
    
    <!-- Message Display -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="rr-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Batch Actions & Grid -->
    <div class="cd-card">
        <div class="rr-batch-bar">
            <div class="rr-batch-actions">
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rr-batch-btn rr-batch-btn--primary" OnClick="btnRefresh_Click" />
                <asp:Button ID="btnReleaseSelected" runat="server" Text="Release Selected" CssClass="rr-batch-btn rr-batch-btn--success" OnClick="btnReleaseSelected_Click" OnClientClick="return confirm('Release results for selected courses to students?');" />
                <asp:Button ID="btnHoldSelected" runat="server" Text="Hold Selected" CssClass="rr-batch-btn rr-batch-btn--danger" OnClick="btnHoldSelected_Click" OnClientClick="return confirm('Hold release for selected courses?');" />
                <asp:Button ID="btnExportExcel" runat="server" Text="Excel" CssClass="rr-batch-btn rr-batch-btn--warning" OnClick="btnExportExcel_Click" />
            </div>
            <asp:Label ID="lblMessage" runat="server" style="font-size: 11px; font-weight: bold;"></asp:Label>
        </div>
        <div class="cd-card__body">
            <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="row_id" 
                CssClass="rr-grid">
                <SettingsPager PageSize="50" AlwaysShowPager="true" Position="Bottom">
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" />
                <Settings ShowFilterRow="false" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="30px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="course_id" Caption="Course Code" VisibleIndex="1" Width="90px">
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course Name" VisibleIndex="2" Width="200px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme" VisibleIndex="3" Width="180px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Acad Year" VisibleIndex="4" Width="80px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="5" Width="40px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="student_count" Caption="Students" VisibleIndex="6" Width="60px">
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="approved_count" Caption="Approved" VisibleIndex="7" Width="70px">
                        <CellStyle HorizontalAlign="Center" ForeColor="#28a745" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="release_status" Caption="Status" VisibleIndex="8" Width="80px">
                        <DataItemTemplate>
                            <%# GetStatusBadge(Eval("release_status")) %>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataDateColumn FieldName="release_date" Caption="Released" VisibleIndex="9" Width="80px">
                        <PropertiesDateEdit DisplayFormatString="dd-MMM-yy" />
                    </dx:GridViewDataDateColumn>
                    <dx:GridViewDataTextColumn FieldName="released_by" Caption="Released By" VisibleIndex="10" Width="100px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="prog_id" Visible="false" VisibleIndex="11" />
                </Columns>
            </dx:ASPxGridView>
            
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvResults">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <script type="text/javascript">
        function toggleFilters() {
            var filterRow = document.getElementById('filterRow');
            var toggleBtn = document.querySelector('.rr-filter-toggle');
            if (filterRow.classList.contains('show')) {
                filterRow.classList.remove('show');
                toggleBtn.classList.remove('active');
            } else {
                filterRow.classList.add('show');
                toggleBtn.classList.add('active');
            }
        }
    </script>
</asp:Content>
