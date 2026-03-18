<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HREmployees.aspx.cs" Inherits="COOPERP_NewScreens_HREmployees" Title="Employee Management - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ========== EMPLOYEE MODULE STYLES ========== */
/* Brand: #174DA4 | All border-radius: 0 (square design) */

/* --- Photo thumbnail --- */
.hr-emp-thumb { width:32px; height:32px; border-radius:50%; object-fit:cover; cursor:pointer; border:2px solid #e0e0e0; transition:transform .15s,box-shadow .15s; }
.hr-emp-thumb:hover { transform:scale(1.15); box-shadow:0 2px 8px rgba(0,0,0,.18); }

/* --- Lightbox --- */
.hr-lightbox-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.85); z-index:99999; align-items:center; justify-content:center; flex-direction:column; }
.hr-lightbox-overlay img { max-width:340px; max-height:340px; border-radius:50%; border:4px solid #fff; object-fit:cover; box-shadow:0 4px 24px rgba(0,0,0,.5); }
.hr-lightbox-overlay .hr-lb-name { color:#fff; font-size:16px; font-weight:700; margin-top:14px; }
.hr-lightbox-overlay .hr-lb-code { color:#b0b0b0; font-size:12px; margin-top:2px; }
.hr-lightbox-close { position:absolute; top:18px; right:24px; color:#fff; font-size:28px; cursor:pointer; background:none; border:none; font-weight:700; z-index:100000; }

/* --- Filter Bar --- */
.hr-filters { display:flex; flex-direction:column; gap:8px; padding:10px 14px; border-bottom:1px solid #e0e0e0; background:#fafbfc; }
.hr-filters-row { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
.hr-search-box { flex:1; min-width:200px; max-width:360px; padding:6px 10px; border:1px solid #ccc; border-radius:4px; font-size:12px; outline:none; }
.hr-search-box:focus { border-color:#174DA4; box-shadow:0 0 0 2px rgba(23,77,164,.12); }
.hr-count-badge { background:#174DA4; color:#fff; padding:2px 10px; border-radius:10px; font-size:11px; font-weight:600; }
.hr-filter-select { padding:5px 8px; border:1px solid #ccc; border-radius:0; font-size:11px; background:#fff; min-width:120px; }

/* --- Card container --- */
.cd-card { background:#fff; border:1px solid #e0e0e0; border-radius:0; }
.cd-card__header { display:flex; align-items:center; justify-content:space-between; padding:10px 14px; border-bottom:1px solid #e0e0e0; }
.cd-card__title { font-size:14px; font-weight:700; color:#1a1a1a; display:flex; align-items:center; gap:8px; }
.cd-card__body { padding:0; }
.cd-p-0 { padding:0 !important; }

/* --- Status badges --- */
.hr-badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; border-radius:0; text-transform:uppercase; letter-spacing:.3px; }
.hr-badge--active { background:#d4edda; color:#155724; }
.hr-badge--valid { background:#d4edda; color:#155724; }
.hr-badge--expired { background:#f8d7da; color:#721c24; }
.hr-badge--terminated { background:#f5c6cb; color:#721c24; }
.hr-badge--resigned { background:#fff3cd; color:#856404; }
.hr-badge--academic { background:#cce5ff; color:#004085; }
.hr-badge--admin { background:#e2e3e5; color:#383d41; }

/* --- Action column uses master cd-action-* popover system from sidebar.css --- */

/* --- Employee Profile Popup --- */
.ep-container { font-family:Segoe UI,Tahoma,sans-serif; height:100%; overflow:hidden; }
.ep-container .dxpLite_Glass .dxtc-content { padding:8px 12px !important; overflow-y:auto !important; }
.ep-tab-scroll { overflow-y:auto; -webkit-overflow-scrolling:touch; }
.ep-profile-header { display:flex; align-items:flex-start; gap:14px; padding:12px 16px; background:linear-gradient(135deg,#f8f9fb 0%,#eef1f5 100%); border-bottom:1px solid #e0e0e0; }
.ep-photo-wrap { flex-shrink:0; }
.ep-photo { width:68px; height:68px; border-radius:50%; object-fit:cover; border:2px solid #174DA4; }
.ep-photo-placeholder { width:68px; height:68px; border-radius:50%; background:#e0e0e0; display:flex; align-items:center; justify-content:center; border:2px solid #174DA4; }
.ep-info { flex:1; min-width:0; }
.ep-name { font-size:16px; font-weight:700; color:#1a1a1a; margin:0 0 1px; line-height:1.2; }
.ep-code { font-size:11px; color:#666; margin:0 0 4px; }
.ep-quick-stats { display:flex; gap:10px; flex-wrap:wrap; margin-top:4px; }
.ep-stat { display:flex; align-items:center; gap:3px; font-size:10px; color:#555; }
.ep-stat svg { color:#174DA4; flex-shrink:0; }

/* --- Force profile popup to be wide --- */
.dxpcLite_Glass.dxpc-mainDiv[id*='popEmployeeProfile'] { width:95vw !important; max-width:1400px !important; height:90vh !important; left:50% !important; transform:translateX(-50%) !important; }

/* --- Profile tabs override --- */
.ep-container .dxpLite_Glass { border:none !important; }
.ep-container .dxpLite_Glass .dxtc-stripContainer { background:#fff !important; border-bottom:1px solid #d0d0d0 !important; padding:0 4px !important; }
.ep-container .dxtc-activeTab,
.ep-container .dxpLite_Glass .dxtc-activeTab,
.ep-container .dxpLite_Glass td.dxtc-activeTab { border-bottom:2px solid #174DA4 !important; background:#e8f0fe !important; }
.ep-container .dxtc-activeTab *,
.ep-container .dxpLite_Glass .dxtc-activeTab *,
.ep-container .dxpLite_Glass .dxtc-activeTab a,
.ep-container .dxpLite_Glass .dxtc-activeTab span,
.ep-container .dxpLite_Glass .dxtc-activeTab .dxtc-text,
.ep-container .dxpLite_Glass td.dxtc-activeTab a,
.ep-container .dxpLite_Glass td.dxtc-activeTab span { color:#174DA4 !important; }
.ep-container .dxpLite_Glass .dxtc-tab { padding:4px 10px !important; font-size:10px !important; font-weight:600 !important; border:none !important; background:transparent !important; margin:0 !important; }
.ep-container .dxpLite_Glass .dxtc-tab a,
.ep-container .dxpLite_Glass .dxtc-tab span,
.ep-container .dxpLite_Glass .dxtc-tab .dxtc-text { color:#555 !important; }
.ep-container .dxpLite_Glass .dxtc-tab:hover { background:#f5f5f5 !important; }
.ep-container .dxpLite_Glass .dxtc-tab:hover a,
.ep-container .dxpLite_Glass .dxtc-tab:hover span,
.ep-container .dxpLite_Glass .dxtc-tab:hover .dxtc-text { color:#174DA4 !important; }
.ep-container .dxpLite_Glass .dxtc-tabRow td { padding:0 !important; }

/* --- Bio data grid --- */
.ep-bio-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:0; }
.ep-bio-item { padding:6px 10px; border-bottom:1px solid #f0f0f0; border-right:1px solid #f0f0f0; }
.ep-bio-label { font-size:9px; text-transform:uppercase; color:#888; letter-spacing:.4px; font-weight:600; margin-bottom:1px; }
.ep-bio-value { font-size:11px; color:#1a1a1a; font-weight:500; line-height:1.3; }

/* --- Data tables --- */
.ep-data-table { width:100%; border-collapse:collapse; font-size:11px; }
.ep-data-table th { background:#f5f7fa; color:#555; font-size:10px; text-transform:uppercase; letter-spacing:.3px; padding:6px 10px; border-bottom:2px solid #e0e0e0; text-align:left; font-weight:600; }
.ep-data-table td { padding:6px 10px; border-bottom:1px solid #f0f0f0; color:#333; }
.ep-data-table tr:hover td { background:#f8f9fc; }
.ep-data-table .text-right { text-align:right; }
.ep-data-table .text-center { text-align:center; }

/* --- Modal system (batch operations) --- */
.hr-modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.5); z-index:10000; align-items:center; justify-content:center; }
.hr-modal { background:#fff; width:520px; max-width:95vw; max-height:85vh; overflow-y:auto; border-radius:0; box-shadow:0 8px 32px rgba(0,0,0,.2); }
.hr-modal__header { background:#174DA4; color:#fff; padding:10px 16px; font-size:13px; font-weight:700; display:flex; align-items:center; justify-content:space-between; }
.hr-modal__close { background:none; border:none; color:#fff; font-size:18px; cursor:pointer; padding:0 4px; }
.hr-modal__body { padding:16px; }
.hr-modal__footer { padding:10px 16px; border-top:1px solid #e0e0e0; display:flex; justify-content:flex-end; gap:8px; }

/* --- Form elements --- */
.hr-form-group { margin-bottom:10px; }
.hr-form-label { display:block; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#666; font-weight:600; margin-bottom:3px; }
.hr-form-input, .hr-form-select, .hr-form-textarea { width:100%; padding:6px 8px; border:1px solid #ccc; border-radius:0; font-size:12px; box-sizing:border-box; }
.hr-form-input:focus, .hr-form-select:focus, .hr-form-textarea:focus { border-color:#174DA4; outline:none; box-shadow:0 0 0 2px rgba(23,77,164,.1); }
.hr-form-row { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.hr-form-row-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px; }

/* --- Buttons --- */
.hr-btn { padding:6px 14px; font-size:11px; font-weight:600; border:none; cursor:pointer; border-radius:0; display:inline-flex; align-items:center; gap:4px; }
.hr-btn--primary { background:#174DA4; color:#fff; }
.hr-btn--primary:hover { background:#1256b8; }
.hr-btn--secondary { background:#6c757d; color:#fff; }
.hr-btn--secondary:hover { background:#5a6268; }
.hr-btn--success { background:#28a745; color:#fff; }
.hr-btn--success:hover { background:#218838; }
.hr-btn--danger { background:#dc3545; color:#fff; }
.hr-btn--danger:hover { background:#c82333; }
.hr-btn--outline { background:#fff; color:#174DA4; border:1px solid #174DA4; }
.hr-btn--outline:hover { background:#174DA4; color:#fff; }
.hr-btn--sm { padding:4px 10px; font-size:10px; }

/* --- Preview Box --- */
.hr-preview-box { background:#e8f0fe; border-left:3px solid #174DA4; padding:10px 14px; margin:10px 0; font-size:12px; color:#174DA4; }

/* --- Grid scroll wrapper --- */
.hr-grid-scroll { overflow-x:auto; overflow-y:visible; -webkit-overflow-scrolling:touch; width:100%; }

/* --- Responsive --- */
@media (max-width:1200px) {
    .hr-filters-row { flex-wrap:wrap; }
    .hr-search-box { min-width:160px; max-width:100%; flex:1 1 200px; }
    .hr-filter-select { min-width:100px; flex:1 1 100px; }
}

@media (max-width:992px) {
    .hr-filters-row { gap:6px; }
    .cd-card__header { flex-wrap:wrap; gap:6px; }
    .hr-search-box { max-width:100%; min-width:0; flex:1 1 100%; }
    .hr-filter-select { flex:1 1 calc(50% - 4px); min-width:0; }
}

@media (max-width:768px) {
    .ep-profile-header { flex-direction:column; align-items:center; text-align:center; gap:8px; padding:10px 12px; }
    .ep-bio-grid { grid-template-columns:repeat(2,1fr); }
    .ep-quick-stats { justify-content:center; }
    .ep-container .dxpLite_Glass .dxtc-tab { padding:3px 6px !important; font-size:9px !important; }
    .hr-form-row, .hr-form-row-3 { grid-template-columns:1fr; }
    .hr-filters { padding:8px 10px; }
    .hr-filters-row { flex-direction:column; gap:6px; }
    .hr-search-box { max-width:100%; }
    .hr-filter-select { width:100%; }
    .cd-card__header { padding:8px 10px; }
    .cd-card__title { font-size:12px; }
    .hr-modal { width:95vw !important; }
}

@media (max-width:576px) {
    .ep-bio-grid { grid-template-columns:1fr; }
    .hr-form-row { grid-template-columns:1fr; }
    .cd-card__header { flex-direction:column; align-items:flex-start; }
}

/* DevExpress grid overrides */
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass { font-size:10px !important; text-transform:uppercase !important; letter-spacing:.3px !important; }
.dxgvDataRow_Glass td, .dxgvGroupRow_Glass td { font-size:11px !important; padding:4px 8px !important; }
.dxgvEditFormDisplayRow_Glass { background:#fffde7 !important; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hdnSelectedEmpID" runat="server" />
<asp:HiddenField ID="hdnPwdEmpID" runat="server" />
<dx:ASPxButton ID="btnLoadProfile" runat="server" Text="Load" ClientVisible="false" OnClick="btnLoadProfile_Click" ClientInstanceName="btnLoadProfile" />
<asp:Button ID="btnChangePassword" runat="server" Text="Go" OnClick="btnChangePassword_Click" Style="display:none" />

<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            Employee Management
        </div>
        <div style="display:flex;gap:6px;">
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="openAddEmployeeModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Add Employee
            </button>
        </div>
    </div>
    
    <!-- Filters -->
    <div class="hr-filters">
        <div class="hr-filters-row">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="hr-search-box" placeholder="Search by name, code, email, phone..." />
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnSearch_Click" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="hr-btn hr-btn--outline hr-btn--sm" OnClick="btnReset_Click" />
            <span class="hr-count-badge"><asp:Literal ID="litCount" runat="server" Text="0" /> employees</span>
        </div>
        <div class="hr-filters-row">
            <asp:DropDownList ID="ddlFilterDept" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Text="All Departments" Value="" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterStation" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Text="All Stations" Value="" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Text="All Types" Value="" />
                <asp:ListItem Text="Academic" Value="Academic" />
                <asp:ListItem Text="Administrative" Value="Administrative" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="hr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Text="All Statuses" Value="" />
                <asp:ListItem Text="VALID" Value="VALID" />
                <asp:ListItem Text="EXPIRED" Value="EXPIRED" />
                <asp:ListItem Text="TERMINATED" Value="TERMINATED" />
                <asp:ListItem Text="RESIGNED" Value="RESIGNED" />
            </asp:DropDownList>
        </div>
    </div>
    
    <!-- Grid -->
    <div class="cd-card__body cd-p-0">
      <div class="hr-grid-scroll">
        <dx:ASPxGridView ID="gvEmployees" runat="server" Width="100%" ClientInstanceName="gvEmployees"
            KeyFieldName="empID" EnableCallBacks="false" Theme="Glass"
            OnRowUpdating="gvEmployees_RowUpdating" OnRowDeleting="gvEmployees_RowDeleting">
            <SettingsPager PageSize="25">
                <Summary Text="Page {0} of {1} ({2} employees)" />
            </SettingsPager>
            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
            <SettingsEditing Mode="PopupEditForm" />
            <SettingsPopup>
                <EditForm Width="780" Height="650" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
            </SettingsPopup>
            <EditFormLayoutProperties ColCount="2">
                <Items>
                    <dx:GridViewLayoutGroup Caption="Personal Information" ColCount="2" ColSpan="2">
                        <Items>
                            <dx:GridViewColumnLayoutItem ColumnName="emp_name" ColSpan="2" />
                            <dx:GridViewColumnLayoutItem ColumnName="emp_email" ColSpan="2" />
                            <dx:GridViewColumnLayoutItem ColumnName="emp_phone" />
                            <dx:GridViewColumnLayoutItem ColumnName="emp_birthdate" />
                            <dx:GridViewColumnLayoutItem ColumnName="gender" />
                            <dx:GridViewColumnLayoutItem ColumnName="emp_nationality" />
                            <dx:GridViewColumnLayoutItem ColumnName="religion" />
                            <dx:GridViewColumnLayoutItem ColumnName="tribe" />
                            <dx:GridViewColumnLayoutItem ColumnName="marital_status" />
                            <dx:GridViewColumnLayoutItem ColumnName="address" />
                            <dx:GridViewColumnLayoutItem ColumnName="current_residence" ColSpan="2" />
                        </Items>
                    </dx:GridViewLayoutGroup>
                    <dx:GridViewLayoutGroup Caption="Employment Details" ColCount="2" ColSpan="2">
                        <Items>
                            <dx:GridViewColumnLayoutItem ColumnName="EmpType" />
                            <dx:GridViewColumnLayoutItem ColumnName="max_education" />
                            <dx:GridViewColumnLayoutItem ColumnName="emp_qualifications" ColSpan="2" />
                            <dx:GridViewColumnLayoutItem ColumnName="Entry_Year" />
                            <dx:GridViewColumnLayoutItem ColumnName="Entry_Satation" />
                            <dx:GridViewColumnLayoutItem ColumnName="usernames" />
                        </Items>
                    </dx:GridViewLayoutGroup>
                    <dx:GridViewLayoutGroup Caption="Financial Details" ColCount="2" ColSpan="2">
                        <Items>
                            <dx:GridViewColumnLayoutItem ColumnName="bankID" />
                            <dx:GridViewColumnLayoutItem ColumnName="bankAccount" />
                            <dx:GridViewColumnLayoutItem ColumnName="tin" />
                            <dx:GridViewColumnLayoutItem ColumnName="nssf_no" />
                        </Items>
                    </dx:GridViewLayoutGroup>
                    <dx:GridViewLayoutGroup Caption="Family &amp; Emergency" ColCount="2" ColSpan="2">
                        <Items>
                            <dx:GridViewColumnLayoutItem ColumnName="spouse_name" />
                            <dx:GridViewColumnLayoutItem ColumnName="no_children" />
                            <dx:GridViewColumnLayoutItem ColumnName="father_name" />
                            <dx:GridViewColumnLayoutItem ColumnName="mother_name" />
                            <dx:GridViewColumnLayoutItem ColumnName="contact_person" />
                            <dx:GridViewColumnLayoutItem ColumnName="relation" />
                            <dx:GridViewColumnLayoutItem ColumnName="phone_contacts" ColSpan="2" />
                            <dx:GridViewColumnLayoutItem ColumnName="referee_1" ColSpan="2" />
                            <dx:GridViewColumnLayoutItem ColumnName="referee_2" ColSpan="2" />
                        </Items>
                    </dx:GridViewLayoutGroup>
                    <dx:GridViewLayoutGroup Caption="Additional Information" ColCount="1" ColSpan="2">
                        <Items>
                            <dx:GridViewColumnLayoutItem ColumnName="medical_background" />
                            <dx:GridViewColumnLayoutItem ColumnName="schooling_info" />
                            <dx:GridViewColumnLayoutItem ColumnName="employment_info" />
                        </Items>
                    </dx:GridViewLayoutGroup>
                    <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right" />
                </Items>
            </EditFormLayoutProperties>
            <Columns>
                <dx:GridViewDataTextColumn FieldName="empID" Caption="ID" Width="50" EditFormSettings-Visible="False" Visible="false" />
                
                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff Code" Width="90" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;color:#174DA4;"><%# Eval("EMP_CODE") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee Name" Width="200">
                    <DataItemTemplate>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <img src='<%# GetPhotoUrl(Eval("EMP_CODE")) %>' class="hr-emp-thumb"
                                 onerror="this.onerror=null; this.src='../staffimages/default.jpg'"
                                 data-empname='<%# Eval("emp_name") %>' data-empcode='<%# Eval("EMP_CODE") %>'
                                 onclick="openLightbox(this.src, this.dataset.empname, this.dataset.empcode)"
                                 alt="" />
                            <div>
                                <div style="font-weight:600;font-size:11px;color:#1a1a1a;"><%# Eval("emp_name") %></div>
                                <div style="font-size:10px;color:#888;"><%# Eval("emp_email") %></div>
                            </div>
                        </div>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="emp_phone" Caption="Phone" Width="110" />
                <dx:GridViewDataTextColumn FieldName="emp_email" Caption="Email" Width="160" Visible="false" />
                
                <dx:GridViewDataComboBoxColumn FieldName="EmpType" Caption="Type" Width="90">
                    <PropertiesComboBox>
                        <Items>
                            <dx:ListEditItem Text="Academic" Value="Academic" />
                            <dx:ListEditItem Text="Administrative" Value="Administrative" />
                            <dx:ListEditItem Text="Support" Value="Support" />
                            <dx:ListEditItem Text="Consultant" Value="Consultant" />
                            <dx:ListEditItem Text="Adjunct" Value="Adjunct" />
                            <dx:ListEditItem Text="Parttime" Value="Parttime" />
                        </Items>
                    </PropertiesComboBox>
                    <DataItemTemplate>
                        <span class='hr-badge <%# Eval("EmpType").ToString().Contains("Acad") ? "hr-badge--academic" : "hr-badge--admin" %>'><%# Eval("EmpType") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataComboBoxColumn>
                
                <dx:GridViewDataTextColumn FieldName="dept_name" Caption="Department" Width="140" EditFormSettings-Visible="False" />
                <dx:GridViewDataTextColumn FieldName="station_name" Caption="Station" Width="110" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataTextColumn FieldName="contractStatus" Caption="Status" Width="90" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <%# GetStatusBadge(Eval("contractStatus")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="scale_name" Caption="Pay Scale" Width="90" EditFormSettings-Visible="False" />
                <dx:GridViewDataTextColumn FieldName="basicpay" Caption="Basic Pay" Width="100" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <%# FormatAmount(Eval("basicpay")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataDateColumn FieldName="emp_birthdate" Caption="DOB" Width="90" Visible="false">
                    <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy" />
                </dx:GridViewDataDateColumn>
                
                <dx:GridViewDataTextColumn FieldName="emp_qualifications" Caption="Qualification" Width="120" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="emp_nationality" Caption="Nationality" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="religion" Caption="Religion" Width="80" Visible="false" />
                
                <dx:GridViewDataComboBoxColumn FieldName="marital_status" Caption="Marital Status" Width="90" Visible="false">
                    <PropertiesComboBox>
                        <Items>
                            <dx:ListEditItem Text="SINGLE" Value="SINGLE" />
                            <dx:ListEditItem Text="MARRIED" Value="MARRIED" />
                            <dx:ListEditItem Text="DIVORCED" Value="DIVORCED" />
                            <dx:ListEditItem Text="WIDOWED" Value="WIDOWED" />
                        </Items>
                    </PropertiesComboBox>
                </dx:GridViewDataComboBoxColumn>
                
                <dx:GridViewDataTextColumn FieldName="address" Caption="Address" Width="120" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="current_residence" Caption="Current Residence" Width="120" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="tribe" Caption="Tribe" Width="80" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="tin" Caption="TIN" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="nssf_no" Caption="NSSF No" Width="100" Visible="false" />
                <dx:GridViewDataComboBoxColumn FieldName="gender" Caption="Gender" Width="70" Visible="false">
                    <PropertiesComboBox>
                        <Items>
                            <dx:ListEditItem Text="Male" Value="Male" />
                            <dx:ListEditItem Text="Female" Value="Female" />
                        </Items>
                    </PropertiesComboBox>
                </dx:GridViewDataComboBoxColumn>
                <dx:GridViewDataComboBoxColumn FieldName="max_education" Caption="Education Level" Width="100" Visible="false">
                    <PropertiesComboBox>
                        <Items>
                            <dx:ListEditItem Text="Certificate" Value="Certificate" />
                            <dx:ListEditItem Text="Diploma" Value="Diploma" />
                            <dx:ListEditItem Text="Bachelors" Value="Bachelors" />
                            <dx:ListEditItem Text="Masters" Value="Masters" />
                            <dx:ListEditItem Text="PHD" Value="PHD" />
                            <dx:ListEditItem Text="Professor" Value="Professor" />
                            <dx:ListEditItem Text="NA" Value="NA" />
                        </Items>
                    </PropertiesComboBox>
                </dx:GridViewDataComboBoxColumn>
                <dx:GridViewDataComboBoxColumn FieldName="bankID" Caption="Bank" Width="100" Visible="false">
                    <PropertiesComboBox DataSourceID="dsBanks" TextField="bank_name" ValueField="bank_id" />
                </dx:GridViewDataComboBoxColumn>
                <dx:GridViewDataTextColumn FieldName="bankAccount" Caption="Account No" Width="120" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="usernames" Caption="User Name" Width="80" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="Entry_Year" Caption="Entry Year" Width="70" Visible="false" />
                <dx:GridViewDataComboBoxColumn FieldName="Entry_Satation" Caption="Entry Station" Width="100" Visible="false">
                    <PropertiesComboBox DataSourceID="dsStations" TextField="station_name" ValueField="ID" />
                </dx:GridViewDataComboBoxColumn>
                <dx:GridViewDataTextColumn FieldName="spouse_name" Caption="Spouse Name" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="no_children" Caption="No. Children" Width="70" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="contact_person" Caption="Contact Person" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="relation" Caption="Relation" Width="80" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="phone_contacts" Caption="Phone Contacts" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="father_name" Caption="Father Name" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="mother_name" Caption="Mother Name" Width="100" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="referee_1" Caption="Referee 1" Width="120" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="referee_2" Caption="Referee 2" Width="120" Visible="false" />
                <dx:GridViewDataMemoColumn FieldName="medical_background" Caption="Medical Background" Visible="false">
                    <PropertiesMemoEdit Rows="3" />
                </dx:GridViewDataMemoColumn>
                <dx:GridViewDataMemoColumn FieldName="schooling_info" Caption="Academic / Prof. Training" Visible="false">
                    <PropertiesMemoEdit Rows="3" />
                </dx:GridViewDataMemoColumn>
                <dx:GridViewDataMemoColumn FieldName="employment_info" Caption="Employment History" Visible="false">
                    <PropertiesMemoEdit Rows="3" />
                </dx:GridViewDataMemoColumn>
                
                <dx:GridViewDataTextColumn Caption="Actions" Width="50" EditFormSettings-Visible="False" Settings-AllowAutoFilter="False" Settings-AllowSort="False" CellStyle-CssClass="cd-action-cell">
                    <DataItemTemplate>
                        <%# GetActionButtonsHtml(Eval("empID"), Eval("emp_name"), Eval("usernames"), Eval("emp_email")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
            </Columns>
        </dx:ASPxGridView>
      </div>
    </div>
</div>

<!-- ========== EMPLOYEE PROFILE POPUP ========== -->
<dx:ASPxPopupControl ID="popEmployeeProfile" runat="server" ClientInstanceName="popEmployeeProfile"
    Width="1400px" Height="850px" Modal="True" AllowDragging="true" AllowResize="true"
    CloseAction="CloseButton" ShowHeader="true" HeaderText="Employee Profile"
    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
    LoadContentViaCallback="None">
    <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Bold="true" Font-Size="12px" Paddings-PaddingTop="8px" Paddings-PaddingBottom="8px" Paddings-PaddingLeft="12px" Paddings-PaddingRight="12px" />
    <ContentStyle Paddings-Padding="0px" />
    <ContentCollection>
        <dx:PopupControlContentControl>
            <div class="ep-container">
                <div class="ep-profile-header">
                    <div class="ep-photo-wrap">
                        <asp:Image ID="imgProfilePhoto" runat="server" CssClass="ep-photo" />
                    </div>
                    <div class="ep-info">
                        <h2 class="ep-name"><asp:Literal ID="litEmpName" runat="server" /></h2>
                        <p class="ep-code"><asp:Literal ID="litEmpCode" runat="server" /> &bull; <asp:Literal ID="litEmpType" runat="server" /></p>
                        <div class="ep-quick-stats">
                            <div class="ep-stat">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                                <asp:Literal ID="litDeptStat" runat="server" />
                            </div>
                            <div class="ep-stat">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                <asp:Literal ID="litStationStat" runat="server" />
                            </div>
                            <div class="ep-stat">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                                <asp:Literal ID="litPayStat" runat="server" />
                            </div>
                            <div class="ep-stat">
                                <asp:Literal ID="litStatusBadge" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
                
                <dx:ASPxPageControl ID="tabEmployeeProfile" runat="server" Theme="Glass" Width="100%" EnableTabScrolling="True">
                    <ClientSideEvents ActiveTabChanged="function(s,e){ setTimeout(fixProfileScroll, 100); }" />
                    <TabPages>
                        <dx:TabPage Text="Bio Data">
                            <ContentCollection>
                                <dx:ContentControl>
                                    <asp:Literal ID="litBioData" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        
                        <dx:TabPage Text="Contracts">
                            <ContentCollection>
                                <dx:ContentControl>
                                    <asp:Literal ID="litContracts" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        
                        <dx:TabPage Text="Qualifications">
                            <ContentCollection>
                                <dx:ContentControl>
                                    <asp:Literal ID="litQualifications" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        
                        <dx:TabPage Text="Leave">
                            <ContentCollection>
                                <dx:ContentControl>
                                    <asp:Literal ID="litLeave" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        
                        <dx:TabPage Text="Payroll History">
                            <ContentCollection>
                                <dx:ContentControl>
                                    <asp:Literal ID="litPayroll" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        
                        <dx:TabPage Text="Emergency Info">
                            <ContentCollection>
                                <dx:ContentControl>
                                    <asp:Literal ID="litEmergency" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                    </TabPages>
                </dx:ASPxPageControl>
            </div>
        </dx:PopupControlContentControl>
    </ContentCollection>
</dx:ASPxPopupControl>

<!-- ========== ADD EMPLOYEE MODAL ========== -->
<div class="hr-modal-overlay" id="addEmployeeModal">
    <div class="hr-modal" style="width:780px;">
        <div class="hr-modal__header">
            <span>Add New Employee</span>
            <button type="button" class="hr-modal__close" onclick="closeAddEmployeeModal()">&#215;</button>
        </div>
        <div class="hr-modal__body">
            <div style="font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;margin-bottom:8px;border-bottom:1px solid #e0e0e0;padding-bottom:4px;">Personal Information</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Full Name *</label>
                    <asp:TextBox ID="txtNewName" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Email *</label>
                    <asp:TextBox ID="txtNewEmail" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Phone *</label>
                    <asp:TextBox ID="txtNewPhone" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Date of Birth</label>
                    <asp:TextBox ID="txtNewDOB" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Gender</label>
                    <asp:DropDownList ID="ddlNewGender" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="Male" Value="Male" />
                        <asp:ListItem Text="Female" Value="Female" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Nationality</label>
                    <asp:DropDownList ID="ddlNewNationality" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="UGANDAN" Value="UGANDAN" Selected="True" />
                        <asp:ListItem Text="KENYAN" Value="KENYAN" />
                        <asp:ListItem Text="TANZANIAN" Value="TANZANIAN" />
                        <asp:ListItem Text="RWANDAN" Value="RWANDAN" />
                        <asp:ListItem Text="SOUTH SUDANESE" Value="SOUTH SUDANESE" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Religion</label>
                    <asp:TextBox ID="txtNewReligion" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Tribe</label>
                    <asp:TextBox ID="txtNewTribe" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Marital Status</label>
                    <asp:DropDownList ID="ddlNewMarital" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="SINGLE" Value="SINGLE" />
                        <asp:ListItem Text="MARRIED" Value="MARRIED" />
                        <asp:ListItem Text="DIVORCED" Value="DIVORCED" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Address</label>
                    <asp:TextBox ID="txtNewAddress" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Current Residence</label>
                <asp:TextBox ID="txtNewResidence" runat="server" CssClass="hr-form-input" Text="UGANDA" />
            </div>

            <div style="font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;margin:12px 0 8px;border-bottom:1px solid #e0e0e0;padding-bottom:4px;">Employment Details</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Employee Type *</label>
                    <asp:DropDownList ID="ddlNewType" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="Academic" Value="Academic" />
                        <asp:ListItem Text="Administrative" Value="Administrative" />
                        <asp:ListItem Text="Support" Value="Support" />
                        <asp:ListItem Text="Consultant" Value="Consultant" />
                        <asp:ListItem Text="Adjunct" Value="Adjunct" />
                        <asp:ListItem Text="Parttime" Value="Parttime" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Education Level</label>
                    <asp:DropDownList ID="ddlNewEducation" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="NA" Value="NA" />
                        <asp:ListItem Text="Certificate" Value="Certificate" />
                        <asp:ListItem Text="Diploma" Value="Diploma" />
                        <asp:ListItem Text="Bachelors" Value="Bachelors" />
                        <asp:ListItem Text="Masters" Value="Masters" />
                        <asp:ListItem Text="PHD" Value="PHD" />
                        <asp:ListItem Text="Professor" Value="Professor" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Qualifications</label>
                <asp:TextBox ID="txtNewQualifications" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" />
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Entry Year</label>
                    <asp:TextBox ID="txtNewEntryYear" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Entry Station</label>
                    <asp:DropDownList ID="ddlNewStation" runat="server" CssClass="hr-form-select" />
                </div>
            </div>

            <div style="font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;margin:12px 0 8px;border-bottom:1px solid #e0e0e0;padding-bottom:4px;">Financial Details</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Bank</label>
                    <asp:DropDownList ID="ddlNewBank" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Bank Account No</label>
                    <asp:TextBox ID="txtNewBankAccount" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">TIN</label>
                    <asp:TextBox ID="txtNewTIN" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">NSSF No</label>
                    <asp:TextBox ID="txtNewNSSF" runat="server" CssClass="hr-form-input" />
                </div>
            </div>

            <div style="font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;margin:12px 0 8px;border-bottom:1px solid #e0e0e0;padding-bottom:4px;">Family &amp; Emergency</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Spouse Name</label>
                    <asp:TextBox ID="txtNewSpouse" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">No. of Children</label>
                    <asp:TextBox ID="txtNewChildren" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Father Name</label>
                    <asp:TextBox ID="txtNewFather" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Mother Name</label>
                    <asp:TextBox ID="txtNewMother" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Emergency Contact Person</label>
                    <asp:TextBox ID="txtNewContactPerson" runat="server" CssClass="hr-form-input" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Relationship</label>
                    <asp:TextBox ID="txtNewRelation" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Emergency Contact Phone</label>
                <asp:TextBox ID="txtNewContactPhone" runat="server" CssClass="hr-form-input" />
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Referee 1</label>
                    <asp:TextBox ID="txtNewReferee1" runat="server" CssClass="hr-form-input" Text="-" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Referee 2</label>
                    <asp:TextBox ID="txtNewReferee2" runat="server" CssClass="hr-form-input" Text="-" />
                </div>
            </div>

            <div style="font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;margin:12px 0 8px;border-bottom:1px solid #e0e0e0;padding-bottom:4px;">Additional Information</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Medical Background</label>
                <asp:TextBox ID="txtNewMedical" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" />
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Academic / Professional Training</label>
                <asp:TextBox ID="txtNewSchooling" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" />
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Employment History</label>
                <asp:TextBox ID="txtNewEmployment" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" />
            </div>

            <div id="addEmpResult" style="margin-top:8px;font-size:12px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--secondary hr-btn--sm" onclick="closeAddEmployeeModal()">Cancel</button>
            <asp:Button ID="btnAddEmployee" runat="server" Text="Add Employee" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnAddEmployee_Click" />
        </div>
    </div>
</div>

<!-- SQL Data Sources for Grid ComboBox Columns -->
<asp:SqlDataSource ID="dsBanks" runat="server" ConnectionString="<%$ ConnectionStrings:vacConnectionString %>"
    ProviderName="MySql.Data.MySqlClient" SelectCommand="SELECT bank_id, bank_name FROM banks ORDER BY bank_name" />
<asp:SqlDataSource ID="dsStations" runat="server" ConnectionString="<%$ ConnectionStrings:vacConnectionString %>"
    ProviderName="MySql.Data.MySqlClient" SelectCommand="SELECT ID, station_name FROM hrm_stations ORDER BY station_name" />

<!-- ========== CHANGE PASSWORD MODAL ========== -->
<div class="hr-modal-overlay" id="changePwdModal">
    <div class="hr-modal" style="width:400px;">
        <div class="hr-modal__header">
            <span>Change User Password</span>
            <button type="button" class="hr-modal__close" onclick="closePwdModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="pwdEmpInfo" style="font-size:12px;color:#555;margin-bottom:12px;padding:8px 10px;background:#f5f7fa;border-left:3px solid #174DA4;"></div>
            <div class="hr-form-group">
                <label class="hr-form-label">New Password</label>
                <asp:TextBox ID="txtNewPassword" runat="server" CssClass="hr-form-input" TextMode="Password" />
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Confirm Password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="hr-form-input" TextMode="Password" />
            </div>
            <div id="pwdResult" style="margin-top:8px;font-size:12px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--secondary hr-btn--sm" onclick="closePwdModal()">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="submitPasswordChange()">Change Password</button>
        </div>
    </div>
</div>

<!-- ========== PHOTO LIGHTBOX ========== -->
<div class="hr-lightbox-overlay" id="hrLightbox" onclick="closeLightbox()">
    <button class="hr-lightbox-close" onclick="closeLightbox()">&times;</button>
    <img id="lbPhoto" src="" alt="" />
    <div class="hr-lb-name" id="lbName"></div>
    <div class="hr-lb-code" id="lbCode"></div>
</div>

<script type="text/javascript">
/* === Profile Loader === */
function openEmployeeProfile(empID) {
    document.getElementById('<%= hdnSelectedEmpID.ClientID %>').value = empID;
    btnLoadProfile.DoClick();
    setTimeout(fixProfileScroll, 300);
    setTimeout(fixProfileScroll, 800);
}
function fixProfileScroll() {
    var container = document.querySelector('.ep-container');
    if (!container) return;
    var popup = container.closest('.dxpc-contentWrapper') || container.parentElement;
    if (!popup) return;
    var popH = popup.offsetHeight || popup.clientHeight;
    var header = container.querySelector('.ep-profile-header');
    var headerH = header ? header.offsetHeight : 0;
    var tabs = container.querySelectorAll('.dxtc-content');
    var stripH = 35;
    var availH = popH - headerH - stripH - 10;
    if (availH < 200) availH = 400;
    for (var i = 0; i < tabs.length; i++) {
        tabs[i].style.maxHeight = availH + 'px';
        tabs[i].style.overflowY = 'auto';
    }
}

/* === Lightbox === */
function openLightbox(src, name, code) {
    document.getElementById('lbPhoto').src = src;
    document.getElementById('lbName').textContent = name;
    document.getElementById('lbCode').textContent = code;
    document.getElementById('hrLightbox').style.display = 'flex';
}
function closeLightbox() {
    document.getElementById('hrLightbox').style.display = 'none';
}
document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeLightbox(); });

/* === Add Employee Modal === */
function openAddEmployeeModal() {
    document.getElementById('addEmployeeModal').style.display = 'flex';
    document.getElementById('addEmpResult').innerHTML = '';
}
function closeAddEmployeeModal() {
    document.getElementById('addEmployeeModal').style.display = 'none';
}

/* === Change Password Modal === */
function openPasswordModal(empID, empName, username) {
    closeAllActionPopovers();
    document.getElementById('<%= hdnPwdEmpID.ClientID %>').value = empID;
    document.getElementById('pwdEmpInfo').innerHTML = '<strong>' + empName + '</strong><br/><span style="font-size:11px;color:#888;">Username: ' + username + '</span>';
    document.getElementById('<%= txtNewPassword.ClientID %>').value = '';
    document.getElementById('<%= txtConfirmPassword.ClientID %>').value = '';
    document.getElementById('pwdResult').innerHTML = '';
    document.getElementById('changePwdModal').style.display = 'flex';
}
function closePwdModal() {
    document.getElementById('changePwdModal').style.display = 'none';
}
function submitPasswordChange() {
    var pw = document.getElementById('<%= txtNewPassword.ClientID %>').value;
    var cpw = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
    var res = document.getElementById('pwdResult');
    if (!pw || pw.length < 1) { res.innerHTML = '<span style="color:#d32f2f;">Please enter a password.</span>'; return; }
    if (pw !== cpw) { res.innerHTML = '<span style="color:#d32f2f;">Passwords do not match.</span>'; return; }
    res.innerHTML = '<span style="color:#174DA4;">Changing password...</span>';
    document.getElementById('<%= btnChangePassword.ClientID %>').click();
}

/* === Search on Enter === */
var searchBox = document.getElementById('<%= txtSearch.ClientID %>');
if (searchBox) {
    searchBox.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            document.getElementById('<%= btnSearch.ClientID %>').click();
        }
    });
}
</script>
</asp:Content>
