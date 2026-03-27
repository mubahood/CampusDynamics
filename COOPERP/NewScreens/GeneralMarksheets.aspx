<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GeneralMarksheets.aspx.cs" Inherits="COOPERP_NewScreens_GeneralMarksheets" Title="General Marksheets - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
/* ---- CD Page Header ---- */
.cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
.cd-page-header__left { display:flex; align-items:center; gap:12px; }
.cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        /* Stats Bar - Compact Inline */ {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .gm-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 12px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 0;
            font-size: 11px;
        }
        .gm-stat-item__label { color: #666; }
        .gm-stat-item__value { font-weight: 700; color: #174DA4; }
        .gm-stat-item--pending .gm-stat-item__value { color: #dc3545; }
        .gm-stat-item--submitted .gm-stat-item__value { color: #007bff; }
        .gm-stat-item--approved .gm-stat-item__value { color: #28a745; }
        .gm-stat-item--captured .gm-stat-item__value { color: #6f42c1; }
        
        /* Filter Toggle & Row */
        .gm-filter-toggle {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            font-size: 11px;
            font-weight: 500;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 0;
            cursor: pointer;
            color: #495057;
        }
        .gm-filter-toggle:hover { background: #f8f9fa; }
        .gm-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .gm-filter-toggle svg { width: 12px; height: 12px; }
        
        .gm-filter-row {
            display: none;
            gap: 10px;
            padding: 12px 15px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .gm-filter-row.show { display: flex; }
        .gm-filter-row__label {
            font-size: 10px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
        }
        .gm-filter-select {
            border: 1px solid #ddd;
            padding: 6px 10px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
            border-radius: 0;
        }
        .gm-filter-select:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.1); }
        
        /* Status Badges */
        .gm-status-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-radius: 0;
        }
        .gm-status-badge--pending { background: #fff3cd; color: #856404; }
        .gm-status-badge--submitted { background: #cce5ff; color: #004085; }
        .gm-status-badge--approved { background: #d4edda; color: #155724; }
        .gm-status-badge--captured { background: #e2d9f3; color: #6f42c1; }
        
        /* Card Styles */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
        }
        .cd-card__body { padding: 0; }
        
        /* Grid Styling */
        .gm-grid { border-collapse: collapse; }
        .gm-grid .dxgvHeader td,
        .gm-grid .dxgvHeader_Glass td {
            background: #f5f7fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            color: #495057 !important;
            border-bottom: 2px solid #174DA4 !important;
        }
        .gm-grid .dxgvDataRow td,
        .gm-grid .dxgvDataRow_Glass td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .gm-grid .dxgvDataRow:hover td,
        .gm-grid .dxgvDataRow_Glass:hover td {
            background: #e3f2fd !important;
        }
        .gm-grid .dxgvSelectedRow td,
        .gm-grid .dxgvSelectedRow_Glass td {
            background: #cce5ff !important;
        }
        .gm-grid .dxgvFocusedRow td,
        .gm-grid .dxgvFocusedRow_Glass td {
            background: #b8daff !important;
        }
        
        /* Batch Actions Bar */
        .gm-batch-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 12px;
            background: #f5f7fa;
            border-bottom: 1px solid #e0e0e0;
            gap: 10px;
            border-radius: 0;
        }
        .gm-batch-actions {
            display: flex;
            gap: 6px;
            align-items: center;
        }
        .gm-batch-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 6px 12px;
            font-size: 11px;
            font-weight: 500;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 0;
            cursor: pointer;
            color: #495057;
            transition: all 0.15s ease;
        }
        .gm-batch-btn:hover { background: #e9ecef; }
        .gm-batch-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .gm-batch-btn--primary:hover { background: #0d3a7d; }
        .gm-batch-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .gm-batch-btn--success:hover { background: #218838; }
        .gm-batch-btn--warning { background: #ffc107; color: #212529; border-color: #ffc107; }
        .gm-batch-btn--warning:hover { background: #e0a800; }
        .gm-batch-btn svg { width: 12px; height: 12px; }
        .gm-batch-btn:disabled { opacity: 0.6; cursor: not-allowed; }
        
        /* Message Box */
        .gm-message {
            padding: 10px 14px;
            font-size: 11px;
            margin-bottom: 10px;
            display: none;
            border-radius: 0;
        }
        .gm-message.show { display: block; }
        .gm-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .gm-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .gm-message--info { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
        .gm-message--warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        
        /* Details Button */
        .gm-details-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            background: #e3f2fd;
            border: 1px solid #90caf9;
            border-radius: 0;
            color: #174DA4;
            cursor: pointer;
            transition: all 0.15s;
        }
        .gm-details-btn:hover {
            background: #174DA4;
            color: #fff;
        }
        
        /* Print Styles */
        @media print {
            .gm-batch-bar, .gm-filter-row { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<!-- ======= PAGE HEADER =========================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/><line x1="9" y1="12" x2="15" y2="12"/><line x1="9" y1="16" x2="15" y2="16"/></svg>
        </div>
        <div>
            <div class="cd-page-header__title">General Marksheets</div>
            <div class="cd-page-header__sub">Generate and export programme marksheets for all student cohorts</div>
        </div>
    </div>
</div>
    <!-- Stats Bar -->
    <div class="gm-stats-bar">
        <div class="gm-stat-item">
            <span class="gm-stat-item__label">Academic Year:</span>
            <span class="gm-stat-item__value"><asp:Literal ID="litAcadYearDisplay" runat="server">2024/2025</asp:Literal></span>
        </div>
        <div class="gm-stat-item">
            <span class="gm-stat-item__label">Semester:</span>
            <span class="gm-stat-item__value"><asp:Literal ID="litSemesterDisplay" runat="server">1</asp:Literal></span>
        </div>
        <div class="gm-stat-item gm-stat-item--pending">
            <span class="gm-stat-item__label">Pending:</span>
            <span class="gm-stat-item__value"><asp:Literal ID="litPendingCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="gm-stat-item gm-stat-item--submitted">
            <span class="gm-stat-item__label">Submitted:</span>
            <span class="gm-stat-item__value"><asp:Literal ID="litSubmittedCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="gm-stat-item gm-stat-item--approved">
            <span class="gm-stat-item__label">Approved:</span>
            <span class="gm-stat-item__value"><asp:Literal ID="litApprovedCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="gm-stat-item gm-stat-item--captured">
            <span class="gm-stat-item__label">Captured:</span>
            <span class="gm-stat-item__value"><asp:Literal ID="litCapturedCount" runat="server">0</asp:Literal></span>
        </div>
        
        <button type="button" class="gm-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
            <span>Filters</span>
        </button>
    </div>
    
    <!-- Filter Row -->
    <div class="gm-filter-row" id="filterRow">
        <span class="gm-filter-row__label">Faculty:</span>
        <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="gm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged" Width="200px"></asp:DropDownList>
        
        <span class="gm-filter-row__label">Academic Year:</span>
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="gm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="gm-filter-row__label">Semester:</span>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="gm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="1" Text="Sem 1" Selected="True"></asp:ListItem>
            <asp:ListItem Value="2" Text="Sem 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Sem 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Sem 4"></asp:ListItem>
        </asp:DropDownList>
        
        <span class="gm-filter-row__label">Campus:</span>
        <asp:DropDownList ID="ddlCampus" runat="server" CssClass="gm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCampus_SelectedIndexChanged"></asp:DropDownList>
        
        <span class="gm-filter-row__label">Status:</span>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="gm-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
            <asp:ListItem Value="NEW" Text="NEW"></asp:ListItem>
            <asp:ListItem Value="SUBMITTED" Text="SUBMITTED" Selected="True"></asp:ListItem>
            <asp:ListItem Value="APPROVED" Text="APPROVED"></asp:ListItem>
            <asp:ListItem Value="CAPTURED" Text="CAPTURED"></asp:ListItem>
        </asp:DropDownList>
    </div>
    
    <!-- Message Display -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="gm-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Batch Actions & Grid -->
    <div class="cd-card">
        <div class="gm-batch-bar">
            <div class="gm-batch-actions">
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="gm-batch-btn gm-batch-btn--primary" OnClick="btnRefresh_Click" />
                <asp:Button ID="btnApproveSelected" runat="server" Text="Approve" CssClass="gm-batch-btn gm-batch-btn--success" OnClick="btnApproveSelected_Click" OnClientClick="return confirm('Approve selected marksheets?');" />
                <asp:Button ID="btnExportExcel" runat="server" Text="Excel" CssClass="gm-batch-btn gm-batch-btn--warning" OnClick="btnExportExcel_Click" />
            </div>
            <asp:Label ID="lblMessage" runat="server" style="font-size: 11px; font-weight: bold;"></asp:Label>
        </div>
        <div class="cd-card__body">
            <dx:ASPxGridView ID="gvMarksheets" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="ID" 
                CssClass="gm-grid" OnRowCommand="gvMarksheets_RowCommand">
                <SettingsPager PageSize="50" AlwaysShowPager="true" Position="Bottom">
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" ConfirmDelete="true" />
                <Settings ShowFilterRow="false" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="30px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" VisibleIndex="1" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="courseID" Caption="Code" VisibleIndex="2" Width="80px">
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course Name" VisibleIndex="3" Width="180px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="classname" Caption="Class" VisibleIndex="4" Width="150px">
                        <CellStyle Font-Size="10px" ForeColor="#555" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="cyear" Caption="Yr" VisibleIndex="5" Width="35px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stream" Caption="Stream" VisibleIndex="6" Width="60px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="EntryYear" Caption="Entry" VisibleIndex="7" Width="45px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="intake" Caption="Intake" VisibleIndex="8" Width="70px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_session" Caption="Session" VisibleIndex="9" Width="60px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Lecturer" VisibleIndex="10" Width="130px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataDateColumn FieldName="dateCreated" Caption="Created" VisibleIndex="11" Width="80px">
                        <PropertiesDateEdit DisplayFormatString="dd-MMM-yy" />
                    </dx:GridViewDataDateColumn>
                    <dx:GridViewDataDateColumn FieldName="dateSubmitted" Caption="Submitted" VisibleIndex="12" Width="80px">
                        <PropertiesDateEdit DisplayFormatString="dd-MMM-yy" />
                    </dx:GridViewDataDateColumn>
                    <dx:GridViewDataTextColumn FieldName="sheet_status" Caption="Status" VisibleIndex="13" Width="80px">
                        <DataItemTemplate>
                            <%# GetStatusBadge(Eval("sheet_status")) %>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="" VisibleIndex="14" Width="35px">
                        <DataItemTemplate>
                            <asp:LinkButton ID="btnViewDetails" runat="server" CommandName="ViewDetails" 
                                CommandArgument='<%# Eval("ID") %>' CssClass="gm-details-btn" ToolTip="View Details">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                            </asp:LinkButton>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="prog_id" Visible="false" VisibleIndex="15" />
                    <dx:GridViewDataTextColumn FieldName="acad_year" Visible="false" VisibleIndex="16" />
                    <dx:GridViewDataTextColumn FieldName="semester" Visible="false" VisibleIndex="17" />
                    <dx:GridViewDataTextColumn FieldName="ExamFormat" Visible="false" VisibleIndex="18" />
                    <dx:GridViewDataTextColumn FieldName="practical_percent" Visible="false" VisibleIndex="19" />
                </Columns>
            </dx:ASPxGridView>
            
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvMarksheets">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Details Popup -->
    <dx:ASPxPopupControl ID="popDetails" runat="server" AllowDragging="True" AllowResize="True" 
        CloseAction="CloseButton" CloseOnEscape="True" Height="600px" PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter" ShowFooter="True" Width="1000px" ClientInstanceName="popDetails">
        <FooterTemplate>
            <div style="padding: 8px 12px; text-align: right; border-top: 1px solid #e0e0e0;">
                <dx:ASPxButton ID="btnClosePopup" runat="server" Text="Close" AutoPostBack="false">
                    <ClientSideEvents Click="function(s, e) { popDetails.Hide(); }" />
                </dx:ASPxButton>
            </div>
        </FooterTemplate>
    </dx:ASPxPopupControl>
    
    <script type="text/javascript">
        function toggleFilters() {
            var filterRow = document.getElementById('filterRow');
            var toggleBtn = document.querySelector('.gm-filter-toggle');
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
