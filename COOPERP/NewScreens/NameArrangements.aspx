<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NameArrangements.aspx.cs" Inherits="COOPERP_NewScreens_NameArrangements" Title="Name Arrangements" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.na-wrap{max-width:1320px;margin:0 auto;padding:10px 12px 24px;font-size:12px;color:#1a1a2e;}
.na-head{display:flex;flex-wrap:wrap;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:12px;}
.na-title{font-size:17px;font-weight:800;color:#05275C;letter-spacing:-.02em;margin:0 0 3px;}
.na-sub{font-size:11px;color:#64748b;line-height:1.5;max-width:700px;margin:0;}
.na-scope{display:inline-flex;align-items:center;gap:6px;padding:5px 9px;background:#f5f7fa;border:1px solid #e0e5ed;font-size:10.5px;color:#05275C;font-weight:700;}

.na-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:8px;margin-bottom:12px;}
.na-kpi{border:1px solid #e0e5ed;border-radius:4px;padding:9px 10px;background:#fff;min-width:0;}
.na-kpi__l{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;margin-bottom:3px;}
.na-kpi__v{font-size:20px;font-weight:800;color:#05275C;line-height:1;}

.na-bar{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px;margin-bottom:12px;align-items:end;}
.na-f{display:flex;flex-direction:column;gap:4px;min-width:0;}
.na-f label{font-size:9.5px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;}
.na-f input,.na-f select{width:100%;padding:7px 8px;border:1px solid #e0e5ed;border-radius:0;font-size:12px;font-family:inherit;color:#1a1a2e;background:#fff;}
.na-f input:focus,.na-f select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 2px rgba(23,77,164,.10);}

.na-btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;padding:8px 14px;border:1px solid #05275C;background:#05275C;color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;}
.na-btn:hover{background:#0a3573;}
.na-btn--ghost{background:#fff;color:#05275C;}
.na-btn--ghost:hover{background:#f5f7fa;}
.na-btn--undo{background:#b45309;border-color:#b45309;}
.na-btn--undo:hover{background:#92400e;}
.na-btn--sm{padding:4px 9px;font-size:10px;}
.na-btn[disabled]{opacity:.45;cursor:not-allowed;}

.na-tblwrap{overflow-x:auto;border:1px solid #e0e5ed;border-radius:4px;background:#fff;}
table.na-tbl{width:100%;border-collapse:collapse;font-size:11px;min-width:940px;}
table.na-tbl th{background:#f5f7fa;color:#05275C;font-size:9.5px;text-transform:uppercase;letter-spacing:.35px;text-align:left;padding:7px;border-bottom:1px solid #e0e5ed;white-space:nowrap;font-weight:800;}
table.na-tbl td{padding:7px;border-bottom:1px solid #f1f5f9;vertical-align:top;}
table.na-tbl tr:last-child td{border-bottom:none;}
table.na-tbl tr.rev td{background:#fafafa;}
.na-mono{font-family:ui-monospace,Menlo,Consolas,monospace;font-weight:700;color:#05275C;}
.na-sm{font-size:10px;color:#64748b;display:block;margin-top:2px;}
.na-from{color:#b91c1c;text-decoration:line-through;text-decoration-thickness:1px;}
.na-to{color:#0b5c3a;font-weight:700;}
.na-badge{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;}
.na-badge--stud{background:#e8f0fc;color:#174DA4;}
.na-badge--rev{background:#f1f5f9;color:#475569;}
.na-badge--drift{background:#fef3c7;color:#92400e;}

.na-pager{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-top:10px;flex-wrap:wrap;font-size:11px;color:#64748b;}
.na-msg{padding:9px 11px;border-radius:4px;font-size:11px;margin-bottom:11px;display:none;line-height:1.5;}
.na-msg.show{display:block;}
.na-msg.err{background:#fef2f2;border:1px solid #fecaca;color:#991b1b;}
.na-msg.ok{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;}
.na-msg.warn{background:#fffbeb;border:1px solid #fde68a;color:#92400e;}
.na-loader{display:none;align-items:center;justify-content:center;gap:8px;font-size:11px;color:#64748b;padding:22px 0;}
.na-loader.show{display:flex;}
.na-spin{width:14px;height:14px;border:2px solid #e0e5ed;border-top-color:#174DA4;border-radius:50%;animation:naspin .7s linear infinite;}
@keyframes naspin{to{transform:rotate(360deg);}}
@media (max-width:640px){.na-wrap{padding:8px;}}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="na-wrap">

  <div class="na-head">
    <div style="min-width:0;">
      <h1 class="na-title">Name Arrangements</h1>
      <p class="na-sub">Every name a student has reordered in the portal, and the means to put one back. Students may reorder the words of their name but never change them &mdash; the words are checked to be identical &mdash; so nothing new is claimed here, only a different order.</p>
    </div>
    <div class="na-scope">
      <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
      <asp:Literal ID="litScope" runat="server" />
    </div>
  </div>

  <div class="na-msg" id="naMsg"></div>

  <div class="na-kpis">
    <div class="na-kpi"><div class="na-kpi__l">Entries</div><div class="na-kpi__v" id="kAll">0</div></div>
    <div class="na-kpi"><div class="na-kpi__l">By students</div><div class="na-kpi__v" id="kStud">0</div></div>
    <div class="na-kpi"><div class="na-kpi__l">Put back by staff</div><div class="na-kpi__v" id="kRev">0</div></div>
    <div class="na-kpi"><div class="na-kpi__l">Changed since</div><div class="na-kpi__v" id="kDrift">0</div></div>
  </div>

  <div class="na-bar">
    <div class="na-f"><label>Search</label><input type="text" id="naQ" placeholder="Reg no, entry no, name or who" /></div>
    <div class="na-f"><label>Show</label>
      <select id="naKind"><option value="">Everything</option><option value="STUDENT">Student rearrangements</option><option value="REVERSAL">Put back by staff</option></select></div>
    <div class="na-f"><label>Per page</label><select id="naPs"><option>25</option><option>50</option><option>100</option></select></div>
    <div class="na-f"><label>&nbsp;</label><button type="button" class="na-btn" id="naGo">Apply</button></div>
  </div>

  <div class="na-loader show" id="naLoad"><span class="na-spin"></span> Loading&hellip;</div>

  <div class="na-tblwrap" id="naTblWrap" style="display:none;">
    <table class="na-tbl">
      <thead><tr><th>Student</th><th>Programme</th><th>From &rarr; to</th><th>Now reads</th><th>Who and when</th><th>Type</th><th></th></tr></thead>
      <tbody id="naRows"></tbody>
    </table>
  </div>

  <div class="na-pager" id="naPager" style="display:none;">
    <span id="naCount"></span>
    <div style="display:flex;gap:6px;">
      <button type="button" class="na-btn na-btn--ghost na-btn--sm" id="naPrev">Previous</button>
      <button type="button" class="na-btn na-btn--ghost na-btn--sm" id="naNext">Next</button>
    </div>
  </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
var PAGE=1, TOTAL=0, PS=25;
function q(i){return document.getElementById(i);}
function esc(s){return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
function n(v){return (Number(v)||0).toLocaleString('en-US');}

function ajax(m,p,cb){
  var x=new XMLHttpRequest();
  x.open('POST','NameArrangements.aspx/'+m,true);
  x.setRequestHeader('Content-Type','application/json; charset=utf-8');
  x.timeout=300000;
  x.onload=function(){
    var o=null;
    try{ o=JSON.parse(x.responseText); o=(typeof o.d==='string')?JSON.parse(o.d):o.d; }catch(e){}
    if(!o) return cb({success:false,message:/login|sign in|<!DOCTYPE/i.test(x.responseText||'')
      ? 'Your session has expired. Sign in again — nothing was changed.' : 'The server did not return valid data.'});
    cb(o);
  };
  x.onerror=function(){cb({success:false,message:'Network error — nothing was changed.'});};
  x.ontimeout=function(){cb({success:false,message:'That took too long.'});};
  x.send(JSON.stringify(p||{}));
}

function msg(t,k){var m=q('naMsg'); if(!t){m.className='na-msg';m.innerHTML='';return;} m.className='na-msg show '+(k||'err'); m.innerHTML=esc(t);}

function load(){
  q('naLoad').className='na-loader show';
  q('naTblWrap').style.display='none'; q('naPager').style.display='none';
  PS=Number(q('naPs').value)||25;
  ajax('GetList',{q:q('naQ').value.trim(),kind:q('naKind').value,page:PAGE,pageSize:PS},function(r){
    q('naLoad').className='na-loader';
    if(!r.success){ msg(r.message||'Could not load.'); return; }
    msg('');
    TOTAL=r.total;
    var items=r.items||[], h='';
    items.forEach(function(x){
      h+='<tr'+(x.isReversal?' class="rev"':'')+'>'
        +'<td><span class="na-mono">'+esc(x.regno)+'</span>'
          +'<span class="na-sm">#'+esc(x.id)+(x.entryno?' · '+esc(x.entryno):'')+'</span></td>'
        +'<td>'+esc(x.progid||'—')+'</td>'
        +'<td><span class="na-from">'+esc(x.oldFull)+'</span><br/><span class="na-to">'+esc(x.newFull)+'</span></td>'
        +'<td>'+esc(x.currentFull||'—')
          +(x.drifted?'<span class="na-sm"><span class="na-badge na-badge--drift">changed since</span></span>':'')+'</td>'
        +'<td>'+esc(x.by)+'<span class="na-sm">'+esc(x.at)+(x.ip?' · '+esc(x.ip):'')+'</span>'
          +(x.reason?'<span class="na-sm" style="color:#92400e;">“'+esc(x.reason)+'”</span>':'')+'</td>'
        +'<td><span class="na-badge '+(x.isReversal?'na-badge--rev">Put back':'na-badge--stud">Student')+'</span>'
          +(x.reversalOf?'<span class="na-sm">undoes #'+esc(x.reversalOf)+'</span>':'')+'</td>'
        +'<td style="white-space:nowrap;">'
          +(x.canReverse
              ? '<button type="button" class="na-btn na-btn--undo na-btn--sm" data-rev="'+x.id+'" data-old="'+esc(x.oldFull)+'" data-reg="'+esc(x.regno)+'">Put back</button>'
              : '<span style="color:#94a3b8;font-size:10px;">'+(x.isReversal?'—':(x.drifted?'name changed since':'nothing to undo'))+'</span>')
        +'</td></tr>';
    });
    q('naRows').innerHTML = h || '<tr><td colspan="7" style="text-align:center;padding:30px;color:#94a3b8;">No name arrangements recorded yet.</td></tr>';
    q('kAll').textContent=n(TOTAL); q('kStud').textContent=n(r.nStudent);
    q('kRev').textContent=n(r.nReversal); q('kDrift').textContent=n(r.nDrift);
    q('naTblWrap').style.display=''; q('naPager').style.display='flex';
    var from=(PAGE-1)*PS+1, to=Math.min(PAGE*PS,TOTAL);
    q('naCount').textContent = TOTAL ? ('Showing '+n(from)+'–'+n(to)+' of '+n(TOTAL)) : 'Nothing to show';
    q('naPrev').disabled=PAGE<=1; q('naNext').disabled=PAGE*PS>=TOTAL;
    wire();
  });
}

function wire(){
  var b=q('naRows').querySelectorAll('[data-rev]');
  for(var i=0;i<b.length;i++) b[i].addEventListener('click',function(){
    var id=+this.getAttribute('data-rev'), old=this.getAttribute('data-old'), reg=this.getAttribute('data-reg');
    var reason=window.prompt('Put '+reg+"'s name back to:\n\n"+old+
      '\n\nThis is recorded as a new entry against your name.\nWhy is it being put back?','');
    if(reason===null) return;
    if(reason.trim().length<5){ msg('Give a reason of at least five characters.'); return; }
    var btn=this; btn.disabled=true; btn.textContent='Working…';
    ajax('Reverse',{id:id,reason:reason.trim()},function(r){
      if(!r.success){ msg(r.message||'It could not be put back.'); btn.disabled=false; btn.textContent='Put back'; return; }
      msg(r.message,'ok'); load();
    });
  });
}

q('naGo').addEventListener('click',function(){PAGE=1;load();});
q('naQ').addEventListener('keydown',function(e){ if(e.keyCode===13){PAGE=1;load();} });
q('naKind').addEventListener('change',function(){PAGE=1;load();});
q('naPs').addEventListener('change',function(){PAGE=1;load();});
q('naPrev').addEventListener('click',function(){ if(PAGE>1){PAGE--;load();} });
q('naNext').addEventListener('click',function(){ if(PAGE*PS<TOTAL){PAGE++;load();} });
load();
})();
</script>
</asp:Content>
