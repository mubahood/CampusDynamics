<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FinanceAuditTrail.aspx.cs" Inherits="COOPERP_NewScreens_FinanceAuditTrail" Title="Finance Audit Trail - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== FINANCE AUDIT TRAIL - ft- design system ==================== */
.ft-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--act{--stat-c:#174DA4}.ft-stat--act .ft-stat__icon{background:#e8f0fc}.ft-stat--act .ft-stat__val{color:#174DA4}
.ft-stat--rep{--stat-c:#e65100}.ft-stat--rep .ft-stat__icon{background:#fff3e0}.ft-stat--rep .ft-stat__val{color:#e65100}
.ft-stat--total{--stat-c:#05275C}.ft-stat--total .ft-stat__icon{background:#e8f0fc}.ft-stat--total .ft-stat__val{color:#05275C}

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

.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}

.ft-table-wrap{overflow:auto;max-height:400px;position:relative}
.ft-table{width:100%;border-collapse:collapse;min-width:800px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:9px 12px;border-bottom:2px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:8px 12px;vertical-align:middle;color:#1a1a2e;font-size:11px}

.ft-nodata{padding:30px 20px;text-align:center;color:#999;font-size:13px}
.ft-pager{display:flex;align-items:center;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666}
.ft-pager__info strong{color:#05275C}

@media(max-width:768px){.ft-stats{grid-template-columns:1fr}.ft-filters__row{flex-direction:column}}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- Stats Row -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--act">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litActivityCount" runat="server" Text="0" /></div><div class="ft-stat__label">Activity Entries</div></div>
    </div>
    <div class="ft-stat ft-stat--rep">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litRepairCount" runat="server" Text="0" /></div><div class="ft-stat__label">Repair Entries</div></div>
    </div>
    <div class="ft-stat ft-stat--total">
        <div class="ft-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litTotalCount" runat="server" Text="0" /></div><div class="ft-stat__label">Total Records</div></div>
    </div>
</div>

<!-- Filter Card -->
<div class="ft-card" style="margin-bottom:14px">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
            Audit Trail Filters
        </div>
        <asp:Literal ID="litPeriodBadge" runat="server" />
    </div>
    <div class="ft-filters">
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Start Date</span>
                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">End Date</span>
                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Log Type</span>
                <asp:DropDownList ID="ddlLogType" runat="server" CssClass="ft-filter-select">
                    <asp:ListItem Value="activity">Activity Log</asp:ListItem>
                    <asp:ListItem Value="repair">Repair Log</asp:ListItem>
                    <asp:ListItem Value="both" Selected="True">Both</asp:ListItem>
                </asp:DropDownList>
            </div>
            <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="ft-btn ft-btn--primary" OnClick="btnFilter_Click" />
        </div>
    </div>
</div>

<!-- Activity Log Card -->
<asp:Panel ID="pnlActivity" runat="server">
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            Activity Log
        </div>
        <asp:Literal ID="litActBadge" runat="server" />
    </div>
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th style="width:60px">ID</th><th>User</th><th>Activity</th><th>Module</th><th>Date/Time</th><th>IP Address</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptActivity" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td style="color:#05275C;font-weight:700;"><%# Eval("id") %></td>
                            <td style="font-weight:600;"><%# Eval("username") %></td>
                            <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title='<%# Eval("activity") %>'><%# Eval("activity") %></td>
                            <td><%# Eval("module") %></td>
                            <td style="white-space:nowrap;"><%# Eval("activity_date", "{0:dd MMM yyyy HH:mm}") %></td>
                            <td><%# Eval("ip_address") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoActivity" runat="server" Visible="false">
                    <tr><td colspan="6" class="ft-nodata">No activity log entries found.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Literal ID="litActFooter" runat="server" /></span>
    </div>
</div>
</asp:Panel>

<!-- Repair Log Card -->
<asp:Panel ID="pnlRepair" runat="server">
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
            Repair Log
        </div>
        <asp:Literal ID="litRepBadge" runat="server" />
    </div>
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th style="width:60px">ID</th><th>Repair Type</th><th>Description</th><th>Performed By</th><th>Date/Time</th><th>Status</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptRepair" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td style="color:#05275C;font-weight:700;"><%# Eval("id") %></td>
                            <td style="font-weight:600;"><%# Eval("repair_type") %></td>
                            <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title='<%# Eval("description") %>'><%# Eval("description") %></td>
                            <td><%# Eval("performed_by") %></td>
                            <td style="white-space:nowrap;"><%# Eval("repair_date", "{0:dd MMM yyyy HH:mm}") %></td>
                            <td><%# Eval("status") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoRepair" runat="server" Visible="false">
                    <tr><td colspan="6" class="ft-nodata">No repair log entries found.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Literal ID="litRepFooter" runat="server" /></span>
    </div>
</div>
</asp:Panel>

</asp:Content>
