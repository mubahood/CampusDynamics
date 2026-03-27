<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsHoldList.aspx.cs" Inherits="COOPERP_NewScreens_ResultsHoldList" Title="Held Results Management - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* ===============================================
           RESULTS HOLD LIST - STYLES
           Prefix: rhl- (Results Hold List)
        =============================================== */
        
        .rhl-container { padding: 0; font-size: 11px; }
        
        /* Page Header */
        .cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .cd-page-header__left { display:flex; align-items:center; gap:12px; }
        .cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
        .cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
        .cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        .cd-page-header__right { display:flex; gap:8px; align-items:center; }
        
        /* Alert Banner */
        .rhl-alert-banner {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            border-left: 4px solid #dc3545;
            border-radius: 0;
            padding: 12px 18px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .rhl-alert-banner__icon {
            width: 40px;
            height: 40px;
            background: #dc3545;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .rhl-alert-banner__icon svg { width: 20px; height: 20px; color: #fff; }
        .rhl-alert-banner__content { flex: 1; }
        .rhl-alert-banner__title { font-size: 13px; font-weight: 600; color: #721c24; margin-bottom: 2px; }
        .rhl-alert-banner__text { font-size: 11px; color: #721c24; }
        
        /* Stats Row */
        .rhl-stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-bottom: 15px;
        }
        .rhl-stat-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 14px 18px;
            position: relative;
            overflow: hidden;
        }
        .rhl-stat-card::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 4px;
            height: 100%;
        }
        .rhl-stat-card--total::before { background: #dc3545; }
        .rhl-stat-card--students::before { background: #fd7e14; }
        .rhl-stat-card--courses::before { background: #6f42c1; }
        .rhl-stat-card--pending::before { background: #ffc107; }
        
        .rhl-stat-card__value { font-size: 22px; font-weight: 700; line-height: 1; margin-bottom: 4px; }
        .rhl-stat-card--total .rhl-stat-card__value { color: #dc3545; }
        .rhl-stat-card--students .rhl-stat-card__value { color: #fd7e14; }
        .rhl-stat-card--courses .rhl-stat-card__value { color: #6f42c1; }
        .rhl-stat-card--pending .rhl-stat-card__value { color: #d39e00; }
        .rhl-stat-card__label { font-size: 10px; color: #6c757d; text-transform: uppercase; }
        
        /* Hold Reason Categories */
        .rhl-reason-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 10px;
            margin-bottom: 15px;
        }
        .rhl-reason-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 12px 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .rhl-reason-card:hover { background: #fafafa; }
        .rhl-reason-card.active { border-color: #dc3545; background: #fff5f5; }
        .rhl-reason-card__icon {
            width: 32px;
            height: 32px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .rhl-reason-card__icon svg { width: 16px; height: 16px; color: #fff; }
        .rhl-reason-card__icon--financial { background: #28a745; }
        .rhl-reason-card__icon--academic { background: #17a2b8; }
        .rhl-reason-card__icon--disciplinary { background: #dc3545; }
        .rhl-reason-card__icon--admin { background: #6f42c1; }
        .rhl-reason-card__icon--other { background: #6c757d; }
        .rhl-reason-card__content { flex: 1; }
        .rhl-reason-card__label { font-size: 10px; color: #6c757d; }
        .rhl-reason-card__count { font-size: 16px; font-weight: 700; color: #1a1a2e; }
        
        /* Filter Panel */
        .rhl-filter-panel {
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 12px 15px;
            margin-bottom: 12px;
        }
        .rhl-filter-row {
            display: flex;
            gap: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .rhl-filter-group {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .rhl-filter-group label {
            font-size: 9px;
            color: #6c757d;
            text-transform: uppercase;
            font-weight: 600;
        }
        .rhl-filter-select {
            padding: 6px 10px;
            font-size: 11px;
            border: 1px solid #ced4da;
            border-radius: 0;
            background: #fff;
            min-width: 140px;
        }
        .rhl-filter-select:focus { border-color: #dc3545; outline: none; }
        
        /* Buttons */
        .rhl-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            font-size: 11px;
            font-weight: 500;
            border: 1px solid transparent;
            border-radius: 0;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
        }
        .rhl-btn svg { width: 12px; height: 12px; }
        .rhl-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .rhl-btn--primary:hover { background: #0d3a7d; }
        .rhl-btn--success { background: #28a745; color: #fff; border-color: #28a745; }
        .rhl-btn--success:hover { background: #218838; }
        .rhl-btn--danger { background: #dc3545; color: #fff; border-color: #dc3545; }
        .rhl-btn--danger:hover { background: #c82333; }
        .rhl-btn--warning { background: #ffc107; color: #212529; border-color: #ffc107; }
        .rhl-btn--warning:hover { background: #e0a800; }
        .rhl-btn--outline { background: #fff; color: #495057; border-color: #ced4da; }
        .rhl-btn--outline:hover { background: #f8f9fa; }
        
        /* Batch Operations Bar */
        .rhl-batch-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 14px;
            background: #721c24;
            border-radius: 0;
            gap: 10px;
        }
        .rhl-batch-bar__left, .rhl-batch-bar__right {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .rhl-batch-bar__selection {
            color: #fff;
            font-size: 11px;
            padding: 4px 10px;
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
        }
        .rhl-batch-bar__selection strong { color: #ffc107; }
        
        /* Grid Card */
        .rhl-grid-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 0 0 6px 6px;
            overflow: hidden;
        }
        
        /* Grid Styles */
        .rhl-grid { border-collapse: collapse; width: 100%; }
        .rhl-grid .dxgvHeader td {
            background: #f5f7fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            color: #495057 !important;
            border-bottom: 2px solid #dc3545 !important;
        }
        .rhl-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .rhl-grid .dxgvDataRow:hover td { background: #fff5f5 !important; }
        .rhl-grid .dxgvSelectedRow td { background: #f8d7da !important; }
        
        /* Hold Reason Badge */
        .rhl-reason-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            border-radius: 12px;
        }
        .rhl-reason-badge--financial { background: #d4edda; color: #155724; }
        .rhl-reason-badge--academic { background: #cce5ff; color: #004085; }
        .rhl-reason-badge--disciplinary { background: #f8d7da; color: #721c24; }
        .rhl-reason-badge--admin { background: #e2d5f1; color: #432874; }
        .rhl-reason-badge--other { background: #e2e3e5; color: #383d41; }
        
        /* Duration Badge */
        .rhl-duration {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .rhl-duration__days { font-size: 14px; font-weight: 700; color: #dc3545; }
        .rhl-duration__label { font-size: 9px; color: #6c757d; }
        
        /* Message */
        .rhl-message {
            padding: 10px 14px;
            border-radius: 6px;
            font-size: 11px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .rhl-message svg { width: 16px; height: 16px; }
        .rhl-message--success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .rhl-message--error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .rhl-message--warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        
        /* Row Actions */
        .rhl-row-actions { display: flex; gap: 4px; justify-content: center; }
        .rhl-row-action {
            width: 24px;
            height: 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.15s ease;
        }
        .rhl-row-action svg { width: 12px; height: 12px; }
        .rhl-row-action--unhold { background: #e8f5e9; color: #388e3c; }
        .rhl-row-action--unhold:hover { background: #c8e6c9; }
        .rhl-row-action--view { background: #e3f2fd; color: #1976d2; }
        .rhl-row-action--view:hover { background: #bbdefb; }
        .rhl-row-action--history { background: #fff3e0; color: #f57c00; }
        .rhl-row-action--history:hover { background: #ffe0b2; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="rhl-container">
        <!-- Page Header -->
        <div class="cd-page-header">
            <div class="cd-page-header__left">
                <div class="cd-page-header__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <div>
                    <div class="cd-page-header__title">Results Hold List</div>
                    <div class="cd-page-header__sub">Manage students with holds preventing results release</div>
                </div>
            </div>
            <div class="cd-page-header__right">
                <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/COOPERP/NewScreens/ResultsRelease.aspx" CssClass="rhl-btn rhl-btn--outline">
                    ← Back to Results
                </asp:HyperLink>
                <asp:Button ID="btnExport" runat="server" Text="📊 Export" CssClass="rhl-btn rhl-btn--primary" OnClick="btnExport_Click" />
            </div>
        </div>
        
        <!-- Alert Banner -->
        <div class="rhl-alert-banner">
            <div class="rhl-alert-banner__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
            </div>
            <div class="rhl-alert-banner__content">
                <div class="rhl-alert-banner__title">Results Hold Notice</div>
                <div class="rhl-alert-banner__text">
                    The following results are currently on hold and NOT visible to students. 
                    Review the hold reasons and take appropriate action to release or maintain the hold.
                </div>
            </div>
        </div>
        
        <!-- Stats Row -->
        <div class="rhl-stats-row">
            <div class="rhl-stat-card rhl-stat-card--total">
                <div class="rhl-stat-card__value"><asp:Literal ID="litTotalHeld" runat="server">0</asp:Literal></div>
                <div class="rhl-stat-card__label">Total Held Records</div>
            </div>
            <div class="rhl-stat-card rhl-stat-card--students">
                <div class="rhl-stat-card__value"><asp:Literal ID="litAffectedStudents" runat="server">0</asp:Literal></div>
                <div class="rhl-stat-card__label">Affected Students</div>
            </div>
            <div class="rhl-stat-card rhl-stat-card--courses">
                <div class="rhl-stat-card__value"><asp:Literal ID="litAffectedCourses" runat="server">0</asp:Literal></div>
                <div class="rhl-stat-card__label">Courses Affected</div>
            </div>
            <div class="rhl-stat-card rhl-stat-card--pending">
                <div class="rhl-stat-card__value"><asp:Literal ID="litLongHeld" runat="server">0</asp:Literal></div>
                <div class="rhl-stat-card__label">Held &gt; 30 Days</div>
            </div>
        </div>
        
        <!-- Hold Reason Categories -->
        <div class="rhl-reason-cards">
            <asp:LinkButton ID="btnReasonFinancial" runat="server" CssClass="rhl-reason-card" OnClick="FilterByReason_Click" CommandArgument="FINANCIAL">
                <div class="rhl-reason-card__icon rhl-reason-card__icon--financial">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                </div>
                <div class="rhl-reason-card__content">
                    <div class="rhl-reason-card__label">Financial</div>
                    <div class="rhl-reason-card__count"><asp:Literal ID="litFinancialCount" runat="server">0</asp:Literal></div>
                </div>
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnReasonAcademic" runat="server" CssClass="rhl-reason-card" OnClick="FilterByReason_Click" CommandArgument="ACADEMIC">
                <div class="rhl-reason-card__icon rhl-reason-card__icon--academic">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                </div>
                <div class="rhl-reason-card__content">
                    <div class="rhl-reason-card__label">Academic Issues</div>
                    <div class="rhl-reason-card__count"><asp:Literal ID="litAcademicCount" runat="server">0</asp:Literal></div>
                </div>
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnReasonDisciplinary" runat="server" CssClass="rhl-reason-card" OnClick="FilterByReason_Click" CommandArgument="DISCIPLINARY">
                <div class="rhl-reason-card__icon rhl-reason-card__icon--disciplinary">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                </div>
                <div class="rhl-reason-card__content">
                    <div class="rhl-reason-card__label">Disciplinary</div>
                    <div class="rhl-reason-card__count"><asp:Literal ID="litDisciplinaryCount" runat="server">0</asp:Literal></div>
                </div>
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnReasonAdmin" runat="server" CssClass="rhl-reason-card" OnClick="FilterByReason_Click" CommandArgument="ADMIN">
                <div class="rhl-reason-card__icon rhl-reason-card__icon--admin">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                </div>
                <div class="rhl-reason-card__content">
                    <div class="rhl-reason-card__label">Administrative</div>
                    <div class="rhl-reason-card__count"><asp:Literal ID="litAdminCount" runat="server">0</asp:Literal></div>
                </div>
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnReasonOther" runat="server" CssClass="rhl-reason-card" OnClick="FilterByReason_Click" CommandArgument="">
                <div class="rhl-reason-card__icon rhl-reason-card__icon--other">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                </div>
                <div class="rhl-reason-card__content">
                    <div class="rhl-reason-card__label">All/Other</div>
                    <div class="rhl-reason-card__count"><asp:Literal ID="litOtherCount" runat="server">0</asp:Literal></div>
                </div>
            </asp:LinkButton>
        </div>
        
        <!-- Filter Panel -->
        <div class="rhl-filter-panel">
            <div class="rhl-filter-row">
                <div class="rhl-filter-group">
                    <label>Academic Year</label>
                    <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="rhl-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
                </div>
                <div class="rhl-filter-group">
                    <label>Semester</label>
                    <asp:DropDownList ID="ddlSemester" runat="server" CssClass="rhl-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Value="" Text="All Semesters"></asp:ListItem>
                        <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
                        <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="rhl-filter-group">
                    <label>Programme</label>
                    <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="rhl-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
                </div>
                <div class="rhl-filter-group">
                    <label>Hold Duration</label>
                    <asp:DropDownList ID="ddlDuration" runat="server" CssClass="rhl-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Value="" Text="Any Duration"></asp:ListItem>
                        <asp:ListItem Value="7" Text="< 7 days"></asp:ListItem>
                        <asp:ListItem Value="30" Text="< 30 days"></asp:ListItem>
                        <asp:ListItem Value="30+" Text="> 30 days"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="rhl-filter-group">
                    <label>&nbsp;</label>
                    <asp:Button ID="btnClearFilters" runat="server" Text="Clear Filters" CssClass="rhl-btn rhl-btn--outline" OnClick="btnClearFilters_Click" />
                </div>
            </div>
        </div>
        
        <!-- Message -->
        <asp:Panel ID="pnlMessage" runat="server" CssClass="rhl-message" Visible="false">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
            <span><asp:Literal ID="litMessage" runat="server"></asp:Literal></span>
        </asp:Panel>
        
        <!-- Batch Operations Bar -->
        <div class="rhl-batch-bar">
            <div class="rhl-batch-bar__left">
                <span class="rhl-batch-bar__selection">
                    Selected: <strong><span id="selectedCount">0</span></strong> record(s)
                </span>
                <asp:Button ID="btnUnholdSelected" runat="server" Text="✓ Unhold Selected" CssClass="rhl-btn rhl-btn--success" OnClick="btnUnholdSelected_Click" OnClientClick="return confirm('Remove hold from selected records? Results will be available for release.');" />
                <asp:Button ID="btnAddNote" runat="server" Text="📝 Add Note" CssClass="rhl-btn rhl-btn--warning" OnClick="btnAddNote_Click" />
            </div>
            <div class="rhl-batch-bar__right">
                <asp:Button ID="btnRefresh" runat="server" Text="↻ Refresh" CssClass="rhl-btn rhl-btn--outline" OnClick="btnRefresh_Click" style="color:#fff; border-color:rgba(255,255,255,0.3);" />
            </div>
        </div>
        
        <!-- Grid Card -->
        <div class="rhl-grid-card">
            <dx:ASPxGridView ID="gvHeldResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="ID" CssClass="rhl-grid" ClientInstanceName="gvHeldResults">
                <ClientSideEvents SelectionChanged="function(s,e) { updateSelectedCount(); }" />
                <SettingsPager PageSize="50" AlwaysShowPager="true">
                    <Summary Visible="true" Text="Page {0} of {1} ({2} held records)" />
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" AllowSelectByRowClick="true" />
                <Settings ShowFilterRow="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="35px" />
                    
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Student" VisibleIndex="1" Width="130px">
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="student_name" Caption="Name" VisibleIndex="2" Width="150px" />
                    
                    <dx:GridViewDataTextColumn FieldName="course_id" Caption="Course" VisibleIndex="3" Width="90px">
                        <CellStyle Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme" VisibleIndex="4" Width="150px" />
                    
                    <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Year" VisibleIndex="5" Width="80px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="6" Width="45px">
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="hold_reason" Caption="Hold Reason" VisibleIndex="7" Width="110px">
                        <DataItemTemplate>
                            <%# GetReasonBadge(Eval("hold_reason")) %>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="hold_notes" Caption="Notes" VisibleIndex="8" Width="180px">
                        <CellStyle Wrap="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataDateColumn FieldName="hold_date" Caption="Held On" VisibleIndex="9" Width="85px">
                        <PropertiesDateEdit DisplayFormatString="dd-MMM-yy" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataDateColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="days_held" Caption="Duration" VisibleIndex="10" Width="70px">
                        <DataItemTemplate>
                            <div class="rhl-duration">
                                <span class="rhl-duration__days"><%# Eval("days_held") %></span>
                                <span class="rhl-duration__label">days</span>
                            </div>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="held_by" Caption="Held By" VisibleIndex="11" Width="90px" />
                    
                    <dx:GridViewDataTextColumn FieldName="ID" Caption="Actions" VisibleIndex="12" Width="80px">
                        <DataItemTemplate>
                            <div class="rhl-row-actions">
                                <button type="button" class="rhl-row-action rhl-row-action--unhold" title="Unhold" onclick="unholdSingle('<%# Eval("ID") %>')">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                </button>
                                <button type="button" class="rhl-row-action rhl-row-action--view" title="View Student" onclick="viewStudent('<%# Eval("regno") %>')">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                </button>
                                <button type="button" class="rhl-row-action rhl-row-action--history" title="History" onclick="viewHistory('<%# Eval("ID") %>')">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                </button>
                            </div>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                </Columns>
            </dx:ASPxGridView>
            
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvHeldResults" />
        </div>
    </div>
    
    <!-- Add Note Popup -->
    <dx:ASPxPopupControl ID="popAddNote" runat="server" Width="500" Height="300" 
        HeaderText="Add Hold Note" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" Modal="true" ClientInstanceName="popAddNote">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px;">
                    <div class="rhl-filter-group" style="margin-bottom: 15px;">
                        <label>Hold Reason</label>
                        <asp:DropDownList ID="ddlHoldReason" runat="server" CssClass="rhl-filter-select" style="width: 100%;">
                            <asp:ListItem Value="FINANCIAL" Text="Financial Issue"></asp:ListItem>
                            <asp:ListItem Value="ACADEMIC" Text="Academic Issue"></asp:ListItem>
                            <asp:ListItem Value="DISCIPLINARY" Text="Disciplinary Issue"></asp:ListItem>
                            <asp:ListItem Value="ADMIN" Text="Administrative"></asp:ListItem>
                            <asp:ListItem Value="OTHER" Text="Other"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="rhl-filter-group" style="margin-bottom: 15px;">
                        <label>Note</label>
                        <asp:TextBox ID="txtHoldNote" runat="server" TextMode="MultiLine" Rows="4" style="width: 100%; padding: 8px; border: 1px solid #ced4da; border-radius: 4px;"></asp:TextBox>
                    </div>
                    <div style="text-align: right;">
                        <asp:Button ID="btnSaveNote" runat="server" Text="Save Note" CssClass="rhl-btn rhl-btn--primary" OnClick="btnSaveNote_Click" />
                        <button type="button" class="rhl-btn rhl-btn--outline" onclick="popAddNote.Hide();">Cancel</button>
                    </div>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <script type="text/javascript">
        function updateSelectedCount() {
            var count = gvHeldResults.GetSelectedRowCount();
            document.getElementById('selectedCount').textContent = count;
        }
        
        function unholdSingle(id) {
            if (confirm('Remove hold from this record?')) {
                __doPostBack('UnholdSingle', id);
            }
        }
        
        function viewStudent(regno) {
            window.open('StudentResultsView.aspx?regno=' + encodeURIComponent(regno), '_blank');
        }
        
        function viewHistory(id) {
            window.open('ResultsAuditLog.aspx?recordId=' + encodeURIComponent(id), '_blank');
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            updateSelectedCount();
        });
    </script>
</asp:Content>
