<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HRContracts.aspx.cs" Inherits="COOPERP_NewScreens_HRContracts" Title="Contract Management - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== CONTRACT MANAGEMENT ===== */

/* Page Header */
.ct-page-header { display:flex; align-items:center; justify-content:space-between; padding:12px 0 10px; margin-bottom:12px; border-bottom:2px solid #174DA4; }
.ct-page-header__left { display:flex; align-items:center; gap:10px; }
.ct-page-header__icon { width:36px; height:36px; background:#174DA4; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.ct-page-header__title { font-size:16px; font-weight:700; color:#1a1a2e; margin:0; }
.ct-page-header__sub { font-size:11px; color:#888; margin-top:1px; }

/* Stats row */
.ct-stats { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; margin-bottom:12px; }
.ct-stat { background:#fff; border:1px solid #e0e0e0; padding:10px 14px; display:flex; align-items:center; gap:10px; }
.ct-stat__icon { width:34px; height:34px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.ct-stat__body { min-width:0; }
.ct-stat__val { font-size:20px; font-weight:700; line-height:1.1; }
.ct-stat__label { font-size:9px; text-transform:uppercase; letter-spacing:.5px; color:#888; margin-top:1px; white-space:nowrap; }
.ct-stat--blue  .ct-stat__icon { background:#e8f0fc; } .ct-stat--blue  .ct-stat__val { color:#174DA4; }
.ct-stat--green .ct-stat__icon { background:#e6f4ea; } .ct-stat--green .ct-stat__val { color:#28a745; }
.ct-stat--red   .ct-stat__icon { background:#fdecea; } .ct-stat--red   .ct-stat__val { color:#dc3545; }
.ct-stat--amber .ct-stat__icon { background:#fff8e1; } .ct-stat--amber .ct-stat__val { color:#e67e00; }
.ct-stat--grey  .ct-stat__icon { background:#f0f0f0; } .ct-stat--grey  .ct-stat__val { color:#555; }

/* Expiry banner */
.ct-banner { display:flex; align-items:center; gap:10px; background:#fff8e1; border:1px solid #ffe082; border-left:4px solid #ffc107; padding:9px 14px; font-size:11px; color:#6d4c00; margin-bottom:10px; }
.ct-banner svg { flex-shrink:0; }
.ct-banner strong { color:#b45309; }
.ct-banner a { color:#174DA4; font-weight:600; text-decoration:none; margin-left:6px; }

/* Card */
.cd-card { background:#fff; border:1px solid #e0e0e0; margin-bottom:12px; }
.cd-card__header { display:flex; align-items:center; justify-content:space-between; padding:9px 14px; border-bottom:1px solid #e0e0e0; background:#fafbfc; }
.cd-card__title { font-size:13px; font-weight:700; color:#1a1a1a; display:flex; align-items:center; gap:7px; }

/* Filter bar */
.ct-filters { display:flex; align-items:center; gap:6px; flex-wrap:wrap; padding:8px 10px; border-bottom:1px solid #e0e0e0; background:#f7f8fa; }
.ct-search-wrap { position:relative; flex:1; min-width:180px; max-width:280px; }
.ct-search-wrap svg { position:absolute; left:7px; top:50%; transform:translateY(-50%); pointer-events:none; color:#999; }
.ct-search-box { width:100%; padding:5px 8px 5px 26px; border:1px solid #d0d0d0; font-size:11px; outline:none; background:#fff; box-sizing:border-box; }
.ct-search-box:focus { border-color:#174DA4; }
.ct-filter-select { padding:5px 8px; border:1px solid #d0d0d0; font-size:11px; background:#fff; cursor:pointer; }
.ct-filter-select:focus { outline:none; border-color:#174DA4; }
.ct-filters-sep { width:1px; height:20px; background:#e0e0e0; margin:0 2px; }

/* Buttons */
.hr-btn { padding:5px 12px; font-size:11px; font-weight:600; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:4px; white-space:nowrap; line-height:1.4; }
.hr-btn--primary { background:#174DA4; color:#fff; }  .hr-btn--primary:hover { background:#0f3a7d; }
.hr-btn--success { background:#28a745; color:#fff; }  .hr-btn--success:hover { background:#218838; }
.hr-btn--danger  { background:#dc3545; color:#fff; }  .hr-btn--danger:hover  { background:#c82333; }
.hr-btn--outline { background:#fff; color:#174DA4; border:1px solid #174DA4; } .hr-btn--outline:hover { background:#174DA4; color:#fff; }
.hr-btn--ghost   { background:transparent; color:#555; border:1px solid #d0d0d0; } .hr-btn--ghost:hover { border-color:#174DA4; color:#174DA4; }
.hr-btn--amber   { background:#e67e00; color:#fff; }  .hr-btn--amber:hover  { background:#b45309; }
.hr-btn--sm      { padding:4px 10px; font-size:10px; }

/* Badges */
.hr-badge { display:inline-block; padding:2px 8px; font-size:9px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }
.hr-badge--valid      { background:#d4edda; color:#155724; }
.hr-badge--expired    { background:#f8d7da; color:#721c24; }
.hr-badge--terminated { background:#e2e3e5; color:#383d41; }
.hr-badge--resigned   { background:#fff3cd; color:#856404; }
.hr-badge--none       { background:#e9ecef; color:#6c757d; }

/* Days remaining pill */
.ct-days { display:inline-flex; align-items:center; gap:3px; padding:2px 6px; font-size:10px; font-weight:700; }
.ct-days--ok     { background:#d4edda; color:#155724; }
.ct-days--warn   { background:#fff3cd; color:#856404; }
.ct-days--urgent { background:#f8d7da; color:#721c24; }
.ct-days--over   { background:#dc3545; color:#fff; }
.ct-days--na     { color:#bbb; font-size:10px; }

/* Row colouring */
.ct-row-valid    td { background:#fff !important; }
.ct-row-expiring td { background:#fffdf0 !important; }
.ct-row-expired  td { background:#fff6f6 !important; }
.ct-row-other    td { background:#fafafa !important; }

/* Action popover (same pattern as HREmployees) */
.cd-action-wrapper  { position:relative; display:inline-block; }
.cd-action-trigger  { background:none; border:1px solid #d0d0d0; border-radius:0; padding:3px 6px; cursor:pointer; color:#555; display:inline-flex; align-items:center; }
.cd-action-trigger:hover { border-color:#174DA4; color:#174DA4; background:#f0f4ff; }
.cd-action-popover  { display:none; position:absolute; right:0; top:100%; z-index:9999; background:#fff; border:1px solid #d0d0d0; box-shadow:0 4px 16px rgba(0,0,0,.12); min-width:160px; }
.cd-action-popover.is-open { display:block; }
.cd-action-popover__menu { list-style:none; margin:0; padding:3px 0; }
.cd-action-popover__item { margin:0; }
.cd-action-popover__btn  { width:100%; background:none; border:none; padding:7px 14px; font-size:11px; color:#333; cursor:pointer; display:flex; align-items:center; gap:7px; text-align:left; }
.cd-action-popover__btn:hover { background:#f0f4ff; color:#174DA4; }
.cd-action-popover__btn--danger:hover { background:#fdecea; color:#dc3545; }
.cd-action-popover__btn--success:hover { background:#e6f4ea; color:#28a745; }
.cd-action-popover__divider { height:1px; background:#e0e0e0; margin:3px 0; }

/* Modal */
.hr-modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.45); z-index:10000; align-items:center; justify-content:center; }
.hr-modal { background:#fff; width:580px; max-width:96vw; max-height:88vh; overflow-y:auto; box-shadow:0 12px 40px rgba(0,0,0,.22); display:flex; flex-direction:column; }
.hr-modal__header { background:#174DA4; color:#fff; padding:10px 16px; font-size:13px; font-weight:700; display:flex; align-items:center; justify-content:space-between; flex-shrink:0; }
.hr-modal__close { background:none; border:none; color:#fff; font-size:20px; cursor:pointer; line-height:1; padding:0; }
.hr-modal__body { padding:16px; flex:1; overflow-y:auto; }
.hr-modal__footer { padding:10px 16px; border-top:1px solid #e0e0e0; display:flex; justify-content:flex-end; gap:8px; flex-shrink:0; background:#fafbfc; }
.hr-modal__section { font-size:9px; text-transform:uppercase; letter-spacing:.6px; color:#174DA4; font-weight:700; padding:6px 0 4px; border-bottom:1px solid #e8ecf4; margin-bottom:8px; margin-top:12px; }
.hr-modal__section:first-child { margin-top:0; }

/* Form */
.hr-form-group   { margin-bottom:10px; }
.hr-form-label   { display:block; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#555; font-weight:600; margin-bottom:3px; }
.hr-form-label .req { color:#dc3545; margin-left:2px; }
.hr-form-input, .hr-form-select, .hr-form-textarea { width:100%; padding:6px 8px; border:1px solid #ccc; font-size:12px; box-sizing:border-box; background:#fff; }
.hr-form-input:focus, .hr-form-select:focus, .hr-form-textarea:focus { border-color:#174DA4; outline:none; }
.hr-form-row  { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.hr-form-row3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px; }
.hr-form-hint { font-size:10px; color:#888; margin-top:2px; }
.hr-result { margin-top:8px; font-size:12px; padding:6px 10px; display:none; }
.hr-result--err  { background:#fdecea; color:#b91c1c; border-left:3px solid #dc3545; display:block; }
.hr-result--ok   { background:#e6f4ea; color:#155724; border-left:3px solid #28a745; display:block; }

/* Grid tweaks */
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass td { font-size:10px !important; text-transform:uppercase !important; letter-spacing:.3px !important; background:#f5f7fa !important; color:#555 !important; border-bottom:2px solid #e0e0e0 !important; }
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td { font-size:11px !important; padding:5px 8px !important; border-bottom:1px solid #f0f0f0 !important; vertical-align:middle !important; }
.dxgvDataRow_Glass:hover td, .dxgvDataRowAlt_Glass:hover td { background:#f0f4ff !important; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="ct-page-header">
    <div class="ct-page-header__left">
        <div class="ct-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <div>
            <div class="ct-page-header__title">Employment Contracts</div>
            <div class="ct-page-header__sub">Manage staff contracts, pay scales and contract status</div>
        </div>
    </div>
    <button type="button" class="hr-btn hr-btn--primary" onclick="openAddContractModal()">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        New Contract
    </button>
</div>

<!-- Stats -->
<div class="ct-stats">
    <div class="ct-stat ct-stat--blue">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Total Contracts</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--green">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litValid" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Valid</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--amber">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litExpiring" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Expiring (90 days)</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--red">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litExpired" runat="server" Text="0" /></div>
            <div class="ct-stat__label">Expired</div>
        </div>
    </div>
    <div class="ct-stat ct-stat--grey">
        <div class="ct-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#555" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div class="ct-stat__body">
            <div class="ct-stat__val"><asp:Literal ID="litNoContract" runat="server" Text="0" /></div>
            <div class="ct-stat__label">No Contract</div>
        </div>
    </div>
</div>

<!-- Expiry Banner -->
<asp:Panel ID="pnlExpiryWarning" runat="server" Visible="false">
<div class="ct-banner">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    <span><strong><asp:Literal ID="litExpiryCount" runat="server" /> contract(s)</strong> are expiring within 90 days — review and renew as needed.
    <a href="javascript:void(0)" onclick="filterByExpiring()">View expiring contracts &rarr;</a></span>
</div>
</asp:Panel>

<!-- Contracts Grid -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            Contract Records
        </div>
        <span id="gridRowCount" style="font-size:10px;color:#888;"></span>
    </div>

    <div class="ct-filters">
        <div class="ct-search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="ct-search-box" placeholder="Search name or staff code…" />
        </div>
        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Statuses" Value="" />
            <asp:ListItem Text="Valid" Value="VALID" />
            <asp:ListItem Text="Expired" Value="EXPIRED" />
            <asp:ListItem Text="Terminated" Value="TERMINATED" />
            <asp:ListItem Text="Resigned" Value="RESIGNED" />
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFilterDept" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Departments" Value="" />
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFilterJob" runat="server" CssClass="ct-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Positions" Value="" />
        </asp:DropDownList>
        <div class="ct-filters-sep"></div>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnSearch_Click" />
        <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="hr-btn hr-btn--ghost hr-btn--sm" OnClick="btnReset_Click" />
    </div>

    <div style="padding:0;">
        <dx:ASPxGridView ID="gvContracts" runat="server" Width="100%" ClientInstanceName="gvContracts"
            KeyFieldName="contractID" EnableCallBacks="false" Theme="Glass"
            OnRowUpdating="gvContracts_RowUpdating" OnRowDeleting="gvContracts_RowDeleting"
            OnHtmlRowCreated="gvContracts_HtmlRowCreated">
            <SettingsPager PageSize="25" />
            <Settings ShowFilterRow="False" HorizontalScrollBarMode="Auto" />
            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
            <SettingsEditing Mode="PopupEditForm" />
            <SettingsPopup>
                <EditForm Width="560" Height="420" Modal="true" HorizontalAlign="Center" VerticalAlign="WindowCenter" />
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
                <dx:GridViewDataTextColumn FieldName="contractID" Visible="false" />

                <dx:GridViewDataTextColumn FieldName="EMP_CODE" Caption="Staff #" Width="70" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-size:10px;font-weight:700;color:#174DA4;font-family:monospace;"><%# Eval("EMP_CODE") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn FieldName="emp_name" Caption="Employee" Width="170" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;color:#1a1a1a;"><%# Eval("emp_name") %></span>
                        <div style="font-size:9px;color:#888;"><%# Eval("dept_name") %></div>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn FieldName="dept_name" Caption="Department" Width="1" Visible="false" EditFormSettings-Visible="False" />

                <dx:GridViewDataTextColumn FieldName="jobname" Caption="Position" Width="130" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-size:11px;color:#444;"><%# Eval("jobname") %></span>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataDateColumn FieldName="contractStart" Caption="Start" Width="90">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>

                <dx:GridViewDataDateColumn FieldName="contractEnd" Caption="End" Width="90">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>

                <dx:GridViewDataTextColumn FieldName="days_remaining" Caption="Days Left" Width="80" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <%# GetDaysRemainingHtml(Eval("contractEnd"), Eval("contractStatus")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataComboBoxColumn FieldName="contractStatus" Caption="Status" Width="100">
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

                <dx:GridViewDataTextColumn FieldName="basicpay" Caption="Basic Pay" Width="95" EditFormSettings-Visible="False">
                    <DataItemTemplate>
                        <span style="font-weight:600;font-size:11px;"><%# FormatCurrency(Eval("basicpay")) %></span>
                        <div style="font-size:9px;color:#888;"><%# Eval("scale_name") %></div>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn FieldName="scale_name" Caption="Pay Scale" Width="1" Visible="false" EditFormSettings-Visible="False" />

                <dx:GridViewDataComboBoxColumn FieldName="payscale_edit" Caption="Pay Scale" Width="100" Visible="false">
                    <PropertiesComboBox DataSourceID="dsPayscales" ValueField="ID" TextField="scale_name" />
                </dx:GridViewDataComboBoxColumn>

                <dx:GridViewDataSpinEditColumn FieldName="fixedamount" Caption="Fixed Amt" Width="90" Visible="false">
                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                </dx:GridViewDataSpinEditColumn>

                <dx:GridViewDataMemoColumn FieldName="comments" Caption="Comments" Width="1" Visible="false">
                    <PropertiesMemoEdit Rows="3" />
                </dx:GridViewDataMemoColumn>

                <dx:GridViewDataTextColumn Caption="" Width="42" EditFormSettings-Visible="False" Settings-AllowAutoFilter="False" Settings-AllowSort="False" CellStyle-CssClass="cd-action-cell">
                    <DataItemTemplate>
                        <%# GetActionButtonsHtml(Eval("contractID"), Eval("emp_name"), Eval("contractStatus"), Eval("empID")) %>
                    </DataItemTemplate>
                </dx:GridViewDataTextColumn>
            </Columns>
        </dx:ASPxGridView>
    </div>
</div>

<asp:SqlDataSource ID="dsPayscales" runat="server" ConnectionString="<%$ ConnectionStrings:vacConnectionString %>"
    ProviderName="MySql.Data.MySqlClient"
    SelectCommand="SELECT ID, CONCAT(scale_name, ' (', FORMAT(basicpay,0), ')') AS scale_name FROM hrm_payscales ORDER BY scale_name" />

<!-- ===== ADD CONTRACT MODAL ===== -->
<div class="hr-modal-overlay" id="addContractModal">
    <div class="hr-modal">
        <div class="hr-modal__header">
            <span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
                Create New Contract
            </span>
            <button type="button" class="hr-modal__close" onclick="closeAddContractModal()">&times;</button>
        </div>
        <div class="hr-modal__body">

            <div class="hr-modal__section">Employee</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Employee <span class="req">*</span></label>
                <asp:DropDownList ID="ddlContractEmployee" runat="server" CssClass="hr-form-select" />
            </div>

            <div class="hr-modal__section">Contract Period</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Start Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtContractStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">End Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtContractEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                    <div class="hr-form-hint" id="contractDurationHint"></div>
                </div>
            </div>

            <div class="hr-modal__section">Position &amp; Department</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Position <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlContractJob" runat="server" CssClass="hr-form-select" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Department <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlContractDept" runat="server" CssClass="hr-form-select" />
                </div>
            </div>

            <div class="hr-modal__section">Compensation</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">Pay Scale</label>
                    <asp:DropDownList ID="ddlContractScale" runat="server" CssClass="hr-form-select" />
                    <div class="hr-form-hint">Leave blank to use fixed amount below</div>
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">Fixed Amount</label>
                    <asp:TextBox ID="txtContractFixed" runat="server" CssClass="hr-form-input" TextMode="Number" Text="0" />
                    <div class="hr-form-hint">Applied only when no pay scale is selected</div>
                </div>
            </div>

            <div class="hr-modal__section">Notes</div>
            <div class="hr-form-group">
                <label class="hr-form-label">Comments</label>
                <asp:TextBox ID="txtContractComments" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" placeholder="Optional notes about this contract…" />
            </div>

            <div id="addContractResult" class="hr-result"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeAddContractModal()">Cancel</button>
            <asp:Button ID="btnAddContract" runat="server" Text="Create Contract" CssClass="hr-btn hr-btn--primary hr-btn--sm" OnClick="btnAddContract_Click" />
        </div>
    </div>
</div>

<!-- ===== RENEW CONTRACT MODAL ===== -->
<asp:HiddenField ID="hdnRenewContractID" runat="server" />
<asp:HiddenField ID="hdnRenewEmpID" runat="server" />
<div class="hr-modal-overlay" id="renewModal">
    <div class="hr-modal" style="width:480px;">
        <div class="hr-modal__header">
            <span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:middle;margin-right:4px;"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
                Renew Contract
            </span>
            <button type="button" class="hr-modal__close" onclick="closeRenewModal()">&times;</button>
        </div>
        <div class="hr-modal__body">
            <div id="renewEmpInfo" style="background:#f0f4ff;border-left:3px solid #174DA4;padding:8px 12px;font-size:12px;margin-bottom:14px;color:#1a1a1a;"></div>
            <div class="hr-modal__section">New Contract Period</div>
            <div class="hr-form-row">
                <div class="hr-form-group">
                    <label class="hr-form-label">New Start Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtRenewStart" runat="server" CssClass="hr-form-input" TextMode="Date" />
                </div>
                <div class="hr-form-group">
                    <label class="hr-form-label">New End Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtRenewEnd" runat="server" CssClass="hr-form-input" TextMode="Date" />
                    <div class="hr-form-hint" id="renewDurationHint"></div>
                </div>
            </div>
            <div class="hr-form-group">
                <label class="hr-form-label">Comments</label>
                <asp:TextBox ID="txtRenewComments" runat="server" CssClass="hr-form-input" TextMode="MultiLine" Rows="2" placeholder="Renewal notes…" />
            </div>
            <div id="renewResult" class="hr-result"></div>
        </div>
        <div class="hr-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost hr-btn--sm" onclick="closeRenewModal()">Cancel</button>
            <asp:Button ID="btnRenewContract" runat="server" Text="Renew Contract" CssClass="hr-btn hr-btn--success hr-btn--sm" OnClick="btnRenewContract_Click" />
        </div>
    </div>
</div>

<script type="text/javascript">
/* ---- Action popover ---- */
function toggleActionPopover(btn, evt) {
    evt.stopPropagation();
    var pop = btn.nextElementSibling;
    var isOpen = pop.classList.contains('is-open');
    closeAllActionPopovers();
    if (!isOpen) pop.classList.add('is-open');
}
function closeAllActionPopovers() {
    document.querySelectorAll('.cd-action-popover.is-open').forEach(function(p){ p.classList.remove('is-open'); });
}
document.addEventListener('click', closeAllActionPopovers);

/* ---- Add contract modal ---- */
function openAddContractModal() {
    document.getElementById('addContractModal').style.display = 'flex';
    var r = document.getElementById('addContractResult');
    r.innerHTML = ''; r.className = 'hr-result';
}
function closeAddContractModal() { document.getElementById('addContractModal').style.display = 'none'; }

/* ---- Renew modal ---- */
function openRenewModal(contractID, empID, empName, endDate) {
    closeAllActionPopovers();
    document.getElementById('<%= hdnRenewContractID.ClientID %>').value = contractID;
    document.getElementById('<%= hdnRenewEmpID.ClientID %>').value = empID;
    document.getElementById('renewEmpInfo').innerHTML = '<strong>' + empName + '</strong><br/><span style="font-size:10px;color:#666;">Previous contract ended: ' + (endDate || '—') + '</span>';
    document.getElementById('<%= txtRenewStart.ClientID %>').value = '';
    document.getElementById('<%= txtRenewEnd.ClientID %>').value = '';
    document.getElementById('<%= txtRenewComments.ClientID %>').value = '';
    document.getElementById('renewDurationHint').innerHTML = '';
    var r = document.getElementById('renewResult');
    r.innerHTML = ''; r.className = 'hr-result';
    document.getElementById('renewModal').style.display = 'flex';
}
function closeRenewModal() { document.getElementById('renewModal').style.display = 'none'; }

/* ---- Grid edit/delete wrappers ---- */
function gridEdit(gridName, key) {
    window[gridName].StartEditRow(window[gridName].GetRowIndexByKey(key));
}
function gridDelete(gridName, key) {
    if (confirm('Delete this contract? This cannot be undone.'))
        window[gridName].DeleteRow(window[gridName].GetRowIndexByKey(key));
}

/* ---- Duration hint ---- */
function updateDuration(startId, endId, hintId) {
    var s = document.getElementById(startId), e = document.getElementById(endId), h = document.getElementById(hintId);
    if (!s || !e || !h) return;
    function calc() {
        var sv = s.value, ev = e.value;
        if (!sv || !ev) { h.innerHTML = ''; return; }
        var days = Math.round((new Date(ev) - new Date(sv)) / 86400000);
        if (days < 0) { h.innerHTML = '<span style="color:#dc3545;">End must be after start</span>'; return; }
        var months = Math.floor(days / 30);
        h.innerHTML = months > 0 ? months + ' month(s) / ' + days + ' days' : days + ' day(s)';
    }
    s.addEventListener('change', calc);
    e.addEventListener('change', calc);
}
updateDuration('<%= txtContractStart.ClientID %>', '<%= txtContractEnd.ClientID %>', 'contractDurationHint');
updateDuration('<%= txtRenewStart.ClientID %>', '<%= txtRenewEnd.ClientID %>', 'renewDurationHint');

/* ---- Filter by expiring shortcut ---- */
function filterByExpiring() {
    var sel = document.getElementById('<%= ddlFilterStatus.ClientID %>');
    if (sel) { sel.value = 'VALID'; sel.dispatchEvent(new Event('change')); }
}

/* ---- Search on Enter ---- */
(function() {
    var sb = document.getElementById('<%= txtSearch.ClientID %>');
    if (sb) sb.addEventListener('keydown', function(e) { if (e.key === 'Enter') { e.preventDefault(); document.getElementById('<%= btnSearch.ClientID %>').click(); } });
})();

/* ---- Row count ---- */
window.addEventListener('load', function() {
    var tbl = document.querySelector('.dxgvControl_Glass');
    if (!tbl) return;
    var rows = tbl.querySelectorAll('.dxgvDataRow_Glass, .dxgvDataRowAlt_Glass');
    var el = document.getElementById('gridRowCount');
    if (el && rows.length) el.textContent = rows.length + ' record(s)';
});
</script>
</asp:Content>
