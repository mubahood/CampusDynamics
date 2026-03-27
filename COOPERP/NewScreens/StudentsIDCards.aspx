<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentsIDCards.aspx.cs" Inherits="COOPERP_NewScreens_StudentsIDCards" Title="Student ID Cards - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* ---- Page Header ---- */
        .cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .cd-page-header__left { display:flex; align-items:center; gap:12px; }
        .cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
        .cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
        .cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        /* ID Cards Stats - Compact Inline */
        .idcard-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .idcard-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .idcard-stat-item__label {
            color: #666;
        }
        .idcard-stat-item__value {
            font-weight: 700;
            color: #174DA4;
        }
        .idcard-stat-item--pending .idcard-stat-item__value { color: #dc3545; }
        .idcard-stat-item--ready .idcard-stat-item__value { color: #ffc107; }
        .idcard-stat-item--printed .idcard-stat-item__value { color: #17a2b8; }
        .idcard-stat-item--taken .idcard-stat-item__value { color: #28a745; }
        
        /* Filter Toggle & Row */
        .idcard-filter-toggle {
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
        .idcard-filter-toggle:hover { background: #f8f9fa; }
        .idcard-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .idcard-filter-toggle svg { width: 12px; height: 12px; }
        .idcard-filter-count {
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
        .idcard-filter-row {
            display: none;
            gap: 8px;
            padding: 8px 10px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .idcard-filter-row.show { display: flex; }
        .idcard-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .idcard-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .idcard-filter-clear {
            padding: 4px 8px;
            font-size: 10px;
            background: #fff;
            border: 1px solid #ddd;
            color: #666;
            cursor: pointer;
        }
        .idcard-filter-clear:hover { background: #f0f0f0; }
        
        /* Status Badge */
        .idcard-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .idcard-status-badge--pending { background: #fff3cd; color: #856404; }
        .idcard-status-badge--ready { background: #cce5ff; color: #004085; }
        .idcard-status-badge--printed { background: #d4edda; color: #155724; }
        .idcard-status-badge--taken { background: #e2e3e5; color: #383d41; }
        
        /* Registration Status Badge */
        .idcard-reg-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
        }
        .idcard-reg-badge--registered { background: #d4edda; color: #155724; }
        .idcard-reg-badge--unregistered { background: #f8d7da; color: #721c24; }
        
        /* Action Button Colors */
        .cd-action-popover__btn--ready { color: #17a2b8 !important; }
        .cd-action-popover__btn--ready:hover { background: #e3f2fd !important; }
        .cd-action-popover__btn--printed { color: #28a745 !important; }
        .cd-action-popover__btn--printed:hover { background: #e8f5e9 !important; }
        .cd-action-popover__btn--taken { color: #6c757d !important; }
        .cd-action-popover__btn--taken:hover { background: #f5f5f5 !important; }
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
        
        /* Card Generation Section */
        .idcard-gen-section {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            background: #f0f7ff;
            border: 1px solid #b8d4f0;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .idcard-gen-section__label {
            font-size: 11px;
            font-weight: 500;
            color: #174DA4;
            white-space: nowrap;
        }
        .idcard-gen-section select {
            padding: 4px 8px;
            font-size: 11px;
            border: 1px solid #ddd;
            min-width: 140px;
        }
        .idcard-gen-section select:focus {
            border-color: #174DA4;
            outline: none;
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
        .idcard-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .idcard-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .idcard-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Photo thumbnail */
        .idcard-photo {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border: 1px solid #ddd;
        }
        
        /* Print Styles */
        @media print {
            .idcard-batch-bar, .idcard-filter-row, .idcard-gen-section { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<!-- ======= PAGE HEADER =========================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
        </div>
        <div>
            <div class="cd-page-header__title">Student ID Cards</div>
            <div class="cd-page-header__sub">Generate and track student identity card production</div>
        </div>
    </div>
</div>
    <!-- Stats Bar (Compact Inline) -->
    <div class="idcard-stats-bar">
        <div class="idcard-stat-item idcard-stat-item--pending">
            <span class="idcard-stat-item__label">Pending:</span>
            <span class="idcard-stat-item__value"><asp:Literal ID="litPending" runat="server" Text="0" /></span>
        </div>
        <div class="idcard-stat-item idcard-stat-item--ready">
            <span class="idcard-stat-item__label">Ready:</span>
            <span class="idcard-stat-item__value"><asp:Literal ID="litReady" runat="server" Text="0" /></span>
        </div>
        <div class="idcard-stat-item idcard-stat-item--printed">
            <span class="idcard-stat-item__label">Printed:</span>
            <span class="idcard-stat-item__value"><asp:Literal ID="litPrinted" runat="server" Text="0" /></span>
        </div>
        <div class="idcard-stat-item idcard-stat-item--taken">
            <span class="idcard-stat-item__label">Taken:</span>
            <span class="idcard-stat-item__value"><asp:Literal ID="litTaken" runat="server" Text="0" /></span>
        </div>
        <div class="idcard-stat-item">
            <span class="idcard-stat-item__label">Total:</span>
            <span class="idcard-stat-item__value"><asp:Literal ID="litTotal" runat="server" Text="0" /></span>
        </div>
        <div style="margin-left: auto;">
            <button type="button" id="btnFilterToggle" class="idcard-filter-toggle" onclick="toggleFilters()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                Filters<span id="filterCount" class="idcard-filter-count" style="display:none;">0</span>
            </button>
        </div>
    </div>
    
    <!-- Filters (Hidden by default) -->
    <div class="idcard-filter-row" id="filterRow">
        <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="idcard-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
        </asp:DropDownList>
        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="idcard-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
            <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
            <asp:ListItem Value="3" Text="Semester 3"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlCardType" runat="server" CssClass="idcard-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCardType_SelectedIndexChanged">
            <asp:ListItem Value="Identity Cards" Text="Identity Cards"></asp:ListItem>
            <asp:ListItem Value="Registration Cards" Text="Registration Cards"></asp:ListItem>
            <asp:ListItem Value="Fees Cards" Text="Fees Cards"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlCardStatus" runat="server" CssClass="idcard-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCardStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All Statuses --"></asp:ListItem>
            <asp:ListItem Value="PENDING" Text="Pending"></asp:ListItem>
            <asp:ListItem Value="READY" Text="Ready"></asp:ListItem>
            <asp:ListItem Value="PRINTED" Text="Printed"></asp:ListItem>
            <asp:ListItem Value="TAKEN" Text="Taken"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="idcard-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width: 180px;">
            <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="idcard-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlIntake_SelectedIndexChanged">
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
        <button type="button" class="idcard-filter-clear" onclick="clearFilters()">Clear Filters</button>
    </div>
    
    <!-- Card Generation Section -->
    <div class="idcard-gen-section">
        <span class="idcard-gen-section__label">Generate Cards:</span>
        <asp:DropDownList ID="ddlGenIntake" runat="server" CssClass="idcard-filter-select">
            <asp:ListItem Value="" Text="-- Select Intake --"></asp:ListItem>
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
        <asp:Button ID="btnGenerateCards" runat="server" Text="Generate Card List" CssClass="cd-btn cd-btn--primary cd-btn--sm" 
            OnClick="btnGenerateCards_Click" OnClientClick="return confirmGenerate();" />
        <span style="border-left: 1px solid #ccc; height: 20px; margin: 0 8px;"></span>
        <span class="idcard-gen-section__label">Update Status To:</span>
        <asp:DropDownList ID="ddlNewStatus" runat="server" CssClass="idcard-filter-select">
            <asp:ListItem Value="READY" Text="Ready"></asp:ListItem>
            <asp:ListItem Value="PRINTED" Text="Printed"></asp:ListItem>
            <asp:ListItem Value="TAKEN" Text="Taken"></asp:ListItem>
        </asp:DropDownList>
        <asp:Button ID="btnUpdateStatus" runat="server" Text="Update Selected" CssClass="cd-btn cd-btn--primary cd-btn--sm" 
            OnClick="btnUpdateStatus_Click" OnClientClick="return confirmUpdateStatus();" />
    </div>
    
    <!-- Card with Header Row -->
    <div class="cd-card">
        <div style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center;">
            <div style="font-size: 11px; color: #666;">
                <asp:Literal ID="litAcadYearDisplay" runat="server" /> | Sem <asp:Literal ID="litSemesterDisplay" runat="server" /> | 
                <asp:Literal ID="litCardTypeDisplay" runat="server" /> | 
                <span id="selectedCountDisplay"><asp:Literal ID="litSelectedCount" runat="server" Text="0" /></span> selected
            </div>
            <div class="cd-batch-ops">
                <button type="button" class="cd-btn cd-btn--primary cd-btn--sm" onclick="toggleBatchMenu(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Batch Actions
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div class="cd-batch-menu" id="batchMenu">
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchReady()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#17a2b8"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Mark as Ready
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchPrinted()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#28a745"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                        Mark as Printed
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doBatchTaken()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#6c757d"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        Mark as Taken
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
            <dx:ASPxGridView ID="gvCards" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="ID" Width="100%" ClientInstanceName="gvCards"
                OnHtmlDataCellPrepared="gvCards_HtmlDataCellPrepared"
                CssClass="idcard-grid">
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
                    <dx:GridViewDataTextColumn FieldName="reg_no" Caption="Reg No" Width="120px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="180px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progcode" Caption="Programme" Width="80px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_intake" Caption="Intake" Width="70px" />
                    <dx:GridViewDataTextColumn FieldName="card_status" Caption="Card Status" Width="90px">
                        <DataItemTemplate>
                            <span class='idcard-status-badge idcard-status-badge--<%# GetStatusClass(Eval("card_status").ToString()) %>'>
                                <%# Eval("card_status") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="reg_status" Caption="Reg Status" Width="90px">
                        <DataItemTemplate>
                            <span class='idcard-reg-badge idcard-reg-badge--<%# GetRegStatusClass(Eval("reg_status").ToString()) %>'>
                                <%# Eval("reg_status") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="residence_stat" Caption="Residence" Width="90px" />
                    <dx:GridViewDataTextColumn FieldName="expiry_date" Caption="Expiry" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="created_by" Caption="Created By" Width="80px" />
                    <dx:GridViewDataTextColumn VisibleIndex="99" Caption=" " Width="40px" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item" style='<%# Eval("card_status").ToString() == "PENDING" ? "" : "display:none;" %>'>
                                            <asp:LinkButton ID="btnReady" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--ready"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnReady_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                                Mark Ready
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item" style='<%# Eval("card_status").ToString() == "READY" ? "" : "display:none;" %>'>
                                            <asp:LinkButton ID="btnPrinted" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--printed"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnPrinted_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                                                Mark Printed
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item" style='<%# Eval("card_status").ToString() == "PRINTED" ? "" : "display:none;" %>'>
                                            <asp:LinkButton ID="btnTaken" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--taken"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnTaken_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                                Mark Taken
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--delete"
                                                CommandArgument='<%# Eval("ID") %>' OnClick="btnDelete_Click"
                                                OnClientClick="return confirm('Delete this card record?');">
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
    <asp:Button ID="btnBatchReady" runat="server" OnClick="btnBatchReady_Click" style="display:none;" />
    <asp:Button ID="btnBatchPrinted" runat="server" OnClick="btnBatchPrinted_Click" style="display:none;" />
    <asp:Button ID="btnBatchTaken" runat="server" OnClick="btnBatchTaken_Click" style="display:none;" />
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
        
        // Confirm generate
        function confirmGenerate() {
            var ddl = document.getElementById('<%= ddlGenIntake.ClientID %>');
            if (!ddl.value) {
                alert('Please select an intake to generate cards for.');
                return false;
            }
            return confirm('Generate ID card list for the selected intake?');
        }
        
        // Confirm update status
        function confirmUpdateStatus() {
            var count = gvCards.GetSelectedRowCount();
            if (count === 0) { 
                alert('Please select at least one card.'); 
                return false; 
            }
            return confirm('Update status for ' + count + ' card(s)?');
        }
        
        // Batch actions
        function doBatchReady() {
            var count = gvCards.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one card.'); return; }
            if (confirm('Mark ' + count + ' card(s) as Ready?')) {
                document.getElementById('<%= btnBatchReady.ClientID %>').click();
            }
        }
        
        function doBatchPrinted() {
            var count = gvCards.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one card.'); return; }
            if (confirm('Mark ' + count + ' card(s) as Printed?')) {
                document.getElementById('<%= btnBatchPrinted.ClientID %>').click();
            }
        }
        
        function doBatchTaken() {
            var count = gvCards.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one card.'); return; }
            if (confirm('Mark ' + count + ' card(s) as Taken?')) {
                document.getElementById('<%= btnBatchTaken.ClientID %>').click();
            }
        }
        
        function doBatchDelete() {
            var count = gvCards.GetSelectedRowCount();
            if (count === 0) { alert('Please select at least one card.'); return; }
            if (confirm('Delete ' + count + ' card record(s)?')) {
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
            var ddls = ['<%= ddlCardStatus.ClientID %>', '<%= ddlProgramme.ClientID %>', '<%= ddlIntake.ClientID %>'];
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
            document.getElementById('<%= ddlCardStatus.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlProgramme.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlIntake.ClientID %>').selectedIndex = 0;
            __doPostBack('<%= ddlCardStatus.UniqueID %>', '');
        }
        
        // On page load
        document.addEventListener('DOMContentLoaded', function() {
            updateFilterCount();
        });
    </script>
</asp:Content>
