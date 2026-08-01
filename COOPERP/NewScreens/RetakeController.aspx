<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="RetakeController.aspx.cs" Inherits="COOPERP_NewScreens_RetakeController" Title="Retake Registrations - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.cd-page-header { background:#fff; padding:10px 14px; margin-bottom:12px; border:1px solid #e4e8f0; display:flex; align-items:center; justify-content:space-between; gap:10px; flex-wrap:wrap; }
.cd-page-header__left { display:flex; align-items:center; gap:11px; }
.cd-page-header__icon { width:34px; height:34px; background:#05275C; display:flex; align-items:center; justify-content:center; border-radius:4px; }
.cd-page-header__title { font-size:15px; font-weight:700; color:#1a1a1a; margin:0; }
.cd-page-header__sub { font-size:11px; color:#6b7280; margin-top:1px; }
.rt-stats { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; margin-bottom:12px; }
.rt-stat { background:#fff; border:1px solid #e4e8f0; padding:10px 13px; border-radius:4px; position:relative; }
.rt-stat__v { font-size:20px; font-weight:800; color:#05275C; line-height:1.05; }
.rt-stat__l { font-size:9px; text-transform:uppercase; letter-spacing:.4px; color:#8a93a0; font-weight:700; margin-top:3px; }
.rt-stat--active .rt-stat__v { color:#b45309; } .rt-stat--done .rt-stat__v { color:#15803d; } .rt-stat--fee .rt-stat__v { font-size:15px; color:#0f766e; }
.cd-card { background:#fff; border:1px solid #e4e8f0; border-radius:4px; overflow:visible; }
.rt-tbar { padding:9px 12px; border-bottom:1px solid #eef1f5; background:#fafbfc; display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; }
.rt-fld { display:flex; flex-direction:column; gap:2px; }
.rt-fld__l { font-size:8.5px; text-transform:uppercase; letter-spacing:.5px; color:#9aa3af; font-weight:700; }
.rt-sel, .rt-in { border:1px solid #dde1e6; padding:6px 9px; font-size:11px; background:#fff; }
.rt-sel:focus, .rt-in:focus { border-color:#174DA4; outline:none; box-shadow:0 0 0 3px rgba(23,77,164,.08); }
.rt-sp { flex:1; }
.rt-count { font-size:11px; color:#174DA4; font-weight:700; background:rgba(23,77,164,.07); padding:5px 12px; }
.hr-btn { padding:6px 13px; font-size:11px; font-weight:600; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:6px; border-radius:0; }
.hr-btn--primary { background:#174DA4; color:#fff; } .hr-btn--primary:hover { background:#0f3a7d; }
.hr-btn--ghost { background:#fff; color:#555; border:1px solid #dde1e6; } .hr-btn--ghost:hover { border-color:#174DA4; color:#174DA4; }
.rt-table-wrap { overflow-x:auto; }
.rt-table { width:100%; border-collapse:collapse; }
.rt-table th { font-size:9.5px; text-transform:uppercase; letter-spacing:.4px; background:#f5f7fa; color:#667; border-bottom:2px solid #e4e8f0; padding:9px 10px; font-weight:700; white-space:nowrap; text-align:left; }
.rt-table td { font-size:11px; padding:8px 10px; border-bottom:1px solid #f2f3f5; vertical-align:middle; }
.rt-table tbody tr:hover td { background:#f0f4ff; }
.rt-name { font-weight:600; color:#1a1a2e; }
.rt-reg { font-size:10px; color:#174DA4; font-weight:600; }
.rt-rt { display:inline-block; margin-left:5px; padding:0 5px; font-size:8px; font-weight:700; color:#b45309; background:#fff3e0; border-radius:8px; }
.rt-mk { font-variant-numeric:tabular-nums; }
.rt-mk--orig { color:#94a3b8; } .rt-mk--new { color:#15803d; font-weight:700; }
.rt-empty { text-align:center; padding:44px; color:#94a3b8; font-size:12px; }
.rt-foot { padding:8px 14px; background:#fafbfc; border-top:1px solid #e4e8f0; font-size:11px; color:#666; }
@media (max-width:900px){ .rt-stats { grid-template-columns:repeat(2,1fr); } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:Button ID="btnExport" runat="server" style="display:none;" OnClick="btnExport_Click" />

<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path></svg>
        </div>
        <div>
            <div class="cd-page-header__title">Retake Registrations</div>
            <div class="cd-page-header__sub">All course retakes &mdash; original vs new marks, fee status, and marks stage</div>
        </div>
    </div>
    <button type="button" class="hr-btn hr-btn--ghost" onclick="document.getElementById('<%= btnExport.ClientID %>').click()">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
        Export CSV
    </button>
</div>

<div class="rt-stats">
    <div class="rt-stat"><div class="rt-stat__v"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="rt-stat__l">Total Retakes</div></div>
    <div class="rt-stat rt-stat--active"><div class="rt-stat__v"><asp:Literal ID="litActive" runat="server" Text="0" /></div><div class="rt-stat__l">In Progress</div></div>
    <div class="rt-stat rt-stat--done"><div class="rt-stat__v"><asp:Literal ID="litCompleted" runat="server" Text="0" /></div><div class="rt-stat__l">Completed</div></div>
    <div class="rt-stat"><div class="rt-stat__v"><asp:Literal ID="litBilled" runat="server" Text="0" /></div><div class="rt-stat__l">Fee Billed</div></div>
    <div class="rt-stat rt-stat--fee"><div class="rt-stat__v"><asp:Literal ID="litFee" runat="server" Text="UGX 0" /></div><div class="rt-stat__l">Total Retake Fees</div></div>
</div>

<div class="cd-card">
    <div class="rt-tbar">
        <div class="rt-fld">
            <span class="rt-fld__l">Search</span>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="rt-in" placeholder="Reg no, course, name" style="min-width:200px;" />
        </div>
        <div class="rt-fld">
            <span class="rt-fld__l">Retake Year</span>
            <asp:DropDownList ID="ddlYear" runat="server" CssClass="rt-sel" />
        </div>
        <div class="rt-fld">
            <span class="rt-fld__l">Semester</span>
            <asp:DropDownList ID="ddlSem" runat="server" CssClass="rt-sel">
                <asp:ListItem Value="" Text="All" /><asp:ListItem Value="1" Text="Sem 1" /><asp:ListItem Value="2" Text="Sem 2" /><asp:ListItem Value="3" Text="Sem 3" />
            </asp:DropDownList>
        </div>
        <div class="rt-fld">
            <span class="rt-fld__l">Status</span>
            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="rt-sel">
                <asp:ListItem Value="" Text="All" /><asp:ListItem Value="REGISTERED" Text="Registered" /><asp:ListItem Value="COMPLETED" Text="Completed" /><asp:ListItem Value="CANCELLED" Text="Cancelled" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" CssClass="hr-btn hr-btn--primary" Text="Filter" OnClick="btnFilter_Click" />
        <asp:Button ID="btnReset" runat="server" CssClass="hr-btn hr-btn--ghost" Text="Reset" OnClick="btnReset_Click" />
        <div class="rt-sp"></div>
        <asp:Label ID="litCount" runat="server" CssClass="rt-count" Text="0 retake(s)" />
    </div>

    <div class="rt-table-wrap">
        <table class="rt-table">
            <thead><tr>
                <th>Student</th><th>Course</th><th>Prog</th><th style="text-align:center;">Att.</th>
                <th>Original</th><th>Retake Period</th><th style="text-align:center;">Fee</th>
                <th style="text-align:center;">Marks Stage</th><th>New</th><th style="text-align:center;">Status</th><th>Registered</th>
            </tr></thead>
            <tbody>
                <asp:Repeater ID="rpt" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><div class="rt-name"><%# Server.HtmlEncode((Eval("name") ?? "").ToString().Trim()=="" ? "&mdash;" : Eval("name").ToString()) %></div><div class="rt-reg"><%# Server.HtmlEncode((Eval("regno") ?? "").ToString()) %></div></td>
                            <td><strong style="color:#05275C;"><%# Server.HtmlEncode((Eval("courseID") ?? "").ToString()) %></strong><span class="rt-rt">RT</span><div style="font-size:10px;color:#64748b;max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title='<%# Server.HtmlEncode((Eval("course_name") ?? "").ToString()) %>'><%# Server.HtmlEncode((Eval("course_name") ?? "").ToString()) %></div></td>
                            <td style="font-size:10px;color:#555;"><%# Server.HtmlEncode((Eval("prog_id") ?? "").ToString()) %></td>
                            <td style="text-align:center;font-weight:600;"><%# Eval("attempt_no") %></td>
                            <td class="rt-mk rt-mk--orig"><%# (Eval("orig_grade") ?? "").ToString()=="" ? "&mdash;" : Server.HtmlEncode(Eval("orig_grade").ToString()) %><%# Eval("orig_total")==DBNull.Value ? "" : " ("+Eval("orig_total")+")" %><div style="font-size:10px;"><%# Server.HtmlEncode((Eval("orig_acad_year") ?? "").ToString()) %></div></td>
                            <td style="font-size:11px;white-space:nowrap;"><%# Server.HtmlEncode((Eval("retake_acad_year") ?? "").ToString()) %> &middot; Sem <%# Eval("retake_semester") %></td>
                            <td style="text-align:center;"><%# (Eval("fee_billed") ?? "").ToString()=="Yes" ? "<span style='color:#15803d;font-weight:700;font-size:10px;'>BILLED</span>" : "<span style='color:#b45309;font-size:10px;'>&mdash;</span>" %></td>
                            <td style="text-align:center;"><%# StageBadge(Eval("stage")) %></td>
                            <td class="rt-mk rt-mk--new"><%# (Eval("new_grade") ?? "").ToString()=="" ? "<span style='color:#94a3b8;font-weight:400;'>pending</span>" : Server.HtmlEncode(Eval("new_grade").ToString()) %><%# Eval("new_total")==DBNull.Value ? "" : " ("+Eval("new_total")+")" %></td>
                            <td style="text-align:center;"><%# StatusBadge(Eval("status")) %></td>
                            <td style="font-size:10px;color:#888;white-space:nowrap;"><%# Server.HtmlEncode((Eval("reg_date") ?? "").ToString()) %><div><%# Server.HtmlEncode((Eval("registered_by") ?? "").ToString()) %></div></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false"><div class="rt-empty">No retake registrations match the current filters.</div></asp:Panel>
    <div class="rt-foot">Showing up to 1,000 most recent retakes. Use filters or export for the full set.</div>
</div>
</asp:Content>
