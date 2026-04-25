<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ProgrammeLecturers.aspx.cs" Inherits="COOPERP_NewScreens_ProgrammeLecturers" Title="Programme Lecturers - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pl-hero { background:#05275C; color:#fff; padding:16px 18px; margin-bottom:16px; border-bottom:3px solid #041d45; }
.pl-hero__title { font-size:17px; font-weight:800; margin:0 0 4px; }
.pl-hero__sub { font-size:12px; opacity:.82; margin:0; }

.pl-stats { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-bottom:16px; }
.pl-stat { background:#fff; border:1px solid #e0e5ed; padding:14px; }
.pl-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; font-weight:700; }
.pl-stat__value { font-size:22px; color:#05275C; font-weight:800; margin-top:8px; }

.pl-card { background:#fff; border:1px solid #e0e5ed; margin-bottom:16px; }
.pl-card__head { display:flex; justify-content:space-between; align-items:center; gap:10px; padding:12px 14px; border-bottom:2px solid #e0e5ed; background:#f8fafc; }
.pl-card__title { font-size:12px; font-weight:800; color:#05275C; text-transform:uppercase; letter-spacing:.4px; }
.pl-card__body { padding:14px; }

.pl-search { width:100%; max-width:320px; border:1px solid #cfd8e3; background:#fff; padding:8px 10px; font-size:12px; color:#1f2937; }
.pl-search:focus { outline:none; border-color:#174DA4; }

.pl-detail { display:grid; grid-template-columns:1.1fr .9fr; gap:14px; }
.pl-detail__box { border:1px solid #e7ebf1; background:#fbfcfe; padding:14px; }
.pl-detail__name { font-size:18px; font-weight:800; color:#05275C; margin:0 0 4px; }
.pl-detail__meta { font-size:12px; color:#6b7280; margin-bottom:10px; }
.pl-kv { display:grid; grid-template-columns:140px 1fr; gap:8px; font-size:12px; margin-bottom:8px; }
.pl-kv__k { color:#6b7280; font-weight:700; text-transform:uppercase; font-size:10px; letter-spacing:.35px; }
.pl-kv__v { color:#1f2937; }
.pl-detail__actions { display:flex; gap:8px; flex-wrap:wrap; margin-top:12px; }
.pl-btn { display:inline-flex; align-items:center; gap:6px; padding:8px 12px; border:1px solid #d2dae6; background:#fff; color:#05275C; text-decoration:none; font-size:12px; font-weight:700; }
.pl-btn:hover { background:#f5f8ff; border-color:#174DA4; text-decoration:none; }
.pl-btn--primary { background:#05275C; border-color:#05275C; color:#fff; }
.pl-btn--primary:hover { background:#174DA4; border-color:#174DA4; color:#fff; }

.pl-table-wrap { overflow-x:auto; }
.pl-table { width:100%; border-collapse:collapse; }
.pl-table th { background:#f8fafc; border-bottom:2px solid #e0e5ed; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; padding:9px 10px; text-align:left; }
.pl-table td { border-bottom:1px solid #eef2f6; font-size:12px; color:#1f2937; padding:10px; vertical-align:top; }
.pl-table tbody tr:hover td { background:#f9fbff; }
.pl-code { font-family:Consolas,"Courier New",monospace; font-size:11px; color:#174DA4; font-weight:700; }
.pl-muted { color:#6b7280; font-size:11px; }
.pl-pill { display:inline-block; padding:3px 8px; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.35px; }
.pl-pill--academic { background:#e8f0fc; color:#174DA4; }
.pl-pill--contract { background:#edf8ef; color:#15803d; }
.pl-link { color:#174DA4; text-decoration:none; font-weight:700; }
.pl-link:hover { text-decoration:underline; }
.pl-empty { padding:20px; text-align:center; font-size:12px; color:#6b7280; }

@media (max-width: 1000px) {
    .pl-stats { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .pl-detail { grid-template-columns:1fr; }
}
</style>
<script type="text/javascript">
function filterLecturerRows() {
    var input = document.getElementById('plSearch');
    var rows = document.querySelectorAll('[data-lecturer-row]');
    var query = input ? input.value.toLowerCase() : '';
    for (var i = 0; i < rows.length; i++) {
        var text = (rows[i].getAttribute('data-search') || '').toLowerCase();
        rows[i].style.display = text.indexOf(query) >= 0 ? '' : 'none';
    }
}
</script>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pl-hero">
    <div class="pl-hero__title">Lecturers</div>
    <p class="pl-hero__sub">Read-only lecturer directory for academic programmes, with quick detail view and current teaching context.</p>
</div>

<div class="pl-stats">
    <div class="pl-stat"><div class="pl-stat__label">Academic Lecturers</div><div class="pl-stat__value"><asp:Literal ID="litTotalLecturers" runat="server" Text="0" /></div></div>
    <div class="pl-stat"><div class="pl-stat__label">With Current Load</div><div class="pl-stat__value"><asp:Literal ID="litLoadedLecturers" runat="server" Text="0" /></div></div>
    <div class="pl-stat"><div class="pl-stat__label">Full Time</div><div class="pl-stat__value"><asp:Literal ID="litFullTimeLecturers" runat="server" Text="0" /></div></div>
    <div class="pl-stat"><div class="pl-stat__label">Departments</div><div class="pl-stat__value"><asp:Literal ID="litDepartmentCount" runat="server" Text="0" /></div></div>
</div>

<asp:PlaceHolder ID="phDetail" runat="server" Visible="false">
<div class="pl-card">
    <div class="pl-card__head">
        <div class="pl-card__title">Lecturer Details</div>
        <a href="ProgrammeLecturers.aspx" class="pl-btn">Back to List</a>
    </div>
    <div class="pl-card__body">
        <asp:Literal ID="litDetail" runat="server" />
    </div>
</div>
</asp:PlaceHolder>

<div class="pl-card">
    <div class="pl-card__head">
        <div class="pl-card__title">Lecturer Directory</div>
        <input type="text" id="plSearch" class="pl-search" placeholder="Search by name, code, department, or faculty..." oninput="filterLecturerRows()" />
    </div>
    <div class="pl-card__body pl-table-wrap">
        <table class="pl-table">
            <thead>
                <tr>
                    <th>Lecturer</th>
                    <th>Department</th>
                    <th>Faculty Context</th>
                    <th>Current Load</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litRows" runat="server" />
            </tbody>
        </table>
    </div>
</div>
</asp:Content>
