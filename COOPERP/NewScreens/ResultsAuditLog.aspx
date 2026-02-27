<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsAuditLog.aspx.cs" Inherits="COOPERP_NewScreens_ResultsAuditLog" Title="Results Audit Log - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* ===============================================
           RESULTS AUDIT LOG - STYLES
           Prefix: ral- (Results Audit Log)
        =============================================== */
        
        .ral-container { padding: 0; font-size: 11px; }
        
        /* Page Header */
        .ral-page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 12px;
            border-bottom: 2px solid #174DA4;
        }
        .ral-page-header__title { font-size: 16px; font-weight: 700; color: #1a1a2e; margin: 0; }
        .ral-page-header__subtitle { font-size: 10px; color: #6c757d; margin-top: 2px; }
        
        /* Stats Row */
        .ral-stats-row {
            display: flex;
            gap: 12px;
            margin-bottom: 15px;
        }
        .ral-stat-card {
            flex: 1;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 14px 18px;
            position: relative;
            overflow: hidden;
        }
        .ral-stat-card::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 4px;
            height: 100%;
        }
        .ral-stat-card--total::before { background: #174DA4; }
        .ral-stat-card--today::before { background: #28a745; }
        .ral-stat-card--week::before { background: #ffc107; }
        .ral-stat-card--critical::before { background: #dc3545; }
        
        .ral-stat-card__value { font-size: 22px; font-weight: 700; line-height: 1; margin-bottom: 4px; }
        .ral-stat-card--total .ral-stat-card__value { color: #174DA4; }
        .ral-stat-card--today .ral-stat-card__value { color: #28a745; }
        .ral-stat-card--week .ral-stat-card__value { color: #d39e00; }
        .ral-stat-card--critical .ral-stat-card__value { color: #dc3545; }
        .ral-stat-card__label { font-size: 10px; color: #6c757d; text-transform: uppercase; }
        
        /* Filter Panel */
        .ral-filter-panel {
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 12px 15px;
            margin-bottom: 12px;
        }
        .ral-filter-row {
            display: flex;
            gap: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .ral-filter-group {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .ral-filter-group label {
            font-size: 9px;
            color: #6c757d;
            text-transform: uppercase;
            font-weight: 600;
        }
        .ral-filter-select, .ral-filter-input {
            padding: 6px 10px;
            font-size: 11px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            background: #fff;
            min-width: 140px;
        }
        .ral-filter-select:focus, .ral-filter-input:focus {
            border-color: #174DA4;
            outline: none;
        }
        
        /* Buttons */
        .ral-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            font-size: 11px;
            font-weight: 500;
            border: 1px solid transparent;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .ral-btn svg { width: 12px; height: 12px; }
        .ral-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .ral-btn--primary:hover { background: #0d3a7d; }
        .ral-btn--outline { background: #fff; color: #495057; border-color: #ced4da; }
        .ral-btn--outline:hover { background: #f8f9fa; }
        .ral-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; }
        .ral-btn--danger:hover { background: #c82333; }
        
        /* Grid Card */
        .ral-grid-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            overflow: hidden;
        }
        .ral-grid-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 15px;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
        }
        .ral-grid-header__title { font-size: 12px; font-weight: 600; }
        .ral-grid-header__actions { display: flex; gap: 6px; }
        
        /* Grid Styles */
        .ral-grid { border-collapse: collapse; width: 100%; }
        .ral-grid .dxgvHeader td {
            background: linear-gradient(180deg, #f8f9fa 0%, #e9ecef 100%) !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            color: #495057 !important;
            border-bottom: 2px solid #174DA4 !important;
        }
        .ral-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .ral-grid .dxgvDataRow:hover td { background: #e8f4fd !important; }
        
        /* Action Type Badges */
        .ral-action-badge {
            display: inline-block;
            padding: 3px 10px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            border-radius: 12px;
        }
        .ral-action-badge--approve { background: #cce5ff; color: #004085; }
        .ral-action-badge--release { background: #d4edda; color: #155724; }
        .ral-action-badge--hold { background: #f8d7da; color: #721c24; }
        .ral-action-badge--edit { background: #fff3cd; color: #856404; }
        .ral-action-badge--create { background: #d1ecf1; color: #0c5460; }
        .ral-action-badge--delete { background: #f5c6cb; color: #721c24; }
        .ral-action-badge--unhold { background: #e2d5f1; color: #432874; }
        
        /* Severity Indicators */
        .ral-severity {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 10px;
        }
        .ral-severity__dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }
        .ral-severity--low .ral-severity__dot { background: #28a745; }
        .ral-severity--medium .ral-severity__dot { background: #ffc107; }
        .ral-severity--high .ral-severity__dot { background: #fd7e14; }
        .ral-severity--critical .ral-severity__dot { background: #dc3545; }
        
        /* User Info Cell */
        .ral-user-info { display: flex; flex-direction: column; gap: 2px; }
        .ral-user-info__name { font-weight: 600; color: #174DA4; }
        .ral-user-info__role { font-size: 9px; color: #6c757d; }
        
        /* Details Expandable */
        .ral-details-toggle {
            background: none;
            border: none;
            color: #174DA4;
            font-size: 10px;
            cursor: pointer;
            text-decoration: underline;
        }
        .ral-details-toggle:hover { color: #0d3a7d; }
        
        /* Timeline View (alternate) */
        .ral-timeline {
            padding: 15px;
            max-height: 600px;
            overflow-y: auto;
        }
        .ral-timeline-item {
            display: flex;
            gap: 15px;
            padding: 12px 0;
            border-bottom: 1px solid #e9ecef;
        }
        .ral-timeline-item:last-child { border-bottom: none; }
        .ral-timeline-item__marker {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .ral-timeline-item__marker svg { width: 18px; height: 18px; color: #fff; }
        .ral-timeline-item__marker--approve { background: #17a2b8; }
        .ral-timeline-item__marker--release { background: #28a745; }
        .ral-timeline-item__marker--hold { background: #dc3545; }
        .ral-timeline-item__marker--edit { background: #ffc107; }
        .ral-timeline-item__content { flex: 1; }
        .ral-timeline-item__title { font-weight: 600; margin-bottom: 3px; }
        .ral-timeline-item__meta { font-size: 10px; color: #6c757d; }
        .ral-timeline-item__details { font-size: 11px; margin-top: 5px; color: #495057; }
        
        /* View Toggle */
        .ral-view-toggle {
            display: flex;
            border: 1px solid #ced4da;
            border-radius: 4px;
            overflow: hidden;
        }
        .ral-view-toggle__btn {
            padding: 5px 12px;
            font-size: 10px;
            border: none;
            background: #fff;
            color: #495057;
            cursor: pointer;
        }
        .ral-view-toggle__btn:not(:last-child) { border-right: 1px solid #ced4da; }
        .ral-view-toggle__btn.active { background: #174DA4; color: #fff; }
        .ral-view-toggle__btn:hover:not(.active) { background: #f8f9fa; }
        
        /* Message */
        .ral-message {
            padding: 10px 14px;
            border-radius: 6px;
            font-size: 11px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .ral-message svg { width: 16px; height: 16px; }
        .ral-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .ral-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .ral-message--info { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="ral-container">
        <!-- Page Header -->
        <div class="ral-page-header">
            <div>
                <h1 class="ral-page-header__title">Results Audit Log</h1>
                <p class="ral-page-header__subtitle">Complete history of all results actions - approvals, releases, holds, and modifications</p>
            </div>
            <div style="display: flex; gap: 8px;">
                <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/COOPERP/NewScreens/ResultsRelease.aspx" CssClass="ral-btn ral-btn--outline">
                    ← Back to Results
                </asp:HyperLink>
                <asp:Button ID="btnExport" runat="server" Text="📊 Export Log" CssClass="ral-btn ral-btn--primary" OnClick="btnExport_Click" />
            </div>
        </div>
        
        <!-- Stats Row -->
        <div class="ral-stats-row">
            <div class="ral-stat-card ral-stat-card--total">
                <div class="ral-stat-card__value"><asp:Literal ID="litTotalActions" runat="server">0</asp:Literal></div>
                <div class="ral-stat-card__label">Total Actions</div>
            </div>
            <div class="ral-stat-card ral-stat-card--today">
                <div class="ral-stat-card__value"><asp:Literal ID="litTodayActions" runat="server">0</asp:Literal></div>
                <div class="ral-stat-card__label">Today's Actions</div>
            </div>
            <div class="ral-stat-card ral-stat-card--week">
                <div class="ral-stat-card__value"><asp:Literal ID="litWeekActions" runat="server">0</asp:Literal></div>
                <div class="ral-stat-card__label">This Week</div>
            </div>
            <div class="ral-stat-card ral-stat-card--critical">
                <div class="ral-stat-card__value"><asp:Literal ID="litCriticalActions" runat="server">0</asp:Literal></div>
                <div class="ral-stat-card__label">Critical Changes</div>
            </div>
        </div>
        
        <!-- Filter Panel -->
        <div class="ral-filter-panel">
            <div class="ral-filter-row">
                <div class="ral-filter-group">
                    <label>Date From</label>
                    <dx:ASPxDateEdit ID="dtFrom" runat="server" Width="130px" DisplayFormatString="dd-MMM-yyyy">
                        <CalendarProperties />
                    </dx:ASPxDateEdit>
                </div>
                <div class="ral-filter-group">
                    <label>Date To</label>
                    <dx:ASPxDateEdit ID="dtTo" runat="server" Width="130px" DisplayFormatString="dd-MMM-yyyy">
                        <CalendarProperties />
                    </dx:ASPxDateEdit>
                </div>
                <div class="ral-filter-group">
                    <label>Action Type</label>
                    <asp:DropDownList ID="ddlActionType" runat="server" CssClass="ral-filter-select">
                        <asp:ListItem Value="" Text="All Actions"></asp:ListItem>
                        <asp:ListItem Value="APPROVE" Text="Approval"></asp:ListItem>
                        <asp:ListItem Value="RELEASE" Text="Release"></asp:ListItem>
                        <asp:ListItem Value="HOLD" Text="Hold"></asp:ListItem>
                        <asp:ListItem Value="UNHOLD" Text="Unhold"></asp:ListItem>
                        <asp:ListItem Value="EDIT" Text="Edit/Update"></asp:ListItem>
                        <asp:ListItem Value="CREATE" Text="Create"></asp:ListItem>
                        <asp:ListItem Value="DELETE" Text="Delete"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="ral-filter-group">
                    <label>User</label>
                    <asp:DropDownList ID="ddlUser" runat="server" CssClass="ral-filter-select">
                        <asp:ListItem Value="" Text="All Users"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="ral-filter-group">
                    <label>Programme</label>
                    <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="ral-filter-select">
                        <asp:ListItem Value="" Text="All Programmes"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="ral-filter-group">
                    <label>Search</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="ral-filter-input" placeholder="Student/Course..."></asp:TextBox>
                </div>
                <div class="ral-filter-group">
                    <label>&nbsp;</label>
                    <asp:Button ID="btnFilter" runat="server" Text="🔍 Filter" CssClass="ral-btn ral-btn--primary" OnClick="btnFilter_Click" />
                </div>
                <div class="ral-filter-group">
                    <label>&nbsp;</label>
                    <asp:Button ID="btnClearFilter" runat="server" Text="Clear" CssClass="ral-btn ral-btn--outline" OnClick="btnClearFilter_Click" />
                </div>
            </div>
        </div>
        
        <!-- Message -->
        <asp:Panel ID="pnlMessage" runat="server" CssClass="ral-message" Visible="false">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
            <span><asp:Literal ID="litMessage" runat="server"></asp:Literal></span>
        </asp:Panel>
        
        <!-- Grid Card -->
        <div class="ral-grid-card">
            <div class="ral-grid-header">
                <div class="ral-grid-header__title">Audit Log Entries</div>
                <div class="ral-grid-header__actions">
                    <div class="ral-view-toggle">
                        <button type="button" class="ral-view-toggle__btn active" onclick="setView('grid')">Grid</button>
                        <button type="button" class="ral-view-toggle__btn" onclick="setView('timeline')">Timeline</button>
                    </div>
                </div>
            </div>
            
            <dx:ASPxGridView ID="gvAuditLog" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="ID" CssClass="ral-grid">
                <SettingsPager PageSize="50" AlwaysShowPager="true">
                    <Summary Visible="true" Text="Page {0} of {1} ({2} entries)" />
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" />
                <Settings ShowFilterRow="true" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewDataDateColumn FieldName="action_date" Caption="Date/Time" VisibleIndex="0" Width="130px">
                        <PropertiesDateEdit DisplayFormatString="dd-MMM-yy HH:mm" />
                    </dx:GridViewDataDateColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="action_type" Caption="Action" VisibleIndex="1" Width="100px">
                        <DataItemTemplate>
                            <%# GetActionBadge(Eval("action_type")) %>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="performed_by" Caption="User" VisibleIndex="2" Width="130px">
                        <DataItemTemplate>
                            <div class="ral-user-info">
                                <span class="ral-user-info__name"><%# Eval("performed_by") %></span>
                                <span class="ral-user-info__role"><%# Eval("user_role") %></span>
                            </div>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="target_entity" Caption="Target" VisibleIndex="3" Width="180px">
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="programme" Caption="Programme" VisibleIndex="4" Width="150px">
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="affected_records" Caption="Records" VisibleIndex="5" Width="70px">
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="description" Caption="Description" VisibleIndex="6">
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="severity" Caption="Severity" VisibleIndex="7" Width="80px">
                        <DataItemTemplate>
                            <%# GetSeverityIndicator(Eval("severity")) %>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="ip_address" Caption="IP Address" VisibleIndex="8" Width="100px">
                        <CellStyle ForeColor="#6c757d" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="ID" Caption="" VisibleIndex="9" Width="60px">
                        <DataItemTemplate>
                            <button type="button" class="ral-details-toggle" onclick="showDetails('<%# Eval("ID") %>')">Details</button>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                </Columns>
            </dx:ASPxGridView>
            
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvAuditLog" />
        </div>
    </div>
    
    <!-- Details Popup -->
    <dx:ASPxPopupControl ID="popDetails" runat="server" Width="600" Height="400" 
        HeaderText="Audit Entry Details" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" Modal="true" ClientInstanceName="popDetails">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px;">
                    <asp:Literal ID="litDetailsContent" runat="server"></asp:Literal>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <script type="text/javascript">
        function setView(viewType) {
            var btns = document.querySelectorAll('.ral-view-toggle__btn');
            btns.forEach(function(btn) {
                btn.classList.remove('active');
                if ((viewType === 'grid' && btn.textContent === 'Grid') || 
                    (viewType === 'timeline' && btn.textContent === 'Timeline')) {
                    btn.classList.add('active');
                }
            });
        }
        
        function showDetails(id) {
            popDetails.Show();
        }
    </script>
</asp:Content>
