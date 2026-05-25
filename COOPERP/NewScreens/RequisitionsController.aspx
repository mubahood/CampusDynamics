<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="RequisitionsController.aspx.cs" Inherits="COOPERP_NewScreens_RequisitionsController" Title="Requisitions Controller — Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*,*::before,*::after{box-sizing:border-box;}
:root{--brand:#174DA4;--brand-dark:#05275C;--border:#e0e5ed;--surface:#f5f7fa;--radius:2px;}

.rc-page{padding:20px;}

/* ── Page header ── */
.rc-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.rc-header__icon{width:44px;height:44px;border-radius:var(--radius);background:var(--brand-dark);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.rc-header__title{font-size:20px;font-weight:700;color:#1a1a2e;line-height:1.2;}
.rc-header__sub{font-size:12px;color:#888;margin-top:1px;}
.rc-header__actions{margin-left:auto;display:flex;gap:8px;}

/* ── KPI cards ── */
.rc-kpi-row{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:16px;}
@media(max-width:900px){.rc-kpi-row{grid-template-columns:repeat(3,1fr);}}
.rc-kpi{background:#fff;border:1px solid var(--border);border-left:4px solid transparent;padding:14px 16px;display:flex;align-items:center;gap:12px;}
.rc-kpi--navy{border-left-color:#05275C;}
.rc-kpi--blue{border-left-color:#174DA4;}
.rc-kpi--amber{border-left-color:#d97706;}
.rc-kpi--green{border-left-color:#16a34a;}
.rc-kpi--purple{border-left-color:#7c3aed;}
.rc-kpi__icon{width:38px;height:38px;border-radius:var(--radius);display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.rc-kpi--navy .rc-kpi__icon{background:#e8eef8;color:#05275C;}
.rc-kpi--blue .rc-kpi__icon{background:#e8eef8;color:#174DA4;}
.rc-kpi--amber .rc-kpi__icon{background:#fef3c7;color:#d97706;}
.rc-kpi--green .rc-kpi__icon{background:#dcfce7;color:#16a34a;}
.rc-kpi--purple .rc-kpi__icon{background:#f3e8ff;color:#7c3aed;}
.rc-kpi__val{font-size:20px;font-weight:700;color:#1a1a2e;line-height:1.2;}
.rc-kpi__label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.4px;}

/* ── Charts row ── */
.rc-charts{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:16px;}
@media(max-width:900px){.rc-charts{grid-template-columns:1fr;}}
.rc-chart-card{background:#fff;border:1px solid var(--border);overflow:hidden;}
.rc-chart-card__head{padding:12px 14px;border-bottom:1px solid var(--border);background:#fafbfc;}
.rc-chart-card__title{font-size:12px;font-weight:700;color:#05275C;}
.rc-chart-card__body{padding:14px;}

/* ── Filter bar ── */
.rc-filter-bar{display:flex;gap:8px;align-items:center;flex-wrap:wrap;background:#fff;border:1px solid var(--border);padding:10px 14px;margin-bottom:12px;}
.rc-search{flex:1;min-width:180px;max-width:300px;padding:6px 10px;border:1px solid var(--border);font-size:12px;}
.rc-search:focus{outline:none;border-color:#174DA4;}
.rc-select{padding:5px 8px;border:1px solid var(--border);font-size:12px;background:#fff;cursor:pointer;}
.rc-select:focus{outline:none;border-color:#174DA4;}
.rc-filter-btn{padding:5px 14px;font-size:11px;font-weight:600;background:#05275C;color:#fff;border:none;cursor:pointer;}
.rc-filter-btn:hover{background:#174DA4;}

/* ── Grid card ── */
.rc-grid-card{background:#fff;border:1px solid var(--border);overflow:hidden;}
.rc-grid-card__head{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-bottom:1px solid var(--border);background:#fafbfc;}
.rc-grid-card__title{font-size:13px;font-weight:700;color:#05275C;}
.rc-table-wrap{overflow-x:auto;}
.rc-table{width:100%;border-collapse:collapse;font-size:12px;}
.rc-table thead th{background:#05275C;color:#fff;padding:8px 12px;text-align:left;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
.rc-table tbody td{padding:8px 12px;border-bottom:1px solid #f5f7fa;color:#333;vertical-align:middle;}
.rc-table tbody tr:last-child td{border-bottom:none;}
.rc-table tbody tr:hover td{background:#f4f8ff;}
.rc-col-num{width:35px;text-align:center;color:#999;font-size:11px;}
.rc-col-amt{text-align:right;font-weight:600;color:#05275C;font-variant-numeric:tabular-nums;}
.rc-col-action{width:80px;text-align:center;}
.rc-nowrap{white-space:nowrap;}

/* ── Badges ── */
.rc-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;border-radius:2px;}
.rc-badge--draft{background:#f1f5f9;color:#64748b;}
.rc-badge--submitted{background:#dbeafe;color:#1d4ed8;}
.rc-badge--supervisor{background:#dcfce7;color:#16a34a;}
.rc-badge--bursar{background:#fef3c7;color:#d97706;}
.rc-badge--vc{background:#f3e8ff;color:#7c3aed;}
.rc-badge--procurement{background:#e0f2fe;color:#0369a1;}
.rc-badge--finance{background:#fef3c7;color:#d97706;}
.rc-badge--paid{background:#05275C;color:#fff;}
.rc-badge--pending-pay{background:#fef9c3;color:#854d0e;}
.rc-badge--returned{background:#ffedd5;color:#c2410c;}
.rc-badge--cancelled{background:#f1f5f9;color:#475569;}
.rc-badge--rejected{background:#fee2e2;color:#dc2626;}

/* ── Priority ── */
.rc-dot{width:8px;height:8px;border-radius:50%;display:inline-block;margin-right:4px;vertical-align:middle;}
.rc-dot--low{background:#94a3b8;}
.rc-dot--medium{background:#f59e0b;}
.rc-dot--high{background:#f97316;}
.rc-dot--urgent{background:#dc2626;}

/* ── Buttons ── */
.rc-btn{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;font-size:11px;font-weight:600;border:none;cursor:pointer;text-decoration:none;transition:all .15s;white-space:nowrap;}
.rc-btn--primary{background:#05275C;color:#fff;}
.rc-btn--primary:hover{background:#174DA4;color:#fff;text-decoration:none;}
.rc-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.rc-btn--outline:hover{border-color:#05275C;color:#05275C;text-decoration:none;}

.rc-empty{text-align:center;padding:40px 20px;color:#999;font-size:12px;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="rc-page">

  <!-- Header -->
  <div class="rc-header">
    <div class="rc-header__icon">
      <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"/>
        <rect x="9" y="3" width="6" height="4" rx="1"/>
        <line x1="9" y1="12" x2="15" y2="12"/><line x1="9" y1="16" x2="13" y2="16"/>
      </svg>
    </div>
    <div>
      <div class="rc-header__title">Requisitions Management</div>
      <div class="rc-header__sub">All requisitions across all departments and stages</div>
    </div>
    <div class="rc-header__actions">
      <a href="BursarRequisitions.aspx" class="rc-btn rc-btn--outline">Bursar Queue</a>
      <a href="FinanceRequisitions.aspx" class="rc-btn rc-btn--primary">Finance Queue</a>
    </div>
  </div>

  <!-- KPI Cards -->
  <div class="rc-kpi-row">
    <div class="rc-kpi rc-kpi--navy">
      <div class="rc-kpi__icon">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
        </svg>
      </div>
      <div><div class="rc-kpi__val"><asp:Literal ID="litKpiTotal" runat="server">0</asp:Literal></div><div class="rc-kpi__label">Total Requisitions</div></div>
    </div>
    <div class="rc-kpi rc-kpi--amber">
      <div class="rc-kpi__icon">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
        </svg>
      </div>
      <div><div class="rc-kpi__val"><asp:Literal ID="litKpiPipeline" runat="server">0</asp:Literal></div><div class="rc-kpi__label">In Pipeline</div></div>
    </div>
    <div class="rc-kpi rc-kpi--green">
      <div class="rc-kpi__icon">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
      <div><div class="rc-kpi__val"><asp:Literal ID="litKpiPaid" runat="server">0</asp:Literal></div><div class="rc-kpi__label">Paid Out</div></div>
    </div>
    <div class="rc-kpi rc-kpi--blue">
      <div class="rc-kpi__icon">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
        </svg>
      </div>
      <div><div class="rc-kpi__val" style="font-size:14px;"><asp:Literal ID="litKpiValue" runat="server">0</asp:Literal></div><div class="rc-kpi__label">Total Value (UGX)</div></div>
    </div>
    <div class="rc-kpi rc-kpi--purple">
      <div class="rc-kpi__icon">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <rect x="2" y="3" width="20" height="14" rx="2"/>
          <line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>
        </svg>
      </div>
      <div><div class="rc-kpi__val"><asp:Literal ID="litKpiPendingBursar" runat="server">0</asp:Literal></div><div class="rc-kpi__label">Awaiting Bursar</div></div>
    </div>
  </div>

  <!-- Charts -->
  <div class="rc-charts">
    <div class="rc-chart-card">
      <div class="rc-chart-card__head"><div class="rc-chart-card__title">By Status</div></div>
      <div class="rc-chart-card__body" style="height:200px;"><canvas id="chartStatus"></canvas></div>
    </div>
    <div class="rc-chart-card">
      <div class="rc-chart-card__head"><div class="rc-chart-card__title">By Department (Top 8)</div></div>
      <div class="rc-chart-card__body" style="height:200px;"><canvas id="chartDept"></canvas></div>
    </div>
    <div class="rc-chart-card">
      <div class="rc-chart-card__head"><div class="rc-chart-card__title">By Type</div></div>
      <div class="rc-chart-card__body" style="height:200px;"><canvas id="chartType"></canvas></div>
    </div>
  </div>

  <!-- Filter bar -->
  <form method="get" action="" class="rc-filter-bar">
    <input type="text" name="q" class="rc-search" value="<%= HttpUtility.HtmlEncode(Request.QueryString["q"] ?? "") %>" placeholder="Search req. no., title, requester..." />
    <select name="status" class="rc-select">
      <option value="">All Statuses</option>
      <option value="SUBMITTED" <%= Sel("SUBMITTED") %>>Awaiting Supervisor</option>
      <option value="SUPERVISOR_APPROVED" <%= Sel("SUPERVISOR_APPROVED") %>>Bursar Queue</option>
      <option value="BURSAR_REVIEW" <%= Sel("BURSAR_REVIEW") %>>Bursar Review</option>
      <option value="VC_PENDING" <%= Sel("VC_PENDING") %>>VC Pending</option>
      <option value="PROCUREMENT" <%= Sel("PROCUREMENT") %>>Procurement</option>
      <option value="FINANCE_REVIEW" <%= Sel("FINANCE_REVIEW") %>>Finance Review</option>
      <option value="PAID_OUT" <%= Sel("PAID_OUT") %>>Paid Out</option>
      <option value="RETURNED" <%= Sel("RETURNED") %>>Returned</option>
      <option value="CANCELLED" <%= Sel("CANCELLED") %>>Cancelled</option>
    </select>
    <select name="req_type" class="rc-select">
      <option value="">All Types</option>
      <option value="GOODS" <%= SelType("GOODS") %>>Goods</option>
      <option value="SERVICES" <%= SelType("SERVICES") %>>Services</option>
      <option value="WORKS" <%= SelType("WORKS") %>>Works</option>
      <option value="TRAVEL" <%= SelType("TRAVEL") %>>Travel</option>
      <option value="MAINTENANCE" <%= SelType("MAINTENANCE") %>>Maintenance</option>
      <option value="OTHER" <%= SelType("OTHER") %>>Other</option>
    </select>
    <button type="submit" class="rc-filter-btn">Filter</button>
    <a href="RequisitionsController.aspx" class="rc-btn rc-btn--outline">Reset</a>
  </form>

  <!-- Master grid -->
  <div class="rc-grid-card">
    <div class="rc-grid-card__head">
      <div class="rc-grid-card__title">All Requisitions — <asp:Literal ID="litTotalCount" runat="server">0</asp:Literal> records</div>
    </div>
    <div class="rc-table-wrap">
      <table class="rc-table">
        <thead>
          <tr>
            <th class="rc-col-num">#</th>
            <th>Req No.</th>
            <th>Title</th>
            <th>Requester / Dept</th>
            <th>Type</th>
            <th>Priority</th>
            <th class="rc-col-amt">Amount (UGX)</th>
            <th>Status</th>
            <th class="rc-nowrap">Date</th>
            <th class="rc-col-action">Action</th>
          </tr>
        </thead>
        <tbody>
          <asp:Literal ID="litGridRows" runat="server" />
        </tbody>
      </table>
    </div>
  </div>

</div>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<asp:HiddenField ID="hfStatusLabels" runat="server" />
<asp:HiddenField ID="hfStatusValues" runat="server" />
<asp:HiddenField ID="hfDeptLabels"   runat="server" />
<asp:HiddenField ID="hfDeptValues"   runat="server" />
<asp:HiddenField ID="hfTypeLabels"   runat="server" />
<asp:HiddenField ID="hfTypeValues"   runat="server" />

<script>
(function() {
    function gv(id) { var el = document.getElementById(id); return el ? el.value : ''; }
    function parse(v) { try { return JSON.parse(v); } catch(e) { return []; } }

    var statusLabels = parse(gv('<%= hfStatusLabels.ClientID %>'));
    var statusValues = parse(gv('<%= hfStatusValues.ClientID %>'));
    var deptLabels   = parse(gv('<%= hfDeptLabels.ClientID %>'));
    var deptValues   = parse(gv('<%= hfDeptValues.ClientID %>'));
    var typeLabels   = parse(gv('<%= hfTypeLabels.ClientID %>'));
    var typeValues   = parse(gv('<%= hfTypeValues.ClientID %>'));

    var palette = ['#05275C','#174DA4','#16a34a','#d97706','#7c3aed','#0369a1','#dc2626','#0891b2','#f59e0b','#64748b'];

    if (statusLabels.length > 0) {
        new Chart(document.getElementById('chartStatus'), {
            type: 'doughnut',
            data: { labels: statusLabels, datasets: [{ data: statusValues, backgroundColor: palette }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 10 }, boxWidth: 10 } } } }
        });
    }

    if (deptLabels.length > 0) {
        new Chart(document.getElementById('chartDept'), {
            type: 'bar',
            data: { labels: deptLabels, datasets: [{ label: 'Requisitions', data: deptValues, backgroundColor: '#174DA4' }] },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { ticks: { font: { size: 10 } } }, y: { ticks: { font: { size: 10 } } } } }
        });
    }

    if (typeLabels.length > 0) {
        new Chart(document.getElementById('chartType'), {
            type: 'doughnut',
            data: { labels: typeLabels, datasets: [{ data: typeValues, backgroundColor: palette }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 10 }, boxWidth: 10 } } } }
        });
    }
})();
</script>
</asp:Content>
