<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="IDCardController.aspx.cs" Inherits="COOPERP_NewScreens_IDCardController" Title="ID Card Controller - Campus Dynamics" %>
<asp:Content ID="Head" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.idc{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;}
.idc-hd{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:14px;}
.idc-hd h1{font-size:18px;font-weight:700;color:#05275C;margin:0;}
.idc-hd p{font-size:12px;color:#5a6472;margin:2px 0 0;}
.idc-hd__r{display:flex;align-items:center;gap:10px;}
.idc-updated{font-size:11px;color:#8a94a6;}
.idc-tabs{display:flex;gap:2px;margin-bottom:12px;}
.idc-tab{border:1px solid #e0e5ed;background:#fff;color:#05275C;font-size:12px;font-weight:600;padding:8px 16px;cursor:pointer;border-radius:0;}
.idc-tab.on{background:#05275C;color:#fff;border-color:#05275C;}
.idc-stats{display:grid;grid-template-columns:repeat(9,1fr);gap:8px;margin-bottom:14px;}
.idc-stat{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:10px 6px;text-align:center;cursor:pointer;transition:border-color .12s,background .12s;}
.idc-stat:hover{border-color:#174DA4;}
.idc-stat__v{font-size:19px;font-weight:700;color:#05275C;line-height:1;}
.idc-stat__l{font-size:9.5px;color:#5a6472;margin-top:4px;text-transform:uppercase;letter-spacing:.3px;}
.idc-stat.on{background:#05275C;border-color:#05275C;}
.idc-stat.on .idc-stat__v,.idc-stat.on .idc-stat__l{color:#fff;}
.idc-card{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:14px;margin-bottom:12px;}
.idc-filters{display:flex;flex-wrap:wrap;gap:8px;align-items:flex-end;}
.idc-fg{display:flex;flex-direction:column;gap:3px;}
.idc-fg label{font-size:10px;color:#5a6472;text-transform:uppercase;letter-spacing:.3px;}
.idc-sel,.idc-in{border:1px solid #d0d5dd;padding:7px 9px;font-size:12px;border-radius:0;background:#fff;min-width:120px;height:34px;box-sizing:border-box;}
.idc-in--search{min-width:210px;}
.idc-btn{border:1px solid #05275C;background:#05275C;color:#fff;font-size:12px;font-weight:600;padding:8px 14px;border-radius:0;cursor:pointer;height:34px;box-sizing:border-box;}
.idc-btn:disabled{opacity:.5;cursor:not-allowed;}
.idc-btn--ghost{background:#fff;color:#05275C;}
.idc-btn--sm{padding:5px 10px;font-size:11px;height:auto;}
.idc-btn--danger{border-color:#c0392b;background:#c0392b;color:#fff;}
.idc-btn--green{border-color:#128a4a;background:#128a4a;color:#fff;}
.idc-chips{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px;min-height:0;}
.idc-chipf{display:inline-flex;align-items:center;gap:6px;font-size:11px;font-weight:600;background:#eef3ff;color:#1e3a5f;border:1px solid #cdddff;padding:3px 6px 3px 10px;border-radius:12px;}
.idc-chipf button{border:none;background:#1e3a5f;color:#fff;width:15px;height:15px;border-radius:50%;font-size:11px;line-height:1;cursor:pointer;padding:0;}
.idc-chipf--clear{background:#fff;color:#c0392b;border-color:#f3c4c0;cursor:pointer;padding:3px 10px;}
.idc-toolbar{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;margin:12px 0 8px;}
.idc-bulk{display:flex;align-items:center;gap:8px;flex-wrap:wrap;background:#05275C;color:#fff;padding:7px 12px;border-radius:4px;}
.idc-bulk__n{font-size:12px;font-weight:700;}
.idc-bulk__hint{font-size:11px;color:#c5d3ec;}
.idc-toolbar__r{display:flex;align-items:center;gap:8px;font-size:11px;color:#5a6472;}
.idc-tbl{width:100%;border-collapse:collapse;font-size:12px;}
.idc-tbl th{background:#f5f7fa;color:#05275C;text-align:left;padding:8px;border-bottom:1px solid #e0e5ed;font-size:10.5px;text-transform:uppercase;letter-spacing:.3px;}
.idc-tbl td{padding:8px;border-bottom:1px solid #eef1f6;}
.idc-tbl tbody tr:hover td{background:#fafbfc;}
.idc-tbl tbody tr.sel td{background:#eef3ff;}
.idc-tbl .idc-ck{width:34px;text-align:center;cursor:default;}
.idc-tbl .idc-clickrow{cursor:pointer;}
.idc-chip{display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px;}
.st-REQUESTED,.st-FINANCE_CHECK{background:#eef3ff;color:#1e3a5f;}
.st-BLOCKED,.st-HALTED,.st-CANCELLED{background:#fef2f2;color:#991b1b;}
.st-SUBMITTED{background:#fff7ed;color:#b5720a;}
.st-APPROVED,.st-PRINTED{background:#f0f9ff;color:#0369a1;}
.st-READY{background:#ecfdf5;color:#047857;}
.st-COLLECTED{background:#e5e7eb;color:#374151;}
.idc-pager{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;margin-top:10px;font-size:12px;color:#5a6472;}
.idc-pages{display:flex;gap:4px;flex-wrap:wrap;}
.idc-pg{border:1px solid #d0d5dd;background:#fff;color:#05275C;font-size:12px;padding:5px 10px;cursor:pointer;border-radius:0;min-width:32px;}
.idc-pg.on{background:#05275C;color:#fff;border-color:#05275C;}
.idc-pg:disabled{opacity:.4;cursor:not-allowed;}
.idc-modal{display:none;position:fixed;inset:0;background:rgba(5,39,92,.45);z-index:1000;align-items:flex-start;justify-content:center;padding:30px 12px;overflow:auto;}
.idc-modal.on{display:flex;}
.idc-box{background:#fff;width:100%;max-width:720px;border-radius:2px;}
.idc-box__hd{display:flex;align-items:center;justify-content:space-between;padding:14px 18px;background:#05275C;color:#fff;font-weight:700;font-size:14px;}
.idc-box__x{background:none;border:none;color:#fff;font-size:20px;cursor:pointer;}
.idc-box__bd{padding:18px;}
.idc-box__ft{padding:12px 18px;border-top:1px solid #eef1f6;display:flex;flex-wrap:wrap;gap:8px;justify-content:flex-end;}
.idc-idn{display:flex;gap:14px;align-items:center;margin-bottom:14px;}
.idc-idn__ph{width:64px;height:64px;border:1px solid #e0e5ed;border-radius:4px;object-fit:cover;background:#f5f7fa;}
.idc-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;}
.idc-fld{background:#f5f7fa;border:1px solid #eef1f6;border-radius:2px;padding:7px 10px;}
.idc-fld__k{font-size:9.5px;color:#5a6472;text-transform:uppercase;}
.idc-fld__v{font-size:12.5px;font-weight:600;margin-top:2px;}
.idc-tl{border-left:2px solid #e0e5ed;margin-left:6px;padding-left:14px;}
.idc-tl__i{position:relative;padding:6px 0;font-size:12px;}
.idc-tl__i:before{content:'';position:absolute;left:-19px;top:10px;width:8px;height:8px;border-radius:50%;background:#174DA4;}
.idc-tl__t{font-size:10px;color:#8a94a6;}
.idc-note{font-size:11px;color:#5a6472;margin-top:4px;}
.idc-empty{text-align:center;color:#8a94a6;padding:26px;font-size:12px;}
.idc-toast{position:fixed;top:18px;right:18px;z-index:2000;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;border-radius:2px;box-shadow:0 4px 16px rgba(0,0,0,.2);}
@media(max-width:1100px){.idc-stats{grid-template-columns:repeat(5,1fr);}}
@media(max-width:700px){.idc-stats{grid-template-columns:repeat(3,1fr);}.idc-grid{grid-template-columns:1fr;}.idc-in--search{min-width:150px;}}
</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="idc">
  <div class="idc-hd">
    <div><h1>ID Card Controller</h1><p>Requests, approvals, printing and collection &middot; XAXU operations</p></div>
    <div class="idc-hd__r"><span class="idc-updated" id="idc-updated"></span><button type="button" class="idc-btn idc-btn--ghost" onclick="IDC.refresh()">Refresh</button></div>
  </div>

  <div class="idc-tabs">
    <button type="button" id="tab-q" class="idc-tab on" onclick="IDC.tab('q')">Requests</button>
    <button type="button" id="tab-w" class="idc-tab" onclick="IDC.tab('w')">Request Windows</button>
  </div>

  <div id="view-q">
    <div class="idc-stats" id="idc-stats"></div>
    <div class="idc-card">
      <div class="idc-filters">
        <div class="idc-fg"><label>Status</label><select id="f-status" class="idc-sel" onchange="IDC.apply()"><option value="">All statuses</option><option>REQUESTED</option><option>FINANCE_CHECK</option><option>BLOCKED</option><option>SUBMITTED</option><option>APPROVED</option><option>HALTED</option><option>PRINTED</option><option>READY</option><option>COLLECTED</option><option>CANCELLED</option></select></div>
        <div class="idc-fg"><label>Type</label><select id="f-type" class="idc-sel" onchange="IDC.apply()"><option value="">All types</option><option value="STUDENT">Student</option><option value="STAFF">Staff</option></select></div>
        <div class="idc-fg"><label>Card</label><select id="f-card" class="idc-sel" onchange="IDC.apply()"><option value="">All cards</option><option value="NEW">New</option><option value="REPLACEMENT">Replacement</option></select></div>
        <div class="idc-fg"><label>Search</label><input id="f-q" class="idc-in idc-in--search" placeholder="request no / student no / name" onkeydown="if(event.keyCode===13)IDC.apply()" /></div>
        <div class="idc-fg"><label>&nbsp;</label><button type="button" class="idc-btn" onclick="IDC.apply()">Apply</button></div>
      </div>
      <div class="idc-chips" id="idc-chips"></div>

      <div class="idc-toolbar">
        <div id="idc-bulk" style="display:none"></div>
        <div class="idc-toolbar__r">
          <span id="idc-count"></span>
          <label>Rows
            <select id="f-size" class="idc-sel" style="min-width:70px;height:28px;padding:3px 6px" onchange="IDC.apply()">
              <option value="25">25</option><option value="50" selected>50</option><option value="100">100</option><option value="200">200</option>
            </select>
          </label>
        </div>
      </div>

      <div style="overflow:auto"><table class="idc-tbl">
        <thead><tr>
          <th class="idc-ck"><input type="checkbox" id="ck-all" onclick="IDC.selAll(this.checked)" title="Select all on this page" /></th>
          <th>Request</th><th>Requester</th><th>Type</th><th>Card</th><th>Status</th><th>Created</th>
        </tr></thead>
        <tbody id="idc-rows"><tr><td colspan="7" class="idc-empty">Loading&hellip;</td></tr></tbody>
      </table></div>
      <div class="idc-pager"><div id="idc-pgtext"></div><div class="idc-pages" id="idc-pages"></div></div>
    </div>
  </div>

  <div id="view-w" style="display:none">
    <div class="idc-card">
      <strong style="font-size:12px;color:#05275C;">Create a request window</strong>
      <div class="idc-filters" style="margin-top:10px;">
        <div class="idc-fg"><label>Title</label><input id="w-title" class="idc-in" placeholder="e.g. 2026/2027 ID drive" /></div>
        <div class="idc-fg"><label>Scope</label><select id="w-scope" class="idc-sel"><option value="BOTH">Both</option><option value="STUDENT">Students</option><option value="STAFF">Staff</option></select></div>
        <div class="idc-fg"><label>Opens</label><input id="w-open" class="idc-in" type="datetime-local" /></div>
        <div class="idc-fg"><label>Closes</label><input id="w-close" class="idc-in" type="datetime-local" /></div>
        <div class="idc-fg"><label>&nbsp;</label><button type="button" class="idc-btn" onclick="IDC.createWindow()">Create</button></div>
      </div>
      <div class="idc-note">While no window exists, requests are open. Once you create one, requests are only accepted inside an active window.</div>
    </div>
    <div class="idc-card"><div style="overflow:auto"><table class="idc-tbl">
      <thead><tr><th>Title</th><th>Scope</th><th>Opens</th><th>Closes</th><th>State</th><th></th></tr></thead>
      <tbody id="idc-wins"><tr><td colspan="6" class="idc-empty">Loading&hellip;</td></tr></tbody>
    </table></div></div>
  </div>
</div>

<div class="idc-modal" id="idc-detail"><div class="idc-box">
  <div class="idc-box__hd"><span id="d-title">Request</span><button type="button" class="idc-box__x" onclick="IDC.close()">&times;</button></div>
  <div class="idc-box__bd" id="d-body">Loading&hellip;</div>
  <div class="idc-box__ft" id="d-actions"></div>
</div></div>

<%-- Administrative status change. Kept separate from the action buttons because it is
     a different kind of act: the buttons walk the lifecycle, this one sets it. --%>
<div class="idc-modal" id="idc-setst"><div class="idc-box" style="max-width:520px">
  <div class="idc-box__hd"><span>Change status</span><button type="button" class="idc-box__x" onclick="IDC.closeStatus()">&times;</button></div>
  <div class="idc-box__bd">
    <div class="idc-fld" style="margin-bottom:12px">
      <div class="idc-fld__k">Request</div>
      <div class="idc-fld__v" id="ss-who">&mdash;</div>
    </div>
    <div class="idc-fld__k" style="margin-bottom:5px">Move to</div>
    <select id="ss-to" class="idc-in" style="width:100%" onchange="IDC.statusPicked()"></select>
    <div id="ss-hint" style="font-size:11.5px;line-height:1.5;margin-top:8px"></div>
    <div id="ss-ovwrap" style="display:none;margin-top:10px">
      <label style="display:flex;gap:8px;align-items:flex-start;background:#fef2f2;border:1px solid #fecaca;padding:9px 11px;font-size:12px;color:#7a1f1a;cursor:pointer">
        <input type="checkbox" id="ss-override" style="margin-top:2px;flex:0 0 auto" onchange="IDC.statusPicked()"/>
        <span>I understand this is not a normal step and I am setting it deliberately. This will be recorded as an override, with my name and reason, in the request&rsquo;s history.</span>
      </label>
    </div>
    <div class="idc-fld__k" style="margin:12px 0 5px">Reason <span id="ss-reqd" style="font-weight:400;text-transform:none;color:#8a94a6"></span></div>
    <textarea id="ss-reason" class="idc-in" style="width:100%;min-height:64px;resize:vertical" placeholder="Why is this being changed? Shown in the request history."></textarea>
    <div id="ss-msg" style="display:none;font-size:12px;padding:8px 10px;margin-top:10px"></div>
  </div>
  <div class="idc-box__ft">
    <button type="button" class="idc-btn idc-btn--ghost" onclick="IDC.closeStatus()">Cancel</button>
    <button type="button" class="idc-btn idc-btn--green" id="ss-go" onclick="IDC.applyStatus()">Apply</button>
  </div>
</div></div>

<script>
window.IDC=(function(){
var CUR=null, CURST='', SEL={}, LASTROWS=[];
// Status list + legal-transition map, fetched once. The status picker uses it to
// label each choice as a normal step or an override, so an operator sees which is
// which before acting instead of after being refused.
var META={statuses:[],transitions:{}};
var state={status:'',type:'',card:'',q:'',page:1,size:50};
function qs(i){return document.getElementById(i);}
function esc(s){return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'):'';}
function toast(m,err){var t=document.createElement('div');t.className='idc-toast';t.style.background=err?'#c0392b':'#128a4a';t.textContent=m;document.body.appendChild(t);setTimeout(function(){t.style.transition='opacity .4s';t.style.opacity='0';setTimeout(function(){t.remove();},400);},2800);}
function call(m,p,cb){var x=new XMLHttpRequest();x.open('POST',location.pathname+'/'+m,true);x.setRequestHeader('Content-Type','application/json; charset=utf-8');x.onload=function(){try{var o=JSON.parse(x.responseText);cb(typeof o.d==='string'?JSON.parse(o.d):o.d);}catch(e){cb({success:false,message:'Parse error'});}};x.onerror=function(){cb({success:false,message:'Network error'});};x.send(JSON.stringify(p||{}));}
function n(v){return (v==null||v==='')?'0':Number(v).toLocaleString();}
function chip(s){return '<span class="idc-chip st-'+esc(s)+'">'+esc(s)+'</span>';}

/* ---------- GET / URL state ---------- */
function readURL(){
  var u=new URLSearchParams(location.search);
  state.status=u.get('status')||'';state.type=u.get('type')||'';state.card=u.get('card')||'';
  state.q=u.get('q')||'';state.page=parseInt(u.get('page')||'1',10)||1;state.size=parseInt(u.get('size')||'50',10)||50;
  qs('f-status').value=state.status;qs('f-type').value=state.type;qs('f-card').value=state.card;qs('f-q').value=state.q;qs('f-size').value=String(state.size);
}
function writeURL(){
  var u=new URLSearchParams();
  if(state.status)u.set('status',state.status);if(state.type)u.set('type',state.type);if(state.card)u.set('card',state.card);
  if(state.q)u.set('q',state.q);if(state.page>1)u.set('page',state.page);if(state.size!==50)u.set('size',state.size);
  var qsr=u.toString();history.replaceState(null,'',location.pathname+(qsr?('?'+qsr):''));
}
function chips(){
  var c=[],lbl={status:'Status',type:'Type',card:'Card',q:'Search'};
  ['status','type','card','q'].forEach(function(k){if(state[k])c.push('<span class="idc-chipf">'+lbl[k]+': '+esc(state[k])+' <button onclick="IDC.clear(\''+k+'\')" title="Remove">&times;</button></span>');});
  qs('idc-chips').innerHTML=c.length?(c.join('')+'<span class="idc-chipf idc-chipf--clear" onclick="IDC.clearAll()">Clear all</span>'):'';
}

/* ---------- stats ---------- */
function stats(){call('Stats',{},function(d){if(!d||!d.success)return;var m=[['total','Total',''],['requested','Draft','REQUESTED'],['submitted','Submitted','SUBMITTED'],['blocked','Blocked','BLOCKED'],['approved','Approved','APPROVED'],['halted','Halted','HALTED'],['printed','Printed','PRINTED'],['ready','Ready','READY'],['collected','Collected','COLLECTED']];
 qs('idc-stats').innerHTML=m.map(function(k){return '<div class="idc-stat'+(state.status===k[2]&&k[2]!==''?' on':(k[2]===''&&!state.status?' on':''))+'" onclick="IDC.filterStatus(\''+k[2]+'\')"><div class="idc-stat__v">'+n(d[k[0]])+'</div><div class="idc-stat__l">'+k[1]+'</div></div>';}).join('');});}

/* ---------- list ---------- */
function load(){
  writeURL();chips();
  var b=qs('idc-rows');b.innerHTML='<tr><td colspan="7" class="idc-empty">Loading&hellip;</td></tr>';
  SEL={};syncBulk();qs('ck-all').checked=false;
  call('List',{status:state.status,type:state.type,cardType:state.card,q:state.q,page:state.page,size:state.size},function(d){
    if(!d||!d.success){b.innerHTML='<tr><td colspan="7" class="idc-empty" style="color:#b42318">'+esc((d&&d.message)||'Error')+'</td></tr>';return;}
    LASTROWS=d.rows||[];
    if(!LASTROWS.length){b.innerHTML='<tr><td colspan="7" class="idc-empty">No requests match these filters.</td></tr>';qs('idc-count').textContent='0 requests';qs('idc-pgtext').textContent='';qs('idc-pages').innerHTML='';return;}
    b.innerHTML=LASTROWS.map(function(r){var rn=esc(r.requestNo);return '<tr id="row-'+rn+'">'+
      '<td class="idc-ck"><input type="checkbox" class="idc-rowck" value="'+rn+'" data-status="'+esc(r.status)+'" onclick="event.stopPropagation();IDC.selOne(\''+rn+'\',this.checked)"'+(SEL[r.requestNo]?' checked':'')+'/></td>'+
      '<td class="idc-clickrow" onclick="IDC.open(\''+rn+'\')"><b>'+rn+'</b></td>'+
      '<td class="idc-clickrow" onclick="IDC.open(\''+rn+'\')">'+esc(r.name||r.number)+'<div style="font-size:10px;color:#8a94a6">'+esc(r.number)+'</div></td>'+
      '<td>'+esc(r.type)+'</td><td>'+esc(r.cardType)+'</td><td>'+chip(r.status)+'</td>'+
      '<td style="font-size:11px;color:#5a6472">'+esc((r.createdAt||'').substring(0,16))+'</td></tr>';}).join('');
    var from=(d.page-1)*state.size+1, to=(d.page-1)*state.size+LASTROWS.length;
    qs('idc-count').textContent=n(d.total)+' request(s) - showing '+from+' to '+to;
    qs('idc-pgtext').textContent='Page '+d.page+' of '+d.pages;
    qs('idc-pages').innerHTML=pager(d.page,d.pages);
  });
}
function pager(pg,pages){
  if(pages<=1)return '';
  var h='<button type="button" class="idc-pg" '+(pg<=1?'disabled':'')+' onclick="IDC.go('+(pg-1)+')">&lsaquo;</button>';
  var start=Math.max(1,pg-2),end=Math.min(pages,pg+2);
  if(start>1){h+=btnpg(1,pg);if(start>2)h+='<span style="padding:5px 2px">…</span>';}
  for(var i=start;i<=end;i++)h+=btnpg(i,pg);
  if(end<pages){if(end<pages-1)h+='<span style="padding:5px 2px">…</span>';h+=btnpg(pages,pg);}
  h+='<button type="button" class="idc-pg" '+(pg>=pages?'disabled':'')+' onclick="IDC.go('+(pg+1)+')">&rsaquo;</button>';
  return h;
}
function btnpg(i,pg){return '<button type="button" class="idc-pg'+(i===pg?' on':'')+'" onclick="IDC.go('+i+')">'+i+'</button>';}

/* ---------- selection + batch ---------- */
function syncBulk(){
  var keys=Object.keys(SEL);var box=qs('idc-bulk');
  if(!keys.length){box.style.display='none';box.innerHTML='';return;}
  var sts={};keys.forEach(function(k){sts[SEL[k]]=1;});var uniq=Object.keys(sts);
  var h='<div class="idc-bulk"><span class="idc-bulk__n">'+keys.length+' selected</span>';
  if(uniq.length===1){
    var s=uniq[0],acts=bulkActionsFor(s);
    if(acts.length){acts.forEach(function(a){h+=' <button type="button" class="idc-btn idc-btn--sm '+(a.cls||'')+'" onclick="IDC.bulk(\''+a.act+'\')">'+a.lbl+'</button>';});}
    else h+='<span class="idc-bulk__hint">No bulk action for '+esc(s)+' requests.</span>';
  }else h+='<span class="idc-bulk__hint">Select requests of the same status to act in bulk.</span>';
  h+=' <button type="button" class="idc-btn idc-btn--sm idc-btn--ghost" onclick="IDC.selClear()">Clear</button></div>';
  box.style.display='';box.innerHTML=h;
}
function bulkActionsFor(s){
  if(s==='SUBMITTED')return [{act:'APPROVE',lbl:'Approve selected',cls:'idc-btn--green'}];
  if(s==='APPROVED')return [{act:'PRINTED',lbl:'Mark printed'}];
  if(s==='PRINTED')return [{act:'READY',lbl:'Mark ready',cls:'idc-btn--green'}];
  if(s==='READY')return [{act:'COLLECTED',lbl:'Mark collected',cls:'idc-btn--green'}];
  return [];
}
function rowStatus(rn){for(var i=0;i<LASTROWS.length;i++)if(LASTROWS[i].requestNo===rn)return LASTROWS[i].status;return '';}

return {
 refresh:function(){readURL();stats();load();windows();stamp();
   call('Meta',{},function(d){if(d&&d.success)META={statuses:d.statuses||[],transitions:d.transitions||{}};});},
 apply:function(){state.status=qs('f-status').value;state.type=qs('f-type').value;state.card=qs('f-card').value;state.q=qs('f-q').value.trim();state.size=parseInt(qs('f-size').value,10)||50;state.page=1;stats();load();},
 go:function(p){state.page=p;load();window.scrollTo(0,0);},
 filterStatus:function(s){state.status=s;qs('f-status').value=s;state.page=1;stats();load();},
 clear:function(k){state[k]='';qs('f-'+(k==='q'?'q':k)).value='';state.page=1;stats();load();},
 clearAll:function(){state.status='';state.type='';state.card='';state.q='';state.page=1;qs('f-status').value='';qs('f-type').value='';qs('f-card').value='';qs('f-q').value='';stats();load();},
 tab:function(t){qs('tab-q').classList.toggle('on',t==='q');qs('tab-w').classList.toggle('on',t==='w');qs('view-q').style.display=t==='q'?'':'none';qs('view-w').style.display=t==='w'?'':'none';if(t==='w')windows();},
 selOne:function(rn,on){if(on)SEL[rn]=rowStatus(rn);else delete SEL[rn];var tr=qs('row-'+rn);if(tr)tr.classList.toggle('sel',on);syncBulk();syncAllCk();},
 selAll:function(on){var cks=document.getElementsByClassName('idc-rowck');for(var i=0;i<cks.length;i++){cks[i].checked=on;var rn=cks[i].value;if(on)SEL[rn]=cks[i].getAttribute('data-status');else delete SEL[rn];var tr=qs('row-'+rn);if(tr)tr.classList.toggle('sel',on);}syncBulk();},
 selClear:function(){SEL={};var cks=document.getElementsByClassName('idc-rowck');for(var i=0;i<cks.length;i++){cks[i].checked=false;var tr=qs('row-'+cks[i].value);if(tr)tr.classList.remove('sel');}qs('ck-all').checked=false;syncBulk();},
 bulk:function(a){
   var ids=Object.keys(SEL);if(!ids.length)return;var cp='';
   if(a==='READY'){cp=prompt('Collection point for '+ids.length+' card(s):','ID Card Office, Admin Block');if(cp===null)return;}
   if(!confirm('Apply "'+a+'" to '+ids.length+' selected request(s)?'))return;
   call('BatchAction',{requestNos:ids.join(','),action:a,reason:'',collectionPoint:cp},function(d){
     if(d&&d.success){toast(d.ok+' updated'+(d.fail?(', '+d.fail+' skipped'):''),d.fail>0&&d.ok===0);stats();load();}
     else toast((d&&d.message)||'Batch failed',true);});
 },
 open:function(rn){CUR=rn;qs('idc-detail').classList.add('on');qs('d-title').textContent=rn;qs('d-body').innerHTML='Loading&hellip;';qs('d-actions').innerHTML='';
  call('Detail',{requestNo:rn},function(d){
   if(!d||!d.success){qs('d-body').innerHTML='<div class="idc-empty" style="color:#b42318">'+esc((d&&d.message)||'Error')+'</div>';return;}
   var q=d.request,idn=d.identity||{},f=d.finance;
   var ph=idn.photo&&idn.photo!=='-'?('../StudentInfo/Photos/'+encodeURIComponent(idn.photo)):'';
   var h='<div class="idc-idn">'+(ph?'<img class="idc-idn__ph" src="'+ph+'" onerror="this.style.display=\'none\'"/>':'<div class="idc-idn__ph"></div>')+'<div><div style="font-size:15px;font-weight:700">'+esc(idn.name)+'</div><div style="font-size:12px;color:#5a6472">'+esc(idn.number)+' &middot; '+esc(idn.subtitle)+'</div><div style="margin-top:4px">'+chip(q.status)+'</div></div></div>';
   h+='<div class="idc-grid">'+fld('Card type',q.card_type)+fld('Requester',q.requester_type)+fld('Created',(q.created_at||'').substring(0,16))+fld('Submitted',(q.submitted_at||'').substring(0,16))+'</div>';
   if(q.card_type==='REPLACEMENT'){h+='<div class="idc-grid">'+fld('Repl. fee ref',q.replacement_fee_ref)+fld('Paid via',q.replacement_fee_method)+fld('Paid on',q.replacement_fee_date)+fld('Notes',q.replacement_fee_notes)+'</div>';}
   if(f){h+='<div class="idc-grid">'+fld('Semester fee',Number(f.fee).toLocaleString())+fld('Paid this sem',Number(f.paid).toLocaleString())+fld('Needed (10%)',Number(f.required).toLocaleString())+fld('Finance',f.eligible?('OK'+(f.flagged?' (flagged)':'')):'BELOW 10%')+'</div>';}
   if(q.halt_reason){h+='<div class="idc-fld" style="background:#fef2f2;border-color:#fecaca"><div class="idc-fld__k">Halt reason</div><div class="idc-fld__v">'+esc(q.halt_reason)+'</div></div>';}
   if(q.collection_point){h+='<div class="idc-fld" style="background:#ecfdf5;border-color:#a7f3d0;margin-top:8px"><div class="idc-fld__k">Collection</div><div class="idc-fld__v">'+esc(q.collection_point)+'</div></div>';}
   h+='<div style="font-size:11px;font-weight:700;color:#05275C;margin:16px 0 6px;text-transform:uppercase">Timeline</div><div class="idc-tl">'+(d.timeline||[]).map(function(e){return '<div class="idc-tl__i"><b>'+esc(e.to)+'</b> '+(e.actor?('&middot; '+esc(e.actor)):'')+(e.channel?(' <span style="font-size:10px;color:#8a94a6">['+esc(e.channel)+']</span>'):'')+(e.note?('<div class="idc-note">'+esc(e.note)+'</div>'):'')+'<div class="idc-tl__t">'+esc((e.at||'').substring(0,16))+'</div></div>';}).join('')+'</div>';
   CURST=q.status;
   qs('d-body').innerHTML=h;
   qs('d-actions').innerHTML=actionsFor(q.status);
  });},
 close:function(){qs('idc-detail').classList.remove('on');},

 /* ---------- administrative status change ----------
    The ordinary buttons walk the lifecycle one legal step at a time. This sets it.
    Both kinds of move are offered in one list and each is LABELLED, so the operator
    can see at a glance which are normal and which are not, rather than discovering it
    from a rejection. Anything abnormal needs the tick and a reason, and lands in the
    request history as an override. Terminal states are included on purpose: a request
    marked COLLECTED by mistake cannot be undone any other way. */
 openStatus:function(){
   if(!CUR){toast('Open a request first',true);return;}
   qs('ss-who').textContent=CUR+(CURST?('  ·  currently '+CURST):'');
   var sel=qs('ss-to'),legal=(META.transitions&&META.transitions[CURST])||[];
   var opts='<option value="">Select a status&hellip;</option>';
   (META.statuses||[]).forEach(function(s){
     if(s===CURST)return;                       // no-op; nothing to choose
     var ok=legal.indexOf(s)>=0;
     opts+='<option value="'+esc(s)+'">'+esc(s)+(ok?'   (normal next step)':'   (override)')+'</option>';
   });
   sel.innerHTML=opts;
   qs('ss-reason').value='';
   qs('ss-override').checked=false;
   qs('ss-msg').style.display='none';
   IDC.statusPicked();
   qs('idc-setst').classList.add('on');
 },
 closeStatus:function(){qs('idc-setst').classList.remove('on');},
 statusPicked:function(){
   var to=qs('ss-to').value,legal=(META.transitions&&META.transitions[CURST])||[];
   var hint=qs('ss-hint'),ov=qs('ss-ovwrap'),go=qs('ss-go'),reqd=qs('ss-reqd');
   if(!to){hint.innerHTML='';ov.style.display='none';reqd.textContent='';go.disabled=true;return;}
   go.disabled=false;
   if(legal.indexOf(to)>=0){
     hint.innerHTML='<span style="color:#128a4a">This is a normal step in the lifecycle. It behaves exactly like the action buttons, and the requester is notified as usual.</span>';
     ov.style.display='none';
     // HALTED always needs a reason — the requester is shown it and has to act on it.
     reqd.textContent=(to==='HALTED')?'(required)':'(optional)';
   }else{
     hint.innerHTML='<span style="color:#b42318"><b>'+esc(CURST)+' &rarr; '+esc(to)+' is not a normal step.</b> '+
       'It can still be done, but it will be recorded as an override against your name.</span>';
     ov.style.display='block';
     reqd.textContent='(required for an override)';
   }
 },
 applyStatus:function(){
   var to=qs('ss-to').value,reason=qs('ss-reason').value.replace(/^\s+|\s+$/g,'');
   var legal=(META.transitions&&META.transitions[CURST])||[];
   var isOv=legal.indexOf(to)<0, ov=qs('ss-override').checked;
   var msg=qs('ss-msg');
   function bad(t){msg.style.display='block';msg.style.background='#fef2f2';msg.style.color='#b42318';msg.style.border='1px solid #fecaca';msg.textContent=t;}
   if(!to){bad('Choose a status.');return;}
   if(isOv&&!ov){bad('This is not a normal step. Tick the box to confirm you mean it.');return;}
   if((isOv||to==='HALTED')&&!reason){bad('Give a reason — it is written into the request history.');return;}
   if(isOv&&!confirm('Force '+CUR+' from '+CURST+' to '+to+'?\n\nThis is not a normal step. It will be recorded as an override with your name and reason.'))return;
   var go=qs('ss-go');go.disabled=true;
   call('SetStatus',{requestNo:CUR,toStatus:to,reason:reason,allowOverride:ov},function(d){
     go.disabled=false;
     if(d&&d.success){IDC.closeStatus();toast(d.message||('Set to '+to),false);IDC.open(CUR);stats();load();}
     else bad((d&&d.message)||'Could not change the status.');
   });
 },
 act:function(a){var reason='',cp='';
  if(a==='HALT'){reason=prompt('Reason for halting this request:');if(!reason)return;}
  if(a==='READY'){cp=prompt('Collection point (location + times):','ID Card Office, Admin Block');if(cp===null)return;}
  if(a==='CANCEL'&&!confirm('Cancel this request?'))return;
  call('Action',{requestNo:CUR,action:a,reason:reason,collectionPoint:cp},function(d){
   if(d&&d.success){toast('Updated: '+d.status);IDC.open(CUR);stats();load();}else{toast((d&&d.message)||'Failed',true);}});},
 createWindow:function(){var t=qs('w-title').value,o=qs('w-open').value,c=qs('w-close').value;if(!t||!o||!c){toast('Title, open and close are required',true);return;}
  call('CreateWindow',{title:t,scope:qs('w-scope').value,opensAt:o.replace('T',' '),closesAt:c.replace('T',' '),notes:''},function(d){if(d&&d.success){toast('Window created');qs('w-title').value='';windows();}else toast((d&&d.message)||'Failed',true);});},
 setWin:function(id,active){call('SetWindow',{id:id,active:active},function(d){if(d&&d.success){toast(d.message);windows();}else toast((d&&d.message)||'Failed',true);});}
};

function syncAllCk(){var cks=document.getElementsByClassName('idc-rowck');var all=cks.length>0;for(var i=0;i<cks.length;i++)if(!cks[i].checked){all=false;break;}qs('ck-all').checked=all;}
function fld(k,v){return '<div class="idc-fld"><div class="idc-fld__k">'+k+'</div><div class="idc-fld__v">'+esc(v||'—')+'</div></div>';}
function actionsFor(st){var b='';
 if(st==='SUBMITTED'){b+=btn('Approve','APPROVE','green')+btn('Halt','HALT','danger');}
 else if(st==='APPROVED'){b+=btn('Mark Printed','PRINTED','')+btn('Halt','HALT','danger');}
 else if(st==='PRINTED'){b+=btn('Mark Ready','READY','green');}
 else if(st==='READY'){b+=btn('Mark Collected','COLLECTED','green');}
 else if(st==='HALTED'){b+='<span style="font-size:11px;color:#8a94a6;align-self:center">Awaiting requester resubmission.</span>';}
 if(st!=='COLLECTED'&&st!=='CANCELLED'&&st!=='PRINTED'&&st!=='READY'&&st!=='APPROVED'){b+=btn('Cancel','CANCEL','ghost');}
 // Every state gets this, including the terminal ones — a request marked COLLECTED by
 // mistake is exactly the case the ordinary buttons cannot reach.
 b+='<button type="button" class="idc-btn idc-btn--ghost" onclick="IDC.openStatus()">Change status&hellip;</button>';
 return b+'<button type="button" class="idc-btn idc-btn--ghost" onclick="IDC.close()">Close</button>';}
function btn(lbl,act,cls){return '<button type="button" class="idc-btn '+(cls?('idc-btn--'+cls):'')+'" onclick="IDC.act(\''+act+'\')">'+lbl+'</button>';}
function windows(){var b=qs('idc-wins');call('Windows',{},function(d){
  if(!d||!d.success||!d.windows.length){b.innerHTML='<tr><td colspan="6" class="idc-empty">No windows yet — requests are open.</td></tr>';return;}
  b.innerHTML=d.windows.map(function(w){return '<tr><td><b>'+esc(w.title)+'</b></td><td>'+esc(w.scope)+'</td><td style="font-size:11px">'+esc((w.opensAt||'').substring(0,16))+'</td><td style="font-size:11px">'+esc((w.closesAt||'').substring(0,16))+'</td><td>'+(w.open?'<span class="idc-chip st-READY">OPEN</span>':(w.active?'<span class="idc-chip st-SUBMITTED">SCHEDULED</span>':'<span class="idc-chip st-COLLECTED">CLOSED</span>'))+'</td><td><button type="button" class="idc-btn idc-btn--ghost idc-btn--sm" onclick="IDC.setWin('+w.id+','+(w.active?'false':'true')+')">'+(w.active?'Close':'Activate')+'</button></td></tr>';}).join('');});}
function stamp(){var d=new Date();qs('idc-updated').textContent='Updated '+d.toLocaleTimeString();}
})();
IDC.refresh();
</script>
</asp:Content>
