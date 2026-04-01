<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="SupplierManagement.aspx.cs" Inherits="COOPERP_NewScreens_SupplierManagement" Title="Supplier Management - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== SUPPLIER MANAGEMENT - ft- design system ==================== */
.ft-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--total{--stat-c:#05275C}.ft-stat--total .ft-stat__icon{background:#e8f0fc}.ft-stat--total .ft-stat__val{color:#05275C}
.ft-stat--active{--stat-c:#2e7d32}.ft-stat--active .ft-stat__icon{background:#e6f4ea}.ft-stat--active .ft-stat__val{color:#2e7d32}
.ft-stat--phone{--stat-c:#e65100}.ft-stat--phone .ft-stat__icon{background:#fff3e0}.ft-stat--phone .ft-stat__val{color:#e65100}

.ft-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:14px}
.ft-card__header{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.ft-card__title{font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:2px 8px;border:1px solid rgba(23,77,164,.15)}
.ft-filters{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px}
.ft-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-input{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;min-width:110px;font-family:inherit}
.ft-filter-input:focus{border-color:#174DA4;outline:none}

.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}
.ft-btn--ghost{background:transparent;border:1px solid #e0e5ed;color:#555}.ft-btn--ghost:hover{border-color:#174DA4;color:#174DA4}
.ft-btn--danger{background:transparent;border:1px solid #e0e5ed;color:#c62828}.ft-btn--danger:hover{background:#fde8e8;border-color:#c62828}
.ft-btn--edit{background:transparent;border:1px solid #e0e5ed;color:#174DA4}.ft-btn--edit:hover{background:#e8f0fc;border-color:#174DA4}
.ft-btn--sm{padding:5px 11px;font-size:10px}
.ft-btn--cancel{background:#757575;color:#fff}.ft-btn--cancel:hover{background:#616161}

.ft-table-wrap{overflow:auto;max-height:520px;position:relative}
.ft-table{width:100%;border-collapse:collapse;min-width:700px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:9px 12px;border-bottom:2px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:8px 12px;vertical-align:middle;color:#1a1a2e;font-size:11px}
.ft-col-id{width:60px;color:#05275C;font-weight:700}
.ft-col-actions{width:120px;text-align:center;white-space:nowrap}

.ft-toast{display:none;padding:9px 14px;font-size:12px;font-weight:600;margin-bottom:12px;border:1px solid transparent}
.ft-toast--success{display:block;background:#e6f4ea;color:#155724;border-color:#c3e6cb}
.ft-toast--error{display:block;background:#fde8e8;color:#c62828;border-color:#f5c6cb}

.ft-nodata{padding:30px 20px;text-align:center;color:#999;font-size:13px}
.ft-pager{display:flex;align-items:center;justify-content:space-between;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666}
.ft-pager__info strong{color:#05275C}

@media(max-width:768px){.ft-stats{grid-template-columns:1fr}.ft-filters__row{flex-direction:column}}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- Message Panel -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false">
    <asp:Literal ID="litMsg" runat="server" />
</asp:Panel>

<!-- Stats Row -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--total">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litSupplierCount" runat="server" Text="0" /></div><div class="ft-stat__label">Total Suppliers</div></div>
    </div>
    <div class="ft-stat ft-stat--active">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litWithAddress" runat="server" Text="0" /></div><div class="ft-stat__label">With Address</div></div>
    </div>
    <div class="ft-stat ft-stat--phone">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litWithPhone" runat="server" Text="0" /></div><div class="ft-stat__label">With Phone</div></div>
    </div>
</div>

<!-- Supplier Card -->
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Supplier Management
        </div>
        <asp:Literal ID="litBadge" runat="server" />
    </div>
    <div class="ft-filters">
        <div class="ft-filters__row">
            <asp:HiddenField ID="hdnEditId" runat="server" Value="" />
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Supplier Name</span>
                <asp:TextBox ID="txtSupplierName" runat="server" placeholder="Company / Person name" CssClass="ft-filter-input" style="min-width:220px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Address</span>
                <asp:TextBox ID="txtSupplierAddress" runat="server" placeholder="Physical / Postal address" CssClass="ft-filter-input" style="min-width:220px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Phone</span>
                <asp:TextBox ID="txtSupplierPhone" runat="server" placeholder="Phone / Mobile" CssClass="ft-filter-input" style="min-width:140px;" />
            </div>
            <asp:Button ID="btnSave" runat="server" Text="+ Add Supplier" CssClass="ft-btn ft-btn--primary" OnClick="btnSave_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="ft-btn ft-btn--cancel ft-btn--sm" OnClick="btnCancel_Click" Visible="false" />
        </div>
    </div>
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th>ID</th><th>Supplier Name</th><th>Address</th><th>Phone</th><th style="text-align:center">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptSuppliers" runat="server" OnItemCommand="rptSuppliers_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="ft-col-id"><%# Eval("supplierID") %></td>
                            <td style="font-weight:600;"><%# Eval("supplierName") %></td>
                            <td><%# Eval("supplierAdress") %></td>
                            <td><%# Eval("supplierPhone") %></td>
                            <td class="ft-col-actions">
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditSupplier"
                                    CommandArgument='<%# Eval("supplierID") + "|" + Eval("supplierName") + "|" + Eval("supplierAdress") + "|" + Eval("supplierPhone") %>'
                                    CssClass="ft-btn ft-btn--edit ft-btn--sm" ToolTip="Edit">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                </asp:LinkButton>
                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteSupplier"
                                    CommandArgument='<%# Eval("supplierID") %>'
                                    CssClass="ft-btn ft-btn--danger ft-btn--sm" ToolTip="Delete"
                                    OnClientClick="return confirm('Delete this supplier?');">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                    <tr><td colspan="5" class="ft-nodata">No suppliers registered.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Literal ID="litFooter" runat="server" /></span>
    </div>
</div>
</asp:Content>
