<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewStudentInfo.aspx.cs" Inherits="COOPERP_NewScreens_NewStudentInfo" Title="Student Records - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Student thumbnail in grid */
        .cd-student-thumb {
            width: 32px;
            height: 32px;
            object-fit: cover;
            border: 1px solid #ddd;
            background: #f5f5f5;
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .cd-student-thumb:hover {
            transform: scale(1.1);
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        /* Photo Lightbox */
        .cd-lightbox-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.85);
            z-index: 99999;
            justify-content: center;
            align-items: center;
        }
        .cd-lightbox-overlay.show {
            display: flex;
        }
        .cd-lightbox {
            position: relative;
            max-width: 90%;
            max-height: 90%;
        }
        .cd-lightbox__img {
            max-width: 100%;
            max-height: 85vh;
            border: 4px solid #fff;
            box-shadow: 0 4px 30px rgba(0,0,0,0.5);
            background: #fff;
        }
        .cd-lightbox__close {
            position: absolute;
            top: -40px;
            right: 0;
            background: none;
            border: none;
            color: #fff;
            font-size: 32px;
            cursor: pointer;
            padding: 0;
            line-height: 1;
            opacity: 0.8;
        }
        .cd-lightbox__close:hover {
            opacity: 1;
        }
        .cd-lightbox__caption {
            color: #fff;
            text-align: center;
            padding: 12px 0;
            font-size: 14px;
        }
        .cd-lightbox__name {
            font-weight: 600;
            font-size: 16px;
        }
        .cd-lightbox__regno {
            opacity: 0.8;
            font-size: 13px;
        }
        
        /* Filter row */
        .cd-filter-row {
            display: flex;
            gap: 10px;
            padding: 8px 12px;
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
            flex-wrap: wrap;
            align-items: center;
        }
        .cd-filter-row__label {
            font-size: 11px;
            color: #666;
        }
        .cd-filter-select {
            border: 1px solid #ddd;
            padding: 4px 8px;
            font-size: 11px;
            min-width: 140px;
            background: #fff;
        }
        .cd-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        
        /* Student Profile Popup Scrolling Fix */
        .sp-popup .dxpc-content {
            overflow: hidden !important;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .sp-popup .dxpc-contentWrapper {
            overflow: hidden !important;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .sp-profile-container {
            display: flex;
            flex-direction: column;
            height: 100%;
            max-height: calc(650px - 45px); /* Subtract header height */
            overflow: hidden;
        }
        .sp-profile-header {
            flex-shrink: 0;
        }
        .sp-profile-tabs-wrapper {
            flex: 1;
            overflow: hidden;
            min-height: 0;
            display: flex;
            flex-direction: column;
        }
        .sp-profile-tabs-wrapper > .dxpc-mainDiv,
        .sp-profile-tabs-wrapper > div {
            height: 100%;
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .sp-profile-tabs-wrapper .dxtc-content {
            flex: 1;
            overflow-y: auto !important;
            min-height: 0;
        }
        .sp-tab-content {
            padding: 16px;
        }
        
        /* Profile Header Section */
        .sp-profile-header {
            display: flex;
            gap: 20px;
            padding: 16px;
            background: linear-gradient(135deg, #f8f9fa 0%, #fff 100%);
            border-bottom: 1px solid #e0e0e0;
        }
        .sp-profile-photo-wrap {
            flex-shrink: 0;
            text-align: center;
        }
        .sp-profile-photo {
            width: 100px;
            height: 120px;
            object-fit: cover;
            border: 2px solid #174DA4;
            background: #f5f5f5;
        }
        .sp-profile-signature {
            width: 80px;
            height: 30px;
            margin-top: 6px;
            border: 1px solid #ddd;
            background: #fff;
        }
        .sp-profile-info {
            flex: 1;
            min-width: 0;
        }
        .sp-profile-name {
            font-size: 20px;
            font-weight: 700;
            color: #333;
            margin: 0 0 2px 0;
            line-height: 1.2;
        }
        .sp-profile-regno {
            font-size: 14px;
            color: #174DA4;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .sp-profile-programme {
            font-size: 12px;
            color: #555;
            margin-bottom: 4px;
        }
        .sp-profile-specialisation {
            font-size: 11px;
            color: #777;
        }
        .sp-profile-quick-stats {
            display: flex;
            gap: 16px;
            margin-top: 12px;
            flex-wrap: wrap;
        }
        .sp-quick-stat {
            display: flex;
            flex-direction: column;
            padding: 6px 12px;
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .sp-quick-stat__label {
            font-size: 9px;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .sp-quick-stat__value {
            font-size: 12px;
            font-weight: 600;
            color: #333;
        }
        
        /* Bio Data Section */
        .sp-bio-section {
            margin-bottom: 16px;
        }
        .sp-bio-section:last-child {
            margin-bottom: 0;
        }
        .sp-bio-section__title {
            font-size: 11px;
            font-weight: 600;
            color: #174DA4;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
            padding-bottom: 4px;
            border-bottom: 1px solid #e0e0e0;
        }
        .sp-bio-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
        }
        .sp-bio-field {
            display: flex;
            flex-direction: column;
        }
        .sp-bio-field__label {
            font-size: 9px;
            color: #888;
            text-transform: uppercase;
            margin-bottom: 2px;
        }
        .sp-bio-field__value {
            font-size: 12px;
            color: #333;
            font-weight: 500;
        }
        
        /* Data Tables in Tabs */
        .sp-data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }
        .sp-data-table th {
            background: #f5f5f5;
            padding: 6px 8px;
            text-align: left;
            font-weight: 600;
            color: #555;
            border-bottom: 1px solid #ddd;
            font-size: 10px;
            text-transform: uppercase;
        }
        .sp-data-table td {
            padding: 6px 8px;
            border-bottom: 1px solid #eee;
            color: #333;
        }
        .sp-data-table tr:hover td {
            background: #f9f9f9;
        }
        .sp-data-table--results td.grade {
            font-weight: 600;
            text-align: center;
        }
        .sp-data-table--results td.grade-A { color: #28a745; }
        .sp-data-table--results td.grade-B { color: #17a2b8; }
        .sp-data-table--results td.grade-C { color: #ffc107; }
        .sp-data-table--results td.grade-D { color: #fd7e14; }
        .sp-data-table--results td.grade-F { color: #dc3545; }
        
        /* Summary Stats */
        .sp-summary-row {
            display: flex;
            gap: 12px;
            margin-bottom: 12px;
            flex-wrap: wrap;
        }
        .sp-summary-card {
            flex: 1;
            min-width: 120px;
            padding: 10px;
            background: #f8f9fa;
            border-left: 3px solid #174DA4;
        }
        .sp-summary-card__label {
            font-size: 9px;
            color: #666;
            text-transform: uppercase;
        }
        .sp-summary-card__value {
            font-size: 16px;
            font-weight: 700;
            color: #174DA4;
        }
        
        /* Semester Groups */
        .sp-semester-group {
            margin-bottom: 16px;
        }
        .sp-semester-group__header {
            font-size: 11px;
            font-weight: 600;
            color: #333;
            padding: 6px 10px;
            background: #e9ecef;
            margin-bottom: 0;
        }
        
        /* Empty State */
        .sp-empty {
            text-align: center;
            padding: 30px;
            color: #888;
            font-size: 12px;
        }
        .sp-empty svg {
            width: 40px;
            height: 40px;
            margin-bottom: 10px;
            opacity: 0.5;
            display: block;
            margin-left: auto;
            margin-right: auto;
            stroke: currentColor;
        }
        
        /* Fix icons in popup - ensure proper display */
        .sp-popup svg {
            display: inline-block;
            vertical-align: middle;
            flex-shrink: 0;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .sp-profile-header {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }
            .sp-bio-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .sp-profile-quick-stats {
                justify-content: center;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    
    <div class="cd-card">
        <!-- Page Header with Title and Batch Operations -->
        <div style="padding: 10px 12px; border-bottom: 1px solid #e0e0e0; background: #fff; display: flex; justify-content: space-between; align-items: center;">
            <h2 style="margin: 0; font-size: 16px; font-weight: 600; color: #174DA4;">
                <asp:Literal ID="litPageTitle" runat="server" Text="Student Records"></asp:Literal>
            </h2>
            
            <!-- Batch Operations Button -->
            <div class="cd-batch-ops">
                <button type="button" class="cd-btn cd-btn--primary cd-btn--sm" onclick="toggleBatchMenu(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Batch Operations
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 4px;"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div class="cd-batch-menu" id="batchMenu">
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchStatusModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="18" y1="8" x2="23" y2="13"></line><line x1="23" y1="8" x2="18" y2="13"></line></svg>
                        Change Students Status
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchPromotionModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
                        Promote Students
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchExportModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        Export Students Data
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchEmailModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                        Send Bulk Email/SMS
                    </a>
                </div>
            </div>
        </div>
        
        <!-- Quick Filters -->
        <div class="cd-filter-row">
            <span class="cd-filter-row__label">Filter:</span>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged" style="min-width: 130px; font-weight: 500;">
                <asp:ListItem Value="" Text="-- All Statuses --"></asp:ListItem>
                <asp:ListItem Value="ADMITTED" Text="Admitted"></asp:ListItem>
                <asp:ListItem Value="ACTIVE" Text="Active"></asp:ListItem>
                <asp:ListItem Value="ALUMNI" Text="Alumni"></asp:ListItem>
                <asp:ListItem Value="SUSPENDED" Text="Suspended"></asp:ListItem>
                <asp:ListItem Value="DEFERRED" Text="Deferred"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterFaculty" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterFaculty_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Faculties --"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterEntryYear" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterEntryYear_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Entry Years --"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Sessions --"></asp:ListItem>
            </asp:DropDownList>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvStudents" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="regno" Width="100%" ClientInstanceName="gvStudents"
                OnRowUpdating="gvStudents_RowUpdating" OnRowDeleting="gvStudents_RowDeleting"
                EnableTheming="True" Theme="Glass" EnableCallBacks="false">
                
                <SettingsPager PageSize="20" AlwaysShowPager="true" Position="Bottom">
                    <Summary Text="Page {0} of {1} ({2} students)" />
                </SettingsPager>
                
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="PopupEditForm" />
                <SettingsDataSecurity AllowDelete="False" />
                
                <SettingsPopup>
                    <EditForm Width="600px" Height="450px" HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" Modal="True" />
                </SettingsPopup>
                
                <EditFormLayoutProperties ColCount="2">
                    <Items>
                        <dx:GridViewLayoutGroup Caption="Personal Information" ColCount="2" ColSpan="2">
                            <Items>
                                <dx:GridViewColumnLayoutItem ColumnName="entryno"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="regno"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="firstname"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="othername"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="gender"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="dob"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="nationality"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="religion"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studPhone"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="email"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="home_dist"></dx:GridViewColumnLayoutItem>
                            </Items>
                        </dx:GridViewLayoutGroup>
                        <dx:GridViewLayoutGroup Caption="Academic Information" ColCount="2" ColSpan="2">
                            <Items>
                                <dx:GridViewColumnLayoutItem ColumnName="progid"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="specialisation"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="entryyear"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="intake"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studsesion"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studCampus"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="gradSystemID"></dx:GridViewColumnLayoutItem>
                            </Items>
                        </dx:GridViewLayoutGroup>
                        <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right"></dx:EditModeCommandLayoutItem>
                    </Items>
                </EditFormLayoutProperties>
                
                <Columns>
                    <dx:GridViewDataTextColumn Caption="" VisibleIndex="0" Width="45px" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <img class="cd-student-thumb" 
                                 src='<%# !String.IsNullOrEmpty(Eval("photofile") as string) ? ResolveUrl("~/COOPERP/StudentInfo/photos/") + Eval("photofile") : ResolveUrl("~/COOPERP/StudentInfo/photos/default.png") %>' 
                                 alt="" 
                                 data-default-src='<%# ResolveUrl("~/COOPERP/StudentInfo/photos/default.png") %>' 
                                 onerror="this.src=this.getAttribute('data-default-src')" 
                                 data-name='<%# HttpUtility.HtmlAttributeEncode((Eval("firstname") ?? "").ToString() + " " + (Eval("othername") ?? "").ToString()) %>' 
                                 data-regno='<%# HttpUtility.HtmlAttributeEncode((Eval("entryno") ?? "").ToString()) %>' 
                                 onclick="openLightbox(this.src, this.getAttribute('data-name'), this.getAttribute('data-regno'))" />
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Paddings-Padding="2px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Reg No" FieldName="entryno" VisibleIndex="1" Width="120px">
                        <CellStyle Font-Bold="True"></CellStyle>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Entry No" FieldName="regno" VisibleIndex="2" Width="85px">
                        <HeaderStyle Font-Size="11px" />
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Year" FieldName="entryyear" VisibleIndex="3" Width="45px">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Student Name" VisibleIndex="4" Width="160px">
                        <DataItemTemplate>
                            <%# Eval("firstname") %> <%# Eval("othername") %>
                        </DataItemTemplate>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" VisibleIndex="5" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Other Names" FieldName="othername" VisibleIndex="6" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Gender" FieldName="gender" VisibleIndex="7" Width="55px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="MALE" Value="MALE" />
                                <dx:ListEditItem Text="FEMALE" Value="FEMALE" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataDateColumn Caption="DOB" FieldName="dob" VisibleIndex="8" Width="90px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataDateColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" VisibleIndex="9" Width="100px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Religion" FieldName="religion" VisibleIndex="10" Visible="False">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="MUSLIM" Value="MUSLIM" />
                                <dx:ListEditItem Text="CHRISTIAN" Value="CHRISTIAN" />
                                <dx:ListEditItem Text="CATHOLIC" Value="CATHOLIC" />
                                <dx:ListEditItem Text="PROTESTANT" Value="PROTESTANT" />
                                <dx:ListEditItem Text="ADVENTIST" Value="ADVENTIST" />
                                <dx:ListEditItem Text="ANGLICAN" Value="ANGLICAN" />
                                <dx:ListEditItem Text="ORTHODOX" Value="ORTHODOX" />
                                <dx:ListEditItem Text="PENTACOSTAL" Value="PENTACOSTAL" />
                                <dx:ListEditItem Text="SDA" Value="SDA" />
                                <dx:ListEditItem Text="OTHERS" Value="OTHERS" />
                            </Items>
                        </PropertiesComboBox>
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Phone" FieldName="studPhone" VisibleIndex="11" Width="95px">
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Email" FieldName="email" VisibleIndex="12" Width="150px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Home District" FieldName="home_dist" VisibleIndex="13" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Prog" FieldName="progcode" VisibleIndex="14" Width="65px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Programme" FieldName="progname" VisibleIndex="15" Visible="False" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="progid" VisibleIndex="16" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Specialisation" FieldName="specialisation" VisibleIndex="17" Width="100px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="entryyear" VisibleIndex="18" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="intake" VisibleIndex="19" Width="80px" Visible="False">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                <dx:ListEditItem Text="MAY" Value="MAY" />
                                <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                <dx:ListEditItem Text="JULY" Value="JULY" />
                                <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                            </Items>
                        </PropertiesComboBox>
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Session" FieldName="studsesion" VisibleIndex="20" Width="55px">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Campus" FieldName="campus_name" VisibleIndex="21" Width="80px">
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Old Status" FieldName="stud_status" VisibleIndex="22" Width="70px" ReadOnly="True">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" ForeColor="#999999" />
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="new_status" VisibleIndex="23" Width="75px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="ADMITTED" Value="ADMITTED" />
                                <dx:ListEditItem Text="ACTIVE" Value="ACTIVE" />
                                <dx:ListEditItem Text="ALUMNI" Value="ALUMNI" />
                                <dx:ListEditItem Text="SUSPENDED" Value="SUSPENDED" />
                                <dx:ListEditItem Text="DEFERRED" Value="DEFERRED" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Campus Code" FieldName="studCampus" VisibleIndex="24" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Grading System" FieldName="gradSystemID" VisibleIndex="25" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="photofile" Visible="False" VisibleIndex="26">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn VisibleIndex="27" Caption=" " Width="40px" 
                        Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item">
                                            <a href="javascript:void(0);" class="cd-action-popover__btn cd-action-popover__btn--view" 
                                               data-regno='<%# Eval("regno") %>' onclick="openStudentProfile(this.getAttribute('data-regno'))">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                                View Profile
                                            </a>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--edit" data-key='<%# Container.KeyValue %>' onclick="gridEditRow('gvStudents', this.getAttribute('data-key'))">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                                Edit
                                            </button>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" CssClass="cd-action-cell" />
                    </dx:GridViewDataTextColumn>
                </Columns>
                
                <SettingsCommandButton>
                    <EditButton>
                        <Image IconID="edit_edit_16x16"></Image>
                    </EditButton>
                    <UpdateButton RenderMode="Link"></UpdateButton>
                    <CancelButton RenderMode="Link"></CancelButton>
                </SettingsCommandButton>
                
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="11px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="10px" />
                </Styles>
                
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Hidden fields and button for loading profile -->
    <asp:HiddenField ID="hdnSelectedRegno" runat="server" />
    <dx:ASPxButton ID="btnLoadProfile" runat="server" ClientInstanceName="btnLoadProfile" 
        OnClick="btnLoadProfile_Click" AutoPostBack="true" 
        ClientVisible="false" Text="Load" />
    
    <!-- Student Profile Modal (Server-loaded) -->
    <dx:ASPxPopupControl ID="popStudentProfile" runat="server" 
        ClientInstanceName="popStudentProfile"
        Width="950px" Height="650px"
        PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        Modal="True" CloseAction="CloseButton"
        HeaderText="Student Profile" CssClass="sp-popup"
        AllowDragging="true" ShowCloseButton="true"
        EnableCallbackAnimation="false" LoadContentViaCallback="None">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Size="13px" Font-Bold="True" Paddings-Padding="10px" />
        <ContentStyle Paddings-Padding="0px" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <asp:Panel ID="pnlProfileContent" runat="server" CssClass="sp-profile-container">
                    <!-- Profile Header -->
                    <div class="sp-profile-header">
                        <div class="sp-profile-photo-wrap">
                            <asp:Image ID="imgProfilePhoto" runat="server" CssClass="sp-profile-photo" />
                            <asp:Image ID="imgProfileSignature" runat="server" CssClass="sp-profile-signature" Visible="false" />
                        </div>
                        <div class="sp-profile-info">
                            <h2 class="sp-profile-name"><asp:Literal ID="litStudentName" runat="server" /></h2>
                            <div class="sp-profile-regno"><asp:Literal ID="litRegNo" runat="server" /></div>
                            <div class="sp-profile-programme"><asp:Literal ID="litProgramme" runat="server" /></div>
                            <div class="sp-profile-specialisation"><asp:Literal ID="litSpecialisation" runat="server" /></div>
                            <div class="sp-profile-quick-stats">
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Entry Year</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litEntryYear" runat="server" /></span>
                                </div>
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Session</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litSession" runat="server" /></span>
                                </div>
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Campus</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litCampus" runat="server" /></span>
                                </div>
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Intake</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litIntake" runat="server" /></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Tabs (Wrapped for scrolling) -->
                    <div class="sp-profile-tabs-wrapper">
                        <dx:ASPxPageControl ID="tabStudentProfile" runat="server" ActiveTabIndex="0" Width="100%" EnableTabScrolling="True">
                            <TabStyle Font-Size="11px" Paddings-PaddingLeft="12px" Paddings-PaddingRight="12px" Paddings-PaddingTop="6px" Paddings-PaddingBottom="6px" />
                            <ActiveTabStyle BackColor="#fff" ForeColor="#174DA4" />
                            <TabPages>
                                <dx:TabPage Text="Bio Data">
                                    <ContentCollection>
                                        <dx:ContentControl runat="server">
                                            <div class="sp-tab-content">
                                                <div class="sp-bio-section">
                                                    <h4 class="sp-bio-section__title">Personal Information</h4>
                                                    <div class="sp-bio-grid">
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Registration Number</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioRegNo" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Entry Number</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioEntryNo" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Full Name</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioFullName" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Gender</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioGender" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Date of Birth</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioDOB" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Nationality</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioNationality" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Religion</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioReligion" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Home District</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioDistrict" runat="server" /></span>
                                                        </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Entry Method</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioEntryMethod" runat="server" /></span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="sp-bio-section">
                                                <h4 class="sp-bio-section__title">Contact Information</h4>
                                                <div class="sp-bio-grid">
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Phone Number</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioPhone" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Email Address</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioEmail" runat="server" /></span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="sp-bio-section">
                                                <h4 class="sp-bio-section__title">Academic Information</h4>
                                                <div class="sp-bio-grid">
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Programme</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioProgramme" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Specialisation</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioSpecialisation" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Entry Year</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioEntryYear" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Intake</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioIntake" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Study Session</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioSession" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Campus</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioCampus" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Grading System</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioGradingSystem" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Course Duration</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioDuration" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Student Hall</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioHall" runat="server" /></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Academic Results">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div style="padding: 12px;">
                                            <div class="sp-results-summary" style="display:flex;align-items:center;gap:24px;padding:8px 12px;background:#f8f9fa;border:1px solid #e9ecef;margin-bottom:12px;">
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">GPA:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:13px;"><asp:Literal ID="litGPA" runat="server" Text="0.00" /></span>
                                                </div>
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">CGPA:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:13px;"><asp:Literal ID="litCGPA" runat="server" Text="0.00" /></span>
                                                </div>
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">CURRENT CLASS:</span>
                                                    <span style="font-weight:700;color:#dc3545;font-size:13px;"><asp:Literal ID="litAwardClass" runat="server" Text="-" /></span>
                                                </div>
                                                <div style="margin-left:auto;display:flex;gap:16px;">
                                                    <span style="font-size:11px;color:#666;">Credits: <strong style="color:#333;"><asp:Literal ID="litTotalCredits" runat="server" Text="0" /></strong></span>
                                                    <span style="font-size:11px;color:#28a745;">Passed: <strong><asp:Literal ID="litCoursesPassed" runat="server" Text="0" /></strong></span>
                                                    <span style="font-size:11px;color:#dc3545;">Failed: <strong><asp:Literal ID="litCoursesFailed" runat="server" Text="0" /></strong></span>
                                                </div>
                                            </div>
                                            <asp:Repeater ID="rptResultsSemesters" runat="server">
                                                <ItemTemplate>
                                                    <div class="sp-semester-group">
                                                        <div class="sp-semester-group__header">
                                                            Year <%# Eval("year") %> - Semester <%# Eval("semester") %> 
                                                            <span style="float:right;font-weight:normal;">GPA: <%# Eval("gpa", "{0:F2}") %></span>
                                                        </div>
                                                        <table class="sp-data-table sp-data-table--results">
                                                            <thead>
                                                                <tr>
                                                                    <th style="width:100px;">Code</th>
                                                                    <th>Course Title</th>
                                                                    <th style="width:50px;text-align:center;">CU</th>
                                                                    <th style="width:50px;text-align:center;">Mark</th>
                                                                    <th style="width:50px;text-align:center;">Grade</th>
                                                                    <th style="width:50px;text-align:center;">GP</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <asp:Repeater ID="rptCourses" runat="server" DataSource='<%# Eval("courses") %>'>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td><%# Eval("course_code") %></td>
                                                                            <td><%# Eval("course_title") %></td>
                                                                            <td style="text-align:center;"><%# Eval("credits") %></td>
                                                                            <td style="text-align:center;"><%# Eval("mark") %></td>
                                                                            <td class="grade grade-<%# Eval("grade") %>"><%# Eval("grade") %></td>
                                                                            <td style="text-align:center;"><%# Eval("gp", "{0:F1}") %></td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <asp:Panel ID="pnlNoResults" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                                                <div>No results found for this student</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Faculty Registration">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <table class="sp-data-table">
                                                <thead>
                                                    <tr>
                                                        <th style="width:80px;">Acad Year</th>
                                                        <th style="width:50px;">Sem</th>
                                                        <th style="width:50px;">Year</th>
                                                        <th>Remarks</th>
                                                        <th style="width:80px;">Reg Date</th>
                                                        <th style="width:80px;text-align:center;">Exam Clear</th>
                                                        <th style="width:80px;text-align:center;">Reg Clear</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <asp:Repeater ID="rptRegistrations" runat="server">
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td><%# Eval("academic_year") %></td>
                                                                <td><%# Eval("semester") %></td>
                                                                <td><%# Eval("study_year") %></td>
                                                                <td><%# Eval("remarks") %></td>
                                                                <td><%# Eval("reg_date", "{0:dd/MM/yyyy}") %></td>
                                                                <td style="text-align:center;">
                                                                    <%# Convert.ToBoolean(Eval("exam_clearance")) ? "<span style='color:#28a745;'>✓</span>" : "<span style='color:#dc3545;'>✗</span>" %>
                                                                </td>
                                                                <td style="text-align:center;">
                                                                    <%# Convert.ToBoolean(Eval("reg_clearance")) ? "<span style='color:#28a745;'>✓</span>" : "<span style='color:#dc3545;'>✗</span>" %>
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </tbody>
                                            </table>
                                            <asp:Panel ID="pnlNoRegistrations" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                                <div>No faculty registration records found</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Course Registration">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <asp:Repeater ID="rptCourseRegSemesters" runat="server">
                                                <ItemTemplate>
                                                    <div class="sp-semester-group">
                                                        <div class="sp-semester-group__header">
                                                            <%# Eval("academic_year") %> - Semester <%# Eval("semester") %>
                                                            <span style="float:right;font-weight:normal;"><%# Eval("course_count") %> courses</span>
                                                        </div>
                                                        <table class="sp-data-table">
                                                            <thead>
                                                                <tr>
                                                                    <th style="width:100px;">Code</th>
                                                                    <th>Course Title</th>
                                                                    <th style="width:50px;text-align:center;">CU</th>
                                                                    <th style="width:80px;">Type</th>
                                                                    <th style="width:100px;">Reg Date</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <asp:Repeater ID="rptRegCourses" runat="server" DataSource='<%# Eval("courses") %>'>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td><%# Eval("course_code") %></td>
                                                                            <td><%# Eval("course_title") %></td>
                                                                            <td style="text-align:center;"><%# Eval("credits") %></td>
                                                                            <td><%# Eval("course_type") %></td>
                                                                            <td><%# Eval("reg_date", "{0:dd/MM/yyyy}") %></td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <asp:Panel ID="pnlNoCourseReg" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                                <div>No course registration records found</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Fees Ledger">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <div class="sp-summary-row">
                                                <div class="sp-summary-card">
                                                    <div class="sp-summary-card__label">Total Invoiced</div>
                                                    <div class="sp-summary-card__value"><asp:Literal ID="litTotalInvoiced" runat="server" Text="0" /></div>
                                                </div>
                                                <div class="sp-summary-card">
                                                    <div class="sp-summary-card__label">Total Paid</div>
                                                    <div class="sp-summary-card__value"><asp:Literal ID="litTotalPaid" runat="server" Text="0" /></div>
                                                </div>
                                                <div class="sp-summary-card" style="border-left-color: #dc3545;">
                                                    <div class="sp-summary-card__label">Balance Due</div>
                                                    <div class="sp-summary-card__value" style="color: #dc3545;"><asp:Literal ID="litBalance" runat="server" Text="0" /></div>
                                                </div>
                                            </div>
                                            <table class="sp-data-table">
                                                <thead>
                                                    <tr>
                                                        <th style="width:90px;">Date</th>
                                                        <th style="width:100px;">Reference</th>
                                                        <th>Description</th>
                                                        <th style="width:100px;text-align:right;">Debit</th>
                                                        <th style="width:100px;text-align:right;">Credit</th>
                                                        <th style="width:100px;text-align:right;">Balance</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <asp:Repeater ID="rptFeesLedger" runat="server">
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td><%# Eval("trans_date") %></td>
                                                                <td><%# Eval("reference") %></td>
                                                                <td><%# Eval("description") %></td>
                                                                <td style="text-align:right;"><%# FormatAmount(Eval("debit")) %></td>
                                                                <td style="text-align:right;"><%# FormatAmount(Eval("credit")) %></td>
                                                                <td style="text-align:right;font-weight:600;"><%# FormatBalance(Eval("running_balance")) %></td>
                                                            </tr>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </tbody>
                                            </table>
                                            <asp:Panel ID="pnlNoFees" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                                                <div>No fees ledger records found</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
                    </div><!-- End of .sp-profile-tabs-wrapper -->
                </asp:Panel>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Photo Lightbox -->
    <asp:HiddenField ID="hdnDefaultPhotoUrl" runat="server" />
    <div id="photoLightbox" class="cd-lightbox-overlay">
        <div class="cd-lightbox">
            <button type="button" class="cd-lightbox__close" onclick="closeLightbox()">&times;</button>
            <img id="lightboxImg" class="cd-lightbox__img" src="" alt="Student Photo" />
            <div class="cd-lightbox__caption">
                <div id="lightboxName" class="cd-lightbox__name"></div>
                <div id="lightboxRegno" class="cd-lightbox__regno"></div>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        function toggleActionPopover(btn, e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            var wrapper = btn.parentElement;
            var popover = wrapper.querySelector('.cd-action-popover');
            
            if (!popover) return;
            
            // Close all other popovers first
            document.querySelectorAll('.cd-action-popover.show').forEach(function(p) {
                if (p !== popover) p.classList.remove('show');
            });
            
            // Toggle this popover
            popover.classList.toggle('show');
            
            // Position check
            if (popover.classList.contains('show')) {
                var rect = popover.getBoundingClientRect();
                if (rect.bottom > window.innerHeight) {
                    popover.classList.add('cd-action-popover--top');
                } else {
                    popover.classList.remove('cd-action-popover--top');
                }
            }
        }
        
        function gridEditRow(gridName, keyValue) {
            var grid = ASPxClientControl.GetControlCollection().GetByName(gridName);
            if (grid) {
                grid.StartEditRowByKey(keyValue);
            }
            closeAllPopovers();
        }
        
        function closeAllPopovers() {
            document.querySelectorAll('.cd-action-popover.show').forEach(function(p) {
                p.classList.remove('show');
            });
        }
        
        // Close popovers when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.cd-action-wrapper')) {
                closeAllPopovers();
            }
        });
        
        // Open Student Profile - triggers server-side load
        function openStudentProfile(regno) {
            closeAllPopovers();
            if (!regno) {
                alert('No registration number provided');
                return;
            }
            document.getElementById('<%= hdnSelectedRegno.ClientID %>').value = regno;
            // Use DevExpress button click
            if (typeof btnLoadProfile !== 'undefined') {
                btnLoadProfile.DoClick();
            } else {
                // Fallback - direct postback
                __doPostBack('<%= btnLoadProfile.UniqueID %>', '');
            }
        }
        
        // Photo Lightbox Functions
        function openLightbox(imgSrc, studentName, regNo) {
            var lightbox = document.getElementById('photoLightbox');
            var lightboxImg = document.getElementById('lightboxImg');
            var lightboxName = document.getElementById('lightboxName');
            var lightboxRegno = document.getElementById('lightboxRegno');
            var defaultUrl = document.getElementById('<%= hdnDefaultPhotoUrl.ClientID %>').value;
            
            lightboxImg.onerror = function() {
                this.onerror = null;
                this.src = defaultUrl;
            };
            lightboxImg.src = imgSrc;
            lightboxName.innerText = studentName || '';
            lightboxRegno.innerText = regNo || '';
            
            lightbox.classList.add('show');
        }
        
        function closeLightbox() {
            document.getElementById('photoLightbox').classList.remove('show');
        }
        
        // Close lightbox on overlay click
        document.addEventListener('DOMContentLoaded', function() {
            var lightbox = document.getElementById('photoLightbox');
            if (lightbox) {
                lightbox.addEventListener('click', function(e) {
                    if (e.target === lightbox) {
                        closeLightbox();
                    }
                });
            }
        });
        
        // Close on Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeLightbox();
                closeBatchStatusModal();
            }
        });
        
        // ========== BATCH OPERATIONS ==========
        
        // Toggle batch operations menu
        function toggleBatchMenu(event) {
            event.stopPropagation();
            var menu = document.getElementById('batchMenu');
            menu.classList.toggle('show');
        }
        
        // Close batch menu when clicking outside
        document.addEventListener('click', function(e) {
            var menu = document.getElementById('batchMenu');
            if (menu && !e.target.closest('.cd-batch-ops')) {
                menu.classList.remove('show');
            }
        });
        
        // Open batch status change modal
        function openBatchStatusModal() {
            document.getElementById('batchMenu').classList.remove('show');
            document.getElementById('batchStatusModal').style.display = 'flex';
            resetBatchStatusForm();
        }
        
        // Close batch status modal
        function closeBatchStatusModal() {
            document.getElementById('batchStatusModal').style.display = 'none';
        }
        
        // Reset the batch status form
        function resetBatchStatusForm() {
            // Uncheck all condition radio buttons
            var radios = document.querySelectorAll('input[name="batchCondition"]');
            radios.forEach(function(r) { r.checked = false; });
            
            // Reset negate to "include" (default)
            document.querySelector('input[name="conditionNegate"][value="include"]').checked = true;
            
            document.getElementById('batchTargetStatus').value = '';
            document.getElementById('conditionPaymentDays').style.display = 'none';
            document.getElementById('conditionEntryYear').style.display = 'none';
            document.getElementById('conditionProgramme').style.display = 'none';
            document.getElementById('conditionCurrentStatus').style.display = 'none';
            document.getElementById('batchPreviewSection').style.display = 'none';
            document.getElementById('batchPreviewCount').innerText = '0';
            document.getElementById('btnApplyBatchStatus').disabled = true;
        }
        
        // Get selected condition type from radio buttons
        function getSelectedCondition() {
            var selected = document.querySelector('input[name="batchCondition"]:checked');
            return selected ? selected.value : '';
        }
        
        // Get whether condition should be negated
        function isConditionNegated() {
            var selected = document.querySelector('input[name="conditionNegate"]:checked');
            return selected ? (selected.value === 'exclude') : false;
        }
        
        // Handle condition type change (from radio button)
        function onConditionTypeChange(condType) {
            // Hide all condition panels
            document.getElementById('conditionPaymentDays').style.display = 'none';
            document.getElementById('conditionEntryYear').style.display = 'none';
            document.getElementById('conditionProgramme').style.display = 'none';
            document.getElementById('conditionCurrentStatus').style.display = 'none';
            
            // Show relevant panel
            if (condType === 'payment') {
                document.getElementById('conditionPaymentDays').style.display = 'block';
            } else if (condType === 'entry_year') {
                document.getElementById('conditionEntryYear').style.display = 'block';
            } else if (condType === 'programme') {
                document.getElementById('conditionProgramme').style.display = 'block';
            } else if (condType === 'current_status') {
                document.getElementById('conditionCurrentStatus').style.display = 'block';
            }
            
            // Reset preview
            document.getElementById('batchPreviewSection').style.display = 'none';
            document.getElementById('btnApplyBatchStatus').disabled = true;
        }
        
        // Preview affected students
        function previewBatchStatusChange() {
            var condType = getSelectedCondition();
            var targetStatus = document.getElementById('batchTargetStatus').value;
            var negate = isConditionNegated();
            
            if (!condType) {
                alert('Please select a condition.');
                return;
            }
            if (!targetStatus) {
                alert('Please select target status.');
                return;
            }
            
            var params = {
                conditionType: condType,
                targetStatus: targetStatus,
                negate: negate
            };
            
            // Get condition-specific values and validate
            if (condType === 'payment') {
                var days = document.getElementById('txtPaymentDays').value;
                if (!days || days < 1) {
                    alert('Please enter a valid number of days.');
                    return;
                }
                params.paymentDays = days;
            } else if (condType === 'entry_year') {
                var year = document.getElementById('ddlBatchEntryYear').value;
                if (!year) {
                    alert('Please select an entry year.');
                    return;
                }
                params.entryYear = year;
            } else if (condType === 'programme') {
                var prog = document.getElementById('<%= ddlBatchProgramme.ClientID %>').value;
                if (!prog) {
                    alert('Please select a programme.');
                    return;
                }
                params.programme = prog;
            } else if (condType === 'current_status') {
                var status = document.getElementById('ddlBatchCurrentStatus').value;
                if (!status) {
                    alert('Please select a current status.');
                    return;
                }
                params.currentStatus = status;
            }
            
            // Show loading
            document.getElementById('batchPreviewCount').innerText = 'Loading...';
            document.getElementById('batchPreviewSection').style.display = 'block';
            
            // Make AJAX call to get preview count
            var xhr = new XMLHttpRequest();
            xhr.open('POST', window.location.pathname + '?action=PreviewBatchStatus', true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        document.getElementById('batchPreviewCount').innerText = response.count;
                        document.getElementById('btnApplyBatchStatus').disabled = (response.count === 0);
                        if (response.error) {
                            alert('Error: ' + response.error);
                        }
                    } else {
                        document.getElementById('batchPreviewCount').innerText = 'Error';
                    }
                }
            };
            xhr.send(JSON.stringify(params));
        }
        
        // Apply batch status change
        function applyBatchStatusChange() {
            var condType = getSelectedCondition();
            var targetStatus = document.getElementById('batchTargetStatus').value;
            var negate = isConditionNegated();
            var count = document.getElementById('batchPreviewCount').innerText;
            
            var matchText = negate ? 'DO NOT meet' : 'meet';
            if (!confirm('Are you sure you want to change the status of ' + count + ' students (who ' + matchText + ' the condition) to ' + targetStatus + '?\n\nThis action cannot be undone.')) {
                return;
            }
            
            var params = {
                conditionType: condType,
                targetStatus: targetStatus,
                negate: negate,
                apply: true
            };
            
            // Get condition-specific values
            if (condType === 'payment') {
                params.paymentDays = document.getElementById('txtPaymentDays').value;
            } else if (condType === 'entry_year') {
                params.entryYear = document.getElementById('ddlBatchEntryYear').value;
            } else if (condType === 'programme') {
                params.programme = document.getElementById('<%= ddlBatchProgramme.ClientID %>').value;
            } else if (condType === 'current_status') {
                params.currentStatus = document.getElementById('ddlBatchCurrentStatus').value;
            }
            
            // Show loading
            document.getElementById('btnApplyBatchStatus').disabled = true;
            document.getElementById('btnApplyBatchStatus').innerText = 'Applying...';
            
            // Make AJAX call to apply changes
            var xhr = new XMLHttpRequest();
            xhr.open('POST', window.location.pathname + '?action=ApplyBatchStatus', true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    document.getElementById('btnApplyBatchStatus').innerText = 'Apply Changes';
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            alert('Successfully updated ' + response.updated + ' students.');
                            closeBatchStatusModal();
                            // Refresh the grid
                            window.location.reload();
                        } else {
                            alert('Error: ' + response.message);
                            document.getElementById('btnApplyBatchStatus').disabled = false;
                        }
                    } else {
                        alert('An error occurred. Please try again.');
                        document.getElementById('btnApplyBatchStatus').disabled = false;
                    }
                }
            };
            xhr.send(JSON.stringify(params));
        }
        
        // Placeholder functions for other batch operations
        function openBatchPromotionModal() {
            document.getElementById('batchMenu').classList.remove('show');
            alert('Batch Promotion feature coming soon!');
        }
        
        function openBatchExportModal() {
            document.getElementById('batchMenu').classList.remove('show');
            alert('Export feature coming soon!');
        }
        
        function openBatchEmailModal() {
            document.getElementById('batchMenu').classList.remove('show');
            alert('Bulk Email/SMS feature coming soon!');
        }
    </script>
    
    <!-- Batch Status Change Modal -->
    <div id="batchStatusModal" class="cd-modal-overlay">
        <div class="cd-modal">
            <div class="cd-modal__header">
                <h3 class="cd-modal__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="18" y1="8" x2="23" y2="13"></line><line x1="23" y1="8" x2="18" y2="13"></line></svg>
                    Batch Change Student Status
                </h3>
                <button type="button" class="cd-modal__close" onclick="closeBatchStatusModal()">&times;</button>
            </div>
            <div class="cd-modal__body">
                <p style="margin-bottom: 12px; color: #666; font-size: 11px;">
                    Select students based on a condition and change their status in bulk.
                </p>
                
                <!-- Condition Selection - Radio Buttons -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Select Condition</label>
                    <div class="cd-radio-group">
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="payment" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students who paid in last X days</span>
                        </label>
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="entry_year" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students by Entry Year</span>
                        </label>
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="programme" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students by Programme</span>
                        </label>
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="current_status" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students by Current Status</span>
                        </label>
                    </div>
                </div>
                
                <!-- Condition Match Type (Include/Exclude) -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Match Type</label>
                    <div class="cd-toggle-group">
                        <label class="cd-toggle cd-toggle--include">
                            <input type="radio" name="conditionNegate" value="include" checked />
                            <span class="cd-toggle__text"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg> Meets condition</span>
                        </label>
                        <label class="cd-toggle cd-toggle--exclude">
                            <input type="radio" name="conditionNegate" value="exclude" />
                            <span class="cd-toggle__text"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg> Does NOT meet condition</span>
                        </label>
                    </div>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Choose whether to target students who match or don't match the condition.</small>
                </div>
                
                <!-- Condition: Payment Days -->
                <div id="conditionPaymentDays" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Students who paid within last</label>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <input type="number" id="txtPaymentDays" class="cd-form-input" style="width: 80px;" value="10" min="1" max="365" />
                        <span style="color: #666; font-size: 11px;">days</span>
                    </div>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Students who made a payment (CR transaction) in the accounts ledger.</small>
                </div>
                
                <!-- Condition: Entry Year -->
                <div id="conditionEntryYear" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Entry Year</label>
                    <select id="ddlBatchEntryYear" class="cd-form-select">
                        <option value="">-- Select Entry Year --</option>
                        <% for (int year = DateTime.Now.Year; year >= 2000; year--) { %>
                        <option value="<%= year %>"><%= year %></option>
                        <% } %>
                    </select>
                </div>
                
                <!-- Condition: Programme -->
                <div id="conditionProgramme" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Programme</label>
                    <asp:DropDownList ID="ddlBatchProgramme" runat="server" CssClass="cd-form-select">
                        <asp:ListItem Value="" Text="-- Select Programme --"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <!-- Condition: Current Status -->
                <div id="conditionCurrentStatus" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Current Status</label>
                    <select id="ddlBatchCurrentStatus" class="cd-form-select">
                        <option value="">-- Select Current Status --</option>
                        <option value="ADMITTED">ADMITTED</option>
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="ALUMNI">ALUMNI</option>
                        <option value="SUSPENDED">SUSPENDED</option>
                        <option value="DEFERRED">DEFERRED</option>
                    </select>
                </div>
                
                <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;" />
                
                <!-- Target Status -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Change Status To</label>
                    <select id="batchTargetStatus" class="cd-form-select">
                        <option value="">-- Select Target Status --</option>
                        <option value="ADMITTED">ADMITTED</option>
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="ALUMNI">ALUMNI</option>
                        <option value="SUSPENDED">SUSPENDED</option>
                        <option value="DEFERRED">DEFERRED</option>
                    </select>
                </div>
                
                <!-- Preview Button -->
                <div class="cd-form-group" style="margin-top: 20px;">
                    <button type="button" class="cd-btn cd-btn--secondary" onclick="previewBatchStatusChange()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        Preview Affected Students
                    </button>
                </div>
                
                <!-- Preview Results -->
                <div id="batchPreviewSection" class="cd-preview-box" style="display: none;">
                    <div class="cd-preview-box__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="cd-preview-box__content">
                        <span class="cd-preview-box__count" id="batchPreviewCount">0</span>
                        <span class="cd-preview-box__label">students will be affected</span>
                    </div>
                </div>
            </div>
            <div class="cd-modal__footer">
                <button type="button" class="cd-btn cd-btn--outline" onclick="closeBatchStatusModal()">Cancel</button>
                <button type="button" id="btnApplyBatchStatus" class="cd-btn cd-btn--primary" onclick="applyBatchStatusChange()" disabled>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Apply Changes
                </button>
            </div>
        </div>
    </div>
    
    <!-- Batch Operations Styles -->
    <style>
        /* Batch Operations Button & Menu */
        .cd-batch-ops {
            position: relative;
        }
        
        .cd-batch-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12);
            min-width: 200px;
            z-index: 1000;
            display: none;
            padding: 4px 0;
        }
        
        .cd-batch-menu.show {
            display: block;
        }
        
        .cd-batch-menu__item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            color: #333;
            text-decoration: none;
            font-size: 12px;
            transition: background 0.1s;
        }
        
        .cd-batch-menu__item:hover {
            background: #f0f4ff;
            color: #174DA4;
        }
        
        .cd-batch-menu__item svg {
            flex-shrink: 0;
            color: #666;
        }
        
        .cd-batch-menu__item:hover svg {
            color: #174DA4;
        }
        
        /* Modal Overlay */
        .cd-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 10000;
            justify-content: center;
            align-items: center;
        }
        
        /* Modal */
        .cd-modal {
            background: #fff;
            border-radius: 0;
            width: 100%;
            max-width: 480px;
            max-height: 90vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
        
        .cd-modal__header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            background: #174DA4;
            color: #fff;
        }
        
        .cd-modal__title {
            margin: 0;
            font-size: 13px;
            font-weight: 600;
            display: flex;
            align-items: center;
        }
        
        .cd-modal__close {
            background: none;
            border: none;
            color: #fff;
            font-size: 20px;
            cursor: pointer;
            line-height: 1;
            opacity: 0.8;
            transition: opacity 0.1s;
            padding: 0;
            width: 24px;
            height: 24px;
        }
        
        .cd-modal__close:hover {
            opacity: 1;
        }
        
        .cd-modal__body {
            padding: 14px;
            overflow-y: auto;
            flex: 1;
        }
        
        .cd-modal__footer {
            padding: 10px 14px;
            background: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            display: flex;
            justify-content: flex-end;
            gap: 8px;
        }
        
        /* Form Elements */
        .cd-form-group {
            margin-bottom: 12px;
        }
        
        .cd-form-label {
            display: block;
            font-size: 11px;
            font-weight: 600;
            color: #333;
            margin-bottom: 4px;
            text-transform: uppercase;
        }
        
        .cd-form-select, .cd-form-input {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ddd;
            border-radius: 0;
            font-size: 12px;
            color: #333;
            background: #fff;
            transition: border-color 0.1s;
        }
        
        .cd-form-select:focus, .cd-form-input:focus {
            outline: none;
            border-color: #174DA4;
        }
        
        .cd-condition-panel {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 0;
            border: 1px solid #e0e0e0;
        }
        
        /* Radio Button Group */
        .cd-radio-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        
        .cd-radio {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 6px 8px;
            border: 1px solid #e0e0e0;
            background: #fff;
            transition: all 0.1s;
            font-size: 11px;
        }
        
        .cd-radio:hover {
            border-color: #174DA4;
            background: #f8faff;
        }
        
        .cd-radio input[type="radio"] {
            display: none;
        }
        
        .cd-radio__mark {
            width: 14px;
            height: 14px;
            border: 2px solid #ccc;
            border-radius: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.1s;
        }
        
        .cd-radio__mark::after {
            content: '';
            width: 6px;
            height: 6px;
            background: #174DA4;
            display: none;
        }
        
        .cd-radio input[type="radio"]:checked + .cd-radio__mark {
            border-color: #174DA4;
        }
        
        .cd-radio input[type="radio"]:checked + .cd-radio__mark::after {
            display: block;
        }
        
        .cd-radio input[type="radio"]:checked ~ .cd-radio__text {
            color: #174DA4;
            font-weight: 600;
        }
        
        .cd-radio__text {
            color: #333;
        }
        
        /* Toggle Group (Include/Exclude) */
        .cd-toggle-group {
            display: flex;
            gap: 0;
            border: 1px solid #ddd;
        }
        
        .cd-toggle {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 8px 12px;
            cursor: pointer;
            font-size: 11px;
            background: #fff;
            transition: all 0.1s;
            border-right: 1px solid #ddd;
        }
        
        .cd-toggle:last-child {
            border-right: none;
        }
        
        .cd-toggle input[type="radio"] {
            display: none;
        }
        
        .cd-toggle__text {
            color: #666;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .cd-toggle__text svg {
            vertical-align: middle;
            flex-shrink: 0;
        }
        
        .cd-toggle--include input[type="radio"]:checked ~ .cd-toggle__text {
            color: #fff;
        }
        
        .cd-toggle--include input[type="radio"]:checked ~ .cd-toggle__text svg {
            stroke: #fff;
        }
        
        .cd-toggle--include:has(input:checked) {
            background: #28a745;
        }
        
        .cd-toggle--exclude input[type="radio"]:checked ~ .cd-toggle__text {
            color: #fff;
        }
        
        .cd-toggle--exclude input[type="radio"]:checked ~ .cd-toggle__text svg {
            stroke: #fff;
        }
        
        .cd-toggle--exclude:has(input:checked) {
            background: #dc3545;
        }
        
        .cd-toggle:hover {
            background: #f5f5f5;
        }
        
        .cd-toggle--include:has(input:checked):hover {
            background: #218838;
        }
        
        .cd-toggle--exclude:has(input:checked):hover {
            background: #c82333;
        }
        
        /* Preview Box */
        .cd-preview-box {
            background: #f0f4ff;
            border: 1px solid #c4d9f8;
            border-radius: 0;
            padding: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 12px;
        }
        
        .cd-preview-box__icon {
            width: 40px;
            height: 40px;
            background: #174DA4;
            border-radius: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            flex-shrink: 0;
        }
        
        .cd-preview-box__content {
            display: flex;
            flex-direction: column;
        }
        
        .cd-preview-box__count {
            font-size: 22px;
            font-weight: 700;
            color: #174DA4;
            line-height: 1.1;
        }
        
        .cd-preview-box__label {
            font-size: 11px;
            color: #666;
        }
        
        /* Buttons */
        .cd-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border: none;
            border-radius: 0;
            font-size: 11px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.1s;
        }
        
        .cd-btn--sm {
            padding: 5px 10px;
            font-size: 11px;
        }
        
        .cd-btn--primary {
            background: #174DA4;
            color: #fff;
        }
        
        .cd-btn--primary:hover {
            background: #0d3a7d;
        }
        
        .cd-btn--primary:disabled {
            background: #9eb9dc;
            cursor: not-allowed;
        }
        
        .cd-btn--secondary {
            background: #e8f0fe;
            color: #174DA4;
            border: 1px solid #c4d9f8;
        }
        
        .cd-btn--secondary:hover {
            background: #d4e4fc;
        }
        
        .cd-btn--outline {
            background: #fff;
            color: #666;
            border: 1px solid #ddd;
        }
        
        .cd-btn--outline:hover {
            background: #f5f5f5;
            border-color: #ccc;
        }
    </style>
    
</asp:Content>
