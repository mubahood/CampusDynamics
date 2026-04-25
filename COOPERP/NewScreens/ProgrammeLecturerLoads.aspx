<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ProgrammeLecturerLoads.aspx.cs" Inherits="COOPERP_NewScreens_ProgrammeLecturerLoads" Title="Programme Lecturer Loads - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pll-hero { background:#05275C; color:#fff; padding:16px 18px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; justify-content:space-between; gap:16px; flex-wrap:wrap; }
.pll-hero__title { font-size:17px; font-weight:800; margin:0 0 4px; }
.pll-hero__sub { font-size:12px; opacity:.82; margin:0; }
.pll-hero__period { background:rgba(255,255,255,.12); padding:10px 12px; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }

.pll-stats { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-bottom:16px; }
.pll-stat { background:#fff; border:1px solid #e0e5ed; padding:14px; }
.pll-stat__label { font-size:10px; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; font-weight:700; }
.pll-stat__value { font-size:22px; font-weight:800; color:#05275C; margin-top:8px; }

.pll-card { background:#fff; border:1px solid #e0e5ed; margin-bottom:16px; }
.pll-card__head { display:flex; justify-content:space-between; align-items:center; gap:10px; padding:12px 14px; border-bottom:2px solid #e0e5ed; background:#f8fafc; }
.pll-card__title { font-size:12px; font-weight:800; color:#05275C; text-transform:uppercase; letter-spacing:.4px; }
.pll-card__sub { color:#6b7280; font-size:11px; margin-top:4px; }
.pll-card__body { padding:14px; }
.pll-search { width:100%; max-width:320px; border:1px solid #cfd8e3; background:#fff; padding:8px 10px; font-size:12px; color:#1f2937; }
.pll-search:focus { outline:none; border-color:#174DA4; }

.pll-table-wrap { overflow-x:auto; }
.pll-table { width:100%; border-collapse:collapse; }
.pll-table th { background:#f8fafc; border-bottom:2px solid #e0e5ed; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.45px; color:#6b7280; padding:9px 10px; text-align:left; }
.pll-table td { border-bottom:1px solid #eef2f6; font-size:12px; color:#1f2937; padding:10px; vertical-align:top; }
.pll-table tbody tr:hover td { background:#f9fbff; }
.pll-code { font-family:Consolas,"Courier New",monospace; font-size:11px; color:#174DA4; font-weight:700; }
.pll-pill { display:inline-block; padding:3px 8px; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:.35px; background:#e8f0fc; color:#174DA4; }
.pll-muted { color:#6b7280; font-size:11px; }
.pll-link { color:#174DA4; text-decoration:none; font-weight:700; }
.pll-link:hover { text-decoration:underline; }
.pll-chip-wrap { display:flex; flex-wrap:wrap; gap:6px; margin-top:7px; }
.pll-chip { display:inline-block; font-size:10px; font-weight:700; color:#174DA4; background:#eef4ff; border:1px solid #d6e3fb; padding:3px 7px; border-radius:999px; max-width:260px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.pll-chip--more { color:#4b5563; background:#f3f4f6; border-color:#e5e7eb; }

.pll-detail { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
.pll-box { border:1px solid #e7ebf1; background:#fbfcfe; padding:14px; }
.pll-kv { display:grid; grid-template-columns:150px 1fr; gap:8px; margin-bottom:8px; }
.pll-kv__k { color:#6b7280; font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.35px; }
.pll-kv__v { color:#1f2937; font-size:12px; }
.pll-empty { padding:20px; text-align:center; color:#6b7280; font-size:12px; }
.pll-rowcard { border:1px solid #e7ebf1; background:#fff; padding:10px 12px; margin-bottom:8px; }

@media (max-width: 1000px) {
    .pll-stats { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .pll-detail { grid-template-columns:1fr; }
}
</style>
<script type="text/javascript">
function filterLoadRows() {
    var input = document.getElementById('pllSearch');
    var rows = document.querySelectorAll('[data-load-row]');
    var query = input ? input.value.toLowerCase() : '';
    for (var i = 0; i < rows.length; i++) {
        var text = (rows[i].getAttribute('data-search') || '').toLowerCase();
        rows[i].style.display = text.indexOf(query) >= 0 ? '' : 'none';
    }
}
</script>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pll-hero">
    <div>
        <div class="pll-hero__title">Lecturer Loads</div>
        <p class="pll-hero__sub">Read-only summary of lecturer workloads and current semester teaching allocations.</p>
    </div>
    <div class="pll-hero__period"><asp:Literal ID="litCurrentPeriod" runat="server" /></div>
</div>

<div class="pll-stats">
    <div class="pll-stat"><div class="pll-stat__label">Lecturers</div><div class="pll-stat__value"><asp:Literal ID="litLecturerCount" runat="server" Text="0" /></div></div>
    <div class="pll-stat"><div class="pll-stat__label">With Load</div><div class="pll-stat__value"><asp:Literal ID="litLecturersWithLoad" runat="server" Text="0" /></div></div>
    <div class="pll-stat"><div class="pll-stat__label">Allocated Courses</div><div class="pll-stat__value"><asp:Literal ID="litAllocatedCourses" runat="server" Text="0" /></div></div>
    <div class="pll-stat"><div class="pll-stat__label">Scheduled Hours</div><div class="pll-stat__value"><asp:Literal ID="litScheduledHours" runat="server" Text="0" /></div></div>
</div>

<asp:PlaceHolder ID="phDetail" runat="server" Visible="false">
<div class="pll-card">
    <div class="pll-card__head">
        <div class="pll-card__title">Lecturer Load Details</div>
        <a href="ProgrammeLecturerLoads.aspx" class="pll-link">Back to List</a>
    </div>
    <div class="pll-card__body">
        <asp:Literal ID="litDetail" runat="server" />
    </div>
</div>
</asp:PlaceHolder>

<div class="pll-card">
    <div class="pll-card__head">
        <div>
            <div class="pll-card__title">Current Semester Summary</div>
            <div class="pll-card__sub">Shows each lecturer with the exact courses currently assigned in this semester.</div>
        </div>
        <input type="text" id="pllSearch" class="pll-search" placeholder="Search by lecturer, course, programme, faculty, or code..." oninput="filterLoadRows()" />
    </div>
    <div class="pll-card__body pll-table-wrap">
        <table class="pll-table">
            <thead>
                <tr>
                    <th>Lecturer</th>
                    <th>Courses on Lecturer</th>
                    <th>Programme Coverage</th>
                    <th>Hours</th>
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
