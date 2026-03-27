<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="HRDeductions.aspx.cs"
    Inherits="COOPERP_NewScreens_HRDeductions"
    Title="Payroll Deduction Records - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* == Shared payroll-records styles (deductions + allowances) === */
.pr-page-header{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;padding:12px 18px;background:#fff;border-bottom:2px solid #174DA4;margin-bottom:14px;}
.pr-page-header__left{display:flex;align-items:center;gap:10px;}
.pr-page-icon{width:36px;height:36px;background:#eef2fb;border-radius:6px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.pr-page-title{font-size:15px;font-weight:700;color:#1a1a2e;}
.pr-page-sub{font-size:11px;color:#666;margin-top:1px;}
.pr-hdr-actions{display:flex;gap:8px;flex-wrap:wrap;}

/* Stats */
.ct-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px;}
.ct-stat{background:#fff;border:1px solid #e0e0e0;border-top:3px solid;padding:12px 14px;display:flex;align-items:center;gap:10px;}
.ct-stat--amber{border-top-color:#f59e0b;}.ct-stat--blue{border-top-color:#174DA4;}
.ct-stat--green{border-top-color:#28a745;}.ct-stat--grey{border-top-color:#6c757d;}
.ct-stat__icon{width:32px;height:32px;border-radius:4px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.ct-stat--amber .ct-stat__icon{background:#fff3cd;}.ct-stat--blue .ct-stat__icon{background:#e8f0fe;}
.ct-stat--green .ct-stat__icon{background:#d4edda;}.ct-stat--grey .ct-stat__icon{background:#e2e3e5;}
.ct-stat__val{font-size:20px;font-weight:700;color:#1a1a2e;line-height:1.1;}
.ct-stat__label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.3px;}

/* Filters */
.ct-filters{background:#fff;border:1px solid #e0e0e0;border-bottom:none;padding:10px 14px;}
.ct-filters__top{display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:8px;}
.ct-search-wrap{display:flex;align-items:center;gap:6px;flex:1 1 200px;min-width:140px;position:relative;}
.ct-search-icon{position:absolute;left:8px;pointer-events:none;}
.ct-search-box{height:30px;padding:0 8px 0 28px;border:1px solid #d0d5dd;font-size:11px;color:#333;width:100%;box-sizing:border-box;}
.ct-filters__count{font-size:11px;color:#888;white-space:nowrap;margin-left:auto;}
.ct-filters__row{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.ct-filter-grp{display:flex;align-items:center;gap:5px;}
.ct-filter-grp__label{font-size:10px;font-weight:600;color:#888;white-space:nowrap;}
.ct-filter-select{height:28px;padding:0 6px;border:1px solid #d0d5dd;font-size:11px;color:#333;}
.ct-filter-sep{width:1px;height:20px;background:#e0e0e0;flex-shrink:0;}

/* Batch toolbar */
.ct-batch-toolbar{display:none;align-items:center;gap:8px;flex-wrap:wrap;padding:8px 14px;background:#fffbe6;border-top:1px solid #ffe082;border-bottom:2px solid #ffc107;}
.ct-batch-info{display:flex;align-items:center;gap:5px;font-size:11px;color:#6d4c00;white-space:nowrap;}
.ct-batch-info strong{font-size:13px;font-weight:700;color:#b45309;}
.ct-batch-sep{width:1px;height:24px;background:#e0c060;margin:0 2px;flex-shrink:0;}
.ct-row-check{cursor:pointer;width:14px;height:14px;accent-color:#174DA4;vertical-align:middle;}

/* Buttons */
.hr-btn{display:inline-flex;align-items:center;gap:6px;padding:0 14px;height:32px;font-size:12px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;transition:background .15s;}
.hr-btn--primary{background:#174DA4;color:#fff;}.hr-btn--primary:hover{background:#0f3a7d;}
.hr-btn--success{background:#28a745;color:#fff;}.hr-btn--success:hover{background:#1e7e34;}
.hr-btn--danger{background:#dc3545;color:#fff;}.hr-btn--danger:hover{background:#bd2130;}
.hr-btn--amber{background:#f59e0b;color:#fff;}.hr-btn--amber:hover{background:#d97706;}
.hr-btn--ghost{background:#fff;color:#333;border:1px solid #d0d5dd;}.hr-btn--ghost:hover{background:#f5f5f5;}
.hr-btn--sm{height:28px;padding:0 10px;font-size:11px;}

/* Row coloring */
.pr-row-pending td{background:#fffff5 !important;}
.pr-row-settled td{background:#f6fff6 !important;}
.pr-row-cancelled td{background:#f7f7f7 !important;opacity:.75;}

/* Status badges */
.pr-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border-radius:0;text-transform:uppercase;letter-spacing:.3px;}
.pr-badge--pending{background:#fff3cd;color:#856404;}
.pr-badge--settled{background:#d4edda;color:#155724;}
.pr-badge--cancelled{background:#e2e3e5;color:#383d41;}

/* Type badge */
.pr-type{display:inline-block;padding:1px 7px;font-size:10px;font-weight:600;background:#fff0f0;color:#c0392b;border:1px solid #f5c6cb;}

/* Period */
.pr-period{font-size:11px;font-weight:700;color:#333;}
.pr-period__year{font-size:10px;color:#888;}

/* Payroll ref */
.pr-payref{font-size:10px;color:#174DA4;font-style:italic;}

/* Amount */
.pr-amount{font-size:12px;font-weight:700;color:#c0392b;}

/* Action popover */
.cd-action-wrapper{position:relative;display:inline-block;}
.cd-action-trigger{background:none;border:none;cursor:pointer;padding:4px 6px;color:#888;border-radius:3px;display:flex;align-items:center;}
.cd-action-trigger:hover{background:#f0f0f0;color:#333;}
.cd-action-popover{display:none;position:absolute;right:0;top:100%;background:#fff;border:1px solid #e0e0e0;box-shadow:0 4px 12px rgba(0,0,0,.12);z-index:999;min-width:160px;}
.cd-action-popover.is-open{display:block;}
.cd-action-popover__menu{list-style:none;margin:0;padding:4px 0;}
.cd-action-popover__item{margin:0;}
.cd-action-popover__btn{display:flex;align-items:center;gap:7px;padding:7px 14px;font-size:11px;font-weight:500;width:100%;background:none;border:none;cursor:pointer;color:#333;text-align:left;white-space:nowrap;}
.cd-action-popover__btn:hover{background:#f5f7fa;}
.cd-action-popover__btn--danger{color:#dc3545;}
.cd-action-popover__btn--warning{color:#f59e0b;}
.cd-action-popover__btn--success{color:#28a745;}
.cd-action-popover__divider{height:1px;background:#e0e0e0;margin:4px 0;}

/* Modal */
.hr-modal-overlay{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.5);z-index:1000;justify-content:center;align-items:flex-start;padding:30px 20px;overflow-y:auto;box-sizing:border-box;}
.hr-modal{background:#fff;border:1px solid #e0e0e0;width:100%;max-width:560px;margin:auto;position:relative;}
.hr-modal--wide{max-width:680px;}
.hr-modal__header{display:flex;align-items:center;justify-content:space-between;padding:11px 16px;background:#174DA4;color:#fff;}
.hr-modal__title{font-size:13px;font-weight:700;display:flex;align-items:center;gap:7px;}
.hr-modal__close{background:none;border:none;font-size:20px;cursor:pointer;color:rgba(255,255,255,.8);padding:0 4px;line-height:1;}
.hr-modal__close:hover{color:#fff;}
.hr-modal__body{padding:16px;max-height:70vh;overflow-y:auto;}
.hr-modal__footer{display:flex;align-items:center;justify-content:flex-end;gap:8px;padding:10px 16px;border-top:1px solid #e0e0e0;background:#fafafa;}

/* Form */
.hr-form-row{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;}
.hr-form-row3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:12px;}
.hr-form-group{display:flex;flex-direction:column;gap:4px;}
.hr-form-group--full{grid-column:span 2;}
.hr-label{font-size:11px;font-weight:600;color:#333;}
.hr-label span{color:#dc3545;}
.hr-input,.hr-select{height:32px;padding:0 9px;border:1px solid #d0d5dd;font-size:12px;color:#1a1a2e;width:100%;box-sizing:border-box;}
.hr-input:focus,.hr-select:focus{outline:none;border-color:#174DA4;}
.hr-textarea{padding:8px 9px;border:1px solid #d0d5dd;font-size:12px;color:#1a1a2e;width:100%;box-sizing:border-box;resize:vertical;min-height:60px;}
.hr-hint{font-size:10px;color:#999;margin-top:2px;}
.hr-result{display:none;padding:8px 12px;font-size:11px;font-weight:600;margin-bottom:10px;border-left:3px solid;}
.hr-result--ok{background:#d4edda;border-color:#28a745;color:#155724;display:block;}
.hr-result--err{background:#f8d7da;border-color:#dc3545;color:#721c24;display:block;}

/* Section label in modal */
.hr-section-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;border-bottom:1px solid #e8f0fe;padding-bottom:4px;margin:14px 0 10px;}

/* Batch preview */
.batch-preview{margin-top:12px;}
.batch-preview__title{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#555;margin-bottom:6px;}
.batch-preview__list{display:flex;flex-wrap:wrap;gap:5px;max-height:100px;overflow-y:auto;padding:2px;}
.batch-preview__item{background:#fff0f0;color:#c0392b;font-size:10px;font-weight:600;padding:3px 8px;border:1px solid #f5c6cb;}
.batch-preview__empty{font-size:11px;color:#aaa;font-style:italic;}

/* Count bar */
.pr-count-bar{font-size:11px;color:#888;padding:5px 14px;background:#fafbfc;border:1px solid #e0e0e0;border-top:none;border-bottom:none;display:flex;align-items:center;justify-content:space-between;}

/* DevExpress overrides */
.dxgvControl_Glass{border:none !important;}
.dxgvHeader_Glass td{font-size:10px !important;text-transform:uppercase !important;letter-spacing:.3px !important;background:#f5f7fa !important;color:#555 !important;}
.dxgvDataRow_Glass td,.dxgvDataRowAlt_Glass td{font-size:11px !important;padding:5px 8px !important;}

@media(max-width:900px){.ct-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:560px){.hr-form-row,.hr-form-row3{grid-template-columns:1fr;}.hr-form-group--full{grid-column:span 1;}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Hidden batch controls -->
<asp:HiddenField ID="hdnBatchIDs" runat="server" />
<asp:Button ID="btnBatchDelete" runat="server" style="display:none;" OnClick="btnBatchDelete_Click" />
<asp:Button ID="btnBatchCancel" runat="server" style="display:none;" OnClick="btnBatchCancel_Click" />

<!-- -- Page Header -------------------------------------------- -->
<div class="pr-page-header">
    <div class="pr-page-header__left">
        <div class="pr-page-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                 fill="none" stroke="#dc3545" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="16"/>
                <line x1="8" y1="12" x2="16" y2="12"/>
            </svg>
        </div>
        <div>
            <div class="pr-page-title">Payroll Deduction Records</div>
            <div class="pr-page-sub">Salary advances, loan repayments and other ad-hoc deductions scheduled for specific payroll periods</div>
        </div>
    </div>
    <div class="pr-hdr-actions">
        <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="openBatchModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Create Recurring
        </button>
        <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="openAddModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Add Deduction
        </button>
    </div>
</div>

<!-- -- Stats ------------------------------------------------- -->
<div class="ct-stats">
    <div class="ct-stat ct-stat--amber">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div>
            <div class="ct-stat__val"><asp:Literal ID="litPending" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Pending</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--blue">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
        <div>
            <div class="ct-stat__val" style="font-size:14px;"><asp:Literal ID="litPendingAmt" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Pending Amount (UGX)</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--green">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <div>
            <div class="ct-stat__val"><asp:Literal ID="litSettled" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Settled This Year</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--grey">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6c757d" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div>
            <div class="ct-stat__val"><asp:Literal ID="litCancelled" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Cancelled</div>
        </div>
    </div>
</div>

<!-- -- Filter Bar -------------------------------------------- -->
<div class="ct-filters">
    <div class="ct-filters__top">
        <div class="ct-search-wrap">
            <svg class="ct-search-icon" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#aaa" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-search-box" placeholder="Search by name or staff code…" />
        </div>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnSearch_Click" />
        <asp:Button ID="btnReset"  runat="server" Text="Reset"  CssClass="hr-btn hr-btn--ghost hr-btn--sm"   OnClick="btnReset_Click" />
        <span class="ct-filters__count"><asp:Literal ID="litFilterCountTop" runat="server" Text="0" /> record(s)</span>
    </div>
    <div class="ct-filters__row">
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Employee</span>
            <asp:DropDownList ID="ddlFilterEmployee" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
        </div>
        <div class="ct-filter-sep"></div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Month</span>
            <asp:DropDownList ID="ddlFilterMonth" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Value="">All Months</asp:ListItem>
                <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Year</span>
            <asp:TextBox ID="txtFilterYear" runat="server" CssClass="ct-filter-select" style="width:60px;" />
        </div>
        <div class="ct-filter-sep"></div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Status</span>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Value="">All Statuses</asp:ListItem>
                <asp:ListItem Value="PENDING">Pending</asp:ListItem>
                <asp:ListItem Value="SETTLED">Settled</asp:ListItem>
                <asp:ListItem Value="CANCELLED">Cancelled</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="ct-filter-sep"></div>
        <div class="ct-filter-grp">
            <span class="ct-filter-grp__label">Per Page</span>
            <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="width:65px;">
                <asp:ListItem Value="25" Selected="True">25</asp:ListItem>
                <asp:ListItem Value="50">50</asp:ListItem>
                <asp:ListItem Value="100">100</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>
</div>

<!-- -- Count bar + batch toolbar ---------------------------- -->
<div class="pr-count-bar">
    <span><asp:Literal ID="litFilterCount" runat="server" Text="0" /> record(s) shown</span>
</div>

<div class="ct-batch-toolbar" id="batchToolbar">
    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
    <div class="ct-batch-info"><strong id="batchCount">0</strong> selected</div>
    <div class="ct-batch-sep"></div>
    <button type="button" class="hr-btn hr-btn--amber hr-btn--sm" onclick="doBatchCancel()">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        Mark Cancelled
    </button>
    <button type="button" class="hr-btn hr-btn--danger hr-btn--sm" onclick="doBatchDelete()">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
        Delete Selected
    </button>
    <div class="ct-batch-sep"></div>
    <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="clearBatchSelection()">Clear</button>
</div>

<!-- -- Grid ------------------------------------------------- -->
<div style="overflow-x:auto;-webkit-overflow-scrolling:touch;border:1px solid #e0e0e0;">
<dx:ASPxGridView ID="gvDeductions" runat="server" Width="100%" ClientInstanceName="gvDeductions"
    KeyFieldName="id" EnableCallBacks="true" Theme="Glass"
    OnRowUpdating="gvDeductions_RowUpdating"
    OnRowDeleting="gvDeductions_RowDeleting"
    OnHtmlRowCreated="gvDeductions_HtmlRowCreated">
    <SettingsPager PageSize="25" />
    <Settings ShowFilterRow="False" HorizontalScrollBarMode="Hidden" />
    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="False" />
    <SettingsEditing Mode="PopupEditForm" />
    <SettingsPopup>
        <EditForm Width="500" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
    </SettingsPopup>
    <EditFormLayoutProperties ColCount="2">
        <Items>
            <dx:GridViewColumnLayoutItem ColumnName="deduction_type"  ColSpan="2" />
            <dx:GridViewColumnLayoutItem ColumnName="amount"          ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="status"          ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="to_deduct_month" ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="to_deduct_year"  ColSpan="1" />
            <dx:GridViewColumnLayoutItem ColumnName="description"     ColSpan="2" />
            <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right" />
        </Items>
    </EditFormLayoutProperties>
    <Columns>
        <dx:GridViewDataTextColumn FieldName="id" Visible="false" />
        <dx:GridViewDataTextColumn FieldName="empID" Visible="false" EditFormSettings-Visible="False" />
        <dx:GridViewDataTextColumn FieldName="payroll_id" Visible="false" EditFormSettings-Visible="False" />

        <dx:GridViewDataTextColumn Caption="" Width="34" Settings-AllowSort="False" Settings-AllowAutoFilter="False" EditFormSettings-Visible="False">
            <HeaderTemplate>
                <input type="checkbox" id="chkSelectAll" onclick="toggleSelectAll(this)"
                       title="Select / deselect all"
                       style="cursor:pointer;accent-color:#174DA4;width:14px;height:14px;" />
            </HeaderTemplate>
            <DataItemTemplate>
                <input type="checkbox" class="ct-row-check" value="<%# Eval("id") %>" onchange="updateBatchToolbar()" />
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff #" Width="68" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-size:10px;font-weight:700;color:#174DA4;font-family:monospace;"><%# Eval("EMP_CODE") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="155" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-weight:600;color:#1a1a2e;font-size:11px;"><%# Eval("emp_name") %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataComboBoxColumn FieldName="deduction_type" Caption="Deduction Type" Width="155">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="Salary Advance"              Value="Salary Advance" />
                    <dx:ListEditItem Text="Loan Repayment (Staff SACCO)" Value="Loan Repayment (Staff SACCO)" />
                    <dx:ListEditItem Text="Loan Repayment (Bank)"       Value="Loan Repayment (Bank)" />
                    <dx:ListEditItem Text="Housing Loan Repayment"      Value="Housing Loan Repayment" />
                    <dx:ListEditItem Text="Court Order / Garnishment"   Value="Court Order / Garnishment" />
                    <dx:ListEditItem Text="Equipment / Asset Recovery"  Value="Equipment / Asset Recovery" />
                    <dx:ListEditItem Text="Overpayment Recovery"        Value="Overpayment Recovery" />
                    <dx:ListEditItem Text="Insurance Premium"           Value="Insurance Premium" />
                    <dx:ListEditItem Text="Welfare Contribution"        Value="Welfare Contribution" />
                    <dx:ListEditItem Text="Other"                       Value="Other" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <span class="pr-type"><%# Eval("deduction_type") %></span>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataSpinEditColumn FieldName="amount" Caption="Amount (UGX)" Width="110">
            <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" MinValue="0" />
            <DataItemTemplate>
                <span class="pr-amount"><%# FormatAmount(Eval("amount")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataSpinEditColumn>

        <dx:GridViewDataComboBoxColumn FieldName="to_deduct_month" Caption="Month" Width="100">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="JANUARY"   Value="JANUARY" />
                    <dx:ListEditItem Text="FEBRUARY"  Value="FEBRUARY" />
                    <dx:ListEditItem Text="MARCH"     Value="MARCH" />
                    <dx:ListEditItem Text="APRIL"     Value="APRIL" />
                    <dx:ListEditItem Text="MAY"       Value="MAY" />
                    <dx:ListEditItem Text="JUNE"      Value="JUNE" />
                    <dx:ListEditItem Text="JULY"      Value="JULY" />
                    <dx:ListEditItem Text="AUGUST"    Value="AUGUST" />
                    <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                    <dx:ListEditItem Text="OCTOBER"   Value="OCTOBER" />
                    <dx:ListEditItem Text="NOVEMBER"  Value="NOVEMBER" />
                    <dx:ListEditItem Text="DECEMBER"  Value="DECEMBER" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <span class="pr-period"><%# Eval("to_deduct_month") %></span>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataSpinEditColumn FieldName="to_deduct_year" Caption="Year" Width="66">
            <PropertiesSpinEdit DisplayFormatString="0" NumberType="Integer" MinValue="2020" MaxValue="2099" />
        </dx:GridViewDataSpinEditColumn>

        <dx:GridViewDataComboBoxColumn FieldName="status" Caption="Status" Width="105">
            <PropertiesComboBox DropDownStyle="DropDownList">
                <Items>
                    <dx:ListEditItem Text="PENDING"   Value="PENDING" />
                    <dx:ListEditItem Text="CANCELLED" Value="CANCELLED" />
                </Items>
            </PropertiesComboBox>
            <DataItemTemplate>
                <%# GetStatusBadge(Eval("status")) %>
            </DataItemTemplate>
        </dx:GridViewDataComboBoxColumn>

        <dx:GridViewDataMemoColumn FieldName="description" Caption="Description" Width="160">
            <PropertiesMemoEdit Rows="3" />
            <DataItemTemplate>
                <span style="font-size:10px;color:#555;" title="<%# Eval("description") %>">
                    <%# TruncStr(Eval("description"), 40) %>
                </span>
            </DataItemTemplate>
        </dx:GridViewDataMemoColumn>

        <dx:GridViewDataTextColumn FieldName="payroll_title" Caption="Payroll Ref" Width="105" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <%# GetPayrollRef(Eval("payroll_title"), Eval("payment_date")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn FieldName="date_recorded" Caption="Recorded" Width="80" EditFormSettings-Visible="False">
            <DataItemTemplate>
                <span style="font-size:10px;color:#888;"><%# FormatDate(Eval("date_recorded")) %></span>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>

        <dx:GridViewDataTextColumn Caption="" Width="42" EditFormSettings-Visible="False" Settings-AllowAutoFilter="False" Settings-AllowSort="False">
            <DataItemTemplate>
                <%# GetActionHtml(Eval("id"), Eval("status")) %>
            </DataItemTemplate>
        </dx:GridViewDataTextColumn>
    </Columns>
</dx:ASPxGridView>
</div>

<!-- ============================================================
     MODAL: Add Single Deduction
     ============================================================ -->
<div class="hr-modal-overlay" id="addDeductionModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span class="hr-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Add Deduction Record
            </span>
            <button type="button" class="hr-modal__close" onclick="closeAddModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="addResult" class="hr-result"></div>
            <div class="hr-section-label">Employee &amp; Deduction</div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Employee <span>*</span></label>
                    <asp:DropDownList ID="ddlAddEmployee" runat="server" CssClass="hr-select" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Deduction Type <span>*</span></label>
                    <asp:DropDownList ID="ddlAddType" runat="server" CssClass="hr-select">
                        <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                        <asp:ListItem>Salary Advance</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Staff SACCO)</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Bank)</asp:ListItem>
                        <asp:ListItem>Housing Loan Repayment</asp:ListItem>
                        <asp:ListItem>Court Order / Garnishment</asp:ListItem>
                        <asp:ListItem>Equipment / Asset Recovery</asp:ListItem>
                        <asp:ListItem>Overpayment Recovery</asp:ListItem>
                        <asp:ListItem>Insurance Premium</asp:ListItem>
                        <asp:ListItem>Welfare Contribution</asp:ListItem>
                        <asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-label">Amount (UGX) <span>*</span></label>
                    <asp:TextBox ID="txtAddAmount" runat="server" CssClass="hr-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Date Recorded</label>
                    <asp:TextBox ID="txtAddDateRecorded" runat="server" CssClass="hr-input" TextMode="Date" />
                </div>
            </div>
            <div class="hr-section-label">Payroll Period</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-label">Month <span>*</span></label>
                    <asp:DropDownList ID="ddlAddMonth" runat="server" CssClass="hr-select">
                        <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                        <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                        <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                        <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                        <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                        <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Year <span>*</span></label>
                    <asp:TextBox ID="txtAddYear" runat="server" CssClass="hr-input" TextMode="Number" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Description / Notes</label>
                    <asp:TextBox ID="txtAddDescription" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="3" />
                </div>
            </div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeAddModal()">Cancel</button>
            <asp:Button ID="btnAddDeduction" runat="server" Text="Save Deduction" CssClass="hr-btn hr-btn--danger hr-btn--sm" OnClick="btnAddDeduction_Click" />
        </div>
    </div>
</div>

<!-- ============================================================
     MODAL: Batch / Recurring Deductions
     ============================================================ -->
<div class="hr-modal-overlay" id="batchDeductionModal">
    <div class="hr-modal hr-modal--wide">
        <div class="hr-modal__header">
            <span class="hr-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                Create Recurring Deductions
            </span>
            <button type="button" class="hr-modal__close" onclick="closeBatchModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="batchResult" class="hr-result"></div>
            <div class="hr-section-label">Employee &amp; Deduction</div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Employee <span>*</span></label>
                    <asp:DropDownList ID="ddlBatchEmployee" runat="server" CssClass="hr-select" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Deduction Type <span>*</span></label>
                    <asp:DropDownList ID="ddlBatchType" runat="server" CssClass="hr-select">
                        <asp:ListItem Value="">-- Select Type --</asp:ListItem>
                        <asp:ListItem>Salary Advance</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Staff SACCO)</asp:ListItem>
                        <asp:ListItem>Loan Repayment (Bank)</asp:ListItem>
                        <asp:ListItem>Housing Loan Repayment</asp:ListItem>
                        <asp:ListItem>Court Order / Garnishment</asp:ListItem>
                        <asp:ListItem>Equipment / Asset Recovery</asp:ListItem>
                        <asp:ListItem>Overpayment Recovery</asp:ListItem>
                        <asp:ListItem>Insurance Premium</asp:ListItem>
                        <asp:ListItem>Welfare Contribution</asp:ListItem>
                        <asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-label">Amount per Instalment (UGX) <span>*</span></label>
                    <asp:TextBox ID="txtBatchAmount" runat="server" CssClass="hr-input" TextMode="Number" Text="0" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Number of Instalments <span>*</span></label>
                    <asp:TextBox ID="txtBatchMonths" runat="server" CssClass="hr-input" TextMode="Number" Text="1" />
                    <span class="hr-hint">Max 60 months</span>
                </div>
            </div>
            <div class="hr-section-label">Starting Payroll Period</div>
            <div class="hr-form-row3">
                <div class="hr-form-group">
                    <label class="hr-label">Start Month <span>*</span></label>
                    <asp:DropDownList ID="ddlBatchStartMonth" runat="server" CssClass="hr-select" onchange="updateBatchPreview()">
                        <asp:ListItem>JANUARY</asp:ListItem><asp:ListItem>FEBRUARY</asp:ListItem>
                        <asp:ListItem>MARCH</asp:ListItem><asp:ListItem>APRIL</asp:ListItem>
                        <asp:ListItem>MAY</asp:ListItem><asp:ListItem>JUNE</asp:ListItem>
                        <asp:ListItem>JULY</asp:ListItem><asp:ListItem>AUGUST</asp:ListItem>
                        <asp:ListItem>SEPTEMBER</asp:ListItem><asp:ListItem>OCTOBER</asp:ListItem>
                        <asp:ListItem>NOVEMBER</asp:ListItem><asp:ListItem>DECEMBER</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="hr-form-group">
                    <label class="hr-label">Start Year <span>*</span></label>
                    <asp:TextBox ID="txtBatchStartYear" runat="server" CssClass="hr-input" TextMode="Number" onchange="updateBatchPreview()" />
                </div>
            </div>
            <div class="hr-form-row">
                <div class="hr-form-group hr-form-group--full">
                    <label class="hr-label">Description / Notes</label>
                    <asp:TextBox ID="txtBatchDescription" runat="server" CssClass="hr-textarea" TextMode="MultiLine" Rows="2"
                        placeholder="E.g. SACCO Loan - instalment {n} of 12" />
                    <span class="hr-hint">Use <strong>{n}</strong> as a placeholder for instalment number (e.g. 1, 2, 3…)</span>
                </div>
            </div>
            <div class="batch-preview">
                <div class="batch-preview__title">Preview - months to be created:</div>
                <div id="batchPreviewList" class="batch-preview__list">
                    <span class="batch-preview__empty">Fill in the fields above to preview</span>
                </div>
            </div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeBatchModal()">Cancel</button>
            <asp:Button ID="btnBatchCreate" runat="server" Text="Create Records" CssClass="hr-btn hr-btn--danger hr-btn--sm" OnClick="btnBatchCreate_Click" />
        </div>
    </div>
</div>

<script>
var MONTHS_ARR=['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];

/* -- Action popovers -- */
function toggleActionPopover(btn,evt){evt.stopPropagation();var pop=btn.nextElementSibling;var isOpen=pop.classList.contains('is-open');closeAllPopovers();if(!isOpen)pop.classList.add('is-open');}
function closeAllPopovers(){document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){p.classList.remove('is-open');});}
document.addEventListener('click',closeAllPopovers);

/* -- Modals -- */
function openAddModal(){
    document.getElementById('addDeductionModal').style.display='flex';
    var r=document.getElementById('addResult');r.innerHTML='';r.className='hr-result';
}
function closeAddModal(){document.getElementById('addDeductionModal').style.display='none';}
function openBatchModal(){
    document.getElementById('batchDeductionModal').style.display='flex';
    var r=document.getElementById('batchResult');r.innerHTML='';r.className='hr-result';
    updateBatchPreview();
}
function closeBatchModal(){document.getElementById('batchDeductionModal').style.display='none';}
document.querySelectorAll('.hr-modal-overlay').forEach(function(o){
    o.addEventListener('click',function(e){if(e.target===o)o.style.display='none';});
});
document.addEventListener('keydown',function(e){
    if(e.key==='Escape'){closeAddModal();closeBatchModal();}
});

/* -- Grid helpers (DX v16.1) -- */
function gridFindIndex(gName,key){
    var g=window[gName];var c=g.GetVisibleRowsOnPage();
    for(var i=0;i<c;i++)if(String(g.GetRowKey(i))===String(key))return i;
    return -1;
}
function gridEdit(gName,key){closeAllPopovers();var idx=gridFindIndex(gName,key);if(idx>=0)window[gName].StartEditRow(idx);}
function gridDelete(gName,key){
    closeAllPopovers();
    if(!confirm('Delete this deduction record? This cannot be undone.'))return;
    var idx=gridFindIndex(gName,key);if(idx>=0)window[gName].DeleteRow(idx);
}

/* -- Batch toolbar -- */
function updateBatchToolbar(){
    var checked=document.querySelectorAll('.ct-row-check:checked');
    var all=document.querySelectorAll('.ct-row-check');
    var tb=document.getElementById('batchToolbar');
    var cnt=document.getElementById('batchCount');
    if(checked.length>0){tb.style.display='flex';cnt.textContent=checked.length;}
    else tb.style.display='none';
    var chk=document.getElementById('chkSelectAll');
    if(chk){chk.indeterminate=(checked.length>0&&checked.length<all.length);chk.checked=all.length>0&&checked.length===all.length;}
}
function toggleSelectAll(cb){document.querySelectorAll('.ct-row-check').forEach(function(c){c.checked=cb.checked;});updateBatchToolbar();}
function clearBatchSelection(){
    document.querySelectorAll('.ct-row-check').forEach(function(c){c.checked=false;});
    var chk=document.getElementById('chkSelectAll');if(chk){chk.checked=false;chk.indeterminate=false;}
    updateBatchToolbar();
}
function getBatchIDs(){var ids=[];document.querySelectorAll('.ct-row-check:checked').forEach(function(c){ids.push(c.value);});return ids.join(',');}
function doBatchCancel(){
    var n=document.querySelectorAll('.ct-row-check:checked').length;
    if(!n||!confirm('Mark '+n+' deduction(s) as CANCELLED?'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=getBatchIDs();
    document.getElementById('<%= btnBatchCancel.ClientID %>').click();
}
function doBatchDelete(){
    var n=document.querySelectorAll('.ct-row-check:checked').length;
    if(!n||!confirm('Permanently delete '+n+' record(s)? This cannot be undone.'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=getBatchIDs();
    document.getElementById('<%= btnBatchDelete.ClientID %>').click();
}

/* -- Batch preview -- */
function updateBatchPreview(){
    var pv=document.getElementById('batchPreviewList');if(!pv)return;
    var selEl=document.getElementById('<%= ddlBatchStartMonth.ClientID %>');
    var yrEl=document.getElementById('<%= txtBatchStartYear.ClientID %>');
    var numEl=document.getElementById('<%= txtBatchMonths.ClientID %>');
    if(!selEl||!yrEl||!numEl){return;}
    var startMon=MONTHS_ARR.indexOf(selEl.value);
    var startYr=parseInt(yrEl.value,10);
    var num=parseInt(numEl.value,10);
    if(startMon<0||isNaN(startYr)||isNaN(num)||num<1){pv.innerHTML='<span class="batch-preview__empty">Fill in all fields above</span>';return;}
    num=Math.min(num,60);
    var html='';
    for(var i=0;i<num;i++){
        var m=(startMon+i)%12;var y=startYr+Math.floor((startMon+i)/12);
        html+='<span class="batch-preview__item">'+MONTHS_ARR[m]+' '+y+'</span>';
    }
    pv.innerHTML=html;
}
(function(){
    var n=document.getElementById('<%= txtBatchMonths.ClientID %>');
    if(n)n.addEventListener('input',updateBatchPreview);
})();

/* -- Single row cancel (reuses batch cancel handler) -- */
function singleCancel(id){
    closeAllPopovers();
    if(!confirm('Mark this deduction as CANCELLED?'))return;
    document.getElementById('<%= hdnBatchIDs.ClientID %>').value=id;
    document.getElementById('<%= btnBatchCancel.ClientID %>').click();
}

/* -- Search on Enter -- */
(function(){
    var sb=document.getElementById('<%= txtSearch.ClientID %>');
    if(sb)sb.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();document.getElementById('<%= btnSearch.ClientID %>').click();}});
    var yr=document.getElementById('<%= txtFilterYear.ClientID %>');
    if(yr)yr.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();document.getElementById('<%= btnSearch.ClientID %>').click();}});
})();
</script>
</asp:Content>