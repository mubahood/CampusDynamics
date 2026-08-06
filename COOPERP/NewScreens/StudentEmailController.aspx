<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true"
    CodeFile="StudentEmailController.aspx.cs" Inherits="COOPERP_NewScreens_StudentEmailController"
    Title="Student Email Controller" %>

<asp:Content ID="ch" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.se-wrap{max-width:1280px;margin:0 auto;padding:18px 20px 40px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;}
.se-head{display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;}
.se-title{font-size:21px;font-weight:800;color:#05275C;margin:0;}
.se-sub{font-size:12px;color:#64748b;margin-top:2px;}
.se-gen{display:inline-flex;align-items:center;gap:7px;background:#05275C;color:#fff;border:0;padding:11px 16px;font-size:13px;font-weight:700;cursor:pointer;}
.se-gen:hover{background:#0a3a82;}
.se-gen:disabled{opacity:.6;cursor:default;}
.se-kpis{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:10px;margin-bottom:16px;}
.se-kpi{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;border-left:3px solid #174DA4;}
.se-kpi__v{font-size:22px;font-weight:800;color:#05275C;line-height:1;}
.se-kpi__l{font-size:10.5px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8;margin-top:5px;}
.se-kpi--ok{border-left-color:#16a34a;}.se-kpi--warn{border-left-color:#ea580c;}.se-kpi--info{border-left-color:#0891b2;}
.se-tabs{display:flex;gap:4px;border-bottom:1px solid #e0e5ed;margin-bottom:12px;}
.se-tab{padding:9px 15px;font-size:13px;font-weight:700;color:#64748b;cursor:pointer;border-bottom:2px solid transparent;}
.se-tab.active{color:#05275C;border-bottom-color:#05275C;}
.se-toolbar{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:10px;}
.se-in,.se-sel{padding:9px 11px;border:1px solid #cbd5e1;font-size:13px;background:#fff;color:#1a1a2e;}
.se-in{flex:1 1 220px;min-width:0;}
.se-btn{padding:9px 13px;border:1px solid #cbd5e1;background:#fff;color:#334155;font-size:13px;font-weight:600;cursor:pointer;}
.se-btn--p{background:#05275C;border-color:#05275C;color:#fff;}
.se-meta{font-size:12px;color:#64748b;margin:4px 0 8px;}
.se-tblwrap{overflow-x:auto;border:1px solid #e0e5ed;background:#fff;}
.se-tbl{width:100%;min-width:900px;border-collapse:collapse;font-size:12px;}
.se-tbl th{background:#f9fafc;text-align:left;padding:9px 11px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;color:#64748b;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.se-tbl td{padding:9px 11px;border-bottom:1px solid #f0f3f7;vertical-align:middle;}
.se-tbl tbody tr:hover td{background:#f9fbff;}
.se-badge{display:inline-block;font-size:10px;font-weight:700;padding:2px 8px;white-space:nowrap;border:1px solid transparent;}
.se-b--pending{background:#fff7ed;color:#9a3412;border-color:#fed7aa;}
.se-b--ready{background:#eef2ff;color:#3730a3;border-color:#c7d2fe;}
.se-b--learn{background:#f5f3ff;color:#6d28d9;border-color:#ddd6fe;}
.se-b--done{background:#e6f4ec;color:#0b5c3a;border-color:#b5dcc5;}
.se-b--verified{background:#ecfeff;color:#155e75;border-color:#a5f3fc;}
.se-b--muted{background:#f1f5f9;color:#475569;border-color:#cbd5e1;}
.se-act{color:#174DA4;font-weight:700;cursor:pointer;font-size:11.5px;}
.se-pager{display:flex;flex-wrap:wrap;gap:4px;justify-content:center;margin-top:14px;}
.se-pager button{min-width:32px;padding:6px 9px;border:1px solid #cbd5e1;background:#fff;font-size:12px;cursor:pointer;}
.se-pager button.active{background:#05275C;border-color:#05275C;color:#fff;}
.se-pager button:disabled{opacity:.45;cursor:default;}
.se-ov{display:none;position:fixed;inset:0;background:rgba(5,39,92,.55);z-index:1000;}
.se-modal{display:none;position:fixed;z-index:1001;top:50%;left:50%;transform:translate(-50%,-50%);width:92%;max-width:460px;background:#fff;box-shadow:0 24px 70px rgba(0,0,0,.35);}
.se-modal__h{display:flex;justify-content:space-between;align-items:center;padding:15px 18px;border-bottom:1px solid #eef2f7;}
.se-modal__t{font-size:16px;font-weight:800;color:#05275C;}
.se-modal__x{border:0;background:none;font-size:24px;color:#94a3b8;cursor:pointer;}
.se-modal__b{padding:16px 18px;}
.se-fl{display:block;font-size:12px;font-weight:700;color:#374151;margin:10px 0 4px;}
.se-fi{width:100%;box-sizing:border-box;padding:10px;border:1px solid #cbd5e1;font-size:14px;}
.se-modal__f{padding:12px 18px;border-top:1px solid #eef2f7;display:flex;justify-content:flex-end;gap:8px;}
.se-msg{font-size:12.5px;padding:9px 11px;margin-bottom:10px;display:none;}
.se-msg--ok{background:#e6f4ec;color:#0b5c3a;border:1px solid #b5dcc5;}
.se-msg--err{background:#fef2f2;color:#b91c1c;border:1px solid #fecaca;}
.se-empty{text-align:center;padding:40px;color:#94a3b8;font-size:13px;}
@media(max-width:640px){.se-wrap{padding:12px;}}
</style>
</asp:Content>

<asp:Content ID="cm" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="se-wrap">
    <div class="se-head">
        <div>
            <h1 class="se-title">Student Email Controller</h1>
            <div class="se-sub">Automated university-email lifecycle for the 2026 intake and beyond — no ICT-office visit required.</div>
        </div>
        <button type="button" class="se-gen" id="btnGen" onclick="genEligible()">
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>
            Generate Eligible Students
        </button>
    </div>

    <div class="se-kpis" id="kpis"></div>
    <div class="se-msg" id="topMsg"></div>

    <div class="se-tabs">
        <div class="se-tab active" id="tabPipe" onclick="setTab('pipe')">Pipeline</div>
        <div class="se-tab" id="tabCand" onclick="setTab('cand')">Candidates</div>
        <div class="se-tab" id="tabComp" onclick="setTab('comp')">Complaints</div>
    </div>

    <!-- Pipeline -->
    <div id="paneP">
        <div class="se-toolbar">
            <input type="text" id="fq" class="se-in" placeholder="Search name, student number or email&hellip;" />
            <select id="fStage" class="se-sel">
                <option value="">All stages</option>
                <option value="PENDING_CREATION">Pending creation</option>
                <option value="READY_FOR_COLLECTION">Ready for collection</option>
                <option value="EMAIL_CREATED">Email created</option>
                <option value="COMPLETED">Completed</option>
            </select>
            <select id="fVerif" class="se-sel">
                <option value="">Any verification</option>
                <option value="VERIFIED">Verified</option>
                <option value="UNVERIFIED">Unverified</option>
            </select>
            <select id="fProg" class="se-sel"><option value="">All programmes</option></select>
            <button type="button" class="se-btn se-btn--p" onclick="doSearch(1)">Search</button>
            <button type="button" class="se-btn" onclick="resetF()">Reset</button>
        </div>
        <div class="se-meta" id="pMeta">Loading&hellip;</div>
        <div class="se-tblwrap">
            <table class="se-tbl"><thead><tr>
                <th>Student</th><th>Student No.</th><th>Programme</th><th>Campus</th><th>Year</th><th>Paid</th><th>Email</th><th>Stage</th><th>Verify</th><th>Updated</th><th></th>
            </tr></thead><tbody id="pBody"></tbody></table>
        </div>
        <div class="se-empty" id="pEmpty" style="display:none;">No students match these filters.</div>
        <div class="se-pager" id="pPager"></div>
    </div>

    <!-- Candidates: 2026+ students NOT yet in the pipeline, with their payments -->
    <div id="paneD" style="display:none;">
        <div class="se-toolbar">
            <input type="text" id="dq" class="se-in" placeholder="Search name or student number&hellip;" />
            <select id="dPay" class="se-sel" onchange="loadCand(1)">
                <option value="paid">Paid something (any amount)</option>
                <option value="partial">Partial payers &mdash; under UGX 100,000</option>
                <option value="eligible">Fully eligible &mdash; UGX 100,000+</option>
                <option value="none">No payment yet</option>
                <option value="">All 2026+ not in pipeline</option>
            </select>
            <button type="button" class="se-btn se-btn--p" onclick="loadCand(1)">Search</button>
            <button type="button" class="se-btn" onclick="qs('dq').value='';loadCand(1)">Reset</button>
        </div>
        <div class="se-meta" id="dMeta">Loading&hellip;</div>
        <div class="se-tblwrap">
            <table class="se-tbl"><thead><tr><th>Student</th><th>Student No.</th><th>Programme</th><th>Campus</th><th>Year</th><th>Paid</th><th></th></tr></thead><tbody id="dBody"></tbody></table>
        </div>
        <div class="se-empty" id="dEmpty" style="display:none;">No students match this filter.</div>
        <div class="se-pager" id="dPager"></div>
    </div>

    <!-- Complaints -->
    <div id="paneC" style="display:none;">
        <div class="se-toolbar">
            <select id="cStatus" class="se-sel" onchange="loadComplaints()">
                <option value="">Open complaints</option>
                <option value="SUBMITTED">Submitted</option>
                <option value="UNDER_REVIEW">Under review</option>
                <option value="RESPONDED">Responded</option>
                <option value="RESOLVED">Resolved</option>
                <option value="CLOSED">Closed</option>
            </select>
        </div>
        <div class="se-tblwrap">
            <table class="se-tbl"><thead><tr><th>Student</th><th>Category</th><th>Details</th><th>Status</th><th>Created</th><th></th></tr></thead><tbody id="cBody"></tbody></table>
        </div>
        <div class="se-empty" id="cEmpty" style="display:none;">No complaints.</div>
    </div>
</div>

<!-- Create email modal -->
<div class="se-ov" id="ov" onclick="closeM()"></div>
<div class="se-modal" id="mCreate" role="dialog" aria-modal="true">
    <div class="se-modal__h"><span class="se-modal__t">Create University Email</span><button type="button" class="se-modal__x" onclick="closeM()">&times;</button></div>
    <div class="se-modal__b">
        <div class="se-msg" id="mMsg"></div>
        <div id="mWho" style="font-size:12.5px;color:#64748b;margin-bottom:6px;"></div>
        <label class="se-fl">University email address</label>
        <input type="text" id="mEmail" class="se-fi" placeholder="e.g. jdoe25@mru.ac.ug" autocomplete="off" />
        <label class="se-fl">Temporary password</label>
        <input type="text" id="mPw" class="se-fi" placeholder="e.g. Mru@2026" autocomplete="off" />
        <label class="se-fl">Notes (optional)</label>
        <input type="text" id="mNotes" class="se-fi" autocomplete="off" />
    </div>
    <div class="se-modal__f">
        <button type="button" class="se-btn" onclick="closeM()">Cancel</button>
        <button type="button" class="se-btn se-btn--p" id="mSave" onclick="saveCreate()">Create &amp; make ready</button>
    </div>
</div>

<!-- Complaint respond modal -->
<div class="se-modal" id="mResp" role="dialog" aria-modal="true">
    <div class="se-modal__h"><span class="se-modal__t">Respond to complaint</span><button type="button" class="se-modal__x" onclick="closeM()">&times;</button></div>
    <div class="se-modal__b">
        <div class="se-msg" id="rMsg"></div>
        <div id="rWho" style="font-size:12.5px;color:#64748b;margin-bottom:6px;"></div>
        <label class="se-fl">Status</label>
        <select id="rStatus" class="se-fi">
            <option value="UNDER_REVIEW">Under review</option>
            <option value="RESPONDED">Responded</option>
            <option value="RESOLVED">Resolved</option>
            <option value="CLOSED">Closed</option>
        </select>
        <label class="se-fl">Response to student</label>
        <textarea id="rText" class="se-fi" rows="3"></textarea>
    </div>
    <div class="se-modal__f"><button type="button" class="se-btn" onclick="closeM()">Cancel</button><button type="button" class="se-btn se-btn--p" onclick="saveResp()">Send update</button></div>
</div>

<!-- 360 Manage modal -->
<div class="se-modal se-modal--wide" id="mManage" role="dialog" aria-modal="true">
    <div class="se-modal__h"><span class="se-modal__t" id="gTitle">Manage student</span><button type="button" class="se-modal__x" onclick="closeM()">&times;</button></div>
    <div class="se-modal__b" id="gBody" style="max-height:72vh;overflow:auto;"><div style="text-align:center;color:#94a3b8;padding:30px">Loading&hellip;</div></div>
</div>

<style>
.se-modal--wide{max-width:640px;}
.se-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border-radius:0;}
.se-b--pending{background:#fff3cd;color:#92610a;}.se-b--ready{background:#e8f0fe;color:#1d4ed8;}.se-b--done{background:#e6f4ea;color:#15803d;}.se-b--muted{background:#f1f5f9;color:#94a3b8;}.se-b--verified{background:#e6f4ea;color:#15803d;}
.se-pay{display:inline-block;padding:1px 7px;font-size:11px;font-weight:700;font-variant-numeric:tabular-nums;}
.se-pay--full{background:#e6f4ea;color:#15803d;}.se-pay--part{background:#fff3cd;color:#b45309;}.se-pay--none{background:#f1f5f9;color:#94a3b8;}
.g-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px 14px;margin:0 0 14px;}
.g-grid div{font-size:12px;padding:5px 0;border-bottom:1px dashed #eef2f7;}
.g-grid span{color:#94a3b8;text-transform:uppercase;font-size:9.5px;font-weight:700;letter-spacing:.3px;display:block;}
.g-grid b{color:#05275C;font-weight:700;word-break:break-word;}
.g-sec{margin:14px 0 8px;font-size:11px;font-weight:800;color:#05275C;text-transform:uppercase;letter-spacing:.4px;padding-bottom:5px;border-bottom:1px solid #eef2f7;}
.g-tl{list-style:none;padding:0;margin:0 0 8px;}
.g-tl li{font-size:12px;padding:4px 0;color:#475569;display:flex;justify-content:space-between;gap:10px;}
.g-tl li b{color:#05275C;}
.g-act{display:flex;flex-wrap:wrap;gap:7px;margin:10px 0 4px;}
.g-abtn{border:1px solid #dde1e6;background:#fff;padding:7px 11px;font-size:12px;font-weight:700;cursor:pointer;color:#374151;}
.g-abtn:hover{border-color:#174DA4;color:#174DA4;}
.g-abtn--p{background:#05275C;color:#fff;border-color:#05275C;}.g-abtn--p:hover{background:#174DA4;color:#fff;}
.g-abtn--d{color:#b91c1c;border-color:#fbc4c4;}.g-abtn--d:hover{background:#b91c1c;color:#fff;}
.g-log{max-height:150px;overflow:auto;border:1px solid #eef2f7;}
.g-log div{font-size:11px;padding:5px 9px;border-bottom:1px solid #f5f7fa;color:#475569;}
.g-log div b{color:#05275C;}.g-log div span{color:#94a3b8;float:right;}
</style>

<script type="text/javascript">
(function(){
'use strict';
var st={q:'',stage:'',verif:'',prog:'',page:1,ps:25};
function qs(id){return document.getElementById(id);}
function esc(s){return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'):'';}
function fmt(n){return (parseInt(n,10)||0).toLocaleString('en-US');}
function ajax(m,p,cb){var x=new XMLHttpRequest();x.open('POST','StudentEmailController.aspx/'+m,true);x.setRequestHeader('Content-Type','application/json; charset=utf-8');x.onload=function(){try{var o=JSON.parse(x.responseText);cb(typeof o.d==='string'?JSON.parse(o.d):o.d);}catch(e){cb({success:false,message:'Parse error'});}};x.onerror=function(){cb({success:false,message:'Network error'});};x.send(JSON.stringify(p||{}));}
function topMsg(m,ok){var e=qs('topMsg');e.textContent=m;e.className='se-msg '+(ok?'se-msg--ok':'se-msg--err');e.style.display='block';setTimeout(function(){e.style.display='none';},5000);}

// URL state
function readUrl(){var u=new URLSearchParams(location.search||'');st.q=u.get('q')||'';st.stage=u.get('stage')||'';st.verif=u.get('verif')||'';st.prog=u.get('prog')||'';st.page=Math.max(1,parseInt(u.get('page'),10)||1);}
function syncUrl(){var u=new URLSearchParams();if(st.q)u.set('q',st.q);if(st.stage)u.set('stage',st.stage);if(st.verif)u.set('verif',st.verif);if(st.prog)u.set('prog',st.prog);if(st.page>1)u.set('page',st.page);history.replaceState(null,'',(u.toString()?'?'+u.toString():location.pathname));}

function loadKpis(){ajax('Stats',{},function(r){if(!r||!r.success)return;var k=[['eligible','Eligible (100k+)','info'],['partial','Paid < 100k','warn'],['total','In Pipeline',''],['pending','Pending','warn'],['ready','Ready','ready'],['quiz','Quiz Passed','info'],['activated','Activated','ok'],['completed','Completed','ok'],['complaints','Open Complaints','warn'],['successRate','Success %','ok']];var h='';k.forEach(function(x){var raw=r[x[0]];var disp=(x[0]==='successRate')?((raw||0)+'%'):fmt(raw);h+='<div class="se-kpi'+(x[2]?' se-kpi--'+x[2]:'')+'"><div class="se-kpi__v">'+disp+'</div><div class="se-kpi__l">'+x[1]+'</div></div>';});qs('kpis').innerHTML=h;});}
function payBadge(p){p=parseInt(p,10)||0;var c=p>=100000?'full':(p>0?'part':'none');return '<span class="se-pay se-pay--'+c+'">'+(p>0?('UGX '+fmt(p)):'—')+'</span>';}

function stageBadge(s){var m={PENDING_CREATION:['pending','Pending creation'],READY_FOR_COLLECTION:['ready','Ready for collection'],EMAIL_CREATED:['ready','Email created'],COMPLETED:['done','Completed']};var x=m[s]||['muted',s||'-'];return '<span class="se-badge se-b--'+x[0]+'">'+esc(x[1])+'</span>';}

window.doSearch=function(page){st.q=qs('fq').value.trim();st.stage=qs('fStage').value;st.verif=qs('fVerif').value;st.prog=qs('fProg').value;st.page=page||1;syncUrl();
qs('pMeta').textContent='Loading…';
ajax('Search',{q:st.q,stage:st.stage,campus:'',programme:st.prog,year:'',verification:st.verif,page:st.page,pageSize:st.ps},function(r){
 if(!r||!r.success){qs('pMeta').textContent=(r&&r.message)||'Error';return;}
 qs('pMeta').textContent=fmt(r.total)+' student'+(r.total===1?'':'s')+(r.pageCount>1?(' · page '+r.page+' of '+r.pageCount):'');
 var b=qs('pBody');b.innerHTML='';qs('pEmpty').style.display=r.rows.length?'none':'block';
 r.rows.forEach(function(x){var canCreate=(x.stage==='PENDING_CREATION');var rg=x.regno.replace(/'/g,"");var tr=document.createElement('tr');
  tr.innerHTML='<td><strong>'+esc(x.name||'-')+'</strong></td><td>'+esc(x.regno)+'</td><td>'+esc(x.programme||'-')+'</td><td>'+esc(x.campus)+'</td><td>'+esc(x.year)+'</td><td>'+payBadge(x.paid)+'</td><td>'+(x.email?esc(x.email):'<span style="color:#cbd5e1">—</span>')+'</td><td>'+stageBadge(x.stage)+'</td><td>'+(x.verification==='VERIFIED'?'<span class="se-badge se-b--verified">Verified</span>':'<span class="se-badge se-b--muted">—</span>')+'</td><td style="color:#94a3b8">'+esc(x.updated||x.created)+'</td><td style="white-space:nowrap">'+(canCreate?'<span class="se-act" onclick="openCreate(\''+rg+'\',\''+esc(x.name).replace(/'/g,"")+'\')">Create</span> · ':'')+'<span class="se-act" onclick="openManage(\''+rg+'\')">Manage</span></td>';
  b.appendChild(tr);});
 renderPager(r.page,r.pageCount);
});};
function renderPager(page,pc){var el=qs('pPager');el.innerHTML='';if(pc<=1)return;function b(t,pg,dis,act){var x=document.createElement('button');x.textContent=t;if(act)x.className='active';if(dis)x.disabled=true;else x.onclick=function(){doSearch(pg);};el.appendChild(x);}b('‹',page-1,page<=1);var f=Math.max(1,page-2),t=Math.min(pc,page+2);for(var i=f;i<=t;i++)b(String(i),i,false,i===page);b('›',page+1,page>=pc);}
window.resetF=function(){qs('fq').value='';qs('fStage').value='';qs('fVerif').value='';qs('fProg').value='';st={q:'',stage:'',verif:'',prog:'',page:1,ps:25};doSearch(1);};

window.genEligible=function(){var btn=qs('btnGen');btn.disabled=true;btn.textContent='Generating…';ajax('GenerateEligible',{},function(r){btn.disabled=false;btn.innerHTML='<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg> Generate Eligible Students';if(r&&r.success){topMsg(r.message,true);loadKpis();doSearch(1);}else topMsg((r&&r.message)||'Failed',false);});};

// Create modal
var _cReg='';
window.openCreate=function(reg,name){_cReg=reg;qs('mWho').textContent=name+' · '+reg;qs('mEmail').value='';qs('mPw').value='';qs('mNotes').value='';qs('mMsg').style.display='none';qs('ov').style.display='block';qs('mCreate').style.display='block';};
window.saveCreate=function(){var em=qs('mEmail').value.trim(),pw=qs('mPw').value.trim();if(!em||!pw){modMsg('mMsg','Email and temporary password are required.',false);return;}qs('mSave').disabled=true;ajax('CreateEmail',{regno:_cReg,email:em,tempPw:pw,notes:qs('mNotes').value.trim()},function(r){qs('mSave').disabled=false;if(r&&r.success){closeM();topMsg(r.message,true);loadKpis();doSearch(st.page);}else modMsg('mMsg',(r&&r.message)||'Failed',false);});};
function modMsg(id,m,ok){var e=qs(id);e.textContent=m;e.className='se-msg '+(ok?'se-msg--ok':'se-msg--err');e.style.display='block';}
window.closeM=function(){qs('ov').style.display='none';qs('mCreate').style.display='none';qs('mResp').style.display='none';qs('mManage').style.display='none';};

// Tabs
window.setTab=function(t){qs('tabPipe').classList.toggle('active',t==='pipe');qs('tabCand').classList.toggle('active',t==='cand');qs('tabComp').classList.toggle('active',t==='comp');qs('paneP').style.display=t==='pipe'?'block':'none';qs('paneD').style.display=t==='cand'?'block':'none';qs('paneC').style.display=t==='comp'?'block':'none';if(t==='comp')loadComplaints();if(t==='cand')loadCand(1);};

// ── Candidates (2026+ not in pipeline, with payments) ──
var _dPage=1;
window.loadCand=function(page){_dPage=page||1;qs('dMeta').textContent='Loading…';
 ajax('Candidates',{q:qs('dq').value.trim(),payFilter:qs('dPay').value,page:_dPage,pageSize:25},function(r){
  if(!r||!r.success){qs('dMeta').textContent=(r&&r.message)||'Error';return;}
  qs('dMeta').textContent=fmt(r.total)+' student'+(r.total===1?'':'s')+(r.pageCount>1?(' · page '+r.page+' of '+r.pageCount):'');
  var b=qs('dBody');b.innerHTML='';qs('dEmpty').style.display=r.rows.length?'none':'block';
  r.rows.forEach(function(x){var rg=x.regno.replace(/'/g,"");var nm=esc(x.name).replace(/'/g,"");var tr=document.createElement('tr');
   tr.innerHTML='<td><strong>'+esc(x.name||'-')+'</strong></td><td>'+esc(x.regno)+'</td><td>'+esc(x.programme||'-')+'</td><td>'+esc(x.campus)+'</td><td>'+esc(x.year)+'</td><td>'+payBadge(x.paid)+'</td><td style="white-space:nowrap"><span class="se-act" onclick="addCand(\''+rg+'\',\''+nm+'\')">+ Add to pipeline</span></td>';
   b.appendChild(tr);});
  var el=qs('dPager');el.innerHTML='';if(r.pageCount>1){function bb(t,pg,dis,act){var y=document.createElement('button');y.textContent=t;if(act)y.className='active';if(dis)y.disabled=true;else y.onclick=function(){loadCand(pg);};el.appendChild(y);}bb('‹',r.page-1,r.page<=1);var f=Math.max(1,r.page-2),tt=Math.min(r.pageCount,r.page+2);for(var i=f;i<=tt;i++)bb(String(i),i,false,i===r.page);bb('›',r.page+1,r.page>=r.pageCount);}
 });};
window.addCand=function(reg,name){if(!confirm('Add '+name+' ('+reg+') to the email pipeline?'))return;ajax('AddToPipeline',{regno:reg,note:'Added from Candidates'},function(r){if(r&&r.success){topMsg(r.message,true);loadCand(_dPage);loadKpis();}else topMsg((r&&r.message)||'Failed',false);});};

// ── 360 Manage ──
var _gReg='';
window.openManage=function(reg){_gReg=reg;qs('gTitle').textContent='Manage · '+reg;qs('gBody').innerHTML='<div style="text-align:center;color:#94a3b8;padding:30px">Loading…</div>';qs('ov').style.display='block';qs('mManage').style.display='block';
 ajax('Detail',{regno:reg},function(r){if(!r||!r.success){qs('gBody').innerHTML='<div class="se-msg se-msg--err" style="display:block">'+esc((r&&r.message)||'Could not load')+'</div>';return;}renderDetail(r);});};
function tl(label,v){return v?('<li>'+label+' <b>'+esc(v)+'</b></li>'):('<li style="opacity:.5">'+label+' <b>—</b></li>');}
function renderDetail(r){var d=r.record;var h='';
 h+='<div class="g-grid">'
  +'<div><span>Name</span><b>'+esc(d.name||'-')+'</b></div><div><span>Student No.</span><b>'+esc(d.regno)+'</b></div>'
  +'<div><span>Programme</span><b>'+esc(d.programme||'-')+'</b></div><div><span>Campus · Year</span><b>'+esc(d.campus)+' · '+esc(d.year)+'</b></div>'
  +'<div><span>Paid</span><b>'+payBadge(d.paid)+'</b></div><div><span>Stage</span><b>'+stageBadge(d.stage)+'</b></div>'
  +'<div><span>Email</span><b>'+(d.email?esc(d.email):'—')+'</b></div><div><span>Temp password</span><b>'+(d.pw?esc(d.pw):'—')+'</b></div>'
  +'<div><span>Verification</span><b>'+(d.verification==='VERIFIED'?'<span class="se-badge se-b--verified">Verified</span>':esc(d.verification||'—'))+'</b></div><div><span>Password changed</span><b>'+esc(d.pwChanged)+'</b></div>'
  +'</div>';
 if(d.notes)h+='<div style="font-size:12px;background:#f8fafc;border:1px solid #eef2f7;padding:8px 10px;margin-bottom:10px"><b>Notes:</b> '+esc(d.notes)+'</div>';
 h+='<div class="g-act">'
  +(d.stage==='PENDING_CREATION'?'<button type="button" class="g-abtn g-abtn--p" onclick="closeM();openCreate(\''+_gReg+'\',\''+esc(d.name).replace(/\x27/g,"")+'\')">Create email</button>':'')
  +'<button type="button" class="g-abtn" onclick="gStage()">Change stage</button>'
  +'<button type="button" class="g-abtn" onclick="gPw()">Reset password</button>'
  +'<button type="button" class="g-abtn g-abtn--d" onclick="gDel()">Remove</button>'
  +'</div>';
 h+='<div class="g-sec">Journey timeline</div><ul class="g-tl">'
  +tl('Added to pipeline',d.t_created)+tl('Email created',d.t_email)+tl('Learn done',d.t_edu)+tl('Gmail guide done',d.t_gmail)+tl('Quiz passed',d.t_quiz)+tl('Credentials viewed',d.t_viewed)+tl('Verified (Active Student)',d.t_verified)+tl('Completed',d.t_completed)+'</ul>';
 if(r.complaints&&r.complaints.length){h+='<div class="g-sec">Complaints</div>';r.complaints.forEach(function(c){h+='<div style="font-size:12px;padding:5px 0;border-bottom:1px dashed #eef2f7"><b>'+esc(c.category)+'</b> — '+esc(c.status)+' <span style="color:#94a3b8">'+esc(c.at)+'</span>'+(c.response?'<br><span style="color:#0b5c3a">'+esc(c.response)+'</span>':'')+'</div>';});}
 h+='<div class="g-sec">Activity log</div><div class="g-log">';
 (r.activity||[]).forEach(function(a){h+='<div><b>'+esc((a.action||'').replace(/_/g,' '))+'</b>'+(a.detail?(' — '+esc(a.detail)):'')+' <span>'+esc(a.at)+' · '+esc(a.actor)+'</span></div>';});
 if(!(r.activity||[]).length)h+='<div style="color:#94a3b8">No activity yet.</div>';
 h+='</div>';
 qs('gBody').innerHTML=h;}
window.gStage=function(){var s=prompt('Set stage to one of:\nPENDING_CREATION, READY_FOR_COLLECTION, EMAIL_CREATED, COMPLETED, SUSPENDED','READY_FOR_COLLECTION');if(!s)return;var note=prompt('Reason / note (optional):','')||'';ajax('SetStatus',{regno:_gReg,stage:s.trim().toUpperCase(),note:note},function(r){if(r&&r.success){topMsg(r.message,true);openManage(_gReg);loadKpis();doSearch(st.page);}else topMsg((r&&r.message)||'Failed',false);});};
window.gPw=function(){var p=prompt('New temporary password for this student:','Mru@2026');if(!p||!p.trim())return;ajax('SetPassword',{regno:_gReg,tempPw:p.trim()},function(r){if(r&&r.success){topMsg(r.message,true);openManage(_gReg);}else topMsg((r&&r.message)||'Failed',false);});};
window.gDel=function(){if(!confirm('Remove '+_gReg+' from the email pipeline? This deletes the record.'))return;var note=prompt('Reason (optional):','')||'';ajax('DeleteRecord',{regno:_gReg,note:note},function(r){if(r&&r.success){closeM();topMsg(r.message,true);loadKpis();doSearch(st.page);}else topMsg((r&&r.message)||'Failed',false);});};

// Complaints
var _rId=0;
window.loadComplaints=function(){ajax('Complaints',{status:qs('cStatus').value},function(r){var b=qs('cBody');b.innerHTML='';if(!r||!r.success){return;}qs('cEmpty').style.display=r.complaints.length?'none':'block';r.complaints.forEach(function(c){var tr=document.createElement('tr');tr.innerHTML='<td><strong>'+esc(c.regno)+'</strong></td><td>'+esc(c.category)+'</td><td style="max-width:280px">'+esc(c.description||'')+'</td><td><span class="se-badge se-b--'+(c.status==='RESOLVED'||c.status==='CLOSED'?'done':'ready')+'">'+esc(c.status)+'</span></td><td style="color:#94a3b8">'+esc(c.created)+'</td><td><span class="se-act" onclick="openResp('+c.id+',\''+esc(c.regno)+'\',\''+esc(c.category)+'\')">Respond</span></td>';b.appendChild(tr);});});};
window.openResp=function(id,reg,cat){_rId=id;qs('rWho').textContent=reg+' · '+cat;qs('rText').value='';qs('rMsg').style.display='none';qs('ov').style.display='block';qs('mResp').style.display='block';};
window.saveResp=function(){ajax('RespondComplaint',{id:_rId,status:qs('rStatus').value,response:qs('rText').value.trim()},function(r){if(r&&r.success){closeM();loadComplaints();loadKpis();}else modMsg('rMsg',(r&&r.message)||'Failed',false);});};

// init
(function(){readUrl();qs('fq').value=st.q;qs('fStage').value=st.stage;qs('fVerif').value=st.verif;
 qs('fq').addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();doSearch(1);}});
 loadKpis();
 ajax('Filters',{},function(r){if(r&&r.success){var s=qs('fProg');(r.programmes||[]).forEach(function(p){var o=document.createElement('option');o.value=p.code;o.textContent=p.name;s.appendChild(o);});qs('fProg').value=st.prog;}
  doSearch(st.page);});
})();
})();
</script>
</asp:Content>
