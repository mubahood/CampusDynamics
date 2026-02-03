<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentsPromotion.aspx.cs" Inherits="COOPERP_NewScreens_StudentsPromotion" Title="Student Promotions - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Promotion Stats - Compact Inline */
        .promo-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .promo-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .promo-stat-item__label {
            color: #666;
        }
        .promo-stat-item__value {
            font-weight: 700;
            color: #174DA4;
        }
        .promo-stat-item--continuing .promo-stat-item__value { color: #28a745; }
        .promo-stat-item--completing .promo-stat-item__value { color: #17a2b8; }
        .promo-stat-item--other .promo-stat-item__value { color: #6c757d; }
        
        /* Filter Toggle & Row */
        .promo-filter-toggle {
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
        .promo-filter-toggle:hover { background: #f8f9fa; }
        .promo-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .promo-filter-toggle svg { width: 12px; height: 12px; }
        .promo-filter-count {
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
        .promo-filter-row {
            display: none;
            gap: 8px;
            padding: 8px 10px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .promo-filter-row.show { display: flex; }
        .promo-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .promo-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .promo-filter-clear {
            padding: 4px 8px;
            font-size: 10px;
            background: #fff;
            border: 1px solid #ddd;
            color: #666;
            cursor: pointer;
        }
        .promo-filter-clear:hover { background: #f0f0f0; }
        
        /* Status Badge */
        .promo-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .promo-status-badge--unregistered { background: #fff3cd; color: #856404; }
        .promo-status-badge--registered { background: #d4edda; color: #155724; }
        .promo-status-badge--cleared { background: #cce5ff; color: #004085; }
        .promo-status-badge--halted { background: #f5c6cb; color: #721c24; }
        .promo-status-badge--deadyear { background: #d6d8db; color: #1b1e21; }
        .promo-status-badge--late { background: #e2e3e5; color: #383d41; }
        .promo-status-badge--discontinued { background: #f8d7da; color: #721c24; }
        
        /* Completion Status Badge */
        .promo-comp-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
        }
        .promo-comp-badge--continuing { background: #d4edda; color: #155724; }
        .promo-comp-badge--completing { background: #cce5ff; color: #004085; }
        .promo-comp-badge--completed { background: #e2e3e5; color: #383d41; }
        
        /* Action Button Colors */
        .cd-action-popover__btn--promote { color: #28a745 !important; }
        .cd-action-popover__btn--promote:hover { background: #e8f5e9 !important; }
        .cd-action-popover__btn--delete { color: #dc3545 !important; }
        .cd-action-popover__btn--delete:hover { background: #ffebee !important; }
        
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
        
        /* Promotion Settings Section */
        .promo-settings-section {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            background: #f0f7ff;
            border: 1px solid #b8d4f0;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .promo-settings-section__label {
            font-size: 11px;
            font-weight: 500;
            color: #174DA4;
            white-space: nowrap;
        }
        .promo-settings-section select {
            padding: 4px 8px;
            font-size: 11px;
            border: 1px solid #ddd;
            min-width: 120px;
        }
        .promo-settings-section select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .promo-settings-section__checkbox {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            color: #333;
        }
        .promo-settings-section__checkbox input {
            margin: 0;
        }
        .promo-arrow {
            color: #174DA4;
            font-size: 16px;
            font-weight: bold;
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
        .promo-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .promo-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .promo-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Print Styles */
        @media print {
            .promo-batch-bar, .promo-filter-row, .promo-settings-section { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar (Compact Inline) -->
    <div class="promo-stats-bar">
        <div class="promo-stat-item promo-stat-item--continuing">
            <span class="promo-stat-item__label">Continuing:</span>
            <span class="promo-stat-item__value"><asp:Literal ID="litContinuing" runat="server" Text="0" /></span>
        </div>
        <div class="promo-stat-item promo-stat-item--completing">
            <span class="promo-stat-item__label">Completing:</span>
            <span class="promo-stat-item__value"><asp:Literal ID="litCompleting" runat="server" Text="0" /></span>
        </div>
        <div class="promo-stat-item promo-stat-item--other">
            <span class="promo-stat-item__label">Other:</span>
            <span class="promo-stat-item__value"><asp:Literal ID="litOther" runat="server" Text="0" /></span>
        </div>
        <div class="promo-stat-item">
            <span class="promo-stat-item__label">Total:</span>
            <span class="promo-stat-item__value"><asp:Literal ID="litTotal" runat="server" Text="0" /></span>
        </div>
        <div style="margin-left: auto;">
            <button type="button" id="btnFilterToggle" class="promo-filter-toggle" onclick="toggleFilters()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                Filters<span id="filterCount" class="promo-filter-count" style="display:none;">0</span>
            </button>
        </div>
    </div>
    
    <!-- Filters (Hidden by default) -->
    <div class="promo-filter-row" id="filterRow">
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="promo-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
        </asp:DropDownList>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="promo-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Semester 3"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="promo-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All Study Years --"></asp:ListItem>
            <asp:ListItem Value="1" Text="Year 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Year 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Year 3"></asp:ListItem>
            <asp:ListItem Value="4" Text="Year 4"></asp:ListItem>
            <asp:ListItem Value="5" Text="Year 5"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="promo-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width: 180px;">
            <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="promo-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlIntake_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All Intakes --"></asp:ListItem>
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
        <asp:DropDownList ID="ddlCompletionStatus" runat="server" CssClass="promo-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCompletionStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All --"></asp:ListItem>
            <asp:ListItem Value="CONTINUING" Text="Continuing"></asp:ListItem>
            <asp:ListItem Value="COMPLETING" Text="Completing"></asp:ListItem>
        </asp:DropDownList>
        <button type="button" class="promo-filter-clear" onclick="clearFilters()">Clear Filters</button>
    </div>
    
    <!-- Promotion Settings Section -->
    <div class="promo-settings-section">
        <span class="promo-settings-section__label">Promote To:</span>
        <asp:DropDownList ID="ddlNewAcadYear" runat="server" CssClass="promo-filter-select" style="min-width: 130px;">
        </asp:DropDownList>
        <asp:DropDownList ID="ddlNewSemester" runat="server" CssClass="promo-filter-select" style="min-width: 100px;">
            <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Semester 3"></asp:ListItem>
        </asp:DropDownList>
        <label class="promo-settings-section__checkbox">
            <asp:CheckBox ID="chkIncrementYear" runat="server" />
            Increment Study Year
        </label>
        <asp:Button ID="btnPromoteSelected" runat="server" Text="Promote Selected" CssClass="cd-btn cd-btn--primary cd-btn--sm" 
            OnClick="btnPromoteSelected_Click" OnClientClick="return confirmPromote();" />
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
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchPromote()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#28a745"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path></svg>
                        Promote Selected
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchDelete()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#dc3545"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                        Delete Selected
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doRefresh()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                        Refresh Grid
                    </a>
                </div>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvPromotion" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="ID" Width="100%" ClientInstanceName="gvPromotion"
                OnHtmlDataCellPrepared="gvPromotion_HtmlDataCellPrepared"
                CssClass="promo-grid">
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
                    <dx:GridViewDataTextColumn FieldName="progcode" Caption="Programme" Width="80px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="studyyear" Caption="Year" Width="50px" />
                    <dx:GridViewDataTextColumn FieldName="regstatus" Caption="Reg Status" Width="100px">
                        <DataItemTemplate>
                            <span class='promo-status-badge promo-status-badge--<%# GetStatusClass(Eval("regstatus").ToString()) %>'>
                                <%# Eval("regstatus") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="completion_status" Caption="Completion" Width="100px">
                        <DataItemTemplate>
                            <span class='promo-comp-badge promo-comp-badge--<%# GetCompletionClass(Eval("completion_status").ToString()) %>'>
                                <%# Eval("completion_status") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="residence_status" Caption="Residence" Width="90px" />
                    <dx:GridViewDataTextColumn VisibleIndex="99" Caption=" " Width="40px" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item" style='<%# Eval("completion_status").ToString() == "CONTINUING" ? "" : "display:none;" %>'>
                                            <asp:LinkButton ID="btnPromote" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--promote"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnPromote_Click"
                                                OnClientClick="return confirm('Promote this student to the new semester?');">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path></svg>
                                                Promote
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--delete"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnDelete_Click"
                                                OnClientClick="return confirm('Delete this registration record?');">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                                Delete Record
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
    
    <!-- Hidden buttons for postback -->
    <asp:Button ID="btnBatchDelete" runat="server" OnClick="btnBatchDelete_Click" style="display:none;" />
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
        
        // Confirm promote
        function confirmPromote() {
            var count = gvPromotion.GetSelectedRowCount();
            if (count === 0) { 
                alert('Please select at least one student.'); 
                return false; 
            }
            return confirm('Promote ' + count + ' student(s) to the new semester?');
        }
        
        // Batch actions
        function doBatchPromote() {
            var count = gvPromotion.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one student.'); return; }
            if (confirm('Promote ' + count + ' student(s) to the new semester?')) {
                document.getElementById('<%= btnPromoteSelected.ClientID %>').click();
            }
        }
        
        function doBatchDelete() {
            var count = gvPromotion.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one student.'); return; }
            if (confirm('Delete ' + count + ' registration record(s)?')) {
                document.getElementById('<%= btnBatchDelete.ClientID %>').click();
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
            var ddls = ['<%= ddlStudyYear.ClientID %>', '<%= ddlProgramme.ClientID %>', '<%= ddlIntake.ClientID %>', '<%= ddlCompletionStatus.ClientID %>'];
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
            document.getElementById('<%= ddlIntake.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlCompletionStatus.ClientID %>').selectedIndex = 0;
            __doPostBack('<%= ddlStudyYear.UniqueID %>', '');
        }
        
        // On page load
        document.addEventListener('DOMContentLoaded', function() {
            updateFilterCount();
        });
    </script>
</asp:Content>
