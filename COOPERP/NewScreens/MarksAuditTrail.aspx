<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksAuditTrail.aspx.cs" Inherits="COOPERP_NewScreens_MarksAuditTrail" Title="Marks Audit Trail - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== MARKS AUDIT TRAIL — mat- design system ==================== */

/* ── Shared Nav (em- = Exams Module) ── */
.em-hdr{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:12px 20px}
.em-hdr__title{font-size:15px;font-weight:700}
.em-hdr__sub{font-size:10px;opacity:.7;margin-top:1px}
.em-hdr__actions{display:flex;gap:6px;align-items:center}
.em-tabs{display:flex;gap:0;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 16px;overflow-x:auto;margin-bottom:12px}
.em-tab{padding:9px 14px;font-size:11px;font-weight:500;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;white-space:nowrap;transition:color .15s,border-color .15s}
.em-tab:hover{color:#1a237e}
.em-tab--active{color:#1a237e;border-bottom-color:#1a237e;font-weight:600}

/* ── Stats Row ── */
.mat-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:12px}
.mat-stat{background:#fff;border:1px solid #e0e5ed;padding:10px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.mat-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--c,#ccc)}
.mat-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.mat-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.mat-stat--total{--c:#1a237e}.mat-stat--total .mat-stat__val{color:#1a237e}
.mat-stat--today{--c:#2e7d32}.mat-stat--today .mat-stat__val{color:#2e7d32}
.mat-stat--week{--c:#d97706}.mat-stat--week .mat-stat__val{color:#d97706}
.mat-stat--users{--c:#6a1b9a}.mat-stat--users .mat-stat__val{color:#6a1b9a}
.mat-stat--top{--c:#00838f}.mat-stat--top .mat-stat__val{color:#00838f;font-size:12px}

/* ── Card System ── */
.mat-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:12px}
.mat-card__hdr{padding:8px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.mat-card__title{font-size:12px;font-weight:700;color:#1a237e;display:flex;align-items:center;gap:6px}
.mat-card__meta{font-size:10px;color:#1a237e;font-weight:600;background:rgba(26,35,126,.07);padding:2px 8px;border:1px solid rgba(26,35,126,.15)}

/* ── Filters (collapsible) ── */
.mat-filtbar{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px;display:none}
.mat-filtbar.show{display:block}
.mat-filtbar__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.mat-fg{display:flex;flex-direction:column;gap:3px}
.mat-fg__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.mat-fg select,.mat-fg input[type=text]{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;font-family:inherit;min-width:110px}
.mat-fg select:focus,.mat-fg input:focus{border-color:#1a237e;outline:none}

/* ── Buttons ── */
.mat-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.mat-btn--primary{background:#1a237e;color:#fff}.mat-btn--primary:hover{background:#283593}
.mat-btn--success{background:#16a34a;color:#fff}.mat-btn--success:hover{background:#15803d}
.mat-btn--ghost{background:transparent;color:#1a237e;border:1px solid #e0e5ed}.mat-btn--ghost:hover{background:#f5f7fa}
.mat-btn--sm{padding:4px 10px;font-size:10px}
.mat-btn--filter{padding:4px 10px;font-size:10px;background:#e8eaf6;border:1px solid #c5cae9;color:#1a237e;cursor:pointer}
.mat-btn--filter:hover{background:#c5cae9}
.mat-btn--filter.active{background:#1a237e;color:#fff;border-color:#1a237e}

/* ── Grid overrides ── */
.mat-grid .dxgvHeader td{background:#f5f7fa!important;font-size:10px!important;font-weight:600!important;text-transform:uppercase!important;letter-spacing:.3px;padding:9px 8px!important;color:#555!important;border-bottom:2px solid #1a237e!important;white-space:nowrap}
.mat-grid .dxgvDataRow td{font-size:11px!important;padding:7px 8px!important;border-bottom:1px solid #f0f2f5!important;vertical-align:middle!important;color:#1a1a2e}
.mat-grid .dxgvDataRow:hover td{background:#eef2fc!important}
.mat-grid .dxgvFocusedRow td{background:#c5cae9!important}
.mat-grid .dxgvDataRow:nth-child(even) td{background:#f9fafb!important}
.mat-grid .dxgvDataRow:nth-child(even):hover td{background:#eef2fc!important}

/* ── Badges ── */
.mat-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px}
.mat-badge--capture{background:#e3f2fd;color:#0d47a1;border:1px solid #90caf9}
.mat-badge--edit{background:#fffbeb;color:#92400e;border:1px solid #fcd34d}
.mat-badge--cancel{background:#fef5f5;color:#991b1b;border:1px solid #f5c6cb}
.mat-badge--autopass{background:#e6f4ea;color:#155724;border:1px solid #c3e6cb}
.mat-badge--mgmt{background:#f3e5f5;color:#4a148c;border:1px solid #ce93d8}

/* ── Severity dots ── */
.mat-sev{display:inline-flex;align-items:center;gap:4px;font-size:10px;font-weight:600}
.mat-sev__dot{width:7px;height:7px;border-radius:50%}
.mat-sev--critical .mat-sev__dot{background:#d32f2f}.mat-sev--critical{color:#d32f2f}
.mat-sev--high .mat-sev__dot{background:#f57c00}.mat-sev--high{color:#f57c00}
.mat-sev--normal .mat-sev__dot{background:#388e3c}.mat-sev--normal{color:#388e3c}

/* ── User highlight ── */
.mat-user{font-weight:700;color:#1a237e}

/* ── Two Column Layout ── */
.mat-cols{display:grid;grid-template-columns:1fr 280px;gap:12px}

/* ── Sidebar panels ── */
.mat-side{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:10px}
.mat-side__hdr{padding:8px 12px;background:#f8f9fb;border-bottom:1px solid #e0e5ed;font-size:11px;font-weight:700;color:#1a237e;display:flex;align-items:center;gap:6px}
.mat-side__body{padding:0}
.mat-side-tbl{width:100%;border-collapse:collapse}
.mat-side-tbl th{font-size:9px;text-transform:uppercase;color:#999;font-weight:600;padding:6px 10px;text-align:left;border-bottom:1px solid #e0e5ed;letter-spacing:.3px}
.mat-side-tbl td{font-size:11px;padding:6px 10px;border-bottom:1px solid #f5f5f5}
.mat-side-tbl tr:hover td{background:#f5f7fa}
.mat-rank{display:inline-flex;align-items:center;justify-content:center;width:20px;height:20px;border-radius:50%;font-size:9px;font-weight:800;color:#fff}
.mat-rank--1{background:#d97706}.mat-rank--2{background:#90a4ae}.mat-rank--3{background:#a1887f}.mat-rank--other{background:#cfd8dc;color:#546e7a}
.mat-bar{height:5px;border-radius:3px;background:#e3e8ef;overflow:hidden}
.mat-bar__fill{height:100%;border-radius:3px;background:linear-gradient(90deg,#1a237e,#3949ab)}
.mat-act-row{display:flex;justify-content:space-between;align-items:center;padding:6px 10px;border-bottom:1px solid #f5f5f5;font-size:11px}
.mat-act-row:last-child{border-bottom:none}
.mat-act-dot{width:8px;height:8px;border-radius:2px;display:inline-block;margin-right:6px}
.mat-act-cnt{font-weight:700;color:#263238}
.mat-recent{padding:5px 0;border-bottom:1px solid #f0f0f0;font-size:11px}
.mat-recent:last-child{border-bottom:none}
.mat-recent__top{display:flex;justify-content:space-between}
.mat-recent__time{color:#90a4ae;font-size:10px}
.mat-recent__desc{color:#666;margin-top:1px;font-size:10px}

/* ── Alert ── */
.mat-alert{padding:8px 14px;margin-bottom:10px;font-size:11px;border-left:3px solid;display:flex;align-items:center;gap:6px}
.mat-alert--error{border-color:#dc3545;background:#fef5f5;color:#991b1b}
.mat-alert--info{border-color:#174DA4;background:#e8f0fc;color:#0d47a1}

/* ── Responsive ── */
@media(max-width:1200px){.mat-cols{grid-template-columns:1fr}.mat-stats{grid-template-columns:repeat(3,1fr)}}
@media(max-width:768px){.mat-stats{grid-template-columns:repeat(2,1fr)}}
@media print{.em-hdr,.em-tabs{display:none!important}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Stats ── -->
<div class="mat-stats">
    <div class="mat-stat mat-stat--total">
        <div><div class="mat-stat__val"><asp:Literal ID="litTotal" runat="server">0</asp:Literal></div><div class="mat-stat__label">Total Actions</div></div>
    </div>
    <div class="mat-stat mat-stat--today">
        <div><div class="mat-stat__val"><asp:Literal ID="litToday" runat="server">0</asp:Literal></div><div class="mat-stat__label">Today</div></div>
    </div>
    <div class="mat-stat mat-stat--week">
        <div><div class="mat-stat__val"><asp:Literal ID="litWeek" runat="server">0</asp:Literal></div><div class="mat-stat__label">This Week</div></div>
    </div>
    <div class="mat-stat mat-stat--users">
        <div><div class="mat-stat__val"><asp:Literal ID="litUniqueUsers" runat="server">0</asp:Literal></div><div class="mat-stat__label">Unique Users</div></div>
    </div>
    <div class="mat-stat mat-stat--top">
        <div><div class="mat-stat__val"><asp:Literal ID="litTopUser" runat="server">—</asp:Literal></div><div class="mat-stat__label">Most Active</div></div>
    </div>
</div>

<!-- ── Alert ── -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="mat-alert mat-alert--info">
    <asp:Literal ID="litMsg" runat="server" />
</asp:Panel>

<!-- ── Main Content: Two-Column ── -->
<div class="mat-cols">
    <!-- LEFT: Grid Card -->
    <div class="mat-card">
        <div class="mat-card__hdr">
            <span class="mat-card__title">Activity Log</span>
            <div style="display:flex;gap:6px;align-items:center">
                <span class="mat-card__meta"><asp:Literal ID="litRowCount" runat="server">0</asp:Literal> entries</span>
                <button type="button" class="mat-btn--filter active" id="btnToggleFilter" onclick="toggleFilters()">Filters</button>
                <asp:Button ID="btnExportCsv" runat="server" Text="Export" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnExportCsv_Click" />
            </div>
        </div>
        <div class="mat-filtbar show" id="matFilterBar">
            <div class="mat-filtbar__row">
                <div class="mat-fg">
                    <span class="mat-fg__label">From</span>
                    <dx:ASPxDateEdit ID="dtFrom" runat="server" Width="120px" DisplayFormatString="dd-MMM-yyyy" />
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">To</span>
                    <dx:ASPxDateEdit ID="dtTo" runat="server" Width="120px" DisplayFormatString="dd-MMM-yyyy" />
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">Action Type</span>
                    <asp:DropDownList ID="ddlAction" runat="server">
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
                    <span class="mat-fg__label">User</span>
                    <asp:DropDownList ID="ddlUser" runat="server" />
                </div>
                <div class="mat-fg">
                    <span class="mat-fg__label">Student / Course</span>
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="e.g. MRU2024..." />
                </div>
                <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="mat-btn mat-btn--primary mat-btn--sm" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="mat-btn mat-btn--ghost mat-btn--sm" OnClick="btnClear_Click" />
            </div>
        </div>
        <dx:ASPxGridView ID="gvLog" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="logid" CssClass="mat-grid" ClientInstanceName="gvLog">
            <SettingsPager PageSize="100" AlwaysShowPager="true">
                <Summary Visible="true" Text="Page {0} of {1} ({2} items)" />
                <PageSizeItemSettings Visible="true" Items="50, 100, 200, 500" />
            </SettingsPager>
            <SettingsBehavior AllowFocusedRow="true" />
            <Settings ShowFilterRow="true" />
            <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
            <Columns>
                <dx:GridViewDataDateColumn FieldName="access_date" Caption="Date / Time" VisibleIndex="0" Width="130px">
                    <PropertiesDateEdit DisplayFormatString="dd-MMM-yy HH:mm" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="user_id" Caption="User" VisibleIndex="1" Width="110px">
                    <DataItemTemplate><span class="mat-user"><%# Eval("user_id") %></span></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="page_function" Caption="Action" VisibleIndex="2" Width="115px">
                    <DataItemTemplate><%# GetActionBadge(Eval("page_function")) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="page_function" Caption="" VisibleIndex="3" Width="65px">
                    <DataItemTemplate><%# GetSeverityDot(Eval("page_function")) %></DataItemTemplate>
                    <CellStyle HorizontalAlign="Center" />
                    <Settings AllowAutoFilter="False" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="student_regno" Caption="Student" VisibleIndex="4" Width="140px">
                    <DataItemTemplate><%# FormatStudent(Eval("student_regno"), Eval("student_name")) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="par" Caption="Details" VisibleIndex="5">
                    <DataItemTemplate><%# ShortenDetails(Eval("par"), Eval("page_function")) %></DataItemTemplate>
                    <CellStyle Wrap="True" />
                </dx:GridViewDataTextColumn>
            </Columns>
        </dx:ASPxGridView>
        <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvLog" />
    </div>

    <!-- RIGHT: Sidebar -->
    <div>
        <div class="mat-side">
            <div class="mat-side__hdr">Top Users (30d)</div>
            <div class="mat-side__body">
                <table class="mat-side-tbl">
                    <thead><tr><th>#</th><th>User</th><th>Cnt</th><th>Bar</th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptTopUsers" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class='<%# GetRankClass(Container.ItemIndex) %>'><%# Container.ItemIndex + 1 %></span></td>
                                    <td style="font-weight:600;color:#333"><%# Eval("user_id") %></td>
                                    <td style="font-weight:700"><%# Eval("cnt") %></td>
                                    <td><div class="mat-bar"><div class="mat-bar__fill" style='width:<%# Eval("pct") %>%'></div></div></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mat-side">
            <div class="mat-side__hdr">Action Breakdown</div>
            <div class="mat-side__body">
                <asp:Repeater ID="rptBreakdown" runat="server">
                    <ItemTemplate>
                        <div class="mat-act-row">
                            <span><span class="mat-act-dot" style='background:<%# Eval("color") %>'></span><%# Eval("label") %></span>
                            <span class="mat-act-cnt"><%# Eval("cnt") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="mat-side">
            <div class="mat-side__hdr">Latest 5 Actions</div>
            <div class="mat-side__body" style="padding:8px 10px">
                <asp:Repeater ID="rptRecent" runat="server">
                    <ItemTemplate>
                        <div class="mat-recent">
                            <div class="mat-recent__top">
                                <span class="mat-user" style="font-size:11px"><%# Eval("user_id") %></span>
                                <span class="mat-recent__time"><%# Eval("time_ago") %></span>
                            </div>
                            <div class="mat-recent__desc"><%# Eval("summary") %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
function toggleFilters(){var b=document.getElementById('matFilterBar'),t=document.getElementById('btnToggleFilter');if(b.classList.contains('show')){b.classList.remove('show');t.classList.remove('active');}else{b.classList.add('show');t.classList.add('active');}}
</script>

</asp:Content>
