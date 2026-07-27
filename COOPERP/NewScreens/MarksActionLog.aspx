<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksActionLog.aspx.cs" Inherits="COOPERP_NewScreens_MarksActionLog" Title="Admin Action Log" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.mal-wrap{padding:16px;max-width:1500px;margin:0 auto;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;}
.mal-hd{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:14px;}
.mal-hd h1{margin:0;font-size:17px;font-weight:800;color:#05275C;}
.mal-hd p{margin:3px 0 0;font-size:12px;color:#64748b;}
.mal-win{display:flex;align-items:center;gap:6px;font-size:11px;color:#475569;white-space:nowrap;}
.mal-sel,.mal-inp{padding:7px 9px;font-size:12px;border:1px solid #cdd5e1;background:#fff;border-radius:0;color:#1a1a2e;}
.mal-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;margin-bottom:12px;}
.mal-kpi{border:1px solid #e0e5ed;background:#fff;padding:12px 14px;border-left:3px solid #05275C;}
.mal-kpi .v{font-size:22px;font-weight:800;color:#05275C;line-height:1;}
.mal-kpi .l{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;margin-top:5px;}
.mal-kpi--warn{border-left-color:#dc3545;} .mal-kpi--warn .v{color:#b42318;}
.mal-kpi--ok{border-left-color:#16a34a;}
.mal-grid{display:grid;grid-template-columns:1fr 260px;gap:12px;align-items:start;}
@media(max-width:1050px){.mal-grid{grid-template-columns:1fr;}}
.mal-card{background:#fff;border:1px solid #e0e5ed;}
.mal-toolbar{display:flex;gap:8px;flex-wrap:wrap;align-items:center;padding:10px 12px;border-bottom:1px solid #e0e5ed;}
.mal-search{flex:1 1 200px;min-width:150px;}
.mal-tw{overflow-x:auto;max-height:600px;overflow-y:auto;}
.mal-tbl{width:100%;border-collapse:collapse;font-size:11px;min-width:820px;}
.mal-tbl th{position:sticky;top:0;background:#05275C;color:#fff;text-align:left;padding:8px 10px;font-size:10px;font-weight:700;white-space:nowrap;text-transform:uppercase;letter-spacing:.3px;}
.mal-tbl td{padding:6px 10px;border-bottom:1px solid #eef2f7;vertical-align:middle;}
.mal-tbl tbody tr:nth-child(even){background:#f6f8fb;}
.mal-row{cursor:pointer;} .mal-row:hover{background:#e8f0fd !important;}
.mal-when{white-space:nowrap;color:#475569;}
.mal-user{font-weight:600;color:#05275C;}
.mal-act{font-family:Consolas,monospace;font-size:10px;color:#174DA4;font-weight:700;}
.mal-b{display:inline-block;padding:1px 7px;font-size:9px;font-weight:700;border-radius:2px;text-transform:uppercase;background:#eef1f6;color:#64748b;}
.mal-b--success{background:#e7f6ec;color:#15803d;}
.mal-b--error{background:#fdeaea;color:#b91c1c;}
.mal-b--auth_fail{background:#fdeaea;color:#b91c1c;}
.mal-b--validation_fail{background:#fef6e7;color:#b45309;}
.mal-b--locked{background:#eef1f6;color:#6b7280;}
.mal-b--idle_timeout{background:#eef2ff;color:#4338ca;}
.mal-side .mal-card{margin-bottom:12px;padding:12px;}
.mal-side h3{margin:0 0 8px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#05275C;}
.mal-mini{display:flex;align-items:center;justify-content:space-between;font-size:11px;padding:4px 0;border-bottom:1px solid #f0f2f6;}
.mal-mini:last-child{border-bottom:none;}
.mal-mini b{color:#05275C;}
.mal-empty{text-align:center;color:#94a3b8;padding:26px;font-size:12px;}
.mal-ovl{display:none;position:fixed;inset:0;background:rgba(10,20,40,.5);z-index:10000;align-items:center;justify-content:center;padding:20px;}
.mal-ovl.open{display:flex;}
.mal-modal{background:#fff;width:560px;max-width:96vw;max-height:88vh;display:flex;flex-direction:column;box-shadow:0 16px 48px rgba(0,0,0,.28);}
.mal-modal__hd{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-bottom:1px solid #e0e5ed;}
.mal-modal__hd h3{margin:0;font-size:14px;color:#05275C;}
.mal-modal__x{background:none;border:none;font-size:22px;line-height:1;color:#888;cursor:pointer;}
.mal-modal__bd{padding:14px 16px;overflow-y:auto;}
.mal-kv{display:grid;grid-template-columns:120px 1fr;gap:5px 10px;font-size:12px;margin-bottom:12px;}
.mal-kv .k{color:#64748b;} .mal-kv .v{color:#1a1a2e;font-weight:500;word-break:break-word;}
.mal-ctx{background:#0f172a;color:#a8e6cf;font-family:Consolas,monospace;font-size:11px;padding:10px 12px;white-space:pre-wrap;word-break:break-word;max-height:260px;overflow:auto;}
.mal-btn{padding:7px 12px;font-size:12px;font-weight:600;border:1px solid #cdd5e1;background:#fff;color:#05275C;cursor:pointer;}
.mal-btn:hover{background:#eef4fd;}
/* action label (human) + raw code */
.mal-actwrap{display:flex;flex-direction:column;line-height:1.25;}
.mal-actlbl{font-weight:700;color:#05275C;font-size:11px;}
.mal-actcode{font-family:Consolas,monospace;font-size:9px;color:#94a3b8;}
.mal-sum{color:#475569;font-size:10.5px;max-width:320px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.mal-sum b{color:#05275C;font-weight:600;}
.mal-dur{display:inline-block;padding:1px 6px;border-radius:2px;font-size:10px;font-weight:600;background:#eef1f6;color:#64748b;}
.mal-dur--slow{background:#fef6e7;color:#b45309;}
/* KPI accent for avg */
.mal-kpi--info{border-left-color:#0277bd;} .mal-kpi--info .v{color:#0277bd;}
/* modal — richer */
.mal-modal{width:600px;}
.mal-msec{margin-bottom:14px;}
.mal-msec__h{font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#94a3b8;font-weight:700;margin:0 0 6px;display:flex;align-items:center;gap:6px;}
.mal-msec__h::after{content:'';flex:1;height:1px;background:#eef2f7;}
.mal-mhero{display:flex;align-items:center;gap:10px;padding:10px 12px;background:#f6f8fb;border:1px solid #eef2f7;border-left:3px solid #05275C;margin-bottom:14px;}
.mal-mhero__ic{width:34px;height:34px;border-radius:7px;background:#05275C;color:#fff;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;}
.mal-mhero__t{font-size:14px;font-weight:800;color:#05275C;line-height:1.2;}
.mal-mhero__s{font-size:10.5px;color:#64748b;margin-top:1px;}
.mal-ctxtbl{width:100%;border-collapse:collapse;font-size:11.5px;}
.mal-ctxtbl td{padding:5px 8px;border-bottom:1px solid #f0f2f6;vertical-align:top;word-break:break-word;}
.mal-ctxtbl td.k{color:#64748b;width:130px;white-space:nowrap;font-weight:600;}
.mal-ctxtbl td.v{color:#1a1a2e;}
.mal-raw-toggle{font-size:10px;color:#174DA4;cursor:pointer;font-weight:600;user-select:none;}
.mal-raw-toggle:hover{text-decoration:underline;}
.mal-none{color:#94a3b8;font-style:italic;font-size:11px;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="mal-wrap">
    <div class="mal-hd">
        <div>
            <h1>Admin Action Log</h1>
            <p>Independent trace of every admin / manager action across the marks module &mdash; who did what, when, from where, and the outcome.</p>
        </div>
        <div class="mal-win"><label>Window</label>
            <select id="malDays" class="mal-sel">
                <option value="1">Today</option>
                <option value="7" selected="selected">Last 7 days</option>
                <option value="30">Last 30 days</option>
                <option value="90">Last 90 days</option>
                <option value="3650">All time</option>
            </select>
        </div>
    </div>

    <div class="mal-kpis">
        <div class="mal-kpi"><div class="v" id="kTotal">&mdash;</div><div class="l">Actions (all time)</div></div>
        <div class="mal-kpi"><div class="v" id="kWindow">&mdash;</div><div class="l">In selected window</div></div>
        <div class="mal-kpi mal-kpi--ok"><div class="v" id="kToday">&mdash;</div><div class="l">Today</div></div>
        <div class="mal-kpi"><div class="v" id="kUsers">&mdash;</div><div class="l">Distinct users</div></div>
        <div class="mal-kpi mal-kpi--info"><div class="v" id="kAvg">&mdash;</div><div class="l">Avg response (ms)</div></div>
        <div class="mal-kpi mal-kpi--warn"><div class="v" id="kProblems">&mdash;</div><div class="l">Errors / failures</div></div>
    </div>

    <div class="mal-grid">
        <div class="mal-card">
            <div class="mal-toolbar">
                <input type="text" id="malQ" class="mal-inp mal-search" placeholder="Search user, student, IP or context&hellip;" />
                <select id="malAction" class="mal-sel" title="Filter by action type"><option value="">All actions</option></select>
                <select id="malPage" class="mal-sel" title="Filter by page"><option value="ALL">All pages</option></select>
                <select id="malOutcome" class="mal-sel" title="Filter by outcome"><option value="all">All outcomes</option></select>
                <select id="malLimit" class="mal-sel" title="Rows to show"><option value="50">50</option><option value="100" selected="selected">100</option><option value="200">200</option><option value="500">500</option></select>
                <button type="button" class="mal-btn" id="malRefresh">&#8635; Refresh</button>
            </div>
            <div class="mal-tw">
                <table class="mal-tbl">
                    <thead><tr><th>When</th><th>User</th><th>Page</th><th>Action</th><th>Summary</th><th>Outcome</th><th>Duration</th><th>IP</th></tr></thead>
                    <tbody id="malBody"><tr><td colspan="8" class="mal-empty">Loading&hellip;</td></tr></tbody>
                </table>
            </div>
        </div>
        <div class="mal-side">
            <div class="mal-card"><h3>Most active users</h3><div id="malTopUsers"><div class="mal-empty">&mdash;</div></div></div>
            <div class="mal-card"><h3>Busiest pages</h3><div id="malTopPages"><div class="mal-empty">&mdash;</div></div></div>
        </div>
    </div>
</div>

<div class="mal-ovl" id="malOvl">
    <div class="mal-modal">
        <div class="mal-modal__hd"><h3 id="malMTitle">Action detail</h3><button type="button" class="mal-modal__x" id="malMClose">&times;</button></div>
        <div class="mal-modal__bd" id="malMBody"></div>
    </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
function $(id){ return document.getElementById(id); }
function esc(s){ s=(s==null?'':''+s); return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function fmt(n){ n=Number(n)||0; return n.toLocaleString('en-US'); }
function get(params){ return fetch('MarksActionLog.aspx?'+params,{credentials:'same-origin',headers:{'X-Requested-With':'XMLHttpRequest'}}).then(function(r){return r.json();}); }
var _rows=[];

/* ── humanizers: turn raw codes into readable labels ── */
var ACT_LABELS={SESSION_SECURITY:'Session security',IDLE_TIMEOUT:'Idle timeout',dropdowns:'Load dropdowns',init:'Initialize',view_record:'View record',edit_marks:'Edit marks',unlocks:'Unlock record',publish:'Publish',search:'Search',summary:'Summary',logs:'View logs',delete_registration:'Delete registration',create_registration:'Create registration'};
function titleCase(s){ s=(''+s).replace(/[_:]+/g,' ').trim(); return s.replace(/\w\S*/g,function(t){return t.charAt(0).toUpperCase()+t.slice(1);}); }
function actLabel(a){ if(a==null||a==='') return '—'; if(ACT_LABELS[a]) return ACT_LABELS[a]; if(/^force_status:/i.test(a)) return 'Force status → '+titleCase(a.split(':')[1]||''); if(/^bulk:/i.test(a)) return 'Bulk → '+titleCase(a.split(':')[1]||''); return titleCase(a); }
var OUT_LABELS={success:'Success',error:'Error',auth_fail:'Auth fail',validation_fail:'Validation',locked:'Locked',idle_timeout:'Idle timeout'};
function outClass(o){ o=(''+(o||'')).toLowerCase(); return o.replace(/[^a-z_]/g,''); }
function outLabel(o){ o=(''+(o||'')).toLowerCase(); return OUT_LABELS[o]||titleCase(o||'—'); }
var CTX_LABELS={id:'Record ID',actor:'Performed by',status:'New status',comment:'Comment',cw:'Course work',exam:'Exam mark',total:'Total',note:'Note / reason',regno:'Student',course:'Course',reason:'Reason'};
function ctxLabel(k){ return CTX_LABELS[k]||titleCase(k); }
function parseCtx(s){ if(!s) return null; try{ var o=JSON.parse(s); return (o&&typeof o==='object'&&!Array.isArray(o))?o:null; }catch(e){ return null; } }
function ctxSummary(r){
    var o=parseCtx(r.ctx); if(!o) return '';
    var b=[];
    if(o.id) b.push('#'+esc(o.id));
    if(o.regno) b.push(esc(o.regno));
    if(o.course) b.push(esc(o.course));
    if(o.status) b.push('&rarr; <b>'+esc(o.status)+'</b>');
    if(o.cw!=null||o.exam!=null||o.total!=null) b.push('CW '+esc(o.cw==null?'-':o.cw)+' &middot; Exam '+esc(o.exam==null?'-':o.exam)+' &middot; Tot '+esc(o.total==null?'-':o.total));
    var n=o.note||o.comment; if(n){ n=''+n; b.push('&ldquo;'+esc(n.slice(0,50))+(n.length>50?'…':'')+'&rdquo;'); }
    if(!b.length&&o.actor) b.push('by '+esc(o.actor));
    return b.join(' &middot; ');
}
function durCell(ms){ ms=Number(ms)||0; return '<span class="mal-dur'+(ms>=800?' mal-dur--slow':'')+'">'+fmt(ms)+' ms</span>'; }
function fillOpts(sel,items,fv,ft,lab){ if(!sel||!items) return; var cur=sel.value; var h='<option value="'+fv+'">'+ft+'</option>'; items.forEach(function(v){ h+='<option value="'+esc(v)+'">'+esc(lab?lab(v):v)+'</option>'; }); sel.innerHTML=h; sel.value=cur; }

function loadStats(){
    get('ajax=stats&days='+$('malDays').value).then(function(d){
        if(!d.ok) return;
        $('kTotal').textContent=fmt(d.total); $('kWindow').textContent=fmt(d.window);
        $('kToday').textContent=fmt(d.today); $('kUsers').textContent=fmt(d.users);
        $('kAvg').textContent=fmt(d.avgms); $('kProblems').textContent=fmt(d.problems);
        $('malTopUsers').innerHTML=(d.top_users&&d.top_users.length)?d.top_users.map(function(x){return '<div class="mal-mini"><span>'+esc(x.k||'(unknown)')+'</span><b>'+fmt(x.n)+'</b></div>';}).join(''):'<div class="mal-empty">No data</div>';
        $('malTopPages').innerHTML=(d.top_pages&&d.top_pages.length)?d.top_pages.map(function(x){return '<div class="mal-mini"><span>'+esc(x.k||'(unknown)')+'</span><b>'+fmt(x.n)+'</b></div>';}).join(''):'<div class="mal-empty">No data</div>';
    });
}
function loadFeed(){
    var body=$('malBody');
    var p='ajax=feed&days='+$('malDays').value+'&limit='+$('malLimit').value
        +'&q='+encodeURIComponent($('malQ').value)+'&page='+encodeURIComponent($('malPage').value)
        +'&outcome='+encodeURIComponent($('malOutcome').value)+'&action='+encodeURIComponent($('malAction').value);
    get(p).then(function(d){
        if(!d.ok){ body.innerHTML='<tr><td colspan="8" class="mal-empty" style="color:#b42318;">'+esc(d.message||'Failed to load.')+'</td></tr>'; return; }
        _rows=d.rows||[];
        fillOpts($('malPage'),d.pages,'ALL','All pages',null);
        fillOpts($('malAction'),d.actions,'','All actions',actLabel);
        fillOpts($('malOutcome'),d.outcomes,'all','All outcomes',outLabel);
        if(!_rows.length){ body.innerHTML='<tr><td colspan="8" class="mal-empty">No actions match your filters.</td></tr>'; return; }
        body.innerHTML=_rows.map(function(r,i){
            var sum=ctxSummary(r);
            return '<tr class="mal-row" data-i="'+i+'">'
                +'<td class="mal-when">'+esc(r.ts)+'</td>'
                +'<td class="mal-user">'+esc(r.user||'(unknown)')+'</td>'
                +'<td>'+esc(r.page)+'</td>'
                +'<td><div class="mal-actwrap"><span class="mal-actlbl">'+esc(actLabel(r.action))+'</span><span class="mal-actcode">'+esc(r.action)+'</span></div></td>'
                +'<td class="mal-sum">'+(sum||'<span style="color:#cbd5e1;">&mdash;</span>')+'</td>'
                +'<td><span class="mal-b mal-b--'+outClass(r.outcome)+'">'+esc(outLabel(r.outcome))+'</span></td>'
                +'<td>'+durCell(r.dur)+'</td>'
                +'<td style="font-size:10px;color:#94a3b8;">'+esc(r.ip)+'</td></tr>';
        }).join('');
        var trs=body.querySelectorAll('.mal-row');
        for(var j=0;j<trs.length;j++) trs[j].onclick=function(){ detail(_rows[parseInt(this.getAttribute('data-i'),10)]); };
    });
}
function detail(r){
    if(!r) return;
    $('malMTitle').textContent='Action detail';
    var o=parseCtx(r.ctx);
    /* hero */
    var h='<div class="mal-mhero"><div class="mal-mhero__ic">&#9670;</div>'
        +'<div><div class="mal-mhero__t">'+esc(actLabel(r.action))+'</div>'
        +'<div class="mal-mhero__s">'+esc(r.page||'')+'  &middot;  <span class="mal-b mal-b--'+outClass(r.outcome)+'">'+esc(outLabel(r.outcome))+'</span></div></div></div>';
    /* who/when/where */
    function row(k,v){ return '<tr><td class="k">'+esc(k)+'</td><td class="v">'+(v==null||v===''?'<span class="mal-none">not recorded</span>':v)+'</td></tr>'; }
    h+='<div class="mal-msec"><div class="mal-msec__h">Who &amp; When</div><table class="mal-ctxtbl">'
        +row('Performed by','<strong>'+esc(r.user||'(unknown)')+'</strong>')
        +row('Timestamp',esc(r.ts))
        +row('Page / screen',esc(r.page))
        +row('Action code','<span class="mal-actcode" style="font-size:11px;">'+esc(r.action)+'</span>')
        +row('Outcome','<span class="mal-b mal-b--'+outClass(r.outcome)+'">'+esc(outLabel(r.outcome))+'</span>')
        +row('Duration',durCell(r.dur))
        +row('IP address',esc(r.ip))
        +(r.corr?row('Correlation ID','<span class="mal-actcode" style="font-size:11px;">'+esc(r.corr)+'</span>'):'')
        +'</table></div>';
    /* parsed context */
    if(o){
        var keys=Object.keys(o), body2='';
        keys.forEach(function(k){ var val=o[k]; if(val==null||val==='') return; body2+='<tr><td class="k">'+esc(ctxLabel(k))+'</td><td class="v">'+esc(''+val)+'</td></tr>'; });
        if(body2) h+='<div class="mal-msec"><div class="mal-msec__h">Details</div><table class="mal-ctxtbl">'+body2+'</table></div>';
    }
    /* raw json (collapsible) */
    if(r.ctx){
        var raw=''; try{ raw=JSON.stringify(JSON.parse(r.ctx),null,2); }catch(e){ raw=r.ctx; }
        h+='<div class="mal-msec"><div class="mal-msec__h">Raw context <span class="mal-raw-toggle" id="malRawT">show</span></div>'
          +'<div class="mal-ctx" id="malRaw" style="display:none;">'+esc(raw)+'</div></div>';
    }
    $('malMBody').innerHTML=h;
    var rt=$('malRawT'); if(rt) rt.onclick=function(){ var el=$('malRaw'); var on=el.style.display==='none'; el.style.display=on?'block':'none'; this.textContent=on?'hide':'show'; };
    $('malOvl').classList.add('open');
}
function reload(){ loadStats(); loadFeed(); }
$('malDays').onchange=reload;
$('malLimit').onchange=loadFeed;
$('malPage').onchange=loadFeed;
$('malOutcome').onchange=loadFeed;
$('malAction').onchange=loadFeed;
$('malRefresh').onclick=reload;
$('malQ').onkeydown=function(e){ if(e.key==='Enter') loadFeed(); };
$('malMClose').onclick=function(){ $('malOvl').classList.remove('open'); };
$('malOvl').onclick=function(e){ if(e.target===this) this.classList.remove('open'); };
document.addEventListener('keydown',function(e){ if(e.key==='Escape') $('malOvl').classList.remove('open'); });
reload();
})();
</script>
</asp:Content>
