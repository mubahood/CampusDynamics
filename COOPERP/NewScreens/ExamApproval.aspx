<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ExamApproval.aspx.cs" Inherits="COOPERP_NewScreens_ExamApproval" Title="Exam Approval & Printing - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Page Header */
        .cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .cd-page-header__left { display:flex; align-items:center; gap:12px; }
        .cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
        .cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
        .cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        .cd-page-header__right { display:flex; gap:8px; align-items:center; }
        .cd-page-header .ea-btn--primary { background:rgba(255,255,255,.15); color:#fff; border:1px solid rgba(255,255,255,.3); }
        .cd-page-header .ea-btn--primary:hover { background:rgba(255,255,255,.25); color:#fff; }
        
        /* Stats Summary */
        .ea-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 12px;
            flex-wrap: wrap;
            align-items: center;
        }
        .ea-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 6px 12px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 0;
            font-size: 11px;
        }
        .ea-stat-item__label { color: #666; }
        .ea-stat-item__value { font-weight: 700; color: #174DA4; font-size: 13px; }
        .ea-stat-item--pending { border-left: 3px solid #ffc107; }
        .ea-stat-item--pending .ea-stat-item__value { color: #856404; }
        .ea-stat-item--approved { border-left: 3px solid #28a745; }
        .ea-stat-item--approved .ea-stat-item__value { color: #28a745; }
        .ea-stat-item--total { border-left: 3px solid #174DA4; }
        
        /* Filter Section */
        .ea-filter-panel {
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 12px;
            margin-bottom: 12px;
        }
        .ea-filter-row {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: flex-end;
        }
        .ea-filter-group {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .ea-filter-label {
            font-size: 10px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
        }
        .ea-filter-select {
            border: 1px solid #ddd;
            padding: 6px 8px;
            font-size: 11px;
            min-width: 140px;
            background: #fff;
            border-radius: 0;
        }
        .ea-filter-select:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,0.1); }
        
        /* Action Buttons */
        .ea-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 12px;
        }
        .ea-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 8px 14px;
            font-size: 11px;
            font-weight: 600;
            border: none;
            border-radius: 0;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .ea-btn svg { width: 14px; height: 14px; }
        .ea-btn--primary { background: #174DA4; color: #fff; }
        .ea-btn--primary:hover { background: #0d3a7d; }
        .ea-btn--success { background: #28a745; color: #fff; }
        .ea-btn--success:hover { background: #1e7e34; }
        .ea-btn--danger { background: #dc3545; color: #fff; }
        .ea-btn--danger:hover { background: #bd2130; }
        .ea-btn--warning { background: #ffc107; color: #212529; }
        .ea-btn--warning:hover { background: #e0a800; }
        .ea-btn--outline { background: #fff; color: #495057; border: 1px solid #ddd; }
        .ea-btn--outline:hover { background: #f8f9fa; }
        .ea-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        
        /* Status Badges */
        .ea-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-radius: 0;
        }
        .ea-badge--pending { background: #fff3cd; color: #856404; }
        .ea-badge--approved { background: #d4edda; color: #155724; }
        .ea-badge--pass { background: #d4edda; color: #155724; }
        .ea-badge--fail { background: #f8d7da; color: #721c24; }
        
        /* Mark Cell */
        .ea-mark-cell { 
            display: inline-block;
            padding: 2px 8px;
            font-weight: 700;
            min-width: 35px;
            text-align: center;
            border-radius: 0;
        }
        .ea-mark-cell--pass { background: #d4edda; color: #155724; }
        .ea-mark-cell--fail { background: #f8d7da; color: #721c24; }
        
        /* Card */
        .ea-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
        }
        .ea-card__header {
            padding: 10px 15px;
            background: #f5f7fa;
            border-bottom: 1px solid #e0e0e0;
            border-radius: 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .ea-card__title {
            font-size: 12px;
            font-weight: 600;
            color: #333;
            margin: 0;
        }
        .ea-card__body { padding: 0; }
        
        /* Tabs */
        .ea-tabs {
            display: flex;
            border-bottom: 2px solid #e0e0e0;
            margin-bottom: 15px;
        }
        .ea-tab {
            padding: 10px 20px;
            font-size: 12px;
            font-weight: 500;
            color: #666;
            background: transparent;
            border: none;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
            transition: all 0.2s;
        }
        .ea-tab:hover { color: #174DA4; }
        .ea-tab.active {
            color: #174DA4;
            border-bottom-color: #174DA4;
            font-weight: 600;
        }
        
        /* Tab Panels */
        .ea-tab-panel { display: none; }
        .ea-tab-panel.active { display: block; }
        
        /* Print Options */
        .ea-print-options {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            padding: 15px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 15px;
        }
        .ea-print-option {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .ea-print-option__label {
            font-size: 10px;
            color: #666;
            font-weight: 600;
        }
        
        /* Grid Styling - Improved */
        .ea-grid { border-collapse: collapse; }
        .ea-grid .dxgvHeader td,
        .ea-grid .dxgvHeader_Glass td {
            background: #f5f7fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            color: #495057 !important;
            text-transform: uppercase !important;
            padding: 10px 8px !important;
            border-bottom: 2px solid #174DA4 !important;
        }
        .ea-grid .dxgvDataRow td,
        .ea-grid .dxgvDataRow_Glass td {
            font-size: 11px !important;
            padding: 8px !important;
            border-bottom: 1px solid #e9ecef !important;
            vertical-align: middle !important;
        }
        .ea-grid .dxgvDataRow:hover td,
        .ea-grid .dxgvDataRow_Glass:hover td {
            background: #e3f2fd !important;
        }
        .ea-grid .dxgvSelectedRow td,
        .ea-grid .dxgvSelectedRow_Glass td {
            background: #cce5ff !important;
        }
        .ea-grid .dxgvFocusedRow td,
        .ea-grid .dxgvFocusedRow_Glass td {
            background: #b8daff !important;
        }
        
        /* Approval Summary */
        .ea-approval-summary {
            background: #e8f4fd;
            border: 1px solid #b8daff;
            padding: 12px 15px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .ea-approval-summary__icon {
            width: 40px;
            height: 40px;
            background: #174DA4;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        .ea-approval-summary__text {
            flex: 1;
        }
        .ea-approval-summary__title {
            font-size: 13px;
            font-weight: 600;
            color: #174DA4;
        }
        .ea-approval-summary__desc {
            font-size: 11px;
            color: #666;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Page Header -->
    <div class="cd-page-header">
        <div class="cd-page-header__left">
            <div class="cd-page-header__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            </div>
            <div>
                <div class="cd-page-header__title">Exam Approval</div>
                <div class="cd-page-header__sub">Review and approve student exam eligibility and registrations</div>
            </div>
        </div>
        <div class="cd-page-header__right">
            <asp:Label ID="lblCurrentUser" runat="server" CssClass="ea-badge ea-badge--approved"></asp:Label>
        </div>
    </div>
    
    <!-- Filter Panel -->
    <div class="ea-filter-panel">
        <div class="ea-filter-row">
            <div class="ea-filter-group">
                <span class="ea-filter-label">Campus</span>
                <dx:ASPxComboBox ID="ddlCampus" runat="server" CssClass="ea-filter-select" Width="150px" 
                    AutoPostBack="true" OnSelectedIndexChanged="ddlCampus_SelectedIndexChanged">
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Academic Year</span>
                <dx:ASPxComboBox ID="ddlAcadYear" runat="server" CssClass="ea-filter-select" Width="120px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Semester</span>
                <dx:ASPxComboBox ID="ddlSemester" runat="server" CssClass="ea-filter-select" Width="100px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                    <Items>
                        <dx:ListEditItem Text="-- All --" Value="" Selected="true" />
                        <dx:ListEditItem Text="Sem 1" Value="1" />
                        <dx:ListEditItem Text="Sem 2" Value="2" />
                    </Items>
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Programme</span>
                <dx:ASPxComboBox ID="ddlProgramme" runat="server" CssClass="ea-filter-select" Width="200px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged">
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Study Year</span>
                <dx:ASPxComboBox ID="ddlStudyYear" runat="server" CssClass="ea-filter-select" Width="80px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlStudyYear_SelectedIndexChanged">
                    <Items>
                        <dx:ListEditItem Text="-- All --" Value="" Selected="true" />
                        <dx:ListEditItem Text="1" Value="1" />
                        <dx:ListEditItem Text="2" Value="2" />
                        <dx:ListEditItem Text="3" Value="3" />
                        <dx:ListEditItem Text="4" Value="4" />
                    </Items>
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Session</span>
                <dx:ASPxComboBox ID="ddlSession" runat="server" CssClass="ea-filter-select" Width="100px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged">
                    <Items>
                        <dx:ListEditItem Text="-- All --" Value="" Selected="true" />
                        <dx:ListEditItem Text="Day" Value="DAY" />
                        <dx:ListEditItem Text="Evening" Value="EVENING" />
                        <dx:ListEditItem Text="Weekend" Value="WEEKEND" />
                    </Items>
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Course</span>
                <dx:ASPxComboBox ID="ddlCourse" runat="server" CssClass="ea-filter-select" Width="200px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged">
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Exam Type</span>
                <dx:ASPxComboBox ID="ddlExamStatus" runat="server" CssClass="ea-filter-select" Width="120px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlExamStatus_SelectedIndexChanged">
                    <Items>
                        <dx:ListEditItem Text="-- All --" Value="" Selected="true" />
                        <dx:ListEditItem Text="Regular" Value="REGULAR" />
                        <dx:ListEditItem Text="Retake" Value="RETAKE" />
                        <dx:ListEditItem Text="Supplementary" Value="SUPPLEMENTARY" />
                        <dx:ListEditItem Text="Special" Value="SPECIAL" />
                    </Items>
                </dx:ASPxComboBox>
            </div>
            <div class="ea-filter-group">
                <span class="ea-filter-label">Approval Status</span>
                <dx:ASPxComboBox ID="ddlApprovalFilter" runat="server" CssClass="ea-filter-select" Width="120px"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlApprovalFilter_SelectedIndexChanged">
                    <Items>
                        <dx:ListEditItem Text="All Results" Value="ALL" Selected="true" />
                        <dx:ListEditItem Text="Pending Only" Value="PENDING" />
                        <dx:ListEditItem Text="Approved Only" Value="APPROVED" />
                    </Items>
                </dx:ASPxComboBox>
            </div>
        </div>
    </div>
    
    <!-- Stats Bar -->
    <div class="ea-stats-bar">
        <div class="ea-stat-item ea-stat-item--total">
            <span class="ea-stat-item__label">Total Results:</span>
            <span class="ea-stat-item__value"><asp:Literal ID="litTotalCount" runat="server" Text="0" /></span>
        </div>
        <div class="ea-stat-item ea-stat-item--pending">
            <span class="ea-stat-item__label">Pending Approval:</span>
            <span class="ea-stat-item__value"><asp:Literal ID="litPendingCount" runat="server" Text="0" /></span>
        </div>
        <div class="ea-stat-item ea-stat-item--approved">
            <span class="ea-stat-item__label">Approved:</span>
            <span class="ea-stat-item__value"><asp:Literal ID="litApprovedCount" runat="server" Text="0" /></span>
        </div>
        <div class="ea-stat-item">
            <span class="ea-stat-item__label">Pass Rate:</span>
            <span class="ea-stat-item__value"><asp:Literal ID="litPassRate" runat="server" Text="0%" /></span>
        </div>
    </div>
    
    <!-- Approval Summary (shown when pending results exist) -->
    <asp:Panel ID="pnlApprovalSummary" runat="server" Visible="false">
        <div class="ea-approval-summary">
            <div class="ea-approval-summary__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                    <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                </svg>
            </div>
            <div class="ea-approval-summary__text">
                <div class="ea-approval-summary__title">
                    <asp:Literal ID="litPendingSummary" runat="server" Text="0 results pending approval" />
                </div>
                <div class="ea-approval-summary__desc">
                    Select results below and click "Approve Selected" to approve them. Only Dean or Administrator can approve results.
                </div>
            </div>
        </div>
    </asp:Panel>
    
    <!-- Action Buttons -->
    <div class="ea-actions">
        <dx:ASPxButton ID="btnApproveSelected" runat="server" Text="Approve" CssClass="ea-btn ea-btn--success"
            OnClick="btnApproveSelected_Click" AutoPostBack="true">
            <Image IconID="actions_apply_16x16office2013" />
        </dx:ASPxButton>
        <dx:ASPxButton ID="btnApproveAll" runat="server" Text="Approve All" CssClass="ea-btn ea-btn--primary"
            OnClick="btnApproveAll_Click" AutoPostBack="true">
            <Image IconID="actions_apply_32x32" />
        </dx:ASPxButton>
        <dx:ASPxButton ID="btnCancelApproval" runat="server" Text="Cancel" CssClass="ea-btn ea-btn--danger"
            OnClick="btnCancelApproval_Click" AutoPostBack="true">
            <Image IconID="actions_cancel_16x16office2013" />
        </dx:ASPxButton>
        <dx:ASPxButton ID="btnPrintMarksheet" runat="server" Text="Print" CssClass="ea-btn ea-btn--outline"
            OnClick="btnPrintMarksheet_Click" AutoPostBack="true">
            <Image IconID="print_print_16x16office2013" />
        </dx:ASPxButton>
        <dx:ASPxButton ID="btnExportExcel" runat="server" Text="Excel" CssClass="ea-btn ea-btn--outline"
            OnClick="btnExportExcel_Click" AutoPostBack="true">
            <Image IconID="export_exporttoxlsx_16x16office2013" />
        </dx:ASPxButton>
        <dx:ASPxButton ID="btnExportPDF" runat="server" Text="PDF" CssClass="ea-btn ea-btn--outline"
            OnClick="btnExportPDF_Click" AutoPostBack="true">
            <Image IconID="export_exporttopdf_16x16office2013" />
        </dx:ASPxButton>
    </div>
    
    <!-- Results Grid -->
    <div class="ea-card">
        <div class="ea-card__header">
            <h3 class="ea-card__title">
                <asp:Literal ID="litGridTitle" runat="server" Text="Exam Results" />
            </h3>
            <span style="font-size: 11px; color: #666;">
                <asp:Literal ID="litCourseInfo" runat="server" />
            </span>
        </div>
        <div class="ea-card__body">
            <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" KeyFieldName="ID" 
                CssClass="ea-grid" AutoGenerateColumns="false">
                <SettingsPager PageSize="50" AlwaysShowPager="true" Position="Bottom">
                </SettingsPager>
                <SettingsBehavior AllowFocusedRow="true" ConfirmDelete="true" />
                <Settings ShowFilterRow="true" />
                <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="30px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" VisibleIndex="1" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="2" Width="110px">
                        <Settings AllowAutoFilter="true" />
                        <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="stud_name" Caption="Student Name" VisibleIndex="3" Width="180px">
                        <Settings AllowAutoFilter="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course" VisibleIndex="4" Width="200px">
                        <Settings AllowAutoFilter="true" />
                        <CellStyle Font-Size="10px" ForeColor="#555" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="cw_mark_entered" Caption="CW" VisibleIndex="5" Width="50px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="exam_mark_entered" Caption="Exam" VisibleIndex="6" Width="50px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="total_mark" Caption="Total" VisibleIndex="7" Width="55px">
                        <DataItemTemplate>
                            <%# GetMarkCellHtml(Eval("total_mark")) %>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="grade" Caption="Grade" VisibleIndex="8" Width="45px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gradept" Caption="GP" VisibleIndex="9" Width="40px">
                        <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                        </PropertiesTextEdit>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="approved_by" Caption="Status" VisibleIndex="10" Width="85px">
                        <DataItemTemplate>
                            <%# GetApprovalStatusBadge(Eval("approved_by")) %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="exam_status" Caption="Exam Type" VisibleIndex="11" Width="100px" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_id" Caption="Course Code" VisibleIndex="12" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Acad Year" VisibleIndex="13" Visible="false">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progid" Caption="Programme" VisibleIndex="14" Visible="false">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header BackColor="#f8f9fa" Font-Bold="true" Font-Size="10px" />
                    <Row Font-Size="11px" />
                    <AlternatingRow BackColor="#fafafa" />
                    <FocusedRow BackColor="#e8f4fd" />
                </Styles>
            </dx:ASPxGridView>
            <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvResults">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Message Popup -->
    <dx:ASPxPopupControl ID="popMessage" runat="server" HeaderText="Campus Dynamics" 
        CloseAction="CloseButton" Modal="true" PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter" Width="350px">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px; text-align: center;">
                    <asp:Literal ID="litMessage" runat="server" />
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Print Preview Popup -->
    <dx:ASPxPopupControl ID="popPrintPreview" runat="server" HeaderText="Print Preview" 
        CloseAction="CloseButton" Modal="true" PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter" Width="900px" Height="700px" AllowResize="true"
        ShowMaximizeButton="true">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <dx:ASPxDocumentViewer ID="docViewer" runat="server" Width="100%" Height="600px">
                </dx:ASPxDocumentViewer>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Loading Panel -->
    <dx:ASPxLoadingPanel ID="lpLoading" runat="server" ClientInstanceName="lpLoading" Modal="true" Text="Processing...">
    </dx:ASPxLoadingPanel>
    
    <script type="text/javascript">
        function showLoading() {
            if (typeof lpLoading !== 'undefined') {
                lpLoading.Show();
            }
        }
        function hideLoading() {
            if (typeof lpLoading !== 'undefined') {
                lpLoading.Hide();
            }
        }
    </script>
</asp:Content>
