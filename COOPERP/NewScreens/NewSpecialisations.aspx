<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewSpecialisations.aspx.cs" Inherits="COOPERP_NewScreens_NewSpecialisations" Title="Specialisations - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        /* ---- Page Header ---- */
        .cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .cd-page-header__left { display:flex; align-items:center; gap:12px; }
        .cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
        .cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
        .cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        /* =============================================
           POPUP & MODAL STYLING
           ============================================= */
        .popup-body {
            padding: 8px;
        }
        .popup-info-bar {
            background: #f8f8f8;
            padding: 6px 10px;
            margin: -8px -8px 8px -8px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 11px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .popup-info-bar .separator { color: #ccc; }
        .popup-info-bar .info-value { color: #174DA4; font-weight: 600; }
        
        /* =============================================
           TABS - Compact & Clean
           ============================================= */
        .cd-tabs { border: none !important; }
        .cd-tabs .dxpLite_Glass,
        .cd-tabs .dxtvControl_Glass,
        .cd-tabs .dxtcLite_Glass { border: none !important; background: transparent !important; }
        
        /* Tab buttons - smaller, cleaner */
        .cd-tabs .dxtc-tab,
        .cd-tabs .dxtc-activeTab {
            padding: 5px 10px !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.3px !important;
            border: none !important;
            border-bottom: 2px solid transparent !important;
            background: transparent !important;
            color: #666 !important;
            margin-right: 2px !important;
        }
        .cd-tabs .dxtc-activeTab {
            color: #174DA4 !important;
            border-bottom-color: #174DA4 !important;
            background: transparent !important;
        }
        .cd-tabs .dxtc-tab:hover {
            color: #174DA4 !important;
            background: #f0f5ff !important;
        }
        .cd-tabs .dxtc-activeTab:hover {
            color: #174DA4 !important;
            background: transparent !important;
        }
        /* Tab strip bottom border */
        .cd-tabs .dxtc-stripContainer { border-bottom: 1px solid #e0e0e0 !important; }
        
        /* Tab content - minimal padding */
        .tab-content { 
            padding: 8px 6px;
            min-height: auto;
        }
        
        /* =============================================
           FORM ELEMENTS - Compact
           ============================================= */
        .form-section { margin-bottom: 8px; }
        .form-label { 
            display: block; 
            font-size: 9px; 
            font-weight: 600; 
            color: #888; 
            margin-bottom: 2px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .form-row { display: flex; gap: 8px; margin-bottom: 8px; align-items: flex-end; }
        .form-group { flex: 0 0 auto; }
        .form-group--flex { flex: 1 1 auto; }
        
        /* Inputs */
        .cd-input, .cd-combo, .cd-input--memo { font-size: 11px !important; }
        .cd-input--memo { font-family: Consolas, monospace !important; }
        .cd-input input, .cd-combo input, .cd-input--memo textarea {
            border: 1px solid #ddd !important;
            padding: 4px 6px !important;
            font-size: 11px !important;
            color: #333 !important;
            background: #fff !important;
        }
        .cd-input input:focus, .cd-combo input:focus, .cd-input--memo textarea:focus {
            border-color: #174DA4 !important;
            outline: none !important;
        }
        
        /* Combo dropdown fix */
        .cd-combo .dxeListBoxItemSelected_Glass,
        .cd-combo tr.dxeListBoxItemSelected_Glass td { background: #174DA4 !important; color: #fff !important; }
        .cd-combo .dxeListBoxItem_Glass:hover,
        .cd-combo tr.dxeListBoxItem_Glass:hover td { background: #f0f5ff !important; color: #174DA4 !important; }
        
        /* =============================================
           BUTTONS - Compact
           ============================================= */
        .btn-row {
            display: flex;
            gap: 6px;
            justify-content: flex-end;
            padding-top: 8px;
            margin-top: 8px;
            border-top: 1px solid #eee;
        }
        .btn-row--top {
            border-top: none;
            border-bottom: 1px solid #eee;
            padding-top: 0;
            padding-bottom: 8px;
            margin-top: 0;
            margin-bottom: 8px;
        }
        .cd-btn--secondary {
            background: #f5f5f5 !important;
            color: #333 !important;
            border: 1px solid #ddd !important;
            padding: 4px 10px !important;
            font-size: 10px !important;
        }
        .cd-btn--secondary:hover { background: #e8e8e8 !important; }
        
        /* =============================================
           RESULT PANELS - Compact
           ============================================= */
        .result-panel {
            margin-top: 6px;
            padding: 6px 8px;
            font-size: 10px;
            background: #f8f9fa;
        }
        .validation-success { color: #155724; }
        .validation-error { color: #721c24; }
        
        /* =============================================
           COURSE STRUCTURE TAB
           ============================================= */
        .structure-container { max-height: 350px; overflow-y: auto; }
        .year-sem-table { 
            width: 100%; 
            border-collapse: collapse; 
            font-size: 10px;
            border: 1px solid #e0e0e0;
        }
        .year-sem-table th, .year-sem-table td { 
            border: 1px solid #e0e0e0; 
            padding: 5px 8px; 
            text-align: left;
            vertical-align: top;
        }
        .year-sem-table th { background: #f8f9fa; font-weight: 600; color: #333; }
        .year-sem-header { background: #174DA4 !important; color: #fff !important; font-size: 11px; }
        .course-item { 
            padding: 3px 6px; 
            margin: 2px 0; 
            background: #fff;
            border: 1px solid #eee;
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            font-size: 10px;
        }
        .course-item:hover { background: #f0f5ff; border-color: #d0c4e8; }
        .course-item strong { color: #174DA4; margin-right: 6px; }
        .course-item .credits { background: #f0f0f0; padding: 1px 5px; font-size: 9px; color: #666; }
        
        /* =============================================
           ALL COURSES GRID - Compact
           ============================================= */
        .cd-grid { font-size: 10px; }
        .cd-grid .dxgvHeader_Glass, .cd-grid th {
            background: #f5f5f5 !important;
            border-bottom: 2px solid #174DA4 !important;
            font-weight: 600 !important;
            padding: 4px 6px !important;
            font-size: 10px !important;
        }
        .cd-grid td { padding: 3px 6px !important; border-bottom: 1px solid #eee !important; }
        .cd-grid tr:hover td { background: #f0f5ff !important; }
        
        /* =============================================
           ACTION BUTTONS - Compact
           ============================================= */
        .manage-courses-btn { 
            cursor: pointer; 
            color: #174DA4; 
            font-size: 9px; 
            padding: 2px 5px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            display: inline-flex;
            align-items: center;
            gap: 2px;
        }
        .manage-courses-btn:hover { background: #174DA4; border-color: #174DA4; color: #fff; }
        .manage-courses-btn svg { width: 9px; height: 9px; }
        
        .print-structure-btn { 
            cursor: pointer; 
            color: #666; 
            font-size: 9px; 
            padding: 2px 5px;
            background: #fff;
            border: 1px solid #ddd;
            display: inline-flex;
            align-items: center;
            gap: 2px;
        }
        .print-structure-btn:hover { background: #28a745; border-color: #28a745; color: #fff; }
        .print-structure-btn svg { width: 9px; height: 9px; }
        
        .course-count-badge { 
            display: inline-block; 
            padding: 1px 8px; 
            background: #e8e0f3; 
            color: #174DA4; 
            font-size: 10px; 
            font-weight: 600;
            min-width: 20px;
            text-align: center;
        }
        
        /* =============================================
           BATCH ADD - Optimized Grid (3 columns for S1, S2, S3)
           ============================================= */
        .batch-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 6px;
        }
        .batch-year-section {
            border: 1px solid #e0e0e0;
            background: #fafafa;
        }
        .batch-year-header {
            background: #174DA4;
            color: #fff;
            padding: 3px 6px;
            font-size: 10px;
            font-weight: 600;
        }
        .batch-year-body {
            padding: 6px;
        }
        .batch-field-row {
            display: flex;
            gap: 4px;
            align-items: flex-end;
        }
        .batch-courses-field {
            flex: 1;
        }
        .batch-courses-field input {
            width: 100%;
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 10px;
            font-family: Consolas, monospace;
        }
        .batch-courses-field input:focus {
            border-color: #174DA4;
            outline: none;
        }
        .batch-courses-field input::placeholder {
            color: #bbb;
            font-size: 9px;
        }
        .batch-small-field {
            width: 40px;
        }
        .batch-small-field select,
        .batch-small-field input {
            width: 100%;
            border: 1px solid #ddd;
            padding: 3px 4px;
            font-size: 9px;
            text-align: center;
        }
        .batch-small-field select:focus,
        .batch-small-field input:focus {
            border-color: #174DA4;
            outline: none;
        }
        .batch-field-label {
            font-size: 8px;
            color: #999;
            margin-bottom: 1px;
            text-transform: uppercase;
            letter-spacing: 0.2px;
        }
        .batch-validation-result {
            margin-top: 4px;
            font-size: 9px;
            padding: 3px 5px;
            display: none;
            line-height: 1.3;
        }
        .batch-validation-result.has-result { display: block; }
        .batch-validation-result.valid { background: #d4edda; border-left: 2px solid #28a745; color: #155724; }
        .batch-validation-result.invalid { background: #f8d7da; border-left: 2px solid #dc3545; color: #721c24; }
        .batch-validation-result.mixed { background: #fff3cd; border-left: 2px solid #856404; color: #856404; }
        
        .batch-actions {
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 6px;
            justify-content: flex-end;
        }
        .batch-result-summary {
            margin-top: 8px;
            padding: 6px 8px;
            background: #f8f9fa;
            font-size: 10px;
            border-left: 3px solid #174DA4;
        }
        
        /* =============================================
           TRANSCRIPT GRID - Compact styling
           ============================================= */
        .transcript-grid {
            font-size: 11px;
            border-collapse: collapse;
        }
        .transcript-grid th {
            border-bottom: 2px solid #174DA4 !important;
            padding: 6px 8px !important;
        }
        .transcript-grid td {
            border-bottom: 1px solid #eee !important;
            padding: 5px 8px !important;
        }
        
        /* =============================================
           TRANSCRIPT TAB - Enhanced Styling
           ============================================= */
        .transcript-context {
            background: #174DA4;
            color: white;
            padding: 10px 12px;
            margin: -8px -8px 8px -8px;
            border-radius: 3px 3px 0 0;
            font-size: 11px;
        }
        .transcript-context-title {
            font-weight: 700;
            font-size: 12px;
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .transcript-context-info {
            display: flex;
            gap: 15px;
            font-size: 10px;
            opacity: 0.95;
            flex-wrap: wrap;
        }
        .transcript-context-info span {
            color: white;
        }
        .transcript-context-info strong {
            color: white;
            font-weight: 600;
        }
        .transcript-warning {
            background: #fff3cd;
            border-left: 4px solid #ff6b6b;
            padding: 8px 10px;
            margin-top: 8px;
            font-size: 11px;
            display: flex;
            align-items: flex-start;
            gap: 8px;
        }
        .transcript-courses-compact {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 5px;
            max-height: 380px;
            overflow-y: auto;
            padding: 6px;
        }
        .transcript-course-item {
            background: white;
            border: 1px solid #e0e0e0;
            border-left: 3px solid transparent;
            padding: 8px 10px;
            font-size: 10px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 6px;
            transition: all 0.2s;
        }
        .transcript-course-item:hover {
            border-color: #174DA4;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .transcript-course-item.status-ready {
            border-left: 3px solid #28a745;
        }
        .transcript-course-item.status-exists {
            border-left: 3px solid #ffc107;
            background: #fffbf0;
        }
        .transcript-course-item.status-invalid {
            border-left: 3px solid #dc3545;
            background: #fff5f5;
            opacity: 0.7;
        }
        .transcript-course-code {
            font-weight: 700;
            color: #174DA4;
            font-size: 11px;
        }
        .transcript-course-meta {
            font-size: 9px;
            color: #666;
            margin-top: 2px;
        }
        .transcript-course-badge {
            font-size: 8px;
            padding: 2px 6px;
            border-radius: 3px;
            font-weight: 600;
            text-transform: uppercase;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            white-space: nowrap;
            line-height: 1;
        }
        .transcript-course-badge svg {
            flex-shrink: 0;
            vertical-align: middle;
        }
        .transcript-course-badge.ready {
            background: #d4edda;
            color: #155724;
        }
        .transcript-course-badge.exists {
            background: #fff3cd;
            color: #856404;
        }
        .transcript-course-badge.invalid {
            background: #f8d7da;
            color: #721c24;
        }
        .transcript-course-name {
            font-size: 9.5px;
            color: #444;
            font-weight: 500;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 180px;
        }
        /* Inline pill tags inside transcript course cards */
        .tci-pill {
            display: inline-block;
            font-size: 8px;
            font-weight: 700;
            padding: 1px 5px;
            border-radius: 10px;
            line-height: 1.4;
            white-space: nowrap;
        }
        .tci-pill--year { background: #e8f0fe; color: #174DA4; }
        .tci-pill--sem  { background: #e8f5e9; color: #2e7d32; }
        .tci-pill--cu   { background: #fff3e0; color: #e65100; }
        /* Copy-from-transcript options bar */
        .copy-options-bar {
            display: flex;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
            padding: 9px 14px;
            background: #f0f5ff;
            border: 1px solid #d0e3ff;
            border-radius: 3px;
            margin-top: 10px;
        }
        .cpy-radio-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .cpy-radio-label {
            font-size: 10px;
            font-weight: 700;
            color: #333;
            white-space: nowrap;
        }
        .cpy-rbl { display: inline-block; }
        .cpy-rbl table { border-collapse: collapse; }
        .cpy-rbl td { padding: 0 10px 0 0; font-size: 10px; white-space: nowrap; line-height: 1.6; }
        .cpy-rbl input[type="radio"] { cursor: pointer; margin-right: 3px; vertical-align: middle; }
        .cpy-rbl label { cursor: pointer; }
        .copy-actions-row {
            display: flex;
            justify-content: flex-end;
            gap: 6px;
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px solid #e0e0e0;
        }
        
        /* =============================================
           COURSES TAB - Toolbar & Summary
           ============================================= */
        .courses-tab-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 8px;
            background: #f8f9fa;
            border-bottom: 2px solid #174DA4;
            margin: -8px -6px 8px -6px;
        }
        .courses-tab-toolbar .toolbar-title {
            font-size: 11px;
            font-weight: 700;
            color: #174DA4;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .courses-tab-toolbar .toolbar-title svg {
            width: 13px;
            height: 13px;
        }
        .courses-tab-toolbar .toolbar-count {
            display: inline-block;
            padding: 1px 8px;
            background: #e8e0f3;
            color: #174DA4;
            font-size: 10px;
            font-weight: 600;
            min-width: 20px;
            text-align: center;
            border-radius: 2px;
        }
        .courses-tab-toolbar .toolbar-spacer {
            flex: 1;
        }
        .courses-tab-summary {
            display: flex;
            gap: 12px;
            padding: 5px 8px;
            background: #f0f5ff;
            border: 1px solid #d0e3ff;
            border-radius: 3px;
            margin-bottom: 8px;
            font-size: 10px;
            color: #333;
        }
        .courses-tab-summary .summary-item {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .courses-tab-summary .summary-item strong {
            color: #174DA4;
        }
        .courses-tab-summary .summary-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            display: inline-block;
        }
        .courses-tab-summary .dot-core { background: #174DA4; }
        .courses-tab-summary .dot-elective { background: #28a745; }
        .courses-tab-summary .dot-credits { background: #ff9800; }
        
        /* =============================================
           STRUCTURE TAB - Batch Delete
           ============================================= */
        .struct-toolbar {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .struct-select-all-label {
            font-size: 10px;
            font-weight: 600;
            color: #555;
            display: flex;
            align-items: center;
            gap: 4px;
            cursor: pointer;
            white-space: nowrap;
            padding: 4px 6px;
            border: 1px solid #ddd;
            background: #f5f5f5;
        }
        .struct-select-all-label:hover { background: #e8e8e8; }
        .struct-select-all-label input[type="checkbox"] {
            cursor: pointer;
            width: 13px;
            height: 13px;
        }
        .cd-btn--danger {
            background: #dc3545 !important;
            color: #fff !important;
            border: 1px solid #c82333 !important;
            padding: 4px 10px !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            cursor: pointer !important;
        }
        .cd-btn--danger:hover { background: #c82333 !important; }
        .struct-sel-badge {
            display: inline-block;
            min-width: 18px;
            padding: 0 5px;
            background: #dc3545;
            color: #fff;
            border-radius: 10px;
            font-size: 9px;
            font-weight: 700;
            text-align: center;
            line-height: 16px;
        }
        .course-item.selected-for-delete {
            background: #fff5f5 !important;
            border-color: #dc3545 !important;
        }

        /* =============================================
           BATCH OPERATIONS TOOLBAR (Main Grid)
           ============================================= */
        .batch-ops-bar {
            display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
            padding: 7px 12px;
            background: #eef2fb;
            border-bottom: 1px solid #c8d8f8;
            transition: background 0.2s;
        }
        .batch-ops-bar.bar-active { background: #dbeafe; border-bottom-color: #174DA4; }
        .batch-sel-info {
            font-size: 10px; font-weight: 700; color: #174DA4;
            display: flex; align-items: center; gap: 5px; white-space: nowrap;
        }
        .batch-sel-count {
            display: inline-block; background: #174DA4; color: white;
            border-radius: 10px; padding: 1px 9px; min-width: 24px;
            text-align: center; font-size: 11px;
        }
        .batch-sep { width: 1px; height: 20px; background: #c8d8f8; margin: 0 3px; flex-shrink: 0; }
        .bat-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 4px 9px; font-size: 10px; font-weight: 600;
            cursor: pointer; border: 1px solid; white-space: nowrap;
            background: white; transition: background .15s, color .15s, border-color .15s;
            line-height: 1.4;
        }
        .bat-btn svg { width: 11px; height: 11px; flex-shrink: 0; }
        .bat-btn.bat-green  { color: #155724; border-color: #b7ddc0; }
        .bat-btn.bat-green:hover  { background: #28a745; color: white; border-color: #28a745; }
        .bat-btn.bat-orange { color: #7a4500; border-color: #ffd08a; }
        .bat-btn.bat-orange:hover { background: #fd7e14; color: white; border-color: #e8660c; }
        .bat-btn.bat-blue   { color: #004085; border-color: #b8daff; }
        .bat-btn.bat-blue:hover   { background: #007bff; color: white; border-color: #0062cc; }
        .bat-btn.bat-teal   { color: #0c5460; border-color: #bee5eb; }
        .bat-btn.bat-teal:hover   { background: #17a2b8; color: white; border-color: #138496; }
        .bat-btn.bat-red    { color: #721c24; border-color: #f5c6cb; }
        .bat-btn.bat-red:hover    { background: #dc3545; color: white; border-color: #dc3545; }
        .bat-btn.bat-dis    { opacity: 0.35; cursor: default !important; pointer-events: none; }
        .batch-result-msg {
            padding: 7px 14px; font-size: 11px;
            border-left: 4px solid; display: flex; align-items: center; gap: 7px;
        }
        .batch-result-msg.ok  { background: #d4edda; border-color: #28a745; color: #155724; }
        .batch-result-msg.err { background: #f8d7da; border-color: #dc3545; color: #721c24; }
        .batch-result-msg.inf { background: #cce5ff; border-color: #007bff; color: #004085; }

        /* Active / Inactive status badge */
        .status-badge { display: inline-block; padding: 1px 9px; border-radius: 10px; font-size: 10px; font-weight: 700; letter-spacing: .3px; white-space: nowrap; }
        .status-active   { background: #d4edda; color: #155724; border: 1px solid #b7ddc0; }
        .status-inactive { background: #e9ecef; color: #666; border: 1px solid #ced4da; }
        /* Dim inactive rows */
        tr.row-inactive > td { background-color: #fafafa !important; color: #aaa !important; }
        tr.row-inactive > td a, tr.row-inactive > td button { opacity: 0.45; }
        /* Grey batch button */
        .bat-btn.bat-grey { color: #3d4555; border-color: #c8ccd6; }
        .bat-btn.bat-grey:hover { background: #6c757d; color: white; border-color: #545b62; }

        /* ===========================
           SMART FILTER BAR
           =========================== */
        .sfilter-bar {
            display: flex; align-items: stretch; flex-wrap: wrap;
            background: linear-gradient(135deg, #f5f8ff 0%, #f0f4fc 100%);
            border-bottom: 2px solid #dde5f5;
        }
        .sfilter-bar.bar-filtered { border-bottom-color: #174DA4; background: linear-gradient(135deg, #eef3ff 0%, #e6edfa 100%); }
        .sfilter-group {
            display: flex; align-items: center; gap: 6px;
            padding: 8px 13px; border-right: 1px solid #e2e8f5;
            min-height: 44px; box-sizing: border-box;
        }
        .sfilter-label {
            font-size: 9px; font-weight: 700; text-transform: uppercase;
            letter-spacing: .5px; color: #8a97b4; white-space: nowrap;
        }
        .sfilter-icon { color: #8a97b4; display: flex; flex-shrink: 0; }
        .sfilter-search-wrap { display: flex; align-items: center; gap: 3px; }
        .sfilter-input {
            border: none; background: transparent; font-size: 12px; color: #333;
            outline: none; width: 200px; padding: 2px 0;
        }
        .sfilter-input::placeholder { color: #b5bfd5; font-style: italic; }
        .sfilter-input:focus { background: white; border-radius: 3px; padding: 2px 7px; box-shadow: 0 0 0 2px #b8d0f8; transition: all .15s; }
        .sfilter-x {
            background: none; border: none; padding: 0 3px; color: #c5cfe0;
            cursor: pointer; font-size: 15px; line-height: 1; flex-shrink: 0;
        }
        .sfilter-x:hover { color: #dc3545; }
        .sfilter-select {
            border: 1px solid #d0d9f0; border-radius: 4px; background: white;
            font-size: 11px; color: #333; padding: 5px 26px 5px 8px; cursor: pointer;
            min-width: 130px; outline: none;
            -webkit-appearance: none; appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='5' viewBox='0 0 8 5'%3E%3Cpath d='M0 0l4 5 4-5z' fill='%23aab'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 8px center;
            transition: border-color .15s, box-shadow .15s;
        }
        .sfilter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px #b8d0f8; }
        .sfilter-select.sf-active { border-color: #174DA4; background-color: #eef3ff; color: #174DA4; font-weight: 600; }
        .sfilter-select--sm { min-width: 95px; }
        .sfilter-actions {
            display: flex; align-items: center; gap: 6px;
            padding: 8px 14px 8px 10px; margin-left: auto;
        }
        .sfilter-apply-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 6px 15px; font-size: 10px; font-weight: 700; letter-spacing: .2px;
            background: #174DA4; color: white !important; border: none; border-radius: 4px;
            cursor: pointer; white-space: nowrap; text-decoration: none !important;
            transition: background .15s; line-height: 1.3;
        }
        .sfilter-apply-btn:hover { background: #1360c8; color: white !important; }
        .sfilter-clear-btn {
            display: inline-flex; align-items: center; gap: 3px;
            font-size: 10px; color: #dc3545 !important; cursor: pointer; background: none;
            border: 1px solid #f5c6cb; padding: 5px 10px; border-radius: 4px;
            transition: background .15s, border-color .15s; white-space: nowrap;
            text-decoration: none !important; line-height: 1.3;
        }
        .sfilter-clear-btn:hover { background: #fff0f0; border-color: #dc3545; }
        /* Active chips strip */
        .sfilter-chips {
            display: flex; align-items: center; flex-wrap: wrap; gap: 5px;
            padding: 5px 14px; background: #eef3ff; border-bottom: 1px solid #c8d8f8;
        }
        .sfilter-chips-label {
            font-size: 9px; font-weight: 700; text-transform: uppercase;
            letter-spacing: .4px; color: #8a97b4; margin-right: 2px; white-space: nowrap;
        }
        .sfchip {
            display: inline-flex; align-items: center; gap: 3px;
            background: white; border: 1px solid #b8ccf0; color: #174DA4;
            border-radius: 10px; padding: 2px 10px; font-size: 10px; font-weight: 600;
        }
        .sfilter-result-count { margin-left: auto; font-size: 10px; color: #555; white-space: nowrap; }
        .sfilter-result-count strong { color: #174DA4; font-weight: 700; }

        /* ---- Per-page selector ---- */
        .per-page-wrap {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 11px; color: #666;
        }
        .per-page-wrap label { font-weight: 600; white-space: nowrap; }
        .per-page-select {
            border: 1px solid #d0d9f0; border-radius: 4px; background: white;
            font-size: 11px; color: #174DA4; font-weight: 700;
            padding: 4px 24px 4px 8px; cursor: pointer; outline: none;
            -webkit-appearance: none; appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='5' viewBox='0 0 8 5'%3E%3Cpath d='M0 0l4 5 4-5z' fill='%23174DA4'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 7px center;
            transition: border-color .15s, box-shadow .15s;
        }
        .per-page-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px #b8d0f8; }

        /* Spinner for AJAX loading */
        .transcript-spinner {
            width: 28px;
            height: 28px;
            border: 3px solid #e0e0e0;
            border-top: 3px solid #174DA4;
            border-radius: 50%;
            animation: transcriptSpin 0.8s linear infinite;
            margin: 0 auto;
        }
        @keyframes transcriptSpin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .transcript-loading-overlay {
            text-align: center;
            padding: 30px 20px;
        }
        .transcript-loading-overlay .transcript-loading-text {
            margin-top: 10px;
            font-size: 11px;
            color: #666;
            font-weight: 500;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<!-- ======= PAGE HEADER =========================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><line x1="6" y1="3" x2="6" y2="15"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M18 9a9 9 0 0 1-9 9"/></svg>
        </div>
        <div>
            <div class="cd-page-header__title">Specialisations</div>
            <div class="cd-page-header__sub">Manage academic programme specialisation tracks</div>
        </div>
    </div>
</div>
    <div class="cd-card">
        <div class="cd-card__header">
            <h3 class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                Programme Specialisations
            </h3>
            <div class="cd-card__actions">
                <asp:LinkButton ID="cmdAddNew" runat="server" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="cmdAddNew_Click">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add New
                </asp:LinkButton>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <!-- ====== Smart Filter Bar ====== -->
            <asp:Panel ID="pnlFilterBar" runat="server" CssClass="sfilter-bar">
                <!-- Search -->
                <div class="sfilter-group">
                    <span class="sfilter-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                    <div class="sfilter-search-wrap">
                        <asp:TextBox ID="txtFilterSearch" runat="server" CssClass="sfilter-input"
                            placeholder="Search name or abbreviation&#x2026;" autocomplete="off" MaxLength="100" />
                        <button type="button" class="sfilter-x" id="btnClearSearchX"
                            onclick="clearFilterSearchJS()" title="Clear search" style="display:none">&#x2715;</button>
                    </div>
                </div>
                <!-- Programme -->
                <div class="sfilter-group">
                    <span class="sfilter-label">Programme</span>
                    <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="sfilter-select"
                        AutoPostBack="True" OnSelectedIndexChanged="ddlFilter_Changed" />
                </div>
                <!-- Fully Set -->
                <div class="sfilter-group">
                    <span class="sfilter-label">Fully Set</span>
                    <asp:DropDownList ID="ddlFilterFullySet" runat="server" CssClass="sfilter-select sfilter-select--sm"
                        AutoPostBack="True" OnSelectedIndexChanged="ddlFilter_Changed">
                        <asp:ListItem Value="" Text="&#8212; All &#8212;" />
                        <asp:ListItem Value="Yes" Text="&#10003;  Yes" />
                        <asp:ListItem Value="No" Text="&#10007;  No" />
                    </asp:DropDownList>
                </div>
                <!-- Status -->
                <div class="sfilter-group">
                    <span class="sfilter-label">Status</span>
                    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="sfilter-select sfilter-select--sm"
                        AutoPostBack="True" OnSelectedIndexChanged="ddlFilter_Changed">
                        <asp:ListItem Value="" Text="&#8212; All &#8212;" />
                        <asp:ListItem Value="Active" Text="&#9679;  Active" />
                        <asp:ListItem Value="Inactive" Text="&#9675;  Inactive" />
                    </asp:DropDownList>
                </div>
                <!-- Actions -->
                <div class="sfilter-actions">
                    <asp:LinkButton ID="btnApplySearch" runat="server" CssClass="sfilter-apply-btn" OnClick="btnApplySearch_Click">
                        <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        Search
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="sfilter-clear-btn"
                        OnClick="btnClearFilters_Click" Visible="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                        Clear All
                    </asp:LinkButton>
                </div>
            </asp:Panel>
            <!-- Active filter chips -->
            <asp:Panel ID="pnlFilterChips" runat="server" Visible="false" CssClass="sfilter-chips">
                <span class="sfilter-chips-label">Filters:</span>
                <asp:Literal ID="litFilterChips" runat="server" />
                <span class="sfilter-result-count"><asp:Label ID="lblFilteredCount" runat="server" /></span>
            </asp:Panel>
            <!-- ====== Batch Operations Toolbar ====== -->
            <div id="divBatchBar" class="batch-ops-bar">
                <div class="batch-sel-info">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                    <span id="spanBatchCount" class="batch-sel-count">0</span>
                    <span>selected</span>
                </div>
                <div class="batch-sep"></div>
                <button type="button" class="bat-btn bat-green bat-dis" onclick="doBatch('fully_set_yes')" title="Mark selected as Fully Configured">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Mark Fully Set
                </button>
                <button type="button" class="bat-btn bat-orange bat-dis" onclick="doBatch('fully_set_no')" title="Mark selected as Not Fully Configured">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    Mark Not Set
                </button>
                <div class="batch-sep"></div>
                <button type="button" class="bat-btn bat-teal bat-dis" onclick="doBatch('set_active')" title="Mark selected as Active">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                    Set Active
                </button>
                <button type="button" class="bat-btn bat-grey bat-dis" onclick="doBatch('set_inactive','Set {n} specialisation(s) as Inactive?\n\nInactive specialisations will be hidden from student-facing views.')" title="Mark selected as Inactive">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                    Set Inactive
                </button>
                <div class="batch-sep"></div>
                <button type="button" class="bat-btn bat-blue bat-dis" onclick="doBatch('print_pdf')" title="Print Course Structures for selected">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                    Print PDFs
                </button>
                <button type="button" class="bat-btn bat-teal bat-dis" onclick="doBatch('export_csv')" title="Export selected to CSV">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                    Export CSV
                </button>
                <div class="batch-sep"></div>
                <button type="button" class="bat-btn bat-red bat-dis" onclick="doBatch('delete','Delete {n} specialisation(s)?\n\nNote: Those with existing courses will be skipped automatically.')" title="Delete selected (skips those with courses)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path></svg>
                    Delete Selected
                </button>
                <span style="flex:1;"></span>
                <span style="font-size:9px;color:#aaa;font-style:italic;">Tick rows to enable actions</span>
            </div>
            <!-- Batch Result Message -->
            <asp:Panel ID="pnlBatchResult" runat="server" Visible="false">
                <asp:Label ID="lblBatchResult" runat="server"></asp:Label>
            </asp:Panel>
            <!-- Hidden batch controls -->
            <asp:HiddenField ID="hdnBatchIds" runat="server" />
            <asp:HiddenField ID="hdnBatchAction" runat="server" />
            <asp:Button ID="btnBatchExecute" runat="server" OnClick="btnBatchExecute_Click" style="display:none;" />
            <!-- ====== Main Grid ====== -->
            <dx:ASPxGridView ID="gvMain" runat="server" AutoGenerateColumns="False" DataSourceID="dsMain" 
                KeyFieldName="spec_id" Width="100%" 
                EnableTheming="True" Theme="Glass"
                ClientInstanceName="gvMain"
                OnRowInserting="gvMain_RowInserting"
                OnRowUpdating="gvMain_RowUpdating"
                OnRowDeleting="gvMain_RowDeleting"
                OnCustomErrorText="gvMain_CustomErrorText"
                OnHtmlRowCreated="gvMain_HtmlRowCreated"
                EnableCallBacks="false">
                <Settings ShowFilterRow="False" ShowFilterRowMenu="False" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="True" AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="Inline" />
                <SettingsDataSecurity AllowDelete="True" />
                <SettingsPager PageSize="20" Mode="ShowPager" />
                <SettingsCommandButton>
                    <UpdateButton Text="Save" />
                    <CancelButton Text="Cancel" />
                    <EditButton Text="Edit" />
                    <DeleteButton Text="Delete" />
                    <NewButton Text="New" />
                </SettingsCommandButton>
                <Columns>
                    <dx:GridViewDataTextColumn Caption="" Width="32px" VisibleIndex="0" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderTemplate>
                            <input type="checkbox" class="spec-sel-all" onchange="toggleSelectAll(this)" style="cursor:pointer;width:13px;height:13px;" title="Select / Deselect All" />
                        </HeaderTemplate>
                        <DataItemTemplate>
                            <input type="checkbox" class="spec-row-chk" data-specid='<%# Eval("spec_id") %>' onchange="updateBatchBar()" style="cursor:pointer;width:13px;height:13px;" />
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" ShowNewButtonInHeader="False" VisibleIndex="1" Width="80px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="spec_id" VisibleIndex="1" Caption="ID" Width="50px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="prog_id" VisibleIndex="2" Caption="Programme" Width="250px">
                        <PropertiesComboBox DataSourceID="dsProgrammes" 
                            TextField="progname" 
                            ValueField="progcode"
                            IncrementalFilteringMode="Contains">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Programme is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataTextColumn FieldName="spec" VisibleIndex="3" Caption="Specialisation Name">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Specialisation Name is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="abbrev" VisibleIndex="4" Caption="Abbrev" Width="80px">
                        <PropertiesTextEdit MaxLength="20">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Abbreviation is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="is_fully_set" VisibleIndex="5" Caption="Fully Set" Width="70px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="Yes" Value="Yes" />
                                <dx:ListEditItem Text="No" Value="No" />
                            </Items>
                        </PropertiesComboBox>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="is_active" VisibleIndex="6" Caption="Status" Width="75px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="Active" Value="Active" />
                                <dx:ListEditItem Text="Inactive" Value="Inactive" />
                            </Items>
                        </PropertiesComboBox>
                        <DataItemTemplate>
                            <%# Convert.ToString(Eval("is_active")) == "Inactive" ? "<span class='status-badge status-inactive'>&#9679; Inactive</span>" : "<span class='status-badge status-active'>&#9679; Active</span>" %>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataTextColumn FieldName="course_count" VisibleIndex="7" Caption="Courses" Width="60px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <span class="course-count-badge"><%# Eval("course_count") %></span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn VisibleIndex="8" Caption="Actions" Width="140px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <div style="display: flex; gap: 4px; justify-content: center;">
                                <a href="javascript:void(0);" class="manage-courses-btn" 
                                    onclick="openManageCourses(<%# Eval("spec_id") %>); return false;" title="Manage Courses">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                                    Manage
                                </a>
                                <a href="javascript:void(0);" class="print-structure-btn" 
                                    onclick="printStructure(<%# Eval("spec_id") %>); return false;" title="Print Course Structure">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                                    PDF
                                </a>
                            </div>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="12px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="11px" />
                </Styles>
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Summary Panel -->
    <div class="cd-card cd-mt-3">
        <div class="cd-card__body" style="padding: 8px 14px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                <!-- Left: totals -->
                <div style="font-size: 12px; color: #555; display: flex; align-items: center; gap: 14px;">
                    <span>
                        <strong style="color:#333">Total:</strong>&nbsp;
                        <asp:Label ID="lblTotalCount" runat="server" Text="0" CssClass="cd-badge cd-badge--primary"></asp:Label>
                        &nbsp;<span style="color:#999;font-size:10px">specialisation(s)</span>
                    </span>
                    <asp:Label ID="lblFilterInfo" runat="server" Text="" style="font-size:11px;color:#888;"></asp:Label>
                </div>
                <!-- Right: per-page -->
                <div class="per-page-wrap">
                    <label for="<%= ddlPageSize.ClientID %>">Rows per page:</label>
                    <asp:DropDownList ID="ddlPageSize" runat="server"
                        CssClass="per-page-select"
                        AutoPostBack="True"
                        OnSelectedIndexChanged="ddlPageSize_Changed">
                        <asp:ListItem Value="10"  Text="10" />
                        <asp:ListItem Value="20"  Text="20" Selected="True" />
                        <asp:ListItem Value="50"  Text="50" />
                        <asp:ListItem Value="100" Text="100" />
                        <asp:ListItem Value="200" Text="200" />
                        <asp:ListItem Value="0"   Text="All" />
                    </asp:DropDownList>
                    <span id="spanPageInfo" style="font-size:10px;color:#999;margin-left:2px;"></span>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Manage Courses Popup -->
    <dx:ASPxPopupControl ID="popManageCourses" runat="server" 
        HeaderText="Manage Specialisation Courses" 
        Width="1050px" Height="620px"
        Modal="True" 
        CloseAction="CloseButton"
        PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter"
        ClientInstanceName="popManageCourses"
        EnableCallbackMode="false"
        CssClass="cd-popup">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Size="13px" Font-Bold="True" Paddings-Padding="10px" />
        <ContentStyle Paddings-Padding="0px" />
        <CloseButtonStyle Paddings-Padding="8px" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <asp:HiddenField ID="hdnSpecId" runat="server" />
                <asp:HiddenField ID="hdnProgCode" runat="server" />
                <asp:HiddenField ID="hdnSelectedSpecId" runat="server" />
                <asp:Button ID="btnOpenManage" runat="server" OnClick="btnOpenManage_Click" style="display:none;" />
                
                <div class="popup-body">
                    <div class="popup-info-bar">
                        <span><strong>Specialisation:</strong> <asp:Literal ID="litSpecName" runat="server"></asp:Literal><asp:Label ID="lblSpecName" runat="server" CssClass="info-value"></asp:Label></span>
                        <span class="separator">|</span>
                        <span><strong>Programme:</strong> <asp:Literal ID="litProgName" runat="server"></asp:Literal><asp:Label ID="lblProgName" runat="server" CssClass="info-value"></asp:Label></span>
                    </div>
                    
                    <dx:ASPxPageControl ID="tabCourses" runat="server" ActiveTabIndex="0" Width="100%" CssClass="cd-tabs">
                        <TabStyle Font-Size="10px" Paddings-PaddingLeft="10px" Paddings-PaddingRight="10px" Paddings-PaddingTop="5px" Paddings-PaddingBottom="5px" />
                        <ActiveTabStyle BackColor="Transparent" ForeColor="#174DA4" />
                        <TabPages>
                            <dx:TabPage Text="Batch Add">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content" style="min-height: auto; padding: 6px;">
                                            <div class="batch-grid">
                                                <!-- Year 1 Semester 1 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y1 - S1</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY1S1" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY1S1CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY1S1Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY1S1Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 1 Semester 2 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y1 - S2</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY1S2" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY1S2CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY1S2Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY1S2Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 1 Semester 3 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y1 - S3</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY1S3" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY1S3CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY1S3Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY1S3Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 2 Semester 1 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y2 - S1</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY2S1" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY2S1CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY2S1Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY2S1Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 2 Semester 2 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y2 - S2</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY2S2" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY2S2CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY2S2Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY2S2Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 2 Semester 3 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y2 - S3</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY2S3" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY2S3CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY2S3Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY2S3Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 3 Semester 1 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y3 - S1</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY3S1" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY3S1CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY3S1Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY3S1Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 3 Semester 2 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y3 - S2</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY3S2" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY3S2CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY3S2Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY3S2Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 3 Semester 3 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y3 - S3</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY3S3" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY3S3CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY3S3Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY3S3Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 4 Semester 1 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y4 - S1</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY4S1" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY4S1CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY4S1Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY4S1Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 4 Semester 2 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y4 - S2</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY4S2" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY4S2CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY4S2Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY4S2Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                                <!-- Year 4 Semester 3 -->
                                                <div class="batch-year-section">
                                                    <div class="batch-year-header">Y4 - S3</div>
                                                    <div class="batch-year-body">
                                                        <div class="batch-field-row">
                                                            <div class="batch-courses-field">
                                                                <asp:TextBox ID="txtY4S3" runat="server" placeholder="Courses"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:TextBox ID="txtY4S3CU" runat="server" Text="3" MaxLength="2"></asp:TextBox>
                                                            </div>
                                                            <div class="batch-small-field">
                                                                <asp:DropDownList ID="ddlY4S3Type" runat="server">
                                                                    <asp:ListItem Text="C" Value="CORE" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="E" Value="ELECTIVE"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <asp:Panel ID="pnlY4S3Result" runat="server" CssClass="batch-validation-result"></asp:Panel>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="batch-actions">
                                                <div style="display: flex; align-items: center; gap: 6px; margin-right: auto;">
                                                    <span style="font-size: 10px; color: #666;">Set Fully Configured:</span>
                                                    <asp:DropDownList ID="ddlSetFullySet" runat="server" style="font-size: 10px; padding: 3px 6px; border: 1px solid #ddd;">
                                                        <asp:ListItem Text="No" Value="No" Selected="True"></asp:ListItem>
                                                        <asp:ListItem Text="Yes" Value="Yes"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                                <dx:ASPxButton ID="cmdValidateAll" runat="server" Text="Validate All" 
                                                    OnClick="cmdValidateAll_Click" CssClass="cd-btn cd-btn--secondary">
                                                </dx:ASPxButton>
                                                <dx:ASPxButton ID="cmdAddAllBatch" runat="server" Text="Add All Courses" 
                                                    OnClick="cmdAddAllBatch_Click" CssClass="cd-btn cd-btn--primary">
                                                </dx:ASPxButton>
                                            </div>
                                            
                                            <asp:Panel ID="pnlBatchSummary" runat="server" Visible="false">
                                                <div class="batch-result-summary">
                                                    <asp:Literal ID="litBatchSummary" runat="server"></asp:Literal>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Copy from Transcript">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content" style="min-height: auto; padding: 0; max-height: 500px; overflow-y: auto;">
                                            <!-- Context: Current Specialization (outside UpdatePanel - set once) -->
                                            <div class="transcript-context" style="position: sticky; top: 0; z-index: 10;">
                                                <div class="transcript-context-title">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                                    Target Specialisation
                                                </div>
                                                <div class="transcript-context-info">
                                                    <span><strong>Specialisation:</strong> <asp:Label ID="lblContextSpecName" runat="server" style="color: white;"></asp:Label></span>
                                                    <span><strong>Programme:</strong> <asp:Label ID="lblContextProgName" runat="server" style="color: white;"></asp:Label></span>
                                                </div>
                                            </div>
                                            
                                            <asp:UpdatePanel ID="upTranscript" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <div style="padding: 8px;">
                                                        <!-- Loading indicator (shown via JS) -->
                                                        <div id="transcriptLoading" style="display:none; text-align: center; padding: 20px;">
                                                            <div class="transcript-spinner"></div>
                                                            <div style="margin-top: 8px; font-size: 11px; color: #666;">Loading transcript...</div>
                                                        </div>
                                                        
                                                        <!-- Step 1: Student Lookup -->
                                                        <div class="form-section">
                                                            <div class="form-row">
                                                                <div class="form-group" style="width: 300px;">
                                                                    <label class="form-label">
                                                                        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 3px;"><circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.35-4.35"></path></svg>
                                                                        Student Reg No / Entry No
                                                                    </label>
                                                                    <asp:TextBox ID="txtTranscriptRegNo" runat="server" placeholder="Enter reg number or entry number" CssClass="cd-input" MaxLength="30"></asp:TextBox>
                                                                </div>
                                                                <div class="form-group">
                                                                    <asp:Button ID="cmdLoadTranscript" runat="server" Text="Load Transcript" 
                                                                        OnClick="cmdLoadTranscript_Click" CssClass="cd-btn cd-btn--primary" style="margin-top: 17px;" />
                                                                </div>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Step 2: Student Info Panel -->
                                                        <asp:Panel ID="pnlTranscriptStudentInfo" runat="server" Visible="false" style="margin-top: 8px; padding: 10px 12px; background: #f0f5ff; border: 1px solid #d0e3ff; border-radius: 3px; font-size: 11px;">
                                                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px;">
                                                                <div>
                                                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 3px;"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                                                    <strong>Student:</strong> <asp:Label ID="lblTranscriptStudent" runat="server"></asp:Label>
                                                                </div>
                                                                <div>
                                                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 3px;"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                                                    <strong>Programme:</strong> <asp:Label ID="lblTranscriptProgramme" runat="server"></asp:Label>
                                                                </div>
                                                                <div>
                                                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 3px;"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                                                                    <strong>Total Courses:</strong> <asp:Label ID="lblTranscriptCourseCount" runat="server"></asp:Label>
                                                                </div>
                                                                <div>
                                                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 3px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                                                    <strong>Ready:</strong> <asp:Label ID="lblTranscriptValidation" runat="server" CssClass="validation-success"></asp:Label>
                                                                </div>
                                                            </div>
                                                        </asp:Panel>
                                                        
                                                        <!-- Program Mismatch Warning -->
                                                        <asp:Panel ID="pnlProgramMismatch" runat="server" Visible="false" CssClass="transcript-warning">
                                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff6b6b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                                            <div>
                                                                <strong>Warning: Programme Mismatch</strong><br/>
                                                                <asp:Label ID="lblProgramMismatchDetails" runat="server"></asp:Label>
                                                            </div>
                                                        </asp:Panel>
                                                    
                                                        <!-- Step 3: Course List for Review (Compact Grid) -->
                                                        <asp:Panel ID="pnlTranscriptCourseList" runat="server" Visible="false" style="margin-top: 8px;">
                                                            <div style="background: #f8f9fa; padding: 6px 8px; border-bottom: 2px solid #174DA4; font-size: 10px; font-weight: 700; color: #174DA4;">
                                                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                                                                COURSES FROM TRANSCRIPT
                                                            </div>
                                                            <div style="border: 1px solid #e0e0e0; background: #fafafa;">
                                                                <asp:Repeater ID="rptTranscriptCourses" runat="server">
                                                                    <HeaderTemplate>
                                                                        <div class="transcript-courses-compact">
                                                                    </HeaderTemplate>
                                                                    <ItemTemplate>
                                                                        <div class='transcript-course-item status-<%# Eval("Status").ToString().ToLower().Replace(" ", "-") %>'>
                                                                            <div style="flex: 1; min-width: 0;">
                                                                                <div style="display: flex; align-items: center; gap: 4px; flex-wrap: wrap; margin-bottom: 3px;">
                                                                                    <span class="transcript-course-code"><%# Eval("CourseCode") %></span>
                                                                                    <span class="tci-pill tci-pill--year">Y<%# Eval("Year") %></span>
                                                                                    <span class="tci-pill tci-pill--sem">S<%# Eval("Semester") %></span>
                                                                                    <span class="tci-pill tci-pill--cu"><%# Eval("CreditUnits") %>CU</span>
                                                                                </div>
                                                                                <div class="transcript-course-name" title='<%# Eval("CourseName") %>'><%# Eval("CourseName") %></div>
                                                                                <div class="transcript-course-meta">Grade: <strong><%# Eval("Grade") %></strong></div>
                                                                            </div>
                                                                            <span class='transcript-course-badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'><%# GetStatusBadgeText(Eval("Status").ToString()) %></span>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                    <FooterTemplate>
                                                                        </div>
                                                                    </FooterTemplate>
                                                                </asp:Repeater>
                                                            </div>
                                                        </asp:Panel>
                                                        
                                                        <!-- Step 4: Summary Panel -->
                                                        <asp:Panel ID="pnlTranscriptSummary" runat="server" Visible="false" style="margin-top: 8px; padding: 8px; background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 3px; font-size: 11px;">
                                                            <asp:Literal ID="litTranscriptSummary" runat="server"></asp:Literal>
                                                        </asp:Panel>
                                                        
                                                        <!-- Step 5: Action Buttons -->
                                                        <asp:Panel ID="pnlTranscriptActions" runat="server" Visible="false">
                                                            <div class="copy-options-bar">
                                                                <div class="cpy-radio-wrap">
                                                                    <span class="cpy-radio-label">Fully Configured:</span>
                                                                    <asp:RadioButtonList ID="rblTranscriptFullySet" runat="server"
                                                                        RepeatDirection="Horizontal" CssClass="cpy-rbl">
                                                                        <asp:ListItem Text="Yes" Value="Yes" Selected="True"></asp:ListItem>
                                                                        <asp:ListItem Text="No" Value="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                                <div class="cpy-radio-wrap">
                                                                    <span class="cpy-radio-label">Status:</span>
                                                                    <asp:RadioButtonList ID="rblTranscriptIsActive" runat="server"
                                                                        RepeatDirection="Horizontal" CssClass="cpy-rbl">
                                                                        <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                                                        <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </div>
                                                            <div class="copy-actions-row">
                                                                <asp:Button ID="cmdCancelTranscript" runat="server" Text="Cancel" 
                                                                    OnClick="cmdCancelTranscript_Click" CssClass="cd-btn cd-btn--secondary" />
                                                                <asp:Button ID="cmdApplyTranscript" runat="server" Text="Apply Courses to Specialisation" 
                                                                    OnClick="cmdApplyTranscript_Click" CssClass="cd-btn cd-btn--primary" />
                                                            </div>
                                                        </asp:Panel>
                                                        
                                                        <!-- Step 6: Result Message -->
                                                        <asp:Panel ID="pnlTranscriptResult" runat="server" Visible="false" style="margin-top: 8px; padding: 8px; border-left: 3px solid #28a745; background: #d4edda; font-size: 11px;">
                                                            <asp:Literal ID="litTranscriptResult" runat="server"></asp:Literal>
                                                        </asp:Panel>
                                                    </div>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="cmdLoadTranscript" EventName="Click" />
                                                    <asp:AsyncPostBackTrigger ControlID="cmdCancelTranscript" EventName="Click" />
                                                    <asp:AsyncPostBackTrigger ControlID="cmdApplyTranscript" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Structure">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content" style="min-height: auto; padding: 6px;">
                                            <!-- Toolbar: Refresh | Print PDF | [spacer] | Select All | Delete Selected -->
                                            <div class="btn-row btn-row--top struct-toolbar">
                                                <dx:ASPxButton ID="cmdRefreshStructure" runat="server" Text="Refresh" 
                                                    OnClick="cmdRefreshStructure_Click" CssClass="cd-btn cd-btn--secondary">
                                                </dx:ASPxButton>
                                                <dx:ASPxButton ID="cmdPrintStructure" runat="server" Text="Print PDF" 
                                                    OnClick="cmdPrintStructure_Click" CssClass="cd-btn cd-btn--primary">
                                                </dx:ASPxButton>
                                                <span style="flex:1;"></span>
                                                <!-- Select All checkbox -->
                                                <label class="struct-select-all-label" title="Select / Deselect all courses">
                                                    <input type="checkbox" id="chkSelectAllStructure" onchange="toggleSelectAllStructure(this)" />
                                                    Select All
                                                </label>
                                                <!-- Hidden field: comma-separated IDs to delete -->
                                                <asp:HiddenField ID="hdnDeleteIds" runat="server" />
                                                <!-- Delete Selected button -->
                                                <asp:Button ID="cmdDeleteSelectedCourses" runat="server"
                                                    Text="Delete Selected"
                                                    CssClass="cd-btn cd-btn--danger"
                                                    OnClick="cmdDeleteSelectedCourses_Click"
                                                    OnClientClick="return collectAndConfirmStructureDelete(this);" />
                                                <span id="spanStructSelCount" style="font-size:10px;color:#999;display:none;">0 selected</span>
                                            </div>
                                            <!-- Delete result message -->
                                            <asp:Panel ID="pnlStructureDeleteResult" runat="server" Visible="false"
                                                style="margin-bottom:6px; padding: 5px 8px; font-size: 10px;">
                                                <asp:Label ID="lblStructureDeleteResult" runat="server"></asp:Label>
                                            </asp:Panel>
                                            <div class="structure-container">
                                                <asp:Literal ID="litCourseStructure" runat="server"></asp:Literal>
                                            </div>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Courses">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content" style="min-height: auto; padding: 6px;">
                                            <!-- Toolbar -->
                                            <div class="courses-tab-toolbar">
                                                <span class="toolbar-title">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                                                    CURRICULUM COURSES
                                                </span>
                                                <span class="toolbar-count"><asp:Label ID="lblCoursesCount" runat="server" Text="0"></asp:Label></span>
                                                <span class="toolbar-spacer"></span>
                                                <dx:ASPxButton ID="cmdRefreshCourses" runat="server" Text="Refresh" 
                                                    OnClick="cmdRefreshCourses_Click" CssClass="cd-btn cd-btn--secondary">
                                                </dx:ASPxButton>
                                            </div>
                                            
                                            <!-- Summary Bar -->
                                            <asp:Panel ID="pnlCoursesSummary" runat="server">
                                                <div class="courses-tab-summary">
                                                    <div class="summary-item">
                                                        <span class="summary-dot dot-core"></span>
                                                        <span>Core: <strong><asp:Label ID="lblCoreCount" runat="server" Text="0"></asp:Label></strong></span>
                                                    </div>
                                                    <div class="summary-item">
                                                        <span class="summary-dot dot-elective"></span>
                                                        <span>Elective: <strong><asp:Label ID="lblElectiveCount" runat="server" Text="0"></asp:Label></strong></span>
                                                    </div>
                                                    <div class="summary-item">
                                                        <span class="summary-dot dot-credits"></span>
                                                        <span>Total CU: <strong><asp:Label ID="lblTotalCredits" runat="server" Text="0"></asp:Label></strong></span>
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                            
                                            <!-- Courses Grid -->
                                            <dx:ASPxGridView ID="gvSpecCourses" runat="server" AutoGenerateColumns="False" 
                                                KeyFieldName="ID" Width="100%" 
                                                CssClass="cd-grid"
                                                ClientInstanceName="gvSpecCourses"
                                                OnRowUpdating="gvSpecCourses_RowUpdating"
                                                OnRowDeleting="gvSpecCourses_RowDeleting">
                                                <Settings ShowFilterRow="True" />
                                                <SettingsBehavior AllowSort="True" ConfirmDelete="True" />
                                                <SettingsEditing Mode="Inline" />
                                                <SettingsPager PageSize="15" />
                                                <Columns>
                                                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" VisibleIndex="0" Width="70px">
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn FieldName="course_code" Caption="Code" Width="90px" ReadOnly="True">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="courseName" Caption="Course Name" ReadOnly="True">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="study_year" Caption="Year" Width="55px">
                                                        <PropertiesComboBox ValueType="System.Int32">
                                                            <Items>
                                                                <dx:ListEditItem Text="1" Value="1" />
                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                <dx:ListEditItem Text="3" Value="3" />
                                                                <dx:ListEditItem Text="4" Value="4" />
                                                                <dx:ListEditItem Text="5" Value="5" />
                                                            </Items>
                                                        </PropertiesComboBox>
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="semester" Caption="Sem" Width="50px">
                                                        <PropertiesComboBox ValueType="System.Int32">
                                                            <Items>
                                                                <dx:ListEditItem Text="1" Value="1" />
                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                <dx:ListEditItem Text="3" Value="3" />
                                                            </Items>
                                                        </PropertiesComboBox>
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="course_type" Caption="Type" Width="75px">
                                                        <PropertiesComboBox>
                                                            <Items>
                                                                <dx:ListEditItem Text="Core" Value="CORE" />
                                                                <dx:ListEditItem Text="Elective" Value="ELECTIVE" />
                                                            </Items>
                                                        </PropertiesComboBox>
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataSpinEditColumn FieldName="CreditUnit" Caption="CU" Width="55px">
                                                        <PropertiesSpinEdit MinValue="0" MaxValue="20" NumberType="Integer" />
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataSpinEditColumn>
                                                </Columns>
                                                <Styles>
                                                    <Header Font-Size="10px" BackColor="#f5f5f5" Font-Bold="True" />
                                                    <Cell Font-Size="10px" Paddings-Padding="3px" />
                                                    <FilterRow Font-Size="10px" />
                                                    <AlternatingRow BackColor="#fafafa" />
                                                    <CommandColumn Paddings-Padding="2px" />
                                                </Styles>
                                            </dx:ASPxGridView>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Data Sources -->
    <asp:SqlDataSource ID="dsMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT s.spec_id, s.prog_id, s.spec, s.abbrev, s.is_fully_set, s.is_active, p.progname, COALESCE(c.course_count, 0) as course_count FROM acad_specialisation s LEFT JOIN acad_programme p ON s.prog_id = p.progcode LEFT JOIN (SELECT specialisation_id, COUNT(*) as course_count FROM acad_programmecourses GROUP BY specialisation_id) c ON s.spec_id = c.specialisation_id ORDER BY p.progname, s.spec"
        InsertCommand="INSERT INTO acad_specialisation (prog_id, spec, abbrev, is_fully_set, is_active) VALUES (@prog_id, @spec, @abbrev, @is_fully_set, @is_active)"
        UpdateCommand="UPDATE acad_specialisation SET prog_id=@prog_id, spec=@spec, abbrev=@abbrev, is_fully_set=@is_fully_set, is_active=@is_active WHERE spec_id=@spec_id"
        DeleteCommand="DELETE FROM acad_specialisation WHERE spec_id=@spec_id">
        <InsertParameters>
            <asp:Parameter Name="prog_id" Type="String" />
            <asp:Parameter Name="spec" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="is_fully_set" Type="String" DefaultValue="No" />
            <asp:Parameter Name="is_active" Type="String" DefaultValue="Active" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="prog_id" Type="String" />
            <asp:Parameter Name="spec" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="is_fully_set" Type="String" />
            <asp:Parameter Name="is_active" Type="String" />
            <asp:Parameter Name="spec_id" Type="Int32" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="spec_id" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsProgrammes" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT progcode, progname FROM acad_programme ORDER BY progname">
    </asp:SqlDataSource>
    
    <script type="text/javascript">
        function openManageCourses(specId) {
            document.getElementById('<%= hdnSelectedSpecId.ClientID %>').value = specId;
            document.getElementById('<%= btnOpenManage.ClientID %>').click();
        }
        
        function printStructure(specId) {
            window.open('SpecialisationStructurePDF.aspx?specId=' + specId, '_blank');
        }
        
        // ======================================================
        // Structure Tab - Batch Delete Functions
        // ======================================================
        
        /** Toggle all course checkboxes when Select All is clicked */
        function toggleSelectAllStructure(cb) {
            var boxes = document.querySelectorAll('.struct-chk');
            for (var i = 0; i < boxes.length; i++) {
                boxes[i].checked = cb.checked;
                var item = boxes[i].closest('.course-item');
                if (item) item.classList.toggle('selected-for-delete', cb.checked);
            }
            updateStructureDeleteBtn();
        }
        
        /** Called on each individual checkbox change */
        function onStructureCheckChange(cb) {
            var item = cb.closest('.course-item');
            if (item) item.classList.toggle('selected-for-delete', cb.checked);
            updateStructureDeleteBtn();
            // Sync the Select All checkbox indeterminate state
            var all = document.querySelectorAll('.struct-chk');
            var checked = document.querySelectorAll('.struct-chk:checked');
            var selectAll = document.getElementById('chkSelectAllStructure');
            if (selectAll) {
                selectAll.indeterminate = (checked.length > 0 && checked.length < all.length);
                selectAll.checked = (all.length > 0 && checked.length === all.length);
            }
        }
        
        /** Update the Delete button label with selected count */
        function updateStructureDeleteBtn() {
            var checked = document.querySelectorAll('.struct-chk:checked');
            var n = checked.length;
            var btn = document.getElementById('<%= cmdDeleteSelectedCourses.ClientID %>');
            var counter = document.getElementById('spanStructSelCount');
            if (btn) {
                btn.value = (n > 0) ? ('Delete Selected (' + n + ')') : 'Delete Selected';
            }
            if (counter) {
                counter.style.display = (n > 0) ? 'inline' : 'none';
                counter.textContent = n + ' selected';
            }
        }
        
        /** Collect IDs, confirm and submit - called via OnClientClick */
        function collectAndConfirmStructureDelete(btn) {
            var checked = document.querySelectorAll('.struct-chk:checked');
            if (checked.length === 0) {
                alert('Please select at least one course to delete.');
                return false;
            }
            if (!confirm('Delete ' + checked.length + ' selected course(s) from this curriculum?\n\nThis action cannot be undone.')) {
                return false;
            }
            var ids = [];
            for (var i = 0; i < checked.length; i++) {
                ids.push(checked[i].getAttribute('data-id'));
            }
            document.getElementById('<%= hdnDeleteIds.ClientID %>').value = ids.join(',');
            return true;
        }
        
        // ======================================================
        // AJAX loading indicator for transcript UpdatePanel
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_beginRequest(function(sender, args) {
            var panel = args.get_postBackElement();
            if (panel && (panel.id.indexOf('cmdLoadTranscript') >= 0 || 
                          panel.id.indexOf('cmdApplyTranscript') >= 0 ||
                          panel.id.indexOf('cmdCancelTranscript') >= 0)) {
                var loader = document.getElementById('transcriptLoading');
                if (loader) loader.style.display = 'block';
                // Disable buttons during request
                if (panel) panel.disabled = true;
            }
        });
        prm.add_endRequest(function(sender, args) {
            var loader = document.getElementById('transcriptLoading');
            if (loader) loader.style.display = 'none';
        });

        // =====================================================
        // BATCH OPERATIONS - Main Specialisations Grid
        // =====================================================
        function toggleSelectAll(cb) {
            var rows = document.querySelectorAll('.spec-row-chk');
            for (var i = 0; i < rows.length; i++) rows[i].checked = cb.checked;
            updateBatchBar();
        }

        function updateBatchBar() {
            var all     = document.querySelectorAll('.spec-row-chk');
            var checked = document.querySelectorAll('.spec-row-chk:checked');
            var n = checked.length;
            // Count badge
            var badge = document.getElementById('spanBatchCount');
            if (badge) badge.textContent = n;
            // Highlight bar
            var bar = document.getElementById('divBatchBar');
            if (bar) { if (n > 0) bar.classList.add('bar-active'); else bar.classList.remove('bar-active'); }
            // Enable / disable action buttons
            var btns = document.querySelectorAll('.bat-btn');
            for (var i = 0; i < btns.length; i++) {
                if (n > 0) btns[i].classList.remove('bat-dis');
                else       btns[i].classList.add('bat-dis');
            }
            // Sync header checkbox indeterminate state
            var selAll = document.querySelector('.spec-sel-all');
            if (selAll) {
                selAll.indeterminate = (n > 0 && n < all.length);
                selAll.checked       = (all.length > 0 && n === all.length);
            }
        }

        function doBatch(action, confirmMsg) {
            var checked = document.querySelectorAll('.spec-row-chk:checked');
            if (checked.length === 0) return;
            if (confirmMsg) {
                if (!confirm(confirmMsg.replace('{n}', checked.length))) return;
            }
            var ids = [];
            for (var i = 0; i < checked.length; i++) ids.push(checked[i].getAttribute('data-specid'));
            document.getElementById('<%= hdnBatchIds.ClientID %>').value = ids.join(',');
            document.getElementById('<%= hdnBatchAction.ClientID %>').value = action;
            document.getElementById('<%= btnBatchExecute.ClientID %>').click();
        }

        // =====================================================
        // SMART FILTER BAR - client-side helpers
        // =====================================================
        (function () {
            var txt  = document.getElementById('<%= txtFilterSearch.ClientID %>');
            var xBtn = document.getElementById('btnClearSearchX');

            function syncX() {
                if (xBtn) xBtn.style.display = txt && txt.value ? 'block' : 'none';
            }
            if (txt) {
                txt.addEventListener('input', syncX);
                syncX();
            }
        })();

        function clearFilterSearchJS() {
            var txt = document.getElementById('<%= txtFilterSearch.ClientID %>');
            if (txt) { txt.value = ''; txt.form.submit(); }
        }
    </script>

</asp:Content>
