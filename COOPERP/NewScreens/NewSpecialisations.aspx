<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewSpecialisations.aspx.cs" Inherits="COOPERP_NewScreens_NewSpecialisations" Title="Specialisations - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
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
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 4px;
            max-height: 350px;
            overflow-y: auto;
            padding: 4px;
        }
        .transcript-course-item {
            background: white;
            border: 1px solid #e0e0e0;
            padding: 6px 8px;
            font-size: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
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
            <dx:ASPxGridView ID="gvMain" runat="server" AutoGenerateColumns="False" DataSourceID="dsMain" 
                KeyFieldName="spec_id" Width="100%" 
                EnableTheming="True" Theme="Glass"
                ClientInstanceName="gvMain"
                OnRowInserting="gvMain_RowInserting"
                OnRowUpdating="gvMain_RowUpdating"
                OnRowDeleting="gvMain_RowDeleting"
                OnCustomErrorText="gvMain_CustomErrorText"
                EnableCallBacks="false">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
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
                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" ShowNewButtonInHeader="False" VisibleIndex="0" Width="80px">
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
                    <dx:GridViewDataTextColumn FieldName="course_count" VisibleIndex="6" Caption="Courses" Width="60px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <span class="course-count-badge"><%# Eval("course_count") %></span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn VisibleIndex="7" Caption="Actions" Width="140px" ReadOnly="True">
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
        <div class="cd-card__body" style="padding: 10px 15px;">
            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #666;">
                <div>
                    <strong>Total Specialisations:</strong> 
                    <asp:Label ID="lblTotalCount" runat="server" Text="0" CssClass="cd-badge cd-badge--primary"></asp:Label>
                </div>
                <div>
                    <asp:Label ID="lblFilterInfo" runat="server" Text="" ForeColor="#888"></asp:Label>
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
                                                                            <div style="flex: 1;">
                                                                                <div class="transcript-course-code"><%# Eval("CourseCode") %></div>
                                                                                <div style="font-size: 9px; color: #555; margin-top: 1px; font-weight: 500;"><%# Eval("CourseName") %></div>
                                                                                <div class="transcript-course-meta">
                                                                                    Y<%# Eval("Year") %> S<%# Eval("Semester") %> &bull; <%# Eval("CreditUnits") %>CU &bull; Grade: <%# Eval("Grade") %>
                                                                                </div>
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
                                                        <asp:Panel ID="pnlTranscriptActions" runat="server" Visible="false" style="margin-top: 8px; display: flex; gap: 6px; align-items: center; padding-top: 8px; border-top: 1px solid #e0e0e0;">
                                                            <div style="display: flex; align-items: center; gap: 6px; margin-right: auto;">
                                                                <span style="font-size: 10px; color: #666;">Set Fully Configured:</span>
                                                                <asp:DropDownList ID="ddlTranscriptFullySet" runat="server" style="font-size: 10px; padding: 3px 6px; border: 1px solid #ddd;">
                                                                    <asp:ListItem Text="No" Value="No" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="Yes" Value="Yes"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </div>
                                                            <asp:Button ID="cmdCancelTranscript" runat="server" Text="Cancel" 
                                                                OnClick="cmdCancelTranscript_Click" CssClass="cd-btn cd-btn--secondary" />
                                                            <asp:Button ID="cmdApplyTranscript" runat="server" Text="Apply Courses to Specialisation" 
                                                                OnClick="cmdApplyTranscript_Click" CssClass="cd-btn cd-btn--primary" />
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
                                            <div class="btn-row btn-row--top">
                                                <dx:ASPxButton ID="cmdRefreshStructure" runat="server" Text="Refresh" 
                                                    OnClick="cmdRefreshStructure_Click" CssClass="cd-btn cd-btn--secondary">
                                                </dx:ASPxButton>
                                                <dx:ASPxButton ID="cmdPrintStructure" runat="server" Text="Print PDF" 
                                                    OnClick="cmdPrintStructure_Click" CssClass="cd-btn cd-btn--primary">
                                                </dx:ASPxButton>
                                            </div>
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
        SelectCommand="SELECT s.spec_id, s.prog_id, s.spec, s.abbrev, s.is_fully_set, p.progname, COALESCE(c.course_count, 0) as course_count FROM acad_specialisation s LEFT JOIN acad_programme p ON s.prog_id = p.progcode LEFT JOIN (SELECT specialisation_id, COUNT(*) as course_count FROM acad_programmecourses GROUP BY specialisation_id) c ON s.spec_id = c.specialisation_id ORDER BY p.progname, s.spec"
        InsertCommand="INSERT INTO acad_specialisation (prog_id, spec, abbrev, is_fully_set) VALUES (@prog_id, @spec, @abbrev, @is_fully_set)"
        UpdateCommand="UPDATE acad_specialisation SET prog_id=@prog_id, spec=@spec, abbrev=@abbrev, is_fully_set=@is_fully_set WHERE spec_id=@spec_id"
        DeleteCommand="DELETE FROM acad_specialisation WHERE spec_id=@spec_id">
        <InsertParameters>
            <asp:Parameter Name="prog_id" Type="String" />
            <asp:Parameter Name="spec" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="is_fully_set" Type="String" DefaultValue="No" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="prog_id" Type="String" />
            <asp:Parameter Name="spec" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="is_fully_set" Type="String" />
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
    </script>
</asp:Content>
