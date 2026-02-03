<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResidenceAllocation.aspx.cs" Inherits="COOPERP_NewScreens_ResidenceAllocation" Title="Residence Allocation - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Residence Stats - Compact Inline */
        .res-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .res-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .res-stat-item__label {
            color: #666;
        }
        .res-stat-item__value {
            font-weight: 700;
            color: #174DA4;
        }
        .res-stat-item--allocated .res-stat-item__value { color: #28a745; }
        .res-stat-item--unallocated .res-stat-item__value { color: #dc3545; }
        .res-stat-item--capacity .res-stat-item__value { color: #17a2b8; }
        
        /* Filter Toggle & Row */
        .res-filter-toggle {
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
        .res-filter-toggle:hover { background: #f8f9fa; }
        .res-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .res-filter-toggle svg { width: 12px; height: 12px; }
        .res-filter-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 16px;
            height: 16px;
            font-size: 9px;
            font-weight: 700;
            background: #dc3545;
            color: #fff;
            border-radius: 50%;
            margin-left: 4px;
        }
        .res-filter-row {
            display: none;
            gap: 8px;
            padding: 8px 10px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .res-filter-row.show { display: flex; }
        .res-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .res-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .res-filter-clear {
            padding: 4px 8px;
            font-size: 10px;
            background: #fff;
            border: 1px solid #ddd;
            color: #666;
            cursor: pointer;
        }
        .res-filter-clear:hover { background: #f0f0f0; }
        
        /* Status Badge */
        .res-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .res-status-badge--resident { background: #d4edda; color: #155724; }
        .res-status-badge--nonresident { background: #fff3cd; color: #856404; }
        
        /* Action Button Colors */
        .cd-action-popover__btn--allocate { color: #28a745 !important; }
        .cd-action-popover__btn--allocate:hover { background: #e8f5e9 !important; }
        .cd-action-popover__btn--remove { color: #dc3545 !important; }
        .cd-action-popover__btn--remove:hover { background: #ffebee !important; }
        
        /* Grid overflow fix for action popover */
        .cd-card__body,
        .cd-card,
        .dxgvCSD,
        .dxgvControl_Glass,
        .dxgvTable_Glass,
        table.dxgvTable_Glass,
        .dxgvDataRow_Glass td,
        td.cd-action-cell {
            overflow: visible !important;
        }
        
        /* Batch Operations Dropdown */
        .cd-batch-menu {
            display: none;
            position: absolute;
            top: 100%;
            right: 0;
            background: #fff;
            border: 1px solid #ddd;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            z-index: 10000;
            min-width: 200px;
        }
        .cd-batch-menu.show { display: block; }
        .cd-batch-menu__item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            font-size: 11px;
            text-decoration: none;
            color: #333;
            cursor: pointer;
        }
        .cd-batch-menu__item:hover { background: #f5f5f5; }
        .cd-batch-menu__item svg { width: 14px; height: 14px; flex-shrink: 0; }
        
        /* Allocation Section */
        .res-alloc-section {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            background: #f0f7ff;
            border: 1px solid #b8d4f0;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .res-alloc-section__label {
            font-size: 11px;
            font-weight: 500;
            color: #174DA4;
            white-space: nowrap;
        }
        .res-alloc-section select {
            padding: 4px 8px;
            font-size: 11px;
            border: 1px solid #ddd;
            min-width: 200px;
        }
        .res-alloc-section select:focus {
            border-color: #174DA4;
            outline: none;
        }
        
        /* Halls Summary Cards */
        .res-halls-row {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
            margin-bottom: 15px;
        }
        .res-hall-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            padding: 12px;
        }
        .res-hall-card__name {
            font-size: 12px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        .res-hall-card__stats {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
        }
        .res-hall-card__stat {
            text-align: center;
        }
        .res-hall-card__stat-value {
            font-size: 16px;
            font-weight: 700;
            color: #174DA4;
        }
        .res-hall-card__stat-label {
            font-size: 9px;
            color: #666;
            text-transform: uppercase;
        }
        .res-hall-card__progress {
            height: 4px;
            background: #e0e0e0;
            margin-top: 8px;
        }
        .res-hall-card__progress-bar {
            height: 100%;
            background: #28a745;
        }
        
        /* Card Styles */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .cd-card__body {
            padding: 0;
        }
        .cd-p-0 { padding: 0 !important; }
        
        /* Grid Styling */
        .res-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .res-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .res-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Print Styles */
        @media print {
            .cd-batch-ops, .res-filter-row, .res-alloc-section { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar (Compact Inline) -->
    <div class="res-stats-bar">
        <div class="res-stat-item res-stat-item--allocated">
            <span class="res-stat-item__label">Allocated:</span>
            <span class="res-stat-item__value"><asp:Literal ID="litAllocated" runat="server" Text="0" /></span>
        </div>
        <div class="res-stat-item res-stat-item--unallocated">
            <span class="res-stat-item__label">Unallocated:</span>
            <span class="res-stat-item__value"><asp:Literal ID="litUnallocated" runat="server" Text="0" /></span>
        </div>
        <div class="res-stat-item res-stat-item--capacity">
            <span class="res-stat-item__label">Total Capacity:</span>
            <span class="res-stat-item__value"><asp:Literal ID="litCapacity" runat="server" Text="0" /></span>
        </div>
        <div class="res-stat-item">
            <span class="res-stat-item__label">Registered:</span>
            <span class="res-stat-item__value"><asp:Literal ID="litRegistered" runat="server" Text="0" /></span>
        </div>
        <div style="margin-left: auto;">
            <button type="button" id="btnFilterToggle" class="res-filter-toggle" onclick="toggleFilters()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                Filters<span id="filterCount" class="res-filter-count" style="display:none;">0</span>
            </button>
        </div>
    </div>
    
    <!-- Filters (Hidden by default) -->
    <div class="res-filter-row" id="filterRow">
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="res-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
        </asp:DropDownList>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="res-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Semester 3"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="res-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- Study Year --"></asp:ListItem>
            <asp:ListItem Value="1" Text="Year 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Year 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Year 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Year 4"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="res-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width: 180px;">
            <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlResidenceStatus" runat="server" CssClass="res-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlResidenceStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- Residence Status --"></asp:ListItem>
            <asp:ListItem Value="RESIDENT" Text="Resident"></asp:ListItem>
            <asp:ListItem Value="NON RESIDENT" Text="Non-Resident"></asp:ListItem>
        </asp:DropDownList>
        <button type="button" class="res-filter-clear" onclick="clearFilters()">Clear Filters</button>
    </div>
    
    <!-- Halls Summary -->
    <div class="res-halls-row">
        <asp:Repeater ID="rptHalls" runat="server">
            <ItemTemplate>
                <div class="res-hall-card">
                    <div class="res-hall-card__name"><%# Eval("hall_name") %></div>
                    <div class="res-hall-card__stats">
                        <div class="res-hall-card__stat">
                            <div class="res-hall-card__stat-value"><%# Eval("allocated") %></div>
                            <div class="res-hall-card__stat-label">Allocated</div>
                        </div>
                        <div class="res-hall-card__stat">
                            <div class="res-hall-card__stat-value"><%# Eval("hall_capacity") %></div>
                            <div class="res-hall-card__stat-label">Capacity</div>
                        </div>
                        <div class="res-hall-card__stat">
                            <div class="res-hall-card__stat-value"><%# Eval("available") %></div>
                            <div class="res-hall-card__stat-label">Available</div>
                        </div>
                    </div>
                    <div class="res-hall-card__progress">
                        <div class="res-hall-card__progress-bar" style="width: <%# GetOccupancyPercent(Eval("allocated"), Eval("hall_capacity")) %>%;"></div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    
    <!-- Allocation Section -->
    <div class="res-alloc-section">
        <span class="res-alloc-section__label">Allocate to Hall:</span>
        <asp:DropDownList ID="ddlAllocHall" runat="server" CssClass="res-filter-select">
        </asp:DropDownList>
        <asp:Button ID="btnAllocate" runat="server" Text="Allocate Selected" CssClass="cd-btn cd-btn--primary cd-btn--sm" 
            OnClick="btnAllocate_Click" OnClientClick="return confirmAllocate();" />
        <asp:Button ID="btnRemoveAllocation" runat="server" Text="Remove Allocation" CssClass="cd-btn cd-btn--sm" 
            OnClick="btnRemoveAllocation_Click" OnClientClick="return confirmRemove();" style="background: #dc3545; color: #fff; border-color: #dc3545;" />
        <span style="border-left: 1px solid #ccc; height: 20px; margin: 0 8px;"></span>
        <asp:Button ID="btnCreateList" runat="server" Text="Create/Refresh List" CssClass="cd-btn cd-btn--sm" 
            OnClick="btnCreateList_Click" OnClientClick="return confirm('Create residence list for current semester?');" />
    </div>
    
    <!-- Card with Header Row -->
    <div class="cd-card">
        <div style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center;">
            <div style="font-size: 11px; color: #666;">
                <asp:Literal ID="litAcadYearDisplay" runat="server" /> | Sem <asp:Literal ID="litSemesterDisplay" runat="server" /> | 
                <span id="selectedCountDisplay"><asp:Literal ID="litSelectedCount" runat="server" Text="0" /></span> selected
            </div>
            <div class="cd-batch-ops">
                <button type="button" class="cd-btn cd-btn--primary cd-btn--sm" onclick="toggleBatchMenu(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Batch Actions
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div class="cd-batch-menu" id="batchMenu">
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doPrintList()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#174DA4"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                        Print Residence List
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doExport()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#28a745"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        Export to Excel
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doRefresh()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                        Refresh Grid
                    </a>
                </div>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvResidence" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="ID" Width="100%" ClientInstanceName="gvResidence"
                CssClass="res-grid">
                <SettingsBehavior AllowSelectByRowClick="true" AllowSelectSingleRowOnly="false" />
                <SettingsPager PageSize="50" AlwaysShowPager="true" Position="Bottom">
                    <PageSizeItemSettings Visible="true" Items="20, 50, 100, 200" />
                </SettingsPager>
                <Settings ShowFilterRow="true" ShowGroupPanel="false" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Styles>
                    <Header Font-Size="10px" Font-Bold="true" BackColor="#f8f9fa" ForeColor="#495057" />
                    <Row Font-Size="11px" />
                    <AlternatingRow Enabled="true" BackColor="#fafbfc" />
                </Styles>
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="True" Width="30px" SelectAllCheckboxMode="AllPages" />
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="110px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="180px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progid" Caption="Programme" Width="80px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="studyyear" Caption="Year" Width="50px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="residence_status" Caption="Residence" Width="100px">
                        <DataItemTemplate>
                            <span class='res-status-badge res-status-badge--<%# GetResidenceClass(Eval("residence_status").ToString()) %>'>
                                <%# Eval("residence_status") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="hall_name" Caption="Hall" Width="150px" />
                    <dx:GridViewDataTextColumn FieldName="room_id" Caption="Room" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="regstatus" Caption="Reg Status" Width="90px" />
                    <dx:GridViewDataTextColumn VisibleIndex="99" Caption=" " Width="40px" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnAllocateSingle" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--allocate"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnAllocateSingle_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                                                Assign Hall
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnRemoveSingle" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--remove"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnRemoveSingle_Click"
                                                OnClientClick="return confirm('Remove residence allocation?');">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                                Remove Allocation
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnViewProfile" runat="server" CssClass="cd-action-popover__btn"
                                                CommandArgument='<%# Eval("regno") %>' OnClick="btnViewProfile_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                                View Profile
                                            </asp:LinkButton>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" CssClass="cd-action-cell" />
                    </dx:GridViewDataTextColumn>
                </Columns>
            </dx:ASPxGridView>
            <dx:ASPxGridViewExporter ID="gveResidence" runat="server" GridViewID="gvResidence" ExportedRowType="All">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Assign Hall Popup -->
    <dx:ASPxPopupControl ID="popAssignHall" runat="server" ClientInstanceName="popAssignHall"
        Width="400px" HeaderText="Assign Hall" Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" ShowCloseButton="true">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Bold="true" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px;">
                    <asp:HiddenField ID="hfAssignId" runat="server" />
                    <table style="width: 100%;">
                        <tr>
                            <td style="width: 100px; padding: 8px;">Select Hall:</td>
                            <td style="padding: 8px;">
                                <asp:DropDownList ID="ddlPopupHall" runat="server" CssClass="res-filter-select" style="width: 100%;">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 8px;">Room (Optional):</td>
                            <td style="padding: 8px;">
                                <asp:TextBox ID="txtRoomId" runat="server" CssClass="res-filter-select" style="width: 100%;" placeholder="e.g., A101"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding: 8px; text-align: right;">
                                <asp:Button ID="btnDoAssign" runat="server" Text="Assign" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="btnDoAssign_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Message Popup -->
    <dx:ASPxPopupControl ID="popMessage" runat="server" ClientInstanceName="popMessage"
        Width="400px" HeaderText="Message" Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" ShowCloseButton="true">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Bold="true" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 20px; text-align: center;">
                    <asp:Literal ID="litMessage" runat="server" />
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Hidden buttons for postback -->
    <asp:Button ID="btnPrintList" runat="server" OnClick="btnPrintList_Click" style="display:none;" />
    <asp:Button ID="btnExport" runat="server" OnClick="btnExport_Click" style="display:none;" />
    <asp:Button ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" style="display:none;" />
    
    <script type="text/javascript">
        // Toggle batch menu
        function toggleBatchMenu(event) {
            event.stopPropagation();
            if (typeof closeAllActionPopovers === 'function') closeAllActionPopovers();
            document.getElementById('batchMenu').classList.toggle('show');
        }
        
        // Close batch menu when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.cd-batch-ops')) {
                var menu = document.getElementById('batchMenu');
                if (menu) menu.classList.remove('show');
            }
        });
        
        // Confirm allocate
        function confirmAllocate() {
            var count = gvResidence.GetSelectedRowCount();
            if (count === 0) { 
                alert('Please select at least one student.'); 
                return false; 
            }
            return confirm('Allocate ' + count + ' student(s) to selected hall?');
        }
        
        // Confirm remove
        function confirmRemove() {
            var count = gvResidence.GetSelectedRowCount();
            if (count === 0) { 
                alert('Please select at least one student.'); 
                return false; 
            }
            return confirm('Remove allocation for ' + count + ' student(s)?');
        }
        
        // Batch actions
        function doPrintList() {
            document.getElementById('<%= btnPrintList.ClientID %>').click();
        }
        
        function doExport() {
            document.getElementById('<%= btnExport.ClientID %>').click();
        }
        
        function doRefresh() {
            document.getElementById('<%= btnRefresh.ClientID %>').click();
        }
        
        // Filter toggle
        function toggleFilters() {
            var row = document.getElementById('filterRow');
            var btn = document.getElementById('btnFilterToggle');
            if (row.classList.contains('show')) {
                row.classList.remove('show');
                btn.classList.remove('active');
            } else {
                row.classList.add('show');
                btn.classList.add('active');
            }
        }
        
        // Count active filters
        function updateFilterCount() {
            var count = 0;
            var ddls = ['<%= ddlStudyYear.ClientID %>', '<%= ddlProgramme.ClientID %>', '<%= ddlResidenceStatus.ClientID %>'];
            ddls.forEach(function(id) {
                var el = document.getElementById(id);
                if (el && el.value !== '') count++;
            });
            var badge = document.getElementById('filterCount');
            var btn = document.getElementById('btnFilterToggle');
            var row = document.getElementById('filterRow');
            if (count > 0) {
                badge.textContent = count;
                badge.style.display = 'inline-flex';
                row.classList.add('show');
                btn.classList.add('active');
            } else {
                badge.style.display = 'none';
            }
        }
        
        // Clear filters
        function clearFilters() {
            document.getElementById('<%= ddlStudyYear.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlProgramme.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlResidenceStatus.ClientID %>').selectedIndex = 0;
            __doPostBack('<%= ddlStudyYear.UniqueID %>', '');
        }
        
        // On page load
        document.addEventListener('DOMContentLoaded', function() {
            updateFilterCount();
        });
    </script>
</asp:Content>
