<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ChartOfAccounts.aspx.cs" Inherits="COOPERP_NewScreens_ChartOfAccounts" Title="Chart of Accounts - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== CHART OF ACCOUNTS - ft- design system ======================= */

/* Stats Row */
.ft-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--main{--stat-c:#05275C}.ft-stat--main .ft-stat__icon{background:#e8f0fc}.ft-stat--main .ft-stat__val{color:#05275C}
.ft-stat--sub{--stat-c:#174DA4}.ft-stat--sub .ft-stat__icon{background:#e8f0fc}.ft-stat--sub .ft-stat__val{color:#174DA4}
.ft-stat--cat{--stat-c:#2e7d32}.ft-stat--cat .ft-stat__icon{background:#e6f4ea}.ft-stat--cat .ft-stat__val{color:#2e7d32}
.ft-stat--ledger{--stat-c:#e65100}.ft-stat--ledger .ft-stat__icon{background:#fff3e0}.ft-stat--ledger .ft-stat__val{color:#e65100}

/* Card / Filters */
.ft-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:14px}
.ft-card__header{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.ft-card__title{font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:2px 8px;border:1px solid rgba(23,77,164,.15)}
.ft-filters{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px}
.ft-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-select,.ft-filter-input{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;cursor:pointer;min-width:110px;font-family:inherit}
.ft-filter-select:focus,.ft-filter-input:focus{border-color:#174DA4;outline:none}

/* Buttons */
.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}
.ft-btn--ghost{background:transparent;border:1px solid #e0e5ed;color:#555}.ft-btn--ghost:hover{border-color:#174DA4;color:#174DA4}
.ft-btn--danger{background:transparent;border:1px solid #e0e5ed;color:#c62828}.ft-btn--danger:hover{background:#fde8e8;border-color:#c62828}
.ft-btn--sm{padding:5px 11px;font-size:10px}

/* Badges */
.ft-badge{display:inline-block;padding:3px 9px;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.3px}
.ft-badge--asset{background:#e8f0fc;color:#174DA4}
.ft-badge--liability{background:#fff3e0;color:#e65100}
.ft-badge--income{background:#e6f4ea;color:#2e7d32}
.ft-badge--expense{background:#fde8e8;color:#c62828}
.ft-badge--equity{background:#f3e8fd;color:#7b1fa2}

/* Data Table */
.ft-table-wrap{overflow:auto;max-height:420px;position:relative}
.ft-table{width:100%;border-collapse:collapse;min-width:600px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:9px 12px;border-bottom:2px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:8px 12px;vertical-align:middle;color:#1a1a2e;font-size:11px}
.ft-col-code{width:90px;color:#05275C;font-weight:700}
.ft-col-actions{width:100px;text-align:center}
td.ft-col-actions a,td.ft-col-actions button{margin:0 2px}

/* Toast */
.ft-toast{display:none;padding:9px 14px;font-size:12px;font-weight:600;margin-bottom:12px;border:1px solid transparent}
.ft-toast--success{display:block;background:#e6f4ea;color:#155724;border-color:#c3e6cb}
.ft-toast--error{display:block;background:#fde8e8;color:#c62828;border-color:#f5c6cb}

/* No Data */
.ft-nodata{padding:30px 20px;text-align:center;color:#999;font-size:13px}

/* Pager */
.ft-pager{display:flex;align-items:center;justify-content:space-between;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666;flex-wrap:wrap;gap:8px}
.ft-pager__info strong{color:#05275C}

@media(max-width:768px){.ft-stats{grid-template-columns:repeat(2,1fr)}.ft-filters__row{flex-direction:column}}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<asp:Label ID="lblMessage" runat="server" Visible="false" />

<!-- Stats Row -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--main">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litMainCount" runat="server" Text="0" /></div><div class="ft-stat__label">Main Accounts</div></div>
    </div>
    <div class="ft-stat ft-stat--sub">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litSubCount" runat="server" Text="0" /></div><div class="ft-stat__label">Sub Accounts</div></div>
    </div>
    <div class="ft-stat ft-stat--cat">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litCatCount" runat="server" Text="0" /></div><div class="ft-stat__label">Categories</div></div>
    </div>
    <div class="ft-stat ft-stat--ledger">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litLedgerTypes" runat="server" Text="0" /></div><div class="ft-stat__label">Ledger Types</div></div>
    </div>
</div>

<!-- Main Accounts Card -->
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            Main Account Categories
        </div>
        <asp:Literal ID="litMainBadge" runat="server" />
    </div>
    <div class="ft-filters">
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Account Code</span>
                <asp:TextBox ID="txtMainAccCode" runat="server" MaxLength="15" CssClass="ft-filter-input" style="min-width:100px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Account Name</span>
                <asp:TextBox ID="txtMainAccName" runat="server" MaxLength="45" CssClass="ft-filter-input" style="min-width:180px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">General Category</span>
                <asp:DropDownList ID="ddlGeneralCategory" runat="server" CssClass="ft-filter-select">
                    <asp:ListItem Text="-- Select --" Value="" />
                    <asp:ListItem Text="Asset" Value="Asset" />
                    <asp:ListItem Text="Liability" Value="Liability" />
                    <asp:ListItem Text="Income" Value="Income" />
                    <asp:ListItem Text="Expense" Value="Expense" />
                    <asp:ListItem Text="Equity" Value="Equity" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Sub Category</span>
                <asp:TextBox ID="txtSubCategory" runat="server" MaxLength="45" CssClass="ft-filter-input" style="min-width:140px;" />
            </div>
            <asp:Button ID="btnAddMainAccount" runat="server" Text="+ Add Main Account" CssClass="ft-btn ft-btn--primary" OnClick="btnAddMainAccount_Click" />
        </div>
    </div>
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th>Code</th><th>Account Name</th><th>Category</th><th>Sub Category</th><th style="text-align:center">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptMainAccounts" runat="server" OnItemCommand="rptMainAccounts_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="ft-col-code"><%# Eval("AccountCode") %></td>
                            <td><%# Eval("AccountName") %></td>
                            <td><span class='ft-badge ft-badge--<%# Eval("GeneralCategory").ToString().ToLower() %>'><%# Eval("GeneralCategory") %></span></td>
                            <td><%# Eval("SubCategory") %></td>
                            <td class="ft-col-actions">
                                <asp:LinkButton ID="lnkViewSubs" runat="server" CommandName="ViewSubs" CommandArgument='<%# Eval("AccountCode") %>' CssClass="ft-btn ft-btn--ghost ft-btn--sm" ToolTip="Filter sub accounts">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg> Subs
                                </asp:LinkButton>
                                <asp:LinkButton ID="lnkDeleteMain" runat="server" CommandName="DeleteMain" CommandArgument='<%# Eval("AccountCode") %>' CssClass="ft-btn ft-btn--danger ft-btn--sm" OnClientClick="return confirm('Delete this main account?');" ToolTip="Delete">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoMain" runat="server" Visible="false">
                    <tr><td colspan="5" class="ft-nodata">No main accounts found.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Literal ID="litMainFooter" runat="server" /></span>
    </div>
</div>

<!-- Sub Accounts Card -->
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
            Sub Accounts
        </div>
        <asp:Literal ID="litSubBadge" runat="server" />
    </div>
    <div class="ft-filters">
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Filter by Main Account</span>
                <asp:DropDownList ID="ddlFilterMainAcc" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterMainAcc_Changed" style="min-width:240px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Main Account (for add)</span>
                <asp:DropDownList ID="ddlMainAccountForSub" runat="server" CssClass="ft-filter-select" style="min-width:240px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Account Name</span>
                <asp:TextBox ID="txtSubAccName" runat="server" MaxLength="45" CssClass="ft-filter-input" style="min-width:160px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Details</span>
                <asp:TextBox ID="txtSubAccDetails" runat="server" MaxLength="150" CssClass="ft-filter-input" style="min-width:140px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Account Type</span>
                <asp:TextBox ID="txtSubAccType" runat="server" MaxLength="45" CssClass="ft-filter-input" style="min-width:100px;" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Ledger Type</span>
                <asp:DropDownList ID="ddlLedgerTypeForSub" runat="server" CssClass="ft-filter-select" />
            </div>
            <asp:Button ID="btnAddSubAccount" runat="server" Text="+ Add Sub Account" CssClass="ft-btn ft-btn--primary" OnClick="btnAddSubAccount_Click" />
        </div>
    </div>
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th>Code</th><th>Account Name</th><th>Main Acc</th><th>Details</th><th>Type</th><th>Ledger Type</th><th style="text-align:center">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptSubAccounts" runat="server" OnItemCommand="rptSubAccounts_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="ft-col-code"><%# Eval("AccountCode") %></td>
                            <td><%# Eval("AccountName") %></td>
                            <td style="color:#174DA4;font-weight:600;"><%# Eval("MainAccountCode") %></td>
                            <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title='<%# Eval("Details") %>'><%# Eval("Details") %></td>
                            <td><%# Eval("accounttype") %></td>
                            <td><%# Eval("collectionLedgerType") %></td>
                            <td class="ft-col-actions">
                                <asp:LinkButton ID="lnkDeleteSub" runat="server" CommandName="DeleteSub" CommandArgument='<%# Eval("AccountCode") %>' CssClass="ft-btn ft-btn--danger ft-btn--sm" OnClientClick="return confirm('Delete this sub account?');" ToolTip="Delete">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoSub" runat="server" Visible="false">
                    <tr><td colspan="7" class="ft-nodata">No sub accounts found. Select a main account or add a new one.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Literal ID="litSubFooter" runat="server" /></span>
    </div>
</div>
</asp:Content>
