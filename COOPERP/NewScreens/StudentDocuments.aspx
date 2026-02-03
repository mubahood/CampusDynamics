<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentDocuments.aspx.cs" Inherits="COOPERP_NewScreens_StudentDocuments" Title="Student Documents - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Document Stats - Compact Inline */
        .doc-stats-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .doc-stat-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .doc-stat-item__label {
            color: #666;
        }
        .doc-stat-item__value {
            font-weight: 700;
            color: #174DA4;
        }
        .doc-stat-item--complete .doc-stat-item__value { color: #28a745; }
        .doc-stat-item--partial .doc-stat-item__value { color: #ffc107; }
        .doc-stat-item--missing .doc-stat-item__value { color: #dc3545; }
        
        /* Filter Toggle & Row */
        .doc-filter-toggle {
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
        .doc-filter-toggle:hover { background: #f8f9fa; }
        .doc-filter-toggle.active { background: #174DA4; color: #fff; border-color: #174DA4; }
        .doc-filter-toggle svg { width: 12px; height: 12px; }
        .doc-filter-count {
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
        .doc-filter-row {
            display: none;
            gap: 8px;
            padding: 8px 10px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .doc-filter-row.show { display: flex; }
        .doc-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .doc-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .doc-filter-clear {
            padding: 4px 8px;
            font-size: 10px;
            background: #fff;
            border: 1px solid #ddd;
            color: #666;
            cursor: pointer;
        }
        .doc-filter-clear:hover { background: #f0f0f0; }
        
        /* Document Status Badge */
        .doc-status-badge {
            display: inline-block;
            padding: 2px 8px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .doc-status-badge--complete { background: #d4edda; color: #155724; }
        .doc-status-badge--partial { background: #fff3cd; color: #856404; }
        .doc-status-badge--missing { background: #f8d7da; color: #721c24; }
        
        /* Action Button Colors */
        .cd-action-popover__btn--view { color: #174DA4 !important; }
        .cd-action-popover__btn--view:hover { background: #e3f2fd !important; }
        .cd-action-popover__btn--upload { color: #28a745 !important; }
        .cd-action-popover__btn--upload:hover { background: #e8f5e9 !important; }
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
        .doc-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .doc-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .doc-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Document Icon */
        .doc-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            background: #e3f2fd;
            color: #174DA4;
        }
        .doc-icon--pdf { background: #ffebee; color: #c62828; }
        .doc-icon--img { background: #e8f5e9; color: #2e7d32; }
        
        /* Upload Section */
        .doc-upload-section {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            background: #f0f7ff;
            border: 1px solid #b8d4f0;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .doc-upload-section__label {
            font-size: 11px;
            font-weight: 500;
            color: #174DA4;
            white-space: nowrap;
        }
        
        /* Print Styles */
        @media print {
            .cd-batch-ops, .doc-filter-row, .doc-upload-section { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Stats Bar (Compact Inline) -->
    <div class="doc-stats-bar">
        <div class="doc-stat-item">
            <span class="doc-stat-item__label">Total Students:</span>
            <span class="doc-stat-item__value"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></span>
        </div>
        <div class="doc-stat-item doc-stat-item--complete">
            <span class="doc-stat-item__label">Complete Docs:</span>
            <span class="doc-stat-item__value"><asp:Literal ID="litComplete" runat="server" Text="0" /></span>
        </div>
        <div class="doc-stat-item doc-stat-item--partial">
            <span class="doc-stat-item__label">Partial:</span>
            <span class="doc-stat-item__value"><asp:Literal ID="litPartial" runat="server" Text="0" /></span>
        </div>
        <div class="doc-stat-item doc-stat-item--missing">
            <span class="doc-stat-item__label">Missing:</span>
            <span class="doc-stat-item__value"><asp:Literal ID="litMissing" runat="server" Text="0" /></span>
        </div>
        <div style="margin-left: auto;">
            <button type="button" id="btnFilterToggle" class="doc-filter-toggle" onclick="toggleFilters()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                Filters<span id="filterCount" class="doc-filter-count" style="display:none;">0</span>
            </button>
        </div>
    </div>
    
    <!-- Filters (Hidden by default) -->
    <div class="doc-filter-row" id="filterRow">
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="doc-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width: 180px;">
            <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="doc-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlEntryYear_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- Entry Year --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="doc-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlIntake_SelectedIndexChanged">
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
        <asp:DropDownList ID="ddlDocStatus" runat="server" CssClass="doc-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDocStatus_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- Doc Status --"></asp:ListItem>
            <asp:ListItem Value="COMPLETE" Text="Complete"></asp:ListItem>
            <asp:ListItem Value="PARTIAL" Text="Partial"></asp:ListItem>
            <asp:ListItem Value="MISSING" Text="Missing"></asp:ListItem>
        </asp:DropDownList>
        <button type="button" class="doc-filter-clear" onclick="clearFilters()">Clear Filters</button>
    </div>
    
    <!-- Card with Header Row -->
    <div class="cd-card">
        <div style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center;">
            <div style="font-size: 11px; color: #666;">
                Showing students with document status | 
                <span id="selectedCountDisplay"><asp:Literal ID="litSelectedCount" runat="server" Text="0" /></span> selected
            </div>
            <div class="cd-batch-ops">
                <button type="button" class="cd-btn cd-btn--primary cd-btn--sm" onclick="toggleBatchMenu(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Actions
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div class="cd-batch-menu" id="batchMenu">
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doPrintList()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#174DA4"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                        Print Student List
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doExport()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#28a745"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        Export to Excel
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="doRefresh()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                        Refresh Grid
                    </a>
                </div>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvDocuments" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="regno" Width="100%" ClientInstanceName="gvDocuments"
                CssClass="doc-grid">
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
                    <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="110px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="180px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progid" Caption="Programme" Width="80px">
                        <Settings AutoFilterCondition="Contains" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="entryyear" Caption="Entry Year" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="intake" Caption="Intake" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="doc_count" Caption="Docs" Width="50px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="doc_status" Caption="Status" Width="90px">
                        <DataItemTemplate>
                            <span class='doc-status-badge doc-status-badge--<%# GetStatusClass(Eval("doc_status").ToString()) %>'>
                                <%# Eval("doc_status") %>
                            </span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="studPhone" Caption="Phone" Width="100px" />
                    <dx:GridViewDataTextColumn FieldName="email" Caption="Email" Width="150px">
                        <Settings AutoFilterCondition="Contains" />
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
                                            <asp:LinkButton ID="btnViewDocs" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--view"
                                                CommandArgument='<%# Eval("regno") %>' OnClick="btnViewDocs_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                                View Documents
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnUploadDoc" runat="server" CssClass="cd-action-popover__btn cd-action-popover__btn--upload"
                                                CommandArgument='<%# Eval("regno") %>' OnClick="btnUploadDoc_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
                                                Upload Document
                                            </asp:LinkButton>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <asp:LinkButton ID="btnViewProfile" runat="server" CssClass="cd-action-popover__btn"
                                                CommandArgument='<%# Eval("regno") %>' OnClick="btnViewProfile_Click">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                                View Profile
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
            <dx:ASPxGridViewExporter ID="gveDocuments" runat="server" GridViewID="gvDocuments" ExportedRowType="All">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Document View Popup -->
    <dx:ASPxPopupControl ID="popViewDocs" runat="server" ClientInstanceName="popViewDocs"
        Width="700px" HeaderText="Student Documents" Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" ShowCloseButton="true">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Bold="true" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px;">
                    <div style="margin-bottom: 15px; padding: 10px; background: #f8f9fa; border: 1px solid #e0e0e0;">
                        <strong>Reg No:</strong> <asp:Literal ID="litViewRegNo" runat="server" /> | 
                        <strong>Name:</strong> <asp:Literal ID="litViewName" runat="server" />
                    </div>
                    <dx:ASPxGridView ID="gvStudentDocs" runat="server" AutoGenerateColumns="False" KeyFieldName="doccode" Width="100%">
                        <Columns>
                            <dx:GridViewDataTextColumn FieldName="doccode" Caption="Code" Width="60px" />
                            <dx:GridViewDataTextColumn FieldName="docfilename" Caption="Document Name" Width="200px" />
                            <dx:GridViewDataTextColumn FieldName="docfiletype" Caption="Type" Width="80px" />
                            <dx:GridViewDataTextColumn FieldName="docdate" Caption="Upload Date" Width="100px" />
                            <dx:GridViewDataTextColumn FieldName="docuser" Caption="Uploaded By" Width="100px" />
                        </Columns>
                    </dx:ASPxGridView>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Upload Document Popup -->
    <dx:ASPxPopupControl ID="popUpload" runat="server" ClientInstanceName="popUpload"
        Width="500px" HeaderText="Upload Document" Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        CloseAction="CloseButton" ShowCloseButton="true">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Bold="true" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 15px;">
                    <asp:HiddenField ID="hfUploadRegNo" runat="server" />
                    <table style="width: 100%;">
                        <tr>
                            <td style="width: 120px; padding: 8px;">Document Type:</td>
                            <td style="padding: 8px;">
                                <asp:DropDownList ID="ddlDocType" runat="server" CssClass="doc-filter-select" style="width: 100%;">
                                    <asp:ListItem Value="PHO" Text="Passport Photo"></asp:ListItem>
                                    <asp:ListItem Value="NID" Text="National ID"></asp:ListItem>
                                    <asp:ListItem Value="CER" Text="Certificate"></asp:ListItem>
                                    <asp:ListItem Value="TRA" Text="Transcript"></asp:ListItem>
                                    <asp:ListItem Value="REC" Text="Recommendation Letter"></asp:ListItem>
                                    <asp:ListItem Value="OTH" Text="Other"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 8px;">Select File:</td>
                            <td style="padding: 8px;">
                                <dx:ASPxUploadControl ID="uploadFile" runat="server" Width="100%">
                                    <ValidationSettings AllowedFileExtensions=".pdf,.jpg,.jpeg,.png,.gif" MaxFileSize="3145728" />
                                </dx:ASPxUploadControl>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding: 8px; text-align: right;">
                                <asp:Button ID="btnDoUpload" runat="server" Text="Upload" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="btnDoUpload_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
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
    <asp:Button ID="btnPrintList" runat="server" OnClick="btnPrintList_Click" style="display:none;" />
    <asp:Button ID="btnExport" runat="server" OnClick="btnExport_Click" style="display:none;" />
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
        
        // Batch actions
        function doPrintList() {
            document.getElementById('<%= btnPrintList.ClientID %>').click();
        }
        
        function doExport() {
            document.getElementById('<%= btnExport.ClientID %>').click();
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
            var ddls = ['<%= ddlProgramme.ClientID %>', '<%= ddlEntryYear.ClientID %>', '<%= ddlIntake.ClientID %>', '<%= ddlDocStatus.ClientID %>'];
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
            document.getElementById('<%= ddlIntake.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= ddlDocStatus.ClientID %>').selectedIndex = 0;
            __doPostBack('<%= ddlProgramme.UniqueID %>', '');
        }
        
        // On page load
        document.addEventListener('DOMContentLoaded', function() {
            updateFilterCount();
        });
    </script>
</asp:Content>
