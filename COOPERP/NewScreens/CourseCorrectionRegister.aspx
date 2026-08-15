<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="CourseCorrectionRegister.aspx.cs" Inherits="COOPERP_NewScreens_CourseCorrectionRegister" Title="Correction Register" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.cr-wrap{max-width:1320px;margin:0 auto;padding:10px 12px 24px;font-size:12px;color:#1a1a2e;}
.cr-head{display:flex;flex-wrap:wrap;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:12px;}
.cr-title{font-size:17px;font-weight:800;color:#05275C;letter-spacing:-.02em;margin:0 0 3px;}
.cr-sub{font-size:11px;color:#64748b;line-height:1.5;max-width:720px;margin:0;}
.cr-scope{display:inline-flex;align-items:center;gap:6px;padding:5px 9px;background:#f5f7fa;border:1px solid #e0e5ed;font-size:10.5px;color:#05275C;font-weight:700;}

.cr-bar{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px;margin-bottom:12px;align-items:end;}
.cr-f{display:flex;flex-direction:column;gap:4px;min-width:0;}
.cr-f label{font-size:9.5px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;}
.cr-f input,.cr-f select,.cr-f textarea{width:100%;padding:7px 8px;border:1px solid #e0e5ed;border-radius:0;font-size:12px;font-family:inherit;color:#1a1a2e;background:#fff;}
.cr-f input:focus,.cr-f select:focus,.cr-f textarea:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 2px rgba(23,77,164,.10);}

.cr-btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;padding:8px 14px;border:1px solid #05275C;background:#05275C;color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;text-decoration:none;}
.cr-btn:hover{background:#0a3573;color:#fff;}
.cr-btn--ghost{background:#fff;color:#05275C;}
.cr-btn--ghost:hover{background:#f5f7fa;}
.cr-btn--danger{background:#b42318;border-color:#b42318;}
.cr-btn--danger:hover{background:#991b12;}
.cr-btn[disabled]{opacity:.45;cursor:not-allowed;}
.cr-btn--sm{padding:4px 9px;font-size:10px;}

.cr-tblwrap{overflow-x:auto;border:1px solid #e0e5ed;border-radius:4px;background:#fff;}
table.cr-tbl{width:100%;border-collapse:collapse;font-size:11px;min-width:900px;}
table.cr-tbl th{background:#f5f7fa;color:#05275C;font-size:9.5px;text-transform:uppercase;letter-spacing:.35px;text-align:left;padding:7px;border-bottom:1px solid #e0e5ed;white-space:nowrap;font-weight:800;}
table.cr-tbl td{padding:7px;border-bottom:1px solid #f1f5f9;vertical-align:top;}
table.cr-tbl tr:last-child td{border-bottom:none;}
table.cr-tbl tr.rev td{background:#fafafa;color:#78716c;}
.cr-mono{font-family:ui-monospace,Menlo,Consolas,monospace;font-weight:700;color:#05275C;}
.cr-sm{font-size:10px;color:#64748b;display:block;margin-top:2px;}
.cr-badge{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;}
.cr-badge.applied{background:#dcfce7;color:#166534;}
.cr-badge.reversed{background:#e2e8f0;color:#475569;}
.cr-badge.partial{background:#fef3c7;color:#92400e;}
.cr-badge.op{background:#e8f0fc;color:#174DA4;}
.cr-arrow{color:#94a3b8;padding:0 3px;}

.cr-pager{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-top:10px;flex-wrap:wrap;font-size:11px;color:#64748b;}
.cr-pager__b{display:flex;gap:6px;}

.cr-msg{padding:9px 11px;border-radius:4px;font-size:11px;margin-bottom:11px;display:none;line-height:1.5;}
.cr-msg.show{display:block;}
.cr-msg.err{background:#fef2f2;border:1px solid #fecaca;color:#991b1b;}
.cr-msg.ok{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;}
.cr-msg.warn{background:#fffbeb;border:1px solid #fde68a;color:#92400e;}

.cr-loader{display:none;align-items:center;gap:8px;font-size:11px;color:#64748b;padding:20px 0;justify-content:center;}
.cr-loader.show{display:flex;}
.cr-spin{width:14px;height:14px;border:2px solid #e0e5ed;border-top-color:#174DA4;border-radius:50%;animation:crspin .7s linear infinite;}
@keyframes crspin{to{transform:rotate(360deg);}}

/* drawer */
.cr-ov{position:fixed;inset:0;background:rgba(5,39,92,.42);display:none;z-index:1000;}
.cr-ov.show{display:block;}
.cr-dw{position:fixed;top:0;right:0;bottom:0;width:min(760px,100%);background:#fff;z-index:1001;display:none;flex-direction:column;box-shadow:-8px 0 28px rgba(5,39,92,.16);}
.cr-dw.show{display:flex;}
.cr-dw__h{padding:12px 14px;border-bottom:1px solid #e0e5ed;display:flex;justify-content:space-between;align-items:flex-start;gap:10px;}
.cr-dw__t{font-size:14px;font-weight:800;color:#05275C;margin:0;}
.cr-dw__b{padding:14px;overflow:auto;flex:1;}
.cr-x{background:none;border:none;font-size:20px;line-height:1;color:#64748b;cursor:pointer;padding:0 4px;}
.cr-meta{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:8px;margin-bottom:12px;}
.cr-meta__i{border:1px solid #e0e5ed;padding:7px 9px;border-radius:4px;background:#fafbfd;}
.cr-meta__l{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;}
.cr-meta__v{font-size:11.5px;font-weight:700;color:#05275C;margin-top:2px;word-break:break-word;}
.cr-sec{font-size:11px;font-weight:800;color:#05275C;margin:14px 0 6px;text-transform:uppercase;letter-spacing:.4px;}
.cr-diff{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:10px;line-height:1.5;}
.cr-diff b{color:#b42318;}
.cr-diff i{font-style:normal;color:#166534;}

@media (max-width:640px){
  .cr-wrap{padding:8px;}
  .cr-dw{width:100%;}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="cr-wrap">

  <div class="cr-head">
    <div style="min-width:0;">
      <h1 class="cr-title">Correction Register</h1>
      <p class="cr-sub">Every course-record correction that has been made, what it touched, who made it and why — and the button that puts it back. Reversals are themselves recorded here, so undoing something is as visible as doing it.</p>
    </div>
    <div class="cr-scope">
      <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
      <asp:Literal ID="litScope" runat="server" />
    </div>
  </div>

  <div class="cr-msg" id="crMsg"></div>

  <div class="cr-bar">
    <div class="cr-f"><label>Search</label><input type="text" id="crQ" placeholder="Reference, code, person or reason" /></div>
    <div class="cr-f"><label>Type of correction</label>
      <select id="crOp"><option value="">All types</option>
        <option value="COURSE_TRANSFER">Course Code Transfer</option>
        <option value="TERM_TRANSFER">Registration Term Transfer</option>
        <option value="COURSE_MERGE">Course Code Merge</option>
        <option value="REVERSAL">Reversal</option></select></div>
    <div class="cr-f"><label>Status</label>
      <select id="crSt"><option value="">Any status</option>
        <option value="APPLIED">Applied</option>
        <option value="REVERSED">Reversed</option>
        <option value="PARTIALLY_REVERSED">Partly reversed</option></select></div>
    <div class="cr-f"><label>Per page</label>
      <select id="crPs"><option>25</option><option>50</option><option>100</option></select></div>
    <div class="cr-f"><label>&nbsp;</label><button type="button" class="cr-btn" id="crGo">Apply filters</button></div>
    <div class="cr-f"><label>&nbsp;</label><a class="cr-btn cr-btn--ghost" href="CourseCorrectionCentre.aspx">New correction</a></div>
  </div>

  <div class="cr-loader show" id="crLoad"><span class="cr-spin"></span> Loading the register…</div>

  <div class="cr-tblwrap" id="crTblWrap" style="display:none;">
    <table class="cr-tbl">
      <thead><tr><th>Reference</th><th>Correction</th><th>What moved</th><th>Effect</th><th>Who and when</th><th>Status</th><th></th></tr></thead>
      <tbody id="crRows"></tbody>
    </table>
  </div>

  <div class="cr-pager" id="crPager" style="display:none;">
    <span id="crCount"></span>
    <div class="cr-pager__b">
      <button type="button" class="cr-btn cr-btn--ghost cr-btn--sm" id="crPrev">Previous</button>
      <button type="button" class="cr-btn cr-btn--ghost cr-btn--sm" id="crNext">Next</button>
    </div>
  </div>
</div>

<div class="cr-ov" id="crOv"></div>
<div class="cr-dw" id="crDw">
  <div class="cr-dw__h">
    <div style="min-width:0;">
      <h2 class="cr-dw__t" id="crDwT">Correction</h2>
      <p class="cr-sub" id="crDwS" style="margin-top:2px;"></p>
    </div>
    <button type="button" class="cr-x" id="crClose">&times;</button>
  </div>
  <div class="cr-dw__b" id="crDwB"></div>
</div>

<script type="text/javascript">
(function(){
'use strict';
var PAGE=1, TOTAL=0, PS=25, CUR=null, IS_ADMIN=false;

function q(id){ return document.getElementById(id); }
function esc(s){ return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ return (Number(v)||0).toLocaleString('en-US'); }

function ajax(m,p,cb){
    var x=new XMLHttpRequest();
    x.open('POST','CourseCorrectionRegister.aspx/'+m,true);
    x.setRequestHeader('Content-Type','application/json; charset=utf-8');
    x.timeout=600000;
    x.onload=function(){ try{ var o=JSON.parse(x.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); }catch(e){ cb({success:false,message:'The server did not return valid data.'}); } };
    x.onerror=function(){ cb({success:false,message:'Network error.'}); };
    x.ontimeout=function(){ cb({success:false,message:'That took too long.'}); };
    x.send(JSON.stringify(p||{}));
}

function msg(t,k){
    var m=q('crMsg');
    if(!t){ m.className='cr-msg'; m.innerHTML=''; return; }
    m.className='cr-msg show '+(k||'err'); m.innerHTML=esc(t);
}

var OPNAME={ COURSE_TRANSFER:'Course Code Transfer', TERM_TRANSFER:'Term Transfer', COURSE_MERGE:'Course Code Merge', REVERSAL:'Reversal' };
function statusBadge(s){
    var c = s==='APPLIED'?'applied':(s==='REVERSED'?'reversed':'partial');
    var t = s==='APPLIED'?'Applied':(s==='REVERSED'?'Reversed':'Partly reversed');
    return '<span class="cr-badge '+c+'">'+t+'</span>';
}

function moved(b){
    if(b.operation==='TERM_TRANSFER')
        return '<span class="cr-mono">'+esc(b.sourceYear)+' S'+b.sourceSem+'</span><span class="cr-arrow">&rarr;</span><span class="cr-mono">'+esc(b.targetYear)+' S'+b.targetSem+'</span>'+
               (b.sourceCode?'<span class="cr-sm">'+esc(b.sourceCode)+' only</span>':'');
    return '<span class="cr-mono">'+esc(b.sourceCode)+'</span><span class="cr-arrow">&rarr;</span><span class="cr-mono">'+esc(b.targetCode)+'</span>';
}

function load(){
    q('crLoad').className='cr-loader show';
    q('crTblWrap').style.display='none'; q('crPager').style.display='none';
    PS=Number(q('crPs').value)||25;
    ajax('GetBatches',{operation:q('crOp').value,status:q('crSt').value,search:q('crQ').value.trim(),page:PAGE,pageSize:PS},function(r){
        q('crLoad').className='cr-loader';
        if(!r||!r.success){ msg((r&&r.message)||'Could not load the register.'); return; }
        msg(''); IS_ADMIN=!!r.isAdmin; TOTAL=r.total;
        var h='';
        (r.items||[]).forEach(function(b){
            var canRev = b.status!=='REVERSED' && b.applied>0;
            h+='<tr'+(b.status==='REVERSED'?' class="rev"':'')+'>'+
               '<td><span class="cr-mono">'+esc(b.batchRef)+'</span>'+(b.reverses>0?'<span class="cr-sm">reverses another batch</span>':'')+'</td>'+
               '<td><span class="cr-badge op">'+esc(OPNAME[b.operation]||b.operation)+'</span></td>'+
               '<td>'+moved(b)+'</td>'+
               '<td>'+n(b.applied)+' record'+(b.applied===1?'':'s')+'<span class="cr-sm">'+n(b.students)+' student'+(b.students===1?'':'s')+
                    (b.skipped?', '+n(b.skipped)+' left alone':'')+(b.residual?', '+n(b.residual)+' still on old code':'')+'</span></td>'+
               '<td>'+esc(b.by)+'<span class="cr-sm">'+esc(b.at)+'</span></td>'+
               '<td>'+statusBadge(b.status)+(b.reversedBy?'<span class="cr-sm">by '+esc(b.reversedBy)+'</span>':'')+'</td>'+
               '<td style="white-space:nowrap;"><button type="button" class="cr-btn cr-btn--ghost cr-btn--sm" data-open="'+b.id+'">Open</button>'+
                   (canRev?' <button type="button" class="cr-btn cr-btn--danger cr-btn--sm" data-rev="'+b.id+'">Reverse</button>':'')+'</td></tr>';
        });
        q('crRows').innerHTML = h || '<tr><td colspan="7" style="text-align:center;padding:30px;color:#94a3b8;">No corrections have been recorded yet.</td></tr>';
        q('crTblWrap').style.display=''; q('crPager').style.display='flex';
        var from=(PAGE-1)*PS+1, to=Math.min(PAGE*PS,TOTAL);
        q('crCount').textContent = TOTAL? ('Showing '+n(from)+'–'+n(to)+' of '+n(TOTAL)) : 'Nothing to show';
        q('crPrev').disabled = PAGE<=1; q('crNext').disabled = PAGE*PS>=TOTAL;
        wire();
    });
}

function wire(){
    var o=q('crRows').querySelectorAll('[data-open]');
    for(var i=0;i<o.length;i++) o[i].addEventListener('click',function(){ open(Number(this.getAttribute('data-open'))); });
    var v=q('crRows').querySelectorAll('[data-rev]');
    for(var j=0;j<v.length;j++) v[j].addEventListener('click',function(){ reverse(Number(this.getAttribute('data-rev')),''); });
}

function open(id){
    CUR=id;
    q('crOv').className='cr-ov show'; q('crDw').className='cr-dw show';
    q('crDwB').innerHTML='<div class="cr-loader show"><span class="cr-spin"></span> Loading the records…</div>';
    ajax('GetBatchRows',{batchId:id,search:''},function(r){
        if(!r||!r.success){ q('crDwB').innerHTML='<div class="cr-msg show err">'+esc((r&&r.message)||'Could not load.')+'</div>'; return; }
        var rows=r.rows||[], studs=r.students||[];
        var h='<div class="cr-sec">Students in this correction</div>';
        if(studs.length){
            h+='<div class="cr-tblwrap"><table class="cr-tbl" style="min-width:0;"><thead><tr><th>Student</th><th>Records</th><th>Restored</th><th></th></tr></thead><tbody>';
            studs.forEach(function(s){
                h+='<tr><td class="cr-mono">'+esc(s.regno)+'</td><td>'+n(s.rows)+'</td><td>'+n(s.reversed)+'</td>'+
                   '<td>'+(s.reversed<s.rows?'<button type="button" class="cr-btn cr-btn--danger cr-btn--sm" data-revstu="'+esc(s.regno)+'">Reverse this student</button>':'<span style="color:#94a3b8;font-size:10px;">already restored</span>')+'</td></tr>';
            });
            h+='</tbody></table></div>';
        } else h+='<p style="font-size:11px;color:#94a3b8;">No student-level records.</p>';

        h+='<div class="cr-sec">Every record touched ('+n(rows.length)+')</div><div class="cr-tblwrap"><table class="cr-tbl" style="min-width:0;">'+
           '<thead><tr><th>Table</th><th>Student</th><th>Before &rarr; after</th><th>Outcome</th></tr></thead><tbody>';
        rows.forEach(function(x){
            h+='<tr'+(x.reversed?' class="rev"':'')+'><td>'+esc(x.table)+'<span class="cr-sm">'+esc(x.pkCol)+' '+esc(x.pk)+'</span></td>'+
               '<td class="cr-mono">'+esc(x.regno)+'</td>'+
               '<td class="cr-diff">'+diff(x.before,x.after)+'</td>'+
               '<td>'+esc(x.verdictText||x.verdict)+(x.reversed?'<span class="cr-sm">restored</span>':'')+
               (x.note?'<span class="cr-sm">'+esc(x.note)+'</span>':'')+'</td></tr>';
        });
        h+='</tbody></table></div>';
        q('crDwB').innerHTML=h;

        var b=q('crDwB').querySelectorAll('[data-revstu]');
        for(var k=0;k<b.length;k++) b[k].addEventListener('click',function(){ reverse(CUR,this.getAttribute('data-revstu')); });
    });
}

function diff(a,b){
    if(!a&&!b) return '<span style="color:#94a3b8;">&mdash;</span>';
    a=a||{}; b=b||{};
    var keys={}, out=[];
    Object.keys(a).forEach(function(k){ keys[k]=1; }); Object.keys(b).forEach(function(k){ keys[k]=1; });
    Object.keys(keys).forEach(function(k){
        var av=a[k], bv=b[k];
        if(String(av==null?'':av)!==String(bv==null?'':bv))
            out.push(esc(k)+': <b>'+esc(av==null?'—':av)+'</b> &rarr; <i>'+esc(bv==null?'—':bv)+'</i>');
    });
    return out.length?out.join('<br/>'):'<span style="color:#94a3b8;">no change</span>';
}

function reverse(id,regno){
    var who = regno ? ('student '+regno+' in this correction') : 'this entire correction';
    var reason = window.prompt('Reversing '+who+' puts the affected records back as they were.\n\nRecords that were changed by someone else afterwards are left alone.\n\nWhy is it being reversed?','');
    if(reason===null) return;
    if(reason.trim().length<5){ msg('Give a reason of at least five characters.'); return; }
    msg('Reversing…','warn');
    ajax('ReverseBatch',{batchId:id,reason:reason.trim(),regno:regno||''},function(r){
        if(!r||!r.success){ msg((r&&r.message)||'The reversal did not run.'); return; }
        msg(r.message,'ok');
        close_(); PAGE=1; load();
    });
}

function close_(){ q('crOv').className='cr-ov'; q('crDw').className='cr-dw'; CUR=null; }

function boot(){
    q('crGo').addEventListener('click',function(){ PAGE=1; load(); });
    q('crQ').addEventListener('keydown',function(e){ if(e.keyCode===13){ PAGE=1; load(); } });
    q('crPs').addEventListener('change',function(){ PAGE=1; load(); });
    q('crPrev').addEventListener('click',function(){ if(PAGE>1){ PAGE--; load(); } });
    q('crNext').addEventListener('click',function(){ if(PAGE*PS<TOTAL){ PAGE++; load(); } });
    q('crClose').addEventListener('click',close_);
    q('crOv').addEventListener('click',close_);
    document.addEventListener('keydown',function(e){ if(e.keyCode===27) close_(); });
    load();
}
if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',boot); else boot();
})();
</script>
</asp:Content>
