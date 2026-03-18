<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HRPayroll.aspx.cs" Inherits="COOPERP_NewScreens_HRPayroll" Title="Payroll Management - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ========== PAYROLL STYLES ========== */
.cd-card { background:#fff; border:1px solid #e0e0e0; border-radius:0; margin-bottom:12px; }
.cd-card__header { display:flex; align-items:center; justify-content:space-between; padding:10px 14px; border-bottom:1px solid #e0e0e0; }
.cd-card__title { font-size:14px; font-weight:700; color:#1a1a1a; display:flex; align-items:center; gap:8px; }
.cd-card__body { padding:14px; }

/* Stats */
.pr-stats { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
.pr-stat { flex:1; min-width:150px; background:#fff; border:1px solid #e0e0e0; padding:12px 16px; }
.pr-stat__val { font-size:20px; font-weight:700; color:#174DA4; }
.pr-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#888; margin-top:2px; }
.pr-stat--accent .pr-stat__val { color:#28a745; }
.pr-stat--danger .pr-stat__val { color:#dc3545; }

/* Filter */
.pr-filters { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:10px 14px; border-bottom:1px solid #e0e0e0; background:#fafbfc; }
.pr-filter-select { padding:5px 8px; border:1px solid #ccc; border-radius:0; font-size:11px; background:#fff; min-width:100px; }

/* Buttons */
.hr-btn { padding:6px 14px; font-size:11px; font-weight:600; border:none; cursor:pointer; border-radius:0; display:inline-flex; align-items:center; gap:4px; }
.hr-btn--primary { background:#174DA4; color:#fff; }
.hr-btn--primary:hover { background:#1256b8; }
.hr-btn--secondary { background:#6c757d; color:#fff; }
.hr-btn--success { background:#28a745; color:#fff; }
.hr-btn--success:hover { background:#218838; }
.hr-btn--danger { background:#dc3545; color:#fff; }
.hr-btn--outline { background:#fff; color:#174DA4; border:1px solid #174DA4; }
.hr-btn--outline:hover { background:#174DA4; color:#fff; }
.hr-btn--sm { padding:4px 10px; font-size:10px; }

/* Badge */
.hr-badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; border-radius:0; text-transform:uppercase; letter-spacing:.3px; }
.hr-badge--locked { background:#d4edda; color:#155724; }
.hr-badge--open { background:#fff3cd; color:#856404; }

/* Modal */
.hr-modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.5); z-index:10000; align-items:center; justify-content:center; }
.hr-modal { background:#fff; width:520px; max-width:95vw; max-height:85vh; overflow-y:auto; border-radius:0; box-shadow:0 8px 32px rgba(0,0,0,.2); }
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

/* Summary panel */
.pr-summary { background:#f8f9fb; border:1px solid #e0e0e0; padding:12px; margin-bottom:12px; }
.pr-summary-row { display:flex; justify-content:space-between; padding:4px 0; font-size:12px; border-bottom:1px solid #f0f0f0; }
.pr-summary-row:last-child { border-bottom:none; }
.pr-summary-row strong { color:#174DA4; }

/* Grid overrides */
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass { font-size:10px !important; text-transform:uppercase !important; letter-spacing:.3px !important; }
.dxgvDataRow_Glass td { font-size:11px !important; padding:4px 8px !important; }
.dxgvFooter_Glass td { font-size:11px !important; font-weight:700 !important; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Stats -->
<div class="pr-stats">
    <div class="pr-stat">
        <div class="pr-stat__val"><asp:Literal ID="litTotalPayrolls" runat="server" Text="0" /></div>
        <div class="pr-stat__label">Total Payrolls</div>
    </div>
    <div class="pr-stat pr-stat--accent">
        <div class="pr-stat__val"><asp:Literal ID="litTotalGross" runat="server" Text="0" /></div>
        <div class="pr-stat__label">Total Gross (Current)</div>
    </div>
    <div class="pr-stat pr-stat--danger">
        <div class="pr-stat__val"><asp:Literal ID="litTotalDeductions" runat="server" Text="0" /></div>
        <div class="pr-stat__label">Total Deductions (Current)</div>
    </div>
    <div class="pr-stat">
        <div class="pr-stat__val"><asp:Literal ID="litTotalNet" runat="server" Text="0" /></div>
        <div class="pr-stat__label">Total Net Pay (Current)</div>
    </div>
</div>

<!-- Payroll Periods Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
            Payroll Periods
        </div>
        <div style="display:flex;gap:6px;">
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="openCreatePayrollModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Create Payroll
            </button>
        </div>
    </div>
    
    <div class="pr-filters">
        <asp:DropDownList ID="ddlPayrollYear" runat="server" CssClass="pr-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPayrollYear_Changed" />
        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="hr-btn hr-btn--outline hr-btn--sm" OnClick="btnRefresh_Click" />
    </div>

    <div style="padding:0;">
        <dx:ASPxGridView ID="gvPayrolls" runat="server" Width="100%" ClientInstanceName="gvPayrolls"
            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
            OnRowDeleting="gvPayrolls_RowDeleting"
            OnCustomButtonCallback="gvPayrolls_CustomButton">
            <SettingsPager PageSize="12" />
            <Settings ShowFilterRow="False" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
            <Columns>
                <dx:GridViewCommandColumn ShowDeleteButton="True" Width="40" ButtonRenderMode="Image" />
                
                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="45" />
                
                <dx:GridViewDataTextColumn FieldName="payroll_title" Caption="Title" Width="200">
                    <DataItemTemplate>
                        <strong style="color:#174DA4;"><%# Eval("payroll_title") %></strong>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="payroll_month" Caption="Month" Width="60" />
                <dx:GridViewDataTextColumn FieldName="payroll_year" Caption="Year" Width="60" />
                
                <dx:GridViewDataDateColumn FieldName="payroll_date" Caption="Date" Width="100">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                
                <dx:GridViewDataTextColumn FieldName="staff_count" Caption="Staff" Width="55">
                    <DataItemTemplate>
                        <span style="font-weight:600;"><%# Eval("staff_count") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="total_amount" Caption="Total Amount" Width="120">
                    <DataItemTemplate>
                        <strong><%# FormatCurrency(Eval("total_amount")) %></strong>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="lockStatus" Caption="Status" Width="80">
                    <DataItemTemplate>
                        <%# GetLockBadge(Eval("lockStatus")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="prepared_by" Caption="Prepared By" Width="100" />
                
                <dx:GridViewDataTextColumn Caption="Actions" Width="160" Settings-AllowAutoFilter="False" Settings-AllowSort="False">
                    <DataItemTemplate>
                        <%# GetPayrollActionHtml(Eval("ID")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
            </Columns>
        </dx:ASPxGridView>
    </div>
</div>

<!-- Payroll Details Card -->
<asp:Panel ID="pnlPayrollDetails" runat="server" Visible="false">
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
            Payroll Details — <asp:Literal ID="litPayrollTitle" runat="server" />
        </div>
        <div>
            <asp:Button ID="btnCloseDetails" runat="server" Text="Close" CssClass="hr-btn hr-btn--secondary hr-btn--sm" OnClick="btnCloseDetails_Click" />
        </div>
    </div>
    
    <!-- Summary -->
    <div class="cd-card__body">
        <div class="pr-summary">
            <div class="pr-summary-row"><span>Total Staff</span><strong><asp:Literal ID="litDetStaff" runat="server" /></strong></div>
            <div class="pr-summary-row"><span>Total Basic Pay</span><strong><asp:Literal ID="litDetBasic" runat="server" /></strong></div>
            <div class="pr-summary-row"><span>Total Allowances</span><strong style="color:#28a745;"><asp:Literal ID="litDetAllow" runat="server" /></strong></div>
            <div class="pr-summary-row"><span>Total Gross Pay</span><strong><asp:Literal ID="litDetGross" runat="server" /></strong></div>
            <div class="pr-summary-row"><span>Total PAYE</span><strong style="color:#dc3545;"><asp:Literal ID="litDetPAYE" runat="server" /></strong></div>
            <div class="pr-summary-row"><span>Total NSSF</span><strong style="color:#dc3545;"><asp:Literal ID="litDetNSSF" runat="server" /></strong></div>
            <div class="pr-summary-row"><span>Total Other Deductions</span><strong style="color:#dc3545;"><asp:Literal ID="litDetOther" runat="server" /></strong></div>
            <div class="pr-summary-row" style="border-top:2px solid #174DA4;padding-top:6px;"><span style="font-weight:700;">Total Net Pay</span><strong style="font-size:14px;"><asp:Literal ID="litDetNet" runat="server" /></strong></div>
        </div>
    </div>

    <div style="padding:0;">
        <dx:ASPxGridView ID="gvPayrollDetails" runat="server" Width="100%" ClientInstanceName="gvPayrollDetails"
            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
            OnRowUpdating="gvPayrollDetails_RowUpdating">
            <SettingsPager PageSize="50" />
            <Settings ShowFilterRow="True" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior AllowFocusedRow="True" />
            <SettingsEditing Mode="PopupEditForm" />
            <SettingsPopup>
                <EditForm Width="500" Height="380" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
            </SettingsPopup>
            <TotalSummary>
                <dx:ASPxSummaryItem FieldName="basic_pay" SummaryType="Sum" DisplayFormat="{0:N0}" />
                <dx:ASPxSummaryItem FieldName="total_allowances" SummaryType="Sum" DisplayFormat="{0:N0}" />
                <dx:ASPxSummaryItem FieldName="gross_pay" SummaryType="Sum" DisplayFormat="{0:N0}" />
                <dx:ASPxSummaryItem FieldName="paye" SummaryType="Sum" DisplayFormat="{0:N0}" />
                <dx:ASPxSummaryItem FieldName="nssf" SummaryType="Sum" DisplayFormat="{0:N0}" />
                <dx:ASPxSummaryItem FieldName="total_deductions" SummaryType="Sum" DisplayFormat="{0:N0}" />
                <dx:ASPxSummaryItem FieldName="net_pay" SummaryType="Sum" DisplayFormat="{0:N0}" />
            </TotalSummary>
            <Columns>
                <dx:GridViewCommandColumn ShowEditButton="True" Width="40" ButtonRenderMode="Image" />
                
                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="40" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Code" Width="90" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;color:#174DA4;"><%# Eval("EMP_CODE") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="180" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataSpinEditColumn FieldName="basic_pay" Caption="Basic Pay" Width="100">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                    <FooterCellStyle Font-Bold="True" />
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="total_allowances" Caption="Allowances" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="gross_pay" Caption="Gross Pay" Width="100">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                    <DataItemTemplate>
                        <strong><%# FormatCurrency(Eval("gross_pay")) %></strong>
                    </DataItemTemplate>
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="paye" Caption="PAYE" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                    <DataItemTemplate>
                        <span style="color:#dc3545;"><%# FormatCurrency(Eval("paye")) %></span>
                    </DataItemTemplate>
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="nssf" Caption="NSSF" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                    <DataItemTemplate>
                        <span style="color:#dc3545;"><%# FormatCurrency(Eval("nssf")) %></span>
                    </DataItemTemplate>
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="total_deductions" Caption="Deductions" Width="90">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataSpinEditColumn FieldName="net_pay" Caption="Net Pay" Width="110">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                    <DataItemTemplate>
                        <strong style="color:#174DA4;"><%# FormatCurrency(Eval("net_pay")) %></strong>
                    </DataItemTemplate>
                </dx:GridViewDataSpinEditColumn>
            </Columns>
        </dx:ASPxGridView>
    </div>
</div>
</asp:Panel>

<asp:HiddenField ID="hdnSelectedPayrollID" runat="server" />
<asp:HiddenField ID="hdnGeneratePayrollID" runat="server" />
<dx:ASPxButton ID="btnViewPayroll" runat="server" ClientVisible="false" ClientInstanceName="btnViewPayroll" OnClick="btnViewPayroll_Click" />
<dx:ASPxButton ID="btnGenPayroll" runat="server" ClientVisible="false" ClientInstanceName="btnGenPayroll" OnClick="btnGenPayroll_Click" />

<!-- Create Payroll Modal -->
<div class="hr-modal-overlay" id="createPayrollModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span>Create New Payroll Period</span>
            <button type="button" class="hr-modal__close" onclick="closeCreatePayrollModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="hr-form-group">
                <label class="hr-form-label">Payroll Title *</label>
                <asp:TextBox ID="txtPayrollTitle" runat="server" CssClass="hr-form-input" />
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Month *</label>
                    <asp:DropDownList ID="ddlPayrollMonth" runat="server" CssClass="hr-form-select">
                        <asp:ListItem Text="January" Value="1" />
                        <asp:ListItem Text="February" Value="2" />
                        <asp:ListItem Text="March" Value="3" />
                        <asp:ListItem Text="April" Value="4" />
                        <asp:ListItem Text="May" Value="5" />
                        <asp:ListItem Text="June" Value="6" />
                        <asp:ListItem Text="July" Value="7" />
                        <asp:ListItem Text="August" Value="8" />
                        <asp:ListItem Text="September" Value="9" />
                        <asp:ListItem Text="October" Value="10" />
                        <asp:ListItem Text="November" Value="11" />
                        <asp:ListItem Text="December" Value="12" />
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Year *</label>
                    <asp:TextBox ID="txtPayrollYear" runat="server" CssClass="hr-form-input" TextMode="Number" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Comments</label>
                <asp:TextBox ID="txtPayrollComments" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" />
            </div>
            <div id="createResult" style="margin-top:8px;font-size:12px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--secondary hr-btn--sm" onclick="closeCreatePayrollModal()">Cancel</button>
            <asp:Button ID="btnCreatePayroll" runat="server" Text="Create Payroll" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnCreatePayroll_Click" />
        </div>
    </div>
</div>

<script type="text/javascript">
function openCreatePayrollModal() {
    document.getElementById('createPayrollModal').style.display = 'flex';
    document.getElementById('createResult').innerHTML = '';
}
function closeCreatePayrollModal() { document.getElementById('createPayrollModal').style.display = 'none'; }

function viewPayrollDetails(id) {
    document.getElementById('<%= hdnSelectedPayrollID.ClientID %>').value = id;
    btnViewPayroll.DoClick();
}
function generatePayroll(id) {
    if (!confirm('Generate payroll details for all staff with active contracts? This will populate pay data based on their pay scales and allowances/deductions.')) return;
    document.getElementById('<%= hdnGeneratePayrollID.ClientID %>').value = id;
    btnGenPayroll.DoClick();
}
</script>
</asp:Content>
