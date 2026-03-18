<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HRLeaveManagement.aspx.cs" Inherits="COOPERP_NewScreens_HRLeaveManagement" Title="Leave Management - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ========== LEAVE MANAGEMENT STYLES ========== */

/* --- Card System --- */
.cd-card { background:#fff; border:1px solid #e0e0e0; border-radius:0; margin-bottom:12px; }
.cd-card__header { display:flex; align-items:center; justify-content:space-between; padding:10px 14px; border-bottom:1px solid #e0e0e0; }
.cd-card__title { font-size:14px; font-weight:700; color:#1a1a1a; display:flex; align-items:center; gap:8px; }
.cd-card__body { padding:14px; }

/* --- Stats row --- */
.lv-stats { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
.lv-stat-card { flex:1; min-width:140px; background:#fff; border:1px solid #e0e0e0; padding:12px 16px; }
.lv-stat-card__val { font-size:22px; font-weight:700; color:#174DA4; }
.lv-stat-card__label { font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#888; margin-top:2px; }

/* --- Filter bar --- */
.lv-filters { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:10px 14px; border-bottom:1px solid #e0e0e0; background:#fafbfc; }
.lv-search-box { flex:1; min-width:180px; max-width:300px; padding:6px 10px; border:1px solid #ccc; border-radius:4px; font-size:12px; outline:none; }
.lv-search-box:focus { border-color:#174DA4; box-shadow:0 0 0 2px rgba(23,77,164,.12); }
.lv-filter-select { padding:5px 8px; border:1px solid #ccc; border-radius:0; font-size:11px; background:#fff; min-width:100px; }

/* --- Buttons --- */
.hr-btn { padding:6px 14px; font-size:11px; font-weight:600; border:none; cursor:pointer; border-radius:0; display:inline-flex; align-items:center; gap:4px; }
.hr-btn--primary { background:#174DA4; color:#fff; }
.hr-btn--primary:hover { background:#1256b8; }
.hr-btn--secondary { background:#6c757d; color:#fff; }
.hr-btn--success { background:#28a745; color:#fff; }
.hr-btn--danger { background:#dc3545; color:#fff; }
.hr-btn--outline { background:#fff; color:#174DA4; border:1px solid #174DA4; }
.hr-btn--outline:hover { background:#174DA4; color:#fff; }
.hr-btn--sm { padding:4px 10px; font-size:10px; }

/* --- Badge --- */
.hr-badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; border-radius:0; text-transform:uppercase; letter-spacing:.3px; }
.hr-badge--success { background:#d4edda; color:#155724; }
.hr-badge--warning { background:#fff3cd; color:#856404; }
.hr-badge--danger { background:#f8d7da; color:#721c24; }

/* --- Modal --- */
.hr-modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.5); z-index:10000; align-items:center; justify-content:center; }
.hr-modal { background:#fff; width:520px; max-width:95vw; max-height:85vh; overflow-y:auto; border-radius:0; box-shadow:0 8px 32px rgba(0,0,0,.2); }
.hr-modal__header { background:#174DA4; color:#fff; padding:10px 16px; font-size:13px; font-weight:700; display:flex; align-items:center; justify-content:space-between; }
.hr-modal__close { background:none; border:none; color:#fff; font-size:18px; cursor:pointer; padding:0 4px; }
.hr-modal__body { padding:16px; }
.hr-modal__footer { padding:10px 16px; border-top:1px solid #e0e0e0; display:flex; justify-content:flex-end; gap:8px; }

/* --- Form --- */
.hr-form-group { margin-bottom:10px; }
.hr-form-label { display:block; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#666; font-weight:600; margin-bottom:3px; }
.hr-form-input, .hr-form-select, .hr-form-textarea { width:100%; padding:6px 8px; border:1px solid #ccc; border-radius:0; font-size:12px; box-sizing:border-box; }
.hr-form-input:focus, .hr-form-select:focus { border-color:#174DA4; outline:none; }
.hr-form-row { display:grid; grid-template-columns:1fr 1fr; gap:10px; }

/* --- Remaining days bar --- */
.lv-days-bar { height:6px; background:#e0e0e0; border-radius:3px; overflow:hidden; margin-top:4px; }
.lv-days-bar__fill { height:100%; border-radius:3px; transition:width .3s; }

/* --- Grid overrides --- */
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass { font-size:10px !important; text-transform:uppercase !important; letter-spacing:.3px !important; }
.dxgvDataRow_Glass td, .dxgvGroupRow_Glass td { font-size:11px !important; padding:4px 8px !important; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Stats -->
<div class="lv-stats">
    <div class="lv-stat-card">
        <div class="lv-stat-card__val"><asp:Literal ID="litTotalStaff" runat="server" Text="0" /></div>
        <div class="lv-stat-card__label">Staff with Leave Allocation</div>
    </div>
    <div class="lv-stat-card">
        <div class="lv-stat-card__val"><asp:Literal ID="litOnLeave" runat="server" Text="0" /></div>
        <div class="lv-stat-card__label">Currently on Leave</div>
    </div>
    <div class="lv-stat-card">
        <div class="lv-stat-card__val"><asp:Literal ID="litTotalDaysTaken" runat="server" Text="0" /></div>
        <div class="lv-stat-card__label">Days Taken This Year</div>
    </div>
    <div class="lv-stat-card">
        <div class="lv-stat-card__val"><asp:Literal ID="litExhausted" runat="server" Text="0" /></div>
        <div class="lv-stat-card__label">Leave Exhausted</div>
    </div>
</div>

<!-- Leave Allocation Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
            Leave Overview — <asp:Literal ID="litCurrentYear" runat="server" />
        </div>
        <div style="display:flex;gap:6px;">
            <button type="button" class="hr-btn hr-btn--primary hr-btn--sm" onclick="openAllocateModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Allocate Leave
            </button>
            <button type="button" class="hr-btn hr-btn--success hr-btn--sm" onclick="openRecordLeaveModal()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                Record Leave Taken
            </button>
        </div>
    </div>
    
    <div class="lv-filters">
        <asp:TextBox ID="txtLeaveSearch" runat="server" CssClass="lv-search-box" placeholder="Search staff name or code..." />
        <asp:DropDownList ID="ddlLeaveYear" runat="server" CssClass="lv-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlLeaveYear_Changed">
        </asp:DropDownList>
        <asp:DropDownList ID="ddlLeaveDept" runat="server" CssClass="lv-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlLeaveYear_Changed">
            <asp:ListItem Text="All Departments" Value="" />
        </asp:DropDownList>
        <asp:Button ID="btnLeaveSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnLeaveSearch_Click" />
        <asp:Button ID="btnLeaveReset" runat="server" Text="Reset" CssClass="hr-btn hr-btn--outline hr-btn--sm" OnClick="btnLeaveReset_Click" />
    </div>

    <div style="padding:0;">
        <dx:ASPxGridView ID="gvLeave" runat="server" Width="100%" ClientInstanceName="gvLeave"
            KeyFieldName="leaveAllocID" EnableCallBacks="false" Theme="Glass"
            OnRowUpdating="gvLeave_RowUpdating" OnRowDeleting="gvLeave_RowDeleting">
            <SettingsPager PageSize="25" />
            <Settings ShowFilterRow="True" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
            <SettingsEditing Mode="PopupEditForm" />
            <SettingsPopup>
                <EditForm Width="400" Height="200" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
            </SettingsPopup>
            <Columns>
                <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" Width="55" ButtonRenderMode="Image" />
                
                <dx:GridViewDataTextColumn FieldName="leaveAllocID" Caption="ID" Width="40" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Code" Width="90" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;color:#174DA4;"><%# Eval("EMP_CODE") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="200" EditFormSettings-Visible="False" />
                <dx:GridViewDataTextColumn FieldName="dept_name" Caption="Department" Width="140" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataTextColumn FieldName="leave_year" Caption="Year" Width="70" EditFormSettings-Visible="False" />
                
                <dx:GridViewDataSpinEditColumn FieldName="default_days" Caption="Allocated Days" Width="100">
                    <PropertiesSpinEdit MinValue="0" MaxValue="365" NumberType="Integer" />
                </dx:GridViewDataSpinEditColumn>
                
                <dx:GridViewDataTextColumn FieldName="taken_days" Caption="Taken" Width="70" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;color:#dc3545;"><%# Eval("taken_days") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn FieldName="remaining" Caption="Remaining" Width="90" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <%# GetRemainingHtml(Eval("default_days"), Eval("taken_days")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                
                <dx:GridViewDataTextColumn Caption="Status" Width="80" EditFormSettings-Visible="False" Settings-AllowAutoFilter="False" Settings-AllowSort="False">
                    <DataItemTemplate>
                        <%# GetLeaveStatusBadge(Eval("default_days"), Eval("taken_days")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
            </Columns>
        </dx:ASPxGridView>
    </div>
</div>

<!-- Leave History Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="12 8 12 12 14 14"></polyline><circle cx="12" cy="12" r="10"></circle></svg>
            Recent Leave Records
        </div>
    </div>
    <div style="padding:0;">
        <dx:ASPxGridView ID="gvLeaveHistory" runat="server" Width="100%" ClientInstanceName="gvLeaveHistory"
            KeyFieldName="leaveRecID" EnableCallBacks="false" Theme="Glass"
            OnRowDeleting="gvLeaveHistory_RowDeleting">
            <SettingsPager PageSize="20" />
            <Settings ShowFilterRow="True" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior ConfirmDelete="True" />
            <Columns>
                <dx:GridViewCommandColumn ShowDeleteButton="True" Width="40" ButtonRenderMode="Image" />
                <dx:GridViewDataTextColumn FieldName="leaveRecID" Visible="false" />
                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Code" Width="90" />
                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="180" />
                <dx:GridViewDataTextColumn FieldName="dept_name" Caption="Department" Width="130" />
                <dx:GridViewDataDateColumn FieldName="startDate" Caption="Start" Width="100">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataDateColumn FieldName="endDate" Caption="End" Width="100">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="no_days" Caption="Days" Width="55">
                    <DataItemTemplate>
                        <span style="font-weight:700;color:#174DA4;"><%# Eval("no_days") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="leave_year" Caption="Year" Width="60" />
            </Columns>
        </dx:ASPxGridView>
    </div>
</div>

<!-- ========== ALLOCATE LEAVE MODAL ========== -->
<div class="hr-modal-overlay" id="allocateModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span>Allocate Leave Days</span>
            <button type="button" class="hr-modal__close" onclick="closeAllocateModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Employee *</label>
                    <asp:DropDownList ID="ddlAllocEmployee" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Leave Year *</label>
                    <asp:TextBox ID="txtAllocYear" runat="server" CssClass="hr-form-input" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Default Days *</label>
                <asp:TextBox ID="txtAllocDays" runat="server" CssClass="hr-form-input" TextMode="Number" Text="30" />
            </div>
            <div id="allocResult" style="margin-top:8px;font-size:12px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--secondary hr-btn--sm" onclick="closeAllocateModal()">Cancel</button>
            <asp:Button ID="btnAllocateLeave" runat="server" Text="Allocate" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnAllocateLeave_Click" />
        </div>
    </div>
</div>

<!-- ========== RECORD LEAVE MODAL ========== -->
<div class="hr-modal-overlay" id="recordLeaveModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span>Record Leave Taken</span>
            <button type="button" class="hr-modal__close" onclick="closeRecordLeaveModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div class="hr-form-group">
                <label class="hr-form-label">Employee *</label>
                <asp:DropDownList ID="ddlRecordEmployee" runat="server" CssClass="hr-form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRecordEmployee_Changed" />
            </div>
            <div id="empLeaveInfo" style="background:#e8f0fe;border-left:3px solid #174DA4;padding:8px 12px;margin-bottom:10px;font-size:11px;display:none;">
                <asp:Literal ID="litEmpLeaveInfo" runat="server" />
            </div>
            <asp:HiddenField ID="hdnLeaveAllocID" runat="server" />
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Date *</label>
                    <asp:TextBox ID="txtLeaveStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">End Date *</label>
                    <asp:TextBox ID="txtLeaveEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Number of Days *</label>
                <asp:TextBox ID="txtLeaveDays" runat="server" CssClass="hr-form-input" TextMode="Number" />
            </div>
            <div id="recordResult" style="margin-top:8px;font-size:12px;"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--secondary hr-btn--sm" onclick="closeRecordLeaveModal()">Cancel</button>
            <asp:Button ID="btnRecordLeave" runat="server" Text="Record Leave" CssClass="hr-btn hr-btn--success hr-btn--sm" OnClick="btnRecordLeave_Click" />
        </div>
    </div>
</div>

<script type="text/javascript">
function openAllocateModal() {
    document.getElementById('allocateModal').style.display = 'flex';
    document.getElementById('allocResult').innerHTML = '';
}
function closeAllocateModal() { document.getElementById('allocateModal').style.display = 'none'; }

function openRecordLeaveModal() {
    document.getElementById('recordLeaveModal').style.display = 'flex';
    document.getElementById('recordResult').innerHTML = '';
}
function closeRecordLeaveModal() { document.getElementById('recordLeaveModal').style.display = 'none'; }

var searchBox = document.getElementById('<%= txtLeaveSearch.ClientID %>');
if (searchBox) {
    searchBox.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            document.getElementById('<%= btnLeaveSearch.ClientID %>').click();
        }
    });
}
</script>
</asp:Content>
