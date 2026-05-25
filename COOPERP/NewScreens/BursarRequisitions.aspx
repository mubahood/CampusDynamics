<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BursarRequisitions.aspx.cs" Inherits="COOPERP_NewScreens_BursarRequisitions" Title="Bursar — Requisitions | Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
*,*::before,*::after{box-sizing:border-box;}
:root{--brand:#174DA4;--brand-dark:#05275C;--border:#e0e5ed;--surface:#f5f7fa;}

.bq-page{padding:20px;}

.bq-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.bq-header__icon{width:44px;height:44px;background:var(--brand-dark);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.bq-header__title{font-size:20px;font-weight:700;color:#1a1a2e;}
.bq-header__sub{font-size:12px;color:#888;margin-top:1px;}
.bq-header__actions{margin-left:auto;display:flex;gap:8px;}

.bq-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:16px;}
@media(max-width:800px){.bq-stats{grid-template-columns:repeat(2,1fr);}}
.bq-stat{background:#fff;border:1px solid var(--border);border-top:3px solid transparent;padding:12px 14px;}
.bq-stat--amber{border-top-color:#d97706;}
.bq-stat--green{border-top-color:#16a34a;}
.bq-stat--purple{border-top-color:#7c3aed;}
.bq-stat--blue{border-top-color:#174DA4;}
.bq-stat__val{font-size:22px;font-weight:700;color:#1a1a2e;}
.bq-stat__label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-top:3px;}

.bq-tabs{display:flex;border-bottom:2px solid var(--border);margin-bottom:16px;gap:0;overflow-x:auto;}
.bq-tab{padding:10px 18px;font-size:12px;font-weight:600;color:#888;cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-2px;background:none;border-top:none;border-left:none;border-right:none;display:flex;align-items:center;gap:6px;white-space:nowrap;transition:all .15s;}
.bq-tab:hover{color:var(--brand-dark);}
.bq-tab.is-active{color:var(--brand-dark);border-bottom-color:var(--brand-dark);}
.bq-tab__badge{display:inline-flex;align-items:center;justify-content:center;min-width:18px;height:18px;border-radius:9px;background:#e0e5ed;color:#555;font-size:10px;font-weight:700;padding:0 5px;}
.bq-tab.is-active .bq-tab__badge{background:#dc2626;color:#fff;}

.bq-panel{display:none;}
.bq-panel.is-active{display:block;}

.bq-card{background:#fff;border:1px solid var(--border);overflow:hidden;margin-bottom:14px;}
.bq-table-wrap{overflow-x:auto;}
.bq-table{width:100%;border-collapse:collapse;font-size:12px;}
.bq-table thead th{background:var(--brand-dark);color:#fff;padding:8px 12px;text-align:left;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
.bq-table tbody td{padding:9px 12px;border-bottom:1px solid #f5f7fa;color:#333;vertical-align:middle;}
.bq-table tbody tr:last-child td{border-bottom:none;}
.bq-table tbody tr:hover td{background:#f4f8ff;}
.bq-col-num{width:35px;text-align:center;color:#999;font-size:11px;}
.bq-col-amt{text-align:right;font-weight:600;color:var(--brand-dark);}
.bq-col-action{width:120px;text-align:right;}
.bq-nowrap{white-space:nowrap;}
.bq-sub{font-size:10px;color:#999;}

.bq-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:700;text-transform:uppercase;border-radius:2px;}
.bq-badge--pending{background:#dbeafe;color:#1d4ed8;}
.bq-badge--approved{background:#dcfce7;color:#16a34a;}
.bq-badge--vc{background:#f3e8ff;color:#7c3aed;}
.bq-badge--procurement{background:#e0f2fe;color:#0369a1;}
.bq-badge--rejected{background:#fee2e2;color:#dc2626;}

.bq-priority{display:inline-flex;align-items:center;gap:4px;font-size:11px;}
.bq-priority__dot{width:7px;height:7px;border-radius:50%;}
.bq-priority--low .bq-priority__dot{background:#94a3b8;}
.bq-priority--medium .bq-priority__dot{background:#f59e0b;}
.bq-priority--high .bq-priority__dot{background:#f97316;}
.bq-priority--urgent .bq-priority__dot{background:#dc2626;animation:bq-pulse 1.5s infinite;}
@keyframes bq-pulse{0%,100%{opacity:1;}50%{opacity:.4;}}

.bq-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 12px;font-size:11px;font-weight:600;border:none;cursor:pointer;text-decoration:none;transition:all .15s;white-space:nowrap;}
.bq-btn--primary{background:var(--brand-dark);color:#fff;}
.bq-btn--primary:hover{background:var(--brand);color:#fff;text-decoration:none;}
.bq-btn--success{background:#16a34a;color:#fff;}
.bq-btn--success:hover{background:#15803d;color:#fff;text-decoration:none;}
.bq-btn--danger{background:#dc2626;color:#fff;}
.bq-btn--danger:hover{background:#b91c1c;color:#fff;text-decoration:none;}
.bq-btn--purple{background:#7c3aed;color:#fff;}
.bq-btn--purple:hover{background:#6d28d9;color:#fff;text-decoration:none;}
.bq-btn--sky{background:#0369a1;color:#fff;}
.bq-btn--sky:hover{background:#0284c7;color:#fff;text-decoration:none;}
.bq-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.bq-btn--outline:hover{border-color:var(--brand-dark);color:var(--brand-dark);text-decoration:none;}
.bq-btn--sm{padding:3px 8px;font-size:10px;}
.bq-btn--xs{padding:2px 6px;font-size:10px;}

.bq-empty{text-align:center;padding:48px 20px;color:#999;font-size:12px;}

/* ── Decision Modal ── */
.bq-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;}
.bq-overlay.is-open{display:flex;}
.bq-modal{background:#fff;border:1px solid var(--border);width:100%;max-width:560px;margin:20px;border-radius:2px;max-height:90vh;overflow-y:auto;}
.bq-modal__head{display:flex;align-items:center;justify-content:space-between;padding:14px 18px;border-bottom:1px solid var(--border);background:#fafbfc;position:sticky;top:0;z-index:1;}
.bq-modal__title{font-size:14px;font-weight:700;color:var(--brand-dark);}
.bq-modal__close{background:none;border:none;font-size:18px;cursor:pointer;color:#888;}
.bq-modal__body{padding:18px;}
.bq-modal__footer{display:flex;gap:8px;justify-content:flex-end;padding:12px 18px;border-top:1px solid var(--border);background:#fafbfc;flex-wrap:wrap;}

.bq-field{margin-bottom:14px;}
.bq-label{display:block;font-size:10px;font-weight:700;color:#555;text-transform:uppercase;letter-spacing:.4px;margin-bottom:5px;}
.bq-textarea{width:100%;border:1px solid var(--border);padding:8px 10px;font-size:12px;font-family:inherit;resize:vertical;min-height:70px;box-sizing:border-box;}
.bq-textarea:focus{outline:none;border-color:var(--brand-dark);}
.bq-select{width:100%;border:1px solid var(--border);padding:7px 10px;font-size:12px;background:#fff;box-sizing:border-box;}
.bq-select:focus{outline:none;border-color:var(--brand-dark);}

.bq-route-opts{display:flex;gap:10px;flex-wrap:wrap;margin-top:4px;}
.bq-route-opt{flex:1;min-width:140px;border:2px solid var(--border);padding:10px 12px;cursor:pointer;transition:all .15s;}
.bq-route-opt:hover{border-color:var(--brand);}
.bq-route-opt.selected{border-color:var(--brand-dark);background:#e8eef8;}
.bq-route-opt__icon{font-size:18px;margin-bottom:4px;}
.bq-route-opt__label{font-size:11px;font-weight:700;color:var(--brand-dark);}
.bq-route-opt__desc{font-size:10px;color:#888;margin-top:2px;}

.bq-info-row{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:12px;}
.bq-info-item{background:#f8fafc;border:1px solid var(--border);padding:8px 10px;}
.bq-info-item__label{font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-bottom:2px;}
.bq-info-item__val{font-size:12px;font-weight:600;color:#1a1a2e;}

.bq-items-mini{margin-bottom:12px;}
.bq-items-mini table{width:100%;border-collapse:collapse;font-size:11px;}
.bq-items-mini th{background:#f0f4f8;padding:5px 8px;text-align:left;font-size:10px;color:#888;font-weight:600;text-transform:uppercase;}
.bq-items-mini td{padding:4px 8px;border-bottom:1px solid #f5f7fa;color:#333;}
.bq-items-mini .td-amt{text-align:right;font-weight:600;}
.bq-grand{background:var(--brand-dark);color:#fff;text-align:right;padding:6px 8px;font-size:12px;font-weight:700;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="bq-page">

  <div class="bq-header">
    <div class="bq-header__icon">
      <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
      </svg>
    </div>
    <div>
      <div class="bq-header__title">Bursar — Requisitions Queue</div>
      <div class="bq-header__sub">Review, approve, escalate or route requisitions to Finance, VC or Procurement</div>
    </div>
    <div class="bq-header__actions">
      <a href="RequisitionsController.aspx" class="bq-btn bq-btn--outline">Master View</a>
    </div>
  </div>

  <div class="bq-stats">
    <div class="bq-stat bq-stat--amber">
      <div class="bq-stat__val"><asp:Literal ID="litCntAwaiting" runat="server">0</asp:Literal></div>
      <div class="bq-stat__label">Awaiting Decision</div>
    </div>
    <div class="bq-stat bq-stat--purple">
      <div class="bq-stat__val"><asp:Literal ID="litCntVcPending" runat="server">0</asp:Literal></div>
      <div class="bq-stat__label">Escalated to VC</div>
    </div>
    <div class="bq-stat bq-stat--blue">
      <div class="bq-stat__val"><asp:Literal ID="litCntProcurement" runat="server">0</asp:Literal></div>
      <div class="bq-stat__label">In Procurement</div>
    </div>
    <div class="bq-stat bq-stat--green">
      <div class="bq-stat__val"><asp:Literal ID="litCntApproved" runat="server">0</asp:Literal></div>
      <div class="bq-stat__label">Approved (This Month)</div>
    </div>
  </div>

  <div class="bq-tabs">
    <button class="bq-tab is-active" onclick="bqTab(this,'pending')">
      Awaiting Decision <span class="bq-tab__badge"><asp:Literal ID="litTabPending" runat="server">0</asp:Literal></span>
    </button>
    <button class="bq-tab" onclick="bqTab(this,'vc')">
      VC Pending <span class="bq-tab__badge" style="background:#f3e8ff;color:#7c3aed;"><asp:Literal ID="litTabVc" runat="server">0</asp:Literal></span>
    </button>
    <button class="bq-tab" onclick="bqTab(this,'procurement')">
      Procurement <span class="bq-tab__badge" style="background:#e0f2fe;color:#0369a1;"><asp:Literal ID="litTabProcurement" runat="server">0</asp:Literal></span>
    </button>
    <button class="bq-tab" onclick="bqTab(this,'history')">
      History <span class="bq-tab__badge" style="background:#e0e5ed;color:#555;"><asp:Literal ID="litTabHistory" runat="server">0</asp:Literal></span>
    </button>
  </div>

  <!-- Pending -->
  <div id="tab-pending" class="bq-panel is-active">
    <div class="bq-card">
      <div class="bq-table-wrap">
        <table class="bq-table">
          <thead><tr>
            <th class="bq-col-num">#</th><th>Req No.</th><th>Requester / Dept</th>
            <th>Title / Type</th><th>Priority</th>
            <th class="bq-col-amt">Amount (UGX)</th>
            <th class="bq-nowrap">Supervisor</th><th class="bq-nowrap">Date</th>
            <th class="bq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litPendingRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- VC Pending -->
  <div id="tab-vc" class="bq-panel">
    <div class="bq-card">
      <div class="bq-table-wrap">
        <table class="bq-table">
          <thead><tr>
            <th class="bq-col-num">#</th><th>Req No.</th><th>Requester</th><th>Title</th>
            <th class="bq-col-amt">Amount (UGX)</th>
            <th>Escalated On</th><th class="bq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litVcRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Procurement -->
  <div id="tab-procurement" class="bq-panel">
    <div class="bq-card">
      <div class="bq-table-wrap">
        <table class="bq-table">
          <thead><tr>
            <th class="bq-col-num">#</th><th>Req No.</th><th>Requester</th><th>Title</th>
            <th class="bq-col-amt">Amount (UGX)</th>
            <th>LPO No.</th><th>Status</th><th class="bq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litProcurementRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- History -->
  <div id="tab-history" class="bq-panel">
    <div class="bq-card">
      <div class="bq-table-wrap">
        <table class="bq-table">
          <thead><tr>
            <th class="bq-col-num">#</th><th>Req No.</th><th>Requester</th><th>Title</th>
            <th class="bq-col-amt">Amount (UGX)</th>
            <th>Decision</th><th>Route</th><th class="bq-nowrap">Date</th><th class="bq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litHistoryRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

</div>

<!-- Decision Modal -->
<div class="bq-overlay" id="bqOverlay">
  <div class="bq-modal">
    <div class="bq-modal__head">
      <div class="bq-modal__title" id="bqModalTitle">Review Requisition</div>
      <button class="bq-modal__close" onclick="closeModal()">✕</button>
    </div>
    <div class="bq-modal__body">
      <!-- Summary info -->
      <div class="bq-info-row" id="bqInfoRow"></div>
      <!-- Items -->
      <div class="bq-items-mini" id="bqItemsMini"></div>
      <!-- Route selector -->
      <div class="bq-field">
        <div class="bq-label">Route To <span style="color:#dc2626;">*</span></div>
        <div class="bq-route-opts">
          <div class="bq-route-opt selected" id="routeFinance" onclick="selectRoute('FINANCE')">
            <div class="bq-route-opt__icon">💰</div>
            <div class="bq-route-opt__label">Finance</div>
            <div class="bq-route-opt__desc">Approve directly, send to Finance for payment</div>
          </div>
          <div class="bq-route-opt" id="routeVC" onclick="selectRoute('VC')">
            <div class="bq-route-opt__icon">🏛</div>
            <div class="bq-route-opt__label">Vice Chancellor</div>
            <div class="bq-route-opt__desc">Escalate for VC approval (large/strategic amounts)</div>
          </div>
          <div class="bq-route-opt" id="routeProcurement" onclick="selectRoute('PROCUREMENT')">
            <div class="bq-route-opt__icon">📦</div>
            <div class="bq-route-opt__label">Procurement</div>
            <div class="bq-route-opt__desc">Route to Procurement section for sourcing &amp; LPO</div>
          </div>
        </div>
      </div>
      <!-- Remarks -->
      <div class="bq-field">
        <label class="bq-label">Remarks / Comments</label>
        <textarea class="bq-textarea" id="bqRemarks" rows="3" placeholder="Optional remarks for the decision..."></textarea>
      </div>
    </div>
    <div class="bq-modal__footer">
      <button class="bq-btn bq-btn--outline" onclick="closeModal()">Cancel</button>
      <button class="bq-btn bq-btn--danger" onclick="submitBursarAction('return')">↩ Return</button>
      <button class="bq-btn bq-btn--success" onclick="submitBursarAction('approve')">✓ Approve &amp; Route</button>
    </div>
  </div>
</div>

<script>
var _bqReqId   = 0;
var _bqRoute   = 'FINANCE';
var _csrfToken = (document.querySelector('meta[name="csrf-token"]') || {}).content || '';

function bqTab(el, name) {
    document.querySelectorAll('.bq-tab').forEach(function(t) { t.classList.remove('is-active'); });
    document.querySelectorAll('.bq-panel').forEach(function(p) { p.classList.remove('is-active'); });
    el.classList.add('is-active');
    var panel = document.getElementById('tab-' + name);
    if (panel) panel.classList.add('is-active');
}

function selectRoute(route) {
    _bqRoute = route;
    ['routeFinance','routeVC','routeProcurement'].forEach(function(id) {
        document.getElementById(id).classList.remove('selected');
    });
    var map = { FINANCE: 'routeFinance', VC: 'routeVC', PROCUREMENT: 'routeProcurement' };
    if (map[route]) document.getElementById(map[route]).classList.add('selected');
}

function openBursarModal(reqId, reqNo, requester, dept, supvName, amount, priority, itemsJson) {
    _bqReqId  = reqId;
    _bqRoute  = 'FINANCE';
    selectRoute('FINANCE');
    document.getElementById('bqModalTitle').textContent = 'Bursar Decision: ' + reqNo;
    document.getElementById('bqRemarks').value = '';

    document.getElementById('bqInfoRow').innerHTML =
        '<div class="bq-info-item"><div class="bq-info-item__label">Requester</div><div class="bq-info-item__val">' + esc(requester) + '</div></div>' +
        '<div class="bq-info-item"><div class="bq-info-item__label">Department</div><div class="bq-info-item__val">' + esc(dept) + '</div></div>' +
        '<div class="bq-info-item"><div class="bq-info-item__label">Supervisor Approved By</div><div class="bq-info-item__val">' + esc(supvName) + '</div></div>' +
        '<div class="bq-info-item"><div class="bq-info-item__label">Total Amount</div><div class="bq-info-item__val">UGX ' + fmt(amount) + '</div></div>';

    var items = [];
    try { items = JSON.parse(itemsJson); } catch(e) {}
    var html = '';
    if (items.length > 0) {
        html = '<table><thead><tr><th>#</th><th>Description</th><th>Qty</th><th>Unit Price</th><th class="td-amt">Total (UGX)</th></tr></thead><tbody>';
        var grand = 0;
        items.forEach(function(it, i) {
            var tot = parseFloat(it.total) || 0; grand += tot;
            html += '<tr><td>' + (i+1) + '</td><td>' + esc(it.desc) + '</td><td>' + (it.qty||0) + ' ' + esc(it.unit||'pcs') + '</td><td>' + fmt(it.price||0) + '</td><td class="td-amt">' + fmt(tot) + '</td></tr>';
        });
        html += '</tbody></table><div class="bq-grand">GRAND TOTAL: UGX ' + fmt(grand) + '</div>';
    }
    document.getElementById('bqItemsMini').innerHTML = html;
    document.getElementById('bqOverlay').classList.add('is-open');
}

function closeModal() {
    document.getElementById('bqOverlay').classList.remove('is-open');
    _bqReqId = 0;
}

function submitBursarAction(action) {
    var remarks = (document.getElementById('bqRemarks').value || '').trim();
    if (action === 'return' && !remarks) { alert('Please provide remarks explaining the reason for returning.'); return; }
    if (action === 'approve') {
        var routeLabel = { FINANCE: 'Finance', VC: 'Vice Chancellor', PROCUREMENT: 'Procurement' }[_bqRoute] || _bqRoute;
        if (!confirm('Approve and route to ' + routeLabel + '?')) return;
    }

    fetch(window.location.pathname + '?ajax=action', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
        body: JSON.stringify({ req_id: _bqReqId, action: action, route: _bqRoute, remarks: remarks })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res.ok) { window.location.reload(); }
        else { alert('Error: ' + (res.error || 'Unknown error')); }
    })
    .catch(function() { alert('Network error. Please try again.'); });
}

function esc(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; }
function fmt(n) { return Math.round(parseFloat(n)||0).toLocaleString('en-UG'); }
</script>
</asp:Content>
