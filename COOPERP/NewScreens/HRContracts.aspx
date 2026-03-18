<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HRContracts.aspx.cs" Inherits="COOPERP_NewScreens_HRContracts" Title="Contract Management - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ========== CONTRACT MANAGEMENT STYLES ========== */
.cd-card { background:#fff; border:1px solid #e0e0e0; border-radius:0; margin-bottom:12px; }
.cd-card__header { display:flex; align-items:center; justify-content:space-between; padding:10px 14px; border-bottom:1px solid #e0e0e0; }
.cd-card__title { font-size:14px; font-weight:700; color:#1a1a1a; display:flex; align-items:center; gap:8px; }
.cd-card__body { padding:14px; }

/* Stats */
.ct-stats { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
.ct-stat { flex:1; min-width:130px; background:#fff; border:1px solid #e0e0e0; padding:12px 16px; }
.ct-stat__val { font-size:22px; font-weight:700; color:#174DA4; }
.ct-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#888; margin-top:2px; }
.ct-stat--green .ct-stat__val { color:#28a745; }
.ct-stat--red .ct-stat__val { color:#dc3545; }
.ct-stat--yellow .ct-stat__val { color:#ffc107; }

/* Filters */
.ct-filters { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:10px 14px; border-bottom:1px solid #e0e0e0; background:#fafbfc; }
.ct-search-box { flex:1; min-width:180px; max-width:300px; padding:6px 10px; border:1px solid #ccc; border-radius:4px; font-size:12px; outline:none; }
.ct-search-box:focus { border-color:#174DA4; }
.ct-filter-select { padding:5px 8px; border:1px solid #ccc; border-radius:0; font-size:11px; background:#fff; min-width:120px; }

/* Buttons */
.hr-btn { padding:6px 14px; font-size:11px; font-weight:600; border:none; cursor:pointer; border-radius:0; display:inline-flex; align-items:center; gap:4px; }
.hr-btn--primary { background:#174DA4; color:#fff; }
.hr-btn--primary:hover { background:#1256b8; }
.hr-btn--secondary { background:#6c757d; color:#fff; }
.hr-btn--success { background:#28a745; color:#fff; }
.hr-btn--danger { background:#dc3545; color:#fff; }
.hr-btn--outline { background:#fff; color:#174DA4; border:1px solid #174DA4; }
.hr-btn--outline:hover { background:#174DA4; color:#fff; }
.hr-btn--sm { padding:4px 10px; font-size:10px; }

/* Badges */
.hr-badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; border-radius:0; text-transform:uppercase; letter-spacing:.3px; }
.hr-badge--valid { background:#d4edda; color:#155724; }
.hr-badge--expired { background:#f8d7da; color:#721c24; }
.hr-badge--terminated { background:#f5c6cb; color:#721c24; }
.hr-badge--resigned { background:#fff3cd; color:#856404; }
.hr-badge--none { background:#e2e3e5; color:#383d41; }

/* Modal */
.hr-modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.5); z-index:10000; align-items:center; justify-content:center; }
.hr-modal { background:#fff; width:560px; max-width:95vw; max-height:85vh; overflow-y:auto; border-radius:0; box-shadow:0 8px 32px rgba(0,0,0,.2); }
.hr-modal__header { background:#174DA4; color:#fff; padding:10px 16px; font-size:13px; font-weight:700; display:flex; align-items:center; justify-content:space-between; }
.hr-modal__close { background:none; border:none; color:#fff; font-size:18px; cursor:pointer; }
.hr-modal__body { padding:16px; }
.hr-modal__footer { padding:10px 16px; border-top:1px solid #e0e0e0; display:flex; justify-content:flex-end; gap:8px; }

/* Form */
.hr-form-group { margin-bottom:10px; }
.hr-form-label { display:block; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#666; font-weight:600; margin-bottom:3px; }
.hr-form-input, .hr-form-select, .hr-form-textarea { width:100%; padding:6px 8px; border:1px solid #ccc; border-radius:0; font-size:12px; box-sizing:border-box; }
.hr-form-input:focus, .hr-form-select:focus { border-color:#174DA4; outline:none; }
.hr-form-row { display:grid; grid-template-columns:1fr 1fr; gap:10px; }

/* Expiry warning */
.ct-expiry-warn { background:#fff3cd; border-left:3px solid #ffc107; padding:8px 12px; font-size:11px; color:#856404; margin-bottom:10px; }
.ct-expiry-warn strong { color:#dc3545; }

/* Grid overrides */
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass { font-size:10px !important; text-transform:uppercase !important; letter-spacing:.3px !important; }
.dxgvDataRow_Glass td { font-size:11px !important; padding:4px 8px !important; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Stats -->
<div class="ct-stats">
    <div class="ct-stat ct-stat--green">
        <div class="ct-stat__val"><asp:Literal ID="litValid" runat="server" Text="0" /></div>
        <div class="ct-stat__label">Valid Contracts</div>
    </div>
    <div class="ct-stat ct-stat--red">
        <div class="ct-stat__val"><asp:Literal ID="litExpired" runat="server" Text="0" /></div>
        <div class="ct-stat__label">Expired</div>
    </div>
    <div class="ct-stat ct-stat--yellow">
        <div class="ct-stat__val"><asp:Literal ID="litExpiring" runat="server" Text="0" /></div>
        <div class="ct-stat__label">Expiring Soon (90 days)</div>
    </div>
    <div class="ct-stat">
        <div class="ct-stat__val"><asp:Literal ID="litNoContract" runat="server" Text="0" /></div>
        <div class="ct-stat__label">No Contract</div>
    </div>
</div>

<!-- Expiring Soon Warning -->
<asp:Panel ID="pnlExpiryWarning" runat="server" Visible="false">
    <div class="ct-expiry-warn">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
        <strong><asp:Literal ID="litExpiryCount" runat="server" /> contracts</strong> are expiring within the next 90 days. Review and renew as needed.
    </div>
</asp:Panel>

<!-- Contracts Grid -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            Employment Contracts
        </div>
        <div style="display:flex;gap:6px;">
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="openAddContractModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                New Contract
            </button>
        </div>
    </div>
    
    <div class="ct-filters">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-search-box" placeholder="Search employee name or code..." />
        <asp:DropDownList ID="ddlFilterDept" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Departments" Value="" />
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Statuses" Value="" />
            <asp:ListItem Text="VALID" Value="VALID" />
            <asp:ListItem Text="EXPIRED" Value="EXPIRED" />
            <asp:ListItem Text="TERMINATED" Value="TERMINATED" />
            <asp:ListItem Text="RESIGNED" Value="RESIGNED" />
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFilterJob" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Positions" Value="" />
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnSearch_Click" />
        <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="hr-btn hr-btn--outline hr-btn--sm" OnClick="btnReset_Click" />
    </div>

    <div style="padding:0;">
        <dx:ASPxGridView ID="gvContracts" runat="server" Width="100%" ClientInstanceName="gvContracts"
            KeyFieldName="contractID" EnableCallBacks="false" Theme="Glass"
            OnRowUpdating="gvContracts_RowUpdating" OnRowDeleting="gvContracts_RowDeleting">
            <SettingsPager PageSize="25" />
            <Settings ShowFilterRow="True" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
            <SettingsEditing Mode="PopupEditForm" />
            <SettingsPopup>
                <EditForm Width="550" Height="400" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
            </SettingsPopup>
            <EditFormLayoutProperties ColCount="2">
                <Items>
                    <dx:GridViewColumnLayoutItem ColumnName="contractStart" ColSpan="1" />
                    <dx:GridViewColumnLayoutItem ColumnName="contractEnd" ColSpan="1" />
                    <dx:GridViewColumnLayoutItem ColumnName="contractStatus" ColSpan="1" />
                    <dx:GridViewColumnLayoutItem ColumnName="payscale_edit" ColSpan="1" />
                    <dx:GridViewColumnLayoutItem ColumnName="fixedamount" ColSpan="1" />
                    <dx:GridViewColumnLayoutItem ColumnName="comments" ColSpan="2" />
                    <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right" />
                </Items>
            </EditFormLayoutProperties>
            <Columns>
                <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" Width="55" ButtonRenderMode="Image" />
                
                <dx:GridViewDataTextColumn FieldName="contractID" Visible="false" />
                
                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff Code" Width="90" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;color:#174DA4;"><%# Eval("EMP_CODE") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="180" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataTextColumn FieldName="jobname" Caption="Position" Width="130" EditFormSettings-Visible="False" />
                <dx:GridViewDataTextColumn FieldName="dept_name" Caption="Department" Width="130" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataDateColumn FieldName="contractStart" Caption="Start" Width="100">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                
                <dx:GridViewDataDateColumn FieldName="contractEnd" Caption="End" Width="100">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                
                <dx:GridViewDataTextColumn FieldName="days_remaining" Caption="Days Left" Width="75" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <%# GetDaysRemainingHtml(Eval("contractEnd"), Eval("contractStatus")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataComboBoxColumn FieldName="contractStatus" Caption="Status" Width="90">
                    <PropertiesComboBox>
                        <Items>
                            <dx:ListEditItem Text="VALID" Value="VALID" />
                            <dx:ListEditItem Text="EXPIRED" Value="EXPIRED" />
                            <dx:ListEditItem Text="TERMINATED" Value="TERMINATED" />
                            <dx:ListEditItem Text="RESIGNED" Value="RESIGNED" />
                        </Items>
                    </PropertiesComboBox>
                    <DataItemTemplate>
                        <%# GetStatusBadge(Eval("contractStatus")) %>
                    </DataItemTemplate>
                </dx:GridViewDataComboBoxColumn>
                
                <dx:GridViewDataTextColumn FieldName="scale_name" Caption="Pay Scale" Width="90" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataComboBoxColumn FieldName="payscale_edit" Caption="Pay Scale" Width="100" Visible="false">
                    <PropertiesComboBox DataSourceID="dsPayscales" ValueField="ID" TextField="scale_name" />
                </dx:GridViewDataComboBoxColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="fixedamount" Caption="Fixed Amount" Width="100">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataTextColumn FieldName="basicpay" Caption="Basic Pay" Width="100" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <strong><%# FormatCurrency(Eval("basicpay")) %></strong>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataMemoColumn FieldName="comments" Caption="Comments" Width="120">
                    <PropertiesMemoEdit Rows="3" />
                </dx:GridViewDataMemoColumn>
            </Columns>
        </dx:ASPxGridView>
    </div>
</div>

<!-- Add Contract Modal -->
<div class="hr-modal-overlay" id="addContractModal">
    <div class="hr-modal" style="width:580px;">
        <div class="hr-modal__header">
            <span>Create New Contract</span>
            <button type="button" class="hr-modal__close" onclick="closeAddContractModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="hr-form-group">
                <label class="hr-form-label">Employee *</label>
                <asp:DropDownList ID="ddlContractEmployee" runat="server" CssClass="hr-form-select" />
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Date *</label>
                    <asp:TextBox ID="txtContractStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">End Date *</label>
                    <asp:TextBox ID="txtContractEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Position / Job *</label>
                    <asp:DropDownList ID="ddlContractJob" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Department *</label>
                    <asp:DropDownList ID="ddlContractDept" runat="server" CssClass="hr-form-select" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Pay Scale</label>
                    <asp:DropDownList ID="ddlContractScale" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Fixed Amount (if no scale)</label>
                    <asp:TextBox ID="txtContractFixed" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Comments</label>
                <asp:TextBox ID="txtContractComments" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" />
            </div>
            <div id="addContractResult" style="margin-top:8px;font-size:12px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--secondary hr-btn--sm" onclick="closeAddContractModal()">Cancel</button>
            <asp:Button ID="btnAddContract" runat="server" Text="Create Contract" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnAddContract_Click" />
        </div>
    </div>
</div>

<asp:SqlDataSource ID="dsPayscales" runat="server" ConnectionString="<%$ ConnectionStrings:vacConnectionString %>"
    ProviderName="MySql.Data.MySqlClient" SelectCommand="SELECT ID, CONCAT(scale_name, ' (', FORMAT(basicpay,0), ')') AS scale_name FROM hrm_payscales ORDER BY scale_name" />

<script type="text/javascript">
function openAddContractModal() {
    document.getElementById('addContractModal').style.display = 'flex';
    document.getElementById('addContractResult').innerHTML = '';
}
function closeAddContractModal() { document.getElementById('addContractModal').style.display = 'none'; }

var sb = document.getElementById('<%= txtSearch.ClientID %>');
if (sb) sb.addEventListener('keydown', function(e) { if (e.key==='Enter') { e.preventDefault(); document.getElementById('<%= btnSearch.ClientID %>').click(); } });
</script>
</asp:Content>
