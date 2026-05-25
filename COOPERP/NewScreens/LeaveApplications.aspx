<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LeaveApplications.aspx.cs" Inherits="COOPERP_NewScreens_LeaveApplications" Title="Leave Applications - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--warn:#b45309;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}

/* ── Header ──────────────────────────────────────────────────────────────── */
.lv-header{background:#fff;border-bottom:1px solid var(--bdr);padding:20px 28px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
.lv-header__title{font-size:18px;font-weight:700;color:var(--txt);margin:0;}
.lv-header__sub{font-size:12px;color:var(--muted);margin:2px 0 0;}

/* ── Stat chips ───────────────────────────────────────────────────────────── */
.pa-list-stats{display:flex;align-items:center;gap:8px;padding:10px 28px;background:var(--surf);border-bottom:1px solid var(--bdr);flex-wrap:wrap;}
.pa-list-stat{display:inline-flex;align-items:center;gap:5px;padding:5px 12px;border:1px solid var(--bdr);background:#fff;font-size:11px;cursor:pointer;white-space:nowrap;transition:border-color .15s;}
.pa-list-stat:hover{border-color:var(--brand);}
.pa-list-stat b{font-size:14px;font-weight:700;color:var(--txt);}
.pa-list-stat__lbl{color:var(--muted);}
.ps--all    {border-left:3px solid var(--brand-dk);}
.ps--pending{border-left:3px solid #f59e0b;}
.ps--hod    {border-left:3px solid #0284c7;}
.ps--hr     {border-left:3px solid #7c3aed;}
.ps--vc     {border-left:3px solid #db2777;}
.ps--ok     {border-left:3px solid var(--success);}
.ps--no     {border-left:3px solid var(--danger);}

/* ── Toolbar ─────────────────────────────────────────────────────────────── */
.lv-toolbar{background:var(--surf);border-bottom:1px solid var(--bdr);padding:12px 28px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
.lv-search{position:relative;flex:1;min-width:180px;max-width:300px;}
.lv-search input{width:100%;height:34px;border:1px solid var(--bdr);background:#fff;font-size:12px;padding:0 10px 0 32px;outline:none;box-sizing:border-box;}
.lv-search input:focus{border-color:var(--brand);}
.lv-search__ico{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#94a3b8;pointer-events:none;}
.lv-toolbar select{height:34px;border:1px solid var(--bdr);background:#fff;font-size:11px;padding:0 8px;outline:none;}
.lv-toolbar select:focus{border-color:var(--brand);}

/* ── Buttons ──────────────────────────────────────────────────────────────── */
.lv-btn{display:inline-flex;align-items:center;gap:5px;padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;text-decoration:none;}
.lv-btn--primary{background:var(--brand-dk);color:#fff;}
.lv-btn--primary:hover{background:var(--brand);}
.lv-btn--outline{background:#fff;color:#374151;border:1px solid var(--bdr);}
.lv-btn--outline:hover{background:var(--surf);}

/* ── Table ────────────────────────────────────────────────────────────────── */
.lv-table-wrap{overflow-x:auto;}
table.lv-table{width:100%;border-collapse:collapse;font-size:11px;}
.lv-table th{background:var(--surf);color:#374151;font-weight:600;padding:9px 14px;text-align:left;border-bottom:2px solid var(--bdr);white-space:nowrap;position:sticky;top:0;z-index:2;}
.lv-table td{padding:9px 14px;border-bottom:1px solid #f1f5f9;color:#374151;vertical-align:middle;}
.lv-table tr:hover td{background:#f8fafc;}

/* ── Employee cell ────────────────────────────────────────────────────────── */
.lv-emp{display:flex;align-items:center;gap:9px;}
.lv-avatar{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#fff;flex-shrink:0;}
.lv-emp__name{font-weight:600;color:var(--txt);font-size:12px;}
.lv-emp__dept{font-size:10px;color:var(--muted);}

/* ── Leave type badge ────────────────────────────────────────────────────── */
.lv-type{display:inline-block;padding:2px 8px;border-radius:2px;font-size:10px;font-weight:700;}
.lv-type--annual    {background:#e0f2fe;color:#0284c7;}
.lv-type--study     {background:#ede9fe;color:#7c3aed;}
.lv-type--sick      {background:#fef9c3;color:#ca8a04;}
.lv-type--maternity {background:#fce7f3;color:#db2777;}
.lv-type--bereavement{background:#f1f5f9;color:#475569;}

/* ── Status badge ─────────────────────────────────────────────────────────── */
.lv-status{display:inline-block;padding:2px 8px;border-radius:2px;font-size:10px;font-weight:700;white-space:nowrap;}
.lv-status--draft        {background:#f1f5f9;color:#64748b;}
.lv-status--submitted    {background:#fef9c3;color:#b45309;}
.lv-status--hod_approved {background:#e0f2fe;color:#0369a1;}
.lv-status--hod_declined {background:#fef2f2;color:#dc2626;}
.lv-status--hr_approved  {background:#ede9fe;color:#7c3aed;}
.lv-status--hr_declined  {background:#fef2f2;color:#dc2626;}
.lv-status--vc_granted   {background:#dcfce7;color:#16a34a;}
.lv-status--vc_not_granted{background:#fef2f2;color:#dc2626;}
.lv-status--vc_postponed {background:#fff7ed;color:#b45309;}
.lv-status--cancelled    {background:#f1f5f9;color:#94a3b8;}

/* ── Action dropdown ─────────────────────────────────────────────────────── */
.pa-act-menu{position:relative;display:inline-block;}
.pa-act-btn{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;font-size:11px;font-weight:600;background:#fff;border:1px solid var(--bdr);cursor:pointer;color:#374151;}
.pa-act-btn:hover{background:var(--surf);}
.pa-act-drop{display:none;position:absolute;right:0;top:100%;z-index:100;background:#fff;border:1px solid var(--bdr);min-width:160px;box-shadow:0 4px 16px rgba(0,0,0,.1);}
.pa-act-menu.open .pa-act-drop{display:block;}
.pa-act-item{display:flex;align-items:center;gap:6px;width:100%;padding:8px 12px;font-size:11px;background:none;border:none;cursor:pointer;text-align:left;color:#374151;white-space:nowrap;}
.pa-act-item:hover{background:var(--surf);}
.pa-act-item--danger{color:var(--danger);}
.pa-act-item--danger:hover{background:#fef2f2;}
.pa-act-sep{height:1px;background:var(--bdr);margin:3px 0;}

/* ── Empty / pager ────────────────────────────────────────────────────────── */
.lv-empty{text-align:center;padding:48px 24px;color:#94a3b8;font-size:13px;}
.lv-pager{padding:12px 28px;display:flex;align-items:center;gap:6px;font-size:11px;color:var(--muted);border-top:1px solid var(--bdr);flex-wrap:wrap;}
.lv-pager a{min-width:28px;height:28px;display:inline-flex;align-items:center;justify-content:center;border:1px solid var(--bdr);color:#374151;text-decoration:none;font-size:11px;font-weight:600;}
.lv-pager a:hover{background:var(--surf);}
.lv-pager a.active{background:var(--brand-dk);color:#fff;border-color:var(--brand-dk);}

/* ── Toast ────────────────────────────────────────────────────────────────── */
.pa-toast{display:none;position:fixed;bottom:24px;right:24px;z-index:3000;background:#fff;border:1px solid var(--bdr);border-left:4px solid var(--success);padding:12px 18px;font-size:12px;box-shadow:0 4px 18px rgba(0,0,0,.12);max-width:320px;border-radius:2px;}
.pa-toast.visible{display:block;}
.pa-toast--err{border-left-color:var(--danger);}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Header -->
<div class="lv-header">
    <div>
        <div class="lv-header__title">Leave Applications</div>
        <div class="lv-header__sub"><asp:Literal ID="litSubtitle" runat="server"></asp:Literal></div>
    </div>
    <asp:Literal ID="litNewBtn" runat="server"></asp:Literal>
</div>

<!-- Stat chips -->
<asp:Literal ID="litStats" runat="server"></asp:Literal>

<!-- Toolbar -->
<div class="lv-toolbar">
    <div class="lv-search">
        <svg class="lv-search__ico" xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" id="txtSearch" placeholder="Search employee, type…" oninput="filterRows()" />
    </div>

    <select id="selStatus" onchange="filterRows()">
        <option value="">All statuses</option>
        <option value="DRAFT">Draft</option>
        <option value="SUBMITTED">Submitted (Pending HOD)</option>
        <option value="HOD_APPROVED">HOD Approved (Pending HR)</option>
        <option value="HOD_DECLINED">HOD Declined</option>
        <option value="HR_APPROVED">HR Approved (Pending VC)</option>
        <option value="HR_DECLINED">HR Declined</option>
        <option value="VC_GRANTED">Granted</option>
        <option value="VC_NOT_GRANTED">Not Granted</option>
        <option value="VC_POSTPONED">Postponed</option>
    </select>

    <select id="selType" onchange="filterRows()">
        <option value="">All leave types</option>
        <option value="annual">Annual Leave</option>
        <option value="study">Study Leave</option>
        <option value="sick">Sick Leave</option>
        <option value="maternity">Maternity Leave</option>
        <option value="bereavement">Family Bereavement</option>
    </select>

    <span id="lblCount" style="font-size:11px;color:var(--muted);margin-left:auto;"></span>
</div>

<!-- Table -->
<div class="lv-table-wrap">
<table class="lv-table">
    <thead>
        <tr>
            <th style="width:38px;">#</th>
            <th style="min-width:200px;">Employee</th>
            <th style="width:130px;">Leave Type</th>
            <th style="width:110px;">From</th>
            <th style="width:110px;">To</th>
            <th style="width:60px;text-align:center;">Days</th>
            <th style="width:140px;">Status</th>
            <th style="width:100px;">Applied</th>
            <th style="width:120px;">Actions</th>
        </tr>
    </thead>
    <tbody id="tblBody">
        <asp:Literal ID="litRows" runat="server"></asp:Literal>
    </tbody>
</table>
</div>

<!-- Pagination -->
<div class="lv-pager">
    <asp:Literal ID="litPager" runat="server"></asp:Literal>
</div>

<!-- Toast -->
<div class="pa-toast" id="paToast"></div>

<script type="text/javascript">
// ── Client-side filter ────────────────────────────────────────────────────────
function filterRows(){
    var q      = (document.getElementById('txtSearch').value||'').toLowerCase();
    var status = (document.getElementById('selStatus').value||'').toLowerCase();
    var type   = (document.getElementById('selType').value||'').toLowerCase();
    var rows   = document.querySelectorAll('#tblBody tr.lv-row');
    var vis    = 0;
    for(var i=0;i<rows.length;i++){
        var r = rows[i];
        var srch   = (r.getAttribute('data-search')||'').toLowerCase();
        var rStatus= (r.getAttribute('data-status')||'').toLowerCase();
        var rType  = (r.getAttribute('data-type')||'').toLowerCase();
        var ok = (!q || srch.indexOf(q)>=0) &&
                 (!status || rStatus === status.toLowerCase()) &&
                 (!type   || rType   === type.toLowerCase());
        r.style.display = ok ? '' : 'none';
        if(ok) vis++;
    }
    document.getElementById('lblCount').textContent = vis + ' application' + (vis!==1?'s':'') + ' shown';
}
filterRows();

// ── Action dropdown ────────────────────────────────────────────────────────────
document.addEventListener('click', function(e){
    var btn = e.target.closest('.pa-act-btn');
    if(btn){
        e.stopPropagation();
        var menu = btn.closest('.pa-act-menu');
        var wasOpen = menu.classList.contains('open');
        document.querySelectorAll('.pa-act-menu.open').forEach(function(m){ m.classList.remove('open'); });
        if(!wasOpen) menu.classList.add('open');
        return;
    }
    document.querySelectorAll('.pa-act-menu.open').forEach(function(m){ m.classList.remove('open'); });
});

// ── Toast ──────────────────────────────────────────────────────────────────────
function showToast(msg, type){
    var t = document.getElementById('paToast');
    t.textContent = msg;
    t.className = 'pa-toast visible' + (type==='err' ? ' pa-toast--err' : '');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function(){ t.classList.remove('visible'); }, 3500);
}

// ── Quick cancel (admin/hr only) ───────────────────────────────────────────────
function cancelApp(id){
    if(!confirm('Cancel this leave application? This cannot be undone.')) return;
    fetch('LeaveApplicationForm.aspx?ajax=cancel', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'id=' + encodeURIComponent(id)
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        if(d.ok){ showToast('Application cancelled.','ok'); setTimeout(function(){ location.reload(); },900); }
        else showToast(d.error||'Failed.','err');
    });
}
</script>
</asp:Content>
