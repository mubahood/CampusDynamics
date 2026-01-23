<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewSpecialisations.aspx.cs" Inherits="COOPERP_NewScreens_NewSpecialisations" Title="Specialisations - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        /* =============================================
           POPUP SPECIFIC OVERRIDES  
           ============================================= */
        
        /* Popup body container */
        .popup-body {
            padding: 12px;
        }
        
        /* Info bar at top of popup */
        .popup-info-bar {
            background: #f5f5f5;
            padding: 10px 12px;
            margin: -12px -12px 15px -12px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .popup-info-bar .separator {
            color: #ccc;
        }
        .popup-info-bar .info-value {
            color: #422774;
            font-weight: 600;
        }
        
        /* Tab styling inside popup */
        .cd-tabs {
            border: none !important;
        }
        .cd-tabs .dxpLite_Glass,
        .cd-tabs .dxtvControl_Glass,
        .cd-tabs .dxtcLite_Glass {
            border: none !important;
            background: transparent !important;
        }
        
        /* Tab content area */
        .tab-content { 
            padding: 15px 10px;
            min-height: 380px;
        }
        
        /* =============================================
           FORM ELEMENTS IN POPUP  
           ============================================= */
        
        /* Form sections */
        .form-section {
            margin-bottom: 15px;
        }
        
        /* Form labels */
        .form-label { 
            display: block; 
            font-size: 11px; 
            font-weight: 600; 
            color: #666; 
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        
        /* Form layout */
        .form-row { 
            display: flex; 
            gap: 12px; 
            margin-bottom: 15px; 
            align-items: flex-end;
        }
        .form-group { 
            flex: 0 0 auto;
        }
        .form-group--flex {
            flex: 1 1 auto;
        }
        
        /* Input styling */
        .cd-input,
        .cd-combo,
        .cd-input--memo {
            font-size: 12px !important;
        }
        .cd-input--memo { 
            font-family: Consolas, "Courier New", monospace !important; 
        }
        
        /* DevExpress input overrides */
        .cd-input input,
        .cd-combo input,
        .cd-input--memo textarea {
            border: 1px solid #ddd !important;
            padding: 6px 8px !important;
            font-size: 12px !important;
            color: #333 !important;
            background: #fff !important;
        }
        .cd-input input:focus,
        .cd-combo input:focus,
        .cd-input--memo textarea:focus {
            border-color: #422774 !important;
            outline: none !important;
            color: #333 !important;
            background: #fff !important;
        }
        
        /* Fix for combo dropdown selected items */
        .cd-combo .dxeListBoxItemSelected_Glass,
        .cd-combo tr.dxeListBoxItemSelected_Glass td {
            background: #422774 !important;
            color: #fff !important;
        }
        .cd-combo .dxeListBoxItem_Glass:hover,
        .cd-combo tr.dxeListBoxItem_Glass:hover td {
            background: #e8e0f3 !important;
            color: #422774 !important;
        }
        
        /* =============================================
           BUTTONS IN POPUP  
           ============================================= */
        
        /* Button row */
        .btn-row {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            padding-top: 12px;
            margin-top: 15px;
            border-top: 1px solid #e0e0e0;
        }
        .btn-row--top {
            border-top: none;
            border-bottom: 1px solid #e0e0e0;
            padding-top: 0;
            padding-bottom: 12px;
            margin-top: 0;
            margin-bottom: 15px;
        }
        
        /* Secondary button style */
        .cd-btn--secondary {
            background: #f5f5f5 !important;
            color: #333 !important;
            border: 1px solid #ddd !important;
        }
        .cd-btn--secondary:hover {
            background: #e8e8e8 !important;
            border-color: #ccc !important;
        }
        
        /* =============================================
           RESULT PANELS  
           ============================================= */
        
        .result-panel {
            margin-top: 12px;
            padding: 10px 12px;
            font-size: 11px;
            background: #f8f9fa;
        }
        .result-panel.success,
        .validation-success {
            background: #d4edda;
            border-left: 3px solid #28a745;
            color: #155724;
        }
        .result-panel.error,
        .validation-error {
            background: #f8d7da;
            border-left: 3px solid #dc3545;
            color: #721c24;
        }
        .result-panel.info {
            background: #e8e0f3;
            border-left: 3px solid #422774;
            color: #422774;
        }
        
        /* =============================================
           COURSE STRUCTURE TAB  
           ============================================= */
        
        .structure-container {
            max-height: 400px;
            overflow-y: auto;
        }
        
        /* Year-Semester structure table */
        .year-sem-table { 
            width: 100%; 
            border-collapse: collapse; 
            font-size: 11px;
            border: 1px solid #e0e0e0;
        }
        .year-sem-table th, 
        .year-sem-table td { 
            border: 1px solid #e0e0e0; 
            padding: 8px 10px; 
            text-align: left;
            vertical-align: top;
        }
        .year-sem-table th { 
            background: #f8f9fa; 
            font-weight: 600;
            color: #333;
        }
        .year-sem-header { 
            background: #422774 !important; 
            color: #fff !important;
            font-size: 12px;
        }
        
        /* Course items in structure */
        .course-item { 
            padding: 4px 8px; 
            margin: 3px 0; 
            background: #fff;
            border: 1px solid #eee;
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            font-size: 11px;
        }
        .course-item:hover { 
            background: #f8f5fc;
            border-color: #d0c4e8;
        }
        .course-item strong {
            color: #422774;
            margin-right: 8px;
        }
        .course-item .credits {
            background: #f0f0f0;
            padding: 1px 6px;
            font-size: 10px;
            color: #666;
        }
        
        /* =============================================
           ALL COURSES TAB / GRID  
           ============================================= */
        
        .cd-grid {
            font-size: 11px;
        }
        .cd-grid .dxgvHeader_Glass,
        .cd-grid th {
            background: #f5f5f5 !important;
            border-bottom: 2px solid #422774 !important;
            font-weight: 600 !important;
            padding: 6px 8px !important;
        }
        .cd-grid td {
            padding: 5px 8px !important;
            border-bottom: 1px solid #eee !important;
        }
        .cd-grid tr:hover td {
            background: #f8f5fc !important;
        }
        
        /* =============================================
           GRID ACTION BUTTONS  
           ============================================= */
        
        .manage-courses-btn { 
            cursor: pointer; 
            color: #422774; 
            font-size: 10px; 
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            padding: 2px 6px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            transition: all 0.15s ease;
        }
        .manage-courses-btn:hover { 
            background: #422774;
            border-color: #422774;
            color: #fff;
        }
        .manage-courses-btn svg {
            width: 10px;
            height: 10px;
        }
        
        /* Print structure button */
        .print-structure-btn { 
            cursor: pointer; 
            color: #666; 
            font-size: 10px; 
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            padding: 2px 6px;
            background: #fff;
            border: 1px solid #ddd;
            transition: all 0.15s ease;
        }
        .print-structure-btn:hover { 
            background: #28a745;
            border-color: #28a745;
            color: #fff;
        }
        .print-structure-btn svg {
            width: 10px;
            height: 10px;
        }
        
        /* Course count badge */
        .course-count-badge { 
            display: inline-block; 
            padding: 2px 10px; 
            background: #e8e0f3; 
            color: #422774; 
            font-size: 11px; 
            font-weight: 600;
            min-width: 24px;
            text-align: center;
        }
        .course-count-badge:empty::after {
            content: "0";
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
                EnableCallBacks="true">
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
                                <asp:LinkButton ID="btnManageCourses" runat="server" CssClass="manage-courses-btn" 
                                    CommandArgument='<%# Eval("spec_id") + "|" + Eval("spec") + "|" + Eval("prog_id") %>'
                                    OnClick="btnManageCourses_Click" ToolTip="Manage Courses">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                                    Manage
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnPrintStructure" runat="server" CssClass="print-structure-btn" 
                                    CommandArgument='<%# Eval("spec_id") + "|" + Eval("spec") + "|" + Eval("progname") %>'
                                    OnClick="btnPrintStructure_Click" ToolTip="Print Course Structure">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                                    PDF
                                </asp:LinkButton>
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
        Width="900px" Height="600px"
        Modal="True" 
        CloseAction="CloseButton"
        PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter"
        ClientInstanceName="popManageCourses"
        CssClass="cd-popup">
        <HeaderStyle BackColor="#422774" ForeColor="White" Font-Size="13px" Font-Bold="True" Paddings-Padding="10px" />
        <ContentStyle Paddings-Padding="0px" />
        <CloseButtonStyle Paddings-Padding="8px" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <asp:HiddenField ID="hdnSpecId" runat="server" />
                <asp:HiddenField ID="hdnProgCode" runat="server" />
                
                <div class="popup-body">
                    <div class="popup-info-bar">
                        <span><strong>Specialisation:</strong> <asp:Label ID="lblSpecName" runat="server" CssClass="info-value"></asp:Label></span>
                        <span class="separator">|</span>
                        <span><strong>Programme:</strong> <asp:Label ID="lblProgName" runat="server" CssClass="info-value"></asp:Label></span>
                    </div>
                    
                    <dx:ASPxPageControl ID="tabCourses" runat="server" ActiveTabIndex="0" Width="100%" CssClass="cd-tabs">
                        <TabStyle Font-Size="11px" Paddings-PaddingLeft="12px" Paddings-PaddingRight="12px" Paddings-PaddingTop="8px" Paddings-PaddingBottom="8px" />
                        <ActiveTabStyle BackColor="#422774" ForeColor="White" />
                        <TabPages>
                            <dx:TabPage Text="Batch Add Courses">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content">
                                            <div class="form-section">
                                                <label class="form-label">
                                                    Enter course codes separated by comma (e.g., BBA101, BBA102, BBA103):
                                                </label>
                                                <dx:ASPxMemo ID="txtBatchCourses" runat="server" Width="100%" Height="80px" 
                                                    NullText="Enter course codes here..." CssClass="cd-input cd-input--memo">
                                                </dx:ASPxMemo>
                                            </div>
                                            
                                            <div class="form-row">
                                                <div class="form-group" style="width: 70px;">
                                                    <label class="form-label">Year</label>
                                                    <dx:ASPxComboBox ID="cmbBatchYear" runat="server" Width="100%" CssClass="cd-combo">
                                                        <Items>
                                                            <dx:ListEditItem Text="1" Value="1" Selected="True" />
                                                            <dx:ListEditItem Text="2" Value="2" />
                                                            <dx:ListEditItem Text="3" Value="3" />
                                                            <dx:ListEditItem Text="4" Value="4" />
                                                            <dx:ListEditItem Text="5" Value="5" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </div>
                                                <div class="form-group" style="width: 70px;">
                                                    <label class="form-label">Semester</label>
                                                    <dx:ASPxComboBox ID="cmbBatchSemester" runat="server" Width="100%" CssClass="cd-combo">
                                                        <Items>
                                                            <dx:ListEditItem Text="1" Value="1" Selected="True" />
                                                            <dx:ListEditItem Text="2" Value="2" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </div>
                                                <div class="form-group" style="width: 65px;">
                                                    <label class="form-label">Credits</label>
                                                    <dx:ASPxSpinEdit ID="spnBatchCredits" runat="server" Width="100%" 
                                                        Number="3" MinValue="0" MaxValue="20" CssClass="cd-combo">
                                                    </dx:ASPxSpinEdit>
                                                </div>
                                                <div class="form-group" style="width: 90px;">
                                                    <label class="form-label">Type</label>
                                                    <dx:ASPxComboBox ID="cmbBatchCourseType" runat="server" Width="100%" CssClass="cd-combo">
                                                        <Items>
                                                            <dx:ListEditItem Text="Core" Value="CORE" Selected="True" />
                                                            <dx:ListEditItem Text="Elective" Value="ELECTIVE" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </div>
                                                <div class="form-group" style="width: 90px;">
                                                    <label class="form-label">&nbsp;</label>
                                                    <dx:ASPxButton ID="cmdValidateBatch" runat="server" Text="Validate" 
                                                        OnClick="cmdValidateBatch_Click" Width="100%" CssClass="cd-btn cd-btn--secondary">
                                                    </dx:ASPxButton>
                                                </div>
                                            </div>
                                            
                                            <asp:Panel ID="pnlValidationResult" runat="server" Visible="false">
                                                <div class="result-panel">
                                                    <asp:Label ID="lblValidationResult" runat="server"></asp:Label>
                                                </div>
                                            </asp:Panel>
                                            
                                            <div class="btn-row">
                                                <dx:ASPxButton ID="cmdAddBatch" runat="server" Text="Add Courses" 
                                                    OnClick="cmdAddBatch_Click" CssClass="cd-btn cd-btn--primary">
                                                </dx:ASPxButton>
                                            </div>
                                            
                                            <asp:Panel ID="pnlBatchResult" runat="server" Visible="false">
                                                <div class="result-panel">
                                                    <asp:Label ID="lblBatchResult" runat="server"></asp:Label>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Course Structure">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content">
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
                            <dx:TabPage Text="All Courses">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content">
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
                                                    <Header Font-Size="11px" BackColor="#f5f5f5" Font-Bold="True" />
                                                    <Cell Font-Size="11px" Paddings-Padding="4px" />
                                                    <FilterRow Font-Size="11px" />
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
</asp:Content>
