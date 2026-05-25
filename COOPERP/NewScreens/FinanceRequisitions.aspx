<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FinanceRequisitions.aspx.cs" Inherits="COOPERP_NewScreens_FinanceRequisitions" Title="Finance — Requisitions | Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
*,*::before,*::after{box-sizing:border-box;}
:root{--brand:#174DA4;--brand-dark:#05275C;--border:#e0e5ed;--green:#16a34a;}

.fq-page{padding:20px;}

.fq-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.fq-header__icon{width:44px;height:44px;background:var(--green);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.fq-header__title{font-size:20px;font-weight:700;color:#1a1a2e;}
.fq-header__sub{font-size:12px;color:#888;margin-top:1px;}
.fq-header__actions{margin-left:auto;display:flex;gap:8px;}

.fq-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:16px;}
@media(max-width:800px){.fq-stats{grid-template-columns:repeat(2,1fr);}}
.fq-stat{background:#fff;border:1px solid var(--border);border-top:3px solid transparent;padding:12px 14px;}
.fq-stat--green{border-top-color:#16a34a;}
.fq-stat--amber{border-top-color:#d97706;}
.fq-stat--blue{border-top-color:#174DA4;}
.fq-stat--navy{border-top-color:#05275C;}
.fq-stat__val{font-size:20px;font-weight:700;color:#1a1a2e;line-height:1.2;}
.fq-stat__label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-top:3px;}

.fq-tabs{display:flex;border-bottom:2px solid var(--border);margin-bottom:16px;gap:0;overflow-x:auto;}
.fq-tab{padding:10px 18px;font-size:12px;font-weight:600;color:#888;cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-2px;background:none;border-top:none;border-left:none;border-right:none;display:flex;align-items:center;gap:6px;white-space:nowrap;transition:all .15s;}
.fq-tab:hover{color:var(--brand-dark);}
.fq-tab.is-active{color:var(--brand-dark);border-bottom-color:var(--brand-dark);}
.fq-tab__badge{display:inline-flex;align-items:center;justify-content:min-width:18px;height:18px;border-radius:9px;background:#e0e5ed;color:#555;font-size:10px;font-weight:700;padding:0 5px;}
.fq-tab.is-active .fq-tab__badge{background:#dc2626;color:#fff;}

.fq-panel{display:none;}
.fq-panel.is-active{display:block;}

.fq-card{background:#fff;border:1px solid var(--border);overflow:hidden;margin-bottom:14px;}
.fq-table-wrap{overflow-x:auto;}
.fq-table{width:100%;border-collapse:collapse;font-size:12px;}
.fq-table thead th{background:var(--green);color:#fff;padding:8px 12px;text-align:left;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
.fq-table tbody td{padding:9px 12px;border-bottom:1px solid #f5f7fa;color:#333;vertical-align:middle;}
.fq-table tbody tr:last-child td{border-bottom:none;}
.fq-table tbody tr:hover td{background:#f0fff8;}
.fq-col-num{width:35px;text-align:center;color:#999;font-size:11px;}
.fq-col-amt{text-align:right;font-weight:700;color:var(--brand-dark);}
.fq-col-action{width:120px;text-align:right;}
.fq-nowrap{white-space:nowrap;}
.fq-sub{font-size:10px;color:#999;}

.fq-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:700;text-transform:uppercase;border-radius:2px;}
.fq-badge--paid{background:#05275C;color:#fff;}
.fq-badge--pending{background:#fef9c3;color:#854d0e;}
.fq-badge--rejected{background:#fee2e2;color:#dc2626;}
.fq-badge--posted{background:#dcfce7;color:#16a34a;}
.fq-badge--unposted{background:#fef3c7;color:#d97706;}

.fq-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 12px;font-size:11px;font-weight:600;border:none;cursor:pointer;text-decoration:none;transition:all .15s;white-space:nowrap;}
.fq-btn--primary{background:var(--brand-dark);color:#fff;}
.fq-btn--primary:hover{background:var(--brand);color:#fff;text-decoration:none;}
.fq-btn--success{background:var(--green);color:#fff;}
.fq-btn--success:hover{background:#15803d;color:#fff;text-decoration:none;}
.fq-btn--amber{background:#d97706;color:#fff;}
.fq-btn--amber:hover{background:#b45309;color:#fff;text-decoration:none;}
.fq-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.fq-btn--outline:hover{border-color:var(--brand-dark);color:var(--brand-dark);text-decoration:none;}
.fq-btn--sm{padding:3px 8px;font-size:10px;}
.fq-btn--danger{background:#dc2626;color:#fff;}
.fq-btn--danger:hover{background:#b91c1c;color:#fff;text-decoration:none;}

.fq-empty{text-align:center;padding:48px 20px;color:#999;font-size:12px;}

/* ── Payment modal ── */
.fq-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;}
.fq-overlay.is-open{display:flex;}
.fq-modal{background:#fff;border:1px solid var(--border);width:100%;max-width:580px;margin:20px;border-radius:2px;max-height:92vh;overflow-y:auto;}
.fq-modal__head{display:flex;align-items:center;justify-content:space-between;padding:14px 18px;border-bottom:1px solid var(--border);background:#fafbfc;position:sticky;top:0;z-index:1;}
.fq-modal__title{font-size:14px;font-weight:700;color:var(--green);}
.fq-modal__close{background:none;border:none;font-size:18px;cursor:pointer;color:#888;}
.fq-modal__body{padding:18px;}
.fq-modal__footer{display:flex;gap:8px;justify-content:flex-end;padding:12px 18px;border-top:1px solid var(--border);background:#fafbfc;flex-wrap:wrap;}

.fq-field{margin-bottom:14px;}
.fq-label{display:block;font-size:10px;font-weight:700;color:#555;text-transform:uppercase;letter-spacing:.4px;margin-bottom:5px;}
.fq-input,.fq-select,.fq-textarea{width:100%;border:1px solid var(--border);padding:7px 10px;font-size:12px;font-family:inherit;box-sizing:border-box;background:#fff;}
.fq-input:focus,.fq-select:focus,.fq-textarea:focus{outline:none;border-color:var(--green);}
.fq-textarea{resize:vertical;min-height:60px;}
.fq-grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px;}

.fq-sum-panel{background:#e8f5e9;border:1px solid #a5d6a7;padding:12px 14px;margin-bottom:14px;}
.fq-sum-panel__label{font-size:10px;color:#388e3c;text-transform:uppercase;letter-spacing:.4px;margin-bottom:4px;}
.fq-sum-panel__val{font-size:20px;font-weight:700;color:#1b5e20;}

.fq-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:12px;}
.fq-info-item{background:#f8fafc;border:1px solid var(--border);padding:8px 10px;}
.fq-info-item__label{font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-bottom:2px;}
.fq-info-item__val{font-size:12px;font-weight:600;color:#1a1a2e;}

.fq-items-mini table{width:100%;border-collapse:collapse;font-size:11px;}
.fq-items-mini th{background:#f0f4f8;padding:5px 8px;text-align:left;font-size:10px;color:#888;font-weight:600;text-transform:uppercase;}
.fq-items-mini td{padding:4px 8px;border-bottom:1px solid #f5f7fa;}
.fq-items-mini .td-r{text-align:right;font-weight:600;}
.fq-grand{background:var(--green);color:#fff;text-align:right;padding:6px 8px;font-size:12px;font-weight:700;margin-bottom:12px;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="fq-page">

  <div class="fq-header">
    <div class="fq-header__icon">
      <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
      </svg>
    </div>
    <div>
      <div class="fq-header__title">Finance — Requisitions Payment Queue</div>
      <div class="fq-header__sub">Process payments, record disbursements and post to ledger</div>
    </div>
    <div class="fq-header__actions">
      <a href="BursarRequisitions.aspx" class="fq-btn fq-btn--outline">Bursar Queue</a>
      <a href="RequisitionsController.aspx" class="fq-btn fq-btn--primary">Master View</a>
    </div>
  </div>

  <div class="fq-stats">
    <div class="fq-stat fq-stat--amber">
      <div class="fq-stat__val"><asp:Literal ID="litCntAwaiting" runat="server">0</asp:Literal></div>
      <div class="fq-stat__label">Awaiting Payment</div>
    </div>
    <div class="fq-stat fq-stat--blue">
      <div class="fq-stat__val"><asp:Literal ID="litCntPending" runat="server">0</asp:Literal></div>
      <div class="fq-stat__label">Pending Payment</div>
    </div>
    <div class="fq-stat fq-stat--green">
      <div class="fq-stat__val"><asp:Literal ID="litCntPaid" runat="server">0</asp:Literal></div>
      <div class="fq-stat__label">Paid Out</div>
    </div>
    <div class="fq-stat fq-stat--navy">
      <div class="fq-stat__val"><asp:Literal ID="litCntUnposted" runat="server">0</asp:Literal></div>
      <div class="fq-stat__label">Ledger Unposted</div>
    </div>
  </div>

  <div class="fq-tabs">
    <button class="fq-tab is-active" onclick="fqTab(this,'awaiting')">
      Awaiting Payment <span class="fq-tab__badge"><asp:Literal ID="litTabAwaiting" runat="server">0</asp:Literal></span>
    </button>
    <button class="fq-tab" onclick="fqTab(this,'pending')">
      Pending Payment <span class="fq-tab__badge" style="background:#fef9c3;color:#854d0e;"><asp:Literal ID="litTabPending" runat="server">0</asp:Literal></span>
    </button>
    <button class="fq-tab" onclick="fqTab(this,'unposted')">
      Ledger Unposted <span class="fq-tab__badge" style="background:#fef3c7;color:#d97706;"><asp:Literal ID="litTabUnposted" runat="server">0</asp:Literal></span>
    </button>
    <button class="fq-tab" onclick="fqTab(this,'history')">
      Paid Out History <span class="fq-tab__badge" style="background:#dcfce7;color:#16a34a;"><asp:Literal ID="litTabHistory" runat="server">0</asp:Literal></span>
    </button>
  </div>

  <!-- Awaiting Payment -->
  <div id="tab-awaiting" class="fq-panel is-active">
    <div class="fq-card">
      <div class="fq-table-wrap">
        <table class="fq-table">
          <thead><tr>
            <th class="fq-col-num">#</th><th>Req No.</th><th>Requester / Dept</th><th>Title</th>
            <th class="fq-col-amt">Amount (UGX)</th>
            <th>Approved Via</th><th class="fq-nowrap">Approved On</th>
            <th class="fq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litAwaitingRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Pending Payment -->
  <div id="tab-pending" class="fq-panel">
    <div class="fq-card">
      <div class="fq-table-wrap">
        <table class="fq-table">
          <thead><tr>
            <th class="fq-col-num">#</th><th>Req No.</th><th>Requester</th><th>Title</th>
            <th class="fq-col-amt">Amount (UGX)</th>
            <th class="fq-nowrap">Marked On</th><th>Remarks</th>
            <th class="fq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litPendingRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Ledger Unposted -->
  <div id="tab-unposted" class="fq-panel">
    <div class="fq-card">
      <div class="fq-table-wrap">
        <table class="fq-table">
          <thead><tr>
            <th class="fq-col-num">#</th><th>Req No.</th><th>Requester</th><th>Title</th>
            <th class="fq-col-amt">Amount (UGX)</th>
            <th>Payment Method</th><th>Ref</th>
            <th class="fq-col-action">Post Ledger</th>
          </tr></thead>
          <tbody><asp:Literal ID="litUnpostedRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- History -->
  <div id="tab-history" class="fq-panel">
    <div class="fq-card">
      <div class="fq-table-wrap">
        <table class="fq-table">
          <thead><tr>
            <th class="fq-col-num">#</th><th>Req No.</th><th>Requester</th><th>Title</th>
            <th class="fq-col-amt">Amount (UGX)</th>
            <th>Method</th><th>Ref</th><th>Ledger</th>
            <th class="fq-nowrap">Paid On</th>
            <th class="fq-col-action">Action</th>
          </tr></thead>
          <tbody><asp:Literal ID="litHistoryRows" runat="server" /></tbody>
        </table>
      </div>
    </div>
  </div>

</div>

<!-- Payment Modal -->
<div class="fq-overlay" id="fqOverlay">
  <div class="fq-modal">
    <div class="fq-modal__head">
      <div class="fq-modal__title" id="fqModalTitle">Process Payment</div>
      <button class="fq-modal__close" onclick="closeModal()">✕</button>
    </div>
    <div class="fq-modal__body">
      <div class="fq-sum-panel">
        <div class="fq-sum-panel__label">Total Amount to Disburse</div>
        <div class="fq-sum-panel__val" id="fqSumVal">UGX 0</div>
      </div>
      <div class="fq-info-grid" id="fqInfoGrid"></div>
      <div class="fq-items-mini" id="fqItems"></div>

      <div class="fq-grid2">
        <div class="fq-field">
          <label class="fq-label">Payment Method <span style="color:#dc2626;">*</span></label>
          <select class="fq-select" id="fqMethod">
            <option value="CASH">Cash</option>
            <option value="CHEQUE">Cheque</option>
            <option value="BANK_TRANSFER">Bank Transfer</option>
            <option value="MOBILE_MONEY">Mobile Money</option>
            <option value="IMPREST">Imprest</option>
          </select>
        </div>
        <div class="fq-field">
          <label class="fq-label">Reference / Voucher No.</label>
          <input type="text" class="fq-input" id="fqRef" placeholder="Cheque no., voucher, RRTN..." />
        </div>
      </div>
      <div class="fq-grid2">
        <div class="fq-field">
          <label class="fq-label">Payment Date <span style="color:#dc2626;">*</span></label>
          <input type="date" class="fq-input" id="fqDate" />
        </div>
        <div class="fq-field">
          <label class="fq-label">Ledger Reference (GL)</label>
          <input type="text" class="fq-input" id="fqLedgerRef" placeholder="GL reference (leave blank to auto-assign)" />
        </div>
      </div>
      <div class="fq-field">
        <label class="fq-label">Finance Remarks</label>
        <textarea class="fq-textarea" id="fqRemarks" rows="2" placeholder="Optional payment notes..."></textarea>
      </div>
    </div>
    <div class="fq-modal__footer">
      <button class="fq-btn fq-btn--outline" onclick="closeModal()">Cancel</button>
      <button class="fq-btn fq-btn--amber" onclick="submitFinanceAction('pending')">⏳ Mark as Pending Payment</button>
      <button class="fq-btn fq-btn--success" onclick="submitFinanceAction('paid')">✓ Mark Paid &amp; Post Ledger</button>
    </div>
  </div>
</div>

<script>
var _fqReqId   = 0;
var _csrfToken = (document.querySelector('meta[name="csrf-token"]') || {}).content || '';

function fqTab(el, name) {
    document.querySelectorAll('.fq-tab').forEach(function(t) { t.classList.remove('is-active'); });
    document.querySelectorAll('.fq-panel').forEach(function(p) { p.classList.remove('is-active'); });
    el.classList.add('is-active');
    var panel = document.getElementById('tab-' + name);
    if (panel) panel.classList.add('is-active');
}

function openPayModal(reqId, reqNo, requester, dept, amount, approvedVia, itemsJson) {
    _fqReqId = reqId;
    document.getElementById('fqModalTitle').textContent = 'Process Payment: ' + reqNo;
    document.getElementById('fqSumVal').textContent = 'UGX ' + fmt(amount);
    document.getElementById('fqDate').value = new Date().toISOString().slice(0, 10);
    document.getElementById('fqMethod').value = 'CASH';
    document.getElementById('fqRef').value = '';
    document.getElementById('fqLedgerRef').value = '';
    document.getElementById('fqRemarks').value = '';

    document.getElementById('fqInfoGrid').innerHTML =
        '<div class="fq-info-item"><div class="fq-info-item__label">Requester</div><div class="fq-info-item__val">' + esc(requester) + '</div></div>' +
        '<div class="fq-info-item"><div class="fq-info-item__label">Department</div><div class="fq-info-item__val">' + esc(dept) + '</div></div>' +
        '<div class="fq-info-item"><div class="fq-info-item__label">Approved Via</div><div class="fq-info-item__val">' + esc(approvedVia) + '</div></div>' +
        '<div class="fq-info-item"><div class="fq-info-item__label">Req. No.</div><div class="fq-info-item__val">' + esc(reqNo) + '</div></div>';

    var items = [];
    try { items = JSON.parse(itemsJson); } catch(e) {}
    var html = '';
    if (items.length > 0) {
        html = '<table><thead><tr><th>#</th><th>Item</th><th>Qty</th><th class="td-r">Unit Price</th><th class="td-r">Total</th></tr></thead><tbody>';
        var grand = 0;
        items.forEach(function(it, i) {
            var tot = parseFloat(it.total) || 0; grand += tot;
            html += '<tr><td>' + (i+1) + '</td><td>' + esc(it.desc) + '</td><td>' + (it.qty||0) + ' ' + esc(it.unit||'pcs') + '</td><td class="td-r">' + fmt(it.price||0) + '</td><td class="td-r">' + fmt(tot) + '</td></tr>';
        });
        html += '</tbody></table><div class="fq-grand">GRAND TOTAL: UGX ' + fmt(grand) + '</div>';
    }
    document.getElementById('fqItems').innerHTML = html;
    document.getElementById('fqOverlay').classList.add('is-open');
}

function closeModal() {
    document.getElementById('fqOverlay').classList.remove('is-open');
    _fqReqId = 0;
}

function postLedger(reqId) {
    if (!confirm('Mark this requisition as ledger-posted?\n\nThis confirms the accounting entry has been made in the General Ledger.')) return;
    var ref = prompt('Enter GL / Ledger Reference (optional):', '') || '';
    fetch(window.location.pathname + '?ajax=action', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
        body: JSON.stringify({ req_id: reqId, action: 'post_ledger', ledger_ref: ref })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) { if (res.ok) { window.location.reload(); } else { alert('Error: ' + res.error); } })
    .catch(function() { alert('Network error.'); });
}

function submitFinanceAction(action) {
    var method = document.getElementById('fqMethod').value;
    var ref    = document.getElementById('fqRef').value.trim();
    var date   = document.getElementById('fqDate').value;
    var lref   = document.getElementById('fqLedgerRef').value.trim();
    var remarks= document.getElementById('fqRemarks').value.trim();

    if (!date) { alert('Please select a payment date.'); return; }
    if (action === 'paid' && !confirm('Confirm payment and post to ledger?\n\nThis action marks the requisition as fully paid out.')) return;

    fetch(window.location.pathname + '?ajax=action', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
        body: JSON.stringify({ req_id: _fqReqId, action: action, method: method, ref: ref, date: date, ledger_ref: lref, remarks: remarks })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res.ok) { closeModal(); window.location.reload(); }
        else { alert('Error: ' + (res.error || 'Unknown error')); }
    })
    .catch(function() { alert('Network error. Please try again.'); });
}

function esc(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; }
function fmt(n) { return Math.round(parseFloat(n)||0).toLocaleString('en-UG'); }
</script>
</asp:Content>
