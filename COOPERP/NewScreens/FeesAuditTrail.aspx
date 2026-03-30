<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesAuditTrail.aspx.cs" Inherits="COOPERP_NewScreens_FeesAuditTrail" Title="Fee Audit Trail - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== FEE AUDIT TRAIL ================================================= */

/* Stats Row */
.fa-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.fa-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.fa-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.fa-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.fa-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.fa-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.fa-stat--total   { --stat-c: #174DA4; } .fa-stat--total .fa-stat__icon { background: #e8f0fc; } .fa-stat--total .fa-stat__val { color: #174DA4; }
.fa-stat--edits   { --stat-c: #e65100; } .fa-stat--edits .fa-stat__icon { background: #fff3e0; } .fa-stat--edits .fa-stat__val { color: #e65100; }
.fa-stat--deletes { --stat-c: #dc3545; } .fa-stat--deletes .fa-stat__icon { background: #fde8e8; } .fa-stat--deletes .fa-stat__val { color: #dc3545; }
.fa-stat--users   { --stat-c: #00695c; } .fa-stat--users .fa-stat__icon { background: #e0f2f1; } .fa-stat--users .fa-stat__val { color: #00695c; }

/* Card & Filters */
.fa-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 14px; }
.fa-card__meta { font-size: 11px; color: #888; }
.fa-filters { padding: 12px 16px; border-bottom: 1px solid #f0f0f0; }
.fa-filters__top { display: flex; gap: 8px; align-items: center; margin-bottom: 10px; flex-wrap: wrap; }
.fa-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 360px; display: flex; align-items: center; gap: 6px; }
.fa-search-wrap svg { color: #aaa; flex-shrink: 0; }
.fa-search-box { border: 1px solid #d0d5dd; padding: 6px 10px; font-size: 12px; width: 100%; outline: none; transition: border-color .15s; }
.fa-search-box:focus { border-color: #174DA4; }
.fa-filters__row { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-end; }
.fa-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.fa-filter-grp__label { font-size: 10px; font-weight: 600; color: #888; text-transform: uppercase; letter-spacing: .3px; }
.fa-filter-select { border: 1px solid #d0d5dd; padding: 5px 8px; font-size: 12px; min-width: 100px; outline: none; background: #fff; }
.fa-filter-select:focus { border-color: #174DA4; }

/* Buttons */
.fa-btn { display: inline-flex; align-items: center; gap: 5px; padding: 7px 14px; font-size: 12px; font-weight: 600; border: 1px solid transparent; cursor: pointer; transition: all .15s; font-family: inherit; text-decoration: none; white-space: nowrap; }
.fa-btn--primary { background: #05275C; color: #fff; }
.fa-btn--primary:hover { background: #174DA4; }
.fa-btn--ghost { background: #fff; border-color: #d0d5dd; color: #555; }
.fa-btn--ghost:hover { background: #f5f5f5; border-color: #174DA4; color: #174DA4; }
.fa-btn--sm { padding: 5px 10px; font-size: 11px; }

/* Action Badges */
.fa-badge { display: inline-block; padding: 2px 10px; font-size: 11px; font-weight: 600; letter-spacing: .3px; }
.fa-badge--edit { background: #fff3e0; color: #e65100; }
.fa-badge--delete { background: #fde8e8; color: #dc3545; }

/* Changed-field highlights */
.fa-diff { display: inline-flex; align-items: center; gap: 4px; font-size: 12px; }
.fa-diff__old { color: #dc3545; text-decoration: line-through; opacity: .7; }
.fa-diff__arrow { color: #888; font-size: 10px; }
.fa-diff__new { color: #16a34a; font-weight: 600; }

/* DevExpress Grid Overrides */
.dxgvControl_Glass { border: none !important; }
.dxgvHeader_Glass { background: #f8f9fb !important; color: #05275C !important; font-size: 11px !important; font-weight: 700 !important; text-transform: uppercase !important; letter-spacing: .3px !important; border-bottom: 2px solid #e0e5ed !important; }
.dxgvDataRow_Glass td, .dxgvGroupRow_Glass td { font-size: 12px !important; }
.dxgvDataRow_Glass:hover td { background: #f0f4ff !important; }
.dxgvSelectedRow_Glass td { background: #e8f0fc !important; }

/* Detail expander (view changes) */
.fa-detail-panel { background: #f9fafb; border: 1px solid #e5e7eb; padding: 14px 18px; margin: 8px 0; }
.fa-detail-panel__title { font-size: 11px; font-weight: 700; color: #05275C; text-transform: uppercase; letter-spacing: .5px; margin-bottom: 8px; }
.fa-detail-grid { display: grid; grid-template-columns: 130px 1fr 1fr; gap: 4px 12px; font-size: 12px; }
.fa-detail-grid__label { font-weight: 600; color: #888; }
.fa-detail-grid__old { color: #dc3545; }
.fa-detail-grid__new { color: #16a34a; font-weight: 600; }

/* Immutable notice */
.fa-notice { display: flex; align-items: center; gap: 8px; padding: 10px 16px; background: #e8f0fc; border-left: 3px solid #174DA4; margin-bottom: 14px; font-size: 12px; color: #05275C; }
.fa-notice svg { flex-shrink: 0; opacity: .7; }

/* Footer */
.fa-grid-footer { padding: 10px 16px; text-align: center; font-size: 11px; color: #888; border-top: 1px solid #f0f0f0; }

/* Toast */
.fs-toast { position: fixed; top: 16px; right: 16px; z-index: 100000; padding: 12px 20px; font-size: 13px; font-weight: 600; box-shadow: 0 4px 16px rgba(0,0,0,.15); max-width: 460px; animation: toastIn .3s ease; }
.fs-toast--success { background: #16a34a; color: #fff; }
.fs-toast--error { background: #dc3545; color: #fff; }
@keyframes toastIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }

/* Detail expand button */
.fa-expand-btn { width: 24px; height: 24px; border: 1px solid #d0d5dd; background: #fff; color: #555; font-size: 12px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px; transition: all .15s; }
.fa-expand-btn:hover { background: #e8f0fc; border-color: #174DA4; color: #174DA4; }

/* Detail Modal */
.fa-modal-overlay { position: fixed; z-index: 99999; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,.45); display: none; align-items: center; justify-content: center; }
.fa-modal-overlay--visible { display: flex; }
.fa-modal { background: #fff; border-radius: 10px; box-shadow: 0 12px 40px rgba(0,0,0,.2); width: 680px; max-width: 95vw; max-height: 85vh; overflow: hidden; display: flex; flex-direction: column; animation: faModalIn .2s ease; }
@keyframes faModalIn { from { transform: scale(.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }
.fa-modal__header { padding: 14px 20px; background: #05275C; display: flex; align-items: center; justify-content: space-between; }
.fa-modal__title { font-size: 14px; font-weight: 700; color: #fff; }
.fa-modal__close { background: none; border: none; color: rgba(255,255,255,.7); font-size: 20px; cursor: pointer; padding: 0 4px; line-height: 1; }
.fa-modal__close:hover { color: #fff; }
.fa-modal__body { padding: 20px; overflow-y: auto; flex: 1; }
.fa-modal__footer { padding: 12px 20px; border-top: 1px solid #e5e7eb; display: flex; justify-content: flex-end; gap: 8px; }

/* Detail modal sections */
.fa-section { margin-bottom: 16px; }
.fa-section__title { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: #05275C; margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px solid #e5e7eb; display: flex; align-items: center; gap: 6px; }
.fa-kv-grid { display: grid; grid-template-columns: 140px 1fr; gap: 6px 12px; font-size: 12px; }
.fa-kv-grid dt { font-weight: 600; color: #888; }
.fa-kv-grid dd { margin: 0; color: #333; }
.fa-changes-table { width: 100%; border-collapse: collapse; font-size: 12px; }
.fa-changes-table th { background: #f8f9fb; padding: 6px 10px; text-align: left; font-weight: 700; color: #05275C; font-size: 10px; text-transform: uppercase; letter-spacing: .3px; border-bottom: 2px solid #e0e5ed; }
.fa-changes-table td { padding: 6px 10px; border-bottom: 1px solid #f0f0f0; }
.fa-changes-table .fa-changed { background: #fffbeb; }
.fa-changes-table .fa-old-val { color: #dc3545; text-decoration: line-through; }
.fa-changes-table .fa-new-val { color: #16a34a; font-weight: 600; }
.fa-changes-table .fa-same { color: #aaa; }

/* Responsive */
@media (max-width: 1000px) { .fa-stats { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 500px) { .fa-stats { grid-template-columns: 1fr; } .fa-modal { width: 98vw; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:Button ID="btnSearch" runat="server" style="display:none;" OnClick="btnSearch_Click" />
<asp:Button ID="btnReset" runat="server" style="display:none;" OnClick="btnReset_Click" />
<asp:Button ID="btnExportCsv" runat="server" style="display:none;" OnClick="btnExportCsv_Click" />

<!-- Toast -->
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div class="fs-toast" id="divToast" runat="server"></div>
</asp:Panel>

<!-- Immutable Notice -->
<div class="fa-notice">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
    <span>This audit trail is <strong>immutable</strong> &mdash; records cannot be edited or deleted. Every change to fee transactions is permanently logged here for accountability.</span>
</div>

<!-- Stats -->
<div class="fa-stats">
    <div class="fa-stat fa-stat--total">
        <div class="fa-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg></div>
        <div><div class="fa-stat__val"><asp:Literal ID="litTotalAudit" runat="server" Text="0" /></div><div class="fa-stat__label">Total Records</div></div>
    </div>
    <div class="fa-stat fa-stat--edits">
        <div class="fa-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg></div>
        <div><div class="fa-stat__val"><asp:Literal ID="litEditCount" runat="server" Text="0" /></div><div class="fa-stat__label">Edits</div></div>
    </div>
    <div class="fa-stat fa-stat--deletes">
        <div class="fa-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg></div>
        <div><div class="fa-stat__val"><asp:Literal ID="litDeleteCount" runat="server" Text="0" /></div><div class="fa-stat__label">Deletions</div></div>
    </div>
    <div class="fa-stat fa-stat--users">
        <div class="fa-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00695c" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg></div>
        <div><div class="fa-stat__val"><asp:Literal ID="litUserCount" runat="server" Text="0" /></div><div class="fa-stat__label">Users Involved</div></div>
    </div>
</div>

<!-- Main Grid Card -->
<div class="fa-card">
    <!-- Filters -->
    <div class="fa-filters">
        <div class="fa-filters__top">
            <div class="fa-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="fa-search-box" placeholder="Search by reg no, student name, TID, changed by..." AutoPostBack="false" />
            </div>
            <button type="button" class="fa-btn fa-btn--primary fa-btn--sm" onclick="document.getElementById('<%= btnSearch.ClientID %>').click()">Search</button>
            <asp:Label ID="lblRecordCount" runat="server" CssClass="fa-card__meta" Text="0 records" />
        </div>
        <div class="fa-filters__row">
            <div class="fa-filter-grp">
                <label class="fa-filter-grp__label">Action</label>
                <asp:DropDownList ID="ddlAction" runat="server" CssClass="fa-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAction_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Actions" />
                    <asp:ListItem Value="EDIT" Text="Edits" />
                    <asp:ListItem Value="DELETE" Text="Deletions" />
                </asp:DropDownList>
            </div>
            <div class="fa-filter-grp">
                <label class="fa-filter-grp__label">Academic Year</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="fa-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
            </div>
            <div class="fa-filter-grp">
                <label class="fa-filter-grp__label">Changed By</label>
                <asp:DropDownList ID="ddlChangedBy" runat="server" CssClass="fa-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlChangedBy_SelectedIndexChanged" />
            </div>
            <div class="fa-filter-grp">
                <label class="fa-filter-grp__label">Date From</label>
                <asp:TextBox ID="txtDateFrom" runat="server" CssClass="fa-filter-select" style="min-width:130px;" />
            </div>
            <div class="fa-filter-grp">
                <label class="fa-filter-grp__label">Date To</label>
                <asp:TextBox ID="txtDateTo" runat="server" CssClass="fa-filter-select" style="min-width:130px;" />
            </div>
            <div class="fa-filter-grp">
                <label class="fa-filter-grp__label">Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="fa-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="min-width:80px;">
                    <asp:ListItem Value="50" Text="50" Selected="True" />
                    <asp:ListItem Value="100" Text="100" />
                    <asp:ListItem Value="200" Text="200" />
                    <asp:ListItem Value="500" Text="500" />
                </asp:DropDownList>
            </div>
            <button type="button" class="fa-btn fa-btn--ghost fa-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
            <span style="flex:1;"></span>
            <button type="button" class="fa-btn fa-btn--ghost fa-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnExportCsv.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                Export CSV
            </button>
        </div>
    </div>

    <!-- Grid -->
    <div style="overflow-x:auto;">
    <dx:ASPxGridView ID="gvAudit" runat="server" ClientInstanceName="gvAudit"
        Width="100%" KeyFieldName="AuditID"
        AutoGenerateColumns="False"
        EnableCallBacks="true"
        Theme="Glass"
        Settings-VerticalScrollBarMode="Visible"
        Settings-VerticalScrollableHeight="520"
        SettingsPager-Mode="ShowPager"
        SettingsPager-PageSize="50"
        OnPageIndexChanged="gvAudit_PageIndexChanged">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="AuditID" Caption="Audit #" Width="70px">
                <CellStyle ForeColor="#05275C" Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="action_type" Caption="Action" Width="75px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span class='fa-badge <%# GetActionClass(Eval("action_type")) %>'><%# Eval("action_type") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="original_tid" Caption="TID" Width="65px" />
            <dx:GridViewDataTextColumn FieldName="orig_regno" Caption="Reg No" Width="120px">
                <CellStyle ForeColor="#05275C" Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student" Width="160px" />
            <dx:GridViewDataTextColumn FieldName="orig_amount" Caption="Orig Amount" Width="105px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span style="font-variant-numeric:tabular-nums;"><%# FormatAmt(Eval("orig_amount")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="amount_change" Caption="Change" Width="105px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <%# FormatAmountChange(Eval("orig_amount"), Eval("new_amount"), Eval("action_type")) %>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="orig_trans_type" Caption="Type" Width="70px" />
            <dx:GridViewDataTextColumn FieldName="changed_by" Caption="Changed By" Width="110px">
                <CellStyle Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="changed_at" Caption="When" Width="130px">
                <DataItemTemplate>
                    <%# FormatDateTime(Eval("changed_at")) %>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="ip_address" Caption="IP" Width="100px">
                <CellStyle ForeColor="#888" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn Caption="" Width="40px">
                <Settings AllowSort="False" AllowAutoFilter="False" />
                <CellStyle HorizontalAlign="Center" Paddings-PaddingLeft="0px" Paddings-PaddingRight="0px" />
                <DataItemTemplate>
                    <button type="button" class="fa-expand-btn" title="View full details"
                        data-auditid='<%# Eval("AuditID") %>'
                        data-action='<%# Eval("action_type") %>'
                        data-tid='<%# Eval("original_tid") %>'
                        data-regno='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("orig_regno"))) %>'
                        data-student='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("student_name"))) %>'
                        data-origtype='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("orig_trans_type"))) %>'
                        data-origitem='<%# Eval("orig_item_code") %>'
                        data-origitemname='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("orig_item_name"))) %>'
                        data-origamount='<%# Eval("orig_amount") %>'
                        data-origdetail='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("orig_detail"))) %>'
                        data-origdate='<%# FormatDateISO(Eval("orig_trans_date")) %>'
                        data-origyear='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("orig_acadyear"))) %>'
                        data-origsem='<%# Eval("orig_semester") %>'
                        data-origstatus='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("orig_post_status"))) %>'
                        data-newtype='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("new_trans_type"))) %>'
                        data-newitem='<%# Eval("new_item_code") %>'
                        data-newitemname='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("new_item_name"))) %>'
                        data-newamount='<%# Eval("new_amount") %>'
                        data-newdetail='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("new_detail"))) %>'
                        data-newdate='<%# FormatDateISO(Eval("new_trans_date")) %>'
                        data-newyear='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("new_acadyear"))) %>'
                        data-newsem='<%# Eval("new_semester") %>'
                        data-newstatus='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("new_post_status"))) %>'
                        data-changedby='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("changed_by"))) %>'
                        data-changedat='<%# FormatDateTime(Eval("changed_at")) %>'
                        data-ip='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("ip_address"))) %>'
                        data-reason='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("reason"))) %>'
                        onclick="showAuditDetail(this)">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                    </button>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsBehavior AllowSort="true" AllowDragDrop="false" />
    </dx:ASPxGridView>
    </div>

    <!-- Footer -->
    <div class="fa-grid-footer">
        <asp:Label ID="lblGridFooter" runat="server" Text="Showing 0 audit records" />
    </div>
</div>

<!-- ============= DETAIL MODAL ============= -->
<div id="modal-detail" class="fa-modal-overlay">
<div class="fa-modal">
    <div class="fa-modal__header">
        <div class="fa-modal__title">Audit Record <span id="detailAuditBadge" style="font-size:11px;background:rgba(255,255,255,.2);padding:2px 8px;border-radius:10px;margin-left:8px;"></span></div>
        <button type="button" class="fa-modal__close" onclick="closeDetailModal()">&times;</button>
    </div>
    <div class="fa-modal__body">

        <!-- Meta Section -->
        <div class="fa-section">
            <div class="fa-section__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                Action Details
            </div>
            <dl class="fa-kv-grid" id="detailMeta"></dl>
        </div>

        <!-- Student Section -->
        <div class="fa-section">
            <div class="fa-section__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                Student
            </div>
            <dl class="fa-kv-grid" id="detailStudent"></dl>
        </div>

        <!-- Changes Section (for EDIT) or Original Values (for DELETE) -->
        <div class="fa-section" id="detailChangesSection">
            <div class="fa-section__title" id="detailChangesTitle">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
                <span id="detailChangesTitleText">Changes Made</span>
            </div>
            <div id="detailChangesBody"></div>
        </div>

        <!-- Reason (if any) -->
        <div class="fa-section" id="detailReasonSection" style="display:none;">
            <div class="fa-section__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="17" y1="10" x2="3" y2="10"></line><line x1="21" y1="6" x2="3" y2="6"></line><line x1="21" y1="14" x2="3" y2="14"></line><line x1="17" y1="18" x2="3" y2="18"></line></svg>
                Reason Provided
            </div>
            <p id="detailReason" style="font-size:13px;color:#333;margin:0;padding:8px 12px;background:#f9fafb;border-left:3px solid #174DA4;"></p>
        </div>

    </div>
    <div class="fa-modal__footer">
        <button type="button" class="fa-btn fa-btn--ghost fa-btn--sm" onclick="closeDetailModal()">Close</button>
    </div>
</div>
</div>
<!-- ============= /DETAIL MODAL ============= -->

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function() {
    var tb = document.getElementById('<%= txtSearch.ClientID %>');
    if (tb) {
        tb.addEventListener('keydown', function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                document.getElementById('<%= btnSearch.ClientID %>').click();
            }
        });
    }
});

function openDetailModal()  { document.getElementById('modal-detail').classList.add('fa-modal-overlay--visible'); }
function closeDetailModal() { document.getElementById('modal-detail').classList.remove('fa-modal-overlay--visible'); }

function showAuditDetail(btn) {
    var d = btn.dataset;

    // Badge
    document.getElementById('detailAuditBadge').textContent = '#' + d.auditid;

    // Meta
    var meta = '<dt>Audit ID</dt><dd>#' + esc(d.auditid) + '</dd>'
        + '<dt>Action</dt><dd><span class="fa-badge ' + (d.action === 'EDIT' ? 'fa-badge--edit' : 'fa-badge--delete') + '">' + esc(d.action) + '</span></dd>'
        + '<dt>Original TID</dt><dd>#' + esc(d.tid) + '</dd>'
        + '<dt>Changed By</dt><dd><strong>' + esc(d.changedby) + '</strong></dd>'
        + '<dt>Date/Time</dt><dd>' + esc(d.changedat) + '</dd>'
        + '<dt>IP Address</dt><dd>' + esc(d.ip || 'N/A') + '</dd>';
    document.getElementById('detailMeta').innerHTML = meta;

    // Student
    var stud = '<dt>Reg No</dt><dd><strong>' + esc(d.regno) + '</strong></dd>'
        + '<dt>Name</dt><dd>' + esc(d.student) + '</dd>';
    document.getElementById('detailStudent').innerHTML = stud;

    // Changes
    if (d.action === 'EDIT') {
        document.getElementById('detailChangesTitleText').textContent = 'Changes Made';
        var fields = [
            { label: 'Transaction Type', orig: d.origtype, newv: d.newtype },
            { label: 'Billing Item', orig: d.origitemname, newv: d.newitemname },
            { label: 'Amount', orig: fmtAmt(d.origamount), newv: fmtAmt(d.newamount) },
            { label: 'Description', orig: d.origdetail, newv: d.newdetail },
            { label: 'Trans Date', orig: d.origdate, newv: d.newdate },
            { label: 'Academic Year', orig: d.origyear, newv: d.newyear },
            { label: 'Semester', orig: d.origsem, newv: d.newsem },
            { label: 'Post Status', orig: d.origstatus, newv: d.newstatus }
        ];
        var html = '<table class="fa-changes-table"><thead><tr><th>Field</th><th>Before</th><th>After</th></tr></thead><tbody>';
        for (var i = 0; i < fields.length; i++) {
            var f = fields[i];
            var changed = (f.orig || '') !== (f.newv || '');
            html += '<tr class="' + (changed ? 'fa-changed' : '') + '">'
                + '<td><strong>' + esc(f.label) + '</strong></td>'
                + '<td class="' + (changed ? 'fa-old-val' : 'fa-same') + '">' + esc(f.orig || '—') + '</td>'
                + '<td class="' + (changed ? 'fa-new-val' : 'fa-same') + '">' + esc(f.newv || '—') + '</td>'
                + '</tr>';
        }
        html += '</tbody></table>';
        document.getElementById('detailChangesBody').innerHTML = html;
    } else {
        document.getElementById('detailChangesTitleText').textContent = 'Deleted Transaction Data';
        var delHtml = '<table class="fa-changes-table"><thead><tr><th>Field</th><th>Value</th></tr></thead><tbody>'
            + '<tr><td><strong>Transaction Type</strong></td><td>' + esc(d.origtype) + '</td></tr>'
            + '<tr><td><strong>Billing Item</strong></td><td>' + esc(d.origitemname) + '</td></tr>'
            + '<tr><td><strong>Amount</strong></td><td>UGX ' + fmtNum(d.origamount) + '</td></tr>'
            + '<tr><td><strong>Description</strong></td><td>' + esc(d.origdetail) + '</td></tr>'
            + '<tr><td><strong>Trans Date</strong></td><td>' + esc(d.origdate) + '</td></tr>'
            + '<tr><td><strong>Academic Year</strong></td><td>' + esc(d.origyear) + '</td></tr>'
            + '<tr><td><strong>Semester</strong></td><td>' + esc(d.origsem) + '</td></tr>'
            + '<tr><td><strong>Post Status</strong></td><td>' + esc(d.origstatus) + '</td></tr>'
            + '</tbody></table>';
        document.getElementById('detailChangesBody').innerHTML = delHtml;
    }

    // Reason
    var reasonSec = document.getElementById('detailReasonSection');
    if (d.reason && d.reason.trim()) {
        document.getElementById('detailReason').textContent = d.reason;
        reasonSec.style.display = '';
    } else {
        reasonSec.style.display = 'none';
    }

    openDetailModal();
}

function esc(str) { var d = document.createElement('div'); d.appendChild(document.createTextNode(str || '')); return d.innerHTML; }
function fmtNum(x) { if (!x || x === '') return '0'; return parseFloat(x).toLocaleString(); }
function fmtAmt(x) { if (!x || x === '') return '—'; return 'UGX ' + parseFloat(x).toLocaleString(); }
</script>

</asp:Content>
