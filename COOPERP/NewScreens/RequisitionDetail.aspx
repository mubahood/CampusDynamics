<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="RequisitionDetail.aspx.cs" Inherits="COOPERP_NewScreens_RequisitionDetail" Title="Requisition Detail — Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
*,*::before,*::after{box-sizing:border-box;}
:root{--brand:#174DA4;--brand-dark:#05275C;--border:#e0e5ed;--surface:#f5f7fa;}

.rd-page{max-width:960px;margin:0 auto;padding:20px;}

/* ── Header ── */
.rd-header{margin-bottom:16px;}
.rd-back{display:inline-flex;align-items:center;gap:4px;font-size:12px;color:var(--brand-dark);text-decoration:none;font-weight:600;margin-bottom:10px;}
.rd-back:hover{text-decoration:underline;}
.rd-header__row{display:flex;align-items:flex-start;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.rd-header__title{font-size:20px;font-weight:700;color:#1a1a2e;}
.rd-header__sub{font-size:11px;color:#999;margin-top:3px;display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.rd-header__actions{display:flex;gap:8px;flex-wrap:wrap;}

/* ── Progress bar ── */
.rd-progress{display:flex;align-items:center;background:#fff;border:1px solid var(--border);padding:14px 18px;margin-bottom:14px;overflow-x:auto;gap:0;}
.rd-stage{flex:1;min-width:80px;text-align:center;position:relative;}
.rd-stage+.rd-stage::before{content:'';position:absolute;left:0;top:35%;width:100%;height:2px;background:#e0e5ed;z-index:0;}
.rd-stage.done+.rd-stage::before,.rd-stage.current+.rd-stage::before{background:#16a34a;}
.rd-stage.rejected+.rd-stage::before{background:#dc2626;}
.rd-dot{width:28px;height:28px;border-radius:50%;border:2px solid #e0e5ed;background:#fff;margin:0 auto 4px;display:flex;align-items:center;justify-content:center;position:relative;z-index:1;font-size:11px;font-weight:700;color:#999;}
.rd-stage.done .rd-dot{background:#16a34a;border-color:#16a34a;color:#fff;}
.rd-stage.current .rd-dot{background:var(--brand-dark);border-color:var(--brand-dark);color:#fff;box-shadow:0 0 0 3px rgba(5,39,92,.2);}
.rd-stage.rejected .rd-dot{background:#dc2626;border-color:#dc2626;color:#fff;}
.rd-stage__label{font-size:9px;color:#999;white-space:nowrap;}
.rd-stage.done .rd-stage__label,.rd-stage.current .rd-stage__label{font-weight:700;}
.rd-stage.done .rd-stage__label{color:#16a34a;}
.rd-stage.current .rd-stage__label{color:var(--brand-dark);}
.rd-stage.rejected .rd-stage__label{color:#dc2626;font-weight:700;}

/* ── Section card ── */
.rd-section{background:#fff;border:1px solid var(--border);margin-bottom:14px;overflow:hidden;}
.rd-section__head{padding:10px 14px;border-bottom:1px solid var(--border);background:#fafbfc;display:flex;align-items:center;justify-content:space-between;}
.rd-section__title{font-size:12px;font-weight:700;color:var(--brand-dark);display:flex;align-items:center;gap:6px;}
.rd-section__body{padding:14px;}

/* ── Meta grid ── */
.rd-meta-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;}
@media(max-width:600px){.rd-meta-grid{grid-template-columns:1fr 1fr;}}
.rd-meta-item{background:#f8fafc;border:1px solid #f0f0f0;padding:8px 10px;}
.rd-meta-item__label{font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-bottom:2px;}
.rd-meta-item__val{font-size:12px;font-weight:600;color:#1a1a2e;}

/* ── Items table ── */
.rd-items-table{width:100%;border-collapse:collapse;font-size:12px;}
.rd-items-table thead th{background:var(--brand-dark);color:#fff;padding:7px 10px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px;text-align:left;}
.rd-items-table thead th.rd-col-r{text-align:right;}
.rd-items-table tbody td{padding:6px 10px;border-bottom:1px solid #f5f7fa;}
.rd-items-table tbody tr:last-child td{border-bottom:none;}
.rd-col-no{width:32px;text-align:center;color:#999;}
.rd-col-unit{width:60px;}
.rd-col-qty{width:50px;text-align:right;}
.rd-col-price{width:120px;text-align:right;}
.rd-col-total{width:130px;text-align:right;font-weight:700;color:var(--brand-dark);}
.rd-grand{display:flex;justify-content:flex-end;padding:8px 10px;background:var(--brand-dark);color:#fff;font-size:14px;font-weight:700;}
.rd-grand span{margin-left:12px;}

/* ── Status badges ── */
.rd-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;border-radius:2px;}
.rd-badge--draft{background:#f1f5f9;color:#64748b;}
.rd-badge--submitted{background:#dbeafe;color:#1d4ed8;}
.rd-badge--green{background:#dcfce7;color:#16a34a;}
.rd-badge--amber{background:#fef3c7;color:#d97706;}
.rd-badge--vc{background:#f3e8ff;color:#7c3aed;}
.rd-badge--procurement{background:#e0f2fe;color:#0369a1;}
.rd-badge--paid{background:#05275C;color:#fff;}
.rd-badge--pending-pay{background:#fef9c3;color:#854d0e;}
.rd-badge--returned{background:#ffedd5;color:#c2410c;}
.rd-badge--red{background:#fee2e2;color:#dc2626;}
.rd-badge--cancelled{background:#f1f5f9;color:#475569;}

/* ── Priority ── */
.rd-pri-dot{width:9px;height:9px;border-radius:50%;display:inline-block;margin-right:4px;vertical-align:middle;}
.rd-pri--low{background:#94a3b8;}
.rd-pri--medium{background:#f59e0b;}
.rd-pri--high{background:#f97316;}
.rd-pri--urgent{background:#dc2626;}

/* ── Approval stages ── */
.rd-approvals{display:flex;flex-direction:column;gap:10px;}
.rd-approval{border:1px solid var(--border);overflow:hidden;}
.rd-approval__head{display:flex;align-items:center;gap:10px;padding:10px 14px;background:#fafbfc;}
.rd-approval__stage{font-size:11px;font-weight:700;color:var(--brand-dark);flex:1;}
.rd-approval__body{padding:10px 14px;font-size:12px;color:#555;border-top:1px solid var(--border);background:#fff;}
.rd-approval--done .rd-approval__head{background:#f0fff4;}
.rd-approval--rejected .rd-approval__head{background:#fff5f5;}
.rd-approval--pending .rd-approval__head{background:#fffbeb;}
.rd-approval--current .rd-approval__head{background:#e8eef8;}

/* ── Timeline ── */
.rd-timeline{list-style:none;padding:0;margin:0;}
.rd-timeline li{display:flex;gap:12px;padding:10px 0;position:relative;margin-left:14px;border-left:2px solid var(--border);padding-left:18px;}
.rd-timeline li::before{content:'●';position:absolute;left:-9px;color:var(--brand);background:#fff;font-size:14px;line-height:1;}
.rd-timeline li.is-current::before{color:#d97706;}
.rd-timeline li.is-rejected::before{color:#dc2626;}
.rd-tl-time{font-size:10px;color:#999;white-space:nowrap;min-width:110px;}
.rd-tl-actor{font-size:11px;font-weight:700;color:#1a1a2e;}
.rd-tl-action{font-size:10px;color:#666;}
.rd-tl-remarks{font-size:11px;color:#888;font-style:italic;margin-top:2px;}

/* ── Action panel ── */
.rd-action-panel{border:2px solid var(--brand-dark);background:#e8eef8;padding:16px;margin-top:4px;}
.rd-action-panel__title{font-size:12px;font-weight:700;color:var(--brand-dark);margin-bottom:12px;display:flex;align-items:center;gap:6px;}
.rd-action-panel__buttons{display:flex;gap:8px;flex-wrap:wrap;margin-top:10px;}
.rd-panel-input{width:100%;border:1px solid var(--border);padding:7px 10px;font-size:12px;font-family:inherit;resize:vertical;box-sizing:border-box;min-height:60px;background:#fff;}
.rd-panel-input:focus{outline:none;border-color:var(--brand-dark);}

/* ── Buttons ── */
.rd-btn{display:inline-flex;align-items:center;gap:4px;padding:7px 16px;font-size:12px;font-weight:600;border:none;cursor:pointer;text-decoration:none;transition:all .15s;white-space:nowrap;}
.rd-btn--primary{background:var(--brand-dark);color:#fff;}
.rd-btn--primary:hover{background:var(--brand);color:#fff;text-decoration:none;}
.rd-btn--success{background:#16a34a;color:#fff;}
.rd-btn--success:hover{background:#15803d;color:#fff;text-decoration:none;}
.rd-btn--danger{background:#dc2626;color:#fff;}
.rd-btn--danger:hover{background:#b91c1c;color:#fff;text-decoration:none;}
.rd-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.rd-btn--outline:hover{border-color:var(--brand-dark);color:var(--brand-dark);text-decoration:none;}
.rd-btn--amber{background:#d97706;color:#fff;}
.rd-btn--amber:hover{background:#b45309;color:#fff;text-decoration:none;}
.rd-btn--purple{background:#7c3aed;color:#fff;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="rd-page">

  <!-- Back -->
  <div class="rd-header">
    <asp:Literal ID="litBackLink" runat="server"><a href="RequisitionsController.aspx" class="rd-back">← Back to Requisitions</a></asp:Literal>
    <div class="rd-header__row">
      <div>
        <div class="rd-header__title">
          <asp:Literal ID="litReqNumber" runat="server">—</asp:Literal>
          — <asp:Literal ID="litTitle" runat="server" />
        </div>
        <div class="rd-header__sub">
          Status: <asp:Literal ID="litStatusBadge" runat="server" />
          &nbsp;|&nbsp; Priority: <asp:Literal ID="litPriorityHtml" runat="server" />
          &nbsp;|&nbsp; Type: <asp:Literal ID="litReqType" runat="server" />
          &nbsp;|&nbsp; Submitted: <asp:Literal ID="litSubmittedAt" runat="server">—</asp:Literal>
        </div>
      </div>
      <div class="rd-header__actions">
        <a href="javascript:window.print()" class="rd-btn rd-btn--outline">🖨 Print</a>
      </div>
    </div>
  </div>

  <!-- Progress -->
  <div class="rd-progress">
    <asp:Literal ID="litProgressBar" runat="server" />
  </div>

  <!-- Requester Info -->
  <div class="rd-section">
    <div class="rd-section__head">
      <div class="rd-section__title">
        <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
          <circle cx="12" cy="7" r="4"/>
        </svg>
        Requester Details
      </div>
    </div>
    <div class="rd-section__body">
      <div class="rd-meta-grid">
        <asp:Literal ID="litRequesterMeta" runat="server" />
      </div>
      <div style="margin-top:12px;">
        <div style="font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-bottom:4px;">Justification / Purpose</div>
        <div style="font-size:12px;color:#333;line-height:1.6;background:#f8fafc;border:1px solid #f0f0f0;padding:10px 12px;">
          <asp:Literal ID="litDescription" runat="server">—</asp:Literal>
        </div>
      </div>
    </div>
  </div>

  <!-- Items -->
  <div class="rd-section">
    <div class="rd-section__head">
      <div class="rd-section__title">
        <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/>
        </svg>
        Requisition Items
      </div>
      <div style="font-size:11px;color:#888;"><asp:Literal ID="litItemCount" runat="server">0</asp:Literal> item(s)</div>
    </div>
    <div>
      <table class="rd-items-table">
        <thead>
          <tr>
            <th class="rd-col-no">#</th>
            <th>Description</th>
            <th class="rd-col-unit">Unit</th>
            <th class="rd-col-qty rd-col-r">Qty</th>
            <th class="rd-col-price rd-col-r">Unit Price (UGX)</th>
            <th class="rd-col-total rd-col-r">Total (UGX)</th>
          </tr>
        </thead>
        <tbody>
          <asp:Literal ID="litItemRows" runat="server" />
        </tbody>
      </table>
      <div class="rd-grand">
        <span>GRAND TOTAL (UGX):</span>
        <span><asp:Literal ID="litGrandTotal" runat="server">0</asp:Literal></span>
      </div>
    </div>
  </div>

  <!-- Approval Stages -->
  <div class="rd-section">
    <div class="rd-section__head">
      <div class="rd-section__title">
        <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <polyline points="9 11 12 14 22 4"/>
          <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
        </svg>
        Approval Chain
      </div>
    </div>
    <div class="rd-section__body">
      <div class="rd-approvals">
        <asp:Literal ID="litApprovalChain" runat="server" />
      </div>
    </div>
  </div>

  <!-- Finance Details (if paid) -->
  <asp:Literal ID="litFinanceSection" runat="server" />

  <!-- Role-Conditional Action Panel -->
  <asp:Literal ID="litActionPanel" runat="server" />

  <!-- Audit Timeline -->
  <div class="rd-section">
    <div class="rd-section__head">
      <div class="rd-section__title">
        <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
        </svg>
        Activity Timeline
      </div>
    </div>
    <div class="rd-section__body">
      <ul class="rd-timeline">
        <asp:Literal ID="litTimeline" runat="server" />
      </ul>
    </div>
  </div>

</div>
</asp:Content>
