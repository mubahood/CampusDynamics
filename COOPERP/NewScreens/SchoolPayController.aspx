<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="SchoolPayController.aspx.cs" Inherits="COOPERP_NewScreens_SchoolPayController" Title="SchoolPay Controller - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .sp-wrap { font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif; color:#1a1a2e; font-size:12px; }
    /* nothing is fixed/sticky here — the whole page scrolls naturally with the master content */
    .sp-btn { display:inline-flex; align-items:center; gap:5px; padding:6px 12px; font-size:12px; font-weight:600; border:none; cursor:pointer; border-radius:0; background:#05275C; color:#fff; text-decoration:none; }
    .sp-btn:hover { background:#0a3a7d; }
    .sp-btn--out { background:#fff; color:#05275C; border:1px solid #cdd5e1; }
    .sp-btn--out:hover { background:#eef4fd; }
    .sp-btn--sm { padding:3px 9px; font-size:11px; }
    .sp-btn--green { background:#15803d; } .sp-btn--green:hover { background:#166534; }
    .sp-btn--amber { background:#b45309; } .sp-btn--amber:hover { background:#92400e; }
    .sp-btn[disabled] { opacity:.5; cursor:not-allowed; }

    .sp-kpis { display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr)); gap:8px; padding:10px 16px; }
    .sp-kpi { background:#fff; border:1px solid #e0e5ed; padding:9px 12px; }
    .sp-kpi .lbl { font-size:10px; color:#6b7280; font-weight:700; text-transform:uppercase; letter-spacing:.3px; }
    .sp-kpi .val { font-size:19px; font-weight:800; color:#05275C; margin-top:2px; line-height:1.1; }
    .sp-kpi .sub { font-size:10px; color:#6b7280; margin-top:1px; }
    .sp-kpi--warn .val { color:#b91c1c; }

    .sp-bar { display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:2px solid #e0e5ed; background:#f5f7fa; padding:0 12px 0 16px; }
    .sp-bar__actions { display:flex; gap:6px; flex-shrink:0; padding:5px 0; }
    .sp-tabs { display:flex; gap:2px; overflow-x:auto; white-space:nowrap; }
    .sp-tab { display:inline-block; padding:9px 14px; font-size:12px; font-weight:600; color:#6b7280; cursor:pointer; border:none; background:none; border-bottom:2px solid transparent; margin-bottom:-2px; text-decoration:none; }
    .sp-tab:hover { color:#05275C; }
    .sp-tab.active { color:#05275C; border-bottom-color:#174DA4; }
    .sp-panel { display:none; padding:14px 16px; }
    .sp-panel.active { display:block; }
    /* auto-sync engine */
    .sp-jobhead { display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; margin:12px 0; }
    .sp-jobbadge { display:inline-flex; align-items:center; gap:8px; font-size:14px; font-weight:700; padding:8px 15px; border-radius:2px; }
    .sp-jobbadge .dot { width:10px; height:10px; border-radius:50%; display:inline-block; }
    .sp-jobbadge.on { background:#e7f6ec; color:#15803d; } .sp-jobbadge.on .dot { background:#22c55e; box-shadow:0 0 0 3px rgba(34,197,94,.22); }
    .sp-jobbadge.paused { background:#fef6e7; color:#b45309; } .sp-jobbadge.paused .dot { background:#f59e0b; }
    .sp-jobbadge.stale { background:#fdeaea; color:#b91c1c; } .sp-jobbadge.stale .dot { background:#ef4444; box-shadow:0 0 0 3px rgba(239,68,68,.18); }
    .sp-jobbadge.off { background:#eef1f6; color:#6b7280; } .sp-jobbadge.off .dot { background:#9ca3af; }
    .sp-jobacts { display:flex; gap:6px; flex-wrap:wrap; }
    .sp-jobgrid { display:grid; grid-template-columns:repeat(auto-fit,minmax(175px,1fr)); gap:10px; }
    .sp-jobcell { border:1px solid #e0e5ed; padding:10px 12px; background:#fff; }
    .sp-jobcell .l { font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#6b7280; margin-bottom:3px; }
    .sp-jobcell .v { font-size:14px; font-weight:600; color:#1a1a2e; word-break:break-word; }
    .sp-jobcell .s { font-size:11px; color:#6b7280; margin-top:2px; word-break:break-word; }
    .sp-jobcell.err { border-color:#f3c9c9; background:#fdf5f5; } .sp-jobcell.err .v { color:#b91c1c; font-size:12px; font-weight:500; }

    .sp-toolbar { display:flex; align-items:flex-end; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
    .sp-fld { display:flex; flex-direction:column; gap:3px; }
    .sp-fld label { font-size:11px; color:#6b7280; font-weight:600; }
    .sp-fld input, .sp-fld select { padding:6px 8px; border:1px solid #e0e5ed; border-radius:0; font-size:12px; }
    .sp-presets { display:flex; gap:5px; flex-wrap:wrap; margin-bottom:10px; }
    .sp-chip { padding:4px 11px; font-size:11px; font-weight:600; border:1px solid #cddffb; background:#f0f6ff; color:#174DA4; cursor:pointer; border-radius:14px; }
    .sp-chip:hover { background:#174DA4; color:#fff; }

    .sp-tw { width:100%; overflow-x:auto; border:1px solid #e0e5ed; }
    table.sp-tbl { width:100%; border-collapse:collapse; font-size:12px; min-width:640px; }
    table.sp-tbl th { text-align:left; background:#05275C; color:#fff; padding:8px 12px; font-weight:600; font-size:11px; white-space:nowrap; }
    table.sp-tbl td { padding:7px 12px; border-bottom:1px solid #eef2f7; vertical-align:middle; }
    /* zebra striping — white + light gray */
    table.sp-tbl tbody tr:nth-child(odd)  { background:#ffffff; }
    table.sp-tbl tbody tr:nth-child(even) { background:#f5f7fb; }
    table.sp-tbl tbody tr:last-child td { border-bottom:none; }
    table.sp-tbl tr.sp-click { cursor:pointer; }
    table.sp-tbl tr.sp-click:hover { background:#e8f0fd; }
    .sp-r { text-align:right; white-space:nowrap; }
    .sp-rcpt { color:#174DA4; font-weight:600; }

    .sp-badge { display:inline-block; padding:2px 7px; font-size:10px; font-weight:700; border-radius:0; }
    .b-cap { background:#dcfce7; color:#15803d; } .b-pend { background:#fef3c7; color:#b45309; }
    .b-new { background:#dbeafe; color:#1e40af; } .b-exist { background:#e5e7eb; color:#374151; }
    .b-fail,.b-nostud { background:#fee2e2; color:#b91c1c; }

    .sp-chan { display:flex; flex-wrap:wrap; gap:8px; }
    .sp-chan .c { background:#fff; border:1px solid #e0e5ed; padding:8px 12px; min-width:150px; flex:1 1 150px; }
    .sp-chan .c b { color:#05275C; }
    .sp-note { font-size:11px; color:#6b7280; margin:8px 0; }
    .sp-result-strip { display:flex; gap:14px; flex-wrap:wrap; background:#f0f6ff; border:1px solid #cddffb; padding:9px 12px; margin-bottom:12px; font-size:12px; }
    .sp-result-strip b { color:#05275C; }
    .sp-empty { text-align:center; color:#9ca3af; padding:22px; }
    .sp-spin { display:inline-block; width:12px; height:12px; border:2px solid rgba(255,255,255,.4); border-top-color:#fff; border-radius:50%; animation:spspin .7s linear infinite; vertical-align:middle; }
    @keyframes spspin { to { transform:rotate(360deg); } }
    #spToast { position:fixed; right:20px; bottom:20px; z-index:10001; display:none; padding:12px 18px; color:#fff; font-size:12px; font-weight:600; box-shadow:0 6px 24px rgba(0,0,0,.18); }

    /* ---- detail modal ---- */
    .sp-ovl { position:fixed; inset:0; background:rgba(10,20,40,.55); z-index:10000; display:none; align-items:flex-start; justify-content:center; padding:24px 12px; overflow:auto; }
    .sp-ovl.open { display:flex; }
    .sp-modal { background:#fff; width:640px; max-width:100%; border-radius:2px; box-shadow:0 12px 40px rgba(0,0,0,.3); }
    .sp-modal__hd { display:flex; align-items:center; justify-content:space-between; background:#05275C; color:#fff; padding:12px 16px; }
    .sp-modal__hd h3 { margin:0; font-size:14px; font-weight:700; }
    .sp-modal__x { background:none; border:none; color:#fff; font-size:20px; cursor:pointer; line-height:1; }
    .sp-modal__bd { padding:14px 16px; max-height:calc(100vh - 150px); overflow-y:auto; }
    .sp-sec { margin-bottom:14px; }
    .sp-sec__t { font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.4px; color:#174DA4; border-bottom:1px solid #e0e5ed; padding-bottom:4px; margin-bottom:8px; display:flex; justify-content:space-between; align-items:center; }
    .sp-kv { display:grid; grid-template-columns:130px 1fr; gap:4px 10px; font-size:12px; }
    .sp-kv .k { color:#6b7280; font-weight:600; }
    .sp-kv .v { color:#1a1a2e; word-break:break-word; }
    .sp-ledline { display:flex; justify-content:space-between; gap:10px; font-size:12px; padding:5px 0; border-bottom:1px dashed #e0e5ed; }
    .sp-ledline .lp { color:#374151; }
    .sp-lnk { color:#174DA4; text-decoration:none; font-weight:600; }
    .sp-lnk:hover { text-decoration:underline; }
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="sp-wrap">
    <div class="sp-kpis">
        <div class="sp-kpi"><div class="lbl">Captured today</div><div class="val" id="kToday">—</div><div class="sub" id="kTodayAmt"></div></div>
        <div class="sp-kpi"><div class="lbl">This week</div><div class="val" id="kWeek">—</div><div class="sub" id="kWeekAmt"></div></div>
        <div class="sp-kpi"><div class="lbl">Total captured</div><div class="val" id="kTotal">—</div><div class="sub" id="kTotalAmt"></div></div>
        <div class="sp-kpi sp-kpi--warn"><div class="lbl">Pending / unposted</div><div class="val" id="kPend">—</div><div class="sub" id="kPendAmt"></div></div>
    </div>

    <div class="sp-bar">
        <div class="sp-tabs">
            <a class="sp-tab" data-tab="ov"   href="?tab=ov">Overview</a>
            <a class="sp-tab" data-tab="rec"  href="?tab=rec">Reconcile &amp; Recover</a>
            <a class="sp-tab" data-tab="pend" href="?tab=pend">Pending &amp; Recapture</a>
            <a class="sp-tab" data-tab="txn"  href="?tab=txn">Transactions</a>
            <a class="sp-tab" data-tab="job"  href="?tab=job">Auto-Sync</a>
            <a class="sp-tab" data-tab="log"  href="?tab=log">Sync Log</a>
        </div>
        <div class="sp-bar__actions">
            <button type="button" class="sp-btn sp-btn--out sp-btn--sm" onclick="spTestConn()"><span id="spConnDot">&#9679;</span> Test connection</button>
            <button type="button" class="sp-btn sp-btn--out sp-btn--sm" onclick="spRefreshAll()">&#8635; Refresh</button>
        </div>
    </div>

    <!-- Overview -->
    <div id="p-ov" class="sp-panel active">
        <div class="sp-note">Payment channels (last 30 days)</div>
        <div class="sp-chan" id="ovChannels"></div>
        <div class="sp-note" style="margin-top:14px;">Latest payments (webhook + pull) &nbsp;·&nbsp; last synced: <b id="ovLastSync">—</b> &nbsp;·&nbsp; <span style="color:#9ca3af;">click a row for full details</span></div>
        <div class="sp-tw"><table class="sp-tbl"><thead><tr><th>Receipt</th><th>Reg No</th><th>Student</th><th>Channel</th><th class="sp-r">Amount</th><th>Date</th><th>Status</th></tr></thead><tbody id="ovRecent"></tbody></table></div>
    </div>

    <!-- Reconcile & Recover -->
    <div id="p-rec" class="sp-panel">
        <div class="sp-note">Pull payments straight from SchoolPay for a date range (max 31 days) and post anything we are missing. Idempotent &mdash; already-captured payments are skipped.</div>
        <div class="sp-presets">
            <span class="sp-chip" onclick="spPreset('today')">Today</span>
            <span class="sp-chip" onclick="spPreset('yesterday')">Yesterday</span>
            <span class="sp-chip" onclick="spPreset('thisweek')">This week</span>
            <span class="sp-chip" onclick="spPreset('lastweek')">Last week</span>
            <span class="sp-chip" onclick="spPreset('thismonth')">This month</span>
            <span class="sp-chip" onclick="spPreset('lastmonth')">Last month</span>
            <span class="sp-chip" onclick="spPreset('last7')">Last 7 days</span>
            <span class="sp-chip" onclick="spPreset('last30')">Last 30 days</span>
        </div>
        <div class="sp-toolbar">
            <div class="sp-fld"><label>From</label><input type="date" id="recFrom" /></div>
            <div class="sp-fld"><label>To</label><input type="date" id="recTo" /></div>
            <button type="button" class="sp-btn sp-btn--green" id="recBtn" onclick="spPull()">&#8681; Pull &amp; Reconcile</button>
        </div>
        <div class="sp-result-strip" id="recStrip" style="display:none;"></div>
        <div class="sp-tw"><table class="sp-tbl"><thead><tr><th>Receipt</th><th>Reg No</th><th>Student</th><th>Channel</th><th class="sp-r">Amount</th><th>Date</th><th>Outcome</th></tr></thead><tbody id="recRows"><tr><td colspan="7" class="sp-empty">Pick a range (or a quick chip) and run a pull.</td></tr></tbody></table></div>
    </div>

    <!-- Pending -->
    <div id="p-pend" class="sp-panel">
        <div class="sp-toolbar" style="justify-content:space-between;">
            <div class="sp-note" style="margin:0;">Received but not yet posted to a student ledger. Recapture drives the same hardened engine (idempotent).</div>
            <button type="button" class="sp-btn sp-btn--amber" onclick="spRecaptureAll()">&#8635; Recapture all pending</button>
        </div>
        <div class="sp-tw"><table class="sp-tbl"><thead><tr><th>Receipt</th><th>Reg No</th><th>Student</th><th>Channel</th><th class="sp-r">Amount</th><th>Date</th><th></th></tr></thead><tbody id="pendRows"></tbody></table></div>
    </div>

    <!-- Transactions -->
    <div id="p-txn" class="sp-panel">
        <div class="sp-toolbar">
            <div class="sp-fld"><label>Search (receipt / reg no / name)</label><input type="text" id="txnQ" style="min-width:240px;" onkeydown="if(event.key==='Enter')spTxn();" /></div>
            <div class="sp-fld"><label>Status</label><select id="txnStatus"><option value="">All</option><option>Captured</option><option>Pending</option></select></div>
            <button type="button" class="sp-btn" onclick="spTxn()">Search</button>
        </div>
        <div class="sp-tw"><table class="sp-tbl"><thead><tr><th>Receipt</th><th>Reg No</th><th>Student</th><th>Channel</th><th class="sp-r">Amount</th><th>Date</th><th>Status</th></tr></thead><tbody id="txnRows"><tr><td colspan="7" class="sp-empty">Search to list transactions.</td></tr></tbody></table></div>
    </div>

    <!-- Auto-Sync engine -->
    <div id="p-job" class="sp-panel">
        <div class="sp-note">The engine pings SchoolPay every <b id="jbInt">5</b> minutes and posts anything we're missing &mdash; idempotent, so it never double-posts. It self-heals after an app restart; if it ever shows <b>Stalled</b>, click <b>Restart engine</b>.</div>
        <div class="sp-jobhead">
            <div class="sp-jobbadge off" id="jbBadge"><span class="dot"></span> Checking…</div>
            <div class="sp-jobacts">
                <button type="button" class="sp-btn sp-btn--sm" id="jbRunBtn" onclick="spJobRun()">&#8635; Run now</button>
                <button type="button" class="sp-btn sp-btn--sm sp-btn--out" id="jbToggleBtn" onclick="spJobToggle()">Pause</button>
                <button type="button" class="sp-btn sp-btn--sm sp-btn--amber" onclick="spJobRestart()">Restart engine</button>
            </div>
        </div>
        <div class="sp-jobgrid" id="jbGrid"></div>
    </div>

    <!-- Sync Log -->
    <div id="p-log" class="sp-panel">
        <div class="sp-note">History of every pull/reconcile run.</div>
        <div class="sp-tw"><table class="sp-tbl"><thead><tr><th>Started</th><th>Range</th><th>Trigger</th><th>By</th><th class="sp-r">Fetched</th><th class="sp-r">New</th><th class="sp-r">Captured</th><th class="sp-r">Existed</th><th class="sp-r">Failed</th><th class="sp-r">SchoolPay total</th><th>Status</th></tr></thead><tbody id="logRows"></tbody></table></div>
    </div>
</div>

<!-- Detail modal -->
<div class="sp-ovl" id="spOvl" onclick="if(event.target===this)spCloseDetail()">
    <div class="sp-modal">
        <div class="sp-modal__hd"><h3 id="spDetTitle">Transaction detail</h3><button type="button" class="sp-modal__x" onclick="spCloseDetail()">&times;</button></div>
        <div class="sp-modal__bd" id="spDetBody"></div>
    </div>
</div>
<div id="spToast"></div>

<script type="text/javascript">
var SP = { url: location.pathname };
function $(id){ return document.getElementById(id); }
function fmt(n){ n=Number(n)||0; return 'UGX ' + n.toLocaleString('en-US',{maximumFractionDigits:0}); }
function esc(s){ s=(s==null?'':''+s); return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/'/g,'&#39;'); }
function toast(msg, ok){ var t=$('spToast'); t.style.background = ok===false ? '#b91c1c' : '#15803d'; t.textContent=msg; t.style.display='block'; clearTimeout(t._t); t._t=setTimeout(function(){t.style.display='none';},4000); }
function get(params){ return fetch(SP.url + '?' + params, {credentials:'same-origin',headers:{'X-Requested-With':'XMLHttpRequest'}}).then(function(r){return r.json();}); }
function badge(st){ var m={Captured:'b-cap',Pending:'b-pend',New:'b-new',Existed:'b-exist',Failed:'b-fail',NoStudent:'b-nostud'}; return '<span class="sp-badge '+(m[st]||'b-exist')+'">'+esc(st)+'</span>'; }
function rowClick(rcpt){ return ' class="sp-click" title="Click to view details" onclick="spDetail(\''+esc(rcpt)+'\')"'; }

/* ---- tabs: GET-addressable via ?tab= (each tab is its own URL) ---- */
function spCurrentTab(){ var m=(location.search||'').match(/[?&]tab=([a-z0-9]+)/i); var t=m?m[1].toLowerCase():'ov'; return document.getElementById('p-'+t)?t:'ov'; }
function spActivateTab(name){
    var tabs=document.querySelectorAll('.sp-tab'); for(var i=0;i<tabs.length;i++) tabs[i].classList.toggle('active', tabs[i].getAttribute('data-tab')===name);
    var ps=document.querySelectorAll('.sp-panel'); for(var j=0;j<ps.length;j++) ps[j].classList.remove('active');
    var p=document.getElementById('p-'+name); if(p) p.classList.add('active');
    if(name==='pend') spLoadPending(); else if(name==='log') spLoadLog(); else if(name==='ov') spRecent(); else if(name==='job') spJobStatus();
    spJobAutoRefresh(name==='job');
}

/* ---- stats + overview ---- */
function spStats(){
    get('act=stats').then(function(d){ if(!d.ok) return;
        $('kToday').textContent=(d.today_cnt||0).toLocaleString(); $('kTodayAmt').textContent=fmt(d.today_amt);
        $('kWeek').textContent=(d.week_cnt||0).toLocaleString(); $('kWeekAmt').textContent=fmt(d.week_amt);
        $('kTotal').textContent=(d.total_cnt||0).toLocaleString(); $('kTotalAmt').textContent=fmt(d.total_amt);
        $('kPend').textContent=(d.pending_cnt||0).toLocaleString(); $('kPendAmt').textContent=fmt(d.pending_amt);
        $('ovLastSync').textContent=d.last_sync||'never';
        var h=''; (d.channels||[]).forEach(function(c){ h+='<div class="c"><b>'+esc(c.name)+'</b><br>'+c.n.toLocaleString()+' &middot; '+fmt(c.amt)+'</div>'; });
        $('ovChannels').innerHTML = h || '<div class="sp-empty">No data.</div>';
    });
}
function spRecent(){
    get('act=recent').then(function(d){ var b=$('ovRecent'); if(!d.ok){b.innerHTML='';return;}
        b.innerHTML = d.rows.length ? d.rows.map(function(x){ return '<tr'+rowClick(x.receipt)+'><td class="sp-rcpt">'+esc(x.receipt)+'</td><td>'+esc(x.regno)+'</td><td>'+esc(x.name)+'</td><td>'+esc(x.channel)+'</td><td class="sp-r">'+fmt(x.amount)+'</td><td>'+esc(x.date)+'</td><td>'+badge(x.status)+'</td></tr>'; }).join('') : '<tr><td colspan="7" class="sp-empty">No payments yet.</td></tr>';
    });
}

function spTestConn(){ $('spConnDot').innerHTML='<span class="sp-spin"></span>';
    get('act=testconn').then(function(d){ $('spConnDot').textContent='●'; $('spConnDot').style.color=d.ok?'#4ade80':'#f87171'; toast(d.message,d.ok); })
    .catch(function(){ $('spConnDot').textContent='●'; $('spConnDot').style.color='#f87171'; toast('Connection test failed.',false); });
}

/* ---- date presets ---- */
function spPreset(kind){
    function iso(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
    var now=new Date(), f=new Date(), t=new Date();
    if(kind==='today'){ }
    else if(kind==='yesterday'){ f.setDate(f.getDate()-1); t.setDate(t.getDate()-1); }
    else if(kind==='thisweek'){ f.setDate(f.getDate()-((f.getDay()+6)%7)); }               // Monday..today
    else if(kind==='lastweek'){ var m=new Date(); m.setDate(m.getDate()-((m.getDay()+6)%7)); f=new Date(m); f.setDate(f.getDate()-7); t=new Date(m); t.setDate(t.getDate()-1); }
    else if(kind==='thismonth'){ f=new Date(now.getFullYear(),now.getMonth(),1); }
    else if(kind==='lastmonth'){ f=new Date(now.getFullYear(),now.getMonth()-1,1); t=new Date(now.getFullYear(),now.getMonth(),0); }
    else if(kind==='last7'){ f.setDate(f.getDate()-6); }
    else if(kind==='last30'){ f.setDate(f.getDate()-29); }
    $('recFrom').value=iso(f); $('recTo').value=iso(t);
}

/* ---- pull & reconcile ---- */
function spPull(){
    var f=$('recFrom').value, t=$('recTo').value; if(!f||!t){ toast('Pick a From and To date.',false); return; }
    var btn=$('recBtn'); btn.disabled=true; var old=btn.innerHTML; btn.innerHTML='<span class="sp-spin"></span> Pulling…';
    get('act=pull&from='+encodeURIComponent(f)+'&to='+encodeURIComponent(t)).then(function(d){
        btn.disabled=false; btn.innerHTML=old;
        if(!d.ok){ toast(d.message||'Pull failed.',false); return; }
        $('recStrip').style.display='flex';
        $('recStrip').innerHTML='<div>Fetched: <b>'+d.fetched+'</b></div><div>New posted: <b>'+d.captured+'</b></div><div>Already had: <b>'+d.existed+'</b></div><div>Needs review: <b>'+d.failed+'</b></div><div>SchoolPay total: <b>'+fmt(d.sp_total)+'</b></div>';
        toast(d.captured+' new payment(s) recovered, '+d.existed+' already present.', true);
        spRunRows(d.run_id); spStats();
    }).catch(function(){ btn.disabled=false; btn.innerHTML=old; toast('Pull failed (network/timeout).',false); });
}
function spRunRows(rid){
    get('act=runrows&run_id='+encodeURIComponent(rid)).then(function(d){ var b=$('recRows'); if(!d.ok){b.innerHTML='';return;}
        b.innerHTML = d.rows.length ? d.rows.map(function(x){ return '<tr'+rowClick(x.receipt)+'><td class="sp-rcpt">'+esc(x.receipt)+'</td><td>'+esc(x.regno)+'</td><td>'+esc(x.name)+'</td><td>'+esc(x.channel)+'</td><td class="sp-r">'+fmt(x.amount)+'</td><td>'+esc(x.date)+'</td><td>'+badge(x.status)+'</td></tr>'; }).join('') : '<tr><td colspan="7" class="sp-empty">No transactions in range.</td></tr>';
    });
}

/* ---- pending / recapture ---- */
function spLoadPending(){
    get('act=pending').then(function(d){ var b=$('pendRows'); if(!d.ok){b.innerHTML='';return;}
        b.innerHTML = d.rows.length ? d.rows.map(function(x){ return '<tr'+rowClick(x.receipt)+'><td class="sp-rcpt">'+esc(x.receipt)+'</td><td>'+esc(x.regno)+'</td><td>'+esc(x.name)+'</td><td>'+esc(x.channel)+'</td><td class="sp-r">'+fmt(x.amount)+'</td><td>'+esc(x.date)+'</td><td><button type="button" class="sp-btn sp-btn--sm" onclick="event.stopPropagation();spRecaptureOne(\''+esc(x.receipt)+'\',this)">Recapture</button></td></tr>'; }).join('') : '<tr><td colspan="7" class="sp-empty">Nothing pending &mdash; all payments are posted.</td></tr>';
    });
}
function spRecaptureOne(receipt, btn){ btn.disabled=true; btn.innerHTML='<span class="sp-spin"></span>';
    get('act=recapture&receipt='+encodeURIComponent(receipt)).then(function(d){ toast(d.message,d.ok); spLoadPending(); spStats(); })
    .catch(function(){ btn.disabled=false; btn.textContent='Recapture'; toast('Failed.',false); });
}
function spRecaptureAll(){ if(!confirm('Recapture ALL pending SchoolPay payments now?')) return;
    get('act=recaptureall').then(function(d){ toast(d.message,d.ok); spLoadPending(); spStats(); }); }

/* ---- transactions ---- */
function spTxn(){
    get('act=transactions&q='+encodeURIComponent($('txnQ').value)+'&status='+encodeURIComponent($('txnStatus').value)).then(function(d){ var b=$('txnRows'); if(!d.ok){b.innerHTML='';return;}
        b.innerHTML = d.rows.length ? d.rows.map(function(x){ return '<tr'+rowClick(x.receipt)+'><td class="sp-rcpt">'+esc(x.receipt)+'</td><td>'+esc(x.regno)+'</td><td>'+esc(x.name)+'</td><td>'+esc(x.channel)+'</td><td class="sp-r">'+fmt(x.amount)+'</td><td>'+esc(x.date)+'</td><td>'+badge(x.status)+'</td></tr>'; }).join('') : '<tr><td colspan="7" class="sp-empty">No matching transactions.</td></tr>';
    });
}

/* ---- sync log ---- */
function spLoadLog(){
    get('act=synclog').then(function(d){ var b=$('logRows'); if(!d.ok){b.innerHTML='';return;}
        b.innerHTML = d.rows.length ? d.rows.map(function(x){ return '<tr><td>'+esc(x.started)+'</td><td>'+esc(x.from)+' &rarr; '+esc(x.to)+'</td><td>'+esc(x.trg)+'</td><td>'+esc(x.by)+'</td><td class="sp-r">'+x.fetched+'</td><td class="sp-r">'+x.new+'</td><td class="sp-r">'+x.captured+'</td><td class="sp-r">'+x.existed+'</td><td class="sp-r">'+x.failed+'</td><td class="sp-r">'+fmt(x.amt)+'</td><td>'+badge(x.status==='OK'?'Captured':x.status)+'</td></tr>'; }).join('') : '<tr><td colspan="11" class="sp-empty">No runs yet.</td></tr>';
    });
}

/* ---- transaction detail modal ---- */
function kv(k,v){ return '<div class="k">'+esc(k)+'</div><div class="v">'+(v==null||v===''?'&mdash;':esc(v))+'</div>'; }
function spDetail(receipt){
    $('spDetTitle').textContent='Transaction '+receipt;
    $('spDetBody').innerHTML='<div class="sp-empty">Loading…</div>';
    $('spOvl').classList.add('open');
    get('act=detail&receipt='+encodeURIComponent(receipt)).then(function(d){
        if(!d.ok){ $('spDetBody').innerHTML='<div class="sp-empty" style="color:#b91c1c;">'+esc(d.message||'Not found.')+'</div>'; return; }
        var h='';
        var p=d.payment, pl=d.pull;
        /* what came in */
        h+='<div class="sp-sec"><div class="sp-sec__t">What came in (SchoolPay)</div><div class="sp-kv">';
        if(p){ h+=kv('Receipt No', p.receipt)+kv('Amount', fmt(p.amount))+kv('Channel', p.channel)+kv('Paid on', p.date)+kv('Payer / student', p.name)+kv('Reg No', p.regno); }
        if(pl){ h+=kv('Settlement bank', pl.bank)+kv('Source txn id', pl.src_txn)+kv('Student pay code', pl.pay_code); if(pl.fee_type==='SUPPLEMENTARY') h+=kv('Fee', pl.supp); }
        h+='</div></div>';
        /* what was captured */
        h+='<div class="sp-sec"><div class="sp-sec__t">What was captured (our ledger)<span>'+badge(p?p.status:'')+'</span></div>';
        if(d.ledger && d.ledger.length){
            h+='<div>';
            d.ledger.forEach(function(l){ h+='<div class="sp-ledline"><span class="lp"><b>'+esc(l.type)+'</b> &middot; '+esc(l.account)+' <span style="color:#9ca3af;">('+esc(l.particulars)+')</span></span><span class="sp-r">'+fmt(l.amount)+'</span></div>'; });
            h+='<div class="sp-note">Voucher '+esc(d.ledger[0].voucher)+' &middot; posted by '+esc(d.ledger[0].teller)+' &middot; '+esc(d.ledger[0].date)+'</div></div>';
        } else { h+='<div class="sp-note" style="color:#b45309;">Not yet posted to the ledger'+(p&&p.status==='Pending'?' — use Recapture on the Pending tab.':'.')+'</div>'; }
        h+='</div>';
        /* student */
        h+='<div class="sp-sec"><div class="sp-sec__t">Student'+(d.links?'<a class="sp-lnk" href="'+esc(d.links.profile)+'" target="_blank" rel="noopener">Open profile &#8599;</a>':'')+'</div><div class="sp-kv">';
        if(d.student){ var s=d.student; h+=kv('Name', s.name)+kv('Reg No', p?p.regno:'')+kv('Programme', (s.progid?s.progid+' — ':'')+s.programme)+kv('Faculty', s.faculty)+kv('Status', s.status)+kv('Gender', s.gender)+kv('Entry year', s.entryyear)+kv('Phone', s.phone)+kv('Email', s.email); }
        else { h+='<div class="k">Student</div><div class="v" style="color:#b91c1c;">Not resolved in student records</div>'; }
        h+='</div></div>';
        /* account */
        h+='<div class="sp-sec"><div class="sp-sec__t">Account'+(d.links?'<a class="sp-lnk" href="'+esc(d.links.ledger)+'" target="_blank" rel="noopener">Open ledger &#8599;</a>':'')+'</div><div class="sp-kv">'+kv('Current balance', d.balance)+'</div></div>';
        $('spDetBody').innerHTML=h;
    }).catch(function(){ $('spDetBody').innerHTML='<div class="sp-empty" style="color:#b91c1c;">Failed to load detail.</div>'; });
}
function spCloseDetail(){ $('spOvl').classList.remove('open'); }
document.addEventListener('keydown', function(e){ if(e.key==='Escape') spCloseDetail(); });

/* ---- auto-sync engine ---- */
var jbTimer=null;
function agoTxt(sec){ sec=Number(sec); if(isNaN(sec)||sec<0) return ''; if(sec<60) return sec+'s ago'; if(sec<3600) return Math.floor(sec/60)+'m ago'; if(sec<86400) return Math.floor(sec/3600)+'h '+Math.floor((sec%3600)/60)+'m ago'; return Math.floor(sec/86400)+'d ago'; }
function jbCell(l,v,s,err){ return '<div class="sp-jobcell'+(err?' err':'')+'"><div class="l">'+esc(l)+'</div><div class="v">'+(v==null||v===''?'&mdash;':esc(v))+'</div>'+(s?'<div class="s">'+esc(s)+'</div>':'')+'</div>'; }
function spJobStatus(){
    get('act=jobstatus').then(function(d){ if(!d.ok) return;
        $('jbInt').textContent=d.interval;
        var alive=d.engine_alive, enabled=d.enabled;
        var hbFresh=(d.hb_ago!=null && d.hb_ago>=0 && d.hb_ago <= d.interval*60*2);
        var cls, label, sub;
        if(!enabled){ cls='paused'; label='Paused'; sub='Auto-sync is turned off'; }
        else if(alive && hbFresh){ cls='on'; label='Running'; sub='Healthy · pinging every '+d.interval+' min'; }
        else if(alive && d.hb_ago==null){ cls='paused'; label='Starting…'; sub='Engine up · first ping within '+d.interval+' min'; }
        else { cls='stale'; label='Stalled'; sub='Engine not responding — click Restart engine'; }
        $('jbBadge').className='sp-jobbadge '+cls;
        $('jbBadge').innerHTML='<span class="dot"></span> '+label;
        $('jbToggleBtn').textContent = enabled ? 'Pause' : 'Resume';
        var g='';
        g+=jbCell('State', label, sub);
        g+=jbCell('Last sync', d.last_run?agoTxt(d.run_ago):'never', d.last_run||'');
        g+=jbCell('Last heartbeat', d.last_hb?agoTxt(d.hb_ago):'—', d.last_hb||'');
        g+=jbCell('Cadence', d.interval+' min', 'rolling window '+d.window_days+' day(s)');
        g+=jbCell('Last result', d.fetched+' fetched', d.captured+' posted · '+d.existed+' already had'+(d.failed>0?' · '+d.failed+' review':''));
        g+=jbCell('Lifetime', (d.total_runs||0).toLocaleString()+' runs', (d.total_captured||0).toLocaleString()+' payments recovered');
        if(d.last_message) g+=jbCell('Last message', d.last_message, '');
        if(d.last_error) g+=jbCell('Last error', d.last_error, '', true);
        if(d.worker) g+=jbCell('Worker', d.worker, d.status?('status '+d.status):'');
        $('jbGrid').innerHTML=g;
    }).catch(function(){});
}
function spJobRestart(){ get('act=jobrestart').then(function(d){ toast(d.message,d.ok); setTimeout(spJobStatus,700); }); }
function spJobRun(){ var b=$('jbRunBtn'); b.disabled=true; var o=b.innerHTML; b.innerHTML='<span class="sp-spin"></span> Running…';
    get('act=jobrun').then(function(d){ b.disabled=false; b.innerHTML=o; toast(d.message,d.ok); spJobStatus(); spStats(); })
    .catch(function(){ b.disabled=false; b.innerHTML=o; toast('Run failed (network/timeout).',false); }); }
function spJobToggle(){ var enabling=$('jbToggleBtn').textContent==='Resume';
    get('act=jobtoggle&on='+(enabling?'1':'0')).then(function(d){ toast(d.message,d.ok); spJobStatus(); }); }
function spJobAutoRefresh(on){ if(jbTimer){ clearInterval(jbTimer); jbTimer=null; } if(on){ jbTimer=setInterval(spJobStatus,15000); } }

function spRefreshAll(){ spStats(); var t=spCurrentTab(); if(t==='ov') spRecent(); else if(t==='pend') spLoadPending(); else if(t==='log') spLoadLog(); else if(t==='job') spJobStatus(); }

/* ---- init ---- */
(function(){
    var today=new Date(), wk=new Date(); wk.setDate(wk.getDate()-7);
    function iso(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
    $('recTo').value=iso(today); $('recFrom').value=iso(wk);
    spStats();
    spActivateTab(spCurrentTab());
})();
</script>
</asp:Content>
