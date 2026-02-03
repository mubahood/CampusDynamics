<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentsSpecialisation.aspx.cs" Inherits="COOPERP_NewScreens_StudentsSpecialisation" Title="Student Specialisations - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Specialisation Stats - Compact Inline */
        .spec-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .spec-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .spec-stat-item__label {
            color: #666;
        }
        .spec-stat-item__value {
            font-weight: 700;
            color: #174DA4;
        }
        .spec-stat-item--assigned .spec-stat-item__value { color: #28a745; }
        .spec-stat-item--unassigned .spec-stat-item__value { color: #dc3545; }
        
        /* Filter Toggle & Row */
        .spec-filter-toggle {
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
        .spec-filter-toggle:hover { background: #f8f9fa; }
        .spec-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .spec-filter-toggle svg { width: 12px; height: 12px; }
        .spec-filter-count {
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
        .spec-filter-row {
            display: none;
            gap: 8px;
            padding: 8px 10px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .spec-filter-row.show { display: flex; }
        .spec-filter-row__label {
            font-size: 10px;
            color: #666;
            font-weight: 500;
        }
        .spec-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .spec-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .spec-filter-clear {
            padding: 4px 8px;
            font-size: 10px;
            background: #fff;
            border: 1px solid #ddd;
            color: #666;
            cursor: pointer;
        }
        .spec-filter-clear:hover { background: #f0f0f0; }
        
        /* Specialisation Badge */
        .spec-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            max-width: 180px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .spec-badge--assigned { background: #d4edda; color: #155724; }
        .spec-badge--unassigned { background: #fff3cd; color: #856404; }
        
        /* Status Badge */
        .stud-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .stud-status-badge--active { background: #d4edda; color: #155724; }
        .stud-status-badge--admitted { background: #cce5ff; color: #004085; }
        .stud-status-badge--graduated { background: #e2e3e5; color: #383d41; }
        .stud-status-badge--discontinued { background: #f8d7da; color: #721c24; }
        .stud-status-badge--suspended { background: #fff3cd; color: #856404; }
        
        /* Action Button Colors */
        .cd-action-popover__btn--assign { color: #28a745 !important; }
        .cd-action-popover__btn--assign:hover { background: #e8f5e9 !important; }
        .cd-action-popover__btn--change { color: #17a2b8 !important; }
        .cd-action-popover__btn--change:hover { background: #e3f2fd !important; }
        .cd-action-popover__btn--clear { color: #dc3545 !important; }
        .cd-action-popover__btn--clear:hover { background: #ffebee !important; }
        
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
        
        /* Assign Specialisation Section */
        .spec-assign-section {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: #f0f7ff;
            border: 1px solid #b8d4f0;
            margin-bottom: 10px;
        }
        .spec-assign-section__label {
            font-size: 11px;
            font-weight: 500;
            color: #174DA4;
            white-space: nowrap;
        }
        .spec-assign-section select {
            padding: 4px 8px;
            font-size: 11px;
            border: 1px solid #ddd;
            min-width: 250px;
            max-width: 350px;
        }
        .spec-assign-section select:focus {
            border-color: #174DA4;
            outline: none;
        }
        
        /* Card Styles - simplified without header */
        .cd-card {
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .cd-card__body {
            padding: 0;
        }
        .cd-p-0 { padding: 0 !important; }
        
        /* Grid Styling */
        .spec-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .spec-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .spec-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Print Styles */
        @media print {
            .spec-batch-bar, .spec-filter-row, .spec-assign-section { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar (Compact Inline) -->
    <div class="spec-stats-bar">
        <div class="spec-stat-item spec-stat-item--assigned">
            <span class="spec-stat-item__label">Assigned:</span>
            <span class="spec-stat-item__value"><asp:Literal ID="litAssigned" runat="server" Text="0" /></span>
        </div>
        <div class="spec-stat-item spec-stat-item--unassigned">
            <span class="spec-stat-item__label">Unassigned:</span>
            <span class="spec-stat-item__value"><asp:Literal ID="litUnassigned" runat="server" Text="0" /></span>
        </div>
        <div class="spec-stat-item">
            <span class="spec-stat-item__label">Total:</span>
            <span class="spec-stat-item__value"><asp:Literal ID="litTotal" runat="server" Text="0" /></span>
        </div>
        <div style="margin-left: auto;">
            <button type="button" id="btnFilterToggle" class="spec-filter-toggle" onclick="toggleFilters()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                Filters<span id="filterCount" class="spec-filter-count" style="display:none;">0</span>
            </button>
        </div>
    </div>
    
    <!-- Filters (Hidden by default) -->
    <div class="spec-filter-row" id="filterRow">
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="spec-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width: 220px;">
            <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="spec-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlEntryYear_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- Entry Year --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlSession" runat="server" CssClass="spec-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All Sessions --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlSpecStatus" runat="server" CssClass="spec-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSpecStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --"></asp:ListItem>
            <asp:ListItem Value="assigned" Text="Assigned"></asp:ListItem>
            <asp:ListItem Value="unassigned" Text="Unassigned"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlStudStatus" runat="server" CssClass="spec-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All Statuses --"></asp:ListItem>
            <asp:ListItem Value="ACTIVE" Text="Active"></asp:ListItem>
            <asp:ListItem Value="ADMITTED" Text="Admitted"></asp:ListItem>
            <asp:ListItem Value="GRADUATED" Text="Graduated"></asp:ListItem>
            <asp:ListItem Value="DISCONTINUED" Text="Discontinued"></asp:ListItem>
        </asp:DropDownList>
        <button type="button" class="spec-filter-clear" onclick="clearFilters()">Clear Filters</button>
    </div>
    
    <!-- Specialisation Assignment Section -->
    <div class="spec-assign-section">
        <span class="spec-assign-section__label">Assign Specialisation:</span>
        <asp:DropDownList ID="ddlNewSpecialisation" runat="server" CssClass="spec-filter-select" style="min-width: 280px;">
            <asp:ListItem Value="" Text="-- Select Specialisation --"></asp:ListItem>
        </asp:DropDownList>
        <asp:Button ID="btnAssignSelected" runat="server" Text="Assign to Selected" CssClass="cd-btn cd-btn--primary cd-btn--sm" 
            OnClick="btnAssignSelected_Click" OnClientClick="return confirmAssign();" />
    </div>
    
    <!-- Card with Header Row -->
    <div class="cd-card">
        <div style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center;">
            <div style="font-size: 11px; color: #666;">
                <asp:Literal ID="litProgrammeDisplay" runat="server" Text="All Programmes" /> | 
                <span id="selectedCountDisplay"><asp:Literal ID="litSelectedCount" runat="server" Text="0" /></span> selected
            </div>
            <div class="cd-batch-ops">
                <button type="button" class="cd-btn cd-btn--primary cd-btn--sm" onclick="toggleBatchMenu(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Batch Actions
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div class="cd-batch-menu" id="batchMenu">
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchAssign()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#28a745"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        Assign Specialisation
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchClear()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#dc3545"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        Clear Specialisation
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doRefresh()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                        Refresh Grid
                    </a>
                </div>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvStudents" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="regno" Width="100%" ClientInstanceName="gvStudents"
                OnHtmlDataCellPrepared="gvStudents_HtmlDataCellPrepared"
                CssClass="spec-grid">
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
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="120px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="180px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progid" Caption="Programme" Width="80px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="entryyear" Caption="Entry Year" Width="70px" />
                    <dx:GridViewDataTextColumn FieldName="studsesion" Caption="Session" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="spec_name" Caption="Specialisation" Width="180px">
                        <DataItemTemplate>
                            <%# GetSpecialisationBadge(Eval("specialisation"), Eval("spec_name")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="new_status" Caption="Status" Width="80px">
                        <DataItemTemplate>
                            <span class='stud-status-badge stud-status-badge--<%# GetStatusClass(Eval("new_status").ToString()) %>'>
                                <%# Eval("new_status") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn VisibleIndex="99" Caption=" " Width="40px" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnAssign" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--assign"
                                                CommandArgument='<%# Eval("regno") %>' OnClick="btnAssign_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                                Assign / Change
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item" style='<%# IsSpecAssigned(Eval("specialisation")) ? "" : "display:none;" %>'>
                                            <asp:LinkButton ID="btnClear" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--clear"
                                                CommandArgument='<%# Eval("regno") %>' OnClick="btnClearSpec_Click"
                                                OnClientClick="return confirm('Clear specialisation for this student?');">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                                Clear Specialisation
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
        </div>
    </div>
    
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
    
    <!-- Assign Single Student Popup -->
    <dx:ASPxPopupControl ID="popAssign" runat="server" ClientInstanceName="popAssign"
        Width="450px" HeaderText="Assign Specialisation" Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" ShowCloseButton="true">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Bold="true" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px;">
                    <asp:HiddenField ID="hdnStudentRegNo" runat="server" />
                    <div style="margin-bottom: 10px;">
                        <label style="font-size: 11px; color: #666; display: block; margin-bottom: 4px;">Student:</label>
                        <asp:Label ID="lblStudentName" runat="server" Font-Bold="true" />
                    </div>
                    <div style="margin-bottom: 10px;">
                        <label style="font-size: 11px; color: #666; display: block; margin-bottom: 4px;">Programme:</label>
                        <asp:Label ID="lblStudentProg" runat="server" />
                    </div>
                    <div style="margin-bottom: 10px;">
                        <label style="font-size: 11px; color: #666; display: block; margin-bottom: 4px;">Current Specialisation:</label>
                        <asp:Label ID="lblCurrentSpec" runat="server" />
                    </div>
                    <div style="margin-bottom: 15px;">
                        <label style="font-size: 11px; color: #666; display: block; margin-bottom: 4px;">New Specialisation:</label>
                        <asp:DropDownList ID="ddlPopupSpec" runat="server" Width="100%" style="padding: 6px; font-size: 12px;">
                        </asp:DropDownList>
                    </div>
                    <div style="text-align: right;">
                        <asp:Button ID="btnSaveSpec" runat="server" Text="Save" CssClass="cd-btn cd-btn--primary" OnClick="btnSaveSpec_Click" />
                        <button type="button" class="cd-btn" onclick="popAssign.Hide();">Cancel</button>
                    </div>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Hidden buttons for postback -->
    <asp:Button ID="btnBatchClear" runat="server" OnClick="btnBatchClear_Click" style="display:none;" />
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
        
        // Confirm assign
        function confirmAssign() {
            var count = gvStudents.GetSelectedRowCount();
            if (count === 0) { 
                alert('Please select at least one student.'); 
                return false; 
            }
            var ddl = document.getElementById('<%= ddlNewSpecialisation.ClientID %>');
            if (!ddl.value) {
                alert('Please select a specialisation to assign.');
                return false;
            }
            return confirm('Assign specialisation to ' + count + ' student(s)?');
        }
        
        // Batch actions
        function doBatchAssign() {
            var count = gvStudents.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one student.'); return; }
            var ddl = document.getElementById('<%= ddlNewSpecialisation.ClientID %>');
            if (!ddl.value) {
                alert('Please select a specialisation to assign.');
                return;
            }
            if (confirm('Assign specialisation to ' + count + ' student(s)?')) {
                document.getElementById('<%= btnAssignSelected.ClientID %>').click();
            }
        }
        
        function doBatchClear() {
            var count = gvStudents.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one student.'); return; }
            if (confirm('Clear specialisation for ' + count + ' student(s)?')) {
                document.getElementById('<%= btnBatchClear.ClientID %>').click();
            }
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
            var ddls = ['<%= ddlProgramme.ClientID %>', '<%= ddlEntryYear.ClientID %>', '<%= ddlSession.ClientID %>', '<%= ddlSpecStatus.ClientID %>', '<%= ddlStudStatus.ClientID %>'];
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
            document.getElementById('<%= ddlProgramme.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlEntryYear.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlSession.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlSpecStatus.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlStudStatus.ClientID %>').selectedIndex = 0;
            __doPostBack('<%= ddlProgramme.UniqueID %>', '');
        }
        
        // On page load
        document.addEventListener('DOMContentLoaded', function() {
            updateFilterCount();
        });
    </script>
</asp:Content>
