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
        /* Add / Move modal form fields */
        .cr-fld { margin-bottom: 10px; }
        .cr-fld2 { display: flex; gap: 10px; margin-bottom: 10px; }
        .cr-fld2 > div { flex: 1; min-width: 0; }
        .cr-fld label, .cr-fld2 label { display: block; font-size: 10px; font-weight: 700; color: #05275C; text-transform: uppercase; letter-spacing: .3px; margin-bottom: 4px; }
        .cr-in { width: 100%; box-sizing: border-box; padding: 7px 9px; border: 1px solid #cfd6e0; border-radius: 0; font-size: 12px; color: #1a1a2e; background: #fff; }
        .cr-in:focus { outline: none; border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }
        .cr-in:disabled { background: #f1f3f7; color: #9aa3af; }
        .cr-hint { display: block; font-size: 10px; color: #94a3b8; margin-top: 4px; }
        .cr-inline-msg { display: none; padding: 8px 10px; border-radius: 0; font-size: 11px; margin-bottom: 10px; }
        .cr-inline-msg.show { display: block; }
        .cr-inline-msg--err { background: #fdecec; color: #a12622; border: 1px solid #f3c7c4; }
        .cr-inline-msg--ok { background: #e9f7ee; color: #1c7a3e; border: 1px solid #bfe6cd; }
        .cr-move-info { background: #f8fafc; border: 1px solid #e6ebf2; padding: 8px 10px; margin-bottom: 12px; }
        .cr-move-info > div { display: flex; justify-content: space-between; align-items: center; font-size: 11px; padding: 3px 0; }
        .cr-move-info > div span { color: #6b7280; }
        .cr-move-info > div b { color: #05275C; text-align: right; }
        .crx-a--move { color: #174DA4; }

        @media (max-width: 900px) {
            .cr-batch-bar { flex-direction: column; align-items: stretch; }
            .cr-batch-actions { flex-wrap: wrap; }
            .cr-batch-btn { width: 100%; justify-content: center; }
            .cr-filter-row { flex-direction: column; align-items: stretch; }
            .cr-filter-select { width: 100% !important; min-width: 100%; }
        }

        /* ===== New datatable approach (crx-) ===== */
        .crx-card{background:#fff;border:1px solid #e3e9f2;border-radius:8px;}
        .crx-head{display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;padding:8px 10px;border-bottom:1px solid #edf1f6;}
        .crx-title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
        .crx-sub{font-size:10px;color:#6b7280;margin-top:2px;}
        .crx-toolbar{display:flex;gap:6px;align-items:center;flex-wrap:wrap;}
        .crx-filters{padding:8px 10px;border-bottom:1px solid #eef2f6;display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:6px;align-items:end;background:#fff;}
        .crx-fg{display:flex;flex-direction:column;gap:2px;min-width:0;}
        .crx-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
        .crx-fg .cr-filter-select,.crx-fg select,.crx-fg input{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:6px;color:#1a1a2e;width:100%;min-width:0;}
        .crx-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 10px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;}
        .crx-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
        .crx-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
        .crx-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
        .crx-btn--success{background:#2e7d32;color:#fff;border-color:#2e7d32;}
        .crx-btn--danger{background:#c62828;color:#fff;border-color:#c62828;}
        .crx-bulk{display:none;padding:6px 10px;border-bottom:1px solid #fdba74;background:#fff7ed;align-items:center;gap:8px;flex-wrap:wrap;}
        .crx-bulk.show{display:flex;}
        .crx-bulk__lbl{font-size:11px;font-weight:700;color:#92400e;}
        .crx-meta{padding:6px 10px;border-bottom:1px solid #eef2f6;font-size:10px;color:#64748b;display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;align-items:center;}
        .crx-pager{display:flex;gap:3px;flex-wrap:wrap;}
        .crx-pager a,.crx-pager span{border:1px solid #d4dbe8;background:#fff;color:#334155;font-size:9px;text-decoration:none;padding:4px 7px;border-radius:6px;}
        .crx-pager a:hover{border-color:#174DA4;color:#174DA4;background:#f4f8ff;}
        .crx-pager .active{background:#05275C;border-color:#05275C;color:#fff;}
        .crx-table-wrap{overflow:auto;background:#fff;}
        .crx-table{width:100%;min-width:980px;border-collapse:collapse;table-layout:fixed;}
        .crx-table th{position:sticky;top:0;background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px 5px;text-align:left;white-space:nowrap;z-index:1;}
        .crx-table td{border-bottom:1px solid #eef2f6;font-size:10.5px;color:#1f2937;padding:5px 5px;vertical-align:middle;overflow:hidden;text-overflow:ellipsis;}
        .crx-table tbody tr:hover td{background:#fafcff;}
        .crx-table .c{text-align:center;}
        .crx-code{font-family:Consolas,monospace;font-size:10px;color:#174DA4;font-weight:700;}
        .crx-link{color:#174DA4;text-decoration:underline;cursor:pointer;}
        .crx-sel{width:30px;text-align:center;}
        .crx-act{width:150px;}
        .crx-row-sel{width:14px;height:14px;cursor:pointer;accent-color:#174DA4;}
        .crx-empty{padding:26px 12px;text-align:center;color:#6b7280;font-size:11px;}
        .crx-a{display:inline-flex;align-items:center;gap:3px;padding:2px 6px;border:1px solid #d6deea;background:#fff;color:#334155;font-size:9px;font-weight:700;cursor:pointer;border-radius:4px;margin:1px;text-decoration:none;}
        .crx-a:hover{border-color:#174DA4;color:#174DA4;background:#f4f8ff;}
        .crx-a--danger{color:#b42318;border-color:#f3c2c2;}
        .crx-a--danger:hover{background:#fef2f2;border-color:#dc3545;color:#b42318;}

        /* Print Styles */
        @media print {
            .cr-batch-bar, .cr-filter-row, .cr-retake-panel, .qe-overlay,
            .crx-toolbar, .crx-filters, .crx-bulk, .crx-act, .crx-sel { display: none !important; }
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
            <asp:ListItem Value="3" Text="Sem 3"></asp:ListItem>
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
    
    <!-- ===== Add Course Registration (self-contained AJAX — no postback) ===== -->
    <div class="cr-modal-overlay" id="addModalOverlay" role="dialog" aria-modal="true" aria-labelledby="addModalTitle">
        <div class="cr-modal">
            <div class="cr-modal__head">
                <span class="cr-modal__title" id="addModalTitle">Add Course Registration</span>
                <button type="button" class="cr-modal__close" onclick="closeAddModal()" aria-label="Close">&times;</button>
            </div>
            <div class="cr-modal__body">
                <div id="addMsg" class="cr-inline-msg"></div>
                <div class="cr-fld">
                    <label>Registration Number</label>
                    <input type="text" id="addRegNo" class="cr-in" placeholder="e.g. MRU2024001234" autocomplete="off" onblur="addLoadCourses()" />
                    <span id="addStudent" class="cr-hint"></span>
                </div>
                <div class="cr-fld">
                    <label>Course</label>
                    <input type="text" id="addCourse" class="cr-in" list="addCourseList" placeholder="Enter the reg number first, then type a code or name&hellip;" autocomplete="off" disabled />
                    <datalist id="addCourseList"></datalist>
                </div>
                <div class="cr-fld2">
                    <div>
                        <label>Academic Year</label>
                        <input type="text" id="addAcad" class="cr-in" placeholder="2025/2026" autocomplete="off" />
                    </div>
                    <div>
                        <label>Semester</label>
                        <select id="addSem" class="cr-in">
                            <option value="1">Semester 1</option>
                            <option value="2">Semester 2</option>
                            <option value="3">Semester 3</option>
                        </select>
                    </div>
                </div>
                <div class="cr-fld">
                    <label>Record Type</label>
                    <select id="addType" class="cr-in">
                        <option value="REGULAR">Regular Course Registration</option>
                        <option value="RETAKE">Retake Course Registration</option>
                    </select>
                </div>
            </div>
            <div class="cr-modal__foot">
                <button type="button" class="cr-batch-btn" onclick="closeAddModal()">Cancel</button>
                <button type="button" class="cr-batch-btn cr-batch-btn--primary" id="addSubmitBtn" onclick="submitAdd(this)">Add Record</button>
            </div>
        </div>
    </div>

    <!-- ===== Move to Correct Course Code (change the paper a student sits) ===== -->
    <div class="cr-modal-overlay" id="moveModalOverlay" role="dialog" aria-modal="true" aria-labelledby="moveModalTitle">
        <div class="cr-modal">
            <div class="cr-modal__head">
                <span class="cr-modal__title" id="moveModalTitle">Move to Correct Course Code</span>
                <button type="button" class="cr-modal__close" onclick="closeMoveModal()" aria-label="Close">&times;</button>
            </div>
            <div class="cr-modal__body">
                <div id="moveMsg" class="cr-inline-msg"></div>
                <div class="cr-move-info">
                    <div><span>Student</span><b id="moveStudent">-</b></div>
                    <div><span>Reg No</span><b id="moveReg">-</b></div>
                    <div><span>Sitting</span><b id="moveContext">-</b></div>
                    <div><span>Current course</span><b id="moveOld" class="crx-code">-</b></div>
                </div>
                <div class="cr-fld">
                    <label>Correct course</label>
                    <input type="text" id="moveNew" class="cr-in" list="moveCourseList" placeholder="Type the correct code or name&hellip;" autocomplete="off" />
                    <datalist id="moveCourseList"></datalist>
                    <span class="cr-hint">The student&rsquo;s mark for this paper (course-work, exam, published result and transcript) moves with them to the new code, so it counts under the correct course in every result summary.</span>
                </div>
                <div class="cr-fld">
                    <label>Reason <span style="font-weight:400;color:#94a3b8;">(optional)</span></label>
                    <input type="text" id="moveReason" class="cr-in" placeholder="e.g. student was registered under the wrong code" autocomplete="off" />
                </div>
            </div>
            <div class="cr-modal__foot">
                <button type="button" class="cr-batch-btn" onclick="closeMoveModal()">Cancel</button>
                <button type="button" class="cr-batch-btn cr-batch-btn--primary" id="moveSubmitBtn" onclick="submitMove(this)">Move Student</button>
            </div>
        </div>
    </div>

    <!-- ===== New GET-driven datatable ===== -->
    <div class="crx-card">
        <div class="crx-head">
            <div>
                <div class="crx-title">Course Registration Records</div>
                <div class="crx-sub">Server-paged &middot; filter, select and act on records below</div>
            </div>
            <div class="crx-toolbar">
                <button type="button" class="crx-btn" onclick="openAddModal()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add Record
                </button>
                <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="crx-btn" OnClick="btnExportExcel_Click" />
            </div>
        </div>

        <!-- Bulk action bar (shown when rows are selected) -->
        <div class="crx-bulk" id="crxBulk">
            <span class="crx-bulk__lbl" id="crxBulkLbl">0 selected</span>
            <asp:Button ID="btnRegisterSelected" runat="server" Text="Register Selected" CssClass="crx-btn crx-btn--success" OnClick="btnRegisterSelected_Click" OnClientClick="return prepBulk('register');" />
            <asp:Button ID="btnRemoveSelected" runat="server" Text="Remove Selected" CssClass="crx-btn crx-btn--danger" OnClick="btnRemoveSelected_Click" OnClientClick="return prepBulk('remove');" Visible="false" />
            <button type="button" class="crx-btn" onclick="clearSel()">Clear Selection</button>
        </div>

        <!-- Meta + pager -->
        <div class="crx-meta">
            <span>Showing <strong><asp:Literal ID="litFrom" runat="server">0</asp:Literal></strong>&ndash;<strong><asp:Literal ID="litTo" runat="server">0</asp:Literal></strong>
                of <strong><asp:Literal ID="litTotal" runat="server">0</asp:Literal></strong> records
                &nbsp;|&nbsp; Page <asp:Literal ID="litPage" runat="server">1</asp:Literal> of <asp:Literal ID="litPageCount" runat="server">1</asp:Literal></span>
            <div class="crx-pager"><asp:Literal ID="litPager" runat="server"></asp:Literal></div>
        </div>

        <div class="crx-table-wrap">
            <table class="crx-table">
                <colgroup>
                    <col style="width:30px;" /><col style="width:120px;" /><col /><col style="width:160px;" />
                    <col style="width:90px;" /><col style="width:80px;" /><col style="width:54px;" /><col style="width:70px;" />
                    <col style="width:80px;" /><col style="width:90px;" /><col style="width:96px;" /><col style="width:158px;" />
                </colgroup>
                <thead>
                    <tr>
                        <th class="crx-sel"><input type="checkbox" id="crxChkAll" onclick="toggleAll(this)" title="Select all on this page" /></th>
                        <th>Reg No</th><th>Student</th><th>Specialisation</th><th>Course</th><th>Acad Yr</th><th>Sem</th>
                        <th>Entry Yr</th><th>Intake</th><th>Reg Status</th><th>Course Status</th><th class="crx-act">Actions</th>
                    </tr>
                </thead>
                <tbody><asp:Literal ID="litRows" runat="server"></asp:Literal></tbody>
            </table>
        </div>

        <div class="crx-meta" style="border-bottom:none;">
            <span><asp:Literal ID="litTotal2" runat="server">0</asp:Literal> total records</span>
            <div class="crx-pager"><asp:Literal ID="litPager2" runat="server"></asp:Literal></div>
        </div>
    </div>

    <!-- Selection + bulk-action carriers -->
    <asp:HiddenField ID="hfSelectedKeys" runat="server" />

    <!-- Hidden DevExpress grid retained only for Excel export -->
    <div style="display:none;">
        <dx:ASPxGridView ID="gvCourseReg" runat="server" Width="100%" AutoGenerateColumns="True" KeyFieldName="regno">
        </dx:ASPxGridView>
        <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvCourseReg">
        </dx:ASPxGridViewExporter>
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
            if (e.key === 'Escape') { closeAddModal(); closeMoveModal(); }
        });

        document.addEventListener('click', function (e) {
            if (e.target === document.getElementById('addModalOverlay')) closeAddModal();
            if (e.target === document.getElementById('moveModalOverlay')) closeMoveModal();
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

    </script>

    <!-- ===== New datatable: selection + admin row actions ===== -->
    <script type="text/javascript">
    (function () {
        var selected = {};
        function qs(id) { return document.getElementById(id); }
        function hf() { return qs('<%= hfSelectedKeys.ClientID %>'); }

        function updateBulk() {
            var keys = Object.keys(selected);
            var bar = qs('crxBulk'), lbl = qs('crxBulkLbl');
            if (lbl) lbl.textContent = keys.length + ' selected';
            if (bar) bar.classList.toggle('show', keys.length > 0);
            var h = hf(); if (h) h.value = keys.join(',');
        }
        window.onRowSel = function (cb) {
            var k = cb.getAttribute('data-key');
            if (cb.checked) selected[k] = 1; else delete selected[k];
            updateBulk();
        };
        window.toggleAll = function (master) {
            var boxes = document.querySelectorAll('.crx-row-sel');
            for (var i = 0; i < boxes.length; i++) {
                boxes[i].checked = master.checked;
                var k = boxes[i].getAttribute('data-key');
                if (master.checked) selected[k] = 1; else delete selected[k];
            }
            updateBulk();
        };
        window.clearSel = function () {
            selected = {};
            var boxes = document.querySelectorAll('.crx-row-sel');
            for (var i = 0; i < boxes.length; i++) boxes[i].checked = false;
            var m = qs('crxChkAll'); if (m) m.checked = false;
            updateBulk();
        };
        window.prepBulk = function (action) {
            var h = hf();
            var keys = h && h.value ? h.value.split(',').filter(Boolean) : [];
            if (keys.length === 0) { alert('Select at least one student by ticking the checkboxes.'); return false; }
            var course = document.getElementById('<%= ddlCourse.ClientID %>');
            if (!course || !course.value) { alert('Please select a course first.'); return false; }
            return confirm(action === 'register'
                ? ('Register ' + keys.length + ' selected student(s) for the selected course?')
                : ('Remove registration for ' + keys.length + ' selected student(s)?'));
        };

        function callAjax(method, payload, cb) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'CourseRegistration.aspx/' + method, true);
            xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
            xhr.onload = function () {
                try { var o = JSON.parse(xhr.responseText); cb(typeof o.d === 'string' ? JSON.parse(o.d) : o.d); }
                catch (e) { cb({ success: false, message: 'Unexpected server response.' }); }
            };
            xhr.onerror = function () { cb({ success: false, message: 'Network error.' }); };
            xhr.send(JSON.stringify(payload));
        }

        window.crxDelete = function (btn) {
            var d = btn.dataset;
            if (!confirm('Delete this course registration?\n\n' + d.regno + ' — ' + d.course + ' (' + d.acad + ', Sem ' + d.sem + ')\n\nThis cannot be undone.')) return;
            btn.disabled = true;
            callAjax('DeleteRegistration', { regno: d.regno, course: d.course, acad: d.acad, sem: parseInt(d.sem, 10) }, function (r) {
                if (r && r.success) { window.location.reload(); }
                else { alert((r && r.message) || 'Delete failed.'); btn.disabled = false; }
            });
        };
        window.crxStatus = function (btn) {
            var d = btn.dataset;
            var cur = (d.status || '').toUpperCase();
            var next = cur === 'RETAKE' ? 'REGULAR' : 'RETAKE';
            if (!confirm('Change course status of ' + d.regno + ' — ' + d.course + '\nfrom ' + (cur || '-') + ' to ' + next + '?')) return;
            btn.disabled = true;
            callAjax('SetCourseStatus', { regno: d.regno, course: d.course, acad: d.acad, sem: parseInt(d.sem, 10), status: next }, function (r) {
                if (r && r.success) { window.location.reload(); }
                else { alert((r && r.message) || 'Update failed.'); btn.disabled = false; }
            });
        };

        // ===== shared helpers =====================================================
        function msg(id, text, kind) {
            var el = qs(id); if (!el) return;
            if (!text) { el.className = 'cr-inline-msg'; el.textContent = ''; return; }
            el.className = 'cr-inline-msg show cr-inline-msg--' + (kind || 'err');
            el.textContent = text;
        }
        function pageVal(clientId) { var el = qs(clientId); return el ? (el.value || '') : ''; }
        // Fill a <datalist> with the programme's courses; skip any code in `skip` (already held).
        function fillCourseList(listId, courses, skip) {
            var dl = qs(listId); if (!dl) return;
            var s = {}; (skip || []).forEach(function (c) { s[(c || '').toUpperCase()] = 1; });
            var h = '';
            (courses || []).forEach(function (c) {
                if (s[(c.code || '').toUpperCase()]) return;
                var lbl = c.code + (c.name ? ' — ' + c.name : '') + (c.sy ? '  (Yr ' + c.sy + (c.sem ? ' S' + c.sem : '') + ')' : '');
                h += '<option value="' + c.code.replace(/"/g, '&quot;') + '">' + lbl.replace(/</g, '&lt;') + '</option>';
            });
            dl.innerHTML = h;
        }
        function codeInList(courses, code, skip) {
            var up = (code || '').trim().toUpperCase(); if (!up) return false;
            var s = {}; (skip || []).forEach(function (c) { s[(c || '').toUpperCase()] = 1; });
            if (s[up]) return false;
            for (var i = 0; i < (courses || []).length; i++) if ((courses[i].code || '').toUpperCase() === up) return true;
            return false;
        }
        // Resolve what the user typed/selected to a real code: exact match first (handles codes with
        // spaces), then the leading token as a fallback. Returns the canonical code or ''.
        function resolveCode(courses, raw) {
            var v = (raw || '').trim(); if (!v) return '';
            for (var i = 0; i < (courses || []).length; i++) if ((courses[i].code || '').toUpperCase() === v.toUpperCase()) return courses[i].code;
            var head = v.split(/\s+—\s+|\s+-\s+/)[0].trim();  // strip a " — Name" / " - Name" suffix only
            for (var j = 0; j < (courses || []).length; j++) if ((courses[j].code || '').toUpperCase() === head.toUpperCase()) return courses[j].code;
            return head;
        }

        // ===== ADD RECORD (self-contained) ========================================
        var addCourses = [], addTaken = [];
        window.openAddModal = function () {
            msg('addMsg', '');
            qs('addRegNo').value = '';
            qs('addStudent').textContent = '';
            var c = qs('addCourse'); c.value = ''; c.disabled = true; qs('addCourseList').innerHTML = '';
            addCourses = []; addTaken = [];
            // Pre-fill sitting context from the page filters (editable).
            var a = pageVal('<%= ddlAcadYear.ClientID %>'); if (a) qs('addAcad').value = a;
            var s = pageVal('<%= ddlSemester.ClientID %>'); if (s && qs('addSem').querySelector('option[value="' + s + '"]')) qs('addSem').value = s;
            var t = pageVal('<%= ddlCourse.ClientID %>');  // if a course filter is active, seed it after courses load
            qs('addModalOverlay').classList.add('show');
            setTimeout(function () { qs('addRegNo').focus(); }, 60);
            window._addSeedCourse = t || '';
        };
        window.closeAddModal = function () { var m = qs('addModalOverlay'); if (m) m.classList.remove('show'); };
        window.addLoadCourses = function () {
            var reg = (qs('addRegNo').value || '').trim();
            var c = qs('addCourse');
            if (!reg) { c.disabled = true; qs('addStudent').textContent = ''; return; }
            qs('addStudent').textContent = 'Loading student…';
            callAjax('GetStudentCourseOptions', { regno: reg, acad: (qs('addAcad').value || '').trim(), sem: parseInt(qs('addSem').value, 10) || 0 }, function (r) {
                if (!r || !r.success) { qs('addStudent').textContent = (r && r.message) || 'Student not found.'; c.disabled = true; return; }
                addCourses = r.courses || []; addTaken = r.taken || [];
                qs('addStudent').textContent = (r.student || '') + (r.prog ? '  ·  ' + r.prog : '');
                fillCourseList('addCourseList', addCourses, addTaken);
                c.disabled = false;
                if (window._addSeedCourse && codeInList(addCourses, window._addSeedCourse, addTaken)) c.value = window._addSeedCourse;
            });
        };
        window.submitAdd = function (btn) {
            var reg = (qs('addRegNo').value || '').trim();
            var course = (qs('addCourse').value || '').trim();
            var acad = (qs('addAcad').value || '').trim();
            var sem = parseInt(qs('addSem').value, 10) || 0;
            var type = qs('addType').value || 'REGULAR';
            if (!reg) { msg('addMsg', 'Please enter a registration number.'); return; }
            if (!acad) { msg('addMsg', 'Please enter the academic year (e.g. 2025/2026).'); return; }
            if (!course) { msg('addMsg', 'Please choose a course.'); return; }
            course = resolveCode(addCourses, course);
            if (!codeInList(addCourses, course, addTaken)) {
                msg('addMsg', addTaken.indexOf(course.toUpperCase()) > -1
                    ? 'The student already has ' + course + ' this semester.'
                    : 'Pick a valid course from the list for this student’s programme.');
                return;
            }
            msg('addMsg', '');
            btn.disabled = true; var orig = btn.textContent; btn.textContent = 'Adding…';
            callAjax('AddCourseRegistration', { regno: reg, course: course, acad: acad, sem: sem, type: type }, function (r) {
                if (r && r.success) { window.location.reload(); }
                else { msg('addMsg', (r && r.message) || 'Could not add the record.'); btn.disabled = false; btn.textContent = orig; }
            });
        };

        // ===== MOVE TO CORRECT COURSE ============================================
        var moveCtx = null, moveCourses = [], moveTaken = [];
        window.crxMove = function (btn) {
            var d = btn.dataset;
            moveCtx = { regno: d.regno, course: d.course, acad: d.acad, sem: d.sem, name: d.name || '' };
            msg('moveMsg', '');
            qs('moveStudent').textContent = moveCtx.name || '-';
            qs('moveReg').textContent = moveCtx.regno;
            qs('moveContext').textContent = moveCtx.acad + '  ·  Semester ' + moveCtx.sem;
            qs('moveOld').textContent = moveCtx.course;
            qs('moveNew').value = ''; qs('moveReason').value = ''; qs('moveCourseList').innerHTML = '';
            moveCourses = []; moveTaken = [];
            qs('moveModalOverlay').classList.add('show');
            callAjax('GetStudentCourseOptions', { regno: moveCtx.regno, acad: moveCtx.acad, sem: parseInt(moveCtx.sem, 10) || 0 }, function (r) {
                if (!r || !r.success) { msg('moveMsg', (r && r.message) || 'Could not load courses.'); return; }
                moveCourses = r.courses || []; moveTaken = r.taken || [];
                // the current (wrong) code is one the student holds — allow moving OFF it, so keep it selectable-away
                fillCourseList('moveCourseList', moveCourses, moveTaken);
                setTimeout(function () { qs('moveNew').focus(); }, 40);
            });
        };
        window.closeMoveModal = function () { var m = qs('moveModalOverlay'); if (m) m.classList.remove('show'); moveCtx = null; };
        window.submitMove = function (btn) {
            if (!moveCtx) return;
            var nw = resolveCode(moveCourses, qs('moveNew').value);
            if (!nw) { msg('moveMsg', 'Please choose the correct course.'); return; }
            if (nw.toUpperCase() === (moveCtx.course || '').toUpperCase()) { msg('moveMsg', 'That is the same as the current course.'); return; }
            if (!codeInList(moveCourses, nw, moveTaken)) {
                msg('moveMsg', moveTaken.indexOf(nw.toUpperCase()) > -1
                    ? 'The student already has ' + nw + ' this semester — delete that duplicate first.'
                    : 'Pick a valid course from the list for this student’s programme.');
                return;
            }
            if (!confirm('Move ' + moveCtx.regno + '\nfrom ' + moveCtx.course + ' to ' + nw + '\nfor ' + moveCtx.acad + ', Semester ' + moveCtx.sem + '?\n\nThe mark moves with the student.')) return;
            msg('moveMsg', '');
            btn.disabled = true; var orig = btn.textContent; btn.textContent = 'Moving…';
            callAjax('ChangeCourseCode', { regno: moveCtx.regno, oldCourse: moveCtx.course, acad: moveCtx.acad, sem: parseInt(moveCtx.sem, 10) || 0, newCourse: nw, reason: (qs('moveReason').value || '').trim() }, function (r) {
                if (r && r.success) { window.location.reload(); }
                else { msg('moveMsg', (r && r.message) || 'Move failed.'); btn.disabled = false; btn.textContent = orig; }
            });
        };
    })();
    </script>
</asp:Content>
