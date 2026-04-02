<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksAuditTrail.aspx.cs" Inherits="COOPERP_NewScreens_MarksAuditTrail" Title="Marks Audit Trail - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===============================================
   MARKS AUDIT TRAIL — mat-
   Modern material-inspired audit dashboard
=============================================== */

/* ── Page Header ── */
.mat-page-header{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:18px 24px;flex-wrap:wrap;gap:10px;}
.mat-page-header__left{display:flex;align-items:center;gap:14px;}
.mat-page-header__icon{width:42px;height:42px;background:rgba(255,255,255,.12);border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.mat-page-header__title{font-size:17px;font-weight:700;line-height:1.2;}
.mat-page-header__sub{font-size:12px;opacity:.75;margin-top:2px;}
.mat-page-header__right{display:flex;gap:8px;align-items:center;}

/* ── KPI Row ── */
.mat-kpi-row{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin:18px 20px 0;}
.mat-kpi{background:#fff;border:1px solid #e3e8ef;border-radius:8px;padding:16px 18px;position:relative;overflow:hidden;}
.mat-kpi::before{content:'';position:absolute;left:0;top:0;width:4px;height:100%;border-radius:4px 0 0 4px;}
.mat-kpi--total::before{background:#1a237e;}
.mat-kpi--today::before{background:#2e7d32;}
.mat-kpi--week::before{background:#f57f17;}
.mat-kpi--users::before{background:#6a1b9a;}
.mat-kpi--top::before{background:#00838f;}
.mat-kpi__val{font-size:26px;font-weight:800;line-height:1;margin-bottom:4px;}
.mat-kpi--total .mat-kpi__val{color:#1a237e;}
.mat-kpi--today .mat-kpi__val{color:#2e7d32;}
.mat-kpi--week .mat-kpi__val{color:#f57f17;}
.mat-kpi--users .mat-kpi__val{color:#6a1b9a;}
.mat-kpi--top .mat-kpi__val{color:#00838f;font-size:15px;font-weight:700;}
.mat-kpi__label{font-size:10px;color:#78909c;text-transform:uppercase;font-weight:600;letter-spacing:.4px;}

/* ── Filters ── */
.mat-filters{background:#f5f7fa;border:1px solid #e3e8ef;border-radius:8px;padding:14px 18px;margin:14px 20px 0;display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;}
.mat-fg{display:flex;flex-direction:column;gap:3px;}
.mat-fg label{font-size:9px;color:#78909c;text-transform:uppercase;font-weight:600;letter-spacing:.3px;}
.mat-fg select,.mat-fg input[type=text]{padding:7px 10px;font-size:11px;border:1px solid #cfd8dc;border-radius:4px;background:#fff;min-width:130px;}
.mat-fg select:focus,.mat-fg input:focus{border-color:#1a237e;outline:none;box-shadow:0 0 0 2px rgba(26,35,126,.12);}

/* ── Buttons ── */
.mat-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 16px;font-size:11px;font-weight:600;border:none;border-radius:4px;cursor:pointer;transition:all .15s;}
.mat-btn--primary{background:#1a237e;color:#fff;}
.mat-btn--primary:hover{background:#0d1657;}
.mat-btn--outline{background:#fff;color:#546e7a;border:1px solid #cfd8dc;}
.mat-btn--outline:hover{background:#eceff1;}
.mat-btn--green{background:#2e7d32;color:#fff;}
.mat-btn--green:hover{background:#1b5e20;}

/* ── Content Area ── */
.mat-content{padding:14px 20px 24px;}

/* ── Two-Column Layout ── */
.mat-columns{display:grid;grid-template-columns:1fr 320px;gap:16px;}

/* ── Grid Card ── */
.mat-card{background:#fff;border:1px solid #e3e8ef;border-radius:8px;overflow:hidden;}
.mat-card__head{display:flex;justify-content:space-between;align-items:center;padding:12px 16px;background:linear-gradient(135deg,#1a237e,#283593);color:#fff;}
.mat-card__title{font-size:12px;font-weight:600;}
.mat-card__body{padding:0;}

/* ── ASPxGridView overrides ── */
.mat-grid .dxgvHeader td{background:#f5f7fa!important;font-size:10px!important;font-weight:700!important;text-transform:uppercase!important;padding:10px 8px!important;color:#455a64!important;border-bottom:2px solid #1a237e!important;letter-spacing:.3px;}
.mat-grid .dxgvDataRow td{font-size:11px!important;padding:9px 8px!important;border-bottom:1px solid #eceff1!important;vertical-align:middle!important;}
.mat-grid .dxgvDataRow:hover td{background:#e8eaf6!important;}
.mat-grid .dxgvFocusedRow td{background:#c5cae9!important;}

/* ── Badges ── */
.mat-badge{display:inline-block;padding:3px 10px;font-size:9px;font-weight:700;text-transform:uppercase;border-radius:3px;letter-spacing:.3px;}
.mat-badge--capture{background:#e3f2fd;color:#0d47a1;}
.mat-badge--edit{background:#fff8e1;color:#e65100;}
.mat-badge--cancel{background:#fce4ec;color:#b71c1c;}
.mat-badge--autopass{background:#e8f5e9;color:#1b5e20;}
.mat-badge--mgmt{background:#f3e5f5;color:#4a148c;}

/* ── Severity dots ── */
.mat-sev{display:inline-flex;align-items:center;gap:5px;font-size:10px;font-weight:600;}
.mat-sev__dot{width:8px;height:8px;border-radius:50%;}
.mat-sev--critical .mat-sev__dot{background:#d32f2f;}
.mat-sev--high .mat-sev__dot{background:#f57c00;}
.mat-sev--normal .mat-sev__dot{background:#388e3c;}

/* ── User cell ── */
.mat-user{font-weight:700;color:#1a237e;}

/* ── Sidebar panels ── */
.mat-side-panel{background:#fff;border:1px solid #e3e8ef;border-radius:8px;overflow:hidden;margin-bottom:14px;}
.mat-side-panel__head{padding:10px 14px;background:#263238;color:#fff;font-size:11px;font-weight:700;display:flex;align-items:center;gap:8px;}
.mat-side-panel__body{padding:0;}

/* ── Top Users Table ── */
.mat-top-table{width:100%;border-collapse:collapse;}
.mat-top-table th{font-size:9px;text-transform:uppercase;color:#78909c;font-weight:700;padding:8px 12px;text-align:left;border-bottom:1px solid #e3e8ef;letter-spacing:.3px;}
.mat-top-table td{font-size:11px;padding:8px 12px;border-bottom:1px solid #f5f5f5;}
.mat-top-table tr:hover td{background:#f5f7fa;}
.mat-top-rank{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;font-size:10px;font-weight:800;color:#fff;}
.mat-top-rank--1{background:#ffd600;}
.mat-top-rank--2{background:#90a4ae;}
.mat-top-rank--3{background:#a1887f;}
.mat-top-rank--other{background:#cfd8dc;color:#546e7a;}
.mat-top-bar{height:6px;border-radius:3px;background:#e3e8ef;overflow:hidden;}
.mat-top-bar__fill{height:100%;border-radius:3px;background:linear-gradient(90deg,#1a237e,#3949ab);}

/* ── Action breakdown ── */
.mat-action-row{display:flex;justify-content:space-between;align-items:center;padding:8px 14px;border-bottom:1px solid #f5f5f5;font-size:11px;}
.mat-action-row:last-child{border-bottom:none;}
.mat-action-row__label{display:flex;align-items:center;gap:6px;}
.mat-action-row__dot{width:10px;height:10px;border-radius:2px;}
.mat-action-row__count{font-weight:700;color:#263238;}

/* ── Message ── */
.mat-msg{padding:10px 16px;border-radius:6px;font-size:11px;margin-bottom:12px;display:flex;align-items:center;gap:8px;}
.mat-msg--error{background:#ffebee;color:#b71c1c;border:1px solid #ef9a9a;}
.mat-msg--info{background:#e3f2fd;color:#0d47a1;border:1px solid #90caf9;}

/* ── Responsive ── */
@media(max-width:1200px){.mat-columns{grid-template-columns:1fr;}.mat-kpi-row{grid-template-columns:repeat(3,1fr);}}
@media(max-width:768px){.mat-kpi-row{grid-template-columns:repeat(2,1fr);}.mat-filters{flex-direction:column;}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══ PAGE HEADER ═══ -->
<div class="mat-page-header">
    <div class="mat-page-header__left">
        <div class="mat-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <div>
            <div class="mat-page-header__title">Marks Audit Trail</div>
            <div class="mat-page-header__sub">Track who inserted, changed, or approved student marks</div>
        </div>
    </div>
    <div class="mat-page-header__right">
        <asp:Button ID="btnExportCsv" runat="server" Text="Export CSV" CssClass="mat-btn mat-btn--green" OnClick="btnExportCsv_Click" />
    </div>
</div>

<!-- ═══ KPI ROW ═══ -->
<div class="mat-kpi-row">
    <div class="mat-kpi mat-kpi--total">
        <div class="mat-kpi__val"><asp:Literal ID="litTotal" runat="server">0</asp:Literal></div>
        <div class="mat-kpi__label">Total Marks Actions</div>
    </div>
    <div class="mat-kpi mat-kpi--today">
        <div class="mat-kpi__val"><asp:Literal ID="litToday" runat="server">0</asp:Literal></div>
        <div class="mat-kpi__label">Today</div>
    </div>
    <div class="mat-kpi mat-kpi--week">
        <div class="mat-kpi__val"><asp:Literal ID="litWeek" runat="server">0</asp:Literal></div>
        <div class="mat-kpi__label">This Week</div>
    </div>
    <div class="mat-kpi mat-kpi--users">
        <div class="mat-kpi__val"><asp:Literal ID="litUniqueUsers" runat="server">0</asp:Literal></div>
        <div class="mat-kpi__label">Unique Users</div>
    </div>
    <div class="mat-kpi mat-kpi--top">
        <div class="mat-kpi__val"><asp:Literal ID="litTopUser" runat="server">—</asp:Literal></div>
        <div class="mat-kpi__label">Most Active User</div>
    </div>
</div>

<!-- ═══ FILTERS ═══ -->
<div class="mat-filters">
    <div class="mat-fg">
        <label>From</label>
        <dx:ASPxDateEdit ID="dtFrom" runat="server" Width="125px" DisplayFormatString="dd-MMM-yyyy" />
    </div>
    <div class="mat-fg">
        <label>To</label>
        <dx:ASPxDateEdit ID="dtTo" runat="server" Width="125px" DisplayFormatString="dd-MMM-yyyy" />
    </div>
    <div class="mat-fg">
        <label>Action Type</label>
        <asp:DropDownList ID="ddlAction" runat="server" CssClass="mat-fg select">
            <asp:ListItem Value="" Text="All Actions" />
            <asp:ListItem Value="Capture Results" Text="Old System Capture" />
            <asp:ListItem Value="Results Capture" Text="Faculty Capture" />
            <asp:ListItem Value="Faculty Exam Results Editor" Text="Marks Edit" />
            <asp:ListItem Value="Results Approval Cancel" Text="Approval Cancel" />
            <asp:ListItem Value="Results Management" Text="Results Management" />
            <asp:ListItem Value="Results Auto Pass" Text="Auto Pass" />
        </asp:DropDownList>
    </div>
    <div class="mat-fg">
        <label>User</label>
        <asp:DropDownList ID="ddlUser" runat="server" CssClass="mat-fg select" />
    </div>
    <div class="mat-fg">
        <label>Search (Reg No / Course)</label>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="mat-fg input" placeholder="e.g. MRU2024..." />
    </div>
    <div class="mat-fg">
        <label>&nbsp;</label>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="mat-btn mat-btn--primary" OnClick="btnFilter_Click" />
    </div>
    <div class="mat-fg">
        <label>&nbsp;</label>
        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="mat-btn mat-btn--outline" OnClick="btnClear_Click" />
    </div>
</div>

<!-- ═══ MESSAGE ═══ -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="mat-msg mat-msg--info" style="margin:14px 20px 0;">
    <asp:Literal ID="litMsg" runat="server" />
</asp:Panel>

<!-- ═══ MAIN CONTENT: Two-Column ═══ -->
<div class="mat-content">
    <div class="mat-columns">

        <!-- LEFT: Log Grid -->
        <div class="mat-card">
            <div class="mat-card__head">
                <span class="mat-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" style="vertical-align:-2px;margin-right:6px;"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                    Marks Activity Log
                </span>
                <span style="font-size:10px;opacity:.7;">
                    <asp:Literal ID="litRowCount" runat="server">0</asp:Literal> entries shown
                </span>
            </div>
            <div class="mat-card__body">
                <dx:ASPxGridView ID="gvLog" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="logid" CssClass="mat-grid" ClientInstanceName="gvLog">
                    <SettingsPager PageSize="40" AlwaysShowPager="true">
                        <Summary Visible="true" Text="Page {0} of {1} ({2} items)" />
                        <PageSizeItemSettings Visible="true" Items="20, 40, 80, 150" />
                    </SettingsPager>
                    <SettingsBehavior AllowFocusedRow="true" />
                    <Settings ShowFilterRow="true" />
                    <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
                    <Columns>
                        <dx:GridViewDataDateColumn FieldName="access_date" Caption="Date / Time" VisibleIndex="0" Width="135px">
                            <PropertiesDateEdit DisplayFormatString="dd-MMM-yy HH:mm" />
                        </dx:GridViewDataDateColumn>

                        <dx:GridViewDataTextColumn FieldName="user_id" Caption="User" VisibleIndex="1" Width="120px">
                            <DataItemTemplate>
                                <span class="mat-user"><%# Eval("user_id") %></span>
                            </DataItemTemplate>
                        </dx:GridViewDataTextColumn>

                        <dx:GridViewDataTextColumn FieldName="page_function" Caption="Action" VisibleIndex="2" Width="120px">
                            <DataItemTemplate>
                                <%# GetActionBadge(Eval("page_function")) %>
                            </DataItemTemplate>
                        </dx:GridViewDataTextColumn>

                        <dx:GridViewDataTextColumn FieldName="severity" Caption="" VisibleIndex="3" Width="70px">
                            <DataItemTemplate>
                                <%# GetSeverityDot(Eval("page_function")) %>
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center" />
                        </dx:GridViewDataTextColumn>

                        <dx:GridViewDataTextColumn FieldName="par" Caption="Details" VisibleIndex="4">
                            <CellStyle Wrap="True" />
                        </dx:GridViewDataTextColumn>

                        <dx:GridViewDataTextColumn FieldName="comments" Caption="Comment" VisibleIndex="5" Width="160px">
                            <CellStyle ForeColor="#546e7a" />
                        </dx:GridViewDataTextColumn>

                        <dx:GridViewDataTextColumn FieldName="ip_address" Caption="IP" VisibleIndex="6" Width="110px">
                            <CellStyle ForeColor="#90a4ae" />
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>

                <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvLog" />
            </div>
        </div>

        <!-- RIGHT: Sidebar Panels -->
        <div>
            <!-- Top Users Panel -->
            <div class="mat-side-panel">
                <div class="mat-side-panel__head">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    Top Users (Last 30 Days)
                </div>
                <div class="mat-side-panel__body">
                    <table class="mat-top-table">
                        <thead><tr><th>#</th><th>User</th><th>Actions</th><th>Activity</th></tr></thead>
                        <tbody>
                            <asp:Repeater ID="rptTopUsers" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><span class='<%# GetRankClass(Container.ItemIndex) %>'><%# Container.ItemIndex + 1 %></span></td>
                                        <td style="font-weight:600;color:#263238;"><%# Eval("user_id") %></td>
                                        <td style="font-weight:700;"><%# Eval("cnt") %></td>
                                        <td>
                                            <div class="mat-top-bar">
                                                <div class="mat-top-bar__fill" style='width:<%# Eval("pct") %>%'></div>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Action Breakdown Panel -->
            <div class="mat-side-panel">
                <div class="mat-side-panel__head">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"/><path d="M22 12A10 10 0 0 0 12 2v10z"/></svg>
                    Action Breakdown
                </div>
                <div class="mat-side-panel__body">
                    <asp:Repeater ID="rptBreakdown" runat="server">
                        <ItemTemplate>
                            <div class="mat-action-row">
                                <span class="mat-action-row__label">
                                    <span class="mat-action-row__dot" style='background:<%# Eval("color") %>'></span>
                                    <%# Eval("label") %>
                                </span>
                                <span class="mat-action-row__count"><%# Eval("cnt") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Recent Activity (Last 5) -->
            <div class="mat-side-panel">
                <div class="mat-side-panel__head">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    Latest 5 Actions
                </div>
                <div class="mat-side-panel__body" style="padding:10px 14px;">
                    <asp:Repeater ID="rptRecent" runat="server">
                        <ItemTemplate>
                            <div style="padding:6px 0;border-bottom:1px solid #f0f0f0;font-size:11px;">
                                <div style="display:flex;justify-content:space-between;">
                                    <span class="mat-user" style="font-size:11px;"><%# Eval("user_id") %></span>
                                    <span style="color:#90a4ae;font-size:10px;"><%# Eval("time_ago") %></span>
                                </div>
                                <div style="color:#546e7a;margin-top:2px;font-size:10px;"><%# Eval("summary") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>
</div>

</asp:Content>
