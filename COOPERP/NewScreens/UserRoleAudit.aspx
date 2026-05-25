<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="UserRoleAudit.aspx.cs" Inherits="COOPERP_NewScreens_UserRoleAudit" Title="Audit Log - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--warn:#b45309;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}

/* ── Header ──────────────────────────────────────────────────────────────────*/
.urm-header{background:#fff;border-bottom:1px solid var(--bdr);padding:20px 28px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
.urm-header__title{font-size:18px;font-weight:700;color:var(--txt);margin:0;}
.urm-header__sub{font-size:12px;color:var(--muted);margin:2px 0 0;}

/* ── Stat chips ───────────────────────────────────────────────────────────── */
.pa-list-stats{display:flex;align-items:center;gap:8px;padding:10px 28px;background:var(--surf);border-bottom:1px solid var(--bdr);flex-wrap:wrap;}
.pa-list-stat{display:inline-flex;align-items:center;gap:5px;padding:5px 12px;border:1px solid var(--bdr);background:#fff;font-size:11px;white-space:nowrap;cursor:pointer;transition:border-color .15s;}
.pa-list-stat:hover{border-color:var(--brand);}
.pa-list-stat b{font-size:14px;font-weight:700;color:var(--txt);}
.pa-list-stat__lbl{color:var(--muted);}
.ps--all{border-left:3px solid var(--brand-dk);}
.ps--today{border-left:3px solid var(--success);}
.ps--assign{border-left:3px solid #0284c7;}
.ps--revoke{border-left:3px solid var(--danger);}
.ps--perm{border-left:3px solid #7c3aed;}

/* ── Filters ─────────────────────────────────────────────────────────────── */
.urm-filters{background:var(--surf);border-bottom:1px solid var(--bdr);padding:12px 28px;display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.urm-filters label{font-size:11px;font-weight:600;color:#374151;white-space:nowrap;}
.urm-filters select,.urm-filters input[type=date],.urm-filters input[type=text]{height:34px;border:1px solid var(--bdr);background:#fff;font-size:11px;padding:0 8px;outline:none;border-radius:0;}
.urm-filters select:focus,.urm-filters input:focus{border-color:var(--brand);}

/* ── Quick filter chips ───────────────────────────────────────────────────── */
.quick-filters{display:flex;align-items:center;gap:6px;padding:8px 28px;background:var(--surf);border-bottom:1px solid var(--bdr);flex-wrap:wrap;}
.qf-label{font-size:11px;font-weight:600;color:var(--muted);margin-right:2px;}
.qf-btn{padding:3px 10px;font-size:11px;border:1px solid var(--bdr);background:#fff;cursor:pointer;color:#374151;border-radius:12px;white-space:nowrap;}
.qf-btn:hover{background:#eff6ff;border-color:var(--brand);color:var(--brand);}

/* ── Buttons ──────────────────────────────────────────────────────────────── */
.urm-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 12px;font-size:11px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;text-decoration:none;}
.urm-btn--primary{background:var(--brand-dk);color:#fff;}
.urm-btn--primary:hover{background:var(--brand);}
.urm-btn--success{background:var(--success);color:#fff;}
.urm-btn--success:hover{background:#15803d;}
.urm-btn--outline{background:#fff;color:#374151;border:1px solid var(--bdr);}
.urm-btn--outline:hover{background:var(--surf);}

/* ── Table ───────────────────────────────────────────────────────────────── */
.urm-table-wrap{overflow-x:auto;}
table.urm-table{width:100%;border-collapse:collapse;font-size:11px;}
.urm-table th{background:var(--surf);color:#374151;font-weight:600;padding:9px 14px;text-align:left;border-bottom:2px solid var(--bdr);white-space:nowrap;position:sticky;top:0;z-index:2;}
.urm-table td{padding:9px 14px;border-bottom:1px solid #f1f5f9;color:#374151;vertical-align:top;}
.urm-table tr:hover td{background:#f8fafc;}
.ts-cell{white-space:nowrap;font-family:monospace;font-size:10px;}
.ts-rel{font-size:10px;color:var(--muted);display:block;margin-top:1px;}
.actor-cell{white-space:nowrap;}
.ip-cell{font-family:monospace;font-size:10px;color:var(--muted);}
.detail-cell{max-width:280px;}
.detail-text{word-break:break-word;line-height:1.5;}
.detail-text.is-truncated{overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;}
.detail-expand{font-size:10px;color:var(--brand);cursor:pointer;border:none;background:none;padding:0;margin-top:3px;display:block;}
.detail-expand:hover{text-decoration:underline;}

/* ── Action type badges ──────────────────────────────────────────────────── */
.at-badge{display:inline-block;padding:2px 7px;border-radius:2px;font-size:10px;font-weight:700;white-space:nowrap;}
.at-assign{background:#dcfce7;color:#16a34a;}
.at-revoke{background:#fef2f2;color:#dc2626;}
.at-create{background:#e0f2fe;color:#0284c7;}
.at-update{background:#fef9c3;color:#ca8a04;}
.at-delete{background:#fce7f3;color:#db2777;}
.at-perms {background:#ede9fe;color:#7c3aed;}
.at-batch {background:#f0fdf4;color:#15803d;}
.at-other {background:#f1f5f9;color:#64748b;}

/* ── Pagination ──────────────────────────────────────────────────────────── */
.urm-pager{padding:12px 28px;display:flex;align-items:center;gap:6px;flex-wrap:wrap;font-size:11px;color:var(--muted);border-top:1px solid var(--bdr);}
.urm-pager a{display:inline-flex;align-items:center;justify-content:center;min-width:28px;height:28px;padding:0 6px;border:1px solid var(--bdr);color:#374151;text-decoration:none;font-size:11px;font-weight:600;}
.urm-pager a:hover{background:var(--surf);}
.urm-pager a.active{background:var(--brand-dk);color:#fff;border-color:var(--brand-dk);}
.urm-pager__info{margin-right:8px;}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Header -->
<div class="urm-header">
    <div>
        <div class="urm-header__title">Role Audit Log</div>
        <div class="urm-header__sub">Complete history of role assignment, revocation and permission changes</div>
    </div>
    <a href="UserRoleAudit.aspx?export=csv<asp:Literal ID="litExportParams" runat="server"></asp:Literal>" class="urm-btn urm-btn--success">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Export CSV
    </a>
</div>

<!-- Stat chips -->
<asp:Literal ID="litStats" runat="server"></asp:Literal>

<!-- Quick date filters -->
<div class="quick-filters">
    <span class="qf-label">Quick:</span>
    <button type="button" class="qf-btn" onclick="quickFilter('today')">Today</button>
    <button type="button" class="qf-btn" onclick="quickFilter('7d')">Last 7 Days</button>
    <button type="button" class="qf-btn" onclick="quickFilter('30d')">Last 30 Days</button>
    <button type="button" class="qf-btn" onclick="quickFilter('assign')">Assigns Only</button>
    <button type="button" class="qf-btn" onclick="quickFilter('revoke')">Revokes Only</button>
    <button type="button" class="qf-btn" onclick="quickFilter('perms')">Permission Changes</button>
</div>

<!-- Filters form -->
<form method="get" action="UserRoleAudit.aspx" id="filterForm">
<div class="urm-filters">
    <label>Action:</label>
    <select name="action_type" id="fAction">
        <option value="">All actions</option>
        <asp:Literal ID="litActionOpts" runat="server"></asp:Literal>
    </select>

    <label>Target:</label>
    <input type="text" name="target" id="fTarget" placeholder="username or role"
           value="<asp:Literal ID="litTargetVal" runat="server"></asp:Literal>" style="width:150px;" />

    <label>Actor:</label>
    <input type="text" name="actor" id="fActor" placeholder="who performed it"
           value="<asp:Literal ID="litActorVal" runat="server"></asp:Literal>" style="width:150px;" />

    <label>From:</label>
    <input type="date" name="from" id="fFrom" value="<asp:Literal ID="litFromVal" runat="server"></asp:Literal>" />

    <label>To:</label>
    <input type="date" name="to" id="fTo" value="<asp:Literal ID="litToVal" runat="server"></asp:Literal>" />

    <button type="submit" class="urm-btn urm-btn--primary">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" y1="6" x2="16" y2="6"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="18" x2="12" y2="18"/></svg>
        Filter
    </button>
    <a href="UserRoleAudit.aspx" class="urm-btn urm-btn--outline">Clear</a>
</div>
</form>

<!-- Table -->
<div class="urm-table-wrap">
<table class="urm-table">
    <thead>
        <tr>
            <th style="width:150px;">Timestamp</th>
            <th style="width:150px;">Action</th>
            <th style="width:90px;">Target Type</th>
            <th style="width:130px;">Target</th>
            <th>Detail</th>
            <th style="width:110px;">Actor</th>
            <th style="width:115px;">IP Address</th>
        </tr>
    </thead>
    <tbody>
        <asp:Literal ID="litRows" runat="server"></asp:Literal>
    </tbody>
</table>
</div>

<!-- Pagination -->
<div class="urm-pager">
    <asp:Literal ID="litPager" runat="server"></asp:Literal>
</div>

<script type="text/javascript">
// ── Quick filter buttons ──────────────────────────────────────────────────────
window.quickFilter = function(preset){
    var today = new Date();
    var pad   = function(n){ return n<10?'0'+n:String(n); };
    var fmt   = function(d){ return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); };

    var action='', from='', to='';

    if(preset==='today'){
        from = to = fmt(today);
    } else if(preset==='7d'){
        var d7 = new Date(today); d7.setDate(today.getDate()-6);
        from = fmt(d7); to = fmt(today);
    } else if(preset==='30d'){
        var d30 = new Date(today); d30.setDate(today.getDate()-29);
        from = fmt(d30); to = fmt(today);
    } else if(preset==='assign'){
        action = 'ASSIGN_ROLE';
    } else if(preset==='revoke'){
        action = 'REVOKE_ROLE';
    } else if(preset==='perms'){
        action = 'UPDATE_PERMISSIONS';
    }

    document.getElementById('fAction').value = action;
    document.getElementById('fFrom').value   = from;
    document.getElementById('fTo').value     = to;
    document.getElementById('filterForm').submit();
};

// ── Detail expand/collapse ────────────────────────────────────────────────────
window.toggleDetail = function(btn){
    var dt = btn.previousElementSibling;
    if(dt.classList.contains('is-truncated')){
        dt.classList.remove('is-truncated');
        btn.textContent = 'Show less ▲';
    } else {
        dt.classList.add('is-truncated');
        btn.textContent = 'Show more ▼';
    }
};
</script>
</asp:Content>
